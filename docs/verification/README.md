# Verification record for claim_0004 (r̂_c(4K₂, C₄) = 17)

Copies of the GPT-6 Astra transcripts, briefs and replies that the commit messages, `CORRESPONDENCE.md`
and `formalization.yaml` cite by their aiseminar paths (`agents/astra/transcripts/…`,
`agents/runs/2026-10-16_ramsey-astra/…`). Copied verbatim on 2026-10-17; the aiseminar laboratory
repository (private) remains the original. Every Astra file begins with a comment line
`<!-- astra: model=gpt-6-astra effort=… thread=… job=… -->` giving the Codex thread and job id.
Local absolute paths inside the transcripts (`/Users/ben/size-ramsey/...`) are the reviewer's
clickable links into this repository at the commit named in the transcript.

Astra's verdicts are inputs to the lab protocol, not its conclusions: the epistemic judgments were
made by Claude Code (orchestrator) and recorded in `CORRESPONDENCE.md` and `formalization.yaml`;
the guarantee for the theorem is the Lean kernel and the CI comparator, not any review.

## transcripts/ — reviews of the informal proof (2026-10-16) and of the formal development (2026-10-17)

| file | role | verdict | acted on in |
|---|---|---|---|
| `20261016T191015_adversary_claim_0004.md` | adversary, informal proof | ACCEPT_WITH_FIXES 0.96 | `5124945` |
| `20261016T191015_independent_prover_claim_0004.md` | independent reconstruction from the statement | agrees, 0.99 | `docs/PROOF.md` |
| `20261016T191015_novelty_checker_claim_0004.md` | literature and novelty audit | novelty of B unestablished (0.75) | `916031d`, `docs/STATUS_CHECK.md` |
| `20261016T191635_reviewer_claim_0004.md` | reviewer, informal proof | ACCEPT_WITH_FIXES 0.96 | `f786091` |
| `20261016T192131_reviewer2_claim_0004.md` | confirming reviewer after fixes | ACCEPT_WITH_FIXES 0.97 | `40928d4` |
| `20261016T192456_reviewer3_claim_0004.md` | final confirming reviewer | ACCEPT 0.98 | `39afd8f` (lab status VERIFIED) |
| `20261017T001309_adversary-meaning_claim_0004.md` | formal adversary, meaning (do the Lean statements say what is claimed) | ACCEPT_WITH_FIXES 0.97 | `c7901d4` |
| `20261017T001309_adversary-trust_claim_0004.md` | formal adversary, trust (can the verification chain be escaped) | ACCEPT_WITH_FIXES 0.98 | `c7901d4` |
| `20261017T002007_statement-recon_claim_0004.md` | independent Lean statement reconstruction from the informal claim alone | 0.97 | `CORRESPONDENCE.md` §13 |
| `20261017T002905_reviewer-formal_claim_0004.md` | formal reviewer | ACCEPT_WITH_FIXES 0.98; recommends FORMALLY_VERIFIED | `713de5e`, `38bd345` |

`review-briefs/` holds the briefs that produced the 2026-10-17 transcripts and the role prompts
(`_system_*.md`) under which Astra was run. Astra was never told that an argument was probably right.

## lean-jobs/ — the Lean proofs written by Astra (commit `c8d54e2`)

Three concurrent Codex jobs from repository snapshots `077b90f` (stream A) and `1e04b3e`
(stream B); `run.json` is the job record, `briefs/` what Astra was given, `replies/` what it
returned. The replies' `lean patch` blocks were applied mechanically onto `832bb41` and judged
(build, forbidden-construct scan, axiom audit, per-module leanchecker, signature and frozen-file
checks) by the orchestrator; the commit message of `c8d54e2` records the one refused target.

| job | targets | reply |
|---|---|---|
| `ramsey-A7-r1` | `SizeRamsey/Tightness.lean` (4 declarations) | `replies/reply_ramsey-A7-r1.md` |
| `ramsey-B67-r1` | `SizeRamsey/Equality/Mixed.lean`, `Equality/Cubic.lean` | `replies/reply_ramsey-B67-r1.md` |
| `ramsey-B89-r1` | `Equality/TwoRegular.lean`, body of `equality_classification`, `connected_transversal_le_three` | `replies/reply_ramsey-B89-r1.md` |

## paper-reviews/ — the two Astra reviews applied to `paper/main.tex` (commit `d1fe5ba`)

`ledger.md` (statement-by-statement ledger kept while writing), `review_ramsey_contract.md`
(statement fidelity against the Lean records and `docs/PROOF.md`), `review_ramsey_exposition.md`.
