# Astra proof loop (`proofloop`): design

## 0. Status

2026-10-16 · **Design, not implemented.** This document merges three independent assessments: `assessment_A_brief_generation.md`, `assessment_B_apply_verify.md` and `assessment_C_orchestration_protocol.md`, all in `/private/tmp/claude-501/-Users-ben-size-ramsey/8ae39630-a002-4b80-8bdd-dfb47d6ceab3/scratchpad/tooling-assessment/` (with the brief `CONTEXT.md` and B's logs).

Facts were re-checked on 2026-10-16 against `~/aiseminar/{AGENTS.md,Makefile,src/aimath}`, `~/.claude/skills/astra/`, both repos and their stream worktrees. "Measured" means a figure measured by B or during this merge.

---

## 1. One-page summary

```
                    proofloop.toml  (per repo, data only, committed)
                             │
┌──────────── ~/.claude/skills/proofloop/  (stdlib Python ≥3.11 + one Lean probe template) ────────────┐
│ preflight ─► inventory ─► brief ─submit─► astra.py (transport) ─► Astra (read-only, --cwd <stream>)  │
│                                                   │ --out files the reply into lab transcripts/     │
│               run.json (~/aiseminar/agents/runs/<date>_<slug>/) ◄── wait/collect ◄─┘                 │
│ SEARCHER          ▼                                   VERIFIER (imports nothing from apply)          │
│ apply + settle ─► branch proofloop/<run>/<key> ────► judge: build·probe·axioms·leanchecker           │
│ (tree in ~/.cache/proofloop/…)                         └─► verdict.json + verdict.md (≤40 lines)    │
│ emit: CORRESPONDENCE build rows, formalization.yaml counts                                           │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘
                             │ verdict.json, run.json (read-only inputs)
                             ▼
~/aiseminar/src/aimath (lab protocol; the only writer of STATUS.yaml):
  gate · promote --gate · packet emitters (REVIEW_ASTRA / RESPONSE_CLAUDE / EVIDENCE / journal)
  + new role prompts agents/astra/prompts/{lean_prover,conjecture_prover,statement_recon}.md
```

1. **One skill, `proofloop`** (`~/.claude/skills/proofloop/`), holds all Lean-side and orchestration code. Neither Lean repository contains any of it; each carries one data file, `proofloop.toml`.
2. **The lab protocol lives in `~/aiseminar/src/aimath`**: the gate, gated promotion and the claim-packet emitters, tested by `make test`. The gate reads `verdict.json` but recomputes the cheap invariants itself.
3. **Ground truth is the compiler, never NOTES.md.** The inventory reads `lake build` warnings and `lake env lean --json` (`hasSorry`, errors, goals), which also work on broken files. The judge uses `EnvProbe.lean`, kept outside the repo, which compares elaborated type and value hashes and runs `collectAxioms`.
4. **Reply contract: body-only ` ```lean patch ` blocks**, keyed by fully qualified name and carrying a signature freshness token. The applier never takes signature text from Astra. Helpers are private theorems, imports come from a whitelist, and a JSON summary trailer ends the reply.
5. **Every attempt runs a kernel replay of the touched modules**: `lake env leanchecker <touched…> Solution`, about 15 s. B's `skipKernelTC` + `addDecl` cheat passes `lake build`, `#print axioms` and `leanchecker Solution`, and nothing else catches it.
6. **Searcher ≠ verifier, structurally.** `pl/apply.py` and `pl/judge.py` never import each other. Astra's own success claims are kept only to calibrate it.
7. **Patches are applied in a throwaway worktree** on branch `proofloop/<run>/<key>`, with `.lake` copied by APFS clone (0.06 s; the following no-op build takes 2–3 s, measured). Merging into a stream is an explicit `proofloop accept`.
8. **One resumable run per claim.** Stages: prove⇄judge → adversary×2 → respond → reviewer → independent → gate → promote. Each prove job covers one owner file. Limits: ≤3 Astra jobs per repo and ≤5 overall, ≤3 repair rounds per target, and a stall after 2 rounds that each close fewer than 2 declarations.
9. **Conjecture W gets its own claim**, expected claim_0006. It enters CONJECTURED → PROOF_ATTEMPT by gated promotion, as an `informal` run framed "prove or refute", and never shares a run with Theorem F.
10. **Sorry count = `declaration uses 'sorry'` diagnostics**, split into Challenge, development and excluded scopes. Measured today:
    - size-ramsey main: **67** (5 + 62);
    - Betti main: **29** (2 + 27);
    - Betti stream-B: **33** (2 + 9 Minimality + 22 stale Stream-A stubs that main already proves).

**Build order**, ranked; effort in Opus agent-days:

| # | Component | Days | Why here |
|---|---|---|---|
| 1 | `preflight` + Astra sandbox probe | 0.5 | settles the symlinked-`.lake/packages` unknown before any 90-min turn |
| 2 | `inventory` (build log + `lake env lean --json` + lexical splitter) | 1.0 | every later tool keys on it |
| 3 | `judge` + `EnvProbe.lean` + red-team suite | 2.0 | trust anchor; immediately usable on Claude-subagent work (Deletion) |
| 4 | `apply` + `settle` | 1.5 | reply → judged branch at zero orchestrator tokens |
| 5 | `brief` (modes `lean-sorry`, `lean-repair`, `conjecture`) + 3 lab role prompts | 1.0 | until then briefs are hand-rendered from §4 |
| 6 | run dir: `init/submit/wait/collect/status/summary/accept/resubmit` | 1.5 | resumability, summary table |
| 7 | `aimath gate` + `promote --gate` | 1.5 | first promotion is days away |
| 8 | emitters (`aimath packet …`, `proofloop emit …`) | 1.0 | step-3 token savings |
| 9 | review-stage briefs (framings, reviewer, isolation) | 0.5 | templates already in §4 |
| | **≈ 10.5 d total**; minimal first release = 1–5 plus thin `init/submit/collect` ≈ 6.5 d | | |

**Three overruled decisions.**

1. **C's per-repo judge in `scripts/` is overruled; the judge goes in the skill.** This also drops C's `proofrun.toml` and its three-home split.
   - Both repos are Palomar submissions, and `scripts/` ships with them.
   - A meta-programming probe in the repo would fail `scripts/check-lean-sources.py` (every `.lean` file needs a `module` header) and contains exactly the constructs the forbidden scan rejects.
   - Identical copies in two repos drift on the first fix.

   C's choice of `aimath` for the gate and promotion is kept. A's `lean-astra` and B's `lean-ingest` become one skill under one name.
2. **B's probe-range locator and B's and C's whole-declaration replies are overruled.**
   - Probe ranges need a green base, and repair targets such as Deletion are exactly the case where the base is broken.
   - Locating through the probe would couple the searcher to the verifier.
   - Whole-declaration replies let Astra write the signature bytes.

   Instead the applier uses A's lexical splitter, checked against `hasSorry` positions (which exist on broken files), and replaces bodies only. The probe belongs to the judge alone.
3. **A's text signature hash and committed `frozen.lock` are overruled as the freeze check.**
   - A text hash taken before `:=` misses `variable`, `local notation`, `local instance` and `open … in` edits that change the elaborated statement, and it raises false alarms on reformatting.
   - The judge instead compares elaborated type and value hashes against the base, record types against `bootstrap`, and frozen-file bytes against `bootstrap`.
   - A's 10-hex text hash survives only as the freshness token `sig=`. The bootstrap baseline is recomputed from `proofloop.toml` and cached in `~/.cache/proofloop/`, not committed.
   - One fact checked today: the `Challenge.lean`/`Solution.lean` docstrings legitimately changed after bootstrap (b17d1fa), so locking every byte at bootstrap would raise false alarms.

C also ranked the gate first in build order. I moved it to 7th, since nothing can be promoted before the Lean work exists, but it is still built before the first FORMALLY_VERIFIED attempt.

---

## 2. Components

Notation:
- `PL=~/.claude/skills/proofloop/scripts/proofloop.py`
- `RUN=~/aiseminar/agents/runs/<YYYY-MM-DD>_<slug>/`
- `KEY` = a job key, e.g. `prove-B-minimality-r1`
- `TREE=~/.cache/proofloop/<project>/<run_id>/<KEY>/tree`
- `LAB=$PROOFLOOP_LAB` (default `~/aiseminar`)

Skill code is stdlib Python ≥ 3.11 (`tomllib json subprocess hashlib fcntl shlex string.Template`) and is tested with `uv run --with pytest pytest ~/.claude/skills/proofloop/tests`. Only `pl/run.py` calls Astra, and only through `~/.claude/skills/astra/scripts/astra.py submit|wait|status`, which needs no changes.

### 2.1 `inventory` and `probe` (ground truth)

**`inventory`** lives in `pl/inventory.py` (~150 lines), `pl/splitter.py` (~200) and `pl/leanio.py` (~150; all Lean calls go through it). CLI: `$PL inventory --root W [--stream B] [--files GLOB…] [--json OUT] [--table]`.

1. **Build pass.** Run `lake build --no-build` (falling back to `lake build`, capped at 600 s). Parse the `declaration uses 'sorry'` warnings, `✖ … Building <M>` and the failure block, and drop `trace:` lines. This gives the repo-wide count and the failing modules; it took 1.1 s on size-ramsey main (measured).
2. **Per-file pass.** For each selected file run `lake env lean --json <file>`. Keep `kind:"hasSorry"` (its `pos..endPos` is the declaration name) and every error together with its `⊢` goal text. Measured: 1.6 s for Deletion, 12.3 s for Minimality.
3. **Splitter.**
   - Tracks `namespace/section/end/variable/open … in/omit … in`.
   - A declaration begins at a top-level `^(@\[[^\]]*\]\s*)*(private |protected |noncomputable )*(theorem|lemma|def|abbrev|instance|structure|inductive)\b` and ends before the next top-level start, any of `end|section|namespace|attribute|variable|omit|open`, or a top-level comment.
   - The signature is everything up to the first depth-0 `:=` outside strings and comments.
   - `sig` = the first 10 hex digits of sha256 over the signature, with comments stripped and whitespace runs collapsed to one space.
   - A file it cannot split is refused with exit 3; it never guesses.
4. **Cross-check.** Every `hasSorry` position must lie inside a splitter range whose body contains `sorry`, or the file is marked unsplittable.
5. **Ownership** comes from `[streams.*].owned` in `proofloop.toml`. NOTES.md status columns are never read; on Betti stream-B they are stale.
6. **References.** `proof_ref` = the PROOF.md `##` section whose first token is the file stem or `Dir.Stem`. `plan_ref` = the plan `###` section naming the most targets. Both are given as line ranges.

Output, `inventory.json`:
```
{schema:"proofloop/inventory/1", root, head, dirty:[…],
 counts:{challenge, development, excluded:{file:n}}, failing_modules:[…],
 targets:[{id, fqn, kind, file, line, end_line, sig, sig_text, reason:"sorry|error",
           diagnostics:[{severity,line,col,kind,head,goal}], stream, proof_ref, plan_ref,
           deferred:null|"import <M> fails"}]}
```
`--table` prints one line per target (`id fqn file:line sig reason`); this is what the orchestrator reads.

Failure modes:
- targets behind a failing import are marked `deferred`, so they are not reported as phantom errors;
- a toolchain mismatch aborts the run;
- each file has a 300 s cap.

Tests:
- Betti `6d054ec --stream B` gives exactly the 9 Minimality targets, against a golden file of A's sig hashes;
- size-ramsey `b17d1fa` gives 67, of which 5 are in Challenge;
- the streamA WIP of Deletion gives 2 error targets and 4 sorry targets;
- a byte-identical splitter round-trip over every `.lean` file in `~/size-ramsey`, `~/five-generator-betti` and `~/semigroup-betti`.

**`probe`** is the judge's semantic core: `pl/probe.py` (~80 lines) plus `lean/EnvProbe.lean.tmpl` (~90 lines of Lean), which is never copied into a repo. CLI: `$PL probe --tree TREE --imports Solution|Challenge --out X.jsonl`.

- **Run.** The template is instantiated with `import <probe_modules>` and run as `cd TREE && lake env lean --json <job>/EnvProbe.lean`.
- **Selection.** It iterates `env.constants` and keeps constants from modules under `lib`, `Challenge`, `Solution` or `Targets`, minus internal and auxiliary names (`.eq_n`, `.match_n`, `._proof_n`, `.proof_n`).
- **Output.** One `IO.println` JSON line per constant: `{"n","kind","mod","range":[l0,c0,l1,c1],"ty":<Expr.hash>,"val":<hash|null>,"sorry_self":bool}`. `"ax"` (from `collectAxioms`) is added only for records, handoffs and added or touched constants, which keeps the run at 2–4 s warm and 29 s cold (measured). For each record it also emits `blocking`: the minimal `sorry_self` constants in its `getUsedConstants` closure.
- **Diff.** `probe diff A B` reports `{changed_type, changed_value, removed, added}`.
- **Bootstrap baseline.** `probe --bootstrap` probes a worktree at `bootstrap` once and caches it as `~/.cache/proofloop/<project>/bootstrap-<sha>.jsonl`.
- **Tests.** Challenge and Solution hashes agree for every record (B observed this on Betti); a definition's `val` is stable when a helper is inserted; renaming a binder changes nothing.

### 2.2 `brief`

`pl/brief.py` (~250 lines) plus `templates/*.md`. CLI: `$PL brief RUN --mode lean-sorry --stream B --files FiveGenBetti/Family/Minimality.lean`; `--mode lean-repair --from KEY` (reads the previous `verdict.json` and reply); `--mode conjecture --conjecture W`; `--role adversary --framing <id>`; `--role reviewer`; `--role independent|statement-recon`.

Outputs:
- `RUN/briefs/<KEY>.md`, sent as `--prompt-file`;
- `RUN/briefs/<KEY>.json`, the manifest: `{key, mode, role, project, root, base_sha, targets:[{id,fqn,file,sig,kind}], allowed_imports, frozen_files, never_edit, forbidden_tokens, system_file, effort, timeout}`;
- `RUN/briefs/_system_<role>.md`, which is `_common.md` + the lab role prompt, verbatim.

Steps:
1. Run `inventory` and `preflight` (§2.3); abort if either fails.
2. Compute `allowed_imports`: `Mathlib.*`, plus project modules that do not import the target and are not in `never_edit`, filtered by `import_rules`.
3. Render with `string.Template`.
4. Lint: refuse if the text matches `(?i)(probably|likely|we believe|seems) (correct|right|true)|has been (verified|checked)` (AGENTS.md §2). `--force` overrides and the override is logged.
5. Keep the inline text to ≤ 250 lines.

Chunking:
- one owner file per job;
- files that share one PROOF.md section are merged if they hold ≤ 8 targets together;
- files with more than 10 targets are split along the plan order (e.g. `Components`, 9 targets → counting 4 + support/attachment 5);
- per-declaration briefs only in repair rounds;
- per-stream briefs never ask for proof text.

Refusals: a dirty root (unless the dirty files lie outside every target's import closure); a target owned by the other stream; an `excluded_scopes` target outside `conjecture` mode. Targets with failing imports are deferred.

Tests: golden renders at fixed SHAs; every cited path and line range exists; `astra.py --dry-run` reproduces the brief after the header; the lint fires; framing reuse is refused (§4.3).

### 2.3 `preflight` (read root and sandbox)

`pl/preflight.py` (~150 lines). CLI: `$PL preflight --root W [--probe-astra] [--materialize]`. The cache is `~/.cache/proofloop/sandbox.json`, keyed by `(realpath root, realpath root/.lake/packages)`.

Mechanical checks (~5 s):
- (a) the root is a worktree with `HEAD == base_sha` and its targets are clean;
- (b) `lake build --no-build` exits 0; in `lean-repair` mode, a failure in the target file alone is allowed;
- (c) `realpath(.lake/packages)` lies inside the root. **Today it does not, in any stream worktree**: `~/size-ramsey-stream{A,B}/.lake/packages -> /Users/ben/size-ramsey/.lake/packages`, and the Betti worktrees are the same;
- (d) `printf 'module\npublic import <Lib>.Defs\n#check Nat.succ_le_iff\n' | lake env lean --stdin` exits 0 locally.

**Astra probe** (`--probe-astra`; once per cache key; effort low, timeout 900 s):
1. Write a canary file, `~/.cache/proofloop/canary/CANARY-<nonce>.txt`.
2. Ask Astra to run four commands and paste the output:
   - `ls -la .lake/packages | head -3; ls .lake/packages/mathlib/Mathlib.lean`
   - check (d)
   - `cat <canary>`
   - `touch .proofloop_write_test`
3. Decide from the `commandExecution` items in `events.jsonl` (`exitCode` and output), not from Astra's prose. Record `lean_ok`, `outside_read` (the nonce was seen) and `write_blocked`.

**Fallback when `lean_ok` is false** (`--materialize`):
1. Replace the link with a copy-on-write APFS clone: `rm <root>/.lake/packages && cp -c -R -p <main>/.lake/packages <root>/.lake/packages`. The time is unmeasured; expect under 2 minutes.
2. `lake build --no-build` must still report "up-to-date". If Lake wants to rebuild Mathlib, restore the symlink and stop.
3. Re-probe.
4. If it still fails, run in **no-elaboration mode**: record it in `run.json sandbox` and tell Astra it cannot run Lean (so `elaborated: false`). Expect more repair rounds.

If `outside_read` is true, which is likely on macOS but unverified, isolating the independent prover by `--cwd` is by instruction only. Gate rule V3 then relies on the `events.jsonl` scan.

### 2.4 `apply` (searcher; deliberately simple)

`pl/contract.py` (~150 lines, the reply parser) and `pl/apply.py` (~200). CLI: `$PL apply RUN KEY [--only ID,…] [--revert ID,…]`. Inputs: the filed transcript (its sha256 checked against the job's `reply.md`) and `briefs/<KEY>.json`.

1. **Build the tree:**
   - `git -C <stream wt> worktree add -b proofloop/<run>/<KEY> TREE <base_sha>`
   - `cp -c -R <stream wt>/.lake TREE/.lake` (this keeps the packages link)
   - `lake build`, which must be a no-op; if the base does not build, the result is `BASE_BROKEN` and nothing is applied.
2. **Parse.** A line state machine finds the fences (a whole-file regex breaks on nested backticks), and `shlex` splits the info strings.
   - Block types are those defined in §3.
   - When an `id` or `decl` appears twice, neither copy is kept.
   - Anything else goes to `unparsed[]`.
   - The summary must name this `brief` and `base`.
   - A bare ` ```lean ` block is never applied.
3. **`body` blocks.**
   - `decl` must resolve to exactly one splitter declaration; a short name is accepted only if its suffix match is unique.
   - The file must be owned by the job's stream and match neither `frozen_files` nor `never_edit`.
   - The current `sig` must equal both the block's `sig` and the brief's, else `rejected_stale_sig`.
   - Everything after the first top-level `:=` is replaced by `:= ` + the block text, re-indented to the declaration's column.
   - `def`/`instance`/`abbrev` targets are accepted only when the brief marks them `kind=def`.
4. **`helper before=X`** inserts the block immediately before X, in the same section. It must be a `private theorem|lemma` whose name is fresh project-wide (checked with `git grep -w`). `private def|abbrev` blocks are applied but flagged.
5. **`import` lines** must match `^public import [A-Z][\w.]*$`, appear in `allowed_imports`, and are appended to the import block.
6. **Forbidden-token scan** of the added text only, after removing comments and strings with `scripts/check-lean-sources.py`'s stripper. The tokens are those in §3 item 5; a hit gives `rejected_forbidden:<tok>`.
7. **Record** `RUN/apply/<KEY>.applied.json` (`{id → {file, line_start, line_end, status}}`, in post-patch coordinates recomputed after every insertion) and `RUN/apply/<KEY>.patch`.

Tests: replies that are well-formed, empty, nested, duplicated, short-named, stale-sig, out-of-scope, or carry a non-whitelisted import.

### 2.5 `settle` (partial-success fixpoint; search, not verdict)

`pl/apply.py` (+~100 lines). CLI: `$PL settle RUN KEY [--commit]`; `apply` runs it by default. It allows at most 4 builds per touched file.

1. Apply every statically valid patch.
2. Run `lake build <touched modules>`.
3. Map each error position (`--json` `pos`, or `file:line:col`) to the patch whose line range contains it. Mark that patch `build_error`, revert it, and rebuild.
4. An error that falls outside every patch is bisected over the upstream patches (at most log2(k) extra builds).

Dependents of a reverted helper fail on the next pass, which is the intended behaviour. `--commit` makes a single commit on `proofloop/<run>/<KEY>` listing the declarations closed and still open, the Astra job, and the attribution line. The commit is never merged by this tool.

Cost: 2–3 builds (17 s for a Minimality edit, measured). Tests: B's fixtures (f), a helper cascade, and (j), downstream breakage found by bisection.

### 2.6 `judge` (verifier) and `verdict.json`

`pl/judge.py` (~300 lines) imports only `pl/{leanio,probe,config}.py`. CLI: `$PL judge RUN KEY` (the settled branch); `$PL judge --tree DIR --base SHA [--out DIR]` (any branch, including Claude-subagent work); `$PL judge RUN --round N` (the stream head after `accept`). It runs ladder rungs L0–L7 (§5) in order and records every gate.

Declaration statuses:
- `proved`: no `hasSorry`, axioms ⊆ permitted, and leanchecker ok on its module.
- `proved_modulo_sorry`: the body is clean, but `sorryAx` arrives through a dependency.
- `still_sorry`, `build_error`, `draft`.
- `regressed`: proved in the base but not now, checked across the whole environment.
- The applier's `rejected_*`, `not_found` and `duplicate` pass through unchanged.

`verdict.json` (exact; schema `proofloop/verdict/1`):

```json
{
  "schema": "proofloop/verdict/1",
  "run": "2026-10-17_fgb-lean", "key": "prove-B-minimality-r1", "project": "five-generator-betti", "stream": "B",
  "tree": "/Users/ben/.cache/proofloop/five-generator-betti/2026-10-17_fgb-lean/prove-B-minimality-r1/tree",
  "base_sha": "<40 hex>", "result_branch": "proofloop/2026-10-17_fgb-lean/prove-B-minimality-r1", "result_sha": "<40 hex>|null",
  "astra_job": "five-generator-betti/<stamp>_<slug>|null", "transcript": "agents/astra/transcripts/<name>.md|null", "reply_sha256": "<hex>|null",
  "track": "lean",
  "overall": "RECORDS_PROVED | PROGRESS | NO_PROGRESS | REJECTED | BASE_BROKEN | TOOL_ERROR",
  "gates": {
    "baseline_build": "ok | failed",
    "static_scan": "ok | rejected_some | rejected_all",
    "lake_build": {"rc": 0, "completed_line": true, "seconds": 17.3, "failing_modules": []},
    "env_diff": {"changed_type": [], "changed_value": [], "removed": [], "added": ["FiveGenBetti.Family.h_aux1"]},
    "records_challenge_eq_solution": {"FiveGenBetti.family_spanRank_eq": true},
    "records_eq_bootstrap": {"FiveGenBetti.family_spanRank_eq": true},
    "frozen_bytes_eq_bootstrap": true,
    "never_edit_bytes_eq_base": true,
    "leanchecker": {"modules": ["FiveGenBetti.Family.Minimality", "Solution"], "rc": 0, "seconds": 15.4},
    "check_lean_sources": 0,
    "validate_formalization": 0
  },
  "declarations": [
    {"name": "FiveGenBetti.Family.H_degree_lt_D", "file": "FiveGenBetti/Family/Minimality.lean", "patch_id": "M4", "mode": "body",
     "status": "proved | proved_modulo_sorry | still_sorry | build_error | regressed | draft | rejected_frozen_change | rejected_forbidden:<tok> | rejected_out_of_scope | rejected_stale_sig | not_found | duplicate",
     "astra_claimed": "PROVED | DRAFT | CONTRACT | SKIPPED | null", "astra_elaborated": true,
     "axioms": ["propext", "Classical.choice", "Quot.sound"],
     "error": {"kind": "Tactic.unsolvedGoals", "line": 55, "head": "<=300 chars", "goal": "<=25 lines"},
     "reject_reason": null}
  ],
  "flags": {"helpers_nonprivate": [], "private_defs_added": [], "contract_requests": ["M9"], "unparsed_blocks": 0,
            "linter_warnings_delta": 0, "slow_modules_over_300s": []},
  "records": [{"name": "FiveGenBetti.family_spanRank_eq", "axioms": ["propext", "sorryAx", "Classical.choice", "Quot.sound"],
               "clean": false, "blocking": ["FiveGenBetti.Family.relation_nonredundant"]}],
  "sorry": {"has_sorry": {"before": {"challenge": 2, "development": 9}, "after": {"challenge": 2, "development": 6}},
            "token_scan": {"before": 11, "after": 8}, "excluded": {"Targets/FiniteWidth.lean": 1}},
  "diffstat": {"files": 1, "insertions": 42, "deletions": 9},
  "milestone": {"leanchecker_all_modules": null, "comparator_ci": null},
  "timing_s": {"tree": 3.3, "build": 17.3, "probe": 6.2, "leanchecker": 15.4, "total": 61.0}
}
```

`overall`:
- `RECORDS_PROVED` iff every record is `clean`, both record checks hold, leanchecker rc = 0, and all gates are ok.
- `PROGRESS` iff ≥ 1 declaration is newly `proved`/`proved_modulo_sorry`, nothing `regressed`, and all gates are ok.
- `REJECTED` iff every patch was rejected statically, or on any `rejected_frozen_change`, removed constant or leanchecker failure, whatever else passed.
- `NO_PROGRESS` otherwise.

`verdict.md` (≤ 40 lines; the default read) contains, in order: an `overall` line with the sorry delta and branch@sha, a declaration × status table, record axioms and `blocking`, the failed gates, and the next commands. Its footer always reads "proved on branch, pending milestone checks (§5 M1–M2)".

**Red-team suite.** Cases live in `tests/redteam/<case>/{reply.md,expected.json}`, pinned to Betti stream-B `6d054ec`, under 1 min each warm. The suite must pass before the first verdict is trusted and after every change to `judge.py`.

| Case | Expected |
|---|---|
| (a) correct body | `proved` |
| (b) dropped hypothesis (made by hand edit; `body` mode cannot do it) | `rejected_frozen_change` |
| (c) `axiom cheat` | scan reject; with the scan off, axioms ⊄ permitted |
| (d) `native_decide` | scan reject; with the scan off, `Lean.ofReduceBool` in the axioms |
| (e) `skipKernelTC` + `run_cmd addDecl` | scan reject; with the scan off, leanchecker rc 1 (observed by B) |
| (f) helper cascade | the helper and its dependents `build_error`; other patches kept |
| (g) reformatted body | `proved` |
| (h) patch to `Defs.lean` or `Solution.lean` | `rejected_out_of_scope` |
| (i) no blocks; duplicate blocks; unknown names | `unparsed`; `duplicate`; `not_found` |
| (j) patch that breaks a downstream module | found by bisection; other patches kept |
| (k) injected `local notation`/`variable` | `rejected_forbidden`; with the scan off, `rejected_frozen_change` |

### 2.7 Gate (`aimath gate`) and gated promotion

`~/aiseminar/src/aimath/gate.py` (~300 lines) and `replies.py` (~100: transcript header, numbered findings, verdicts) add a `gate` CLI subcommand and `make gate CLAIM= [TO=]`. Tests: `~/aiseminar/tests/test_gate.py`, on fixture copies of claim_0004 and claim_0005.

- **`python -m aimath.cli gate CLAIM [--to X] [--json] [--run RUN]`**: exit 0 = permitted, 1 = blocked, 3 = only judgment items remain.
- **`promote CLAIM X --gate --evidence "…" --evidence-path P… --commit SHA [--override "reason"]`** adds the history keys `evidence_paths`, `commit`, `gate: PERMITTED|OVERRIDE` and `run`. The library default stays `gate=False`, so the existing state-machine test still passes. Call it with argv, never as `make promote EVIDENCE=…`, to avoid shell quoting.
- **Independence.** The gate re-hashes the Challenge and frozen files itself and reruns `rev-parse`, `status --porcelain` and the scoped token scan.
- **Verdict parse.** Strip `*`, `` ` `` and spaces, then take the last match of `VERDICT:\s*(ACCEPT_WITH_FIXES|ACCEPT|REJECT|INCONCLUSIVE)` and of `CONFIDENCE[^:]*:\s*([01](?:\.\d+)?)`.

Rule kinds: M = mechanical. J = the judgment must be *recorded* (a RESPONSE line without `TODO(claude)`, or a `run.json` field), and the gate checks only that the record exists.

| from → to | id | kind | check |
|---|---|---|---|
| SPECULATIVE → EMPIRICAL | E1 | M | an `evidence_paths` entry is an `aimath manifest` MANIFEST.json whose sha256s re-verify |
| EMPIRICAL → CONJECTURED | C1 | M | CLAIM.md statement not `TBD`; "what would refute it" paragraph present |
| | C2 | J | tested range recorded in EVIDENCE.md (W: w ≤ 20 tested vs 40 claimed) |
| CONJECTURED → PROOF_ATTEMPT | P1 | M | PROOF.md (or its pointer target) not template, no `GAP`, ≥ 1 label `**(Lemma\|Claim\|Proposition\|Theorem) X**` |
| | P2 | J | "written in full, every lemma labelled" |
| PROOF_ATTEMPT → UNDER_REVIEW | U1 | M | non-failed adversary job whose `.prompt.md` contains PROOF.md's path or sha256 at submission |
| UNDER_REVIEW → VERIFIED | V1 | M | every finding of every adversary/reviewer transcript since the last promotion answered in a RESPONSE_CLAUDE.md section naming its stamp (ranges count); no `TODO(claude)` |
| | V2 | M | latest `reviewer*` transcript postdates the latest RESPONSE section and says `VERDICT: ACCEPT` |
| | V3 | M | `independent_prover` job ran with `--cwd RUN/isolated/<key>/` (listing recorded), `isolation_breach == false` |
| | V4 | J | `independent reconstruction: AGREES\|DIFFERS (…)` line in REVIEW_ASTRA.md |
| | V5 | M/J | non-template COMPUTATION.md ⇒ re-verified MANIFEST dated ≥ the PROOF_ATTEMPT entry |
| | R3 | M | forced third pass (§4.3): two latest passes recorded `substantive: false` ⇒ a later adversary job with an unused framing family; unrecorded `substantive` blocks |
| | REV | M | REVIEW_ASTRA.md cites every counted transcript; no `<!-- condensed: TODO -->` |
| VERIFIED → FORMALLY_VERIFIED | F0 | M | STATUS.yaml `formalization: {repo, commit}`; commit exists, clean, on a remote branch |
| | F1 | M | verdict `has_sorry.development == 0` **and** the gate's own scan `\b(sorry\|admit)\b` (comments stripped; excl. `.lake/ vendor/ Challenge.lean` + `excluded_scopes`) = 0; Challenge count = bootstrap count |
| | F2 | M | no `^\s*(axiom\|opaque)\b`, `native_decide`, `implemented_by`, `extern`, `debug.skipKernelTC` outside `.lake/ vendor/` |
| | F3 | M | verdict at that commit `overall == RECORDS_PROVED`; record axioms ⊆ `permitted_axioms` |
| | F4 | M | Challenge sha256 = `run.json frozen.challenge_sha256`; frozen files = `bootstrap` (re-hashed by the gate) |
| | F5 | M | `formalization.yaml status.sorry_count` = measured total (Challenge-inclusive, §6); `sorryAx ∉ status.axioms` |
| | F6 | M | CORRESPONDENCE "Build and audit record" table (found by heading) has rows at this commit for `lake build`, AxiomAudit, check-lean-sources, leanchecker (all modules) |
| | F7 | M | comparator CI success at this commit (`gh run list --commit <sha> --json conclusion,url`); UNKNOWN blocks unless `--waive comparator="reason"` (§10) |
| | F8 | M | EVIDENCE.md section `Lean build and audit, <repo>@<sha12>` |
| | F9 | M | adversary jobs `meaning` and `trust` on the formal development after the commit date, answered (V1 logic); one `statement_recon` job completed |
| | F10 | J | correspondence argument (CORRESPONDENCE §1–§8) judged right |
| any → REFUTED | X1 | M | EVIDENCE.md `REFUTED`/`GAP` section with pointer; FAILED_APPROACHES.md entry naming the claim |
| UNDER_REVIEW → PROOF_ATTEMPT | B1 | M | permitted, with a pointer to the forcing finding |

### 2.8 Run directory and `run.json`

`pl/run.py` (~400 lines).
```
$PL init --repo R --claim C --kind lean|informal [--slug S]   # prints RUN; refuses a 2nd non-done run per claim
$PL submit RUN --keys K1,K2 [--dry-run]                       # renders if missing; enforces concurrency limits
$PL wait RUN [--stage S] [--any] [--timeout S]                # ALWAYS run_in_background; ends with collect; prints only the summary
$PL collect RUN | accept RUN KEY | resubmit RUN KEY | status RUN | summary [RUN|--all] | gc
```

**Layout.** `RUN` is committed in the lab and holds only small files (logs capped at 200 KB), never trees:
- `run.json`, plus `run.json.lock` (gitignored);
- `briefs/`;
- `isolated/<KEY>/`, each independent job's only `--cwd`, plus `<KEY>.listing.txt`;
- `apply/`;
- `judge/`, including `round-<N>.verdict.json`;
- `gate/latest.json`;
- `SUMMARY.md`.

**`collect`** (idempotent), for each terminal job:
- verifies the transcript's sha256, and itself files `<base>.FAILED.md` for failed or timed-out jobs (`--out` fires only on completion);
- copies `prompt.md` to `<base>.prompt.md`;
- parses verdict, confidence, finding count and `proofloop-summary`;
- scans the `commandExecution` items in `events.jsonl` to set `self_checked` (a `lake env lean` exited 0) and `isolation_breach` (an independent job read a path containing `PROOF`, the repo, or the claim packet);
- for prover jobs, runs `apply → settle → judge`, unless `--no-auto-judge` is given.

**`accept`** refuses while a live job reads the stream, and refuses any verdict other than `PROGRESS` or `RECORDS_PROVED`. It merges with `--ff-only`, or `--no-edit` when the files touched are disjoint, then runs `judge --round`.

`run.json` (exact; schema `proofloop/run/1`):

```json
{
  "schema": "proofloop/run/1", "run_id": "2026-10-17_fgb-lean", "kind": "lean",
  "created": "2026-10-17T09:12:00", "updated": "2026-10-17T11:40:12",
  "lab": {"root": "/Users/ben/aiseminar", "claim": "claim_0005", "status_at_start": "VERIFIED", "target_status": "FORMALLY_VERIFIED"},
  "repo": {"path": "/Users/ben/five-generator-betti", "project": "five-generator-betti", "config_sha256": "<hex>", "bootstrap": "2869b0b",
           "streams": {"B": {"worktree": "/Users/ben/five-generator-betti-streamB", "branch": "lean/stream-B", "head": "<sha>"}}},
  "sandbox": {"root": "/Users/ben/five-generator-betti-streamB", "lean_ok": true, "outside_read": true, "write_blocked": true,
              "materialized": false, "probe_job": "<project>/<job>", "mode": "elaborate | no-elaboration"},
  "frozen": {"challenge_sha256": "<hex>", "records": ["FiveGenBetti.family_spanRank_eq"],
             "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"],
             "frozen_files": {"FiveGenBetti/Defs.lean": "<sha256>"}, "baseline_has_sorry": {"challenge": 2, "development": 9}},
  "stage": "prove | judge | adversary | respond | review | independent | gate | promote | done | blocked",
  "prove_round": 1,
  "limits": {"jobs_per_repo": 3, "jobs_total": 5, "repair_rounds_per_target": 3, "stall_rounds": 2, "stall_min_closed": 2},
  "targets": [{"fqn": "FiveGenBetti.Family.psi_H", "file": "FiveGenBetti/Family/Minimality.lean", "stream": "B",
               "state": "open | proposed | proved | escalated | contract_request", "attempts": 0, "last_key": null, "accepted_commit": null}],
  "jobs": [
    {"key": "prove-B-minimality-r1", "role": "lean_prover", "mode": "lean-sorry", "stage": "prove", "round": 1, "stream": "B",
     "framing_id": null, "family": null,
     "astra_job": "five-generator-betti/<stamp>_<slug>", "job_dir": "/Users/ben/.claude/astra/jobs/five-generator-betti/<stamp>_<slug>",
     "cwd": "/Users/ben/five-generator-betti-streamB", "base_sha": "<sha>", "effort": "xhigh", "timeout": 10800,
     "brief": "briefs/prove-B-minimality-r1.md", "brief_sha256": "<hex>",
     "transcript": "agents/astra/transcripts/20261017T091500_lean_prover_claim_0005_minimality_r1.md",
     "prompt_copy": "agents/astra/transcripts/20261017T091500_lean_prover_claim_0005_minimality_r1.prompt.md",
     "submitted": "<iso>", "finished": null, "status": "queued | running | completed | failed | timeout | cancelled | dead",
     "reply_sha256": null, "verdict": null, "confidence": null, "findings": null,
     "self_checked": null, "isolation_breach": null, "retry_of": null,
     "judged": {"verdict_json": null, "overall": null, "closed": [], "accepted": false}}
  ],
  "review_passes": [{"n": 1, "kind": "adversary | reviewer | independent | statement_recon", "jobs": ["adv-meaning-1", "adv-trust-1"],
                     "substantive": null, "response_section": null, "note": ""}],
  "promotions": [{"from": "VERIFIED", "to": "FORMALLY_VERIFIED", "date": null, "gate_json": null, "commit": null, "override": null}],
  "events": [{"t": "2026-10-17T09:15:02", "msg": "submitted prove-B-minimality-r1"}]
}
```

Invariants:
- `key` is unique;
- a `completed` job has `reply_sha256` equal to the sha256 of its transcript;
- `review_passes[].jobs` name existing keys;
- `stage` only moves forward, except `judge→prove` and `respond→adversary`;
- writes take a `flock` and finish with an atomic rename.

### 2.9 Transcript filing and emitters

**Filing.** `submit` passes `--out LAB/agents/astra/transcripts/<stamp>_<role>[N]_<claim>[_<tag>].md`, so Astra's detached worker files the reply even if no Claude session is alive.
- `stamp` is set once per batch.
- `role` ∈ `lean_prover|conjecture_prover|adversary|reviewer|independent_prover|statement_recon`.
- `tag` = a file or framing slug + `r<round>`.

The gate matches transcript names with `^\d{8}T\d{6}_[a-z_]+?\d*_claim_\d{4}(_[a-z0-9_-]+)?(\.FAILED)?\.md$`.

**Emitters** are append-only and idempotent (keyed by stamp or commit) and print their diff. They never write a judgment; they leave `TODO(claude)` markers, which the gate treats as blocking.

| Command | Home | Writes (generated part) | Left to the orchestrator |
|---|---|---|---|
| `aimath packet review-stub CLAIM TRANSCRIPT` | lab `packet.py` | REVIEW_ASTRA.md: `## <date> <role> (<path>)`, VERDICT/CONFIDENCE line, one lead sentence per finding, `<!-- condensed: TODO -->` | condensation |
| `aimath packet respond-skel CLAIM TRANSCRIPT` | lab | RESPONSE_CLAUDE.md: `## Response to <role> <stamp> (pass N, <date>)` + `k. TODO(claude): accepted / rejected / deferred —` per finding | every answer |
| `aimath packet evidence-lean CLAIM VERDICT_JSON` | lab | EVIDENCE.md `## <date> Lean build and audit, <repo>@<sha12>`: build rc/s, has_sorry split, records × axioms, leanchecker, check-lean-sources, validate-formalization, comparator CI URL or "not run" | nothing |
| `aimath packet history-evidence RUN_JSON --to X` | lab | prints evidence string (existing style) + `--evidence-path` args | approve/edit |
| `aimath packet journal RUN_JSON` | lab | `journal.new_entry` + `## Result (proofloop <run_id>)` with the summary table | interpretation, next actions |
| `proofloop emit correspondence RUN VERDICT_JSON` | skill `pl/emit.py` | repo CORRESPONDENCE.md "Build and audit record" rows `\| date \| command \| commit \| outcome \|` | prose, "not run" line |
| `proofloop emit formalization RUN VERDICT_JSON` | skill | repo formalization.yaml: targeted line edits of `status.sorry_count`, `status.axioms` (no YAML round-trip) | `status.scope`, `known_gaps`, fidelity prose |

The repo emitters write to the integration branch, never to a scratch tree, and the orchestrator commits their output.

### 2.10 Orchestrator summary table (the only output of `wait`, `collect` and `summary`)

```
run 2026-10-17_fgb-lean · claim_0005 VERIFIED→FORMALLY_VERIFIED · stage judge r1 · has_sorry dev 9→6 · sandbox elaborate
key                     role          state      verdict / overall                    conf  n   note
prove-B-minimality-r1   lean_prover   completed  PROGRESS                             0.62  9   proved 3 · build_error 2 · draft 3 · contract 1 (M9)
judge@3fa1c2e           judge         —          build ok · probe = · ax ok · lc ok              blocking: relation_nonredundant
gate  VERIFIED→FORMALLY_VERIFIED: BLOCKED — F1 6 development sorries (+5 more reasons)
next  $PL accept RUN prove-B-minimality-r1 ; $PL brief RUN --mode lean-repair --from prove-B-minimality-r1
```

Rules for this table:
- at most 12 job rows; older rounds collapse to one line each;
- never any reply text;
- the gate's first blocking reason plus a count of the rest;
- the last line is always the next command.

---

## 3. The reply-format contract (exact text appended to every Lean prover brief)

`$BRIEF_ID`, `$BASE_SHA` and `$ALLOWED_IMPORTS` are substituted.

````text
## REPLY FORMAT (machine-applied; deviations are discarded, not interpreted)

A script parses your reply. Prose outside the blocks below is read only if the script fails;
put explanations in `note` blocks.

1. PROOF. For each target you solve, exactly one block:

   ```lean patch id=<ID> decl=<FullyQualifiedName> sig=<SIG> mode=body
   <the complete text that follows `:=` in the declaration: starting with `by` or a term,
    indented as it will appear in the file; no signature, no `theorem` line>
   ```

   The script keeps the file's signature byte-for-byte through `:=` and replaces everything after
   it with your text. Copy `id`, `decl`, `sig` from the target table. You cannot change a
   signature; if one is wrong, use a `contract` block (item 6).

2. HELPER. A new auxiliary lemma, inserted immediately before the declaration named in `before=`
   (same namespace and section variables), full text:

   ```lean patch id=<ID>.h<k> mode=helper before=<FullyQualifiedName>
   private theorem <fresh_name> ... := by
     ...
   ```

   Only `private theorem` / `private lemma`. The name must not exist anywhere in the project.

3. IMPORT. Only modules from ALLOWED IMPORTS ($ALLOWED_IMPORTS), one per line:

   ```lean patch mode=import
   public import Mathlib.Algebra.MvPolynomial.Degrees
   ```

4. Only the target file(s) may change. Never touch frozen files, Challenge.lean, Solution.lean,
   AxiomAudit.lean, or files of the other stream.

5. FORBIDDEN anywhere in your Lean text: sorry, admit, native_decide, decide +native, axiom,
   opaque, unsafe, partial, implemented_by, extern, csimp, run_cmd, run_tac, run_elab, #eval,
   elab, macro, syntax, notation, initialize, open Lean, addDecl, Environment, instance,
   `attribute [...]` other than `attribute [local instance] Classical.propDecidable`,
   `set_option` other than `set_option maxHeartbeats N in` with N ≤ 1000000. Any `debug.` option.
   Only propext, Classical.choice, Quot.sound may appear in `#print axioms`.

6. CONTRACT. If a target is false or unprovable from its hypotheses, or a frozen interface must
   change (never applied; it goes to a human; as valuable as a proof):

   ```contract id=<ID> decl=<FullyQualifiedName>
   PROBLEM: <one sentence>
   EVIDENCE: <counterexample with explicit data, or the precise missing hypothesis>
   PROPOSED SIGNATURE: <full Lean text>
   CONSUMERS AFFECTED: <declarations that use it>
   ```

7. DRAFT. A target you could not finish: your best partial proof (may contain `sorry`; never
   applied; shown to the next round), and the exact missing lemma as a Lean statement in a note:

   ```lean patch id=<ID> decl=<FullyQualifiedName> sig=<SIG> mode=draft
   ...
   ```

8. NOTES: ```note id=<ID>``` blocks, at most 15 lines each. Number any other finding (plan error,
   interface defect) inside a `note id=general` block.

9. End with exactly one summary block. "elaborated": true means you piped the whole modified
   file through `lake env lean --stdin` in your sandbox and it printed no error and no
   `declaration uses 'sorry'` warning for that id. If you could not run Lean, say false.

   ```proofloop-summary
   {"brief": "$BRIEF_ID", "base": "$BASE_SHA",
    "results": [{"id": "<ID>", "status": "PROVED|DRAFT|CONTRACT|SKIPPED", "elaborated": true,
                 "lean_output": "<last 3 lines of the lake env lean output>"}],
    "helpers": ["<names>"], "imports": ["<modules>"], "subagents": <n>, "confidence": <0-1>}
   ```

Do not paraphrase this format, do not nest blocks, do not use triple backticks inside a block.
````

**Conjecture mode** (exact text appended to the conjecture brief). The parser splits the reply into a PROOF.md draft (the lemmas) and COMPUTATION.md (the computations, which Claude re-runs under `experiments/` and records with `aimath manifest`). VERDICT is a routing hint only.

````text
## REPLY FORMAT (parsed by a script, then judged under the lab protocol)

Begin with:
STATEMENT: <the exact statement you address, verbatim from the brief>
OUTCOME: PROOF | REDUCTION_TO_FINITE_CHECK | COUNTEREXAMPLE | PARTIAL | NO_PROGRESS
SCOPE: <exact range of widths/parameters your argument covers>

Then labelled lemmas:

### L<n>. <title>
STATEMENT: <precise, all quantifiers and ranges>
DEPENDS: <labels, literature (author, title, theorem number, year), or none>
COMPUTATION: none | C<k>
PROOF: <complete argument; no "clearly", "similarly", "routine", "it can be checked">

Every finite verification you rely on is a program (python3 stdlib only, or one C file) with its
exact expected output:

```computation id=C<k> lang=python
...
```
EXPECTED OUTPUT: <literal text, or "prints OK and exits 0">

COUNTEREXAMPLE: give n0<…<n4, the width, β₁ and how you computed it, as a computation block.
PARTIAL / NO_PROGRESS: the exact lemma that would finish, and the smallest case where your
approach fails.

Close with:
WEAKEST STEP: <label and one sentence>
VERDICT: PROOF | REDUCTION | COUNTEREXAMPLE | PARTIAL | NO_PROGRESS
CONFIDENCE: <0-1>
SUBAGENTS: <n and what for>
````

---

## 4. Brief templates

Each brief goes out as `--prompt-file briefs/<KEY>.md` with `--system briefs/_system_<role>.md` (`_common.md` + the role prompt, verbatim). Briefs cite repository paths instead of pasting the files; anything outside the read root is attached with `--file`.

### 4.1 Lean prover (`templates/lean_prover.md`; system: new lab `prompts/lean_prover.md`)

```
[$project] $stream $file_slug r$round — brief $brief_id

Read root: this directory (read-only), commit $base_sha. Lean $toolchain, Mathlib $mathlib_rev.
$elaboration_paragraph
  # elaborate:      "Every import of the targets is built. Elaborate a modified copy with
  #                  `lake env lean --stdin < <copy>` (pipe it; you cannot write files)."
  # no-elaboration: "You cannot run Lean in this sandbox; mark every result elaborated: false."

## Task
Replace each `sorry`$and_errors in the targets below by a complete proof. Signatures, definitions
and all other files are frozen. If a statement is false or unprovable as stated, report it with a
`contract` block and explicit data; that outcome is as valuable as a proof.

## Ground truth (compiler output at $base_sha; trust this over any status table in the repo)
$ground_truth     # counts; stale-doc warnings ("NOTES.md status column is stale for stream B")
$diagnostics      # lean-repair only: current errors with goals (≤25 lines each) + previous attempt per failing id

## Targets ($namespace_and_section_variables)
| id | decl | file:line | sig | kind |
$target_table
Full signatures, exactly as in the file:
$signatures
Suggested order: $order

## Read (intended route; not established Lean)
- $proof_ref      # docs/PROOF.md lines a–b, "## <heading>"
- $plan_ref       # plan lines a–b (this file's section) and §5 pitfalls lines c–d
- Definitions used: $def_refs
- Proved helpers nearby (names only; read the files): $nearby_names

## Rules
Frozen byte-for-byte: $frozen_files. Never edit: $never_edit. Only $target_files may change.
ALLOWED IMPORTS: $allowed_imports. Permitted axioms: propext, Classical.choice, Quot.sound.
$repo_rules       # proofloop.toml [brief].extra_rules

$reply_contract   # §3 verbatim
```

`prompts/lean_prover.md` (~15 lines) says: you are proving Lean declarations whose signatures are frozen; elaborate everything you propose and report the real output; never change a signature, a definition or an import beyond what is allowed; a counterexample or the exact missing lemma is a first-class result; reply strictly in the contract.

### 4.2 Conjecture prover (`templates/conjecture_prover.md`; system: new `prompts/conjecture_prover.md`)

```
[$project] conjecture $label — prove or refute — $date

Read root: this directory (read-only), commit $base_sha.
Statement to prove OR refute (both outcomes are equally useful):
$informal_statement
Formal version: $lean_file (`$lean_decl`). Report any mismatch between informal and formal
hypotheses as a finding.

Evidence status: computed for $tested_range only; the statement claims $claimed_range. Values
outside $tested_range are untested. Do not treat the computations as evidence for any step of a
proof. Try counterexamples first in the untested range, smallest parameters first.

Background you may read: $background_refs
Claim packet (inlined below; it lies outside your root): CLAIM.md, EVIDENCE.md.
State precisely what you prove: all widths; or only $claimed_range by reduction to a finite check
(give the check as a program); or neither.

$reply_contract_conjecture   # §3 conjecture mode verbatim
```

### 4.3 Adversary (`templates/adversary.md`; system: lab `prompts/adversary.md`)

```
[$project] adversary ($framing_id): $claim pass $pass — $date

$framing_text

Object under attack: $object_description
Files (read them; do not rely on summaries): $file_list
$lean_clause   # Lean route: "Repository commit $commit. You may run `lake env lean --stdin` /
               # `lake build` in the sandbox; give any Lean counter-test (an `example` showing
               # vacuity, a statement mismatch, an unexpected axiom) as exact text with its output."

Report: (1) the single most damaging objection; (2) all other gaps ranked; (3) counterexample or
counter-test candidates with explicit data; (4) what evidence would change your mind.
Do not list strengths. Number every finding.
End with `VERDICT: ACCEPT|ACCEPT_WITH_FIXES|REJECT|INCONCLUSIVE` and `CONFIDENCE: 0-1`.
```

Framings live in `templates/framings.toml`; the family of each is in brackets:

- `meaning` [semantics]: "Assume the statements of record in `Challenge.lean` do not mean what `CORRESPONDENCE.md` says. Find the divergence: definitions in $defs_files that differ from the informal notions (induced vs non-induced copies, `Fin n` vs arbitrary types, `sInf ∅ = 0`, off-by-one ranges, `spanRank` vs minimal number of generators, field hypotheses); hypotheses making a record vacuous (exhibit an instance); a record weaker than its informal counterpart."
- `trust` [verification chain]: "Assume the build is green but the theorem is not verified. Find how a false or different statement could pass: Solution/Challenge drift; AxiomAudit auditing the wrong names; comparator.json missing a record or allowing axioms; sorry hidden behind macros, instances, `opaque`, `implemented_by`, `extern`, kernel-weakening options; frozen files changed since $bootstrap (`git diff $bootstrap -- $frozen_files`); module visibility hiding a dependency from `#print axioms`."
- `refute` [mathematics] (the lab default): "Assume the claim is false. Find the mistake."
- `reduction` [mathematics/structure]: "Assume every lemma is true but the case analysis or reduction loses a case. Enumerate the cases claimed exhaustive and construct an object outside them, smallest first."
- `hostile-referee` [presentation; only for a forced third pass]: "Two earlier passes agreed; assume that agreement was shallow. Re-derive the three load-bearing steps ($load_bearing) from scratch without reading REVIEW_ASTRA.md or RESPONSE_CLAUDE.md; report any step you could not re-derive."

On the Lean route the first pass runs `meaning` and `trust` as two parallel jobs. On the informal route (W) the first pass runs `refute` and `reduction`.

**Forced-third-round rule** (AGENTS.md §4; checked by gate R3):
- A *pass* is one adversary batch or one reviewer job.
- After each pass the orchestrator records `substantive: true|false` in `run.json review_passes[]`. A pass is non-substantive if no finding forced a change to PROOF.md, to a Lean statement, or to CORRESPONDENCE.md.
- If the two latest passes are both non-substantive, `brief` refuses every role except `adversary`, and that adversary must use a framing **family** never used for this claim (default `hostile-referee`).
- A framing id is never reused for a claim; this is checked across all runs and transcripts.

### 4.4 Reviewer (`templates/reviewer.md`; system: lab `prompts/reviewer.md`)

```
[$project] reviewer$n: $claim pass $pass — $date

Referee the claim packet $packet_path (CLAIM.md, PROOF.md$proof_pointer, EVIDENCE.md,
REVIEW_ASTRA.md, RESPONSE_CLAUDE.md — inlined below) $lean_clause.
Adversary transcripts this pass: $adversary_transcripts; the response is RESPONSE_CLAUDE.md
§ "$response_heading".
Tasks: (a) judge each adversary finding's answer: RESOLVED / PARTIALLY / NOT RESOLVED, citing its
number; (b) check whether the revisions introduced new errors; (c) new objections, numbered;
(d) the status this packet should hold now on the ladder SPECULATIVE → … → FORMALLY_VERIFIED,
and the correct epistemic category (theorem / computer-assisted / formally verified).
End with `VERDICT: ACCEPT|ACCEPT_WITH_FIXES|REJECT|INCONCLUSIVE` and `CONFIDENCE: 0-1`.
```

On the Lean route, `$lean_clause` = "and the formal development at `$repo` commit `$commit` (Challenge.lean, Solution.lean, CORRESPONDENCE.md, formalization.yaml), with the judge's `verdict.json` inlined below".

### 4.5 Independent prover (`templates/independent_prover.md`, `templates/statement_recon.md`)

The job's `--cwd` is `RUN/isolated/<KEY>/`. That directory holds only `STATEMENT.md`, copied from `claim_NNNN/requests/statement.md`, plus `lean-toolchain` for the Lean variant. Its `ls -lR` listing and sha256s are recorded.

```
[$project] independent prover: $claim — $date
Prove the statements in STATEMENT.md (the only file in your working directory) by your own route,
or say precisely where you get stuck and which lemma you would need. Do not look for, open, or
assume any other proof; do not read files outside your working directory. Every lemma with its
hypotheses. Finite case checks only with exactly what is checked and how a third party re-checks it.
End with one line per statement: `CONFIDENCE[<label>]: 0-1`.
```

On the Lean route the reconstruction is of the statements (system: new `prompts/statement_recon.md`):

```
[$project] independent formal statements: $claim — $date
STATEMENT.md (the only file here) gives the informal theorems. Write from scratch Lean 4 / Mathlib
statements of each (Lean $toolchain, Mathlib $mathlib_rev), with your own definitions where
Mathlib has none. Do not look for an existing formalization. For each statement list the modelling
choices (vertex types, induced vs non-induced copies, empty infimum, field hypotheses) and the
alternatives you rejected. One block ```lean statement=<label>``` per statement.
End with `CONFIDENCE: 0-1`.
```

The orchestrator compares these modelling choices with CORRESPONDENCE §3–§8 (a judgment, gate items V4 and F10). Optionally it adds `example : Mine ↔ Record` in a scratch file as extra evidence, recorded as a CORRESPONDENCE row.

---

## 5. Verification ladder

Costs are measured on this Mac with the Mathlib cache present (by B unless marked). The last column gives when each step runs: **A** = every judged attempt, **R** = every round, on the stream head after `accept`, **M** = at a milestone, before FORMALLY_VERIFIED.

| # | Step | Command | Catches | Cost | When |
|---|---|---|---|---|---|
| L0 | scratch tree; base builds | `git worktree add -b proofloop/<run>/<key> TREE <sha>`; `cp -c -R <wt>/.lake TREE/`; `lake build` | broken base (`BASE_BROKEN`), dirty-tree contamination | 0.06 s + 2.1–3.2 s | A |
| L1 | static: scope, `sig` freshness, imports, forbidden tokens on added text | `pl/apply.py` | out-of-scope edits, stale reads, `axiom`, `native_decide`, `run_cmd`/`addDecl`/`debug.skipKernelTC` (cheap filter for the kernel-bypass cheat), injected `notation`/`variable` | < 0.1 s (est.) | A |
| L2 | elaborate touched files | `lake env lean --json <file>` | per-declaration errors with goals; `hasSorry` | 1.6 s (Deletion) – 12.3 s (Minimality) | A (in settle) |
| L3 | build | `lake build` (rc 0 **and** "Build completed successfully") | downstream breakage; stale oleans (Lake deletes a failed module's olean, observed) | 17 s (Minimality downstream); 1–3 min if Defs-level | A, R |
| L4 | environment probe + diff | `lake env lean --json EnvProbe.lean` (Solution closure; Challenge) | changed types/values of any baseline constant (incl. via `variable`/`notation`/`instance` context); removed or renamed constants; Challenge ≠ Solution record types; record types ≠ bootstrap (catches a frozen-definition edit that changes Challenge and Solution alike) | 2–4 s warm, 29 s cold | A, R |
| L5 | axioms | probe `collectAxioms`; repo `lake env lean <Lib>/AxiomAudit.lean` kept as the recorded artefact | custom axioms; `sorryAx` (→ `blocking`); `Lean.ofReduceBool` | 4.3 s | A, R |
| L6 | kernel replay | `lake env leanchecker <touched modules…> Solution` (never the lib root module) | **the kernel-bypass cheat**; any kernel/elaborator disagreement in touched modules | 3.6 s single; 15.4 s Minimality + Solution | A, R |
| L7 | repo checks + frozen bytes | `python3 scripts/check-lean-sources.py`; `ruby scripts/validate-formalization.rb`; `git diff --quiet $bootstrap -- $frozen_files`; `never_edit` bytes vs base | module headers, size limits, metadata; byte-level freeze ("definitions frozen byte-for-byte") | 0.02 + 0.23 + < 0.1 s | A, R |
| M1 | replay every project module | `lake env leanchecker <each module except the lib root>` | anything in untouched modules (e.g. a cheat merged before the judge existed) | ≈ 1 min for Betti's 23 non-root modules (derived from B's 11 min 46 s full sweep, in which the root module alone took ≈ 11 min) | M |
| M2 | comparator | CI job running `scripts/verify-comparator.sh` (Linux + bubblewrap), read via `gh run list --commit <sha>` | statement mismatch and extra axioms, by an independent implementation | CI minutes; 0 local | M |
| M3 | fresh replay | `lake env leanchecker --fresh Solution` | trust in the cached Mathlib oleans | hours, 1 core | M, optional (§10) |
| M4 | independent kernel | `lake env leanexport Solution` + nanoda | Lean-kernel bugs | ≈ 6 GB export + hours | not required |

**The kernel-bypass cheat.** B reproduced it in an APFS clone of Betti stream-B:
- `set_option debug.skipKernelTC true in run_cmd … addDecl` installs `cheat : False := True.intro`, then `H_degree_lt_D := cheat.elim`.
- Everything that does not replay the touched module stays green: `lake build` rc 0; `#print axioms` lists only `[propext, Classical.choice, Quot.sound]`; `lake env leanchecker Solution` rc 0, because it replays only Solution's own declarations.
- `lake env leanchecker FiveGenBetti.Family.Minimality` exits 1 with `(kernel) declaration type mismatch, 'FiveGenBetti.Family.cheat' has type True but it is expected to have type False`.

So L1 blocks the obvious spellings, L6 on touched modules is the guarantee, and M1 covers older merges.

The lab's `make lean-check` is not used. Its `rg '\b(sorry|admit|axiom)\b'` always fails on Palomar-shaped repos (the deliberate Challenge sorries, the `#print axioms` text), and it misses both statement drift and kernel bypass. Gate checks F1 and F2 replace it.

**Sorry counting.**
- Primary: the `hasSorry` diagnostics, one per declaration whose own body uses `sorry`, split into `{challenge, development}` plus `excluded` for files in `excluded_scopes`. Those are elaborated separately, because Betti's `Targets` is not a default build target.
- Secondary: a comment-stripped `\b(sorry|admit)\b` token scan. It can be higher than the primary count when one declaration holds several sorries.
- Decisive: `sorryAx ∉ axioms(record)`.

**Measured 2026-10-16.**

| Location | Count | Detail |
|---|---|---|
| size-ramsey main `b17d1fa` | **67** (5 Challenge + 62) | Basic 7, SmallGraphs 6, Deletion 9, Components 9, Reductions 8, Tightness 4, Universal 1, Upper 5, ColoringBase 3, Coloring 2, Equality* 8. Measured by a `lake build --no-build` replay (1.1 s); `grep -rw sorry` also gives 67. CONTEXT's "69" is wrong. |
| Betti main `d12682a` | **29** (2 + 27) | all 27 are stream-B stubs |
| Betti stream-B `6d054ec` | **33** | 2 + 9 Minimality + 22 Stream-A stubs that main has proved |
| Betti, main merged into stream-B | **11** (2 + 9) | expected |
| Betti `Targets/FiniteWidth.lean` | **1** | outside the default targets |

`formalization.yaml` is stale in both repos: size-ramsey says 12 where it should say 67, and Betti main says 4 where it should say 29. The Challenge-inclusive convention matches `~/semigroup-betti`, whose `sorry_count: 2` counts its two Challenge stubs.

---

## 6. Per-repo config: `proofloop.toml`

This is the only per-repo file. It sits at the repo root, is committed, and holds data only, so it is as harmless in a Palomar submission as `comparator.json`. Schema `proofloop/config/1`:
- every key below is required unless marked optional;
- paths are relative to the repo root;
- globs use `fnmatch` with `**`;
- `~` is expanded.

```toml
# ~/size-ramsey/proofloop.toml
schema        = "proofloop/config/1"
project       = "size-ramsey"                  # astra --project tag and cache key
lib           = "SizeRamsey"
claim         = "claim_0004"                   # lab claim this repo formalizes
bootstrap     = "a979fb0"                      # frozen-interface commit: records + frozen-file baseline
records_from  = "comparator.json"              # theorem_names + permitted_axioms (gating)
extra_records_from = ""                        # optional; reported, never gating
challenge     = "Challenge.lean"
solution      = "Solution.lean"
axiom_audit   = "SizeRamsey/AxiomAudit.lean"
probe_modules = ["Solution"]                   # EnvProbe imports (Challenge probed separately)
proof         = "docs/PROOF.md"
plan          = "docs/astra/2026-10-16_lean_plan.md"
correspondence = "CORRESPONDENCE.md"
correspondence_table_heading = "Build and audit record"
sorry_count_convention = "challenge_inclusive" # formalization.yaml status.sorry_count = all hasSorry
frozen_files  = ["SizeRamsey/Defs.lean", "SizeRamsey/Shared.lean", "SizeRamsey/AInterface.lean"]
never_edit    = ["Challenge.lean", "Solution.lean", "SizeRamsey.lean", "SizeRamsey/Main.lean",
                 "SizeRamsey/AxiomAudit.lean", "lakefile.toml", "lean-toolchain", "lake-manifest.json",
                 "comparator*.json", "proofloop.toml", "scripts/**", ".github/**"]
excluded_scopes = []

[streams.A]
worktree = "~/size-ramsey-streamA"
branch   = "lean/stream-A"
owned    = ["SizeRamsey/Basic.lean", "SizeRamsey/FiniteChecks.lean", "SizeRamsey/SmallGraphs.lean",
            "SizeRamsey/Deletion.lean", "SizeRamsey/Components.lean", "SizeRamsey/Reductions.lean",
            "SizeRamsey/Universal.lean", "SizeRamsey/Tightness.lean"]

[streams.B]
worktree = "~/size-ramsey-streamB"
branch   = "lean/stream-B"
owned    = ["SizeRamsey/Upper.lean", "SizeRamsey/ColoringBase.lean", "SizeRamsey/Coloring.lean",
            "SizeRamsey/Equality.lean", "SizeRamsey/Equality/**"]

[[import_rules]]                                # NOTES.md: B imports A only through AInterface
stream = "B"
forbid_streams = ["A"]                          # A-owned project modules are not importable from B files
note = "use SizeRamsey.AInterface"

[brief]
helper_namespace = "SizeRamsey.Plan"
extra_rules = [
  "`attribute [local instance] Classical.propDecidable` is already active where needed; do not add others.",
  "Keep the unused-`[Fintype V]` linter warnings on frozen signatures (NOTES.md 'Remaining linter warnings').",
  "Never use ℕ subtraction in counting identities; prove additive forms (plan §5).",
]
```

```toml
# ~/five-generator-betti/proofloop.toml
schema        = "proofloop/config/1"
project       = "five-generator-betti"
lib           = "FiveGenBetti"
claim         = "claim_0005"
bootstrap     = "2869b0b"
records_from  = "comparator.json"
extra_records_from = "comparator.all-targets.json"   # adds W; must fail until W is proved; never gating
challenge     = "Challenge.lean"
solution      = "Solution.lean"
axiom_audit   = "FiveGenBetti/AxiomAudit.lean"
probe_modules = ["Solution"]
proof         = "docs/PROOF.md"
plan          = "docs/astra/2026-10-16_lean_plan.md"
correspondence = "CORRESPONDENCE.md"
correspondence_table_heading = "Build and audit record"
sorry_count_convention = "challenge_inclusive"
frozen_files  = ["FiveGenBetti/Defs.lean", "FiveGenBetti/Interface.lean", "FiveGenBetti/Certificate/Defs.lean"]
never_edit    = ["Challenge.lean", "Solution.lean", "FiveGenBetti.lean", "FiveGenBetti/Main.lean",
                 "FiveGenBetti/Family/Main.lean", "FiveGenBetti/AxiomAudit.lean", "Targets/**", "vendor/**",
                 "lakefile.toml", "lean-toolchain", "lake-manifest.json", "comparator*.json",
                 "proofloop.toml", "scripts/**", ".github/**"]
excluded_scopes = ["Targets/"]

[streams.A]                                     # complete and merged to main (A1–A5)
worktree = "~/five-generator-betti-streamA"
branch   = "lean/stream-A"
owned    = ["FiveGenBetti/Algebra.lean", "FiveGenBetti/Fiber.lean", "FiveGenBetti/Bridge.lean",
            "FiveGenBetti/Graded/**", "FiveGenBetti/GradedGenerators.lean"]

[streams.B]
worktree = "~/five-generator-betti-streamB"
branch   = "lean/stream-B"
owned    = ["FiveGenBetti/Family/Defs.lean", "FiveGenBetti/Family/Data.lean", "FiveGenBetti/Family/Relations.lean",
            "FiveGenBetti/Family/NormalForms.lean", "FiveGenBetti/Family/Generation.lean",
            "FiveGenBetti/Family/Apery.lean", "FiveGenBetti/Family/Minimality.lean", "FiveGenBetti/Examples/**"]

[conjectures.W]
claim          = ""                             # set to the new claim id (expected claim_0006) once opened
record         = "FiveGenBetti.beta1_five_le_two_width_add_two"         # Challenge.lean, all-targets only
lean_file      = "Targets/FiniteWidth.lean"
lean_decl      = "FiveGenBetti.Targets.beta1_five_le_two_width_add_two"
correspondence_section = "4. Hypotheses of W"
evidence       = "~/aiseminar/experiments/local/2026-10-16_semigroup_e5_family_tests/out/MANIFEST.json"
tested_range   = "4 ≤ w ≤ 20 (all m)"
claimed_range  = "4 ≤ w ≤ 40"
background     = ["docs/PROOF.md", "docs/astra/2026-10-16_workflow_betti.md", "vendor/SemigroupBetti-aa266b8/"]

[brief]
helper_namespace = "FiveGenBetti.Family"
extra_rules = [
  "`relation_nonredundant` must hold for every field K, including positive characteristic.",
  "Natural subtraction `k-1`, `q+1+r-k` is ℕ; never restate it over ℤ in signatures.",
]
```

---

## 7. Run model

**One run per claim.** size-ramsey runs as claim_0004 (`lean`), Betti as claim_0005 (`lean`), and W as its own new claim (`informal`). "One Astra agent per repository" is read as one *campaign* per repo, made up of file-jobs. A single 62-sorry turn cannot cover 6–23 plan agent-days in 90 minutes, and one failure would sink the whole round. `--jobs-per-repo 1` enforces the literal reading instead (§10, question 5).

**Stages, `lean` kind:**
1. **prove r.** One job per target group in a stream. All jobs in the round read the stream worktree at one `base_sha`. Limits: ≤ 3 per repo, ≤ 5 in total, never two jobs on one file. Defaults: `xhigh`, 10800 s.
2. **judge.**
   - A background `wait --any` files each reply as it lands and runs apply → settle → judge; the orchestrator reads `verdict.md` and `accept`s PROGRESS or RECORDS_PROVED branches.
   - After the round, `judge --round r` runs on the stream head. Failed targets get `lean-repair` briefs, ≤ 3 attempts each.
   - Escalation: type plumbing (≤ 3 errors, known goals, no missing mathematics) goes to a Claude Opus coding subagent. Anything else goes to a per-stream strategy brief (no proof text) or a contract request for Ben.
   - The stall rule sets `stage: blocked`.
   - Once both streams are clean, the orchestrator integrates, by hand or with a subagent (plan §4: merge streams, `Main`, `Solution`, `AxiomAudit`). `judge` must then return RECORDS_PROVED, followed by M1 and M2.
3. **adversary ×2.** `meaning` and `trust`, in parallel, on the integration commit.
4. **respond.** `review-stub` and `respond-skel` scaffold the files. The orchestrator answers every finding, fixes Lean or CORRESPONDENCE as needed (which may loop back to judge), and records `substantive`.
5. **reviewer.** If R3 fires, the forced third adversary pass runs next.
6. **independent.** `statement_recon`, run isolated.
7. **gate.** Runs after `evidence-lean`, after `emit correspondence|formalization` (committed to the integration branch), and after comparator CI.
8. **promote.** `aimath promote … --gate`, then `aimath packet journal`.

**Stages, `informal` kind (W):**
1. Open the claim: `make claim`, then gated SPECULATIVE → EMPIRICAL (E1, the existing MANIFEST) and EMPIRICAL → CONJECTURED (C2, tested w ≤ 20 against a claimed 40).
2. prove: one conjecture job.
3. judge: the orchestrator reads the reply, re-runs every computation block under `experiments/` with `aimath manifest`, and cross-checks every finite claim against the test-3 data.
4. Claude writes PROOF.md in full; CONJECTURED → PROOF_ATTEMPT (P1, P2).
5. adversary (`refute` + `reduction`), moving to UNDER_REVIEW at submission (U1).
6. respond → reviewer → independent prover → gate → VERIFIED.

If the result is only a reduction to a finite check over w ≤ 40, the claim is *computer-assisted*, and CLAIM.md states exactly the proved scope. W never enters the Lean run.

**Resumability.** All state is in `run.json` and in files.
- `summary --all` restores context in a new session.
- `wait` can be re-run at any time; Astra workers are detached, and `--out` files replies without Claude.
- Dead jobs are re-run with `resubmit`.
- `collect`, `apply`, `judge` and the emitters are idempotent.

**Claude-token budget per stage:**

| Stage | Reads | Budget |
|---|---|---|
| first brief of a template | the rendered brief once (afterwards only the inventory table) | 3–4k, then ≤ 1k |
| submit / wait | summary table | ≤ 0.5k per wake-up |
| judge (per reply) | `verdict.md`; `git diff` only on flags or `rejected_frozen_change` | 1–2k (≈ 5k with diff) |
| repair round / contract request | target table / the `contract` block | ≤ 1k / 1–3k |
| adversary (per pass) | review-stub lead lines, then full text of findings to answer | 6–15k |
| respond | writes answers and fixes | 3–8k output |
| reviewer | verdict + NOT RESOLVED items | 1–3k |
| independent / statement recon | the full reconstruction | 5–10k |
| gate / promote / emitters | gate table, emitter diffs | ≤ 2k |
| **whole campaign, per repo** | | **≈ 60–120k** |

**Orchestrator judgment.** The tools record these decisions but never make them:
- `accept`;
- contract requests and any `rejected_frozen_change` (to Ben, recorded as a NOTES "contract deviation");
- chunking and escalation;
- whether a pass was substantive, and whether a response answers a finding;
- V4 agreement and the F10 correspondence argument;
- whether W's argument is a proof, and how its scope is worded;
- integration edits, waivers and overrides.

---

## 8. Skill extraction

**Why a skill.** The default was "lives in size-ramsey, extracted only if generically useful". The code is generic by construction: it holds no repo constants, and both repos use it unchanged through `proofloop.toml`. In `~/size-ramsey/scripts/` it would ship orchestration tooling inside a Palomar submission, and Betti would have to call into another project's tree. So only this design lives in size-ramsey; the code starts as a skill.

```
~/.claude/skills/proofloop/
  SKILL.md
  scripts/proofloop.py                       # CLI dispatch (~150)
  scripts/pl/{config,leanio,splitter,inventory,preflight,brief,contract,apply,probe,judge,run,emit}.py
  lean/EnvProbe.lean.tmpl
  templates/{lean_prover,conjecture_prover,adversary,reviewer,independent_prover,statement_recon,
             reply_lean,reply_conjecture,sandbox_probe}.md   templates/framings.toml
  tests/{unit,redteam,fixtures}/             # fake astra via PROOFLOOP_ASTRA
```

**Lab side.** `src/aimath/{gate,replies,packet}.py` with their CLI subcommands; Makefile targets `gate`, `respond-skel` and `review-stub`; and `agents/astra/prompts/{lean_prover,conjecture_prover,statement_recon}.md`.

**SKILL.md outline:**
1. When to use: "prove the remaining sorries with Astra", "run the proof loop on <repo>", "take claim X to FORMALLY_VERIFIED", "resume run R", "judge this branch".
2. Prerequisites: the astra skill, `$PROOFLOOP_LAB` with `aimath`, `proofloop.toml`, a passed preflight.
3. The loop as a table: stage → command → what to read → which judgment to record.
4. Waiting: `wait` always with `run_in_background: true`; never poll; `summary --all` in a new session.
5. Safety: scratch trees only, never main or a dirty tree; merge only via `accept`; the verdict decides, not Astra.
6. Protocol: never edit STATUS.yaml by hand; `aimath gate`, then `aimath promote --gate`; W gets its own claim.
7. Failures: dead jobs, a missing verdict, a refused brief, `BASE_BROKEN`, a blocked gate.
8. What is repo-specific: only `proofloop.toml`.

**What belongs where.** Generic: all skill code, the reply contract, the ladder, the framings and the run schema. Repo-specific: `proofloop.toml`. Lab-owned: the gate rules and the role prompts.

**Minimal first release (≈ 6.5 d).** `preflight`, `inventory`, `probe`, `judge` with the red-team suite passing, `apply` + `settle`, `brief` (three prover modes), the three lab role prompts, and `init/submit/collect` with a `run.json` that has no review stages. The gate, the emitters and the review briefs follow before the first promotion.

---

## 9. Immediate next actions (today, 2026-10-16)

None of the tools exists yet, so today's briefs are written by hand from §3 and §4. Replies wait in the job directories until `apply` and `judge` exist, so submitting early loses nothing.

1. **Probe the sandbox first** (effort low, 5–15 min).
   - Run the §2.3 probe by hand with `--cwd ~/five-generator-betti-streamB` and read the exit codes in `events.jsonl`.
   - If `lean_ok` is false, materialise the packages with `cp -c -R -p` and probe again.
   - Record the outcome in the journal.
2. **Merge main into Betti stream-B.**
   - Run `git -C ~/five-generator-betti-streamB merge main`. A's `git merge-tree` showed it merges cleanly, and Stream A is complete on main.
   - Run `lake build`; expect 11 `hasSorry`.
   - Fix the stale stream-B status column in `FiveGenBetti/NOTES.md` (5 min).
3. **Send Betti `Family/Minimality.lean` (9 sorries) to Astra** in `lean-sorry` mode, as one job covering all 9.
   - Why Astra: this is the mathematical core of B5. The three nonredundancy theorems need the six ψ/degree lemmas, and the plan estimates 4–7 days.
   - Flags: `--cwd ~/five-generator-betti-streamB --system <_common+lean_prover> --effort xhigh --timeout 10800 --out ~/aiseminar/agents/astra/transcripts/<stamp>_lean_prover_claim_0005_minimality_r1.md`.
   - Expect a mix of PROVED and DRAFT. Round 2 splits the nonredundancy group out.
4. **Give size-ramsey `Deletion.lean` (2 coercion errors + 4 sorries, uncommitted on stream-A) to a Claude Opus coding subagent first.**
   - Why a subagent: both errors are type plumbing with known goals (`{v // v ∉ D} = ↑{x | x ∉ D}` and a Finset-vs-Set filter). Minutes for a subagent, against a 5–90-minute Astra turn that cannot write files.
   - Deletion also blocks Components, Reductions, Universal and Tightness.
   - Budget: about 1 h, including the 4 A4 sorries (plan lines 1352–1404).
   - Commit to `lean/stream-A` only when `lake build` is green and `lake env leanchecker SizeRamsey.Deletion` exits 0.
   - Whatever sorries remain join stream-A round 1 for Astra, together with Components.
5. **Start build items 1–3** (an Opus agent: preflight, inventory, judge + EnvProbe + red-team) while Astra runs. The first real test is `judge --tree` on step 4's Deletion commit.
6. **Optional today:** send size-ramsey stream-B `Upper.lean` (5 sorries) as a second Astra job. B files import only `AInterface`, which builds at bootstrap.
7. **Optional, Ben's call:** open the W claim (`make claim` + two gated promotions to CONJECTURED) and submit the conjecture-prover job (§4.2). It is a separate claim and does not compete with Minimality.

---

## 10. Risks and open questions for Ben (policy calls)

1. **Comparator for FORMALLY_VERIFIED?** AGENTS.md does not require it; the workflow lists it. *Recommendation:* require comparator CI success at the promoted commit (F7), with a recorded waiver that only Ben can grant.
2. **Confirm the sandbox boundary before any run?** *Recommendation:* yes for elaboration through the symlinked `.lake/packages`. It is a single probe of under 15 min (§9 step 1), and without it a 90-minute turn may run blind. Out-of-cwd reads should not block proving: they matter only for isolating the independent prover, which then rests on the `events.jsonl` scan.
3. **Require `--fresh` and nanoda?** *Recommendation:* no. Require M1 and M2, and record M3 and M4 as "not run", as `~/semigroup-betti` does.
4. **AGENTS.md amendments.**
   - §2: the astra skill's `submit/wait --out` becomes the transport; retire `scripts/astra_fanout.py`; document `requests/` and the transcript names.
   - §3/§9: FORMALLY_VERIFIED may point at an external pinned repo through a STATUS.yaml field `formalization: {repo, commit}`, with ladder L0–L7 + M1–M2 as the required record. `lean/<claim>/` and the `rg` check do not fit Palomar repos.
   - §4: statement reconstruction counts as the Lean-route independent reconstruction (a new rule).
5. **Literal "one Astra agent per repository"**, or a campaign of ≤ 3 concurrent file-jobs per repo? The design defaults to the campaign.
6. **Frozen-interface changes.** *Recommendation:* every `contract` request needs Ben, and each is recorded as a NOTES "contract deviation".
7. **Gate overrides on FORMALLY_VERIFIED.** *Recommendation:* only with Ben's explicit approval, recorded in history.
8. **Lab footprint.** Run directories are committed under `~/aiseminar/agents/runs/`, and prover transcripts are 50–100 KB each. Is that acceptable?
9. **Config placement.** Each repo root gets a data-only `proofloop.toml`, which ships in the Palomar submission. Is that acceptable, or should it sit beside the claim packet?

Technical risks (settled by tests, not by Ben):
- **EnvProbe value-hash stability under helper insertion** (`match_`/`proof_` auxiliaries may be renumbered). Red-team fixture (g) and a "helper before a def" fixture decide it. The fallback, byte comparison of frozen sources, is still exact.
- **Splitter fragility** on `mutual`, `where` and indented declarations. It refuses rather than guesses, and the round-trip test covers all three repos.
- **`leanchecker` on the library root** takes about 11 min, and why is not understood. It is excluded from per-attempt runs.
- **Over-claimed elaboration.** Astra's claim is never used to route; `self_checked` from `events.jsonl` cross-checks it.
- **Stdin vs on-disk elaboration of `module` files.** Parity is unverified, so the judge always elaborates on disk.
- **Read roots moving mid-turn.** `accept` refuses while a job is live, and `sig` tokens catch the rest.
- **W framing.** The brief says "prove or refute", states that w ∈ [21, 40] is untested, and asks for counterexample attempts there first.
