/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Deletion

/-! Connected components (Stream A): additivity of `tau4` and `edgeCount` over components
(isolated components included), component inheritance, bridges, and cut-edge counting. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

section FiniteGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem tau4_components :
    tau4 G =
      ∑ C : G.ConnectedComponent, tau4 (compGraph G C) := by
  sorry

theorem edgeCount_components :
    edgeCount G =
      ∑ C : G.ConnectedComponent, edgeCount (compGraph G C) := by
  sorry

omit [Fintype V] in
theorem compGraph_connected (C : G.ConnectedComponent) :
    (compGraph G C).Connected := by
  exact C.connected_toSimpleGraph

theorem compGraph_degree
    (C : G.ConnectedComponent) (v : C.supp) :
    (compGraph G C).degree v = G.degree v.val := by
  sorry

theorem component_edgeCount_le (C : G.ConnectedComponent) :
    edgeCount (compGraph G C) ≤ edgeCount G := by
  sorry

theorem component_square_supported
    (hsq : SquareSupported G) (C : G.ConnectedComponent) :
    SquareSupported (compGraph G C) := by
  sorry

theorem connected_positive_degree
    (hc : G.Connected) (hp : 0 < edgeCount G) :
    ∀ v, 0 < G.degree v := by
  sorry

theorem square_supported_no_bridge
    (h : SquareSupported G) {u v : V} (huv : G.Adj u v) :
    ¬ G.IsBridge s(u, v) := by
  sorry

theorem component_attachment_card_ge_two
    (hcon : G.Connected) (hsq : SquareSupported G)
    (D : Finset V) (hD : D.Nonempty)
    (hproper : D ≠ Finset.univ)
    (C : (erase G D).ConnectedComponent) :
    2 ≤ (attachmentEdges G D C).card := by
  sorry

theorem attachment_sum (D : Finset V) :
    (∑ C : (erase G D).ConnectedComponent,
      (attachmentEdges G D C).card) +
      2 * edgeCount (G.induce (D : Set V)) =
        ∑ v ∈ D, G.degree v := by
  sorry

end FiniteGraph

end SizeRamsey.Plan
