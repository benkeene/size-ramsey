/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Components
public import SizeRamsey.SmallGraphs

/-! The five local reductions of Theorem A and the degree-class exhaustion (Stream A). Each
contract records the residual `erase G D` and the exact number of removed edges. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

section FiniteGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem square_supported_degree_ge_two
    (hs : SquareSupported G) (v : V)
    (hv : 0 < G.degree v) :
    2 ≤ G.degree v := by
  sorry

theorem degree_four_reduction
    (v : V) (hdeg : 4 ≤ G.degree v) :
    tau4 G ≤ tau4 (erase G {v}) + 1 ∧
    edgeCount (erase G {v}) + 4 ≤ edgeCount G := by
  sorry

theorem mixed_reduction
    {u v : V} (h : G.Adj u v)
    (hu : G.degree u = 2) (hv : G.degree v = 3) :
    tau4 G ≤ tau4 (erase G {u,v}) + 1 ∧
    edgeCount (erase G {u,v}) + 4 = edgeCount G := by
  sorry

theorem two_regular_square_supported
    (hcon : G.Connected) (hsq : SquareSupported G)
    (hdeg : ∀ v, G.degree v = 2) :
    Nonempty (G ≃g SimpleGraph.cycleGraph 4) := by
  sorry

theorem cubic_chordless_reduction
    (f : Fin 4 → V)
    (hdeg : ∀ i, G.degree (f i) = 3)
    (hf : IsC4Map G f)
    (hac : ¬ G.Adj (f 0) (f 2))
    (hbd : ¬ G.Adj (f 1) (f 3)) :
    tau4 G ≤ tau4 (erase G (Finset.univ.image f)) + 2 ∧
    edgeCount (erase G (Finset.univ.image f)) + 8 =
      edgeCount G := by
  sorry

theorem subcubic_chord_reduction
    (hdeg : ∀ v, G.degree v ≤ 3)
    (f : Fin 4 → V) (hf : IsC4Map G f)
    (hac : G.Adj (f 0) (f 2)) :
    tau4 G ≤ tau4 (erase G {f 0,f 1,f 2}) + 1 ∧
    edgeCount (erase G {f 0,f 1,f 2}) +
      G.degree (f 1) + 3 = edgeCount G ∧
    2 ≤ G.degree (f 1) := by
  sorry

theorem degree_two_three_cases
    (hcon : G.Connected)
    (hdeg : ∀ v, G.degree v = 2 ∨ G.degree v = 3) :
    (∀ v, G.degree v = 2) ∨
    (∀ v, G.degree v = 3) ∨
    ∃ u v, G.Adj u v ∧
      G.degree u = 2 ∧ G.degree v = 3 := by
  sorry

theorem square_component_reduction
    (C : G.ConnectedComponent)
    (hiso : Nonempty
      (compGraph G C ≃g SimpleGraph.cycleGraph 4)) :
    tau4 G = tau4 (erase G C.supp.toFinset) + 1 ∧
    edgeCount (erase G C.supp.toFinset) + 4 =
      edgeCount G := by
  sorry

end FiniteGraph

end SizeRamsey.Plan
