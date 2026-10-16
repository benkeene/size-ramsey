/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import SizeRamsey.Universal
public import SizeRamsey.FiniteChecks

/-! Theorem B: tightness lemmas, then the degree-4, mixed degree-2/3, cubic and 2-regular cases.
Not to be implemented before the informal proof passes the review gate (docs/PROOF.md). -/

@[expose] public section

namespace SizeRamsey.Proof

theorem equality_classification {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected) (hpos : 0 < edgeCount G) (hle : edgeCount G ≤ 16) :
    4 * tau4 G = edgeCount G ↔
      Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨ Nonempty (G ≃g wheel5) ∨
      Nonempty (G ≃g k33MinusEdge) ∨ Nonempty (G ≃g octahedron) := by
  sorry

end SizeRamsey.Proof
