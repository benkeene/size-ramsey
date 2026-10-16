/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import Mathlib.Combinatorics.SimpleGraph.Finite
public import Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected
public import Mathlib.Combinatorics.SimpleGraph.CycleGraph
public import Mathlib.Order.Lattice.Nat

/-! Definitions shared by the development library. They repeat `Challenge.lean` verbatim (the
comparator checks agreement); the library never imports `Challenge`. -/

@[expose] public section

namespace SizeRamsey

/-- `f` is a (not necessarily induced) copy of `C₄` in `G`: four distinct vertices with the four
cyclic adjacencies. Diagonals are permitted. -/
def IsC4Map {V : Type*} (G : SimpleGraph V) (f : Fin 4 → V) : Prop :=
  Function.Injective f ∧
    G.Adj (f 0) (f 1) ∧ G.Adj (f 1) (f 2) ∧ G.Adj (f 2) (f 3) ∧ G.Adj (f 3) (f 0)

/-- `G` contains a `C₄` (not necessarily induced). -/
def HasC4 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 4 → V, IsC4Map G f

/-- `G` contains a matching of four edges: eight distinct endpoints, four adjacent pairs. -/
def HasMatching4 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 8 → V, Function.Injective f ∧
    G.Adj (f 0) (f 1) ∧ G.Adj (f 2) (f 3) ∧ G.Adj (f 4) (f 5) ∧ G.Adj (f 6) (f 7)

/-- `S` meets every `C₄` of `G`. -/
def c4Transversal {V : Type*} (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ f : Fin 4 → V, IsC4Map G f → ∃ i : Fin 4, f i ∈ S

/-- `τ₄(G)`: the least size of a vertex set meeting every `C₄` of `G`. -/
noncomputable def tau4 {V : Type*} [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf {k : ℕ | ∃ S : Finset V, c4Transversal G S ∧ S.card = k}

/-- The number of edges of `G` (each unordered edge counted once). -/
noncomputable def edgeCount {V : Type*} [Fintype V] (G : SimpleGraph V) : ℕ := by
  classical
  exact G.edgeFinset.card

/-- `F → (4K₂, C₄)`: every red subgraph `R ≤ F` has a red 4-matching or the blue graph
`F \ R` has a `C₄`. -/
def ArrowsMatching4C4 {V : Type*} (F : SimpleGraph V) : Prop :=
  ∀ R : SimpleGraph V, R ≤ F → HasMatching4 R ∨ HasC4 (F \ R)

/-- The simple graph on `Fin n` with the listed edges (either orientation). -/
def graphOfEdges {n : ℕ} (es : Finset (Fin n × Fin n)) : SimpleGraph (Fin n) :=
  SimpleGraph.fromRel (fun u v => (u, v) ∈ es)

/-- The 4-wheel `W₅`: rim `0 1 2 3`, center `4`. -/
def wheel5 : SimpleGraph (Fin 5) :=
  graphOfEdges {(0,1), (1,2), (2,3), (3,0), (4,0), (4,1), (4,2), (4,3)}

/-- `K₃,₃ − e`: parts `{0,1,2}`, `{3,4,5}`, missing edge `{0,3}`. -/
def k33MinusEdge : SimpleGraph (Fin 6) :=
  graphOfEdges {(0,4), (0,5), (1,3), (1,4), (1,5), (2,3), (2,4), (2,5)}

/-- The octahedron `K₂,₂,₂`: parts `{0,1}`, `{2,3}`, `{4,5}`. -/
def octahedron : SimpleGraph (Fin 6) :=
  graphOfEdges {(0,2), (0,3), (0,4), (0,5), (1,2), (1,3), (1,4), (1,5),
    (2,4), (2,5), (3,4), (3,5)}

/-- The 17-edge upper witness: two copies of `K₃,₃ − e` (on `0..5` and `6..11`) joined by the
bridge `{5,6}`. -/
def F17 : SimpleGraph (Fin 12) :=
  graphOfEdges {(0,4), (0,5), (1,3), (1,4), (1,5), (2,3), (2,4), (2,5),
    (6,10), (6,11), (7,9), (7,10), (7,11), (8,9), (8,10), (8,11), (5,6)}

/-- The connected size-Ramsey number `r̂_c(4K₂, C₄)`: the least number of edges of a connected
graph (on some `Fin n`) arrowing `(4K₂, C₄)`. -/
noncomputable def connectedSizeRamsey : ℕ :=
  sInf {m : ℕ | ∃ (n : ℕ) (F : SimpleGraph (Fin n)),
    F.Connected ∧ edgeCount F = m ∧ ArrowsMatching4C4 F}

end SizeRamsey
