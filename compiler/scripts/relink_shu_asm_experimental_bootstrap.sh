#!/usr/bin/env bash
# experimental bootstrap 重链：pipeline_su.o + SU companions + seed C（与 build_shu_asm.sh 首链一致）。
# ast_pool.c 变更后须重编 pipeline_glue_standalone / pipeline_su，再本脚本重链 shu_asm.experimental。
# 用法：cd compiler && make lexer_su.o parser_su.o typeck_su.o codegen_su.o && ./scripts/relink_shu_asm_experimental_bootstrap.sh
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build_asm"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
SEED_O="$BUILD_DIR/asm_driver_seed"
BSTRICT_DISPATCH="src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"
PARSER_ALIAS_O="$BUILD_DIR/parser_asm_link_alias.o"
PARSER_ASM_PARTIAL="$BUILD_DIR/parser_asm_minimal_partial.o"

# codegen.c 引用 async_liveness / async_cps_codegen（与 Makefile OBJS_CORE、build_shu_asm 一致）。
ensure_async_cps_seed_objs() {
  local src out src_pair
  for src_pair in \
    "src/async/async_liveness.c:$SEED_O/async_liveness.o" \
    "src/async/async_cps_codegen.c:$SEED_O/async_cps_codegen.o"; do
    src="${src_pair%%:*}"
    out="${src_pair##*:}"
    if [ ! -f "$out" ] || [ "$src" -nt "$out" ]; then
      echo "relink_experimental_bootstrap: cc $src -> $out"
      mkdir -p "$(dirname "$out")"
      "$CC" $CFLAGS -c -o "$out" "$src"
    fi
  done
}
ensure_async_cps_seed_objs

# B-strict shu_asm：driver_run_compiler_full 走 impl_c（与 build_shu_asm.sh 一致）。
ensure_runtime_driver_asm_strict_obj() {
  local o="src/runtime_driver_asm_strict.o"
  if [ ! -f "$o" ] || [ "src/runtime.c" -nt "$o" ]; then
    echo "relink_experimental_bootstrap: cc $o <- src/runtime.c (-DSHU_ASM_USE_COMPILER_IMPL_C)"
    "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -DSHU_USE_SU_PREPROCESS \
      -DSHU_ASM_USE_COMPILER_IMPL_C -c -o "$o" src/runtime.c
  fi
}
ensure_runtime_driver_asm_strict_obj

# pipeline_glue / pipeline_su 引用 target_cpu / simd_enc / simd_loop（SIMD-S1–S4）。
ensure_simd_glue_link_objs() {
  if [ ! -f src/asm/pipeline_abi_f32_xmm.o ] || [ src/asm/pipeline_abi_f32_xmm.c -nt src/asm/pipeline_abi_f32_xmm.o ]; then
    echo "relink_experimental_bootstrap: cc pipeline_abi_f32_xmm.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/pipeline_abi_f32_xmm.o src/asm/pipeline_abi_f32_xmm.c
  fi
  if [ ! -f src/driver/target_cpu.o ] || [ src/driver/target_cpu.c -nt src/driver/target_cpu.o ]; then
    echo "relink_experimental_bootstrap: cc src/driver/target_cpu.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/target_cpu.o src/driver/target_cpu.c
  fi
  if [ ! -f src/asm/simd_enc.o ] || [ src/asm/simd_enc.c -nt src/asm/simd_enc.o ]; then
    echo "relink_experimental_bootstrap: cc src/asm/simd_enc.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_enc.o src/asm/simd_enc.c
  fi
  if [ ! -f src/asm/simd_loop.o ] || [ src/asm/simd_loop.c -nt src/asm/simd_loop.o ]; then
    echo "relink_experimental_bootstrap: cc src/asm/simd_loop.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_loop.o src/asm/simd_loop.c
  fi
}
ensure_simd_glue_link_objs

# parser 别名 TU（pipeline_bootstrap_link_alias 已废弃：weak dispatch 在 pipeline_glue.c）
if [ ! -f "$PARSER_ALIAS_O" ] || [ "src/asm/parser_asm_link_alias.c" -nt "$PARSER_ALIAS_O" ]; then
  echo "relink_experimental_bootstrap: cc parser_asm_link_alias.o"
  "$CC" $CFLAGS -c -o "$PARSER_ALIAS_O" src/asm/parser_asm_link_alias.c
fi
if [ ! -f "$PARSER_ASM_PARTIAL" ] && [ -f "$BUILD_DIR/parser.o" ]; then
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    cat > "$BUILD_DIR/parser_asm_minimal_export.txt" <<'EOF'
_parse_expr_into
_copy_module_import_path64
_parse_one_function_ok_for_pipeline
EOF
    ld -r -exported_symbols_list "$BUILD_DIR/parser_asm_minimal_export.txt" -o "$PARSER_ASM_PARTIAL" "$BUILD_DIR/parser.o"
  else
    # Linux：ld -exported_symbols_list 为 Mach-O 语法；bootstrap 链不依赖 partial，跳过即可。
    cp -f "$BUILD_DIR/parser.o" "$PARSER_ASM_PARTIAL"
  fi
fi

for o in pipeline_su.o pipeline_bootstrap_orchestration.o preprocess_su.o lexer_su.o parser_su.o typeck_su.o codegen_su.o \
  lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o \
  driver_fmt_su.o driver_check_su.o driver_test_su.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o; do
  if [ ! -f "$o" ]; then
    echo "relink_experimental_bootstrap: missing $o (make $o)" >&2
    exit 1
  fi
done

PIPELINE_RUN_SU_ALIAS_O="src/asm/pipeline_run_su_link_alias.o"
if [ ! -f "$PIPELINE_RUN_SU_ALIAS_O" ] || [ "src/asm/pipeline_run_su_link_alias.c" -nt "$PIPELINE_RUN_SU_ALIAS_O" ]; then
  echo "relink_experimental_bootstrap: cc pipeline_run_su_link_alias.o"
  "$CC" $CFLAGS -c -o "$PIPELINE_RUN_SU_ALIAS_O" src/asm/pipeline_run_su_link_alias.c
fi

# Linux：std/io io_uring 须 -luring（与 build_shu_asm.sh PIPELINE_LIBS 一致）。
PIPELINE_LIBS=""
if [ "$(uname -s)" = "Linux" ]; then
  PIPELINE_LIBS="-luring -lpthread"
fi

echo "relink_experimental_bootstrap: linking shu_asm.experimental ..."
"$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm.experimental \
  src/asm/runtime_asm_build.o \
  src/runtime_driver_asm_strict.o \
  pipeline_su.o \
  pipeline_bootstrap_orchestration.o \
  preprocess_su.o \
  "$BUILD_DIR/ast_pool_l5_bridge.o" \
  driver_fmt_su.o driver_check_su.o driver_test_su.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o \
  "$BUILD_DIR/std_fs_shim.o" \
  "$BUILD_DIR/su_seed_bridge.o" \
  "$BUILD_DIR/seed_host/asm_backend_partial.o" \
  src/asm/user_asm_seed_bridge.o \
  src/asm/asm_backend_compat_stubs.o \
  src/asm/pipeline_run_su_link_alias.o \
  $BSTRICT_DISPATCH \
  src/driver/fmt_check_cmd_driver.o \
  src/driver/target_cpu.o \
  src/asm/simd_enc.o \
  src/asm/simd_loop.o \
  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
  "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
  "$BUILD_DIR/lsp_codegen_extern.o" \
  "$SEED_O/preprocess.o" \
  "$SEED_O/parser.o" \
  "$SEED_O/typeck.o" \
  "$SEED_O/codegen.o" \
  "$SEED_O/async_liveness.o" \
  "$SEED_O/async_cps_codegen.o" \
  "$SEED_O/lexer.o" \
  "$SEED_O/ast_seed.o" \
  parser_su.o lexer_su.o typeck_su.o codegen_su.o \
  lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o \
  "$SEED_O/lsp_diag.o" \
  "$SEED_O/lsp_state.o" \
  src/lsp/lsp_diag_pipeline_sizes.o \
  ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
  -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.relink_experimental_bootstrap_err"

if [ ! -x shu_asm.experimental ]; then
  echo "relink_experimental_bootstrap: link failed" >&2
  tail -n 12 "$BUILD_DIR/.relink_experimental_bootstrap_err" 2>/dev/null || true
  exit 1
fi

cp -f shu_asm.experimental shu_asm
echo "relink_experimental_bootstrap OK (copied to shu_asm)"
echo "relink_experimental_bootstrap: verify: SHU_S2_FAIL_ON_EMIT_HEAVY=1 ../tests/run-s2-typeck-emit-heavy.sh"
