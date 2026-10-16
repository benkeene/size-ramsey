# size-ramsey

Lean 4 / Mathlib formalization (in preparation) of the connected size-Ramsey number
r̂_c(4K₂, C₄) = 17: every connected simple graph with at most 16 edges admits a red/blue edge
colouring with no red 4-edge matching and no blue 4-cycle, and an explicit 12-vertex, 17-edge
graph has no such colouring. The lower bound goes through a structural lemma: every connected
graph with at most 16 edges has a set of at most three vertices meeting every 4-cycle
(4·τ₄(G) ≤ |E(G)| in general, with equality through 16 edges only for C₄, W₅, K₃,₃ − e, K₂,₂,₂).

Status: PROOF_ATTEMPT (2026-10-16). Informal argument in `docs/`; scaffolding plan in `docs/astra/`.
Template: `~/semigroup-betti` (Palomar entry PALOMAR-2026-10-07-000005).
