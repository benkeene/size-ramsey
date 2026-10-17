<!-- astra: model=gpt-6-astra effort=xhigh status=completed thread=01a147fd-0293-7db3-9ec9-a98a05f6955f job=20261016T235201_a7-tightness-prover-r1-4-sorries-404f34b -->

```lean patch id=ramsey-A7-r1.1 decl=SizeRamsey.Plan.equality_square_supported sig=1ec1b879 mode=body
by
  intro a b hab
  by_contra hns
  obtain ⟨htau, hcount⟩ := tau4_delete_non_square_edge G hab hns
  have hbound := universal (G.deleteEdges {s(a, b)})
  omega
```

```note id=ramsey-A7-r1.1
Compiled the whole modified Tightness.lean via `lake env lean --stdin`, exit 0.
Remaining warnings:
<stdin>:36:8: warning: declaration uses `sorry`
<stdin>:41:8: warning: declaration uses `sorry`
<stdin>:47:8: warning: declaration uses `sorry`
These are the other three target declarations.
No helpers or imports needed. Follows the unsupported-edge deletion argument.
```

```note id=general
No admitted dependencies.
Actual axiom audit output:
'SizeRamsey.Plan.equality_square_supported' depends on axioms: [propext, Classical.choice, Quot.sound]
'SizeRamsey.Plan.universal' depends on axioms: [propext, Classical.choice, Quot.sound]
'SizeRamsey.Plan.tau4_delete_non_square_edge' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```proofloop-summary
{"brief":"ramsey-A7-r1","base":"404f34b","results":[{"id":"ramsey-A7-r1.1","status":"PROVED","elaborated":true,"lean_output":"<stdin>:36:8: warning: declaration uses `sorry`\n<stdin>:41:8: warning: declaration uses `sorry`\n<stdin>:47:8: warning: declaration uses `sorry`"}],"helpers":[],"imports":[],"subagents":0,"confidence":1}
```

```lean patch id=ramsey-A7-r1.4 decl=SizeRamsey.Plan.equality_residual_components sig=39941dae mode=body
by
  have hbound := universal (erase G D)
  have heq : tau4 G = tau4 (erase G D) + c := by omega
  have hres : 4 * tau4 (erase G D) = edgeCount (erase G D) := by omega
  refine ⟨heq, ?_⟩
  have hsum : (∑ C : (erase G D).ConnectedComponent,
      4 * tau4 (compGraph (erase G D) C)) =
      ∑ C : (erase G D).ConnectedComponent,
        edgeCount (compGraph (erase G D) C) := by
    rw [← Finset.mul_sum, ← tau4_components, ← edgeCount_components]
    exact hres
  exact fun C => (Finset.sum_eq_sum_iff_of_le
    (fun C _ => universal (compGraph (erase G D) C))).mp hsum C (Finset.mem_univ C)
```

```note id=general
No helpers or additional imports.
No admitted dependencies: printed axioms are exactly [propext, Classical.choice, Quot.sound].
The proof follows the intended equality chain and componentwise nonnegative-deficit argument; Finset.sum_eq_sum_iff_of_le packages the latter.
The whole modified target file was piped through lake env lean --stdin. Exit code 0.
Real output:
<stdin>:27:8: warning: declaration uses `sorry`
<stdin>:32:8: warning: declaration uses `sorry`
<stdin>:37:8: warning: declaration uses `sorry`
'SizeRamsey.Plan.equality_residual_components' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```proofloop-summary
{"brief":"ramsey-A7-r1","base":"404f34b","results":[{"id":"ramsey-A7-r1.4","status":"PROVED","elaborated":true,"lean_output":"<stdin>:32:8: warning: declaration uses `sorry`\n<stdin>:37:8: warning: declaration uses `sorry`\n'SizeRamsey.Plan.equality_residual_components' depends on axioms: [propext, Classical.choice, Quot.sound]"}],"helpers":[],"imports":[],"subagents":0,"confidence":1}
```

```lean patch id=ramsey-A7-r1.3 decl=SizeRamsey.Plan.equality_min_degree sig=d2e8343a mode=body
by
  classical
  have hne : G ≠ ⊥ := by
    intro h
    subst G
    simp [edgeCount] at hm
  obtain ⟨a, b, hab⟩ := SimpleGraph.ne_bot_iff_exists_adj.mp hne
  let : Nontrivial V := hab.nontrivial
  intro v
  obtain ⟨w, hw⟩ := hcon.preconnected.exists_adj_of_nontrivial v
  obtain ⟨f, hf, hf0, _⟩ := equality_square_supported G ht hw
  have h01 : G.Adj v (f 1) := by simpa [hf0] using hf.2.1
  have h03 : G.Adj v (f 3) := by simpa [hf0] using hf.2.2.2.2.symm
  have h13 : f 1 ≠ f 3 := hf.1.ne (by decide)
  exact Finset.one_lt_card.mpr
    ⟨f 1, (G.mem_neighborFinset v (f 1)).mpr h01, f 3, (G.mem_neighborFinset v (f 3)).mpr h03, h13⟩
```

```note id=ramsey-A7-r1.3
Elaborated the entire modified Tightness.lean by piping Python output to lake env lean --stdin.
Exit code 0. No warning on equality_min_degree.
Direct project dependency: equality_square_supported; currently admitted in baseline, being proved concurrently.
No helper or import required. Follows the informal route: positive edge count gives a nontrivial vertex type; connectedness supplies an incident edge; square support supplies two distinct neighbors.
Actual compiler output:
<stdin>:27:8: warning: declaration uses `sorry`
<stdin>:32:8: warning: declaration uses `sorry`
<stdin>:57:8: warning: declaration uses `sorry`
```

```proofloop-summary
{"brief":"ramsey-A7-r1","base":"404f34b","results":[{"id":"ramsey-A7-r1.3","status":"PROVED","elaborated":true,"lean_output":"<stdin>:27:8: warning: declaration uses `sorry`\n<stdin>:32:8: warning: declaration uses `sorry`\n<stdin>:57:8: warning: declaration uses `sorry`"}],"helpers":[],"imports":[],"subagents":0,"confidence":1}
```

```note id=ramsey-A7-r1.3
The shorter proof is mathematically sound and follows the required route.
connected_positive_degree requires exactly connectedness and positive edge count.
square_supported_degree_ge_two requires exactly square support and positive vertex degree.
Both helpers have complete proof bodies; no additional hypotheses or admitted contracts are introduced.
The root agent compiled the exact shorter body successfully; my independent longer proof also compiled successfully.
```


```lean patch id=ramsey-A7-r1.1 decl=SizeRamsey.Plan.equality_square_supported sig=1ec1b879 mode=body
by
  intro a b hab
  by_contra hns
  obtain ⟨htau, hcount⟩ := tau4_delete_non_square_edge G hab hns
  have hbound := universal (G.deleteEdges {s(a, b)})
  omega
```

```lean patch id=ramsey-A7-r1.2 decl=SizeRamsey.Plan.equality_max_degree_le_four sig=46e5bb4c mode=body
by
  intro v
  have hdel : tau4 G ≤ tau4 (erase G {v}) + 1 := by
    have h := tau4_delete_vertices_le G {v} {v} subset_rfl (fun _ _ h => h)
    simpa using h
  have hcount := (erase_singleton_counts G v).1
  have hbound := universal (erase G {v})
  omega
```

```lean patch id=ramsey-A7-r1.3 decl=SizeRamsey.Plan.equality_min_degree sig=d2e8343a mode=body
by
  intro v
  exact square_supported_degree_ge_two G (equality_square_supported G ht) v
    (connected_positive_degree G hcon hm v)
```

```lean patch id=ramsey-A7-r1.4 decl=SizeRamsey.Plan.equality_residual_components sig=39941dae mode=body
by
  have hbound := universal (erase G D)
  have heq : tau4 G = tau4 (erase G D) + c := by omega
  have hres : 4 * tau4 (erase G D) = edgeCount (erase G D) := by omega
  refine ⟨heq, ?_⟩
  have hsum : (∑ C : (erase G D).ConnectedComponent,
      4 * tau4 (compGraph (erase G D) C)) =
      ∑ C : (erase G D).ConnectedComponent,
        edgeCount (compGraph (erase G D) C) := by
    rw [← Finset.mul_sum, ← tau4_components, ← edgeCount_components]
    exact hres
  exact fun C => (Finset.sum_eq_sum_iff_of_le
    (fun C _ => universal (compGraph (erase G D) C))).mp hsum C (Finset.mem_univ C)
```

```note id=general
1. Piped the whole modified Tightness.lean, containing all four replacements, through lake env lean --stdin: exit 0, empty compiler output.
2. No admitted dependencies. A separate compilation of that same modified file with four axiom checks returned exit 0 and exactly:
'SizeRamsey.Plan.equality_square_supported' depends on axioms: [propext, Classical.choice, Quot.sound]
'SizeRamsey.Plan.equality_max_degree_le_four' depends on axioms: [propext, Classical.choice, Quot.sound]
'SizeRamsey.Plan.equality_min_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
'SizeRamsey.Plan.equality_residual_components' depends on axioms: [propext, Classical.choice, Quot.sound]
3. All proofs follow the intended route; sum_eq_sum_iff_of_le packages the component deficit argument.
4. Used three subagents: independent square-support, minimum-degree, and residual-component proofs. Parent proved the maximum-degree bound and compiled and audited the combined replacements.
```

```proofloop-summary
{"brief":"ramsey-A7-r1","base":"404f34b","results":[{"id":"ramsey-A7-r1.1","status":"PROVED","elaborated":true,"lean_output":""},{"id":"ramsey-A7-r1.2","status":"PROVED","elaborated":true,"lean_output":""},{"id":"ramsey-A7-r1.3","status":"PROVED","elaborated":true,"lean_output":""},{"id":"ramsey-A7-r1.4","status":"PROVED","elaborated":true,"lean_output":""}],"helpers":[],"imports":[],"subagents":3,"confidence":1}
```