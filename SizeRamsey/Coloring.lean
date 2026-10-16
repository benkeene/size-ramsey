/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import SizeRamsey.Equality

/-! Corollary C: a 3-vertex transversal gives an avoiding colouring (edges at the transversal red,
the rest blue); connected graphs with at most 16 edges have one by Theorems A and B. -/

@[expose] public section

namespace SizeRamsey

/-- The red graph of a transversal `S`: the edges of `F` incident with `S`. -/
def incidentRed {V : Type*} (F : SimpleGraph V) (S : Finset V) : SimpleGraph V :=
  SimpleGraph.fromRel (fun u v => F.Adj u v ∧ (u ∈ S ∨ v ∈ S))

theorem avoiding_coloring_of_transversal {V : Type*} (F : SimpleGraph V)
    (S : Finset V) (hS : c4Transversal F S) (hcard : S.card ≤ 3) :
    ∃ R : SimpleGraph V, R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  sorry

theorem connected_transversal_le_three {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected) (hle : edgeCount G ≤ 16) :
    ∃ S : Finset V, c4Transversal G S ∧ S.card ≤ 3 := by
  sorry

namespace Proof

theorem avoiding_coloring_le_sixteen {V : Type*} [Fintype V] (F : SimpleGraph V)
    (hconn : F.Connected) (hle : edgeCount F ≤ 16) :
    ∃ R : SimpleGraph V, R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  sorry

end Proof

end SizeRamsey
