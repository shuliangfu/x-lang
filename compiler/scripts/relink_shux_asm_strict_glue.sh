#!/usr/bin/env bash
# 仅 strict 重链 shux_asm：更新 pipeline_glue_standalone.o（含 ast_pool.c）后快速激活 EMIT_HEAVY，无需全量 build_shux_asm。
# 用法：cd compiler && ./scripts/relink_shux_asm_strict_glue.sh
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build_asm"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
SEED_O="$BUILD_DIR/asm_driver_seed"
export STRICT_LINK_BUILD_ASM_PIPELINE=1

asm_seed_sx_frontend_o_ready() {
  local o
  for o in parser_sx.o typeck_sx.o codegen_sx.o lexer_sx.o; do
    if [ ! -f "$o" ] || [ ! -s "$o" ]; then
      return 1
    fi
  done
  return 0
}

asm_seed_omit_c_frontend_seed() {
  if [ -n "${SHUX_LEGACY_SEED_FRONTEND_CC:-}" ]; then
    return 1
  fi
  asm_seed_sx_frontend_o_ready
}

asm_seed_st_async_support_link() {
  echo "$SEED_O/async_liveness.o $SEED_O/async_cps_codegen.o $SEED_O/autovec.o"
}

asm_seed_st_preprocess_link() {
  if asm_seed_omit_c_frontend_seed; then
    echo ""
    return 0
  fi
  echo "$SEED_O/preprocess.o"
}

have_link_liburing() {
  printf 'int main(void){return 0;}\n' | "$CC" -x c - -o /dev/null -luring >/dev/null 2>&1
}

# codegen.c 引用 async_liveness / async_cps_codegen（与 Makefile OBJS_CORE、build_shux_asm 一致）。
ensure_async_cps_seed_objs() {
  local src out
  for src_pair in \
    "src/async/async_liveness.c:$SEED_O/async_liveness.o" \
    "src/async/async_cps_codegen.c:$SEED_O/async_cps_codegen.o"; do
    src="${src_pair%%:*}"
    out="${src_pair##*:}"
    if [ ! -f "$out" ] || [ "$src" -nt "$out" ]; then
      echo "  cc -c $src -> $out"
      mkdir -p "$(dirname "$out")"
      "$CC" $CFLAGS -c -o "$out" "$src"
    fi
  done
}

# 与 build_shux_asm.sh 一致：判断 build_asm/typeck.o 是否已 EMIT_HEAVY 自举（__text>8192）。
asm_o_text_bytes() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  if [ -z "$hex" ]; then
    hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  fi
  if [ -z "$hex" ]; then
    echo 0
    return
  fi
  echo $((16#$hex))
}

asm_strict_typeck_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
  [ "$t" -gt 8192 ] 2>/dev/null
}

# macOS ld64 / lld 支持 -exported_symbols_list；GNU bfd ld 须 objcopy --keep-global-symbols。
ld_supports_exported_symbols_list() {
  ld -v 2>&1 | grep -qE 'PROJECT:ld64|LLD|LLVM'
}

# 从符号列表（每行一个，可带 Mach-O 前缀 _）做 ld -r 局部导出；与 build_shux_asm.sh 一致。
ld_partial_export() {
  local syms_file="$1"
  local out_o="$2"
  shift 2
  local in_o="$1"
  if ld_supports_exported_symbols_list; then
    ld -r -exported_symbols_list "$syms_file" -o "$out_o" "$in_o"
    return $?
  fi
  local keep="$out_o.keep_syms"
  : > "$keep"
  while IFS= read -r sym || [ -n "$sym" ]; do
    [ -z "$sym" ] && continue
    case "$sym" in \#*) continue ;; esac
    sym="${sym#_}"
    echo "$sym" >> "$keep"
  done < "$syms_file"
  ld -r -o "$out_o" "$in_o" || return 1
  objcopy --keep-global-symbols="$keep" "$out_o" "$out_o"
}

ensure_typeck_c_orchestration_partial_obj() {
  local PARTIAL="$BUILD_DIR/typeck_c_orchestration_partial.o"
  local SYMS="$BUILD_DIR/typeck_c_orchestration_export.txt"
  local TCKO="src/typeck/typeck.o"
  [ -f "$TCKO" ] || TCKO="$SEED_O/typeck.o"
  [ -f "$TCKO" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$TCKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' _typeck_module _typeck_one_function > "$SYMS"
    echo "  ld -r -exported_symbols_list $SYMS $TCKO -> $PARTIAL (C orchestration only)" >&2
    ld_partial_export "$SYMS" "$PARTIAL" "$TCKO" 2>"$BUILD_DIR/.typeck_c_orch_partial_err" || return 1
  fi
  return 0
}

ensure_typeck_c_user_precheck_obj() {
  if ensure_typeck_c_orchestration_partial_obj; then
    echo "$BUILD_DIR/typeck_c_orchestration_partial.o"
    return 0
  fi
  echo "relink_shux_asm_strict_glue: warn: typeck_c_orchestration_partial failed; fallback stubs" >&2
  if [ ! -f "$BUILD_DIR/typeck_c_module_stubs.o" ] || [ typeck_c_module_stubs.c -nt "$BUILD_DIR/typeck_c_module_stubs.o" ]; then
    echo "  cc -c typeck_c_module_stubs.c -> $BUILD_DIR/typeck_c_module_stubs.o" >&2
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/typeck_c_module_stubs.o" typeck_c_module_stubs.c
  fi
  echo "$BUILD_DIR/typeck_c_module_stubs.o"
  return 1
}

# strict 链：C 编排 partial（run_sx_pipeline_impl 等），与 build_shux_asm.sh 一致。
ensure_pipeline_asm_orchestration_partial_obj() {
  local PARTIAL SYMS ALIAS_O
  PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_orchestration_export.txt"
  ALIAS_O="$BUILD_DIR/pipeline_asm_orchestration_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$ALIAS_O" ]; then
    echo "  cc -c src/asm/pipeline_asm_orchestration_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -c -o "$ALIAS_O" src/asm/pipeline_asm_orchestration_alias.c
  fi
  if [ ! -f "$PARTIAL" ] || [ "$ALIAS_O" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_run_sx_pipeline_impl
_run_sx_pipeline_impl
_run_sx_pipeline_parse_entry_do_parse
_run_sx_pipeline_parse_entry_if_needed
_parse_into_with_init_buf
EOF
    echo "  ld partial export $SYMS orchestration_alias.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$ALIAS_O"
  fi
  cp -f "$PARTIAL" "$BUILD_DIR/pipeline_asm_runtime_partial.o"
  return 0
}

# strict WPO opt-in：pipeline_wpo.o helper 子集（编排入口仍走 C orchestration partial）。
ensure_pipeline_wpo_helpers_partial_obj() {
  local PARTIAL SYMS WPO_E
  PARTIAL="$BUILD_DIR/pipeline_wpo_helpers_partial.o"
  SYMS="$BUILD_DIR/pipeline_wpo_helpers_export.txt"
  WPO_E="$BUILD_DIR/pipeline_wpo.o"
  if [ ! -f "$WPO_E" ] || [ ! -s "$WPO_E" ]; then
    return 1
  fi
  if ! asm_pipeline_wpo_strict_reach_ok; then
    return 1
  fi
  if [ ! -f "$SYMS" ] || [ "$WPO_E" -nt "$SYMS" ]; then
    nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE \
      '^(run_sx_pipeline_impl|run_sx_pipeline_parse_entry_do_parse|run_sx_pipeline_parse_entry_if_needed|run_sx_pipeline_typecheck_entry|parse_into_with_init_buf|parse_into_with_init|pipeline_run_sx_pipeline_impl|pipeline_run_sx_pipeline)$' \
      >"$SYMS"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$WPO_E" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export pipeline_wpo helpers -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$WPO_E" || return 1
    nm "$PARTIAL" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt"
  fi
  return 0
}

# WPO opt-in：typecheck emit 桥（helper 内 SX typecheck_entry thin bl 依赖）。
ensure_pipeline_wpo_typecheck_emit_bridge_obj() {
  local BR_O="$BUILD_DIR/pipeline_wpo_typecheck_emit_bridge.o"
  local BR_SRC="src/asm/pipeline_wpo_typecheck_emit_bridge.c"
  [ -f "$BR_SRC" ] || return 1
  if [ ! -f "$BR_O" ] || [ "$BR_SRC" -nt "$BR_O" ]; then
    echo "  cc -c $BR_SRC -> $BR_O"
    "$CC" $CFLAGS -c -o "$BR_O" "$BR_SRC" || return 1
  fi
  return 0
}

# B-hybrid / strict_glue：lsp_sx.o 缺的 LSP 响应桩；typeck_lsp_io 见 src/lsp/typeck_lsp_io_stub.c。
# strict 链：ast.sx 裸名 → pipeline_glue ast_ast_*（typeck_strict_link_partial 去重后缺 ast_block_if_*）。
ensure_ast_asm_bare_link_alias_obj() {
  local ALIAS_O="$BUILD_DIR/ast_asm_bare_link_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ ast_asm_bare_link_alias.c -nt "$ALIAS_O" ]; then
    echo "relink_shux_asm_strict_glue: cc ast_asm_bare_link_alias.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -I"$BUILD_DIR" -c -o "$ALIAS_O" ast_asm_bare_link_alias.c
  fi
}

ensure_asm_shux_lsp_diag_stub_obj() {
  local STUB_C="scripts/asm_shux_lsp_diag_stub.c"
  local STUB_O="$BUILD_DIR/asm_shux_lsp_diag_stub.o"
  local LSP_IO_STUB="src/lsp/typeck_lsp_io_stub.c"
  local LSP_IO_O="$BUILD_DIR/typeck_lsp_io_stub.o"
  if [ ! -f "$LSP_IO_O" ] || [ "$LSP_IO_STUB" -nt "$LSP_IO_O" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $LSP_IO_O <- $LSP_IO_STUB"
    "$CC" $CFLAGS -c -o "$LSP_IO_O" "$LSP_IO_STUB"
  fi
  if [ ! -f "$STUB_O" ] || [ "$STUB_C" -nt "$STUB_O" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $STUB_O <- $STUB_C"
    "$CC" $CFLAGS -c -o "$STUB_O" "$STUB_C"
  fi
}

# E-02：默认 seed 链 lsp_diag_stubs_no_c.o（与 build_shux_asm.sh 一致）。
lsp_diag_seed_obj_path() {
  local seed_dir="$1"
  if [ "${SHUX_LEGACY_LSP_DIAG_C:-0}" = "1" ]; then
    echo "$seed_dir/lsp_diag.o"
  else
    echo "$seed_dir/lsp_diag_stubs_no_c.o"
  fi
}

ensure_lsp_diag_seed_obj() {
  local seed_dir="$1"
  if [ "${SHUX_LEGACY_LSP_DIAG_C:-0}" = "1" ]; then
    if [ ! -f "$seed_dir/lsp_diag.o" ] || [ "src/lsp/lsp_diag.c" -nt "$seed_dir/lsp_diag.o" ]; then
      echo "  cc -c $seed_dir/lsp_diag.o <- lsp_diag.c (LEGACY)"
      "$CC" $CFLAGS -c -o "$seed_dir/lsp_diag.o" src/lsp/lsp_diag.c
    fi
  else
    if [ ! -f "$seed_dir/lsp_diag_stubs_no_c.o" ] || [ "src/lsp/lsp_diag_stubs_no_c.c" -nt "$seed_dir/lsp_diag_stubs_no_c.o" ]; then
      echo "  cc -c $seed_dir/lsp_diag_stubs_no_c.o (E-02 soft-retire lsp_diag.c)"
      "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$seed_dir/lsp_diag_stubs_no_c.o" src/lsp/lsp_diag_stubs_no_c.c
    fi
  fi
}

# strict 链：自 build_asm/pipeline.o 导出除 impl/parse/typecheck 外符号，避免与 orchestration partial 重复。
ensure_pipeline_o_strict_link_partial_obj() {
  local PARTIAL SYMS PO WPO_E
  PARTIAL="$BUILD_DIR/pipeline_strict_link_partial.o"
  SYMS="$BUILD_DIR/pipeline_strict_link_export.txt"
  PO="$BUILD_DIR/pipeline.o"
  WPO_E="$BUILD_DIR/pipeline_wpo.o"
  if [ ! -f "$PO" ] || [ ! -s "$PO" ]; then
    return 1
  fi
  # SX 编排：partial 不得再 export C 版 run_sx_pipeline_*（runtime bootstrap 提供 pipeline_run_sx_pipeline_impl）。
  pipeline_strict_link_export_syms_stale() {
    local syms="$1"
    local po="$2"
    [ -f "$syms" ] || return 0
    if asm_strict_sx_orchestration_ok 2>/dev/null; then
      grep -qxF 'run_sx_pipeline_impl' "$syms" 2>/dev/null && return 0
      grep -qxF 'run_sx_pipeline_parse_entry_do_parse' "$syms" 2>/dev/null && return 0
    fi
    local n_po n_sym
    n_po=$(nm "$po" 2>/dev/null | awk '/ T / {c++} END{print c+0}')
    n_sym=$(wc -l <"$syms" | tr -d ' ')
    if [ "${n_po:-0}" -gt 80 ] 2>/dev/null && [ "${n_sym:-0}" -lt 40 ] 2>/dev/null; then
      grep -qxF 'run_sx_pipeline_impl' "$syms" 2>/dev/null && return 0
    fi
    return 1
  }
  if pipeline_strict_link_export_syms_stale "$SYMS" "$PO"; then
    rm -f "$PARTIAL" "$SYMS"
  fi
  rebuild_pipeline_o_wpo_strict_helpers_if_needed || true
  if [ ! -f "$SYMS" ] || [ "$PO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; }; then
    nm "$PO" 2>/dev/null | awk '/ T / {print $3}' | grep -vE \
      'run_sx_pipeline_(impl|parse_entry_do_parse|parse_entry_if_needed|typecheck_entry)$|^(parse_into_with_init_buf|parse_into_with_init|pipeline_run_sx_pipeline_impl)$' \
      >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && asm_pipeline_wpo_strict_reach_ok; then
      if asm_pipeline_wpo_strict_link_full_ok; then
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_export_syms.txt"
        echo "  pipeline_strict_link: minus full pipeline_wpo exports ($(wc -l <"$BUILD_DIR/.pipeline_wpo_export_syms.txt" | tr -d ' ') syms)"
      elif [ -f "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" ] && [ -s "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" ]; then
        cp -f "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" "$BUILD_DIR/.pipeline_wpo_export_syms.txt"
      elif [ -f "$WPO_E" ]; then
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_export_syms.txt"
      fi
      if [ -s "$BUILD_DIR/.pipeline_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.pipeline_wpo_export_syms.txt" -o "$BUILD_DIR/.pipeline_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.pipeline_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  pipeline_strict_link: minus pipeline_wpo exports ($(wc -l <"$BUILD_DIR/.pipeline_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
    fi
    echo "  nm pipeline.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols, minus parse/typecheck/impl entry)"
  fi
  if [ ! -s "$SYMS" ]; then
    echo "  pipeline_strict_link: 0 symbols after WPO subtract — cannot build partial" >&2
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$PO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; } || \
     [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO" || return 1
  fi
  if [ -f "$PARTIAL" ] && [ -f "$BUILD_DIR/pipeline_wpo_helpers_partial.o" ] && \
     comm -12 <(nm "$PARTIAL" 2>/dev/null | awk '/ T / {print $3}' | sort -u) \
              <(nm "$BUILD_DIR/pipeline_wpo_helpers_partial.o" 2>/dev/null | awk '/ T / {print $3}' | sort -u) | grep -q .; then
    echo "  pipeline_strict_link: stale partial overlaps wpo helpers — rebuild once" >&2
    rm -f "$PARTIAL"
    echo "  ld partial export $SYMS pipeline.o -> $PARTIAL (retry)"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO" || return 1
  fi
  return 0
}

# pipeline_wpo.o 编排链 reach：run_sx_pipeline_impl 直接 callee 须已定义（与 build_shux_asm.sh 一致）。
asm_pipeline_wpo_strict_reach_ok() {
  local po="$BUILD_DIR/pipeline_wpo.o"
  [ -f "$po" ] || return 1
  nm "$po" 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_typecheck_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_parse_entry_if_needed$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_deps$' && return 1
  return 0
}

# track-only：链整颗 pipeline_wpo.o（SX 编排）；默认 helpers + C orchestration。
asm_pipeline_wpo_strict_link_full_ok() {
  [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL:-0}" = "1" ] || return 1
  asm_pipeline_wpo_strict_reach_ok || return 1
  return 0
}

# build_asm pipeline.o 第二遍：path/resolve/load + run_sx_pipeline_impl 均 SX 真 emit（阈值 6144B）。
asm_strict_pipeline_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
  [ "$t" -ge 6144 ] 2>/dev/null || return 1
  nm -g "$BUILD_DIR/pipeline.o" 2>/dev/null | grep -qE '(_)?path_append_from_buf_256|(_)?resolve_path_.*su' || return 1
  nm -g "$BUILD_DIR/pipeline.o" 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  return 0
}

# SX 编排（build_asm pipeline.o）替代 C orchestration alias；用户 .sx 编译与 experimental 对齐。
asm_strict_sx_orchestration_ok() {
  [ "${SHUX_ASM_STRICT_C_ORCHESTRATION:-0}" = "1" ] && return 1
  [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ] || return 1
  asm_strict_pipeline_selfhosted || return 1
  return 0
}

# 自举 typeck + SX 编排：glue 走 pipeline_sx partial + glue_strict_minimal（勿 glue_standalone 双 astpool）。
asm_strict_typeck_sx_glue_via_pipeline_sx() {
  asm_strict_typeck_selfhosted || return 1
  asm_strict_sx_orchestration_ok || return 1
  return 0
}

# ast_pool.c / PIPELINE_SX_DEPS 变更后须重建 pipeline_sx.o（与 build_shux_asm.sh 一致）。
ensure_pipeline_sx_o_fresh() {
  local need=0
  if [ ! -f pipeline_sx.o ] || [ ! -f pipeline_gen.c ]; then
    need=1
  fi
  if [ "$need" -eq 0 ] && [ "ast_pool.c" -nt "pipeline_sx.o" ]; then
    need=1
  fi
  for dep in \
    src/pipeline/pipeline.sx src/codegen/codegen.sx src/typeck/typeck.sx src/parser/parser.sx \
    src/ast/ast.sx src/lexer/lexer.sx src/preprocess/preprocess.sx src/asm/asm.sx \
    src/asm/backend.sx src/asm/platform/elf.sx src/asm/arch/arm64.sx src/asm/arch/arm64_enc.sx; do
    if [ -f "$dep" ] && [ "$dep" -nt "pipeline_sx.o" ]; then
      need=1
      break
    fi
  done
  if [ "$need" -eq 1 ]; then
    echo "relink_shux_asm_strict_glue: rebuild pipeline_sx.o (PIPELINE_SX_DEPS / ast_pool newer) ..."
    make bootstrap-pipeline pipeline_sx.o
  fi
  if [ -f pipeline_sx.o ]; then
    mkdir -p "$BUILD_DIR/gen_driver"
    cp -f pipeline_sx.o "$BUILD_DIR/gen_driver/pipeline_sx.o"
  fi
}

# strict 回退：从 pipeline_sx.o 部分链接 pipeline_run_sx_pipeline_impl（与 experimental SX 编排一致）。
ensure_pipeline_runtime_bootstrap_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
  SYMS="$BUILD_DIR/pipeline_runtime_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    echo "relink_shux_asm_strict_glue: missing $SUO (run build_shux_asm once)" >&2
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' '_pipeline_run_sx_pipeline_impl' > "$SYMS"
    echo "  ld partial export $SYMS pipeline_sx.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO"
  fi
}

# strict SX 编排：从 pipeline_sx.o 导出 glue/astpool 桥接；替代 glue_standalone 避免双 astpool SIGSEGV。
ensure_pipeline_sx_glue_support_partial_obj() {
  local PARTIAL SYMS SUO TCK_SYMS
  PARTIAL="$BUILD_DIR/pipeline_sx_glue_support_partial.o"
  SYMS="$BUILD_DIR/pipeline_sx_glue_support_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  TCK_SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    echo "relink_shux_asm_strict_glue: missing $SUO (run build_shux_asm once)" >&2
    return 1
  fi
  if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -f typeck_sx.o ]; then
    nm typeck_sx.o 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.typeck_sx_all_t.txt"
    TCK_SYMS="$BUILD_DIR/.typeck_sx_all_t.txt"
  else
    ensure_typeck_o_strict_link_partial_obj || true
    TCK_SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  fi
  if [ ! -f "$SYMS" ] || [ "$SUO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$TCK_SYMS" ] && [ "$TCK_SYMS" -nt "$SYMS" ]; } || \
     { [ -f "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" ] && [ "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" -nt "$SYMS" ]; }; then
    ensure_pipeline_glue_standalone_export_syms_txt || return 1
    nm "$SUO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_sx_all_t.txt"
    comm -12 "$BUILD_DIR/.pipeline_sx_all_t.txt" "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" \
      >"$BUILD_DIR/.pipeline_sx_glue_common.txt" 2>/dev/null || return 1
    : >"$SYMS"
    while IFS= read -r sym || [ -n "$sym" ]; do
      [ -z "$sym" ] && continue
      case "$sym" in
        pipeline_run_sx_pipeline_impl|run_sx_pipeline_impl)
          continue
          ;;
        typeck_sx_ast|typeck_sx_ast_library|check_block|check_expr|check_block_*|check_expr_*|typeck_check_*)
          continue
          ;;
      esac
      if [ -f "$TCK_SYMS" ] && grep -qxF "$sym" "$TCK_SYMS" 2>/dev/null; then
        continue
      fi
      PIPE_SYMS="$BUILD_DIR/pipeline_strict_link_export.txt"
      if [ -f "$PIPE_SYMS" ] && grep -qxF "$sym" "$PIPE_SYMS" 2>/dev/null; then
        continue
      fi
      printf '%s\n' "$sym" >>"$SYMS"
    done <"$BUILD_DIR/.pipeline_sx_glue_common.txt"
    sort -u "$SYMS" -o "$SYMS"
    for sym in pipeline_load_and_sync_direct_import_deps pipeline_run_sx_pipeline_fill_dep_import_path; do
      grep -qxF "$sym" "$SYMS" 2>/dev/null || printf '%s\n' "$sym" >>"$SYMS"
    done
    echo "relink_shux_asm_strict_glue: pipeline_sx glue support: $(wc -l <"$SYMS" | tr -d ' ') syms"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline_sx.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO" || return 1
  fi
  return 0
}

ensure_asm_pipeline_run_impl_alias_obj() {
  local ALIAS_OBJ="$BUILD_DIR/pipeline_run_impl_alias.o"
  local ALIAS_CFLAGS="$CFLAGS"
  if asm_strict_sx_orchestration_ok; then
    ALIAS_CFLAGS="$CFLAGS -DSHUX_PIPELINE_RUN_IMPL_ALIAS_PARSE_ALIASES=0"
  fi
  if [ ! -f "$ALIAS_OBJ" ] || [ "src/asm/pipeline_run_impl_alias.c" -nt "$ALIAS_OBJ" ] || \
     [ ! -f "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" ] || \
     { asm_strict_sx_orchestration_ok && [ "$(cat "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" 2>/dev/null)" != "1" ]; } || \
     { ! asm_strict_sx_orchestration_ok && [ "$(cat "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" 2>/dev/null)" = "1" ]; }; then
    echo "  cc -c src/asm/pipeline_run_impl_alias.c -> $ALIAS_OBJ (SX orch=$(asm_strict_sx_orchestration_ok && echo 1 || echo 0))"
    "$CC" $ALIAS_CFLAGS -c -o "$ALIAS_OBJ" src/asm/pipeline_run_impl_alias.c
    if asm_strict_sx_orchestration_ok; then echo "1" >"$BUILD_DIR/.pipeline_run_impl_alias_sx_orch"; else echo "0" >"$BUILD_DIR/.pipeline_run_impl_alias_sx_orch"; fi
  fi
}

# WPO helpers 导出排除表：mega entry + check_* 须由 typeck.o 全量提供（WPO 版内联压缩 check_block 会 SIGSEGV）。
typeck_wpo_helpers_export_exclude_re() {
  echo '^(check_block|check_expr|typeck_sx_ast|typeck_sx_ast_library)$'
}

# strict WPO：从 typeck_wpo.o 仅导出 layout/unify helper；entry/check_* 仍由 typeck.o 全量提供。
ensure_typeck_wpo_helpers_partial_obj() {
  local PARTIAL SYMS WPO_E EXCLUDE_RE
  PARTIAL="$BUILD_DIR/typeck_wpo_helpers_partial.o"
  SYMS="$BUILD_DIR/typeck_wpo_helpers_export.txt"
  WPO_E="$BUILD_DIR/typeck_wpo.o"
  EXCLUDE_RE=$(typeck_wpo_helpers_export_exclude_re)
  if [ ! -f "$WPO_E" ] || [ ! -s "$WPO_E" ]; then
    return 1
  fi
  if ! asm_typeck_wpo_strict_reach_ok; then
    return 1
  fi
  if [ -f "$PARTIAL" ]; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' && rm -f "$PARTIAL" "$SYMS"
  fi
  if [ ! -f "$SYMS" ] || [ "$WPO_E" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ]; then
    nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE "$EXCLUDE_RE" >"$SYMS"
    echo "  nm typeck_wpo.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') layout syms, minus check_block/check_expr/typeck_sx_ast*)"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$WPO_E" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS typeck_wpo.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$WPO_E" || return 1
    nm "$PARTIAL" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt"
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' && {
      echo "relink_shux_asm_strict_glue: typeck_wpo_helpers_partial must not export typeck_sx_ast" >&2
      return 1
    }
  fi
  return 0
}

# WPO strict partial 导出表是否过期：旧缓存曾误删 check_block callee 或误含 WPO typeck_sx_ast。
typeck_wpo_strict_partial_export_syms_stale() {
  local syms="$1"
  [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] || return 1
  asm_typeck_wpo_strict_reach_ok || return 1
  [ -f "$syms" ] || return 0
  grep -qxF 'typeck_check_block_one_while' "$syms" 2>/dev/null || return 0
  grep -qxF 'check_block_as_loop_body' "$syms" 2>/dev/null || return 0
  grep -qxF 'typeck_sx_ast' "$syms" 2>/dev/null && return 0
  if [ -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ] && \
     grep -qxF 'typeck_sx_ast' "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" 2>/dev/null; then
    return 0
  fi
  return 1
}

# pipeline_glue_standalone.o 全局 T 导出表：与 build_asm/typeck.o 并列链时会 duplicate ast_pool/glue → fill_cl SIGSEGV。
ensure_pipeline_glue_standalone_export_syms_txt() {
  local GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
  local OUT="$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt"
  [ -f "$GLUE_O" ] || return 1
  if [ ! -f "$OUT" ] || [ "$GLUE_O" -nt "$OUT" ] || [ "pipeline_glue.c" -nt "$OUT" ]; then
    nm "$GLUE_O" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$OUT"
  fi
  [ -s "$OUT" ] || return 1
  return 0
}

# strict 链：自 build_asm/typeck.o 导出除 WPO 已定义外符号。
ensure_typeck_o_strict_link_partial_obj() {
  local PARTIAL SYMS TCKO WPO_E GLUE_O
  PARTIAL="$BUILD_DIR/typeck_strict_link_partial.o"
  SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  TCKO="$BUILD_DIR/typeck.o"
  WPO_E="$BUILD_DIR/typeck_wpo.o"
  GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
  if [ ! -f "$TCKO" ] || [ ! -s "$TCKO" ]; then
    return 1
  fi
  if typeck_wpo_strict_partial_export_syms_stale "$SYMS"; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || rm -f "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$PARTIAL" ]; then
    rm -f "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$TCKO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; } || \
     { [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$SYMS" ]; }; then
    nm "$TCKO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_typeck_wpo_strict_reach_ok && asm_typeck_wpo_strict_link_helpers_ok; then
      if [ -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ] && [ -s "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ]; then
        cp -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" "$BUILD_DIR/.typeck_wpo_export_syms.txt"
      else
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE "$(typeck_wpo_helpers_export_exclude_re)" | sort -u >"$BUILD_DIR/.typeck_wpo_export_syms.txt"
      fi
      if [ -s "$BUILD_DIR/.typeck_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.typeck_wpo_export_syms.txt" -o "$BUILD_DIR/.typeck_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.typeck_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  typeck_strict_link: minus typeck_wpo layout exports ($(wc -l <"$BUILD_DIR/.typeck_wpo_export_syms.txt" | tr -d ' ') syms, keep check_block/typeck_sx_ast from typeck.o)"
      fi
    fi
    if ensure_pipeline_glue_standalone_export_syms_txt; then
      sort -u "$SYMS" -o "$SYMS"
      comm -12 "$SYMS" "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" >"$BUILD_DIR/.typeck_glue_dup_syms.txt" 2>/dev/null || true
      if [ -s "$BUILD_DIR/.typeck_glue_dup_syms.txt" ]; then
        comm -23 "$SYMS" "$BUILD_DIR/.typeck_glue_dup_syms.txt" >"$SYMS.glue" 2>/dev/null && mv -f "$SYMS.glue" "$SYMS"
        echo "  typeck_strict_link: minus typeck∩glue duplicate exports ($(wc -l <"$BUILD_DIR/.typeck_glue_dup_syms.txt" | tr -d ' ') syms, glue_standalone owns ast_pool)"
      fi
    fi
    echo "  nm typeck.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$TCKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; } || \
     { [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$PARTIAL" ]; }; then
    echo "  ld partial export $SYMS typeck.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$TCKO" || return 1
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || {
        echo "relink_shux_asm_strict_glue: typeck_strict_link_partial missing typeck_check_block_one_while" >&2
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?check_block_as_loop_body$' || {
        echo "relink_shux_asm_strict_glue: typeck_strict_link_partial missing check_block_as_loop_body" >&2
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?check_block$' || {
        echo "relink_shux_asm_strict_glue: typeck_strict_link_partial missing check_block" >&2
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' || {
        echo "relink_shux_asm_strict_glue: typeck_strict_link_partial missing typeck_sx_ast" >&2
        return 1
      }
    fi
  fi
  return 0
}

# typeck_wpo.o WPO reach：typeck_sx_ast / check_block / check_expr 须在 TU 内定义。
asm_typeck_wpo_strict_reach_ok() {
  local to="$BUILD_DIR/typeck_wpo.o"
  [ -f "$to" ] || return 1
  nm "$to" 2>/dev/null | grep -qE '(_)?typeck_sx_ast' || return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?typeck_sx_ast$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_block$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_expr$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_block' || return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_expr' || return 1
  return 0
}

# typeck_wpo helpers partial 仅于 typeck.o 未自举时链入；自举后 wpo partial 会带入内联 check_block 局部符号。
asm_typeck_wpo_strict_link_helpers_ok() {
  [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] || return 1
  asm_typeck_wpo_strict_reach_ok || return 1
  asm_strict_typeck_selfhosted && return 1
  return 0
}

# backend_wpo.o WPO reach：asm_codegen_ast / emit_expr_elf / emit_block_body_elf 须在 TU 内定义。
asm_backend_wpo_strict_reach_ok() {
  local bo="$BUILD_DIR/backend_wpo.o"
  [ -f "$bo" ] || return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?asm_codegen_ast$' || return 1
  nm "$bo" 2>/dev/null | grep -qE ' U (_)?asm_codegen_ast$' && return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?emit_expr_elf' || return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?emit_block_body_elf' || return 1
  return 0
}

asm_strict_backend_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
  [ "$t" -gt 1024 ] 2>/dev/null
}

ensure_backend_asm_bare_link_alias_obj() {
  local ALIAS_O="$BUILD_DIR/backend_asm_bare_link_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ backend_asm_bare_link_alias.c -nt "$ALIAS_O" ]; then
    echo "  cc -c backend_asm_bare_link_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$ALIAS_O" backend_asm_bare_link_alias.c
  fi
}

ensure_asm_backend_seed_helper_partial_obj() {
  local PARTIAL SYMS SEED EXCLUDE
  PARTIAL="$BUILD_DIR/asm_backend_seed_helper_partial.o"
  SYMS="$BUILD_DIR/asm_backend_seed_helper_export.txt"
  EXCLUDE="$BUILD_DIR/asm_backend_seed_helper_exclude.txt"
  SEED="$BUILD_DIR/seed_host/asm_backend_partial.o"
  if [ ! -f "$SEED" ] || [ ! -s "$SEED" ]; then
    return 1
  fi
  if [ ! -f "$SYMS" ] || [ "$SEED" -nt "$SYMS" ] || [ ! -f "$EXCLUDE" ] || [ "$EXCLUDE" -nt "$SYMS" ]; then
    cat >"$EXCLUDE" <<'EOF'
backend_asm_codegen_ast
backend_asm_codegen_ast_to_elf
backend_emit_expr_elf
backend_emit_block_body_elf
EOF
    nm "$SEED" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS.all"
    sort -u "$EXCLUDE" -o "$EXCLUDE"
    comm -23 "$SYMS.all" "$EXCLUDE" >"$SYMS"
    rm -f "$SYMS.all"
    echo "  seed helper export: $(wc -l <"$SYMS" | tr -d ' ') symbols (seed minus wpo thin entry)" >&2
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SEED" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS seed asm_backend_partial.o -> $PARTIAL" >&2
    ld_partial_export "$SYMS" "$PARTIAL" "$SEED" || return 1
  fi
  return 0
}

backend_wpo_strict_partial_export_syms_stale() {
  local syms="$1"
  [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] || return 1
  asm_backend_wpo_strict_reach_ok || return 1
  [ -f "$syms" ] || return 0
  grep -qxF 'arch_emit_add_imm_to_rax' "$syms" 2>/dev/null || return 0
  grep -qxF 'asm_codegen_ast_seed_mega' "$syms" 2>/dev/null && return 0
  return 1
}

ensure_backend_o_strict_link_partial_obj() {
  local PARTIAL SYMS BACKO WPO_E
  PARTIAL="$BUILD_DIR/backend_strict_link_partial.o"
  SYMS="$BUILD_DIR/backend_strict_link_export.txt"
  BACKO="$BUILD_DIR/backend.o"
  WPO_E="$BUILD_DIR/backend_wpo.o"
  if [ ! -f "$BACKO" ] || [ ! -s "$BACKO" ]; then
    return 1
  fi
  if backend_wpo_strict_partial_export_syms_stale "$SYMS"; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?arch_emit_add_imm_to_rax$' || rm -f "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$BACKO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; }; then
    nm "$BACKO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_backend_wpo_strict_reach_ok; then
      nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.backend_wpo_export_syms.txt"
      if [ -s "$BUILD_DIR/.backend_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.backend_wpo_export_syms.txt" -o "$BUILD_DIR/.backend_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.backend_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  backend_strict_link: minus backend_wpo.o exports ($(wc -l <"$BUILD_DIR/.backend_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
      grep -vxF 'asm_codegen_ast_seed_mega' "$SYMS" >"$SYMS.nmega" 2>/dev/null && mv -f "$SYMS.nmega" "$SYMS"
      grep -vxF 'asm_codegen_ast_to_elf_seed_mega' "$SYMS" >"$SYMS.nmega2" 2>/dev/null && mv -f "$SYMS.nmega2" "$SYMS"
    fi
    echo "  nm backend.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$BACKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; }; then
    echo "  ld partial export $SYMS backend.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$BACKO" || return 1
    if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?arch_emit_add_imm_to_rax$' || {
        echo "relink_shux_asm_strict_glue: backend_strict_link_partial missing arch_emit_add_imm_to_rax" >&2
        return 1
      }
    fi
  fi
  return 0
}

ensure_asm_backend_compat_stubs_obj() {
  local STUB_O="$BUILD_DIR/asm_backend_compat_stubs.o"
  if [ ! -f "$STUB_O" ] || [ src/asm/asm_backend_compat_stubs.c -nt "$STUB_O" ]; then
    echo "  cc -c src/asm/asm_backend_compat_stubs.c -> $STUB_O"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$STUB_O" src/asm/asm_backend_compat_stubs.c
  fi
}

# 与 build_shux_asm.sh 一致：pipeline_glue_standalone 引用 simd_enc / simd_loop / target_cpu。
ensure_simd_glue_link_objs() {
  if [ ! -f src/asm/pipeline_abi_f32_xmm.o ] || [ src/asm/pipeline_abi_f32_xmm.c -nt src/asm/pipeline_abi_f32_xmm.o ]; then
    echo "  cc -c src/asm/pipeline_abi_f32_xmm.c -> src/asm/pipeline_abi_f32_xmm.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/pipeline_abi_f32_xmm.o src/asm/pipeline_abi_f32_xmm.c
  fi
  if [ ! -f src/driver/target_cpu.o ] || [ src/driver/target_cpu.c -nt src/driver/target_cpu.o ]; then
    echo "  cc -c src/driver/target_cpu.c -> src/driver/target_cpu.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/target_cpu.o src/driver/target_cpu.c
  fi
  if [ ! -f src/asm/simd_enc.o ] || [ src/asm/simd_enc.c -nt src/asm/simd_enc.o ]; then
    echo "  cc -c src/asm/simd_enc.c -> src/asm/simd_enc.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_enc.o src/asm/simd_enc.c
  fi
  if [ ! -f src/asm/simd_loop.o ] || [ src/asm/simd_loop.c -nt src/asm/simd_loop.o ]; then
    echo "  cc -c src/asm/simd_loop.c -> src/asm/simd_loop.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_loop.o src/asm/simd_loop.c
  fi
}

strict_asm_backend_companion_objs() {
  if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
    ensure_backend_asm_bare_link_alias_obj >&2 || return 1
    ensure_asm_backend_seed_helper_partial_obj >&2 || return 1
    printf '%s\n' "$BUILD_DIR/backend_wpo.o $BUILD_DIR/backend_asm_bare_link_alias.o $BUILD_DIR/asm_backend_seed_helper_partial.o"
    return 0
  fi
  printf '%s\n' "$BUILD_DIR/seed_host/asm_backend_partial.o"
  return 0
}

# Linux reach OK 时默认链 pipeline_wpo FULL；显式 SHUX_ASM_STRICT_LINK_PIPELINE_WPO=0 关闭。
maybe_default_pipeline_wpo_strict_link() {
  if [ -n "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO+x}" ]; then
    return 0
  fi
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64|Linux-aarch64|Linux-arm64)
      if asm_pipeline_wpo_strict_reach_ok; then
        export SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1
        if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL:-1}" = "0" ]; then
          export SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
          echo "relink_shux_asm_strict_glue: default SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1 (helpers)"
        else
          export SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=1
          echo "relink_shux_asm_strict_glue: default SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1 + FULL=1"
        fi
      fi
      ;;
  esac
}

# 默认 C orchestration；SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1 且 reach OK 才链 pipeline_wpo helpers。
maybe_default_pipeline_wpo_strict_link
if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && [ "${STRICT_LINK_BUILD_ASM_WPO:-}" != "0" ] && asm_pipeline_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_WPO=1
  echo "relink_shux_asm_strict_glue: STRICT_LINK_BUILD_ASM_WPO=1 (pipeline_wpo.o opt-in)"
else
  export STRICT_LINK_BUILD_ASM_WPO=0
fi
if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-}" != "0" ] && asm_typeck_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
  echo "relink_shux_asm_strict_glue: STRICT_LINK_BUILD_ASM_TYPECK_WPO=1 (typeck_wpo reach OK; helpers only if typeck.o not selfhosted)"
else
  export STRICT_LINK_BUILD_ASM_TYPECK_WPO=0
fi
if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-}" != "0" ] && asm_backend_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  echo "relink_shux_asm_strict_glue: STRICT_LINK_BUILD_ASM_BACKEND_WPO=1 (backend_wpo.o reach OK)"
fi

# WPO strict 链：pipeline_wpo.o 依赖 resolve_path_* 等 helper；CI 跳过 pipeline second pass 时 build_asm/pipeline.o 与 wpo 符号重叠、partial 为空。
rebuild_pipeline_o_wpo_strict_helpers_if_needed() {
  local po="$BUILD_DIR/pipeline.o"
  local comp tmp pt
  [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] || return 0
  asm_pipeline_wpo_strict_reach_ok || return 0
  [ -f "$po" ] || return 1
  if nm "$po" 2>/dev/null | grep -qE ' T (_)?resolve_path_try_one_lib_root$'; then
    return 0
  fi
  tmp="$BUILD_DIR/pipeline.wpo_strict_helpers.o"
  for comp in ./shux_asm.experimental ./shux_asm ./shux ./shux-sx; do
    [ -x "$comp" ] || continue
    echo "relink_shux_asm_strict_glue: rebuild pipeline.o EMIT_HEAVY for WPO helpers via $comp ..."
    ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
    rm -f "$tmp" 2>/dev/null || true
    if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      "$comp" -backend asm -o "$tmp" -L asm_libroot -L .. -L src \
      src/pipeline/pipeline.sx 2>/dev/null; then
      pt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
      if [ "$pt" -gt 512 ] 2>/dev/null \
        && nm "$tmp" 2>/dev/null | grep -qE ' T (_)?resolve_path_try_one_lib_root$'; then
        mv -f "$tmp" "$po"
        rm -f "$BUILD_DIR/pipeline_strict_link_partial.o" "$BUILD_DIR/pipeline_strict_link_export.txt" 2>/dev/null || true
        echo "relink_shux_asm_strict_glue: pipeline.o WPO helpers OK (__text=${pt}B)"
        return 0
      fi
    fi
    rm -f "$tmp" 2>/dev/null || true
  done
  echo "relink_shux_asm_strict_glue: warn: pipeline.o WPO helper rebuild failed" >&2
  return 1
}

# S5 WPO strict 链：pipeline_wpo.o + glue 入口/typecheck emit 别名（替代 C orchestration partial）。
ensure_pipeline_wpo_strict_link_alias_obj() {
  local ALIAS_O="$BUILD_DIR/pipeline_wpo_strict_link_alias.o"
  local ALIAS_SRC="src/asm/pipeline_wpo_strict_link_alias.c"
  if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -ne 1 ] || ! asm_pipeline_wpo_strict_reach_ok; then
    return 0
  fi
  if [ ! -f "$ALIAS_SRC" ]; then
    return 1
  fi
  if [ ! -f "$ALIAS_O" ] || [ "$ALIAS_SRC" -nt "$ALIAS_O" ]; then
    echo "  cc -c $ALIAS_SRC -> $ALIAS_O (WPO strict link alias)"
    "$CC" $CFLAGS -c -o "$ALIAS_O" "$ALIAS_SRC" || return 1
  fi
  return 0
}

# 重编 pipeline_glue_standalone.o（含 ast_pool.c EMIT_HEAVY 修复）
detect_gen() {
  PIPELINE_GEN_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  case "$(uname -s)" in
    Darwin) PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers" ;;
  esac
}
detect_gen
GLUE_TYPES="$BUILD_DIR/pipeline_glue_types.inc"
if [ ! -f "$GLUE_TYPES" ]; then
  echo "relink_shux_asm_strict_glue: missing $GLUE_TYPES (run build_shux_asm once)" >&2
  exit 1
fi
PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
PARSER_ASM_LINK_ALIAS_CFLAGS="-DPARSER_ASM_LINK_ALIAS_SKIP_SX_SYMBOLS"
PARSER_ASM_THIN_C="parser_asm_thin_glue.o"
if [ ! -f "$PARSER_ASM_THIN_C" ] || [ "src/asm/parser_asm_thin_c.c" -nt "$PARSER_ASM_THIN_C" ]; then
  echo "relink_shux_asm_strict_glue: cc parser_asm_thin_glue.o (parse_peek / skip_balanced thin C)"
  "$CC" $CFLAGS $PARSER_ASM_THIN_GLUE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -c -o "$PARSER_ASM_THIN_C" src/asm/parser_asm_thin_c.c
fi
if [ ! -f "$BUILD_DIR/pipeline_glue_strict_minimal.o" ] || [ "src/asm/pipeline_glue_strict_minimal.c" -nt "$BUILD_DIR/pipeline_glue_strict_minimal.o" ]; then
  echo "relink_shux_asm_strict_glue: cc pipeline_glue_strict_minimal.o"
  "$CC" $CFLAGS -c -o "$BUILD_DIR/pipeline_glue_strict_minimal.o" src/asm/pipeline_glue_strict_minimal.c
fi
if asm_strict_typeck_sx_glue_via_pipeline_sx; then
  ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
  echo "relink_shux_asm_strict_glue: ST_GLUE glue_strict_minimal + pipeline_sx glue support (SX orch)"
else
  echo "relink_shux_asm_strict_glue: cc pipeline_glue_standalone.o <- ast_pool.c"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I"$BUILD_DIR" -c -o "$BUILD_DIR/pipeline_glue_standalone.o" src/asm/pipeline_glue_standalone.c
  ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
fi

# 收集非空 build_asm/*.o 并经 filter_strict_asm_objs 筛选（与 build_shux_asm strict 链一致）。
build_nonempty_asm_objs() {
  NONEMPTY_ASM=""
  for o in "$BUILD_DIR"/*.o; do
    [ -f "$o" ] || continue
    base=$(basename "$o")
    case "$base" in
      typeck_skip.o|typeck_heavy.o|typeck.second.o)
        continue
        ;;
    esac
    if [ -s "$o" ]; then
      NONEMPTY_ASM="$NONEMPTY_ASM $o"
    fi
  done
}

filter_strict_asm_objs() {
  FILTERED=""
  UNAME_HOST=$(uname -m 2>/dev/null || echo unknown)
  local LINK_BUILD_ASM_TYPECK=0
  local LINK_BUILD_ASM_PIPELINE=0
  if asm_strict_typeck_selfhosted; then
    LINK_BUILD_ASM_TYPECK=1
  fi
  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
    LINK_BUILD_ASM_PIPELINE=1
  fi
  for o in $NONEMPTY_ASM; do
    base=$(basename "$o")
    if [ "$base" = "pipeline.o" ]; then
      if [ "$LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
        if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && asm_pipeline_wpo_strict_reach_ok; then
          if asm_pipeline_wpo_strict_link_full_ok; then
            ensure_pipeline_wpo_strict_link_alias_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_strict_link_alias.o"
            FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo.o"
            # FULL 仍须 pipeline_sx glue support：ast_pool 桥接（typeck_sx 依赖 ast_ref_is_null 等）不在 pipeline_wpo.o 内。
            if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
              FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
              echo "relink_shux_asm_strict_glue: link pipeline_sx glue support (FULL wpo astpool bridge)"
            fi
            echo "relink_shux_asm_strict_glue: link whole pipeline_wpo.o (SX orchestration, FULL)"
          else
            if asm_strict_sx_orchestration_ok; then
              ensure_pipeline_runtime_bootstrap_partial_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
              if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
                echo "relink_shux_asm_strict_glue: link pipeline_sx glue support (replace glue_standalone astpool)"
              fi
              if ensure_pipeline_wpo_helpers_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_helpers_partial.o"
                echo "relink_shux_asm_strict_glue: link pipeline_wpo_helpers + pipeline_sx runtime bootstrap (opt-in WPO)"
              else
                echo "relink_shux_asm_strict_glue: pipeline_wpo_helpers partial failed — pipeline_sx runtime bootstrap only" >&2
              fi
              echo "su" >"$BUILD_DIR/.pipeline_strict_orch_mode"
            else
              ensure_pipeline_asm_orchestration_partial_obj
              FILTERED="$FILTERED $BUILD_DIR/pipeline_asm_orchestration_partial.o"
              if ensure_pipeline_wpo_helpers_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_helpers_partial.o"
                echo "relink_shux_asm_strict_glue: link pipeline_wpo_helpers + C orchestration (opt-in WPO)"
              fi
              echo "c" >"$BUILD_DIR/.pipeline_strict_orch_mode"
            fi
          fi
        else
          if asm_strict_sx_orchestration_ok; then
            ensure_pipeline_runtime_bootstrap_partial_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
            if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
              FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
              echo "relink_shux_asm_strict_glue: link pipeline_sx glue support (replace glue_standalone astpool)"
            fi
            echo "relink_shux_asm_strict_glue: link pipeline_sx runtime bootstrap orchestration"
            echo "su" >"$BUILD_DIR/.pipeline_strict_orch_mode"
          else
            ensure_pipeline_asm_orchestration_partial_obj
            FILTERED="$FILTERED $BUILD_DIR/pipeline_asm_orchestration_partial.o"
            echo "relink_shux_asm_strict_glue: link pipeline_asm_orchestration_partial.o (C run_sx_pipeline_impl)"
            echo "c" >"$BUILD_DIR/.pipeline_strict_orch_mode"
          fi
        fi
        if ensure_pipeline_o_strict_link_partial_obj; then
          FILTERED="$FILTERED $BUILD_DIR/pipeline_strict_link_partial.o"
        else
          FILTERED="$FILTERED $o"
        fi
      fi
      continue
    fi
    if [ "$base" = "parser.o" ]; then
      continue
    fi
    case "$base" in
      parser.o|backend.o|asm.o|main.o|lsp.o|std_fs.o|\
      codegen.o|pipeline_glue_link.o|pipeline_run_impl_alias.o|pipeline_glue_standalone.o|pipeline_glue_strict_minimal.o|\
      parser_bootstrap_partial.o|parser_from_sx_partial.o|parser_strict_merged.o|\
      pipeline_parse_sx_partial.o|pipeline_runtime_bootstrap_partial.o|pipeline_sx_glue_support_partial.o|\
      pipeline_asm_sx_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_strict_link_partial.o|pipeline_wpo.o|pipeline_wpo_helpers_partial.o|pipeline_wpo_typecheck_emit_bridge.o|pipeline_wpo_strict_link_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      pipeline_run_bootstrap_trampoline.o|pipeline_bootstrap_orchestration_strict.o|\
      typeck_skip.o|typeck_heavy.o|typeck.second.o|\
      typeck_asm_layout_partial.o|typeck_sx_no_layout_partial.o|typeck_c_orchestration_partial.o|\
      typeck_c_module_stubs.o|typeck_asm_bare_link_alias.o|typeck_wpo.o|typeck_wpo_helpers_partial.o|typeck_strict_link_partial.o|\
      typeck_lsp_io_stub.o|\
      backend_wpo.o|backend_strict_link_partial.o|backend_asm_bare_link_alias.o|asm_backend_seed_helper_partial.o|\
      asm_backend_compat_stubs.o|\
      std_fs_shim.o|sx_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shux_lsp_diag_stub.o|lsp_codegen_extern.o|\
      ast_pool_l5_bridge.o|\
      lexer.o|peephole.o|platform_elf.o|macho.o|coff.o|\
      parser_asm_link_alias.o|parser_asm_minimal_partial.o|parser_asm_thin_c.o|\
      driver_compile.o|driver_compile_asm_link_alias.o|driver_compile_emit_heavy.o|driver_compile_link.o)
      continue
      ;;
    esac
    if [ "$base" = "typeck.o" ]; then
      if [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
        if asm_typeck_wpo_strict_link_helpers_ok; then
          if ensure_typeck_wpo_helpers_partial_obj; then
            FILTERED="$FILTERED $BUILD_DIR/typeck_wpo_helpers_partial.o"
            echo "relink_shux_asm_strict_glue: link typeck_wpo_helpers + typeck.o partial"
          else
            FILTERED="$FILTERED $BUILD_DIR/typeck_wpo.o"
          fi
          ensure_typeck_o_strict_link_partial_obj && FILTERED="$FILTERED $BUILD_DIR/typeck_strict_link_partial.o"
        elif asm_strict_typeck_selfhosted; then
          if asm_strict_typeck_sx_glue_via_pipeline_sx; then
            echo "relink_shux_asm_strict_glue: skip build_asm/typeck.o (SX glue; seed typeck + typeck_sx.o tail)"
          elif ensure_typeck_o_strict_link_partial_obj; then
            FILTERED="$FILTERED $BUILD_DIR/typeck_strict_link_partial.o"
            echo "relink_shux_asm_strict_glue: link typeck.o partial (selfhosted, minus glue dupes)"
          else
            FILTERED="$FILTERED $o"
            echo "relink_shux_asm_strict_glue: link whole typeck.o (selfhosted partial failed)"
          fi
        else
          FILTERED="$FILTERED $o"
        fi
      fi
      continue
    fi
    if [ "$base" = "typeck_asm_layout_partial.o" ] && [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
      continue
    fi
    case "$UNAME_HOST" in
      arm64|aarch64)
        case "$base" in
          x86_64.o|x86_64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
      x86_64|amd64)
        case "$base" in
          arm64.o|arm64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
    esac
    FILTERED="$FILTERED $o"
  done
}

build_nonempty_asm_objs
filter_strict_asm_objs
ASM_TRY_OBJS="$FILTERED"

# build_asm/parser.o 仅导出 parser_sx/glue 缺的符号（勿链整颗 parser.o，会与 seed parser 重复）。
ensure_parser_asm_minimal_partial_obj() {
  local PARTIAL SYMS PO
  PARTIAL="$BUILD_DIR/parser_asm_minimal_partial.o"
  SYMS="$BUILD_DIR/parser_asm_minimal_export.txt"
  PO="$BUILD_DIR/parser.o"
  if [ ! -f "$PO" ] || [ ! -s "$PO" ]; then
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$PO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_parse_expr_into
_copy_module_import_path64
_parse_one_function_ok_for_pipeline
EOF
    echo "relink_shux_asm_strict_glue: ld -r parser_asm_minimal_partial.o <- parser.o (3 symbols)"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO" || return 1
  fi
  return 0
}

PARSER_ASM_PARTIAL=""
if ensure_parser_asm_minimal_partial_obj; then
  PARSER_ASM_PARTIAL="$BUILD_DIR/parser_asm_minimal_partial.o"
fi

PARSER_ALIAS_O="$BUILD_DIR/parser_asm_link_alias.o"
if [ ! -f "$PARSER_ALIAS_O" ] || [ "src/asm/parser_asm_link_alias.c" -nt "$PARSER_ALIAS_O" ]; then
  echo "relink_shux_asm_strict_glue: cc parser_asm_link_alias.o"
  "$CC" $CFLAGS $PARSER_ASM_LINK_ALIAS_CFLAGS -c -o "$PARSER_ALIAS_O" src/asm/parser_asm_link_alias.c
fi

ST_LAYOUT_PARTIAL=""
if [ -f "$BUILD_DIR/typeck_asm_layout_partial.o" ] && ! asm_strict_typeck_selfhosted; then
  ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o"
fi

ST_TYPECK_SX_LINK="typeck_sx.o"
if [ -f "$BUILD_DIR/typeck_sx_no_layout_partial.o" ] && ! asm_strict_typeck_selfhosted; then
  ST_TYPECK_SX_LINK="$BUILD_DIR/typeck_sx_no_layout_partial.o"
fi

ensure_async_cps_seed_objs
ST_ASYNC_CPS_SEED=$(asm_seed_st_async_support_link)
ST_PREPROCESS_SEED=$(asm_seed_st_preprocess_link)

# strict 自举链须 typeck_sx.o（与 experimental 一致；缺则 SX typeck 桥接不全）。
ensure_typeck_sx_o_for_strict_link() {
  if [ ! -f typeck_sx.o ] && command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
    echo "relink_shux_asm_strict_glue: make typeck_sx.o ..."
    make -s typeck_sx.o
  fi
  [ -f typeck_sx.o ] || return 1
  return 0
}
ensure_typeck_sx_o_for_strict_link || echo "relink_shux_asm_strict_glue: warn: missing typeck_sx.o" >&2

ST_TYPECK_C_STUBS=""
ST_TYPECK_BARE_ALIAS=""
if asm_strict_typeck_selfhosted; then
  ST_TYPECK_C_STUBS=$(ensure_typeck_c_user_precheck_obj)
  if asm_seed_omit_c_frontend_seed; then
    ensure_typeck_sx_o_for_strict_link || true
    ST_SEED_PARSER_TCK="$ST_ASYNC_CPS_SEED codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
    echo "relink_shux_asm_strict_glue: omit asm_driver_seed frontend C objs (SX companions ready)"
  elif asm_strict_typeck_sx_glue_via_pipeline_sx; then
    ensure_typeck_sx_o_for_strict_link || true
    ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $ST_ASYNC_CPS_SEED $SEED_O/lexer.o $SEED_O/ast_seed.o codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
    echo "relink_shux_asm_strict_glue: seed typeck + typeck_sx tail (SX glue; no build_asm typeck partial/bare_link)"
  else
    if [ ! -f "$BUILD_DIR/typeck_asm_bare_link_alias.o" ] || [ typeck_asm_bare_link_alias.c -nt "$BUILD_DIR/typeck_asm_bare_link_alias.o" ]; then
      echo "  cc -c typeck_asm_bare_link_alias.c -> $BUILD_DIR/typeck_asm_bare_link_alias.o"
      "$CC" $CFLAGS -c -o "$BUILD_DIR/typeck_asm_bare_link_alias.o" typeck_asm_bare_link_alias.c
    fi
    ST_TYPECK_BARE_ALIAS="$BUILD_DIR/typeck_asm_bare_link_alias.o"
    ST_SEED_PARSER_TCK="$ST_TYPECK_C_STUBS $ST_TYPECK_BARE_ALIAS $SEED_O/parser.o $SEED_O/codegen.o $ST_ASYNC_CPS_SEED $SEED_O/lexer.o $SEED_O/ast_seed.o codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
    if [ -f src/typeck/typeck_f64_bits.o ]; then
      ST_SEED_PARSER_TCK="$ST_SEED_PARSER_TCK src/typeck/typeck_f64_bits.o"
    fi
    echo "relink_shux_asm_strict_glue: typeck partial + bare_link_alias (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o")B)"
  fi
elif asm_seed_omit_c_frontend_seed; then
  ST_SEED_PARSER_TCK="$ST_ASYNC_CPS_SEED $ST_TYPECK_SX_LINK codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
  echo "relink_shux_asm_strict_glue: typeck not selfhosted; omit asm_driver_seed frontend C objs"
else
  ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $ST_ASYNC_CPS_SEED $SEED_O/lexer.o $SEED_O/ast_seed.o $ST_TYPECK_SX_LINK codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
  echo "relink_shux_asm_strict_glue: typeck not selfhosted yet (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o")B)"
fi

BSTRICT_DISPATCH="src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"
ST_DRIVER_COMPILE_O="driver_compile_sx.o"
# asm driver 替换须 STRICT_LINK_BUILD_ASM_DRIVER=1；默认仍用 C-gen（link.o 链入后 strict check 仍待修 arm64 对齐/ABI）。
if [ "${STRICT_LINK_BUILD_ASM_DRIVER:-0}" -eq 1 ] && [ -f "$BUILD_DIR/driver_compile_link.o" ]; then
  dc_sz=$(asm_o_text_bytes "$BUILD_DIR/driver_compile_emit_heavy.o" 2>/dev/null || echo 0)
  if [ "$dc_sz" -lt 5120 ] 2>/dev/null; then
    dc_sz=$(asm_o_text_bytes "$BUILD_DIR/driver_compile.o" 2>/dev/null || echo 0)
  fi
  if [ "$dc_sz" -ge 5120 ] 2>/dev/null; then
    ST_DRIVER_COMPILE_O="$BUILD_DIR/driver_compile_link.o"
    echo "relink_shux_asm_strict_glue: driver selfhosted (__text=${dc_sz}B, link.o, STRICT_LINK_BUILD_ASM_DRIVER=1)"
  fi
fi
# orchestration partial 已含 pipeline_run_sx_pipeline_impl；勿再链 trampoline（与 build_shux_asm strict_support 一致）。
ensure_pipeline_run_bootstrap_trampoline_obj() {
  local TRAMP_O TRAMP_CFLAGS
  TRAMP_O="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
  TRAMP_CFLAGS="$CFLAGS"
  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
    if echo " $ASM_TRY_OBJS $ST_RUNTIME_PARTIAL $ST_STRICT_ORCH_ALIAS " | grep -qE 'pipeline\.o|orchestration|runtime_bootstrap|wpo_strict_link_alias'; then
      TRAMP_CFLAGS="$CFLAGS -DSTRICT_LINK_BUILD_ASM_PIPELINE=1"
    fi
  fi
  if [ ! -f "$TRAMP_O" ] || [ "src/asm/pipeline_run_bootstrap_trampoline.c" -nt "$TRAMP_O" ]; then
    echo "relink_shux_asm_strict_glue: cc pipeline_run_bootstrap_trampoline.o"
    "$CC" $TRAMP_CFLAGS -c -o "$TRAMP_O" src/asm/pipeline_run_bootstrap_trampoline.c
  fi
}
ST_WPO_ALIAS=""
# pipeline_strict_link_partial 内 run_sx_pipeline_typecheck_entry 会 thin bl→run_sx_pipeline_typecheck_entry_emit。
if echo " $ASM_TRY_OBJS " | grep -q 'pipeline_strict_link_partial.o'; then
  if echo " $ASM_TRY_OBJS " | grep -q 'pipeline_wpo_strict_link_alias.o'; then
    : # strict_link_alias 已提供 emit
  else
    ensure_pipeline_wpo_typecheck_emit_bridge_obj && ST_WPO_ALIAS="$BUILD_DIR/pipeline_wpo_typecheck_emit_bridge.o"
    echo "relink_shux_asm_strict_glue: link pipeline_wpo_typecheck_emit_bridge (strict_link_partial typecheck_entry)"
  fi
elif [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ]; then
  if asm_pipeline_wpo_strict_link_full_ok; then
    : # alias/bridge 已在 ASM_TRY_OBJS
  else
    ensure_pipeline_wpo_typecheck_emit_bridge_obj && ST_WPO_ALIAS="$BUILD_DIR/pipeline_wpo_typecheck_emit_bridge.o"
  fi
fi
# pipeline.sx + C 编排 alias（须在 trampoline 编译前判定 STRICT_LINK_BUILD_ASM_PIPELINE）。
ensure_pipeline_sx_o_fresh || true
ST_PIPELINE_SX_TAIL=""
if [ -f pipeline_sx.o ] && [ "$ST_GLUE_OBJ" != "$BUILD_DIR/pipeline_glue_standalone.o" ]; then
  ST_PIPELINE_SX_TAIL="pipeline_sx.o"
fi
ST_STRICT_ORCH_ALIAS=""
if [ "$ST_GLUE_OBJ" = "$BUILD_DIR/pipeline_glue_standalone.o" ]; then
  if ! echo " $ASM_TRY_OBJS " | grep -qE 'pipeline_asm_orchestration|pipeline_runtime_bootstrap|pipeline_wpo_strict_link_alias'; then
    echo "relink_shux_asm_strict_glue: glue_standalone uses orchestration partial (not full alias TU)"
  fi
fi
ST_RUNTIME_PARTIAL=""
if asm_pipeline_wpo_strict_link_full_ok; then
  ST_RUNTIME_PARTIAL=""
elif [ -n "$ST_WPO_ALIAS" ]; then
  ST_RUNTIME_PARTIAL=""
elif echo " $ASM_TRY_OBJS " | grep -q 'pipeline_runtime_bootstrap_partial.o'; then
  ST_RUNTIME_PARTIAL=""
elif echo " $ASM_TRY_OBJS " | grep -q 'pipeline_asm_orchestration_partial.o'; then
  ST_RUNTIME_PARTIAL=""
elif echo " $ASM_TRY_OBJS " | grep -q 'pipeline_strict_link_partial.o'; then
  ST_RUNTIME_PARTIAL=""
elif [ "$ST_GLUE_OBJ" = "$BUILD_DIR/pipeline_glue_standalone.o" ] && \
     ! echo " $ASM_TRY_OBJS " | grep -qE 'pipeline_asm_orchestration|pipeline_runtime_bootstrap|pipeline_wpo_strict_link_alias|pipeline_strict_link_partial'; then
  ensure_pipeline_asm_orchestration_partial_obj && ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_partial.o"
elif [ -f "$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o" ] && ! asm_strict_sx_orchestration_ok; then
  ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o"
else
  ensure_pipeline_run_bootstrap_trampoline_obj
  ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
fi
ensure_asm_backend_compat_stubs_obj
# lsp_state.o 依赖 typeck_lsp_main_impl（lsp.sx -E → lsp_sx.o）；与 build_shux_asm ensure_asm_experimental_lsp_objs 一致。
ensure_strict_glue_lsp_objs() {
  GEN_DIR="$BUILD_DIR/gen_driver"
  mkdir -p "$GEN_DIR"
  if [ ! -f Makefile ] || ! command -v make >/dev/null 2>&1; then
    echo "relink_shux_asm_strict_glue: warn: cannot make lsp_sx.o (no Makefile/make)" >&2
    return 1
  fi
  echo "relink_shux_asm_strict_glue: ensure lsp_sx.o (+ lsp_io) for lsp_state (typeck_lsp_main_impl) ..."
  make -s lsp_io_gen.c lsp_gen.c lsp_io_std_heap_gen.c lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o
  cp -f lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o "$GEN_DIR/"
}
ensure_strict_glue_lsp_objs || true
ensure_asm_shux_lsp_diag_stub_obj
ensure_lsp_diag_seed_obj "$SEED_O"
LSP_DIAG_SEED_O=$(lsp_diag_seed_obj_path "$SEED_O")
# G-02-B1：优先 pipeline_fill_dep_strict_alias.sx（-backend asm）；失败回退 .c。
SHUX_REL="${SHUX:-./shux_asm}"
[ -x "$SHUX_REL" ] || SHUX_REL=./shux
LIBROOT_REL=""
if [ -f src/asm/asm_build_list.sx ]; then
  LIBROOT_REL=$(sed -n 's|^// LIBROOT:[[:space:]]*||p' src/asm/asm_build_list.sx | head -1)
fi
if [ -f src/asm/pipeline_fill_dep_strict_alias.sx ] \
  && { [ ! -f src/asm/pipeline_fill_dep_strict_alias.o ] \
    || [ src/asm/pipeline_fill_dep_strict_alias.sx -nt src/asm/pipeline_fill_dep_strict_alias.o ]; }; then
  if [ -x "$SHUX_REL" ] && "$SHUX_REL" -backend asm -o src/asm/pipeline_fill_dep_strict_alias.o $LIBROOT_REL \
    src/asm/pipeline_fill_dep_strict_alias.sx 2>/dev/null; then
    echo "relink_shux_asm_strict_glue: $SHUX_REL -backend asm pipeline_fill_dep_strict_alias.sx"
  elif [ -f src/asm/pipeline_fill_dep_strict_alias.c ]; then
    echo "relink_shux_asm_strict_glue: cc -c src/asm/pipeline_fill_dep_strict_alias.c (fallback)"
    "$CC" $CFLAGS -c -o src/asm/pipeline_fill_dep_strict_alias.o src/asm/pipeline_fill_dep_strict_alias.c
  fi
elif [ ! -f src/asm/pipeline_fill_dep_strict_alias.o ] \
  && [ -f src/asm/pipeline_fill_dep_strict_alias.c ]; then
  echo "relink_shux_asm_strict_glue: cc -c src/asm/pipeline_fill_dep_strict_alias.c"
  "$CC" $CFLAGS -c -o src/asm/pipeline_fill_dep_strict_alias.o src/asm/pipeline_fill_dep_strict_alias.c
fi
ST_BSTRICT_LINK_EXTRA="src/std_sys_shim.o src/asm/parser_asm_parse_expr_link.o src/asm/pipeline_fill_dep_strict_alias.o"
ensure_ast_asm_bare_link_alias_obj
ST_AST_BARE_ALIAS=""
if ! echo " $ASM_TRY_OBJS " | grep -q 'ast_asm_bare_link_alias.o'; then
  ST_AST_BARE_ALIAS="$BUILD_DIR/ast_asm_bare_link_alias.o"
fi
ST_LSP_SX_OBJS=""
if [ -f "$BUILD_DIR/gen_driver/lsp_sx.o" ]; then
  ST_LSP_SX_OBJS="$BUILD_DIR/gen_driver/lsp_sx.o $BUILD_DIR/gen_driver/lsp_io_sx.o $BUILD_DIR/gen_driver/lsp_io_std_heap_sx.o"
fi
ST_TYPECK_LSP_STUB=""
if [ -z "$ST_LSP_SX_OBJS" ]; then
  ST_TYPECK_LSP_STUB="$BUILD_DIR/typeck_lsp_io_stub.o"
fi
ensure_simd_glue_link_objs
ST_BACKEND_COMPANIONS=$(strict_asm_backend_companion_objs) || ST_BACKEND_COMPANIONS="$BUILD_DIR/seed_host/asm_backend_partial.o"
if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
  echo "relink_shux_asm_strict_glue: link backend_wpo.o (WPO reach OK)"
fi
if [ ! -f "$BUILD_DIR/seed_link_compat.o" ] || [ "src/seed_link_compat.c" -nt "$BUILD_DIR/seed_link_compat.o" ]; then
  echo "relink_shux_asm_strict_glue: cc -c $BUILD_DIR/seed_link_compat.o <- src/seed_link_compat.c"
  "$CC" $CFLAGS -c -o "$BUILD_DIR/seed_link_compat.o" src/seed_link_compat.c
fi
ST_STRICT_COMPANIONS="$BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $ST_BACKEND_COMPANIONS src/asm/user_asm_seed_bridge.o $BUILD_DIR/asm_backend_compat_stubs.o $BSTRICT_DISPATCH src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o preprocess_sx.o $BUILD_DIR/ast_pool_l5_bridge.o driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o $ST_DRIVER_COMPILE_O driver_emit_sx.o $ST_BSTRICT_LINK_EXTRA"

ST_PARSER_SX_TAIL=""
PARSER_ALIAS_LINK=""
if [ -f parser_sx.o ]; then
  ST_PARSER_SX_TAIL="parser_sx.o"
  if [ -f lexer_sx.o ]; then
    ST_PARSER_SX_TAIL="$ST_PARSER_SX_TAIL lexer_sx.o"
  else
    echo "relink_shux_asm_strict_glue: warn: missing lexer_sx.o (make lexer_sx.o); strict 链可能 undefined"
  fi
  # parser_sx.o 已导出 parse_expr_into / parser_copy_module_import_path64 等；勿再链 partial 与 link_alias。
  PARSER_ASM_PARTIAL=""
  PARSER_ALIAS_LINK=""
else
  PARSER_ALIAS_LINK="$PARSER_ALIAS_O"
fi

ST_TYPECK_SX_TAIL=""
if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -f typeck_sx.o ]; then
  ST_TYPECK_SX_TAIL="typeck_sx.o"
fi

ensure_runtime_driver_diagnostic_obj() {
  local o="src/runtime_driver_diagnostic.o"
  if [ ! -f "$o" ] || [ "src/runtime_driver_diagnostic.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_driver_diagnostic.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_driver_diagnostic.c
  fi
}

# 与 build_shux_asm.sh 一致：pipeline_sx/typeck_sx 引用 driver_typeck_skip_large_entry / pipeline_get_dep_arena_slot。
ensure_runtime_driver_abi_obj() {
  local o="src/runtime_driver_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_driver_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_driver_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_driver_abi.c
  fi
}

ensure_runtime_pipeline_abi_obj() {
  local o="src/runtime_pipeline_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_pipeline_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_pipeline_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_pipeline_abi.c
  fi
}

ensure_runtime_driver_diagnostic_obj
ensure_runtime_driver_abi_obj
ensure_runtime_pipeline_abi_obj

# 与 build_shux_asm.sh strict 链一致：driver_get_argv_i / shux_read_file_into_path / invoke_ld。
ensure_runtime_abi_obj() {
  local o="src/runtime_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_abi.c
  fi
}
ensure_runtime_io_abi_obj() {
  local o="src/runtime_io_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_io_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_io_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_io_abi.c
  fi
}
ensure_runtime_proc_abi_obj() {
  local o="src/runtime_proc_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_proc_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_proc_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_proc_abi.c
  fi
}
ensure_runtime_link_abi_obj() {
  local o="src/runtime_link_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_link_abi.c" -nt "$o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $o <- src/runtime_link_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_link_abi.c
  fi
}
ensure_seed_autovec_obj() {
  if [ ! -f "$SEED_O/autovec.o" ] || [ "src/codegen/autovec.c" -nt "$SEED_O/autovec.o" ]; then
    echo "relink_shux_asm_strict_glue: cc -c $SEED_O/autovec.o <- src/codegen/autovec.c"
    mkdir -p "$SEED_O"
    "$CC" $CFLAGS -c -o "$SEED_O/autovec.o" src/codegen/autovec.c
  fi
}
ensure_runtime_abi_obj
ensure_runtime_io_abi_obj
ensure_runtime_proc_abi_obj
ensure_runtime_link_abi_obj
ensure_seed_autovec_obj

echo "relink_shux_asm_strict_glue: linking shux_asm.strict_glue (glue_standalone + build_asm pipeline.o ...) ..."
# Linux strict 链：runtime_panic + liburing（与 build_shux_asm PIPELINE_LIBS 一致）。
ST_RUNTIME_PANIC=""
ST_PIPELINE_LIBS="-lm -lc"
if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  _arch="$(uname -m 2>/dev/null)"
  _panic_src=""
  if [ "$_arch" = "x86_64" ] && [ -f src/asm/runtime_panic_x86_64.s ]; then
    _panic_src="src/asm/runtime_panic_x86_64.s"
  elif { [ "$_arch" = "aarch64" ] || [ "$_arch" = "arm64" ]; } && [ -f src/asm/runtime_panic_arm64.c ]; then
    _panic_src="src/asm/runtime_panic_arm64.c"
  elif [ -f src/asm/runtime_panic.c ]; then
    _panic_src="src/asm/runtime_panic.c"
  fi
  if [ -n "$_panic_src" ] && { [ ! -f runtime_panic.o ] || [ "$_panic_src" -nt runtime_panic.o ]; }; then
    echo "relink_shux_asm_strict_glue: cc runtime_panic.o <- $_panic_src"
    if [ "${_panic_src##*.}" = "s" ]; then
      "$CC" -c -o runtime_panic.o "$_panic_src"
    else
      "$CC" $CFLAGS -c -o runtime_panic.o "$_panic_src"
    fi
  fi
  [ -f runtime_panic.o ] && ST_RUNTIME_PANIC="runtime_panic.o"
  ST_PIPELINE_LIBS="-lpthread -lm -lc"
  if have_link_liburing; then
    ST_PIPELINE_LIBS="-luring $ST_PIPELINE_LIBS"
  else
    echo "relink_shux_asm_strict_glue: liburing unavailable; link without -luring" >&2
  fi
fi
set +e
"$CC" ${CFLAGS} -Wl,--allow-multiple-definition -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm.strict_glue \
  src/asm/runtime_asm_build.o \
  src/runtime_abi.o \
  src/runtime_io_abi.o \
  src/runtime_proc_abi.o \
  src/runtime_link_abi.o \
  src/runtime_driver.o \
  src/runtime_driver_diagnostic.o \
  src/runtime_driver_abi.o \
  src/runtime_pipeline_abi.o \
  $ST_RUNTIME_PANIC \
  "$ST_GLUE_OBJ" \
  $ASM_TRY_OBJS \
  $PARSER_ASM_PARTIAL \
  $PARSER_ALIAS_LINK \
  "$PARSER_ASM_THIN_C" \
  $ST_AST_BARE_ALIAS \
  $ST_WPO_ALIAS \
  $ST_RUNTIME_PARTIAL \
  "$BUILD_DIR/std_fs_shim.o" \
  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
  "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
  $ST_TYPECK_LSP_STUB \
  "$BUILD_DIR/lsp_codegen_extern.o" \
  $ST_PREPROCESS_SEED \
  $ST_SEED_PARSER_TCK \
  $ST_STRICT_COMPANIONS \
  "$LSP_DIAG_SEED_O" \
  $ST_LSP_SX_OBJS \
  "$SEED_O/lsp_state.o" \
  src/lsp/lsp_diag_pipeline_sizes.o \
  $ST_LAYOUT_PARTIAL \
  $ST_PARSER_SX_TAIL \
  $ST_PIPELINE_SX_TAIL \
  $ST_TYPECK_SX_TAIL \
  $ST_PIPELINE_LIBS 2>"$BUILD_DIR/.relink_strict_glue_err"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "relink_shux_asm_strict_glue: link failed rc=$RC" >&2
  tail -n 12 "$BUILD_DIR/.relink_strict_glue_err" 2>/dev/null || true
  exit "$RC"
fi
echo "relink_shux_asm_strict_glue OK -> shux_asm.strict_glue ($(nm shux_asm.strict_glue 2>/dev/null | grep -c ' T .*asm_skip_heavy_module_func_body' || echo 0) asm_skip_heavy)"
echo "relink_shux_asm_strict_glue: 验证: SHUX_S2_EMIT_HEAVY_COMPILER=./shux_asm.strict_glue ./tests/run-s2-typeck-emit-heavy.sh"
echo "relink_shux_asm_strict_glue: WPO dogfood 编 build_asm/*.sx 优先 ./shux_asm.experimental（含 pipeline_sx.o）；用户 -o 用 strict_glue"
