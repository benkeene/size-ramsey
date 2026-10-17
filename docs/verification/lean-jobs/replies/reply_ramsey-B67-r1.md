<!-- astra: model=gpt-6-astra effort=xhigh status=completed thread=01a147fd-0293-7af2-988a-0d201e489eaf job=20261016T235202_b6-b7-mixed-cubic-prover-r1-3-sorries-d1c156b -->

```lean patch id=ramsey-B67-r1.3.h1 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_chordless_adjacency_r1
    {V : Type u} (G : SimpleGraph V) (f : Fin 4 → V)
    (hf : IsC4Map G f)
    (h02 : ¬ G.Adj (f 0) (f 2)) (h13 : ¬ G.Adj (f 1) (f 3)) :
    ∀ i j, G.Adj (f i) (f j) ↔ (SimpleGraph.cycleGraph 4).Adj i j := by
  obtain ⟨hi, h01, h12, h23, h30⟩ := hf
  have h10 := h01.symm
  have h21 := h12.symm
  have h32 := h23.symm
  have h03 := h30.symm
  have h20 : ¬ G.Adj (f 2) (f 0) := fun h => h02 h.symm
  have h31 : ¬ G.Adj (f 3) (f 1) := fun h => h13 h.symm
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp_all [SimpleGraph.cycleGraph_adj] <;> decide
```

```lean patch id=ramsey-B67-r1.3.h2 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_third_neighbor_r1
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (v a b : V) (hd : G.degree v = 3)
    (ha : G.Adj v a) (hb : G.Adj v b) (hab : a ≠ b) :
    ∃! w, G.Adj v w ∧ w ≠ a ∧ w ≠ b := by
  classical
  let S := ((G.neighborFinset v).erase a).erase b
  have ha' : a ∈ G.neighborFinset v := by simpa using ha
  have hb' : b ∈ (G.neighborFinset v).erase a := by
    simp [hb, hab.symm]
  have hcard : S.card = 1 := by
    dsimp only [S]
    rw [Finset.card_erase_of_mem hb', Finset.card_erase_of_mem ha',
      G.card_neighborFinset_eq_degree, hd]
  obtain ⟨w, hw⟩ := Finset.card_eq_one.mp hcard
  have hmem (x : V) : x ∈ S ↔ G.Adj v x ∧ x ≠ a ∧ x ≠ b := by
    simp only [S, Finset.mem_erase, SimpleGraph.mem_neighborFinset]
    tauto
  refine ⟨w, (hmem w).mp ?_, ?_⟩
  · rw [hw]
    exact Finset.mem_singleton_self w
  · intro y hy
    have hy' := (hmem y).mpr hy
    simpa [hw] using hy'
```

```lean patch id=ramsey-B67-r1.3.h3 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_square_unique_cross_r1
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (l r : Fin 4 → V)
    (hl : Function.Injective l) (hr : Function.Injective r)
    (hd : ∀ v, G.degree v = 3)
    (hdisj : ∀ i j, l i ≠ r j)
    (hcover : ∀ v, (∃ i, l i = v) ∨ ∃ j, r j = v)
    (hleft : ∀ i j, G.Adj (l i) (l j) ↔
      (SimpleGraph.cycleGraph 4).Adj i j) :
    ∀ i, ∃! j, G.Adj (l i) (r j) := by
  intro i
  have hnext : (SimpleGraph.cycleGraph 4).Adj i (i + 1) := by
    fin_cases i <;> decide
  have hprev : (SimpleGraph.cycleGraph 4).Adj i (i + 3) := by
    fin_cases i <;> decide
  have hne : l (i + 1) ≠ l (i + 3) := by
    intro he
    have := hl he
    fin_cases i <;> contradiction
  obtain ⟨w, hw, huniq⟩ := cubic_third_neighbor_r1 G (l i)
    (l (i + 1)) (l (i + 3)) (hd _) ((hleft _ _).mpr hnext)
    ((hleft _ _).mpr hprev) hne
  have hwleft : ∀ k, l k ≠ w := by
    intro k hk
    have hik := (hleft i k).mp (hk.symm ▸ hw.1)
    have hkp : k = i + 1 ∨ k = i + 3 := by
      exact (show ∀ i k : Fin 4, (SimpleGraph.cycleGraph 4).Adj i k →
        k = i + 1 ∨ k = i + 3 by decide) i k hik
    rcases hkp with hk' | hk'
    · exact hw.2.1 (hk.symm.trans (congrArg l hk'))
    · exact hw.2.2 (hk.symm.trans (congrArg l hk'))
  obtain ⟨j, hj⟩ := (hcover w).resolve_left (by
    rintro ⟨k, hk⟩
    exact hwleft k hk)
  refine ⟨j, ?_, ?_⟩
  · simpa only [hj] using hw.1
  · intro k hk
    apply hr
    apply Eq.trans _ hj.symm
    apply huniq
    exact ⟨hk, (hdisj (i + 1) k).symm, (hdisj (i + 3) k).symm⟩
```

```lean patch id=ramsey-B67-r1.3 decl=SizeRamsey.Plan.equality_cubic_impossible sig=9b2211d6 mode=body
by
  classical
  have hhand : 3 * Fintype.card V = 2 * edgeCount G := by
    simpa only [h3, Finset.sum_const, Finset.card_univ, smul_eq_mul,
      Nat.mul_comm, edgeCount] using G.sum_degrees_eq_twice_card_edges
  have ht' := ht
  unfold Tight at ht'
  have hm12 : edgeCount G = 12 := by omega
  have hn8 : Fintype.card V = 8 := by omega
  have ht3 : tau4 G = 3 := by omega
  have hmax : ∀ v, G.degree v ≤ 3 := fun v => by rw [h3]
  have hsquare : HasC4 G := by
    by_contra h
    have := (tau4_eq_zero_iff G).mpr h
    omega
  obtain ⟨l, hl⟩ := hsquare
  obtain ⟨hl02, hl13⟩ := tight_subcubic_chordless G ht hmax l hl
  let D : Finset V := Finset.univ.image l
  have hD : D.card = 4 := by
    simp [D, Finset.card_image_of_injective _ hl.1]
  obtain ⟨hred, hcount⟩ := cubic_chordless_reduction G l
    (fun i => h3 (l i)) hl hl02 hl13
  change tau4 G ≤ tau4 (erase G D) + 2 at hred
  have hres : HasC4 (erase G D) := by
    by_contra h
    have := (tau4_eq_zero_iff (erase G D)).mpr h
    omega
  obtain ⟨q, hq⟩ := hres
  have hcard : Fintype.card {v : V // v ∉ D} = 4 := by
    have := erase_card D
    omega
  have hqbij : Function.Bijective q :=
    (Fintype.bijective_iff_injective_and_card q).mpr
      ⟨hq.1, by simp [hcard]⟩
  let r : Fin 4 → V := fun i => (q i).val
  have hr : Function.Injective r := by
    intro i j hij
    exact hq.1 (Subtype.ext hij)
  have hdisj : ∀ i j, l i ≠ r j := by
    intro i j hij
    apply (q j).property
    exact Finset.mem_image.mpr ⟨i, Finset.mem_univ i, hij⟩
  have hcover : ∀ v, (∃ i, l i = v) ∨ ∃ j, r j = v := by
    intro v
    by_cases hv : v ∈ D
    · left
      obtain ⟨i, _, hi⟩ := Finset.mem_image.mp hv
      exact ⟨i, hi⟩
    · right
      obtain ⟨j, hj⟩ := hqbij.2 ⟨v, hv⟩
      exact ⟨j, congrArg Subtype.val hj⟩
  have hrmap : IsC4Map G r := ⟨hr, hq.2⟩
  obtain ⟨hr02, hr13⟩ := tight_subcubic_chordless G ht hmax r hrmap
  have hleft := cubic_chordless_adjacency_r1 G l hl hl02 hl13
  have hright := cubic_chordless_adjacency_r1 G r hrmap hr02 hr13
  have huniqL := cubic_square_unique_cross_r1 G l r hl.1 hr h3
    hdisj hcover hleft
  have huniqR := cubic_square_unique_cross_r1 G r l hr hl.1 h3
    (fun i j => (hdisj j i).symm) (fun v => (hcover v).symm) hright
  let m : Fin 4 → Fin 4 := fun i => Classical.choose (huniqL i).exists
  have hmAdj : ∀ i, G.Adj (l i) (r (m i)) :=
    fun i => Classical.choose_spec (huniqL i).exists
  have hminj : Function.Injective m := by
    intro i j hij
    apply (huniqR (m i)).unique
    · exact (hmAdj i).symm
    · rw [hij]
      exact (hmAdj j).symm
  let μ : Fin 4 ≃ Fin 4 := Equiv.ofBijective m
    ((Fintype.bijective_iff_injective_and_card m).mpr ⟨hminj, rfl⟩)
  have hcross : ∀ i j, G.Adj (l i) (r j) ↔ μ i = j := by
    intro i j
    constructor
    · intro hij
      exact (huniqL i).unique (hmAdj i) hij
    · intro hij
      subst j
      exact hmAdj i
  have htrans := two_squares_matching_transversal G l r μ hl.1 hr
    hdisj hcover hleft hright hcross
  have hbound := tau4_le_card htrans
  have hcardle : ({l 0, r (μ 2)} : Finset V).card ≤ 2 :=
    Finset.card_le_two
  omega
```

```note id=ramsey-B67-r1.3
Whole modified Cubic.lean piped through lake env lean --stdin: exit 0.
Only declaration-uses-sorry warning: <stdin>:21:8, unchanged crossing lemma.
Additional compiler lint: <stdin>:125:5 unused hc; <stdin>:129:5 unused ih.
Last 3 compiler lines were:
  [apply] _ih

Note: This linter can be disabled with `set_option linter.unusedVariables false`
Original target compiler check: lines 21 and 40 both warned declaration uses sorry.
Route refinement: second square's injectivity and residual cardinal 4 prove coverage; common chordlessness then gives its induced adjacency without separate residual edge exhaustion.
```

```note id=general
Admitted dependencies directly used: SizeRamsey.Plan.tau4_eq_zero_iff, SizeRamsey.Plan.cubic_chordless_reduction, SizeRamsey.Plan.erase_card, SizeRamsey.tau4_le_card.
Through proved SizeRamsey.Plan.tight_subcubic_chordless: SizeRamsey.Plan.subcubic_chord_reduction and SizeRamsey.Plan.universal.
The crossing lemma remains admitted during my isolated compilation; parent's completed proof removes that dependency.
No imports required. No subagents spawned by this child; collaborated with existing audit agent.
```

```proofloop-summary
{"brief":"ramsey-B67-r1","base":"d1c156b","results":[{"id":"ramsey-B67-r1.3","status":"PROVED","elaborated":true,"lean_output":"  [apply] _ih\n\nNote: This linter can be disabled with `set_option linter.unusedVariables false`"}],"helpers":["cubic_chordless_adjacency_r1","cubic_third_neighbor_r1","cubic_square_unique_cross_r1"],"imports":[],"subagents":0,"confidence":0.99}
```

Delivered three compiled private helpers to parent and Mixed agent:

- `b67_audit_cycle4_arrange`
- `b67_audit_mixed_opposite`
- `b67_audit_mixed_normalize`

They prove the attachment vertices are opposite in the residual square and construct the required residual labeling. No extra imports. Each helper’s printed dependencies are exactly `[propext, Classical.choice, Quot.sound]`.

Whole original `Mixed.lean` with these helpers inserted compiled successfully; its only warning remained the unchanged target:
`<stdin>:106:8: warning: declaration uses `sorry``

No false relevant contract found. Caution for final dependency notes: `Basic.lean` and `Deletion.lean` contain admitted declarations here despite the brief’s “proved results” wording. List all used contracts, including `tau4_le_card`, `tau4_eq_zero_iff`, `erase_degree`, or `erase_card` when applicable.

Unmodified target compilation confirmed warnings at Mixed `20:8`, Cubic `21:8` and `40:8`, with exit code 0. No additional subagents spawned.

```lean patch id=ramsey-B67-r1.1 decl=SizeRamsey.Plan.equality_mixed_degree_case sig=36278b38 mode=body
by
  classical
  obtain ⟨u, v, huv, hdu, hdv⟩ := hmix
  have hsq := equality_square_supported G ht
  obtain ⟨f, hf, hf0, hf1⟩ := hsq huv
  have hdiag := tight_subcubic_chordless G ht hmax f hf
  obtain ⟨hfi, hf01, hf12, hf23, hf30⟩ := hf
  let a := f 2
  let t := f 3
  have hat : G.Adj a t := hf23
  have hva : G.Adj v a := hf1 ▸ hf12
  have htu : G.Adj t u := hf0 ▸ hf30
  have huvne : u ≠ v := huv.ne
  have haut : u ≠ t := by
    intro h
    have : (0 : Fin 4) = 3 := hfi (hf0.trans h)
    contradiction
  have huane : u ≠ a := by
    intro h
    have : (0 : Fin 4) = 2 := hfi (hf0.trans h)
    contradiction
  have hvat : v ≠ t := by
    intro h
    have : (1 : Fin 4) = 3 := hfi (hf1.trans h)
    contradiction
  have hva_ne : v ≠ a := hva.ne
  have hat_ne : a ≠ t := hat.ne
  have hnvt : ¬ G.Adj v t := by
    simpa only [hf1] using hdiag.2
  have hNu : G.neighborFinset u = {v, t} := by
    symm
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · simpa using huv
      · simpa using htu.symm
    · rw [G.card_neighborFinset_eq_degree, hdu]
      simp [hvat]
  have hNvcard : (G.neighborFinset v \ {u, a}).card = 1 := by
    rw [Finset.card_sdiff_of_subset]
    · simp [G.card_neighborFinset_eq_degree, hdv, huane]
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · simpa using huv.symm
      · simpa using hva
  obtain ⟨b, hb⟩ := Finset.card_eq_one.mp hNvcard
  have hbmem : b ∈ G.neighborFinset v \ {u, a} := by rw [hb]; simp
  obtain ⟨hbv, hbua⟩ := Finset.mem_sdiff.mp hbmem
  have hvb : G.Adj v b := by simpa using hbv
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hbua
  have hbune : b ≠ u := hbua.1
  have hbane : b ≠ a := hbua.2
  have hbtne : b ≠ t := by
    rintro rfl
    exact hnvt hvb
  have hNv : G.neighborFinset v = {u, a, b} := by
    symm
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl
      · simpa using huv.symm
      · simpa using hva
      · exact hbv
    · rw [G.card_neighborFinset_eq_degree, hdv]
      simp [huane, hbune.symm, hbane.symm]
  have hNu' : ∀ x, G.Adj u x ↔ x = v ∨ x = t := by
    intro x
    rw [← G.mem_neighborFinset, hNu]
    simp
  have hNv' : ∀ x, G.Adj v x ↔ x = u ∨ x = a ∨ x = b := by
    intro x
    rw [← G.mem_neighborFinset, hNv]
    simp
  let D : Finset V := {u, v}
  let H := erase G D
  have haD : a ∉ D := by simp [D, huane.symm, hva_ne.symm]
  have hbD : b ∉ D := by simp [D, hbune, hvb.ne.symm]
  have htD : t ∉ D := by simp [D, haut.symm, hvat.symm]
  let A : {x : V // x ∉ D} := ⟨a, haD⟩
  let B : {x : V // x ∉ D} := ⟨b, hbD⟩
  let T : {x : V // x ∉ D} := ⟨t, htD⟩
  have hmin := equality_min_degree G hc hp ht
  have hcut_le : ∀ x : {x : V // x ∉ D},
      (G.neighborFinset x.val ∩ D).card ≤ 1 := by
    intro x
    have hx : x.val ≠ u ∧ x.val ≠ v := by simpa [D] using x.property
    by_cases hxu : G.Adj x.val u
    · have hxt : x.val = t := (hNu' x.val).mp hxu.symm |>.resolve_left hx.2
      have hsub : G.neighborFinset x.val ∩ D ⊆ {u} := by
        intro y hy
        obtain ⟨hyN, hyD⟩ := Finset.mem_inter.mp hy
        have hxy : G.Adj x.val y := by simpa using hyN
        simp only [D, Finset.mem_insert, Finset.mem_singleton] at hyD
        rcases hyD with rfl | rfl
        · simp
        · exact (hnvt (hxt ▸ hxy.symm)).elim
      exact (Finset.card_le_card hsub).trans (by simp)
    · have hsub : G.neighborFinset x.val ∩ D ⊆ {v} := by
        intro y hy
        obtain ⟨hyN, hyD⟩ := Finset.mem_inter.mp hy
        have hxy : G.Adj x.val y := by simpa using hyN
        simp only [D, Finset.mem_insert, Finset.mem_singleton] at hyD
        rcases hyD with rfl | rfl
        · exact (hxu hxy).elim
        · simp
      exact (Finset.card_le_card hsub).trans (by simp)
  have hHnoiso : ∀ x, 0 < H.degree x := by
    intro x
    have hd := erase_degree G D x
    have hm := hmin x.val
    have hx := hcut_le x
    change H.degree x + _ = _ at hd
    omega
  have hHp : 0 < edgeCount H := by
    have hd := H.degree_le_card_edgeFinset A
    have hp := hHnoiso A
    rw [← edgeCount_eq_card] at hd
    omega
  obtain ⟨hlift, hcount⟩ := mixed_reduction G huv hdu hdv
  change tau4 G ≤ tau4 H + 1 at hlift
  change edgeCount H + 4 = edgeCount G at hcount
  have hHtight : Tight H := by
    have hA := universal H
    unfold Tight at ht ⊢
    omega
  have hDnonempty : D.Nonempty := by simp [D]
  have hDproper : D ≠ Finset.univ := by
    intro h
    exact haD (h.symm ▸ Finset.mem_univ a)
  have hcut2 : ∀ C : H.ConnectedComponent,
      2 ≤ (attachmentEdges G D C).card :=
    component_attachment_card_ge_two G hc hsq D hDnonempty hDproper
  have hcounts := erase_edgeCount G D
  have hdegs : ∑ x ∈ D, G.degree x = 5 := by simp [D, huvne, hdu, hdv]
  rw [hdegs] at hcounts
  change edgeCount H + 5 = edgeCount G + _ at hcounts
  have hinner : edgeCount (G.induce (D : Set V)) = 1 := by omega
  have hsum : ∑ C : H.ConnectedComponent, (attachmentEdges G D C).card = 3 := by
    have hs := attachment_sum G D
    have hs' : (∑ C : H.ConnectedComponent, (attachmentEdges G D C).card) + 2 = 5 := by
      simpa only [hinner, hdegs, Nat.mul_one] using hs
    omega
  have hcompeq : ∀ C C' : H.ConnectedComponent, C = C' := by
    intro C C'
    by_contra hne
    have hle : ∑ K ∈ ({C, C'} : Finset H.ConnectedComponent),
        (attachmentEdges G D K).card ≤
        ∑ K : H.ConnectedComponent, (attachmentEdges G D K).card :=
      Finset.sum_le_sum_of_subset (Finset.subset_univ _)
    rw [Finset.sum_pair hne, hsum] at hle
    have hC := hcut2 C
    have hC' := hcut2 C'
    omega
  have hHconn : H.Connected :=
    (SimpleGraph.connected_iff_exists_forall_reachable H).mpr
      ⟨A, fun y => SimpleGraph.ConnectedComponent.exact
        (hcompeq (H.connectedComponentMk A) (H.connectedComponentMk y))⟩
  have hclassified : Classified H := ih H hHconn hHp (by omega) hHtight
  have hHmin := equality_min_degree H hHconn hHp hHtight
  have hdeg_attach : ∀ x : {x : V // x ∉ D},
      (G.Adj x.val u ∨ G.Adj x.val v) → H.degree x = 2 := by
    intro x hx
    have hex : (G.neighborFinset x.val ∩ D).Nonempty := by
      rcases hx with hx | hx
      · exact ⟨u, Finset.mem_inter.mpr ⟨by simpa using hx, by simp [D]⟩⟩
      · exact ⟨v, Finset.mem_inter.mpr ⟨by simpa using hx, by simp [D]⟩⟩
    have hpos := Finset.card_pos.mpr hex
    have hd := erase_degree G D x
    have hle := hmax x.val
    have hge := hHmin x
    change H.degree x + _ = _ at hd
    omega
  have hda : H.degree A = 2 := hdeg_attach A (Or.inr hva.symm)
  have hdb : H.degree B = 2 := hdeg_attach B (Or.inr hvb.symm)
  have hdt : H.degree T = 2 := hdeg_attach T (Or.inl htu)
  obtain ⟨e⟩ := classified_three_degree_two H hclassified A B T
    (by intro h; exact hbane (congrArg Subtype.val h).symm)
    (by intro h; exact hat_ne (congrArg Subtype.val h))
    (by intro h; exact hbtne (congrArg Subtype.val h))
    hda hdb hdt
  obtain ⟨q, hq, hq0, hq1, hq2, hqadj⟩ :=
    b67_audit_mixed_normalize G u v A B T
      (by intro h; exact hbane (congrArg Subtype.val h).symm)
      (by intro h; exact hat_ne (congrArg Subtype.val h))
      (by intro h; exact hbtne (congrArg Subtype.val h))
      hNu' hNv' hat hsq e
  apply b67_mixed_final_labels G u v huvne q hq hqadj
  · simpa only [hq1] using hNu'
  · simpa only [hq0, hq2] using hNv'
```

```note id=ramsey-B67-r1.1
All four helpers supplied by root/audit and root were inserted before the target, then this entire modified Mixed.lean was piped through lake env lean --stdin.
Compiler exit 0; no declaration-uses-sorry warning.
Only compiler warning: <stdin>:169:5: warning: Variable name `hm` is not explicitly referenced.
Last three lines: "  [apply] _hm", blank, "Note: This linter can be disabled with `set_option linter.unusedVariables false`".
A second full-source compilation with #print axioms also exited 0 and printed:
'SizeRamsey.Plan.equality_mixed_degree_case' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
Non-isolation, residual connectedness, three degree-two attachments, and explicit relabelling are separately proved.
Residual tightness uses direct saturation of mixed_reduction and universal instead of equality_residual_components.
```

```note id=general
Admitted dependencies used directly: SizeRamsey.Plan.equality_square_supported, SizeRamsey.Plan.equality_min_degree, SizeRamsey.Plan.mixed_reduction, SizeRamsey.Plan.erase_degree, SizeRamsey.Plan.universal, SizeRamsey.Plan.erase_edgeCount, SizeRamsey.Plan.component_attachment_card_ge_two, SizeRamsey.Plan.attachment_sum, SizeRamsey.Plan.classified_three_degree_two.
Through proved SizeRamsey.Plan.tight_subcubic_chordless: SizeRamsey.Plan.subcubic_chord_reduction and SizeRamsey.Plan.universal.
All reconstruction helpers have no admitted project dependency.
No imports required.
This child spawned no further agents; collaborated with existing audit agent on opposite attachment and normalization, and root on the final relabelling.
```

```proofloop-summary
{"brief":"ramsey-B67-r1","base":"d1c156b","results":[{"id":"ramsey-B67-r1.1","status":"PROVED","elaborated":true,"lean_output":"  [apply] _hm\n\nNote: This linter can be disabled with `set_option linter.unusedVariables false`"}],"helpers":["b67_audit_cycle4_arrange","b67_audit_mixed_opposite","b67_audit_mixed_normalize","b67_mixed_final_labels"],"imports":[],"subagents":0,"confidence":0.99}
```

```lean patch id=ramsey-B67-r1.1.h1 mode=helper before=SizeRamsey.Plan.equality_mixed_degree_case
private theorem b67_audit_cycle4_arrange (i j k : Fin 4)
    (hij : i ≠ j) (hik : i ≠ k) (hjk : j ≠ k)
    (hij' : ¬ (SimpleGraph.cycleGraph 4).Adj i j)
    (hik' : (SimpleGraph.cycleGraph 4).Adj i k) :
    ∃ l : Fin 4, Function.Bijective ![i,k,j,l] ∧
      ∀ x y : Fin 4,
        (SimpleGraph.cycleGraph 4).Adj (![i,k,j,l] x) (![i,k,j,l] y) ↔
        (SimpleGraph.cycleGraph 4).Adj x y := by
  have hh : ∀ i j k : Fin 4, i ≠ j → i ≠ k → j ≠ k →
      ¬ (SimpleGraph.cycleGraph 4).Adj i j →
      (SimpleGraph.cycleGraph 4).Adj i k →
      ∃ l : Fin 4, Function.Bijective ![i,k,j,l] ∧
        ∀ x y : Fin 4,
          (SimpleGraph.cycleGraph 4).Adj (![i,k,j,l] x) (![i,k,j,l] y) ↔
          (SimpleGraph.cycleGraph 4).Adj x y := by decide
  exact hh i j k hij hik hjk hij' hik'
```

```lean patch id=ramsey-B67-r1.1.h2 mode=helper before=SizeRamsey.Plan.equality_mixed_degree_case
private theorem b67_audit_mixed_opposite
    {V : Type*} [Fintype V] (G : SimpleGraph V) (u v : V)
    (a b t : {x : V // x ∉ ({u,v} : Finset V)})
    (_hab : a ≠ b) (_hat : a ≠ t) (hbt : b ≠ t)
    (hNu : ∀ x, G.Adj u x ↔ x = v ∨ x = t.val)
    (hNv : ∀ x, G.Adj v x ↔ x = u ∨ x = a.val ∨ x = b.val)
    (hatAdj : G.Adj a.val t.val)
    (hs : SquareSupported G)
    (e : erase G {u,v} ≃g SimpleGraph.cycleGraph 4) :
    ¬ G.Adj a.val b.val := by
  classical
  have hbv : b.val ≠ v := by
    intro h
    exact b.property (by simp [h])
  have hbtv : b.val ≠ t.val := fun h => hbt (Subtype.ext h)
  have htri : ∀ x y z : {x : V // x ∉ ({u,v} : Finset V)},
      G.Adj x.val y.val → G.Adj x.val z.val → ¬ G.Adj y.val z.val := by
    intro x y z hxy hxz hyz
    have hh : ∀ i j k : Fin 4,
        (SimpleGraph.cycleGraph 4).Adj i j →
        (SimpleGraph.cycleGraph 4).Adj i k →
        ¬ (SimpleGraph.cycleGraph 4).Adj j k := by decide
    exact hh (e x) (e y) (e z) (e.map_rel_iff.mpr hxy)
      (e.map_rel_iff.mpr hxz) (e.map_rel_iff.mpr hyz)
  intro habAdj
  obtain ⟨f, ⟨hinj, h01, h12, h23, h30⟩, hf0, hf1⟩ :=
    hs ((hNv b.val).mpr (Or.inr (Or.inr rfl)))
  have hxv : f 2 ≠ v := by
    rw [← hf0]
    exact hinj.ne (by decide)
  have hyb : f 3 ≠ b.val := by
    rw [← hf1]
    exact hinj.ne (by decide)
  have hy := (hNv (f 3)).mp (by simpa only [hf0] using h30.symm)
  rcases hy with hy | hy | hy
  · have hx := (hNu (f 2)).mp (by simpa only [hy] using h23.symm)
    rcases hx with hx | hx
    · exact hxv hx
    · have hbtAdj : G.Adj b.val t.val := by simpa only [hf1, hx] using h12
      exact htri a b t habAdj hatAdj hbtAdj
  · have hxu : f 2 ≠ u := by
      intro hx
      have hb := (hNu b.val).mp (by simpa only [hf1, hx] using h12.symm)
      exact hb.elim hbv hbtv
    let x : {x : V // x ∉ ({u,v} : Finset V)} := ⟨f 2, by simp [hxu, hxv]⟩
    exact htri a b x habAdj (by simpa only [hy] using h23.symm)
      (by simpa only [hf1] using h12)
  · exact hyb hy
```

```lean patch id=ramsey-B67-r1.1.h3 mode=helper before=SizeRamsey.Plan.equality_mixed_degree_case
private theorem b67_audit_mixed_normalize
    {V : Type*} [Fintype V] (G : SimpleGraph V) (u v : V)
    (a b t : {x : V // x ∉ ({u,v} : Finset V)})
    (hab : a ≠ b) (hat : a ≠ t) (hbt : b ≠ t)
    (hNu : ∀ x, G.Adj u x ↔ x = v ∨ x = t.val)
    (hNv : ∀ x, G.Adj v x ↔ x = u ∨ x = a.val ∨ x = b.val)
    (hatAdj : G.Adj a.val t.val)
    (hs : SquareSupported G)
    (e : erase G {u,v} ≃g SimpleGraph.cycleGraph 4) :
    ∃ q : Fin 4 → {x : V // x ∉ ({u,v} : Finset V)},
      Function.Bijective q ∧ q 0 = a ∧ q 1 = t ∧ q 2 = b ∧
      ∀ i j, G.Adj (q i).val (q j).val ↔
        (SimpleGraph.cycleGraph 4).Adj i j := by
  have hnab := b67_audit_mixed_opposite G u v a b t hab hat hbt hNu hNv hatAdj hs e
  obtain ⟨l, hp, hrel⟩ := b67_audit_cycle4_arrange (e a) (e b) (e t)
    (e.injective.ne hab) (e.injective.ne hat) (e.injective.ne hbt)
    (fun h => hnab (e.map_rel_iff.mp h)) (e.map_rel_iff.mpr hatAdj)
  refine ⟨fun i => e.symm (![e a, e t, e b, l] i), e.symm.bijective.comp hp,
    by simp, by simp, by simp, ?_⟩
  intro i j
  exact e.symm.map_rel_iff.trans (hrel i j)
```

```lean patch id=ramsey-B67-r1.1.h4 mode=helper before=SizeRamsey.Plan.equality_mixed_degree_case
private theorem b67_mixed_final_labels
    {V : Type u} [Fintype V] (G : SimpleGraph V) (u v : V)
    (huv : u ≠ v)
    (q : Fin 4 → {x : V // x ∉ ({u, v} : Finset V)})
    (hq : Function.Bijective q)
    (hR : ∀ i j, G.Adj (q i).val (q j).val ↔
      (SimpleGraph.cycleGraph 4).Adj i j)
    (hNu : ∀ x, G.Adj u x ↔ x = v ∨ x = (q 1).val)
    (hNv : ∀ x, G.Adj v x ↔ x = u ∨ x = (q 0).val ∨ x = (q 2).val) :
    Nonempty (G ≃g k33MinusEdge) := by
  classical
  have hqu : ∀ i, (q i).val ≠ u := by
    intro i
    have h := (q i).property
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at h
    exact h.1
  have hqv : ∀ i, (q i).val ≠ v := by
    intro i
    have h := (q i).property
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at h
    exact h.2
  have hqi : Function.Injective (fun i => (q i).val) :=
    fun i j h => hq.1 (Subtype.ext h)
  let f : Fin 6 → V := ![u, (q 0).val, (q 2).val, (q 3).val, v, (q 1).val]
  have hfi : Function.Injective f := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [f, hqi.eq_iff]
  have hfs : Function.Surjective f := by
    intro x
    by_cases hxu : x = u
    · exact ⟨0, hxu.symm⟩
    by_cases hxv : x = v
    · exact ⟨4, hxv.symm⟩
    obtain ⟨i, hi⟩ := hq.2 ⟨x, by simp [hxu, hxv]⟩
    have hi' : (q i).val = x := congrArg Subtype.val hi
    fin_cases i
    · exact ⟨1, hi'⟩
    · exact ⟨5, hi'⟩
    · exact ⟨2, hi'⟩
    · exact ⟨3, hi'⟩
  have huN : ∀ x, G.Adj x u ↔ x = v ∨ x = (q 1).val := by
    intro x
    rw [G.adj_comm, hNu]
  have hvN : ∀ x, G.Adj x v ↔ x = u ∨ x = (q 0).val ∨ x = (q 2).val := by
    intro x
    rw [G.adj_comm, hNv]
  have hadj : ∀ i j, G.Adj (f i) (f j) ↔ k33MinusEdge.Adj i j := by
    intro i j
    fin_cases i <;> fin_cases j <;>
      simp [f, hNu, hNv, huN, hvN, hR, hqi.eq_iff, hqu, hqv,
        k33MinusEdge, graphOfEdges, SimpleGraph.fromRel,
        SimpleGraph.cycleGraph] <;> decide
  let e : k33MinusEdge ≃g G := {
    toEquiv := Equiv.ofBijective f ⟨hfi, hfs⟩
    map_rel_iff' := by intro i j; exact hadj i j }
  exact ⟨e.symm⟩
```

```lean patch id=ramsey-B67-r1.1 decl=SizeRamsey.Plan.equality_mixed_degree_case sig=36278b38 mode=body
by
  classical
  obtain ⟨u, v, huv, hdu, hdv⟩ := hmix
  have hsq := equality_square_supported G ht
  obtain ⟨f, hf, hf0, hf1⟩ := hsq huv
  have hdiag := tight_subcubic_chordless G ht hmax f hf
  obtain ⟨hfi, hf01, hf12, hf23, hf30⟩ := hf
  let a := f 2
  let t := f 3
  have hat : G.Adj a t := hf23
  have hva : G.Adj v a := hf1 ▸ hf12
  have htu : G.Adj t u := hf0 ▸ hf30
  have huvne : u ≠ v := huv.ne
  have haut : u ≠ t := by
    intro h
    have : (0 : Fin 4) = 3 := hfi (hf0.trans h)
    contradiction
  have huane : u ≠ a := by
    intro h
    have : (0 : Fin 4) = 2 := hfi (hf0.trans h)
    contradiction
  have hvat : v ≠ t := by
    intro h
    have : (1 : Fin 4) = 3 := hfi (hf1.trans h)
    contradiction
  have hva_ne : v ≠ a := hva.ne
  have hat_ne : a ≠ t := hat.ne
  have hnvt : ¬ G.Adj v t := by
    simpa only [hf1] using hdiag.2
  have hNu : G.neighborFinset u = {v, t} := by
    symm
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · simpa using huv
      · simpa using htu.symm
    · rw [G.card_neighborFinset_eq_degree, hdu]
      simp [hvat]
  have hNvcard : (G.neighborFinset v \ {u, a}).card = 1 := by
    rw [Finset.card_sdiff_of_subset]
    · simp [G.card_neighborFinset_eq_degree, hdv, huane]
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · simpa using huv.symm
      · simpa using hva
  obtain ⟨b, hb⟩ := Finset.card_eq_one.mp hNvcard
  have hbmem : b ∈ G.neighborFinset v \ {u, a} := by rw [hb]; simp
  obtain ⟨hbv, hbua⟩ := Finset.mem_sdiff.mp hbmem
  have hvb : G.Adj v b := by simpa using hbv
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hbua
  have hbune : b ≠ u := hbua.1
  have hbane : b ≠ a := hbua.2
  have hbtne : b ≠ t := by
    rintro rfl
    exact hnvt hvb
  have hNv : G.neighborFinset v = {u, a, b} := by
    symm
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl
      · simpa using huv.symm
      · simpa using hva
      · exact hbv
    · rw [G.card_neighborFinset_eq_degree, hdv]
      simp [huane, hbune.symm, hbane.symm]
  have hNu' : ∀ x, G.Adj u x ↔ x = v ∨ x = t := by
    intro x
    rw [← G.mem_neighborFinset, hNu]
    simp
  have hNv' : ∀ x, G.Adj v x ↔ x = u ∨ x = a ∨ x = b := by
    intro x
    rw [← G.mem_neighborFinset, hNv]
    simp
  let D : Finset V := {u, v}
  let H := erase G D
  have haD : a ∉ D := by simp [D, huane.symm, hva_ne.symm]
  have hbD : b ∉ D := by simp [D, hbune, hvb.ne.symm]
  have htD : t ∉ D := by simp [D, haut.symm, hvat.symm]
  let A : {x : V // x ∉ D} := ⟨a, haD⟩
  let B : {x : V // x ∉ D} := ⟨b, hbD⟩
  let T : {x : V // x ∉ D} := ⟨t, htD⟩
  have hmin := equality_min_degree G hc hp ht
  have hcut_le : ∀ x : {x : V // x ∉ D},
      (G.neighborFinset x.val ∩ D).card ≤ 1 := by
    intro x
    have hx : x.val ≠ u ∧ x.val ≠ v := by simpa [D] using x.property
    by_cases hxu : G.Adj x.val u
    · have hxt : x.val = t := (hNu' x.val).mp hxu.symm |>.resolve_left hx.2
      have hsub : G.neighborFinset x.val ∩ D ⊆ {u} := by
        intro y hy
        obtain ⟨hyN, hyD⟩ := Finset.mem_inter.mp hy
        have hxy : G.Adj x.val y := by simpa using hyN
        simp only [D, Finset.mem_insert, Finset.mem_singleton] at hyD
        rcases hyD with rfl | rfl
        · simp
        · exact (hnvt (hxt ▸ hxy.symm)).elim
      exact (Finset.card_le_card hsub).trans (by simp)
    · have hsub : G.neighborFinset x.val ∩ D ⊆ {v} := by
        intro y hy
        obtain ⟨hyN, hyD⟩ := Finset.mem_inter.mp hy
        have hxy : G.Adj x.val y := by simpa using hyN
        simp only [D, Finset.mem_insert, Finset.mem_singleton] at hyD
        rcases hyD with rfl | rfl
        · exact (hxu hxy).elim
        · simp
      exact (Finset.card_le_card hsub).trans (by simp)
  have hHnoiso : ∀ x, 0 < H.degree x := by
    intro x
    have hd := erase_degree G D x
    have hm := hmin x.val
    have hx := hcut_le x
    change H.degree x + _ = _ at hd
    omega
  have hHp : 0 < edgeCount H := by
    have hd := H.degree_le_card_edgeFinset A
    have hp := hHnoiso A
    rw [← edgeCount_eq_card] at hd
    omega
  obtain ⟨hlift, hcount⟩ := mixed_reduction G huv hdu hdv
  change tau4 G ≤ tau4 H + 1 at hlift
  change edgeCount H + 4 = edgeCount G at hcount
  have hHtight : Tight H := by
    have hA := universal H
    unfold Tight at ht ⊢
    omega
  have hDnonempty : D.Nonempty := by simp [D]
  have hDproper : D ≠ Finset.univ := by
    intro h
    exact haD (h.symm ▸ Finset.mem_univ a)
  have hcut2 : ∀ C : H.ConnectedComponent,
      2 ≤ (attachmentEdges G D C).card :=
    component_attachment_card_ge_two G hc hsq D hDnonempty hDproper
  have hcounts := erase_edgeCount G D
  have hdegs : ∑ x ∈ D, G.degree x = 5 := by simp [D, huvne, hdu, hdv]
  rw [hdegs] at hcounts
  change edgeCount H + 5 = edgeCount G + _ at hcounts
  have hinner : edgeCount (G.induce (D : Set V)) = 1 := by omega
  have hsum : ∑ C : H.ConnectedComponent, (attachmentEdges G D C).card = 3 := by
    have hs := attachment_sum G D
    have hs' : (∑ C : H.ConnectedComponent, (attachmentEdges G D C).card) + 2 = 5 := by
      simpa only [hinner, hdegs, Nat.mul_one] using hs
    omega
  have hcompeq : ∀ C C' : H.ConnectedComponent, C = C' := by
    intro C C'
    by_contra hne
    have hle : ∑ K ∈ ({C, C'} : Finset H.ConnectedComponent),
        (attachmentEdges G D K).card ≤
        ∑ K : H.ConnectedComponent, (attachmentEdges G D K).card :=
      Finset.sum_le_sum_of_subset (Finset.subset_univ _)
    rw [Finset.sum_pair hne, hsum] at hle
    have hC := hcut2 C
    have hC' := hcut2 C'
    omega
  have hHconn : H.Connected :=
    (SimpleGraph.connected_iff_exists_forall_reachable H).mpr
      ⟨A, fun y => SimpleGraph.ConnectedComponent.exact
        (hcompeq (H.connectedComponentMk A) (H.connectedComponentMk y))⟩
  have hclassified : Classified H := ih H hHconn hHp (by omega) hHtight
  have hHmin := equality_min_degree H hHconn hHp hHtight
  have hdeg_attach : ∀ x : {x : V // x ∉ D},
      (G.Adj x.val u ∨ G.Adj x.val v) → H.degree x = 2 := by
    intro x hx
    have hex : (G.neighborFinset x.val ∩ D).Nonempty := by
      rcases hx with hx | hx
      · exact ⟨u, Finset.mem_inter.mpr ⟨by simpa using hx, by simp [D]⟩⟩
      · exact ⟨v, Finset.mem_inter.mpr ⟨by simpa using hx, by simp [D]⟩⟩
    have hpos := Finset.card_pos.mpr hex
    have hd := erase_degree G D x
    have hle := hmax x.val
    have hge := hHmin x
    change H.degree x + _ = _ at hd
    omega
  have hda : H.degree A = 2 := hdeg_attach A (Or.inr hva.symm)
  have hdb : H.degree B = 2 := hdeg_attach B (Or.inr hvb.symm)
  have hdt : H.degree T = 2 := hdeg_attach T (Or.inl htu)
  obtain ⟨e⟩ := classified_three_degree_two H hclassified A B T
    (by intro h; exact hbane (congrArg Subtype.val h).symm)
    (by intro h; exact hat_ne (congrArg Subtype.val h))
    (by intro h; exact hbtne (congrArg Subtype.val h))
    hda hdb hdt
  obtain ⟨q, hq, hq0, hq1, hq2, hqadj⟩ :=
    b67_audit_mixed_normalize G u v A B T
      (by intro h; exact hbane (congrArg Subtype.val h).symm)
      (by intro h; exact hat_ne (congrArg Subtype.val h))
      (by intro h; exact hbtne (congrArg Subtype.val h))
      hNu' hNv' hat hsq e
  apply b67_mixed_final_labels G u v huvne q hq hqadj
  · simpa only [hq1] using hNu'
  · simpa only [hq0, hq2] using hNv'
```

```lean patch id=ramsey-B67-r1.2 decl=SizeRamsey.Plan.two_squares_matching_transversal sig=f285a7ee mode=body
by
  intro f hf
  classical
  by_contra hno
  push Not at hno
  have hll : ∀ a b : Fin 4, (SimpleGraph.cycleGraph 4).Adj a b →
      a ≠ 0 → b ≠ 0 → a = 2 ∨ b = 2 := by decide
  have hcycle : ∀ a b c d k : Fin 4,
      (SimpleGraph.cycleGraph 4).Adj a b →
      (SimpleGraph.cycleGraph 4).Adj b c →
      (SimpleGraph.cycleGraph 4).Adj c d →
      (SimpleGraph.cycleGraph 4).Adj d a →
      a ≠ c → b ≠ d → a = k ∨ b = k ∨ c = k ∨ d = k := by decide
  have hrr : ∀ a b, G.Adj (r a) (l b) ↔ μ b = a := by
    intro a b
    rw [G.adj_comm, hcross]
  have h02 : f 0 ≠ f 2 := fun h => absurd (hf.1 h) (by decide)
  have h13 : f 1 ≠ f 3 := fun h => absurd (hf.1 h) (by decide)
  have hn0 := hno 0
  have hn1 := hno 1
  have hn2 := hno 2
  have hn3 := hno 3
  obtain ⟨hinj, h01, h12, h23, h30⟩ := hf
  rcases hcover (f 0) with ⟨a, ha⟩ | ⟨a, ha⟩ <;>
    rcases hcover (f 1) with ⟨b, hb⟩ | ⟨b, hb⟩ <;>
    rcases hcover (f 2) with ⟨c, hc⟩ | ⟨c, hc⟩ <;>
    rcases hcover (f 3) with ⟨d, hd⟩ | ⟨d, hd⟩
  all_goals
    simp only [← ha, ← hb, ← hc, ← hd, hleft, hright, hcross, hrr] at h01 h12 h23 h30
    simp only [← ha, ← hb, ← hc, ← hd, Finset.mem_insert, Finset.mem_singleton,
      not_or, ne_eq, hl.eq_iff, hr.eq_iff] at hn0 hn1 hn2 hn3 h02 h13
  · exact (hcycle a b c d 0 h01 h12 h23 h30 h02 h13).elim hn0.1
      (fun h => h.elim hn1.1 (fun h => h.elim hn2.1 hn3.1))
  · exact h02 (μ.injective (h30.trans h23.symm))
  · exact h13 (μ.injective (h12.trans h23.symm))
  · rcases hll a b h01 hn0.1 hn1.1 with ha2 | hb2
    · exact hn3.2 (h30.symm.trans (congrArg μ ha2))
    · exact hn2.2 (h12.symm.trans (congrArg μ hb2))
  · exact h02 (μ.injective (h01.trans h12.symm))
  · exact h02 (μ.injective (h01.trans h12.symm))
  · rcases hll d a h30 hn3.1 hn0.1 with hd2 | ha2
    · exact hn2.2 (h23.symm.trans (congrArg μ hd2))
    · exact hn1.2 (h01.symm.trans (congrArg μ ha2))
  · exact h13 (h01.symm.trans h30)
  · exact h13 (μ.injective (h01.trans h30.symm))
  · rcases hll b c h12 hn1.1 hn2.1 with hb2 | hc2
    · exact hn0.2 (h01.symm.trans (congrArg μ hb2))
    · exact hn3.2 (h23.symm.trans (congrArg μ hc2))
  · exact h02 (h01.symm.trans h12)
  · exact h02 (h01.symm.trans h12)
  · rcases hll c d h23 hn2.1 hn3.1 with hc2 | hd2
    · exact hn1.2 (h12.symm.trans (congrArg μ hc2))
    · exact hn0.2 (h30.symm.trans (congrArg μ hd2))
  · exact h13 (h12.symm.trans h23)
  · exact h02 (h30.symm.trans h23)
  · exact (hcycle a b c d (μ 2) h01 h12 h23 h30 h02 h13).elim hn0.2
      (fun h => h.elim hn1.2 (fun h => h.elim hn2.2 hn3.2))
```

```lean patch id=ramsey-B67-r1.3.h1 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_chordless_adjacency_r1
    {V : Type u} (G : SimpleGraph V) (f : Fin 4 → V)
    (hf : IsC4Map G f)
    (h02 : ¬ G.Adj (f 0) (f 2)) (h13 : ¬ G.Adj (f 1) (f 3)) :
    ∀ i j, G.Adj (f i) (f j) ↔ (SimpleGraph.cycleGraph 4).Adj i j := by
  obtain ⟨hi, h01, h12, h23, h30⟩ := hf
  have h10 := h01.symm
  have h21 := h12.symm
  have h32 := h23.symm
  have h03 := h30.symm
  have h20 : ¬ G.Adj (f 2) (f 0) := fun h => h02 h.symm
  have h31 : ¬ G.Adj (f 3) (f 1) := fun h => h13 h.symm
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp_all [SimpleGraph.cycleGraph_adj] <;> decide
```

```lean patch id=ramsey-B67-r1.3.h2 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_third_neighbor_r1
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (v a b : V) (hd : G.degree v = 3)
    (ha : G.Adj v a) (hb : G.Adj v b) (hab : a ≠ b) :
    ∃! w, G.Adj v w ∧ w ≠ a ∧ w ≠ b := by
  classical
  let S := ((G.neighborFinset v).erase a).erase b
  have ha' : a ∈ G.neighborFinset v := by simpa using ha
  have hb' : b ∈ (G.neighborFinset v).erase a := by
    simp [hb, hab.symm]
  have hcard : S.card = 1 := by
    dsimp only [S]
    rw [Finset.card_erase_of_mem hb', Finset.card_erase_of_mem ha',
      G.card_neighborFinset_eq_degree, hd]
  obtain ⟨w, hw⟩ := Finset.card_eq_one.mp hcard
  have hmem (x : V) : x ∈ S ↔ G.Adj v x ∧ x ≠ a ∧ x ≠ b := by
    simp only [S, Finset.mem_erase, SimpleGraph.mem_neighborFinset]
    tauto
  refine ⟨w, (hmem w).mp ?_, ?_⟩
  · rw [hw]
    exact Finset.mem_singleton_self w
  · intro y hy
    have hy' := (hmem y).mpr hy
    simpa [hw] using hy'
```

```lean patch id=ramsey-B67-r1.3.h3 mode=helper before=SizeRamsey.Plan.equality_cubic_impossible
private theorem cubic_square_unique_cross_r1
    {V : Type u} [Fintype V] (G : SimpleGraph V)
    (l r : Fin 4 → V)
    (hl : Function.Injective l) (hr : Function.Injective r)
    (hd : ∀ v, G.degree v = 3)
    (hdisj : ∀ i j, l i ≠ r j)
    (hcover : ∀ v, (∃ i, l i = v) ∨ ∃ j, r j = v)
    (hleft : ∀ i j, G.Adj (l i) (l j) ↔
      (SimpleGraph.cycleGraph 4).Adj i j) :
    ∀ i, ∃! j, G.Adj (l i) (r j) := by
  intro i
  have hnext : (SimpleGraph.cycleGraph 4).Adj i (i + 1) := by
    fin_cases i <;> decide
  have hprev : (SimpleGraph.cycleGraph 4).Adj i (i + 3) := by
    fin_cases i <;> decide
  have hne : l (i + 1) ≠ l (i + 3) := by
    intro he
    have := hl he
    fin_cases i <;> contradiction
  obtain ⟨w, hw, huniq⟩ := cubic_third_neighbor_r1 G (l i)
    (l (i + 1)) (l (i + 3)) (hd _) ((hleft _ _).mpr hnext)
    ((hleft _ _).mpr hprev) hne
  have hwleft : ∀ k, l k ≠ w := by
    intro k hk
    have hik := (hleft i k).mp (hk.symm ▸ hw.1)
    have hkp : k = i + 1 ∨ k = i + 3 := by
      exact (show ∀ i k : Fin 4, (SimpleGraph.cycleGraph 4).Adj i k →
        k = i + 1 ∨ k = i + 3 by decide) i k hik
    rcases hkp with hk' | hk'
    · exact hw.2.1 (hk.symm.trans (congrArg l hk'))
    · exact hw.2.2 (hk.symm.trans (congrArg l hk'))
  obtain ⟨j, hj⟩ := (hcover w).resolve_left (by
    rintro ⟨k, hk⟩
    exact hwleft k hk)
  refine ⟨j, ?_, ?_⟩
  · simpa only [hj] using hw.1
  · intro k hk
    apply hr
    apply Eq.trans _ hj.symm
    apply huniq
    exact ⟨hk, (hdisj (i + 1) k).symm, (hdisj (i + 3) k).symm⟩
```

```lean patch id=ramsey-B67-r1.3 decl=SizeRamsey.Plan.equality_cubic_impossible sig=9b2211d6 mode=body
by
  classical
  have hhand : 3 * Fintype.card V = 2 * edgeCount G := by
    simpa only [h3, Finset.sum_const, Finset.card_univ, smul_eq_mul,
      Nat.mul_comm, edgeCount] using G.sum_degrees_eq_twice_card_edges
  have ht' := ht
  unfold Tight at ht'
  have hm12 : edgeCount G = 12 := by omega
  have hn8 : Fintype.card V = 8 := by omega
  have ht3 : tau4 G = 3 := by omega
  have hmax : ∀ v, G.degree v ≤ 3 := fun v => by rw [h3]
  have hsquare : HasC4 G := by
    by_contra h
    have := (tau4_eq_zero_iff G).mpr h
    omega
  obtain ⟨l, hl⟩ := hsquare
  obtain ⟨hl02, hl13⟩ := tight_subcubic_chordless G ht hmax l hl
  let D : Finset V := Finset.univ.image l
  have hD : D.card = 4 := by
    simp [D, Finset.card_image_of_injective _ hl.1]
  obtain ⟨hred, hcount⟩ := cubic_chordless_reduction G l
    (fun i => h3 (l i)) hl hl02 hl13
  change tau4 G ≤ tau4 (erase G D) + 2 at hred
  have hres : HasC4 (erase G D) := by
    by_contra h
    have := (tau4_eq_zero_iff (erase G D)).mpr h
    omega
  obtain ⟨q, hq⟩ := hres
  have hcard : Fintype.card {v : V // v ∉ D} = 4 := by
    have := erase_card D
    omega
  have hqbij : Function.Bijective q :=
    (Fintype.bijective_iff_injective_and_card q).mpr
      ⟨hq.1, by simp [hcard]⟩
  let r : Fin 4 → V := fun i => (q i).val
  have hr : Function.Injective r := by
    intro i j hij
    exact hq.1 (Subtype.ext hij)
  have hdisj : ∀ i j, l i ≠ r j := by
    intro i j hij
    apply (q j).property
    exact Finset.mem_image.mpr ⟨i, Finset.mem_univ i, hij⟩
  have hcover : ∀ v, (∃ i, l i = v) ∨ ∃ j, r j = v := by
    intro v
    by_cases hv : v ∈ D
    · left
      obtain ⟨i, _, hi⟩ := Finset.mem_image.mp hv
      exact ⟨i, hi⟩
    · right
      obtain ⟨j, hj⟩ := hqbij.2 ⟨v, hv⟩
      exact ⟨j, congrArg Subtype.val hj⟩
  have hrmap : IsC4Map G r := ⟨hr, hq.2⟩
  obtain ⟨hr02, hr13⟩ := tight_subcubic_chordless G ht hmax r hrmap
  have hleft := cubic_chordless_adjacency_r1 G l hl hl02 hl13
  have hright := cubic_chordless_adjacency_r1 G r hrmap hr02 hr13
  have huniqL := cubic_square_unique_cross_r1 G l r hl.1 hr h3
    hdisj hcover hleft
  have huniqR := cubic_square_unique_cross_r1 G r l hr hl.1 h3
    (fun i j => (hdisj j i).symm) (fun v => (hcover v).symm) hright
  let m : Fin 4 → Fin 4 := fun i => Classical.choose (huniqL i).exists
  have hmAdj : ∀ i, G.Adj (l i) (r (m i)) :=
    fun i => Classical.choose_spec (huniqL i).exists
  have hminj : Function.Injective m := by
    intro i j hij
    apply (huniqR (m i)).unique
    · exact (hmAdj i).symm
    · rw [hij]
      exact (hmAdj j).symm
  let μ : Fin 4 ≃ Fin 4 := Equiv.ofBijective m
    ((Fintype.bijective_iff_injective_and_card m).mpr ⟨hminj, rfl⟩)
  have hcross : ∀ i j, G.Adj (l i) (r j) ↔ μ i = j := by
    intro i j
    constructor
    · intro hij
      exact (huniqL i).unique (hmAdj i) hij
    · intro hij
      subst j
      exact hmAdj i
  have htrans := two_squares_matching_transversal G l r μ hl.1 hr
    hdisj hcover hleft hright hcross
  have hbound := tau4_le_card htrans
  have hcardle : ({l 0, r (μ 2)} : Finset V).card ≤ 2 :=
    Finset.card_le_two
  omega
```

```note id=ramsey-B67-r1.1
Parent independently piped the entire modified Mixed.lean through lake env lean --stdin: exit 0; no declaration-uses-sorry warning.
Only lint: <stdin>:169:5: warning: Variable name `hm` is not explicitly referenced.
Axiom output: 'SizeRamsey.Plan.equality_mixed_degree_case' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
Residual non-isolation, connectedness, three degree-two attachments, opposite attachments, coverage, and adjacency equivalence are separately proved.
Route refinement: residual tightness follows directly by saturation of mixed_reduction and universal.
```

```note id=ramsey-B67-r1.2
Parent piped the entire modified Cubic.lean, with both targets completed, through lake env lean --stdin: exit 0; no declaration-uses-sorry warnings.
Only lint for this target: <stdin>:26:5: warning: Variable name `hdisj` is not explicitly referenced.
Axiom output: 'SizeRamsey.Plan.two_squares_matching_transversal' depends on axioms: [propext, Classical.choice, Quot.sound]
The proof splits the sixteen side-membership patterns of an arbitrary square. Kernel computations concern only the fixed four-cycle.
No admitted dependencies.
```

```note id=ramsey-B67-r1.3
Parent independently verified this proof together with the completed crossing lemma in the whole modified Cubic.lean.
Compiler exit 0; no declaration-uses-sorry warnings.
Remaining lint: <stdin>:180:5 unused hc; <stdin>:184:5 unused ih.
Axiom output: 'SizeRamsey.Plan.equality_cubic_impossible' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
Route refinement: positive residual tau supplies a square; injectivity and residual cardinal four establish coverage. Common chordlessness supplies induced adjacency without a separate edge-exhaustion argument.
```

```note id=general
1. Basic.lean and Deletion.lean also contain admissions in this snapshot; the proofs are conditional on the following named contracts.
Mixed direct admissions: SizeRamsey.Plan.equality_square_supported, SizeRamsey.Plan.equality_min_degree, SizeRamsey.Plan.mixed_reduction.
Mixed direct admissions continued: SizeRamsey.Plan.erase_degree, SizeRamsey.Plan.universal, SizeRamsey.Plan.erase_edgeCount.
Mixed direct admissions continued: SizeRamsey.Plan.component_attachment_card_ge_two, SizeRamsey.Plan.attachment_sum, SizeRamsey.Plan.classified_three_degree_two.
Cubic direct admissions: SizeRamsey.Plan.tau4_eq_zero_iff, SizeRamsey.Plan.cubic_chordless_reduction, SizeRamsey.Plan.erase_card, SizeRamsey.tau4_le_card.
Both classification proofs additionally use SizeRamsey.Plan.subcubic_chord_reduction and SizeRamsey.Plan.universal through the proved tight_subcubic_chordless.
2. No false relevant contract was found. No literature facts were imported.
3. No imports, signatures, definitions, or workspace files were changed.
4. Three subagents were used: mixed-case prover; cubic-contradiction prover; independent contract auditor who also proved the residual-square normalization helpers. Parent proved crossing and final relabeling and independently replayed both integrated files.
```

```proofloop-summary
{"brief":"ramsey-B67-r1","base":"d1c156b","results":[{"id":"ramsey-B67-r1.1","status":"PROVED","elaborated":true,"lean_output":"\nNote: This linter can be disabled with `set_option linter.unusedVariables false`\n'SizeRamsey.Plan.equality_mixed_degree_case' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"},{"id":"ramsey-B67-r1.2","status":"PROVED","elaborated":true,"lean_output":"Note: This linter can be disabled with `set_option linter.unusedVariables false`\n'SizeRamsey.Plan.two_squares_matching_transversal' depends on axioms: [propext, Classical.choice, Quot.sound]\n'SizeRamsey.Plan.equality_cubic_impossible' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"},{"id":"ramsey-B67-r1.3","status":"PROVED","elaborated":true,"lean_output":"Note: This linter can be disabled with `set_option linter.unusedVariables false`\n'SizeRamsey.Plan.two_squares_matching_transversal' depends on axioms: [propext, Classical.choice, Quot.sound]\n'SizeRamsey.Plan.equality_cubic_impossible' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]"}],"helpers":["b67_audit_cycle4_arrange","b67_audit_mixed_opposite","b67_audit_mixed_normalize","b67_mixed_final_labels","cubic_chordless_adjacency_r1","cubic_third_neighbor_r1","cubic_square_unique_cross_r1"],"imports":[],"subagents":3,"confidence":0.99}
```