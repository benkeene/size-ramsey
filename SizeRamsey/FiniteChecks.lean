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

end SizeRamsey.Plan
