#!/bin/sh
# g05_ensure_relink_prereqs.sh — G-05 100%：依赖齐备（纯 shell，不调用 make）
#
# 职责：
#   1) 加载 g05_relink_env.sh 清单
#   2) 热路径 C 源用 cc 强制重编（对齐历史 ensure 的 -B runtime / glue）
#   3) 检查 G05_OBJS 全部存在；缺失则失败并提示冷启动（Makefile 仅冷启动）
#
# 用法（compiler/ 目录）：
#   sh scripts/g05_ensure_relink_prereqs.sh
#
# 环境：
#   G05_SKIP_HOT_REBUILD=1  跳过热路径 cc 重编（仅检查）
#   G05_CC                  覆盖编译器（默认 cc）

set -e
cd "$(dirname "$0")/.."

echo "g05_ensure_relink_prereqs: load env (shell, no make)"
# shellcheck disable=SC2046
eval "$(sh scripts/g05_relink_env.sh)"

CC="${G05_CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
# 与 Makefile RUNTIME_DRIVER_NO_C_CFLAGS 一致（runtime.c → runtime_driver_no_c.o）
RUNTIME_DRIVER_NO_C_CFLAGS="-DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -DSHUX_NO_C_FRONTEND -DSHUX_ASM_USE_COMPILER_IMPL_C"

if [ ! -f "${G05_BOOTSTRAP:-bootstrap_shuxc}" ] && [ ! -f shux ] && [ ! -f shux-c ]; then
  echo "g05_ensure_relink_prereqs: missing bootstrap binary (bootstrap_shuxc/shux/shux-c)" >&2
  echo "  cold-start: make -C compiler bootstrap-driver-seed   # Makefile 冷启动实现层" >&2
  exit 1
fi

# --- 热路径：直接 cc -c（不经 make）；G-02e-22：.inc 走 cc_inc_tu ---
g05_cc_c() {
  # $1 = .o  $2 = .c|.inc  [$3...] = extra cflags
  _o="$1"
  _c="$2"
  shift 2
  if [ ! -f "$_c" ]; then
    echo "g05_ensure_relink_prereqs: missing source $_c" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$_o")"
  case "$_c" in
    *.inc)
      echo "g05_ensure: cc_inc_tu $_c → $_o"
      # shellcheck disable=SC2086
      sh scripts/cc_inc_tu.sh "$_c" "$_o" "$@"
      ;;
    *)
      echo "g05_ensure: cc -c $_c → $_o"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS "$@" -c -o "$_o" "$_c"
      ;;
  esac
}

if [ "${G05_SKIP_HOT_REBUILD:-}" != "1" ]; then
  echo "g05_ensure_relink_prereqs: hot rebuild (cc, no make)"
  g05_cc_c src/runtime_link_abi.o src/runtime_link_abi.inc
  # 注意：.o 名是 runtime_driver_no_c.o，源文件是 runtime.inc + NO_C flags
  g05_cc_c src/runtime_driver_no_c.o src/runtime.inc $RUNTIME_DRIVER_NO_C_CFLAGS
  # G-02f-12：runtime_pipeline_abi 产品 seed（须 SHUX_USE_X_PIPELINE）
  _rpabi=seeds/runtime_pipeline_abi.from_x.c
  if [ -f "$_rpabi" ]; then
    if [ ! -f src/runtime_pipeline_abi.o ] || [ "$_rpabi" -nt src/runtime_pipeline_abi.o ]; then
      echo "g05_ensure: runtime_pipeline_abi.o ← seed -DSHUX_USE_X_PIPELINE (G-02f-12)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_USE_X_PIPELINE -c -o src/runtime_pipeline_abi.o "$_rpabi"
    fi
  fi
  # G-02f-12：runtime_io / driver_abi / diagnostic / lsp ctx seeds
  for _pair in     "src/runtime_io_abi.o:seeds/runtime_io_abi.from_x.c"     "src/runtime_driver_abi.o:seeds/runtime_driver_abi.from_x.c"     "src/runtime_driver_diagnostic.o:seeds/runtime_driver_diagnostic.from_x.c"     "src/lsp/lsp_diag_pipeline_ctx.o:seeds/lsp_diag_pipeline_ctx.from_x.c"
  do
    _o="${_pair%%:*}"
    _s="${_pair#*:}"
    if [ -f "$_s" ]; then
      if [ ! -f "$_o" ] || [ "$_s" -nt "$_o" ]; then
        echo "g05_ensure: $_o ← seed (G-02f-12)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_o" "$_s"
      fi
    fi
  done
  # G-02f-11：pipeline_glue_strict_minimal 产品 seed
  _pglue=seeds/pipeline_glue_strict_minimal.from_x.c
  if [ -f "$_pglue" ]; then
    if [ ! -f build_asm/pipeline_glue_strict_minimal.o ] || [ "$_pglue" -nt build_asm/pipeline_glue_strict_minimal.o ]; then
      echo "g05_ensure: pipeline_glue_strict_minimal.o ← seed (G-02f-11)"
      mkdir -p build_asm
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o build_asm/pipeline_glue_strict_minimal.o "$_pglue"
    fi
  fi
  # G-02e：typeck_f64_bits 纯 .s
  _f64s=""
  case "${G05_UNAME_S:-$(uname -s)}/${G05_UNAME_M:-$(uname -m)}" in
    Linux/x86_64) _f64s=src/typeck/typeck_f64_bits_x86_64.s ;;
    Linux/aarch64) _f64s=src/typeck/typeck_f64_bits_aarch64_elf.s ;;
    Darwin/arm64) _f64s=src/typeck/typeck_f64_bits_arm64.s ;;
    Darwin/x86_64) _f64s=src/typeck/typeck_f64_bits_x86_64.s ;;
  esac
  if [ -n "$_f64s" ] && [ -f "$_f64s" ]; then
    if [ ! -f src/typeck/typeck_f64_bits.o ] || [ "$_f64s" -nt src/typeck/typeck_f64_bits.o ]; then
      echo "g05_ensure: cc -c $_f64s → src/typeck/typeck_f64_bits.o"
      $CC -c -o src/typeck/typeck_f64_bits.o "$_f64s"
    fi
  fi
  # G-02f-1：lsp_diag_pipeline_sizes_nostub 来自 .x 冷启动 C（非 .inc）
  _sizes_from_x=seeds/lsp_diag_pipeline_sizes.from_x.c
  if [ -f "$_sizes_from_x" ]; then
    if [ ! -f src/lsp/lsp_diag_pipeline_sizes_nostub.o ] || [ "$_sizes_from_x" -nt src/lsp/lsp_diag_pipeline_sizes_nostub.o ] \
      || [ src/lsp/lsp_diag_pipeline_sizes.x -nt src/lsp/lsp_diag_pipeline_sizes_nostub.o ] 2>/dev/null; then
      echo "g05_ensure: cc -c $_sizes_from_x → src/lsp/lsp_diag_pipeline_sizes_nostub.o (G-02f-1 .x)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -c -o src/lsp/lsp_diag_pipeline_sizes_nostub.o "$_sizes_from_x"
    fi
  fi
  # G-02f-6：target_cpu.o 单文件 pure seed（含 OS detect）
  _tcpure=seeds/target_cpu_pure.from_x.c
  if [ -f "$_tcpure" ]; then
    if [ ! -f src/driver/target_cpu.o ] || [ "$_tcpure" -nt src/driver/target_cpu.o ] \
      || [ src/driver/target_cpu_pure.x -nt src/driver/target_cpu.o ] 2>/dev/null; then
      echo "g05_ensure: target_cpu.o ← pure.from_x (G-02f-6 single TU)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/driver/target_cpu.o "$_tcpure"
    fi
  fi
  # G-02f-7：simd_enc.o 纯编码 seed
  _simd_enc=seeds/simd_enc.from_x.c
  if [ -f "$_simd_enc" ]; then
    if [ ! -f src/asm/simd_enc.o ] || [ "$_simd_enc" -nt src/asm/simd_enc.o ] \
      || [ src/asm/simd_enc.x -nt src/asm/simd_enc.o ] 2>/dev/null; then
      echo "g05_ensure: simd_enc.o ← simd_enc.from_x (G-02f-7)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_enc.o "$_simd_enc"
    fi
  fi
  # G-02f-8：simd_loop.o seed
  _simd_loop=seeds/simd_loop.from_x.c
  if [ -f "$_simd_loop" ]; then
    if [ ! -f src/asm/simd_loop.o ] || [ "$_simd_loop" -nt src/asm/simd_loop.o ] \
      || [ src/asm/simd_loop.x -nt src/asm/simd_loop.o ] 2>/dev/null; then
      echo "g05_ensure: simd_loop.o ← simd_loop.from_x (G-02f-8)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_loop.o "$_simd_loop"
    fi
  fi
  # G-02f-9：backend_*_dispatch 四件套 seed
  for _disp in backend_enc_dispatch backend_arch_emit_dispatch backend_try_inline_dispatch backend_call_dispatch; do
    _ds="seeds/${_disp}.from_x.c"
    _do="src/asm/${_disp}.o"
    if [ -f "$_ds" ]; then
      if [ ! -f "$_do" ] || [ "$_ds" -nt "$_do" ]; then
        echo "g05_ensure: ${_disp}.o ← ${_disp}.from_x (G-02f-9)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_do" "$_ds"
      fi
    fi
  done
  # G-02f-10：parser parse_expr_link + thin_glue seed
  _pel=seeds/parser_asm_parse_expr_link.from_x.c
  if [ -f "$_pel" ]; then
    if [ ! -f src/asm/parser_asm_parse_expr_link.o ] || [ "$_pel" -nt src/asm/parser_asm_parse_expr_link.o ]; then
      echo "g05_ensure: parser_asm_parse_expr_link.o ← seed (G-02f-10 SKIP_X)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS -c -o src/asm/parser_asm_parse_expr_link.o "$_pel"
    fi
  fi
  _pthin=seeds/parser_asm_thin_c.from_x.c
  if [ -f "$_pthin" ]; then
    if [ ! -f parser_asm_thin_glue.o ] || [ "$_pthin" -nt parser_asm_thin_glue.o ]; then
      echo "g05_ensure: parser_asm_thin_glue.o ← thin seed (G-02f-10)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
        -c -o parser_asm_thin_glue.o "$_pthin"
    fi
  fi
  # G-02f-11：中型产品桥 seed 单 TU
  _diag=seeds/diag.from_x.c
  if [ -f "$_diag" ]; then
    if [ ! -f src/diag.o ] || [ "$_diag" -nt src/diag.o ]; then
      echo "g05_ensure: diag.o ← seed (G-02f-11)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/diag.o "$_diag"
    fi
  fi
  _xsb=seeds/x_seed_bridge.from_x.c
  if [ -f "$_xsb" ]; then
    if [ ! -f src/x_seed_bridge.o ] || [ "$_xsb" -nt src/x_seed_bridge.o ]; then
      echo "g05_ensure: x_seed_bridge.o ← seed (G-02f-11)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/x_seed_bridge.o "$_xsb"
    fi
  fi
  _slc=seeds/seed_link_compat.from_x.c
  if [ -f "$_slc" ]; then
    if [ ! -f src/seed_link_compat.o ] || [ "$_slc" -nt src/seed_link_compat.o ]; then
      echo "g05_ensure: seed_link_compat.o ← seed (G-02f-11)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/seed_link_compat.o "$_slc"
    fi
  fi
  _rdss=seeds/runtime_driver_strict_glue_stubs.from_x.c
  if [ -f "$_rdss" ]; then
    if [ ! -f src/runtime_driver_strict_glue_stubs.o ] || [ "$_rdss" -nt src/runtime_driver_strict_glue_stubs.o ] \
      || [ src/runtime_heap_user.inc -nt src/runtime_driver_strict_glue_stubs.o ] 2>/dev/null; then
      echo "g05_ensure: runtime_driver_strict_glue_stubs.o ← seed (G-02f-11)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/runtime_driver_strict_glue_stubs.o "$_rdss"
    fi
  fi
  _fcc=seeds/fmt_check_cmd.from_x.c
  if [ -f "$_fcc" ]; then
    if [ ! -f src/driver/fmt_check_cmd_driver.o ] || [ "$_fcc" -nt src/driver/fmt_check_cmd_driver.o ]; then
      echo "g05_ensure: fmt_check_cmd_driver.o ← seed -DSHUX_USE_X_PIPELINE (G-02f-11)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_USE_X_PIPELINE -c -o src/driver/fmt_check_cmd_driver.o "$_fcc"
    fi
  fi
  # LANG-007：host-local typeck_gen.c 可能缺 S0 边界委托；补丁后若变更则重编 typeck_x.o


  if [ -f typeck_gen.c ] && [ -f scripts/patch_typeck_gen_lang007.py ]; then
    _tg_before=$(wc -c < typeck_gen.c | tr -d ' ')
    python3 scripts/patch_typeck_gen_lang007.py || true
    _tg_after=$(wc -c < typeck_gen.c | tr -d ' ')
    if [ "$_tg_before" != "$_tg_after" ] || [ ! -f typeck_x.o ] || [ typeck_gen.c -nt typeck_x.o ]; then
      echo "g05_ensure: cc -c typeck_gen.c → typeck_x.o (LANG-007 patch)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o typeck_x.o typeck_gen.c
    fi
  fi
  # G-02e：产品链 C 源缺失或比 .o 新时强制重编（并入/删 TU 后跨机 git pull 必走此路径）
  # shellcheck disable=SC2086
  for o in $G05_OBJS; do
    c="${o%.o}.c"
    inc="${o%.o}.inc"
    src=""
    if [ -f "$c" ]; then
      src="$c"
    elif [ -f "$inc" ]; then
      src="$inc"
    fi
    # special: runtime_driver_no_c.o 源是 runtime.c（上面已热编）
    case "$o" in
      # 已在热路径专用 flags / .x seed 编译
      src/runtime_driver_no_c.o|src/runtime_pipeline_abi.o|src/runtime_link_abi.o|src/runtime_io_abi.o|src/runtime_driver_abi.o|src/runtime_driver_diagnostic.o|src/lsp/lsp_diag_pipeline_ctx.o|src/typeck/typeck_f64_bits.o|src/lsp/lsp_diag_pipeline_sizes_nostub.o|src/driver/target_cpu.o|src/asm/simd_enc.o|src/asm/simd_loop.o|src/asm/backend_enc_dispatch.o|src/asm/backend_arch_emit_dispatch.o|src/asm/backend_try_inline_dispatch.o|src/asm/backend_call_dispatch.o|src/asm/parser_asm_parse_expr_link.o|parser_asm_thin_glue.o|src/diag.o|src/x_seed_bridge.o|src/seed_link_compat.o|src/runtime_driver_strict_glue_stubs.o|src/driver/fmt_check_cmd_driver.o|build_asm/*|*.s) continue ;;
    esac

    if [ -n "$src" ]; then
      if [ ! -f "$o" ] || [ "$src" -nt "$o" ]; then
        g05_cc_c "$o" "$src"
      fi
    fi
  done
fi

# --- 齐备检查 ---
mkdir -p build_asm/seed_host
miss=0
# shellcheck disable=SC2086
for o in $G05_OBJS; do
  if [ ! -f "$o" ]; then
    echo "g05_ensure_relink_prereqs: MISSING $o" >&2
    miss=$((miss + 1))
  fi
done

if [ "$miss" -ne 0 ]; then
  echo "g05_ensure_relink_prereqs: $miss object(s) missing" >&2
  echo "  G-05 产品路径不调用 make 编 .o；请先冷启动补齐依赖图：" >&2
  echo "    make -C compiler bootstrap-driver-seed" >&2
  echo "    # 或已有完整 build_asm/ 时：" >&2
  echo "    make -C compiler build-seed-asm-host pipeline_x.o driver_x.o" >&2
  exit 1
fi

n=$(echo "$G05_OBJS" | wc -w | tr -d ' ')
echo "g05_ensure_relink_prereqs OK ($n objs present, host=${G05_UNAME_S:-?}/${G05_UNAME_M:-?})"
