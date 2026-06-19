#!/usr/bin/env bash
# experimental bootstrap 重链：pipeline_sx.o + SU companions + seed C（与 build_shux_asm.sh 首链一致）。
# ast_pool.c 变更后须重编 pipeline_glue_standalone / pipeline_sx，再本脚本重链 shux_asm.experimental。
# 用法：cd compiler && make lexer_su.o parser_sx.o typeck_su.o codegen_su.o && ./scripts/relink_shux_asm_experimental_bootstrap.sh
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build_asm"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
SEED_O="$BUILD_DIR/asm_driver_seed"
BSTRICT_DISPATCH="src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"
PARSER_ALIAS_O="$BUILD_DIR/parser_asm_link_alias.o"
PARSER_ASM_PARTIAL="$BUILD_DIR/parser_asm_minimal_partial.o"

# codegen.c 引用 async_liveness / async_cps_codegen（与 Makefile OBJS_CORE、build_shux_asm 一致）。
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

# bootstrap-driver-seed 同款 C 种子 .o（experimental 链须 preprocess/parser/typeck 等；缺则 ld 失败）。
ensure_asm_driver_seed_c_objs() {
  mkdir -p "$SEED_O"
  if [ ! -f "$SEED_O/preprocess.o" ] || [ "src/preprocess.c" -nt "$SEED_O/preprocess.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/preprocess.o"
    "$CC" $CFLAGS -DSHUX_USE_SX_PREPROCESS -c -o "$SEED_O/preprocess.o" src/preprocess.c
  fi
  if [ ! -f "$SEED_O/lexer.o" ] || [ "src/lexer/lexer.c" -nt "$SEED_O/lexer.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/lexer.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lexer.o" src/lexer/lexer.c
  fi
  if [ ! -f "$SEED_O/ast_seed.o" ] || [ "src/ast/ast.c" -nt "$SEED_O/ast_seed.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/ast_seed.o"
    "$CC" $CFLAGS -DSHUX_USE_SX_AST -c -o "$SEED_O/ast_seed.o" src/ast/ast.c
  fi
  if [ ! -f "$SEED_O/parser.o" ] || [ "src/parser/parser.c" -nt "$SEED_O/parser.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/parser.o"
    "$CC" $CFLAGS -c -o "$SEED_O/parser.o" src/parser/parser.c
  fi
  if [ ! -f "$SEED_O/typeck.o" ] || [ "src/typeck/typeck.c" -nt "$SEED_O/typeck.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/typeck.o"
    "$CC" $CFLAGS -c -o "$SEED_O/typeck.o" src/typeck/typeck.c
  fi
  if [ ! -f "$SEED_O/codegen.o" ] || [ "src/codegen/codegen.c" -nt "$SEED_O/codegen.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/codegen.o"
    "$CC" $CFLAGS -c -o "$SEED_O/codegen.o" src/codegen/codegen.c
  fi
  if [ ! -f "$SEED_O/lsp_diag.o" ] || [ "src/lsp/lsp_diag.c" -nt "$SEED_O/lsp_diag.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/lsp_diag.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lsp_diag.o" src/lsp/lsp_diag.c
  fi
  if [ ! -f "$SEED_O/lsp_state.o" ] || [ "src/lsp/lsp_state.c" -nt "$SEED_O/lsp_state.o" ]; then
    echo "relink_experimental_bootstrap: cc $SEED_O/lsp_state.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lsp_state.o" src/lsp/lsp_state.c
  fi
}
ensure_asm_driver_seed_c_objs

# ast_pool.c / pipeline_glue.c 变更后须重编 pipeline_sx.o（glue 在 pipeline_gen.c #include 内）。
ensure_pipeline_su_fresh_for_ast_pool() {
  if [ -f ast_pool.c ] && { [ ! -f pipeline_sx.o ] || [ ast_pool.c -nt pipeline_sx.o ]; }; then
    echo "relink_experimental_bootstrap: ast_pool.c newer than pipeline_sx.o — rebuild ..."
    if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
      make -s pipeline_sx.o PIPELINE_SU_FORCE_COMPILE=1 || {
        echo "relink_experimental_bootstrap: warn: pipeline_sx.o rebuild failed" >&2
        return 1
      }
    fi
  fi
  if [ -f pipeline_glue.c ] && { [ ! -f pipeline_sx.o ] || [ pipeline_glue.c -nt pipeline_sx.o ]; }; then
    echo "relink_experimental_bootstrap: pipeline_glue.c newer than pipeline_sx.o — rebuild ..."
    if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
      make -s pipeline_sx.o PIPELINE_SU_FORCE_COMPILE=1 || {
        echo "relink_experimental_bootstrap: warn: pipeline_sx.o rebuild failed" >&2
        return 1
      }
    fi
  fi
  return 0
}
ensure_pipeline_su_fresh_for_ast_pool || true

# experimental 链符号桥（缺则 ld 失败）。
if [ ! -f "$BUILD_DIR/asm_experimental_symbol_bridge.o" ] || [ "src/asm/asm_experimental_symbol_bridge.c" -nt "$BUILD_DIR/asm_experimental_symbol_bridge.o" ]; then
  echo "relink_experimental_bootstrap: cc asm_experimental_symbol_bridge.o"
  "$CC" $CFLAGS -c -o "$BUILD_DIR/asm_experimental_symbol_bridge.o" src/asm/asm_experimental_symbol_bridge.c
fi

# runtime_asm_build.o（首链 bootstrap-asm 产物；缺则 ld 失败）。
if [ ! -f src/asm/runtime_asm_build.o ] || [ "src/asm/runtime_asm_build.c" -nt src/asm/runtime_asm_build.o ]; then
  echo "relink_experimental_bootstrap: cc runtime_asm_build.o"
  "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/runtime_asm_build.o src/asm/runtime_asm_build.c
fi

# B-strict shux_asm：driver_run_compiler_full 走 impl_c（与 build_shux_asm.sh 一致）。
ensure_runtime_driver_asm_strict_obj() {
  local o="src/runtime_driver_asm_strict.o"
  if [ ! -f "$o" ] || [ "src/runtime.c" -nt "$o" ]; then
    echo "relink_experimental_bootstrap: cc $o <- src/runtime.c (-DSHUX_ASM_USE_COMPILER_IMPL_C)"
    "$CC" $CFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS \
      -DSHUX_ASM_USE_COMPILER_IMPL_C -c -o "$o" src/runtime.c
  fi
}
ensure_runtime_driver_asm_strict_obj

# pipeline_glue / pipeline_sx 引用 target_cpu / simd_enc / simd_loop（SIMD-S1–S4）。
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

# build_asm 伴生 .o（experimental 链与 build_shux_asm ensure_asm_bootstrap_su_companion_objs 对齐）。
ensure_experimental_companion_objs() {
  mkdir -p "$BUILD_DIR" "$BUILD_DIR/seed_host"
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    make -s parser_sx.o lexer_su.o typeck_su.o codegen_su.o preprocess_su.o \
      lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
      driver_su.o driver_fmt_su.o driver_check_su.o driver_test_sx.o \
      driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o \
      pipeline_bootstrap_orchestration.o 2>/dev/null || true
  fi
  if [ ! -f "$BUILD_DIR/std_fs_shim.o" ] || [ "src/std_fs_shim.c" -nt "$BUILD_DIR/std_fs_shim.o" ]; then
    echo "relink_experimental_bootstrap: cc std_fs_shim.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/std_fs_shim.o" src/std_fs_shim.c
  fi
  if [ ! -f "$BUILD_DIR/sx_seed_bridge.o" ] || [ "src/sx_seed_bridge.c" -nt "$BUILD_DIR/sx_seed_bridge.o" ]; then
    echo "relink_experimental_bootstrap: cc sx_seed_bridge.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/sx_seed_bridge.o" src/sx_seed_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/ast_pool_l5_bridge.o" ] || [ "src/ast_pool_l5_bridge.c" -nt "$BUILD_DIR/ast_pool_l5_bridge.o" ]; then
    echo "relink_experimental_bootstrap: cc ast_pool_l5_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/ast_pool_l5_bridge.o" src/ast_pool_l5_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/lsp_codegen_extern.o" ] || [ "src/lsp/lsp_codegen_extern.c" -nt "$BUILD_DIR/lsp_codegen_extern.o" ]; then
    echo "relink_experimental_bootstrap: cc lsp_codegen_extern.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/lsp_codegen_extern.o" src/lsp/lsp_codegen_extern.c
  fi
  if [ ! -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ] || [ "src/asm/backend.sx" -nt "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
    echo "relink_experimental_bootstrap: build_seed_asm_host (asm_backend_partial.o) ..."
    ./scripts/build_seed_asm_host.sh
  fi
  if [ ! -f src/asm/asm_backend_compat_stubs.o ] || [ "src/asm/asm_backend_compat_stubs.c" -nt src/asm/asm_backend_compat_stubs.o ]; then
    echo "relink_experimental_bootstrap: cc asm_backend_compat_stubs.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/asm_backend_compat_stubs.o src/asm/asm_backend_compat_stubs.c
  fi
  if [ ! -f src/asm/user_asm_seed_bridge.o ] || [ "src/asm/user_asm_seed_bridge.c" -nt src/asm/user_asm_seed_bridge.o ]; then
    echo "relink_experimental_bootstrap: cc user_asm_seed_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/user_asm_seed_bridge.o src/asm/user_asm_seed_bridge.c
  fi
}
ensure_experimental_companion_objs

# parser thin C glue（EMIT_HEAVY 第二遍 bl→parser_*_glue 符号）。
PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
PARSER_ASM_LINK_ALIAS_CFLAGS="-DPARSER_ASM_LINK_ALIAS_SKIP_SU_SYMBOLS"
PARSER_ASM_THIN_C="parser_asm_thin_glue.o"
if [ ! -f "$PARSER_ASM_THIN_C" ] || [ "src/asm/parser_asm_thin_c.c" -nt "$PARSER_ASM_THIN_C" ]; then
  echo "relink_experimental_bootstrap: cc parser_asm_thin_glue.o"
  "$CC" $CFLAGS $PARSER_ASM_THIN_GLUE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -c -o "$PARSER_ASM_THIN_C" src/asm/parser_asm_thin_c.c
fi

# parser 别名 TU（pipeline_bootstrap_link_alias 已废弃：weak dispatch 在 pipeline_glue.c）
if [ ! -f "$PARSER_ALIAS_O" ] || [ "src/asm/parser_asm_link_alias.c" -nt "$PARSER_ALIAS_O" ]; then
  echo "relink_experimental_bootstrap: cc parser_asm_link_alias.o"
  "$CC" $CFLAGS $PARSER_ASM_LINK_ALIAS_CFLAGS -c -o "$PARSER_ALIAS_O" src/asm/parser_asm_link_alias.c
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

# parser_sx.o：Makefile 要求 parser_copy_module_import_path64 在 gen 内；experimental 链由 link_alias+thin_glue 提供。
ensure_parser_su_obj() {
  if [ -f parser_sx.o ]; then
    return 0
  fi
  if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
    make -s parser_sx.o 2>/dev/null || true
  fi
  if [ ! -f parser_sx.o ] && [ -f parser_gen.c ]; then
    echo "relink_experimental_bootstrap: cc parser_gen.c -> parser_sx.o (link_alias supplies parser_* pipeline symbols)"
    "$CC" $CFLAGS $(make -s -f Makefile print-PIPELINE_GEN_CFLAGS 2>/dev/null || echo "") \
      -I. -Iinclude -Isrc \
      -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len \
      -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr \
      -c parser_gen.c -o parser_sx.o
  fi
  if [ ! -f parser_sx.o ]; then
    echo "relink_experimental_bootstrap: missing parser_sx.o (make parser_sx.o or restore parser_gen.c)" >&2
    exit 1
  fi
}
ensure_parser_su_obj

# 瘦 parser_sx.o 无 parse_into_buf：默认 cc seed slice TU；SU PARSE_BOOTSTRAP_EMIT 仍 139，仅 opt-in 探测。
ensure_parser_parse_bootstrap_asm_obj() {
  PARSER_PARSE_BOOT_O="$BUILD_DIR/parser_parse_bootstrap.o"
  PBOOT_C_SRC="src/asm/parser_asm_parse_bootstrap_obj.c"
  PBOOT_SEED_SLICE="src/asm/parser_asm_seed_parse_into_buf_slice.c"
  mkdir -p "$BUILD_DIR"

  compile_parser_parse_bootstrap_cc_obj() {
    echo "relink_experimental_bootstrap: cc parser_asm_parse_bootstrap_obj.c -> $PARSER_PARSE_BOOT_O"
    if ! "$CC" $CFLAGS -c -o "$PARSER_PARSE_BOOT_O" "$PBOOT_C_SRC"; then
      echo "relink_experimental_bootstrap: warn: cc parser_parse_bootstrap.o failed" >&2
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    if ! nm -g "$PARSER_PARSE_BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
      echo "relink_experimental_bootstrap: warn: parser_parse_bootstrap.o missing parse_into_buf" >&2
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    return 0
  }

  try_parser_parse_bootstrap_su_emit() {
    SHUX_SEED="./shux"
    PBOOT_LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
    if [ -x ./shux_asm2_refreshed ] && file ./shux_asm2_refreshed 2>/dev/null | grep -q "ELF.*x86-64"; then
      _min="/tmp/shux_seed_parse_probe.$$.sx"
      printf 'function main(): i32 { return 0; }\n' > "$_min"
      if ! env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 ./shux -backend asm -o /tmp/shux_seed_probe.$$.o \
          $PBOOT_LIBROOT "$_min" 2>/dev/null || [ ! -s /tmp/shux_seed_probe.$$.o ]; then
        SHUX_SEED="./shux_asm2_refreshed"
        echo "relink_experimental_bootstrap: ./shux parse probe failed — bootstrap seed=$SHUX_SEED" >&2
      fi
      rm -f "$_min" /tmp/shux_seed_probe.$$.o 2>/dev/null || true
    fi
    if [ ! -x "$SHUX_SEED" ]; then
      return 1
    fi
    if [ -f ast_pool.c ] && { [ ! -f pipeline_sx.o ] || [ ast_pool.c -nt pipeline_sx.o ]; }; then
      echo "relink_experimental_bootstrap: ast_pool.c newer — rebuild pipeline_sx.o for parse bootstrap ..."
      if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
        make -s pipeline_sx.o PIPELINE_SU_FORCE_COMPILE=1 || true
      fi
    fi
    if [ -f pipeline_sx.o ] && [ pipeline_sx.o -nt "$SHUX_SEED" ] 2>/dev/null; then
      echo "relink_experimental_bootstrap: refresh ./shux (pipeline_sx.o for parse bootstrap emit) ..."
      if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
        make -s relink-shux 2>/dev/null || true
      fi
    fi
    echo "relink_experimental_bootstrap: $SHUX_SEED asm parser parse bootstrap (SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT opt-in) ..."
    ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
    if ! env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
        "$SHUX_SEED" -backend asm -o "$PARSER_PARSE_BOOT_O" $PBOOT_LIBROOT src/parser/parser.sx \
        2>"$BUILD_DIR/.parser_parse_bootstrap_err"; then
      echo "relink_experimental_bootstrap: warn: parser parse bootstrap SU emit failed" >&2
      tail -8 "$BUILD_DIR/.parser_parse_bootstrap_err" 2>/dev/null || true
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    if ! nm -g "$PARSER_PARSE_BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
      echo "relink_experimental_bootstrap: warn: SU bootstrap .o missing parse_into_buf" >&2
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    return 0
  }

  need_rebuild=0
  if [ ! -f "$PARSER_PARSE_BOOT_O" ]; then
    need_rebuild=1
  elif [ "$PBOOT_C_SRC" -nt "$PARSER_PARSE_BOOT_O" ] || [ "$PBOOT_SEED_SLICE" -nt "$PARSER_PARSE_BOOT_O" ]; then
    need_rebuild=1
  fi

  if [ "$need_rebuild" = "1" ]; then
    if [ "${SHUX_ASM_PARSER_PARSE_BOOTSTRAP_SU_EMIT:-0}" = "1" ]; then
      try_parser_parse_bootstrap_su_emit || compile_parser_parse_bootstrap_cc_obj || true
    else
      compile_parser_parse_bootstrap_cc_obj || true
    fi
  fi

  if [ ! -f "$PARSER_PARSE_BOOT_O" ]; then
    PARSER_PARSE_BOOT_O=""
  fi
  # parser_sx.o 已真 emit parse_into* 时勿再链 bootstrap .o（否则 ld multiple definition）。
  if [ -f parser_sx.o ] && nm parser_sx.o 2>/dev/null | grep -qE '[[:space:]]T parser_parse_into_buf$'; then
    PARSER_PARSE_BOOT_O=""
  fi
}
ensure_parser_parse_bootstrap_asm_obj

for o in pipeline_sx.o pipeline_bootstrap_orchestration.o preprocess_su.o lexer_su.o typeck_su.o codegen_su.o \
  lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
  driver_fmt_su.o driver_check_su.o driver_test_sx.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o; do
  if [ ! -f "$o" ]; then
    echo "relink_experimental_bootstrap: missing $o (make $o)" >&2
    exit 1
  fi
done

PIPELINE_RUN_SU_ALIAS_O="src/asm/pipeline_run_sx_link_alias.o"
if [ ! -f "$PIPELINE_RUN_SU_ALIAS_O" ] || [ "src/asm/pipeline_run_sx_link_alias.c" -nt "$PIPELINE_RUN_SU_ALIAS_O" ]; then
  echo "relink_experimental_bootstrap: cc pipeline_run_sx_link_alias.o"
  "$CC" $CFLAGS -c -o "$PIPELINE_RUN_SU_ALIAS_O" src/asm/pipeline_run_sx_link_alias.c
fi

# Linux：std/io io_uring 须 -luring（与 build_shux_asm.sh PIPELINE_LIBS 一致）。
PIPELINE_LIBS=""
if [ "$(uname -s)" = "Linux" ]; then
  PIPELINE_LIBS="-luring -lpthread"
fi

echo "relink_experimental_bootstrap: linking shux_asm.experimental ..."
# seed parser/typeck/codegen/lexer 供 runtime/lsp_diag 链接；parser_su/typeck_su 须链在末尾压过重复 glue（build_shux_asm ST_PARSER_SU_TAIL）。
# lsp_state.o 依赖 typeck_lsp_main_impl（与 strict_glue ensure_strict_glue_lsp_objs 一致）。
ensure_experimental_lsp_objs() {
  GEN_DIR="$BUILD_DIR/gen_driver"
  mkdir -p "$GEN_DIR"
  if [ ! -f Makefile ] || ! command -v make >/dev/null 2>&1; then
    echo "relink_experimental_bootstrap: warn: cannot make lsp_sx.o" >&2
    return 1
  fi
  make -s lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
    lsp_sx.o lsp_io_sx.o lsp_diag_sx.o lsp_io_std_heap_su.o
  cp -f lsp_sx.o lsp_io_sx.o lsp_diag_sx.o lsp_io_std_heap_su.o "$GEN_DIR/"
}
ensure_experimental_lsp_objs || true
ST_LSP_SU=""
if [ -f "$BUILD_DIR/gen_driver/lsp_sx.o" ]; then
  ST_LSP_SU="$BUILD_DIR/gen_driver/lsp_sx.o $BUILD_DIR/gen_driver/lsp_io_sx.o $BUILD_DIR/gen_driver/lsp_io_std_heap_su.o $BUILD_DIR/gen_driver/lsp_diag_sx.o"
fi
if [ ! -f "$BUILD_DIR/asm_shu_lsp_diag_stub.o" ] || [ "scripts/asm_shu_lsp_diag_stub.c" -nt "$BUILD_DIR/asm_shu_lsp_diag_stub.o" ]; then
  "$CC" $CFLAGS -c -o "$BUILD_DIR/asm_shu_lsp_diag_stub.o" scripts/asm_shu_lsp_diag_stub.c
fi
ST_LSP_DIAG_STUB="$BUILD_DIR/asm_shu_lsp_diag_stub.o"
"$CC" $CFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm.experimental \
  src/asm/runtime_asm_build.o \
  src/runtime_driver_asm_strict.o \
  pipeline_sx.o \
  pipeline_bootstrap_orchestration.o \
  preprocess_su.o \
  "$BUILD_DIR/ast_pool_l5_bridge.o" \
  driver_fmt_su.o driver_check_su.o driver_test_sx.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o \
  "$BUILD_DIR/std_fs_shim.o" \
  "$BUILD_DIR/sx_seed_bridge.o" \
  "$BUILD_DIR/seed_host/asm_backend_partial.o" \
  src/asm/user_asm_seed_bridge.o \
  src/asm/asm_backend_compat_stubs.o \
  src/asm/pipeline_run_sx_link_alias.o \
  $BSTRICT_DISPATCH \
  src/driver/fmt_check_cmd_driver.o \
  src/driver/target_cpu.o \
  src/asm/simd_enc.o \
  src/asm/simd_loop.o \
  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
  ${PARSER_PARSE_BOOT_O:+"$PARSER_PARSE_BOOT_O"} \
  $ST_LSP_DIAG_STUB \
  "$BUILD_DIR/lsp_codegen_extern.o" \
  "$SEED_O/preprocess.o" \
  "$SEED_O/async_liveness.o" \
  "$SEED_O/async_cps_codegen.o" \
  "$SEED_O/ast_seed.o" \
  "$SEED_O/lexer.o" \
  "$SEED_O/parser.o" \
  "$SEED_O/typeck.o" \
  "$SEED_O/codegen.o" \
  "$SEED_O/lsp_diag.o" \
  $ST_LSP_SU \
  "$SEED_O/lsp_state.o" \
  src/lsp/lsp_diag_pipeline_sizes.o \
  "$PARSER_ASM_THIN_C" \
  "$PARSER_ALIAS_O" \
  parser_sx.o lexer_su.o typeck_su.o codegen_su.o \
  lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
  ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
  -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.relink_experimental_bootstrap_err"

if [ ! -x shux_asm.experimental ]; then
  echo "relink_experimental_bootstrap: link failed" >&2
  tail -n 12 "$BUILD_DIR/.relink_experimental_bootstrap_err" 2>/dev/null || true
  exit 1
fi

cp -f shux_asm.experimental shux_asm
echo "relink_experimental_bootstrap OK (copied to shux_asm)"
echo "relink_experimental_bootstrap: verify: SHUX_S2_FAIL_ON_EMIT_HEAVY=1 ../tests/run-s2-typeck-emit-heavy.sh"
