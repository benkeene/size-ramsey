# Status check (incomplete, 2026-10-16)

> Historical literature audit (2026-10-16). The project has since proved the value 17 (Solution.lean; Palomar PALOMAR-2026-10-17-000012 v1); the statements below about an unknown value describe the literature search at that date. Novelty of B remains unestablished.

Verified: Wang–Song–Zhang–Zhang, EJGTA 13(1) (2025) 163–170, doi:10.5614/ejgta.2025.13.1.11,
Theorem 1.3 (upper bound ⌊(9n−1)/2⌋) and Conjecture 1 (equality); McKay's catalogue lists
8,037,472 connected graphs with 16 edges.

Outstanding before any novelty claim:
- [ ] Text of the 2018 correction to Rahadjeng–Baskoro–Assiyatun (doi:10.1007/s12044-018-0375-6).
- [ ] Dzido, Procedia CS 270 (2025) 881–890 and 2799–2807 (only abstracts seen).
- [ ] Literature on "quadrilateral transversal", "C4 vertex deletion" bounds for Theorems A/B.

What appears to remain unknown is exactly whether every connected finite simple graph with at
most 16 edges admits an edge colouring with neither a red four-edge matching nor a blue 4-cycle.
Classification: UNKNOWN FINITE VALUE (provisional, confidence 0.80).

## Update 2026-10-16 (novelty thread, transcript 20261016T191015_novelty_checker_claim_0004)
- [x] 2018 correction retrieved: it restricts r̂_c(nK₂, K₁,₃) = 4n − 1 to n ≥ 4; r̂_c(3K₂, C₄) = 13
      (2017, Lemma 2.4) stands.
- [x] Dzido 2025 (Procedia CS 270): abstracts announce 3K₂ and 2K₂ versus cycles only; full texts
      not retrieved. Dzido AJC 95 (2026): restricted parameter, not connected.
- [x] Theorem A is a corollary of Alon–Mubayi–Thomas, JGT 38 (2001) 113–123, Theorem 1.5 (fvs of
      subcubic graphs ≤ (m + c)/4) with the degree-≥4 deletion step. Not new.
- [x] K₃,₃ − e → (2K₂, C₄): Wijaya–Yulianti–Baskoro–Assiyatun–Suprijanto, J. Algorithms Comput. 46
      (2015) 9–25, Theorem 2.6. Not new. D is the n = 4 case of WSZZ's construction. Not new.
- [x] Lower bound 16: Erdős–Faudree 1984 (r̂(nK₂, C₄) = 4n). Known.
- [ ] Novelty of B (and of "no connected 16-edge graph has τ₄ = 4") still unestablished (0.75).

What appears to remain unknown is exactly whether r̂_c(4K₂, C₄) is 16 or 17, i.e. whether some
connected 16-edge graph arrows (4K₂, C₄); the literature gives 16 ≤ r̂_c ≤ 17.
