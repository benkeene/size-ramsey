/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Universal

/-! Consequences of Theorem A under equality `4 · τ₄(G) = |E(G)|` (Stream A). Imports
`Universal`, never `Equality`. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

section FiniteGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem equality_square_supported
    (ht : 4 * tau4 G = edgeCount G) :
    SquareSupported G := by
  sorry

theorem equality_max_degree_le_four
    (ht : 4 * tau4 G = edgeCount G) :
    ∀ v, G.degree v ≤ 4 := by
  sorry

theorem equality_min_degree
    (hcon : G.Connected) (hm : 0 < edgeCount G)
    (ht : 4 * tau4 G = edgeCount G) :
    ∀ v, 2 ≤ G.degree v := by
  sorry

theorem equality_residual_components
    (D : Finset V) (c : ℕ)
    (ht : 4 * tau4 G = edgeCount G)
    (hlift : tau4 G ≤ tau4 (erase G D) + c)
    (hcount : edgeCount (erase G D) + 4 * c = edgeCount G) :
    tau4 G = tau4 (erase G D) + c ∧
    ∀ C : (erase G D).ConnectedComponent,
      4 * tau4 (compGraph (erase G D) C) =
        edgeCount (compGraph (erase G D) C) := by
  sorry

end FiniteGraph

end SizeRamsey.Plan
