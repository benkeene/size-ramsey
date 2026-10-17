# Assessment A: the step-1 interface (context curation and brief generation)

Assessor A, 2026-10-16. Lens: what Astra is handed in step 1, how much of it can be generated
mechanically, and what reply format makes step 2 mechanical. Steps 2–3 are covered only where the
brief has to anticipate them.

Files read: `CONTEXT.md`; `~/aiseminar/{MISSION,AGENTS}.md`; `~/aiseminar/agents/astra/prompts/{_common,adversary,independent_prover}.md`;
`~/aiseminar/agents/astra/invoke.py` (head); `~/aiseminar/agents/shared/claim_0005/{STATUS.yaml,REVIEW_ASTRA.md,requests/prover.md}`;
`~/.claude/skills/astra/SKILL.md` and `scripts/astra.py` (`read_body`, `build_prompt`, `new_job`, thread start);
`~/size-ramsey/{SizeRamsey/NOTES.md, CORRESPONDENCE.md, formalization.yaml, docs/astra/brief_lean_plan.md, docs/PROOF.md headings, SizeRamsey/Shared.lean}`;
plan `~/size-ramsey/docs/astra/2026-10-16_lean_plan.md` §A4 (l.1352–1404), §5, §6;
`~/size-ramsey-streamA/SizeRamsey/Deletion.lean` (uncommitted) plus its live diagnostics;
`~/five-generator-betti{,-streamB}/FiveGenBetti/NOTES.md`, `Family/{Minimality,Data,Lemmas}.lean`, `AxiomAudit.lean`,
`Challenge.lean`, `Targets/FiniteWidth.lean`, `docs/PROOF.md`, `docs/astra/2026-10-16_workflow_betti.md` (head),
the plan's §0, B5 (l.1753–1865) and §6; `scripts/check-lean-sources.py`; `~/semigroup-betti/README.md` (Verification).

Probes I ran (read-only apart from Lean's own caches):
`lake env lean SizeRamsey/Deletion.lean` in `~/size-ramsey-streamA` (4 s; 2 errors, 4 sorry warnings) and
`lake env lean FiveGenBetti/Family/Minimality.lean` in `~/five-generator-betti-streamB` (8 s; 9 sorry warnings);
`git merge-tree --write-tree main lean/stream-B` in five-generator-betti (clean merge).

---

## 1. Summary of recommendations, ranked by value/effort

Six facts from the repos shape everything below:

- **F1. Per-file elaboration costs 4–8 s.** `lake env lean <file>` gives the authoritative sorry/error set,
  with goal text, for one file. That is much cheaper than `lake build`, and it works even when a downstream
  file is broken.
- **F2. The status docs are stale where it matters.** `~/five-generator-betti-streamB/FiveGenBetti/NOTES.md`
  still lists every B1–B4 declaration as `stub`, but the only Family sorries left are the 9 in
  `Minimality.lean`. The stream-B worktree also shows **22 Stream-A sorries** (Fiber, Bridge, Algebra,
  Graded/*, GradedGenerators) that are already proved on `main`. A brief built from NOTES.md or from a raw
  grep would mislead Astra badly. The ground truth has to come from the compiler, filtered by ownership.
- **F3. Astra's read root breaks the toolchain path.** In both repos the stream worktrees have
  `.lake/packages` as a **symlink out of the read root** (`~/size-ramsey-streamA/.lake/packages ->
  /Users/ben/size-ramsey/.lake/packages`; the same holds for betti). The plans were produced with
  `cwd` = the main checkout, where the packages are real. Whether Astra's read-only sandbox follows that
  symlink is untested. If it does not, Astra cannot run `lake env lean --stdin` in a worktree, and its
  "elaborated, exit 0" claims disappear.
- **F4. Astra can elaborate but cannot persist.** It elaborated whole files via `lake env lean --stdin`
  (plan headers). So the brief can and should require it to elaborate its proposal before replying.
  Elaboration needs every import of the target to be built in the read root.
- **F5. The PROOF.md headings are keyed by module name.** Examples: `## Family.Minimality`, `## Deletion`,
  `## Components.tau4_components`. The plans' `###` sections name their declarations verbatim. So
  "relevant informal proof + plan sketch for file X" can be computed as line ranges. Nothing needs pasting.
- **F6. The NOTES.md table schemas differ.** Size-ramsey uses `| declaration | owner | file | status |`;
  betti uses `| declaration | file | owner | status |`, and its cells hold several backticked names. One
  parser must key on header names.

Ranked recommendations:

| # | Recommendation | Value | Effort |
|---|---|---|---|
| 1 | **Reply-format contract** (§3): body-only replacement blocks keyed by declaration id + signature hash, plus a JSON summary. Makes step 2 a script, not a reading task, and makes "signature changed" structurally impossible. | very high | 0.5 day (text + parser) |
| 2 | **`leaninv`, the inventory tool**: per-file `lake env lean` diagnostics joined with a lexical declaration splitter → JSON listing every target (FQN, file:line span, signature text, sig hash, has-sorry, error+goal text, owner, frozen). Filters by owner and stream, so F2 cannot happen. | very high | 1 day, ~300 lines of Python |
| 3 | **`astra-brief`, the brief generator**: inventory + repo config + mode (`lean-sorry`, `lean-repair`, `conjecture`) → `brief.md` (≤ ~200 inline lines, references by path and line range) + `brief.json` manifest (ids, hashes, base SHA, read root, allowed imports), plus the exact `astra.py submit` command line. | very high | 1–1.5 days, ~350 lines + 3 templates |
| 4 | **Read-root preflight** (`astra-brief --preflight`): check that the read root is a clean commit, that imports of the targets have `.olean`s, and that `.lake/packages` resolves inside the root (else **materialise** it or root Astra at the main checkout); optionally run a 1-minute `--effort low` probe job asking Astra to run `lake env lean --stdin` on a 3-line file. | high (prevents silent loss of elaboration, F3) | 0.5 day |
| 5 | **`frozen.lock`**: generated once at the bootstrap commit (`a979fb0` size-ramsey, `2869b0b` betti). It holds the full-text sha256 of every frozen definition and the signature hash of every planned theorem and statement of record. The brief quotes hashes from it; the applier and judge check against it. | high | 0.5 day (a mode of `leaninv`) |
| 6 | **Integration read root for split streams**: `astra-brief` refuses a stream worktree whose sibling stream has merged work the target depends on, unless `--allow-stale-contracts`. It suggests a scratch merge worktree instead (betti: `main` + `lean/stream-B` merges cleanly). | medium-high | 0.25 day |
| 7 | **Two new role prompts** in `~/aiseminar/agents/astra/prompts/`: `lean_prover.md` (prove the listed sorries, frozen signatures, reply contract) and `conjecture_prover.md` ("prove or refute", neutral framing, computations as runnable blocks). These are the `--system` files the generator passes. | medium-high | 0.25 day |
| 8 | **Goal extraction for repair rounds**: elaborate a stdin copy of the file with each inner `sorry` replaced by `(extract_goal; sorry)` and inline the goals. This only pays off for partial proofs and for repair rounds. | medium | 0.25 day |
| 9 | **"Nearby names" digest**: names (not bodies) of already proved helpers in the target file and its project imports, plus the plan section's "Verified APIs" list. Stops Astra duplicating helpers; it can grep Mathlib itself. | low-medium | 0.25 day |
| 10 | Chunking and concurrency policy encoded in the generator (§2.6): one job per owner file by default, at most 3 concurrent per repo, never two jobs on one file. | medium | encoded as defaults |

What I would build first: 1 + 2 + 3 + 4, about 3 days of Opus work. Everything else is optional polish.

---

## 2. Proposed tools

All tools are stdlib Python 3.11, need no repo-specific constants, and are configured per repo by an
optional `.astra-brief.toml`. Defaults are autodetected from the shared layout: the lib dir comes from
`lakefile.toml` `[[lean_lib]]` names minus `Challenge`/`Solution`; then `<Lib>/NOTES.md`,
`docs/PROOF.md`, the newest `docs/astra/*_lean_plan.md`, `Challenge.lean`, `Solution.lean`,
`<Lib>/AxiomAudit.lean`.

```toml
# .astra-brief.toml (optional; both repos need only 3–4 keys)
lib = "FiveGenBetti"
frozen_files = ["FiveGenBetti/Defs.lean", "FiveGenBetti/Interface.lean", "FiveGenBetti/Certificate/Defs.lean"]
records = ["Challenge.lean"]               # statements of record
out_of_scope = ["Targets/"]                # conjecture targets: only mode=conjecture may select them
bootstrap = "2869b0b"                      # frozen.lock baseline
```

### 2.1 `leaninv`: declaration and sorry inventory

- **Purpose.** Answer "what exactly is left, where, with what signature, and what does Lean say about
  it right now", by compiler, not by docs.
- **Inputs.** `--root DIR` (worktree), optional `--files GLOB…`, `--owner A|B`, `--elaborate`
  (default on), `--base REF`, `--lock frozen.lock`.
- **Outputs.** `inventory.json`: a list of `{id, fqn, kind, file, line_start, line_end, sig_text,
  sig_hash, body_text, has_sorry, diagnostics:[{severity,line,col,msg}], goals:[…], owner, frozen,
  proof_section:{path,lines}, plan_section:{path,lines}}`. Also a `files` map with
  `{imports, elab_ok, elab_seconds, sorry_warnings, errors}` and a `summary` with counts per
  owner/file. `--table` prints a 1-line-per-target text table (what the orchestrator reads).
- **CLI.**
  `leaninv --root ~/five-generator-betti-streamB --owner B --table`
  `leaninv --root ~/size-ramsey-streamA --files SizeRamsey/Deletion.lean --json > inv.json`
  `leaninv --root ~/size-ramsey --lock-out frozen.lock --at a979fb0` (lock mode).
- **Implementation sketch** (~300 lines).
  1. *Lexical splitter.* Read the file and track `namespace`/`section`/`end`, `variable`, and
     `open … in`/`omit … in` prefixes. A declaration starts at a top-level line matching
     `^(@\[[^\]]*\]\s*)*(private |protected |noncomputable )*(theorem|lemma|def|abbrev|instance|structure|inductive)\b`
     and ends before the next top-level start, `end`, `section`, `namespace`, top-level `/-`,
     `attribute`, `variable`, `omit`, `open`. Its signature is the text up to the first `:=` at
     bracket depth 0 that is not inside a string/comment. `sig_hash` = sha256 of the
     whitespace-normalised signature, truncated to 10 hex digits. The FQN is namespace + name. Both
     repos write all declarations unindented at top level (checked), so this holds. The splitter
     **refuses** (exit 3) files it cannot split cleanly; it never guesses.
  2. *Elaboration.* Run `lake env lean <file>` per file, in topological order, at most 4 at a time.
     Parse `file:line:col: (error|warning): msg` plus continuation lines. Map the `declaration uses
     'sorry'` warning position, which is the name token, to a declaration. Attach each error to the
     enclosing declaration, with the goal text that follows it (the `⊢` blocks, as in the Deletion
     output). A declaration counts as a target if its lexical body contains `sorry` **or** it has an
     error. `has_sorry` from the lexer must agree with the warnings; a disagreement is reported, not
     resolved.
  3. *Ownership.* Parse NOTES.md tables by header names (F6). Split cells on commas, strip backticks
     and parentheticals, and expand `Plan.`/namespace prefixes by suffix-match against FQNs. Ownership
     falls back to the plan §0 file-ownership table (file → owner). **Status columns are ignored**
     (F2).
  4. *Section mapping.* For each target file `X/Y.lean`, the proof section is the `##` heading of
     PROOF.md whose first token equals `Y` or `X.Y`, up to the next `##`. The plan section is the
     `###` section that contains the most occurrences of the file's target names. Both are emitted as
     line ranges.
  5. *Lock mode.* At `--at REF`, run `git worktree add` into a temp dir (or use `git show REF:path`
     for every file, which needs no build), then record for every declaration in frozen files and
     every declaration in `records` the full-text hash, and for every other theorem the signature
     hash.
- **Failure modes.** A file that does not split, which is refused. Cascading errors when an import
  fails to build, reported as `import_failed: Deletion` and not as N phantom errors. `lake` missing
  or toolchain mismatch: the tool aborts with the `lean-toolchain` content. Very long files: the time
  cap per file is 300 s.
- **Tests.** Golden snapshots at fixed SHAs:
  - five-generator-betti `6d054ec` + `--owner B` → exactly the 9 Minimality targets, with
    `sig_hash` `f9c2f5f06e … a7351065ef` (values in §4.1).
  - The same SHA without the owner filter → 31 lib sorries + 2 Challenge + 1 Targets.
  - size-ramsey `b17d1fa` → the per-file counts in CONTEXT §4a.
  - The current streamA `Deletion.lean` → 2 error targets with goals + 4 sorry targets.
  - Splitter round-trip: re-assembling the declarations reproduces each file byte for byte on all
    `.lean` files of all three repos.

### 2.2 `astra-brief`: brief generator

- **Purpose.** Turn an inventory selection into the step-1 interface. It writes `brief.md`, which is
  sent to Astra; `brief.json`, a manifest for the applier and judge; and `submit.sh`, the exact
  `astra.py submit …` line.
- **Inputs.** `--root`, `--mode lean-sorry|lean-repair|conjecture`, a target selection (`--file`,
  `--ids`, `--owner`, `--conjecture DECL`), `--round N`, `--prev-report apply_report.json` (repair
  rounds), `--role` (defaults to `lean_prover`/`conjecture_prover`), `--effort` (default xhigh), and
  `--extra PATH` (files outside the root that must be inlined, e.g. claim packets).
- **Outputs.** `<jobdir>/brief.md`, `<jobdir>/brief.json`, `<jobdir>/submit.sh`. The job dir is
  `<root>/.astra/briefs/<brief_id>/`, which must be git-ignored. `brief_id` =
  `<repo>-<stream>-<fileslug>-r<N>-<sha7>`.
- **CLI.**
  `astra-brief --root ~/five-generator-betti-streamB --mode lean-sorry --file FiveGenBetti/Family/Minimality.lean`
  `astra-brief --root ~/size-ramsey-streamA --mode lean-repair --file SizeRamsey/Deletion.lean --allow-dirty`
  `astra-brief --root ~/five-generator-betti --mode conjecture --conjecture FiveGenBetti.Targets.beta1_five_le_two_width_add_two --extra ~/aiseminar/agents/shared/claim_0006`
- **Implementation sketch** (~350 lines + 3 Markdown templates with `string.Template` slots).
  1. Run `leaninv` (in-process import) on the target file plus its import closure. The closure
     elaboration is skipped when `.olean`s are newer than their sources.
  2. Run the preflight (2.3). Abort on failure unless overridden.
  3. Fill the template. The inline part holds the rules, the target table, the current diagnostics
     and goals, the nearby-names digest, the reference list with line ranges, and the reply contract
     (§3, verbatim). The referenced part is everything else (§2.5).
  4. Write `brief.json` = `{brief_id, mode, repo, root, base_sha, dirty_files, targets:[{id, fqn,
     file, sig_hash, kind}], allowed_imports, frozen_lock_sha, forbidden_tokens, role, effort}`.
  5. Write `submit.sh`:
     `astra.py submit -p <repo> -t "<stream> <file> r<N>" --cwd <root> --system <role.md> --prompt-file brief.md [--file <extra>…] --effort xhigh --timeout 10800 --out <jobdir>/reply.md`.
     It is printed rather than executed, so the orchestrator stays in control. A `--submit` flag runs
     it and appends the job id to `brief.json`.
- **Failure modes.** Brief too large: more than 250 inline lines makes it split, or warn that the
  selection is too large (§2.6). Targets spanning files owned by different streams: refused. A target
  in `out_of_scope` outside `conjecture` mode: refused. A dirty root without `--allow-dirty`: refused,
  because Astra would read uncommitted text that the applier's base SHA does not describe (see the
  Deletion case, §4.2).
- **Tests.** Snapshot tests of `brief.md` for the two worked examples at fixed SHAs. Every path and
  line range cited in a generated brief must exist. `--dry-run` through `astra.py` must reproduce
  `brief.md` byte for byte in `prompt.md` after the header.

### 2.3 `astra-brief --preflight`: read-root check

Checks:

- **(a)** The root is a git worktree whose HEAD equals `base_sha`, with the target file(s) clean or
  explicitly allowed.
- **(b)** Every import of the targets has an up-to-date `.olean` under `<root>/.lake/build`.
- **(c)** `<root>/.lake/packages` is not a symlink leaving the root. If it is (F3), offer
  `--materialize`, which replaces the symlink by `cp -c` APFS clones (instant, no extra space), or
  `--trust-symlink` after a probe. Rooting Astra at the main checkout does not help: the stream
  worktree is then outside the root.
- **(d)** Optionally `--probe`: a `--effort low` Astra job, "run `lake env lean --stdin` on this
  4-line file and paste stdout/exit code". Its result is cached per root in
  `.astra/preflight.json`.

I recommend making (c) a hard failure until one probe has settled the question. Without
elaboration, Astra's Lean text is guesswork, and the 90-minute turn is wasted.

### 2.4 `astra-apply`: contract parser and applier (specified here because §3 is its input)

Kept deliberately dumb and separate from the judge (MISSION: searcher ≠ verifier).

- **Input.** `brief.json` and `reply.md`.
- **Output.** A branch `astra/<brief_id>` in a scratch worktree `~/<repo>-apply`, which is never the
  read root and never main. It holds one commit per target block. The tool also writes
  `apply_report.json`: per id `{applied|rejected, reason}`, plus `git diff --stat`.

Steps:

1. Parse the fenced blocks with regex on the info string. Reject the whole reply if the
   `astra-summary` JSON is missing or names another `brief_id`.
2. For each `body` block, find the declaration by FQN with the `leaninv` splitter, and require that
   the current `sig_hash` equals both the block's `sig` and `brief.json`.
3. Keep the file's signature bytes through `:=` and replace the rest of the declaration with the
   block content.
4. Insert `helper` blocks before their anchor and `import` blocks into the header. Reject any
   import not in `allowed_imports`.
5. Reject any block containing `sorry`, `admit`, `native_decide`, `axiom`, `unsafe`, `@[implemented_by`,
   `@[extern`, `set_option maxHeartbeats 0`, `set_option debug.skipKernelTC`, or `elab`/`macro`
   definitions.
6. Run `leaninv` on the touched files. The applier re-elaborates only to label the result, which is
   not a verdict; the judge reruns from scratch. Write the report.

It is ~250 lines.

### 2.5 What goes inline vs by reference (sizing policy, encoded in the templates)

Astra reads paths, so the brief inlines only what is (i) volatile, (ii) contractual, or
(iii) not in the read root:

| Inline (always) | Reference (path + line range) | Inline via `--file` only if outside the root |
|---|---|---|
| Mode, goal, and the "not told it is probably right" framing | `docs/PROOF.md` section for the file | aiseminar claim packet (CLAIM, EVIDENCE, COMPUTATION) |
| Rules: frozen defs/signatures, forbidden tokens, permitted axioms, ownership | Plan section(s) for the file and plan §5 pitfalls | Data manifests from `~/aiseminar/experiments/...` |
| Target table: id, FQN, file:line, sig_hash, one-line status (sorry / error) | The target file itself (Astra reads it whole) | |
| **Exact signatures of the targets** (short, and the hash is useless without the text) | Definitions the targets mention (file:line of each `def`) | |
| Current diagnostics + goal states (repair) or `extract_goal` output (partial) | NOTES.md (with an explicit "status column stale" warning when F2 applies) | |
| Names of proved helpers in file and imports (digest, ≤ 30 names) | CORRESPONDENCE.md §§2–3 (definition audit) | |
| Ground truth that contradicts the docs (F2) | Mathlib under `.lake/packages/mathlib` | |
| Reply contract (§3) verbatim | | |

Target size: **120–220 lines, ≤ 12 KB**. That is about 2–4 k orchestrator tokens to review once per
template; afterwards the orchestrator reads only `inventory --table` (one line per target). Do not
inline the plan sketch even though it is the most useful text: Astra reads it anyway, and inlined
copies go stale against the file.

### 2.6 Chunking and concurrency policy

**Unit = one owner file** (default). Lean elaboration, the applier, the build check and blame are all
per file. Ownership is per file by the plans' construction, and signatures are frozen, so **every
file can be proved against the stubs of its imports in parallel**, as long as its imports *build*
(sorries fine, errors not).

- **Merge** small files that share one PROOF.md section and one plan section, e.g. size-ramsey
  `Equality/{Common,Extension}` or `Universal` + `Tightness` (5 sorries). This applies when the total
  is ≤ 8 targets and ≤ 3 plan-days.
- **Split** a file when it has > 10 targets or > 4 plan-days. Split along the plan's internal order
  into groups that share a proof idea. For example, Minimality splits into arithmetic/ψ (6) and
  nonredundancy (3); size-ramsey `Components` (9) splits into counting (4) and support/attachment (5).
- **Per-declaration** jobs only in repair rounds (one failing declaration) or after two failed rounds
  on a hard lemma. Then the brief adds `extract_goal` output and Astra's previous attempt.
- **Per-stream** jobs never produce proof text. Use them only for strategy questions, e.g. "the plan's
  route for X fails because Y; propose a new contract".
- **Order** by the import DAG for *buildability*: a target whose imports fail to elaborate is
  deferred, not submitted (F4). For size-ramsey stream A this means Deletion must be green (or its
  uncommitted change shelved) before Components/Reductions/Universal/Tightness can be briefed. Stream
  B files import A only via `AInterface`, which builds at the bootstrap commit, so all B files can go
  at once from `~/size-ramsey-streamB`.

**Concurrency.** At most **3 Astra jobs per repo, 5 overall**, and never two jobs on one file or on
one read root that the applier will touch. Reasons:

1. Astra fans out to its own subagents (`_common.md` tells it to), so per-job breadth is already
   high.
2. The binding constraint is the orchestrator's verify loop. A `lake build` takes 1–3 min per
   worktree and is serial within one worktree, and each reply costs the orchestrator one
   `apply_report` + one judge table. Three replies arriving together is about the most it can absorb
   without reading raw text.
3. Read roots must stay frozen while jobs read them, so the applier works in `~/<repo>-apply`.

For the step-1 "one Astra agent per repository": treat it as one **campaign** per repo, made of
several file-jobs. A single 69-sorry turn cannot finish plan estimates of 6–23 agent-days in 90
minutes, and one failure would cost the whole round.

### 2.7 Conjecture mode (Betti W) in the same generator

The generator's only branch is the template plus the reply contract (§3.2).

- **Targets.** One statement, taken from `Targets/FiniteWidth.lean`, plus the informal statement from
  the claim packet.
- **Context, referenced.** PROOF.md `## Decomposition` (labelled *unverified working notes*), plus
  `docs/astra/2026-10-16_workflow_betti.md`: the periodicity reduction to m ≤ w² + w and the
  certificate/checker design.
- **Context, inlined via `--file`** because it lies outside the root. These are the W claim packet
  (it does not exist yet; claim_0005 is F only, so `make claim TITLE=...` first, status CONJECTURED)
  and the data summary "widths 4–20, all m, no β₁ > 2w+2" (claim_0005 history).
- **Framing.** "Prove or refute" (adversarial-neutral), never "prove". The brief must state the
  tested range exactly, w ≤ 20 against the claim's 40, so Astra knows widths 21–40 are untested.
- **Role.** `conjecture_prover.md`.

Lean is optional output here. It only becomes a target after an informal proof has passed the
protocol (AGENTS.md §9: formalize only stable results).

### 2.8 Role prompts (two files, ~30 lines each, in `~/aiseminar/agents/astra/prompts/`)

- `lean_prover.md`: you are proving frozen-signature Lean declarations; elaborate everything you
  propose with `lake env lean --stdin` in your sandbox and report the exact output; never change a
  signature, definition or import outside the allowance; if a target is false or unprovable as
  stated, say so with a counterexample or the exact missing lemma (that is a *contract change
  request*, the most valuable possible output); reply strictly in the contract.
- `conjecture_prover.md`: an adapted `independent_prover.md` that *may* read the repo's notes,
  prefers counterexamples small-first, separates "proved" / "reduced to a finite computation" /
  "heuristic", and writes every finite check as a runnable program.

---

## 3. The reply-format contract (exact text, appended verbatim to every brief)

### 3.1 Lean modes (`lean-sorry`, `lean-repair`)

````text
## REPLY FORMAT (machine-applied; deviations are discarded, not interpreted)

Your reply is parsed by a script. Prose outside the blocks below is read by a human only if the
script fails; put explanations inside `note` blocks.

1. For each target you solve, emit exactly one block:

   ```lean-patch id=<ID> decl=<FQN> sig=<SIG_HASH> kind=body
   <the complete text that follows `:=` in the declaration, starting with `by` or a term,
    indented exactly as it will appear in the file; no signature, no `theorem` line>
   ```

   The script keeps the file's existing signature byte-for-byte through `:=` and replaces
   everything after it with your text. `id`, `decl`, `sig` must be copied from the target table.
   You cannot change a signature; do not try. If a signature is wrong, use a `contract` block.

2. New auxiliary lemmas go in their own blocks, inserted immediately before the declaration
   named in `before=`; full text including the `theorem`/`lemma` line:

   ```lean-patch id=<ID>.h<k> kind=helper before=<FQN of a target or existing declaration>
   private theorem <fresh_name> ... := by
     ...
   ```

   Helpers must be `private theorem`/`private lemma` unless the brief allows otherwise; names
   must not exist anywhere in the project. No `def`, `instance`, `abbrev`, `structure`,
   `notation`, `macro`, `elab`, `attribute [... ] <existing decl>`, `set_option` other than
   `set_option maxHeartbeats N in` with N ≤ 1000000.

3. A needed import goes in its own block, one per line, only from the ALLOWED IMPORTS list:

   ```lean-patch kind=import
   public import Mathlib.Algebra.MvPolynomial.Degrees
   ```

4. Forbidden anywhere in your Lean text: `sorry`, `admit`, `native_decide`, `axiom`, `unsafe`,
   `implemented_by`, `extern`, `decide := true` config tricks, `debug.` options, edits to any
   frozen file, Challenge.lean, Solution.lean or files of the other stream.

5. A target you could not finish: give your best partial proof as `kind=draft` (it may contain
   `sorry`; it is never applied, only shown to the next round), and state what is missing:

   ```lean-patch id=<ID> decl=<FQN> sig=<SIG_HASH> kind=draft
   ...
   ```

6. If a target is FALSE or unprovable from its hypotheses, or a frozen contract must change,
   emit a contract block (this is never applied; it goes to a human):

   ```contract id=<ID> decl=<FQN>
   PROBLEM: <one sentence>
   EVIDENCE: <counterexample with explicit data, or the precise missing hypothesis>
   PROPOSED SIGNATURE: <full Lean text>
   CONSUMERS AFFECTED: <declarations that use it>
   ```

7. Free-text explanations: ```note id=<ID>``` blocks, at most 15 lines each.

8. End the reply with exactly one summary block. Report elaboration honestly: "elaborated" means
   you ran the whole modified file through `lake env lean --stdin` in your sandbox and it printed
   no error and no `declaration uses 'sorry'` warning for that id. If you could not run Lean, say
   `"elaborated": false`.

   ```astra-summary
   {"brief": "<BRIEF_ID>", "base": "<BASE_SHA>",
    "results": [{"id": "<ID>", "status": "COMPLETE|DRAFT|CONTRACT|SKIPPED",
                 "elaborated": true, "lean_output": "<last 3 lines of lake env lean output>"}],
    "helpers": ["<names>"], "imports": ["<modules>"],
    "subagents": <n>, "confidence": <0-1>}
   ```

Do not paraphrase this format, do not wrap blocks in other blocks, do not use triple backticks
inside a block.
````

Why this shape rather than the alternatives:

- **Unified diffs fail.** Astra's line numbers drift against a file it cannot write, a single bad
  hunk header kills the whole patch, and diffs can silently touch signatures.
- **Whole-file replacement is an all-or-nothing gamble.** The judge would have to compare every
  frozen byte, and one bad declaration discards eight good ones.
- **Body-only blocks give per-target granularity.** Each target is applied, built and blamed
  independently.
- **The signature guard is structural.** The script never takes signature text from Astra; the
  `sig` echo only proves Astra read the current version. The FQN key survives line shifts from other
  edits.
- **Helpers and imports are explicit.** They are the two legitimate ways a proof grows outside its
  body, and making them explicit lets the applier and judge police them.

### 3.2 Conjecture mode (`conjecture`)

````text
## REPLY FORMAT (parsed by a script, then judged by humans and the lab protocol)

Begin with:
STATEMENT: <the exact statement you address, verbatim from the brief>
OUTCOME: PROOF | REDUCTION_TO_FINITE_CHECK | COUNTEREXAMPLE | PARTIAL | NO_PROGRESS

Then labelled lemmas, each as:

### L<n>. <title>
STATEMENT: <precise, with all quantifiers and ranges>
DEPENDS: <labels, literature (author, title, theorem number, year), or "none">
COMPUTATION: none | C<k>
PROOF: <complete argument; no "clearly", no "it can be checked">

Every finite verification you rely on is a program block that runs with python3 (stdlib only)
or a single C file, with the exact expected output:

```computation id=C<k> lang=python expect_sha256=<optional>
...
```
EXPECTED OUTPUT: <literal text or a statement like "prints OK and exits 0">

For COUNTEREXAMPLE: give the generators n0<…<n4, the width, β₁ and how you computed it, as a
computation block. For PARTIAL / NO_PROGRESS: the exact lemma that would finish the proof, and the
smallest case where your approach fails.

Close with:
WEAKEST STEP: <label and one sentence>
VERDICT: PROOF | REDUCTION | COUNTEREXAMPLE | PARTIAL | NO_PROGRESS
CONFIDENCE: <0-1>
SUBAGENTS: <n and what for>
````

The Claude-side script splits this into the claim packet's PROOF.md draft (lemmas) and
COMPUTATION.md (computation blocks, which Claude runs under `experiments/` with a manifest). The
conjecture thereby enters the protocol at CONJECTURED → PROOF_ATTEMPT. The VERDICT line is a
routing hint only; it never promotes anything.

---

## 4. Worked examples

### 4.1 five-generator-betti, Minimality.lean (mode `lean-sorry`)

Generated skeleton. The ids, lines and hashes are real: `sig_hash` is sha256 of the
whitespace-normalised signature, computed on `~/five-generator-betti-streamB` at `6d054ec`.

**Preflight decision.**

- **Read root.** Use a scratch merge worktree `~/five-generator-betti-integ`, a clean merge of `main`
  (`d12682a`) and `lean/stream-B` (`6d054ec`), with `.lake/packages` materialised by APFS clone and
  `lake build` run. Do not use streamB itself: there the A handoffs that Minimality imports
  (`Graded/Projection.lean`) are still `sorry` and NOTES.md is stale, which is legitimate for
  contracts but confusing as context.
- **Fallback.** If the merge worktree is not wanted, use `~/five-generator-betti-streamB`. The brief
  then adds the sentence: "The 22 sorries in Algebra/Fiber/Bridge/Graded/GradedGenerators are Stream
  A's, already proved on main; use their statements as black boxes."
- **Chunking.** One job for all 9, since the 3 nonredundancy theorems depend on the other 6 as
  lemmas, and a joint job lets Astra reuse ψ computations. If round 1 returns DRAFT on the
  nonredundancy group, round 2 splits it out.

```markdown
[five-generator-betti] B5 Minimality r1 — brief five-generator-betti-integ-family-minimality-r1-<sha7>

Read root: this directory (read-only). Base commit <BASE_SHA>. Lean v4.35.0-rc3, Mathlib c55e6e78
under .lake/packages; every import of the target file is built, so you can elaborate with
`lake env lean --stdin < <modified copy>` (pipe a modified copy of the file; you cannot write files).

## Task
Replace each `sorry` in FiveGenBetti/Family/Minimality.lean (the file's 9 theorems) by a complete
proof. Signatures, definitions and other files are frozen (rules below). If a statement is false
or unprovable as stated, report it with a `contract` block and explicit data; that outcome is as
valuable as a proof.

## Ground truth (from the compiler at <BASE_SHA>, 2026-10-16)
- Remaining admissions in the whole library: exactly these 9. `FiveGenBetti/NOTES.md`'s status
  column is stale for Stream B (B1–B4 are proved); trust this list.
- `Family.spanRank_eq` (Family/Main.lean) is assembled from `relation_nonredundant`; do not edit it.

## Targets  (file FiveGenBetti/Family/Minimality.lean; section variables `(K) [Field K] (k q : ℕ)`)
| id | decl (FQN FiveGenBetti.Family.…) | line | sig |
|----|-----------------------------------|------|-----|
| M1 | psi_H                  | 21 | f9c2f5f06e |
| M2 | psi_N                  | 25 | 290dbe560b |
| M3 | psi_N_ne_zero          | 33 | 7b97fd3acb |
| M4 | H_degree_lt_D          | 51 | a50e9a1608 |
| M5 | H_boundary_collisions  | 57 | ef8ea08ce9 |
| M6 | H_degree_lt_D_add_m    | 68 | 0412b9f95c |
| M7 | H_nonredundant         | 38 | dcca670c47 |
| M8 | N_nonredundant         | 45 | e2f9d52f1b |
| M9 | relation_nonredundant  | 74 | a7351065ef |
(full signatures: <generator inlines the 9 signatures, 60 lines, exactly as in the file>)

Suggested order M4–M6 (pure ℕ arithmetic on relationDegree), M1–M3 (ψ), M7, M8, M9.

## Informal proof and plan (read these; they are the intended route, not established Lean)
- docs/PROOF.md lines 64–83, "## Family.Minimality" (H within H by ordinary-degree projection;
  N by weighted projection to degree D+r then ψ; H within the full list: weight projection,
  then `H_degree_lt_D_add_m` forces any N multiplier scalar, ψ kills it; q = k−1 collisions).
- docs/astra/2026-10-16_lean_plan.md lines 1753–1865 (B5: order of projections matters;
  ordinary-degree projection is NOT applicable to the full H∪N list; the collision table at
  q = k−1; verified API names) and lines 1953–1977 (§5 pitfalls).
- Definitions used: FiveGenBetti/Family/Data.lean — `relation` l.53, `relationDegree` l.63,
  `nOffset` l.66, `psi` l.112, `relExp`/`hExp`/`nExp`/`RelIndex` (same file); `HIndex`/`NIndex`
  FiveGenBetti/Family/Defs.lean; `mono`, `weight` FiveGenBetti/Interface.lean.
- Contracts you may use as black boxes (proved on main):
  `homogeneous_mem_span_range`, `weighted_component_eq_zero_of_small`
  (FiveGenBetti/Graded/Projection.lean).

## Already proved helpers nearby (names only; read the files for statements)
Family/Lemmas.lean: exp5_apply_*, <weight/mono helpers…>; Family/Relations.lean: h_weight,
n_weight, relation_weightedHomogeneous, relationDegree_pos, relation_mem_toricKer, relIndex_card;
Family/NormalForms.lean: normalOffset_lt, normalOffset_injective, … (generator emits ≤ 30 names)

## Rules
- Frozen byte-for-byte: Defs.lean, Interface.lean, Certificate/Defs.lean, Challenge.lean,
  Targets/. Theorem signatures everywhere are frozen; you supply bodies only.
- Only Minimality.lean may change. ALLOWED IMPORTS: any `Mathlib.*`; project modules
  FiveGenBetti.{Interface, Family.Defs, Family.Data, Family.Lemmas, Family.Relations,
  Family.NormalForms, Graded.Projection} (upstream of Minimality in the DAG; never
  Family.Generation/Apery/Main, AxiomAudit, Solution, Challenge).
- Permitted axioms: propext, Classical.choice, Quot.sound. No native_decide.
- `relation_nonredundant` must hold for every field K, including positive characteristic.
- Natural subtraction: `k-1`, `q+1+r-k` are ℕ; do not rewrite them as integers in signatures.

## REPLY FORMAT
<§3.1 verbatim, with BRIEF_ID and BASE_SHA substituted>
```

`submit.sh`:

```bash
~/.claude/skills/astra/scripts/astra.py submit -p five-generator-betti \
  -t "B5 Minimality r1" --cwd ~/five-generator-betti-integ \
  --system ~/aiseminar/agents/astra/prompts/lean_prover.md \
  --prompt-file ~/five-generator-betti-integ/.astra/briefs/<id>/brief.md \
  --effort xhigh --timeout 10800 --out ~/five-generator-betti-integ/.astra/briefs/<id>/reply.md
```

About 130 inline lines. Orchestrator cost per round: read `inventory --table` (9 lines) and
`apply_report.json` + the judge table. The 2000-line plan never enters Claude context.

### 4.2 size-ramsey, Deletion.lean (mode `lean-repair`, which also finishes the sorries)

**Preflight decision.**

- **Root state.** Read root `~/size-ramsey-streamA`. HEAD `17b3d0a` (A3) builds; `Deletion.lean` is
  **uncommitted and failing**. The generator refuses this without `--allow-dirty`. Recommended
  handling: commit the WIP to a throwaway branch `wip/A4-deletion` in the streamA worktree, or
  snapshot it with `git stash create`. Then `base_sha` describes exactly what Astra reads, and the
  applier can verify hashes. Deletion imports only `SizeRamsey.Basic`, which is built, so Astra can
  elaborate it.
- **Symlink.** `.lake/packages` points to `/Users/ben/size-ramsey/.lake/packages`, so the F3
  preflight applies.
- **Is Astra the right tool?** The two errors are coercion plumbing, not mathematics. The generator
  should flag "repair-only targets with ≤ 3 errors and no sorry" as candidates for a Claude Opus
  subagent instead (AGENTS.md: Claude does code). Here, though, the same file holds 4 genuine sorries
  from plan A4, so one Astra job doing both is efficient. Components, Reductions, Universal and
  Tightness are deferred until Deletion builds, since their imports fail.

```markdown
[size-ramsey] A4 Deletion r1 (repair + finish) — brief size-ramsey-streamA-deletion-r1-<sha7>

Read root: this directory (read-only), base <BASE_SHA> (= 17b3d0a + WIP commit of
SizeRamsey/Deletion.lean). Lean v4.35.0-rc3 / Mathlib c55e6e78; SizeRamsey.Basic is built, so
`lake env lean --stdin < <modified Deletion.lean>` works from this directory.

## Task
SizeRamsey/Deletion.lean fails to elaborate (2 errors) and has 4 admitted plan theorems.
Make the whole file elaborate with no error and no `sorry`. Frozen signatures; bodies only.

## Current Lean output (lake env lean SizeRamsey/Deletion.lean, 2026-10-16)
R1 erase_degree_eq (l.170), error at 171:77, unsolved goals after `convert … using 2`:
  ⊢ { v // v ∉ D } = ↑{x | x ∉ D}
  ⊢ erase G D = SimpleGraph.induce {x | x ∉ D} G
  ⊢ {x ∈ G.neighborFinset ↑v | x ∉ D} = {x ∈ G.neighborFinset ↑v | x ∈ {x | x ∉ D}}
R2 induce_finset_degree_eq (l.174), error at 175:88:
  ⊢ {x ∈ G.neighborFinset ↑v | x ∈ D} = {x ∈ G.neighborFinset ↑v | x ∈ ↑D}
(`erase` is `G.induce {v | v ∉ D}` by definition: SizeRamsey/Shared.lean l.23.)
Sorry warnings: 221 erase_edgeCount, 226 erase_singleton_counts,
241 tau4_delete_non_square_edge, 248 tau4_delete_leaf_vertex.
Note: `erase_degree` (l.234) is proved but depends on R1; `tau4_erase_lift`,
`tau4_delete_vertices_le`, `transversal_iff_no_square_erase`, `erase_card` are proved.

## Targets  (namespace SizeRamsey.Plan; section FiniteGraph has `{V} [Fintype V] (G)`)
| id | decl | line | sig | kind |
|----|------|------|-----|------|
| R1 | erase_degree_eq          | 170 | 55cd2ed6fc | error (local helper; signature still frozen for this round) |
| R2 | induce_finset_degree_eq  | 174 | e576ae2f70 | error (local helper) |
| S1 | erase_edgeCount          | 221 | 2dca431573 | sorry (plan A4, frozen) |
| S2 | erase_singleton_counts   | 226 | 7ff03df1aa | sorry (plan A4, frozen) |
| S3 | tau4_delete_non_square_edge | 241 | 22d800f40e | sorry (plan A4, frozen) |
| S4 | tau4_delete_leaf_vertex  | 248 | 7154a03bed | sorry (plan A4, frozen) |
(full signatures inlined by the generator, ~35 lines)

## Informal proof and plan
- docs/PROOF.md lines 36–49 "## Deletion (with lifting maps)".
- docs/astra/2026-10-16_lean_plan.md lines 1352–1404 (A4: additive identity
  m(G−D) + Σ_{v∈D} d(v) = m(G) + m(G[D]) by inside/outside/crossing partition; never use ℕ
  subtraction; singleton transport between `erase G {v}` and `deleteIncidenceSet v` by restricting
  squares, not by a graph isomorphism; EdgeOnSquare = consecutive edge, normalise by rotate/reverse)
  and lines 2140–2168 (§5 pitfalls: Fintype diamonds, classical decidability, `edgeCount_eq_card`).
- Verified Mathlib names are listed in that plan section; check any other name by grep in
  .lake/packages/mathlib or by elaboration.

## Already proved in this file (use them; do not duplicate)
isC4Map_iff_cyclic, IsC4Map.{rotate,reverse,edgeOnSquare,induce_val,induce_mk,erase_val,erase_mk},
tau4_le_of_restrict, tau4_le_of_embed, tau4_eq_of_same_squares, tau4_erase_eq_of,
induce_degree_eq, sum_degrees_induce, card_filter_neighborFinset, cross_count, tau4_erase_lift,
tau4_delete_vertices_le, transversal_iff_no_square_erase, erase_degree, erase_card.
Imported (SizeRamsey/Basic.lean): edgeCount_eq_card, tau4_le_card,
exists_transversal_card_eq_tau4, tau4_mono, tau4_iso, Plan.edgeCount_iso, …

## Rules
Frozen: Defs.lean, Shared.lean, AInterface.lean, Challenge.lean, every plan signature. Only
SizeRamsey/Deletion.lean may change. ALLOWED IMPORTS: Mathlib.*, SizeRamsey.{Defs,Shared,Basic}.
`attribute [local instance] Classical.propDecidable` is already active in this file. Permitted
axioms propext/Classical.choice/Quot.sound; no native_decide. Keep the unused-`[Fintype V]`
linter warnings on frozen signatures (NOTES.md "Remaining linter warnings").

## REPLY FORMAT
<§3.1 verbatim>
```

`submit.sh` is the same as in §4.1 with `-p size-ramsey -t "A4 Deletion r1" --cwd ~/size-ramsey-streamA`.

**Repair round r2** (generated automatically from `apply_report.json` when some blocks fail): the same
skeleton, restricted to the failing ids. It inlines Lean's new diagnostics for those declarations and
Astra's r1 text as a `previous attempt` block, and it states "r1's other blocks were applied; current
base <sha>". Rounds stop at 3 per target. After that the generator emits a per-stream strategy
question instead (§2.6).

---

## 5. Placement recommendation

**Put the generic tools in a new skill, `~/.claude/skills/lean-astra/`.** This covers `leaninv`,
`astra-brief` (+ templates), `astra-apply`, and the reply-contract parser, with a `SKILL.md` saying
when to use each and the §2.6 policy. Reasons:

1. Both repos need the tools *now* and unchanged. Code in `~/size-ramsey/scripts/` would be invoked
   from betti by an absolute path into another project's tree and versioned with the wrong project.
2. Both repos are Palomar submission targets. Their `scripts/` directory ships in the submission
   (`~/semigroup-betti`'s scripts are part of its verification ladder), and Astra campaign tooling
   does not belong in a formalization artifact.
3. The tools are a layer over the existing `astra` skill (they emit `astra.py submit` lines). A
   sibling skill keeps that dependency explicit and is extractable "as a skill later" by
   construction.

**Per repo**: a ≤ 10-line `.astra-brief.toml` (committed; harmless metadata), `frozen.lock`
(committed; it is also useful to the judge and CI), and `.astra/` added to `.gitignore` (briefs,
replies and reports are working files; the canonical copies of replies already live in
`~/.claude/astra/jobs/`).

**In `~/aiseminar`**: the two role prompts (§2.8), because role prompts are lab policy and live in
`agents/astra/prompts/`. Also the protocol glue for step 3: Makefile targets that file transcripts,
draft REVIEW_ASTRA/RESPONSE_CLAUDE sections and promote with evidence pointers, because they encode
AGENTS.md §3–4. Other assessors cover step 3. My only constraint on it is that it consume
`brief.json`/`apply_report.json`/judge JSON, not replies.

---

## 6. Open questions and risks

1. **Sandbox and symlinked `.lake/packages` (F3).** This is the largest unknown. The plans'
   elaboration happened from main checkouts with real package dirs. Settle it with one `--probe` job
   (§2.3) before the campaign. If symlinks are not followed, materialise with `cp -c` clones; the
   size is negligible on APFS.
2. **Does stdin elaboration of a `module` file behave like the file?** The plans claim yes (exit 0
   with `public import` headers). Two things are unverified: whether private helpers and `@[expose]`
   behave identically, and whether stdin elaboration of a file whose *own* `.olean` is stale is
   affected. The judge must always re-elaborate on disk; Astra's `elaborated: true` is a hint.
3. **Astra over-claiming elaboration.** Mitigated by `lean_output` in the summary, which is
   checkable against reality later, and by never routing on it.
4. **Moving read roots.** If the orchestrator commits to a read root during a 90-minute turn, Astra
   reads a mixture. Rule: the applier never writes to a read root with a live job (the generator
   records the job in `.astra/active.json`), and `sig` hashes catch the rest.
5. **Contract changes.** The plans forbid relocating or weakening signatures, but a frozen signature
   could be false (the betti scaffold plan already refuted one claim, indispensability). The
   `contract` block routes this to a human. The generator must never auto-apply one.
6. **Parallel helper-name collisions.** Two file-jobs may each invent `aux_card`. Requiring
   `private` helpers keeps them file-local under the module system. The applier also checks project-
   wide name freshness at apply time.
7. **Splitter fragility.** Unusual layouts (indented declarations inside `section … end` blocks,
   `mutual`, `where` clauses) need care. The splitter refuses rather than guesses, and the round-trip
   test (§2.1) runs on all three repos.
8. **Stale-doc contamination.** Even with ground truth inlined, Astra will read NOTES.md. Fix the
   streamB NOTES.md status column (5 minutes of Claude time) before any campaign, as well as relying
   on the warning.
9. **W framing.** "Prove the conjecture" invites motivated reasoning. The data only reach w = 20, and
   Astra's own workflow note (`2026-10-16_workflow_betti.md`) says the existing sweep does not
   certify maxima. The brief should ask for "prove or refute", including a request to try
   counterexamples at w ∈ [21, 40] with small m first.
10. **Effort and time.** Minimality is "4–7 days" in the plan. A 3-hour xhigh turn may return mostly
    drafts. That is acceptable: drafts with exact sticking points feed r2, and that loop is the
    design.

---

## 7. What I deliberately left out, and why

- **A Lean metaprogram inventory** (iterating the environment for `sorryAx`, `DeclarationRanges`,
  pretty-printed types). It is authoritative for *transitive* sorries and elaborated types, but it
  needs a green build of the whole import closure, which fails exactly when a file is broken (the
  Deletion case). It belongs in the judge (axiom audit and elaborated-type freeze check), not in the
  brief generator. Per-file `lake env lean` gives what the brief needs.
- **LSP or REPL-based goal extraction** (lean4 REPL, `lake serve`). It is heavier and not needed:
  compiler error output already contains goals, and `extract_goal` over stdin covers partial proofs.
- **Mathlib premise retrieval** (embedding search, `exact?` sweeps). Astra can grep and elaborate
  against the pinned Mathlib in its sandbox. A curated list adds orchestrator tokens and staleness
  for little gain beyond the plan's existing "verified APIs".
- **Pasting the plan, PROOF.md or target files inline.** They are in the read root. Inlining doubles
  prompt size and creates stale copies.
- **The judge, the axiom audit, comparator, claim-packet updates and adversary briefs** (steps 2–3).
  These are other assessors' lenses. I fixed only the interfaces they consume (`brief.json`,
  `apply_report.json`, the summary block) so the pipeline composes.
- **Auto-submission and auto-promotion.** The generator prints the submit line by default. Nothing
  in this layer ever changes STATUS.yaml. Both choices follow AGENTS.md ("Never promote silently";
  Astra's verdicts are inputs).
- **Diff-based or whole-file reply formats.** Rejected for the reasons in §3.1.
