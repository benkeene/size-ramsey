/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.FiniteChecks

/-! The four equality graphs `C₄`, `W₅`, `K₃,₃ − e`, `K₂,₂,₂` (Stream A): edge counts, degrees,
transversal numbers, optimal transversals through any prescribed vertex, and the consequences
for classified graphs. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

/-! ### Computational certificates (no classical instance override) -/

section Certificates

theorem cycle4_edgeCount : edgeCount (SimpleGraph.cycleGraph 4) = 4 := by
  rw [edgeCount_eq_card]; decide

theorem wheel5_edgeCount : edgeCount wheel5 = 8 := by
  rw [edgeCount_eq_card]; decide

theorem k33MinusEdge_edgeCount : edgeCount k33MinusEdge = 8 := by
  rw [edgeCount_eq_card]; decide

theorem octahedron_edgeCount : edgeCount octahedron = 12 := by
  rw [edgeCount_eq_card]; decide

/-- Optimal transversals through each prescribed vertex. -/
def cycle4Pres : Fin 4 → Finset (Fin 4) := fun v => {v}

def wheel5Pres : Fin 5 → Finset (Fin 5) := ![{0, 4}, {1, 4}, {2, 4}, {3, 4}, {4, 0}]

def k33Pres : Fin 6 → Finset (Fin 6) := ![{0, 1}, {1, 2}, {2, 0}, {3, 4}, {4, 5}, {5, 3}]

def octahedronPres : Fin 6 → Finset (Fin 6) :=
  ![{0, 1, 2}, {1, 0, 2}, {2, 3, 0}, {3, 2, 0}, {4, 5, 0}, {5, 4, 0}]

theorem cycle4Pres_spec : ∀ v, v ∈ cycle4Pres v ∧ (cycle4Pres v).card = 1 ∧
    QTrans (SimpleGraph.cycleGraph 4) (cycle4Pres v) := by
  decide

theorem wheel5Pres_spec : ∀ v, v ∈ wheel5Pres v ∧ (wheel5Pres v).card = 2 ∧
    QTrans wheel5 (wheel5Pres v) := by
  decide

theorem k33Pres_spec : ∀ v, v ∈ k33Pres v ∧ (k33Pres v).card = 2 ∧
    QTrans k33MinusEdge (k33Pres v) := by
  decide

theorem octahedronPres_spec : ∀ v, v ∈ octahedronPres v ∧ (octahedronPres v).card = 3 ∧
    QTrans octahedron (octahedronPres v) := by
  decide

theorem wheel5_avoid_one : ∀ x : Fin 5, ∃ a b c d : Fin 5, wheel5.Adj a b ∧ wheel5.Adj b c ∧
    wheel5.Adj c d ∧ wheel5.Adj d a ∧ a ≠ c ∧ b ≠ d ∧ a ≠ x ∧ b ≠ x ∧ c ≠ x ∧ d ≠ x := by
  decide

theorem k33_avoid_one : ∀ x : Fin 6, ∃ a b c d : Fin 6, k33MinusEdge.Adj a b ∧
    k33MinusEdge.Adj b c ∧ k33MinusEdge.Adj c d ∧ k33MinusEdge.Adj d a ∧ a ≠ c ∧ b ≠ d ∧
    a ≠ x ∧ b ≠ x ∧ c ≠ x ∧ d ≠ x := by
  decide

theorem octahedron_avoid_pair : ∀ x y : Fin 6, ∃ a b c d : Fin 6, octahedron.Adj a b ∧
    octahedron.Adj b c ∧ octahedron.Adj c d ∧ octahedron.Adj d a ∧ a ≠ c ∧ b ≠ d ∧
    a ≠ x ∧ b ≠ x ∧ c ≠ x ∧ d ≠ x ∧ a ≠ y ∧ b ≠ y ∧ c ≠ y ∧ d ≠ y := by
  decide

theorem prescribedOptimal_of_table {V : Type*} [Fintype V] {G : SimpleGraph V} (k : ℕ)
    (P : V → Finset V)
    (hP : ∀ v, v ∈ P v ∧ (P v).card = k ∧ QTrans G (P v))
    (hlower : ∀ S : Finset V, S.card < k → ¬ c4Transversal G S) (v₀ : V) :
    tau4 G = k ∧ PrescribedOptimal G := by
  have hk : tau4 G = k :=
    tau4_eq_of_certificates k ⟨P v₀, c4Transversal_of_QTrans (hP v₀).2.2, (hP v₀).2.1⟩ hlower
  refine ⟨hk, fun v => ⟨P v, (hP v).1, c4Transversal_of_QTrans (hP v).2.2, ?_⟩⟩
  rw [hk, (hP v).2.1]

theorem cycle4_tau : tau4 (SimpleGraph.cycleGraph 4) = 1 ∧
    PrescribedOptimal (SimpleGraph.cycleGraph 4) :=
  prescribedOptimal_of_table 1 cycle4Pres cycle4Pres_spec
    (not_c4Transversal_of_card_lt_one (a := 0) (b := 1) (c := 2) (d := 3)
      (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)) 0

theorem wheel5_tau : tau4 wheel5 = 2 ∧ PrescribedOptimal wheel5 :=
  prescribedOptimal_of_table 2 wheel5Pres wheel5Pres_spec
    (not_c4Transversal_of_avoid_one 0 wheel5_avoid_one) 0

theorem k33_tau : tau4 k33MinusEdge = 2 ∧ PrescribedOptimal k33MinusEdge :=
  prescribedOptimal_of_table 2 k33Pres k33Pres_spec
    (not_c4Transversal_of_avoid_one 0 k33_avoid_one) 0

theorem octahedron_tau : tau4 octahedron = 3 ∧ PrescribedOptimal octahedron :=
  prescribedOptimal_of_table 3 octahedronPres octahedronPres_spec
    (not_c4Transversal_of_avoid_pair 0 octahedron_avoid_pair) 0

theorem small_degrees_comp :
    (∀ i : Fin 4, (SimpleGraph.cycleGraph 4).degree i = 2) ∧
    (∀ i : Fin 5,
      wheel5.degree i = if i = 4 then 4 else 3) ∧
    (∀ i : Fin 6,
      k33MinusEdge.degree i =
        if i = 0 ∨ i = 3 then 2 else 3) ∧
    (∀ i : Fin 6, octahedron.degree i = 4) := by
  decide

theorem k33_three_degree_two_absurd : ∀ x y z : Fin 6, x ≠ y → x ≠ z → y ≠ z →
    (x = 0 ∨ x = 3) → (y = 0 ∨ y = 3) → (z = 0 ∨ z = 3) → False := by
  decide

end Certificates

attribute [local instance] Classical.propDecidable

theorem small_graph_data :
    (edgeCount (SimpleGraph.cycleGraph 4) = 4 ∧
      tau4 (SimpleGraph.cycleGraph 4) = 1 ∧
      PrescribedOptimal (SimpleGraph.cycleGraph 4)) ∧
    (edgeCount wheel5 = 8 ∧ tau4 wheel5 = 2 ∧
      PrescribedOptimal wheel5) ∧
    (edgeCount k33MinusEdge = 8 ∧ tau4 k33MinusEdge = 2 ∧
      PrescribedOptimal k33MinusEdge) ∧
    (edgeCount octahedron = 12 ∧ tau4 octahedron = 3 ∧
      PrescribedOptimal octahedron) :=
  ⟨⟨cycle4_edgeCount, cycle4_tau⟩, ⟨wheel5_edgeCount, wheel5_tau⟩,
    ⟨k33MinusEdge_edgeCount, k33_tau⟩, ⟨octahedron_edgeCount, octahedron_tau⟩⟩

theorem small_degrees :
    (∀ i : Fin 4, (SimpleGraph.cycleGraph 4).degree i = 2) ∧
    (∀ i : Fin 5,
      wheel5.degree i = if i = 4 then 4 else 3) ∧
    (∀ i : Fin 6,
      k33MinusEdge.degree i =
        if i = 0 ∨ i = 3 then 2 else 3) ∧
    (∀ i : Fin 6, octahedron.degree i = 4) := by
  convert small_degrees_comp using 0

theorem prescribedOptimal_iso
    {V : Type u} {W : Type v} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) (h : PrescribedOptimal H) :
    PrescribedOptimal G := by
  intro v
  obtain ⟨T, hv, hT, hcard⟩ := h (e v)
  refine ⟨T.map e.symm.toEquiv.toEmbedding, Finset.mem_map.mpr ⟨e v, hv, by simp⟩,
    c4Transversal_map_iso e hT, ?_⟩
  rw [Finset.card_map, hcard, tau4_iso e]

theorem classified_tight
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) :
    Tight G := by
  obtain ⟨d1, d2, d3, d4⟩ := small_graph_data
  unfold Tight
  rcases h with h | h | h | h <;> obtain ⟨e⟩ := h <;> rw [tau4_iso e, edgeCount_iso e]
  · rw [d1.1, d1.2.1]
  · rw [d2.1, d2.2.1]
  · rw [d3.1, d3.2.1]
  · rw [d4.1, d4.2.1]

theorem classified_prescribed
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) :
    PrescribedOptimal G := by
  obtain ⟨d1, d2, d3, d4⟩ := small_graph_data
  rcases h with h | h | h | h <;> obtain ⟨e⟩ := h
  · exact prescribedOptimal_iso e d1.2.2
  · exact prescribedOptimal_iso e d2.2.2
  · exact prescribedOptimal_iso e d3.2.2
  · exact prescribedOptimal_iso e d4.2.2

theorem classified_three_degree_two
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) (a b c : V)
    (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c)
    (ha : G.degree a = 2)
    (hb : G.degree b = 2)
    (hc : G.degree c = 2) :
    Nonempty (G ≃g SimpleGraph.cycleGraph 4) := by
  obtain ⟨-, d2, d3, d4⟩ := small_degrees
  rcases h with h | h | h | h
  · exact h
  all_goals obtain ⟨e⟩ := h
  · exfalso
    have := d2 (e a)
    rw [e.degree_eq, ha] at this
    split_ifs at this <;> omega
  · exfalso
    have key : ∀ x, G.degree x = 2 → e x = 0 ∨ e x = 3 := by
      intro x hx
      have := d3 (e x)
      rw [e.degree_eq, hx] at this
      split_ifs at this with h'
      · exact h'
      · omega
    exact k33_three_degree_two_absurd (e a) (e b) (e c) (e.injective.ne hab)
      (e.injective.ne hac) (e.injective.ne hbc) (key a ha) (key b hb) (key c hc)
  · exfalso
    have := d4 (e a)
    rw [e.degree_eq, ha] at this
    omega

end SizeRamsey.Plan
