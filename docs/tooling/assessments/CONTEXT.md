# Curated context for the tooling assessment (2026-10-16, evening)

You are assessing what functional/scripting tooling should be built to support ONE workflow,
described in §3. Read this file fully, then read the files it points at. Do not modify any
repository. Write only your assessment file (path given in your prompt).

## 1. The laboratory and its protocol

`~/aiseminar` is an AI-assisted mathematics research lab. Read `~/aiseminar/MISSION.md` and
`~/aiseminar/AGENTS.md` in full (they are short). Key rules that constrain tooling:

- Roles: GPT-6 Astra (OpenAI, via Codex) does theory: proofs, adversarial reviews, independent
  reconstructions, novelty audits. Claude does code, repository state, verification, journal,
  packaging. Claude writes the final epistemic judgments; "Astra agreed" is never evidence.
- Astra is never told that a proposed argument is probably right. Role prompts live in
  `~/aiseminar/agents/astra/prompts/` (`_common.md`, `adversary.md`, `reviewer.md`,
  `independent_prover.md`, `novelty_checker.md`, `methodology_auditor.md`). Read them.
- Claim packets: `~/aiseminar/agents/shared/claim_NNNN/` with CLAIM.md CONTEXT.md EVIDENCE.md
  PROOF.md COMPUTATION.md REVIEW_ASTRA.md RESPONSE_CLAUDE.md STATUS.yaml. Status ladder:
  SPECULATIVE → EMPIRICAL → CONJECTURED → PROOF_ATTEMPT → UNDER_REVIEW → VERIFIED →
  FORMALLY_VERIFIED (or REFUTED). Promotion evidence per step is in AGENTS.md §3. Review
  protocol in §4: adversary → Claude responds → reviewer → independent reconstruction →
  certificate/Lean. If two consecutive rounds agree without substantive objection, force a
  third adversary round with a fresh framing.
- Lab CLI: `~/aiseminar/Makefile` targets `claim TITLE=...`, `promote CLAIM= TO= EVIDENCE=`,
  `journal SLUG=`, `manifest DIR=`, `lean-check DIR=`, `envreport`; implemented in
  `~/aiseminar/src/aimath/` (python, uv venv, pytest suite `make test`). Astra transcripts go to
  `~/aiseminar/agents/astra/transcripts/`. Existing wrapper: `~/aiseminar/agents/astra/invoke.py`
  (role prompt + claim packet files → Codex; saves transcript; never fabricates).
- Lean rule (AGENTS.md §9): formalize only stable results; record `lake build` and
  `rg -n '\b(sorry|admit|axiom)\b'` in the claim packet; four-way distinction informal theorem /
  formal statement / correspondence argument / Lean verification.
- Existing claim packets relevant here: `~/aiseminar/agents/shared/claim_0004` (size-Ramsey,
  status VERIFIED) and `claim_0005` (Betti family, status VERIFIED). Read their STATUS.yaml and
  REVIEW_ASTRA.md to see what a completed review round looks like.

## 2. How Astra is invoked (the only sanctioned interface)

Read `~/.claude/skills/astra/SKILL.md` in full and skim `~/.claude/skills/astra/scripts/astra.py`
(stdlib python; drives `codex app-server` over JSON-RPC). Facts you must design around:

- `astra.py ask|submit|wait|status|reply|cancel`. `submit` detaches; `wait <job>` blocks until a
  terminal state. Turns take 5–90 minutes. Several submits run concurrently.
- Astra runs in a READ-ONLY sandbox rooted at the project directory (`--cwd DIR`). It can read
  any file under that root, so prompts should reference paths rather than paste. It CANNOT write
  files. It CAN run commands in the sandbox (it elaborated Lean with `lake env lean --stdin` during
  planning: see the header of `~/size-ramsey/docs/astra/2026-10-16_lean_plan.md`), but nothing it
  does persists. Its output is a Markdown reply at `~/.claude/astra/jobs/<project>/<job>/reply.md`
  (also `prompt.md`, `commentary.md`, `events.jsonl`, `status.json`), optionally copied with `--out`.
- Options: `--project`, `--title`, `--prompt-file`, `--file` (inline verbatim), `--system FILE`,
  `--effort low|medium|high|xhigh`, `--model`, `--timeout`, `--dry-run`.
- Ask for structured output when acting mechanically: numbered findings,
  `VERDICT: ACCEPT|ACCEPT_WITH_FIXES|REJECT|INCONCLUSIVE`, `CONFIDENCE: 0-1`.
- Claude's rule: never poll in a foreground loop; a backgrounded `wait` is the watcher.

## 3. THE WORKFLOW THE TOOLING MUST SUPPORT

For each of the two repositories below, in a run driven by Claude Fable 5.1 (the orchestrating
model, hereafter "the orchestrator"):

1. Spawn one Astra agent per repository (two total). Astra is given (a) an interface produced
   by this tooling and (b) the repository's Lean development and informal theorem content so far
   as context. Astra's job: PROVE the theorem / results / conjecture in question. Concretely this
   means producing Lean proof text for the remaining admitted (`sorry`) declarations, and/or an
   informal proof of the still-open conjecture (Betti Theorem W), in a form the orchestrator can
   act on. Astra can see the whole repository directory read-only.
2. Astra's reply is interpreted by the orchestrator to evaluate whether the theorem is (now)
   correct / proved: e.g. apply the proposed Lean text, `lake build`, run the axiom audit,
   check that the statements of record are unchanged, judge informal arguments.
3. If proved, spawn two adversarial Astra agents (role `adversary`, fresh framing) and then
   follow the aiseminar protocol for a claimed result: claim packet updates, RESPONSE_CLAUDE.md,
   reviewer pass, independent reconstruction, STATUS.yaml promotion with evidence pointers,
   journal entry, transcripts filed. For Lean results the target status is FORMALLY_VERIFIED
   (sorry-free build, permitted axioms only, CORRESPONDENCE.md argument, comparator).

The question for you: what scripts, generators, checkers, templates or small programs would make
steps 1–3 reliable, repeatable and cheap in orchestrator tokens? "Interface" in step 1 means
whatever artifact(s) this tooling hands Astra: a generated brief, a sorry inventory, a frozen
contract list, a reply format specification, etc. You decide what it should be.

## 4. The two repositories (identical layout, both templated on ~/semigroup-betti)

Both are Lean 4 / Mathlib projects (toolchain `leanprover/lean4:v4.35.0-rc3`, Mathlib
`c55e6e786f49471c72fbddbec5415808896aec1e`, Lean module system: `module`, `public import`,
`@[expose] public section`). Layout: `Challenge.lean` (statements of record, deliberate sorries),
`Solution.lean` (same statements proved via thin calls into the development), development
library directory, `<Lib>/NOTES.md` (informal label → declaration map with per-declaration
status), `<Lib>/AxiomAudit.lean` (`#print axioms` of the records), `docs/PROOF.md` (reviewed
informal proof), `docs/astra/2026-10-16_lean_plan.md` (the executable two-stream Lean plan from
Astra: §0 ownership/DAG, §1 frozen interfaces, §2 stream A list, §3 stream B list, §4 integration,
§5 pitfalls, §6 milestones), `CORRESPONDENCE.md`, `formalization.yaml` (Palomar metadata v0.4,
`status.sorry_count`), `scripts/check-lean-sources.py`, `scripts/validate-formalization.rb`,
`scripts/verify-comparator.sh` (Linux only), `comparator.json`, `.github/workflows/ci.yml`.
`lake build` takes ~1–3 minutes locally with the Mathlib cache present. Never commit `.lake`.
Build warnings include `declaration uses 'sorry'` per admitted declaration (a cheap inventory).
Constraints on proofs: no `sorry`, no `native_decide`, only `propext`/`Quot.sound`/
`Classical.choice`; frozen definitions byte-for-byte; theorem signatures frozen (bodies only).

Each repo has two git worktrees for the plan's two streams:
`~/<repo>-streamA` (branch `lean/stream-A`) and `~/<repo>-streamB` (branch `lean/stream-B`).

### 4a. `~/size-ramsey` — r̂_c(4K₂, C₄) = 17
Five statements of record A–E (see `CORRESPONDENCE.md` §2 and `Challenge.lean`). Informal proof
VERIFIED by the lab (claim_0004). Lean: 69 `sorry` in main (bootstrap). Stream A has A1–A3
committed; A4 (`SizeRamsey/Deletion.lean`) is uncommitted and FAILS to build with two unsolved
coercion goals (lines ~171, ~175: `{v // v ∉ D} = ↑{x | x ∉ D}` and a Finset-vs-Set filter
mismatch). Stream B has not started. Remaining A files: Deletion (4 sorries), Components (9),
Reductions (8), Universal (1), Tightness (4). B files: Upper (5), ColoringBase (3), Coloring (2),
Equality.lean + Equality/{Common,Cubic,DegreeFour,Extension,Mixed,TwoRegular} (8). Plan effort:
A 6–11 agent-days, B 5.5–11.5 agent-days. Read `SizeRamsey/NOTES.md` and the plan's §6.

### 4b. `~/five-generator-betti` — Theorem F (β₁ = 4k+2 for the family) and conjecture W
Read `README.md`, `FiveGenBetti/NOTES.md`, `CORRESPONDENCE.md`. Stream A (generic algebra,
projection, I/𝔪I, cardinality lemma, fiber bridge) is COMPLETE and merged to main. Stream B
(`lean/stream-B`, not merged) has B1–B4 committed and building: generators/relations, normal
forms and offset bijection, staged reduction and J = I, Apéry. Remaining: B5 nonredundancy
(`FiveGenBetti/Family/Minimality.lean`, 9 sorries: psi_H, psi_N, psi_N_ne_zero, H_nonredundant,
N_nonredundant, H_degree_lt_D, H_boundary_collisions, H_degree_lt_D_add_m, relation_nonredundant),
then assembly, axiom audit, comparator. Theorem W (`Targets/FiniteWidth.lean`, β₁ ≤ 2w+2 for
minimally five-generated semigroups with 4 ≤ w ≤ 40) is a CONJECTURE, outside Solution's import
closure and outside version 1; its intended support is a certified computational sweep, but an
informal/structural proof from Astra would be a new mathematical result and must enter the
protocol at CONJECTURED → PROOF_ATTEMPT, not be treated like the Lean sorries.
`vendor/SemigroupBetti-aa266b8/` is the complete four-generator library (reference, read-only).

### 4c. The finished template `~/semigroup-betti`
A complete, sorry-free, Palomar-submitted repo of the same shape. Its `README.md` "Verification"
section lists the full check ladder (check-lean-sources, validate-formalization, comparator,
leanchecker, leanchecker --fresh, leanexport + nanoda). Use it as the definition of "done".

## 5. Constraints on the tooling itself

- Lives, by default, in the current codebase `~/size-ramsey` but must serve both repos
  unchanged (same layout). If you conclude it belongs in `~/aiseminar` (the lab) or as a
  `~/.claude/skills/<name>/` skill instead, say so and why. Generic enough → may be extracted
  as a skill later; design for that (stdlib python or shell, no repo-specific constants baked in).
- Orchestrator tokens (Claude) are the scarce resource; Astra turns are cheap but slow
  (5–90 min). Prefer tooling that compresses what the orchestrator must read: structured JSON
  verdicts, diffs, pass/fail tables, not raw transcripts.
- Searcher ≠ verifier: anything that applies Astra's Lean text must be separate from and
  simpler than anything that judges it. The judge is `lake build` + `#print axioms` +
  statement-of-record unchanged check, never Astra's own claim of success.
- Astra cannot write files. Any "apply" step is Claude-side and must be safe: work in a
  scratch worktree or on a branch, never on a dirty main; leave a reviewable diff.
- Do not design around pasting whole repos into prompts; Astra reads paths.
- Respect frozen interfaces: tooling should detect if a proposed patch changes a frozen
  definition or a statement of record and reject it.
- Everything must be runnable on this Mac (no Linux-only comparator in the critical path;
  the comparator runs in CI).
