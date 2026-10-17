# Assessment C: orchestration and protocol tooling (lens: step 3 and the glue around steps 1–2)

Assessor C, 2026-10-16. Read-only investigation; nothing was modified. Files actually read are cited
inline. Short names used below: **lab** = `~/aiseminar`, **skill** = `~/.claude/skills/astra`,
**SR** = `~/size-ramsey`, **FGB** = `~/five-generator-betti`.

---

## 0. What I found that shapes the design (facts, with sources)

1. **The protocol's state is spread over five places, and none of them knows about the others.**
   `STATUS.yaml` holds the ladder (`lab/agents/shared/claim_0004/STATUS.yaml`), the Astra job
   lives in `~/.claude/astra/jobs/<project>/<job>/status.json`, the verbatim reply in
   `lab/agents/astra/transcripts/`, the request bodies in `claim_NNNN/requests/*.md` (a convention
   that appeared on 2026-10-16 and isn't documented in AGENTS.md), and the Lean facts in the repo
   (`SR/formalization.yaml`, `SR/CORRESPONDENCE.md` §10, `SR/SizeRamsey/NOTES.md`). On
   2026-10-16 the orchestrator joined them by memory. Example: claim_0004's history entry
   "adversary 20261016T191015 (answered)" is a free-text pointer that no program checks.
2. **`aimath promote` validates almost nothing** (`lab/src/aimath/claims.py`). It checks that
   the status name is known, that the move is legal under `TRANSITIONS`, and that the evidence
   string is non-empty. It doesn't check that any evidence file exists, doesn't record a commit,
   and doesn't enforce any row of the AGENTS.md §3 table. It writes with `yaml.safe_dump`, which is
   harmless here because existing STATUS.yaml files have no comments. It *is* the right write
   primitive. `make promote EVIDENCE="..."` routes long evidence strings through make and shell
   quoting, which is fragile, so call `python -m aimath.cli promote` with argv instead.
3. **There are two Astra front-ends with different transcript headers.** `lab/agents/astra/invoke.py`
   is blocking. It writes `<!-- model: … role: … effort: … date: … prompt: X.prompt.md -->` and a
   `.prompt.md` sibling. The skill's `astra.py --out` writes on completion, from the detached
   worker, `<!-- astra: model=… effort=… status=… thread=… job=… -->` (`astra.py` lines 323–329).
   All eleven 2026-10-16 transcripts (`20261016T19*.md`) use the **skill** header and the name
   pattern `<batchstamp>_<role>[N]_<claim>.md`, where `reviewer2` and `reviewer3` number the
   confirming passes, and none has a `.prompt.md` sibling. The request bodies went to
   `claim_0004/requests/`. In practice, then, the lab convention is now "skill `--out` into
   transcripts/, body in requests/". AGENTS.md still names `invoke.py`. `lab/scripts/astra_fanout.py`
   is a foreground ThreadPool over `invoke.py`. It can't be resumed and breaks the "never poll in
   the foreground" rule, so it should be retired in favour of the skill.
4. **`--out` is the key robustness lever.** `astra.py` writes the `--out` file from the detached
   worker when the turn completes. So if the orchestrator passes `--out
   lab/agents/astra/transcripts/<name>.md` at submit time, the verbatim filing happens even if every
   Claude session is dead. Collection then only needs to verify and parse; it never needs to copy.
5. **Independent-prover isolation was done by cwd.** The claim_0004 prover and novelty jobs ran
   with `cwd=/private/tmp/.../scratchpad/prover_ramsey`, containing only `STATEMENT.md`
   (`~/.claude/astra/jobs/size-ramsey/*/status.json`; `claim_0004/requests/prover.md`: "it is the
   only file"). A scratchpad is session-scoped, so that isolation directory is lost. It belongs in
   the run directory. Whether the Codex read-only sandbox actually prevents reads *outside* cwd is
   unverified. `events.jsonl` logs Astra's command executions, so it can be scanned mechanically.
6. **Verdict lines are parseable but not uniform.** Across the 2026-10-16 transcripts I saw
   `VERDICT: ACCEPT  ` (trailing spaces), `` `CONFIDENCE: 0.78` `` (backticked), and
   `**CONFIDENCE: 0.89. Subagents used: 3…**` (bold, with trailing prose, `SR/docs/astra/2026-10-16_lean_plan.md`).
   The independent prover gives per-theorem confidences. A parser must strip `*`, `` ` `` and
   whitespace and take the last match.
7. **The metadata is already stale.** `SR/formalization.yaml` says `sorry_count: 12`, while
   CONTEXT.md says main has 69 after bootstrap. `SR/CORRESPONDENCE.md` §10 records only the
   "scaffold" commit. FGB's §11 "Build and audit record" is empty, and FGB numbers its sections
   differently (§10 is "Exclusions"). A gate checker has to locate the table by heading text,
   not by section number, and should treat a stale `sorry_count` as a blocking finding. Even the
   counts disagree: CONTEXT.md says 69, while `grep -rEwn sorry --include='*.lean'` on SR main
   (b17d1fa) gives 67 tokens, 5 of them the deliberate ones in `Challenge.lean`. The gate must say
   which count it uses (token grep, scoped) and the judge reports both that count and the
   build-warning count.
8. **Records and permitted axioms are already machine-readable.** `SR/comparator.json` has
   `theorem_names` (the five records) and `permitted_axioms`. FGB additionally has
   `comparator.all-targets.json`, which includes Theorem W and "must fail until it is proved"
   (`FGB/Targets/FiniteWidth.lean`). CI runs the comparator job (`SR/.github/workflows/ci.yml`
   line 88). The gate can therefore get comparator evidence from `gh run list --commit <sha>`
   without running Linux locally.
9. **For the Lean step, AGENTS.md §3 expects `lean/<claim>/CORRESPONDENCE.md` inside the lab**
   (claim_0003 did that: `lab/lean/claim_0003`). SR and FGB are external repos, and STATUS.yaml has
   no field naming them. The gate needs one: `formalization: {repo, commit}` (see §4).
10. **The two repos have the same layout but different status vocabularies.** SR's NOTES.md uses
    stub/proved/assembled. FGB's uses stub/frozen/def (from stubs). Sorry inventories should come
    from `lake build` warnings ("declaration uses `sorry`", one line each; see the scratchpad
    `B_betti_build.log`), not from NOTES.md.

---

## 1. Summary of recommendations, ranked by value per unit of effort

| # | Recommendation | Value | Effort | Where |
|---|---|---|---|---|
| 1 | **`aimath gate`**: a protocol gate checker that reads only files and prints which promotion is permitted now and what blocks the others (JSON plus a one-screen table) | very high: replaces orchestrator memory with a check | ~300 py + ~200 test lines | lab `src/aimath/gate.py` |
| 2 | **Run directory + `run.json` manifest + `proofrun submit/wait/collect`**: submit with `--out` straight into `transcripts/`, then one backgrounded `wait` per stage that ends in `collect` and a summary table | very high: makes runs resumable, keeps raw transcripts out of the orchestrator's context | ~450 py | skill `~/.claude/skills/proofrun/scripts/proofrun.py` |
| 3 | **Brief renderer + four templates** (prover, adversary with fresh-framing slots, reviewer, independent prover/statement reconstructor) using the lab role prompts verbatim | high: prompts become reproducible, isolation and fresh framing become mechanical | ~120 py + templates | skill `templates/`, role text from `lab/agents/astra/prompts/` |
| 4 | **`aimath promote --gate`** plus structured `evidence_paths` / `commit` in history entries | high: blocks silent promotion; small change | ~50 py | lab `claims.py`, `cli.py` |
| 5 | **Emitters**: RESPONSE_CLAUDE.md skeleton (numbered from the parsed findings), REVIEW_ASTRA.md section stub, EVIDENCE.md Lean-audit block, CORRESPONDENCE build-table rows, formalization.yaml numeric fields, journal section | medium-high: saves about 2–5k orchestrator tokens per round and prevents format drift | ~250 py | lab `src/aimath/packet.py` (lab files); skill (repo files) |
| 6 | **`proofrun summary`**: one table per run, or all runs | medium: cheap to build once the manifest exists | ~80 py | skill |
| 7 | **W route: `proofrun open-claim`** wrapping `aimath claim` and promotions SPECULATIVE→…→PROOF_ATTEMPT, each one gated | medium | ~40 py | skill, calling lab |
| 8 | Housekeeping: retire `lab/scripts/astra_fanout.py`; amend AGENTS.md §2 to name the skill's submit/wait as the sanctioned transport, and document `requests/` and the transcript naming; add `formalization:` to STATUS.yaml | medium (consistency) | doc edits | lab (Ben's call) |

**Build order:** 1 → 4 → 2 → 3 → 5 → 6 → 7. The gate is useful on day one against the existing
claim_0004 and claim_0005 packets, before any run tooling exists. Run it now and it would
correctly say "VERIFIED → FORMALLY_VERIFIED blocked: 62 sorries outside Challenge, yaml sorry_count stale (12), no
§10 row at HEAD, no comparator CI success at HEAD."

**Deliberate split (searcher ≠ verifier):**
- `proofrun` *applies and orchestrates*: it stages Astra's Lean text on a branch and drives the jobs.
- The repo-local judge (`scripts/judge.py`, designed by the other assessors; I only fix its JSON
  contract in §3.3) *judges one commit*.
- `aimath gate` *decides admissibility of a status change* from files alone.

None of the three imports another. The gate re-runs nothing expensive itself. It reads
`judge.json` but recomputes the cheap invariants (the sorry grep, the Challenge hash, the
`git rev-parse`) independently, so a bug in the judge can't produce a promotion.

---

## 2. Proposed tools

### T1. `aimath gate` (lab)

- **Purpose:** for one claim, evaluate every rule of AGENTS.md §3/§4 for the *next* legal
  transitions and say PERMITTED / BLOCKED (with reasons) / NEEDS-JUDGMENT (with the
  judgment items).
- **Inputs:** `claim_NNNN/` (STATUS.yaml, all .md files), `agents/astra/transcripts/`, optional
  `agents/runs/*/run.json` that reference the claim, and for Lean claims the repo named by
  `STATUS.yaml: formalization.repo` (git, formalization.yaml, CORRESPONDENCE.md, comparator.json,
  `judge/*.json` from the run), and `gh` for CI conclusions (optional; reported as UNKNOWN if
  offline).
- **Outputs:** stdout table (≤ 15 lines); `--json` gives `{claim, status, transitions:[{to,
  verdict, checks:[{id, ok, detail, kind: mechanical|judgment}]}]}`; exit 0 if the requested
  `--to` is permitted, 1 if blocked, 3 if only judgment items remain.
- **CLI:** `python -m aimath.cli gate claim_0004 [--to FORMALLY_VERIFIED] [--json] [--repo-commit HEAD]`;
  `make gate CLAIM=claim_0004 [TO=…]`.
- **Sketch** (Python, lab venv, ~300 lines): a rule table keyed by (from, to). Each rule is a list
  of small pure functions `check(ctx) -> Check`. The context loader parses STATUS.yaml; lists
  transcripts whose name matches `_<role>\d*_<claim>(\b|_)`; and parses each transcript's header
  (`<!-- astra: … -->` or the legacy `<!-- model: … -->`), its numbered findings (`^\s*(\d+)\.\s`
  at top level), and its last `VERDICT:`/`CONFIDENCE:` match after stripping `*` and `` ` ``. It
  parses RESPONSE_CLAUDE.md sections (`^## Response to …`) and the numbers or ranges answered
  (`^(\d+)(?:[–-](\d+))?\.`). For Lean claims it runs `git -C repo rev-parse HEAD`,
  `git status --porcelain`, the scoped sorry grep, and a CORRESPONDENCE table scan.
  Rules are in §4.
- **Failure modes:** heading drift in repo docs (mitigation: locate tables by header regex
  `^\|\s*date\s*\|\s*command\s*\|\s*commit`); transcripts misnamed by hand (the gate lists
  "unattributed transcripts mentioning claim_NNNN" as a warning); `gh` unauthenticated (comparator
  UNKNOWN, which blocks FORMALLY_VERIFIED unless waived; see §4).
- **Tests:** fixture packets built from copies of claim_0004 and claim_0005 in `tmp_path`, with
  synthetic transcripts. Golden expectations: claim_0004 today gives FORMALLY_VERIFIED BLOCKED with
  exactly the reasons {sorry>0, yaml stale, no §10 row at HEAD, comparator unknown}. Deleting
  the reviewer3 transcript makes a re-promotion to VERIFIED BLOCKED ("latest reviewer verdict
  ACCEPT_WITH_FIXES"). A RESPONSE missing finding 7 gives BLOCKED "adversary 20261016T191015
  finding 7 unanswered". Parser unit tests use the verdict-format zoo from §0.6.

### T2. `proofrun` core: `init`, `submit`, `wait`, `collect`, `status` (skill)

- **Purpose:** represent a run on disk, submit Astra jobs with deterministic names and `--out`
  filing, wait without foreground polling, and collect parsed verdicts into the manifest.
- **Inputs:** a repo `proofrun.toml` (§6) and the lab path (`$AIMATH_LAB`, default `~/aiseminar`).
- **CLI:**
  ```
  proofrun init --repo ~/size-ramsey --claim claim_0004 --kind lean [--slug sr-lean] → prints RUN dir
  proofrun brief RUN prove --stream A [--decls FILE] [--round N]   → writes briefs/<key>.md (no submit)
  proofrun submit RUN <stage> [--only KEY] [--effort xhigh] [--dry-run]
  proofrun wait RUN [--stage S] [--any]           # run with run_in_background: true; ends by running collect
  proofrun collect RUN                             # idempotent; parses replies; updates run.json
  proofrun status RUN | proofrun summary [RUN|--all]
  proofrun resubmit RUN KEY                        # dead/failed/timeout → KEY-retryN, same brief
  ```
- **Sketch** (stdlib Python 3.13, ~450 lines):
  - `submit` renders or loads `briefs/<key>.md`. It computes `stamp = now()` **once per stage
    batch**, as on 2026-10-16. For each job it builds the transcript base
    `lab/agents/astra/transcripts/<stamp>_<role>[N]_<claim-or-run-tag>`. It shells out to
    `astra.py submit -p <project> -t "<role>: <claim> r<round> <framing>" --effort … --cwd <cwd>
    --system <lab role prompt assembled> --prompt-file briefs/<key>.md --out <base>.md`, then
    parses `submitted <project>/<job>` from stdout. It copies the job's `prompt.md` to
    `<base>.prompt.md` immediately (the prompt is final at submit time) and appends the job record
    to `run.json` under an `fcntl.flock`.
  - The system prompt is `_common.md` plus `<role>.md` concatenated into `briefs/_system_<role>.md`.
    That is identical to what `invoke.py build_prompt` prepends, minus the claim inlining. Briefs
    reference packet paths instead (Astra reads them), and the independent prover gets no packet.
  - `wait` loops `astra.py wait <job>` over the stage's non-terminal jobs. Sequential waits cost
    max(turn time), not the sum. Then it calls `collect`. With `--any` it returns after the first
    terminal job, so the orchestrator can judge prover A while prover B still runs. Exit codes:
    0 all completed; 2 any failed/timeout/cancelled/dead; 3 `--timeout` elapsed. Its stdout is
    **only** the summary table (≤ 15 lines), never a reply.
  - `collect` does the following for each job. It reads `status.json`. For terminal jobs it
    verifies that `sha256(reply.md) == sha256(<base>.md)`. If `--out` failed (it only fires on
    `completed`), it files the reply itself for failed/timeout jobs as `<base>.FAILED.md` with the
    header, so negative results are recorded and never paraphrased. It parses verdict, confidence
    and the finding count. For prover jobs it counts fenced `lean decl=` blocks and `STATUS:`
    lines (§5.1 format). It scans `events.jsonl` for command executions, recording a
    `self_checked` flag if `lake env lean` ran and an `isolation_breach` flag if an
    independent-prover job touched `PROOF` or the repo path. It updates `run.json`.
  - `status` marks `dead` when status is `running` and `pid_alive(pid)` is false, using the same
    rule as `astra.py cmd_wait`.
- **Failure modes:**
  - the machine sleeps mid-turn: the job goes dead, `resubmit` handles it;
  - two background waits race on `run.json`: flock plus atomic rename;
  - a reply with no VERDICT: recorded `verdict: null`, flagged in the summary, never defaulted;
  - `--out` path collision at the same second: the stamp plus role plus N suffix is unique per
    batch, and `submit` refuses an existing path;
  - astra.py's interface changes: one adapter function, `_astra(args) -> (job_ref)`, and a
    contract test against `--dry-run`.
- **Tests:** a fake `ASTRA` (env `PROOFRUN_ASTRA`) stub script that creates a job dir with
  status.json, writes reply.md after N ms, and honours `--out`. The tests cover:
  submit → wait → collect end-to-end in `tmp_path`; dead-pid detection; idempotent `collect`
  (run twice, identical run.json); the flock race (two collects in parallel); the transcript name
  grammar matching the gate's regex (shared fixture).

### T3. `proofrun brief`: brief renderer and templates (skill)

- **Purpose:** produce the exact text Astra receives for each stage from templates (§5) plus
  run data. It enforces three things mechanically:
  1. **Distinct framings.** Every adversary job in a claim's history has a `framing_id`. A new
     adversary job must use an id not used before for this claim. A forced third round
     (§4 rule R-3RD) must use a framing from a *different family*.
  2. **Isolation for the independent prover.** It creates `RUN/isolated/<key>/` containing only
     `STATEMENT.md` (copied from `claim_NNNN/requests/statement.md`, or for Lean from
     CORRESPONDENCE §1 plus `Challenge.lean`). It records `ls -lR` and hashes, and sets `--cwd`
     to that directory.
  3. **No "probably right" language.** It refuses to render if the body matches
     `/(probably|likely|we believe|seems) (correct|right|true)|verified|has been checked/i`.
     This is AGENTS.md §2, "Astra is never told…". `--force` is available and logs the override.
- **Inputs:** template name, `run.json`, `proofrun.toml` (records, owned files, frozen files),
  optional decl list (from the judge's sorry inventory).
- **Sketch:** `string.Template` (`$name`) substitution, ~120 lines. The templates live in
  `skill/templates/` and the framings in `skill/templates/framings.toml`.
- **Tests:** golden renders; framing reuse refused; isolation directory contains exactly one file;
  the banned-phrase lint works.

### T4. `aimath promote --gate` (lab change)

- **Purpose:** make promotion impossible unless T1 says PERMITTED, or an override with a
  reason is recorded in history.
- **Interface:** `aimath promote claim_0004 FORMALLY_VERIFIED --evidence "…" --evidence-path
  PATH … [--commit SHA] [--override "reason"]`. A history entry gains optional keys
  `evidence_paths: [...]`, `commit:`, `gate: PERMITTED|OVERRIDE`, `run:`.
- **Can `make promote` be reused as is?** As the *write primitive*, yes: `claims.promote` is
  correct and its tests (`tests/test_tooling.py::test_claim_state_machine`) cover legality.
  As a *protocol enforcement point*, no: it validates only status name, legality and non-empty
  evidence. Add `gate=True` by default in the CLI path and keep the library default `False`, so
  the existing tests stand. Keep `EVIDENCE` free text for humans and add `evidence_paths` that
  the gate checks for existence.
- **Tests:** promote without gate approval raises; override writes `gate: OVERRIDE` plus the reason;
  the existing state-machine test still passes.

### T5. Emitters (lab `aimath packet …` for lab files; `proofrun emit …` for repo files)

All emitters are **append-only, idempotent** (keyed by transcript stamp or commit), and print the
diff they made. None of them writes a judgment; each leaves `TODO(claude)` markers that the gate
treats as blocking.

| Emitter | Writes | Content generated mechanically | Left to the orchestrator |
|---|---|---|---|
| `aimath packet respond-skel CLAIM TRANSCRIPT` | RESPONSE_CLAUDE.md: `## Response to <role> <stamp> (round N, YYYY-MM-DD)` then `k. TODO(claude): accepted / rejected / deferred: …` for every parsed finding k | numbering, header, transcript pointer | every answer |
| `aimath packet review-stub CLAIM TRANSCRIPT` | REVIEW_ASTRA.md: `## YYYY-MM-DD <role> (<path>)` + `VERDICT …, CONFIDENCE …` + one line per finding = its bold lead sentence (`^\d+\.\s+\*\*(.+?)\*\*`) | header, verdict line, lead sentences | condensation and corrections; marker `<!-- condensed: TODO -->` |
| `aimath packet evidence-lean CLAIM JUDGE_JSON` | EVIDENCE.md: `## YYYY-MM-DD Lean build and audit, <repo>@<sha12>` with a table (build exit, jobs, wall time, scoped sorry count, records × axioms, leanchecker, check-lean-sources, validate-formalization, comparator CI URL/conclusion) | all of it, from judge.json and gh | nothing |
| `proofrun emit correspondence RUN JUDGE_JSON` | repo `CORRESPONDENCE.md` build/audit table: rows `\| date \| command \| commit \| outcome \|` for `lake build`, `lake env lean <Lib>/AxiomAudit.lean`, `python3 scripts/check-lean-sources.py`, `ruby scripts/validate-formalization.rb`, `lake env leanchecker Solution`, comparator (CI) | rows | the prose above the table and the "not run" line |
| `proofrun emit formalization RUN JUDGE_JSON` | repo `formalization.yaml`: **targeted line edits** of `status.sorry_count`, `status.axioms` (no YAML round-trip; preserves comments and folded scalars) | numbers, axiom list | `status.scope`, `review.notes`, `known_gaps` prose (prints a reminder listing those keys) |
| `aimath packet journal RUN_JSON` | journal entry via `journal.new_entry` (exists) plus an appended `## Result (proofrun <run_id>)` section with the run summary table and pointers | table, pointers | Interpretation, Failed ideas, Next actions |
| `aimath packet history-evidence RUN_JSON --to X` | prints a compact evidence string in the existing style (`adversary 20261016T191015 (ACCEPT_WITH_FIXES 0.96, answered); …`) plus `evidence_paths` | string | approve or edit |

Tests: golden files; idempotency (emit twice gives one copy); a formalization.yaml with comments
round-trips byte-identical except for the edited lines; `ruby scripts/validate-formalization.rb`
passes after emit (integration test, skipped without ruby).

### T6. `proofrun summary`

Prints the run table (§3.4). `--all` prints one line per run. It reads only `run.json` and
the gate JSON cached at `RUN/gate/latest.json`.

### T7. `proofrun open-claim` (W route)

Runs `aimath claim TITLE=… PROBLEM=…`, writes CLAIM.md from a given statement file, and then
walks SPECULATIVE → EMPIRICAL → CONJECTURED → PROOF_ATTEMPT **one gated `promote` per step**,
stopping at the first BLOCKED with the gate's reasons. It never creates a claim directly at
CONJECTURED. `claims.new_claim(status=…)` would allow that, but it skips levels, which AGENTS.md
§3 forbids.

---

## 3. Run directory layout and manifest schema

### 3.1 Location

`~/aiseminar/agents/runs/<YYYY-MM-DD>_<slug>/`, committed in the lab. The runs are protocol
records, and the lab owns the protocol. Small files only: build logs are capped at 200 KB and
kept, while `.lake` artifacts are never copied. The Astra job directories stay in
`~/.claude/astra/jobs/` and are referenced, not copied; the verbatim replies live in
`transcripts/`.

```
agents/runs/2026-10-17_sr-lean/
  run.json                    # manifest (schema below); the only file tools mutate in place
  run.json.lock               # flock target (gitignored)
  briefs/
    _system_adversary.md      # _common.md + adversary.md as sent (snapshot)
    prove-A-r1.md             # exact --prompt-file bodies
    adv-meaning-r1.md
    adv-trust-r1.md
    review-r1.md
    recon-r1.md
  isolated/
    recon-r1/STATEMENT.md     # the ONLY file under the independent job's --cwd
    recon-r1.listing.txt      # ls -lR + sha256 at submit time
  apply/
    prove-A-r1.patch          # git diff applied on the scratch branch (reviewable)
    prove-A-r1.apply.json     # which decl blocks applied/rejected and why (from the applier)
  judge/
    prove-A-r1.json           # judge contract (3.3), one per judged commit
    prove-A-r1.build.log      # truncated lake build log
  gate/
    latest.json               # last aimath gate --json output
  SUMMARY.md                  # regenerated by `proofrun summary RUN > SUMMARY.md` at milestones
```

### 3.2 `run.json` (schema `proofrun/1`)

```json
{
  "schema": "proofrun/1",
  "run_id": "2026-10-17_sr-lean",
  "kind": "lean",                                 // "lean" | "informal"
  "created": "2026-10-17T09:12:00", "updated": "…",
  "lab": {"root": "/Users/ben/aiseminar", "claim": "claim_0004",
          "status_at_start": "VERIFIED", "target_status": "FORMALLY_VERIFIED"},
  "repo": {"path": "/Users/ben/size-ramsey", "project_tag": "size-ramsey",
           "base_branch": "main", "base_commit": "b17d1fa…",
           "streams": {"A": {"worktree": "/Users/ben/size-ramsey-streamA", "branch": "lean/stream-A"},
                       "B": {"worktree": "/Users/ben/size-ramsey-streamB", "branch": "lean/stream-B"}},
           "config": "proofrun.toml", "config_sha256": "…"},
  "frozen": {"challenge_sha256": "…", "records": ["SizeRamsey.four_mul_tau4_le_edgeCount", "…"],
             "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"],
             "frozen_files": {"SizeRamsey/Defs.lean": "sha256…", "SizeRamsey/Shared.lean": "…",
                              "SizeRamsey/AInterface.lean": "…"},
             "baseline_sorries": 69},
  "targets": [
    {"decl": "SizeRamsey.Plan.tau4_erase_lift", "file": "SizeRamsey/Deletion.lean", "stream": "A",
     "state": "sorry",                            // sorry | proposed | accepted | rejected
     "by_job": null, "accepted_commit": null}
  ],
  "stage": "prove",                               // prove|judge|adversary|respond|review|reconstruct|promote|done|blocked
  "round": 1,
  "jobs": [
    {"key": "prove-A-r1", "role": "prover", "stage": "prove", "round": 1, "stream": "A",
     "framing_id": null, "family": null,
     "astra_job": "size-ramsey/20261017T091500_prover-claim-0004-r1-stream-a",
     "job_dir": "/Users/ben/.claude/astra/jobs/size-ramsey/20261017T091500_…",
     "cwd": "/Users/ben/size-ramsey-streamA", "effort": "xhigh", "timeout": 7200,
     "brief": "briefs/prove-A-r1.md", "brief_sha256": "…",
     "transcript": "agents/astra/transcripts/20261017T091500_prover_claim_0004_A.md",
     "prompt_copy": "agents/astra/transcripts/20261017T091500_prover_claim_0004_A.prompt.md",
     "submitted": "…", "finished": null,
     "status": "running",                         // queued|running|completed|failed|timeout|cancelled|dead
     "reply_sha256": null, "verdict": null, "confidence": null, "findings": null,
     "lean_blocks": null, "decl_status": null,     // prover only: {"decl": "PROVED|PARTIAL|STUCK"}
     "self_checked": null, "isolation_breach": null,
     "retry_of": null}
  ],
  "judgments": [
    {"key": "prove-A-r1", "job": "prove-A-r1", "branch": "proofrun/2026-10-17_sr-lean/prove-A-r1",
     "commit": "3fa1c2…", "judge_json": "judge/prove-A-r1.json",
     "build_ok": true, "sorries_before": 69, "sorries_after": 61,
     "records_unchanged": true, "frozen_unchanged": true, "axioms_ok": null,
     "accepted": ["SizeRamsey.Plan.tau4_erase_lift"], "rejected": {"SizeRamsey.Plan.erase_card": "build error L171"},
     "decided_by": "judge"}                       // the orchestrator's call is recorded separately in rounds[]
  ],
  "rounds": [
    {"round": 1, "stage": "adversary", "jobs": ["adv-meaning-r1", "adv-trust-r1"],
     "substantive": null,                         // orchestrator judgment: true|false; gate R-3RD reads it
     "response_section": "RESPONSE_CLAUDE.md#response-to-adversary-20261017T…",
     "note": ""}
  ],
  "promotions": [
    {"from": "VERIFIED", "to": "FORMALLY_VERIFIED", "date": null,
     "gate_json": "gate/latest.json", "commit": null, "override": null}
  ],
  "events": [{"t": "2026-10-17T09:15:02", "msg": "submitted prove-A-r1, prove-B-r1"}]
}
```

Invariants (checked by `proofrun collect` and by the T2 tests):
- `key` is unique.
- `transcript` matches `^agents/astra/transcripts/\d{8}T\d{6}_[a-z_]+\d*_[A-Za-z0-9_]+(\.FAILED)?\.md$`,
  the grammar the gate also uses.
- every `completed` job has `reply_sha256` equal to the sha of `transcript`.
- `rounds[].jobs` reference existing keys.
- `stage` only moves forward, except that `respond` can go back to `adversary` and `judge` can go
  back to `prove`.

The Lean-kind stage machine is prove ⇄ judge (loop while the sorry count falls) →
adversary → respond → review → reconstruct → promote → done. The informal kind (W) is
prove → judge (orchestrator reading plus computational cross-check) → open-claim →
adversary → respond → review → reconstruct → promote(VERIFIED).

### 3.3 Judge contract that `proofrun` consumes (`judge/<key>.json`)

I don't design the judge (other lenses do); this is the minimal contract the orchestration and
the gate rely on.

```json
{"schema": "leanjudge/1", "repo": "/Users/ben/size-ramsey", "commit": "3fa1c2…", "tree_clean": true,
 "toolchain": "leanprover/lean4:v4.35.0-rc3",
 "build": {"exit": 0, "jobs": 1043, "seconds": 142.0, "log": "judge/prove-A-r1.build.log"},
 "sorry_warnings": [{"file": "SizeRamsey/Components.lean", "line": 40, "decl": "…"}],
 "sorry_scoped_grep": {"pattern": "\\b(sorry|admit)\\b", "excluded": ["Challenge.lean", "Targets/"], "hits": 61},
 "axiom_decls": 0, "native_decide": 0,
 "axioms": {"SizeRamsey.F17_spec": ["propext", "Classical.choice", "Quot.sound"], "…": ["…", "sorryAx"]},
 "records_unchanged": true, "challenge_sha256": "…", "frozen_unchanged": true,
 "check_lean_sources": 0, "validate_formalization": 0,
 "leanchecker": {"ran": false}}
```

### 3.4 The orchestrator-facing summary (the only thing `wait` prints)

```
run 2026-10-17_sr-lean · claim_0004 VERIFIED→FORMALLY_VERIFIED · stage adversary r1 · sorries 69→0
key            role         state      verdict            conf  finds  note
prove-A-r1     prover       completed  —                  —     31 blk A: 29 accepted, 2 rejected (build)
prove-B-r1     prover       completed  —                  —     22 blk B: 22 accepted
judge@9c41e0   judge        —          build ok · axioms ok · records= · frozen=        sorry 0
adv-meaning-r1 adversary    completed  ACCEPT_WITH_FIXES  0.93  6      framing meaning
adv-trust-r1   adversary    running    —                  —     —      framing trust-base, 41 min
gate  VERIFIED→FORMALLY_VERIFIED: BLOCKED — adv-trust-r1 pending; RESPONSE r1: 6 TODO; no §10 row @9c41e0
next  proofrun wait RUN --stage adversary   (background)   then: aimath packet respond-skel …
```

Rules for this table: at most 12 job rows (older rounds collapse to one line each), never any
reply text, and the gate's first blocking reason plus a count of the rest.

---

## 4. The protocol gate checker

### 4.1 Rules table

The **M** rows are mechanical, checked by `aimath gate`. The **J** rows need judgment and are
reported as "NEEDS-JUDGMENT: <item>". A J item is satisfied only when the orchestrator has
recorded the judgment as data (a RESPONSE line without `TODO(claude)`, or `run.json
rounds[].substantive`), so the *consequence* of each judgment is still enforced mechanically.

| from → to | id | kind | check | files / fields |
|---|---|---|---|---|
| SPECULATIVE → EMPIRICAL | E1 | M | some `evidence_paths` entry is a `MANIFEST.json` under `experiments/`, and every listed sha256 re-verifies | STATUS.yaml (new entry), `experiments/local/*/out/MANIFEST.json` (`aimath manifest` format) |
| | E2 | M | the experiment README has a non-empty fenced block under `## Reproduce` and an env report | `experiments/local/<…>/README.md` |
| EMPIRICAL → CONJECTURED | C1 | M | CLAIM.md `**Statement.**` is not `TBD`, and a `What would refute it` paragraph exists | CLAIM.md |
| | C2 | J | "tested range recorded": EVIDENCE.md names the range | EVIDENCE.md |
| CONJECTURED → PROOF_ATTEMPT | P1 | M | PROOF.md, or the file its first path points to (e.g. `~/size-ramsey/docs/PROOF.md`), is not template text, has no `GAP` token, and contains ≥ 1 label (`\*\*(Lemma|Claim|Proposition|Theorem) [\w.]+`) | PROOF.md (+ pointer) |
| | P2 | J | "written in full, every lemma labeled" | — |
| PROOF_ATTEMPT → UNDER_REVIEW | U1 | M | an adversary job exists for this claim (transcript, or a run.json job in a non-failed state) whose prompt contains PROOF.md's path or its sha256 *at the time of submission* | transcripts/, `*.prompt.md`, run.json |
| UNDER_REVIEW → VERIFIED | V1 | M | every finding number of every adversary/reviewer transcript after the last promotion appears in a RESPONSE_CLAUDE.md section naming that transcript's stamp (ranges `8–9` count), and no `TODO(claude)` remains | transcripts, RESPONSE_CLAUDE.md |
| | V2 | M | the **latest** `reviewer*` transcript for the claim is later than the latest RESPONSE section and has `VERDICT: ACCEPT` (claim_0004: reviewer3 ACCEPT 0.98 ✔; reviewer2 AWF alone would ✘) | transcripts |
| | V3 | M | an `independent_prover` transcript exists whose job `cwd` contained no PROOF file (listing in `isolated/*.listing.txt`) and whose `events.jsonl` shows no read of a path containing `PROOF` or the repo root (`isolation_breach == false`) | run.json, job dir |
| | V4 | J | "the two proofs agree": a RESPONSE or REVIEW line `independent reconstruction: AGREES|DIFFERS (…)` exists | REVIEW_ASTRA.md |
| | V5 | M/J | if COMPUTATION.md is non-template, EVIDENCE.md cites a MANIFEST re-verified (E1) dated ≥ the PROOF_ATTEMPT entry. Whether that re-run is "independent" is J | EVIDENCE.md |
| | R-3RD | M | **forced third round.** If the last two review rounds (`rounds[]`, or adjacent transcripts) are both recorded `substantive: false`, require a later adversary job whose `framing_id` was never used for this claim **and** whose framing family differs from both. An unrecorded `substantive` in either round is BLOCKED ("record the judgment") | run.json `rounds[]`, job `framing_id` |
| | REV | M | REVIEW_ASTRA.md has a section citing each transcript path counted above, and no `condensed: TODO` | REVIEW_ASTRA.md |
| VERIFIED → FORMALLY_VERIFIED | F0 | M | STATUS.yaml has `formalization: {repo, commit}`. `git -C repo cat-file -e commit` succeeds; HEAD == commit or `--repo-commit` given; tree clean at that commit; commit is on a remote branch (`git branch -r --contains`) | STATUS.yaml, repo git |
| | F1 | M | the scoped grep `\b(sorry\|admit)\b` over `*.lean` outside `.lake/`, `vendor/`, `Challenge.lean` and the config's `excluded_scopes` (FGB: `Targets/`) finds 0 hits. `Challenge.lean` holds exactly `len(records)` sorries (SR: 5) | repo files, `proofrun.toml`/comparator.json |
| | F2 | M | no `^\s*(axiom\|opaque)\b`, no `native_decide`, no `implemented_by\|extern\|debug.skipKernelTC` outside `.lake`/`vendor` | repo files |
| | F3 | M | `judge/<…>.json` for this commit exists with `build.exit == 0`, and for every record `axioms ⊆ permitted_axioms` (from `comparator.json`) | judge json, comparator.json |
| | F4 | M | the Challenge sha256 equals `run.json frozen.challenge_sha256` recorded when the run started, and the frozen files are unchanged. The gate re-hashes them itself rather than trusting the judge | repo, run.json |
| | F5 | M | `formalization.yaml status.sorry_count == 0` (or equals the Challenge-deliberate count if the yaml convention counts those; the config fixes which), `sorryAx ∉ status.axioms` | formalization.yaml |
| | F6 | M | the CORRESPONDENCE build/audit table has rows whose `commit` cell prefix-matches the commit for: `lake build`, the AxiomAudit command, `check-lean-sources`, and `leanchecker` | CORRESPONDENCE.md (table found by header regex) |
| | F7 | M | comparator: `gh run list --commit <sha> --workflow ci.yml --json conclusion,url` shows success for a run including the `comparator` job. UNKNOWN when offline, which blocks unless `--waive comparator="reason"`; the waiver is written into history | gh |
| | F8 | M | the claim packet contains the AGENTS.md §9 record: EVIDENCE.md has a `Lean build and audit, <repo>@<sha12>` section (T5 evidence-lean) | EVIDENCE.md |
| | F9 | M | two adversary jobs on the formal development with distinct framing families (§5.2: *meaning* and *trust base*) completed after commit date; findings answered (V1 logic); an independent statement reconstruction (§5.4b) completed | transcripts, run.json |
| | F10 | J | the correspondence argument is right (CORRESPONDENCE.md §1–§8 prose, fidelity divergences in formalization.yaml) | — |
| any → REFUTED | X1 | M | EVIDENCE.md has a `REFUTED` or `GAP` section with a pointer, and `FAILED_APPROACHES.md` gained an entry naming the claim | EVIDENCE.md, FAILED_APPROACHES.md |
| UNDER_REVIEW → PROOF_ATTEMPT | B1 | M | always permitted; requires a pointer to the transcript finding that forced it | — |

Output example (claim_0004 today, if the rules were implemented):

```
claim_0004  VERIFIED  (formalization: ~/size-ramsey @ b17d1fa)
→ FORMALLY_VERIFIED  BLOCKED
  F1 ✘ 62 sorry tokens outside Challenge.lean (measured on main @ b17d1fa: 67 incl. Challenge's 5; Components 9, Deletion 9, Reductions 8, …)
  F3 ✘ no judge record for b17d1fa
  F5 ✘ formalization.yaml sorry_count 12 ≠ 0 (and ≠ observed 62/67: stale)
  F6 ✘ no CORRESPONDENCE build row for b17d1fa (only 'scaffold')
  F7 ? comparator CI for b17d1fa: UNKNOWN
  F9 ✘ no adversary on the formal development; no statement reconstruction
  F10 ⋯ judgment: correspondence argument
→ REFUTED  permitted only with X1
```

### 4.2 What stays human or orchestrator judgment (and is labelled as such)

- Whether an adversary finding is *substantive* (feeds R-3RD), whether a response actually
  answers it, and whether the independent proof "agrees" (V4). The gate checks only that a
  judgment was recorded, not whether it is right.
- Whether Astra's informal argument for W is a proof at all: P2, and the decision to open the claim.
- The correspondence argument (F10) and every prose field (`status.scope`, `fidelity.divergences`).
- Novelty (outside the ladder; the novelty_checker transcript is input).
- Accepting a waiver (F7) or an override (T4). Both are recorded with a reason, and Ben's
  approval is required for any override of a FORMALLY_VERIFIED gate (recommendation; AGENTS.md
  doesn't say this today).

### 4.3 W route (conjecture W in FGB) versus the Lean ladder

- W gets **its own claim packet** (claim_0006, say). claim_0005's CLAIM.md says so: "claim to be
  opened separately once evidence exists". W is not a target of the FGB Lean run. Its Lean
  statement lives outside `Solution`'s import closure and in `comparator.all-targets.json` only,
  so the FGB run's F1 uses `excluded_scopes = ["Targets/"]` and W's `sorry` never blocks
  Theorem F.
- Ladder via T7, each step gated:
  1. SPECULATIVE → EMPIRICAL. E1 is satisfied by the existing
     `experiments/local/2026-10-16_semigroup_e5_family_tests/out/MANIFEST.json` (test 3: widths
     4–20, all m; no β₁ > 2w+2).
  2. EMPIRICAL → CONJECTURED. C1 is the statement. C2 must record that the tested range is
     **w ≤ 20 only** while the statement goes to 40, and what refutes it.
  3. CONJECTURED → PROOF_ATTEMPT, only after Astra's informal proof has been written into
     PROOF.md with labels (P1).
  4. PROOF_ATTEMPT → UNDER_REVIEW at adversary submission (U1).
- The W run's `kind` is `informal`. Its "judge" stage is the orchestrator's reading plus a
  mechanical cross-check: any finite claim in Astra's proof (e.g. "the extremal offsets are
  (1, w/2, w−1)") is checked against the test-3 data before the claim is opened. The target status
  is VERIFIED. FORMALLY_VERIFIED for W would need the certified sweep or a Lean proof of
  `Targets/FiniteWidth.lean`, which is out of scope for this workflow.
- An important wording guard: if Astra's argument proves W for *all* widths, or only for
  w ≤ 40 by a finite reduction, CLAIM.md must state exactly what is proved. The brief (§5.1b)
  asks for that explicitly.

---

## 5. Brief templates (exact text; `$placeholders` are filled by `proofrun brief`)

All briefs are sent as `--prompt-file`, with `--system briefs/_system_<role>.md` (`_common.md`
plus the lab role prompt, verbatim). They reference paths; nothing large is pasted. Every brief
ends with the machine trailer the parsers expect.

### 5.1a Prover (Lean sorries), step 1

```
[$project] prover: $claim round $round, stream $stream — $date

You are rooted read-only in `$cwd` (branch `$branch`, commit `$commit`). You may run
`lake env lean --stdin` and `lake build $module` in the sandbox; nothing you write persists.

Goal: replace the `sorry` bodies of the declarations listed below with complete proofs. Read
first: `$lib/NOTES.md`, `docs/astra/$plan_file` §$plan_sections, `docs/PROOF.md` (the informal
proof to follow), and the files containing the targets.

Targets (from the current build's `declaration uses 'sorry'` warnings):
$target_table

Hard constraints (a proposal that violates any of them is discarded without reading):
- Signatures are frozen: change only the text after `:=` (or the `by` block). Do not change any
  definition, any file listed as frozen ($frozen_files), `Challenge.lean`, or the statement of
  any declaration in `$records`.
- No `sorry`, `admit`, `native_decide`, new `axiom`/`opaque`, `implemented_by`, `set_option` that
  weakens checking. Only `propext`, `Quot.sound`, `Classical.choice` may appear in `#print axioms`.
- New helper lemmas are allowed only in files owned by stream $stream ($owned_files), under
  namespace `$helper_ns`, placed before first use.
- Module system: keep `module` / `public import` / `@[expose] public section` conventions.

Reply format (parsed by a script; deviations are lost):
1. For each target, one fenced block whose info string is
   `lean decl=<FullyQualifiedName> file=<path>` containing the COMPLETE declaration (attributes,
   signature copied verbatim, new body). Helpers: `lean helper file=<path> before=<DeclName>`.
2. After the blocks, one line per target: `STATUS: <FullyQualifiedName> PROVED|PARTIAL|STUCK`.
   PROVED means you elaborated it with `lake env lean` in the sandbox; say so. PARTIAL/STUCK: give
   the exact missing lemma as a Lean statement.
3. Number every other finding (contract defects, plan errors, frozen-interface problems).
End with `CONFIDENCE: 0-1` and the number of subagents used.
```

### 5.1b Prover (open conjecture W), step 1

```
[$project] prover: conjecture W — $date

You are rooted read-only in `$cwd`. The statement to prove or refute is
`Targets/FiniteWidth.lean` (`beta1_five_le_two_width_add_two`) and its informal form in
`CORRESPONDENCE.md` §$w_section. Background you may read: `docs/PROOF.md` (Theorem F, a
different statement), `vendor/SemigroupBetti-aa266b8/` (the four-generator proof), and the
numerical record at `$evidence_path` (widths 4–20 only; widths 21–40 untested).

Produce either (a) a complete proof with every lemma labelled (**Lemma W.n**) and its hypotheses,
stating precisely the range of widths it covers and every finite verification it relies on (what
is checked, how a third party would check it); or (b) a counterexample with explicit generators
and β₁; or (c) a precise account of where you are stuck, with the exact missing lemma.
Do not treat the numerical record as evidence for any step of a proof.

Number every lemma and every finite claim. End with
`OUTCOME: PROOF|COUNTEREXAMPLE|STUCK`, `SCOPE: <exact width range proved>`, `CONFIDENCE: 0-1`.
```

### 5.2 Adversary with a fresh framing (step 3)

One template with a framing slot. `framings.toml` defines the framings. A run submits **two
adversaries with different families**. A forced third round must use a family not yet used for
this claim.

```
[$project] adversary ($framing_id): $claim round $round — $date

$framing_text

Object under attack: $object_description
Files (read them; do not rely on summaries): $file_list
Repository commit: $commit. You may run `lake env lean --stdin` / `lake build` in the sandbox;
if you construct a Lean counter-test (an `example` exhibiting vacuity, a mismatch, or an
unexpected axiom), include its exact text and the elaborator output so it can be re-run.

Report: (1) the single most damaging objection; (2) all other gaps ranked; (3) explicit
counterexample or counter-test candidates with data; (4) what evidence would change your mind.
Do not list strengths. Number every finding.
End with `VERDICT: ACCEPT|ACCEPT_WITH_FIXES|REJECT|INCONCLUSIVE` and `CONFIDENCE: 0-1`.
```

`framings.toml` (families in brackets; `$records` etc. filled in):

- **meaning** [semantics]: "Assume the Lean statements of record in `Challenge.lean` do *not*
  mean what `CORRESPONDENCE.md` §1–§2 says they mean. Find the divergence: definitions in
  `$defs_files` that differ from the informal notions (non-induced vs induced copies, `Fin n` vs
  arbitrary finite types, infimum conventions on ℕ (`sInf ∅ = 0`), off-by-one ranges, `spanRank`
  vs minimal number of generators, field hypotheses), hypotheses that make a record vacuous
  (exhibit an instance satisfying them), or a record weaker than its informal counterpart."
- **trust** [verification chain]: "Assume the build is green but the theorem is not actually
  verified. Find the route by which a false or different statement could pass: a record proved
  in `Solution.lean` whose statement differs from `Challenge.lean`; `AxiomAudit.lean` auditing the
  wrong names or importing `Challenge`; `comparator.json` missing a record or allowing extra
  axioms; `sorry` hidden behind macros, `decide` on an instance proved by `sorry`, `opaque`,
  `implemented_by`, `extern`, `unsafe`, options weakening the kernel; frozen definitions edited
  since `$base_commit` (`git diff $base_commit -- $frozen_files`); module-system visibility hiding a
  dependency from `#print axioms`."
- **refute** [mathematics, informal route]: "Assume the claim below is false. Find the mistake."
  This is the lab's own adversary framing and the default for W.
- **reduction** [mathematics, informal route]: "Assume every lemma is individually true but the
  case analysis or reduction loses a case. Enumerate the cases the proof claims to exhaust and
  construct an object outside them (smallest first)."
- **hostile-referee** [presentation; third-round only]: "You are a referee who suspects that two
  previous rounds of agreement were shallow. Re-derive the three load-bearing steps
  ($load_bearing) from scratch, without reading earlier reviews (`REVIEW_ASTRA.md`,
  `RESPONSE_CLAUDE.md` are off-limits), and report any step you could not re-derive."

Lean route: round 1 = {meaning, trust}. Informal W route: round 1 = {refute, reduction}. Forced
third round: hostile-referee, or whichever family hasn't been used yet.

### 5.3 Reviewer (re-review after the response)

```
[$project] reviewer$n: $claim round $round — $date

Referee claim packet `$packet_path` (read CLAIM.md, PROOF.md$proof_pointer, EVIDENCE.md,
REVIEW_ASTRA.md, RESPONSE_CLAUDE.md) $lean_clause.
Adversary transcripts this round: $adversary_transcripts. The response to them is
RESPONSE_CLAUDE.md § "$response_heading".

Tasks: (a) judge each adversary finding's answer individually: RESOLVED / PARTIALLY /
NOT RESOLVED, citing the finding number; (b) check whether the revisions introduced new errors;
(c) any new objection, numbered; (d) recommend the status this packet should hold now under the
ladder SPECULATIVE → EMPIRICAL → CONJECTURED → PROOF_ATTEMPT → UNDER_REVIEW → VERIFIED →
FORMALLY_VERIFIED, and say which epistemic category (theorem / computer-assisted /
formally verified) is correct.
End with `VERDICT: ACCEPT|ACCEPT_WITH_FIXES|REJECT|INCONCLUSIVE` and `CONFIDENCE: 0-1`.
```

For the Lean route, `$lean_clause` = "and the formal development at `$repo` commit `$commit`:
`Challenge.lean`, `Solution.lean`, `CORRESPONDENCE.md`, `formalization.yaml`, the judge record
`$judge_json_copy` (inlined via --file, since it lives outside your root)".

### 5.4a Independent prover (informal; `--cwd RUN/isolated/<key>/`, which holds only STATEMENT.md)

```
[$project] independent prover: $claim — $date

Prove the statements in STATEMENT.md (in your working directory; it is the only file) by your
own route, or say precisely where you get stuck and which lemma you would need. Do not look for,
open, or assume the existence of any other proof, and do not read files outside your working
directory. Write every lemma with its hypotheses. Finite case checks are acceptable only if you
state exactly what is checked and how a third party would verify it.
End with one line per statement `CONFIDENCE[<label>]: 0-1`.
```

### 5.4b Independent statement reconstruction (Lean route; `--cwd RUN/isolated/<key>/` holding only STATEMENT.md and `lean-toolchain`)

This is the Lean analogue of "proof rewritten from scratch". The proof is checked by the kernel;
what needs independent reconstruction is the *formal statement*.

```
[$project] independent formal statements: $claim — $date

STATEMENT.md (the only file here) gives the informal theorems. Write, from scratch, Lean 4 /
Mathlib statements of each one (Lean $toolchain, Mathlib $mathlib_rev), with your own
definitions where Mathlib has none. Do not look for an existing formalization. For each
statement, list the modelling choices you made (vertex types, copies vs induced copies, how an
infimum over an empty set is handled, field/ring hypotheses) and the alternatives you rejected.
Output one fenced block `lean statement=<label>` per statement.
End with `CONFIDENCE: 0-1`.
```

The orchestrator then diffs the modelling choices against CORRESPONDENCE §3–§7 (judgment). Where
the statements are close, it tries `example : Mine ↔ Record` in a scratch file. That is optional
strong evidence, recorded as a row in CORRESPONDENCE §10. Its absence is not a gate failure; only
the job's existence is (F9).

---

## 6. Placement and skill-extraction plan

**Opinion: three homes, by what each piece encodes.**

| Piece | Encodes | Home | Why |
|---|---|---|---|
| `gate`, `promote --gate`, packet emitters, transcript name grammar, verdict parser | the lab's protocol (AGENTS.md §2–§4, §9) | `~/aiseminar/src/aimath/{gate,packet,replies}.py`, CLI subcommands, Makefile targets `gate`, `respond-skel`, `review-stub` | the protocol already lives there (claims.py) with pytest (`make test`, 85 passing); protocol changes and checker changes should land in one commit |
| Lean judge, sorry inventory, applier | one repo layout | each repo's `scripts/` (identical copies), driven by `proofrun.toml` | CI can run the judge; the repos are self-contained Palomar submissions (`semigroup-betti` README "Verification") |
| run dir, submit/wait/collect, briefs, framings, summary, open-claim, repo-file emitters | multi-repo orchestration on top of the astra skill | `~/.claude/skills/proofrun/` | spans the lab, two repos and the astra skill; useful for any future repo of the same shape; must not depend on the cwd |

The tooling should **not** live in `~/size-ramsey`. The orchestration touches the lab and FGB,
and a copy in SR would drift from the FGB copy on the first fix.

**`~/.claude/skills/proofrun/` layout:**
```
SKILL.md
scripts/proofrun.py          # stdlib only (tomllib, json, fcntl, subprocess, hashlib, string)
templates/prove_lean.md  prove_informal.md  adversary.md  reviewer.md
templates/independent_prover.md  statement_recon.md  framings.toml
tests/ (pytest, fake astra stub)
```

**SKILL.md outline:**
1. *When to use*: "run the proof campaign / prove the remaining sorries with Astra / take claim X
   to FORMALLY_VERIFIED / resume run R".
2. *Prerequisites*: astra skill; a lab with `aimath` (`$AIMATH_LAB`); `proofrun.toml` in the repo.
3. *The loop*, as a table of stage → command → what to read (only the summary) → the
   orchestrator's judgment step.
4. *Waiting*: always `proofrun wait RUN` with `run_in_background: true`; never poll; resume in a
   new session with `proofrun summary --all`.
5. *Apply safely*: scratch branch `proofrun/<run>/<key>` from the stream branch, never on main,
   never in a dirty tree; the judge decides, Astra's STATUS lines don't.
6. *Protocol*: never edit STATUS.yaml by hand; `aimath gate` then `aimath promote` (gated); the
   W route goes through `open-claim`.
7. *Failure handling*: dead jobs (`resubmit`), missing verdicts, a refused brief (banned phrase),
   a blocked gate (read its first reason).
8. *What is repo-specific*: only `proofrun.toml`.

**Repo-specific configuration (`proofrun.toml`, one per repo; everything else is generic):**
```toml
project_tag = "size-ramsey"
lib = "SizeRamsey"
claim = "claim_0004"
records_from = "comparator.json"          # theorem_names + permitted_axioms
challenge = "Challenge.lean"
axiom_audit = "SizeRamsey/AxiomAudit.lean"
plan = "docs/astra/2026-10-16_lean_plan.md"
frozen_files = ["SizeRamsey/Defs.lean", "SizeRamsey/Shared.lean", "SizeRamsey/AInterface.lean"]
excluded_scopes = []                      # FGB: ["Targets/"]
correspondence_table_heading = "Build and audit record"
helper_namespace = "SizeRamsey.Plan"
[streams.A]  worktree = "~/size-ramsey-streamA"  branch = "lean/stream-A"  owned = ["SizeRamsey/Basic.lean", "…"]
[streams.B]  worktree = "~/size-ramsey-streamB"  branch = "lean/stream-B"  owned = ["SizeRamsey/Upper.lean", "…"]
```
The owned-file lists can be generated once from NOTES.md's owner column and then frozen into the
toml. Parsing NOTES.md on every run would be fragile, since the two repos use different status
vocabularies.

**Reuse versus generalise (lab code):**

| Existing | Verdict |
|---|---|
| `claims.promote`, `TRANSITIONS`, `new_claim`, `load_status` | reuse unchanged as primitives; add optional history keys and the CLI `--gate` |
| `journal.new_entry` | reuse unchanged; the emitter appends a section |
| `cli.cmd_manifest` (MANIFEST.json) | reuse unchanged; the gate's E1 verifies its format |
| `cli.cmd_envreport` | reuse for the judge's environment record |
| `invoke.py build_prompt` | reuse *the role prompt files*, not the function: the skill sends `_common.md + <role>.md` as `--system`. `invoke.py --claim` inlines PROOF.md, which is wrong for the independent prover, so don't route through it |
| `invoke.py` transport, `appserver_client.py`, `scripts/astra_fanout.py` | supersede with the skill's `astra.py submit/wait` (detached, resumable). Keep `invoke.py` for ad-hoc calls; retire `astra_fanout.py` |
| `Makefile lean-check` (`rg '\b(sorry\|admit\|axiom)\b'`) | generalise: as written it would fail on SR/FGB (deliberate Challenge sorries; the word `axiom` appears in `AxiomAudit.lean` comments and `#print axioms`). The gate's F1/F2 replace it for external repos |

---

## 7. Open questions and risks

1. **Does the sandbox actually confine reads to `--cwd`?** If it doesn't, the
   independent-prover isolation is by instruction only. Mitigation: the V3 `events.jsonl` scan.
   Test it once with a canary file outside cwd and record the result in the skill.
2. **AGENTS.md vs practice.** AGENTS.md names `invoke.py` and `lean/<claim>/CORRESPONDENCE.md`.
   Practice is the skill plus external repos. Ben should amend §2, §3 and §9, or the gate
   implements rules nobody wrote down. I'd add `formalization: {repo, commit}` to STATUS.yaml and
   say FORMALLY_VERIFIED may point to an external pinned repo.
3. **Is the comparator required for FORMALLY_VERIFIED?** AGENTS.md doesn't require it; CONTEXT.md
   §3 lists it. I recommend requiring CI success (F7) with an explicit, recorded waiver path. The
   Mac can't run it, but CI already does.
4. **What counts as the independent reconstruction for a Lean promotion?** AGENTS.md requires it
   only for VERIFIED (already done for both claims). I propose the statement reconstruction (5.4b)
   as the Lean-route analogue. That is a lab policy choice, so it's flagged as a proposal, not
   an existing rule.
5. **"Two total" Astra provers vs 69 sorries.** One turn won't close SR's ~64 non-Challenge
   sorries. The run loops prove→judge rounds, and per-stream jobs (A and B on disjoint owned
   files) double throughput. That deviates from "one Astra agent per repository" in letter; I'd
   accept the deviation. The orchestrator stops a loop when two consecutive rounds reduce the
   sorry count by < 2 (`stage: blocked`).
6. **Transcript volume.** Each prover reply may be 50–100 KB of Lean. They are verbatim lab
   records, so they belong in `transcripts/`. Git growth is acceptable; don't strip them.
7. **Concurrent edits to RESPONSE_CLAUDE.md** by two orchestrator sessions. The emitters are
   append-only with idempotency keys, but prose edits can still conflict. One run per claim at a
   time (the gate refuses a second `proofrun init` for a claim with a non-`done` run).
8. **Gate heuristics produce false confidence.** A label regex for "every lemma labeled" is
   weak. Every heuristic check is marked J, not M, and the summary prints J items as unresolved
   until a judgment is recorded.
9. **Stale metadata is a protocol problem, not a cosmetic one.** SR's `sorry_count: 12` versus
   the real count shows that free-text metadata drifts within a day. The F5 equality check
   between observed and declared counts should also run in CI.

## 8. Deliberately left out, and why

- **The Lean applier and judge internals** (block parsing, signature-diffing, branch handling,
  build-warning inventory). These belong to the other lenses. I fixed only the JSON contract
  (§3.3) and the separation rule.
- **Automatic condensation of REVIEW_ASTRA.md by a model.** It would spend tokens (Claude) or put
  Astra in the loop of judging Astra. The mechanical stub plus orchestrator condensation is
  cheaper and keeps the epistemic judgment with Claude, as AGENTS.md requires.
- **Auto-promotion.** No tool promotes on its own; `promote` stays an explicit orchestrator call,
  gated. AGENTS.md says "never promote silently".
- **A daemon or watcher process.** The skill's rule is that a backgrounded `wait` *is* the
  watcher. `--out` plus the detached worker already make filing session-independent.
- **Novelty-check orchestration.** It isn't on the ladder; the existing role prompt and a
  one-off submit suffice.
- **leanexport/nanoda, `leanchecker --fresh`.** These take hours and aren't required by the
  ladder. The gate lists them in the summary as "not run", as the template README does.
- **HPC or the certified W sweep.** The workflow concerns proofs. A computational certificate for
  W would enter as EVIDENCE for a computer-assisted theorem, which is a different route.
- **Changes to `astra.py`.** It isn't needed. Everything above uses its existing
  `submit/wait/status --out --cwd --system` interface.
