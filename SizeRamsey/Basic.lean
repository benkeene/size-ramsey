/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import SizeRamsey.Defs

/-! Basic semantics of `tau4` and `edgeCount`: attainment, monotonicity, isomorphism invariance,
and the bridge from the classical `edgeCount` to a computable `edgeFinset.card`. -/

@[expose] public section

namespace SizeRamsey

theorem edgeCount_eq_card {V : Type*} [Fintype V] (G : SimpleGraph V) [Fintype G.edgeSet] :
    edgeCount G = G.edgeFinset.card := by
  unfold edgeCount
  congr 1
  ext e
  simp only [SimpleGraph.mem_edgeFinset]

instance {n : ℕ} (es : Finset (Fin n × Fin n)) : DecidableRel (graphOfEdges es).Adj := by
  unfold graphOfEdges
  infer_instance

instance : DecidableRel F17.Adj := by
  unfold F17
  infer_instance

theorem F17_edgeCount : edgeCount F17 = 17 := by
  rw [edgeCount_eq_card]
  decide

theorem tau4_le_card {V : Type*} [Fintype V] {G : SimpleGraph V} {S : Finset V}
    (hS : c4Transversal G S) : tau4 G ≤ S.card := by
  sorry

theorem exists_transversal_card_eq_tau4 {V : Type*} [Fintype V] (G : SimpleGraph V) :
    ∃ S : Finset V, c4Transversal G S ∧ S.card = tau4 G := by
  sorry

theorem tau4_mono {V : Type*} [Fintype V] {G H : SimpleGraph V} (h : G ≤ H) :
    tau4 G ≤ tau4 H := by
  sorry

theorem tau4_iso {V W : Type*} [Fintype V] [Fintype W] {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) : tau4 G = tau4 H := by
  sorry

end SizeRamsey
