/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Basic
public import Mathlib.Tactic.FinCases
public import Mathlib.Data.Fin.VecNotation

/-! Decidability instances and small explicit certificates (Stream A). This file deliberately
has no classical instance override, so `decide` runs on the computable instances. Finite facts
are checked on explicit witnesses; there is no graph census. -/

@[expose] public section

namespace SizeRamsey.Plan

instance {V : Type*} [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (f : Fin 4 → V) :
    Decidable (IsC4Map G f) := by
  unfold IsC4Map
  infer_instance

instance {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    Decidable (HasC4 G) := by
  unfold HasC4
  infer_instance

instance {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) :
    Decidable (c4Transversal G S) := by
  unfold c4Transversal
  infer_instance

instance : DecidableRel wheel5.Adj := by
  unfold wheel5
  infer_instance

instance : DecidableRel k33MinusEdge.Adj := by
  unfold k33MinusEdge
  infer_instance

instance : DecidableRel octahedron.Adj := by
  unfold octahedron
  infer_instance

theorem k33_square_avoids_vertex (v : Fin 6) :
    ∃ f : Fin 4 → Fin 6,
      IsC4Map k33MinusEdge f ∧ ∀ i, f i ≠ v := by
  fin_cases v
  · exact ⟨![1,3,2,4], by decide⟩
  · exact ⟨![0,4,2,5], by decide⟩
  · exact ⟨![0,4,1,5], by decide⟩
  · exact ⟨![0,4,1,5], by decide⟩
  · exact ⟨![1,3,2,5], by decide⟩
  · exact ⟨![1,3,2,4], by decide⟩

theorem k33_triangle_free :
    ∀ a b c, k33MinusEdge.Adj a b →
      k33MinusEdge.Adj b c → ¬ k33MinusEdge.Adj c a := by
  decide

/-- A square presented by its four consecutive vertices. -/
theorem isC4Map_of_adj {V : Type*} {G : SimpleGraph V} {a b c d : V}
    (hab : G.Adj a b) (hbc : G.Adj b c) (hcd : G.Adj c d) (hda : G.Adj d a)
    (hac : a ≠ c) (hbd : b ≠ d) : IsC4Map G ![a, b, c, d] := by
  refine ⟨?_, hab, hbc, hcd, hda⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [hab.ne, hbc.ne, hcd.ne, hda.ne, hab.ne.symm,
    hbc.ne.symm, hcd.ne.symm, hda.ne.symm, hac.symm, hbd.symm]

/-- Quantifier form of a transversal, cheap to `decide` on `Fin n` (no search over maps). -/
def QTrans {V : Type*} (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ a b c d, G.Adj a b → G.Adj b c → G.Adj c d → G.Adj d a → a ≠ c → b ≠ d →
    a ∈ S ∨ b ∈ S ∨ c ∈ S ∨ d ∈ S

instance {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (S : Finset (Fin n)) :
    Decidable (QTrans G S) := by
  unfold QTrans
  infer_instance

theorem c4Transversal_of_QTrans {V : Type*} {G : SimpleGraph V} {S : Finset V}
    (h : QTrans G S) : c4Transversal G S := by
  rintro f ⟨hinj, h01, h12, h23, h30⟩
  rcases h _ _ _ _ h01 h12 h23 h30 (hinj.ne (by decide)) (hinj.ne (by decide)) with
    h | h | h | h
  exacts [⟨0, h⟩, ⟨1, h⟩, ⟨2, h⟩, ⟨3, h⟩]

/-- A square avoiding `S` shows that `S` is not a transversal. -/
theorem not_c4Transversal_of_square {V : Type*} {G : SimpleGraph V} {S : Finset V}
    {a b c d : V}
    (hab : G.Adj a b) (hbc : G.Adj b c) (hcd : G.Adj c d) (hda : G.Adj d a)
    (hac : a ≠ c) (hbd : b ≠ d)
    (havoid : a ∉ S ∧ b ∉ S ∧ c ∉ S ∧ d ∉ S) : ¬ c4Transversal G S := by
  intro hS
  obtain ⟨i, hi⟩ := hS _ (isC4Map_of_adj hab hbc hcd hda hac hbd)
  fin_cases i <;> simp_all

theorem exists_subset_pair {V : Type*} [DecidableEq V] (x₀ : V) (S : Finset V)
    (hS : S.card ≤ 2) : ∃ x y, S ⊆ {x, y} := by
  rcases Nat.lt_or_ge S.card 2 with h | h
  · rcases Nat.lt_or_ge S.card 1 with h' | h'
    · rw [Nat.lt_one_iff, Finset.card_eq_zero] at h'
      exact ⟨x₀, x₀, by simp [h']⟩
    · obtain ⟨x, hx⟩ := (Finset.card_eq_one (s := S)).mp (by omega)
      exact ⟨x, x, by rw [hx]; simp⟩
  · obtain ⟨x, y, -, hxy⟩ := (Finset.card_eq_two (s := S)).mp (by omega)
    exact ⟨x, y, hxy.le⟩

/-- Lower bound `τ₄ ≥ 3` from a table: every pair of vertices is avoided by some square. -/
theorem not_c4Transversal_of_avoid_pair {V : Type*} {G : SimpleGraph V}
    (x₀ : V)
    (h : ∀ x y : V, ∃ a b c d : V, G.Adj a b ∧ G.Adj b c ∧ G.Adj c d ∧ G.Adj d a ∧
      a ≠ c ∧ b ≠ d ∧ a ≠ x ∧ b ≠ x ∧ c ≠ x ∧ d ≠ x ∧ a ≠ y ∧ b ≠ y ∧ c ≠ y ∧ d ≠ y)
    (S : Finset V) (hS : S.card < 3) : ¬ c4Transversal G S := by
  classical
  obtain ⟨x, y, hxy⟩ := exists_subset_pair x₀ S (by omega)
  obtain ⟨a, b, c, d, hab, hbc, hcd, hda, hac, hbd, h1, h2, h3, h4, h5, h6, h7, h8⟩ := h x y
  refine not_c4Transversal_of_square hab hbc hcd hda hac hbd ⟨?_, ?_, ?_, ?_⟩ <;>
    intro hm <;> have := hxy hm <;> simp_all

theorem exists_subset_single {V : Type*} (x₀ : V) (S : Finset V)
    (hS : S.card ≤ 1) : ∃ x, S ⊆ {x} := by
  rcases Nat.lt_or_ge S.card 1 with h' | h'
  · rw [Nat.lt_one_iff, Finset.card_eq_zero] at h'
    exact ⟨x₀, by simp [h']⟩
  · obtain ⟨x, hx⟩ := (Finset.card_eq_one (s := S)).mp (by omega)
    exact ⟨x, hx.le⟩

/-- Lower bound `τ₄ ≥ 2` from a table: every vertex is avoided by some square. -/
theorem not_c4Transversal_of_avoid_one {V : Type*} {G : SimpleGraph V}
    (x₀ : V)
    (h : ∀ x : V, ∃ a b c d : V, G.Adj a b ∧ G.Adj b c ∧ G.Adj c d ∧ G.Adj d a ∧
      a ≠ c ∧ b ≠ d ∧ a ≠ x ∧ b ≠ x ∧ c ≠ x ∧ d ≠ x)
    (S : Finset V) (hS : S.card < 2) : ¬ c4Transversal G S := by
  obtain ⟨x, hx⟩ := exists_subset_single x₀ S (by omega)
  obtain ⟨a, b, c, d, hab, hbc, hcd, hda, hac, hbd, h1, h2, h3, h4⟩ := h x
  refine not_c4Transversal_of_square hab hbc hcd hda hac hbd ⟨?_, ?_, ?_, ?_⟩ <;>
    intro hm <;> have := hx hm <;> simp_all

/-- Lower bound `τ₄ ≥ 1` from one square. -/
theorem not_c4Transversal_of_card_lt_one {V : Type*} {G : SimpleGraph V} {a b c d : V}
    (hab : G.Adj a b) (hbc : G.Adj b c) (hcd : G.Adj c d) (hda : G.Adj d a)
    (hac : a ≠ c) (hbd : b ≠ d) (S : Finset V) (hS : S.card < 1) : ¬ c4Transversal G S := by
  rw [Nat.lt_one_iff, Finset.card_eq_zero] at hS
  subst hS
  exact not_c4Transversal_of_square hab hbc hcd hda hac hbd (by simp)

end SizeRamsey.Plan
