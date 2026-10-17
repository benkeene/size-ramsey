/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Reductions

/-! Theorem A (Stream A): `4 · τ₄(G) ≤ |E(G)|` by strong induction on the edge count, and its
`Proof` wrapper consumed by `Solution`. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

theorem universal
    {V : Type u} [Fintype V] (G : SimpleGraph V) :
    4 * tau4 G ≤ edgeCount G := by
  sorry

end SizeRamsey.Plan

namespace SizeRamsey.Proof

theorem four_mul_tau4_le_edgeCount
    {V : Type*} [Fintype V] (G : SimpleGraph V) :
    4 * tau4 G ≤ edgeCount G := by
  exact Plan.universal G

end SizeRamsey.Proof
