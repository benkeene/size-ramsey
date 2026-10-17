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
  intro a b hab
  by_contra hns
  obtain ⟨htau, hcount⟩ := tau4_delete_non_square_edge G hab hns
  have hbound := universal (G.deleteEdges {s(a, b)})
  omega

theorem equality_max_degree_le_four
    (ht : 4 * tau4 G = edgeCount G) :
    ∀ v, G.degree v ≤ 4 := by
  intro v
  have hdel : tau4 G ≤ tau4 (erase G {v}) + 1 := by
    have h := tau4_delete_vertices_le G {v} {v} subset_rfl (fun _ _ h => h)
    simpa using h
  have hcount := (erase_singleton_counts G v).1
  have hbound := universal (erase G {v})
  omega

theorem equality_min_degree
    (hcon : G.Connected) (hm : 0 < edgeCount G)
    (ht : 4 * tau4 G = edgeCount G) :
    ∀ v, 2 ≤ G.degree v := by
  intro v
  exact square_supported_degree_ge_two G (equality_square_supported G ht) v
    (connected_positive_degree G hcon hm v)

theorem equality_residual_components
    (D : Finset V) (c : ℕ)
    (ht : 4 * tau4 G = edgeCount G)
    (hlift : tau4 G ≤ tau4 (erase G D) + c)
    (hcount : edgeCount (erase G D) + 4 * c = edgeCount G) :
    tau4 G = tau4 (erase G D) + c ∧
    ∀ C : (erase G D).ConnectedComponent,
      4 * tau4 (compGraph (erase G D) C) =
        edgeCount (compGraph (erase G D) C) := by
  have hbound := universal (erase G D)
  have heq : tau4 G = tau4 (erase G D) + c := by omega
  have hres : 4 * tau4 (erase G D) = edgeCount (erase G D) := by omega
  refine ⟨heq, ?_⟩
  have hsum : (∑ C : (erase G D).ConnectedComponent,
      4 * tau4 (compGraph (erase G D) C)) =
      ∑ C : (erase G D).ConnectedComponent,
        edgeCount (compGraph (erase G D) C) := by
    rw [← Finset.mul_sum, ← tau4_components, ← edgeCount_components]
    exact hres
  exact fun C => (Finset.sum_eq_sum_iff_of_le
    (fun C _ => universal (compGraph (erase G D) C))).mp hsum C (Finset.mem_univ C)

end FiniteGraph

end SizeRamsey.Plan
