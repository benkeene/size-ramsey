/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.AInterface

/-! Equality, two-regular case (Stream B): the graph is `C₄`. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem equality_two_regular_case
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (hc : G.Connected)
    (hp : 0 < edgeCount G)
    (ht : Tight G)
    (h2 : ∀ v, G.degree v = 2) :
    Nonempty (G ≃g SimpleGraph.cycleGraph 4) := by
  exact two_regular_square_supported G hc (equality_square_supported G ht) h2

end SizeRamsey.Plan
