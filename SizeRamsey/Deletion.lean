/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Basic

/-! Induced vertex deletion `erase G D` and edge deletion (Stream A): lifting transversals,
exact additive edge counts, residual degrees, and transport between `erase G {v}` and
`deleteIncidenceSet v`. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

section FiniteGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem tau4_erase_lift
    (D X : Finset V) (hX : X ⊆ D)
    (hHit : HitsDeleted G D X)
    (T : Finset {v : V // v ∉ D})
    (hT : c4Transversal (erase G D) T) :
    c4Transversal G (liftTransversal D X T) ∧
      (liftTransversal D X T).card ≤ T.card + X.card := by
  sorry

theorem tau4_delete_vertices_le
    (D X : Finset V) (hX : X ⊆ D)
    (hHit : HitsDeleted G D X) :
    tau4 G ≤ tau4 (erase G D) + X.card := by
  sorry

theorem transversal_iff_no_square_erase (D : Finset V) :
    c4Transversal G D ↔ ¬ HasC4 (erase G D) := by
  sorry

theorem erase_edgeCount (D : Finset V) :
    edgeCount (erase G D) + (∑ v ∈ D, G.degree v) =
      edgeCount G + edgeCount (G.induce (D : Set V)) := by
  sorry

theorem erase_singleton_counts (v : V) :
    edgeCount (erase G {v}) + G.degree v = edgeCount G ∧
    edgeCount (erase G {v}) =
      edgeCount (G.deleteIncidenceSet v) ∧
    tau4 (erase G {v}) =
      tau4 (G.deleteIncidenceSet v) := by
  sorry

theorem erase_degree
    (D : Finset V) (v : {x : V // x ∉ D}) :
    (erase G D).degree v +
      (G.neighborFinset v.val ∩ D).card = G.degree v.val := by
  sorry

theorem tau4_delete_non_square_edge
    {u v : V} (hadj : G.Adj u v)
    (h : ¬ EdgeOnSquare G u v) :
    tau4 (G.deleteEdges {s(u, v)}) = tau4 G ∧
    edgeCount (G.deleteEdges {s(u, v)}) + 1 = edgeCount G := by
  sorry

theorem tau4_delete_leaf_vertex
    (v : V) (hd : G.degree v ≤ 1) :
    tau4 (erase G {v}) = tau4 G := by
  sorry

end FiniteGraph

theorem erase_card
    {V : Type u} [Fintype V] (D : Finset V) :
    Fintype.card {x : V // x ∉ D} + D.card =
      Fintype.card V := by
  sorry

end SizeRamsey.Plan
