# Development notes

| informal label (docs/PROOF.md) | Lean declaration | file | status |
|---|---|---|---|
| Theorem A | `SizeRamsey.Proof.four_mul_tau4_le_edgeCount` | Universal.lean | admitted |
| Theorem B | `SizeRamsey.Proof.equality_classification` | Equality.lean | admitted (review gate) |
| Corollary C | `SizeRamsey.Proof.avoiding_coloring_le_sixteen` | Coloring.lean | admitted |
| Theorem D | `SizeRamsey.Proof.F17_spec` | Upper.lean | assembled; parts admitted |
| F17 edge count | `SizeRamsey.F17_edgeCount` | Basic.lean | proved (`decide`) |
| endpoint | `SizeRamsey.connectedSizeRamsey_eq_seventeen` | Solution.lean | proved from C, D |

Conventions: every file starts with `module`; `public import` for exported dependencies;
`@[expose] public section`; the library never imports `Challenge`; `Solution` imports the
library publicly and restates the five theorems. No `native_decide`.

Discharge order (scaffold plan §9): Basic → D → colouring from a transversal → Deletion and
Components → A → SmallGraphs and FiniteChecks → B (after review gate) → C → Solution records.
