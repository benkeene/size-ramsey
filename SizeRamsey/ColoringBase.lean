/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Shared
public import SizeRamsey.Basic

/-! The generic avoiding colouring (Stream B): colour red the edges of `F` incident with a
transversal `S`; if `|S| ≤ 3` there is no red 4-matching and no blue `C₄`. Imports no
equality-classification file. -/

@[expose] public section

namespace SizeRamsey

/-- The red graph of a transversal `S`: the edges of `F` incident with `S`. -/
def incidentRed {V : Type*} (F : SimpleGraph V) (S : Finset V) : SimpleGraph V :=
  SimpleGraph.fromRel (fun u v => F.Adj u v ∧ (u ∈ S ∨ v ∈ S))

end SizeRamsey

namespace SizeRamsey.Plan

theorem incidentRed_adj {V : Type*}
    (F : SimpleGraph V) (S : Finset V) (u v : V) :
    (incidentRed F S).Adj u v ↔
      F.Adj u v ∧ (u ∈ S ∨ v ∈ S) := by
  simp only [incidentRed, SimpleGraph.fromRel_adj]
  constructor
  · rintro ⟨_, h | h⟩
    · exact h
    · exact ⟨h.1.symm, h.2.symm⟩
  · intro h
    exact ⟨h.1.ne, Or.inl h⟩

theorem matching4_incident_card {V : Type*}
    (F : SimpleGraph V) (S : Finset V)
    (h : HasMatching4 (incidentRed F S)) :
    4 ≤ S.card := by
  classical
  obtain ⟨f, hf, h01, h23, h45, h67⟩ := h
  have pick : ∀ a b : Fin 8, (incidentRed F S).Adj (f a) (f b) →
      ∃ k, (k = a ∨ k = b) ∧ f k ∈ S := fun a b hab =>
    ((incidentRed_adj F S _ _).1 hab).2.elim (fun h => ⟨a, Or.inl rfl, h⟩)
      (fun h => ⟨b, Or.inr rfl, h⟩)
  obtain ⟨k0, hk0, hs0⟩ := pick _ _ h01
  obtain ⟨k1, hk1, hs1⟩ := pick _ _ h23
  obtain ⟨k2, hk2, hs2⟩ := pick _ _ h45
  obtain ⟨k3, hk3, hs3⟩ := pick _ _ h67
  have hcard : ({k0, k1, k2, k3} : Finset (Fin 8)).card = 4 := by
    rcases hk0 with rfl | rfl <;> rcases hk1 with rfl | rfl <;>
      rcases hk2 with rfl | rfl <;> rcases hk3 with rfl | rfl <;> decide
  have hsub : ({k0, k1, k2, k3} : Finset (Fin 8)).image f ⊆ S := by
    intro x hx
    simp only [Finset.mem_image, Finset.mem_insert, Finset.mem_singleton] at hx
    obtain ⟨k, hk, rfl⟩ := hx
    rcases hk with rfl | rfl | rfl | rfl <;> assumption
  calc 4 = (({k0, k1, k2, k3} : Finset (Fin 8)).image f).card := by
        rw [Finset.card_image_of_injective _ hf, hcard]
    _ ≤ S.card := Finset.card_le_card hsub

theorem transversal_no_blue_square {V : Type*}
    (F : SimpleGraph V) (S : Finset V)
    (h : c4Transversal F S) :
    ¬ HasC4 (F \ incidentRed F S) := by
  rintro ⟨f, hf, h01, h12, h23, h30⟩
  have hF : IsC4Map F f := ⟨hf, h01.1, h12.1, h23.1, h30.1⟩
  have red : ∀ a b : Fin 4, (F \ incidentRed F S).Adj (f a) (f b) →
      f a ∈ S → False := fun a b hab ha =>
    hab.2 ((incidentRed_adj F S _ _).2 ⟨hab.1, Or.inl ha⟩)
  obtain ⟨i, hi⟩ := h f hF
  fin_cases i
  · exact red _ _ h01 hi
  · exact red _ _ h12 hi
  · exact red _ _ h23 hi
  · exact red _ _ h30 hi

end SizeRamsey.Plan

namespace SizeRamsey

theorem avoiding_coloring_of_transversal {V : Type*}
    (F : SimpleGraph V) (S : Finset V)
    (hS : c4Transversal F S) (hcard : S.card ≤ 3) :
    ∃ R : SimpleGraph V,
      R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  refine ⟨incidentRed F S, fun u v h => ((Plan.incidentRed_adj F S u v).1 h).1,
    fun hm => ?_, Plan.transversal_no_blue_square F S hS⟩
  have := Plan.matching4_incident_card F S hm
  omega

end SizeRamsey
