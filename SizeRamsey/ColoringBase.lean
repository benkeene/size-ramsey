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
  sorry

theorem transversal_no_blue_square {V : Type*}
    (F : SimpleGraph V) (S : Finset V)
    (h : c4Transversal F S) :
    ¬ HasC4 (F \ incidentRed F S) := by
  sorry

end SizeRamsey.Plan

namespace SizeRamsey

theorem avoiding_coloring_of_transversal {V : Type*}
    (F : SimpleGraph V) (S : Finset V)
    (hS : c4Transversal F S) (hcard : S.card ≤ 3) :
    ∃ R : SimpleGraph V,
      R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  sorry

end SizeRamsey
