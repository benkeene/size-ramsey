/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import SizeRamsey.Reductions

/-! Theorem A: `4 · τ₄(G) ≤ |E(G)|` by strong induction on the edge count. -/

@[expose] public section

namespace SizeRamsey.Proof

theorem four_mul_tau4_le_edgeCount {V : Type*} [Fintype V] (G : SimpleGraph V) :
    4 * tau4 G ≤ edgeCount G := by
  sorry

end SizeRamsey.Proof
