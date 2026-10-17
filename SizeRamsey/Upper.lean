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
  sorry

end SizeRamsey.Plan

namespace SizeRamsey

theorem F17_connected :
    F17.Connected := by
  sorry

theorem k33MinusEdge_arrows_matching2_c4 :
    ∀ R : SimpleGraph (Fin 6), R ≤ k33MinusEdge →
      HasMatching2 R ∨ HasC4 (k33MinusEdge \ R) := by
  sorry

theorem F17_arrows_matching4_c4 :
    ArrowsMatching4C4 F17 := by
  sorry

namespace Proof

theorem F17_spec :
    F17.Connected ∧ edgeCount F17 = 17 ∧
      ArrowsMatching4C4 F17 :=
  ⟨F17_connected, F17_edgeCount, F17_arrows_matching4_c4⟩

end Proof
end SizeRamsey
