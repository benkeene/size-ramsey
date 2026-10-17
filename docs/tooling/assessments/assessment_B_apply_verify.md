# Assessment B: ingesting and verifying Astra's reply (apply + judge)

Assessor B, 2026-10-16. Lens: workflow step 2 (CONTEXT.md §3), from "`reply.md` exists" to "the
orchestrator knows, in a few hundred tokens, whether the theorem is now proved". Steps 1 and 3
are covered only where they constrain step 2.

Files read: `~/aiseminar/{MISSION.md,AGENTS.md,Makefile}`, `~/aiseminar/agents/astra/{invoke.py,prompts/_common.md}`,
`~/aiseminar/agents/shared/claim_0005/STATUS.yaml`, `~/.claude/skills/astra/SKILL.md`,
`~/.claude/skills/astra/scripts/astra.py` (outline), both repos' `Challenge.lean`, `Solution.lean`,
`<Lib>/AxiomAudit.lean`, `<Lib>/NOTES.md`, `comparator.json` (+ Betti `comparator.all-targets.json`),
`formalization.yaml` (status block), `lakefile.toml`, `.github/workflows/ci.yml`, `scripts/*`
(byte-identical in both repos), `CORRESPONDENCE.md` (headings), Betti `Targets/FiniteWidth.lean`
and `FiveGenBetti/Family/Minimality.lean` (stream B), `docs/astra/2026-10-16_lean_plan.md` §4–§6,
`~/semigroup-betti/README.md` "Verification".

Experiments run (no repository file was edited; all mutations happened in an APFS clone of
`~/five-generator-betti-streamB` under the scratchpad, `.../tooling-assessment/clonetest/`, whose
`.git` link I deleted first so no git command could touch the real repo). Logs are next to this
file: `B_betti_build.log`, `B_sr_build.log`, `B_deletion.json`, `probe/*.lean`, `lc*.out`.

---

## 1. Summary of recommendations (ranked by value / effort)

1. **The judge must include a kernel replay (`leanchecker`) of every touched module. `#print axioms`
   alone is not enough. I showed this.** In the clone I added, before a stub, a
   `set_option debug.skipKernelTC true in run_cmd … addDecl` that installs `cheat : False` with
   the value `True.intro`, and proved `H_degree_lt_D` by `cheat.elim`. Results: `lake build` exit 0;
   `#print axioms FiveGenBetti.Family.H_degree_lt_D` gave `[propext, Classical.choice, Quot.sound]`
   (looks clean); `lake env leanchecker Solution` exit 0 (it replays only Solution's own
   declarations); `lake env leanchecker FiveGenBetti.Family.Minimality` exit 1 with
   `(kernel) declaration type mismatch, 'FiveGenBetti.Family.cheat' has type True but it is expected to have type False`.
   Per touched module this costs about 4 s. The cheap first filter is a forbidden-construct scan of
   the added text (`run_cmd`, `elab`, `set_option debug.`, `addDecl`, …), described in §2 T4.
   **Value: decisive. Effort: about 20 lines.**
2. **Decide "proved" from the Lean environment, never from text and never from the applier.** A small
   Lean probe file kept *outside* the repo (`EnvProbe.lean`, run with `lake env lean --json`)
   prints, for every project constant: kind, module, declaration range, a structural hash of the
   type, a hash of the value (definitions only), and `collectAxioms`. Comparing the probe output
   before and after the patch gives, in one step: the frozen-definition check, the signature
   check (it sees the elaborated type, so it catches `variable`, instance and notation tricks that
   a text diff misses, and it ignores pure reformatting), missing or renamed constants, and
   per-declaration axioms. I prototyped it (`probe/Probe.lean`, `probe/FP_*.lean`). It runs in
   2–29 s, and the Challenge and Solution hashes of `family_spanRank_eq`, `toricIdeal`,
   `familyGens` and `MinimallyGenerates` came out identical. That is a Mac-runnable,
   statement-level stand-in for the Linux comparator. **Value: very high. Effort: about 80 lines of Lean plus 60 of Python.**
3. **A strict reply contract with addressable patches.** Astra emits fenced blocks such as
   ` ```lean patch decl=<FullName> mode=body ` (or `mode=decl`, `mode=helper anchor=<FullName>`,
   `mode=import file=<path>`). The applier finds the target through the probe's declaration
   ranges, so it never guesses with a regex. In `body` mode it replaces only the final
   `:= by\n  sorry` of a stub whose shape is canonical. **Value: high (removes most applier
   ambiguity). Effort: about 150 lines of Python.**
4. **A scratch worktree cloned from the stream branch with the build cache.** Run
   `git worktree add -b astra/<job> <scratch> <base-sha>`, then `cp -c -R <stream>/.lake <scratch>/`.
   The APFS clone took 0.06 s, it keeps the `packages` symlink, and the following `lake build` was a
   no-op in 3.2 s, so Lake accepted the copied traces. Main and the stream worktrees are never
   dirtied, and every attempt leaves a reviewable branch. **Value: high. Effort: about 40 lines.**
5. **A per-declaration fixpoint ("settle").** Apply all patches, build, map each error (JSON
   `pos`) to the patch whose inserted line range contains it, revert those patches to `sorry`,
   and repeat until the build is green. Then commit the survivors with their statuses. Lean
   recovers from errors per declaration, so one pass usually reports every failing patch; a
   second pass catches dependents of a reverted helper. **Value: high (salvages partial
   success). Effort: about 80 lines.**
6. **A machine verdict (`verdict.json`) plus a summary of 40 lines or fewer (`verdict.md`).** The
   orchestrator reads only `verdict.md` (a few hundred tokens). It opens the JSON or the branch
   diff only when something needs judgment. Schema in §3. **Value: high (token compression).
   Effort: about 60 lines.**
7. **A round-2 feedback file (`feedback.md`, under about 6 KB).** For each failed patch it lists
   the first error, the goal state truncated to 25 lines, and the applied text. Round 2 runs with
   `--cwd <scratch worktree>`, so Astra sees the partially proved tree, and with
   `--file feedback.md`. **Value: medium-high. Effort: about 60 lines.**
8. **An informal-proof triage path (Theorem W).** It cannot be built. The tool only extracts and
   lints it: it checks for a theorem statement, labelled lemmas each with a proof, cited labels
   that are defined, words such as "sketch", "similarly" or "omitted", and computational claims
   that need an independent re-run. It writes a `PROOF_ATTEMPT` candidate file and routes it to
   the adversary step. It never sets any status. **Value: medium. Effort: about 100 lines.**
9. **A red-team fixture suite for the judge** (§2 T8). These are about ten canned malicious or
   broken replies, applied to a pinned commit, each with its expected verdict. Run it before
   trusting the tool and after every change to it. **Value: high (it is what makes 1–6
   trustworthy). Effort: about 1 day, mostly writing the fixtures.**

Do **not** reuse `make lean-check` from aiseminar here. Its `rg '\b(sorry|admit|axiom)\b'` always
fails on these repos, because `Challenge.lean` contains deliberate `sorry`s, and it misses both the
kernel-bypass vector and statement drift.

---

## 2. Proposed tools

One stdlib-Python CLI, `lean_ingest.py`, with subcommands, plus one Lean file, `EnvProbe.lean`, and a
per-repo `contract.json`. Each subcommand reads and writes files in a job directory,
`~/.cache/lean-ingest/<repo>/<job>/`, so every step can be rerun and inspected on its own.
`run` chains them.

### Per-repo input: `contract.json` (at the repo root; generated in step 1, reviewed once)

```json
{
  "lib_roots": ["FiveGenBetti", "Targets"],
  "probe_imports": ["Solution", "FiveGenBetti.Targets.FiniteWidth"],  // whatever module names lake uses
  "records_from": "comparator.json",
  "extra_records_from": "comparator.all-targets.json",
  "handoff": ["FiveGenBetti.Family.relation_nonredundant", "..."],
  "frozen_files": ["Challenge.lean", "Solution.lean", "FiveGenBetti/AxiomAudit.lean",
                   "FiveGenBetti/Defs.lean", "FiveGenBetti/Interface.lean",
                   "FiveGenBetti/Certificate/Defs.lean", "lakefile.toml", "lean-toolchain",
                   "lake-manifest.json", "comparator*.json", "scripts/**", ".github/**"],
  "editable": {"B": ["FiveGenBetti/Family/**"], "A": ["FiveGenBetti/*.lean", "FiveGenBetti/Graded/**"]},
  "import_rules": [{"files": "SizeRamsey/Equality/**", "may_not_import_prefix": "SizeRamsey.Deletion",
                    "note": "B imports A only via AInterface (size-ramsey NOTES)"}],
  "permitted_axioms_from": "comparator.json"
}
```

Everything specific to a repo lives here. The script has no constants.

### T1 `extract`: reply.md to patches.json

- **Purpose.** Turn Astra's Markdown into an ordered list of typed patches and an informal part.
- **Input.** `~/.claude/astra/jobs/<project>/<job>/reply.md`.
- **Output.** `patches.json`: `[{id, decl, mode, anchor?, file?, text, src_line}]`, plus
  `informal.md` (prose outside patch blocks, if there is a `## INFORMAL PROOF` section),
  `claims.json` (Astra's own `STATUS:` lines, kept only for calibration), and `unparsed[]`.
- **CLI.** `lean_ingest.py extract --reply R --job-dir J`
- **Sketch** (Python, about 120 lines).
  1. Strip the header comment written by astra.py.
  2. Scan the fences with a line state machine; a regex over the whole file breaks on nested
     backticks.
  3. Parse the info string with `shlex`: `lean patch decl=… mode=…`.
  4. Fallback for a ` ```lean ` block without attributes: if it contains exactly one
     `theorem|lemma <name>` and `<name>` resolves (in the baseline probe) to a stub, treat it as
     `mode=decl`. Otherwise put it in `unparsed`.
  5. Reject duplicate `decl=` (keep neither, report it).
- **Failure modes.** Astra drifts from the format (handled by the fallback, and visible in
  `unparsed`). A block names a short name (`psi_H`): resolve it against the baseline constants
  by suffix and accept it only if exactly one matches.
- **Tests.** Golden replies (well-formed, no blocks, nested fences, duplicates, short names).

### T2 `scratch`: isolated worktree with warm cache

- **CLI.** `lean_ingest.py scratch --repo ~/five-generator-betti-streamB --job J [--base <sha>]`
- **Steps.**
  1. Refuse a nonexistent base SHA. Default to `HEAD`; a dirty worktree is allowed because only
     the commit is used, and the dirty files are reported as a warning. Example:
     `size-ramsey-streamA` has a modified `Deletion.lean` right now.
  2. `git -C <repo> worktree add -b astra/<job> ~/.cache/lean-ingest/<repo>/<job>/tree <sha>`.
  3. `cp -c -R <repo>/.lake <tree>/.lake`. This is an APFS clone, 0.06 s measured, and it keeps
     the `packages -> ~/<main>/.lake/packages` symlink.
  4. `lake build`, which must be a no-op or close to it (measured: 3.2 s Betti, 2.1 s size-ramsey).
  5. Run the baseline probe (T3), producing `baseline.json`. Cache it by SHA.
- **Failure modes.** The base itself does not build. That happens today: stream A of size-ramsey
  fails only because of the *uncommitted* Deletion, and the committed HEAD builds. In that case
  record `baseline_build: failed` and stop: you cannot judge a patch against a broken base.
- **Cleanup.** `lean_ingest.py gc` removes worktrees whose branch has been merged or abandoned,
  using `git worktree remove`.

### T3 `probe`: environment fingerprint (the core of the judge)

- **Lean file.** `EnvProbe.lean`, kept in the tool directory and never in the repo. It is generated
  per run with the repo's imports and run as `cd <tree> && lake env lean --json <probe>`.
- **What it does.** A `#eval`/`elab` command iterates `env.constants`. It keeps constants whose
  module (`env.getModuleIdxFor?`) is in the project (names under `lib_roots`, `Solution`, and
  `Targets`), and drops `Name.isInternal` and auto-generated names (`.eq_<n>`, `.match_<n>`,
  `._proof_<n>`, `.proof_<n>`). For each constant it emits **one JSON object per line** through
  `IO.println`:
  `{"n":…, "kind":"thm|def|inst|ax|opaque|ctor|rec|induct", "mod":…, "range":[l0,c0,l1,c1], "sel":[l,c],
    "ty":<hash type>, "val":<hash value or null>, "ax":[…], "lp":[…]}`.
  The range comes from `findDeclarationRanges?`. Use `IO.println`, not `logInfo`: `logInfo`
  wrapped long axiom lists across lines in my run.
- **Second probe.** `Probe_challenge.lean` imports only `Challenge` and fingerprints the record
  names and the definitions they mention. The same names exist in Solution, so the two cannot be
  imported together.
- **Observed** (prototype, `probe/FP_Challenge.lean` and `probe/FP_Solution.lean`, Betti stream B):

  ```
  FP|FiveGenBetti.family_spanRank_eq|3214739211|-
  FP|FiveGenBetti.toricIdeal|1792096711|3584580939
  FP|FiveGenBetti.familyGens|2182590791|3662714855
  FP|FiveGenBetti.MinimallyGenerates|98267386|3964533747
  ```

  The output was identical from Challenge (1.95 s) and Solution (4.38 s). The first probe after
  a build took 29 s wall at 23 % CPU, almost all of it loading the Mathlib oleans with a cold
  page cache.
- **Lines.** About 80 Lean, plus about 60 Python to diff two probe outputs into
  `{changed_type[], changed_value[], removed[], added[]}`.
- **Failure modes.**
  - The structural `Expr` hash ignores binder *names*. Renaming `hk` to `h` is invisible.
    That is semantically harmless, and a named-argument call that breaks shows up as a build
    error downstream.
  - 64-bit collisions are negligible.
  - The hashes of definitions compiled by structural recursion depend on auxiliary names. These
    are stable when the definition's text is unchanged; a false *reject* is possible in principle
    (for example, a helper inserted before a definition shifts nothing per-declaration, but this
    needs testing), and a false accept is not.
  - Optional: for `changed_type`, also print `ppExpr` with `pp.all` for the summary.

### T4 `apply`: patches into the scratch tree (deliberately dumb)

- **CLI.** `lean_ingest.py apply --job-dir J [--only id,id] [--revert id,id]`
- **Rules.** Applied in order. Each one is checked statically first, and any violation becomes
  `rejected_*` without touching the file.
  1. `decl` must exist in `baseline.json`. Otherwise the result is `not_found`. The target file
     comes from the probe's `mod`, never from Astra's claim.
  2. The file must be in `editable[owner]` and not in `frozen_files`. Otherwise
     `rejected_out_of_scope`. The owner is inferred from the file; a patch that crosses streams is
     out of scope.
  3. `mode=body`: the baseline declaration text (by range) must end with the regex
     `:=\s*by\s*\n\s*sorry\s*\Z`, and must match it exactly once. Replace only that tail with
     `:= by\n` plus `textwrap.indent(textwrap.dedent(text), "  ")`. The signature bytes stay
     untouched by construction. If the stub is not canonical (it is partly proved, or has internal
     `sorry`s), demand `mode=decl`.
  4. `mode=decl`: replace the whole range, and record `sig_text_changed` if the normalized text
     before the first top-level `:=` differs from baseline. That is advisory; the probe is the
     judge.
  5. `mode=helper anchor=X`: insert immediately before X's range, in the same section, so the
     section `variable`s match. Only `theorem`, `lemma` and `private theorem/lemma`, and
     `def`/`abbrev` with a warning, are allowed.
  6. `mode=import`: one line each, of the form `^(public )?import [A-Z][\w.]*$`, appended to the
     file's import block. `import Challenge` is rejected, and `import_rules` from the contract
     apply.
  7. **Forbidden-construct scan of the added text only.** Rejected:
     - `sorry`, `admit`, `native_decide`, `decide +native` and `Lean.ofReduceBool`, `Lean.trustCompiler`;
     - `axiom`, `opaque`, `unsafe`, `partial`, `@[extern`, `implemented_by`, `@[csimp]`;
     - `run_cmd`, `run_tac`, `run_elab`, `#eval`, `elab`, `macro`, `syntax`, `notation`,
       `initialize`, `builtin_`;
     - `set_option debug.`, `set_option maxHeartbeats 0`, `set_option maxRecDepth`;
     - `open Lean` (meta access), `addDecl`, `Environment`, `attribute [local instance]` that is
       not `Classical.propDecidable`, `instance` in a body.

     The scan runs on text with comments and strings stripped, using the same comment stripper
     as `scripts/check-lean-sources.py`. A hit produces `rejected_forbidden:<token>`. This scan is
     the cheap filter. Leanchecker (T5 L6) is the guarantee.
- **Output.** The edited files, and `applied.json` with `{id → {file, line_start, line_end}}` in
  the post-patch coordinates, recomputed after every insertion. This is what attributes errors to
  patches.
- **Lines.** About 150 Python. The applier never decides proof status.

### T5 `verify`: the ladder (§4), producing verdict.json and verdict.md

- **CLI.** `lean_ingest.py verify --job-dir J`
- **Gates.** Only a green `lake build` (exit 0 **and** `Build completed successfully` in the log)
  unlocks the probe, the axiom audit and leanchecker. Lake deletes the olean of a failed module:
  I observed `object file …/Minimality.olean … does not exist`. So a stale environment cannot
  silently pass, but the gate makes that explicit.
- **Per-declaration status.**
  - `proved`: its own text has no `hasSorry`, its axioms ⊆ permitted, and leanchecker passed on
    its module.
  - `proved_modulo_sorry`: the body is clean but the axioms contain `sorryAx` through its
    dependencies. This is the NOTES legend "assembled".
  - `still_sorry`, `build_error`, `rejected_*`, `not_found`.
  - `regressed`: it was `proved` in baseline and is not now. Checked over the whole environment,
    not only the patched declarations.
- **Lines.** About 200 Python.

### T6 `settle`: partial-success fixpoint and commit

- **CLI.** `lean_ingest.py settle --job-dir J [--commit]`
- **Loop.**
  1. `apply all`, then build.
  2. For each error message (`lake env lean --json` / build log `file:line:col`), find the patch
     whose `[line_start, line_end]` contains it. An error outside every patch, for example in a
     downstream module, is attributed to *all* patches in the upstream touched files, and the
     tool falls back to bisection over them, at most log2(k) builds.
  3. Mark those patches `build_error`, revert them, and rebuild.
  4. Stop when green or when nothing is left. A reverted helper makes its dependents fail with
     `Unknown identifier`, which round 2 of the loop catches.
  5. Then run the full ladder on the survivors.
  6. With `--commit`, create a commit on `astra/<job>`: one commit containing the surviving
     patches, with a message that lists the declarations proved and still open, the job id, and
     the attribution line. The tool **never** merges into `lean/stream-*` or main. Merging is the
     orchestrator's explicit fast-forward,
     `git -C ~/<repo>-streamB merge --ff-only astra/<job>`, after reading `verdict.md`.
- **Cost.** Usually two or three builds of the touched module plus its downstream modules
  (measured: 17 s for a Minimality edit in Betti).

### T7 `feedback`: compact round-2 input for Astra

- **CLI.** `lean_ingest.py feedback --job-dir J > J/feedback.md`
- **Content.** For each non-proved patch:
  - the name, status and file:line;
  - the first error message (`kind` and `data` from the JSON), with the goal state truncated to
    25 lines;
  - the text as applied, or a pointer to the reverted version on the branch;
  - for `rejected_*`, the rule broken.
  The file ends with a list of "declarations now proved on branch `astra/<job>` at `<sha>`", so
  Astra builds on them.
- **Size.** It is capped at about 6 KB; if it is longer, only the first error per declaration is
  kept.
- **Round 2.** `astra.py submit --cwd <tree> --file J/feedback.md …`. Astra can then read, and
  run `lake env lean`, in the patched tree (it used `lake env lean --stdin` while planning, per
  the plan header).
- **Observed error payload** (JSON form, from `lake env lean --json SizeRamsey/Deletion.lean` in
  size-ramsey stream A, 1.6 s):

  ```json
  {"severity":"error","kind":"Tactic.unsolvedGoals","pos":{"line":171,"column":77},"endPos":{"line":172,"column":50},
   "fileName":"SizeRamsey/Deletion.lean","data":"unsolved goals\ncase e'_2.e'_1\n…\n⊢ { v // v ∉ D } = ↑{x | x ∉ D}\n…"}
  {"severity":"warning","kind":"hasSorry","pos":{"line":221,"column":8},"endPos":{"line":221,"column":23},"data":"declaration uses `sorry`"}
  ```

  `kind:"hasSorry"` and its `pos`..`endPos` span, which is exactly the declaration's name, make
  the sorry inventory exact without regex. A failed `exact?` gives
  `kind:"[anonymous]"`, `` "`exact?` could not close the goal…" ``.

### T8 `informal`: triage for Theorem W (or any reply without Lean patches)

- **CLI.** `lean_ingest.py informal --job-dir J --claim ~/aiseminar/agents/shared/claim_NNNN`
- **Checks** (about 100 lines). All are heuristics that produce flags, never a status.
  - A `## THEOREM` statement is present. Its hypotheses are echoed into the summary verbatim, so
    the orchestrator compares them with `CLAIM.md` and with the Lean target
    `Targets.beta1_five_le_two_width_add_two` (`4 ≤ w ≤ 40`, `StrictMono`, `gcd = 1`,
    `MinimallyGenerates`).
  - Every `Lemma W.n` has a `Proof` and every cited label exists, which gives a dependency graph.
  - Flags on `sketch|similarly|routine|omitted|left to the reader|clearly|it is easy`.
  - **Every computational claim** ("checked", "verified by computer", "for all w ≤ 40",
    tables) is listed as `unverified_computation`. Astra's sandbox runs leave nothing behind, and
    searcher ≠ verifier (AGENTS.md §5).
- **Output.** `J/PROOF_ATTEMPT_candidate.md`, the prose copied verbatim with the job id in its
  header, plus a `verdict.json` with `track:"informal"` and
  `route:"CONJECTURED→PROOF_ATTEMPT requires Claude to write PROOF.md in full, every lemma labelled; then adversary"`.
- **Never** writes into the claim packet automatically. Placing the file and promoting the claim
  are `make promote` decisions that belong to the orchestrator.

### T9 Red-team fixture suite (`tests/fixtures/<case>/reply.md` plus `expected.json`)

Pinned to a base SHA of Betti stream B (`6d054ec`), where B5 is a self-contained file. Cases and
expected verdicts:

| case | expected |
|---|---|
| (a) correct body for an easy stub (for example an arithmetic `H_degree_lt_D` closed by `omega`/`nlinarith` after unfolding; find one by hand first) | `proved` |
| (b) the same body with the hypothesis `hq` deleted (statement weakened) | `rejected_frozen_change` (probe `changed_type`) |
| (c) `axiom cheat : False` helper | `rejected_forbidden:axiom` (scan) and, with the scan disabled, an axioms ⊄ permitted failure |
| (d) `native_decide` | the scan rejects it; with the scan disabled, `Lean.ofReduceBool` appears in the axioms |
| (e) the `skipKernelTC` plus `run_cmd addDecl` cheat used in my experiment | the scan rejects it; with the scan disabled, leanchecker fails (I observed exactly this) |
| (f) a helper that fails, with two dependents | helper `build_error`; dependents `build_error` after the fixpoint; others kept |
| (g) whitespace and docstring change to a signature in `mode=decl` | `proved` (`sig_text_changed` advisory only) |
| (h) a patch to `Defs.lean` or `Solution.lean` | `rejected_out_of_scope` |
| (i) a reply with no blocks; duplicate blocks; unknown name | `unparsed`, `duplicate`, `not_found` |
| (j) a body that is correct but breaks a downstream module | attributed by bisection; the rest kept |
| (k) a `local notation`/`variable` added above the target, changing its meaning | `rejected_frozen_change` (type hash) |

Each fixture runs in under a minute on a warm cache. Running the suite is a `make`/`pytest`
target in the tool's own directory.

---

## 3. Verdict JSON schema (exact)

```json
{
  "schema": "lean-ingest/verdict/v1",
  "job": "five-generator-betti/20261016T213000_prove-b5",
  "astra_reply": "/Users/ben/.claude/astra/jobs/five-generator-betti/<job>/reply.md",
  "repo": "/Users/ben/five-generator-betti-streamB",
  "base_sha": "6d054ec…(40)",
  "result_branch": "astra/20261016T213000_prove-b5",
  "result_sha": "…(40) | null",
  "track": "lean | informal | mixed",
  "overall": "RECORDS_PROVED | PROGRESS | NO_PROGRESS | REJECTED | BASE_BROKEN | TOOL_ERROR",
  "gates": {
    "baseline_build": "ok | failed",
    "static_scan": "ok | rejected",
    "lake_build": {"rc": 0, "seconds": 17.3, "completed_line": true},
    "env_diff": {"changed_type": [], "changed_value": [], "removed": [], "added": ["FiveGenBetti.Family.h_aux1"]},
    "records_challenge_eq_solution": {"FiveGenBetti.family_spanRank_eq": true},
    "leanchecker": {"FiveGenBetti.Family.Minimality": 0, "Solution": 0},
    "check_lean_sources": 0,
    "validate_formalization": 0
  },
  "declarations": [
    {
      "name": "FiveGenBetti.Family.H_degree_lt_D",
      "file": "FiveGenBetti/Family/Minimality.lean",
      "patch_id": 3,
      "mode": "body",
      "status": "proved | proved_modulo_sorry | still_sorry | build_error | rejected_frozen_change | rejected_forbidden | rejected_out_of_scope | not_found | duplicate | regressed",
      "astra_claimed": "PROVED | PARTIAL | GAVE_UP | null",
      "axioms": ["propext", "Classical.choice", "Quot.sound"],
      "error": {"kind": "Tactic.unsolvedGoals", "line": 55, "message_head": "…(≤300 chars)", "goal": "…(≤25 lines)"} ,
      "reject_reason": null
    }
  ],
  "records": [
    {"name": "FiveGenBetti.family_spanRank_eq", "axioms": ["propext", "sorryAx", "Classical.choice", "Quot.sound"],
     "clean": false, "blocking": ["FiveGenBetti.Family.relation_nonredundant"]}
  ],
  "handoffs": [{"name": "…", "axioms": [], "clean": true}],
  "sorry": {
    "hasSorry_before": 33, "hasSorry_after": 30,
    "hasSorry_before_excl_challenge": 31, "hasSorry_after_excl_challenge": 28,
    "text_sorry_before": 0, "text_sorry_after": 0
  },
  "diffstat": {"files": 1, "insertions": 42, "deletions": 9},
  "unparsed_blocks": 0,
  "informal": null,
  "timing_s": {"scratch": 4.1, "build": 34.0, "probe": 6.2, "leanchecker": 7.9, "total": 61.0}
}
```

- **`records[].blocking`** lists the minimal unproved declarations in the transitive dependency
  closure: constants with `sorryAx` whose own body has `hasSorry`. The probe computes it by
  walking `getUsedConstants` until it reaches constants that carry their own `sorry`. This is the
  most useful single field for deciding the next Astra prompt.
- **`overall`**:
  - `RECORDS_PROVED` iff every record in `comparator.json` is clean, `records_challenge_eq_solution`
    holds for all of them, and leanchecker passes on every touched module **and** on `Solution`.
  - `PROGRESS` iff at least one declaration is newly `proved` or `proved_modulo_sorry` and nothing
    `regressed`.
  - `REJECTED` iff every patch was rejected.
- **`informal`**, when present:
  `{"candidate": "<path>", "statement_echo": "…", "lemmas": n, "undefined_refs": [], "flags": [], "unverified_computation": [], "route": "…"}`.

`verdict.md` is the same information in at most 40 lines: one header line with `overall`, a table
of declaration and status, the axioms of the records, the sorry delta, the branch and SHA, and
"next" pointers to `feedback.md` and the diff command. This is the only file the orchestrator must
read.

---

## 4. Verification ladder, cost and observed output

The machine is this Mac with the Mathlib cache present. "Measured" means I ran it during this
assessment.

| # | step | command | cost | gate / reads |
|---|---|---|---|---|
| L0 | scratch tree with warm cache | `git worktree add -b astra/<job> <tree> <sha>`; `cp -c -R <repo>/.lake <tree>/` ; `lake build` | clone **0.06 s**; no-op build **3.2 s** (Betti), **2.1 s** (size-ramsey) measured | base must build |
| L1 | static: scope, forbidden constructs, imports, contract rules | python on added text | under 0.1 s (est.) | reject before building |
| L2 | elaborate touched modules | `lake build <Module>` (writes oleans), or `lake env lean --json <file>` for diagnostics | Minimality edit **12.3 s** (`--json`), **17.3 s** (`lake build`, error case) measured; Deletion 1.6 s | JSON `kind` / `pos` gives per-declaration errors and `hasSorry` |
| L3 | full build | `lake build` | downstream of Minimality about 17 s measured; a change to Defs/Shared would rebuild everything, about 1–3 min (CONTEXT §4) | must report rc 0 and `Build completed successfully` |
| L4 | env probe, diff vs baseline, Challenge≡Solution | `lake env lean --json EnvProbe.lean`, `… Probe_challenge.lean` | **2–4 s** warm, **29 s** cold measured | frozen definitions, types, removed constants |
| L5 | axioms (records, handoffs, touched) | from the probe (`collectAxioms`), plus the repo's own `lake env lean <Lib>/AxiomAudit.lean` as the recorded output | AxiomAudit **4.3 s** measured | ⊆ `permitted_axioms` of comparator.json |
| L6 | kernel replay | `lake env leanchecker <M>` for each touched module, plus `Solution` | **3.6 s** single module, **6.3 s** Solution, **15.4 s** for `Minimality Solution` in one call (measured); full 24-module sweep **11 min 46 s** | rc 0 required; it is the only guard against kernel bypass |
| L7 | repo checks | `python3 scripts/check-lean-sources.py`; `ruby scripts/validate-formalization.rb` | **0.02 s**, **0.23 s** measured | rc 0 |
| L8 | milestone only (not per reply) | `./scripts/verify-comparator.sh` (Linux CI), `lake env leanchecker --fresh Solution` (hours), leanexport + nanoda | hours, Linux | needed for FORMALLY_VERIFIED, not for "proved on branch" |

A typical reply that touches one file costs about 1–2 min of wall time end to end, and the
orchestrator spends zero tokens on it until it reads `verdict.md`.

**Note on the full-project leanchecker sweep (measured, Betti clone with the cheat present).** I
looped `lake env leanchecker <M>` over all 24 project modules: **11 min 46 s wall** in total.
Three modules failed:
- `FiveGenBetti.Family.Minimality`: the cheat, correctly.
- `FiveGenBetti`: the library root, which alone took about 11 min. It evidently replays much
  more than its own (empty) contents, and it also tripped on the cheat.
- `Targets.FiniteWidth`: its olean was presumably not built by the default targets, which is a
  harness artifact.

Several modules in one process work. `lake env leanchecker FiveGenBetti.Family.Minimality Solution`
took **15.4 s** and exited 1, catching the cheat. The recommendation:
- **Per reply:** one `leanchecker <touched modules…> Solution` call, about 15 s.
- **Never** pass the library root module per reply.
- **At milestones:** the all-module sweep (about 12 min) and `--fresh` (hours), as semigroup-betti
  did on 2026-10-07.

### Observed output shapes

- **Build warnings, replayed from cache** (`B_betti_build.log`, 33 instances):
  `warning: FiveGenBetti/Algebra.lean:32:6: declaration uses `sorry``. The line:column is the
  declaration name, not the `sorry`. Line prefixes are `⚠ [8964/8984] Replayed FiveGenBetti.Algebra`,
  `✖ [1209/1228] Building SizeRamsey.Deletion (1.1s)`, and `trace: .> LEAN_PATH=…` (very long,
  must be dropped). The run ends with `Some required targets logged failures:\n- SizeRamsey.Deletion\nerror: build failed`.
- **Axiom audit**: `'FiveGenBetti.family_spanRank_eq' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]`
  (other forms are `… does not depend on any axioms`, and lists that wrap onto several lines
  when long, as `logInfo` did in my probe). Parse it with a regex over the whole text that
  tolerates newlines inside the brackets, or better, take the probe's JSON.
- **Kernel replay failure**:
  `uncaught exception: while replaying declaration 'FiveGenBetti.Family.cheat': (kernel) declaration type mismatch …`, exit 1.
  Success prints nothing and exits 0.
- **Missing olean after a failed build**: `object file '…/Minimality.olean' of module FiveGenBetti.Family.Minimality does not exist`.

### Signature extraction: answer to "`#check` vs text diff"

Use neither as the judge. `#check` output is pretty-printed: it depends on notation and on `pp`
options, and it is lossy about instances. A text diff of everything before `:= by` is defeated by
a changed `variable`, `open`, `local notation`/instance, or `include` *above* the declaration, and
it raises false alarms on reformatting. The structural hash of `ConstantInfo.type` (and of `.value`
for definitions) from the probe is exact and cheap. Keep the text diff only as an advisory field
(`sig_text_changed`) and for the human-readable diff.

### Sorry counting

The authoritative count is the `kind:"hasSorry"` messages, one per declaration whose body still
uses `sorry`. Report it both with and without `Challenge.lean`, whose 5 (size-ramsey) or 2 (Betti)
`sorry`s are deliberate. The textual `sorry` scan (comments stripped) is secondary. The plan §4
says it: "textual absence does not establish a clean dependency closure". `formalization.yaml`
`status.sorry_count` (Betti main: 4) is *reported* against the measured count but not edited by
this tool; editing it is a step-3 metadata action.

---

## 5. Placement

- **The apply/verify engine (T1–T7, T9)** goes in **`~/.claude/skills/lean-ingest/`** (stdlib
  Python plus `EnvProbe.lean`), with a short SKILL.md. Reasons:
  1. It must serve both repos unchanged. A copy in `~/size-ramsey/scripts` would be duplicated
     into five-generator-betti and drift; the existing `scripts/` are byte-identical template
     copies, and that is already a drift hazard.
  2. Anything placed in the repo is part of the Palomar submission. A meta-programming Lean probe
     inside the repo would fail `check-lean-sources.py` (no `module` header) or, worse, contain
     exactly the constructs the forbidden scan rejects.
  3. It pairs naturally with the `astra` skill (transport) without bloating it. Keep astra.py a
     pure transport; this skill consumes its `reply.md`.
- **Per-repo `contract.json`** goes at the repo root of each Lean repo. It is plain data, harmless
  to Palomar, versioned with the frozen-interface decisions, and generated by the step-1 tooling.
- **Protocol glue (T8's routing and the step-3 claim-packet updates)** goes in **`~/aiseminar`**.
  For example, add `make ingest-record CLAIM= VERDICT=`, which copies `verdict.json` into the
  claim packet's `EVIDENCE.md`/`COMPUTATION.md` and files the transcript. The lab owns status
  semantics, `make promote` and transcripts, and the skill must not know about claim packets. Also
  fix `make lean-check` there: it should call the skill's `verify` instead of
  `rg '\b(sorry|admit|axiom)\b'`, which cannot pass on a Palomar-shaped repo because Challenge's
  `sorry`s are deliberate.

---

## 6. Open questions and risks

### How a buggy applier could produce a false "proved", and what prevents it

| failure | prevention |
|---|---|
| The applier patches the wrong declaration, or reports "applied" while the `sorry` remains | Status never comes from the applier. It comes from `hasSorry` messages and `collectAxioms` of the named constant in the rebuilt environment. A mis-applied patch yields `still_sorry` or `build_error`, never `proved`. |
| The patch weakens a statement (drops a hypothesis, changes `≤` to `<`, swaps a definition) | The probe's type and value hash diff against the baseline gives `rejected_frozen_change`, and Challenge≡Solution is checked for the records. |
| The meaning changes through context (`variable`, `local instance`, `notation`, `open … in`) | The same type-hash diff, because it compares elaborated types, not text. |
| A custom axiom, `native_decide` or `ofReduceBool` | The scan rejects it first; the axiom allowlist from `comparator.json` catches it second. |
| Kernel bypass (`debug.skipKernelTC`, meta `addDecl`) that `#print axioms` reports as clean | The scan, then **leanchecker per touched module**. This was demonstrated, and it is not caught by `leanchecker Solution`. |
| A stale olean is audited after a failed build | The gate requires build rc 0 plus the completion line. Lake also deletes the failed module's olean (observed). The probe runs in the same tree right after the build. |
| Edits to Solution.lean or AxiomAudit.lean (for example deleting a `#print`) | Frozen-file scope check. The list of names to audit comes from `comparator.json` and `contract.json`, not from the repo's AxiomAudit file. |
| A name is shadowed (a new `X` in another namespace; the original is renamed) | Fully qualified names, and `removed[]` in the env diff gives `rejected_frozen_change`. |
| The base already contains a cheat (from an earlier merge) | The baseline also runs leanchecker on touched modules, and milestones run the full sweep. |
| The tool itself is wrong | The red-team suite T9 must pass, and the final FORMALLY_VERIFIED step still runs the independent CI comparator and the `--fresh` and nanoda replays. The tool's "proved" means "proved on branch, pending milestone checks", and `verdict.md` says so. |

### Open questions

1. **Hash stability** of definition values across unrelated edits in the same file (for example,
   whether `match_` and `_proof_` auxiliaries are renumbered). Fixture (g) and a "helper inserted
   before a def" fixture must settle this. If it is unstable, compare frozen definitions by their
   source bytes (between the probe's ranges) instead. That is still exact, and it is what NOTES
   demands ("definitions frozen byte-for-byte").
2. **What `leanchecker <LibRoot>` actually replays.** It took about 11 min, compared with seconds
   for leaf modules. Until that is understood, exclude root and re-export modules from the
   per-reply set. Several modules per call is confirmed to work.
3. **Concurrency.** Two Astra replies for the same stream need separate worktrees and branches,
   which the job-specific branch gives for free. Merging both is a git question for the
   orchestrator.
4. **Ownership.** Should a stream-B reply ever be allowed to touch an A file? The plan says no.
   The tool rejects it, and the orchestrator can override with `--allow-cross-stream`, which is
   recorded in the verdict.
5. **Heavy proofs.** A proof that passes but is very slow (`decide` on large finite structures)
   could exceed CI's budget. Record the per-module build seconds and flag any module above 5 min.
6. **Linter noise.** A new proof may add warnings (long lines, unused variables). Report the
   count only; it does not affect the verdict.

### What is not automatable (the orchestrator's judgment)

- **Whether a `rejected_frozen_change` is a justified contract fix.** The plan allows interface
  change requests "with a concrete failing consumer example". This is a decision and a NOTES
  "contract deviations" entry.
- **Merging `astra/<job>` into the stream branch, and when to merge the streams into main.**
- **Whether an informal argument for W is a proof.** Its routing into the protocol, its
  rewriting into a full PROOF.md, and the choice of adversary framing all belong to the
  orchestrator. Beyond the lint, the tool says nothing about mathematical correctness.
- **Whether a Lean proof is a faithful formalization of the informal argument.** It does not
  have to be, since a statement of record is all that matters for Lean truth. But CORRESPONDENCE.md
  and NOTES status updates are written by Claude.
- **The decision to declare FORMALLY_VERIFIED.** That needs the milestone ladder (L8) and the
  lab protocol.

---

## 7. Deliberately left out

- **Driving Astra (submit and wait) inside this tool.** The astra skill already does it, and
  mixing transport with judging violates searcher ≠ verifier.
- **Generating the step-1 brief and sorry inventory.** That belongs to another assessor, except
  for the reply-format spec that T1 parses. That spec must be part of the step-1 interface, and
  the probe's `baseline.json` (names, ranges, stub shape, `blocking`) is the natural sorry
  inventory to hand to Astra.
- **Automatic merges, NOTES.md and formalization.yaml edits, and claim-packet promotion.** These
  are judgment and protocol actions (§6). The tool only emits the data they need.
- **Running the comparator locally.** It is Linux and bubblewrap only (`scripts/verify-comparator.sh`).
  The probe's Challenge≡Solution hash check is a cheap local proxy, not a substitute, and it is
  labelled as such.
- **The LSP or REPL (`lean --server`, Pantograph) for goal extraction.** `lake env lean --json`
  already returns goal states in the `unsolvedGoals` messages, which is enough for feedback, and
  it needs no new dependency.
- **Per-declaration builds (one build per patch).** They are k times slower. The fixpoint over
  JSON error positions gets the same attribution in 2–3 builds.
