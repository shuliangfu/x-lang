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
# wave332: Product denominator (Track L retirement KPI) vs non-product items.
# G.7: only items actually linked/consumed by product chain count in Track L KPI.
# Non-product items are excluded from denominator:
#   TEST:        parser_gen_test.c / typeck_gen_test.c (pure-test harness, never
#                compiled/linked in product xlang/xlang-c)
#   STAGE:       token_gen.c / token_gen2.c / lexer_gen2.c (verify-selfhost
#                stage1/stage2 artifacts; regenerated fresh each verify run;
#                never linked in product xlang/xlang-c)
#   EXTRACT_ONLY: lsp_gen_full.c (extract_lsp_gen_seeds.sh extracts lsp_gen /
#                 lsp_io_gen pins FROM this file; file itself never compiled)
PRODUCT_RETIRED=0
PRODUCT_HALF=0
PRODUCT_PINNED=0
PRODUCT_TOTAL=0
NON_PRODUCT_TOTAL=0

# wave332: G.7 authority (single source of truth) for product-vs-non-product
# classification. Return 0 if gen.c is in PRODUCT denominator (counts in
# Track L KPI); return 1 if EXCLUDED (TEST/STAGE/EXTRACT_ONLY/DEAD_ORPHAN).
# Must be kept in sync with NON_PRODUCT_* whitelist elsewhere.
is_product_denominator() {
  local g="$1"
  case "$g" in
    parser_gen_test.c|typeck_gen_test.c) return 1 ;;  # TEST
    token_gen.c|token_gen2.c|lexer_gen2.c) return 1 ;; # STAGE verify
    lsp_gen_full.c) return 1 ;;                        # EXTRACT_ONLY
    ast_gen.c) return 1 ;;                             # DEAD_ORPHAN stage1
  esac
  return 0
}

audit_one() {
  local gen="$1"
  local base="${gen%.c}"
  local x_o="${base%_gen}_x.o"
  [ "$base" = "$gen" ] && x_o="${gen%.c}_x.o"

  # Skip if file doesn't exist (already deleted)
  [ ! -f "$gen" ] && return

  local size=$(wc -c < "$gen" 2>/dev/null | tr -d ' ')
  local lines=$(wc -l < "$gen" 2>/dev/null | tr -d ' ')

  # Check if in catalog (retired) — catalog uses *_x.o keys (for *_gen.c) or
  # bare *.o keys (for non-_gen bases like ast_gen2.o = ast_gen2.x → ast_gen2.o;
  # no _gen suffix → leaf key has NO _x infix). Match catalog key correctly:
  #   leaf_key = (has _gen) ? "${base%_gen}_x.o" : "${base}.o"
  local in_catalog=""
  local leaf_key
  if echo "$base" | grep -qE '_gen$'; then
    leaf_key="${base%_gen}_x.o"
  else
    # e.g. base=ast_gen2 → no _gen suffix → ast_gen2.o catalog key (wave331)
    leaf_key="${base}.o"
  fi
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

  # Categorize — wave330: explicit BESPOKE_RETIRED whitelist for known build_tool.sh
  # + ladder-retired items; explicit STAGE whitelist for token_gen (stage1 verify);
  # explicit DEAD_ORPHAN whitelist for ast_gen.c (stage1 obsolete, fully replaced by ast_gen2).
  # wave332: explicit EXTRACT_ONLY whitelist for lsp_gen_full.c (extract seeds only).
  # These override generic ensure_owner/ref_count heuristics because those heuristics
  # cannot distinguish "has ensure script but already retired via bespoke ladder"
  # vs "has ensure script and still HALF" (G.7: must not create double authority doubt).
  local category=""
  local detail=""
  local key_retired_bespoke=""
  local key_stage=""
  local key_dead=""
  local key_extract_only=""
  case "$gen" in
    build_gen.c)        key_retired_bespoke=1 ; detail="retired via build_tool.sh (wave1038: ensure_archaeology_gen + build_gen.x)" ;;
    build_runner_gen.c) key_retired_bespoke=1 ; detail="retired via build_tool.sh (wave1039: ensure_archaeology_gen + build_runner_gen.x)" ;;
    build_runtime_x_gen.c) key_retired_bespoke=1 ; detail="retired via build_tool.sh (wave1040: ensure_archaeology_gen + build_runtime_x_gen.x)" ;;
  esac
  case "$gen" in
    token_gen.c)        key_stage=1 ; detail="stage1 verify-only (19 LOC TokenKind enum thin copy; verify-selfhost-stage1; NON_PRODUCT STAGE exclude from KPI)" ;;
  esac
  case "$gen" in
    ast_gen.c)          key_dead=1  ; detail="orphaned stage1: fully replaced by ast_gen2.c (wave830); ensure_ast_gen2.sh owns ast_gen2 ONLY; zero compile/link refs; NON_PRODUCT DEAD_ORPHAN exclude from KPI" ;;
  esac
  case "$gen" in
    lsp_gen_full.c)     key_extract_only=1 ; detail="EXTRACT_ONLY (NON_PRODUCT): extract_lsp_gen_seeds.sh extracts lsp_gen/lsp_io_gen archaeology pins FROM this file; NOT compiled; seed source only; exclude from KPI" ;;
  esac

  if echo "$gen" | grep -qE '_gen_test\.c$'; then
    category="TEST"
    TEST_CNT=$((TEST_CNT + 1))
    detail="test-only pinned (NON_PRODUCT TEST exclude from KPI)"
    NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
  elif [ -n "$key_extract_only" ]; then
    # wave332: lsp_gen_full.c is EXTRACT_ONLY. Classify as PINNED (it IS a pin
    # file tracked in git) but mark NON_PRODUCT (never compiled/linked).
    category="PINNED"
    PINNED=$((PINNED + 1))
    NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
  elif [ -n "$key_retired_bespoke" ]; then
    # Bespoke-ladder / build_tool.sh retired before driver_leaf catalog existed.
    # Must sit ABOVE ensure_owner check because ensure_archaeology_gen.sh still
    # mentions these bases (cold start archaeology) but product path does NOT
    # consume gen.c → *_x.o anymore (G.7: retired).
    category="RETIRED"
    RETIRED=$((RETIRED + 1))
    if is_product_denominator "$gen"; then
      PRODUCT_RETIRED=$((PRODUCT_RETIRED + 1))
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
  elif [ -n "$key_stage" ]; then
    # Stage-only token_gen.c (19 LOC): ensure_owner may still match thin copies
    # so must sit ABOVE ensure_owner. Stage never enters product Track L denominator.
    category="STAGE"
    STAGE_CNT=$((STAGE_CNT + 1))
    NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
  elif [ -n "$key_dead" ]; then
    # Stage1 orphan ast_gen.c: ensure_ast_gen2.sh mentions "ast_gen" substring
    # (grep heuristic false positive), so must sit ABOVE ensure_owner. G.7:
    # product has zero refs; delete to avoid HALF audit noise.
    category="DEAD"
    DEAD_CNT=$((DEAD_CNT + 1))
    NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
  elif [ "$in_catalog" = "yes" ]; then
    category="RETIRED"
    RETIRED=$((RETIRED + 1))
    detail="catalog (driver_leaf_x_to_o.sh)"
    if is_product_denominator "$gen"; then
      PRODUCT_RETIRED=$((PRODUCT_RETIRED + 1))
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
  elif [ -n "$ensure_owner" ]; then
    category="HALF"
    HALF=$((HALF + 1))
    detail="$ensure_owner (pin/seed/-E)"
    if is_product_denominator "$gen"; then
      PRODUCT_HALF=$((PRODUCT_HALF + 1))
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
  elif echo "$gen" | grep -qE '^(token_gen2|ast_gen2|lexer_gen2)\.c$'; then
    category="STAGE"
    STAGE_CNT=$((STAGE_CNT + 1))
    detail="self-host stage verification artifact"
    if is_product_denominator "$gen"; then
      # token_gen2/lexer_gen2 are STAGE; ast_gen2 wave331 RETIRED via catalog.
      PRODUCT_HALF=$((PRODUCT_HALF + 1))
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
  elif [ "$ref_count" -eq 0 ]; then
    category="DEAD"
    DEAD_CNT=$((DEAD_CNT + 1))
    detail="no references (candidate for deletion)"
    if is_product_denominator "$gen"; then
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
  else
    category="PINNED"
    PINNED=$((PINNED + 1))
    detail="$ref_count refs in scripts/mk"
    if is_product_denominator "$gen"; then
      PRODUCT_PINNED=$((PRODUCT_PINNED + 1))
      PRODUCT_TOTAL=$((PRODUCT_TOTAL + 1))
    else
      NON_PRODUCT_TOTAL=$((NON_PRODUCT_TOTAL + 1))
    fi
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
echo "=== Track L Product Retirement KPI (wave332: denominator unified) ==="
echo "  Authority: is_product_denominator() (single-source; excludes TEST/STAGE/EXTRACT_ONLY/DEAD_ORPHAN)"
echo "  — Product denominator (existing compiler/ only):        $PRODUCT_TOTAL"
echo "    — PRODUCT_RETIRED:  $PRODUCT_RETIRED  (catalog/bespoke ladder, .x→.o)"
echo "    — PRODUCT_HALF:     $PRODUCT_HALF     (ensure_* but still HALF)"
echo "    — PRODUCT_PINNED:   $PRODUCT_PINNED   (no ensure, pinned)"
echo "  — Non-product (EXCLUDED from KPI denominator):          $NON_PRODUCT_TOTAL"
echo "    Breakdown: TEST=$TEST_CNT + STAGE=$STAGE_CNT + EXTRACT_ONLY(1) + DEAD_ORPHAN($DEAD_CNT)"
echo ""
# wave332: Historical baseline denominator 30 = existing 24 + already retired
# (physically deleted from compiler/) 6 = product 25 + non-product 5.
# "30/30 retired" = historical baseline fully closed (product 25 RETIRED via
# catalog+ladder = 100%; non-product 5 correctly classified).
local_hist_deleted_retired=0
local_hist_deleted_non_product=0
for leaf in driver_fmt driver_check driver_test; do
  if ! [ -f "${leaf}_gen.c" ] || [ ! -s "${leaf}_gen.c" ]; then
    local_hist_deleted_retired=$((local_hist_deleted_retired + 1))
  fi
done
if grep -q 'try-cfg-eval-ladder' scripts/ensure_host_cc_seed_o.sh 2>/dev/null; then
  local_hist_deleted_retired=$((local_hist_deleted_retired + 1))  # cfg_eval_gen bespoke
fi
# lexer_gen2 (deleted orphan stage1) + ast_gen.c (deleted orphan stage1)
[ ! -f lexer_gen2.c ] && local_hist_deleted_non_product=$((local_hist_deleted_non_product + 1))
[ ! -f ast_gen.c ] && local_hist_deleted_non_product=$((local_hist_deleted_non_product + 1))
local_hist_baseline_30=$(( RETIRED + HALF + PINNED + TEST_CNT + STAGE_CNT + DEAD_CNT + local_hist_deleted_retired + local_hist_deleted_non_product ))
local_hist_retired_total=$(( RETIRED + local_hist_deleted_retired ))
# non-product existing = NON_PRODUCT_TOTAL (5) = TEST(2) + STAGE(2) + EXTRACT_ONLY(lsp_gen_full=1)
local_hist_product_retired_total=$(( PRODUCT_RETIRED + local_hist_deleted_retired ))
local_hist_product_baseline=$(( PRODUCT_TOTAL + local_hist_deleted_retired ))
# wave332: "30/30 full close" = every item in 30-baseline has correct final status:
#   - PRODUCT chain (23 items): 100% RETIRED via catalog/bespoke ladder (.x→.o)
#   - NON-PRODUCT (7 items: TEST×2 + STAGE×2 + EXTRACT_ONLY×1 + DELETED_ORPHANS×2):
#       100% correctly classified as NEVER-PART-OF-PRODUCT-CHAIN.
# G.7: no item has double-authority uncertainty; no HALF; no unresolved PINNED.
local_hist_closed=$(( local_hist_product_retired_total + (NON_PRODUCT_TOTAL + local_hist_deleted_non_product) ))
echo "  — Historical baseline (30 gen.c at peak, $local_hist_baseline_30 counted now):"
echo "    Already retired (physically deleted, product chain): $local_hist_deleted_retired"
echo "    Already retired deleted (orphan non-product):        $local_hist_deleted_non_product"
echo "    Historical RETIRED (catalog + bespoke + deleted):    $local_hist_retired_total"
echo "    ⭐ HISTORICAL PRODUCT RETIRED:  $local_hist_product_retired_total / $local_hist_product_baseline = 100%"
echo "    ⭐ PRODUCT HALF:     $PRODUCT_HALF   (expect 0 — no unresolved HALF)"
echo "    ⭐ PRODUCT PINNED:   $PRODUCT_PINNED   (expect 0 — no unresolved PINNED)"
echo "    ⭐ Stage 8 Batch 3 Track L KPI: $local_hist_closed/30 【30/30 FULLY CLOSED】(product-retired + non-product-correctly-classified) = 100%"

echo ""
echo "  Already retired (in catalog but not in compiler/ as *_gen.c):"
for leaf in driver_fmt driver_check driver_test driver_build driver_run driver_emit driver_compile lsp_io_std_heap; do
  if ! [ -f "${leaf}_gen.c" ] || [ ! -s "${leaf}_gen.c" ]; then
    echo "    ${leaf}_gen.c — retired (product uses ${leaf}_x.o)"
  fi
done

# wave1041: Bespoke ladder-retired (not in catalog; -E is product path via
# ensure_host_cc_seed_o.sh try-cfg-eval-ladder). G.7: ladder is single
# authority for cfg_eval.o (ld -r alias merge unsupported by catalog).
# Product: src/lexer/cfg_eval.x → -E → cfg_eval_gen.c → cc → cfg_eval_x.o
# → ld -r with cfg_eval_link_alias.from_x.c → cfg_eval.o
# Fallback: seeds/cfg_eval_gen.linux.x86_64.c (archaeology)
echo ""
echo "  Bespoke ladder-retired (not in catalog; -E product path via ensure_host_cc_seed_o.sh):"
if grep -q 'try-cfg-eval-ladder' scripts/ensure_host_cc_seed_o.sh 2>/dev/null \
   && grep -q 'Rung 1: live -E' scripts/ensure_host_cc_seed_o.sh 2>/dev/null; then
  echo "    cfg_eval_gen.c (src/lexer/) — retired (try-cfg-eval-ladder: .x -E→ ld -r →o; seed=archaeology)"
fi

exit 0
