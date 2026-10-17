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
  apply le_antisymm
  · choose T hT hcard using fun C : G.ConnectedComponent =>
      exists_transversal_card_eq_tau4 (compGraph G C)
    let S : Finset V := Finset.univ.biUnion fun C => (T C).map (Function.Embedding.subtype _)
    have hS : c4Transversal G S := by
      intro f hf
      set C := G.connectedComponentMk (f 0)
      have hmem : ∀ i, f i ∈ C.supp := by
        obtain ⟨_, h01, h12, h23, h30⟩ := hf
        have m0 : f 0 ∈ C.supp := rfl
        have m1 : f 1 ∈ C.supp := (C.mem_supp_congr_adj h01).mp m0
        have m2 : f 2 ∈ C.supp := (C.mem_supp_congr_adj h12).mp m1
        have m3 : f 3 ∈ C.supp := (C.mem_supp_congr_adj h23).mp m2
        intro i; fin_cases i
        exacts [m0, m1, m2, m3]
      obtain ⟨i, hi⟩ := hT C _ (IsC4Map.induce_mk hf hmem)
      refine ⟨i, Finset.mem_biUnion.mpr ⟨C, Finset.mem_univ _, ?_⟩⟩
      exact Finset.mem_map.mpr ⟨_, hi, rfl⟩
    refine (tau4_le_card hS).trans (Finset.card_biUnion_le.trans ?_)
    exact (Finset.sum_congr rfl fun C _ => by rw [Finset.card_map, hcard C]).le
  · obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 G
    have hC : ∀ C : G.ConnectedComponent, tau4 (compGraph G C) ≤
        (T.filter (fun v => G.connectedComponentMk v = C)).card := by
      intro C
      have hTC : c4Transversal (compGraph G C) (T.subtype (· ∈ C.supp)) := by
        intro f hf
        obtain ⟨i, hi⟩ := hT _ (IsC4Map.induce_val hf)
        exact ⟨i, Finset.mem_subtype.mpr hi⟩
      refine (tau4_le_card hTC).trans (le_of_eq ?_)
      rw [Finset.card_subtype]
      rfl
    rw [← hcard, Finset.card_eq_sum_card_fiberwise (f := G.connectedComponentMk)
      (t := Finset.univ) (fun _ _ => Finset.mem_coe.mpr (Finset.mem_univ _))]
    exact Finset.sum_le_sum fun C _ => hC C

theorem edgeCount_components :
    edgeCount G =
      ∑ C : G.ConnectedComponent, edgeCount (compGraph G C) := by
  have hC : ∀ C : G.ConnectedComponent, 2 * edgeCount (compGraph G C) =
      ∑ v ∈ Finset.univ.filter (fun v => G.connectedComponentMk v = C), G.degree v := by
    intro C
    rw [edgeCount_eq_card, ← SimpleGraph.sum_degrees_eq_twice_card_edges,
      Finset.sum_subtype (p := (· ∈ C.supp)) _ (fun v => by simp)]
    exact Finset.sum_congr rfl fun v _ =>
      SimpleGraph.degree_induce_of_neighborSet_subset fun w hw => (C.mem_supp_congr_adj hw).mp v.2
  have hG : 2 * edgeCount G = ∑ v, G.degree v := by
    rw [edgeCount_eq_card, SimpleGraph.sum_degrees_eq_twice_card_edges]
  have hsum : ∑ v, G.degree v = ∑ C : G.ConnectedComponent,
      ∑ v ∈ Finset.univ.filter (fun v => G.connectedComponentMk v = C), G.degree v :=
    (Finset.sum_fiberwise_of_maps_to (fun _ _ => Finset.mem_univ _) _).symm
  have : 2 * edgeCount G = 2 * ∑ C : G.ConnectedComponent, edgeCount (compGraph G C) := by
    rw [hG, hsum, Finset.mul_sum]
    exact Finset.sum_congr rfl fun C _ => (hC C).symm
  omega

omit [Fintype V] in
theorem compGraph_connected (C : G.ConnectedComponent) :
    (compGraph G C).Connected := by
  exact C.connected_toSimpleGraph

theorem compGraph_degree
    (C : G.ConnectedComponent) (v : C.supp) :
    (compGraph G C).degree v = G.degree v.val := by
  refine SimpleGraph.degree_induce_of_neighborSet_subset fun w hw => ?_
  exact (C.mem_supp_congr_adj hw).mp v.2

theorem component_edgeCount_le (C : G.ConnectedComponent) :
    edgeCount (compGraph G C) ≤ edgeCount G := by
  have h1 := sum_degrees_induce G C.supp
  have h2 : ∑ v ∈ Finset.univ.filter (· ∈ C.supp),
      ((G.neighborFinset v).filter (· ∈ C.supp)).card ≤ ∑ v, G.degree v := by
    refine (Finset.sum_le_sum fun v _ => ?_).trans
      (Finset.sum_le_sum_of_subset (Finset.filter_subset _ _))
    rw [← G.card_neighborFinset_eq_degree]
    exact Finset.card_filter_le _ _
  have h3 : ∑ v, G.degree v = 2 * edgeCount G := by
    rw [edgeCount_eq_card, SimpleGraph.sum_degrees_eq_twice_card_edges]
  unfold compGraph
  omega

theorem component_square_supported
    (hsq : SquareSupported G) (C : G.ConnectedComponent) :
    SquareSupported (compGraph G C) := by
  intro a b hab
  obtain ⟨f, hf, h0, h1⟩ := hsq (show G.Adj a.val b.val from hab)
  have hmem : ∀ i, f i ∈ C.supp := by
    obtain ⟨_, h01, h12, h23, h30⟩ := hf
    have m0 : f 0 ∈ C.supp := h0 ▸ a.2
    have m1 : f 1 ∈ C.supp := (C.mem_supp_congr_adj h01).mp m0
    have m2 : f 2 ∈ C.supp := (C.mem_supp_congr_adj h12).mp m1
    have m3 : f 3 ∈ C.supp := (C.mem_supp_congr_adj h23).mp m2
    intro i; fin_cases i
    exacts [m0, m1, m2, m3]
  exact ⟨_, IsC4Map.induce_mk hf hmem, Subtype.ext h0, Subtype.ext h1⟩

theorem connected_positive_degree
    (hc : G.Connected) (hp : 0 < edgeCount G) :
    ∀ v, 0 < G.degree v := by
  intro v
  rw [edgeCount_eq_card, Finset.card_pos] at hp
  obtain ⟨e, he⟩ := hp
  induction e using Sym2.ind with
  | _ a b =>
    rw [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeSet] at he
    by_cases hva : v = a
    · exact hva ▸ he.degree_pos_left
    · obtain ⟨p⟩ := hc.preconnected v a
      cases p with
      | nil => exact absurd rfl hva
      | cons h _ => exact h.degree_pos_left

theorem square_supported_no_bridge
    (h : SquareSupported G) {u v : V} (huv : G.Adj u v) :
    ¬ G.IsBridge s(u, v) := by
  rw [SimpleGraph.isBridge_iff, not_not]
  obtain ⟨f, ⟨hinj, -, h12, h23, h30⟩, rfl, rfl⟩ := h huv
  have hne : ∀ i j : Fin 4, i ≠ j → f i ≠ f j := fun i j hij => hinj.ne hij
  have hadj : ∀ i j : Fin 4, G.Adj (f i) (f j) → s(f i, f j) ≠ s(f 0, f 1) →
      (G.deleteEdges {s(f 0, f 1)}).Adj (f i) (f j) := fun i j ha hn =>
    SimpleGraph.deleteEdges_adj.mpr ⟨ha, by simpa using hn⟩
  have e30 : s(f 3, f 0) ≠ s(f 0, f 1) := by
    intro he; rcases Sym2.eq_iff.mp he with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact hne 3 0 (by decide) h1
    · exact hne 3 1 (by decide) h1
  have e23 : s(f 2, f 3) ≠ s(f 0, f 1) := by
    intro he; rcases Sym2.eq_iff.mp he with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact hne 2 0 (by decide) h1
    · exact hne 2 1 (by decide) h1
  have e12 : s(f 1, f 2) ≠ s(f 0, f 1) := by
    intro he; rcases Sym2.eq_iff.mp he with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact hne 1 0 (by decide) h1
    · exact hne 2 0 (by decide) h2
  exact ((hadj 3 0 h30 e30).symm.reachable.trans (hadj 2 3 h23 e23).symm.reachable).trans
    (hadj 1 2 h12 e12).symm.reachable

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
