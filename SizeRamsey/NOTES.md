# Development notes

Plan of record: `docs/astra/2026-10-16_lean_plan.md` (two parallel streams). Stream A owns the
structural library, Stream B owns D, colouring, equality and integration (plan §0). `Shared.lean`
and `AInterface.lean` are frozen after bootstrap: names, types, definitions and instance
conventions do not change; admitted bodies were replaced in place by their owner. B imports A only
through `SizeRamsey.AInterface`. New declarations live in `SizeRamsey.Plan`; the four
`SizeRamsey.Proof.*` interfaces consumed by `Solution.lean` keep their names.

Status legend: **proved** = no `sorry` in the body and no `sorryAx` in `#print axioms`.
**(Astra)** = body written by GPT-6 Astra (aiseminar `agents/runs/2026-10-16_ramsey-astra/`,
replies `reply_ramsey-{A7,B67,B89}-r1.md`) and applied mechanically in `a73d95a`; every other
body was written by Claude Opus 5.5 coding agents on `lean/stream-A` / `lean/stream-B`.

State as of `a73d95a` (2026-10-17): every development declaration is proved; no stub or
assembled-from-stubs declaration remains. The only `sorry`s in the project are the five
deliberate statements of record in `Challenge.lean`. `#print axioms` of the five records in
`Solution.lean` is `[propext, Classical.choice, Quot.sound]`; `lake env leanchecker` on all 25
built project modules (literal argv in `CORRESPONDENCE.md` §10) exits 0. The proof certificate
is `Solution.lean` and its dependency closure (`lake build Solution`: zero `sorry` warnings); the
default `lake build` also shows the five deliberate `Challenge.lean` warnings. Adversary pass 1
and reviewer pass 1 ACCEPT_WITH_FIXES (fixes applied); independent statement reconstruction done;
full CI comparator not run; lab status promotion not made, so not yet formally verified.

## Status

| declaration | owner | file | status |
|---|---|---|---|
| `IsC4Map`, `HasC4`, `HasMatching4`, `c4Transversal`, `tau4`, `edgeCount`, `ArrowsMatching4C4`, `graphOfEdges`, `wheel5`, `k33MinusEdge`, `octahedron`, `F17`, `connectedSizeRamsey` | frozen | Defs.lean | definitions (agree with Challenge) |
| `Plan.erase`, `EdgeOnSquare`, `SquareSupported`, `Tight`, `Classified`, `SmallerClassified`, `PrescribedOptimal`, `compGraph`, `componentFintype`, `HitsDeleted`, `liftTransversal`, `componentVerts`, `attachmentEdges` | frozen | Shared.lean | definitions |
| `edgeCount_eq_card` | A | Basic.lean | proved |
| `F17_edgeCount` | A | Basic.lean | proved (`decide`) |
| `tau4_le_card`, `exists_transversal_card_eq_tau4`, `tau4_mono`, `tau4_iso` | A | Basic.lean | proved |
| `Plan.edgeCount_iso`, `Plan.tau4_eq_zero_iff`, `Plan.tau4_eq_of_certificates` | A | Basic.lean | proved |
| decidability instances (`IsC4Map`, `HasC4`, `c4Transversal`, `wheel5`, `k33MinusEdge`, `octahedron`) | A | FiniteChecks.lean | defined |
| `Plan.k33_square_avoids_vertex`, `Plan.k33_triangle_free` | A | FiniteChecks.lean | proved |
| `Plan.small_graph_data`, `Plan.small_degrees`, `Plan.prescribedOptimal_iso` | A | SmallGraphs.lean | proved |
| `Plan.classified_tight`, `Plan.classified_prescribed`, `Plan.classified_three_degree_two` | A | SmallGraphs.lean | proved |
| `Plan.tau4_erase_lift`, `Plan.tau4_delete_vertices_le`, `Plan.transversal_iff_no_square_erase` | A | Deletion.lean | proved |
| `Plan.erase_edgeCount`, `Plan.erase_singleton_counts`, `Plan.erase_degree`, `Plan.erase_card` | A | Deletion.lean | proved |
| `Plan.tau4_delete_non_square_edge`, `Plan.tau4_delete_leaf_vertex` | A | Deletion.lean | proved |
| `Plan.compGraph_connected` | A | Components.lean | proved |
| `Plan.tau4_components`, `Plan.edgeCount_components`, `Plan.compGraph_degree`, `Plan.component_edgeCount_le` | A | Components.lean | proved |
| `Plan.component_square_supported`, `Plan.connected_positive_degree`, `Plan.square_supported_no_bridge` | A | Components.lean | proved |
| `Plan.component_attachment_card_ge_two`, `Plan.attachment_sum` | A | Components.lean | proved |
| `Plan.square_supported_degree_ge_two`, `Plan.degree_four_reduction`, `Plan.mixed_reduction` | A | Reductions.lean | proved |
| `Plan.two_regular_square_supported`, `Plan.cubic_chordless_reduction`, `Plan.subcubic_chord_reduction` | A | Reductions.lean | proved |
| `Plan.degree_two_three_cases`, `Plan.square_component_reduction` | A | Reductions.lean | proved |
| `Plan.universal` (Theorem A) | A | Universal.lean | proved |
| `Proof.four_mul_tau4_le_edgeCount` | A | Universal.lean | proved (from `Plan.universal`) |
| `Plan.equality_square_supported`, `Plan.equality_max_degree_le_four` | A | Tightness.lean | proved (Astra) |
| `Plan.equality_min_degree`, `Plan.equality_residual_components` | A | Tightness.lean | proved (Astra) |
| (import boundary) | A | AInterface.lean | public imports only |
| `HasMatching2` | B | Upper.lean | definition |
| `Plan.leftCopy`, `Plan.rightCopy` | B | Upper.lean | definitions |
| `Plan.leftCopy_injective`, `Plan.rightCopy_injective`, `Plan.copies_disjoint` | B | Upper.lean | proved |
| `Plan.leftCopy_adj`, `Plan.rightCopy_adj`, `Plan.hasC4_map` | B | Upper.lean | proved |
| `Plan.star_or_empty`, `Plan.matching2_union` | B | Upper.lean | proved |
| `F17_connected`, `k33MinusEdge_arrows_matching2_c4`, `F17_arrows_matching4_c4` | B | Upper.lean | proved |
| `Proof.F17_spec` (Theorem D) | B | Upper.lean | proved |
| `incidentRed` | B | ColoringBase.lean | definition |
| `Plan.incidentRed_adj` | B | ColoringBase.lean | proved |
| `Plan.matching4_incident_card`, `Plan.transversal_no_blue_square`, `avoiding_coloring_of_transversal` | B | ColoringBase.lean | proved |
| `Plan.tight_subcubic_chordless` | B | Equality/Common.lean | proved |
| `Plan.k33_extension_tau_le_two` | B | Equality/Extension.lean | proved |
| `Plan.equality_degree_four_case` | B | Equality/DegreeFour.lean | proved |
| `Plan.equality_mixed_degree_case` | B | Equality/Mixed.lean | proved (Astra) |
| `Plan.mixed_reconstruction` | B | Equality/Mixed.lean | proved |
| private helpers `b67_audit_cycle4_arrange`, `b67_audit_mixed_opposite`, `b67_audit_mixed_normalize`, `b67_mixed_final_labels` | B | Equality/Mixed.lean | proved (Astra) |
| `Plan.two_squares_matching_transversal`, `Plan.equality_cubic_impossible` | B | Equality/Cubic.lean | proved (Astra) |
| private helpers `cubic_chordless_adjacency_r1`, `cubic_third_neighbor_r1`, `cubic_square_unique_cross_r1` | B | Equality/Cubic.lean | proved (Astra) |
| `Plan.equality_two_regular_case` | B | Equality/TwoRegular.lean | proved (Astra) |
| `Plan.classification_of_step` | B | Equality.lean | proved |
| `Proof.equality_classification` (Theorem B) | B | Equality.lean | proved (Astra) |
| `connected_transversal_le_three` | B | Coloring.lean | proved (Astra) |
| `Proof.avoiding_coloring_le_sixteen` (Corollary C) | B | Coloring.lean | proved (from `connected_transversal_le_three`) |
| (final exports) | B | Main.lean | public imports only |
| five statements of record, `connectedSizeRamsey_eq_seventeen` | B | Solution.lean | proved; endpoint from C and D |
| axiom audit | B | AxiomAudit.lean | imports `Solution`; not imported by `SizeRamsey` |

## Import DAG

`Defs → Shared → Basic → {FiniteChecks → SmallGraphs, Deletion → Components}`;
`Components + SmallGraphs → Reductions → Universal → Tightness`;
`AInterface = Tightness + SmallGraphs`; `AInterface → Upper, Equality/{Common, Extension,
TwoRegular}`; `Common + Extension → DegreeFour`; `Common → Mixed, Cubic`;
four cases `→ Equality`; `Shared + Basic → ColoringBase`; `Equality + ColoringBase → Coloring`;
`Coloring + Upper → Main → SizeRamsey → Solution → AxiomAudit`.

## Contract deviations

Recorded at bootstrap. None changes a declaration name, a statement, or the mathematics.

1. `FiniteChecks.lean` additionally imports `Mathlib.Data.Fin.VecNotation`; without it the
   plan's witnesses `![1,3,2,4]` parse as Boolean negation and fail. `Mathlib.Tactic.FinCases`
   is imported there too (the plan asks for it); both are re-exported to B through `AInterface`.
2. `compGraph_connected` is stated under `omit [Fintype V] in`, as the plan's §5 recommends, so
   its type has no `Fintype V` argument (the interface harness had an unused one).
3. `equality_residual_components`: `4*c` written `4 * c` (whitespace linter); same term.
4. `small_degrees` (SmallGraphs.lean) has the plan's text, but because `FiniteChecks` is now
   imported, the `degree` instances for `wheel5`, `k33MinusEdge` and `octahedron` elaborate to
   the computable `DecidableRel` instances from `FiniteChecks` instead of
   `Classical.propDecidable` as in the plan's one-file harness. The statements are
   propositionally equal (`Fintype` is a subsingleton). Every other distributed declaration
   elaborates to exactly the harness type (checked by comparing the elaborated types of all 43
   interface theorems against a re-elaboration of the plan's initial `AInterface` text).
5. Module doc-strings were added to `Shared.lean` and `AInterface.lean` (style linter), and the
   repository's copyright header precedes `module` in every new file. The Lean text of both
   frozen files is otherwise verbatim.

Remaining linter warnings (frozen signatures, left as is): `linter.unusedFintypeInType` on
`tau4_erase_lift`, `transversal_iff_no_square_erase`, `component_square_supported`,
`square_supported_no_bridge`.

## Conventions

Every file starts with `module`; `public import` for exported dependencies;
`@[expose] public section`; the library never imports `Challenge`; `Solution` imports the
library publicly and restates the five theorems. No `native_decide`. Structural sections use
`attribute [local instance] Classical.propDecidable`; certificate sections (`Basic` instances,
`FiniteChecks`, `Upper`) do not, so that `decide` runs.
