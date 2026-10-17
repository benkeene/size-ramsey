/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Shared

/-! Basic semantics of `tau4` and `edgeCount` (Stream A): attainment, monotonicity, isomorphism
invariance, the minimum-certificate principle, and the bridge from the classical `edgeCount` to a
computable `edgeFinset.card`. -/

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

theorem tau4_le_card
    {V : Type*} [Fintype V]
    {G : SimpleGraph V} {S : Finset V}
    (hS : c4Transversal G S) :
    tau4 G ≤ S.card :=
  Nat.sInf_le ⟨S, hS, rfl⟩

theorem exists_transversal_card_eq_tau4
    {V : Type*} [Fintype V] (G : SimpleGraph V) :
    ∃ S : Finset V,
      c4Transversal G S ∧ S.card = tau4 G := by
  have h := Nat.sInf_mem
    (s := {k : ℕ | ∃ S : Finset V, c4Transversal G S ∧ S.card = k})
    ⟨_, Finset.univ, fun _ _ => ⟨0, Finset.mem_univ _⟩, rfl⟩
  exact h

theorem tau4_mono
    {V : Type*} [Fintype V]
    {G H : SimpleGraph V} (h : G ≤ H) :
    tau4 G ≤ tau4 H := by
  obtain ⟨S, hS, hcard⟩ := exists_transversal_card_eq_tau4 H
  refine hcard ▸ tau4_le_card fun f hf => hS f ?_
  obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
  exact ⟨hinj, h h01, h h12, h h23, h h30⟩

theorem IsC4Map.comp_iso
    {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) {f : Fin 4 → V} (hf : IsC4Map G f) :
    IsC4Map H (e ∘ f) := by
  obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
  exact ⟨e.injective.comp hinj, e.map_adj_iff.mpr h01, e.map_adj_iff.mpr h12,
    e.map_adj_iff.mpr h23, e.map_adj_iff.mpr h30⟩

theorem c4Transversal_map_iso
    {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) {T : Finset W} (hT : c4Transversal H T) :
    c4Transversal G (T.map e.symm.toEquiv.toEmbedding) := by
  intro f hf
  obtain ⟨i, hi⟩ := hT _ (IsC4Map.comp_iso e hf)
  refine ⟨i, Finset.mem_map.mpr ⟨_, hi, ?_⟩⟩
  simp

theorem tau4_le_of_iso
    {V W : Type*} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) :
    tau4 G ≤ tau4 H := by
  obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 H
  have := tau4_le_card (c4Transversal_map_iso e hT)
  rwa [Finset.card_map, hcard] at this

theorem tau4_iso
    {V W : Type*} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) :
    tau4 G = tau4 H :=
  le_antisymm (tau4_le_of_iso e) (tau4_le_of_iso e.symm)

end SizeRamsey

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

theorem edgeCount_iso
    {V : Type u} {W : Type v} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W} (e : G ≃g H) :
    edgeCount G = edgeCount H := by
  rw [edgeCount_eq_card, edgeCount_eq_card]
  exact e.card_edgeFinset_eq

theorem tau4_eq_zero_iff
    {V : Type u} [Fintype V] (G : SimpleGraph V) :
    tau4 G = 0 ↔ ¬ HasC4 G := by
  constructor
  · intro h0 ⟨f, hf⟩
    obtain ⟨S, hS, hcard⟩ := exists_transversal_card_eq_tau4 G
    rw [h0, Finset.card_eq_zero] at hcard
    subst hcard
    obtain ⟨i, hi⟩ := hS f hf
    simp at hi
  · intro h
    have : c4Transversal G ∅ := fun f hf => (h ⟨f, hf⟩).elim
    exact Nat.le_zero.mp (tau4_le_card this)

theorem tau4_eq_of_certificates
    {V : Type u} [Fintype V] {G : SimpleGraph V} (k : ℕ)
    (hupper : ∃ S : Finset V, c4Transversal G S ∧ S.card = k)
    (hlower : ∀ S : Finset V,
      S.card < k → ¬ c4Transversal G S) :
    tau4 G = k := by
  obtain ⟨S, hS, rfl⟩ := hupper
  refine le_antisymm (tau4_le_card hS) ?_
  by_contra hlt
  obtain ⟨T, hT, hcard⟩ := exists_transversal_card_eq_tau4 G
  exact hlower T (by omega) hT

end SizeRamsey.Plan
