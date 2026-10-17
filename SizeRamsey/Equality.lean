/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Equality.DegreeFour
public import SizeRamsey.Equality.Mixed
public import SizeRamsey.Equality.Cubic
public import SizeRamsey.Equality.TwoRegular

/-! Theorem B (Stream B): strong induction on the edge count over vertex types in one universe,
dispatching to the degree-four, mixed, cubic and two-regular cases; the converse is
`classified_tight`. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u

attribute [local instance] Classical.propDecidable

theorem classification_of_step
    (step : ∀ {V : Type u} [Fintype V]
      (G : SimpleGraph V),
      G.Connected → 0 < edgeCount G →
      edgeCount G ≤ 16 →
      Tight G → SmallerClassified G → Classified G)
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (hc : G.Connected)
    (hp : 0 < edgeCount G)
    (hm : edgeCount G ≤ 16)
    (ht : Tight G) :
    Classified G := by
  have aux : ∀ n, ∀ {W : Type u} [Fintype W]
      (H : SimpleGraph W),
      edgeCount H = n → H.Connected →
      0 < edgeCount H → edgeCount H ≤ 16 →
      Tight H → Classified H := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro W inst H he hconn hpos hcap htight
      apply step H hconn hpos hcap htight
      intro X instX K kc kp klt kt
      have kn : edgeCount K < n := by omega
      exact ih (edgeCount K) kn K rfl kc kp
        (by omega) kt
  exact aux (edgeCount G) G rfl hc hp hm ht

end SizeRamsey.Plan

namespace SizeRamsey.Proof

theorem equality_classification
    {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected)
    (hpos : 0 < edgeCount G)
    (hle : edgeCount G ≤ 16) :
    4 * tau4 G = edgeCount G ↔
      Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨
      Nonempty (G ≃g wheel5) ∨
      Nonempty (G ≃g k33MinusEdge) ∨
      Nonempty (G ≃g octahedron) := by
  sorry

end SizeRamsey.Proof
