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

/-! ### Local counting helpers -/

theorem degree_ge_card_of_subset (x : V) (s : Finset V) (hs : ∀ y ∈ s, G.Adj x y) :
    s.card ≤ G.degree x := by
  rw [← G.card_neighborFinset_eq_degree]
  exact Finset.card_le_card fun y hy => (G.mem_neighborFinset x y).mpr (hs y hy)

theorem two_le_degree_of_adj {x a b : V} (ha : G.Adj x a) (hb : G.Adj x b) (hab : a ≠ b) :
    2 ≤ G.degree x := by
  have := degree_ge_card_of_subset G x {a, b} (by simp [ha, hb])
  rwa [Finset.card_pair hab] at this

theorem three_le_degree_of_adj {x a b c : V} (ha : G.Adj x a) (hb : G.Adj x b)
    (hc : G.Adj x c) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    3 ≤ G.degree x := by
  have := degree_ge_card_of_subset G x {a, b, c} (by simp [ha, hb, hc])
  rwa [Finset.card_insert_of_notMem (by simp [hab, hac]), Finset.card_pair hbc] at this

theorem four_le_degree_of_adj {x a b c d : V} (ha : G.Adj x a) (hb : G.Adj x b)
    (hc : G.Adj x c) (hd : G.Adj x d) (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    4 ≤ G.degree x := by
  have := degree_ge_card_of_subset G x {a, b, c, d} (by simp [ha, hb, hc, hd])
  rwa [Finset.card_insert_of_notMem (by simp [hab, hac, had]),
    Finset.card_insert_of_notMem (by simp [hbc, hbd]), Finset.card_pair hcd] at this

theorem two_mul_edgeCount_induce (D : Finset V) :
    2 * edgeCount (G.induce (D : Set V)) =
      ∑ x ∈ D, ∑ y ∈ D, if G.Adj x y then 1 else 0 := by
  rw [edgeCount_eq_card, ← SimpleGraph.sum_degrees_eq_twice_card_edges]
  have hD : Finset.univ.filter (· ∈ D) = D := by ext; simp
  refine Eq.trans ?_ (Finset.sum_subtype (p := (· ∈ D)) (F := inferInstance) D (fun _ => Iff.rfl)
    (fun x => ∑ y ∈ D, if G.Adj x y then 1 else 0)).symm
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [induce_finset_degree_eq G D x, card_filter_neighborFinset, hD]

theorem sum_fin_four (c : Fin 4 → ℕ) : ∑ i, c i = c 0 + c 1 + c 2 + c 3 := by
  rw [Finset.sum_fin_eq_sum_range]; simp [Finset.sum_range_succ]

omit [Fintype V] in
theorem IsC4Map.adj_at {g : Fin 4 → V} (hg : IsC4Map G g) (k : Fin 4) :
    G.Adj (g k) (g (k + 1)) ∧ G.Adj (g (k + 1)) (g (k + 2)) ∧
      G.Adj (g (k + 2)) (g (k + 3)) ∧ G.Adj (g (k + 3)) (g k) := by
  have h := (isC4Map_iff_cyclic.mp hg).2
  refine ⟨h k, ?_, ?_, ?_⟩
  · have := h (k + 1); rwa [add_assoc, show (1 + 1 : Fin 4) = 2 from rfl] at this
  · have := h (k + 2); rwa [add_assoc, show (2 + 1 : Fin 4) = 3 from rfl] at this
  · have := h (k + 3); rwa [add_assoc, show (3 + 1 : Fin 4) = 0 from rfl, add_zero] at this

omit [Fintype V] in
theorem IsC4Map.ne_at {g : Fin 4 → V} (hg : IsC4Map G g) (k : Fin 4) {a b : Fin 4}
    (h : a ≠ b) : g (k + a) ≠ g (k + b) := fun he => h (add_left_cancel (hg.1 he))

theorem square_supported_degree_ge_two
    (hs : SquareSupported G) (v : V)
    (hv : 0 < G.degree v) :
    2 ≤ G.degree v := by
  obtain ⟨w, hw⟩ := (G.degree_pos_iff_exists_adj v).mp hv
  obtain ⟨g, hg, rfl, rfl⟩ := hs hw
  obtain ⟨-, -, -, h30⟩ := IsC4Map.adj_at G hg 0
  have hne := IsC4Map.ne_at G hg 0 (a := 1) (b := 3) (by decide)
  simp only [zero_add] at h30 hne
  exact two_le_degree_of_adj G hw h30.symm hne

theorem degree_four_reduction
    (v : V) (hdeg : 4 ≤ G.degree v) :
    tau4 G ≤ tau4 (erase G {v}) + 1 ∧
    edgeCount (erase G {v}) + 4 ≤ edgeCount G := by
  refine ⟨?_, ?_⟩
  · have := tau4_delete_vertices_le G {v} {v} subset_rfl fun f _ h => h
    simpa using this
  · have := (erase_singleton_counts G v).1
    omega

theorem mixed_reduction
    {u v : V} (h : G.Adj u v)
    (hu : G.degree u = 2) (hv : G.degree v = 3) :
    tau4 G ≤ tau4 (erase G {u,v}) + 1 ∧
    edgeCount (erase G {u,v}) + 4 = edgeCount G := by
  have huv : u ≠ v := h.ne
  refine ⟨?_, ?_⟩
  · have hHit : HitsDeleted G {u, v} {v} := by
      intro g hg ⟨k, hk⟩
      by_cases hv' : ∃ i, g i = v
      · obtain ⟨i, hi⟩ := hv'
        exact ⟨i, by simp [hi]⟩
      · push Not at hv'
        exfalso
        have hk' : g k = u := by
          rcases Finset.mem_insert.mp hk with h' | h'
          · exact h'
          · exact absurd (Finset.mem_singleton.mp h') (hv' k)
        obtain ⟨h1, -, -, h3⟩ := IsC4Map.adj_at G hg k
        have hne := IsC4Map.ne_at G hg k (a := 1) (b := 3) (by decide)
        rw [hk'] at h1 h3
        have := three_le_degree_of_adj G h h1 h3.symm (hv' _).symm (hv' _).symm hne
        omega
    have := tau4_delete_vertices_le G {u, v} {v} (by simp) hHit
    simpa using this
  · have h1 := erase_edgeCount G {u, v}
    have h2 := two_mul_edgeCount_induce G {u, v}
    rw [Finset.sum_pair huv, hu, hv] at h1
    simp only [Finset.sum_pair huv, SimpleGraph.irrefl, h, h.symm, if_true, if_false] at h2
    omega

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
  have hinj := hf.1
  obtain ⟨-, h01, h12, h23, h30⟩ := hf
  have hne : ∀ i j : Fin 4, i ≠ j → f i ≠ f j := fun i j h => hinj.ne h
  refine ⟨?_, ?_⟩
  · have hHit : HitsDeleted G (Finset.univ.image f) {f 0, f 2} := by
      intro g hg ⟨k, hk⟩
      by_contra hX
      push Not at hX
      have hX' : ∀ j, g j ≠ f 0 ∧ g j ≠ f 2 := fun j => by
        have := hX j; simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at this
        exact this
      obtain ⟨m, -, hm⟩ := Finset.mem_image.mp hk
      obtain ⟨g1, -, -, g3⟩ := IsC4Map.adj_at G hg k
      have hg13 := IsC4Map.ne_at G hg k (a := 1) (b := 3) (by decide)
      rw [← hm] at g1 g3
      have h02 := hne 0 2 (by decide)
      fin_cases m
      · exact (hX' k).1 hm.symm
      · have := four_le_degree_of_adj G h01.symm h12 g1 g3.symm h02 (hX' _).1.symm
          (hX' _).1.symm (hX' _).2.symm (hX' _).2.symm hg13
        have := hdeg 1; simp_all
      · exact (hX' k).2 hm.symm
      · have := four_le_degree_of_adj G h30 h23.symm g1 g3.symm h02 (hX' _).1.symm
          (hX' _).1.symm (hX' _).2.symm (hX' _).2.symm hg13
        have := hdeg 3; simp_all
    have hcard : ({f 0, f 2} : Finset V).card = 2 := Finset.card_pair (hne 0 2 (by decide))
    have := tau4_delete_vertices_le G (Finset.univ.image f) {f 0, f 2}
      (by intro x hx; simp only [Finset.mem_insert, Finset.mem_singleton] at hx
          rcases hx with rfl | rfl <;> exact Finset.mem_image_of_mem _ (Finset.mem_univ _)) hHit
    omega
  · have h1 := erase_edgeCount G (Finset.univ.image f)
    have h2 := two_mul_edgeCount_induce G (Finset.univ.image f)
    rw [Finset.sum_image fun x _ y _ h => hinj h] at h1 h2
    simp only [hdeg, Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul] at h1
    simp only [Finset.sum_image fun x _ y _ h => hinj h] at h2
    have hca : ¬ G.Adj (f 2) (f 0) := fun h => hac h.symm
    have hdb : ¬ G.Adj (f 3) (f 1) := fun h => hbd h.symm
    simp only [sum_fin_four, SimpleGraph.irrefl, h01, h12, h23, h30, h01.symm, h12.symm,
      h23.symm, h30.symm, hac, hbd, hca, hdb, ite_true, ite_false] at h2
    omega

theorem subcubic_chord_reduction
    (hdeg : ∀ v, G.degree v ≤ 3)
    (f : Fin 4 → V) (hf : IsC4Map G f)
    (hac : G.Adj (f 0) (f 2)) :
    tau4 G ≤ tau4 (erase G {f 0,f 1,f 2}) + 1 ∧
    edgeCount (erase G {f 0,f 1,f 2}) +
      G.degree (f 1) + 3 = edgeCount G ∧
    2 ≤ G.degree (f 1) := by
  have hinj := hf.1
  have hfc := hf
  obtain ⟨-, h01, h12, h23, h30⟩ := hf
  have hne : ∀ i j : Fin 4, i ≠ j → f i ≠ f j := fun i j h => hinj.ne h
  have hd0 : G.degree (f 0) = 3 := le_antisymm (hdeg _)
    (three_le_degree_of_adj G h01 hac h30.symm (hne 1 2 (by decide)) (hne 1 3 (by decide))
      (hne 2 3 (by decide)))
  have hd2 : G.degree (f 2) = 3 := le_antisymm (hdeg _)
    (three_le_degree_of_adj G h12.symm h23 hac.symm (hne 1 3 (by decide)) (hne 1 0 (by decide))
      (hne 3 0 (by decide)))
  have hN : ∀ a : Fin 4, (a = 0 ∨ a = 2) → ∀ y, G.Adj (f a) y → ∃ j, j ≠ a ∧ y = f j := by
    rintro a (rfl | rfl) y hy
    · by_contra hc
      push Not at hc
      have := four_le_degree_of_adj G h01 hac h30.symm hy (hne 1 2 (by decide))
        (hne 1 3 (by decide)) (hc 1 (by decide)).symm (hne 2 3 (by decide))
        (hc 2 (by decide)).symm (hc 3 (by decide)).symm
      omega
    · by_contra hc
      push Not at hc
      have := four_le_degree_of_adj G h12.symm h23 hac.symm hy (hne 1 3 (by decide))
        (hne 1 0 (by decide)) (hc 1 (by decide)).symm (hne 3 0 (by decide))
        (hc 3 (by decide)).symm (hc 0 (by decide)).symm
      omega
  have key4 : ∀ a b c d : Fin 4, a ≠ 1 → b ≠ 1 → c ≠ 1 → d ≠ 1 → a ≠ b → a ≠ c → a ≠ d →
      b ≠ c → b ≠ d → c ≠ d → False := by intro a b c d; omega
  have key2 : ∀ iq ir : Fin 4, iq ≠ 1 → ir ≠ 1 → iq ≠ ir → ¬(iq = 0 ∨ iq = 2) →
      (ir = 0 ∨ ir = 2) := by intro a b; omega
  refine ⟨?_, ?_, two_le_degree_of_adj G h01.symm h12 (hne 0 2 (by decide))⟩
  · have hHit : HitsDeleted G {f 0, f 1, f 2} {f 1} := by
      intro g hg ⟨k, hk⟩
      by_contra hX
      push Not at hX
      have hX' : ∀ j, g j ≠ f 1 := fun j h => hX j (by simp [h])
      have hidx : ∀ j i, g j = f i → i ≠ 1 := fun j i h hi => hX' j (hi ▸ h)
      obtain ⟨g1, g2, g3, g4⟩ := IsC4Map.adj_at G hg k
      have n13 := IsC4Map.ne_at G hg k (a := 1) (b := 3) (by decide)
      have n12 := IsC4Map.ne_at G hg k (a := 1) (b := 2) (by decide)
      have n23 := IsC4Map.ne_at G hg k (a := 2) (b := 3) (by decide)
      have n02 := IsC4Map.ne_at G hg k (a := 0) (b := 2) (by decide)
      simp only [add_zero] at n02
      obtain ⟨a, ha, hka⟩ : ∃ a : Fin 4, (a = 0 ∨ a = 2) ∧ g k = f a := by
        simp only [Finset.mem_insert, Finset.mem_singleton] at hk
        rcases hk with h | h | h
        · exact ⟨0, Or.inl rfl, h⟩
        · exact absurd h (hX' k)
        · exact ⟨2, Or.inr rfl, h⟩
      rw [hka] at g1 g4
      obtain ⟨iq, hqa, hq⟩ := hN a ha _ g1
      obtain ⟨ir, hra, hr⟩ := hN a ha _ g4.symm
      have hqr : iq ≠ ir := fun h => n13 (by rw [hq, hr, h])
      have hq1 := hidx _ _ hq
      have hr1 := hidx _ _ hr
      have ha1 : a ≠ 1 := by rcases ha with rfl | rfl <;> decide
      by_cases hqA : iq = 0 ∨ iq = 2
      · rw [hq] at g2
        obtain ⟨it, htq, ht⟩ := hN iq hqA _ g2
        have hta : it ≠ a := fun h => n02 (by rw [hka, ht, h])
        have htr : it ≠ ir := fun h => n23 (by rw [ht, hr, h])
        exact key4 a iq ir it ha1 hq1 hr1 (hidx _ _ ht) hqa.symm hra.symm hta.symm hqr
          htq.symm htr.symm
      · have hrA := key2 iq ir hq1 hr1 hqr hqA
        rw [hr] at g3
        obtain ⟨it, htr, ht⟩ := hN ir hrA _ g3.symm
        have hta : it ≠ a := fun h => n02 (by rw [hka, ht, h])
        have htq : it ≠ iq := fun h => n12 (by rw [ht, hq, h])
        exact key4 a iq ir it ha1 hq1 hr1 (hidx _ _ ht) hqa.symm hra.symm hta.symm hqr
          htq.symm htr.symm
    have := tau4_delete_vertices_le G {f 0, f 1, f 2} {f 1} (by simp) hHit
    simpa using this
  · have h1 := erase_edgeCount G {f 0, f 1, f 2}
    have h2 := two_mul_edgeCount_induce G {f 0, f 1, f 2}
    have m0 : f 0 ∉ ({f 1, f 2} : Finset V) := by
      simp [hne 0 1 (by decide), hne 0 2 (by decide)]
    have n12 := hne 1 2 (by decide)
    rw [Finset.sum_insert m0, Finset.sum_pair n12, hd0, hd2] at h1
    simp only [Finset.sum_insert m0, Finset.sum_pair n12, SimpleGraph.irrefl, h01, h12, hac,
      h01.symm, h12.symm, hac.symm, ite_true, ite_false] at h2
    omega

theorem degree_two_three_cases
    (hcon : G.Connected)
    (hdeg : ∀ v, G.degree v = 2 ∨ G.degree v = 3) :
    (∀ v, G.degree v = 2) ∨
    (∀ v, G.degree v = 3) ∨
    ∃ u v, G.Adj u v ∧
      G.degree u = 2 ∧ G.degree v = 3 := by
  by_cases h2 : ∀ v, G.degree v = 2
  · exact Or.inl h2
  by_cases h3 : ∀ v, G.degree v = 3
  · exact Or.inr (Or.inl h3)
  push Not at h2 h3
  obtain ⟨a, ha⟩ := h2
  obtain ⟨b, hb⟩ := h3
  have hb2 : G.degree b = 2 := (hdeg b).resolve_right hb
  obtain ⟨p⟩ := hcon.preconnected b a
  obtain ⟨⟨⟨x, y⟩, hxy⟩, -, hx, hy⟩ :=
    p.exists_boundary_dart {w | G.degree w = 2} hb2 ha
  exact Or.inr (Or.inr ⟨x, y, hxy, hx, (hdeg y).resolve_left hy⟩)

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
