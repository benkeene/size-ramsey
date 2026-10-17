# Correspondence: informal theorem ↔ formal statement (2026-10-16; updated 2026-10-17)

Status: sorry-free Lean development at `a73d95a`, kernel-replayed locally (per-module
leanchecker, all 25 built project modules); adversary pass 1 on the formal development
ACCEPT_WITH_FIXES (meaning 0.97, trust 0.98; fixes applied 2026-10-17); independent statement
reconstruction done (§13); reviewer pass and CI comparator pending. Not formally verified.
Sections 1–7 are the correspondence argument as written at the scaffold, with the Corollary C
record scope made explicit after adversary pass 1 (§1, §2, §8); no statement or definition has
changed since the stream base `b17d1fa`. §10 is the audit record.

## 1. Informal statements

For a finite simple graph G let τ₄(G) be the least size of a vertex set meeting every (not
necessarily induced) 4-cycle, and |E(G)| its number of edges.

* **A.** 4·τ₄(G) ≤ |E(G)|.
* **B.** If G is connected with 0 < |E(G)| ≤ 16, then 4·τ₄(G) = |E(G)| iff G ≅ C₄, W₅ (4-wheel),
  K₃,₃ − e, or K₂,₂,₂ (octahedron).
* **C.** Every connected G with |E(G)| ≤ 16 has a C₄-transversal of at most three vertices and
  therefore R ⊆ E(G) with no red (R) matching of four edges and no blue (E(G) \ R) 4-cycle
  (CLAIM.md wording). **The statement of record for C is only the colouring conclusion**; the
  transversal conclusion is proved in the library as `SizeRamsey.connected_transversal_le_three`
  but is not a statement of record (§2, §8).
* **D.** F₁₇ (two vertex-disjoint copies of K₃,₃ − e joined by a bridge; 12 vertices, 17 edges)
  is connected and every red/blue colouring of its edges has a red 4-matching or a blue C₄.
  The record fixes the bridge endpoints (§5, §13): vertex 5 (degree 3 in its copy) to vertex 6
  (vertex 0 of the second copy, degree 2); CLAIM.md's D is to be read with these endpoints.
* **E.** r̂_c(4K₂, C₄) = 17.

## 2. Statement table

| informal | `Challenge.lean` | development |
|---|---|---|
| A | `SizeRamsey.four_mul_tau4_le_edgeCount` | `SizeRamsey.Proof.four_mul_tau4_le_edgeCount` (Universal.lean) |
| B | `SizeRamsey.equality_classification` | `SizeRamsey.Proof.equality_classification` (Equality.lean) |
| C (colouring) | `SizeRamsey.avoiding_coloring_le_sixteen` | `SizeRamsey.Proof.avoiding_coloring_le_sixteen` (Coloring.lean) |
| C (transversal) | none (not a statement of record) | `SizeRamsey.connected_transversal_le_three` (Coloring.lean) |
| D | `SizeRamsey.F17_spec` | `SizeRamsey.Proof.F17_spec` (Upper.lean) |
| E | `SizeRamsey.connectedSizeRamsey_eq_seventeen` | proved in Solution.lean from C and D |

`SizeRamsey.connected_transversal_le_three` is generic in a finite vertex type `V`:
`G.Connected → edgeCount G ≤ 16 → ∃ S : Finset V, c4Transversal G S ∧ S.card ≤ 3`; its
`#print axioms` is `[propext, Classical.choice, Quot.sound]` (adversary-meaning run, 2026-10-17).
The two halves are not interchangeable (K₇ with every edge red avoids both colours, yet no three
vertices meet all its 4-cycles), so the C record is strictly weaker than CLAIM.md's C.

Scope of the five records against CLAIM.md (adversary pass 1 comparison, 2026-10-17):

| | record versus CLAIM.md |
|---|---|
| A | equal, after relabelling an arbitrary finite vertex type by `Fin n` (§4) |
| B | stronger than CLAIM.md's literal "only for": the record is an iff (converse included); equal to §1's iff |
| C | weaker as stated: the colouring conclusion only; the transversal half is proved but unrecorded |
| D | equal, for the explicitly specified bridge endpoints |
| E | equal to the stated finite connected size-Ramsey minimum |

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

Corollary C record scope: the statement of record `SizeRamsey.avoiding_coloring_le_sixteen` is
the colouring consequence only. The transversal statement of CLAIM.md's C is proved and named
(`SizeRamsey.connected_transversal_le_three`, Coloring.lean, axiom-clean) but is in neither
`Challenge.lean` nor `comparator.json`. `TODO(ben)`: packaging decision whether to add it as a
sixth statement of record (Challenge.lean, Solution.lean, comparator.json, AxiomAudit.lean);
until then CLAIM.md's C is covered by the record only in its colouring half.

Comparator wording: the docstrings of `Solution.lean` (line 42) and `SizeRamsey/Defs.lean`
(line 15) say "the comparator checks" agreement. That describes the comparator's function, not a
completed run: the CI comparator has not run. The files are left unedited (Defs.lean is frozen).
The trust adversary separately ran the toolchain's `Lake.Check.compareAt` and `checkAxioms` on
the existing Challenge and Solution environments (`Except.ok ()` for both); that is a check over
existing `.olean`s, not the sandboxed CI comparator run.

Gaps: the CI comparator (statement/definition agreement between Challenge and Solution) has not
run; adversary pass 1 on the formal development is done (ACCEPT_WITH_FIXES; aiseminar
`agents/astra/transcripts/20261017T001309_adversary-{meaning,trust}_claim_0004.md`), the reviewer
pass is pending; the independent statement reconstruction is done and compared in §13 (not
elaborated by its author); `leanchecker --fresh`, NanoDa and con-ron have not run.
`AxiomAudit.lean` prints axioms and does not fail on `sorryAx`, and `leanchecker` accepts
declarations that depend on `sorryAx` (the trust adversary's synthetic test); both outputs must be
inspected, as recorded in §10. Provenance (see `formalization.yaml` `automation.notes`):
Tightness, Equality/Mixed, Equality/Cubic, Equality/TwoRegular, the body of
`equality_classification` and `connected_transversal_le_three` were written by GPT-6 Astra and
applied mechanically; the rest by Claude Opus 5.5 coding agents. Novelty of A/B is not claimed.

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
| 2026-10-17 | `lake build` | `a470609` | exit 0, 1228 jobs |
| 2026-10-17 | `lake env lean SizeRamsey/AxiomAudit.lean` | `a470609` | exit 0; `[propext, Classical.choice, Quot.sound]` for all five records (output inspected) |
| 2026-10-17 | literal replay, argv below (25 modules) | `a470609` | exit 0, no output; `time`: 1:54.79 wall |

Literal replay (2026-10-17, HEAD `a470609`, after `lake build`): the module list is the root
`SizeRamsey`, `Challenge`, `Solution`, and every `SizeRamsey.*` module with a `.olean` under
`.lake/build/lib/lean` (22; `SizeRamsey/AxiomAudit.lean` is not a build target and has no
`.olean`), 25 in all:

```
lake env leanchecker SizeRamsey Challenge Solution SizeRamsey.AInterface SizeRamsey.Basic
  SizeRamsey.Coloring SizeRamsey.ColoringBase SizeRamsey.Components SizeRamsey.Defs
  SizeRamsey.Deletion SizeRamsey.Equality SizeRamsey.Equality.Common SizeRamsey.Equality.Cubic
  SizeRamsey.Equality.DegreeFour SizeRamsey.Equality.Extension SizeRamsey.Equality.Mixed
  SizeRamsey.Equality.TwoRegular SizeRamsey.FiniteChecks SizeRamsey.Main SizeRamsey.Reductions
  SizeRamsey.Shared SizeRamsey.SmallGraphs SizeRamsey.Tightness SizeRamsey.Universal
  SizeRamsey.Upper
```

(one argv, wrapped here for width). Exit 0, empty output; 36.30 s user, 125.32 s system,
1:54.79 wall. This replaces an earlier row recording an unlisted "all 24 built modules" sweep at
`a73d95a` (exit 0, 1 min 20 s wall), whose module list was not retained; the adversary trust pass
independently ran `lake env leanchecker -v SizeRamsey Solution Challenge`, exit 0, replaying the
same 25 modules. Normal replay trusts imported Mathlib declarations; it does not replay from an
empty environment (`--fresh`) and does not elaborate sources.

Not run: CI comparator (Linux, bubblewrap), `leanchecker --fresh`, NanoDa, con-ron; reviewer pass
on the formal development. Independent statement reconstruction: done 2026-10-17 (§13). Adversary
pass 1 (meaning, trust): done 2026-10-17, ACCEPT_WITH_FIXES. Lean sources differ between `a73d95a`
and `a470609` only in the `Solution.lean` module docstring: one comment line ("currently
admitted") replaced by two comment lines ("sorry-free as of `a73d95a`"); no statement, definition
or proof changed.

## 11. Computations

Exploratory, unretained (Astra, 2026-10-16): equality hosts with 4, 8, 12 edges are exactly the
four graphs; six 4-regular 8-vertex graphs have τ₄ = 3; all 15 degree-4 extensions of K₃,₃ − e
have τ₄ ≤ 2. None of this is Lean evidence.

## 12. Review packet

`~/aiseminar/agents/shared/claim_0004/` (informal proof VERIFIED; `STATUS.yaml` carries a
`formalization:` key with the Lean state, `EVIDENCE.md` the 2026-10-17 Lean audit); history in
`docs/STATUS_CHECK.md`. Formal adversary pass 1: aiseminar
`agents/astra/transcripts/20261017T001309_adversary-{meaning,trust}_claim_0004.md`.
Astra run directory for the formal proofs:
`~/aiseminar/agents/runs/2026-10-16_ramsey-astra/` (replies `reply_ramsey-{A7,B67,B89}-r1.md`).

## 13. Independent statement reconstruction, 2026-10-17

GPT-6 Astra wrote statements A–E from CLAIM.md alone, without access to this repository
(aiseminar `agents/astra/transcripts/20261017T002007_statement-recon_claim_0004.md`, namespace
`IndependentStatementRecon`, CONFIDENCE 0.97). Its Lean block was **not elaborated** (Mathlib was
unavailable in its sandbox); the comparison below is by reading, plus the edge-list check stated.

1. *Copies.* `IsFourCycle`/`HasFourCycle` use `v : Fin 4 ↪ V` with the four cyclic adjacencies;
   `HasFourMatching` uses `v : Fin 8 ↪ V` with adjacencies (0,1), (2,3), (4,5), (6,7). Same
   content as `IsC4Map`/`HasC4`/`HasMatching4`, which use an injective function instead of an
   embedding structure; both are non-induced.
2. *Transversal number and edge count.* `tau4` is `sInf` over cardinalities of transversals,
   nonempty via `Finset.univ`: same. `edgeCount` is `Nat.card G.edgeSet` there and
   `G.edgeFinset.card` here: the same number (unordered edges counted once).
3. *Colourings.* Red subgraph `R` with every red edge in `G`, blue part with adjacency
   `G.Adj u v ∧ ¬ R.Adj u v`; `Arrows` quantifies over all such `R`. Same as `R ≤ F`, `F \ R` and
   `ArrowsMatching4C4`.
4. *A, B.* Same hypotheses and conclusions; theirs quantify over `[Fintype V]`, ours over `Fin n`
   (equal up to relabelling, §4). B is an iff with `Nonempty (G ≃g ·)` in both. Their C4, W5 and
   K33MinusEdge are explicit edge lists and their octahedron the relation `u/2 ≠ v/2`; they agree
   with ours **on the same labels** (not only up to relabelling): `decide` proved
   `∀ i j, ours.Adj i j ↔ i ≠ j ∧ ((i,j) ∈ L ∨ (j,i) ∈ L)` for each of their lists `L`
   (`cycleGraph 4`, `wheel5`, `k33MinusEdge`) and `octahedron.Adj i j ↔ i ≠ j ∧ i/2 ≠ j/2`
   (`lake env lean` on a scratch file importing `SizeRamsey.Upper`, exit 0, 2026-10-17). Degree
   sequences: `k33MinusEdge` [2,3,3,2,3,3]; `F17` [2,3,3,2,3,4,3,3,3,2,3,3].
5. *C.* The reconstruction states **both** halves: a transversal of size at most three **and**
   an avoiding colouring. Our record states only the colouring half; the transversal half is
   `SizeRamsey.connected_transversal_le_three`. This independently confirms adversary-meaning
   finding 2; same `TODO(ben)` as §8.
6. *D.* The reconstruction defines `F17 p q` on `Fin 2 × Fin 6` and quantifies over all bridge
   endpoints `p q : Fin 6`, noting a genuine ambiguity: bridging a degree-2 or a degree-3 vertex
   of K₃,₃ − e can give non-isomorphic hosts. Our `F17` is one host: copies on 0..5 and 6..11
   (missing edges {0,3} and {6,9}), bridge {5,6}, i.e. vertex 5 (degree 3 in its copy) to vertex
   6 = vertex 0 of the second copy (degree 2). `decide` proved
   `F17.Adj (emb u) (emb v) ↔ theirs(p := 5, q := 0)` for all `u v : Fin 2 × Fin 6`, with
   `emb (c, i) = 6c + i` (same scratch run). **Modelling choice:** D-of-record is this one
   17-edge host, which is all E needs (E's infimum needs one witness); it is a specialisation of
   the reconstruction's endpoint-universal D. (Their D also states the vertex count 12, fixed by
   our type `Fin 12`.)
7. *E.* Same domain (`Fin n` for all `n`, connected, arrowing) and infimum. Their E adds an
   explicit `connectedRamseySizes.Nonempty` conjunct; ours discharges nonemptiness inside the
   proof via the F₁₇ witness (§7). Equivalent content for the value 17.
