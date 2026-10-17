/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import Mathlib.Combinatorics.SimpleGraph.Finite
public import Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected
public import Mathlib.Combinatorics.SimpleGraph.CycleGraph
public import Mathlib.Order.Lattice.Nat
public import SizeRamsey

/-!
# The connected size-Ramsey number of a four-edge matching versus a quadrilateral

`r̂_c(4K₂, C₄)` is the least number of edges of a connected simple graph `F` such that every
red/blue colouring of the edges of `F` contains a red matching of four edges or a blue `C₄`.
Wang–Song–Zhang–Zhang (EJGTA 13 (2025) 163–170, Theorem 1.3) prove `r̂_c(nK₂, C₄) ≤ ⌊(9n−1)/2⌋`
and conjecture equality (Conjecture 1); the case `n = 4`, value `17`, is the target.

Statements of record (all with non-induced copies, graphs on `Fin n`):

* `SizeRamsey.four_mul_tau4_le_edgeCount` (Theorem A): `4 · τ₄(G) ≤ |E(G)|`.
* `SizeRamsey.equality_classification` (Theorem B): for connected `G` with `0 < |E(G)| ≤ 16`,
  equality holds iff `G` is `C₄`, `W₅`, `K₃,₃ − e` or the octahedron.
* `SizeRamsey.avoiding_coloring_le_sixteen` (Corollary C): every connected `F` with at most 16
  edges has `R ≤ F` with no red 4-matching and no blue `C₄`.
* `SizeRamsey.F17_spec` (Theorem D): the explicit 12-vertex, 17-edge graph is connected and
  arrows `(4K₂, C₄)`.
* `SizeRamsey.connectedSizeRamsey_eq_seventeen`: `r̂_c(4K₂, C₄) = 17`.

Status 2026-10-16: the informal structural argument (docs/PROOF.md) is verified by the aiseminar
review protocol (ordinary theorem, not formally verified); this file states the targets. Proofs are in `Solution.lean`.
-/

/-! ## Proofs (this module)

The five theorem statements of `Challenge.lean`, restated verbatim and proved. The definitions come
from `SizeRamsey.Defs` (identical text); this module does not import `Challenge`, and the
comparator checks that statements and definitions agree. Four theorems are thin calls into the
development library (`SizeRamsey.Proof.*`, sorry-free as of `a73d95a`); the fifth is proved from
C and D. -/

@[expose] public section

namespace SizeRamsey

/-- Theorem A: the universal quadrilateral-transversal bound. -/
theorem four_mul_tau4_le_edgeCount {n : ℕ} (G : SimpleGraph (Fin n)) :
    4 * tau4 G ≤ edgeCount G := by
  exact Proof.four_mul_tau4_le_edgeCount G

/-- Theorem B: all connected equality cases through sixteen edges. -/
theorem equality_classification {n : ℕ} (G : SimpleGraph (Fin n))
    (hconn : G.Connected) (hpos : 0 < edgeCount G) (hle : edgeCount G ≤ 16) :
    4 * tau4 G = edgeCount G ↔
      Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨ Nonempty (G ≃g wheel5) ∨
      Nonempty (G ≃g k33MinusEdge) ∨ Nonempty (G ≃g octahedron) := by
  exact Proof.equality_classification G hconn hpos hle

/-- Corollary C: an avoiding colouring for every small connected host. -/
theorem avoiding_coloring_le_sixteen {n : ℕ} (F : SimpleGraph (Fin n))
    (hconn : F.Connected) (hle : edgeCount F ≤ 16) :
    ∃ R : SimpleGraph (Fin n), R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  exact Proof.avoiding_coloring_le_sixteen F hconn hle

/-- Theorem D: the explicit seventeen-edge upper witness. -/
theorem F17_spec : F17.Connected ∧ edgeCount F17 = 17 ∧ ArrowsMatching4C4 F17 := by
  exact Proof.F17_spec

theorem connectedSizeRamsey_eq_seventeen : connectedSizeRamsey = 17 := by
  have hmem : 17 ∈ {m : ℕ | ∃ (n : ℕ) (F : SimpleGraph (Fin n)),
      F.Connected ∧ edgeCount F = m ∧ ArrowsMatching4C4 F} :=
    ⟨12, F17, F17_spec⟩
  apply le_antisymm (Nat.sInf_le hmem)
  apply le_csInf ⟨17, hmem⟩
  intro m hm
  rcases hm with ⟨n, F, hconn, hcount, harr⟩
  by_contra h
  have hm16 : m ≤ 16 := Nat.le_of_lt_succ (Nat.lt_of_not_ge h)
  obtain ⟨R, hRF, hR, hB⟩ := avoiding_coloring_le_sixteen F hconn (hcount ▸ hm16)
  exact (harr R hRF).elim hR hB

end SizeRamsey
