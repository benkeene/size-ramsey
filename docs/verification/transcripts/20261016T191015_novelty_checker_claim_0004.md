<!-- astra: model=gpt-6-astra effort=high status=completed thread=01a146fa-fbdc-7791-9b2e-9a3a48bb72ef job=20261016T191015_novelty-claim-0004-status -->

**The 17-edge construction and the \(K_{3,3}-e\) lemma are already known. Theorem A follows from a stronger 2001 theorem. The potentially new contribution is the equality classification B and, through it, the lower bound proving \(\hat r_c(4K_2,C_4)=17\).** I found no prior proof of that exact value, but cannot certify its absence: I retrieved the two Dzido 2025 abstracts and bibliographic information, not their complete texts.

This is a literature/status audit as of **2026-10-16**, not a verification of a supplied proof of B.

Your taxonomy lacks “KNOWN THEOREM.” Below, **KNOWN COMPUTATION†** includes established analytical results; † does not mean computer-assisted.

| Sub-statement | Classification | Novelty assessment | Confidence |
|---|---|---|---:|
| A: \(4\tau_4(G)\le |E(G)|\) | **KNOWN COMPUTATION† — consequence of a known theorem** | Follows from Alon–Mubayi–Thomas (2001), with elementary treatment of their exceptions. An independent proof could be useful, but the inequality is already implicit in established work. | 0.99 |
| B: precisely four connected equality graphs through 16 edges | **UNKNOWN CLASSIFICATION / PROPOSED NEW CONTRIBUTION** | No matching classification located. Existing Ramsey-minimal classifications concern a different property. | 0.75 |
| C: every connected graph through 16 edges has \(\tau_4\le3\) | **PROPOSED NEW CONTRIBUTION**, conditional on B | A handles \(m\le15\); B must exclude equality at \(m=16\). The colouring deduction is elementary. | 0.95 for implication; 0.75 for novelty |
| \(K_{3,3}-e\to(2K_2,C_4)\) | **KNOWN COMPUTATION†** | Explicitly established by 2015, and used by Wang–Song–Zhang–Zhang. | 0.99 |
| D: the two-copy, one-bridge graph arrows \((4K_2,C_4)\) | **KNOWN COMPUTATION†** | Exactly the \(n=4\) instance of the published general construction. | 0.99 |
| E: \(\hat r_c(4K_2,C_4)=17\) | **UNKNOWN FINITE VALUE / PROPOSED NEW CONTRIBUTION** | The verified literature gives \(16\le\hat r_c\le17\). The potentially new part is excluding 16 edges. | 0.80 |

None of A–E is primarily an **OPEN ASYMPTOTIC PROBLEM**. The all-\(n\) conjecture is a broader exact-formula problem; proving its \(n=4\) case would not settle that family.

**Why A is already implicit in known work.** Noga Alon, Dhruv Mubayi and Robin Thomas, “Large induced forests in sparse graphs,” *Journal of Graph Theory* **38** (2001), 113–123, DOI **10.1002/jgt.1028**, prove the relevant stronger result in Theorem 1.5. For subcubic graphs without a \(K_4\) component, the feedback vertex number is at most \((m+c)/4\), where \(c\) counts explicitly described exceptional components. [Author manuscript](https://web.math.princeton.edu/~nalon/PDFS/amt4.pdf).

Here is the deduction for your non-induced \(C_4\) parameter:

- Nonexceptional subcubic components have \(\tau_4\le\mathrm{fvs}\le m/4\).
- Each exceptional component consists of \(t\) triangles and \(k\) copies of \(K_4\) with one edge subdivided, connected by bridges in a tree. It has \(m=4t+8k-1\). One vertex per subdivided \(K_4\) hits every \(C_4\), so \(\tau_4\le k\le m/4\).
- A \(K_4\) component has \(\tau_4=1\le6/4\).
- For arbitrary graphs, repeatedly delete a vertex of degree at least four. Each selected vertex costs one transversal vertex and removes at least four edges. Apply the subcubic bound to the remainder.

Thus **A is a direct corollary**, although I did not locate that corollary explicitly stated under the notation \(\tau_4\). This deduction is my own; the underlying theorem and exceptions are verified. Their Lemma 2.1 also directly gives the stronger feedback-vertex bound \(m/4\) for every triangle-free graph.

**The Ramsey results and correction.**

Paul Erdős and Ralph J. Faudree, “Size Ramsey numbers involving matchings,” *Finite and Infinite Sets*, Colloquia Mathematica Societatis János Bolyai **37** (1984), 247–264, Theorem 3, gives
\[
\hat r(nK_2,C_4)=4n
\]
for the **ordinary**, unrestricted-connectivity size-Ramsey number. Hence the connected \(n=4\) value is at least 16. Confidence: **0.99**. [Original paper](https://users.renyi.hu/~p_erdos/1984-20.pdf).

Sha Wang, Ruyu Song, Yixin Zhang and Yanbo Zhang, “Connected size Ramsey numbers of matchings versus a small path or cycle,” *EJGTA* **13** (2025), 163–170; **arXiv:2205.03965** (2022), DOI **10.5614/ejgta.2025.13.1.11**, prove
\[
\hat r_c(nK_2,C_4)\le\left\lfloor\frac{9n-1}{2}\right\rfloor
\]
in Theorem 1.3 and conjecture equality. Their even-\(n\) construction joins \(n/2\) copies of \(K_{3,3}-e\) using \(n/2-1\) edges. This is precisely D when \(n=4\). Confidence: **0.99**. [Published paper](https://ejgta.org/index.php/ejgta/article/download/2224/pdf_324).

The earlier source is Kristiana Wijaya, Lyra Yulianti, Edy Tri Baskoro, Hilda Assiyatun and Djoko Suprijanto, “All Ramsey \((2K_2,C_4)\)-Minimal Graphs,” *Journal of Algorithms and Computation* **46** (2015), 9–25. Their Theorem 2.6 identifies the six-vertex graph \(F_1\), whose listed edges give \(K_{3,3}-e\). Theorem 2.12 lists **26 Ramsey-minimal graphs**. This establishes the arrowing lemma substantially before the 2022 preprint. Confidence: **0.99**. [Full paper](https://jac.ut.ac.ir/article_7922_651e3bc41b32f240cb33e7a9669c32df.pdf).

For the requested correction, I recovered its complete text from an author-posted copy:

- Rahadjeng–Baskoro–Assiyatun’s original article is in *Proceedings—Mathematical Sciences* **127** (2017), 787–792, DOI **10.1007/s12044-017-0366-z**. Lemma 2.4 states \(\hat r_c(3K_2,C_4)=13\). [Original article, author-posted copy](https://www.academia.edu/86070778/Connected_size_Ramsey_number_for_matchings_vs_small_stars_or_cycles).
- The 2018 publisher correction, **128**, article 15, DOI **10.1007/s12044-018-0375-6**, changes **Theorem 2.3**, restricting the formula \(\hat r_c(nK_2,K_{1,3})=4n-1\) to **\(n\ge4\)**. It concerns the claw, not \(C_4\), and **does not amend the \(n=3\), \(C_4\) value**. Confidence: **0.99**. [Complete correction](https://www.academia.edu/86070774/Publisher_Correction_to_Connected_size_Ramsey_number_for_matchings_vs_small_stars_or_cycles).

**The requested 2025–2026 checks.**

| Source | Verified scope and consequence |
|---|---|
| Tomasz Dzido, *Procedia Computer Science* **270** (2025), **881–890**, DOI **10.1016/j.procs.2025.09.208** | “Hybrid reinforcement learning and classical graph checking approach for restricted and connected size Ramsey numbers of **\(3K_2\)** and cycles.” Announced scope fixes the matching at three edges. [Publisher record](https://www.sciencedirect.com/science/article/pii/S1877050925028789). |
| Tomasz Dzido, same volume, **2799–2807**, DOI **10.1016/j.procs.2025.09.402** | “Computational approaches to restricted and connected size Ramsey numbers for **\(2K_2\)** and cycles.” Its indexed references explicitly cite Wang–Song–Zhang–Zhang. [Publisher record](https://www.sciencedirect.com/science/article/pii/S1877050925030753). |
| Tomasz Dzido, “A note on the restricted size Ramsey number for \(2K_2\) and all cycles,” *Australasian Journal of Combinatorics* **95** (2026), 298–306 | Full text retrieved. Concerns **restricted** size-Ramsey numbers with matching size two; it does not settle the connected \(4K_2\) problem. In particular, its restricted value for \((2K_2,C_4)\) is 9, which must not be confused with the connected value 8. [Full paper](https://ajc.maths.uq.edu.au/pdf/95/ajc_v95_p298.pdf). |

For the two 2025 papers, confidence in their **announced scope is 0.99**. Neither abstract announces \((4K_2,C_4)\) or connected matching–\(C_4\) results beyond matching size three. **I cannot exclude an incidental general theorem or table entry without their full texts.**

Another verified 2025 citation is Fanghua Guo, Yanbo Zhang and Yunqing Zhang, “Matching-star size Ramsey numbers under connectivity constraint,” *JCMCC* **126** (2025), 93–100. Reference 23 cites the published Wang–Song–Zhang–Zhang article; its results concern stars, not \(C_4\). Confidence: **0.99**. [Full paper](https://combinatorialpress.com/article/jcmcc/volume%20126/matching-star-size-ramsey-numbers-under-connectivity-constraint.pdf). I did not verify a **2026** paper citing WSZZ; the 2026 Dzido paper is relevant nearby literature, not a verified such citation.

**Terminology and records that matter.**

- **Induced forests, decycling number, feedback vertex number:** this community supplies the decisive predecessor to A.
- **Square-transversal, quadrilateral transversal, \(C_4\)-vertex deletion, \(C_4\)-subgraph hitting:** definitions require checking. Groshaus–Hell–Klein–Nogueira–Protti, “Cycle transversals in bounded degree graphs,” *Electronic Notes in Discrete Mathematics* **35** (2009), 189–195, and *DMTCS* **13** (2011), study **induced/chordless** cycles. Their polynomial-time subcubic and NP-hard degree-four results do not directly concern your parameter. Confidence: **0.98**. [Journal version](https://dmtcs.episciences.org/533).
- Your problem is equivalently **induced \(\{C_4,K_4-e,K_4\}\)-free vertex deletion**. Merely deleting induced \(C_4\)'s misses chorded squares.
- **Edge transversals** and **cycle isolation** are different: the former delete edges; the latter delete closed neighbourhoods. For example, Borg–Scicluna’s 2025 **arXiv:2510.08361** concerns isolation, not \(\tau_4\). [Preprint](https://arxiv.org/abs/2510.08361).
- For exact \(C_4\) packing, the elementary Erdős–Pósa-type relation is \(\nu_4\le\tau_4\le4\nu_4\). It does not itself yield \(4\tau_4\le m\). Minor models and cycles of arbitrary length also change the problem.
- In **coding/design theory**, bipartite \(C_4\)'s appear as rectangles in incidence matrices or girth-four cycles in Tanner graphs. Your deletion operation removes rows/columns; results about deleting matrix entries, packing blocks, or maximizing a \(C_4\)-free edge set are not interchangeable.

The **2015 list of 26 Ramsey-minimal graphs** is a concrete published record. The Dzido papers are additional computational leads. [McKay’s graph collections](https://users.cecs.anu.edu.au/~bdm/data/graphs.html) provide enumeration inputs, but do not certify B. I found **no verified OEIS entry or House of Graphs record** containing the requested value or equality classification. A complete enumeration through 16 edges must account for connected graphs up to 17 vertices; checking only a small-order graph atlas is insufficient without a reduction.

Finally, C should say **“a set of at most three vertices”**: a literal three-element set does not exist in \(K_1\) or \(K_2\). A and B imply the corrected statement, and colouring incident edges red gives the claimed avoidance colouring.

what appears to remain unknown is exactly: whether the connected value is 16 or 17 in literature not retrieved here, and whether B’s four-graph equality classification—or the weaker exclusion of connected 16-edge graphs with \(\tau_4=4\)—has already been proved; a valid proof of B would establish the proposed value 17, while A, the \(K_{3,3}-e\) lemma, and the 17-edge construction already follow from known work.

CONFIDENCE: 0.82