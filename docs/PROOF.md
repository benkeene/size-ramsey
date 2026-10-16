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
| subcubic, chorded square | delete a tip, then the 3 sterile triangle edges | τ(G) ≤ τ(H) + 1, m(H) + 5 ≤ m(G) |
A connected square-supported component with degrees in {2,3} is 2-regular, cubic, or has an
adjacent 2/3 pair.

## Universal.four_mul_tau4_le_edgeCount (Theorem A)
Strong induction on |E|: delete unsupported edges; otherwise pick a component with an edge and
apply a reduction.

## Equality (Theorem B)
Tightness: `equality_square_supported`, `equality_max_degree_le_four`,
`equality_residual_components` (every residual component attains equality),
`square_supported_no_bridge`, `component_attachment_card_ge_two` (count edges across the cut).
Small graphs: τ₄(C₄)=1, τ₄(W₅)=2, τ₄(K₃,₃−e)=2, τ₄(K₂,₂,₂)=3, each with an optimal
transversal through any prescribed vertex.
* `equality_degree_four_case`: H = G − v has no isolates, ≤ 2 components; two components give a
  transversal through one attachment each, contradiction; one component is C₄ (→ W₅), W₅ (→
  octahedron), K₃,₃ − e (all 15 four-neighbour extensions have τ₄ ≤ 2, contradiction),
  octahedron (impossible: max degree 4).
* `equality_mixed_degree_case`: N(v) = {u,a,b}, N(u) = {v,t}; chorded squares excluded; a,b,t
  distinct; no residual isolates; residual connected; attachment vertices of residual degree
  exactly 2; residual is C₄; a, b opposite; reconstruction is K₃,₃ − e.
* `equality_cubic_impossible`: m = 12, n = 8; delete a chordless square; residual C₄; cross
  edges a perfect matching; two vertices hit every square.
* `equality_two_regular_case`: the component is C₄.

## Coloring (Corollary C)
`connected_transversal_le_three` from A and B (τ₄ = 4 forces m = 16, excluded by B);
`avoiding_coloring_of_transversal`: edges at S red, rest blue; a red matching injects into S.

## Upper (Theorem D)
A pairwise-intersecting edge family in a bipartite graph is a star (empty family handled);
deleting any vertex of K₃,₃ − e leaves a square; hence K₃,₃ − e → (2K₂, C₄); two copies joined by
a bridge give a red 4-matching with eight distinct endpoints. Bridge colour irrelevant.

## Endpoint
`connectedSizeRamsey_eq_seventeen` from C and D (proved in Solution.lean).
