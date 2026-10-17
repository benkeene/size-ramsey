# Exposition review: paper/main.tex (rendered main.pdf, 14 pp. at 110 dpi)

Every page was viewed (`ramsey_pages/p-01..14.png`). The comprehension test (step 2) was done from main.tex alone, before opening PROOF.md or Lean (neither was opened afterwards). Log: no overfull or underfull boxes, no warnings.

## A. Rendered pages
1. MAJOR (release blocker). Red draft markers print: "[check]" after [4] (p1, l.66), "[affiliation]" footnote (p1, l.54), "[visibility]" (p14, l.498). Resolve them and delete `\red`.
2. MINOR. Large blank page bottoms: p3 (~8 lines), p4 (~10 lines), p5 (~9 lines; Table 1 could not fit and floated to the top of p6). Try `[htbp]` for tab:reductions, or place the table after the proof. Check p3/p4 after that.
3. MINOR. p7/p8: Lemma 4.1 statement sits at the foot of p7 and its proof starts on p8. This should clear once item 2 is fixed; otherwise add `\needspace` before §4.1.
4. MINOR. p8, proof of Lemma 4.1(v): the inline sum breaks inside the bracket ("∑_C(|E(C)| − / 4τ4(C)) = 0"). Smallest repair: put that sum in a display, or write "the sum over components of |E(C)|−4τ4(C) vanishes".
5. MINOR. p8, Lemma 4.1(i),(ii): the inline chains break after "≤". This is acceptable, but (ii) could become a display.
6. MINOR. Bibliography: [6] (RBA18) has no pages or article number; [7] "The mathlib Community": capitalise "Mathlib" with `{M}`.
7. OK, no repair needed: house profile (11pt Letter, centred title, no date, header with rule, plain title page), link colour #000072 on refs, citations and URL, Table 1 layout (booktabs, rows (a)–(e) linked and aligned), Table 2, the hash break on p13 (seqsplit) and the URL break on p14. No TOC, which is right for 14 pages.

## B. Comprehension test (reader reconstruction; places where I guessed or supplied the reason)
Reconstruction, in brief. Thm A: delete D, charge X⊆D meeting all squares through D. τ grows by ≤|X| and ≥4|X| edges go, so induction closes; edges off squares are free. Square-supported with Δ≤3 means degrees are 2 or 3, which gives (b), (c), or a cubic square with or without a chord, i.e. (e)/(d). This is exhaustive by Lemma 3.4(iii). Tightness forces equality, so the residual components are tight and smaller, and the IH puts them in 𝒯. The cut lemma limits the number of components. All four equality cases and C/D/E reconstruct correctly from the text. The gaps are local:

8. MINOR. §3.1 opening, p5: "a neighbour of degree three can be charged for both". The referent of "both" is unclear (the two deleted vertices? the two square edges?). Repair: "...can be charged for the squares through both vertices".
9. MINOR. Proof of Thm A, l.246: "so that X≠∅" is never used visibly. I had to work out that its job is |E(G−D)|<|E(G)|. Repair: "so that X≠∅ (hence |E(G−D)|<|E(G)|) and".
10. MINOR. Prop 4.6, "The vertices a and b are opposite", l.390: "it is not u". The reader must supply why (N(u)={v,t} and t≠a). Repair: "it is not u, since t≠a,".
11. MINOR. Prop 4.6, l.388: "among the members of 𝒯 only C4 has three such vertices". I searched back to the degree list in §2. Repair: append "(degrees listed in Section 2)".
12. MINOR. Lemma 4.4, l.338: the WLOG ("we may assume ... a0∉N(z) or b0∈N(z)") is not justified. I reconstructed it: if a0∈N(z) and b0∉N(z), the swap gives b0∈N(z). Repair: add "(the swap turns a0∈N(z) into b0∈N(z))".
13. MINOR. Lemma 4.4 case 2, l.342: "the remaining vertices are a0, b_k and z" is elliptical. Repair: "so only a0, b_k and z can have two neighbours".
14. MINOR. Preface to Lemma 4.4, l.329: it does not say what the lemma is for; I found its use only in Prop 4.5. Repair: add "which excludes H≅K33−e in Proposition 4.5".
15. MINOR. "Exact" deletion (intro l.105, §4 opening l.260 "reduction (e) is never exact") is used as a term but defined only implicitly. Repair: in §4 opening, "call a reduction exact if it removes exactly 4|X| edges".
16. MINOR. Lemma 4.1 proof opener, l.276: "Each part compares G with a smaller graph" is false for (iii). Repair: "Parts (i), (ii), (iv), (v) compare...".
17. MINOR. Prop 4.7 assumes (4.1), but the sentence before it (l.395) says the IH is not needed. Repair: drop "satisfying (4.1)" from the statement, or drop the clause "and the induction hypothesis is not needed".
18. MINOR. §5.2 opening, l.440: "A colouring without a red matching of two edges has all its red edges at one vertex" is false as stated (triangle), and the qualification comes only afterwards. Repair: start with "In a bipartite host, ...".

## C. Prose
19. MINOR, inconsistency. The intro (l.105) has "Three facts control how the graph is reassembled"; the §4 opening (l.260) has "Two further facts". Align the counts. The §4 opening otherwise largely repeats the intro's second strategy paragraph; trim the intro paragraph to the mechanism and the case list.
20. MINOR, duplication. Formal scope of Thm C/D is stated three times: intro "Formal verification" (l.107), Remark 5.4 (l.463), §6 "Scope". "F17 is the case n=4 of WSZZ" appears twice (l.93, l.463). Keep one of each, in §6 and l.93.
21. MINOR. Intro l.103: the appositive list "Five local configurations, a vertex..., ..., always provide" is hard to parse. Repair: "Five local configurations (a vertex ..., ...) always provide".
22. MINOR. §2 l.113: "Isomorphisms are isomorphisms of whole graphs, vertices included" is opaque to a graph theorist. Repair: "...; in particular isolated vertices count".
23. MINOR, deletion test. l.121: "Two further conditions organise the whole paper." Delete. l.329: "and it is done by hand" — delete (it reads as a contrast with machine checking).
24. MINOR. §5 opening (l.419) gives a route but no mechanism. Acceptable for a short section; optionally add "a transversal of size three spoils every red 4K2".
25. OK. No internal language outside §6 (no stream, plan, claim, lab or review-pass vocabulary). §6 vocabulary (statement file, comparison tool, kernels) is appropriate there. The Use-of-AI paragraph is proportionate. No hedging. Lettered Theorems A–E are self-contained given the preceding intro paragraphs. The abstract is calibrated: result, mechanism, classification, formalisation.

## D. Source format
26. MINOR. A tie is missing after the plural "Theorems"/"Sections" before \ref: l.83, 107, 109, 419, 472 (twice), 492. Use `Theorems~\ref{thm:A}`, `Sections~\ref{...}`.
27. OK. No `\[ \]` or `\( \)`. Every display ends with `\,.` or `\,,`. There are no manual `\\` in paragraphs and no typed label numbers (only citation locators). Paired formulas use `\quad\mbox{and}\quad`.

## One sentence per section
- §1: The answer is 17. The lower bound comes from τ4≤3 for connected graphs with ≤16 edges, which follows from 4τ4≤|E| and the four equality cases.
- §2: τ4 is additive over components, and deleting a vertex set D removes Σdeg − e(G[D]) edges.
- §3: Every square-supported graph has a deletion that removes at least four edges per charged transversal vertex.
- §4: In a tight graph every deletion is exact and the residue is a union of smaller tight graphs; few attaching edges and transversals through any vertex leave only C4, W5, K33−e and K222.
- §5: Three red stars kill every 4K2 and every blue square below 17 edges, while two joined copies of K33−e force one or the other.
- §6: All five statements are kernel-checked; Thm C(i) and the general bridge of Remark 5.4 are outside the compared statements.

## Verdict: ACCEPT_WITH_REPAIRS
1 MAJOR (draft markers), 22 MINOR; items 7, 25 and 27 needed no repair. The mathematics reads through without gaps a reader cannot close. All repairs are a clause or less, apart from the float placement.
