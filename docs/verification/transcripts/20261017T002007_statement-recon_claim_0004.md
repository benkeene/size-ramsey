<!-- astra: model=gpt-6-astra effort=high status=completed thread=01a14816-b04d-7c53-917e-cddbc076c6c0 job=20261017T002007_independent-formal-statements-r-c-4k2-c4-17-a-e -->

A–C modelling recommendations:

1. Define a C₄ using four pairwise distinct vertices and the four cyclic adjacency assertions. Do not require absent diagonals: K₄ contains a C₄ under the stated convention.
2. Define a transversal `S : Finset V` by requiring every such quadruple to have at least one vertex in `S`.
3. Define
   `τ₄(G) := sInf {k : ℕ | ∃ S : Finset V, S.card = k ∧ IsC4Transversal G S}`.
   With `[Fintype V]`, `Finset.univ` witnesses nonemptiness, including the empty vertex type. Explicitly explain this guard. For a C₄-free graph, `∅` witnesses τ₄ = 0.
4. For B, retain all three hypotheses: connectedness, positive edge count, and edge count at most 16. The conclusion is an equivalence with a disjunction of four `Nonempty (G ≃g H)` assertions. Merely asserting that the listed examples attain equality omits the classification direction.
5. For C, explicitly assert existence of a transversal of cardinality at most three **and** existence of an avoiding colouring. Connected graphs with zero edges are included.
6. A robust four-matching predicate uses `a b : Fin 4 → V` with injectivity of both maps, `∀ i j, a i ≠ b j`, and adjacency of each `a i, b i`. These conditions give exactly eight distinct endpoints without index arithmetic.
7. Use colourings `Sym2 V → Bool`, or colour the edge subtype. A colouring `V → V → Bool` requires symmetry; otherwise it is an incorrect directed model. Values assigned to nonedges are harmless if every monochromatic witness also explicitly requires graph adjacency.

I read no files and consulted no existing formalization. These are semantic recommendations, not an elaboration check.

D–E audit:

- **Bridge endpoints are unspecified and not interchangeable by isomorphism.** In \(K_{3,3}-e\), deficient vertices have degree 2 and the other vertices degree 3. Different endpoint choices can give nonisomorphic bridge graphs. Define `F17 (p q : Fin 6)` and quantify over both endpoints in D. Choosing one fixed pair specializes the informal construction.
- A convenient vertex type is `Fin 2 × Fin 6`. The graph adjacency is
  \[
  (\text{same copy}\land H.Adj\,u.2\,v.2)
  \lor (u=(0,p)\land v=(1,q))
  \lor (u=(1,q)\land v=(0,p)).
  \]
  Include `edgeCount (F17 p q) = 17`, connectedness, and the arrow property in D. The vertex count is fixed by the type; adding its explicit cardinality equality preserves the supplied assertion verbatim.
- **Endpoint independence has a short mathematical explanation:** in a bipartite graph, a set of edges containing no 2-matching is a star (or empty). Deleting any one vertex from \(K_{3,3}-e\) leaves a C₄. Consequently, absence of a blue C₄ forces a red 2-matching inside each copy separately, producing a red 4-matching regardless of the bridge.
- Total colourings `Sym2 V → Bool` are sound: nonedge colours never enter any witness predicate, and every actual edge colouring extends to such a total function. This avoids symmetry side conditions and dependent edge-membership arguments. Every red or blue witness must still explicitly require adjacency in the original graph.
- Define
  `ramseySizes := {m : ℕ | ∃ n : ℕ, ∃ G : SimpleGraph (Fin n), G.Connected ∧ edgeCount G = m ∧ Arrows G}`.
  Then define the number as `sInf ramseySizes`, and state E as
  `ramseySizes.Nonempty ∧ connectedSizeRamsey = 17`.
  This explicitly guards against the empty natural-number infimum. Restriction to `Fin n` represents every finite simple graph up to isomorphism. Including `n = 0` is harmless because Mathlib’s connectedness includes nonemptiness.

No files or existing formalizations consulted. No elaboration performed in this delegated audit.

No identified API blocker in the proposed approach. Recommended syntax:

- `Nat.card ↥(G.edgeSet)` for edge count.
- `Fin 4 ↪ V` and `Fin 8 ↪ V` for the cycle and matching witnesses.
- `Nonempty (G ≃g H)` for isomorphism.
- Structure proofs with explicit introductions:
  ```
  symm := by
    intro a b h
    exact ⟨G.symm h.1, fun hr => h.2 (R.symm hr)⟩
  loopless := by
    intro a h
    exact G.loopless a h.1
  ```

The main semantic precaution is D: universally parameterize the bridge endpoints if the informal construction permits any endpoints. Fixing one particular bridge gives a sufficient witness for E but a potentially weaker reading of D.

An `sInf` over transversal cardinalities has a witness from `Finset.univ`. Explicitly assert nonemptiness of the connected Ramsey witness set alongside its infimum equality. These choices are standard Mathlib syntax, but pinned-version elaboration remains unchecked.

I reconstructed these independently without consulting an existing formalization. I submitted the complete file to `lake env lean --stdin`; it failed at `import Mathlib` with **`unknown module prefix 'Mathlib'`**. Lean v4.35.0-rc3 is available, but the requested Mathlib dependency is unavailable here. **Elaboration is therefore unverified.** The five theorem proofs below are placeholders.

```lean statement=ABCDE
import Mathlib

namespace IndependentStatementRecon

def IsFourCycle {V : Type*} (G : SimpleGraph V)
    (v : Fin 4 ↪ V) : Prop :=
  G.Adj (v 0) (v 1) ∧ G.Adj (v 1) (v 2) ∧
  G.Adj (v 2) (v 3) ∧ G.Adj (v 3) (v 0)

def HasFourCycle {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ v : Fin 4 ↪ V, IsFourCycle G v

def HasFourMatching {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ v : Fin 8 ↪ V,
    G.Adj (v 0) (v 1) ∧ G.Adj (v 2) (v 3) ∧
    G.Adj (v 4) (v 5) ∧ G.Adj (v 6) (v 7)

def IsC4Transversal {V : Type*} (G : SimpleGraph V)
    (S : Finset V) : Prop :=
  ∀ v : Fin 4 ↪ V, IsFourCycle G v → ∃ i : Fin 4, v i ∈ S

noncomputable def tau4 {V : Type*} [Fintype V]
    (G : SimpleGraph V) : ℕ :=
  sInf {k : ℕ | ∃ S : Finset V, S.card = k ∧ IsC4Transversal G S}

noncomputable def edgeCount {V : Type*} (G : SimpleGraph V) : ℕ :=
  Nat.card ↥(G.edgeSet)

def IsRedSubgraph {V : Type*} (G R : SimpleGraph V) : Prop :=
  ∀ u v : V, R.Adj u v → G.Adj u v

def bluePart {V : Type*} (G R : SimpleGraph V) : SimpleGraph V where
  Adj u v := G.Adj u v ∧ ¬ R.Adj u v
  symm := by
    intro u v h
    exact ⟨G.symm h.1, fun hr => h.2 (R.symm hr)⟩
  loopless := by
    intro u h
    exact G.loopless u h.1

def Arrows {V : Type*} (G : SimpleGraph V) : Prop :=
  ∀ R : SimpleGraph V, IsRedSubgraph G R →
    HasFourMatching R ∨ HasFourCycle (bluePart G R)

def HasAvoidingColouring {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ R : SimpleGraph V, IsRedSubgraph G R ∧
    ¬ HasFourMatching R ∧ ¬ HasFourCycle (bluePart G R)

def graphOfRelation {V : Type*} (r : V → V → Prop) : SimpleGraph V where
  Adj u v := u ≠ v ∧ (r u v ∨ r v u)
  symm := by
    intro u v h
    exact ⟨Ne.symm h.1, h.2.elim Or.inr Or.inl⟩
  loopless := by
    intro u h
    exact h.1 rfl

def edgeListGraph (n : ℕ)
    (es : Finset (Fin n × Fin n)) : SimpleGraph (Fin n) :=
  graphOfRelation (fun u v => (u, v) ∈ es)

def C4 : SimpleGraph (Fin 4) :=
  edgeListGraph 4 {(0, 1), (1, 2), (2, 3), (3, 0)}

def W5 : SimpleGraph (Fin 5) :=
  edgeListGraph 5
    {(0, 1), (1, 2), (2, 3), (3, 0), (4, 0), (4, 1), (4, 2), (4, 3)}

-- Parts {0,1,2} and {3,4,5}; the deleted edge is {0,3}.
def K33MinusEdge : SimpleGraph (Fin 6) :=
  edgeListGraph 6
    {(0, 4), (0, 5), (1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5)}

-- Parts {0,1}, {2,3}, {4,5}.
def Octahedron : SimpleGraph (Fin 6) :=
  graphOfRelation (fun u v : Fin 6 => u.val / 2 ≠ v.val / 2)

def F17 (p q : Fin 6) : SimpleGraph (Fin 2 × Fin 6) :=
  graphOfRelation (fun u v : Fin 2 × Fin 6 =>
    (u.1 = v.1 ∧ K33MinusEdge.Adj u.2 v.2) ∨
    (u = (0, p) ∧ v = (1, q)))

def connectedRamseySizes : Set ℕ :=
  {m : ℕ | ∃ n : ℕ, ∃ G : SimpleGraph (Fin n),
    G.Connected ∧ edgeCount G = m ∧ Arrows G}

noncomputable def connectedSizeRamsey : ℕ :=
  sInf connectedRamseySizes

theorem statementA {V : Type*} [Fintype V] (G : SimpleGraph V) :
    4 * tau4 G ≤ edgeCount G := by
  sorry

theorem statementB {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected) (hpos : 0 < edgeCount G)
    (hbound : edgeCount G ≤ 16) :
    (4 * tau4 G = edgeCount G) ↔
      (Nonempty (G ≃g C4) ∨ Nonempty (G ≃g W5) ∨
       Nonempty (G ≃g K33MinusEdge) ∨ Nonempty (G ≃g Octahedron)) := by
  sorry

theorem statementC {V : Type*} [Fintype V] (G : SimpleGraph V)
    (hconn : G.Connected) (hbound : edgeCount G ≤ 16) :
    (∃ S : Finset V, S.card ≤ 3 ∧ IsC4Transversal G S) ∧
      HasAvoidingColouring G := by
  sorry

theorem statementD (p q : Fin 6) :
    Fintype.card (Fin 2 × Fin 6) = 12 ∧
    edgeCount (F17 p q) = 17 ∧
    (F17 p q).Connected ∧ Arrows (F17 p q) := by
  sorry

theorem statementE :
    connectedRamseySizes.Nonempty ∧ connectedSizeRamsey = 17 := by
  sorry

end IndependentStatementRecon
```

1. **Shared graph and subgraph conventions.** A–C quantify over arbitrary vertex types with `[Fintype V]`. Restricting them to `Fin n` would be equivalent up to relabelling but less direct. `edgeCount` counts the unordered edges in `G.edgeSet`, once each. A cycle uses an injection `Fin 4 ↪ V` and four cyclic adjacencies; there are no diagonal restrictions. An induced graph embedding would incorrectly exclude cycles with chords. A matching uses an injection `Fin 8 ↪ V` and four specified edges; additional edges among its vertices are allowed.

2. **A: transversal minimum.** `tau4` is the natural-number infimum of cardinalities of actual finite transversals. This set is nonempty: `Finset.univ` meets every cycle, including vacuously when no cycles exist. Thus this definition never relies on the empty-infimum convention. `Nat.find` would require packaging that existence proof into the definition; `Finset.min` would additionally enumerate candidate cardinalities. Neither changes the intended minimum.

3. **B: equality classification.** All three hypotheses—connectedness, positive edge count, and the upper bound—are retained. The equivalence uses `Nonempty (G ≃g H)`, asserting existence of a graph isomorphism without selecting one. Literal equality would wrongly depend on vertex labels. C₄, W₅, and K₃,₃ minus an edge have explicit edge lists; the octahedron has three explicitly specified independent parts. These definitions avoid ambiguity in library naming conventions.

4. **C: both requested conclusions.** The statement includes an actual transversal of size at most three and an avoiding colouring. A colouring is represented by its red spanning subgraph `R`; the blue edges are exactly the edges of `G` absent from `R`. This represents every red/blue edge colouring. A function on ordered vertex pairs would require symmetry conditions; colouring the edge subtype with `Bool` is equivalent but adds unnecessary membership arguments. Connected graphs with zero edges remain included.

5. **D: bridge endpoints.** The vertex type `Fin 2 × Fin 6` records the two disjoint copies directly. `F17 p q` adds exactly the edge between `(0,p)` and `(1,q)`; symmetry supplies its reverse adjacency. Both endpoint choices are universally quantified. This resolves a genuine ambiguity: endpoints of degree two and degree three in K₃,₃ minus an edge need not yield isomorphic bridge constructions. Choosing fixed endpoints would specialize D. The statement explicitly includes vertex count, edge count, connectedness, and the colouring property.

6. **E: domain and existence guard.** The infimum ranges over edge counts of connected Ramsey graphs on `Fin n`, for every natural number `n`, without an artificial vertex bound. Every finite simple graph has such a labelled representative. Quantifying over arbitrary vertex types inside this set would introduce unnecessary universe issues. The explicit conjunct `connectedRamseySizes.Nonempty` guards against an empty infimum. An `IsLeast` formulation would also work, but would not separately define the requested numerical invariant.

I used **three subagents**: an A–C semantic audit, a D–E construction and minimum audit, and an independent Lean syntax/API audit. None consulted existing formalizations. No mathematical proofs or successful elaboration are claimed.

CONFIDENCE: 0.97