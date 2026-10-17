/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.Defs
public import Mathlib.Combinatorics.SimpleGraph.DeleteEdges
public import Mathlib.Combinatorics.SimpleGraph.DegreeSum

/-! Shared vocabulary of both streams (frozen after bootstrap): the induced residual `erase`,
square support, tightness, the classification predicates, components, and cut edges. -/

@[expose] public section

namespace SizeRamsey.Plan

universe u v

attribute [local instance] Classical.propDecidable

def erase {V : Type u} (G : SimpleGraph V) (D : Finset V) :
    SimpleGraph {v : V // v ∉ D} :=
  G.induce {v | v ∉ D}

def EdgeOnSquare {V : Type u} (G : SimpleGraph V) (a b : V) : Prop :=
  ∃ f : Fin 4 → V, IsC4Map G f ∧ f 0 = a ∧ f 1 = b

def SquareSupported {V : Type u} (G : SimpleGraph V) : Prop :=
  ∀ ⦃a b⦄, G.Adj a b → EdgeOnSquare G a b

def Tight {V : Type u} [Fintype V] (G : SimpleGraph V) : Prop :=
  4 * tau4 G = edgeCount G

def Classified {V : Type u} (G : SimpleGraph V) : Prop :=
  Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨
    Nonempty (G ≃g wheel5) ∨
    Nonempty (G ≃g k33MinusEdge) ∨
    Nonempty (G ≃g octahedron)

def SmallerClassified {V : Type u} [Fintype V]
    (G : SimpleGraph V) : Prop :=
  ∀ {W : Type u} [Fintype W] (H : SimpleGraph W),
    H.Connected → 0 < edgeCount H →
    edgeCount H < edgeCount G → Tight H → Classified H

def PrescribedOptimal {V : Type u} [Fintype V]
    (G : SimpleGraph V) : Prop :=
  ∀ v : V, ∃ S : Finset V,
    v ∈ S ∧ c4Transversal G S ∧ S.card = tau4 G

def compGraph {V : Type u} (G : SimpleGraph V)
    (C : G.ConnectedComponent) : SimpleGraph C.supp :=
  G.induce C.supp

noncomputable instance componentFintype
    {V : Type u} [Fintype V] (G : SimpleGraph V) :
    Fintype G.ConnectedComponent :=
  Fintype.ofFinite _

def HitsDeleted {V : Type u} (G : SimpleGraph V)
    (D X : Finset V) : Prop :=
  ∀ f : Fin 4 → V, IsC4Map G f →
    (∃ i, f i ∈ D) → ∃ i, f i ∈ X

noncomputable def liftTransversal {V : Type u}
    (D X : Finset V) (T : Finset {v : V // v ∉ D}) : Finset V :=
  T.image Subtype.val ∪ X

noncomputable def componentVerts {V : Type u} [Fintype V]
    (G : SimpleGraph V) (D : Finset V)
    (C : (erase G D).ConnectedComponent) : Finset V :=
  C.supp.toFinset.image Subtype.val

noncomputable def attachmentEdges {V : Type u} [Fintype V]
    (G : SimpleGraph V) (D : Finset V)
    (C : (erase G D).ConnectedComponent) : Finset (V × V) :=
  ((componentVerts G D C) ×ˢ D).filter
    (fun p => G.Adj p.1 p.2)

end SizeRamsey.Plan
