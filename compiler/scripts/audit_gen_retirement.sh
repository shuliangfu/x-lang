#!/usr/bin/env bash
# audit_gen_retirement.sh — audit pinned gen.c retirement status
#
# Categorizes each compiler/*_gen.c (and *_gen2.c / *_gen_test.c / pinned
# variants) into:
#   [RETIRED]  in driver_leaf_x_to_o.sh catalog (product uses *_x.o)
#   [HALF]     has ensure_*_gen.sh but still pin/seed/-E managed
#   [PINNED]   no ensure script; still Makefile/seed pinned
#   [TEST]     test-only pinned (parser_gen_test / typeck_gen_test)
#   [STAGE]    self-host stage1/stage2 verification artifact (not product)
#   [DEAD]     no references found (candidate for deletion)
#
# Usage (cwd = compiler/):
#   bash scripts/audit_gen_retirement.sh
#   bash scripts/audit_gen_retirement.sh --summary   # counts only
#
# Output: one line per gen file + summary counts.
# Exit: 0 always (informational).

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$COMPILER_DIR" || exit 1

SUMMARY_ONLY=0
[ "${1:-}" = "--summary" ] && SUMMARY_ONLY=1

# Collect gen.c candidates: *_gen.c, *_gen2.c, *_gen_test.c, lsp_gen_full.c
GEN_FILES=$(ls -1 *_gen.c *_gen2.c *_gen_test.c lsp_gen_full.c 2>/dev/null | sort -u)

# Catalog (retired) leaf table
CATALOG_SH="scripts/driver_leaf_x_to_o.sh"

# ensure scripts
ENSURE_SCRIPTS=$(ls -1 scripts/ensure_*.sh 2>/dev/null)

# Counters
RETIRED=0
HALF=0
PINNED=0
TEST_CNT=0
STAGE_CNT=0
DEAD_CNT=0

audit_one() {
  local gen="$1"
  local base="${gen%.c}"
  local x_o="${base%_gen}_x.o"
  [ "$base" = "$gen" ] && x_o="${gen%.c}_x.o"

  # Skip if file doesn't exist (already deleted)
  [ ! -f "$gen" ] && return

  local size=$(wc -c < "$gen" 2>/dev/null | tr -d ' ')
  local lines=$(wc -l < "$gen" 2>/dev/null | tr -d ' ')

  # Check if in catalog (retired) — catalog uses *_x.o keys, not *_gen.c names
  # Map gen.c → expected x.o key, then check if catalog has that key
  local in_catalog=""
  local leaf_key="${base%_gen}_x.o"
  if [ -f "$CATALOG_SH" ] && grep -qE "^\s*${leaf_key}\)" "$CATALOG_SH" 2>/dev/null; then
    in_catalog="yes"
  fi

  # Check which ensure script manages it
  local ensure_owner=""
  for sh in $ENSURE_SCRIPTS; do
    if grep -qE "$base" "$sh" 2>/dev/null; then
      ensure_owner=$(basename "$sh")
      break
    fi
  done

  # Check if *_x.o exists
  local has_x_o="no"
  [ -f "$x_o" ] && has_x_o="yes"

  # Check seed pin
  local seed_pin=""
  local seed_file="seeds/${base}.linux.x86_64.c"
  [ -f "$seed_file" ] && seed_pin="yes"

  # Check references in scripts/ (excluding self-audit)
  local ref_count=$(grep -rl "$base" scripts/ mk/ verify-selfhost*.sh build_and_test*.sh 2>/dev/null | grep -v "audit_gen_retirement" | wc -l | tr -d ' ')

  # Categorize
  local category=""
  local detail=""

  if echo "$gen" | grep -qE '_gen_test\.c$'; then
    category="TEST"
    TEST_CNT=$((TEST_CNT + 1))
    detail="test-only pinned"
  elif [ "$in_catalog" = "yes" ]; then
    category="RETIRED"
    RETIRED=$((RETIRED + 1))
    detail="catalog (driver_leaf_x_to_o.sh)"
  elif [ -n "$ensure_owner" ]; then
    category="HALF"
    HALF=$((HALF + 1))
    detail="$ensure_owner (pin/seed/-E)"
  elif echo "$gen" | grep -qE '^(token_gen2|ast_gen2|lexer_gen2)\.c$'; then
    category="STAGE"
    STAGE_CNT=$((STAGE_CNT + 1))
    detail="self-host stage verification artifact"
  elif [ "$ref_count" -eq 0 ]; then
    category="DEAD"
    DEAD_CNT=$((DEAD_CNT + 1))
    detail="no references (candidate for deletion)"
  else
    category="PINNED"
    PINNED=$((PINNED + 1))
    detail="$ref_count refs in scripts/mk"
  fi

  if [ $SUMMARY_ONLY -eq 0 ]; then
    printf '[%-7s] %-28s %6s B %5s L  x_o=%-3s seed=%-3s  %s\n' \
      "$category" "$gen" "$size" "$lines" "$has_x_o" "${seed_pin:-no}" "$detail"
  fi
}

# 7.4-blocked front-end gens (for annotation)
A_LAYER="parser_gen.c lexer_gen.c ast_gen2.c typeck_gen.c codegen_gen.c"

if [ $SUMMARY_ONLY -eq 0 ]; then
  echo "=== gen.c Retirement Audit ==="
  echo "  (cwd: $COMPILER_DIR)"
  echo ""
  printf '%-9s %-28s %8s %7s  %-8s %-8s  %s\n' \
    "CATEGORY" "FILE" "BYTES" "LINES" "X_O" "SEED" "DETAIL"
  echo "--------------------------------------------------------------------------------"
fi

for gen in $GEN_FILES; do
  audit_one "$gen"
done

# Also check for deleted but still in inventory
if [ $SUMMARY_ONLY -eq 0 ]; then
  echo ""
  echo "=== 7.4-blocked front-end (A layer) ==="
  for g in $A_LAYER; do
    if [ -f "$g" ]; then
      echo "  $g — exists (7.4 mega de-pin required)"
    fi
  done
fi

echo ""
echo "=== Summary ==="
echo "  RETIRED:  $RETIRED  (catalog managed, product uses *_x.o)"
echo "  HALF:     $HALF     (ensure_*_gen.sh but still pin/seed/-E)"
echo "  PINNED:   $PINNED   (no ensure, Makefile/seed pinned)"
echo "  TEST:     $TEST_CNT (test-only pinned)"
echo "  STAGE:    $STAGE_CNT (self-host stage verification)"
echo "  DEAD:     $DEAD_CNT (no references, deletion candidate)"
echo "  TOTAL:    $((RETIRED + HALF + PINNED + TEST_CNT + STAGE_CNT + DEAD_CNT))"
echo ""
echo "  Already retired (in catalog but not in compiler/ as *_gen.c):"
for leaf in driver_fmt driver_check driver_test driver_build driver_run driver_emit driver_compile lsp_io_std_heap; do
  if ! [ -f "${leaf}_gen.c" ] || [ ! -s "${leaf}_gen.c" ]; then
    echo "    ${leaf}_gen.c — retired (product uses ${leaf}_x.o)"
  fi
done

exit 0
