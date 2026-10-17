# Statement ledger: main.tex

Canonical manuscript: `paper/main.tex` (single file), bibliography `paper/refs.bib`.
Repository revision at start of writing: `82cbe1f` (clean).
Mathematical authority: `docs/PROOF.md` (mathematics only), `Challenge.lean` (statements of
record), `CORRESPONDENCE.md` §1–§8, §13. Literature: `formalization.yaml` `sources:`,
`docs/STATUS_CHECK.md`.

Status vocabulary: DRAFTED (in main.tex), COMPILED (compiles with resolved references),
RENDER-CHECKED (rendered page images inspected).

## Statements

(filled in below, one row per public statement, in manuscript order)

| label | role | depends on | PROOF.md location | Lean name | status |
|---|---|---|---|---|---|
| `lem:components` (Lemma 2.1) | component additivity of tau_4 and edge count | — | "Components.tau4_components" | `Plan.tau4_components`, `Plan.edgeCount_components` | REPAIRED-R1, RENDER-CHECKED |
| `thm:A` (Theorem A) | principal: 4 tau_4 <= edges | 3.1–3.4, 2.1 | "Universal.four_mul_tau4_le_edgeCount" | `SizeRamsey.four_mul_tau4_le_edgeCount` (record) | REPAIRED-R1, RENDER-CHECKED |
| `lem:deletion` (Lemma 3.1) | lifting T -> T u X | — | "Deletion", first bullet | `Plan.tau4_delete_vertices_le`, `Plan.tau4_erase_lift` | REPAIRED-R1, RENDER-CHECKED |
| `lem:offsquare` (Lemma 3.2) | edges off squares | — | "Deletion", third bullet | `Plan.tau4_delete_non_square_edge` | REPAIRED-R1, RENDER-CHECKED |
| `lem:reductions` (Lemma 3.3 + Table 1) | the five reductions (a)–(e) | 2.1, 3.1, (2.2) | "Reductions (contracts)" table | `Plan.degree_four_reduction`, `Plan.mixed_reduction`, `Plan.square_component_reduction`, `Plan.cubic_chordless_reduction`, `Plan.subcubic_chord_reduction` | REPAIRED-R1, RENDER-CHECKED |
| `lem:structure` (Lemma 3.4) | min degree 2; 2-regular => C4; trichotomy | — | "Reductions", last line; "Universal" | `Plan.square_supported_degree_ge_two`, `Plan.two_regular_square_supported`, `Plan.degree_two_three_cases` | REPAIRED-R1, RENDER-CHECKED |
| `lem:tight` (Lemma 4.1) | consequences of tightness (i)–(v) | Thm A, 3.2, 3.3, 3.4, 2.1 | "Equality (Theorem B)", tightness paragraph | `Plan.equality_square_supported`, `Plan.equality_max_degree_le_four`, `Plan.equality_min_degree`, `Plan.tight_subcubic_chordless`, `Plan.equality_residual_components` | REPAIRED-R1, RENDER-CHECKED |
| `lem:cut` (Lemma 4.2) | cut lemma (edges, not endpoints) | — | "Deletion", second bullet | `Plan.component_attachment_card_ge_two` | REPAIRED-R1, RENDER-CHECKED |
| `lem:small` (Lemma 4.3) | tau_4 of the four graphs; prescribed vertex | — | "Equality", last bullet | `Plan.small_graph_data`, `Plan.classified_tight`, `Plan.classified_prescribed` | REPAIRED-R1, RENDER-CHECKED |
| `lem:extension` (Lemma 4.4) | K33-e plus a degree-4 vertex has tau_4 <= 2 | — | `equality_degree_four_case` bullet (symbolic K33-e) | `Plan.k33_extension_tau_le_two` | REPAIRED-R1, RENDER-CHECKED |
| `prop:deg4` (Prop. 4.5) | degree-four case: W5 or K222 | 3.3(a), 4.1, 4.2, 4.3, 4.4, 2.1, (4.1) | `equality_degree_four_case` | `Plan.equality_degree_four_case` (Lean concludes "classified"; the paper states W5 or K222, which is what the proof gives) | REPAIRED-R1, RENDER-CHECKED |
| `prop:mixed` (Prop. 4.6) | mixed 2/3 case: K33-e | 3.3(b), 4.1, 4.2, (4.1) | `equality_mixed_degree_case` | `Plan.equality_mixed_degree_case`, `Plan.mixed_reconstruction` | REPAIRED-R1, RENDER-CHECKED |
| `prop:cubic` (Prop. 4.7) | cubic case impossible | 3.3(d), 4.1 | `equality_cubic_impossible` | `Plan.equality_cubic_impossible`, `Plan.two_squares_matching_transversal` | REPAIRED-R1, RENDER-CHECKED |
| `thm:B` (Theorem B) | principal: equality classification | 4.3, 4.1, 3.4, 4.5–4.7 | "Equality (Theorem B)" | `SizeRamsey.equality_classification` (record) | REPAIRED-R1, RENDER-CHECKED |
| `lem:colouring` (Lemma 5.1) | transversal of size <= 3 gives avoiding colouring | — | "Coloring", `avoiding_coloring_of_transversal` | `avoiding_coloring_of_transversal` | REPAIRED-R1, RENDER-CHECKED |
| `thm:C` (Theorem C) | principal: (i) transversal <= 3, (ii) colouring | Thm A, Thm B, 5.1 | "Coloring (Corollary C)" | (ii) `SizeRamsey.avoiding_coloring_le_sixteen` (record); (i) `SizeRamsey.connected_transversal_le_three` (library, not a record) | REPAIRED-R1, RENDER-CHECKED |
| `lem:star` (Lemma 5.2) | star lemma | — | "Upper (Theorem D)" | `Plan.star_or_empty` | REPAIRED-R1, RENDER-CHECKED |
| `lem:k33arrow` (Lemma 5.3) | K33-e -> (2K2, C4), quoted [WYBAS15, Thm 2.6] with proof | 5.2, 4.3 | "Upper (Theorem D)" | `k33MinusEdge_arrows_matching2_c4` | REPAIRED-R1, RENDER-CHECKED |
| `thm:D` (Theorem D) | principal: fixed host F17 | 5.3 | "Upper (Theorem D)"; host as CORRESPONDENCE §1 D | `SizeRamsey.F17_spec` (record) | REPAIRED-R1, RENDER-CHECKED |
| `rem:bridge` (Remark 5.4) | any bridge; NOT formalised (stated as such) | proof of D | CORRESPONDENCE §1 D | none | REPAIRED-R1, RENDER-CHECKED |
| `thm:E` (Theorem E) | principal: value 17 | Thm C(ii), Thm D | "Endpoint" | `SizeRamsey.connectedSizeRamsey_eq_seventeen` (record) | REPAIRED-R1, RENDER-CHECKED |

Labelled displays: `eq:tau` (2.1), `eq:edgecount` (2.2), `eq:rc` (2.3), `eq:charge` (3.1),
`eq:IH` (4.1, the induction hypothesis of Section 4.3), `eq:deg4tau` (4.2). Tables:
`tab:reductions`, `tab:lean`.

Not promoted to public statements (proof-local or Lean API only): `tau4_le_card`, `tau4_mono`,
`tau4_iso` (one sentence in §2), `tau4_delete_leaf_vertex` (unused), `attachment_sum`,
`erase_*` counting lemmas (absorbed in (2.2)), `classification_of_step`, `two_regular` case
(one line in the proof of Theorem B), `prescribedOptimal_iso`, `classified_three_degree_two`
(one sentence in Prop. 4.6).

Placement deviation from the brief: the cut lemma is in §4.1 (its first use), not §3; Theorem A
does not use it.

## PROOF.md / Challenge.lean disagreements

None found. The two documented scope points (C record = colouring half; D = fixed host) are
stated in §1 and §6 and in Remark 5.4. Theorem statements A, B, C(ii), D, E carry exactly the
content of the five records; C(i) carries the content of `connected_transversal_le_three`.
Lemma-level differences from the Lean names: Prop. 4.5 states "W5 or K222" (Lean: in the list);
Prop. 4.7 is stated under the standing hypotheses although its proof uses neither connectivity
nor (4.1) (matches the Lean hypotheses).

## Draft markers in main.tex (after repair round 1)

- `\red{[affiliation]}` in the `\thanks` of the author line (kept, decision 8).
- `\red{[visibility]}` in §6 Availability (kept, decision 8).
- The EFRS78 `[check]` marker was removed: data confirmed from Crossref.

## Bibliography fields (refs.bib comments)

Confirmed from Crossref metadata (api.crossref.org, fetched 2026-10-17; recorded beside each
entry): EFRS78 (all fields), RBA17 (journal, vol. 127, no. 5, pp. 787–792), RBA18 (title
"Publisher correction to: ...", vol. 128, no. 1, art. 15), AMT01 (issue 3), Mathlib20
(proceedings, pp. 367–381), Lean4 (book, series, pp. 625–635). Still unconfirmed (`[check]`
comment in refs.bib only): Lean4 LNCS volume 12699; EF84 book title, publisher, address.
Mathlib author capitalised "Mathlib" per decision 10 (Crossref has "mathlib").

## Open author decisions

1. AI disclosure: SETTLED by coordinator decision 9 — §6 names "GPT-6 Astra (OpenAI) and
   Claude models (Anthropic)"; these names appear in §6 only.
2. Repository visibility and the final Availability sentence (`[visibility]`).
3. Affiliation (`[affiliation]`).
4. Whether to add a sixth statement of record for Theorem C(i) (`TODO(ben)` in
   CORRESPONDENCE §8); if added, §6 Scope and Table 2 simplify.
5. A figure of the four tight graphs (with the labels h, r_i, a_i, b_i) and of F17 would help
   Sections 2, 4 and 5; not drawn, as figures need author approval.
6. Attribution wording for Theorem A: SETTLED by decision 3 (K4-free hypothesis and the
   exceptional components named; derivation needs the degree-4 deletion plus a direct check).
7. Sentence before Prop. 4.7 rewritten (exposition 17): the proof uses only cubic + tight +
   1 <= |E| <= 16, the only use of the edge bound in the inductive step; statement keeps the
   Lean hypotheses.

## Build

`latexmk -pdf -interaction=nonstopmode main.tex`: no errors, no warnings, no overfull or
underfull boxes; citations and references resolved. 14 pages (US Letter, 11pt). All 14 pages
rendered at 110 dpi and inspected.

## Repair round 1 (two reviews, both ACCEPT_WITH_REPAIRS; coordinator decisions 1–10)

Contract review:
- R1 RESOLVED: §6 says C4 is Mathlib's cycle graph on four vertices; W5, K33-e, octahedron, F17
  are edge lists, with the full label mapping (decision 1).
- R2 RESOLVED: "at most one edge leaving the square" (§3.1).
- R3 RESOLVED: AMT sentence rewritten per decision 3 (K4-free, exceptional components, degree-4
  deletion plus direct check of K4 and those components).
- R4 RESOLVED: §6 says the five records are on {0,...,n-1} and the C(i) library theorem on an
  arbitrary finite vertex type.
- R5 RESOLVED: intro says WSZZ's n=4 construction is two copies of K33-e joined by an edge and
  F17 is one such graph; the identity claim in Remark 5.4 was removed.
- R6 RESOLVED: §5.2 opening now restricted to a triangle-free host such as a copy of K33-e.
- R7 RESOLVED: §4 opening restricts to components with an edge and notes isolated vertices are
  tight but excluded by the positive edge count.
- R8 RESOLVED: abstract lists the verified results instead of "all statements"; §6 Scope says
  the general-bridge extension lies outside the formal development.
- R9 RESOLVED: heuristic sentence removed; replaced by the supported comparison
  rc(3K2,C4)=13 > r(3K2,C4)=12 (EF84 with n=3, RBA17).
- R10 RESOLVED: EFRS78 confirmed by Crossref, marker removed; RBA18 article number 15 added;
  [affiliation], [visibility] kept by decision.
- R11 RESOLVED: Lemma 3.4(ii) proof gives the walk argument that a connected 2-regular finite
  graph is a cycle.

Exposition review:
- 1 RESOLVED in part: [check] removed; [affiliation], [visibility] kept by decision 8.
- 2 RESOLVED: Table 1 placed [b], now on the same page as Lemma 3.3; blank feet reduced (p.8 and
  p.11 keep ~5–7 blank lines before a lemma and a section start; accepted).
- 3 RESOLVED: \needspace before §4.1; Lemma 4.1 statement and proof start on one page.
- 4 RESOLVED: sum in Lemma 4.1(v) proof is a display.
- 5 DECLINED: breaks after "<=" in Lemma 4.1(i),(ii) accepted (reviewer: acceptable).
- 6 RESOLVED: RBA18 now "no. 1, Art. 15"; "The Mathlib Community".
- 7 no action (OK).
- 8 RESOLVED: "charged for the squares through both vertices".
- 9 RESOLVED: "X nonempty, hence |E(G-D)| < |E(G)|".
- 10 RESOLVED: "since the neighbours of u are v and t != a".
- 11 RESOLVED: "(the degrees are listed in Section 2)".
- 12 RESOLVED: both WLOG clauses in Lemma 4.4 justified in parentheses; the other "we may"
  (rotation of a chorded square, proof of Thm A) is self-justifying.
- 13 RESOLVED: Lemma 4.4 cases 2 and 3 end "so only ... can have at least two neighbours".
- 14 RESOLVED: preface of Lemma 4.4 names its use in Proposition 4.5.
- 15 RESOLVED: "exact" defined in the §4 opening; intro defines it inline.
- 16 RESOLVED: Lemma 4.1 proof opening names parts (i), (ii), (iv), (v).
- 17 RESOLVED: hypotheses kept (Lean); preceding sentence says what the proof uses.
- 18 RESOLVED: with R6.
- 19 RESOLVED: "three facts" in §4 opening, each with its lemma; intro points to Section 4.
- 20 RESOLVED: formal scope now in intro (one sentence) and §6 only; "case n=4" stated once.
- 21 RESOLVED: list split into its own sentence (intro proof strategy, now shortened).
- 22 RESOLVED: isomorphism defined as a bijection of whole vertex sets; isolated vertices count.
- 23 RESOLVED: both sentences deleted.
- 24 RESOLVED: §5 opening states the mechanism.
- 25, 27 no action (OK).
- 26 RESOLVED: ties before \ref after plural "Theorems"/"Sections".

Other edits for length (to stay at 14 pages): §3 opening shortened, intro "Proof strategy"
first paragraph shortened, "Organisation" paragraph removed, Lemma 2.1 equation made inline.

Build after round 1: 14 pages; latexmk 0 warnings, 0 overfull, 0 underfull; all 14 pages
re-rendered at 110 dpi and inspected.
