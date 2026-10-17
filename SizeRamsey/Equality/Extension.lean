/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.AInterface

/-! Symbolic `K₃,₃ − e` extension (Stream B): adding a degree-four vertex to `K₃,₃ − e` gives
`τ₄ ≤ 2`. Proved by the five symbolic neighbour-split cases, not by enumerating extensions. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem k33_extension_tau_le_two
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (z : V)
    (hiso : Nonempty (erase G {z} ≃g k33MinusEdge))
    (hdeg : G.degree z = 4) :
    tau4 G ≤ 2 := by
  sorry

end SizeRamsey.Plan
