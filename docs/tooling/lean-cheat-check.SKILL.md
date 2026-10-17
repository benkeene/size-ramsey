---
name: lean-cheat-check
description: Audit a Lean 4 / Mathlib repository, or a patch to one, for "Lean cheats" — constructs that make `lake build` and `#print axioms` look clean while bypassing or weakening the kernel's guarantee (sorry/axiom smuggling, native_decide, `debug.skipKernelTC` plus meta `addDecl`, `implemented_by`/`@[extern]`, `#exit`, statement drift between Challenge and Solution, shadowed or homoglyph names, option/lakefile/manifest tampering, committed .olean files). Use before trusting any claim that a Lean result is proved, when reviewing model- or agent-written Lean, before promoting a claim to FORMALLY_VERIFIED, and before a Palomar submission. Runs a four-layer ladder: static scan → axiom sweep → per-module kernel replay (`leanchecker`) → statement fidelity. The kernel replay is the guarantee; everything else is a cheap filter.
argument-hint: <repo-root> [--diff <git-ref>] [--modules M1 M2 ...]
---

# lean-cheat-check — does this Lean proof actually prove what it says?

## 0. Install

This file is self-contained. To make it a skill:

```bash
mkdir -p ~/.claude/skills/lean-cheat-check/scripts && cp lean-cheat-check.SKILL.md ~/.claude/skills/lean-cheat-check/SKILL.md
```

On first use, materialise the two embedded programs (§6 and §7) into
`~/.claude/skills/lean-cheat-check/scripts/lean_cheat_scan.py` and
`~/.claude/skills/lean-cheat-check/scripts/AxiomSweep.lean.tmpl`, exactly as printed. Nothing
in this skill ever writes into the audited repository; all generated files live in the skill
directory or in a scratch clone.

## 1. The trust model in one minute

A Lean 4 proof is believed because the **kernel** re-checks the final term of every declaration
against its stated type, using only the inference rules plus three standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). Everything else — the elaborator, tactics,
`simp`, `decide`, macros, the compiler, Lake, the `.olean` cache — is untrusted machinery
whose only job is to produce a term the kernel accepts. `lake build` succeeding means the
elaborator accepted the file; `#print axioms T` lists the axioms reachable from `T`'s term.
Neither statement is the same as "the kernel checked `T`", and there are exactly four ways a
clean-looking repository can still prove nothing:

| # | Escape | Mechanism | What still looks clean |
|---|---|---|---|
| E1 | **Extra axioms** | `sorry` (→ `sorryAx`), `axiom foo : False`, `native_decide` (→ `Lean.ofReduceBool`, `Lean.trustCompiler`) | `lake build` is green (warnings only). `#print axioms` catches it — *if someone reads the output and knows the allowlist*. |
| E2 | **Kernel bypass** | `set_option debug.skipKernelTC true` (Lean core: *"may compromise soundness because your proofs will not be checked by the Lean kernel"*), `Lean.addDecl`/`addDeclWithoutChecking`/`addAndCompile` from `run_cmd`/`elab`/`#eval`, `Environment.addDeclCore` | **`lake build` green, `#print axioms` clean** (the bogus term mentions no axiom). Only a kernel *replay* (`leanchecker`) fails. Demonstrated on this toolchain (v4.35.0-rc3): `cheat : False := True.intro` installed this way; `#print axioms` of a theorem using `cheat.elim` printed `[propext, Classical.choice, Quot.sound]`. |
| E3 | **Wrong statement** | the formal statement differs from the intended one: Challenge/Solution drift, `autoImplicit` turning a typo into a free variable, `variable (h : False)` or `omit`/`include` changing hypotheses, redefined `notation`/`macro`/`instance` changing what symbols mean, shadowing (`def Nat.Prime`, a project namespace's own `propext`), Cyrillic/fullwidth homoglyphs in identifiers, vacuous hypotheses | Build, axioms *and* kernel replay are all clean. The theorem is true — it's just not the theorem. Only a statement-fidelity check (comparator, type hashes, human reading) catches it. |
| E4 | **Tampered environment** | lakefile `leanOptions`/`moreLeanArgs` setting `debug.*` or `-D` flags; `lake-manifest.json` pointing Mathlib at a fork; a custom `lean-toolchain`/elan override with a patched kernel; committed `.olean`/`.ilean` files (imported without re-checking); `initialize` blocks; CI env vars | Everything local is clean because the tools themselves are compromised. Only configuration audit plus a `--fresh` replay or an independent kernel (nanoda) catches it. |

This is also how the Palomar registry defends itself: its documentation never bans
`skipKernelTC`, `addDecl`, `unsafe` or `implemented_by`; the comparator's final step replays
the whole Solution environment through the kernel, and the registry adds independent NanoDa and
con-ron replays ("Independent kernel replay is a registry invariant, not a submitter option").
A 2026-10-16 scan of all 200 registered entries (86,071 `.lean` files) found zero
`set_option debug.*` in any registered proof, and Palomar's own `core_notation_audit.lean`
uses `addDecl` under `skipKernelTC` deliberately, outside any Solution, to insert type proxies.
Public write-ups of the attack class: CircuitEq PR #1 (`skipKernelTC` + `decide +kernel` proves
2 + 2 = 5, passes build and `#print axioms`, caught by leanchecker); leibniz-daemon PR #414
(`unsafe def evil : False := evil`, option name assembled from string fragments inside
`run_cmd` so no grep sees it, notation redefinition).

Design rule that follows: **a scanner is a filter, never a verdict.** The verdict comes from
`lake env leanchecker <every touched module>` plus a statement-fidelity check, both run by you
(the auditor), never by the party that produced the proof, and never inferred from the
producer's own description of what it did.

## 2. When this skill triggers

- Any claim, by a person, a model, or a subagent, that a Lean declaration "is proved", "builds
  sorry-free", "has clean axioms", or that a milestone like FORMALLY_VERIFIED is reached.
- A patch to a Lean repo written by a model (Astra, Opus, anyone). Run in `--diff` mode.
- Before `git merge` of a proof branch, before updating `formalization.yaml`'s `sorry_count`,
  before a Palomar submission, before writing a CORRESPONDENCE.md build-record row.
- Periodically on `main` of any Lean repo you rely on (the base can already contain a cheat).

## 3. Inputs

| Input | How to get it |
|---|---|
| `ROOT` | repo root; must contain `lakefile.toml` or `lakefile.lean` and `lean-toolchain` |
| `BASE` (optional) | a git ref; with `--diff BASE` the scan only reports lines added since `BASE`, but layers 2–4 still run on whole modules |
| modules | the Lean modules to replay: by default every `.lean` under the repo's `lean_lib` roots (excluding `.lake`); in patch mode at least every touched module **plus** the top-level statement module (`Solution`) |
| allowlist | `comparator.json` → `permitted_axioms` if present, else `["propext","Classical.choice","Quot.sound"]` |
| statements of record | `comparator.json` → `theorem_names`, or `formalization.yaml` → `status.main_results`, or ask |

## 4. Procedure (the ladder)

Run the layers in order; stop and report `CHEAT_FOUND` as soon as a layer fails with a
CRITICAL finding; otherwise run all four and report what each one covered. Never skip layer 3
because layers 1–2 were clean — that is exactly the gap E2 exploits.

### Layer 0 — preconditions (seconds)

```bash
cd "$ROOT" && git status --short            # audit a clean tree or a named ref, not a dirty one
cat lean-toolchain                          # must be `leanprover/lean4:vX.Y.Z[-rcN]`, not a path
elan show | head -5                         # no local override pointing at a custom toolchain
git ls-files | grep -E '\.(olean|ilean|trace|hash)$' | head   # must be empty
grep -n '^\.lake' .gitignore                # .lake must be ignored
```

If the tree is dirty, either audit `HEAD` in a fresh `git worktree add` or state in the report
that uncommitted changes were included.

### Layer 1 — static scan (under a second)

```bash
python3 -I ~/.claude/skills/lean-cheat-check/scripts/lean_cheat_scan.py "$ROOT" [--diff BASE] --json > scan.json
python3 -I ~/.claude/skills/lean-cheat-check/scripts/lean_cheat_scan.py "$ROOT" [--diff BASE]
```

The scanner (§6) strips comments and string literals, then reports every occurrence of the
constructs in §5 with file:line, severity and the stripped snippet, plus the configuration
checks (lakefile options, manifest URLs/revs, toolchain format, tracked build artifacts,
homoglyphs). Exit code 2 = CRITICAL findings, 1 = HIGH/MEDIUM only, 0 = nothing.

Reading the result: `sorry` in `Challenge.lean` of a Palomar-shaped repo is expected (statements
of record are deliberately admitted there); the scanner marks it `expected` when the file is
named in `comparator.json`'s `challenge_module`. Everything else CRITICAL is a finding. HIGH
findings (`run_cmd`, `elab`, `macro`, `notation`, `instance` of a core class, `open Lean`…)
are legitimate in some developments; they are flagged because each is a place where a cheat
could be hidden, so **read every one** and say in the report why it is benign.

### Layer 2 — axiom sweep (5–30 s)

Do not rely on the repo's own `AxiomAudit.lean`: it lists only what its author chose to list.
Generate a sweep over **every** constant in the project's modules from the template in §7:

```bash
SK=~/.claude/skills/lean-cheat-check/scripts
sed -e "s|@ROOTS@|$ROOT_MODULES|" -e "s|@PREFIXES@|$PREFIXES|" -e "s|@ALLOWED@|$ALLOWED|" \
    $SK/AxiomSweep.lean.tmpl > /tmp/lcc/AxiomSweep.lean      # outside the repo
cd "$ROOT" && lake build && lake env lean /tmp/lcc/AxiomSweep.lean
```

where `ROOT_MODULES` is e.g. `Solution Targets.FiniteWidth` (what to import so the whole
project is in the environment), `PREFIXES` the module-name prefixes that count as "project"
(e.g. `FiveGenBetti Challenge Solution Targets`), and `ALLOWED` the allowlist. The sweep prints
one line per project constant whose axioms are not a subset of the allowlist, one line per
`axiom` declared in a project module, and a final `SWEEP n constants checked`. Require
`n > 0` and roughly equal to the number of declarations you expect; a sweep that checks zero
constants is a broken sweep, not a clean repo.

This layer catches E1 completely and E2 **not at all** (the demonstration above passes it).

### Layer 3 — kernel replay (4–20 s per module; the guarantee)

```bash
cd "$ROOT" && lake env leanchecker <Module.A> <Module.B> ... Solution ; echo "rc=$?"
```

`leanchecker` ships with the toolchain (`~/.elan/toolchains/<tc>/bin/leanchecker`). Given module
names, it re-runs the kernel on every declaration **of those modules** (not their imports). Facts
measured on v4.35.0-rc3 with a Mathlib-sized project:

- `leanchecker Solution` alone **passes** with the E2 cheat present in a library module, because
  `Solution` merely references the cheating theorem. You must name the module that *contains*
  each touched declaration. In patch mode: every touched module + `Solution`. On `main`: every
  project module (a 24-module project took about 12 minutes; most of it in the library root).
- With the cheat present, `leanchecker FiveGenBetti.Family.Minimality` exits 1 with
  `(kernel) declaration type mismatch, 'FiveGenBetti.Family.cheat' has type True but it is expected to have type False`.
- Running it with no module argument tries the package name and fails with
  `Could not find any oleans for: <Pkg>`; that is a usage error, not a result.
- Milestone-only (hours): `lake env leanchecker --fresh Solution` replays the entire import
  closure including Mathlib from scratch, which is the only local answer to E4 (compromised
  `.olean` cache); `lake env leanexport Solution > Solution.export` plus the independent Rust
  kernel `nanoda` removes trust in the Lean kernel binary itself.

Record the exact command, exit code and the first error line in the report.

### Layer 4 — statement fidelity (minutes of reading, plus one script)

The replay proves the kernel accepts each term for its stated type. Now check the stated types
are the intended ones (E3):

1. **Challenge vs Solution.** The Palomar comparator (`scripts/verify-comparator.sh`, Linux +
   bubblewrap, runs in CI) checks that each `theorem_names` entry has an identical type in both
   modules and permitted axioms in Solution. Locally, approximate it: run the §7 sweep twice,
   once importing `Challenge` and once `Solution`, with `set_option pp.all true`, and diff the
   printed types of the record theorems. Any difference is a finding; whitespace-only is not.
2. **Frozen definitions.** If the repo declares frozen definitions (NOTES.md, a plan, a
   `frozen.lock`), confirm they are byte-identical to the frozen text; for signatures, compare
   the `pp.all` types from the sweep with a baseline taken at the bootstrap commit. Text
   diffing is advisory; the elaborated type is what counts, because `variable`, `omit`,
   `local notation` and `attribute [local instance]` placed *above* a declaration change its
   type without touching its line.
3. **Vacuity.** For each statement of record, name the hypotheses and show they are
   satisfiable by an intended instance (e.g. the explicit 17-edge host for an arrowing
   statement; a concrete semigroup for a spanRank statement). A statement with `[Fintype V]`
   that is only ever instantiated at `Fin 0`, or with hypotheses `3 ≤ k` and `k ≤ 2`, is
   vacuous; the kernel will not tell you.
4. **Meaning of symbols.** For every HIGH finding of kind `notation`/`macro`/`syntax`/
   `instance`/`open … renaming`/`attribute [local instance]`, state what it redefines and
   confirm it is not used in a statement of record. Check `lakefile` has
   `autoImplicit = false` (and no file sets it true): with autoImplicit, a misspelled
   identifier in a statement becomes a universally quantified variable.
5. **Names.** Project declarations whose *last* component collides with a core/Mathlib name
   used in statements (`propext`, `Nat.Prime`, `SimpleGraph.Connected`…) are flagged by the
   scanner as `shadow`; confirm `#print axioms` output refers to the fully qualified standard
   names (`propext`, not `MyLib.propext`). Homoglyph findings (Cyrillic, fullwidth, zero-width,
   or mathematical-alphanumeric Latin lookalikes) are CRITICAL until explained.

## 5. Cheat catalogue (what the scanner looks for)

Severity: **C** = critical (bypass or axiom smuggling), **H** = high (meta-level power that can
hide a cheat; read every hit), **M** = medium (changes meaning or hygiene; confirm intent).

| Construct (regex family) | Sev | Escape | Caught by |
|---|---|---|---|
| `sorry`, `admit` (outside the declared Challenge module) | C | E1 | scan, sweep (`sorryAx`) |
| `axiom` | C | E1 | scan, sweep |
| `native_decide`, `decide +native`, `Lean.ofReduceBool`, `Lean.trustCompiler` | C | E1 | scan, sweep |
| `debug.skipKernelTC` anywhere (source, lakefile, CI, env) | C | E2 | scan; **replay** |
| `addDecl`, `addDeclWithoutChecking`, `addAndCompile`, `addDeclCore`, `Environment.add`, `modifyEnv`, `setEnv` | C | E2 | scan; **replay** |
| `#exit` (nothing after it is elaborated) | C | E2/E3 | scan |
| `implemented_by`, `@[extern`, `@[csimp]`, `unsafe` | C | E1 (with native_decide) | scan, sweep |
| `run_cmd`, `run_tac`, `run_elab`, `#eval`, `elab`, `elab_rules`, `macro`, `macro_rules`, `syntax`, `declare_syntax_cat` | H | E2/E3 | scan |
| `notation`, `infix*`, `prefix`, `postfix`, `local notation` | H | E3 | scan |
| `instance` of a core class (`LE`, `LT`, `Add`, `Mul`, `Decidable*`, `Fintype`, `Membership`…) on a core type; `@[default_instance]`; `attribute [local instance]`/`[instance]` not `Classical.propDecidable`/`Classical.dec*` | H | E3 | scan |
| `open Lean`, `open … renaming`, `export` | H | E2/E3 | scan |
| `initialize`, `builtin_initialize` | H | E4 | scan |
| `set_option autoImplicit true`, lakefile `autoImplicit = true`/missing `false` | H | E3 | scan |
| `opaque`, `partial def`, `set_option maxHeartbeats 0`, `omit`, `include` | M | E3/hygiene | scan |
| lakefile `[leanOptions]` with `debug.*` or `weak.debug.*`; `moreLeanArgs`/`moreServerArgs` with `-D`; `lakefile.lean` scripts/`extraDepTargets` | C | E4 | scan (config) |
| `lake-manifest.json`: a `mathlib` entry whose `url` is not `https://github.com/leanprover-community/mathlib4` or whose `rev` differs from the documented SHA | C | E4 | scan (config) + `git -C .lake/packages/mathlib rev-parse HEAD` |
| `lean-toolchain` not of the form `leanprover/lean4:v…`; `elan override` present | C | E4 | layer 0 |
| tracked `.olean`/`.ilean`/`.trace`/`.hash`; `.lake` not gitignored | C | E4 | layer 0 / scan (config) |
| identifier with Cyrillic, fullwidth, zero-width, or mathematical-alphanumeric Latin lookalike characters (`ℕ`, Greek letters, subscripts are legitimate and not flagged) | C | E3 | scan (homoglyph) |
| project declaration shadowing a core/Mathlib name's last component | M | E3 | scan (shadow, heuristic) |

Honest metaprogramming patterns seen in registered Palomar repos, which the scanner will flag
HIGH and you should sign off on: `run_cmd` axiom-audit files; a no-op tag attribute registered
via `initialize`; `Kernel.Environment.addDecl` (kernel-checked) called *before* `addDecl`, which
is the correct order for programmatic declarations.

Not cheats (do not flag): `Classical.choice`/`propext`/`Quot.sound`; `decide`, `decide +kernel`,
`rfl`, `omega`, `simp`, `norm_num`, `aesop`; `noncomputable`; `set_option maxHeartbeats N` with
N > 0; `@[simp]`/`@[reducible]`; `private`; linter options; `attribute [local instance] Classical.propDecidable`.

## 6. Embedded program: `lean_cheat_scan.py`

Stdlib only. Save verbatim to `~/.claude/skills/lean-cheat-check/scripts/lean_cheat_scan.py`.

```python
#!/usr/bin/env python3
"""lean_cheat_scan.py — static filter for Lean 4 proof cheats. A FILTER, NOT A VERDICT.

usage: lean_cheat_scan.py ROOT [--diff GITREF] [--json] [--challenge MODULE]
exit: 0 nothing found, 1 HIGH/MEDIUM only, 2 CRITICAL present (or config failure)
"""
from __future__ import annotations
import argparse, json, pathlib, re, subprocess, sys

CORE_CLASSES = r"(LE|LT|Add|Mul|Sub|Neg|Div|Mod|Pow|HAdd|HMul|Zero|One|Dvd|Membership|Decidable|DecidableEq|DecidableRel|DecidablePred|Fintype|Finite|Inhabited|Nonempty|Setoid|Preorder|PartialOrder|LinearOrder|Field|Ring|CommRing|Group|Monoid|Lattice|TopologicalSpace|MeasurableSpace)"
CORE_TYPES = r"(ℕ|ℤ|ℚ|ℝ|ℂ|Nat|Int|Rat|Real|Bool|Prop|Fin\b|Finset|Set|List|Multiset|SimpleGraph|MvPolynomial|Polynomial|Ideal|Submodule)"

RULES = [  # (name, severity, regex)
    ("sorry",            "C", r"\bsorry\b"),
    ("admit",            "C", r"\badmit\b"),
    ("axiom",            "C", r"^\s*(@\[[^\]]*\]\s*)?(private\s+|protected\s+|public\s+)?axiom\b"),
    ("native_decide",    "C", r"\bnative_decide\b|\bdecide\s*\+\s*native\b"),
    ("ofReduceBool",     "C", r"\b(Lean\.)?ofReduceBool\b|\b(Lean\.)?trustCompiler\b"),
    ("skipKernelTC",     "C", r"skipKernelTC"),
    ("addDecl",          "C", r"\baddDecl(WithoutChecking|Core)?\b|\baddAndCompile\b|\bEnvironment\.add\w*|\bmodifyEnv\b|\bsetEnv\b"),
    ("hash_exit",        "C", r"^\s*#exit\b"),
    ("implemented_by",   "C", r"implemented_by|@\[\s*extern\b|@\[\s*csimp\s*\]"),
    ("unsafe",           "C", r"\bunsafe\b"),
    ("set_option_debug", "C", r"set_option\s+(weak\.)?debug\."),
    ("meta_cmd",         "H", r"^\s*(run_cmd|run_tac|run_elab|#eval)\b"),
    ("elab_macro",       "H", r"^\s*(@\[[^\]]*\]\s*)?(scoped\s+|local\s+)?(elab|elab_rules|macro|macro_rules|syntax|declare_syntax_cat)\b"),
    ("notation",         "H", r"^\s*(@\[[^\]]*\]\s*)?(scoped\s+|local\s+)?(notation|infix|infixl|infixr|prefix|postfix|binder_predicate)\b"),
    ("core_instance",    "H", r"^\s*(@\[[^\]]*\]\s*)?(scoped\s+|local\s+)?(noncomputable\s+)?instance\b[^:]*:\s*" + CORE_CLASSES + r"\s*\(?\s*" + CORE_TYPES),
    ("default_instance", "H", r"@\[\s*default_instance"),
    ("local_instance",   "H", r"attribute\s*\[\s*(local\s+|scoped\s+)?instance[^\]]*\](?![^\n]*Classical\.(propDecidable|dec\w*))"),
    ("open_lean",        "H", r"^\s*open\s+(Lean\b|.*\brenaming\b)|^\s*export\b"),
    ("initialize",       "H", r"^\s*(builtin_)?initialize\b"),
    ("autoImplicit",     "H", r"set_option\s+(relaxed)?autoImplicit\s+true"),
    ("opaque",           "M", r"^\s*(@\[[^\]]*\]\s*)?(private\s+|protected\s+|public\s+)?opaque\b"),
    ("partial",          "M", r"^\s*(private\s+|protected\s+|public\s+)?partial\s+def\b"),
    ("heartbeats0",      "M", r"set_option\s+maxHeartbeats\s+0\b"),
    ("omit_include",     "M", r"^\s*(omit|include)\b"),
]
SEV_RANK = {"C": 2, "H": 1, "M": 0}
HOMOGLYPH = re.compile(r"[Ѐ-ӿ＀-￯​-‏ - \U0001D400-\U0001D7FF]")  # Cyrillic, fullwidth, zero-width/format, math-alphanumeric Latin lookalikes. ℕ, Greek, subscripts, ×ˢ are legitimate Lean and NOT flagged.
DECL = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+|public\s+|noncomputable\s+)*(theorem|lemma|def|abbrev|instance|structure|class|inductive|axiom|opaque)\s+([^\s:({\[]+)")
SHADOW_LAST = {"propext", "choice", "sound", "Prime", "Connected", "Adj", "card", "degree", "Nat", "Int", "Finset", "Set", "sorryAx", "ofReduceBool"}

def strip(text: str) -> list[str]:
    """Return lines with comments and string literals blanked (same line count)."""
    out, i, n, depth, in_str = [], 0, len(text), 0, False
    cur = []
    while i < n:
        c = text[i]
        if depth:
            if text.startswith("/-", i): depth += 1; i += 2; continue
            if text.startswith("-/", i): depth -= 1; i += 2; continue
            if c == "\n": out.append("".join(cur)); cur = []
            i += 1; continue
        if in_str:
            if c == "\\": i += 2; continue
            if c == '"': in_str = False
            if c == "\n": out.append("".join(cur)); cur = []
            i += 1; continue
        if text.startswith("/-", i): depth = 1; i += 2; continue
        if text.startswith("--", i):
            j = text.find("\n", i); i = n if j < 0 else j; continue
        if c == '"': in_str = True; i += 1; continue
        if c == "\n": out.append("".join(cur)); cur = []
        else: cur.append(c)
        i += 1
    out.append("".join(cur))
    return out

def added_lines(root: pathlib.Path, ref: str) -> dict[str, set[int]]:
    diff = subprocess.run(["git", "-C", str(root), "diff", "-U0", ref, "--", "*.lean", "lakefile.toml", "lakefile.lean", "lake-manifest.json", "lean-toolchain"],
                          capture_output=True, text=True, check=True).stdout
    res, cur = {}, None
    for ln in diff.splitlines():
        if ln.startswith("+++ "): cur = ln[6:] if ln.startswith("+++ b/") else None
        elif ln.startswith("@@") and cur:
            m = re.search(r"\+(\d+)(?:,(\d+))?", ln); s = int(m.group(1)); k = int(m.group(2) or 1)
            res.setdefault(cur, set()).update(range(s, s + k))
    return res

def scan(root: pathlib.Path, diff: str | None, challenge: str | None):
    findings, mask = [], added_lines(root, diff) if diff else None
    files = [p for p in root.rglob("*.lean") if ".lake" not in p.parts and ".git" not in p.parts]
    for p in sorted(files):
        rel = p.relative_to(root).as_posix()
        try: raw = p.read_text(encoding="utf-8")
        except UnicodeDecodeError: findings.append(dict(file=rel, line=0, sev="C", rule="non_utf8", text="")); continue
        if p.is_symlink(): findings.append(dict(file=rel, line=0, sev="C", rule="symlink", text=""))
        lines, rawlines = strip(raw), raw.splitlines()
        is_challenge = (rel == f"{(challenge or 'Challenge').replace('.', '/')}.lean")
        for idx, (ln, rl) in enumerate(zip(lines, rawlines), start=1):
            if mask is not None and idx not in mask.get(rel, set()): continue
            for name, sev, rx in RULES:
                if re.search(rx, ln):
                    f = dict(file=rel, line=idx, sev=sev, rule=name, text=ln.strip()[:160])
                    if name == "sorry" and is_challenge: f["sev"] = "M"; f["note"] = "expected: statement of record in Challenge module"
                    findings.append(f)
            if HOMOGLYPH.search(ln):
                findings.append(dict(file=rel, line=idx, sev="C", rule="homoglyph", text=rl.strip()[:160]))
            m = DECL.match(ln)
            if m and m.group(2).split(".")[-1] in SHADOW_LAST:
                findings.append(dict(file=rel, line=idx, sev="M", rule="shadow", text=ln.strip()[:160]))
    # configuration
    def cfg(rule, sev, text): findings.append(dict(file="<config>", line=0, sev=sev, rule=rule, text=text))
    tc = (root / "lean-toolchain").read_text().strip() if (root / "lean-toolchain").exists() else ""
    if not re.fullmatch(r"leanprover/lean4:v\d+\.\d+\.\d+(-rc\d+)?", tc): cfg("toolchain", "C", f"lean-toolchain = {tc!r}")
    for lf in ("lakefile.toml", "lakefile.lean"):
        q = root / lf
        if q.exists():
            t = q.read_text()
            if re.search(r"debug\.|-D\s*\w|moreLeanArgs|moreServerArgs|weak\.debug", t): cfg("lakefile_options", "C", f"{lf}: debug/-D/moreLeanArgs present")
            if not re.search(r"autoImplicit\s*=\s*false|autoImplicit\s*,\s*false|⟨`autoImplicit,\s*false⟩", t): cfg("lakefile_autoImplicit", "H", f"{lf}: autoImplicit not set to false")
            if lf == "lakefile.lean" and re.search(r"\bscript\b|extraDepTargets|IO\.Process", t): cfg("lakefile_scripts", "H", "lakefile.lean runs scripts")
    mf = root / "lake-manifest.json"
    if mf.exists():
        try:
            for pk in json.loads(mf.read_text()).get("packages", []):
                if pk.get("name") == "mathlib" and pk.get("url") not in ("https://github.com/leanprover-community/mathlib4", "https://github.com/leanprover-community/mathlib4.git"):
                    cfg("manifest_mathlib_url", "C", f"mathlib url = {pk.get('url')!r}")
                if pk.get("type") == "path": cfg("manifest_path_dep", "H", f"path dependency {pk.get('name')}: {pk.get('dir')}")
        except json.JSONDecodeError: cfg("manifest_json", "C", "lake-manifest.json unparsable")
    tracked = subprocess.run(["git", "-C", str(root), "ls-files"], capture_output=True, text=True).stdout.splitlines()
    bad = [t for t in tracked if re.search(r"\.(olean|ilean|trace|hash)$", t) or t.startswith(".lake/")]
    if bad: cfg("tracked_build_artifacts", "C", f"{len(bad)} tracked build artifacts, e.g. {bad[0]}")
    gi = (root / ".gitignore").read_text() if (root / ".gitignore").exists() else ""
    if not re.search(r"^\.lake/?$|^/\.lake/?$", gi, re.M): cfg("gitignore_lake", "H", ".lake not gitignored")
    ci = root / ".github" / "workflows"
    if ci.exists():
        for w in ci.glob("*.y*ml"):
            if re.search(r"skipKernelTC|LEAN_[A-Z_]*=|-D\s*debug", w.read_text()): cfg("ci_env", "C", f"{w.name}: suspicious env/option")
    return findings

def main() -> int:
    ap = argparse.ArgumentParser(); ap.add_argument("root"); ap.add_argument("--diff"); ap.add_argument("--json", action="store_true"); ap.add_argument("--challenge")
    a = ap.parse_args(); root = pathlib.Path(a.root).resolve()
    chal = a.challenge
    cj = root / "comparator.json"
    if chal is None and cj.exists():
        try: chal = json.loads(cj.read_text()).get("challenge_module")
        except json.JSONDecodeError: pass
    fs = scan(root, a.diff, chal)
    worst = max((SEV_RANK[f["sev"]] for f in fs), default=-1)
    if a.json:
        print(json.dumps(dict(root=str(root), diff=a.diff, findings=fs, worst={2: "C", 1: "H", 0: "M", -1: None}[worst]), indent=1))
    else:
        for f in sorted(fs, key=lambda f: (-SEV_RANK[f["sev"]], f["file"], f["line"])):
            print(f"{f['sev']} {f['rule']:<22} {f['file']}:{f['line']}  {f['text']}" + (f"   [{f['note']}]" if f.get('note') else ""))
        c = {s: sum(1 for f in fs if f["sev"] == s) for s in "CHM"}
        print(f"\n{c['C']} critical, {c['H']} high, {c['M']} medium   (scan is a filter; run leanchecker)")
    return 2 if worst == 2 else 1 if worst >= 0 else 0

if __name__ == "__main__":
    sys.exit(main())
```

## 7. Embedded program: `AxiomSweep.lean.tmpl`

Save verbatim to `~/.claude/skills/lean-cheat-check/scripts/AxiomSweep.lean.tmpl`. It is *meta
code* (it uses `run_cmd` and `open Lean`), which is why it must live outside the audited repo
and is itself never part of anything trusted: a bug in it can only lose coverage (visible as a
low `SWEEP` count), never produce a false pass of layer 3. Placeholders: `@ROOTS@` (space-
separated modules to import), `@PREFIXES@` (comma-separated quoted module-name roots, e.g.
`` `FiveGenBetti, `Challenge, `Solution, `Targets ``), `@ALLOWED@` (comma-separated quoted
names, e.g. `` `propext, `Classical.choice, `Quot.sound ``). Verify the few API names against
your pinned toolchain the first time (`getModuleFor?`, `collectAxioms`, `SMap.fold` are the
ones that have moved historically); a compile error here is loud, not silent.

```lean
-- AxiomSweep.lean (generated; lives OUTSIDE the audited repository)
import @ROOTS@
open Lean Elab Command

set_option pp.all true

def sweepPrefixes : List Name := [@PREFIXES@]
def sweepAllowed  : List Name := [@ALLOWED@]

/-- Is `m` a project module (its root component is in `sweepPrefixes`)? -/
def isProjectModule (m : Name) : Bool := sweepPrefixes.contains m.getRoot

run_cmd liftCoreM do
  let env ← getEnv
  let mut checked := 0
  let mut bad := 0
  for (n, ci) in env.constants.fold (fun acc n ci => (n, ci) :: acc) [] do
    if n.isInternal then continue
    let some m := env.getModuleFor? n | continue   -- `none` = current file (this probe); skip
    unless isProjectModule m do continue
    checked := checked + 1
    if let .axiomInfo _ := ci then
      bad := bad + 1
      logInfo m!"AXIOM_DECLARED {n} in {m}"
    let axs ← collectAxioms n
    let extra := axs.filter (fun a => !sweepAllowed.contains a)
    if !extra.isEmpty then
      bad := bad + 1
      logInfo m!"BAD_AXIOMS {n} in {m} : {extra}"
  logInfo m!"SWEEP {checked} constants checked, {bad} flagged"
```

For the layer-4 type dump, append (one name per statement of record):

```lean
run_cmd liftCoreM do
  for n in [@RECORDS@] do
    let ci ← getConstInfo n
    logInfo m!"TYPE {n} : {ci.type}"
```

and diff the `TYPE` lines between a `Challenge`-importing and a `Solution`-importing run.

## 8. Self-test (do this once per toolchain; keeps the skill honest)

In a scratch clone of any sorry-free module, insert immediately before some theorem `T`:

```lean
set_option debug.skipKernelTC true in
run_cmd Lean.Elab.Command.liftCoreM do
  Lean.addDecl (.thmDecl { name := `cheat, levelParams := [], type := Lean.mkConst ``False,
                           value := Lean.mkConst ``True.intro })
theorem T' : <T's statement> := cheat.elim
```

Expected ladder behaviour (observed on v4.35.0-rc3): layer 1 reports `skipKernelTC`, `addDecl`,
`meta_cmd`, `set_option_debug` as CRITICAL; layer 2 (sweep) is **clean** for `T'`; layer 3
`leanchecker <that module>` exits 1 with `(kernel) declaration type mismatch … 'cheat' has type
True but it is expected to have type False`, while `leanchecker Solution` alone exits 0. If
your toolchain does not reproduce this, update §1/§4 before trusting the skill. Additional
fixtures worth keeping: `axiom cheat : False` (layers 1 and 2 catch), `native_decide` (1 and 2,
`Lean.ofReduceBool`), a hypothesis deleted from a frozen signature (layer 4 only), a
`local notation` above a theorem changing a symbol (layer 4 only), `#exit` before the last
theorem (layer 1; layer 2 then shows the theorem missing from the sweep count).

## 9. Report format

Write the report for a reader who did not watch; it must stand alone and must say what was
*not* checked.

```
# lean-cheat-check report — <repo> @ <commit>  (<date>)
Mode: full | diff vs <ref>        Modules replayed: <list>        Allowlist: <list>

| Layer | Ran | Result | Evidence |
|---|---|---|---|
| 0 preconditions | yes | clean | toolchain leanprover/lean4:v4.35.0-rc3; 0 tracked oleans |
| 1 static scan   | yes | 0 C / 3 H / 1 M | H: run_cmd in AxiomAudit.lean (benign: prints axioms) ... |
| 2 axiom sweep   | yes | 212 checked, 0 flagged | SWEEP line |
| 3 kernel replay | yes | rc 0 on 7 modules | `lake env leanchecker A B ... Solution` |
| 4 fidelity      | partial | records' types identical Challenge/Solution; vacuity argued for A–E | comparator not run locally (Linux CI) |

Findings (numbered, severity, file:line, why it matters, resolution or why benign)
Not checked: --fresh replay, nanoda, comparator (CI), <anything skipped>

VERDICT: CLEAN | SUSPICIOUS | CHEAT_FOUND | INCOMPLETE
```

`CLEAN` requires layers 0–3 all run and clean, and layer 4 at least items 1, 4 and 5 done.
`INCOMPLETE` whenever layer 3 did not cover every touched module. Never write `CLEAN` on the
strength of a build log, a `#print axioms` listing, or the proof author's description.

## 10. Limitations

- The scanner is regex over stripped text: it will miss novel constructs and flag benign
  ones. That is acceptable only because layer 3 does not depend on it.
- `leanchecker` trusts the Lean kernel binary and the `.olean` files of imports. Only
  `--fresh` (hours) addresses tampered import oleans; only an independent kernel (nanoda,
  via `leanexport`) addresses a tampered Lean binary. Run both before external claims.
- Statement fidelity (E3) is partly human judgment: whether a formal statement means the
  informal theorem is argued in a CORRESPONDENCE document, not computed. This skill makes
  the inputs to that judgment explicit; it cannot replace it.
- The sweep's module filter relies on module names; a project that puts code under a
  Mathlib-looking module name (`Mathlib.Foo`) evades the prefix filter. Check `lean_lib`
  roots in the lakefile against the prefixes you pass.
