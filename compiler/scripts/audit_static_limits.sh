#!/usr/bin/env bash
# audit_static_limits.sh — static caps vs source-side enum scale (read-only)
#
# Compare MODULE_ENUM_MAX (live = pipe_en_max_variants in runtime_pipeline_abi.x)
# and AST_ENUM_MAX_VARIANTS (ast.h legacy doc) against .x enum variant counts.
# Prevents silent truncate → typeck "found ?" class failures.
#
# wave965: retarget off deleted compiler/ast_pool.c (wave309 leave). Grepping a
# missing file silently defaulted MODULE_ENUM_MAX=256 and always reported 0
# sentinel hits while printing OK — fake authority (same debt layer as dead -nt).
# PLATFORM: SHARED — structural honesty only (no product compile); dual-end L2.
#
# Usage: bash compiler/scripts/audit_static_limits.sh
# Exit: 0=pass; 1=enum variants near/over MODULE hard cap (headroom <16)
#       or live MODULE authority unresolved.

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1

ABI_X="compiler/src/runtime_pipeline_abi.x"
AST_H="compiler/include/ast.h"

# Live authority: pipe_en_max_variants() return N in runtime_pipeline_abi.x
# (≡ historic MODULE_ENUM_MAX_VARIANTS; ast_pool.c retired wave309).
# PLATFORM: SHARED — use grep/sed (Ubuntu gold often has no ripgrep in PATH).
MODULE_ENUM_MAX="$(
  ln="$(grep -nE 'function[[:space:]]+pipe_en_max_variants[[:space:]]*\(' "$ABI_X" 2>/dev/null \
    | head -1 | cut -d: -f1)"
  if [ -n "${ln:-}" ]; then
    # Body is small: scan a short window after the function line for `return N;`.
    sed -n "${ln},$((ln + 12))p" "$ABI_X" \
      | grep -oE 'return[[:space:]]+[0-9]+[[:space:]]*;' \
      | head -1 | awk '{print $2}' | tr -d ';'
  fi
)"
AST_ENUM_MAX="$(
  grep -oE 'AST_ENUM_MAX_VARIANTS[[:space:]]+[0-9]+' "$AST_H" 2>/dev/null \
    | head -1 | awk '{print $NF}'
)"

if [ -z "${MODULE_ENUM_MAX:-}" ]; then
  echo "audit_static_limits: FAIL: cannot resolve pipe_en_max_variants return in $ABI_X" >&2
  echo "  (ast_pool.c retired wave309; do not silent-default — fake authority)" >&2
  exit 1
fi
: "${AST_ENUM_MAX:=32}"

echo "=== hard-cap macros (hot path) ==="
echo "MODULE_ENUM_MAX_VARIANTS=$MODULE_ENUM_MAX  (pipe_en_max_variants @ runtime_pipeline_abi.x)"
echo "AST_ENUM_MAX_VARIANTS=$AST_ENUM_MAX  (ast.h legacy doc; no fixed-array refs)"
echo ""

export MODULE_ENUM_MAX AST_ENUM_MAX
python3 - <<'PY'
from pathlib import Path
import re, sys, os

mod_max = int(os.environ["MODULE_ENUM_MAX"])
ast_max = int(os.environ["AST_ENUM_MAX"])
root = Path("compiler/src")
rows = []
for p in sorted(root.rglob("*.x")):
    text = p.read_text(errors="ignore")
    for m in re.finditer(r"(?:export\s+)?enum\s+(\w+)\s*\{([^}]*)\}", text, re.S):
        name, body = m.group(1), m.group(2)
        vars_ = re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:,|//|\n|$)", body, re.M)
        vars_ = [v for v in vars_ if v not in ("if", "else", "return", "while", "for")]
        if len(vars_) >= 8:
            rows.append((len(vars_), name, str(p)))
rows.sort(reverse=True)

print("=== compiler/src large enum variant counts ===")
print(f"{'n':>4}  {'enum':28s}  {'file':42s}  MODULE  AST_legacy")
fail = 0
for n, name, path in rows[:40]:
    if n >= mod_max:
        m_st = "OVER"
        fail = 1
    elif n >= mod_max - 16:
        m_st = "NEAR"
        fail = 1
    else:
        m_st = "OK"
    a_st = "OK" if n <= ast_max else "OVER_LEGACY"
    print(f"{n:4d}  {name:28s}  {path:42s}  {m_st:6s}  {a_st}")
if not rows:
    print("(no enums with >=8 variants found)")

print("")
print("=== sentinel class (0 also legal index) — retired with ast_pool.c ===")
print("ast_pool.c left wave309; param_base/field_base/struct_lit_field_base")
print("assignment sentinels lived only in that C shell. Live path = abi.x pools.")
print("Scan of deleted compiler/ast_pool.c removed (never fired / always 0 hits).")
print("PLATFORM: SHARED — archaeology N/A; not a silent-green 0-hit report.")

print("")
print("=== class-A hard caps (summary) ===")
print("  MODULE_ENUM_MAX_VARIANTS — list count; silent fail → diagnostics")
print("  AST_ENUM_MAX_VARIANTS=32 — legacy doc constant; X path does not read")
print("  XLANG_DRIVER_DEP_SLOT_MAX=32 — dep-graph slots; raise when hit")
print("  name[64]/param[32] — semantic lengths; do not raise")
print("  detail: analysis/X侧车grow池与动态上限清单.md § silent hard-cap table")
print("")

if fail:
    print(f"FAIL: enum NEAR/OVER MODULE_ENUM_MAX_VARIANTS={mod_max} (need headroom ≥16)")
    sys.exit(1)
print(f"OK: all scanned enums have ≥16 headroom under MODULE_ENUM_MAX_VARIANTS={mod_max}")
sys.exit(0)
PY
