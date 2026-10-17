<!-- astra: model=gpt-6-astra effort=xhigh status=completed thread=01a147fd-0293-7080-8e52-183c1dfaa881 job=20261016T235202_b8-b9-tworegular-equality-coloring-prover-r1-3-s -->

At d1c156b, classification_of_step already has a complete proof. The actual admission in Equality.lean is SizeRamsey.Proof.equality_classification (line 57). Should target ramsey-B89-r1.2 be corrected to that declaration, with its actual signature hash?
- Correct target .2 to equality_classification
- Keep the listed target classification_of_step

Proof body:

```lean
by
  exact two_regular_square_supported G hc (equality_square_supported G ht) h2
```

Whole modified `SizeRamsey/Equality/TwoRegular.lean` compiled through `lake env lean --stdin`, exit code 0. Exact compiler output:

```text
<stdin>:23:5: warning: Variable name `hp` is not explicitly referenced.

Hint: The binding can be removed (if unused) or named `_` (if used implicitly). Alternatively, prefix the name with `_` to silence this warning:
  [apply] _hp

Note: This linter can be disabled with `set_option linter.unusedVariables false`
```

Separate complete-file compilation with audit appended also exited 0:

```text
'SizeRamsey.Plan.equality_two_regular_case' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
```

Admitted dependencies used:

- `SizeRamsey.Plan.equality_square_supported`
- `SizeRamsey.Plan.two_regular_square_supported`

No helpers/imports. Follows intended route exactly. Both dependency signatures are mathematically sound; no contract issue found. `hp` is redundant.

The listed target `SizeRamsey.Plan.classification_of_step` is already proved at the specified commit. Whole-file stdin compilation succeeded; its axiom audit contains only `[propext, Classical.choice, Quot.sound]`. The only original-file warning is:

```text
<stdin>:57:8: warning: declaration uses `sorry`
```

That warning belongs to `SizeRamsey.Proof.equality_classification`, which is the actual admitted assembly theorem.

Existing wrapper body, independently recompiled:

```lean
by
  have aux : ∀ n, ∀ {W : Type u} [Fintype W]
      (H : SimpleGraph W),
      edgeCount H = n → H.Connected →
      0 < edgeCount H → edgeCount H ≤ 16 →
      Tight H → Classified H := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro W inst H he hconn hpos hcap htight
      apply step H hconn hpos hcap htight
      intro X instX K kc kp klt kt
      have kn : edgeCount K < n := by omega
      exact ih (edgeCount K) kn K rfl kc kp
        (by omega) kt
  exact aux (edgeCount G) G rfl hc hp hm ht
```

I also proved the actual admitted `SizeRamsey.Proof.equality_classification`:

```lean
by
  classical
  constructor
  · intro ht
    apply Plan.classification_of_step (G := G) _ hconn hpos hle ht
    intro W inst H hc hp hm ht ih
    have hmin := Plan.equality_min_degree H hc hp ht
    have hmax := Plan.equality_max_degree_le_four H ht
    by_cases hfour : ∃ v, H.degree v = 4
    · exact Plan.equality_degree_four_case H hc hp hm ht ih hfour
    · have hthree : ∀ v, H.degree v ≤ 3 := by
        intro v
        have := hmax v
        have : H.degree v ≠ 4 := fun hv => hfour ⟨v, hv⟩
        omega
      have hcases : ∀ v, H.degree v = 2 ∨ H.degree v = 3 := by
        intro v
        have := hmin v
        have := hthree v
        omega
      rcases Plan.degree_two_three_cases H hc hcases with htwo | hthree' | hmixed
      · exact Or.inl (Plan.equality_two_regular_case H hc hp ht htwo)
      · exact (Plan.equality_cubic_impossible H hc hp hm ht ih hthree').elim
      · exact Or.inr (Or.inr (Or.inl
          (Plan.equality_mixed_degree_case H hc hp hm ht ih hthree hmixed)))
  · intro h
    exact Plan.classified_tight G h
```

The complete modified file was piped through `lake env lean --stdin`, exit code `0`, with no warnings or errors. Appended audit produced exactly:

```text
'SizeRamsey.Proof.equality_classification' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
```

No helpers or imports needed. Admitted dependencies, all in `SizeRamsey.Plan`:

- `equality_min_degree`
- `equality_max_degree_le_four`
- `equality_degree_four_case`
- `degree_two_three_cases`
- `equality_two_regular_case`
- `equality_cubic_impossible`
- `equality_mixed_degree_case`
- `classified_tight`

Signature hash discrepancy also confirmed: raw SHA256 of the current wrapper text from `theorem` up to but excluding `:=` is `1f4ca028`; stripping trailing whitespace yields `9f01c6a7`, neither the brief's `bcc646a7`. For actual `equality_classification`, corresponding hashes are `2a14bca7` and `dd75a2f3`. User clarification is needed for a mechanically applicable corrected target identifier/hash.

No subagents spawned by this worker.

```lean patch id=ramsey-B89-r1.3 decl=SizeRamsey.connected_transversal_le_three sig=f93f8177 mode=body
by
  obtain ⟨S, hS, hcard⟩ := exists_transversal_card_eq_tau4 G
  refine ⟨S, hS, ?_⟩
  rw [hcard]
  by_contra hnot
  have hu := Proof.four_mul_tau4_le_edgeCount G
  have hm : edgeCount G = 16 := by omega
  have heq : 4 * tau4 G = edgeCount G := by omega
  have hclass := (Proof.equality_classification G hconn (by omega) hle).mp heq
  obtain ⟨hC, hW, hK, hO⟩ := Plan.small_graph_data
  rcases hclass with hC4 | hW5 | hK33 | hOct
  · obtain ⟨e⟩ := hC4
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hW5
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hK33
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hOct
    have hi := Plan.edgeCount_iso e
    omega
```

```note id=ramsey-B89-r1.3
The original file produces: SizeRamsey/Coloring.lean:18:8: warning: declaration uses `sorry`.
Piped the whole modified Coloring.lean through lake env lean --stdin; exit 0, no errors or warnings.
Appended diagnostic output:
'SizeRamsey.connected_transversal_le_three' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
Follows the plan's route: τ₄ > 3 implies m = 16 and equality; classification contradicts the four representative edge counts.
No helpers or imports required.
```

```note id=general
Admitted dependencies used by this proof:
SizeRamsey.exists_transversal_card_eq_tau4.
SizeRamsey.Plan.universal, via SizeRamsey.Proof.four_mul_tau4_le_edgeCount.
SizeRamsey.Proof.equality_classification.
SizeRamsey.Plan.small_graph_data.
SizeRamsey.Plan.edgeCount_iso.
All five are direct admitted bodies in the current snapshot; the universal wrapper is proved.
Source discrepancy: classification_of_step already has a complete proof; equality_classification remains admitted.
No subagents spawned by this agent (root occupied all available slots).
```

```proofloop-summary
{"brief":"ramsey-B89-r1","base":"d1c156b","results":[{"id":"ramsey-B89-r1.3","status":"PROVED","elaborated":true,"lean_output":"'SizeRamsey.connected_transversal_le_three' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"}],"helpers":[],"imports":[],"subagents":0,"confidence":1.0}
```

```lean patch id=ramsey-B89-r1.1 decl=SizeRamsey.Plan.equality_two_regular_case sig=e3e937be mode=body
by
  exact two_regular_square_supported G hc (equality_square_supported G ht) h2
```

```lean patch id=ramsey-B89-r1.2 decl=SizeRamsey.Plan.classification_of_step sig=bcc646a7 mode=body
by
  have aux : ∀ n, ∀ {W : Type u} [Fintype W]
      (H : SimpleGraph W),
      edgeCount H = n → H.Connected →
      0 < edgeCount H → edgeCount H ≤ 16 →
      Tight H → Classified H := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro W inst H he hconn hpos hcap htight
      apply step H hconn hpos hcap htight
      intro X instX K kc kp klt kt
      have kn : edgeCount K < n := by omega
      exact ih (edgeCount K) kn K rfl kc kp
        (by omega) kt
  exact aux (edgeCount G) G rfl hc hp hm ht
```

```lean patch id=ramsey-B89-r1.3 decl=SizeRamsey.connected_transversal_le_three sig=f93f8177 mode=body
by
  obtain ⟨S, hS, hcard⟩ := exists_transversal_card_eq_tau4 G
  refine ⟨S, hS, ?_⟩
  rw [hcard]
  by_contra hnot
  have hu := Proof.four_mul_tau4_le_edgeCount G
  have hm : edgeCount G = 16 := by omega
  have heq : 4 * tau4 G = edgeCount G := by omega
  have hclass := (Proof.equality_classification G hconn (by omega) hle).mp heq
  obtain ⟨hC, hW, hK, hO⟩ := Plan.small_graph_data
  rcases hclass with hC4 | hW5 | hK33 | hOct
  · obtain ⟨e⟩ := hC4
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hW5
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hK33
    have hi := Plan.edgeCount_iso e
    omega
  · obtain ⟨e⟩ := hOct
    have hi := Plan.edgeCount_iso e
    omega
```

```note id=general
1. At verified HEAD d1c156b1ec6747f4f16b3b474a295f3d6a8ab91d, classification_of_step is already proved.
Its block above repeats the existing proof; it removes no admission.
The sole admission in Equality.lean is SizeRamsey.Proof.equality_classification, starting at line 57.
2. Hashing signature text with trailing whitespace stripped reproduces the supplied .1 and .3 hashes.
For classification_of_step this gives 9f01c6a7, not the supplied bcc646a7.
For equality_classification it gives dd75a2f3.
The .2 patch retains the explicitly required metadata; the brief needs correction before applying the actual assembly proof.
3. The following note supplies a complete body for equality_classification, without silently changing the named target.
That exact body was inserted into the whole Equality.lean text and compiled through stdin: exit 0, no warnings/errors.
Its audit printed: 'SizeRamsey.Proof.equality_classification' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
```

```note id=ramsey-B89-r1.2
by
  classical
  refine ⟨?_, Plan.classified_tight G⟩
  intro ht
  apply Plan.classification_of_step (G := G) _ hconn hpos hle ht
  intro W inst H hc hp hm ht ih
  by_cases hfour : ∃ v, H.degree v = 4
  · exact Plan.equality_degree_four_case H hc hp hm ht ih hfour
  · have hthree : ∀ v, H.degree v ≤ 3 := by
      intro v; have := Plan.equality_max_degree_le_four H ht v; have : H.degree v ≠ 4 := fun hv => hfour ⟨v, hv⟩; omega
    have hcases : ∀ v, H.degree v = 2 ∨ H.degree v = 3 := by intro v; have := Plan.equality_min_degree H hc hp ht v; have := hthree v; omega
    rcases Plan.degree_two_three_cases H hc hcases with htwo | hthree' | hmixed
    · exact Or.inl (Plan.equality_two_regular_case H hc hp ht htwo)
    · exact (Plan.equality_cubic_impossible H hc hp hm ht ih hthree').elim
    · exact Or.inr (Or.inr (Or.inl (Plan.equality_mixed_degree_case H hc hp hm ht ih hthree hmixed)))
```

```note id=general
Admitted dependencies of .1: SizeRamsey.Plan.equality_square_supported; SizeRamsey.Plan.two_regular_square_supported.
The listed .2 wrapper has no admitted dependencies.
Admitted dependencies of .3:
SizeRamsey.exists_transversal_card_eq_tau4;
SizeRamsey.Plan.universal, through SizeRamsey.Proof.four_mul_tau4_le_edgeCount;
SizeRamsey.Proof.equality_classification;
SizeRamsey.Plan.small_graph_data; SizeRamsey.Plan.edgeCount_iso.
Additional admitted dependencies of the assembly body supplied in the note:
SizeRamsey.Plan.equality_min_degree; SizeRamsey.Plan.equality_max_degree_le_four;
SizeRamsey.Plan.equality_degree_four_case; SizeRamsey.Plan.degree_two_three_cases;
SizeRamsey.Plan.equality_two_regular_case, using its compiled snapshot admission;
SizeRamsey.Plan.equality_cubic_impossible; SizeRamsey.Plan.equality_mixed_degree_case;
SizeRamsey.Plan.classified_tight.
4. Basic.lean contains admissions despite the brief's “proved results” description.
These are conditional proofs against the named contracts, not admission-free proofs of the full development.
```

```note id=general
Each reported body was checked by piping the complete corresponding file through lake env lean --stdin.
The .1 proof produces only an unused-hypothesis warning for hp; .3 produces no warnings.
The listed .2 wrapper's file still warns about the separate equality_classification admission.
No files were written; no imports or helpers are needed; the proofs follow the intended route.
Three subagents independently handled two-regularity, strong induction/classification assembly, and coloring.
The primary agent independently reran all compilations and checked the signature discrepancies.
```

```proofloop-summary
{"brief":"ramsey-B89-r1","base":"d1c156b","results":[{"id":"ramsey-B89-r1.1","status":"PROVED","elaborated":true,"lean_output":"\nNote: This linter can be disabled with `set_option linter.unusedVariables false`\n'SizeRamsey.Plan.equality_two_regular_case' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"},{"id":"ramsey-B89-r1.2","status":"PROVED","elaborated":true,"lean_output":"<stdin>:57:8: warning: declaration uses `sorry`\n'SizeRamsey.Plan.classification_of_step' depends on axioms: [propext, Classical.choice, Quot.sound]"},{"id":"ramsey-B89-r1.3","status":"PROVED","elaborated":true,"lean_output":"'SizeRamsey.connected_transversal_le_three' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"}],"helpers":[],"imports":[],"subagents":3,"confidence":1.0}
```