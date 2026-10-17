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
  sorry

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
