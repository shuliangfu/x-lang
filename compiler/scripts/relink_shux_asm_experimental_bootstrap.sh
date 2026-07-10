#!/usr/bin/env bash
# experimental bootstrap 重链：pipeline_x.o + X companions + seed C（与 build_shux_asm.sh 首链一致）。
# ast_pool.c 变更后须重编 pipeline_glue_standalone / pipeline_x，再本脚本重链 shux_asm.experimental。
# 用法：cd compiler && make lexer_x.o parser_x.o typeck_x.o codegen_x.o && ./scripts/relink_shux_asm_experimental_bootstrap.sh
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build_asm"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
SEED_O="$BUILD_DIR/asm_driver_seed"
BSTRICT_DISPATCH="src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o"
PARSER_EXPR_LINK_O="src/asm/parser_asm_parse_expr_link.o"
PARSER_ASM_PARTIAL="$BUILD_DIR/parser_asm_minimal_partial.o"

experimental_bootstrap_info() {
  printf 'info: relink_experimental_bootstrap: %s\n' "$*" >&2
}

experimental_bootstrap_warn() {
  printf 'warning: relink_experimental_bootstrap: %s\n' "$*" >&2
}

experimental_bootstrap_error() {
  printf 'build error: relink_experimental_bootstrap: %s\n' "$*" >&2
}

# codegen.c 引用 async_liveness / async_cps_codegen（与 Makefile OBJS_CORE、build_shux_asm 一致）。
ensure_async_cps_seed_objs() {
  local src out src_pair
  for src_pair in \
    "src/async/async_liveness.c:$SEED_O/async_liveness.o" \
    "src/async/async_cps_codegen.c:$SEED_O/async_cps_codegen.o"; do
    src="${src_pair%%:*}"
    out="${src_pair##*:}"
    if [ ! -f "$out" ] || [ "$src" -nt "$out" ]; then
      experimental_bootstrap_info "cc $src -> $out"
      mkdir -p "$(dirname "$out")"
      "$CC" $CFLAGS -c -o "$out" "$src"
    fi
  done
}
ensure_async_cps_seed_objs

# bootstrap-driver-seed 同款 C 种子 .o（experimental 链须 parser/typeck 等；缺则 ld 失败）。
ensure_asm_driver_seed_c_objs() {
  mkdir -p "$SEED_O"
  if [ ! -f "$SEED_O/lexer.o" ] || [ "src/asm/runtime_lexer_glue.c" -nt "$SEED_O/lexer.o" ]; then
    experimental_bootstrap_info "cc $SEED_O/lexer.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lexer.o" src/asm/runtime_lexer_glue.c
  fi
  if [ ! -f "$SEED_O/ast_seed.o" ] || [ "src/asm/runtime_ast_glue.c" -nt "$SEED_O/ast_seed.o" ]; then
    experimental_bootstrap_info "cc $SEED_O/ast_seed.o"
    "$CC" $CFLAGS -c -o "$SEED_O/ast_seed.o" src/asm/runtime_ast_glue.c
  fi
  # G-02a: typeck.c 已物理删除；typeck.o 由 typeck.x 生成（typeck_x.o），编排桩由 typeck_c_module_stubs.o 提供。
  # G-02a: codegen.c 已物理删除；codegen.o 由 codegen.x 生成（codegen_x.o），编排桩由 codegen_pipeline_stubs.o 提供。
  if [ ! -f "$SEED_O/lsp_diag.o" ] || [ "src/asm/runtime_lsp_glue.c" -nt "$SEED_O/lsp_diag.o" ]; then
    experimental_bootstrap_info "cc $SEED_O/lsp_diag.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lsp_diag.o" src/asm/runtime_lsp_glue.c
  fi
  if [ ! -f "$SEED_O/lsp_state.o" ] || [ "src/lsp/lsp_state.c" -nt "$SEED_O/lsp_state.o" ]; then
    experimental_bootstrap_info "cc $SEED_O/lsp_state.o"
    "$CC" $CFLAGS -c -o "$SEED_O/lsp_state.o" src/lsp/lsp_state.c
  fi
}
ensure_asm_driver_seed_c_objs

# ast_pool.c / pipeline_glue.c 变更后须重编 pipeline_x.o（glue 在 pipeline_gen.c #include 内）。
ensure_pipeline_x_fresh_for_ast_pool() {
  if [ -f ast_pool.c ] && { [ ! -f pipeline_x.o ] || [ ast_pool.c -nt pipeline_x.o ]; }; then
    experimental_bootstrap_info "ast_pool.c newer than pipeline_x.o - rebuild"
    if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
      make -s pipeline_x.o PIPELINE_X_FORCE_COMPILE=1 || {
        experimental_bootstrap_warn "pipeline_x.o rebuild failed"
        return 1
      }
    fi
  fi
  if [ -f pipeline_glue.c ] && { [ ! -f pipeline_x.o ] || [ pipeline_glue.c -nt pipeline_x.o ]; }; then
    experimental_bootstrap_info "pipeline_glue.c newer than pipeline_x.o - rebuild"
    if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
      make -s pipeline_x.o PIPELINE_X_FORCE_COMPILE=1 || {
        experimental_bootstrap_warn "pipeline_x.o rebuild failed"
        return 1
      }
    fi
  fi
  return 0
}
ensure_pipeline_x_fresh_for_ast_pool || true

# experimental 链符号桥（缺则 ld 失败）。
if [ ! -f "$BUILD_DIR/asm_experimental_symbol_bridge.o" ] || [ "src/asm/asm_experimental_symbol_bridge.c" -nt "$BUILD_DIR/asm_experimental_symbol_bridge.o" ]; then
  experimental_bootstrap_info "cc asm_experimental_symbol_bridge.o"
  "$CC" $CFLAGS -c -o "$BUILD_DIR/asm_experimental_symbol_bridge.o" src/asm/asm_experimental_symbol_bridge.c
fi

# runtime_asm_build.o（首链 bootstrap-asm 产物；缺则 ld 失败）。
if [ ! -f src/asm/runtime_asm_build.o ] || [ "src/asm/runtime_asm_build.c" -nt src/asm/runtime_asm_build.o ]; then
  experimental_bootstrap_info "cc runtime_asm_build.o"
  "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/runtime_asm_build.o src/asm/runtime_asm_build.c
fi

# B-strict shux_asm：driver_run_compiler_full 走 impl_c（与 build_shux_asm.sh 一致）。
ensure_runtime_abi_obj() {
  local o="src/runtime_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_abi.c" -nt "$o" ]; then
    experimental_bootstrap_info "cc $o <- src/runtime_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_abi.c
  fi
}
ensure_runtime_io_abi_obj() {
  local o="src/runtime_io_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_io_abi.c" -nt "$o" ]; then
    experimental_bootstrap_info "cc $o <- src/runtime_io_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_io_abi.c
  fi
}
ensure_runtime_proc_abi_obj() {
  local o="src/runtime_proc_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_proc_abi.c" -nt "$o" ]; then
    experimental_bootstrap_info "cc $o <- src/runtime_proc_abi.c"
    "$CC" $CFLAGS -c -o "$o" src/runtime_proc_abi.c
  fi
}
ensure_runtime_driver_asm_strict_obj() {
  ensure_runtime_abi_obj
  ensure_runtime_io_abi_obj
  ensure_runtime_proc_abi_obj
  local o="src/runtime_driver_asm_strict.o"
  if [ ! -f "$o" ] || [ "src/runtime.c" -nt "$o" ]; then
    experimental_bootstrap_info "cc $o <- src/runtime.c (-DSHUX_ASM_USE_COMPILER_IMPL_C)"
    "$CC" $CFLAGS -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS \
      -DSHUX_ASM_USE_COMPILER_IMPL_C -c -o "$o" src/runtime.c
  fi
}
ensure_runtime_driver_asm_strict_obj

# pipeline_glue / pipeline_x 引用 target_cpu / simd_enc / simd_loop（SIMD-S1–S4）。
ensure_simd_glue_link_objs() {
  # G-02e: f32 xmm ABI 并入 backend_call_dispatch.o（无独立 pipeline_abi_f32_xmm.o）
  if [ ! -f src/asm/backend_call_dispatch.o ] || [ src/asm/backend_call_dispatch.c -nt src/asm/backend_call_dispatch.o ]; then
    experimental_bootstrap_info "cc src/asm/backend_call_dispatch.o (incl. f32 xmm ABI)"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/backend_call_dispatch.o src/asm/backend_call_dispatch.c
  fi
  if [ ! -f src/driver/target_cpu.o ] || [ src/driver/target_cpu.c -nt src/driver/target_cpu.o ]; then
    experimental_bootstrap_info "cc src/driver/target_cpu.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/target_cpu.o src/driver/target_cpu.c
  fi
  if [ ! -f src/asm/simd_enc.o ] || [ src/asm/simd_enc.c -nt src/asm/simd_enc.o ]; then
    experimental_bootstrap_info "cc src/asm/simd_enc.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_enc.o src/asm/simd_enc.c
  fi
  if [ ! -f src/asm/simd_loop.o ] || [ src/asm/simd_loop.c -nt src/asm/simd_loop.o ]; then
    experimental_bootstrap_info "cc src/asm/simd_loop.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_loop.o src/asm/simd_loop.c
  fi
}
ensure_simd_glue_link_objs

# build_asm 伴生 .o（experimental 链与 build_shux_asm ensure_asm_bootstrap_x_companion_objs 对齐）。
ensure_experimental_companion_objs() {
  mkdir -p "$BUILD_DIR" "$BUILD_DIR/seed_host"
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    make -s parser_x.o lexer_x.o typeck_x.o codegen_x.o preprocess_x.o \
      x_frontend_link_alias.o \
      driver_x.o driver_fmt_x.o driver_check_x.o driver_test_x.o \
      driver_build_x.o driver_run_x.o driver_compile_x.o driver_emit_x.o \
      pipeline_bootstrap_orchestration.o 2>/dev/null || true
  fi
  if [ ! -f src/runtime_io_abi.o ] || [ src/runtime_io_abi.c -nt src/runtime_io_abi.o ]; then
    experimental_bootstrap_info "cc runtime_io_abi.o (incl. fs/sys shim)"
    "$CC" $CFLAGS -c -o src/runtime_io_abi.o src/runtime_io_abi.c
  fi
  if [ ! -f "$BUILD_DIR/x_seed_bridge.o" ] || [ "src/x_seed_bridge.c" -nt "$BUILD_DIR/x_seed_bridge.o" ]; then
    experimental_bootstrap_info "cc x_seed_bridge.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/x_seed_bridge.o" src/x_seed_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/ast_pool_l5_bridge.o" ] || [ "src/ast_pool_l5_bridge.c" -nt "$BUILD_DIR/ast_pool_l5_bridge.o" ]; then
    experimental_bootstrap_info "cc ast_pool_l5_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/ast_pool_l5_bridge.o" src/ast_pool_l5_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/lsp_codegen_extern.o" ] || [ "src/lsp/lsp_codegen_extern.c" -nt "$BUILD_DIR/lsp_codegen_extern.o" ]; then
    experimental_bootstrap_info "cc lsp_codegen_extern.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/lsp_codegen_extern.o" src/lsp/lsp_codegen_extern.c
  fi
  if [ ! -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ] || [ "src/asm/backend.x" -nt "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
    experimental_bootstrap_info "build_seed_asm_host (asm_backend_partial.o)"
    ./scripts/build_seed_asm_host.sh
  fi
  if [ ! -f src/asm/asm_backend_compat_stubs.o ] || [ "src/asm/asm_backend_compat_stubs.c" -nt src/asm/asm_backend_compat_stubs.o ]; then
    experimental_bootstrap_info "cc asm_backend_compat_stubs.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/asm_backend_compat_stubs.o src/asm/asm_backend_compat_stubs.c
  fi
  if [ ! -f src/asm/user_asm_seed_bridge.o ] || [ "src/asm/user_asm_seed_bridge.c" -nt src/asm/user_asm_seed_bridge.o ]; then
    experimental_bootstrap_info "cc user_asm_seed_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/user_asm_seed_bridge.o src/asm/user_asm_seed_bridge.c
  fi
}
ensure_experimental_companion_objs

# parser thin C glue（EMIT_HEAVY 第二遍 bl→parser_*_glue 符号）。
PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
PARSER_ASM_LINK_ALIAS_CFLAGS="-DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS"
PARSER_ASM_THIN_C="parser_asm_thin_glue.o"
if [ ! -f "$PARSER_ASM_THIN_C" ] || [ "src/asm/parser_asm_thin_c.c" -nt "$PARSER_ASM_THIN_C" ] \
  || [ "src/asm/parser_asm_struct_layout_slice.inc" -nt "$PARSER_ASM_THIN_C" ] \
  || [ "src/asm/parser_asm_block_from_res_slice.inc" -nt "$PARSER_ASM_THIN_C" ] \
  || [ "src/asm/parser_asm_if_stmt_slice.inc" -nt "$PARSER_ASM_THIN_C" ]; then
  experimental_bootstrap_info "cc parser_asm_thin_glue.o"
  "$CC" $CFLAGS $PARSER_ASM_THIN_GLUE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -c -o "$PARSER_ASM_THIN_C" src/asm/parser_asm_thin_c.c
fi

# parse_expr_into 桥 + pipeline 弱 parse 桩（G-02e-7：原 parser_asm_link_alias 并入）
if [ ! -f "$PARSER_EXPR_LINK_O" ] || [ "src/asm/parser_asm_parse_expr_link.c" -nt "$PARSER_EXPR_LINK_O" ]; then
  experimental_bootstrap_info "cc parser_asm_parse_expr_link.o"
  "$CC" $CFLAGS $PARSER_ASM_LINK_ALIAS_CFLAGS -c -o "$PARSER_EXPR_LINK_O" src/asm/parser_asm_parse_expr_link.c
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

# parser_x.o：Makefile 要求 parser_copy_module_import_path64 在 gen 内；experimental 链由 link_alias+thin_glue 提供。
ensure_parser_x_obj() {
  if [ -f parser_x.o ]; then
    return 0
  fi
  if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
    make -s parser_x.o 2>/dev/null || true
  fi
  if [ ! -f parser_x.o ] && [ -f parser_gen.c ]; then
    experimental_bootstrap_info "cc parser_gen.c -> parser_x.o (link_alias supplies parser_* pipeline symbols)"
    "$CC" $CFLAGS $(make -s -f Makefile print-PIPELINE_GEN_CFLAGS 2>/dev/null || echo "") \
      -I. -Iinclude -Isrc \
      -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len \
      -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr \
      -c parser_gen.c -o parser_x.o
  fi
  if [ ! -f parser_x.o ]; then
    experimental_bootstrap_error "missing parser_x.o (make parser_x.o or restore parser_gen.c)"
    exit 1
  fi
}
ensure_parser_x_obj

# 瘦 parser_x.o 无 parse_into_buf：默认 cc seed slice TU；X PARSE_BOOTSTRAP_EMIT 仍 139，仅 opt-in 探测。
ensure_parser_parse_bootstrap_asm_obj() {
  PARSER_PARSE_BOOT_O="$BUILD_DIR/parser_parse_bootstrap.o"
  PBOOT_C_SRC="src/asm/parser_asm_parse_bootstrap_obj.c"
  PBOOT_SEED_SLICE="src/asm/parser_asm_seed_parse_into_buf_slice.inc"
  mkdir -p "$BUILD_DIR"

  compile_parser_parse_bootstrap_cc_obj() {
    experimental_bootstrap_info "cc parser_asm_parse_bootstrap_obj.c -> $PARSER_PARSE_BOOT_O"
    if ! "$CC" $CFLAGS -c -o "$PARSER_PARSE_BOOT_O" "$PBOOT_C_SRC"; then
      experimental_bootstrap_warn "cc parser_parse_bootstrap.o failed"
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    if ! nm -g "$PARSER_PARSE_BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
      experimental_bootstrap_warn "parser_parse_bootstrap.o missing parse_into_buf"
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    return 0
  }

  try_parser_parse_bootstrap_x_emit() {
    SHUX_SEED="./shux"
    PBOOT_LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
    if [ -x ./shux_asm2_refreshed ] && file ./shux_asm2_refreshed 2>/dev/null | grep -q "ELF.*x86-64"; then
      _min="/tmp/shux_seed_parse_probe.$$.x"
      printf 'function main(): i32 { return 0; }\n' > "$_min"
      if ! env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 ./shux -backend asm -o /tmp/shux_seed_probe.$$.o \
          $PBOOT_LIBROOT "$_min" 2>/dev/null || [ ! -s /tmp/shux_seed_probe.$$.o ]; then
        SHUX_SEED="./shux_asm2_refreshed"
        experimental_bootstrap_warn "./shux parse probe failed - bootstrap seed=$SHUX_SEED"
      fi
      rm -f "$_min" /tmp/shux_seed_probe.$$.o 2>/dev/null || true
    fi
    if [ ! -x "$SHUX_SEED" ]; then
      return 1
    fi
    if [ -f ast_pool.c ] && { [ ! -f pipeline_x.o ] || [ ast_pool.c -nt pipeline_x.o ]; }; then
      experimental_bootstrap_info "ast_pool.c newer - rebuild pipeline_x.o for parse bootstrap"
      if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
        make -s pipeline_x.o PIPELINE_X_FORCE_COMPILE=1 || true
      fi
    fi
    if [ -f pipeline_x.o ] && [ pipeline_x.o -nt "$SHUX_SEED" ] 2>/dev/null; then
      experimental_bootstrap_info "refresh ./shux (pipeline_x.o for parse bootstrap emit)"
      if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
        make -s relink-shux 2>/dev/null || true
      fi
    fi
    experimental_bootstrap_info "$SHUX_SEED asm parser parse bootstrap (SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT opt-in)"
    ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
    if ! env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
        "$SHUX_SEED" -backend asm -o "$PARSER_PARSE_BOOT_O" $PBOOT_LIBROOT src/parser/parser.x \
        2>"$BUILD_DIR/.parser_parse_bootstrap_err"; then
      experimental_bootstrap_warn "parser parse bootstrap X emit failed"
      tail -8 "$BUILD_DIR/.parser_parse_bootstrap_err" 2>/dev/null | sed 's/^/  /' || true
      rm -f "$PARSER_PARSE_BOOT_O"
      return 1
    fi
    if ! nm -g "$PARSER_PARSE_BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
      experimental_bootstrap_warn "X bootstrap .o missing parse_into_buf"
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
    if [ "${SHUX_ASM_PARSER_PARSE_BOOTSTRAP_X_EMIT:-0}" = "1" ]; then
      try_parser_parse_bootstrap_x_emit || compile_parser_parse_bootstrap_cc_obj || true
    else
      compile_parser_parse_bootstrap_cc_obj || true
    fi
  fi

  if [ ! -f "$PARSER_PARSE_BOOT_O" ]; then
    PARSER_PARSE_BOOT_O=""
  fi
  # parser_x.o 已真 emit parse_into* 时勿再链 bootstrap .o（否则 ld multiple definition）。
  if [ -f parser_x.o ] && nm parser_x.o 2>/dev/null | grep -qE '[[:space:]]T parser_parse_into_buf$'; then
    PARSER_PARSE_BOOT_O=""
  fi
}
ensure_parser_parse_bootstrap_asm_obj

for o in pipeline_x.o pipeline_bootstrap_orchestration.o preprocess_x.o lexer_x.o typeck_x.o codegen_x.o \
  x_frontend_link_alias.o \
  driver_fmt_x.o driver_check_x.o driver_test_x.o driver_build_x.o driver_run_x.o driver_compile_x.o driver_emit_x.o; do
  if [ ! -f "$o" ]; then
    experimental_bootstrap_error "missing $o (make $o)"
    exit 1
  fi
done

PIPELINE_RUN_X_ALIAS_O="src/asm/pipeline_run_x_link_alias.o"
if [ ! -f "$PIPELINE_RUN_X_ALIAS_O" ] || [ "src/asm/pipeline_run_x_link_alias.c" -nt "$PIPELINE_RUN_X_ALIAS_O" ]; then
  experimental_bootstrap_info "cc pipeline_run_x_link_alias.o"
  "$CC" $CFLAGS -c -o "$PIPELINE_RUN_X_ALIAS_O" src/asm/pipeline_run_x_link_alias.c
fi

# Linux：std/io io_uring 须 -luring（与 build_shux_asm.sh PIPELINE_LIBS 一致）。
PIPELINE_LIBS=""
if [ "$(uname -s)" = "Linux" ]; then
  PIPELINE_LIBS="-luring -lpthread"
fi

experimental_bootstrap_info "linking shux_asm.experimental"
# seed parser/typeck/codegen/lexer 供 runtime/lsp_diag 链接；parser_x/typeck_x 须链在末尾压过重复 glue（build_shux_asm ST_PARSER_X_TAIL）。
# lsp_state.o 依赖 typeck_lsp_main_impl（与 strict_glue ensure_strict_glue_lsp_objs 一致）。
ensure_experimental_lsp_objs() {
  GEN_DIR="$BUILD_DIR/gen_driver"
  mkdir -p "$GEN_DIR"
  if [ ! -f Makefile ] || ! command -v make >/dev/null 2>&1; then
    experimental_bootstrap_warn "cannot make lsp_x.o"
    return 1
  fi
  make -s lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
    lsp_x.o lsp_io_x.o lsp_diag_x.o lsp_io_std_heap_x.o
  cp -f lsp_x.o lsp_io_x.o lsp_diag_x.o lsp_io_std_heap_x.o "$GEN_DIR/"
}
ensure_experimental_lsp_objs || true
ST_LSP_X=""
if [ -f "$BUILD_DIR/gen_driver/lsp_x.o" ]; then
  ST_LSP_X="$BUILD_DIR/gen_driver/lsp_x.o $BUILD_DIR/gen_driver/lsp_io_x.o $BUILD_DIR/gen_driver/lsp_io_std_heap_x.o $BUILD_DIR/gen_driver/lsp_diag_x.o"
fi
if [ ! -f "$BUILD_DIR/asm_shux_lsp_diag_stub.o" ] || [ "scripts/asm_shux_lsp_diag_stub.c" -nt "$BUILD_DIR/asm_shux_lsp_diag_stub.o" ]; then
  "$CC" $CFLAGS -c -o "$BUILD_DIR/asm_shux_lsp_diag_stub.o" scripts/asm_shux_lsp_diag_stub.c
fi
ST_LSP_DIAG_STUB="$BUILD_DIR/asm_shux_lsp_diag_stub.o"
GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
PIPELINE_GEN_CFLAGS="-O2 -g -fno-strict-aliasing -DPIPELINE_GEN_STANDALONE"
if [ ! -f "$GLUE_O" ] || [ "src/asm/pipeline_glue_standalone.c" -nt "$GLUE_O" ] \
  || [ "pipeline_glue.c" -nt "$GLUE_O" ] || [ "ast_pool.c" -nt "$GLUE_O" ]; then
  experimental_bootstrap_info "cc pipeline_glue_standalone.o"
  mkdir -p "$BUILD_DIR"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I"$BUILD_DIR" -c -o "$GLUE_O" src/asm/pipeline_glue_standalone.c
fi
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  EXP_ALLOW_MULTIDEF="-Wl,-multiply_defined -Wl,suppress"
else
  EXP_ALLOW_MULTIDEF="-Wl,--allow-multiple-definition"
fi
"$CC" $CFLAGS $EXP_ALLOW_MULTIDEF -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -o shux_asm.experimental \
  src/asm/runtime_asm_build.o \
  "$GLUE_O" \
  src/runtime_abi.o \
  src/runtime_io_abi.o \
  src/runtime_proc_abi.o \
  src/runtime_driver_asm_strict.o \
  pipeline_x.o \
  pipeline_bootstrap_orchestration.o \
  preprocess_x.o \
  "$BUILD_DIR/ast_pool_l5_bridge.o" \
  driver_fmt_x.o driver_check_x.o driver_test_x.o driver_build_x.o driver_run_x.o driver_compile_x.o driver_emit_x.o \
  src/runtime_io_abi.o \
  src/runtime_io_abi.o \
  "$BUILD_DIR/x_seed_bridge.o" \
  "$BUILD_DIR/seed_host/asm_backend_partial.o" \
  src/asm/user_asm_seed_bridge.o \
  src/asm/asm_backend_compat_stubs.o \
  src/asm/pipeline_run_x_link_alias.o \
  $BSTRICT_DISPATCH \
  src/driver/fmt_check_cmd_driver.o \
  src/driver/target_cpu.o \
  src/asm/simd_enc.o \
  src/asm/simd_loop.o \
  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
  ${PARSER_PARSE_BOOT_O:+"$PARSER_PARSE_BOOT_O"} \
  $ST_LSP_DIAG_STUB \
  "$BUILD_DIR/lsp_codegen_extern.o" \
  "$SEED_O/async_liveness.o" \
  "$SEED_O/async_cps_codegen.o" \
  "$SEED_O/ast_seed.o" \
  "$SEED_O/lexer.o" \
  "$SEED_O/parser.o" \
  "$SEED_O/lsp_diag.o" \
  $ST_LSP_X \
  "$SEED_O/lsp_state.o" \
  src/lsp/lsp_diag_pipeline_sizes.o \
  "$PARSER_ASM_THIN_C" \
  "$PARSER_EXPR_LINK_O" \
  parser_x.o lexer_x.o typeck_x.o codegen_x.o \
  x_frontend_link_alias.o \
  -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.relink_experimental_bootstrap_err"

if [ ! -x shux_asm.experimental ]; then
  experimental_bootstrap_error "link failed"
  tail -n 12 "$BUILD_DIR/.relink_experimental_bootstrap_err" 2>/dev/null | sed 's/^/  /' || true
  exit 1
fi

cp -f shux_asm.experimental shux_asm
experimental_bootstrap_info "OK (copied to shux_asm)"
experimental_bootstrap_info "verify: SHUX_S2_FAIL_ON_EMIT_HEAVY=1 ../tests/run-s2-typeck-emit-heavy.sh"
