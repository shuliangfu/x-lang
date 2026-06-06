#!/usr/bin/env bash
# 仅 strict 重链 shu_asm：更新 pipeline_glue_standalone.o（含 ast_pool.c）后快速激活 EMIT_HEAVY，无需全量 build_shu_asm。
# 用法：cd compiler && ./scripts/relink_shu_asm_strict_glue.sh
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build_asm"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
SEED_O="$BUILD_DIR/asm_driver_seed"
export STRICT_LINK_BUILD_ASM_PIPELINE=1

# codegen.c 引用 async_liveness / async_cps_codegen（与 Makefile OBJS_CORE、build_shu_asm 一致）。
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

# 与 build_shu_asm.sh 一致：判断 build_asm/typeck.o 是否已 EMIT_HEAVY 自举（__text>8192）。
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

# 从符号列表（每行一个，可带 Mach-O 前缀 _）做 ld -r 局部导出；与 build_shu_asm.sh 一致。
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
  echo "relink_shu_asm_strict_glue: warn: typeck_c_orchestration_partial failed; fallback stubs" >&2
  if [ ! -f "$BUILD_DIR/typeck_c_module_stubs.o" ] || [ typeck_c_module_stubs.c -nt "$BUILD_DIR/typeck_c_module_stubs.o" ]; then
    echo "  cc -c typeck_c_module_stubs.c -> $BUILD_DIR/typeck_c_module_stubs.o" >&2
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/typeck_c_module_stubs.o" typeck_c_module_stubs.c
  fi
  echo "$BUILD_DIR/typeck_c_module_stubs.o"
  return 1
}

# strict 链：C 编排 partial（run_su_pipeline_impl 等），与 build_shu_asm.sh 一致。
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
_pipeline_run_su_pipeline_impl
_run_su_pipeline_impl
_run_su_pipeline_parse_entry_do_parse
_run_su_pipeline_parse_entry_if_needed
_parse_into_with_init_buf
EOF
    echo "  ld partial export $SYMS orchestration_alias.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$ALIAS_O"
  fi
  cp -f "$PARTIAL" "$BUILD_DIR/pipeline_asm_runtime_partial.o"
  return 0
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
  if [ ! -f "$SYMS" ] || [ "$PO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; }; then
    nm "$PO" 2>/dev/null | awk '/ T / {print $3}' | grep -vE \
      'run_su_pipeline_(impl|parse_entry_do_parse|parse_entry_if_needed|typecheck_entry)$|^(parse_into_with_init_buf|parse_into_with_init|pipeline_run_su_pipeline_impl)$' \
      >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_pipeline_wpo_strict_reach_ok; then
      nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_export_syms.txt"
      if [ -s "$BUILD_DIR/.pipeline_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.pipeline_wpo_export_syms.txt" -o "$BUILD_DIR/.pipeline_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.pipeline_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  pipeline_strict_link: minus pipeline_wpo.o exports ($(wc -l <"$BUILD_DIR/.pipeline_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
    fi
    echo "  nm pipeline.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols, minus parse/typecheck/impl entry)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$PO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; } || \
     [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO" || return 1
  fi
  return 0
}

# pipeline_wpo.o 编排链 reach：run_su_pipeline_impl 直接 callee 须已定义（与 build_shu_asm.sh 一致）。
asm_pipeline_wpo_strict_reach_ok() {
  local po="$BUILD_DIR/pipeline_wpo.o"
  [ -f "$po" ] || return 1
  nm "$po" 2>/dev/null | grep -qE '(_)?run_su_pipeline_impl' || return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_su_pipeline_typecheck_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_su_pipeline_codegen_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_su_pipeline_parse_entry_if_needed$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_su_pipeline_codegen_deps$' && return 1
  return 0
}

# WPO strict partial 导出表是否过期：旧缓存曾误删 check_block/check_expr impl callee，导致 glue U 符号。
typeck_wpo_strict_partial_export_syms_stale() {
  local syms="$1"
  [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] || return 1
  asm_typeck_wpo_strict_reach_ok || return 1
  [ -f "$syms" ] || return 0
  grep -qxF 'typeck_check_block_one_while' "$syms" 2>/dev/null || return 0
  grep -qxF 'check_block_as_loop_body' "$syms" 2>/dev/null || return 0
  return 1
}

# strict 链：自 build_asm/typeck.o 导出除 WPO 已定义外符号。
ensure_typeck_o_strict_link_partial_obj() {
  local PARTIAL SYMS TCKO WPO_E
  PARTIAL="$BUILD_DIR/typeck_strict_link_partial.o"
  SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  TCKO="$BUILD_DIR/typeck.o"
  WPO_E="$BUILD_DIR/typeck_wpo.o"
  if [ ! -f "$TCKO" ] || [ ! -s "$TCKO" ]; then
    return 1
  fi
  if typeck_wpo_strict_partial_export_syms_stale "$SYMS"; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || rm -f "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$TCKO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; }; then
    nm "$TCKO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_typeck_wpo_strict_reach_ok; then
      nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.typeck_wpo_export_syms.txt"
      if [ -s "$BUILD_DIR/.typeck_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.typeck_wpo_export_syms.txt" -o "$BUILD_DIR/.typeck_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.typeck_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  typeck_strict_link: minus typeck_wpo.o exports ($(wc -l <"$BUILD_DIR/.typeck_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
    fi
    echo "  nm typeck.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$TCKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; }; then
    echo "  ld partial export $SYMS typeck.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$TCKO" || return 1
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || {
        echo "relink_shu_asm_strict_glue: typeck_strict_link_partial missing typeck_check_block_one_while" >&2
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?check_block_as_loop_body$' || {
        echo "relink_shu_asm_strict_glue: typeck_strict_link_partial missing check_block_as_loop_body" >&2
        return 1
      }
    fi
  fi
  return 0
}

# typeck_wpo.o WPO reach：typeck_su_ast / check_block / check_expr 须在 TU 内定义。
asm_typeck_wpo_strict_reach_ok() {
  local to="$BUILD_DIR/typeck_wpo.o"
  [ -f "$to" ] || return 1
  nm "$to" 2>/dev/null | grep -qE '(_)?typeck_su_ast' || return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?typeck_su_ast$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_block$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_expr$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_block' || return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_expr' || return 1
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
        echo "relink_shu_asm_strict_glue: backend_strict_link_partial missing arch_emit_add_imm_to_rax" >&2
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

# 与 build_shu_asm.sh 一致：pipeline_glue_standalone 引用 simd_enc / simd_loop / target_cpu。
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

# reach OK 时默认链 pipeline_wpo.o（可用 STRICT_LINK_BUILD_ASM_WPO=0 强制 C orchestration partial）。
if [ "${STRICT_LINK_BUILD_ASM_WPO:-}" != "0" ] && asm_pipeline_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_WPO=1
  echo "relink_shu_asm_strict_glue: STRICT_LINK_BUILD_ASM_WPO=1 (pipeline_wpo.o reach OK)"
fi
if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-}" != "0" ] && asm_typeck_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
  echo "relink_shu_asm_strict_glue: STRICT_LINK_BUILD_ASM_TYPECK_WPO=1 (typeck_wpo.o reach OK)"
fi
if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-}" != "0" ] && asm_backend_wpo_strict_reach_ok; then
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  echo "relink_shu_asm_strict_glue: STRICT_LINK_BUILD_ASM_BACKEND_WPO=1 (backend_wpo.o reach OK)"
fi

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
  echo "relink_shu_asm_strict_glue: missing $GLUE_TYPES (run build_shu_asm once)" >&2
  exit 1
fi
echo "relink_shu_asm_strict_glue: cc pipeline_glue_standalone.o <- ast_pool.c"
"$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I"$BUILD_DIR" -c -o "$BUILD_DIR/pipeline_glue_standalone.o" src/asm/pipeline_glue_standalone.c

# 收集非空 build_asm/*.o 并经 filter_strict_asm_objs 筛选（与 build_shu_asm strict 链一致）。
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
        if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && asm_pipeline_wpo_strict_reach_ok; then
          FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo.o"
          echo "relink_shu_asm_strict_glue: link pipeline_wpo.o (SU run_su_pipeline_impl, reach OK)"
        else
          ensure_pipeline_asm_orchestration_partial_obj
          FILTERED="$FILTERED $BUILD_DIR/pipeline_asm_orchestration_partial.o"
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
      parser_bootstrap_partial.o|parser_from_su_partial.o|parser_strict_merged.o|\
      pipeline_parse_su_partial.o|pipeline_runtime_bootstrap_partial.o|\
      pipeline_asm_su_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_strict_link_partial.o|pipeline_wpo.o|pipeline_wpo_strict_link_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      pipeline_run_bootstrap_trampoline.o|pipeline_bootstrap_orchestration_strict.o|\
      typeck_skip.o|typeck_heavy.o|typeck.second.o|\
      typeck_asm_layout_partial.o|typeck_su_no_layout_partial.o|typeck_c_orchestration_partial.o|\
      typeck_c_module_stubs.o|typeck_asm_bare_link_alias.o|typeck_wpo.o|typeck_strict_link_partial.o|\
      backend_wpo.o|backend_strict_link_partial.o|backend_asm_bare_link_alias.o|asm_backend_seed_helper_partial.o|\
      asm_backend_compat_stubs.o|\
      std_fs_shim.o|su_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shu_lsp_diag_stub.o|lsp_codegen_extern.o|\
      ast_pool_l5_bridge.o|\
      lexer.o|peephole.o|platform_elf.o|macho.o|coff.o|\
      parser_asm_link_alias.o|parser_asm_minimal_partial.o|\
      driver_compile.o|driver_compile_asm_link_alias.o|driver_compile_emit_heavy.o|driver_compile_link.o)
      continue
      ;;
    esac
    if [ "$base" = "typeck.o" ]; then
      if [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
        if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
          FILTERED="$FILTERED $BUILD_DIR/typeck_wpo.o"
          echo "relink_shu_asm_strict_glue: link typeck_wpo.o (SU typeck_su_ast, reach OK)"
          ensure_typeck_o_strict_link_partial_obj && FILTERED="$FILTERED $BUILD_DIR/typeck_strict_link_partial.o"
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

# build_asm/parser.o 仅导出 parser_su/glue 缺的符号（勿链整颗 parser.o，会与 seed parser 重复）。
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
    echo "relink_shu_asm_strict_glue: ld -r parser_asm_minimal_partial.o <- parser.o (3 symbols)"
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
  echo "relink_shu_asm_strict_glue: cc parser_asm_link_alias.o"
  "$CC" $CFLAGS -c -o "$PARSER_ALIAS_O" src/asm/parser_asm_link_alias.c
fi

ST_LAYOUT_PARTIAL=""
if [ -f "$BUILD_DIR/typeck_asm_layout_partial.o" ] && ! asm_strict_typeck_selfhosted; then
  ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o"
fi

ST_TYPECK_SU_LINK="typeck_su.o"
if [ -f "$BUILD_DIR/typeck_su_no_layout_partial.o" ] && ! asm_strict_typeck_selfhosted; then
  ST_TYPECK_SU_LINK="$BUILD_DIR/typeck_su_no_layout_partial.o"
fi

ensure_async_cps_seed_objs
ST_ASYNC_CPS_SEED="$SEED_O/async_liveness.o $SEED_O/async_cps_codegen.o"

ST_TYPECK_C_STUBS=""
ST_TYPECK_BARE_ALIAS=""
if asm_strict_typeck_selfhosted; then
  ST_TYPECK_C_STUBS=$(ensure_typeck_c_user_precheck_obj)
  if [ ! -f "$BUILD_DIR/typeck_asm_bare_link_alias.o" ] || [ typeck_asm_bare_link_alias.c -nt "$BUILD_DIR/typeck_asm_bare_link_alias.o" ]; then
    echo "  cc -c typeck_asm_bare_link_alias.c -> $BUILD_DIR/typeck_asm_bare_link_alias.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/typeck_asm_bare_link_alias.o" typeck_asm_bare_link_alias.c
  fi
  ST_TYPECK_BARE_ALIAS="$BUILD_DIR/typeck_asm_bare_link_alias.o"
  ST_SEED_PARSER_TCK="$ST_TYPECK_C_STUBS $ST_TYPECK_BARE_ALIAS $SEED_O/parser.o $SEED_O/codegen.o $ST_ASYNC_CPS_SEED $SEED_O/lexer.o $SEED_O/ast_seed.o codegen_su.o lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o"
  if [ -f src/typeck/typeck_f64_bits.o ]; then
    ST_SEED_PARSER_TCK="$ST_SEED_PARSER_TCK src/typeck/typeck_f64_bits.o"
  fi
  echo "relink_shu_asm_strict_glue: typeck whole link (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o")B)"
else
  ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $ST_ASYNC_CPS_SEED $SEED_O/lexer.o $SEED_O/ast_seed.o $ST_TYPECK_SU_LINK codegen_su.o lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o"
  echo "relink_shu_asm_strict_glue: typeck not selfhosted yet (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o")B)"
fi

BSTRICT_DISPATCH="src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"
ST_DRIVER_COMPILE_O="driver_compile_su.o"
# asm driver 替换须 STRICT_LINK_BUILD_ASM_DRIVER=1；默认仍用 C-gen（link.o 链入后 strict check 仍待修 arm64 对齐/ABI）。
if [ "${STRICT_LINK_BUILD_ASM_DRIVER:-0}" -eq 1 ] && [ -f "$BUILD_DIR/driver_compile_link.o" ]; then
  dc_sz=$(asm_o_text_bytes "$BUILD_DIR/driver_compile_emit_heavy.o" 2>/dev/null || echo 0)
  if [ "$dc_sz" -lt 5120 ] 2>/dev/null; then
    dc_sz=$(asm_o_text_bytes "$BUILD_DIR/driver_compile.o" 2>/dev/null || echo 0)
  fi
  if [ "$dc_sz" -ge 5120 ] 2>/dev/null; then
    ST_DRIVER_COMPILE_O="$BUILD_DIR/driver_compile_link.o"
    echo "relink_shu_asm_strict_glue: driver selfhosted (__text=${dc_sz}B, link.o, STRICT_LINK_BUILD_ASM_DRIVER=1)"
  fi
fi
# orchestration partial 已含 pipeline_run_su_pipeline_impl；勿再链 trampoline（与 build_shu_asm strict_support 一致）。
ensure_pipeline_run_bootstrap_trampoline_obj() {
  local TRAMP_O TRAMP_CFLAGS
  TRAMP_O="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
  TRAMP_CFLAGS="$CFLAGS"
  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
    TRAMP_CFLAGS="$CFLAGS -DSTRICT_LINK_BUILD_ASM_PIPELINE=1"
  fi
  if [ ! -f "$TRAMP_O" ] || [ "src/asm/pipeline_run_bootstrap_trampoline.c" -nt "$TRAMP_O" ]; then
    echo "relink_shu_asm_strict_glue: cc pipeline_run_bootstrap_trampoline.o"
    "$CC" $TRAMP_CFLAGS -c -o "$TRAMP_O" src/asm/pipeline_run_bootstrap_trampoline.c
  fi
}
ST_RUNTIME_PARTIAL=""
if [ -f "$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o" ]; then
  ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o"
elif echo " $ASM_TRY_OBJS " | grep -q ' pipeline_asm_orchestration_partial.o '; then
  ST_RUNTIME_PARTIAL=""
else
  ensure_pipeline_run_bootstrap_trampoline_obj
  ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
fi
ensure_asm_backend_compat_stubs_obj
ensure_simd_glue_link_objs
ST_BACKEND_COMPANIONS=$(strict_asm_backend_companion_objs) || ST_BACKEND_COMPANIONS="$BUILD_DIR/seed_host/asm_backend_partial.o"
if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
  echo "relink_shu_asm_strict_glue: link backend_wpo.o (WPO reach OK)"
fi
ST_STRICT_COMPANIONS="$BUILD_DIR/su_seed_bridge.o $ST_BACKEND_COMPANIONS src/asm/user_asm_seed_bridge.o $BUILD_DIR/asm_backend_compat_stubs.o $BSTRICT_DISPATCH src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o preprocess_su.o $BUILD_DIR/ast_pool_l5_bridge.o driver_fmt_su.o driver_check_su.o driver_test_su.o driver_build_su.o driver_run_su.o $ST_DRIVER_COMPILE_O driver_emit_su.o"

ST_PARSER_SU_TAIL=""
PARSER_ALIAS_LINK=""
if [ -f parser_su.o ]; then
  ST_PARSER_SU_TAIL="parser_su.o"
  if [ -f lexer_su.o ]; then
    ST_PARSER_SU_TAIL="$ST_PARSER_SU_TAIL lexer_su.o"
  else
    echo "relink_shu_asm_strict_glue: warn: missing lexer_su.o (make lexer_su.o); strict 链可能 undefined"
  fi
  # parser_su.o 已导出 parse_expr_into / parser_copy_module_import_path64 等；勿再链 partial 与 link_alias。
  PARSER_ASM_PARTIAL=""
  PARSER_ALIAS_LINK=""
else
  PARSER_ALIAS_LINK="$PARSER_ALIAS_O"
fi

echo "relink_shu_asm_strict_glue: linking shu_asm.strict_glue (glue_standalone + build_asm pipeline.o ...) ..."
# Linux strict 链：runtime_panic + liburing（与 build_shu_asm PIPELINE_LIBS 一致）。
ST_RUNTIME_PANIC=""
ST_PIPELINE_LIBS="-lm -lc"
if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  if [ ! -f runtime_panic.o ] || [ src/asm/runtime_panic_x86_64.s -nt runtime_panic.o ]; then
    if [ -f src/asm/runtime_panic_x86_64.s ]; then
      echo "relink_shu_asm_strict_glue: cc runtime_panic.o"
      "$CC" -c -o runtime_panic.o src/asm/runtime_panic_x86_64.s
    elif [ -f src/asm/runtime_panic.c ]; then
      "$CC" $CFLAGS -c -o runtime_panic.o src/asm/runtime_panic.c
    fi
  fi
  [ -f runtime_panic.o ] && ST_RUNTIME_PANIC="runtime_panic.o"
  ST_PIPELINE_LIBS="-luring -lpthread -lm -lc"
fi
ST_WPO_ALIAS=""
if ensure_pipeline_wpo_strict_link_alias_obj; then
  ST_WPO_ALIAS="$BUILD_DIR/pipeline_wpo_strict_link_alias.o"
fi
set +e
"$CC" ${CFLAGS} -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm.strict_glue \
  src/asm/runtime_asm_build.o \
  src/runtime_driver.o \
  $ST_RUNTIME_PANIC \
  $ASM_TRY_OBJS \
  $PARSER_ASM_PARTIAL \
  $PARSER_ALIAS_LINK \
  "$BUILD_DIR/pipeline_glue_standalone.o" \
  $ST_WPO_ALIAS \
  $ST_RUNTIME_PARTIAL \
  "$BUILD_DIR/std_fs_shim.o" \
  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
  "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
  "$BUILD_DIR/lsp_codegen_extern.o" \
  "$SEED_O/preprocess.o" \
  $ST_SEED_PARSER_TCK \
  $ST_STRICT_COMPANIONS \
  "$SEED_O/lsp_diag.o" \
  "$SEED_O/lsp_state.o" \
  src/lsp/lsp_diag_pipeline_sizes.o \
  ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
  $ST_LAYOUT_PARTIAL \
  $ST_PARSER_SU_TAIL \
  $ST_PIPELINE_LIBS 2>"$BUILD_DIR/.relink_strict_glue_err"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "relink_shu_asm_strict_glue: link failed rc=$RC" >&2
  tail -n 12 "$BUILD_DIR/.relink_strict_glue_err" 2>/dev/null || true
  exit "$RC"
fi
echo "relink_shu_asm_strict_glue OK -> shu_asm.strict_glue ($(nm shu_asm.strict_glue 2>/dev/null | grep -c ' T .*asm_skip_heavy_module_func_body' || echo 0) asm_skip_heavy)"
echo "relink_shu_asm_strict_glue: 验证: SHU_S2_EMIT_HEAVY_COMPILER=./shu_asm.strict_glue ./tests/run-s2-typeck-emit-heavy.sh"
echo "relink_shu_asm_strict_glue: 注意: strict_glue 的 SHU_ASM_ENTRY_MODULE_ONLY 自编译已知 SIGSEGV；WPO dogfood 请用 relink_shu_asm_experimental_bootstrap.sh + shu_asm.experimental"
