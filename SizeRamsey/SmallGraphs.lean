/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.FiniteChecks

/-! The four equality graphs `C₄`, `W₅`, `K₃,₃ − e`, `K₂,₂,₂` (Stream A): edge counts, degrees,
transversal numbers, optimal transversals through any prescribed vertex, and the consequences
for classified graphs. -/

@[expose] public section

namespace SizeRamsey.Plan

open scoped BigOperators

universe u v

attribute [local instance] Classical.propDecidable

theorem small_graph_data :
    (edgeCount (SimpleGraph.cycleGraph 4) = 4 ∧
      tau4 (SimpleGraph.cycleGraph 4) = 1 ∧
      PrescribedOptimal (SimpleGraph.cycleGraph 4)) ∧
    (edgeCount wheel5 = 8 ∧ tau4 wheel5 = 2 ∧
      PrescribedOptimal wheel5) ∧
    (edgeCount k33MinusEdge = 8 ∧ tau4 k33MinusEdge = 2 ∧
      PrescribedOptimal k33MinusEdge) ∧
    (edgeCount octahedron = 12 ∧ tau4 octahedron = 3 ∧
      PrescribedOptimal octahedron) := by
  sorry

theorem small_degrees :
    (∀ i : Fin 4, (SimpleGraph.cycleGraph 4).degree i = 2) ∧
    (∀ i : Fin 5,
      wheel5.degree i = if i = 4 then 4 else 3) ∧
    (∀ i : Fin 6,
      k33MinusEdge.degree i =
        if i = 0 ∨ i = 3 then 2 else 3) ∧
    (∀ i : Fin 6, octahedron.degree i = 4) := by
  sorry

theorem prescribedOptimal_iso
    {V : Type u} {W : Type v} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) (h : PrescribedOptimal H) :
    PrescribedOptimal G := by
  sorry

theorem classified_tight
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) :
    Tight G := by
  sorry

theorem classified_prescribed
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) :
    PrescribedOptimal G := by
  sorry

theorem classified_three_degree_two
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (h : Classified G) (a b c : V)
    (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c)
    (ha : G.degree a = 2)
    (hb : G.degree b = 2)
    (hc : G.degree c = 2) :
    Nonempty (G ≃g SimpleGraph.cycleGraph 4) := by
  sorry

end SizeRamsey.Plan
