# Correspondence: informal theorem ↔ formal statement (2026-10-16; updated 2026-10-17)

Status: sorry-free Lean development at `a73d95a`, kernel-replayed locally (per-module
leanchecker), pending adversary and reviewer passes on the formal development, independent
statement reconstruction, and the CI comparator. Not formally verified. Sections 1–7 are the
correspondence argument as written at the scaffold; no statement or definition has changed since
the stream base `b17d1fa`. §10 is the audit record.

## 1. Informal statements

For a finite simple graph G let τ₄(G) be the least size of a vertex set meeting every (not
necessarily induced) 4-cycle, and |E(G)| its number of edges.

* **A.** 4·τ₄(G) ≤ |E(G)|.
* **B.** If G is connected with 0 < |E(G)| ≤ 16, then 4·τ₄(G) = |E(G)| iff G ≅ C₄, W₅ (4-wheel),
  K₃,₃ − e, or K₂,₂,₂ (octahedron).
* **C.** Every connected G with |E(G)| ≤ 16 has R ⊆ E(G) with no red (R) matching of four edges
  and no blue (E(G) \ R) 4-cycle.
* **D.** F₁₇ (two vertex-disjoint copies of K₃,₃ − e joined by a bridge; 12 vertices, 17 edges)
  is connected and every red/blue colouring of its edges has a red 4-matching or a blue C₄.
* **E.** r̂_c(4K₂, C₄) = 17.

## 2. Statement table

| informal | `Challenge.lean` | development |
|---|---|---|
| A | `SizeRamsey.four_mul_tau4_le_edgeCount` | `SizeRamsey.Proof.four_mul_tau4_le_edgeCount` (Universal.lean) |
| B | `SizeRamsey.equality_classification` | `SizeRamsey.Proof.equality_classification` (Equality.lean) |
| C | `SizeRamsey.avoiding_coloring_le_sixteen` | `SizeRamsey.Proof.avoiding_coloring_le_sixteen` (Coloring.lean) |
| D | `SizeRamsey.F17_spec` | `SizeRamsey.Proof.F17_spec` (Upper.lean) |
| E | `SizeRamsey.connectedSizeRamsey_eq_seventeen` | proved in Solution.lean from C and D |

## 3. Definition audit

* `IsC4Map G f`: `f : Fin 4 → V` injective with the four cyclic adjacencies. Non-induced:
  diagonals allowed. **Not** `SimpleGraph.Embedding` (which is induced).
* `HasMatching4 R`: `f : Fin 8 → V` injective with `R.Adj (f 0) (f 1)`, …, `(f 6) (f 7)`;
  extra edges among the endpoints allowed.
* `c4Transversal G S`, `tau4 G = sInf {k | ∃ S, c4Transversal G S ∧ S.card = k}`; the set is
  nonempty (`Finset.univ`), attainment is `exists_transversal_card_eq_tau4`.
* `edgeCount G = G.edgeFinset.card` under `classical`; unordered edges counted once;
  `edgeCount_eq_card` bridges to any `Fintype G.edgeSet` instance so concrete counts can be
  decided (`F17_edgeCount`).
* Blue graph `F \ R` with `R ≤ F`: `(F \ R).Adj u v ↔ F.Adj u v ∧ ¬ R.Adj u v`
  (`SimpleGraph.sdiff_adj`), a genuine partition of the edges of `F`.
* `Connected` (Mathlib) includes nonemptiness: `Fin 0` excluded, the one-vertex graph included.

## 4. `Fin n` versus arbitrary finite vertex types

Statements of record are on `SimpleGraph (Fin n)`; the development is generic in `V` with
`[Fintype V]` and `tau4_iso` transports along relabelings. E quantifies over all `n`.

## 5. Named graphs (explicit edge lists, `graphOfEdges`)

| graph | vertices | edges | convention |
|---|---|---|---|
| `SimpleGraph.cycleGraph 4` | Fin 4 | 4 | Mathlib |
| `wheel5` | Fin 5 | 8 | rim 0-1-2-3-0, center 4 |
| `k33MinusEdge` | Fin 6 | 8 | parts {0,1,2}, {3,4,5}; missing edge {0,3} |
| `octahedron` | Fin 6 | 12 | parts {0,1}, {2,3}, {4,5} |
| `F17` | Fin 12 | 17 | copies on 0..5 and 6..11 (missing edges {0,3}, {6,9}); bridge {5,6} |

## 6. Equality classification

`Nonempty (G ≃g H)` is an isomorphism of the whole graph (vertices included), not of the
support; B's `↔` includes the converse, which requires the four transversal numbers.

## 7. The infimum in E

`connectedSizeRamsey = sInf {m | ∃ n F, F.Connected ∧ edgeCount F = m ∧ ArrowsMatching4C4 F}`;
`⟨12, F17, F17_spec⟩` shows 17 is in the set, `Nat.sInf_le` and `le_csInf` give both inequalities
(the proof in Solution.lean uses C and D, both proved in the development as of `a73d95a`).

## 8. Formalized scope and gaps

As of `a73d95a` (2026-10-17) every declaration of the development library and of `Solution.lean`
is proved: the only `sorry`s in the project are the five deliberate ones in `Challenge.lean` (the
statements of record), and `#print axioms` of the five records in `Solution.lean` is
`[propext, Classical.choice, Quot.sound]`. No custom axioms, no `native_decide`.
`Challenge.lean`, `SizeRamsey/Defs.lean`, `Shared.lean` and `AInterface.lean` are byte-identical
to the stream base `b17d1fa`, which differs from the bootstrap `a979fb0` only by a status
docstring edit; the statements of record and the frozen definitions are therefore unchanged.

Gaps: the CI comparator (statement/definition agreement between Challenge and Solution) has not
run; no adversary or reviewer pass has examined the formal development; the formal statements
have not been independently reconstructed from the informal ones; `leanchecker --fresh`, NanoDa
and con-ron have not run. Provenance (see `formalization.yaml` `automation.notes`): Tightness,
Equality/Mixed, Equality/Cubic, Equality/TwoRegular, the body of `equality_classification` and
`connected_transversal_le_three` were written by GPT-6 Astra and applied mechanically; the rest
by Claude Opus 5.5 coding agents. Novelty of A/B is not claimed.

## 9. Toolchain

`leanprover/lean4:v4.35.0-rc3`; Mathlib `v4.35.0-rc3` (`c55e6e786f49471c72fbddbec5415808896aec1e`);
manifest copied from PALOMAR-2026-10-07-000005 with the root renamed.

## 10. Build and audit record

| date | command | commit | outcome |
|---|---|---|---|
| 2026-10-16 | `lake build` | scaffold | success, 1043 jobs, sorry warnings only |
| 2026-10-16 | `lake env lean SizeRamsey/AxiomAudit.lean` | scaffold | all five depend on `sorryAx` (expected) |
| 2026-10-16 | `python3 scripts/check-lean-sources.py` | scaffold | satisfied |
| before 2026-10-17 | `lake env leanchecker SizeRamsey.Deletion SizeRamsey.Components SizeRamsey.Reductions SizeRamsey.Universal` | branch `lean/stream-A` | exit 0 |
| before 2026-10-17 | `lake env leanchecker SizeRamsey.Upper SizeRamsey.ColoringBase SizeRamsey.Coloring` | branch `lean/stream-B` | exit 0 |
| before 2026-10-17 | `lake env leanchecker SizeRamsey.Equality.Common SizeRamsey.Equality.Extension SizeRamsey.Equality.DegreeFour` | branch `lean/stream-B` | exit 0 |
| 2026-10-17 | `lake build` | `a73d95a` | exit 0, 1228 jobs; `declaration uses sorry`: 5, all in `Challenge.lean`, 0 elsewhere |
| 2026-10-17 | `lake env lean SizeRamsey/AxiomAudit.lean` | `a73d95a` | `[propext, Classical.choice, Quot.sound]` for all five records |
| 2026-10-17 | `lake env leanchecker SizeRamsey.Tightness SizeRamsey.Equality.Mixed SizeRamsey.Equality.Cubic SizeRamsey.Equality.TwoRegular SizeRamsey.Equality SizeRamsey.Coloring SizeRamsey.Main Solution Challenge` | `a73d95a` | exit 0 |
| 2026-10-17 | `python3 scripts/check-lean-sources.py` | `a73d95a` | satisfied |
| 2026-10-17 | `ruby scripts/validate-formalization.rb` | `a73d95a` | passes |
| 2026-10-17 | forbidden-construct scan of every applied diff | `a73d95a` | 0 findings |
| 2026-10-17 | frozen-file comparison against `b17d1fa` (Challenge, Solution, Defs, Shared, AInterface) | `a73d95a` | byte-identical |
| 2026-10-17 | `lake env leanchecker <all 24 built modules: Challenge, Solution, SizeRamsey.* incl. Equality.*>` | `a73d95a` | exit 0, 1 min 20 s wall |

Not run: CI comparator (Linux, bubblewrap), `leanchecker --fresh`, NanoDa, con-ron; adversary
and reviewer passes on the formal development; independent statement reconstruction.
`Solution.lean` was afterwards edited in a docstring only (comment lines; no statement or proof).

## 11. Computations

Exploratory, unretained (Astra, 2026-10-16): equality hosts with 4, 8, 12 edges are exactly the
four graphs; six 4-regular 8-vertex graphs have τ₄ = 3; all 15 degree-4 extensions of K₃,₃ − e
have τ₄ ≤ 2. None of this is Lean evidence.

## 12. Review packet

`~/aiseminar/agents/shared/claim_0004/` (informal proof VERIFIED; `STATUS.yaml` carries a
`formalization:` key with the Lean state, `EVIDENCE.md` the 2026-10-17 Lean audit); history in
`docs/STATUS_CHECK.md`. Astra run directory for the formal proofs:
`~/aiseminar/agents/runs/2026-10-16_ramsey-astra/` (replies `reply_ramsey-{A7,B67,B89}-r1.md`).
