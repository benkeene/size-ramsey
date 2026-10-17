# Brief: an executable Lean 4 formalization plan for r̂_c(4K₂, C₄) = 17, split into two parallel streams

You are rooted read-only in `~/size-ramsey`. Read, in this order: `README.md`, `docs/PROOF.md`
(the reviewed informal proof, revised after three review passes), `docs/astra/2026-10-16_scaffold_plan.md`
(your earlier plan, §§5–11), `Challenge.lean`, `Solution.lean`, every file under `SizeRamsey/`
(the current scaffold: definitions real, four interfaces admitted plus the basic lemmas),
`SizeRamsey/NOTES.md`, and the pinned Mathlib under `.lake/packages/mathlib` (Lean v4.35.0-rc3,
Mathlib c55e6e78), in particular `Mathlib/Combinatorics/SimpleGraph/` (Finite, DeleteEdges,
Connectivity, ConnectedComponent, Subgraph, Maps, Walk/Path), for exact lemma names. You can
elaborate candidate statements with `lake env lean --stdin`; do so for every signature you propose.

**Goal.** A plan that two Claude Opus 5.5 coding agents can execute *in parallel, without editing
the same files*, to prove all five statements of record with no `sorry`, no `native_decide`, only
`propext`/`Quot.sound`/`Classical.choice`, under the module system, with `lake build` green at
every commit. The proof to formalize is exactly `docs/PROOF.md` (Theorem A by the five
reductions; Theorem B by tightness lemmas and the four equality cases with the symbolic K₃,₃ − e
extension argument; C from A, B and the transversal colouring; D by the star lemma and gluing).

**Deliverable: a document with these sections.**

0. **Dependency graph and file ownership.** Final file list under `SizeRamsey/`, which stream
   owns each file, the import DAG; a frozen interface file written FIRST with full Lean text
   (shared definitions beyond `Defs.lean` if any, and the signatures of the handoff theorems).
   Suggested split to evaluate: Stream A = τ₄ semantics, deletion library (induced deletion,
   incidence deletion, exact edge counts, lifting maps), component additivity, the five
   reductions, Theorem A, the tightness lemmas, the small graphs (edge counts, τ₄ values,
   prescribed-vertex property) and the finite checks; Stream B = Theorem D (star lemma,
   K₃,₃ − e arrows (2K₂, C₄), gluing two copies, connectedness of F17), the colouring from a
   transversal, Corollary C from A and B, the endpoint, and then the equality cases of Theorem B
   consuming Stream A's tightness and small-graph lemmas (degree-4 case with the symbolic extension
   lemma, mixed case with the K₃,₃ − e reconstruction, cubic case with the crossing lemma,
   2-regular case). Say whether this split is right and where they meet.
1. **Frozen interface file(s)**: full elaborated Lean text with `sorry` bodies.
2. **Stream A work list**, in order: each declaration with its full signature, proof sketch, the
   Mathlib lemmas it uses (verified names: e.g. `SimpleGraph.card_edgeFinset_deleteIncidenceSet`,
   `SimpleGraph.induce`, `SimpleGraph.ConnectedComponent`, `SimpleGraph.Iso`, `Finset.card`
   lemmas), how to represent "vertex deletion" (choose one representation and justify it: induced
   subtype `G.induce {v}ᶜ` versus `deleteIncidenceSet`; how to transport τ₄ and edge counts
   between them), how to state and prove "edge e lies on a square", the cut lemma, component
   additivity (index type, `Finset.sum` over components), effort estimates, and "done when" tests.
3. **Stream B work list**, same shape, including: how to express the explicit graphs and prove
   their properties (decide-friendly encodings; `graphOfEdges`; DecidableRel instances), how to
   state isomorphism classes (`Nonempty (G ≃g wheel5)`) and construct the isomorphisms in the
   equality cases (vertex relabelling of a 5/6-vertex residual), the symbolic K₃,₃ − e extension
   lemma, the crossing-parity argument in the cubic case, and how the equality classification's
   strong induction is organized in Lean (induction on edge count with a universally quantified
   vertex type? on `Fin n`? on `Fintype.card`?); the colouring lemma (`incidentRed`), the star
   lemma, gluing via the two injections `Fin 6 → Fin 12`.
4. **Integration**: assembly, `#print axioms`, comparator, order in which sorries vanish.
5. **Pitfalls** (induced subgraphs and subtypes, `Fintype` instance diamonds, `edgeCount` under
   `classical`, decidability of `IsC4Map`, `Nonempty (G ≃g H)` with heterogeneous vertex types,
   long `decide`s, linter noise), each with a workaround.
6. **Milestones and checks** for the two agents, with what to commit and report.

Be concrete enough that an agent can start typing from section 1. End with `CONFIDENCE: 0-1`
and how many subagents you used.
