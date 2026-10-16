/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/

module

public import SizeRamsey.SmallGraphs

/-! Theorem D: `K₃,₃ − e → (2K₂, C₄)` (a pairwise-intersecting edge family in a bipartite graph is a
star; deleting its centre leaves a square), and two copies joined by a bridge arrow `(4K₂, C₄)`. -/

@[expose] public section

namespace SizeRamsey

/-- `G` contains a matching of two edges. -/
def HasMatching2 {V : Type*} (G : SimpleGraph V) : Prop :=
  ∃ f : Fin 4 → V, Function.Injective f ∧ G.Adj (f 0) (f 1) ∧ G.Adj (f 2) (f 3)

theorem F17_connected : F17.Connected := by
  sorry

theorem k33MinusEdge_arrows_matching2_c4 :
    ∀ R : SimpleGraph (Fin 6), R ≤ k33MinusEdge → HasMatching2 R ∨ HasC4 (k33MinusEdge \ R) := by
  sorry

theorem F17_arrows_matching4_c4 : ArrowsMatching4C4 F17 := by
  sorry

namespace Proof

theorem F17_spec : F17.Connected ∧ edgeCount F17 = 17 ∧ ArrowsMatching4C4 F17 :=
  ⟨F17_connected, F17_edgeCount, F17_arrows_matching4_c4⟩

end Proof

end SizeRamsey
