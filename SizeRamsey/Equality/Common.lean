/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.AInterface

/-! Equality, common lemma (Stream B): a tight subcubic graph has no chorded square. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem tight_subcubic_chordless
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (ht : Tight G)
    (hmax : ∀ v, G.degree v ≤ 3)
    (f : Fin 4 → V) (hf : IsC4Map G f) :
    ¬ G.Adj (f 0) (f 2) ∧
    ¬ G.Adj (f 1) (f 3) := by
  sorry

end SizeRamsey.Plan
