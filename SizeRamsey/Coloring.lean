/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Equality
public import SizeRamsey.ColoringBase

/-! Corollary C (Stream B): connected graphs with at most 16 edges have a transversal of size at
most three (Theorems A and B), hence an avoiding colouring (`ColoringBase`). -/

@[expose] public section

namespace SizeRamsey

theorem connected_transversal_le_three
    {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected) (hle : edgeCount G ≤ 16) :
    ∃ S : Finset V,
      c4Transversal G S ∧ S.card ≤ 3 := by
  obtain ⟨S, hS, hcard⟩ := exists_transversal_card_eq_tau4 G
  refine ⟨S, hS, ?_⟩
  rw [hcard]
  by_contra hnot
  have hu := Proof.four_mul_tau4_le_edgeCount G
  have hm : edgeCount G = 16 := by omega
  have heq : 4 * tau4 G = edgeCount G := by omega
  have hclass := (Proof.equality_classification G hconn (by omega) hle).mp heq
  obtain ⟨hC, hW, hK, hO⟩ := Plan.small_graph_data
  rcases hclass with hC4 | hW5 | hK33 | hOct
  · obtain ⟨e⟩ := hC4
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hW5
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hK33
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hOct
    have hi := Plan.edgeCount_iso e
    omega

namespace Proof

theorem avoiding_coloring_le_sixteen
    {V : Type*} [Fintype V] (F : SimpleGraph V)
    (hconn : F.Connected) (hle : edgeCount F ≤ 16) :
    ∃ R : SimpleGraph V,
      R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  obtain ⟨S, hS, hcard⟩ := connected_transversal_le_three F hconn hle
  exact avoiding_coloring_of_transversal F S hS hcard

end Proof
end SizeRamsey
