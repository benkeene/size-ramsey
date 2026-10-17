/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

public import SizeRamsey.AInterface

/-! Theorem D (Stream B): `K₃,₃ − e → (2K₂, C₄)` (a triangle-free graph without a 2-matching is
empty or a star; deleting its centre leaves a square), and two copies joined by a bridge arrow
`(4K₂, C₄)`. Uses from Stream A only the elementary `K₃,₃ − e` certificates, never `tau4`. This
file has no classical instance override, so `decide` runs on the computable instances. -/

@[expose] public section

namespace SizeRamsey

/-- `G` contains a matching of two edges. -/
def HasMatching2 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 4 → V, Function.Injective f ∧ G.Adj (f 0) (f 1) ∧ G.Adj (f 2) (f 3)

end SizeRamsey

namespace SizeRamsey.Plan

private theorem edges_meet {V : Type*} {G : SimpleGraph V}
    (hmatch : ¬ HasMatching2 G) {a b c d : V}
    (hab : G.Adj a b) (hcd : G.Adj c d) :
    a = c ∨ a = d ∨ b = c ∨ b = d := by
  by_contra hne
  push Not at hne
  obtain ⟨h1, h2, h3, h4⟩ := hne
  apply hmatch
  refine ⟨![a, b, c, d], ?_, by simpa using hab, by simpa using hcd⟩
  have hab' := hab.ne
  have hcd' := hcd.ne
  intro i j h
  fin_cases i <;> fin_cases j <;> simp_all [eq_comm]

theorem star_or_empty {V : Type*} (G : SimpleGraph V)
    (htri : ∀ a b c,
      G.Adj a b → G.Adj b c → ¬ G.Adj c a)
    (hmatch : ¬ HasMatching2 G) :
    G = ⊥ ∨
      ∃ v, ∀ a b, G.Adj a b → a = v ∨ b = v := by
  by_cases hbot : G = ⊥
  · exact Or.inl hbot
  right
  obtain ⟨x, y, hxy⟩ := SimpleGraph.ne_bot_iff_exists_adj.1 hbot
  by_contra hno
  push Not at hno
  obtain ⟨a, b, hab, hax, hbx⟩ := hno x
  obtain ⟨c, d, hcd, hcy, hdy⟩ := hno y
  -- an edge `y z` with `z ≠ x`
  have hz : ∃ z, G.Adj y z ∧ z ≠ x := by
    rcases edges_meet hmatch hxy hab with h | h | h | h
    · exact absurd h.symm hax
    · exact absurd h.symm hbx
    · subst h; exact ⟨b, hab, hbx⟩
    · subst h; exact ⟨a, hab.symm, hax⟩
  have hw : ∃ w, G.Adj x w ∧ w ≠ y := by
    rcases edges_meet hmatch hxy hcd with h | h | h | h
    · subst h; exact ⟨d, hcd, hdy⟩
    · subst h; exact ⟨c, hcd.symm, hcy⟩
    · exact absurd h.symm hcy
    · exact absurd h.symm hdy
  obtain ⟨z, hyz, hzx⟩ := hz
  obtain ⟨w, hxw, hwy⟩ := hw
  rcases edges_meet hmatch hyz hxw with h | h | h | h
  · exact hxy.ne h.symm
  · exact hwy h.symm
  · exact hzx h
  · subst h; exact htri x y z hxy hyz hxw.symm

def leftCopy (i : Fin 6) : Fin 12 :=
  ⟨i.val, by omega⟩

def rightCopy (i : Fin 6) : Fin 12 :=
  ⟨i.val + 6, by omega⟩

theorem leftCopy_injective :
    Function.Injective leftCopy := by
  intro a b h
  apply Fin.ext
  exact congrArg (fun x : Fin 12 => x.val) h

theorem rightCopy_injective :
    Function.Injective rightCopy := by
  intro a b h
  apply Fin.ext
  have := congrArg Fin.val h
  dsimp [rightCopy] at this
  omega

theorem copies_disjoint (i j : Fin 6) :
    leftCopy i ≠ rightCopy j := by
  intro h
  have := congrArg Fin.val h
  dsimp [leftCopy, rightCopy] at this
  omega

theorem leftCopy_adj (i j : Fin 6) :
    F17.Adj (leftCopy i) (leftCopy j) ↔
      k33MinusEdge.Adj i j := by
  fin_cases i <;> fin_cases j <;> decide

theorem rightCopy_adj (i j : Fin 6) :
    F17.Adj (rightCopy i) (rightCopy j) ↔
      k33MinusEdge.Adj i j := by
  fin_cases i <;> fin_cases j <;> decide

theorem hasC4_map {V W : Type*}
    {G : SimpleGraph V} {H : SimpleGraph W}
    (f : V → W) (hf : Function.Injective f)
    (hadj : ∀ ⦃a b⦄,
      G.Adj a b → H.Adj (f a) (f b)) :
    HasC4 G → HasC4 H := by
  rintro ⟨g, hg, h01, h12, h23, h30⟩
  exact ⟨f ∘ g, hf.comp hg,
    hadj h01, hadj h12, hadj h23, hadj h30⟩

theorem matching2_union {V W : Type*}
    {G H : SimpleGraph V} {F : SimpleGraph W}
    (i j : V → W)
    (hi : Function.Injective i)
    (hj : Function.Injective j)
    (hdis : ∀ a b, i a ≠ j b)
    (hG : ∀ ⦃a b⦄,
      G.Adj a b → F.Adj (i a) (i b))
    (hH : ∀ ⦃a b⦄,
      H.Adj a b → F.Adj (j a) (j b)) :
    HasMatching2 G → HasMatching2 H → HasMatching4 F := by
  rintro ⟨f, hf, hf01, hf23⟩ ⟨g, hg, hg01, hg23⟩
  have hdis' : ∀ a b, j b ≠ i a := fun a b h => hdis a b h.symm
  refine ⟨![i (f 0), i (f 1), i (f 2), i (f 3), j (g 0), j (g 1), j (g 2), j (g 3)],
    ?_, by simpa using hG hf01, by simpa using hG hf23, by simpa using hH hg01,
    by simpa using hH hg23⟩
  intro a b h
  fin_cases a <;> fin_cases b <;>
    simp_all [hi.eq_iff, hj.eq_iff, hf.eq_iff, hg.eq_iff]

end SizeRamsey.Plan

namespace SizeRamsey

theorem F17_connected :
    F17.Connected := by
  rw [SimpleGraph.connected_iff_exists_forall_reachable]
  refine ⟨5, ?_⟩
  have e : ∀ a b : Fin 12, F17.Adj a b → F17.Reachable a b := fun _ _ h => h.reachable
  have r0 : F17.Reachable 5 0 := e _ _ (by decide)
  have r1 : F17.Reachable 5 1 := e _ _ (by decide)
  have r2 : F17.Reachable 5 2 := e _ _ (by decide)
  have r6 : F17.Reachable 5 6 := e _ _ (by decide)
  have r3 : F17.Reachable 5 3 := r1.trans (e _ _ (by decide))
  have r4 : F17.Reachable 5 4 := r0.trans (e _ _ (by decide))
  have r10 : F17.Reachable 5 10 := r6.trans (e _ _ (by decide))
  have r11 : F17.Reachable 5 11 := r6.trans (e _ _ (by decide))
  have r7 : F17.Reachable 5 7 := r10.trans (e _ _ (by decide))
  have r8 : F17.Reachable 5 8 := r10.trans (e _ _ (by decide))
  have r9 : F17.Reachable 5 9 := r7.trans (e _ _ (by decide))
  intro w
  fin_cases w
  exacts [r0, r1, r2, r3, r4, SimpleGraph.Reachable.refl _, r6, r7, r8, r9, r10, r11]

theorem k33MinusEdge_arrows_matching2_c4 :
    ∀ R : SimpleGraph (Fin 6), R ≤ k33MinusEdge →
      HasMatching2 R ∨ HasC4 (k33MinusEdge \ R) := by
  intro R hR
  by_cases hm : HasMatching2 R
  · exact Or.inl hm
  right
  have htri : ∀ a b c, R.Adj a b → R.Adj b c → ¬ R.Adj c a :=
    fun a b c hab hbc hca => Plan.k33_triangle_free a b c (hR hab) (hR hbc) (hR hca)
  rcases Plan.star_or_empty R htri hm with hbot | ⟨v, hv⟩
  · obtain ⟨f, ⟨hf, h01, h12, h23, h30⟩, -⟩ := Plan.k33_square_avoids_vertex 0
    subst hbot
    exact ⟨f, hf, by simpa using h01, by simpa using h12, by simpa using h23,
      by simpa using h30⟩
  · obtain ⟨f, ⟨hf, h01, h12, h23, h30⟩, hfv⟩ := Plan.k33_square_avoids_vertex v
    have blue : ∀ a b : Fin 4, k33MinusEdge.Adj (f a) (f b) →
        (k33MinusEdge \ R).Adj (f a) (f b) := fun a b h =>
      ⟨h, fun hr => (hv _ _ hr).elim (hfv a) (hfv b)⟩
    exact ⟨f, hf, blue _ _ h01, blue _ _ h12, blue _ _ h23, blue _ _ h30⟩

theorem F17_arrows_matching4_c4 :
    ArrowsMatching4C4 F17 := by
  intro R hR
  have hL : R.comap Plan.leftCopy ≤ k33MinusEdge := fun a b h =>
    (Plan.leftCopy_adj a b).1 (hR (SimpleGraph.comap_adj.1 h))
  have hRt : R.comap Plan.rightCopy ≤ k33MinusEdge := fun a b h =>
    (Plan.rightCopy_adj a b).1 (hR (SimpleGraph.comap_adj.1 h))
  have blueL : ∀ ⦃a b⦄, (k33MinusEdge \ R.comap Plan.leftCopy).Adj a b →
      (F17 \ R).Adj (Plan.leftCopy a) (Plan.leftCopy b) := fun a b h =>
    ⟨(Plan.leftCopy_adj a b).2 h.1, fun hr => h.2 (SimpleGraph.comap_adj.2 hr)⟩
  have blueR : ∀ ⦃a b⦄, (k33MinusEdge \ R.comap Plan.rightCopy).Adj a b →
      (F17 \ R).Adj (Plan.rightCopy a) (Plan.rightCopy b) := fun a b h =>
    ⟨(Plan.rightCopy_adj a b).2 h.1, fun hr => h.2 (SimpleGraph.comap_adj.2 hr)⟩
  rcases k33MinusEdge_arrows_matching2_c4 _ hL with hmL | hcL
  · rcases k33MinusEdge_arrows_matching2_c4 _ hRt with hmR | hcR
    · exact Or.inl (Plan.matching2_union Plan.leftCopy Plan.rightCopy
        Plan.leftCopy_injective Plan.rightCopy_injective Plan.copies_disjoint
        (fun _ _ h => SimpleGraph.comap_adj.1 h) (fun _ _ h => SimpleGraph.comap_adj.1 h)
        hmL hmR)
    · exact Or.inr (Plan.hasC4_map Plan.rightCopy Plan.rightCopy_injective blueR hcR)
  · exact Or.inr (Plan.hasC4_map Plan.leftCopy Plan.leftCopy_injective blueL hcL)

namespace Proof

theorem F17_spec :
    F17.Connected ∧ edgeCount F17 = 17 ∧
      ArrowsMatching4C4 F17 :=
  ⟨F17_connected, F17_edgeCount, F17_arrows_matching4_c4⟩

end Proof
end SizeRamsey
