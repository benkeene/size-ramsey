# size-ramsey

Lean 4 / Mathlib formalization of the connected size-Ramsey number
r̂_c(4K₂, C₄) = 17: every connected simple graph with at most 16 edges admits a red/blue edge
colouring with no red 4-edge matching and no blue 4-cycle, and an explicit 12-vertex, 17-edge
graph has no such colouring. The lower bound goes through a structural lemma: every connected
graph with at most 16 edges has a set of at most three vertices meeting every 4-cycle
(4·τ₄(G) ≤ |E(G)| in general, with equality through 16 edges only for C₄, W₅, K₃,₃ − e, K₂,₂,₂).

Status: informal proof VERIFIED by the aiseminar review protocol (2026-10-16; four Astra passes and an
independent reconstruction). Lean: the proof certificate is `Solution.lean` and its dependency
closure (the `SizeRamsey` library), which does not import `Challenge.lean`; `lake build Solution`
reports zero `sorry` warnings, and the six records in `Solution.lean` depend on
`[propext, Classical.choice, Quot.sound]` only. The default `lake build` also builds
`Challenge.lean`, whose six deliberate `sorry`s (the statements of record) give six warnings, so
the default build is not sorry-free. Proofs complete at `c8d54e2` (2026-10-17), kernel-replayed
locally (leanchecker, 25 modules); formal adversary pass 1 and reviewer pass 1 both
ACCEPT_WITH_FIXES (reviewer 0.98, 2026-10-17; fixes applied); independent statement
reconstruction done (`CORRESPONDENCE.md` §13). The reviewer recommends FORMALLY_VERIFIED for A,
B, C (via two declarations), D for the fixed host of CLAIM.md, and E; the endpoint-universal
reading of D is not formalized. Since 2026-10-17 (after `38bd345`) both halves of C are records:
the transversal half `SizeRamsey.connected_transversal_le_three` is the sixth record (`cc2aec2`);
the CI comparator passed with six records at `46bf2d0` (https://github.com/benkeene/size-ramsey/actions/runs/39034260971). Lab status (aiseminar claim_0004, 2026-10-17): FORMALLY_VERIFIED
with exactly that scope. CI comparator passed at `38bd345` (2026-10-17, GitHub Actions run
https://github.com/benkeene/size-ramsey/actions/runs/39005389761): statement and axiom check
passed, and con-ron, nanoda and the Lean default kernel accepted the solution; `leanchecker
--fresh` remains not run (optional). Informal argument in `docs/PROOF.md`; plan in `docs/astra/`;
audit record in `CORRESPONDENCE.md` §10. Theorem A is a corollary of Alon–Mubayi–Thomas (2001); the
proposed new content is the equality classification B and, through it, the value 17 (novelty of B
unestablished; no novelty claim is made).
Template: `~/semigroup-betti` (Palomar entry PALOMAR-2026-10-07-000005).

## Layout
- `Challenge.lean` — the six statements of record (Mathlib-only imports, deliberate `sorry`s).
- `Solution.lean` — the same statements proved: the numerical equality from C and D, the other five
  by thin calls into `SizeRamsey.Proof.*` (proved, no `sorry`).
- `SizeRamsey/` — development library in dependency order (Defs, Basic, SmallGraphs, Deletion,
  Components, Reductions, Universal, FiniteChecks, Equality, Coloring, Upper, Main); `NOTES.md`
  maps informal labels to declarations; `AxiomAudit.lean` prints the axioms of record.
- `docs/PROOF.md` — the labelled informal argument (VERIFIED by the lab protocol); `docs/STATUS_CHECK.md`;
  `docs/astra/` — the Astra workflow and scaffold reports; `docs/verification/` — the Astra review
  transcripts, Lean job briefs and replies, and paper reviews (indexed in its README); `CORRESPONDENCE.md`.

## Building and checking

```
lake exe cache get      # on a clean machine; locally .lake/packages is cloned from ~/semigroup-betti
lake build Solution      # the proof certificate: zero sorry warnings
lake build               # also builds Challenge.lean: six deliberate sorry warnings (statements of record)
python3 scripts/check-lean-sources.py
ruby scripts/validate-formalization.rb
lake env lean SizeRamsey/AxiomAudit.lean   # [propext, Classical.choice, Quot.sound] for all six records
./scripts/verify-comparator.sh          # Linux with bubblewrap only; passed in CI at 46bf2d0 (six records)
```

Pinned toolchain `leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`
(`c55e6e786f49471c72fbddbec5415808896aec1e`), the same as PALOMAR-2026-10-07-000005. Never commit `.lake`.

## Provenance (who wrote what)

Every commit has Ben Keene as git author. The `Co-Authored-By` trailer names the Claude Code
session that **committed** the work; commits whose content GPT-6 Astra wrote also carry
`Co-authored-by: GPT-6 Astra <noreply@openai.com>` and `Astra-Job`/`Astra-Thread` trailers (added by a
history rewrite on 2026-10-17, `CORRESPONDENCE.md` §14). The map below is
the record; `formalization.yaml` `automation.notes` states the same division of labour, and
`docs/verification/README.md` indexes the Astra transcripts, briefs and replies cited here.

| commits | content | written by | judged and committed by |
|---|---|---|---|
| `48c43d5`, `70ed534`, `4adfd40` (`docs/astra/`) | status check, scaffold plan, two-stream Lean plan | GPT-6 Astra (Codex jobs; thread and job ids in each file's first line) | Claude Fable 5.1 |
| `74fccbf`, `4aaea11` | Lean scaffold: frozen definitions, statements of record, admitted library chain | Claude Fable 5.1 | Claude Fable 5.1 |
| `5124945` … `39afd8f` | the informal proof `docs/PROOF.md` and its review fixes | structural argument found by GPT-6 Astra (independent prover); fixes written by Claude Fable 5.1 in response to the Astra adversary and reviewer transcripts | Claude Fable 5.1 |
| `5d7ba04` (`docs/tooling/`) | proof-loop design merged from three assessments | three Claude assessment subagents (A, B, C), merged by Claude Fable 5.1 | Claude Fable 5.1 |
| `lean/stream-A`: `85509ce` … `077b90f` (18 commits) | Basic, SmallGraphs, FiniteChecks, Deletion, Components, Reductions, Universal (Theorem A) | Claude Opus 5.5 coding agents in a worktree (two commits carry their trailer; the rest carry the orchestrator's) | Claude Fable 5.1 |
| `lean/stream-B`: `7f0134b` … `1a842fa` (13 commits) | Upper (Theorem D), ColoringBase, Coloring assembly, Equality/Common, Extension, DegreeFour | Claude Opus 5.5 coding agents in a worktree | Claude Fable 5.1 |
| `4765345`, `832bb41` | merges of the two streams | — | Claude Fable 5.1 |
| `c8d54e2` | Tightness, Equality/Mixed, Equality/Cubic, Equality/TwoRegular, body of `equality_classification`, `connected_transversal_le_three` | GPT-6 Astra (three concurrent Codex jobs, `docs/verification/lean-jobs/`), applied mechanically | Claude Fable 5.1 |
| `a3a3f04` … `56ca263` | records: CORRESPONDENCE.md, formalization.yaml, README, fixes from the formal adversary and reviewer passes | Claude Fable 5.1, responding to GPT-6 Astra transcripts (`docs/verification/transcripts/`) | Claude Fable 5.1 (one by Claude Opus 5.5) |
| `d1fe5ba` (`paper/`) | LaTeX writeup | Claude Fable 5.1, with two GPT-6 Astra reviews applied (`docs/verification/paper-reviews/`) | Claude Fable 5.1 |
| `cc2aec2` | sixth statement of record, provenance section, `docs/verification/` | Claude Fable 5.1 | Claude Fable 5.1 |

Agent agreement is never treated as evidence (`formalization.yaml` `automation.notes`); the
guarantee is the Lean kernel and the CI comparator. Decisions of scope, promotion and submission
are Ben Keene's.

## Submission
Palomar submissions go through https://submit.palomar-registry.org/ with the full 40-character commit SHA. This repository is
ready for submission from the registry's side: the CI comparator passed at `38bd345`
(2026-10-17, https://github.com/benkeene/size-ramsey/actions/runs/39005389761; con-ron, nanoda
and the Lean default kernel accepted the solution). Remaining before submitting, all the owner's
decisions: repository visibility (currently private; the registry must be able to clone), a
human read of `CORRESPONDENCE.md`, and the optional packaging items in `CORRESPONDENCE.md` §8 and
aiseminar claim_0004 `RESPONSE_CLAUDE.md` (`TODO(ben)`). `leanchecker --fresh` has not run
(optional; the registry's comparator performs independent replay). Formal adversary pass 1 and reviewer
pass 1 are done (ACCEPT_WITH_FIXES; fixes applied). The transversal half of Corollary C,
`SizeRamsey.connected_transversal_le_three`, was added as the sixth record on 2026-10-17
(`cc2aec2`); the CI comparator passed with six records at `46bf2d0` (`CORRESPONDENCE.md` §8, §10). See `status.scope` and `known_gaps` in `formalization.yaml`.
