/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Basic

/-! Induced vertex deletion `erase G D` and edge deletion (Stream A): lifting transversals,
exact additive edge counts, residual degrees, and transport between `erase G {v}` and
`deleteIncidenceSet v`. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

/-! ### Square normalisation and transport -/

section Squares

variable {V : Type*} {W : Type*}

theorem isC4Map_iff_cyclic {G : SimpleGraph V} {f : Fin 4 → V} :
    IsC4Map G f ↔ Function.Injective f ∧ ∀ i, G.Adj (f i) (f (i + 1)) := by
  constructor
  · rintro ⟨hinj, h01, h12, h23, h30⟩
    refine ⟨hinj, fun i => ?_⟩
    fin_cases i
    exacts [h01, h12, h23, h30]
  · rintro ⟨hinj, h⟩
    exact ⟨hinj, h 0, h 1, h 2, h 3⟩

theorem IsC4Map.rotate {G : SimpleGraph V} {f : Fin 4 → V} (hf : IsC4Map G f) (k : Fin 4) :
    IsC4Map G (fun i => f (i + k)) := by
  rw [isC4Map_iff_cyclic] at hf ⊢
  refine ⟨hf.1.comp (add_left_injective k), fun i => ?_⟩
  have := hf.2 (i + k)
  rwa [add_right_comm] at this

theorem IsC4Map.reverse {G : SimpleGraph V} {f : Fin 4 → V} (hf : IsC4Map G f) (k : Fin 4) :
    IsC4Map G (fun i => f (k - i)) := by
  rw [isC4Map_iff_cyclic] at hf ⊢
  refine ⟨hf.1.comp (sub_right_injective), fun i => ?_⟩
  have := hf.2 (k - (i + 1))
  rw [show k - (i + 1) + 1 = k - i by rw [sub_add_eq_sub_sub, sub_add_cancel]] at this
  exact this.symm

theorem IsC4Map.edgeOnSquare {G : SimpleGraph V} {f : Fin 4 → V} (hf : IsC4Map G f)
    (i : Fin 4) : EdgeOnSquare G (f i) (f (i + 1)) ∧ EdgeOnSquare G (f (i + 1)) (f i) := by
  refine ⟨⟨_, IsC4Map.rotate hf i, by simp, by simp [add_comm]⟩,
    ⟨_, IsC4Map.reverse hf (i + 1), by simp, by simp⟩⟩

theorem IsC4Map.induce_val {G : SimpleGraph V} {s : Set V} {f : Fin 4 → s}
    (hf : IsC4Map (G.induce s) f) : IsC4Map G (fun i => (f i : V)) := by
  obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
  exact ⟨Subtype.val_injective.comp hinj, h01, h12, h23, h30⟩

theorem IsC4Map.induce_mk {G : SimpleGraph V} {s : Set V} {f : Fin 4 → V}
    (hf : IsC4Map G f) (h : ∀ i, f i ∈ s) : IsC4Map (G.induce s) (fun i => ⟨f i, h i⟩) := by
  obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
  exact ⟨fun i j hij => hinj (congrArg Subtype.val hij), h01, h12, h23, h30⟩

theorem IsC4Map.erase_val {G : SimpleGraph V} {D : Finset V} {f : Fin 4 → {v : V // v ∉ D}}
    (hf : IsC4Map (erase G D) f) : IsC4Map G (fun i => (f i : V)) :=
  IsC4Map.induce_val (s := {v | v ∉ D}) hf

theorem IsC4Map.erase_mk {G : SimpleGraph V} {D : Finset V} {f : Fin 4 → V}
    (hf : IsC4Map G f) (h : ∀ i, f i ∉ D) :
    IsC4Map (erase G D) (fun i => (⟨f i, h i⟩ : {v : V // v ∉ D})) :=
  IsC4Map.induce_mk (s := {v | v ∉ D}) hf h

/-- If `g` sends squares of `G` to squares of `H` injectively, `τ₄(G) ≤ τ₄(H)`. -/
theorem tau4_le_of_restrict [Fintype V] [Fintype W] {G : SimpleGraph V} {H : SimpleGraph W}
    (g : V → W) (hg : Function.Injective g)
    (hsq : ∀ f, IsC4Map G f → IsC4Map H (g ∘ f)) : tau4 G ≤ tau4 H := by
  obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 H
  have hS : c4Transversal G (Finset.univ.filter (fun v => g v ∈ T)) := by
    intro f hf
    obtain ⟨i, hi⟩ := hT _ (hsq f hf)
    exact ⟨i, by simpa using hi⟩
  refine (tau4_le_card hS).trans (hcard ▸ ?_)
  exact Finset.card_le_card_of_injOn g (fun v hv => by simpa using hv) hg.injOn

/-- If every square of `G` is the `g`-image of a square of `H` (`g` injective),
`τ₄(G) ≤ τ₄(H)`. -/
theorem tau4_le_of_embed [Fintype V] [Fintype W] {G : SimpleGraph V} {H : SimpleGraph W}
    (g : W → V)
    (hsq : ∀ f, IsC4Map G f → ∃ f', IsC4Map H f' ∧ g ∘ f' = f) : tau4 G ≤ tau4 H := by
  obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 H
  have hS : c4Transversal G (T.image g) := by
    intro f hf
    obtain ⟨f', hf', rfl⟩ := hsq f hf
    obtain ⟨i, hi⟩ := hT _ hf'
    exact ⟨i, Finset.mem_image_of_mem g hi⟩
  exact (tau4_le_card hS).trans (hcard ▸ Finset.card_image_le)

theorem tau4_eq_of_same_squares [Fintype V] {G H : SimpleGraph V}
    (h : ∀ f, IsC4Map G f ↔ IsC4Map H f) : tau4 G = tau4 H :=
  le_antisymm (tau4_le_of_restrict id Function.injective_id fun f hf => (h f).mp hf)
    (tau4_le_of_restrict id Function.injective_id fun f hf => (h f).mpr hf)

/-- `τ₄(erase G D) = τ₄(H)` when the squares of `H` avoid `D` and `H` agrees with `G` off `D`. -/
theorem tau4_erase_eq_of [Fintype V] (G H : SimpleGraph V) (D : Finset V)
    (havoid : ∀ f, IsC4Map H f → ∀ i, f i ∉ D)
    (hadj : ∀ a b, a ∉ D → b ∉ D → (H.Adj a b ↔ G.Adj a b)) :
    tau4 (erase G D) = tau4 H := by
  apply le_antisymm
  · refine tau4_le_of_restrict Subtype.val Subtype.val_injective fun f hf => ?_
    obtain ⟨hinj, h01, h12, h23, h30⟩ := IsC4Map.erase_val hf
    have := (f 0).2; have := (f 1).2; have := (f 2).2; have := (f 3).2
    refine ⟨hinj, ?_, ?_, ?_, ?_⟩ <;> simp only [Function.comp] <;> rw [hadj] <;> assumption
  · refine tau4_le_of_embed Subtype.val fun f hf => ?_
    have hD := havoid f hf
    obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
    refine ⟨fun i => ⟨f i, hD i⟩, IsC4Map.erase_mk ⟨hinj, ?_, ?_, ?_, ?_⟩ hD, rfl⟩ <;>
      rw [← hadj _ _ (hD _) (hD _)] <;> assumption

end Squares

section Counting

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem induce_degree_eq (s : Set V) (v : s) :
    (G.induce s).degree v = ((G.neighborFinset v.val).filter (· ∈ s)).card := by
  rw [← SimpleGraph.card_neighborFinset_eq_degree]
  rw [← Finset.card_map (Function.Embedding.subtype _)]
  congr 1
  ext w
  simp only [Finset.mem_map, SimpleGraph.mem_neighborFinset, Function.Embedding.coe_subtype,
    Finset.mem_filter, SimpleGraph.induce_adj]
  constructor
  · rintro ⟨a, ha, rfl⟩
    exact ⟨ha, a.2⟩
  · rintro ⟨ha, hs⟩
    exact ⟨⟨w, hs⟩, ha, rfl⟩

theorem sum_degrees_induce (s : Set V) :
    ∑ v ∈ Finset.univ.filter (· ∈ s), ((G.neighborFinset v).filter (· ∈ s)).card =
      2 * edgeCount (G.induce s) := by
  rw [edgeCount_eq_card, ← SimpleGraph.sum_degrees_eq_twice_card_edges]
  rw [Finset.sum_subtype (p := (· ∈ s)) _ (by simp)]
  exact Finset.sum_congr rfl fun v _ => (induce_degree_eq G s v).symm

theorem card_filter_neighborFinset (v : V) (p : V → Prop) [DecidablePred p] :
    ((G.neighborFinset v).filter p).card =
      ∑ w ∈ Finset.univ.filter p, if G.Adj v w then 1 else 0 := by
  rw [← Finset.card_filter]
  congr 1
  ext w
  simp [and_comm]

theorem cross_count (D : Finset V) :
    ∑ v ∈ Finset.univ.filter (· ∉ D), ((G.neighborFinset v).filter (· ∈ D)).card =
      ∑ v ∈ D, ((G.neighborFinset v).filter (· ∉ D)).card := by
  simp_rw [card_filter_neighborFinset]
  rw [Finset.sum_comm]
  have hD : Finset.univ.filter (· ∈ D) = D := by ext; simp
  rw [hD]
  refine Finset.sum_congr rfl fun w _ => Finset.sum_congr rfl fun v _ => ?_
  simp [G.adj_comm]

theorem erase_degree_eq (D : Finset V) (v : {x : V // x ∉ D}) :
    (erase G D).degree v = ((G.neighborFinset v.val).filter (· ∉ D)).card := by
  convert induce_degree_eq G {x | x ∉ D} v using 2
  · rfl
  · rfl
  · ext w; simp

theorem induce_finset_degree_eq (D : Finset V) (v : (D : Set V)) :
    (G.induce (D : Set V)).degree v = ((G.neighborFinset v.val).filter (· ∈ D)).card := by
  convert induce_degree_eq G (D : Set V) v using 2
  ext w; simp

end Counting

section FiniteGraph

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

theorem tau4_erase_lift
    (D X : Finset V) (hX : X ⊆ D)
    (hHit : HitsDeleted G D X)
    (T : Finset {v : V // v ∉ D})
    (hT : c4Transversal (erase G D) T) :
    c4Transversal G (liftTransversal D X T) ∧
      (liftTransversal D X T).card ≤ T.card + X.card := by
  clear hX
  refine ⟨fun f hf => ?_, ?_⟩
  · by_cases hD : ∃ i, f i ∈ D
    · obtain ⟨i, hi⟩ := hHit f hf hD
      exact ⟨i, Finset.mem_union_right _ hi⟩
    · push Not at hD
      obtain ⟨i, hi⟩ := hT _ (IsC4Map.erase_mk hf hD)
      exact ⟨i, Finset.mem_union_left _ (Finset.mem_image_of_mem Subtype.val hi)⟩
  · unfold liftTransversal
    exact (Finset.card_union_le _ _).trans (Nat.add_le_add_right Finset.card_image_le _)

theorem tau4_delete_vertices_le
    (D X : Finset V) (hX : X ⊆ D)
    (hHit : HitsDeleted G D X) :
    tau4 G ≤ tau4 (erase G D) + X.card := by
  obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 (erase G D)
  obtain ⟨h1, h2⟩ := tau4_erase_lift G D X hX hHit T hT
  exact (tau4_le_card h1).trans (hcard ▸ h2)

theorem transversal_iff_no_square_erase (D : Finset V) :
    c4Transversal G D ↔ ¬ HasC4 (erase G D) := by
  constructor
  · rintro hS ⟨f, hf⟩
    obtain ⟨i, hi⟩ := hS _ (IsC4Map.erase_val hf)
    exact (f i).2 hi
  · intro h f hf
    by_contra hcon
    push Not at hcon
    exact h ⟨_, IsC4Map.erase_mk hf hcon⟩

theorem erase_edgeCount (D : Finset V) :
    edgeCount (erase G D) + (∑ v ∈ D, G.degree v) =
      edgeCount G + edgeCount (G.induce (D : Set V)) := by
  have hE : ∑ v ∈ Finset.univ.filter (· ∉ D), ((G.neighborFinset v).filter (· ∉ D)).card =
      2 * edgeCount (erase G D) := by
    rw [edgeCount_eq_card, ← SimpleGraph.sum_degrees_eq_twice_card_edges]
    rw [Finset.sum_subtype (p := (· ∉ D)) _ (by simp)]
    exact Finset.sum_congr rfl fun v _ => (erase_degree_eq G D v).symm
  have hI : ∑ v ∈ D, ((G.neighborFinset v).filter (· ∈ D)).card =
      2 * edgeCount (G.induce (D : Set V)) := by
    rw [edgeCount_eq_card, ← SimpleGraph.sum_degrees_eq_twice_card_edges]
    rw [Finset.sum_subtype (p := (· ∈ D)) _ (by simp)]
    exact Finset.sum_congr rfl fun v _ => (induce_finset_degree_eq G D v).symm
  have hG : ∑ v, G.degree v = 2 * edgeCount G := by
    rw [edgeCount_eq_card, SimpleGraph.sum_degrees_eq_twice_card_edges]
  have hsplit : ∀ v, G.degree v = ((G.neighborFinset v).filter (· ∈ D)).card +
      ((G.neighborFinset v).filter (· ∉ D)).card := fun v => by
    rw [← G.card_neighborFinset_eq_degree, Finset.card_filter_add_card_filter_not]
  have hD : Finset.univ.filter (· ∈ D) = D := by ext; simp
  have hU : ∑ v, G.degree v = ∑ v ∈ D, G.degree v +
      ∑ v ∈ Finset.univ.filter (· ∉ D), G.degree v := by
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (· ∈ D), hD]
  have hDs : ∑ v ∈ D, G.degree v = ∑ v ∈ D, ((G.neighborFinset v).filter (· ∈ D)).card +
      ∑ v ∈ D, ((G.neighborFinset v).filter (· ∉ D)).card := by
    rw [← Finset.sum_add_distrib]; exact Finset.sum_congr rfl fun v _ => hsplit v
  have hNs : ∑ v ∈ Finset.univ.filter (· ∉ D), G.degree v =
      ∑ v ∈ Finset.univ.filter (· ∉ D), ((G.neighborFinset v).filter (· ∈ D)).card +
      ∑ v ∈ Finset.univ.filter (· ∉ D), ((G.neighborFinset v).filter (· ∉ D)).card := by
    rw [← Finset.sum_add_distrib]; exact Finset.sum_congr rfl fun v _ => hsplit v
  have hC := cross_count G D
  omega

theorem erase_singleton_counts (v : V) :
    edgeCount (erase G {v}) + G.degree v = edgeCount G ∧
    edgeCount (erase G {v}) =
      edgeCount (G.deleteIncidenceSet v) ∧
    tau4 (erase G {v}) =
      tau4 (G.deleteIncidenceSet v) := by
  have h0 : edgeCount (G.induce ((({v} : Finset V)) : Set V)) = 0 := by
    rw [edgeCount_eq_card, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro e he
    induction e using Sym2.ind with
    | _ a b =>
      rw [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeSet] at he
      have ha := a.2; have hb := b.2
      simp only [Finset.coe_singleton, Set.mem_singleton_iff] at ha hb
      exact he.ne (Subtype.ext (ha.trans hb.symm))
  have h1 : edgeCount (erase G {v}) + G.degree v = edgeCount G := by
    have := erase_edgeCount G {v}
    rw [Finset.sum_singleton, h0] at this
    exact this
  have hle : G.degree v ≤ edgeCount G := by omega
  refine ⟨h1, ?_, ?_⟩
  · have h2 : edgeCount (G.deleteIncidenceSet v) = edgeCount G - G.degree v := by
      rw [edgeCount_eq_card, edgeCount_eq_card, SimpleGraph.card_edgeFinset_deleteIncidenceSet]
    omega
  · refine tau4_erase_eq_of G _ {v} (fun f hf i => ?_) (fun a b ha hb => ?_)
    · obtain ⟨_, h01, h12, h23, h30⟩ := hf
      rw [Finset.mem_singleton]
      fin_cases i
      · exact (SimpleGraph.deleteIncidenceSet_adj.mp h01).2.1
      · exact (SimpleGraph.deleteIncidenceSet_adj.mp h12).2.1
      · exact (SimpleGraph.deleteIncidenceSet_adj.mp h23).2.1
      · exact (SimpleGraph.deleteIncidenceSet_adj.mp h30).2.1
    · rw [Finset.mem_singleton] at ha hb
      rw [SimpleGraph.deleteIncidenceSet_adj]
      exact ⟨fun h => h.1, fun h => ⟨h, ha, hb⟩⟩

theorem erase_degree
    (D : Finset V) (v : {x : V // x ∉ D}) :
    (erase G D).degree v +
      (G.neighborFinset v.val ∩ D).card = G.degree v.val := by
  rw [erase_degree_eq, ← Finset.filter_mem_eq_inter, ← G.card_neighborFinset_eq_degree, add_comm]
  exact Finset.card_filter_add_card_filter_not _

theorem tau4_delete_non_square_edge
    {u v : V} (hadj : G.Adj u v)
    (h : ¬ EdgeOnSquare G u v) :
    tau4 (G.deleteEdges {s(u, v)}) = tau4 G ∧
    edgeCount (G.deleteEdges {s(u, v)}) + 1 = edgeCount G := by
  sorry

theorem tau4_delete_leaf_vertex
    (v : V) (hd : G.degree v ≤ 1) :
    tau4 (erase G {v}) = tau4 G := by
  sorry

end FiniteGraph

theorem erase_card
    {V : Type u} [Fintype V] (D : Finset V) :
    Fintype.card {x : V // x ∉ D} + D.card =
      Fintype.card V := by
  rw [Fintype.card_subtype_compl, Fintype.card_coe]
  have := Finset.card_le_univ D
  omega

end SizeRamsey.Plan
