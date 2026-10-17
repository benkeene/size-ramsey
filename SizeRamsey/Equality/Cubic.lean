/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Equality.Common

/-! Equality, cubic case (Stream B): the crossing lemma for two squares joined by a perfect
matching, and the contradiction for tight cubic graphs. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem two_squares_matching_transversal
    {V : Type u} (G : SimpleGraph V)
    (l r : Fin 4 → V) (μ : Fin 4 ≃ Fin 4)
    (hl : Function.Injective l)
    (hr : Function.Injective r)
    (hdisj : ∀ i j, l i ≠ r j)
    (hcover : ∀ v,
      (∃ i, l i = v) ∨ ∃ j, r j = v)
    (hleft : ∀ i j,
      G.Adj (l i) (l j) ↔
        (SimpleGraph.cycleGraph 4).Adj i j)
    (hright : ∀ i j,
      G.Adj (r i) (r j) ↔
        (SimpleGraph.cycleGraph 4).Adj i j)
    (hcross : ∀ i j,
      G.Adj (l i) (r j) ↔ μ i = j) :
    c4Transversal G {l 0, r (μ 2)} := by
  sorry

theorem equality_cubic_impossible
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (hc : G.Connected)
    (hp : 0 < edgeCount G)
    (hm : edgeCount G ≤ 16)
    (ht : Tight G)
    (ih : SmallerClassified G)
    (h3 : ∀ v, G.degree v = 3) :
    False := by
  sorry

end SizeRamsey.Plan
