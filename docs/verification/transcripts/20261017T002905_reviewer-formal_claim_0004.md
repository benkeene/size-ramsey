<!-- astra: model=gpt-6-astra effort=xhigh status=completed thread=01a1481e-e6fc-7551-84d1-2d4975be814b job=20261017T002905_reviewer-claim-0004-formal-r-c-4k2-c4-17-pass-1 -->

1. **No gap found in the strong induction or mixed case.** I read [Equality.lean](/Users/ben/size-ramsey/SizeRamsey/Equality.lean:25) and [Mixed.lean](/Users/ben/size-ramsey/SizeRamsey/Equality/Mixed.lean:20) end to end, and checked the relevant definitions, reductions, tightness lemmas, component-cut lemma, small-graph discriminator and degree-four induction call sites.

2. **The induction measure and universe quantification are correct.** `classification_of_step` quantifies simultaneously over all finite vertex types in one universe and inducts on `edgeCount H` ([Equality.lean:37](/Users/ben/size-ramsey/SizeRamsey/Equality.lean:37)). `SmallerClassified` requires connectedness, strictly positive edge count, strict edge-count decrease and tightness ([Shared.lean:42](/Users/ben/size-ramsey/SizeRamsey/Shared.lean:42)). The induction recovers the inherited `≤16` bound from strict decrease at Equality:47–50. Subtypes and component-support types remain in the same universe.

   Actual recursive applications satisfy this contract:
   - Mixed: `edgeCount H + 4 = edgeCount G`, at Mixed:296–302; application at 335.
   - Degree-four connected residual: four edges removed, DegreeFour:370–383.
   - Degree-four components: `component_edgeCount_le` supplies an upper bound by the residual edge count, DegreeFour:119–125.

3. **The dispatch is exhaustive.** Equality:72–80 first separates a degree-four vertex. Otherwise, tightness bounds every degree above by four; exclusion of four makes the upper bound three. Connectedness and positive edge count give minimum degree two. `degree_two_three_cases`, proved by a boundary edge on a path between the degree classes ([Reductions.lean:315](/Users/ben/size-ramsey/SizeRamsey/Reductions.lean:315)), yields exactly the all-two, all-three or adjacent-two/three alternatives. There is no omitted irregular subcubic case.

4. **The mixed proof supplies its structural premises rather than assuming them.** Its mathematical argument is:

   - Choose adjacent `u,v` of degrees two and three and a supporting square `u,v,a,t,u`. Tight subcubic squares have no diagonals. The third neighbour `b` of `v` is distinct from `a,t`; in particular `b=t` would make the forbidden diagonal `vt` (Mixed:177–250).
   - Delete `u,v`. Every surviving vertex loses at most one neighbour; original minimum degree two therefore leaves positive residual degree (260–295).
   - The mixed reduction removes four edges and costs at most one transversal vertex. The universal inequality forces residual tightness (296–302).
   - Exactly three edges cross the deleted set, while every residual component receives at least two. Therefore the residual is connected (307–334).
   - Apply induction. The three distinct attachment vertices have residual degree exactly two, by residual minimum degree two and original maximum degree three (335–357). Of the four classified graphs, only C₄ has three degree-two vertices; this finite discriminator is proved in [SmallGraphs.lean:181](/Users/ben/size-ramsey/SizeRamsey/SmallGraphs.lean:181).
   - If `a,b` were adjacent in that residual C₄, support of `vb` would either force a residual triangle or contradict the exact neighbourhoods. The detailed split is Mixed:61–84; it does not simply assert the questionable “must pass through `u`” shortcut.
   - Normalize the residual cycle as `a,t,b,s`, then explicitly label all six vertices `[u,a,b,s,v,t]`. The map is proved injective, surjective and adjacency-preserving, giving precisely K₃,₃−e (86–163; application 358–366).

5. **No vacuous structural helper found.** The finite cycle-arrangement lemma at Mixed:20–35 proves an ordinary finite proposition by `decide`. The normalization and final-label helpers use concrete neighbourhood and residual-isomorphism premises established at their call sites.

   I independently compiled a concrete realization using K₃,₃−e with `u=0`, `v=4`, residual order `[1,5,2,3]`. Lean verified:
   - bijectivity of that residual order;
   - distinct attachment vertices;
   - `N(u)={4,5}` and `N(v)={0,1,2}`;
   - exact residual C₄ adjacency;
   - tightness and square support;
   - maximum degree at most three;
   - the selected degree-two/degree-three edge.

   The trailing `mixed_reconstruction` theorem at Mixed:368–380 is merely an isomorphism-constructor wrapper. It is not used to conceal a missing reconstruction: the actual branch uses the fully proved `b67_mixed_final_labels`.

6. **No circular use of Theorem B.** Mixed imports only `Equality.Common`; Common imports `AInterface`; AInterface imports `Tightness` and `SmallGraphs`. `Tightness` imports `Universal`, which imports `Reductions`, never `Equality`. `classified_tight` proves the converse from independently established small-graph data ([SmallGraphs.lean:158](/Users/ben/size-ramsey/SizeRamsey/SmallGraphs.lean:158)). Thus neither tightness facts nor the converse assume the classification being proved.

7. **Actual verification results.**
   - `lake env lean SizeRamsey/Equality/Mixed.lean`: exit **0**, only the unused `hm` warning at line 169.
   - `lake env lean SizeRamsey/Equality.lean`: exit **0**, empty output.
   - Concrete witness and axiom audit through `lake env lean --stdin`: exit **0**. Both `SizeRamsey.Plan.equality_mixed_degree_case` and `SizeRamsey.Proof.equality_classification` report exactly `[propext, Classical.choice, Quot.sound]`.

   The first heredoc invocation was rejected because the shell attempted to create a temporary file under the read-only policy. I reran the actual Lean input successfully using Python subprocess stdin; no files were written.

8. **Minor stale documentation, not a mathematical objection.** [docs/PROOF.md:17](/Users/ben/size-ramsey/docs/PROOF.md:17) still says: “Lean formalization of Theorem B may now start.” This conflicts with the completed-development status elsewhere. The mixed-case prose at lines 100–110 correctly conveys the argument, although the formal proof is appreciably more explicit about the opposite-vertices step.

No subagents used by this delegated agent. Confidence **0.99** in these scope-specific findings.

1. **A–E semantic comparison, independently read from source.**

   | Record | Relation to CLAIM.md | Evidence |
   |---|---|---|
   | A | Equal up to finite relabelling. | `Solution.lean:51–53`; the development is generic in `[Fintype V]`. I independently elaborated transport from this record via `G.overFinIso rfl`. |
   | B | Stronger than the literal “only”: Lean proves iff. | `Solution.lean:56–61`. Connectedness, `0 < edgeCount G`, and `≤16` are all retained. The conclusion concerns whole-graph isomorphism. |
   | C | Contains only the colouring conclusion. Full CLAIM C is proved by two declarations together. | Record `Solution.lean:64–67`; omitted conjunct `Coloring.lean:18–44`. |
   | D | One specified host; weaker than an endpoint-universal interpretation. Equal to a construction with explicitly fixed bridge endpoints. | `Defs.lean:73–75`: bridge `{5,6}`, hence local endpoints 5 and 0. `Solution.lean:70–71`. |
   | E | Equal to the finite connected size-Ramsey minimum. | Definition `Defs.lean:79–81`; proof `Solution.lean:73–84`. |

2. **Underlying definitions correctly express the mathematics.**

   - `Defs.lean:23–38`: injections force four/eight distinct vertices; adjacency assertions impose precisely a non-induced C₄ or four disjoint edges. No absent-edge requirement occurs.
   - `Defs.lean:41–42`: τ₄ is an infimum over actual transversal cardinalities. `Basic.lean:44–51` supplies `Finset.univ` and invokes `Nat.sInf_mem`; no empty-infimum convention is used.
   - `Defs.lean:45–47`: `edgeCount` counts the edge finset. Mathlib `Finite.lean:59–64,124–128` identifies it with the cardinality of the unordered edge set. I independently elaborated `edgeCount G = Nat.card G.edgeSet`.
   - `Defs.lean:51–52`: `R ≤ F` ranges over every red spanning subgraph. Mathlib `Basic.lean:266–267` gives blue adjacency exactly `F.Adj u v ∧ ¬R.Adj u v`. I elaborated both partition equations.
   - Mathlib `Connectivity/Connected.lean:314–316` includes `Nonempty V`. Thus `Fin 0` cannot qualify, while C includes the connected singleton. B additionally excludes it through positive edge count.
   - There is no bound on `n` in E. Finite relabelling loses no finite graph, and the Ramsey set contains 17 explicitly at `Solution.lean:74–76`. Lines 77–84 establish both inequalities.

3. **C scope: correspondence repair RESOLVED; no mathematical obstruction remains.**

   Meaning finding 1 requested explicitly mapping CLAIM C to both declarations **or** expanding the record. `CORRESPONDENCE.md:34–43,108–113` now does the former. Calling record expansion “ACKNOWLEDGED-OPEN” should not imply that the theorem lacks a formal proof.

   `Coloring.lean:23–44` covers zero-edge cases without a separate branch: assuming the minimum exceeds three forces `m=16`, then equality classification contradicts the listed graphs’ edge counts. The colour construction is fully proved in `ColoringBase.lean:39–93`.

   C’s omission from the five-target list does not weaken E: E only needs the avoiding-colouring conclusion. Adding a sixth comparator target is additional packaging assurance, not missing mathematics.

4. **D scope: transparent specialisation, but canonical CLAIM should be precise.**

   `CORRESPONDENCE.md:26–27` says:

   > “CLAIM.md's D is to be read with these endpoints.”

   That is a proposed narrowing of the canonical statement, not evidence that the two scopes were already identical. Under an endpoint-universal reading, the record is a specialisation. Amend CLAIM D to specify `{5,6}`, or formalise arbitrary endpoints before claiming exact endpoint-universal coverage.

   This does not affect E. One 17-edge witness suffices. Moreover, the arrow proof at `Upper.lean:187–207` uses only the two disjoint copies and never the bridge edge. Endpoint independence follows mathematically from the already proved `k33MinusEdge_arrows_matching2_c4` and disjoint union argument; connectedness is supplied by any bridge. That universal extension is not itself a declared theorem here.

5. **Minor new documentation imprecision: K₇ does not separate the bounded statements.**

   `CORRESPONDENCE.md:44–45` says:

   > “The two halves are not interchangeable (K₇ with every edge red avoids both colours, yet no three vertices meet all its 4-cycles), so the C record is strictly weaker than CLAIM.md's C.”

   K₇ has 21 edges. It separates the two unrestricted conclusion predicates, not the assertions under C’s `≤16` hypothesis. Prefer “the record omits the separately proved transversal conjunct”; explicitly say the illustrative K₇ lies outside the hypothesis. This is not a counterexample to C or a theorem defect.

6. **Independent executable evidence.**

   At HEAD `134d223a76dd263576365d22bd8411d47ded698d`, a combined `lake env lean --stdin` probe exited **0**. It proved:

   - `edgeCount G = Nat.card G.edgeSet`;
   - τ₄ attainment directly from `sInf` and `Finset.univ`;
   - A for arbitrary finite vertex types by transporting the record;
   - red/blue partition;
   - complete CLAIM C as a conjunction;
   - attainment of the Ramsey minimum using F₁₇;
   - exhaustive K₃,₃−e and octahedron adjacency characterisations;
   - both F₁₇ blocks and its unique cross edge;
   - local bridge endpoint degrees 3 and 2;
   - C₄ in K₄ and a four-edge matching in K₈.

   Actual audit output:

   ```text
   'SizeRamsey.connected_transversal_le_three' depends on axioms: [propext, Classical.choice, Quot.sound]
   'SizeRamsey.connectedSizeRamsey_eq_seventeen' depends on axioms: [propext, Classical.choice, Quot.sound]
   ```

No theorem-level semantic defect found. I used no further subagents.

1. **Verification-chain conclusion: no certificate defect found.** I independently reran the pinned toolchain’s `Lake.Check.compareAt` and `Lake.Check.checkAxioms` on separately imported Challenge/Solution environments, using exactly the five configured theorem names and `[propext, Quot.sound, Classical.choice]`. The wrapper throws `IO.userError` on either `.error`.

   Actual result from `lake env lean --stdin`, **exit 0**:

   ```text
   recursive comparator: Except.ok ()
   axiom comparator: Except.ok ()
   ```

   This checks existing elaborated declarations recursively and enforces the axiom allowlist. It is **not** the Linux sandboxed export/comparator run, a clean rebuild, or fresh dependency replay. The first attempted zsh heredoc failed because the read-only sandbox prohibits its temporary file; the successful invocation used Python `subprocess.run(..., input=..., text=True)`.

2. **Trust-response judgments, numbered by the final adversary report.**

   | Finding | Judgment | Evidence and limit |
   |---|---|---|
   | Trust 1: audit commands are not rejection gates | **PARTIALLY** | Documentation now accurately explains this at `CORRESPONDENCE.md:127–129` and `formalization.yaml:167`. AxiomAudit still only prints. The actual certificate is clean, and my fail-on-error allowlist check passed. A reusable retained local gate remains absent; CI has the gate configured. |
   | Trust 2: complete pipeline unexecuted | **NOT RESOLVED** as execution gap | Explicitly acknowledged at `CORRESPONDENCE.md:122–126,182–187`; no evidence of Linux comparator, fresh replay, NanoDa, or con-ron execution. Accurate acknowledgment resolves reporting, not execution. None is mandated by quoted AGENTS §3. |
   | Trust 3: stale endpoint/count/docstring text | **RESOLVED** | `docs/PROOF.md:144–152` gives completed proof status; `CORRESPONDENCE.md:160–180` gives 25-module argv, outcome and limitations; `:184–187` correctly says one comment line became two. My git diffs confirm comment-only Lean change. |
   | Trust 4: statement drift | **RESOLVED** | My recursive comparator and allowlist rerun passed. `comparator.json:4–15` has exactly five targets, three allowed axioms, no definition holes. Frozen-file diffs against `b17d1fa` and Lean diff against `a73d95a` contain only the Solution comment change. |
   | Trust 5: hidden trust extensions | **RESOLVED** within inspected scope | Independent project-source scan found only five executable `sorry`s, all in Challenge, and no listed dangerous constructs. `lakefile.toml:6–11` has no weakening option. The allowlist passed. I did not independently repeat the prior 385-constant sweep or dependency-checkout hash audit. |
   | Trust 6: induction/vacuity | **RESOLVED only subject to mathematical audit** | Response correctly records “no change needed”; I did not reread equality cases for this delegated scope. Parent/other agent should provide its independent judgment. |
   | Trust 7: failed candidates and boundaries | **RESOLVED only subject to semantic audit** | Same reservation: no new response defect; parent’s separate mathematical audit supplies independent evidence. |
   | Trust 8: requested process repairs | **PARTIALLY** | Exact replay record and endpoint correction done. Full comparator execution still absent. A failing-on-error comparator/axiom invocation now passes in this review, but no new retained repository gate was added. Fresh replay and independent kernels are additional assurance. |

3. **Clear remaining documentation error: machine-checking is incorrectly denied.**

   `formalization.yaml:164` says:

   > “CI comparator (Linux, bubblewrap) not run: Challenge/Solution statement and definition agreement is not machine-checked yet.”

   The first clause is accurate; the second is false. `CORRESPONDENCE.md:118–120` already records actual recursive comparator success over existing environments. I independently reproduced it. Correct wording: “Full sandboxed CI comparator/export has not run; existing elaborated declarations passed recursive statement/definition comparison and axiom checking.”

   This sentence predates `134d223` but survives a revision that expressly claims comparator documentation is resolved. Thus the response is incomplete on cross-document consistency.

4. **New imprecise strictness claim introduced by `134d223`.**

   `CORRESPONDENCE.md:44–45`:

   > “The two halves are not interchangeable (K₇ with every edge red avoids both colours, yet no three vertices meet all its 4-cycles), so the C record is strictly weaker than CLAIM.md's C.”

   K₇ has 21 edges. It shows that the two **conclusions without C’s hypotheses** are not generally equivalent. It cannot establish strictness on connected graphs with ≤16 edges. The narrower explicit recorded conclusion is real, but the quoted inference overstates what the example proves. Replace “strictly weaker” by “omits the transversal conclusion,” and state the example’s out-of-scope status as the adversary did.

5. **D clarification is honest specialization, not identity with every reading of CLAIM.**

   `CORRESPONDENCE.md:26–27` says:

   > “The record fixes the bridge endpoints … CLAIM.md's D is to be read with these endpoints.”

   `:233–242` correctly identifies specialization to `(p,q)=(5,0)`. Documentation cannot retroactively prove endpoint-universal D. If the packet intends universal arbitrary endpoint choice, it must say that stronger informal statement is not the D record, or formalize it. This does **not** weaken E, which needs one connected 17-edge host. The wording is acceptable as a proposed scope correction, not as evidence that the old unspecified statement already had a unique host.

6. **Retained novelty overclaim and stale literature metadata.**

   `README.md:18–19` says:

   > “the new content is the equality classification B and the value 17.”

   This is stronger than the packet’s recorded literature evidence: `formalization.yaml:170` says novelty of B is unestablished, and `:174` says no novelty claim is made. The sentence was retained, not newly introduced substantively. Use “proposed new content” or omit novelty.

   `formalization.yaml:79` still says the 2018 correction “is still to be audited,” whereas the inlined novelty report records full-text audit. This is stale background metadata. I did not independently check the literature; neither issue enters the formal proof.

7. **Exact promotion rule and the Challenge exception.**

   The quoted AGENTS §3 requires:

   > “Lean build with no `sorry`/`admit`/custom axioms; … `CORRESPONDENCE.md` arguing the formal statement matches the informal one.”

   `lakefile.toml:4` includes Challenge among default targets, so a default `lake build` with five Challenge `sorry` warnings is not literally a no-`sorry` build. This should be resolved by identifying **Solution and its dependency closure** as the proof certificate and retaining `lake build Solution` plus the clean transitive axiom audit. The intentionally admitted reference file need not be deleted or converted into a proof, and it is not imported by Solution. Parent reports that it is running the explicit proof target.

   Under that scope, Linux CI comparator, `leanchecker --fresh`, NanoDa and con-ron are **additional assurance**, not necessary conditions under the quoted rule. C’s separate axiom-clean theorem and correspondence mapping satisfy semantic coverage; adding a sixth record is optional packaging. Endpoint-universal D is necessary only if that stronger D is included in what is being promoted.

8. **Tool implementation independently inspected.**

   - Pinned `Lake/Check/Compare.lean:67–108` compares target constant signatures and recursively compares non-target constants; `:50–56` does not grant arbitrary definition holes.
   - Pinned `Lake/Check/Axioms.lean:73–91` requires target theorem declarations; `:44–53` recursively rejects nonallowlisted axioms.
   - Pinned `LeanChecker.lean:17–38` replays module constants against imports; `:41–43` fresh-replays imported declarations too. Neither elaborates source.
   - `scripts/verify-comparator.sh:49–61` rejects supplied external-kernel configuration, installs bundled NanoDa/con-ron commands, runs cache then comparator, and propagates failure.
   - CI’s comparator job is configured at `.github/workflows/ci.yml:88–109`; configuration is not execution evidence.
   - `python3 scripts/check-lean-sources.py`: **exit 0**, “Lean source requirements satisfied.”
   - `ruby scripts/validate-formalization.rb`: **exit 0**, “formalization.yaml contains no TEMPLATE values.” This validator is metadata/template checking, not a theorem-status validator.

9. **Recommended scope decision.** No trust-chain reason remains to withhold ordinary formal-verification status from E and the actual clean Solution certificate, provided the parent’s proof-target build succeeds and correspondence scope is stated accurately. For the unchanged umbrella packet, require reconciliation of C/D coverage and stale status wording before an unqualified blanket label. Do **not** invent CI/fresh-kernel requirements absent from AGENTS §3.

No subagents spawned by this delegated agent.

I found no mathematical defect or verification escape in the proof of \(\hat r_c(4K_2,C_4)=17\). **E merits FORMALLY_VERIFIED under the quoted AGENTS §3 rule.** The packet still needs documentation corrections, and an unqualified formal-verification label for endpoint-universal D would exceed the formalized scope.

1. **Audit evidence for this review.**

   The checkout was clean at `134d223a76dd263576365d22bd8411d47ded698d`. The Lean diff from `a73d95a` contains only the stated Solution docstring change.

   | Check rerun | Result |
   |---|---|
   | `lake build` | Exit 0; 1228 jobs; five deliberate Challenge `sorry` warnings |
   | `lake build Solution` | Exit 0; 1225 jobs; **zero `sorry` warnings** |
   | `lake env lean SizeRamsey/AxiomAudit.lean` | All five records depend exactly on `[propext, Classical.choice, Quot.sound]` |
   | `lake env leanchecker -v SizeRamsey Solution Challenge` | Exit 0; explicitly replayed all **25** project modules |
   | Direct source elaboration of Solution, Equality, Cubic and Mixed | All exit 0 |
   | Recursive `Lake.Check.compareAt` on separately imported Challenge/Solution environments | `Except.ok ()` |
   | `Lake.Check.checkAxioms`, with the three-axiom allowlist | `Except.ok ()`; this review’s wrapper failed on any error |
   | Source requirements and metadata scripts | Both exit 0 |

   The local comparator checks existing elaborated environments. It does **not** establish execution of the Linux sandboxed pipeline. Normal replay trusts imported declarations; neither normal nor fresh replay elaborates source. I did not run Linux CI, `--fresh`, NanoDa or con-ron.

2. **Dispositions of the meaning adversary’s numbered findings.**

   Numbering here follows the final consolidated seven-finding report.

   | Finding | Judgment | Evidence |
   |---|---|---|
   | **M1 — C omits the transversal assertion** | **RESOLVED** | The requested alternative was to expand the record **or explicitly map both declarations**. [CORRESPONDENCE.md:34](/Users/ben/size-ramsey/CORRESPONDENCE.md:34) now supplies that mapping. The omitted assertion is proved at [Coloring.lean:18](/Users/ben/size-ramsey/SizeRamsey/Coloring.lean:18), and its clean axiom report was independently rerun. Adding a sixth record is optional packaging. |
   | **M2 — stale endpoint paragraph** | **RESOLVED** | [PROOF.md:144](/Users/ben/size-ramsey/docs/PROOF.md:144) now describes the completed proof. The executable audit agrees. |
   | **M3 — comparator coverage overstated** | **PARTIALLY** | [CORRESPONDENCE.md:115](/Users/ben/size-ramsey/CORRESPONDENCE.md:115) correctly distinguishes function, local execution and unrun CI. But `formalization.yaml:164` still gives a contradictory account; see finding 7 below. |
   | **M4 — five-statement comparison** | **PARTIALLY** | A/B/C/E are accurately characterized. D is equal only after specifying the intended endpoints; the canonical CLAIM still leaves them unspecified. See findings 4 and 9. |
   | **M5 — boundary and definition attacks** | **RESOLVED** | Independent semantic probes checked attainment, finite relabelling, colour partition and Ramsey nonemptiness. B retains its positive-edge hypothesis; E has an explicit witness. |
   | **M6 — explicit graphs** | **RESOLVED** | Independent Lean probes checked exhaustive adjacency descriptions, both F₁₇ blocks and its unique cross edge—not merely degree sequences. |
   | **M7 — evidence needed to remove qualifications** | **PARTIALLY** | The substantive correspondence and endpoint repairs are done. Cross-document errors remain. An unrun CI pipeline must remain recorded as unrun, but its execution is not required by quoted §3. |

3. **Dispositions of the trust adversary’s numbered findings.**

   | Finding | Judgment | Evidence |
   |---|---|---|
   | **T1 — audit commands are not rejection gates** | **PARTIALLY** | [CORRESPONDENCE.md:127](/Users/ben/size-ramsey/CORRESPONDENCE.md:127) now explains this correctly. The current certificate passes an independently rerun, failing-on-error allowlist check. A retained local rejection gate remains absent; that is automation debt, not a defect in this certificate. |
   | **T2 — complete pipeline unexecuted** | **NOT RESOLVED** as an execution gap | Accurate acknowledgment does not execute the pipeline. [CORRESPONDENCE.md:182](/Users/ben/size-ramsey/CORRESPONDENCE.md:182) correctly records the missing runs. They are additional assurance under §3. |
   | **T3 — endpoint, module count, docstring description** | **RESOLVED** | The endpoint text is corrected; the explicit 25-module replay was independently reproduced; the git diff confirms one comment line became two. |
   | **T4 — statement drift** | **RESOLVED** | Recursive comparison passed again. [comparator.json:4](/Users/ben/size-ramsey/comparator.json:4) lists precisely the five targets and three permitted axioms, with no definition holes. |
   | **T5 — hidden trust extensions** | **RESOLVED** within the audited certificate | The independent source scan and recursive allowlist check found none. The only executable `sorry`s are in Challenge. I do not claim to have repeated the earlier 385-constant sweep or dependency hash audit. |
   | **T6 — induction and vacuous helpers** | **RESOLVED** | Independently reread induction, Cubic and Mixed; see finding 5. Concrete mixed-helper premises were instantiated successfully. |
   | **T7 — counterexample candidates and boundaries** | **RESOLVED** | No candidate satisfies the hypotheses and contradicts the conclusion. The singleton exclusion, non-induced encodings and nonempty Ramsey set are substantive safeguards present in the source. |
   | **T8 — requested process repairs** | **PARTIALLY** | Exact replay documentation and endpoint correction are complete. Local comparison and enforced axiom checking pass. The retained automation and full pipeline remain incomplete. |

4. **Independent reconstruction of A–E: the mathematical meanings are correct, with the stated scope qualifications.**

   [Defs.lean](/Users/ben/size-ramsey/SizeRamsey/Defs.lean:23) uses an injective map from `Fin 4` and precisely four cyclic adjacency assertions. Diagonals are unrestricted. The matching predicate similarly uses eight distinct vertices and four specified adjacent pairs; additional edges are unrestricted. These encode ordinary, non-induced copies.

   The transversal predicate quantifies over every such cycle. Its cardinality set contains `Finset.univ`, including for the empty vertex type. [Basic.lean:44](/Users/ben/size-ramsey/SizeRamsey/Basic.lean:44) applies `Nat.sInf_mem`, so `tau4` is an attained minimum, not an accidental empty infimum. An independent stdin proof reconstructed this directly from the definition.

   `edgeCount` counts unordered edges once. The independent probe proved its equality to `Nat.card G.edgeSet`.

   A red subgraph `R ≤ F` specifies exactly an edge colouring: blue adjacency is `F.Adj u v ∧ ¬ R.Adj u v`. The probe proved both partition equations
   \[
   R\sqcup(F\setminus R)=F,\qquad R\sqcap(F\setminus R)=\bot.
   \]
   Conversely, every red/blue edge colouring supplies such an `R`.

   | Record | Lean versus CLAIM |
   |---|---|
   | **A** | **Equal**, after finite relabelling. Arbitrary finite vertex types have representatives on `Fin n`; transport through `overFinIso` was elaborated independently. |
   | **B** | **Stronger than the literal “only” wording:** Lean proves an iff. All three hypotheses—connectedness, positive edge count, at most 16 edges—are retained. Isomorphism concerns the whole graph. |
   | **C** | **Weaker as a recorded conclusion:** colouring only. The library proves the complete CLAIM C through two declarations. |
   | **D** | **Equal for the specified host; weaker than endpoint-universal D.** The bridge joins local vertex 5 of the first copy, degree 3, to local vertex 0 of the second, degree 2. `Fin 12` fixes the vertex count. |
   | **E** | **Equal** to the finite connected size-Ramsey minimum. |

   E quantifies over every natural `n`, with no hidden vertex bound. Connectedness includes nonemptiness. Crucially, [Solution.lean:74](/Users/ben/size-ramsey/Solution.lean:74) puts 17 into the defining set using F₁₇ before applying the infimum inequalities. Lines 79–84 exclude every smaller member using C. There is no empty-infimum loophole.

5. **The strong induction and the audited Astra-authored cases contain no omitted case or circularity.**

   I read **Equality.lean and Cubic.lean end to end**; the equality subagent independently read **Equality.lean and Mixed.lean end to end**.

   [Equality.lean:37](/Users/ben/size-ramsey/SizeRamsey/Equality.lean:37) inducts on edge count simultaneously over finite vertex types in one universe. [Shared.lean:42](/Users/ben/size-ramsey/SizeRamsey/Shared.lean:42) requires recursive inputs to be connected, positive-edge, tight and strictly smaller. Residual subtypes and component supports remain in that universe. The inherited 16-edge cap follows from strict decrease.

   The dispatch is exhaustive: degree four; otherwise degrees lie in `{2,3}`; then all two, all three, or an adjacent 2/3 pair. The last trichotomy is proved using a path crossing between degree classes at [Reductions.lean:315](/Users/ben/size-ramsey/SizeRamsey/Reductions.lean:315).

   In the cubic branch, [Cubic.lean:188](/Users/ben/size-ramsey/SizeRamsey/Equality/Cubic.lean:188) derives
   \[
   3|V|=2m,\quad 4\tau_4=m,\quad 0<m\le16
   \Longrightarrow m=12,\ |V|=8,\ \tau_4=3.
   \]
   Tightness excludes chords. Deleting the first square costs at most two transversal vertices, so its four-vertex residual must contain a square. That square exhausts the residual. Degree three then supplies a unique cross-neighbour on each side, hence an actual permutation—not an assumed matching.

   The transversal lemma at [Cubic.lean:21](/Users/ben/size-ramsey/SizeRamsey/Equality/Cubic.lean:21) exhausts all sixteen left/right assignments of the four cycle vertices. It constructs `{l 0, r (μ 2)}`, contradicting \(\tau_4=3\). The unused connectedness and induction hypotheses are harmless strengthening; the tight cubic conjunction is intentionally proved impossible.

   As a separate **computed check**, I enumerated all 24 cross-matchings between two labelled squares and every ordered four-vertex cycle: all 24 proposed transversals worked. This is supplementary evidence, not a dependency of the Lean proof.

   Mixed establishes residual positivity, exactly four removed edges, tightness and connectedness before invoking induction at [Mixed.lean:335](/Users/ben/size-ramsey/SizeRamsey/Equality/Mixed.lean:335). Three attachment edges and at least two per component force connectedness. Three distinct residual degree-two vertices force the residual C₄. The final six-vertex labelling is explicitly proved bijective and adjacency-preserving. Its structural premises were independently instantiated in K₃,₃−e.

   No audited equality lemma assumes B through its imports: the dependency route runs through the previously proved universal bound and small-graph facts.

6. **The computational evidence does not carry the theorem.**

   Ordinary Lean `decide` produces kernel-checked proof terms. The finite checks here therefore differ epistemically from external graph-search outputs. The formal dependency closure does not use the exploratory census or Python experiment certificates.

   The inlined packet identifies separate experiment verifiers and records their shared **geng coverage assumption**. Those files lie outside this read root; I cannot independently certify their implementation or independence from their descriptions alone. In particular, two programs consuming the same census do not independently establish census completeness.

   This limitation does not block the present formal theorem. The experiments remain observations. `leanchecker` supplies separate replay using Lean’s kernel; it is not an independently implemented kernel such as NanoDa.

7. **New documentation objection: the metadata falsely denies an already completed machine check.**

   [formalization.yaml:164](/Users/ben/size-ramsey/formalization.yaml:164) says:

   > “CI comparator (Linux, bubblewrap) not run: Challenge/Solution statement and definition agreement is not machine-checked yet.”

   The first clause is correct; the second is false. [CORRESPONDENCE.md:118](/Users/ben/size-ramsey/CORRESPONDENCE.md:118) records the earlier recursive comparison, and this review independently reproduced it.

   Replace the sentence with: **“The full sandboxed CI pipeline has not run; existing elaborated declarations passed recursive statement/definition comparison and axiom checking.”**

   This is retained inconsistency, not new executable drift.

8. **New documentation objection: the K₇ example does not establish strictness under C’s hypotheses.**

   Introduced in the revision, [CORRESPONDENCE.md:44](/Users/ben/size-ramsey/CORRESPONDENCE.md:44) says:

   > “The two halves are not interchangeable … so the C record is strictly weaker than CLAIM.md’s C.”

   K₇ has **21 edges**. It separates the unrestricted conclusion predicates; it does not separate the statements restricted to connected graphs with at most 16 edges.

   Write **“the record omits the separately proved transversal conclusion”**, and explicitly identify K₇ as outside C’s hypotheses. The coverage difference is real; the claimed strictness argument is not valid as written.

9. **D’s canonical quantifiers still need precision; neither C nor D undermines E.**

   [CORRESPONDENCE.md:27](/Users/ben/size-ramsey/CORRESPONDENCE.md:27) says:

   > “CLAIM.md’s D is to be read with these endpoints.”

   This proposes a specialization of the canonical wording. It does not prove that unspecified endpoints were already uniquely determined.

   Amend CLAIM D to specify the fixed host, or formally state and prove the endpoint-universal version before claiming that stronger D has been formalized. Different endpoint degrees can produce nonisomorphic hosts.

   Endpoint independence is mathematically straightforward: each disjoint K₃,₃−e copy independently forces a red two-matching unless there is a blue C₄; the two matchings combine. The bridge only provides connectedness. [Upper.lean:187](/Users/ben/size-ramsey/SizeRamsey/Upper.lean:187) already uses this mechanism, but the universal family is not a declared theorem.

   **E needs one witness, so fixed-host D is sufficient. E needs only C’s colouring half, so the five-record packaging is also sufficient.**

10. **Other stale or unsupported packet statements should be corrected.**

   [README.md:18](/Users/ben/size-ramsey/README.md:18), also reflected in PROOF.md, says:

   > “the new content is the equality classification B and the value 17.”

   As a novelty claim, this exceeds the recorded evidence: [formalization.yaml:170](/Users/ben/size-ramsey/formalization.yaml:170) explicitly says B’s novelty is unestablished. Use “proposed new content” or omit the novelty assertion. This overclaim was retained, not substantively introduced by the latest revision.

   Also stale: “Lean formalization of Theorem B may now start” at [PROOF.md:17](/Users/ben/size-ramsey/docs/PROOF.md:17), and the inlined CLAIM’s assertion that the development is admitted. Historical passages should be clearly marked historical.

   I directly verified the literature identification: WSZZ’s published Theorem 1.3 is the upper bound, and Conjecture 1 gives the proposed equality; substituting \(n=4\) yields 17. Confidence **0.99**, based on the retrieved text, not recollection. [Published paper, pp. 164–165](https://www.ejgta.org/index.php/ejgta/article/download/2224/pdf_324). I did not independently re-audit the other novelty references in this pass; none is needed by the formal proof.

11. **Status and exact promotion requirements.**

   The quoted §3 requires:

   > “Lean build with no `sorry`/`admit`/custom axioms; … `CORRESPONDENCE.md` arguing the formal statement matches the informal one”.

   The default build includes admitted Challenge statements. It should therefore **not** be described as a globally sorry-free build. The proof certificate is **Solution and its dependency closure**, which does not import Challenge. This review’s `lake build Solution` passed with zero sorry warnings, and transitive axiom checking passed.

   My recommendation is:

   - **E, A, B, complete C via its two declarations, and fixed-host D:** **FORMALLY_VERIFIED theorem**, relative to the standard Lean axioms and pinned toolchain.
   - **Endpoint-universal D:** not formally verified by this development. Keep that stronger scope at **VERIFIED** unless formalized.
   - **The umbrella packet:** promote with the explicit scope above; correct canonical D and synchronize the stale metadata before applying an unqualified A–E label.

   **Nothing further is required by quoted §3 for E.** Linux comparator CI, `leanchecker --fresh`, NanoDa/con-ron, and a sixth C record provide additional assurance. Accurate correspondence is necessary; pretending fixed-host D proves every endpoint choice is not acceptable.

   I used **3 subagents**: statement semantics; verification chain and documentation; induction and Mixed. I reconciled their reports with my own Cubic reading, build, axiom audit, replay, source checks and independent finite enumeration. No files were changed.

VERDICT: ACCEPT_WITH_FIXES  
CONFIDENCE: 0.98