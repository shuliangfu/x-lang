#!/usr/bin/env bash
# bc_host_cc_product_inventory.sh — wave963 · open BC track (stage 8.3 map)
#
# Authority (G.7):
#   Single machine-checkable inventory of *product residual C* that still
#   require host-cc on the cold / product path (BC layer). Does NOT compile
#   and does NOT own .o lists (those stay compiler/mk/*.mk + catalog).
#
#   Human map: analysis/C迁移追踪.md §8.3
#   Progress:  analysis/自举进度.md (wave rows)
#   Related:   leaf_pattern_residual.sh (MG leaf residual · already closed)
#
# What this is:
#   BC = bootstrap compile layer: compiler TUs should not need host cc/gcc.
#   Today glue/ast_pool / pin gen / stubs still do. This script freezes the
#   known residual surface so new orphan product C cannot land silently, and
#   so 8.3.9-class debug scratch cannot reappear under analysis/.
#
# What this is NOT:
#   - Not a second compile driver
#   - Not physical delete of product glue (that is later 8.3.1+ waves)
#   - Not pin lift
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/bc_host_cc_product_inventory.sh
#   bash compiler/scripts/bc_host_cc_product_inventory.sh dump
#   bash compiler/scripts/bc_host_cc_product_inventory.sh --check
#   ./xbuild bc-inventory | bc-host-cc [--check]
#
# PLATFORM: SHARED — inventory of sources; ABI lives in the residual bodies.
# Wave: 963 open BC + 8.3.9 orphan gone (analysis/_debug_io_ctx_gen.c was
# gitignored local scratch; --check asserts ABSENT).
# 8.3.1 domain thin cuts: ctfe + assign + coerce_init + method_call + check_block + region_assign + asm_emit_unary + asm_emit_as + asm_emit_return + asm_emit_logand + asm_emit_block_body + asm_emit_block_if_stmt + asm_emit_block_inits (#include TU).
# 8.3.2 domain thin cuts: ast_pool_module_import + ast_pool_struct_layout +
#   ast_pool_top_level + ast_pool_type_alias (#include into ast_pool TU).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  dump|list|""|--dump) MODE=dump ;;
  help|-h|--help)
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "bc_host_cc_product_inventory: unknown mode '$MODE' (use dump|check)" >&2
    exit 2
    ;;
esac

# relpath_from_repo|stage_id|role|min_loc|expect
# expect: present | absent
# min_loc: for present rows, soft floor (0 = any non-empty / placeholder OK)
PRODUCT_RESIDUAL_ROWS=(
  # --- 8.3.1 / 8.3.2 volume main debt ---
  "compiler/pipeline_glue.c|8.3.1|product mega glue (typeck/codegen/asm/match)|24000|present"
  "compiler/ast_pool.c|8.3.2|AST pool / MatchArm / sidecar|10000|present"
  "compiler/ast_pool_module_import.c|8.3.2|module ImportEntry cold-twin accessors slice|180|present"
  "compiler/ast_pool_struct_layout.c|8.3.2|module StructLayout cold accessors slice|360|present"
  "compiler/ast_pool_top_level.c|8.3.2|module TopLevelLetEntry cold accessors slice|100|present"
  "compiler/ast_pool_type_alias.c|8.3.2|module TypeAliasEntry cold accessors slice|80|present"
  # --- 8.3.1 domain thin slices (#include into pipeline_glue TU; not separate .o) ---
  "compiler/pipeline_typeck_ctfe.c|8.3.1|typeck CTFE producer slice|1000|present"
  "compiler/pipeline_typeck_assign.c|8.3.1|typeck assign domain slice|250|present"
  "compiler/pipeline_typeck_coerce_init.c|8.3.1|typeck coerce-init domain slice|300|present"
  "compiler/pipeline_typeck_method_call.c|8.3.1|typeck method_call + generic UFCS mono slice|800|present"
  "compiler/pipeline_typeck_check_block.c|8.3.1|typeck check_block orchestration slice|250|present"
  "compiler/pipeline_typeck_region_assign.c|8.3.1|typeck region/escape assign-site slice|350|present"
  "compiler/pipeline_asm_emit_unary.c|8.3.1|asm ELF unary emit (NEG/LOGNOT/BITNOT) slice|200|present"
  "compiler/pipeline_asm_emit_as.c|8.3.1|asm ELF as/await/try/float-lit emit slice|350|present"
  "compiler/pipeline_asm_emit_return.c|8.3.1|asm ELF return emit (slice escape + return_impl) slice|550|present"
  "compiler/pipeline_asm_emit_logand.c|8.3.1|asm ELF LOGAND/LOGOR short-circuit emit slice|80|present"
  "compiler/pipeline_asm_emit_block_body.c|8.3.1|asm ELF block body sync emit (defer + body_sync) slice|700|present"
  "compiler/pipeline_asm_emit_block_if_stmt.c|8.3.1|asm ELF block-level if-stmt emit (then-first jz) slice|80|present"
  "compiler/pipeline_asm_emit_block_inits.c|8.3.1|asm ELF block const/let init emit slice|140|present"
  # --- 8.3.3 typeck slices often pulled by glue ---
  "compiler/pipeline_typeck_field_access.c|8.3.3|field_access slice|500|present"
  "compiler/pipeline_typeck_soa.c|8.3.3|typeck SOA helper|50|present"
  # --- 8.3.4 bootstrap glue / orchestration ---
  "compiler/ast_pool_bootstrap_glue.c|8.3.4|cold-start ast bridge|100|present"
  "compiler/pipeline_bootstrap_orchestration.c|8.3.4|orchestration wrapper → seed|1|present"
  # --- 8.3 product weak twin / standalone seed ---
  "compiler/seeds/pipeline_glue_standalone.from_x.c|8.3.1|standalone glue seed twin|50|present"
  "compiler/seeds/pipeline_glue_strict_minimal.from_x.c|8.3|strict_minimal seed twin|1000|present"
  # --- 8.3.5 link alias / stubs (retire later) ---
  "compiler/ast_asm_bare_link_alias.c|8.3.5|bare link alias wrapper|1|present"
  "compiler/backend_asm_bare_link_alias.c|8.3.5|bare link alias wrapper|1|present"
  "compiler/backend_asm_strict_fallback_alias.c|8.3.5|strict fallback alias wrapper|1|present"
  "compiler/typeck_asm_bare_link_alias.c|8.3.5|typeck bare link alias|50|present"
  "compiler/x_frontend_link_alias.c|8.3.5|x frontend link alias wrapper|1|present"
  "compiler/_stubs.c|8.3.5|cold weak stubs|1|present"
  "compiler/_x_stubs2.c|8.3.5|x frontend stubs2|1|present"
  "compiler/xlang_x_stubs.c|8.3.5|xlang-x stubs|1|present"
  "compiler/typeck_c_module_stubs.c|8.3.5|typeck c-module stubs wrapper|1|present"
  # --- 8.3.7 scripts asm stubs ---
  "compiler/scripts/asm_text_stub.c|8.3.7|asm text stub|1|present"
  "compiler/scripts/asm_xlang_lsp_diag_stub.c|8.3.7|lsp diag asm stub|1|present"
  # --- 8.3.9 orphan debug gen (wave963: must stay gone) ---
  "analysis/_debug_io_ctx_gen.c|8.3.9|orphan debug gen (gitignored scratch)|0|absent"
)

# 8.3.8 gen_driver placeholders live outside compiler/; empty files are OK.
GEN_DRIVER_DIR="build_asm/gen_driver"
GEN_DRIVER_EXPECTED=(
  driver_check.c
  driver_fmt.c
  driver_gen.c
  driver_test.c
  lsp_gen.c
  lsp_io_gen.c
  lsp_io_std_heap_gen.c
  pipeline_gen.c
  preprocess_gen.c
)

loc_of() {
  local f="$1"
  if [ ! -f "$f" ]; then
    echo 0
    return
  fi
  wc -l < "$f" | tr -d ' '
}

dump_rows() {
  local row path stage role min_loc expect abs loc status
  echo "BC_HOST_CC_PRODUCT_INVENTORY wave963"
  echo "ROOT=$ROOT"
  echo "MODE=dump"
  echo "--- product residual C (stage 8.3 map) ---"
  printf '%-8s %-10s %7s %s\n' "EXPECT" "STAGE" "LOC" "PATH"
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    abs="$ROOT/$path"
    if [ -f "$abs" ]; then
      loc="$(loc_of "$abs")"
      status="present"
    else
      loc=0
      status="absent"
    fi
    printf '%-8s %-10s %7s %s\n' "$status" "$stage" "$loc" "$path"
  done
  echo "--- 8.3.8 build_asm/gen_driver placeholders ---"
  local g
  for g in "${GEN_DRIVER_EXPECTED[@]}"; do
    abs="$ROOT/$GEN_DRIVER_DIR/$g"
    if [ -f "$abs" ]; then
      loc="$(loc_of "$abs")"
      printf 'present  8.3.8     %7s %s/%s\n' "$loc" "$GEN_DRIVER_DIR" "$g"
    else
      printf 'absent   8.3.8     %7s %s/%s\n' "0" "$GEN_DRIVER_DIR" "$g"
    fi
  done
  echo "--- summary ---"
  local present=0 absent=0
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    if [ -f "$ROOT/$path" ]; then present=$((present + 1)); else absent=$((absent + 1)); fi
  done
  echo "ROWS=${#PRODUCT_RESIDUAL_ROWS[@]} present_on_disk=$present absent_on_disk=$absent"
  echo "BC_TRACK=open wave963"
  echo "NEXT=8.3.1 pipeline_glue / 8.3.2 ast_pool thin slices (host-cc still required)"
}

run_check() {
  local fail=0
  note() { echo "bc_host_cc_product_inventory: $*" >&2; }
  bad() { echo "bc_host_cc_product_inventory: FAIL: $*" >&2; fail=1; }

  note "wave963 BC track open — product residual C inventory check"
  note "PLATFORM: SHARED — inventory only; no compile"

  local row path stage role min_loc expect abs loc
  local present_debt=0
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    abs="$ROOT/$path"
    case "$expect" in
      present)
        if [ ! -f "$abs" ]; then
          bad "missing expected residual $path ($stage · $role)"
          continue
        fi
        loc="$(loc_of "$abs")"
        if [ "$loc" -lt "$min_loc" ]; then
          bad "$path loc=$loc < min_loc=$min_loc ($stage)"
        else
          note "ok present $path loc=$loc ($stage)"
        fi
        present_debt=$((present_debt + 1))
        ;;
      absent)
        if [ -e "$abs" ]; then
          bad "must stay absent (wave963 8.3.9): $path still exists"
        else
          note "ok absent $path ($stage)"
        fi
        ;;
      *)
        bad "unknown expect='$expect' for $path"
        ;;
    esac
  done

  # 8.3.8: directory + named placeholders (empty files allowed; missing dir soft-notes).
  if [ ! -d "$ROOT/$GEN_DRIVER_DIR" ]; then
    note "gen_driver dir absent (ok if unused on this host): $GEN_DRIVER_DIR"
  else
    local g
    for g in "${GEN_DRIVER_EXPECTED[@]}"; do
      if [ ! -f "$ROOT/$GEN_DRIVER_DIR/$g" ]; then
        bad "missing gen_driver placeholder $GEN_DRIVER_DIR/$g (8.3.8)"
      fi
    done
    note "ok gen_driver placeholders n=${#GEN_DRIVER_EXPECTED[@]}"
  fi

  # Guard: no second debug orphan under analysis/ matching *_debug_*_gen.c
  # (gitignored area — only catch local reintroduction).
  if [ -d "$ROOT/analysis" ]; then
    local hit
    hit="$(find "$ROOT/analysis" -maxdepth 1 -type f \( -name '_debug_*_gen.c' -o -name '*_debug_io_ctx_gen.c' \) 2>/dev/null | head -5 || true)"
    if [ -n "$hit" ]; then
      bad "analysis/ debug gen scratch reappeared (8.3.9 class): $hit"
    else
      note "ok no analysis/ _debug_*_gen.c scratch"
    fi
  fi

  # Self-document wave tag + xbuild surface (leaf honesty twin).
  if ! grep -q 'wave963' "$0"; then
    bad "inventory script must document wave963"
  fi
  if [ ! -f "$ROOT/xlang-build.sh" ]; then
    bad "missing root xlang-build.sh"
  elif ! grep -qE 'bc-inventory|bc_host_cc_product_inventory' "$ROOT/xlang-build.sh"; then
    bad "xlang-build.sh must wire bc-inventory → this script (wave963)"
  else
    note "ok xbuild bc-inventory wiring"
  fi

  if [ "$present_debt" -lt 10 ]; then
    bad "present residual debt rows $present_debt < 10 (inventory under-count?)"
  else
    note "present residual product C rows=$present_debt (BC debt still open)"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "bc_host_cc_product_inventory: --check FAILED" >&2
    exit 1
  fi
  echo "bc_host_cc_product_inventory: CHECK OK (BC open · 8.3.1 typeck+asm slices + 8.3.2 ast_pool module_import+struct_layout+top_level+type_alias present · 8.3.9 absent · host-cc residual still required)" >&2
}

case "$MODE" in
  dump) dump_rows ;;
  check) run_check ;;
esac
