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
reports zero `sorry` warnings, and the five records in `Solution.lean` depend on
`[propext, Classical.choice, Quot.sound]` only. The default `lake build` also builds
`Challenge.lean`, whose five deliberate `sorry`s (the statements of record) give five warnings, so
the default build is not sorry-free. Proofs complete at `a73d95a` (2026-10-17), kernel-replayed
locally (leanchecker, 25 modules); formal adversary pass 1 and reviewer pass 1 both
ACCEPT_WITH_FIXES (reviewer 0.98, 2026-10-17; fixes applied); independent statement
reconstruction done (`CORRESPONDENCE.md` §13). The reviewer recommends FORMALLY_VERIFIED for A,
B, C (via two declarations), D for the fixed host of CLAIM.md, and E; the endpoint-universal
reading of D is not formalized. Lab status (aiseminar claim_0004, 2026-10-17): FORMALLY_VERIFIED
with exactly that scope. CI comparator passed at `a988d32` (2026-10-17, GitHub Actions run
https://github.com/benkeene/size-ramsey/actions/runs/39005389761): statement and axiom check
passed, and con-ron, nanoda and the Lean default kernel accepted the solution; `leanchecker
--fresh` remains not run (optional). Informal argument in `docs/PROOF.md`; plan in `docs/astra/`;
audit record in `CORRESPONDENCE.md` §10. Theorem A is a corollary of Alon–Mubayi–Thomas (2001); the
proposed new content is the equality classification B and, through it, the value 17 (novelty of B
unestablished; no novelty claim is made).
Template: `~/semigroup-betti` (Palomar entry PALOMAR-2026-10-07-000005).

## Layout
- `Challenge.lean` — the five statements of record (Mathlib-only imports, deliberate `sorry`s).
- `Solution.lean` — the same statements proved: the numerical equality from C and D, the other four
  by thin calls into `SizeRamsey.Proof.*` (proved, no `sorry`).
- `SizeRamsey/` — development library in dependency order (Defs, Basic, SmallGraphs, Deletion,
  Components, Reductions, Universal, FiniteChecks, Equality, Coloring, Upper, Main); `NOTES.md`
  maps informal labels to declarations; `AxiomAudit.lean` prints the axioms of record.
- `docs/PROOF.md` — the labelled informal argument (VERIFIED by the lab protocol); `docs/STATUS_CHECK.md`;
  `docs/astra/` — the Astra workflow and scaffold reports; `CORRESPONDENCE.md`.

## Building and checking

```
lake exe cache get      # on a clean machine; locally .lake/packages is cloned from ~/semigroup-betti
lake build Solution      # the proof certificate: zero sorry warnings
lake build               # also builds Challenge.lean: five deliberate sorry warnings (statements of record)
python3 scripts/check-lean-sources.py
ruby scripts/validate-formalization.rb
lake env lean SizeRamsey/AxiomAudit.lean   # [propext, Classical.choice, Quot.sound] for all five records
./scripts/verify-comparator.sh          # Linux with bubblewrap only; passed in CI at a988d32
```

Pinned toolchain `leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`
(`c55e6e786f49471c72fbddbec5415808896aec1e`), the same as PALOMAR-2026-10-07-000005. Never commit `.lake`.

## Submission
Palomar submissions go through https://submit.palomar-registry.org/ with the full 40-character commit SHA. This repository is
ready for submission from the registry's side: the CI comparator passed at `a988d32`
(2026-10-17, https://github.com/benkeene/size-ramsey/actions/runs/39005389761; con-ron, nanoda
and the Lean default kernel accepted the solution). Remaining before submitting, all the owner's
decisions: repository visibility (currently private; the registry must be able to clone), a
human read of `CORRESPONDENCE.md`, and the optional packaging items in `CORRESPONDENCE.md` §8 and
aiseminar claim_0004 `RESPONSE_CLAUDE.md` (`TODO(ben)`). `leanchecker --fresh` has not run
(optional; the registry's comparator performs independent replay). Formal adversary pass 1 and reviewer
pass 1 are done (ACCEPT_WITH_FIXES; fixes applied). The Corollary C record omits the separately
proved transversal conclusion `SizeRamsey.connected_transversal_le_three`; adding it as a sixth
record is optional packaging (`CORRESPONDENCE.md` §8, `TODO(ben)`). See `status.scope` and `known_gaps` in
`formalization.yaml` and `CORRESPONDENCE.md` §10.
