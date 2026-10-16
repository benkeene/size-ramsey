# Brief: a step-by-step report for building the `size-ramsey` Lean formalization repository

You are rooted (read-only) in `~/semigroup-betti`, Ben Keene's completed Palomar-registered
Lean 4 / Mathlib formalization of β₁ ≤ 2w for four-generated numerical semigroups. **It is the
template**: read `README.md`, `Challenge.lean`, `Solution.lean`, `formalization.yaml`,
`comparator.json`, `CORRESPONDENCE.md`, `lakefile.toml`, `lean-toolchain`, `lake-manifest.json`,
`.github/workflows/ci.yml`, `scripts/`, and `SemigroupBetti/NOTES.md` for the layout, the module
system conventions (`module`, `public import`, `@[expose] public section`), the Palomar metadata,
and the verification scripts. A compiled Mathlib for the pinned toolchain (v4.35.0-rc3) exists
in this repo's `.lake` (11 GB), so a new repo that pins the same toolchain and Mathlib revision
can reuse it instead of rebuilding.

**The new repository** is `~/size-ramsey` (created today, empty apart from a README). Its goal is
a Palomar-compatible formalization of the connected size-Ramsey result in the inlined workflow
reply (read the whole inlined file, especially §2 "Mathematics first", §7 "Verification and Lean
plan", and the two embedded subagent reports on the transversal proof and on census/Lean cost):

- **Theorem A (universal bound).** For every finite simple graph G, 4·τ₄(G) ≤ |E(G)|, where
  τ₄(G) is the minimum size of a vertex set meeting every (not necessarily induced) 4-cycle.
- **Theorem B (equality through 16 edges).** Among connected graphs with 0 < |E(G)| ≤ 16,
  equality holds only for C₄, the 4-wheel W₅, K₃,₃ − e, and the octahedron K₂,₂,₂.
- **Corollary C (lower bound).** Every connected simple graph with at most 16 edges has R ≤ F
  with no red 4-edge matching and no blue C₄ (blue = F minus R).
- **Theorem D (upper bound).** The explicit 12-vertex, 17-edge graph F₁₇ (two copies of
  K₃,₃ − e joined by a bridge) is connected and arrows (4K₂, C₄).
- Hence r̂_c(4K₂, C₄) = 17 (define the connected size-Ramsey number as a Nat.sInf or state the
  two inequalities separately; recommend which, with Palomar's Mathlib-only Challenge in mind).

All of this is currently PROOF_ATTEMPT: the informal argument in the inlined reply has passed
one adversarial pass and is not yet written up or independently reconstructed.

**What the report must contain** (numbered steps Claude Code will execute in order; be concrete:
file names, declaration names, exact Lean statement drafts, commands):

1. **Repository layout and bootstrap.** The directory tree; `lakefile.toml`, `lean-toolchain`,
   `lake-manifest.json` strategy (reuse the template's pins and copy/symlink its
   `.lake/packages/mathlib`? or `lake exe cache get`? give the exact commands and the trade-offs);
   `formalization.yaml` fields for this project (name, description, classification: arXiv
   math.CO, MSC 05C55/05D10/05C35; status scope text); `comparator.json`; `LICENSE`;
   `CORRESPONDENCE.md` skeleton; CI workflow adapted from the template; the `scripts/` to copy.
2. **`Challenge.lean` draft.** Mathlib-only statements of record (Verso/Palomar cannot import a
   whole-Mathlib or project-internal module; use targeted imports as the template does). Write
   the actual Lean text for: `SimpleGraph (Fin n)`-based definitions of `HasMatching4`, `HasC4`,
   `c4Transversal`/`tau4`, the arrowing predicate, the statement of Theorem A, Theorem B (as a
   disjunction of isomorphism classes, say how to state "is isomorphic to C₄" with Mathlib's
   `SimpleGraph.Iso`/`≃g` and `SimpleGraph.cycleGraph`, `completeBipartiteGraph`, etc.),
   Corollary C, Theorem D, and the final equality. Say what is risky in each statement
   (non-induced copies, injectivity, the definition of edge count `F.edgeFinset.card`,
   `Fintype` instances, decidable equality) and how the statements will be checked against the
   informal theorem in CORRESPONDENCE.md.
3. **Proof decomposition into a development library** `SizeRamsey/` with one file per group of
   lemmas, in dependency order, each with its intended statements (Lean signatures where you can,
   prose where the statement is still open), the proof strategy, and a difficulty estimate:
   edge-deletion of non-square edges preserving τ₄; vertex deletion inequalities; the five
   reduction cases of the universal bound; the equality classification cases (degree-4 vertex
   with the four residual graphs, the degree-3/degree-2 reduction reconstructing K₃,₃ − e,
   the cubic 12-edge case, pure degree 2); the colouring corollary; the K₃,₃ − e arrowing lemma
   and the two-copies gluing. Which parts are better done by `decide`/finite case checks (e.g.
   the 15 degree-4 extensions of K₃,₃ − e, the six 4-regular 8-vertex graphs, the 256 colourings
   of K₃,₃ − e) versus structural proofs, and how to state those finite checks so kernel `decide`
   is feasible (no `native_decide`, Palomar policy).
4. **Scaffolding order.** What to `sorry` first so that `lake build` passes on day one with the
   full statement chain present (Challenge with sorries, Solution importing the library with
   sorried lemmas), and the order to discharge sorries so that the first real theorem (suggest:
   Theorem D or the colouring corollary from a transversal) lands early.
5. **Informal proof write-up.** Where in the repo the human-readable proof lives (`docs/PROOF.md`),
   its required structure (every lemma labeled, matching the Lean names), and the review
   protocol it must pass before the Lean work on Theorem B starts (the lab's AGENTS.md:
   adversary → response → reviewer → independent reconstruction; claim packet in `~/aiseminar`).
6. **Correspondence and verification.** The `CORRESPONDENCE.md` argument, `#print axioms`
   checks, `rg` for sorry/admit/axiom, `leanchecker`, NanoDa, comparator, file-size/line limits
   (Challenge ≤ 1,000 lines / 100 KiB; source ≤ 10,000 lines; checkout ≤ 500 MiB).
7. **Risks and open questions** about the formalization specifically (Mathlib API gaps for
   subgraph deletion and cycle transversals, isomorphism-class statements, finite-check cost),
   ranked, with what to try first.

Do not assume the informal proof is correct; where a step looks under-justified for
formalization, say so and propose the lemma that would be needed. End with `CONFIDENCE: 0-1`
on the plan being executable as written, and state how many subagents you used.
