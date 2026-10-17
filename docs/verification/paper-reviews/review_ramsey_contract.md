# Contract review: paper/main.tex (untracked, 507 lines), 2026-10-17

Read-only review. Authorities: docs/PROOF.md (Definitions..Endpoint), Challenge.lean, SizeRamsey/Coloring.lean,
CORRESPONDENCE.md §1-8, §13, SizeRamsey/NOTES.md, Reductions/Equality*/Tightness/Upper.lean, formalization.yaml,
docs/STATUS_CHECK.md, and the AMT01 PDF (tau.ac.il/~nogaa/PDFS/amt4.pdf, Thm 1.5 text read via pdftotext).

## 1. Theorem surface (labels)
mainthm A thm:A, B thm:B, C thm:C (i C:trans, ii C:col), D thm:D, E thm:E; Lemma 2.1 lem:components;
Lemma 3.1 lem:deletion; 3.2 lem:offsquare; 3.3 lem:reductions (a-e); 3.4 lem:structure (i-iii);
Lemma 4.1 lem:tight (i-v); 4.2 lem:cut; 4.3 lem:small; 4.4 lem:extension; Prop 4.5 prop:deg4; 4.6 prop:mixed;
4.7 prop:cubic; Lemma 5.1 lem:colouring; 5.2 lem:star; 5.3 lem:k33arrow (cites WYBAS15 Thm 2.6); Remark 5.4 rem:bridge.
Clause-by-clause against Lean (no drift found):
- Conventions: square = sequence of 4 distinct vertices with 4 cyclic adjacencies, chords allowed (= IsC4Map,
  injective map); 4K2 copy = 4 edges with 8 distinct endpoints, extra edges allowed (= HasMatching4); tau4 = attained
  min (eq:tau; Lean sInf, attained via Finset.univ); connected includes >=1 vertex (= Mathlib Connected);
  isomorphism of whole graphs (= `≃g`). Colouring = partition of E(F) (= R ≤ F, blue F \ R).
- A: "every graph" (finite, vertex set may be empty) = `four_mul_tau4_le_edgeCount` on Fin n (n=0 allowed). Equal.
- B: connected, 1 ≤ |E| ≤ 16, iff, isomorphic to C4/W5/K33-e/Oct = `equality_classification` (0 < edgeCount, ≤ 16,
  iff, Nonempty ≃g). Equal.
- C(i) = `connected_transversal_le_three` (generic Fintype V, card ≤ 3); C(ii) = `avoiding_coloring_le_sixteen`. Equal;
  Section 6 and Table 2 correctly say C(i) is not a statement of record.
- D: bridge b2a0'. With a_i=i, b_i=3+i (Lean parts {0,1,2},{3,4,5}, missing {0,3}), b2 = vertex 5 (degree 3 in its
  copy) and a0' = vertex 6 = vertex 0 of copy 2 (degree 2). Connected, 17 edges, arrows = `F17_spec`. Equal.
- E: min over connected F (eq:rc), nonempty by D = sInf over graphs on Fin n for all n. Equal for finite graphs.
- Remark rem:bridge: explicitly "not part of" the formal verification; Section 6 Scope repeats it. OK.

## 2. Proof inferences (all checked; mapped to clauses/calculations)
Table 1 vs PROOF.md reductions: (a) D=X={v}, ≥4 edges; (b) D={u,v}, X={v}, 2+3-1=4; (c) component C4, X one
vertex; (d) chordless square, degrees 3, X={a,c}, 12-4=8; (e) Δ≤3, chord ac, X={b}, d(b)+3 ≥ 5. All match PROOF.md
and the Lean statements (mixed_reduction, cubic_chordless_reduction, subcubic_chord_reduction; Lean uses `erase`
keeping isolated vertices, paper uses induced G-D, equivalent for counts and squares). The "why X suffices"
arguments are complete on the page (for (e) the a/c symmetry is valid: hypotheses invariant under abcd -> cbad).
Tightness (i)-(v): each a one-line comparison with A; (v) uses component additivity + nonnegative summands. OK.
Cut lemma: first-exit argument + square wzpq gives a second edge (wq, qp, pz ≠ wz). OK.
Small graphs: transversals and lower bounds all given on the page; automorphism a_k<->b_k verified (missing edge
maps to itself). Script confirms tau4 = 1,2,2,3, tightness, prescribed-vertex property.
Lemma extension: the 1/2/3-split WLOG via the automorphism, and "a0∉N(z) or b0∈N(z)" normalisation, cover all
4-subsets; the three patterns {a1,a2}, {a1,a2}, {a1,b1} (Lean: {1,2}, {4,5} via symmetric case, {1,4}) each leave ≤3
vertices of degree ≥2. Brute force over all 15 choices of N(z): tau4 ≤ 2 in every case.
Prop deg4: no isolates (deg ≥2, lose ≤1), ≤2 components by cut lemma; two-component case uses the path pqr and the
prescribed vertex x_i; one-component case: C4->W5, W5->Oct (hub not adjacent by Δ≤4), Oct impossible, K33-e
contradicts Lemma extension. Complete.
Prop mixed: a,b,t distinct (t=a gives chord va in square uvba); 3 cut edges, distinct ends, ≥2 per component -> H
connected; a,b,t degree exactly 2 in H; only C4 in T has three degree-2 vertices (degrees listed in §2); a,b
opposite (adjacent case forces triangle abt); reconstruction = K{v,t,s},{u,a,b} minus su. Complete.
Prop cubic: 3|m, 4|m, m ≤ 16 -> m = 12, n = 8, tau = 3; residual of chordless square has tau ≥ 1 so is a chordless
square; perfect matching; mixed squares use exactly two opposite matching edges; {l0, mu(l2)} hits all. Complete.
2-regular -> C4 (Lemma structure (ii)); Thm B assembly; C from A+B (tau=4 forces m=16 tight, list has ≤12 edges);
Lemma colouring; star lemma; K33-e arrow via Lemma small; D gluing; E from C(ii), D. All complete.
Unsupported steps: "Connectedness is clear" (Lemma small; not load-bearing); "A connected 2-regular graph is a cycle
C_k" (Lemma structure (ii); standard, load-bearing, acceptable); "likewise", "by the same argument" (Prop mixed; exact
symmetric repeats, fine).

## 3. Explanatory and bibliographic sentences
TRUE (per audit): EF84 Thm 3 r̂(nK2,C4)=4n => rc ≥ 4n; RBA17 Lemma 2.4 rc(3K2,C4)=13; RBA18 concerns the claw result
(restricted to n ≥ 4), value 13 stands; WSZZ Thm 1.3 and Conj. 1, ⌊35/2⌋ = 17; 16 ≤ rc ≤ 17; WYBAS15 Thm 2.6;
4C4 is tight, 16 edges, arrows; Lean toolchain v4.35.0-rc3 and Mathlib rev c55e6e7... (lake-manifest); library
≈3,700 lines (3,728); no native_decide; 25 modules replayed; comparator with nanoda/con-ron (CORRESPONDENCE).
Novelty: only "We are not aware of a prior statement of Theorem B". Acceptable; no stronger claim.

## Findings
R1 BLOCKER (false sentence about the formalization). §6 Definitions: "The graphs of~$\Tfam$ and~$F_{17}$ are explicit
  edge lists". Evidence: Challenge.lean uses `SimpleGraph.cycleGraph 4` (Mathlib) for C4; only wheel5, k33MinusEdge,
  octahedron, F17 are `graphOfEdges` lists (CORRESPONDENCE §5). Repair: "C4 is Mathlib's cycleGraph 4; W5, K33-e, the
  octahedron and F17 are explicit edge lists, labelled as ... (W5: rim r_i = i, hub h = 4; K33-e: a_i = i, b_i = 3+i;
  octahedron parts {0,1},{2,3},{4,5}; second copy of F17 shifted by 6)".
R2 BLOCKER (literally false explanatory sentence). §3.1 opening: "Around a square whose vertices have degree three,
  every vertex has only one edge leaving the square, which is what lets two opposite corners, or one vertex of a
  chord, cover...". For a chorded square (reduction (e)) a and c have no edge leaving. Repair: "at most one edge".
R3 MAJOR (attribution incomplete / hidden step). §1: "it can be derived from ... [AMT01, Theorem 1.5], which bounds in
  terms of the number of edges how many vertices are needed to meet all cycles of a graph of maximum degree three,
  together with the deletion of vertices of degree at least four." AMT Thm 1.5 assumes K4 ⊄ G and gives
  a(G) ≥ |V| − |E|/4 − c/4 with c = number of components in the family F (trees of triangles and K̇4's). Without the
  K4 hypothesis the described bound is false (K4: fvs 2 > 6/4). The derivation needs, besides deleting degree ≥4
  vertices, the check that K4 (tau4=1) and F(t,k) components (tau4 ≤ k ≤ t+2k−1 = ⌊|E|/4⌋) satisfy 4tau4 ≤ |E|.
  The claim is true after that check, but not "together with the deletion" alone. Repair: "...of a K4-free graph of
  maximum degree three, up to an additive term for an explicit family of exceptional components; with the deletion of
  vertices of degree at least four and a direct check of K4 and those components it yields Theorem A."
R4 MINOR. §6 Definitions: "The formal statements concern simple graphs on $\{0,\dots,n-1\}$" — the row-4 theorem
  `connected_transversal_le_three` is stated for any finite vertex type. Repair: add "(the library theorem for C(i)
  is stated for an arbitrary finite vertex type)".
R5 MINOR (unsupported). §1 and rem:bridge: "This host is the case $n=4$ of the construction of WSZZ" — the audit
  supports "D is the n=4 case of WSZZ's construction" but records no bridge endpoints, and bridge choice changes the
  isomorphism type (CORRESPONDENCE §13 item 6). Repair: "a host of the kind used in the construction of WSZZ" unless
  the bridge in WSZZ is checked to be degree-3 to degree-2.
R6 MINOR. §5.2 opening: "A colouring without a red matching of two edges has all its red edges at one vertex" — false
  in general (red triangle); true for a copy of K33-e. Repair: "A colouring of a copy of K33-e without ...".
R7 MINOR. §4 opening: "every component of the residual graph is again tight. These components are smaller connected
  tight graphs, so by strong induction they belong to the list" — an isolated-vertex component is tight but not in T
  (PROOF.md: C4 ⊔ K1). The propositions do exclude isolates. Repair: "every component with an edge".
R8 MINOR. Abstract: "All statements are formally verified" — rem:bridge's general statement is not. Repair: "The
  results above are formally verified..." or "Theorems A-E, with Theorem D for one fixed host, are...".
R9 MINOR. §1: "a disconnected host may assign each edge of the matching its own component" — heuristic, unsupported
  as explanation; harmless (the difference itself is supported: 12 vs 13 at n = 3). Optionally cite nC4 vs RBA17.
R10 MINOR (draft hygiene). Red markers remain: [affiliation], EFRS78 "[check]" (not in audited sources), [visibility];
  refs.bib RBA18 lacks article number 15; RBA17/EF84/EFRS78/Lean4/Mathlib20 fields marked [check].
R11 MINOR. Lemma structure (ii): "A connected 2-regular graph is a cycle C_k with k ≥ 3" used without proof
  (standard; load-bearing for B's 2-regular case). Acceptable; optionally one clause of justification.

## 4. Arithmetic (python3 -I scratchpad/chk/c.py, brute force)
C4: 4 edges, degrees [2,2,2,2], tau4 1. W5: 8 edges, [3,3,3,3,4], tau4 2. K33-e: 8 edges, [2,2,3,3,3,3], tau4 2.
Oct: 12 edges, all degree 4, tau4 3. All tight, all with the prescribed-vertex property. F17: 17 edges, degrees
[2,3,3,2,3,4,3,3,3,2,3,3] (vertex 5 degree 4 = 3+bridge, vertex 6 degree 3 = 2+bridge), matches CORRESPONDENCE §13.
K33-e + degree-4 vertex: tau4 ≤ 2 for all 15 neighbourhoods. Cubic: m ∈ [1,16] with 3|m, 4|m gives only m = 12,
n = 2m/3 = 8. WSZZ at n=4: ⌊35/2⌋ = 17. tau4(K4) = 1.

## Verdict: ACCEPT_WITH_REPAIRS. Blockers: R1, R2 (both one-phrase repairs). Major: R3. Minor: R4-R11.
The mathematics and the statement contract are correct; no theorem is strengthened or weakened against the Lean
records, and every proof step is on the page.
