<!-- astra: model=gpt-6-astra effort=high status=completed thread=01a146e2-e100-7262-94ca-ff9f57eb9b8f job=20261016T184356_scaffold-size-ramsey-lean-repo-plan -->

I reconstructed the structural argument. I found no counterexample or false step, but the supplied text suppresses several indispensable lemmas. This remains an independently checked **proof attempt**, not a completed formal proof.

Two simplifications materially reduce Lean work:

1. **Discard the octahedron extension case.** Equality already implies maximum degree at most four. Every octahedron vertex has degree four; adjoining a vertex with four neighbors necessarily creates degree-five vertices.
2. **In the cubic chordless-square reduction, delete all four square vertices.** For square \(a b c d a\), let \(H=G-\{a,b,c,d\}\). Then
   \[
   |E(H)|=|E(G)|-8,\qquad \tau_4(G)\le\tau_4(H)+2.
   \]
   Add \(a,c\) to a transversal of \(H\). Any square avoiding \(a,c\) cannot contain \(b\) or \(d\), which each have at most one remaining neighbor. This avoids isolated \(b,d\) in the original residual construction.

The exact required lemma groups are:

**Transversal bookkeeping**

- `tau4_le_card`: a certified transversal bounds the minimum.
- `exists_transversal_card_eq_tau4`: the minimum is attained.
- `tau4_mono`: spanning subgraph monotonicity.
- `tau4_iso`: invariance under graph isomorphism.
- `tau4_delete_vertices_le`: \(\tau_4(G)\le |S|+\tau_4(G-S)\).
- `tau4_delete_leaf_vertex`: deleting a vertex of degree at most one preserves \(\tau_4\).
- `tau4_delete_non_square_edge`: deleting an edge lying in no \(C_4\) preserves \(\tau_4\).
- `tau4_components`: additivity over connected components, including zero contributions from isolated vertices.
- Exact edge-count formulas for deleting a vertex, two adjacent vertices, and a chordless cubic square.

The first universal theorem can avoid component additivity: induct on total edges, choose a component containing an edge, and perform a local reduction there. Equality classification still needs component additivity.

**Universal bound reductions**

- `square_supported_min_degree`: every nonisolated vertex of a square-supported graph has degree at least two.
- `degree_ge_four_reduction`: delete one vertex and at least four edges.
- `mixed_degree_reduction`: adjacent \(u,v\) with degrees two and three give
  \[
  \tau_4(G)\le1+\tau_4(G-\{u,v\}),\qquad
  |E(G-\{u,v\})|=|E(G)|-4.
  \]
  The inequality follows because \(u\) becomes a leaf after deleting \(v\). No attachment-distinctness hypothesis is needed for this universal reduction.
- `connected_two_regular_square_supported_iso_cycle4`: choose a square; degree two saturates its vertices, and connectedness excludes anything outside it.
- `cubic_chordless_square_reduction`: delete all four square vertices as above.
- `subcubic_chorded_square_strict_reduction`: a chorded square removes at least five edges at transversal cost one. Its diagonal endpoints have all neighbors inside the four vertices. Delete a tip; the remaining triangle attaches to the rest only through the other tip, so its three edges lie in no square. The deleted tip has degree at least two. In the cubic case this removes six edges. \(K_4\) satisfies the same argument.

These cases exhaust square-supported components: with all active degrees in \(\{2,3\}\), a connected component is all degree two, all degree three, or has an adjacent degree-two/degree-three pair.

**Consequences of equality**

- `equality_square_supported`: an unsupported edge contradicts the universal bound after deletion.
- `equality_max_degree_le_four`: deleting a degree-at-least-five vertex makes the bound strict.
- `equality_residual_components`: in a tight reduction, each residual component attains equality separately.
- `square_supported_no_bridge`: every edge lying in a square is not a bridge.
- `component_attachment_card_ge_two`: deleting a connected vertex set from a connected square-supported graph leaves each residual component with at least two attachment edges. A unique attachment would be a bridge.
- Exact exceptional-graph edge counts, transversal numbers, and `optimal_transversal_through_vertex`.

The last property is elementary:

- \(C_4\): any singleton.
- \(W_5\): center plus any rim vertex.
- \(K_{3,3}-e\): any two vertices in the same bipartition class.
- Octahedron: any three vertices.

The claimed minimum values still require lower bounds; certify these independently by exhibiting a surviving square after every smaller deletion.

**Degree-four equality case**

Let \(H=G-v\). It has no isolated vertices, since the original graph has minimum degree at least two. Every component has at least two attachments, so there are at most two components.

For two components, each has exactly two attachments. Choose an optimal transversal through one attachment in each. Every square through \(v\) has its other three vertices in one component and uses both attachments there. Thus the union already hits every square of \(G\), contradicting tightness.

For connected \(H\), induction gives:

- \(C_4\) extends uniquely to \(W_5\).
- \(W_5\) extends uniquely to the octahedron because its center cannot receive another edge.
- Any four-neighbor extension of \(K_{3,3}-e\) has a two-vertex transversal.
- Octahedron is excluded immediately by maximum degree four.

The fifteen \(K_{3,3}-e\) extensions are an excellent optional finite certificate. Their completeness is simply the fifteen four-subsets of six vertices. This is much cleaner than a census of unlabeled graphs.

**Mixed degree-two/degree-three equality case**

Write \(N(v)=\{u,a,b\}\), \(N(u)=\{v,t\}\).

The full argument needs these separate steps:

1. Equality excludes every chorded square using the strict reduction.
2. Hence \(a,b,t\) are distinct. If \(t=a\), a square through \(uv\) forces \(ab\), making \(u v b a u\) a chorded square with chord \(va\); similarly for \(t=b\).
3. After deleting \(u,v\), each surviving vertex loses at most one incident edge. Thus no residual vertex is isolated.
4. The three attachment edges are \(va,vb,ut\). Every residual component receives at least two, so there is exactly one component.
5. Tightness makes the residual graph square-supported. Its attachment vertices have residual degree at least two; original maximum degree three makes their residual degrees exactly two.
6. Among the inductive list, only \(C_4\) has three degree-two vertices. \(K_{3,3}-e\) has exactly two.
7. In the residual square, \(a,b\) must be opposite. If they were adjacent, the third attachment vertex \(t\) is adjacent to precisely one of them; the edge from \(v\) to the other cannot lie in a square.
8. With \(a,b\) opposite, either placement of \(t\) yields \(K_{3,3}-e\).

The source text’s assertion that “equality forces degree two” is not self-contained without steps 3–5.

**Cubic equality case**

Handshake plus \(4\mid m\) gives \(m=12,n=8\). A chordless square exists because all edges are square-supported and chorded squares are excluded.

Delete its four vertices. Tightness leaves a four-vertex, four-edge graph with transversal number one, hence containing a square and therefore exactly \(C_4\). Cubicity makes the four cross edges a perfect matching.

Choose opposite \(a,c\) in the first square and delete \(a\) and the vertex matched to \(c\). Every non-original square uses exactly two matching edges and an adjacent pair in the first square. Every such pair meets \(\{a,c\}\). This gives a two-vertex transversal, contradiction.

No enumeration of six four-regular eight-vertex graphs is needed. Such an enumeration provides evidence only unless completeness is proved; it is strictly less attractive than the structural degree-four argument.

**Upper witness**

The structural proof is small and sound, including the empty red-edge case:

- A pairwise-intersecting edge family in a bipartite graph is a star.
- Every vertex deletion of \(K_{3,3}-e\) leaves a square.
- Therefore each copy arrows \((2K_2,C_4)\).
- Inject the two disjoint red two-edge matchings into the twelve-vertex witness to obtain a red four-edge matching.

The bridge’s color never matters. This should be the first substantial completed theorem.

**Protocol**

I read `/Users/ben/aiseminar/AGENTS.md`. Its required claim promotion is: full labeled proof → adversary → written responses → reviewer → independent reconstruction, with independently rerun computations when used. Two consecutive agreements without substantive objection require a fresh third adversarial round. This audit does not satisfy that complete protocol.

I performed logical reconstruction, not a fresh exhaustive graph computation. I used **zero additional subagents**.

Read all requested template files, including full scripts and development notes, and the lab’s `AGENTS.md` plus `MISSION.md`. No writes; no further subagents.

1. **Pins and cache bootstrap**

Verified:

```text
Lean: leanprover/lean4:v4.35.0-rc3
Mathlib: c55e6e786f49471c72fbddbec5415808896aec1e
Mathlib inputRev: v4.35.0-rc3
Manifest version: 1.3.0
Manifest root name: semigroupbetti
```

The `.lake/packages` tree is 11 GiB and contains nine sibling packages: Mathlib, plausible, LeanSearchClient, importGraph, proofwidgets, aesop, Qq, batteries, Cli. Mathlib has no internal `.lake/packages`, so copying/symlinking Mathlib alone is insufficient.

Recommended execution after creating new configuration/source files:

```sh
cd /Users/ben/size-ramsey
mkdir -p .lake scripts .github/workflows
cp /Users/ben/semigroup-betti/lean-toolchain .
cp /Users/ben/semigroup-betti/LICENSE .
cp /Users/ben/semigroup-betti/scripts/check-lean-sources.py scripts/
cp /Users/ben/semigroup-betti/scripts/validate-formalization.rb scripts/
cp /Users/ben/semigroup-betti/scripts/verify-comparator.sh scripts/
cp /Users/ben/semigroup-betti/.github/workflows/ci.yml .github/workflows/

python3 - <<'PY'
import json
from pathlib import Path
p = json.loads(Path("/Users/ben/semigroup-betti/lake-manifest.json").read_text())
p["name"] = "sizeramsey"
Path("lake-manifest.json").write_text(json.dumps(p, indent=2) + "\n")
PY

test ! -e .lake/packages
cp -cRp /Users/ben/semigroup-betti/.lake/packages .lake/packages
lake build
```

`cp -cRp` is the macOS/APFS copy-on-write option; use `cp -Rp` if cloning is unavailable, at about 11 GiB extra allocation. Command semantics were not executed under this read-only session. Do not copy root `.lake/build`; the new project must build its own modules. Do not run `lake update` merely to rename the root package: preserve the flattened dependency pins exactly.

A symlink of the entire `.lake/packages` is faster but shares mutable package caches and Git checkouts, so a build/update could mutate the template. Reject it as the default for a template treated as read-only. Fresh Linux/CI builds use:

```sh
lake exe cache get
lake build
```

Cache completeness today was not measured. Template records incomplete cache on October 6, requiring approximately 4,900 locally compiled Mathlib modules; do not promise instantaneous cold builds.

Use the template Lake options verbatim, replacing package/root module names:

```toml
name = "sizeramsey"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["SizeRamsey", "Challenge", "Solution"]

[leanOptions]
pp.unicode.fun = true
autoImplicit = false
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.35.0-rc3"

[[lean_lib]]
name = "SizeRamsey"

[[lean_lib]]
name = "Challenge"

[[lean_lib]]
name = "Solution"
```

2. **Real template conventions and discrepancies**

- Every Lean source uses `module`, public imports when interface-visible, and `@[expose] public section`.
- `Solution.lean` does **not** import `Challenge`. It restates public definitions/theorems verbatim under the same names and proves them through internal library lemmas. Importing Challenge causes theorem collisions and imports admitted statements.
- Development uses separate namespaces/types to avoid defining Challenge’s public names before Solution repeats them.
- `SemigroupBetti/NOTES.md` maps informal labeled lemmas to exact Lean names, files, deviations, axioms, remaining holes. Copy that documentation pattern.
- Actual `.github/workflows/ci.yml` **already contains the Comparator job**. README says it is absent; that prose is stale. CORRESPONDENCE says Comparator/NanoDa not yet run; do not turn workflow presence into proof of a successful run.
- README advertises `nanoda.json`, but this file does **not exist**. Do not copy the illustrative direct NanoDa command as an executable recipe. Use `scripts/verify-comparator.sh`, whose actual setup is present.

3. **Verification scripts and CI**

Copy only the three infrastructure scripts above. Do not copy semigroup brute-force code/results.

`check-lean-sources.py` checks:

- `module` as first non-comment token;
- no `.lean` symbolic links;
- at most **10,000 physical lines per Lean file**, not 10,000 aggregate lines;
- Challenge at most 1,000 lines and 100 KiB;
- `.git` and `.lake` omitted.

It does **not** fully validate imports, axioms, source checkout size, or the metadata schema.

`validate-formalization.rb` verifies YAML parsing, selected required mappings, version v0.4, Apache-2.0, a nonempty ≤10,000-character description, and absence of `TEMPLATE` sentinels. Passing this is weaker than complete current Palomar metadata validation.

`verify-comparator.sh`:

- requires Linux `bwrap`, `lake`, `lean`, Python;
- checks bundled `lake`, `leanexport`, `leanchecker`, `nanoda_bin`, **con-ron**;
- reads ordinary checked-in `comparator.json`;
- rejects submitted `external_kernels`;
- removes ineffective `enable_nanoda`;
- writes a temporary configuration registering bundled NanoDa and con-ron;
- runs `lake exe cache get`;
- runs `lake comparator --config "$config"`.

Thus no external-kernel setting belongs in checked-in `comparator.json`.

Actual CI jobs: license/metadata, README submission link, source/build, Comparator. Preserve pinned Actions SHAs. Comparator installs bubblewrap and adjusts disposable Ubuntu runner AppArmor user namespace restriction. Build timeout is 350 minutes, Comparator 60 minutes. The latter may need measured adjustment if cold caches/replay exceed it; do not assume 60 minutes suffices.

During scaffolding, Comparator should legitimately fail while Solution contains holes. Either accept that red job explicitly or gate it with a visible development condition; never mark a skipped job as successful verification.

4. **Metadata**

Suggested prose:

```yaml
version: "v0.4"
project:
  name: "The connected size-Ramsey number of a four-edge matching versus a quadrilateral"
  description: >-
    A Lean formalization project for the connected size-Ramsey equality
    rhat_c(4K2,C4)=17, using a universal C4 vertex-transversal bound,
    a classification of connected equality cases through sixteen edges,
    an avoiding-colouring construction, and an explicit seventeen-edge host.
    The development is currently incomplete.
  authors: ["Ben Keene"]
  license: "Apache-2.0"
  responsible_maintainers: ["Ben Keene"]
classification:
  arxiv: [math.CO]
  msc2020: ["05C55", "05D10", "05C35"]
status:
  scope: >-
    PROOF_ATTEMPT / SCAFFOLD (2026-10-16). Statements and proof interfaces
    are under development. No complete formal proof or independent kernel
    replay is claimed. The informal structural argument requires the
    laboratory's adversarial review, response, reviewer pass, and independent
    reconstruction before equality-classification formalization begins.
  sorry_count: <actual number outside Challenge>
  sorry_in_definitions: 0
  axioms: ["propext", "Classical.choice", "Quot.sound", "sorryAx"]
review:
  status: self-assessed
  reviewers: ["Ben Keene", "GPT-6 Astra"]
  notes: >-
    One earlier adversarial pass is recorded. The current report audits the
    scaffold and identifies proof obligations; the full promotion protocol
    is not yet complete.
```

Replace the displayed count placeholder with a measured integer before running validator.

**Important correction:** current upstream PalomarTemplate explicitly counts development `sorry`s **excluding Challenge’s deliberate holes**. Semigroup template’s `sorry_count: 2` includes its Challenge holes and should not be perpetuated. At completion use `sorry_count: 0`, even if Challenge retains five or six deliberate statements of record.

The `axioms` list during scaffolding must honestly disclose `sorryAx`; at completion obtain actual names from Solution’s declarations and remove `sorryAx`.

Current policy permits omitting `repository` for substantive development; template’s explicit `repository.role: substantive-development` remains compatible.

Source provenance needs deliberate resolution:

- Known upper bound must be credited to Wang–Song–Zhang–Zhang.
- Do not claim audited novelty for A/B/C.
- Do not mechanically copy `original-proof` from the semigroup project.
- Current Palomar source-origin alternatives distinguish original results from source-based formalization, and prohibit mixing an `original-proof` entry with substantive `formalizes`/`adapts` source relationships. A project advertising both a new lower theorem and a formalized known upper theorem therefore needs an accurate source narrative and origin choice; this is a metadata issue to resolve before submission, not a reason to delay scaffolding.
- Use `type: paper` for the cited article to satisfy the stricter policy vocabulary visible in current binding documentation.

5. **Correspondence skeleton**

Recommended sections:

1. Informal statements A–D and final equality, with precise quantifiers.
2. Table: informal label ↔ Challenge declaration ↔ internal theorem.
3. Definition audit: undirected edges counted once; non-induced injective C4; eight distinct matching endpoints; transversal minimum attained; red/blue partition; connectedness convention.
4. Fin n versus arbitrary finite vertex sets, including relabeling invariance.
5. Explicit graph tables: C4, wheel convention W5, missing edge of K3,3−e, octahedron, F17 bridge endpoints.
6. Equality classification interpretation: whole-graph isomorphism; no isolated vertices hidden by a support-only equivalence.
7. Nat.sInf nonempty set/minimum argument, if used.
8. Formalized scope and remaining gaps.
9. Exact toolchain/manifests.
10. Build, sorry audit, axiom checks, kernel replay, Comparator/NanoDa/con-ron logs and exit codes.
11. Computational experiments, clearly separated from Lean coverage proofs.
12. Review packet links and dated status history.

6. **Review protocol**

`/Users/ben/aiseminar/AGENTS.md` explicitly requires:

- full `PROOF.md`, every lemma labeled;
- claim packet via `make claim TITLE=...`;
- `CLAIM.md`, `CONTEXT.md`, `EVIDENCE.md`, `PROOF.md`, `COMPUTATION.md`, `REVIEW_ASTRA.md`, `RESPONSE_CLAUDE.md`, `STATUS.yaml`;
- adversary → Claude response → reviewer → independent computational rerun where relevant → proof rewritten from scratch;
- if two consecutive reviews contain no substantive objection, a third adversary pass with fresh framing;
- each status transition dated and supported in history;
- Lean no-hole/custom-axiom check and correspondence before FORMALLY_VERIFIED.

It says formalize only once stable and important. User explicitly authorizes a scaffold now, so definitions and sorried interfaces can be built now; do not treat this as authorization to promote theorem status prematurely.

7. **Live primary policy checks**

Verified today against:

- [Current submission guide](https://palomar-registry.org/how-to-submit)
- [Binding submission standard](https://github.com/PalomarRegistry/PalomarPolicy/blob/main/CONTRIBUTING.md)
- [Current template metadata](https://raw.githubusercontent.com/PalomarRegistry/PalomarTemplate/main/formalization.yaml)
- [Submission security policy](https://github.com/PalomarRegistry/PalomarSubmission/blob/main/SECURITY.md)

Current standard confirms:

- ≤10,000 physical lines **per source file**;
- Challenge ≤1,000 lines / 100 KiB, warning above 300 lines / 32 KiB;
- checkout ≤500 MiB excluding `.git` and symbolic links, measured on submitted source before dependency/build creation;
- `.lake` is replaced by verifier, so never commit it;
- standard three allowed axioms; no `sorryAx` or `Lean.ofReduceBool`;
- exact Mathlib toolchain match;
- Challenge transitive imports cannot contain project helpers;
- no compiled artifacts outside `.lake`;
- metadata ≤256 KiB;
- full 40-character submitted commit.

The current web documentation itself has stale/conflicting descriptions of verifier deployment (older externally pinned Landrun versus local bundled bwrap/NanoDa/con-ron). Do not rewrite the known working rc3 script from those prose descriptions. Record actual script/toolchain behavior and rerun registry checks before release.

Suggested source-size guard: `git archive --format=tar HEAD | wc -c` gives a conservative tracked-source upper bound including tar overhead; require it <524288000. It is not the exact verifier accounting, but comfortably sufficient for this small structural repository.

Completed source audit and actual read-only elaboration tests using pinned Lean v4.35.0-rc3.

- The full Challenge draft sent above compiles with exactly the intended theorem `sorry` warnings.
- Generic definitions over `V : Type*` compile; only `tau4` and `edgeCount` need `[Fintype V]`. Keep statements of record on `SimpleGraph (Fin n)`.
- The stronger equality **iff** statement compiles.
- The final `sInf` equality proof sent above compiles without its own `sorry`, using C and D.
- The concrete `F17` edge count has an actual kernel `decide` proof, following the tested `edgeCount_eq_card` bridge. Complete stdin elaboration took approximately 1.8–2.0 seconds. This is not a standalone kernel or NanoDa benchmark.
- No files were written.

Verified targeted imports:

```lean
module
public import Mathlib.Combinatorics.SimpleGraph.Finite
public import Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected
public import Mathlib.Combinatorics.SimpleGraph.CycleGraph
public import Mathlib.Order.Lattice.Nat

@[expose] public section
```

Use the tested generic definitions, explicit edge lists, and theorem drafts already transmitted. The final wrapper is short enough that I recommend retaining both C/D and the `connectedSizeRamsey = 17` theorem.

Important API findings:

1. `SimpleGraph.Embedding` (`↪g`) means **induced** embedding. It is wrong for `HasC4`. An injective map with four positive adjacency conditions correctly permits diagonals.
2. `SimpleGraph.Iso` (`≃g`) is heterogeneous in vertex types. `Nonempty (G ≃g SimpleGraph.cycleGraph 4)` is correct even when `G : SimpleGraph (Fin n)`.
3. `completeBipartiteGraph V W` has vertices `V ⊕ W`. Explicit finite edge lists avoid extra transport in Challenge.
4. `(F \ R).Adj u v ↔ F.Adj u v ∧ ¬ R.Adj u v` is `SimpleGraph.sdiff_adj`.
5. `Connected` includes nonemptiness: `Fin 0` is excluded, `Fin 1` is allowed.
6. `edgeCount` defined with `classical` does not immediately `change` to the computable `edgeFinset` instance. The following compiled bridge resolves that:

```lean
theorem edgeCount_eq_card {V : Type*} [Fintype V]
    (G : SimpleGraph V) [Fintype G.edgeSet] :
    edgeCount G = G.edgeFinset.card := by
  unfold edgeCount
  congr 1
  ext e
  simp only [SimpleGraph.mem_edgeFinset]
```

The actual computed fact:

```lean
instance {n : ℕ} (es : Finset (Fin n × Fin n)) :
    DecidableRel (graphOfEdges es).Adj := by
  unfold graphOfEdges
  infer_instance

instance : DecidableRel F17.Adj := by
  unfold F17
  infer_instance

example : edgeCount F17 = 17 := by
  rw [edgeCount_eq_card]
  decide
```

Useful existing deletion API, in `Mathlib.Combinatorics.SimpleGraph.DeleteEdges`:

```lean
SimpleGraph.card_edgeFinset_deleteIncidenceSet
SimpleGraph.card_edgeFinset_induce_compl_singleton
SimpleGraph.induce_deleteIncidenceSet_of_notMem
SimpleGraph.edgeFinset_deleteIncidenceSet_eq_sdiff
```

In particular:

```lean
theorem card_edgeFinset_deleteIncidenceSet
    (G : SimpleGraph V) [DecidableRel G.Adj] (x : V) :
    #(G.deleteIncidenceSet x).edgeFinset =
      #G.edgeFinset - G.degree x
```

Use `deleteIncidenceSet` for edge-count induction while keeping the original vertex type. For equality classification and connectivity, use `G.induce {x}ᶜ`, connected to it by the existing cardinality lemma. This reduces bookkeeping but does not supply the new transversal lemmas.

`SimpleGraph.Iso.card_edgeFinset_eq` and `SimpleGraph.sum_degrees_eq_twice_card_edges` also exist.

No subagents used by this delegated auditor.

The structural route is credible, but the supplied argument is not yet a formalization specification. Two corrections should enter the write-up immediately:

- In the cubic reduction, delete **all four square vertices**. The original reduction leaves isolated vertices and does not justify treating the residual graph as connected.
- The degree-four extension of the octahedron is impossible once maximum degree four has been proved. No separate seven-vertex argument is needed.

I found no counterexample. That is an audit result, not a completed proof of A–C.

The statement draft below was elaborated against the pinned toolchain using stdin, without repository writes. Its final `sInf` wrapper also elaborates, conditional on C and D. The explicit F₁₇ edge count has an actual kernel `decide` proof. No complete repository build, Comparator run, or independent-kernel replay was performed.

**1. Bootstrap a self-contained repository while preserving the template’s pins.**

Use this layout:

```text
size-ramsey/
├── README.md
├── LICENSE
├── .gitignore
├── lean-toolchain
├── lakefile.toml
├── lake-manifest.json
├── formalization.yaml
├── comparator.json
├── Challenge.lean
├── Solution.lean
├── SizeRamsey.lean
├── SizeRamsey/
│   ├── Defs.lean
│   ├── Basic.lean
│   ├── Deletion.lean
│   ├── Components.lean
│   ├── Reductions.lean
│   ├── Universal.lean
│   ├── SmallGraphs.lean
│   ├── FiniteChecks.lean
│   ├── Equality.lean
│   ├── Coloring.lean
│   ├── Upper.lean
│   ├── Main.lean
│   └── NOTES.md
├── docs/
│   ├── PROOF.md
│   ├── STATUS_CHECK.md
│   ├── FAILED_APPROACHES.md
│   ├── verification/
│   └── astra/                    # preserve existing reports
├── scripts/
│   ├── check-lean-sources.py
│   ├── validate-formalization.rb
│   └── verify-comparator.sh
└── .github/workflows/ci.yml
```

Set `lakefile.toml` to:

```toml
name = "sizeramsey"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["SizeRamsey", "Challenge", "Solution"]

[leanOptions]
pp.unicode.fun = true
autoImplicit = false
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.35.0-rc3"

[[lean_lib]]
name = "SizeRamsey"

[[lean_lib]]
name = "Challenge"

[[lean_lib]]
name = "Solution"
```

The verified pins are:

```text
Lean:    leanprover/lean4:v4.35.0-rc3
Mathlib: c55e6e786f49471c72fbddbec5415808896aec1e
```

Execute:

```sh
cd /Users/ben/size-ramsey
mkdir -p SizeRamsey docs/verification scripts .github/workflows .lake

cp /Users/ben/semigroup-betti/lean-toolchain .
cp /Users/ben/semigroup-betti/LICENSE .
cp /Users/ben/semigroup-betti/scripts/check-lean-sources.py scripts/
cp /Users/ben/semigroup-betti/scripts/validate-formalization.rb scripts/
cp /Users/ben/semigroup-betti/scripts/verify-comparator.sh scripts/
cp /Users/ben/semigroup-betti/.github/workflows/ci.yml .github/workflows/

python3 - <<'PY'
import json
from pathlib import Path
manifest = json.loads(
    Path("/Users/ben/semigroup-betti/lake-manifest.json").read_text()
)
manifest["name"] = "sizeramsey"
Path("lake-manifest.json").write_text(
    json.dumps(manifest, indent=2) + "\n"
)
PY
```

Preserve **every dependency entry**, not just Mathlib’s revision. Do not run `lake update` merely to rename the root package.

For this Mac, prefer an APFS copy-on-write clone:

```sh
test ! -e .lake/packages
cp -cRp /Users/ben/semigroup-betti/.lake/packages .lake/packages
```

This copies all nine sibling packages and their build products while keeping subsequent writes independent. If filesystem cloning is unavailable, use `cp -Rp`, accepting approximately 11 GiB of additional storage.

Do **not** default to symlinking the template’s package tree. Lake/cache/update operations could then modify the template. Copying only `.lake/packages/mathlib` is also insufficient: its dependencies live alongside it.

Do not copy the root `.lake/build`. The new project must build its own modules.

For a fresh checkout or CI:

```sh
lake exe cache get
lake build
```

Current cache completeness was not measured. The template records an incomplete cache earlier this month; a cold build may compile substantial Mathlib dependencies.

Ignore `.lake/` and generated export/build artifacts. Never commit the local dependency cache. Copy the three infrastructure scripts above, not the semigroup experiments.

**2. Write honest metadata and preserve the actual verification workflow.**

Start `formalization.yaml` with:

```yaml
version: "v0.4"

project:
  name: "The connected size-Ramsey number of a four-edge matching versus a quadrilateral"
  description: >-
    A Lean formalization project for rhat_c(4K2,C4)=17.
    The intended proof uses a universal C4 vertex-transversal bound,
    classification of connected equality cases through sixteen edges,
    an avoiding-colouring construction, and an explicit seventeen-edge host.
    The development is currently incomplete.
  authors: ["Ben Keene"]
  license: "Apache-2.0"
  responsible_maintainers: ["Ben Keene"]

repository:
  role: substantive-development

classification:
  arxiv: [math.CO]
  msc2020: ["05C55", "05D10", "05C35"]

status:
  scope: >-
    PROOF_ATTEMPT / SCAFFOLD (2026-10-16). The statements and proof
    interfaces are being developed. The structural proof has not completed
    the laboratory review protocol. No complete formal proof, Comparator
    acceptance, or independent kernel replay is claimed.
  sorry_count: 4
  sorry_in_definitions: 0
  axioms: ["propext", "Classical.choice", "Quot.sound", "sorryAx"]
  main_results:
    - "SizeRamsey.four_mul_tau4_le_edgeCount"
    - "SizeRamsey.equality_classification"
    - "SizeRamsey.avoiding_coloring_le_sixteen"
    - "SizeRamsey.F17_spec"
    - "SizeRamsey.connectedSizeRamsey_eq_seventeen"

fidelity:
  divergences: >-
    Statements of record use graphs on Fin n. Copies of the matching
    and quadrilateral are non-induced. Equality cases are whole-graph
    isomorphism classes. The connected size-Ramsey number is defined
    by a natural-number infimum whose defining set is proved nonempty.

sources:
  - title: "Connected size Ramsey numbers of matchings versus a small path or cycle"
    authors: ["Sha Wang", "Ruyu Song", "Yixin Zhang", "Yanbo Zhang"]
    type: paper
    id: "https://doi.org/10.5614/ejgta.2025.13.1.11"
    relationship: background
    note: >-
      Theorem 1.3 supplies the known upper construction.
      Conjecture 1 predicts the general matching-versus-C4 value.
      This project supplies its own elementary proof for the upper block.

related_formalizations: []

automation:
  methods:
    - method: agent
      models: ["GPT-6 Astra (OpenAI)", "Claude (Anthropic)"]
      framework: "Codex; Claude Code"
      tool_setup: >-
        Independent mathematical review and Lean development against
        a pinned local Lean/Mathlib installation.
  notes: >-
    Record the exact Claude model and actual division of work as development
    proceeds. AI review does not itself establish theorem status.

review:
  status: self-assessed
  reviewers: ["GPT-6 Astra"]
  notes: >-
    The current scaffold audit includes independent structural and API checks.
    The full adversary-response-reviewer-reconstruction protocol remains
    outstanding. Maintainer review must be recorded separately when performed.

known_gaps:
  - "The structural proof and its formalization remain incomplete."
  - "The literature and novelty audit remains incomplete."

limitations:
  - "No novelty claim is established by this scaffold."

alignment:
  namespace: "SizeRamsey"
```

The count `4` assumes the exact four-hole scaffold in step 4. Update it when that changes.

Two template details must **not** be copied blindly:

- Current upstream metadata counts development holes **excluding deliberate Challenge holes**. Thus the completed project should say `sorry_count: 0`, even though Challenge retains five `sorry`s.
- The actual template CI **already includes Comparator**. Its README says otherwise; that prose is stale. The template also advertises a `nanoda.json` that is absent.

Retain the actual CI jobs and pinned Action revisions: metadata/license, README submission link, source/build, and Comparator. The Comparator job installs `bubblewrap` and configures its disposable Ubuntu runner. During scaffolding it should fail because of `sorryAx`; either leave that visibly failing or explicitly mark it as a skipped development gate. Do not relax its permitted axioms.

Use:

```json
{
  "challenge_module": "Challenge",
  "solution_module": "Solution",
  "theorem_names": [
    "SizeRamsey.four_mul_tau4_le_edgeCount",
    "SizeRamsey.equality_classification",
    "SizeRamsey.avoiding_coloring_le_sixteen",
    "SizeRamsey.F17_spec",
    "SizeRamsey.connectedSizeRamsey_eq_seventeen"
  ],
  "permitted_axioms": [
    "propext",
    "Quot.sound",
    "Classical.choice"
  ]
}
```

Do not put `external_kernels` or `enable_nanoda` in this file. The copied verification script supplies the bundled external kernels itself.

Before submission, reconcile source-origin metadata with the completed novelty audit. Do not declare the lower argument novel merely because this report did not locate an earlier proof. The known upper bound and its construction were rechecked in the primary paper. [Wang–Song–Zhang–Zhang, Theorem 1.3](https://www.ejgta.org/index.php/ejgta/article/download/2224/pdf_324)

**3. Install this Mathlib-only `Challenge.lean`.**

Use generic definitions internally so induced subgraphs do not require repeated reindexing. All statements of record remain on `SimpleGraph (Fin n)`.

The following surface elaborated against the pinned installation; the theorem holes remain intentional.

```lean
/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import Mathlib.Combinatorics.SimpleGraph.Finite
public import Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected
public import Mathlib.Combinatorics.SimpleGraph.CycleGraph
public import Mathlib.Order.Lattice.Nat

@[expose] public section

namespace SizeRamsey

def IsC4Map {V : Type*} (G : SimpleGraph V)
    (f : Fin 4 → V) : Prop :=
  Function.Injective f ∧
    G.Adj (f 0) (f 1) ∧
    G.Adj (f 1) (f 2) ∧
    G.Adj (f 2) (f 3) ∧
    G.Adj (f 3) (f 0)

def HasC4 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 4 → V, IsC4Map G f

def HasMatching4 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 8 → V,
    Function.Injective f ∧
      G.Adj (f 0) (f 1) ∧
      G.Adj (f 2) (f 3) ∧
      G.Adj (f 4) (f 5) ∧
      G.Adj (f 6) (f 7)

def c4Transversal {V : Type*} (G : SimpleGraph V)
    (S : Finset V) : Prop :=
  ∀ f : Fin 4 → V, IsC4Map G f →
    ∃ i : Fin 4, f i ∈ S

noncomputable def tau4 {V : Type*} [Fintype V]
    (G : SimpleGraph V) : ℕ :=
  sInf {k : ℕ |
    ∃ S : Finset V, c4Transversal G S ∧ S.card = k}

noncomputable def edgeCount {V : Type*} [Fintype V]
    (G : SimpleGraph V) : ℕ := by
  classical
  exact G.edgeFinset.card

def ArrowsMatching4C4 {V : Type*}
    (F : SimpleGraph V) : Prop :=
  ∀ R : SimpleGraph V, R ≤ F →
    HasMatching4 R ∨ HasC4 (F \ R)

def graphOfEdges {n : ℕ}
    (es : Finset (Fin n × Fin n)) : SimpleGraph (Fin n) :=
  SimpleGraph.fromRel (fun u v => (u, v) ∈ es)

def wheel5 : SimpleGraph (Fin 5) :=
  graphOfEdges
    {(0,1), (1,2), (2,3), (3,0),
     (4,0), (4,1), (4,2), (4,3)}

def k33MinusEdge : SimpleGraph (Fin 6) :=
  graphOfEdges
    {(0,4), (0,5),
     (1,3), (1,4), (1,5),
     (2,3), (2,4), (2,5)}

def octahedron : SimpleGraph (Fin 6) :=
  graphOfEdges
    {(0,2), (0,3), (0,4), (0,5),
     (1,2), (1,3), (1,4), (1,5),
     (2,4), (2,5), (3,4), (3,5)}

def F17 : SimpleGraph (Fin 12) :=
  graphOfEdges
    {(0,4), (0,5),
     (1,3), (1,4), (1,5),
     (2,3), (2,4), (2,5),
     (6,10), (6,11),
     (7,9), (7,10), (7,11),
     (8,9), (8,10), (8,11),
     (5,6)}

noncomputable def connectedSizeRamsey : ℕ :=
  sInf {m : ℕ |
    ∃ (n : ℕ) (F : SimpleGraph (Fin n)),
      F.Connected ∧ edgeCount F = m ∧ ArrowsMatching4C4 F}

/-- Theorem A: the universal quadrilateral-transversal bound. -/
theorem four_mul_tau4_le_edgeCount {n : ℕ}
    (G : SimpleGraph (Fin n)) :
    4 * tau4 G ≤ edgeCount G := by
  sorry

/-- Theorem B: all connected equality cases through sixteen edges. -/
theorem equality_classification {n : ℕ}
    (G : SimpleGraph (Fin n))
    (hconn : G.Connected)
    (hpos : 0 < edgeCount G)
    (hle : edgeCount G ≤ 16) :
    4 * tau4 G = edgeCount G ↔
      Nonempty (G ≃g SimpleGraph.cycleGraph 4) ∨
      Nonempty (G ≃g wheel5) ∨
      Nonempty (G ≃g k33MinusEdge) ∨
      Nonempty (G ≃g octahedron) := by
  sorry

/-- Corollary C: an avoiding colouring for every small connected host. -/
theorem avoiding_coloring_le_sixteen {n : ℕ}
    (F : SimpleGraph (Fin n))
    (hconn : F.Connected)
    (hle : edgeCount F ≤ 16) :
    ∃ R : SimpleGraph (Fin n),
      R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R) := by
  sorry

/-- Theorem D: the explicit seventeen-edge upper witness. -/
theorem F17_spec :
    F17.Connected ∧ edgeCount F17 = 17 ∧
      ArrowsMatching4C4 F17 := by
  sorry

theorem connectedSizeRamsey_eq_seventeen :
    connectedSizeRamsey = 17 := by
  sorry

end SizeRamsey
```

I recommend retaining **both C/D and the numerical equality**. The endpoint wrapper is already short and checked; avoiding `sInf` would save little.

Specific statement risks:

| Item | Required interpretation/check |
|---|---|
| `HasC4` | Four distinct vertices and four positive adjacencies; diagonals permitted. |
| `HasMatching4` | Eight distinct endpoints; additional edges between endpoints permitted. |
| Graph embeddings | Do **not** replace these definitions with `SimpleGraph.Embedding`: that API means an induced embedding. |
| `edgeCount` | `edgeFinset` counts unordered edges once. Its classical finite instance needs a bridge before concrete computation. |
| `tau4` | Prove the set is nonempty using `Finset.univ`, then prove attainment and minimality. |
| Blue graph | `SimpleGraph.sdiff_adj` identifies adjacency with `F.Adj u v ∧ ¬ R.Adj u v`; `R ≤ F` makes this a genuine partition of host edges. |
| Connectedness | Mathlib’s `Connected` includes nonemptiness. The one-vertex, zero-edge graph is included; `Fin 0` is excluded. |
| Equality classes | `Nonempty (G ≃g H)` is an isomorphism of the entire graph, not merely its support. |
| Named graphs | Wheel center is `4`; the missing bipartite edge is `{0,3}`; octahedron parts are `{0,1}`, `{2,3}`, `{4,5}`; bridge is `{5,6}`. |

`SimpleGraph.cycleGraph 4` uses `Fin 4`. The heterogeneous isomorphisms above elaborate. `completeBipartiteGraph (Fin 3) (Fin 3)` instead uses a sum type; explicit edge lists avoid that transport in Challenge. Prove its correspondence to `k33MinusEdge` in `SmallGraphs.lean`.

The `↔` in B deliberately includes the converse. That requires proving the four listed transversal numbers, which the classification argument needs anyway.

**4. Establish a four-hole scaffold that builds on day one.**

Use this separation:

- `Challenge.lean` contains the definitions and five admitted statements above.
- `SizeRamsey/Defs.lean` repeats the definitions, with identical names and bodies, but no statements of record.
- The development imports `Defs`, never `Challenge`.
- `Solution.lean` imports `SizeRamsey` and restates the five theorem declarations under their Challenge names. It does not redeclare definitions already supplied by `Defs`.
- `Challenge` and `Solution` are separate environments. Never import both into one module.

This slightly improves on the template’s duplication pattern: definitions are duplicated between Challenge and `Defs`, while Solution receives its definitions through the development library. Comparator must check their agreement.

Initially put exactly four admitted interfaces under `namespace SizeRamsey.Proof`:

| File | Admitted interface |
|---|---|
| `Universal.lean` | `four_mul_tau4_le_edgeCount` |
| `Equality.lean` | `equality_classification` |
| `Coloring.lean` | `avoiding_coloring_le_sixteen` |
| `Upper.lean` | `F17_spec` |

Use generic finite vertex types for the first three internal interfaces where convenient; their Solution specializations are on `Fin n`.

The first four Solution proofs are thin calls:

```lean
exact Proof.four_mul_tau4_le_edgeCount G
exact Proof.equality_classification G hconn hpos hle
exact Proof.avoiding_coloring_le_sixteen F hconn hle
exact Proof.F17_spec
```

Use this already-elaborated proof for the fifth Solution theorem:

```lean
theorem connectedSizeRamsey_eq_seventeen :
    connectedSizeRamsey = 17 := by
  have hmem :
      17 ∈ {m : ℕ |
        ∃ (n : ℕ) (F : SimpleGraph (Fin n)),
          F.Connected ∧ edgeCount F = m ∧
            ArrowsMatching4C4 F} :=
    ⟨12, F17, F17_spec⟩
  apply le_antisymm (Nat.sInf_le hmem)
  apply le_csInf ⟨17, hmem⟩
  intro m hm
  rcases hm with ⟨n, F, hconn, hcount, harr⟩
  by_contra h
  have hm16 : m ≤ 16 :=
    Nat.le_of_lt_succ (Nat.lt_of_not_ge h)
  obtain ⟨R, hRF, hR, hB⟩ :=
    avoiding_coloring_le_sixteen F hconn (hcount ▸ hm16)
  exact (harr R hRF).elim hR hB
```

This establishes the dependency chain, not the result: its axioms still include the four development holes.

Every file begins with `module`. Use `public import` for exported dependencies and `@[expose] public section` for the public definitions and lemmas. Initially unused development files can contain only their header and intended imports.

Then run:

```sh
python3 scripts/check-lean-sources.py
ruby scripts/validate-formalization.rb
lake build
```

Do not attempt to make Comparator pass by permitting `sorryAx`.

**5. Land small genuine results first: basic semantics, the upper witness, and transversal colouring.**

Implement these files before the structural classification.

| File | Intended contents | Difficulty |
|---|---|---|
| `Basic.lean` | Minimum attainment, monotonicity, isomorphism invariance, edge-count bridge | Low–medium |
| `SmallGraphs.lean` | Named-graph interpretation, degrees, counts, explicit squares | Low |
| `FiniteChecks.lean` | Small Boolean checkers and soundness, only where useful | Medium |
| `Upper.lean` | Bipartite star lemma, upper block, two-copy gluing | Medium |
| `Coloring.lean` | Colouring from an arbitrary small transversal | Medium |

Start with these signatures:

```lean
theorem tau4_le_card {V : Type*} [Fintype V]
    {G : SimpleGraph V} {S : Finset V}
    (hS : c4Transversal G S) :
    tau4 G ≤ S.card

theorem exists_transversal_card_eq_tau4 {V : Type*} [Fintype V]
    (G : SimpleGraph V) :
    ∃ S : Finset V, c4Transversal G S ∧ S.card = tau4 G

theorem tau4_mono {V : Type*} [Fintype V]
    {G H : SimpleGraph V} (h : G ≤ H) :
    tau4 G ≤ tau4 H

theorem tau4_iso {V W : Type*} [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W}
    (e : G ≃g H) :
    tau4 G = tau4 H
```

These are intended interfaces, not checked proof bodies.

The following bridge and finite proof **were checked**:

```lean
theorem edgeCount_eq_card {V : Type*} [Fintype V]
    (G : SimpleGraph V) [Fintype G.edgeSet] :
    edgeCount G = G.edgeFinset.card := by
  unfold edgeCount
  congr 1
  ext e
  simp only [SimpleGraph.mem_edgeFinset]

instance {n : ℕ} (es : Finset (Fin n × Fin n)) :
    DecidableRel (graphOfEdges es).Adj := by
  unfold graphOfEdges
  infer_instance

instance : DecidableRel F17.Adj := by
  unfold F17
  infer_instance

theorem F17_edgeCount : edgeCount F17 = 17 := by
  rw [edgeCount_eq_card]
  decide
```

The issue is real: directly changing the classical `edgeCount` expression into a computational `edgeFinset.card` failed. The bridge removes dependence on the particular `Fintype` instance.

For the upper proof, add `HasMatching2` analogously using an injective map from `Fin 4`, and prove:

```text
bipartite_pairwise_intersecting_edges_have_center
k33MinusEdge_delete_vertex_hasC4
k33MinusEdge_arrows_matching2_c4
F17_connected
F17_arrows_matching4_c4
F17_spec
```

The star lemma must handle an empty red graph. Either choose an arbitrary vertex in this nonempty block or formulate the lemma as “no red edges, or a common endpoint.”

For gluing, restrict a colouring along the two injections

```text
i ↦ i
i ↦ i + 6
```

from the two six-vertex blocks. Prove their images disjoint. Two red two-edge matchings then give eight distinct endpoints. The bridge colour is irrelevant.

For colouring from a transversal, define:

```lean
def incidentRed {V : Type*} (F : SimpleGraph V)
    (S : Finset V) : SimpleGraph V :=
  SimpleGraph.fromRel
    (fun u v => F.Adj u v ∧ (u ∈ S ∨ v ∈ S))
```

Target:

```lean
theorem avoiding_coloring_of_transversal
    {V : Type*} [Fintype V]
    (F : SimpleGraph V) (S : Finset V)
    (hS : c4Transversal F S) (hcard : S.card ≤ 3) :
    ∃ R : SimpleGraph V,
      R ≤ F ∧ ¬ HasMatching4 R ∧ ¬ HasC4 (F \ R)
```

The matching argument needs an explicit injection from the four red matching edges into `S`, choosing an endpoint from each. Injectivity follows from the eight distinct endpoints. Do not bury this step under “immediate.”

**6. Write and review `docs/PROOF.md` before implementing Theorem B.**

Use labeled sections whose labels are Lean names:

```text
Definitions and conventions
Basic.tau4_minimum_spec
Deletion.tau4_delete_non_square_edge
Deletion.tau4_delete_vertices_le
Components.tau4_components
Reductions.degree_ge_four_reduction
Reductions.mixed_degree_reduction
Reductions.two_regular_component
Reductions.cubic_chordless_square_reduction
Reductions.subcubic_chorded_square_strict_reduction
Universal.four_mul_tau4_le_edgeCount
Equality.equality_square_supported
Equality.equality_max_degree_le_four
Equality.tight_components
Equality.degree_four_case
Equality.mixed_degree_case
Equality.cubic_case
Equality.equality_classification
Coloring.connected_transversal_le_three
Coloring.avoiding_coloring_le_sixteen
Upper.k33MinusEdge_arrows_matching2_c4
Upper.F17_spec
Endpoint.connectedSizeRamsey_eq_seventeen
```

Each lemma must state:

- the exact graph and vertex hypotheses;
- the residual graph, including its vertex type;
- the exact number of removed edges;
- the transversal lifting map;
- any connectedness or non-isolation assertion;
- where induction applies.

Create the claim packet in `~/aiseminar` using its normal session procedure:

```sh
cd /Users/ben/aiseminar
make test
make journal SLUG=size-ramsey-scaffold
make claim TITLE="Connected size-Ramsey number of 4K2 versus C4"
```

Read the current journal, status, and failure records first. Record the generated claim identifier; do not invent one. Link the packet and this repository’s proof by relative repository paths plus immutable commits when available.

The governing [AGENTS.md](/Users/ben/aiseminar/AGENTS.md) requires:

> “Astra objections all answered … second Astra pass (`reviewer`) finds no gap; proof rewritten from scratch once … and the two proofs agree.”

It also requires a fresh adversarial round after two consecutive agreements without a substantive objection.

Therefore the gate is:

1. Complete labeled proof.
2. Adversary report.
3. Written responses addressing every objection.
4. Reviewer pass on the revised proof.
5. Independent reconstruction without following this proof.
6. Independent reruns of any computations used as evidence.
7. Explicit status transition with evidence pointers.

This gate applies before implementing B’s substantial proof. It does not prohibit the authorized scaffold, elementary infrastructure, or the independently understood upper construction.

Maintain `SizeRamsey/NOTES.md` in the template’s style: informal label, Lean declaration, file, deviation, remaining holes, and axiom status. Record failed formalization approaches in `docs/FAILED_APPROACHES.md`.

**7. Prove Theorem A using a reusable deletion library.**

Recommended development order:

```text
Defs
  → Basic
  → Deletion
  → Components
  → Reductions
  → Universal
```

Use two deletion representations deliberately:

- `G.deleteIncidenceSet v` keeps the original vertex type and makes `v` isolated. Convenient for edge induction.
- `G.induce {v}ᶜ` removes the vertex. Necessary when asserting residual connectedness or whole-graph isomorphism.

Mathlib already supplies, in `SimpleGraph.DeleteEdges`:

```text
card_edgeFinset_deleteIncidenceSet
card_edgeFinset_induce_compl_singleton
induce_deleteIncidenceSet_of_notMem
edgeFinset_deleteIncidenceSet_eq_sdiff
```

In particular:

```lean
#(G.deleteIncidenceSet v).edgeFinset =
  #G.edgeFinset - G.degree v
```

Do not reprove the entire deletion API.

Define a local `deleteVertices G S := G.induce (↑S)ᶜ`, with classical finite instances installed in proofs. Establish:

```text
tau4_delete_vertices_le:
  tau4 G ≤ S.card + tau4 (deleteVertices G S)

tau4_delete_leaf_vertex:
  degree G v ≤ 1 →
  tau4 (deleteVertices G {v}) = tau4 G

tau4_delete_non_square_edge:
  e ∈ G.edgeSet →
  no C4 of G uses e →
  tau4 (G.deleteEdges {e}) = tau4 G
```

Define “an edge lies on a square” using `IsC4Map` and the four unordered consecutive pairs. It must refer to an **edge of the square**, not merely two vertices appearing somewhere in its image.

Also prove:

```text
tau4_components:
  tau4 G = sum over connected components C of tau4 (G induced on C)

edgeCount_components:
  edgeCount G = sum over connected components C of edgeCount (G induced on C)
```

Include isolated components: both contributions are zero. Establish the finite component-index instance explicitly.

The five reductions should have the following mathematical contracts:

| Reduction | Residual graph `H` | Required inequalities |
|---|---|---|
| Degree ≥4 | Delete `v` | `τ(G) ≤ τ(H)+1`, `m(H)+4 ≤ m(G)` |
| Adjacent degrees 2 and 3 | Delete both `u,v` | `τ(G) ≤ τ(H)+1`, `m(H)+4 = m(G)` |
| Connected degree 2, square-supported | Remove that component | Component is C₄; cost 1, four edges |
| Cubic chordless square | Delete its four vertices | `τ(G) ≤ τ(H)+2`, `m(H)+8 = m(G)` |
| Subcubic chorded square | Delete a tip, then three sterile triangle edges | `τ(G) ≤ τ(H)+1`, `m(H)+5 ≤ m(G)` |

The last reduction removes six edges when the deleted tip has degree three. The weaker five-edge statement is the right reusable lemma for excluding chorded squares in subcubic equality cases.

Necessary local arguments:

- After deleting opposite vertices of a chordless square, the other two square vertices have at most one surviving neighbor. This justifies deleting the entire square at transversal cost two.
- In the chorded case, the diagonal endpoints have all their neighbors inside the diamond. After deleting a tip, the remaining triangle meets the outside only through the other tip. No triangle edge lies on a four-cycle.
- The mixed reduction does **not** require distinct attachment vertices for A. Deleting the degree-three vertex makes the degree-two vertex a leaf.
- A connected square-supported component whose degrees lie in `{2,3}` either has constant degree or has an adjacent mixed-degree pair. Prove this via a path between the two degree classes.

Prove A by strong induction on edge count. Unsupported edges give a strict decrease without changing `τ`. Otherwise choose a component containing an edge and apply one of the reductions.

Component additivity is not essential for this universal induction if reductions are local. It is essential for the equality argument.

Difficulty: deletion/transversal transport is **medium–high**; the exhausted-case induction is **medium** once the reductions are proved.

**8. Implement B as tightness lemmas followed by four structural cases.**

First prove:

```text
equality_square_supported
equality_max_degree_le_four
equality_residual_components
square_supported_no_bridge
component_attachment_card_ge_two
```

The tightness lemma must explicitly derive equality throughout a chain such as

\[
4\tau(G)\le 4c+4\tau(H)\le 4c+m(H)=m(G).
\]

Componentwise equality then follows because all component deficits are nonnegative and their sum is zero.

An attachment lemma should count **edges across the cut**. It is false in general to substitute “distinct attachment vertices” without proving distinctness.

Before the case analysis, establish in `SmallGraphs.lean`:

| Graph | Edges | `τ₄` | Optimal transversal through any specified vertex |
|---|---:|---:|---|
| C₄ | 4 | 1 | That vertex |
| W₅ | 8 | 2 | Center and a suitable rim vertex |
| K₃,₃−e | 8 | 2 | Two vertices in one bipartition class |
| Octahedron | 12 | 3 | Any three vertices |

The lower bounds on `τ` require checking that every smaller deletion leaves a square. Those are suitable finite proofs.

I independently recomputed these four values and the prescribed-vertex property, and checked all fifteen four-neighbor extensions of K₃,₃−e. These are exploratory computations from this session, not retained Lean certificates.

Then prove the cases.

**Degree four — `equality_degree_four_case`.**

For `H = G-v`:

1. Original minimum degree at least two implies `H` has no isolated vertices.
2. Every residual component receives at least two of the four attachment edges.
3. Hence there are one or two components.
4. With two components, each has exactly two attachments. Choose an optimal transversal containing one attachment in each component. Every square through `v` uses both attachment vertices of one component, so this union already meets it. This contradicts equality.
5. With one component, apply induction.

The four residual possibilities are:

- C₄: the extension is W₅.
- W₅: maximum degree four forces attachment to precisely the four rim vertices, giving the octahedron.
- K₃,₃−e: every four-neighbor extension has a two-vertex transversal, contradicting tightness.
- Octahedron: every old vertex already has degree four, so any attachment contradicts maximum degree four.

**Mixed degree — `equality_mixed_degree_case`.**

Write `N(v)={u,a,b}` and `N(u)={v,t}`. Required intermediate lemmas:

```text
equality_subcubic_has_no_chorded_square
mixed_attachments_distinct
mixed_residual_no_isolates
mixed_residual_connected
mixed_attachment_residual_degree_two
mixed_residual_iso_cycle4
mixed_reconstruction_iso_k33MinusEdge
```

The distinctness proof cannot be omitted. If `t=a`, a square through `uv` forces the additional adjacency producing a chorded square; similarly for `t=b`.

After distinctness, every surviving vertex loses at most one incident edge, so there are no isolates. Three attachment edges and the two-attachments-per-component lemma force residual connectedness.

Tightness makes the residual graph square-supported. The attachment vertices therefore have residual degree at least two; original maximum degree three makes that degree exactly two. Only C₄ in the inductive list has three degree-two vertices.

Finally prove that `a,b` are opposite in this C₄. If adjacent, one of `va,vb` cannot lie on a square. The resulting graph is K₃,₃−e.

This is likely the hardest proof file because it combines degree arithmetic, residual connectedness, and an explicit isomorphism.

**Cubic — `equality_cubic_impossible`.**

Use the handshake lemma and `4 ∣ m`:

\[
3n=2m,\qquad 0<m\le16
\quad\Longrightarrow\quad m=12,\ n=8.
\]

Chorded squares have already been excluded. Delete all four vertices of a chordless square. Tightness leaves four vertices, four edges, and transversal number one. Thus the residual graph contains a square and is exactly C₄.

Cubicity makes the cross edges a perfect matching. Prove:

```text
two_squares_matching_gluing_has_transversal_two
```

Choose a vertex `a` in the first square and the matched image of its opposite vertex `c`. Every mixed square uses exactly two matching edges and an adjacent pair from the first square; that pair meets `{a,c}`. This gives a two-vertex transversal, contradicting equality.

Do not leave “every mixed square has this form” implicit.

**Degree two — `equality_two_regular_case`.**

Choose a square. Its vertices already exhaust their degree-two neighborhoods. Connectedness excludes any other vertex. Construct the C₄ isomorphism directly; a general classification of finite regular graphs is unnecessary.

For finite computation, use this division:

| Task | Recommendation |
|---|---|
| Named-graph counts and small transversal facts | Kernel `decide` after computational bridge |
| Fifteen extensions of K₃,₃−e | Small witness table is reasonable |
| 256 colourings of K₃,₃−e | Fallback; structural star proof preferred |
| Six four-regular eight-vertex graphs | Omit from the proof |
| All connected sixteen-edge hosts | Omit from the primary development |

For the fifteen extensions, completeness is simply the enumeration of four-subsets of six vertices. Supply one two-vertex transversal for each subset and check it. Avoid searching for witnesses inside the kernel.

For the 256-colouring fallback, encode a colouring by `Fin 256` or eight Boolean edge bits. Do **not** enumerate `SimpleGraph (Fin 6)` and filter afterward.

A checker should test square-freeness through distinct vertices/common-neighbor pairs, with a proved soundness theorem. Do not ask `decide` to evaluate the noncomputable `tau4` definition.

The claimed six four-regular representatives require a separate completeness proof. Their small count does not make that proof free.

**9. Finish C and the endpoint without importing unnecessary machinery.**

Prove:

```lean
theorem connected_transversal_le_three
    {V : Type*} [Fintype V]
    (G : SimpleGraph V)
    (hconn : G.Connected)
    (hle : edgeCount G ≤ 16) :
    ∃ S : Finset V, c4Transversal G S ∧ S.card ≤ 3
```

Argument:

- A gives `τ₄(G) ≤ 4`.
- If `τ₄(G)=4`, A and the edge bound force `m=16`.
- B puts `G` in one of the four classes, whose edge counts are `4,8,8,12`, contradiction.
- Minimum attainment supplies `S`.

This also covers zero edges; B is used only after deriving `m=16`, so its positive-edge hypothesis is available.

Apply `avoiding_coloring_of_transversal` to obtain C. Close the Solution wrapper already given.

Recommended discharge order:

1. Basic semantics and explicit edge counts.
2. Theorem D.
3. Colouring from a transversal.
4. Deletion and component infrastructure.
5. Theorem A.
6. Named-graph extremality and small finite checks.
7. Theorem B, after its review gate.
8. Connected three-vertex transversal and C.
9. All five Solution records and verification.

A theorem whose proof merely calls an admitted lemma is not an early completed theorem. Audit D’s dependency axioms separately when claiming that milestone.

**10. Build the correspondence record and run the full verification ladder.**

`CORRESPONDENCE.md` should contain:

1. Informal A–D and endpoint, with exact quantifiers.
2. Table mapping each statement to its Challenge and internal declaration.
3. Non-induced copy semantics.
4. Edge-count interpretation and finite-instance independence.
5. Transversal minimum nonemptiness and attainment.
6. Red/blue partition argument.
7. Named-graph adjacency tables and isomorphisms.
8. `Fin n` coverage of arbitrary finite graphs, via relabeling invariance.
9. Whole-graph versus support-only equality classification.
10. Nonemptiness of the set defining `connectedSizeRamsey`.
11. Formalized scope, remaining gaps, and review-packet links.
12. Exact commands, commit, exit codes, axiom output, and replay logs.

Create `SizeRamsey/AxiomAudit.lean`, importing **Solution only**, with:

```lean
module
import Solution

#print axioms SizeRamsey.four_mul_tau4_le_edgeCount
#print axioms SizeRamsey.equality_classification
#print axioms SizeRamsey.avoiding_coloring_le_sixteen
#print axioms SizeRamsey.F17_spec
#print axioms SizeRamsey.connectedSizeRamsey_eq_seventeen
```

Run:

```sh
lake build
lake env lean SizeRamsey/AxiomAudit.lean

rg -n '\b(sorry|admit|axiom)\b' \
  SizeRamsey Solution.lean SizeRamsey.lean

rg -n 'native_decide|Lean\.ofReduceBool' \
  SizeRamsey Solution.lean SizeRamsey.lean

python3 scripts/check-lean-sources.py
ruby scripts/validate-formalization.rb

lake env leanchecker Solution
lake env leanchecker --fresh Solution
```

Interpret the `rg` output: comments and `#print axioms` are not admitted proofs. Conversely, a clean textual scan does not replace dependency-axiom checking.

Replay every project module as well as Solution. `leanchecker Solution` alone is not equivalent to replaying its complete import closure.

On Linux:

```sh
./scripts/verify-comparator.sh
```

The copied script registers the bundled **NanoDa and con-ron**, then invokes Comparator. Record successful completion of each actual checker; the presence of a CI job proves nothing about its result.

Do not use the template’s standalone `nanoda.json` recipe: the referenced configuration file is missing. Comparator is the concrete available route.

Current requirements distinguish **10,000 lines per Lean source file** from an aggregate source limit. Challenge has the stricter 1,000-line/100-KiB limit. Keep this structural project below 10,000 lines in aggregate as an engineering target, but do not misstate the policy. [Current submission guide](https://palomar-registry.org/how-to-submit)

Check the submitted source snapshot conservatively:

```sh
git archive --format=tar HEAD | wc -c
```

Require it comfortably below `524288000` bytes; tar overhead makes this a conservative bound for this small repository. Do not count the untracked 11-GiB dependency cache as submitted source. The checkout limit and source scanning rules are specified in the [binding submission standard](https://github.com/PalomarRegistry/PalomarPolicy/blob/main/CONTRIBUTING.md).

The local scripts are partial checks: the Ruby validator is not a complete schema validator, and the Python checker does not audit imports or axioms.

At completion:

- Development `sorry_count` becomes zero.
- Challenge retains its intentional holes.
- Solution’s dependencies use only the permitted standard axioms.
- Metadata records actual review and replay results.
- Submission identifies the full immutable commit.
- Novelty remains a separate claim requiring its own evidence.

**11. Treat these as the ranked implementation risks and first experiments.**

| Rank | Risk | First action |
|---:|---|---|
| 1 | Equality reconstruction is still compressed prose | Finish the mixed-case proof with explicit attachment and isomorphism lemmas before coding B |
| 2 | Vertex deletion silently changes connectedness or retains isolates | Prototype singleton deletion, mixed deletion, and whole-square deletion first |
| 3 | Componentwise tightness is assumed rather than proved | Establish additive `τ` and edge-count formulas, then one reusable tightness lemma |
| 4 | Wrong copy notion changes the theorem | Keep injective adjacency maps; audit against induced embeddings |
| 5 | Classical definitions obstruct finite reduction | Use the checked `edgeCount_eq_card` bridge and Boolean certificate checkers |
| 6 | A small representative list is mistaken for exhaustive coverage | Use complete finite attachment domains; avoid unlabeled graph censuses |
| 7 | Challenge/library definitions drift | Keep bodies synchronized and run Comparator throughout integration |
| 8 | Replay cost exceeds expectations | Benchmark a small certificate batch through the actual external checkers before expanding it |
| 9 | Novelty and source provenance remain unresolved | Complete the correction/recent-paper audit separately; make no novelty claim meanwhile |

The first three risks dominate the formalization. I would budget a checkpoint after deletion infrastructure plus D, then another after A. The earlier 10–20-person-day estimate is not established by measured Lean progress; do not treat it as a delivery commitment.

I used **three subagents**: one independently reconstructed and attacked the structural argument, one inspected Mathlib and elaborated the statement/endpoint drafts, and one audited bootstrap, metadata, CI, and current Palomar requirements. I reconciled their reports and independently ran the small named-graph and extension checks.

CONFIDENCE: 0.88