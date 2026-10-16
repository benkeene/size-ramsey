# size-ramsey

Lean 4 / Mathlib formalization (in preparation) of the connected size-Ramsey number
r̂_c(4K₂, C₄) = 17: every connected simple graph with at most 16 edges admits a red/blue edge
colouring with no red 4-edge matching and no blue 4-cycle, and an explicit 12-vertex, 17-edge
graph has no such colouring. The lower bound goes through a structural lemma: every connected
graph with at most 16 edges has a set of at most three vertices meeting every 4-cycle
(4·τ₄(G) ≤ |E(G)| in general, with equality through 16 edges only for C₄, W₅, K₃,₃ − e, K₂,₂,₂).

Status: informal proof VERIFIED by the aiseminar review protocol (2026-10-16; four Astra passes and an
independent reconstruction); Lean development admitted. Informal argument in `docs/PROOF.md`;
scaffolding plan in `docs/astra/`. Theorem A is a corollary of Alon–Mubayi–Thomas (2001); the new
content is the equality classification B and the value 17.
Template: `~/semigroup-betti` (Palomar entry PALOMAR-2026-10-07-000005).

## Layout
- `Challenge.lean` — the five statements of record (Mathlib-only imports, deliberate `sorry`s).
- `Solution.lean` — the same statements proved: the numerical equality from C and D, the other four
  by thin calls into `SizeRamsey.Proof.*` (admitted).
- `SizeRamsey/` — development library in dependency order (Defs, Basic, SmallGraphs, Deletion,
  Components, Reductions, Universal, FiniteChecks, Equality, Coloring, Upper, Main); `NOTES.md`
  maps informal labels to declarations; `AxiomAudit.lean` prints the axioms of record.
- `docs/PROOF.md` — the labelled informal argument (PROOF_ATTEMPT); `docs/STATUS_CHECK.md`;
  `docs/astra/` — the Astra workflow and scaffold reports; `CORRESPONDENCE.md`.

## Building and checking

```
lake exe cache get      # on a clean machine; locally .lake/packages is cloned from ~/semigroup-betti
lake build
python3 scripts/check-lean-sources.py
ruby scripts/validate-formalization.rb
lake env lean SizeRamsey/AxiomAudit.lean   # expected to show sorryAx while the development is admitted
./scripts/verify-comparator.sh          # Linux with bubblewrap only; fails until the proofs are complete
```

Pinned toolchain `leanprover/lean4:v4.35.0-rc3`, Mathlib `v4.35.0-rc3`
(`c55e6e786f49471c72fbddbec5415808896aec1e`), the same as PALOMAR-2026-10-07-000005. Never commit `.lake`.

## Submission
Palomar submissions go through https://submit.palomar-registry.org/ with the full 40-character commit SHA. This repository is
not ready for submission: see `status.scope` in `formalization.yaml` and `CORRESPONDENCE.md` §10.
