<!-- astra: model=gpt-6-astra effort=high status=completed thread=01a146d3-707f-7022-a8cd-9065bbed9a9d job=20261016T182704_workflow-size-ramsey-r-c-4k2-c4-17 -->

Status check performed 2026-10-16. The target remains **provisionally an UNKNOWN FINITE VALUE**, with the upper bound verified and no resolution located in this search. Confidence that this is still open: **0.80**, conditional on inspecting the recent adjacent computational papers and the correction.

Verified primary-source facts:

- Wang–Song–Zhang–Zhang, *EJGTA* **13(1)** (2025), 163–170, DOI **10.5614/ejgta.2025.13.1.11**, Theorem 1.3 proves
  \[
  \widehat r_c(nK_2,C_4)\le \lfloor(9n-1)/2\rfloor.
  \]
  Conjecture 1 asserts equality for every positive integer \(n\). Their construction uses copies of \(K_{3,3}-e\), joined by added edges. Thus the stated 17-edge witness is correct. **Beware search-engine OCR:** one extracted page incorrectly displayed ceiling symbols; the PDF extraction gives floors, consistent with the construction. [Journal PDF](https://www.ejgta.org/index.php/ejgta/article/download/2224/pdf_324), [arXiv:2205.03965](https://arxiv.org/abs/2205.03965).
- McKay’s primary catalogue explicitly lists **8,037,472 connected simple graphs with 16 edges**. Its adjacent disconnected/no-isolates table has **12,334,829**, so these must not be conflated. The catalogue states these graph families can be generated using `geng`. This verifies the published count, **not completeness of an independently performed computation or a Lean proof**. [McKay catalogue](https://users.cecs.anu.edu.au/~bdm/data/graphs.html).
- Rahadjeng–Baskoro–Assiyatun’s 2017 article is *Proceedings—Mathematical Sciences* **127**, 787–792, DOI **10.1007/s12044-017-0366-z**. Its accessible abstract confirms that it determines the \(3K_2,C_4\) case. The primary publisher’s change history explicitly states that **Theorem 2.3 was incorrect**. [Original article](https://link.springer.com/article/10.1007/s12044-017-0366-z).
- The correction is *Proceedings—Mathematical Sciences* **128**, article 15 (2018), DOI **10.1007/s12044-018-0375-6**, publisher date 22 March 2018. **I could not obtain the corrected theorem text**: Springer gives a subscription preview and attempted IAS mirrors failed. Therefore I have not independently verified the specific value 13 or whether the correction affects the matching–\(C_4\) statement. Do not mark this part of G0 complete. [Correction](https://link.springer.com/article/10.1007/s12044-018-0375-6).

Recent adjacent work that G0 must inspect:

1. Tomasz Dzido, “Hybrid reinforcement learning and classical graph checking approach for restricted and connected size Ramsey numbers of \(3K_2\) and cycles,” *Procedia Computer Science* **270** (2025), 881–890, DOI **10.1016/j.procs.2025.09.208**. Publisher abstract claims new exact values, using reinforcement learning and Nauty verification. **Only abstract inspected; exact scope, completeness claims and artifacts unverified.** [Publisher page](https://www.sciencedirect.com/science/article/pii/S1877050925028789).
2. Dzido, “Computational approaches to restricted and connected size Ramsey numbers for \(2K_2\) and cycles,” same volume, 2799–2807, DOI **10.1016/j.procs.2025.09.402**. Same caveat. [Publisher page](https://www.sciencedirect.com/science/article/pii/S1877050925030753).
3. Dzido, “A note on the restricted size Ramsey number for \(2K_2\) and all cycles,” *Australasian Journal of Combinatorics* **95(2)** (2026), 298–306. Full PDF inspected: this is the **restricted** size parameter, minimizing edges on exactly \(r(G,H)\) vertices; it does **not** settle our connected \(4K_2,C_4\) target. [Primary PDF](https://ajc.maths.uq.edu.au/pdf/95/ajc_v95_p298.pdf).

Suggested status sentence:

> What appears to remain unknown is exactly whether every connected finite simple graph with at most 16 edges admits an edge colouring containing neither a red four-edge matching nor a blue 4-cycle; a positive answer, together with the known 17-edge construction, establishes \(\widehat r_c(4K_2,C_4)=17\).

Search terminology included: “connected size Ramsey”, “matching versus cycle”, `4K2 C4`, `C_4 17`, paper title/arXiv ID, 2025/2026, and correction DOI. These searches found no \(4K_2,C_4\) resolution. **Repository/artifact discovery remains incomplete**; lack of a search hit is not a novelty certificate.

For correctness benchmarking, either obtain and audit the correction before relying on \(n=3\), or first use \(n=2\) with an independent elementary proof/enumeration of value 8. The 2025 papers make this an active nearby area, so “quiet, untouched problem” would be unsupported.

No repository writes; no additional subagents used by this literature subagent.

The census is mathematically certifiable, but a straightforward augmentation-closure certificate could be substantially larger than the host-colouring certificates. The reduced census and formal replay must be benchmarked before treating Palomar as feasible.

**Proved reductions**

1. An arrowing host has at least eight vertices: otherwise colouring every edge red avoids a four-edge matching.
2. A minimum-edge connected arrowing host has minimum degree at least two. Delete a leaf; any avoiding colouring of the remaining connected graph extends by colouring the pendant edge blue.
3. If such a host has \(8\le n\le16\) and fewer than sixteen edges, add missing edges on the same vertex set until it has sixteen edges. This preserves connectedness, minimum degree, and arrowing. There are enough missing edges because \(\binom n2\ge28\). **This is the argument needed to combine a minimum-degree filter with an exact sixteen-edge census; pendant extension alone does not justify that combination.**
4. Every connected \(m\)-edge, \(n\)-vertex graph has a vertex set of size at most \(m-n+1\) meeting every cycle. Choose a spanning tree and one endpoint from each non-tree edge. Deleting these vertices leaves a subgraph of the tree. Consequently, every sixteen-edge host with \(n\ge14\) has the desired three-vertex \(C_4\)-transversal.

Thus the genuinely unresolved lower-bound census can be restricted to

\[
8\le n\le13,\qquad |E|=16,\qquad \delta\ge2,\qquad G\text{ connected}.
\]

The filtered count is **unmeasured**. The published 8,037,472 is a conservative full-census number, not the size of the resulting computation.

For the proposed transversal lemma, the same \(8\le n\le13\) range contains every possible counterexample. Leaf removal preserves the minimum transversal size. For \(n\le6\), delete at most three vertices to leave at most three. For \(n=7\) and \(m\le16\), the complement has at least five edges, hence some vertex \(x\) has two non-neighbours \(y,z\). Retain \(x,y,z,w\), with any fourth vertex \(w\); the induced graph has \(d(x)\le1\), so it has no \(C_4\). Delete the remaining three vertices. These are proofs, not computational observations.

**Upper bound without a large truth table**

Let \(H=K_{3,3}-e\). It arrows \((2K_2,C_4)\):

- If the red edges contain no two disjoint edges, they are pairwise intersecting.
- In a bipartite graph, any pairwise-intersecting family of edges has a common endpoint. Otherwise two red edges sharing \(v\), together with an edge avoiding \(v\), force a triangle.
- For every vertex \(v\), \(H-v\) contains a \(C_4\): it is \(K_{2,3}\) or \(K_{2,3}-e\).
- Therefore a colouring without a red two-edge matching has a blue \(C_4\).

Two vertex-disjoint copies of \(H\), joined by a bridge, have twelve vertices and seventeen edges. In the absence of a blue \(C_4\), each copy contributes a red two-edge matching; together these form a red four-edge matching. The bridge colour is immaterial. This is a small formal proof; a 256-colouring check of \(H\) is a fallback.

**Complete augmentation certificate**

A particularly simple, independently verifiable specification uses representative lists \(S_0,\ldots,S_{16}\), beginning with \(S_0=\{K_1\}\). From a connected representative \(H\), permit:

- adding any absent edge between existing vertices;
- adding one new vertex adjacent to any existing vertex.

For **every** permitted augmentation of every representative in \(S_m\), the coverage certificate supplies an index in \(S_{m+1}\) and an explicit vertex permutation establishing isomorphism.

Completeness follows by induction: a connected graph with a cycle has a non-bridge edge whose deletion leaves a connected predecessor; a connected acyclic graph with an edge has a leaf whose deletion gives a predecessor. Duplicate representatives are harmless. Canonical labelling need not be trusted or formalized: it is only a searcher convenience, while the verifier checks the supplied permutations.

A list assigning each output graph *one* predecessor is insufficient. That proves reachability of listed graphs, not coverage of missing graphs. The certificate must close **all parent/augmentation choices**, or prove a sound pruning rule for omitted choices.

Automorphism-orbit compression is possible, but then every omitted augmentation must have an explicit, checked automorphism carrying it to a covered augmentation. Do not trust computed orbit counts.

McKay’s primary table gives 1,867,871 connected fifteen-edge graphs and 8,037,472 connected sixteen-edge graphs. [McKay graph data](https://users.cecs.anu.edu.au/~bdm/data/graphs.html), accessed 2026-10-16. At the last layer, a fifteen-edge representative on \(k\) vertices has

\[
\binom{k}{2}-15+k
\]

augmentations, at most 121 for \(k\le16\). This yields a conservative bound of 226,012,391 closure records at that layer alone. At approximately 12–20 bytes per target/permutation record, the naive certificate can exceed the 500 MiB checkout limit by several times. This is an upper bound, not a measured size; reduced coverage, orbit compression, and structural pruning must be measured.

`geng -c -d2 n 16:16` for \(n=8,\ldots,13\), with pinned version and checked command semantics, is an appropriate production searcher. A second independent augmentation implementation provides substantial ordinary computer-assisted evidence. **Neither nauty provenance, matching counts, nor hashes make its output a Lean completeness proof.** Lean needs a proved-complete generator, the verified closure certificate above, or a different proved coverage mechanism.

**Lean statements and checker**

Use `SimpleGraph (Fin n)` and make all copies non-induced.

Define `HasMatching4 R` by an injective map from eight vertices whose four specified pairs are adjacent. Define `HasC4 B` by an injective map from four vertices with the four cyclic adjacencies. For \(R\le F\), define blue adjacency by
\[
B(u,v)\iff F(u,v)\land\neg R(u,v).
\]

Then the target statements are:

\[
\forall n,F,\quad F.\mathrm{Connected}\land |E(F)|\le16
\Longrightarrow
\exists R\le F,\ \neg\mathrm{HasMatching4}(R)\land
\neg\mathrm{HasC4}(F\setminus R),
\]

and the explicit twelve-vertex upper witness has seventeen edges, is connected, and satisfies
\[
\forall R\le F,\quad
\mathrm{HasMatching4}(R)\lor\mathrm{HasC4}(F\setminus R).
\]

For each host, give a sixteen-bit red-edge mask. A separately written checker:

1. checks the host encoding and canonical edge ordering;
2. checks every four-subset of its sixteen edges for a red matching—at most \(\binom{16}{4}=1820\) choices;
3. checks blue \(C_4\)-freeness, preferably using the equivalent condition that every distinct vertex pair has at most one common blue neighbour.

A transversal certificate instead contains at most three vertex indices. Prove once that colouring every edge incident with the selected vertices red gives red matching number at most three; then the individual check only verifies that the remaining graph has no \(C_4\).

Prove the Boolean checker’s soundness once and use kernel `decide` on its concrete input, rather than asking `decide` to search for a colouring or quantify over all colourings.

**Kernel-cost judgement**

No per-host kernel timings have been measured, so none should be asserted. For the full 8,037,472 hosts, illustrative serial replay times are:

| Measured time per host | Total host checks |
|---:|---:|
| 1 ms | 2.23 hours |
| 10 ms | 22.3 hours |
| 100 ms | 223 hours |
| 1 s | 93 days |

These exclude coverage verification, elaboration, and independent NanoDa replay. They demonstrate why neither “eight million is easy” nor “eight million can never be kernel-replayed” is justified without measurement.

Build first: the checker-soundness theorem, a packed certificate decoder, and batches of 1, 10, 100, and 1,000 diverse hosts. Measure kernel time, peak memory, source/olean size, and NanoDa replay. Separately benchmark a complete small augmentation-closure certificate; colouring-check speed does not predict coverage cost.

My execution estimate is 2–5 person-days for reduction statements and a working per-host checker prototype; a further 5–15 for trustworthy formal augmentation coverage is plausible but uncertain. A short structural proof would offer a much more credible Palomar endpoint than the uncompressed full census. A census can still produce a rigorous ordinary computer-assisted result if formal replay fails; that must be a separately approved outcome.

I used no additional subagents; I was the delegated coverage/Lean auditor.

I find no mathematical gap in the proposed proof of
\[
\tau_{C_4}(G)\le \lfloor |E(G)|/4\rfloor
\]
or the connected equality classification through sixteen edges. This is an independently checked **proof attempt**, pending a fully written proof and repository review protocol.

The steps requiring explicit justification are:

- Removing edges in no \(C_4\) preserves \(\tau_{C_4}\). For equality when \(4\mid m\), even one such edge is impossible.
- In the mixed-degree reduction, write \(N(v)=\{u,a,b\}\), \(N(u)=\{v,t\}\). If \(t=a\) or \(b\), the requirement that \(uv\) lie in a \(C_4\) forces a chorded square. Therefore \(a,b,t\) are distinct. Each component of \(G-\{u,v\}\) needs at least two attachment edges, since otherwise its sole attachment is a bridge. With three attachments there is only one component.
- Equality makes all three attachment vertices degree two in the remaining graph. The inductive list therefore leaves only \(C_4\). Its vertices \(a,b\) must be opposite: if adjacent, they have no common neighbour, and having both \(va,vb\) on squares would force \(t\) adjacent to both, impossible. This reconstructs \(K_{3,3}-e\).
- For a degree-four deletion yielding two components, each receives exactly two attachment neighbours. An optimal transversal containing one specified attachment vertex in each component blocks every new square through the deleted vertex.
- The simpler \(K_{3,3}-e\) extension argument sent by the transversal agent is sound: after the indicated two deletions, the new vertex has one neighbour in each old bipartition class, so a square through it would require an old length-two path between opposite classes.
- In the cubic equality case, twelve edges and eight vertices are the only possibility. Reduction about a chordless square leaves another square, and cubicity makes the cross edges a perfect matching. Every mixed square uses an adjacent pair of vertices of the first square. Selecting one first-square vertex and the matched image of its opposite hits every square.

Consequently, the classification excludes a connected sixteen-edge graph with \(\tau_{C_4}=4\), proving the requested three-vertex transversal statement if the written induction follows these steps.

Audit confidence: **0.94**. No additional subagents used.

**Proof attempt:** every connected simple graph with at most 16 edges has a vertex set of size at most three meeting every \(C_4\). I found a complete-looking structural argument. It needs adversarial review; the census should be suspended while it is checked.

The stronger induction is:

1. Every finite simple graph satisfies \(4\tau_4(G)\le |E(G)|\).
2. Among connected graphs with at most 16 edges, equality occurs only for:
   - \(C_4\): four edges, \(\tau_4=1\);
   - the four-wheel \(W_5\) and \(K_{3,3}-e\): eight edges, \(\tau_4=2\);
   - the octahedron \(K_{2,2,2}\): twelve edges, \(\tau_4=3\).

In particular, no connected 16-edge equality case exists.

For the universal inequality, discard edges belonging to no \(C_4\); this preserves \(\tau_4\). Work componentwise in the remaining square-supported graph.

- A vertex of degree at least four can be deleted at cost one transversal vertex and at least four edges.
- In a mixed degree-two/degree-three component, choose adjacent vertices \(u,v\) of degrees two and three. Delete \(v\), then discard the remaining edge at \(u\), which has become a leaf. Cost: one vertex, at least four edges.
- A component of degree two throughout is \(C_4\).
- In a cubic component containing a chordless square \(a b c d a\), delete \(a,c\), then discard the two remaining leaf edges at \(b,d\). Cost: two vertices, eight edges.
- For a chorded square in a cubic component, its diagonal endpoints have all three neighbors inside the diamond. Delete a tip; the remaining triangle attaches to the rest only at its other tip, so none of its three edges belongs to a \(C_4\). Deleting the tip and discarding that triangle removes six edges at cost one vertex. This also handles \(K_4\).

Equality forces every reduction to be tight, and all residual components to be equality cases. Strong induction through 16 edges gives the stated classification:

- Degree at least five is impossible in equality.
- In the degree-four reduction, every residual component receives at least two neighbors of the removed vertex, since every original edge belongs to a square. If there are two components, there are two attachments in each. Each listed equality graph has an optimal transversal containing any prescribed vertex. Choose one attachment in each optimal transversal: all new squares are hit without increasing the total transversal size, contradicting equality. Thus the residual graph is connected.
- Adding a degree-four vertex to \(C_4\) gives \(W_5\). Adding one to \(W_5\), while retaining maximum degree four, gives the octahedron.
- Adding a degree-four vertex \(v\) to \(K_{3,3}-e\) still admits a two-vertex transversal. Write its bipartition as \(A,B\), with missing edge \(a_0b_0\). If the four attachments split \(3+1\), delete two vertices from the three-attachment part. If they split \(2+2\), delete an attached vertex of \(A\setminus\{a_0\}\) and one of \(B\setminus\{b_0\}\). The old remainder is square-free. The remaining neighbors of \(v\) lie one in each part, so no length-two old path joins them and no square uses \(v\).
- Adding a degree-four vertex to the octahedron gives seven vertices. Retain the new vertex, its two nonneighbors, and any fourth vertex. The new vertex has degree at most one in this four-set, so it contains no square. Hence three deletions suffice.
- In the degree-three/degree-two reduction, tightness forces the three surviving attachment vertices to be distinct and of degree two in the residual graph. The edge through the deleted degree-two vertex forces two of those attachment vertices to be adjacent. Among the smaller equality cases, only \(C_4\) has adjacent degree-two vertices. The other new edge must also belong to a square, forcing all attachments into this same \(C_4\). The only square-supported reconstruction is \(K_{3,3}-e\).
- A connected cubic equality graph within the bound must have twelve edges and eight vertices. The chorded-square reduction is strict. In the chordless reduction the remainder must be a \(C_4\), so the original graph consists of two disjoint squares joined by a perfect matching. Label their vertices using that matching. Cross-squares correspond to edges common to two cyclic orders on four labels. Their intersection is either a square or two disjoint edges, and has a two-vertex cover \(\{a,c\}\). Delete vertex \(a\) from the first square and the vertex matched to \(c\) from the second. This hits both original squares and every cross-square, giving \(\tau_4\le2\), contradicting equality.

The coloring implication is immediate: color every edge incident to the three-vertex transversal red, and everything else blue. Blue has no square, while each edge in a red matching consumes a distinct transversal vertex.

**Upper witness:** \(K_{3,3}-e\to(2K_2,C_4)\). A red graph without a two-edge matching has pairwise-intersecting edges. In a bipartite graph such an edge family is a star. Deleting its center from \(K_{3,3}-e\) leaves a square. Thus two vertex-disjoint copies joined by a bridge give the 17-edge upper bound.

**Exact read-only observations:** I independently decoded graph6 and enumerated square vertex masks and candidate transversal subsets.

- `geng -c -d4 -D4 8 16:16`: six graphs; all had \(\tau_4=3\).
- `geng -q -c -d2 n m:m`, over \(4\le n\le m\), for \(m=4,8,12\): respectively 1, 22, and 1,624 hosts. Equality hosts were exactly the four graphs listed above.
- All 15 ways to add a four-neighbor vertex to \(K_{3,3}-e\) admitted a two-vertex transversal.

These checks took fractions of a second. **No artifacts or scripts were retained**, consistent with the no-write instruction; these are pilot observations, not certificate-backed repository evidence. The structural proof above does not depend on enumeration.

I used no further subagents; I was the independently delegated structural-proof agent.

## 0. The two questions and the statement

**What mathematical uncertainty does the computation reduce?** Whether every connected simple graph with at most 16 edges admits a colouring with neither a red four-edge matching nor a blue \(C_4\).

**If it succeeds, what new mathematical statement will we know?** Together with the known upper construction,
\[
\widehat r_c(4K_2,C_4)=17.
\]
An independently verified arrowing host with at most 16 edges would instead refute the published conjecture.

**Recommendation: suspend the large census while reviewing the structural proof below.** We found a complete-looking proof of the proposed three-vertex transversal lemma. An independent adversarial pass found no gap. Its current repository label should be **PROOF_ATTEMPT**, not VERIFIED: this session does not satisfy the full promotion protocol.

Write \(\tau_4(G)\) for the minimum number of vertices meeting every—not necessarily induced—\(C_4\). The proposed stronger statement is:

> Every finite simple graph satisfies \(4\tau_4(G)\le |E(G)|\). Among connected graphs with \(0<|E(G)|\le16\), equality occurs only for \(C_4\), the four-wheel \(W_5\), \(K_{3,3}-e\), and the octahedron \(K_{2,2,2}\).

Their edge counts are respectively \(4,8,8,12\). Thus a connected graph with at most 16 edges has \(\tau_4\le3\).

No repository files were written. The small checks reported below were exploratory observations; no retained certificate supports a status promotion.

## 1. Status check

**Checked 2026-10-16; novelty gate remains incomplete.**

Wang–Song–Zhang–Zhang’s Theorem 1.3 gives
\[
\widehat r_c(nK_2,C_4)\le\left\lfloor(9n-1)/2\right\rfloor,
\]
and Conjecture 1 asserts equality. The construction uses copies of \(K_{3,3}-e\). These statements were verified in the primary paper. [EJGTA 13 (2025), DOI 10.5614/ejgta.2025.13.1.11](https://www.ejgta.org/index.php/ejgta/article/download/2224/pdf_324), [arXiv:2205.03965](https://arxiv.org/abs/2205.03965).

McKay’s catalogue explicitly lists **8,037,472 connected simple graphs with 16 edges**. This verifies the published count, not completeness of a future computation. [McKay’s graph catalogue](https://users.cecs.anu.edu.au/~bdm/data/graphs.html).

The 2017 Rahadjeng–Baskoro–Assiyatun abstract confirms that it treats the \(3K_2,C_4\) case. However, the publisher records an incorrect Theorem 2.3, and we could not retrieve the corrected theorem text. **Do not mark the correction audit complete or use the claimed value 13 as an audited benchmark yet.** [Original article](https://link.springer.com/article/10.1007/s12044-017-0366-z), [2018 correction](https://link.springer.com/article/10.1007/s12044-018-0375-6).

G0 must also inspect:

- Dzido’s 2025 computational paper on connected/restricted \(3K_2\) versus cycles; only its abstract was accessible in this check. [DOI 10.1016/j.procs.2025.09.208](https://www.sciencedirect.com/science/article/pii/S1877050925028789).
- The corresponding \(2K_2\) computational paper and any associated code or data. [DOI 10.1016/j.procs.2025.09.402](https://www.sciencedirect.com/science/article/pii/S1877050925030753).
- Literature on “quadrilateral transversal”, “\(C_4\) vertex deletion”, and edge bounds for cycle transversals, prompted by the proof below.

The inspected 2026 restricted-size paper concerns a different parameter and does not settle this target. [AJC 95 (2026), 298–306](https://ajc.maths.uq.edu.au/pdf/95/ajc_v95_p298.pdf).

> **What appears to remain unknown is exactly whether every connected finite simple graph with at most 16 edges admits an edge colouring containing neither a red four-edge matching nor a blue 4-cycle.**

Classification: **UNKNOWN FINITE VALUE**, provisionally; confidence **0.80** that it remains unpublished. Our transversal argument is **OUR PROPOSED NEW CONTRIBUTION**, with novelty unestablished. Searches found no resolution, but the correction, recent computational papers, and repository/artifact search remain outstanding.

## 2. Mathematics first

### A. Universal transversal bound — proof attempt

We prove
\[
4\tau_4(G)\le m,\qquad m=|E(G)|,
\]
by induction on \(m\).

Deleting edges belonging to no \(C_4\) preserves \(\tau_4\). Discard them and isolated vertices. Work componentwise; every remaining vertex has degree at least two.

1. **A vertex of degree at least four.** Delete it, apply induction, and add that vertex to the transversal. This costs one vertex and removes at least four edges.

2. **A component with degrees two and three.** There are adjacent vertices \(u,v\) with degrees two and three. Delete \(v\); \(u\) becomes a leaf, so its remaining edge belongs to no square and can be discarded. Again, one transversal vertex accounts for four removed edges.

3. **A component of degree two throughout.** Since every edge belongs to a square, this component is \(C_4\).

4. **A cubic component with a chordless square \(abcd a\).** Delete opposite vertices \(a,c\), removing six edges. Vertices \(b,d\) become leaves; discard their remaining two distinct edges. Two transversal vertices account for eight removed edges.

5. **A cubic component with a chorded square.** If it is a diamond, the diagonal endpoints have all their neighbours inside it. Delete a tip. The remaining triangle attaches to the rest only through the other tip, so none of its edges belongs to a square. Delete those three edges too: six edges removed for one transversal vertex. The \(K_4\) case works the same way.

These cases exhaust the possibilities.

A useful strengthening of the last observation: **in any subcubic graph, a chorded square gives a strict reduction of at least five edges for one transversal vertex.**

### B. Equality through sixteen edges — proof attempt

Suppose \(G\) is connected, \(m=4k\le16\), and \(\tau_4(G)=k\). Strong induction will classify it.

Equality forces:

- every edge to belong to a square;
- maximum degree at most four;
- every residual component in a tight reduction to attain equality itself.

The last assertion follows from additivity of \(\tau_4\) over components and the universal bound. In particular, each residual component with edges has edge count divisible by four.

The proposed inductive list is
\[
C_4,\quad W_5,\quad K_{3,3}-e,\quad K_{2,2,2}.
\]
Each has an optimal transversal containing any specified vertex.

**Case 1: a degree-four vertex \(v\).**

Let \(H=G-v\). Equality requires \(\tau_4(H)=k-1\). There are no isolated vertices in \(H\), because \(G\) has minimum degree at least two.

Every component of \(H\) receives at least two neighbours of \(v\); a sole attachment would be a bridge, impossible because every edge of \(G\) lies in a square.

If \(H\) has two components, each receives exactly two attachments. In each component choose an optimal transversal containing one attachment vertex. These transversals also hit every square through \(v\), contradicting \(\tau_4(G)=k\). Consequently \(H\) is connected.

Its possibilities are now small:

- \(H=C_4\): adding \(v\) gives \(W_5\).
- \(H=W_5\): avoiding degree five forces \(v\) to join the four rim vertices, giving the octahedron.
- \(H=K_{3,3}-e\): adding any degree-four vertex still leaves a two-vertex transversal. To see this, write the old bipartition as \(A,B\), with missing edge \(a_0b_0\).
  - For attachment split \(3+1\), delete two vertices from the three-attachment side.
  - For split \(2+2\), delete an attached vertex in \(A\setminus\{a_0\}\) and an attached vertex in \(B\setminus\{b_0\}\).
  
  The old remainder is square-free. The new vertex has one surviving neighbour in each old part, and no old length-two path joins opposite parts. Thus no square uses the new vertex.
- \(H=K_{2,2,2}\): the extension has seven vertices. Retain \(v\), its two non-neighbours, and any fourth vertex. In this four-set \(v\) has degree at most one, so there is no square. Three deletions suffice.

**Case 2: maximum degree three, with adjacent degree-three and degree-two vertices.**

Write
\[
N(v)=\{u,a,b\},\qquad N(u)=\{v,t\}.
\]
Delete \(v,u\), removing four edges.

The vertices \(a,b,t\) are distinct: if \(t=a\) or \(b\), the requirement that \(uv\) belong to a square produces a chorded square, whose reduction is strict.

Each residual component requires at least two attachments, otherwise there is a bridge. There are only three attachments, so the residual graph is connected. Equality forces all three attachment vertices to have residual degree two.

Of the smaller equality graphs, only \(C_4\) has three degree-two vertices. In that square, \(a,b\) must be opposite; otherwise the requirement that both \(va,vb\) belong to squares cannot be met. The reconstruction is precisely \(K_{3,3}-e\).

**Case 3: cubic.**

Since \(m\) is divisible by both three and four, the only positive possibility within the bound is \(m=12\), hence eight vertices.

A chorded square gives a strict reduction. Around a chordless square, the tight eight-edge reduction leaves another \(C_4\). Cubicity forces the original graph to consist of two squares joined by a perfect matching.

Choose a vertex \(a\) of the first square and the vertex of the second square matched to the opposite vertex \(c\). These two vertices hit both original squares. Every other square uses two matching edges and an adjacent pair in the first square; that pair contains \(a\) or \(c\). Thus they hit every square, contradicting \(\tau_4=3\).

**Case 4: degree two throughout.** The graph is \(C_4\).

This completes the proposed classification. In particular, there is no connected equality case with sixteen edges.

### C. Ramsey consequence and upper witness

For connected \(G\) with \(m\le16\), the argument gives a transversal \(S\) with \(|S|\le3\). Colour edges incident with \(S\) red and all other edges blue. Blue contains no square; a red matching uses distinct vertices of \(S\), so has at most three edges.

For the upper bound, let \(H=K_{3,3}-e\). A red edge family without two disjoint edges is pairwise intersecting. In a bipartite graph such a family is a star. Deleting its centre from \(H\) leaves a square, necessarily blue. Therefore
\[
H\to(2K_2,C_4).
\]
Two vertex-disjoint copies joined by a bridge give the twelve-vertex, seventeen-edge upper witness.

**Assessment:** I find no gap in this argument. The independent coverage/Lean agent adversarially checked it and likewise found none. Nevertheless, require a written claim packet, a fresh proof reconstruction, and the repository’s review sequence before promotion.

## 3. Laptop tests

Claude should first run `make test`, open the required journal, and record the two mathematical questions. Use exact arithmetic throughout. **Aggregate experimental cap: four laptop core-hours**, excluding implementation time.

| Test | Exact inputs and purpose | Required output and measurements | Cap |
|---|---|---|---|
| **1. Known-value check** | All connected hosts with at most seven edges, plus \(K_{3,3}-e\). Reproduce \(\widehat r_c(2K_2,C_4)=8\). | Avoiding colourings for smaller hosts; independent check of all 256 colourings of the upper block; searcher/verifier agreement. | 15 min |
| **2. Equality audit** | Connected minimum-degree-two hosts with \(m=4,8,12\), \(4\le n\le m\), using `geng -q -c -d2 n m:m`. Compute \(\tau_4\). | Equality representatives and independently checked transversal/non-transversal results; expected list exactly the four graphs above. | 30 min |
| **3. Stratified sixteen-edge pilot** | At most 4,096 hosts from orders \(8,\ldots,13\), minimum degree two. Stratify by order, presence of bridges, and square counts \(0,1\!-\!4,5\!-\!12,\ge13\). Fixed seed `20261016`; record sampling procedure and stratum sizes. | Frequency of \(\tau_4\le3\); smallest transversal distribution; SAT and direct-search agreement; retain every anomalous host. | 60 min |
| **4. Cost benchmark** | Same pilot, with generation, decoding, transversal search, general colouring search, and independent verification timed separately. | Mean/p50/p95/max time; peak RSS; bytes per certificate; stratum-weighted projection. Benchmark in-process solving, not only process startup. | 60 min |
| **5. Lean feasibility** | Structural lemma prototypes; upper block; certificate batches of 1, 10, 100, 1,000 hosts; a complete small augmentation certificate. | Kernel time, peak memory, checkout/olean size, allowed-axiom audit, NanoDa replay. Separate coverage cost from colouring cost. | 75 min machine time; two person-days implementation |

For Test 3, use a bounded streaming sample or pinned `geng` residue classes; do not call its prefix a random sample. If population counts are unavailable within the cap, report stratum-specific rates and conservative projections.

Exploratory checks in this session found:

- \(1,22,1{,}624\) connected minimum-degree-two hosts at \(m=4,8,12\), with exactly the proposed equality cases.
- Six connected four-regular eight-vertex graphs; all had \(\tau_4=3\).
- All fifteen degree-four extensions of \(K_{3,3}-e\) had \(\tau_4\le2\).

These were unarchived read-only checks, **not reproducible repository evidence or production benchmarks**.

## 4. Encoding, searcher, verifier, and certificates

This is the fallback census specification and the diagnostic implementation for the pilot.

**Safe host reduction.** A minimum-edge connected arrowing host has minimum degree at least two: a leaf edge can always be coloured blue after solving the smaller graph. It has at least eight vertices, because otherwise all-red avoids a four-edge matching.

If it has fewer than sixteen edges, add missing edges **on the same vertices** until it has sixteen. This preserves minimum degree, connectedness, and arrowing. This is the justification for combining the exact-edge and minimum-degree filters; pendant extension alone does not justify that combination.

Finally, a connected \(m\)-edge, \(n\)-vertex graph has a cycle transversal of size at most \(m-n+1\): choose one endpoint of each non-tree edge of a spanning tree. Thus at \(m=16\), orders \(n\ge14\) already have a three-vertex transversal.

The unresolved fallback census is therefore
\[
8\le n\le13,\qquad m=16,\qquad \delta\ge2,\qquad G\text{ connected}.
\]
**Its count has not been measured.**

**Searcher.** Order the sixteen edges lexicographically and use a Boolean \(r_e\) for each edge:

- For each four-edge matching \(M\), add \(\bigvee_{e\in M}\neg r_e\).
- For each square \(Q\), add \(\bigvee_{e\in Q}r_e\).

SAT is an avoiding colouring. First try a three-vertex transversal; otherwise solve this formula. A complete \(2^{16}\)-assignment search is the bounded fallback.

Vertex relabelling preserves the problem. **Colour swapping is invalid.** No further symmetry constraints are needed.

**Certificate.** Each record contains the host, its deterministic edge order, and either:

- a sixteen-bit red-edge mask; or
- at most three vertex indices forming a transversal.

For reduced hosts, either witness fits in two packed bytes before framing. Full-census graph6 plus two-byte colour masks is roughly 217 MB before indexes and metadata, using the conservative 25-byte host bound. Coverage certificates are additional.

**Independent verifier.** Implement without importing searcher cycle or matching routines. It reads only the certificate and checks:

1. Host simplicity and edge ordering.
2. Absence of a red four-edge matching, directly over at most \(\binom{16}{4}=1820\) edge subsets.
3. Blue square-freeness using the independent characterization: every pair of distinct vertices has at most one common blue neighbour.
4. For transversal records, the size bound and square-freeness after deletion.

Any UNSAT report triggers independent enumeration of all 65,536 colourings of that host. Do not accumulate DRAT for this problem.

**Coverage.** `geng -c -d2 n 16:16` is a suitable searcher. Its output is not, by itself, a Lean completeness proof.

A certifiable augmentation construction starts with \(S_0=\{K_1\}\). From each connected representative, allow:

- adding any missing edge;
- adding a new pendant vertex at any existing vertex.

For **every** augmentation of **every** representative in \(S_m\), supply an explicit isomorphism to an entry in \(S_{m+1}\). Completeness follows by deleting a non-bridge edge from a cyclic connected graph, or a leaf from a tree.

Checking one predecessor per output proves only reachability, not coverage. Intermediate layers must not be restricted to minimum degree two without a separate completeness theorem.

A second independently written enumeration is valuable for an ordinary computer-assisted proof. Lean requires the proved-complete generator or checked augmentation closure; matching counts and hashes do not replace it.

## 5. One brief iteration

**Primary branch: structural proof survives.**

Allocate at most three person-days to Claude’s full write-up and fresh Astra reviews:

- **Adversary:** attack the equality induction, especially residual components and degree-two attachments.
- **Independent prover:** reconstruct the transversal result without reading this proof.
- **Novelty checker:** search for the universal bound, equality classification, and an already published consequence for \(4K_2,C_4\).

Then proceed directly to formalization. **No cluster census is needed.**

**Second branch: a specific proof gap survives.**

Retain the universal bound if sound and isolate the unresolved equality configurations. Generate those configurations first. Reconsider a reduced census only if this gives a finite, measured, certifiable task. Stop after the single iteration if the only outcome is an unbounded formal-coverage project.

**Third branch: a pilot reports a counterexample.**

Verify it immediately:

- \(\tau_4>3\) refutes the proposed structural lemma only.
- No avoiding colouring refutes the Ramsey conjecture.

If rates are ten times slower than projected, permit one implementation correction within the existing cap. Do not compensate automatically with cluster time.

## 6. Conditional cluster deployment

**Current recommendation: zero cluster hours.** The following becomes active only after G2 rejects or cannot complete the structural route and Ben approves G3.

Job prefix: **`sr4c4_`**.

Use immutable, indexed host chunks, targeting about five minutes of measured work per task and no more than 10,000 hosts per chunk. One CPU per task; memory request initially 1 GB, increased only from measured RSS. Bound concurrency to eight workers on node1 and six on node2, subject to allocation.

Let \(N_s\) be stratum counts and \(t_s\) the measured total processing seconds per host:
\[
H_1=\frac{T_{\rm generation}+T_{\rm coverage}+\sum_sN_st_s}{3600}.
\]
Laptop-to-node1 conversion is an explicit uncertainty, to be calibrated by the first small deployment batch.

For orientation only, processing all 8,037,472 hosts costs:

| Total seconds per host | Core-hours, excluding generation and coverage |
|---:|---:|
| 0.001 | 2.23 |
| 0.01 | 22.3 |
| 0.1 | 223 |
| 1 | 2,233 |

These are arithmetic scenarios, **not measurements**. Replace the full count with the measured reduced count.

Initial deployment cap: **100 node1-equivalent core-hours**, accounting node2 at 0.27 equivalent per physical core-hour; shared-storage cap **10 GB**. Any larger request returns to Ben with measured justification.

Use node-local `/scratch` for temporary solver files. Keep checked certificates, immutable manifests, and coverage artifacts on shared storage. Use atomic chunk claims, transactional output renames, checked `.done` markers, and restartable jobs. A `.done` marker requires independent verification.

Stop on the first independently verified arrowing host, any coverage discrepancy, budget exhaustion, or unexplained verifier disagreement. Incomplete chunks remain incomplete; timeouts establish nothing.

## 7. Verification and Lean plan

Use `SimpleGraph (Fin n)`, with non-induced copies.

Define:

- `HasMatching4 R` by an injective map from eight vertices with four specified adjacent pairs.
- `HasC4 B` by an injective map from four vertices with cyclic adjacencies.
- Blue adjacency for \(R\le F\) by \(F.Adj\,u\,v\land\neg R.Adj\,u\,v\).

The lower theorem is:
\[
\forall n\,\forall F,\quad
F.\mathrm{Connected}\land |E(F)|\le16
\Longrightarrow
\exists R\le F,\ 
\neg\mathrm{HasMatching4}(R)\land
\neg\mathrm{HasC4}(F\setminus R).
\]

The upper theorem exhibits an explicit \(F_{17}:\mathrm{SimpleGraph}(\mathrm{Fin}\ 12)\), proves connectedness and seventeen edges, and proves
\[
\forall R\le F_{17},\quad
\mathrm{HasMatching4}(R)\lor\mathrm{HasC4}(F_{17}\setminus R).
\]

**Preferred endpoint:** formalize the structural transversal proof and its colouring implication. This removes global generation and millions of concrete checks. The upper proof is also structural; its 256-colouring block check is only a fallback.

Estimate **10–20 person-days** for the complete structural formalization, including correspondence and replay, with substantial uncertainty about graph-deletion bookkeeping. Build the deletion/reduction lemmas first.

**Fallback per-host endpoint:** prove the Boolean certificate checker sound once, then use kernel `decide` only on supplied witnesses. Do not ask it to search for colourings.

No kernel timings were measured here. At 1, 10, 100 milliseconds per host, eight million checks would take roughly 2.23, 22.3, 223 serial hours respectively; at one second, about 93 days. These exclude coverage, elaboration, and NanoDa replay. Therefore **“eight million can never be kernel-replayed” is not justified**, but neither is a feasibility promise.

Coverage is likely worse. McKay lists 1,867,871 connected fifteen-edge hosts. An uncompressed closure scheme has at most 121 augmentations per such host: up to 226 million records at the last layer alone. At approximately 12–20 bytes each, that conservative bound is several GB. Actual size must be measured.

Palomar gates remain: checkout below 500 MiB; no `native_decide` or `Lean.ofReduceBool`; only permitted axioms; independent NanoDa replay. If the census cannot meet those gates, either find structural compression or obtain Ben’s explicit approval for a non-Palomar computer-assisted result. Do not relabel it formally verified.

## 8. Gates

| Gate | Evidence required | Stop rule and cap | Decision |
|---|---|---|---|
| **G0 — status** | Corrected 2017 theorem; recent computational papers/artifacts; dated novelty search for both target and transversal argument. | One research day, then record exact missing sources. No novelty claim or cluster deployment while materially unresolved. | Astra assesses; Ben chooses continuation. |
| **G1 — laptop** | Tests above, independently checked outputs, cost table, archived environment and manifests. | Four core-hours; stop on any unexplained disagreement. | Claude reports; Astra audits. |
| **G2 — iteration** | Full proof and adversarial review; fresh independent reconstruction; or a precisely bounded fallback. | Three person-days. No second open-ended search redesign. | Ben chooses structural formalization, census fallback, or abandonment. |
| **G3 — deploy** | Measured workload, complete-coverage design, resource projection, viable claimed endpoint. | Initially 100 node1-equivalent hours and 10 GB; explicit Ben approval. | Ben. Skip if structural proof survives. |
| **G4 — claim** | Objections answered, second review, independent proof and applicable reruns; Lean correspondence/build/NanoDa for formal status. | Structural formalization checkpoint after ten person-days; reassess by twenty. Missing evidence means no promotion. | Claude maintains claim status; Ben owns external release. |

Record failed proof steps and failed computational branches in `FAILED_APPROACHES.md`; do not erase them when the route changes. Follow the prescribed claim-status sequence, including its extra adversarial round when consecutive reviews find no substantive objection.

## 9. Risks and what I am least sure about

1. **Novelty/status:** the correction and adjacent computational papers are incompletely inspected. This is the largest unresolved external risk.
2. **Equality-proof bookkeeping:** the argument appears sound, but distinct attachment vertices, strict reductions, and residual connectedness must remain explicit in the written proof.
3. **Formalization effort:** a short mathematical induction can still require substantial graph-library work.
4. **Fallback completeness:** verifying every listed colouring is easy compared with certifying that no host was omitted.
5. **Benchmark bias:** sparse high-order hosts can dominate an unstratified sample and conceal the expensive cases.

I am least sure about **novelty and formalization duration**, rather than the SAT encoding. The structural proof makes a large census a contingency.

I used **three subagents**: an independent transversal investigator, a census/Lean auditor who then adversarially reviewed the new proof, and a literature/status checker. I independently developed and reconciled the structural argument.

CONFIDENCE: 0.91