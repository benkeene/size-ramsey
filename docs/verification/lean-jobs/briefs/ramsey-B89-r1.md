[size-ramsey] stream B · Equality/TwoRegular.lean + Equality.lean (strong induction) + Coloring.lean (B8, B9) · round 1 — brief ramsey-B89-r1

Read root: this directory (a detached read-only snapshot of branch `lean/stream-B` at commit d1c156b). Lean `leanprover/lean4:v4.35.0-rc3`, Mathlib `c55e6e786f49471c72fbddbec5415808896aec1e`.
Every import of the targets is built (`lake build` succeeded here). Elaborate a modified copy of a target file with `lake env lean --stdin < <copy>` (pipe it; you cannot write files). A probe confirmed this works in your sandbox for this toolchain.

## Task
Replace each `sorry` in the targets below by a complete proof. Signatures, definitions and all other files are frozen. If a statement is false or unprovable from its hypotheses — including because an admitted contract it depends on is stated wrongly — report it with a `contract` block and explicit data (a concrete graph on `Fin n`); that outcome is as valuable as a proof.

## Ground truth (compiler output at d1c156b; trust this over any status table in the repo)
`lake build`: success with `declaration uses sorry` warnings only. Run `lake env lean <file>` on each target file to see the exact current sorry lines yourself. Some declarations your proofs may use are themselves still admitted on this snapshot (Stream A contracts in Components.lean, Reductions.lean, Universal.lean, Tightness.lean, SmallGraphs.lean, FiniteChecks.lean may have `sorry` bodies here even though another agent is proving them concurrently on the live branch). That is expected: prove your targets against the admitted *signatures*; `#print axioms` of your results will then show `sorryAx` only through those named dependencies, which the judge accepts. List every admitted dependency you rely on in a `note id=general` block. `SizeRamsey/NOTES.md` status columns are stale; the compiler is the truth.
Equality.lean assembles Theorem B by strong induction from the four case files (DegreeFour, Mixed, Cubic, TwoRegular) and the tightness/small-graph contracts; on this snapshot several of those case theorems are admitted and are being proved concurrently elsewhere. Prove the induction against their signatures. Coloring.lean's `connected_transversal_le_three` (B9) follows from Theorems A and B plus the small-graph τ₄ values; `avoiding_coloring_le_sixteen` is already assembled from it.

## Targets
| id | decl | file:line | sig |
|---|---|---|---|
| ramsey-B89-r1.1 | SizeRamsey.Plan.equality_two_regular_case | SizeRamsey/Equality/TwoRegular.lean:20 | e3e937be |
| ramsey-B89-r1.2 | SizeRamsey.Plan.classification_of_step | SizeRamsey/Equality.lean:25 | bcc646a7 |
| ramsey-B89-r1.3 | SizeRamsey.connected_transversal_le_three | SizeRamsey/Coloring.lean:18 | f93f8177 |
Full signatures: exactly as in the files (read them; do not retype from memory). `sig` is the sha256 prefix of the signature text from `theorem` to just before `:=`; copy it verbatim into your blocks.

## Read (intended route; not established Lean)
- `docs/PROOF.md` lines 21–29 ("## Induction framework"), 73–124 ("## Equality (Theorem B)"), 125–129 ("## Coloring (Corollary C)").
- `docs/astra/2026-10-16_lean_plan.md` lines 1958–2071 (§3 B8 Two-regular case and strong induction; B9 C and endpoint); §4 Integration (lines 2072–2139) and §5 pitfalls (lines 2140–2168).
- Definitions: `SizeRamsey/Defs.lean` (`IsC4Map`, `HasMatching4`, `c4Transversal`, `tau4`, `edgeCount`, `graphOfEdges`, named graphs `wheel5`, `k33MinusEdge`, `octahedron`, `F17`), `SizeRamsey/Shared.lean` (`erase`, `compGraph`, `EdgeOnSquare`, `SquareSupported`, `HitsDeleted`, `liftTransversal`, `componentVerts`, `attachmentEdges`, …). Both frozen.
- Proved results on this snapshot (names; read the files): Basic.lean (`tau4` attainment, `tau4_le_card`, `tau4_mono`, `tau4_iso`, `edgeCount_iso`, `tau4_eq_zero_iff`, `tau4_eq_of_certificates`), SmallGraphs.lean and FiniteChecks.lean (small-graph data, prescribed-optimal transversals, `k33_square_avoids_vertex`, `k33_triangle_free`), Deletion.lean (`tau4_erase_lift`, `tau4_delete_vertices_le`, `transversal_iff_no_square_erase`, `erase_edgeCount`, `erase_singleton_counts`, `erase_degree`, `tau4_delete_non_square_edge`, `tau4_delete_leaf_vertex`, `erase_card`), Upper.lean and ColoringBase.lean (Theorem D, generic colouring).

## Rules
Frozen byte-for-byte: `SizeRamsey/Defs.lean`, `SizeRamsey/Shared.lean`, `SizeRamsey/AInterface.lean`. Never edit: `Challenge.lean`, `Solution.lean`, `SizeRamsey/AxiomAudit.lean`, `SizeRamsey/Main.lean`, `SizeRamsey.lean`, and any file not listed as a target. Only `SizeRamsey/Equality/TwoRegular.lean`, `SizeRamsey/Equality.lean`, `SizeRamsey/Coloring.lean` may change (bodies, `private` helpers, allowed imports). Do not relocate declarations between files.
ALLOWED IMPORTS: any `public import Mathlib.*`; among project modules only `SizeRamsey.AInterface`, `SizeRamsey.Equality.*`, `SizeRamsey.ColoringBase` (Coloring.lean already imports ColoringBase and Equality) (respect the import DAG in plan §0: Equality files import `AInterface`, never the reverse; Tightness imports `Universal`, never `Equality`).
Permitted axioms: propext, Classical.choice, Quot.sound (plus `sorryAx` only via the admitted dependencies you name). Keep the module header (`module`, `public import`, `@[expose] public section`). `set_option maxHeartbeats N in` with N ≤ 1000000 is allowed before a single declaration. Kernel `decide` on small `Fin n` facts is fine; `native_decide` is forbidden; do not brute-force the equality classification by finite census — the plan's symbolic argument is the route.

## REPLY FORMAT (machine-applied; deviations are discarded, not interpreted)

A script parses your reply. Prose outside the blocks below is read only if the script fails;
put explanations in `note` blocks.

1. PROOF. For each target you solve, exactly one block:

   ```lean patch id=<ID> decl=<FullyQualifiedName> sig=<SIG> mode=body
   <the complete text that follows `:=` in the declaration: starting with `by` or a term,
    indented as it will appear in the file; no signature, no `theorem` line>
   ```

   The script keeps the file's signature byte-for-byte through `:=` and replaces everything after
   it with your text. Copy `id`, `decl`, `sig` from the target table. You cannot change a
   signature; if one is wrong, use a `contract` block (item 6).

2. HELPER. A new auxiliary lemma, inserted immediately before the declaration named in `before=`
   (same namespace and section variables), full text:

   ```lean patch id=<ID>.h<k> mode=helper before=<FullyQualifiedName>
   private theorem <fresh_name> ... := by
     ...
   ```

   Only `private theorem` / `private lemma`. The name must not exist anywhere in the project.

3. IMPORT. Only modules from ALLOWED IMPORTS, one per line:

   ```lean patch mode=import
   public import Mathlib.Algebra.MvPolynomial.Degrees
   ```

4. Only the target file(s) may change. Never touch frozen files, Challenge.lean, Solution.lean,
   AxiomAudit.lean, or files of the other stream.

5. FORBIDDEN anywhere in your Lean text: sorry, admit, native_decide, decide +native, axiom,
   opaque, unsafe, partial, implemented_by, extern, csimp, run_cmd, run_tac, run_elab, #eval,
   elab, macro, syntax, notation, initialize, open Lean, addDecl, Environment, instance,
   `attribute [...]` other than `attribute [local instance] Classical.propDecidable`,
   `set_option` other than `set_option maxHeartbeats N in` with N ≤ 1000000. Any `debug.` option.
   Only propext, Classical.choice, Quot.sound may appear in `#print axioms`.

6. CONTRACT. If a target is false or unprovable from its hypotheses, or a frozen interface must
   change (never applied; it goes to a human; as valuable as a proof):

   ```contract id=<ID> decl=<FullyQualifiedName>
   PROBLEM: <one sentence>
   EVIDENCE: <counterexample with explicit data, or the precise missing hypothesis>
   PROPOSED SIGNATURE: <full Lean text>
   CONSUMERS AFFECTED: <declarations that use it>
   ```

7. DRAFT. A target you could not finish: your best partial proof (may contain `sorry`; never
   applied; shown to the next round), and the exact missing lemma as a Lean statement in a note:

   ```lean patch id=<ID> decl=<FullyQualifiedName> sig=<SIG> mode=draft
   ...
   ```

8. NOTES: ```note id=<ID>``` blocks, at most 15 lines each. Number any other finding (plan error,
   interface defect) inside a `note id=general` block.

9. End with exactly one summary block. "elaborated": true means you piped the whole modified
   file through `lake env lean --stdin` in your sandbox and it printed no error and no
   `declaration uses sorry` warning for that id. If you could not run Lean, say false.

   ```proofloop-summary
   {"brief": "ramsey-B89-r1", "base": "d1c156b",
    "results": [{"id": "<ID>", "status": "PROVED|DRAFT|CONTRACT|SKIPPED", "elaborated": true,
                 "lean_output": "<last 3 lines of the lake env lean output>"}],
    "helpers": ["<names>"], "imports": ["<modules>"], "subagents": <n>, "confidence": <0-1>}
   ```

Do not paraphrase this format, do not nest blocks, do not use triple backticks inside a block.
