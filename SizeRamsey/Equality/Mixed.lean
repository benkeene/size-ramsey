/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Equality.Common

/-! Equality, mixed degree-2/3 case (Stream B): the graph is `K₃,₃ − e`. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem equality_mixed_degree_case
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (hc : G.Connected)
    (hp : 0 < edgeCount G)
    (hm : edgeCount G ≤ 16)
    (ht : Tight G)
    (ih : SmallerClassified G)
    (hmax : ∀ v, G.degree v ≤ 3)
    (hmix : ∃ u v,
      G.Adj u v ∧ G.degree u = 2 ∧ G.degree v = 3) :
    Nonempty (G ≃g k33MinusEdge) := by
  sorry

theorem mixed_reconstruction
    {V : Type u} (G : SimpleGraph V)
    (f : Fin 6 ≃ V)
    (hadj : ∀ i j,
      G.Adj (f i) (f j) ↔ k33MinusEdge.Adj i j) :
    Nonempty (G ≃g k33MinusEdge) := by
  let e : k33MinusEdge ≃g G := {
    toEquiv := f
    map_rel_iff' := by
      intro a b
      exact hadj a b
  }
  exact ⟨e.symm⟩

end SizeRamsey.Plan
