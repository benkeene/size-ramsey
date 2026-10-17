# Informal proof (lab status VERIFIED as an ordinary theorem, 2026-10-16; not formally verified)

Lean (2026-10-17): proofs complete at commit `a73d95a`; the proof certificate is `Solution.lean`
and its dependency closure (`lake build Solution`: zero `sorry` warnings; the default `lake build`
also shows the deliberate `Challenge.lean` warnings, six since the sixth record of 2026-10-17). Kernel-replayed locally (leanchecker,
25 modules); formal adversary pass 1 and reviewer pass 1 ACCEPT_WITH_FIXES (fixes applied);
independent statement reconstruction done (`CORRESPONDENCE.md` §13); CI comparator passed at
`a988d32` (2026-10-17; con-ron, nanoda and the Lean default kernel accepted; `CORRESPONDENCE.md`
§10). Lab status (aiseminar claim_0004): FORMALLY_VERIFIED, scope as in the final paragraph.

Source: Astra threads of 2026-10-16 (`docs/astra/2026-10-16_workflow_ramsey.md` §2 and the
scaffold plan); revised after the adversary (transcript 20261016T191015) and reviewer
(20261016T191635) passes; an independent reconstruction from the statement alone
(20261016T191015_independent_prover_claim_0004) agrees on every reduction and case. Labels are the intended Lean names. Every lemma must state the exact graph and
vertex hypotheses, the residual graph and its vertex type, the exact number of removed edges,
the transversal lifting map, any connectedness or non-isolation claim, and where induction is
applied. Review record (aiseminar claim_0004): adversary 20261016T191015 (ACCEPT_WITH_FIXES 0.96,
answered); independent reconstruction from the statement alone 20261016T191015 (agrees, 0.99);
reviewer 20261016T191635 (ACCEPT_WITH_FIXES 0.96, applied); confirming reviews 20261016T192131
(ACCEPT_WITH_FIXES 0.97, applied) and 20261016T192456 (ACCEPT 0.98). (Historical, 2026-10-16:
"Lean formalization of Theorem B may now start"; it has since been completed, see the Endpoint
section.) Novelty: A is a corollary of Alon–Mubayi–Thomas (2001); the proposed new content is B
and, through it, the value 17 (novelty of B unestablished; no novelty claim is made;
docs/STATUS_CHECK.md).

## Definitions and conventions
τ₄, non-induced C₄, 4-matchings, red/blue as in `SizeRamsey/Defs.lean`. "Square-supported":
every edge lies on a C₄. Two deletion representations: `deleteIncidenceSet v` (keeps the vertex
type, isolates `v`) for edge induction; `induce {v}ᶜ` for residual connectedness and isomorphisms.

## Induction framework
Theorem A is proved first, for all finite graphs, by strong induction on |E(G)|. Theorem B is then
proved by strong induction on the positive edge count of a connected tight graph (4τ₄(G) = |E(G)|),
the induction hypothesis being applied only to residual components with strictly fewer, positive
edges. "H = G − D" denotes the induced subgraph on V(G) ∖ D (an induced subtype in Lean; the
`deleteIncidenceSet` form with isolated leftover vertices is equivalent for counting since isolated
vertices contribute 0 edges and no squares). Computations in EVIDENCE.md are observations only;
no step below depends on them.

## Basic.tau4_minimum_spec
τ₄(G) = min{|S| : S meets every square}. The set is nonempty (S = V(G)), so the minimum is
attained (`exists_transversal_card_eq_tau4`); any transversal bounds it (`tau4_le_card`); if
G ≤ H (same vertex set) every square of G is one of H, so τ₄(G) ≤ τ₄(H) (`tau4_mono`); an
isomorphism maps squares to squares and transversals to transversals both ways (`tau4_iso`).

## Deletion (with lifting maps)
* `tau4_delete_vertices_le`: for D ⊆ V(G), X ⊆ D meeting every square that meets D, and
  H = G − D (induced on the subtype V ∖ D): τ₄(G) ≤ τ₄(H) + |X|, lifting map T ↦ ι(T) ∪ X with ι
  the subtype inclusion (squares inside H meet T, all others meet D hence X);
  |E(H)| = |E(G)| − Σ_{u∈D} d(u) + e(D). Special case X = D.
* Cut lemma (`component_attachment_card_ge_two`): if G is connected and square-supported,
  ∅ ≠ D ⊊ V(G), and C is a component of G − D, then at least two edges join C to D. Proof:
  connectedness gives one such edge; if it were the only one it would be a bridge; but every
  square-supported edge lies on a cycle and is not a bridge. Edges are counted, not endpoints.
* `tau4_delete_non_square_edge`: if e lies on no square, G and G − e have the same squares, so
  τ₄(G − e) = τ₄(G) and |E| drops by 1.
* `tau4_delete_leaf_vertex`: a vertex of degree ≤ 1 lies on no square; deleting it leaves the
  squares unchanged, so τ₄ is preserved.

## Components.tau4_components
A square lies inside one component, and a transversal is the disjoint union of its traces, so
τ₄(G) = Σ_C τ₄(C) and |E(G)| = Σ_C |E(C)| over components (isolated vertices contribute 0 to both).

## Reductions (contracts)
| reduction | residual H | inequalities |
|---|---|---|
| vertex of degree ≥ 4 | G − v | τ(G) ≤ τ(H) + 1, m(H) + 4 ≤ m(G) |
| adjacent degrees 2 and 3 (u, v) | G − {u, v} | τ(G) ≤ τ(H) + 1, m(H) + 4 = m(G) (u becomes a leaf after deleting v) |
| connected, all degrees 2, square-supported | — | the component is C₄ |
| cubic, chordless square abcd | G − {a,b,c,d}, charged set X = {a,c} | τ(G) ≤ τ(H) + 2, m(H) = m(G) − 8 (after deleting a, c the vertices b, d have ≤ 1 neighbour, so no remaining square meets {b,d}; 4·3 − 4 = 8 edges go) |
| subcubic, square abcd with diagonal ac (one or two chords) | D = {a,b,c}, H = G − D (induced), charged X = {b}: subcubicity gives d(a) = d(c) = 3 with all neighbours inside the square, so after deleting b neither a nor c lies on a square (the triangle acd meets the rest only at d) and X meets every square that meets D | τ(G) ≤ τ(H) + 1, m(H) = m(G) − d_G(b) − 3 exactly, with d_G(b) ≥ 2, so ≥ 5 edges removed; K₄ included; invalid when Δ = 4 |
A connected square-supported component with degrees in {2,3} is 2-regular, cubic, or has an
adjacent 2/3 pair.

## Universal.four_mul_tau4_le_edgeCount (Theorem A)
Strong induction on |E|. Base m = 0: τ₄ = 0. If some edge lies on no square, delete it (τ₄
unchanged, m − 1) and induct. Otherwise every vertex with an edge has degree ≥ 2; pick a component
with an edge: if it has a vertex of degree ≥ 4 or is 2-regular (then it is a C₄ by the reduction
table, removed by component additivity: τ₄ drops by 1, m by 4) or cubic or has an adjacent 2/3 pair,
apply the corresponding reduction (r ≥ 4|X| edges removed) and induct:
4τ(G) ≤ 4τ(H) + 4|X| ≤ m(H) + 4|X| ≤ m(G).

## Equality (Theorem B)
Tightness (G connected, 0 < m ≤ 16, 4τ₄ = m): `equality_square_supported` (deleting an
unsupported edge keeps τ₄ and gives 4τ₄(G) ≤ m − 1, contradicting A for G − e... i.e. contradicting
tightness), `equality_max_degree_le_four` (a vertex of degree d ≥ 5 gives 4τ₄(G) ≤ 4τ₄(G − v) + 4 ≤
m − d + 4 < m), hence minimum degree ≥ 2 by connectedness, positive edge count and square-support;
`equality_residual_components` (from 4τ(G) ≤ 4c + 4τ(H) ≤ 4c + m(H) = m(G) and
Σ_C (m(C) − 4τ(C)) = 0 with nonnegative summands by A; zero-edge components are not fed to B;
note C₄ ⊔ K₁ is tight with an isolate), `square_supported_no_bridge`,
`component_attachment_card_ge_two` (counts edges across the cut; endpoints need not be distinct:
two squares sharing vertex 0 minus {1,2,3}). The reductions exhaust the cases only after
restricting to a component containing an edge and removing unsupported edges.
Small graphs: τ₄(C₄)=1, τ₄(W₅)=2, τ₄(K₃,₃−e)=2, τ₄(K₂,₂,₂)=3, each with an optimal
transversal through any prescribed vertex.
* `equality_degree_four_case`: H = G − v has no isolates (min degree 2), each residual component
  receives ≥ 2 cut edges (all from v, so with distinct endpoints), hence ≤ 2 components; two
  components: a square through v leaves a 3-vertex path in one component and uses both
  attachments there, so optimal transversals through one attachment each (prescribed-vertex
  property) hit everything, contradiction; one component: C₄ (→ W₅), W₅ (→ octahedron),
  K₃,₃ − e (symbolic: A = {a₀,a₁,a₂}, B = {b₀,b₁,b₂}, missing a₀b₀; z with 4 neighbours; split
  3+1 → delete two on the 3-side; 2+2 with b₀ ∈ N(z) → delete A∖{a₀}, symmetric if a₀ ∈ N(z);
  N(z) = {a₁,a₂,b₁,b₂} → delete {a₁,b₁}; each residual is square-free, so τ₄ ≤ 2, contradiction),
  octahedron (impossible: max degree 4).
* `equality_mixed_degree_case` (hypothesis Δ(G) ≤ 3, after the degree-4 case; W₅ shows equality
  alone does not exclude chorded squares): N(v) = {u,a,b}, N(u) = {v,t}; chorded squares excluded
  by the strict subcubic reduction; t = a would force the chord va, so a,b,t distinct; then every
  surviving vertex loses ≤ 1 edge and min degree 2 gives no residual isolates; three cut edges and
  ≥ 2 cut edges per component give one component; residual tightness + non-isolation make it
  square-supported, so attachment vertices have residual degree ≥ 2, = 2 by subcubicity; the
  only inductive equality graph with three degree-2 vertices is C₄; a, b are opposite in it: if
  adjacent they have no common residual neighbour, while square-support of va and vb in G forces
  t to be adjacent to both a and b (the squares through va, vb must close through u–t), impossible
  in that C₄; with residual cycle a,t,b,s,a the reconstruction has bipartition {v,t,s} ⊔ {u,a,b}
  and the single missing cross edge su, i.e. K₃,₃ − e. (The exclusion t = b is symmetric to t = a.)
* `equality_cubic_impossible`: 3 | m (handshake, 3n = 2m), 4 | m (tightness) and 0 < m ≤ 16
  force m = 12, n = 8; delete all four vertices of a chordless square;
  residual C₄; cross edges a perfect matching μ; a mixed square crosses an even number of times and
  not four (consecutive matching edges at a vertex are impossible), so exactly twice, with one
  internal edge in each square; the square through an internal edge at c contains μ(c); hence
  {a, μ(c)} with a, c opposite hits every square: τ₄ ≤ 2, contradiction.
* `equality_two_regular_case`: the component is C₄.
* The four graphs are tight, with the prescribed-vertex property: C₄: any single vertex, and no
  empty set works. W₅ (center h, rim 0123): {h, any rim vertex} is a transversal; deleting any one
  vertex leaves a square (delete h: the rim; delete rim vertex i: the square h, i+1, i+2, i+3, h
  with indices mod 4), so τ₄ = 2. K₃,₃ − e (parts A, B, missing a₀b₀): two vertices of
  one part form a transversal (the remainder is a star plus one vertex, square-free); deleting any
  single vertex leaves K₂,₃ or K₂,₃ − e, which contains a square; so τ₄ = 2 and through any
  prescribed vertex (take its part). Octahedron (parts {0,1},{2,3},{4,5}): a 4-vertex subset meets the parts as 2+2
  (a C₄ between the two parts) or 2+1+1 (a C₄ through the full part and the two singles), so every
  4-subset contains a square and τ₄ ≥ 3; deleting a whole part and one more vertex leaves a path,
  so τ₄ = 3, and the prescribed-vertex property follows by deleting the part containing the
  prescribed vertex plus one more vertex.

## Coloring (Corollary C)
`Proof.connected_transversal_le_three` (a set of AT MOST three vertices; K₁, K₂ have no 3-subset) from A
and B (τ₄ = 4 forces m = 16, excluded by B);
`avoiding_coloring_of_transversal`: edges at S red, rest blue; a red matching injects into S.

## Upper (Theorem D)
Star lemma: in a triangle-free (in particular bipartite) graph, a family of edges with no two
disjoint shares a common vertex unless it is empty: for two distinct intersecting edges xy, xz,
any further edge meeting both but avoiding x would be yz, a triangle; empty and singleton families
are immediate. Hence a red graph without a 2-matching is a star (or empty);
deleting any vertex of K₃,₃ − e leaves a square; hence K₃,₃ − e → (2K₂, C₄); two copies joined by
a bridge give a red 4-matching with eight distinct endpoints. Bridge colour irrelevant.

## Endpoint
`connectedSizeRamsey_eq_seventeen` from C and D: the Lean deduction in Solution.lean is complete
and unconditional. As of commit `a73d95a` all five statements of record then registered are
proved in `Solution.lean`, whose dependency closure contains no `sorry` (`lake build Solution`:
zero `sorry` warnings; only `Challenge.lean` carries the deliberate ones);
`#print axioms` of each is `[propext, Classical.choice, Quot.sound]`, and every built project
module (25) is kernel-replayed by `leanchecker` (`CORRESPONDENCE.md` §10). Since 2026-10-17 both
halves of C are records: the three-vertex transversal `connected_transversal_le_three` is the
sixth statement of record, proved from the library lemma `Proof.connected_transversal_le_three`
(`CORRESPONDENCE.md` §8). D is formalized for the fixed host of
CLAIM.md's D (bridge from vertex 5 of the first copy to vertex 0 of the second); the
endpoint-universal statement is not formalized. Formal adversary pass 1 and reviewer pass 1 are
ACCEPT_WITH_FIXES (fixes applied); the CI comparator passed at `a988d32` (2026-10-17,
https://github.com/benkeene/size-ramsey/actions/runs/39005389761). Lab status (aiseminar
claim_0004, 2026-10-17): FORMALLY_VERIFIED for A, B, C (two declarations), fixed-host D and E.
