<!-- astra: model=gpt-6-astra effort=high status=completed thread=01a146fa-fbb4-7bc1-9a65-227772c61567 job=20261016T191015_independent-prover-claim-0004 -->

A, B, and D are true. C is true with “at most three vertices.” Literally, C is false for \(K_1\) and \(K_2\), which have no three-element vertex set. This wording issue does not affect the colouring conclusion or E.

Write \(m(G)=|E(G)|\), \(\tau(G)=\tau_4(G)\), and \(H=K_{3,3}-e\). All cycles below have four distinct vertices; chords are allowed.

**Deletion and lifting lemma.** Let \(G\) be a finite simple graph, let \(D\subseteq V(G)\), and suppose \(X\subseteq D\) meets every 4-cycle that intersects \(D\). Set \(R=G-D\). Then
\[
m(R)=m(G)-r,\qquad
r=\sum_{u\in D}d_G(u)-e_G(D),
\]
and the transversal lifting map is
\[
\mathcal L:\ T\longmapsto T\cup X
\]
for every 4-cycle transversal \(T\) of \(R\). Consequently,
\[
\tau(G)\le \tau(R)+|X|.
\]
Indeed, cycles contained in \(R\) meet \(T\), and all other cycles meet \(X\).

Here and below, a directly exhibited transversal \(X\) also gives the lifting map \(\varnothing\mapsto X\) from the specified C4-free residual \(G-X\).

**Subcubic deletion lemma.** Suppose \(\Delta(G)\le3\) and \(Q=abcd a\) is a 4-cycle. One of the following reductions applies.

| Hypotheses | Deleted set \(D\) | Lift set \(X\) | Exact residual edge count |
|---|---|---|---|
| \(Q\) has exactly one chord, say \(ac\) | \(V(Q)\) | \(\{b\}\) | \(m(G)-[1+d_G(b)+d_G(d)]\) |
| \(Q\) has both chords | \(V(Q)\) | \(\{a\}\) | \(m(G)-6\) |
| \(Q\) is chordless and has adjacent vertices \(v,x\) of degrees \(3,2\) | \(\{v,x\}\) | \(\{v\}\) | \(m(G)-4\) |
| Every vertex of \(Q\) has degree \(2\) | \(V(Q)\) | \(\{a\}\) | \(m(G)-4\) |
| \(Q\) is chordless and every vertex has degree \(3\) | \(V(Q)\) | \(\{a,c\}\) | \(m(G)-8\) |

These cases exhaust the possibilities: on a chordless cycle with both degree types, some consecutive pair has different degrees.

For the first row, \(a,c\) have no neighbours outside \(Q\), while \(b,d\) have at most one each. A cycle meeting \(Q\) but avoiding \(b\) would have to use the triangle \(acd\), whose only possible connection to the rest of \(G-b\) is through \(d\). It therefore cannot be a 4-cycle. The five internal edges give the stated deletion count, which is between five and seven.

In the second row, \(Q\) induces an isolated \(K_4\). In the third, every cycle through the degree-two vertex \(x\) also contains \(v\), and the deletion removes \(3+2-1=4\) edges. In the fourth, \(Q\) is a component. In the last, after deleting \(a,c\), the vertices \(b,d\) each have degree one; hence no remaining cycle meets \(Q\). The deletion of all four vertices removes \(12-4=8\) edges. Thus every row has precisely the lifting map asserted by the preceding lemma.

**Proof of A.** Induct on \(m(G)\). If \(G\) has no 4-cycle, use the empty transversal.

If some vertex \(v\) has degree \(d\ge4\), take
\[
R=G-v,\qquad m(R)=m(G)-d,
\qquad \mathcal L(T)=T\cup\{v\}.
\]
The induction hypothesis gives
\[
4\tau(G)\le4\tau(R)+4\le m(G)-d+4\le m(G).
\]

Otherwise apply the subcubic deletion lemma. In every row the number \(r\) of removed edges satisfies \(r\ge4|X|\). Therefore
\[
4\tau(G)\le4\tau(R)+4|X|
\le m(G)-r+4|X|\le m(G).
\]
This proves A.

For the equality analysis, call \(G\) *tight* when \(4\tau(G)=m(G)\).

**Equality lemma.** The following statements hold.

1. Every component of a tight graph is tight.
2. Every edge of a tight graph belongs to a 4-cycle.
3. A connected tight graph with positive edge count has minimum degree at least two and maximum degree at most four.
4. If a tight graph undergoes a valid deletion with \(r=4|X|\), its residual is tight.
5. A tight subcubic graph contains no chorded 4-cycle.

For (1), both edge count and transversal number add over components, and A holds for each component.

For (2), if an edge \(f\) belongs to no 4-cycle, then
\[
R=G-f,\qquad m(R)=m(G)-1,\qquad \tau(R)=\tau(G).
\]
The transversal families are identical, so the lifting map is the identity. Applying A to \(R\) contradicts tightness.

The minimum-degree assertion follows from (2). If \(d_G(v)\ge5\), the residual \(G-v\) has \(m(G)-d_G(v)\) edges and the lift \(T\mapsto T\cup\{v\}\) gives
\[
4\tau(G)\le m(G)-d_G(v)+4<m(G).
\]
This proves the maximum-degree assertion.

For (4), equality must hold throughout
\[
m(G)=4\tau(G)\le4\tau(R)+4|X|
\le m(G)-r+4|X|=m(G).
\]
For (5), either chorded reduction in the subcubic lemma removes strictly more than four edges for its one-vertex lift, contradicting tightness.

We will also use this immediate consequence of (2): if \(G\) is connected and tight, every component of \(G-D\) has at least two edges joining it to \(D\). Exactly one such edge would be a bridge.

**The four listed graphs are tight.** Here are explicit checks, including the relevant residual counts.

- \(C_4\) has \(\tau=1\). Deleting one vertex leaves \(P_3\), with two edges.
- \(W_5\) has \(\tau=2\). Deleting its hub leaves \(C_4\), with four edges; deleting a rim vertex leaves \(K_4-e\), with five edges and a 4-cycle. Thus no singleton works. Deleting the hub and any rim vertex leaves \(P_3\), with two edges.
- Label \(H\) by parts
  \[
  \{a_1,a_2,a_3\},\qquad \{b_1,b_2,b_3\},
  \]
  with missing edge \(a_3b_3\). Deleting a degree-two vertex leaves \(K_{2,3}\), with six edges. Deleting a degree-three vertex leaves \(K_{2,3}-e\), with five edges. Both contain a 4-cycle. Any two vertices from the same part form a transversal: their deletion leaves a star, possibly with an isolated vertex, with exactly two or three edges. Hence \(\tau(H)=2\). In particular, every vertex of \(H\) belongs to a minimum transversal.
- In \(K_{2,2,2}\), deleting any two vertices leaves either \(K_{2,2}\), with four edges, or \(K_{2,1,1}\), with five edges. Both contain a 4-cycle. Deleting one whole part and one vertex of another part leaves \(K_{1,2}\), with two edges. Thus its transversal number is three.

Their edge counts are respectively \(4,8,8,12\).

**Proof of B.** We classify connected tight graphs with at most sixteen edges by induction on their edge count. Such a graph \(G\) has
\[
m(G)\in\{4,8,12,16\},
\qquad 2\le\delta(G)\le\Delta(G)\le4.
\]
Every smaller nontrivial tight component is therefore one of the already classified graphs.

First suppose that \(G\) has a vertex \(v\) of degree four. Put
\[
R=G-v,\qquad m(R)=m(G)-4,
\qquad \mathcal L(T)=T\cup\{v\}.
\]
The residual is tight. It has no isolated vertex, since such a vertex would have degree at most one in \(G\). Every component of \(R\) receives at least two of the four edges from \(v\), so \(R\) has at most two components.

If \(m(R)=0\), these observations are impossible.

If \(m(R)=4\), then \(R=C_4\), and \(v\) joins all four vertices. Thus \(G=W_5\).

If \(m(R)=8\), there are three possibilities.

- If \(R=W_5\), its degree-four hub cannot receive another edge. Hence \(v\) joins all four rim vertices, giving \(K_{2,2,2}\).
- If \(R\) consists of two copies of \(C_4\), \(v\) has two neighbours in each. Choose one neighbour \(x\) in the first and one neighbour \(y\) in the second. The set \(\{x,y\}\) meets both original cycles and every cycle through \(v\). Its deletion leaves two copies of \(P_3\), together with \(v\) and its two remaining incident edges: exactly
  \[
  12-3-3=6
  \]
  edges, forming a tree. Thus \(\tau(G)\le2\), contradicting tightness at twelve edges.
- If \(R=H\), the following finite table supplies a two-vertex transversal for every choice of the four neighbours of \(v\).

In the table, \(U=V(H)\setminus N_G(v)\) is the omitted pair. Swapping \(a_1,a_2\), swapping \(b_1,b_2\), and interchanging the two parts reduces all fifteen choices of \(U\) to these five rows.

| Omitted pair \(U\) | Transversal \(X\) | Exact \(m(G-X)\) | Residual structure |
|---|---|---:|---|
| \(\{a_1,a_2\}\) | \(\{b_1,b_2\}\) | 4 | A tree |
| \(\{a_1,b_1\}\) | \(\{a_1,a_2\}\) | 5 | A triangle with two pendant edges |
| \(\{a_3,b_3\}\) | \(\{a_1,b_1\}\) | 5 | A triangle with two pendant edges |
| \(\{a_1,a_3\}\) | \(\{b_1,b_2\}\) | 4 | A triangle with a pendant edge and an isolated vertex |
| \(\{a_1,b_3\}\) | \(\{a_2,b_1\}\) | 5 | A triangle with a pendant path of length two |

Each residual is C4-free. The table can be verified simply by starting with the eight edges \(a_ib_j\), excluding \(a_3b_3\), adding \(vu\) for \(u\notin U\), and removing the edges incident to \(X\). Thus this case also has \(\tau(G)\le2\).

If \(m(R)=12\), the inductive possibilities are
\[
K_{2,2,2},\quad W_5\sqcup C_4,\quad H\sqcup C_4,\quad
C_4\sqcup C_4\sqcup C_4.
\]
The first cannot receive any edge from \(v\), because all its vertices already have degree four. The last has too many components.

In either remaining case write \(R=J\sqcup C\), where \(C=C_4\) and \(J\in\{W_5,H\}\). Each component receives two edges from \(v\). Choose \(p\in N(v)\cap V(J)\), and choose \(z\in N(v)\cap V(C)\).

For \(J=W_5\), let \(h\) be its hub and take \(X=\{h,p,z\}\). The hub cannot be adjacent to \(v\), so \(p\) is a rim vertex. The residual comprises two copies of \(P_3\) and the two remaining edges at \(v\), giving exactly six edges.

For \(J=H\), choose another vertex \(t\) in the same part as \(p\), and take \(X=\{p,t,z\}\). Put
\[
k=|\{p,t\}\cap N(v)|,\qquad
h_0=8-d_H(p)-d_H(t).
\]
Here \(k\in\{1,2\}\), and \(H-\{p,t\}\) is a star, possibly with an isolated vertex, having exactly \(h_0\in\{2,3\}\) edges. The full residual has exactly
\[
h_0+2+(3-k)=h_0+5-k
\]
edges: the star residual, \(C-z=P_3\), and the remaining edges at \(v\).

In both constructions, \(X\) covers the cycles within \(J\) and \(C\). Any cycle through \(v\) lies otherwise in one component and uses both neighbours of \(v\) in that component, so it meets \(p\) or \(z\). Thus \(\tau(G)\le3\), contradicting tightness at sixteen edges. This finishes the degree-four case.

Now suppose \(\Delta(G)\le3\). Choose a 4-cycle \(Q\); by the equality lemma it is chordless.

If all its vertices have degree two, connectedness gives \(G=C_4\).

Suppose next that \(Q\) has adjacent vertices \(v,x\) of degrees three and two. Write the cycle as
\[
v\,x\,y\,z\,v
\]
and let \(w\) be the third neighbour of \(v\). The reduction is
\[
R=G-\{v,x\},\qquad m(R)=m(G)-4,
\qquad \mathcal L(T)=T\cup\{v\}.
\]
Its three attachment edges are \(xy,vz,vw\).

There are no isolated vertices in \(R\). Indeed, an isolated residual vertex would need both \(v\) and \(x\) as neighbours in \(G\), since \(\delta(G)\ge2\). It would then be \(y\), but \(yz\) is an edge of \(R\).

Each component of \(R\) requires at least two attachment edges. There are only three, so \(R\) is connected. By induction and \(\Delta(R)\le3\), it is either \(C_4\) or \(H\). The three attachment endpoints \(y,z,w\) must be distinct and each have degree two in \(R\); otherwise adding the attachment edges would produce degree at least four. Since \(H\) has only two degree-two vertices, \(R=C_4\).

Write this residual cycle as \(y\,p\,q\,r\,y\). The two neighbours of \(v\) in \(R\) are a pair from \(\{p,q,r\}\).

- The pair \(\{p,r\}\) produces \(H\).
- The pairs \(\{p,q\}\) and \(\{q,r\}\) are equivalent by reflection. For \(\{p,q\}\), deleting \(p\) leaves exactly the five-cycle
  \[
  y\,r\,q\,v\,x\,y,
  \]
  with \(8-3=5\) edges. Thus \(\{p\}\) is a transversal, contradicting tightness.

It remains to consider a chordless cycle \(Q=q_0q_1q_2q_3q_0\) whose four vertices all have degree three. Delete all four vertices:
\[
R=G-V(Q),\qquad m(R)=m(G)-8,
\qquad \mathcal L(T)=T\cup\{q_0,q_2\}.
\]
The residual is tight. Exactly four edges join \(Q\) to \(R\), one at each \(q_i\).

The following elementary classification will be useful. Let \(f(q_i)\) be the unique neighbour of \(q_i\) outside \(Q\). A 4-cycle intersecting \(Q\) is exactly one of these types:

- \(Q\) itself;
- three consecutive vertices of \(Q\), together with a common external neighbour of the two endpoints;
- two adjacent vertices \(q_i,q_{i+1}\), together with their distinct external neighbours, provided those external neighbours are adjacent.

There cannot be a cycle using exactly one vertex of \(Q\), because that vertex has only one external neighbour. With exactly two vertices of \(Q\), they must be adjacent; otherwise each would require two external neighbours. This proves the classification.

Since \(m(R)\le8\), its nontrivial components are \(C_4\), \(H\), or two copies of \(C_4\). The wheel is excluded by the degree bound. Isolated residual vertices are also possible.

If \(m(R)=0\), all four attachment edges end at isolated residual vertices. Each such vertex has degree two or three in \(G\). Consequently there are exactly two, each attached to a pair of vertices of \(Q\).

If the pairs are opposite pairs, the graph is \(H\). If they are adjacent pairs, the cycle classification shows that \(Q\) is the only 4-cycle. For example, with external vertices attached to \(\{q_0,q_1\}\) and \(\{q_2,q_3\}\), deleting \(q_0\) leaves a triangle with a pendant path of length two, having exactly \(8-3=5\) edges. Thus this graph is not tight.

If \(m(R)=4\), its nontrivial component is a cycle \(C\). Each vertex of \(C\) can receive at most one attachment edge. There are only two possibilities:

- All four attachments end at \(C\), giving a perfect matching between \(Q\) and \(C\).
- Two end at \(C\), and two end at one isolated residual vertex \(u\).

For the first, let \(r_i=f(q_i)\). The set
\[
X=\{q_0,r_2\}
\]
is a transversal. It meets both original cycles. Every mixed cycle uses an edge of \(Q\); that edge meets \(q_0\) or \(q_2\), and in the latter case the mixed cycle contains \(r_2\). The two selected vertices are nonadjacent and each has degree three, so the residual has exactly
\[
12-3-3=6
\]
edges. It consists of the two broken cycles and the two surviving matching edges. Hence \(\tau(G)\le2\), contrary to tightness.

For the second possibility, the two neighbours of \(u\) on \(Q\) must be opposite, or the edges incident with \(u\) belong to no 4-cycle. The other two vertices of \(Q\) are then also opposite. Their attachment edges to \(C\) cannot lie in a 4-cycle: the mixed-cycle type requires adjacent vertices of \(Q\), and no vertex of \(C\) receives two attachments. This contradicts the equality lemma.

Finally, suppose \(m(R)=8\).

If the nontrivial residual component is \(H\), only its two degree-two vertices can receive attachments. Both must do so, and the remaining two attachment edges end at one isolated residual vertex. But the two degree-two vertices of \(H\) are nonadjacent. The cycle classification therefore shows that neither attachment edge to \(H\) lies in a 4-cycle, a contradiction.

Otherwise \(R\) consists of two cycles \(C_1,C_2\). Each receives exactly two attachments, and there are no isolated residual vertices. For the attachment edges to belong to 4-cycles, each attached pair on \(Q\) must be adjacent, and each corresponding pair in \(C_i\) must also be adjacent. Relabel so that \(C_1\) attaches at \(q_0,q_1\) and \(C_2\) at \(q_2,q_3\).

Choose an unattached vertex \(r\in V(C_1)\), and let \(s\in V(C_2)\) be the vertex attached to \(q_2\). Then
\[
X=\{q_0,r,s\}
\]
meets \(Q,C_1,C_2\), as well as the mixed cycle at each attachment pair. These are all the cycles by the classification. The selected vertices are independent and have degrees \(3,2,3\), so the residual has exactly
\[
16-(3+2+3)=8
\]
edges and is C4-free. Thus \(\tau(G)\le3\), again contradicting tightness.

All possibilities have been exhausted. The only connected tight graphs with at most sixteen edges are
\[
C_4,\quad W_5,\quad K_{3,3}-e,\quad K_{2,2,2}.
\]
Together with the explicit tightness checks, this proves B.

**Corollary C, with the necessary wording correction.** Let \(G\) be connected with at most sixteen edges.

If \(m(G)\le15\), A gives \(\tau(G)\le3\). If \(m(G)=16\), A gives \(\tau(G)\le4\), and equality would make \(G\) a sixteen-edge graph in B’s list. There is no such graph. Hence again \(\tau(G)\le3\).

Choose a transversal \(S\) with \(|S|\le3\). Its C4-free residual is
\[
R=G-S,\qquad
m(R)=m(G)-\sum_{s\in S}d_G(s)+e_G(S).
\]
Colour every edge incident to \(S\) red and every edge of \(R\) blue. A red matching has at most \(|S|\le3\) edges, because its edges must use distinct vertices of \(S\). The blue graph is C4-free.

If \(|V(G)|\ge3\), pad \(S\) to exactly three vertices if necessary. Without this vertex-count hypothesis, the literal three-element-set claim is false.

**Star lemma.** If a triangle-free simple graph has matching number at most one, all its edges share a common vertex, unless it has no edges.

To prove this, one edge is immediate. Otherwise choose two edges \(ab,ac\). Any edge not incident to \(a\) must intersect both and therefore must be \(bc\), which would create a triangle. Thus all edges are incident to \(a\).

**Proof of D.** First prove
\[
H\longrightarrow(2K_2,C_4).
\]
Consider a red/blue colouring of \(H\) with no red matching of two edges. The red graph is bipartite, hence triangle-free. By the star lemma all red edges are incident to one vertex \(u\); if there are no red edges, choose any \(u\).

The residual \(H-u\) is entirely blue. As checked above, it is either

- \(K_{2,3}\), with exactly six edges, when \(d_H(u)=2\); or
- \(K_{2,3}-e\), with exactly five edges, when \(d_H(u)=3\).

Both contain a 4-cycle. Therefore every colouring of \(H\) has a red two-edge matching or a blue 4-cycle.

Now \(F_{17}\) consists of two vertex-disjoint copies \(H_1,H_2\), joined by one bridge. It is connected and has
\[
6+6=12\text{ vertices},\qquad 8+8+1=17\text{ edges}.
\]
Deleting the bridge leaves precisely \(H_1\sqcup H_2\), with sixteen edges.

In any colouring with no blue 4-cycle, each \(H_i\) contains a red matching of two edges. Their union is a red matching of four edges, since the copies are vertex-disjoint. The bridge’s colour and endpoints do not affect this argument. This proves D.

Consequently, C’s colouring conclusion gives the lower bound seventeen for the connected size-Ramsey number, and D gives the matching upper bound. Thus E also follows:
\[
\widehat r_c(4K_2,C_4)=17.
\]

For verification, I independently executed the five extension-table checks above, all 24 perfect matchings between the two four-cycles in the twelve-edge case, and all \(2^8=256\) colourings of \(H\). The checks enumerate four-vertex subsets and cyclic orders to detect 4-cycles, and disjoint edge pairs to detect two-edge matchings. All agreed with the arguments above.

Theorem A — CONFIDENCE: 0.99  
Theorem B — CONFIDENCE: 0.99  
Corollary C — CONFIDENCE: 1.00 in the literal counterexample and the corrected conclusion  
Theorem D — CONFIDENCE: 1.00