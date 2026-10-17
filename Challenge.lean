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

/-!
# The connected size-Ramsey number of a four-edge matching versus a quadrilateral

`r̂_c(4K₂, C₄)` is the least number of edges of a connected simple graph `F` such that every
red/blue colouring of the edges of `F` contains a red matching of four edges or a blue `C₄`.
Wang–Song–Zhang–Zhang (EJGTA 13 (2025) 163–170, Theorem 1.3) prove `r̂_c(nK₂, C₄) ≤ ⌊(9n−1)/2⌋`
and conjecture equality (Conjecture 1); the case `n = 4`, value `17`, is the target.

Statements of record (all with non-induced copies, graphs on `Fin n`):

* `SizeRamsey.four_mul_tau4_le_edgeCount` (Theorem A): `4 · τ₄(G) ≤ |E(G)|`.
* `SizeRamsey.equality_classification` (Theorem B): for connected `G` with `0 < |E(G)| ≤ 16`,
  equality holds iff `G` is `C₄`, `W₅`, `K₃,₃ − e` or the octahedron.
* `SizeRamsey.connected_transversal_le_three` (Corollary C, transversal half): every connected `G`
  with at most 16 edges has a set of at most three vertices meeting every `C₄`.
* `SizeRamsey.avoiding_coloring_le_sixteen` (Corollary C, colouring half): every connected `F` with
  at most 16 edges has `R ≤ F` with no red 4-matching and no blue `C₄`.
* `SizeRamsey.F17_spec` (Theorem D): the explicit 12-vertex, 17-edge graph is connected and
  arrows `(4K₂, C₄)`.
* `SizeRamsey.connectedSizeRamsey_eq_seventeen`: `r̂_c(4K₂, C₄) = 17`.

Status 2026-10-16: the informal structural argument (docs/PROOF.md) is verified by the aiseminar
review protocol (ordinary theorem, not formally verified); this file states the targets. Proofs are in `Solution.lean`.
The sixth record (transversal half of C) was added 2026-10-17; it was proved in the library from the
start and is registered so that the comparator checks its statement too.
-/

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


/-- Theorem A: the universal quadrilateral-transversal bound. -/
theorem four_mul_tau4_le_edgeCount {n : ℕ} (G : SimpleGraph (Fin n)) :
    4 * tau4 G ≤ edgeCount G := by
  sorry

/-- Theorem B: all connected equality cases through sixteen edges. -/
theorem equality_classification {n : ℕ} (G : SimpleGraph (Fin n))
    (hconn : G.Connected) (hpos : 0 < edgeCount G) (hle : edgeCount G ≤ 16) :
    4 * tau4 G = edgeCount G ↔
      Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨ Nonempty (G ≃g wheel5) ∨
      Nonempty (G ≃g k33MinusEdge) ∨ Nonempty (G ≃g octahedron) := by
  sorry

/-- Corollary C (transversal half): every small connected host has a quadrilateral-transversal of
at most three vertices. -/
theorem connected_transversal_le_three {n : ℕ} (G : SimpleGraph (Fin n))
    (hconn : G.Connected) (hle : edgeCount G ≤ 16) :
    ∃ S : Finset (Fin n), c4Transversal G S ∧ S.card ≤ 3 := by
  sorry

/-- Corollary C (colouring half): an avoiding colouring for every small connected host. -/
theorem avoiding_coloring_le_sixteen {n : ℕ} (F : SimpleGraph (Fin n))
    (hconn : F.Connected) (hle : edgeCount F ≤ 16) :
    ∃ R : SimpleGraph (Fin n), R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  sorry

/-- Theorem D: the explicit seventeen-edge upper witness. -/
theorem F17_spec : F17.Connected ∧ edgeCount F17 = 17 ∧ ArrowsMatching4C4 F17 := by
  sorry

/-- The connected size-Ramsey number of `(4K₂, C₄)` is `17`. -/
theorem connectedSizeRamsey_eq_seventeen : connectedSizeRamsey = 17 := by
  sorry

end SizeRamsey
