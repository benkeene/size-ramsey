/-
Copyright (c) 2026 Ben Keene. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ben Keene
-/
module

import Solution

/-! Axiom audit of the statements of record, from `Solution` (never `Challenge`).
Run `lake env lean SizeRamsey/AxiomAudit.lean`; the completed project shows only
`propext`, `Classical.choice`, `Quot.sound`. -/

#print axioms SizeRamsey.four_mul_tau4_le_edgeCount
#print axioms SizeRamsey.equality_classification
#print axioms SizeRamsey.connected_transversal_le_three
#print axioms SizeRamsey.avoiding_coloring_le_sixteen
#print axioms SizeRamsey.F17_spec
#print axioms SizeRamsey.connectedSizeRamsey_eq_seventeen
