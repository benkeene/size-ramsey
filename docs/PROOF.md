# Informal proof (PROOF_ATTEMPT, 2026-10-16)

Source: Astra threads of 2026-10-16 (`docs/astra/2026-10-16_workflow_ramsey.md` §2 and the
scaffold plan). Labels are the intended Lean names. Every lemma must state the exact graph and
vertex hypotheses, the residual graph and its vertex type, the exact number of removed edges,
the transversal lifting map, any connectedness or non-isolation claim, and where induction is
applied. Review gate before Theorem B is formalized: adversary → response → reviewer →
independent reconstruction (aiseminar AGENTS.md §3–4).

## Definitions and conventions
τ₄, non-induced C₄, 4-matchings, red/blue as in `SizeRamsey/Defs.lean`. "Square-supported":
every edge lies on a C₄. Two deletion representations: `deleteIncidenceSet v` (keeps the vertex
type, isolates `v`) for edge induction; `induce {v}ᶜ` for residual connectedness and isomorphisms.

## Basic.tau4_minimum_spec
`tau4_le_card`, `exists_transversal_card_eq_tau4`, `tau4_mono`, `tau4_iso`.

## Deletion
* `tau4_delete_non_square_edge`: an edge on no C₄ can be deleted without changing τ₄.
* `tau4_delete_vertices_le`: τ₄(G) ≤ |S| + τ₄(G − S).
* `tau4_delete_leaf_vertex`: deleting a vertex of degree ≤ 1 preserves τ₄.
* exact edge-count formulas (`card_edgeFinset_deleteIncidenceSet` etc.).

## Components.tau4_components
τ₄ and the edge count are additive over connected components (isolated vertices contribute 0).

## Reductions (contracts)
| reduction | residual H | inequalities |
|---|---|---|
| vertex of degree ≥ 4 | G − v | τ(G) ≤ τ(H) + 1, m(H) + 4 ≤ m(G) |
| adjacent degrees 2 and 3 (u, v) | G − {u, v} | τ(G) ≤ τ(H) + 1, m(H) + 4 = m(G) (u becomes a leaf after deleting v) |
| connected, all degrees 2, square-supported | — | the component is C₄ |
| cubic, chordless square abcd | G − {a,b,c,d} | τ(G) ≤ τ(H) + 2, m(H) + 8 = m(G) (b, d keep ≤ 1 neighbour) |
| subcubic, chorded square abcd with diagonal ac | delete tip b, then the 3 sterile edges of triangle acd (it meets the outside only at d) | τ(G) ≤ τ(H) + 1, m(H) + d_G(b) + 3 ≤ m(G), ≥ 5 removed; invalid at Δ = 4 |
A connected square-supported component with degrees in {2,3} is 2-regular, cubic, or has an
adjacent 2/3 pair.

## Universal.four_mul_tau4_le_edgeCount (Theorem A)
Strong induction on |E|: delete unsupported edges; otherwise pick a component with an edge and
apply a reduction.

## Equality (Theorem B)
Tightness: `equality_square_supported`, `equality_max_degree_le_four`,
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
  only inductive equality graph with three degree-2 vertices is C₄; a, b opposite; with residual
  cycle a,t,b,s,a the reconstruction has bipartition {v,t,s} ⊔ {u,a,b} and missing edge su,
  i.e. K₃,₃ − e.
* `equality_cubic_impossible`: m = 12, n = 8; delete all four vertices of a chordless square;
  residual C₄; cross edges a perfect matching μ; a mixed square crosses an even number of times and
  not four (consecutive matching edges at a vertex are impossible), so exactly twice, with one
  internal edge in each square; the square through an internal edge at c contains μ(c); hence
  {a, μ(c)} with a, c opposite hits every square: τ₄ ≤ 2, contradiction.
* `equality_two_regular_case`: the component is C₄.

## Coloring (Corollary C)
`connected_transversal_le_three` (a set of AT MOST three vertices; K₁, K₂ have no 3-subset) from A
and B (τ₄ = 4 forces m = 16, excluded by B);
`avoiding_coloring_of_transversal`: edges at S red, rest blue; a red matching injects into S.

## Upper (Theorem D)
A pairwise-intersecting edge family in a bipartite graph is a star (empty family handled);
deleting any vertex of K₃,₃ − e leaves a square; hence K₃,₃ − e → (2K₂, C₄); two copies joined by
a bridge give a red 4-matching with eight distinct endpoints. Bridge colour irrelevant.

## Endpoint
`connectedSizeRamsey_eq_seventeen` from C and D (proved in Solution.lean).
