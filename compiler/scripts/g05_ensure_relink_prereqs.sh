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
#   SHUX_G05_PREFER_X_O=1   L2：优先 .x→C(-E)→.o（失败回退 seed；见 analysis/G-02f-L2-x-o-pilot.md）
#                           TUs：sizes + target_cpu_flags + strict_glue_thin（G-02f-256～258）

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

# G-02f-256/257/258 / L2：.x → shux -backend c -E → cc -c → .o
# 返回 0 成功；失败不删既有 .o（调用方回退 seed）。
# $1=.x  $2=.o  [$3...]=extra cflags for cc
# 环境：G05_X_O_WEAK=1 时给顶层函数加 __attribute__((weak))
#       （strict_glue 等与 bootstrap_seed_pipeline_filtered 同名符号需 weak，对齐 seed）
g05_try_x_to_o() {
  _xsrc="$1"
  _xout="$2"
  shift 2
  _xshux=""
  if [ -x ./shux ]; then
    _xshux=./shux
  elif [ -x ./shux-c ]; then
    _xshux=./shux-c
  elif [ -x ./bootstrap_shuxc ]; then
    _xshux=./bootstrap_shuxc
  else
    return 1
  fi
  if [ ! -f "$_xsrc" ]; then
    return 1
  fi
  mkdir -p "$(dirname "$_xout")"
  _xtmp=$(mktemp "${TMPDIR:-/tmp}/g05_x_XXXXXX.c") || return 1
  # 优先默认 -E（Linux 上 -backend c -E 可能 SIGSEGV）；再回退 -backend c -E
  # shellcheck disable=SC2086
  if ! "$_xshux" -E "$_xsrc" >"$_xtmp" 2>/dev/null || [ ! -s "$_xtmp" ]; then
    : >"$_xtmp"
    if ! "$_xshux" -backend c -E "$_xsrc" >"$_xtmp" 2>/dev/null || [ ! -s "$_xtmp" ]; then
      rm -f "$_xtmp"
      return 1
    fi
  fi
  if [ "${G05_X_O_WEAK:-0}" = "1" ]; then
    # 仅改非 static 的简单返回类型函数定义行（-E 产物形态）
    perl -i -pe 's/^(void|int32_t|int|size_t|uint8_t|uint32_t|uint64_t)\s+(\w+)\s*\(/__attribute__((weak)) $1 $2(/' "$_xtmp" || true
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS "$@" -c -o "$_xout" "$_xtmp"; then
    rm -f "$_xtmp"
    return 1
  fi
  rm -f "$_xtmp"
  return 0
}

# G-02f-257：1:1 L2 表项 — $1=.o $2=.x $3=seed.c $4=label
# PREFER_X_O=1 时优先 .x；失败或未设则 seed cc。
g05_ensure_l2_or_seed() {
  _l2_o="$1"
  _l2_x="$2"
  _l2_seed="$3"
  _l2_label="$4"
  if [ ! -f "$_l2_o" ] \
    || { [ -f "$_l2_seed" ] && [ "$_l2_seed" -nt "$_l2_o" ]; } \
    || { [ -f "$_l2_x" ] && [ "$_l2_x" -nt "$_l2_o" ]; }; then
    _l2_done=0
    if [ "${SHUX_G05_PREFER_X_O:-0}" = "1" ] && [ -f "$_l2_x" ]; then
      if g05_try_x_to_o "$_l2_x" "$_l2_o"; then
        echo "g05_ensure: $_l2_o ← $_l2_x (G-02f-257 L2 prefer .x: $_l2_label)"
        _l2_done=1
      else
        echo "g05_ensure: L2 prefer .x failed for $_l2_label; fallback seed" >&2
      fi
    fi
    if [ "$_l2_done" = "0" ] && [ -f "$_l2_seed" ]; then
      echo "g05_ensure: cc -c $_l2_seed → $_l2_o ($_l2_label seed)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -c -o "$_l2_o" "$_l2_seed"
    fi
  fi
}

if [ "${G05_SKIP_HOT_REBUILD:-}" != "1" ]; then
  echo "g05_ensure_relink_prereqs: hot rebuild (cc, no make)"
  # G-02f-13 / G-02f-267～272：runtime_link_abi.o ← seed（G05 hot）
  # PREFER_X_O=1：L0..L3 + L8 std list + L8b on_demand hybrid → rest（SHUX_LABI_*_FROM_X）
  _rlink=seeds/runtime_link_abi.from_x.c
  _labi_l0_seed=seeds/labi_path_pure.from_x.c
  _labi_l1_seed=seeds/labi_diag_pure.from_x.c
  _labi_l2_seed=seeds/labi_host_lit.from_x.c
  _labi_l3_seed=seeds/labi_path_io.from_x.c
  _labi_l8_seed=seeds/labi_std_list.from_x.c
  _labi_l8b_seed=seeds/labi_ondemand_list.from_x.c
  _labi_o=src/runtime_link_abi.o
  if [ -f "$_rlink" ]; then
    if [ ! -f "$_labi_o" ] || [ "$_rlink" -nt "$_labi_o" ] \
      || { [ -f "$_labi_l0_seed" ] && [ "$_labi_l0_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l1_seed" ] && [ "$_labi_l1_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l2_seed" ] && [ "$_labi_l2_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l3_seed" ] && [ "$_labi_l3_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8_seed" ] && [ "$_labi_l8_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8b_seed" ] && [ "$_labi_l8b_seed" -nt "$_labi_o" ]; }; then
      _labi_done=0
      if [ "${SHUX_G05_PREFER_X_O:-0}" = "1" ] && [ -f "$_labi_l0_seed" ]; then
        _labi_l0_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l0.XXXXXX") || true
        _labi_l1_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l1.XXXXXX") || true
        _labi_l2_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l2.XXXXXX") || true
        _labi_l3_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l3.XXXXXX") || true
        _labi_l8_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l8.XXXXXX") || true
        _labi_l8b_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l8b.XXXXXX") || true
        _labi_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_rest.XXXXXX") || true
        _labi_l0_ok=0
        _labi_l1_ok=0
        _labi_l2_ok=0
        _labi_l3_ok=0
        _labi_l8_ok=0
        _labi_l8b_ok=0
        if [ -n "$_labi_l0_o" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l0_o" "$_labi_l0_seed"; then
            _labi_l0_ok=1
            echo "g05_ensure: L0 path pure ← $_labi_l0_seed (G-02f-267 seed slice)"
          fi
        fi
        if [ -n "$_labi_l1_o" ] && [ -f "$_labi_l1_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l1_o" "$_labi_l1_seed"; then
            _labi_l1_ok=1
            echo "g05_ensure: L1 diag pure ← $_labi_l1_seed (G-02f-268 seed slice)"
          fi
        fi
        if [ -n "$_labi_l2_o" ] && [ -f "$_labi_l2_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l2_o" "$_labi_l2_seed"; then
            _labi_l2_ok=1
            echo "g05_ensure: L2 host lit ← $_labi_l2_seed (G-02f-269 seed slice)"
          fi
        fi
        if [ -n "$_labi_l3_o" ] && [ -f "$_labi_l3_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l3_o" "$_labi_l3_seed"; then
            _labi_l3_ok=1
            echo "g05_ensure: L3 path IO ← $_labi_l3_seed (G-02f-270 seed slice)"
          fi
        fi
        if [ -n "$_labi_l8_o" ] && [ -f "$_labi_l8_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l8_o" "$_labi_l8_seed"; then
            _labi_l8_ok=1
            echo "g05_ensure: L8 std list ← $_labi_l8_seed (G-02f-271 seed slice)"
          fi
        fi
        if [ -n "$_labi_l8b_o" ] && [ -f "$_labi_l8b_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l8b_o" "$_labi_l8b_seed"; then
            _labi_l8b_ok=1
            echo "g05_ensure: L8b on_demand list ← $_labi_l8b_seed (G-02f-272 seed slice)"
          fi
        fi
        _labi_rest_defs="-DSHUX_LABI_PATH_PURE_FROM_X"
        if [ "$_labi_l1_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_DIAG_PURE_FROM_X"
        fi
        if [ "$_labi_l2_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_HOST_LIT_FROM_X"
        fi
        if [ "$_labi_l3_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_PATH_IO_FROM_X"
        fi
        if [ "$_labi_l8_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_STD_LIST_FROM_X"
        fi
        if [ "$_labi_l8b_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_ONDEMAND_LIST_FROM_X"
        fi
        # shellcheck disable=SC2086
        if [ "$_labi_l0_ok" = "1" ] && [ -n "$_labi_rest_o" ] \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc $_labi_rest_defs \
               -c -o "$_labi_rest_o" "$_rlink"; then
          _labi_link="$_labi_l0_o"
          if [ "$_labi_l1_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l1_o"
          fi
          if [ "$_labi_l2_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l2_o"
          fi
          if [ "$_labi_l3_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l3_o"
          fi
          if [ "$_labi_l8_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l8_o"
          fi
          if [ "$_labi_l8b_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l8b_o"
          fi
          # shellcheck disable=SC2086
          if $CC -r -nostdlib -o "$_labi_o" $_labi_link "$_labi_rest_o" 2>/dev/null; then
            echo "g05_ensure: $_labi_o ← L0/L1/L2/L3/L8/L8b + link_abi rest (G-02f-272 hybrid)"
            _labi_done=1
          fi
        fi
        if [ "$_labi_done" = "0" ]; then
          echo "g05_ensure: L0/L1/L2/L3/L8/L8b link_abi hybrid failed; fallback full seed" >&2
        fi
        rm -f "$_labi_l0_o" "$_labi_l1_o" "$_labi_l2_o" "$_labi_l3_o" "$_labi_l8_o" "$_labi_l8b_o" "$_labi_rest_o"
      fi
      if [ "$_labi_done" = "0" ]; then
        echo "g05_ensure: runtime_link_abi.o ← seed (G-02f-13)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_o" "$_rlink"
      fi
    fi
  fi
  # G-02f-14 / G-02f-261～265：runtime_driver_no_c.o ← seeds/runtime.from_x.c + NO_C flags
  # PREFER_X_O=1：R2/R0/R1/R5-lite/R3 preamble 切片 hybrid → rest（SHUX_RT_*_FROM_X）
  # 注：RFC R4 DCE 在 !SHUX_USE_X_DRIVER 下，不进产品 .o
  _rt=seeds/runtime.from_x.c
  _rt_content_x=src/runtime/rt_content.x
  _rt_content_seed=seeds/rt_content.from_x.c
  _rt_util_seed=seeds/rt_util.from_x.c
  _rt_argv_seed=seeds/rt_argv.from_x.c
  _rt_ef_seed=seeds/rt_emit_flags.from_x.c
  _rt_pre_seed=seeds/rt_preamble.from_x.c
  _rt_o=src/runtime_driver_no_c.o
  if [ -f "$_rt" ]; then
    if [ ! -f "$_rt_o" ] || [ "$_rt" -nt "$_rt_o" ] \
      || { [ -f "$_rt_content_seed" ] && [ "$_rt_content_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_util_seed" ] && [ "$_rt_util_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_argv_seed" ] && [ "$_rt_argv_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_ef_seed" ] && [ "$_rt_ef_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_pre_seed" ] && [ "$_rt_pre_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_content_x" ] && [ "$_rt_content_x" -nt "$_rt_o" ]; }; then
      _rt_done=0
      if [ "${SHUX_G05_PREFER_X_O:-0}" = "1" ] && [ -f "$_rt_content_seed" ]; then
        _rt_c_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_content.XXXXXX") || true
        _rt_u_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_util.XXXXXX") || true
        _rt_a_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_argv.XXXXXX") || true
        _rt_e_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_eflags.XXXXXX") || true
        _rt_p_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_pre.XXXXXX") || true
        _rt_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_rest.XXXXXX") || true
        _rt_content_ok=0
        _rt_util_ok=0
        _rt_argv_ok=0
        _rt_ef_ok=0
        _rt_pre_ok=0
        if [ -n "$_rt_c_o" ] && [ -f "$_rt_content_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_c_o" "$_rt_content_seed"; then
            _rt_content_ok=1
            echo "g05_ensure: R2 content ← $_rt_content_seed (G-02f-261 seed slice)"
          fi
        fi
        if [ -n "$_rt_u_o" ] && [ -f "$_rt_util_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_u_o" "$_rt_util_seed"; then
            _rt_util_ok=1
            echo "g05_ensure: R0 util ← $_rt_util_seed (G-02f-262 seed slice)"
          fi
        fi
        if [ -n "$_rt_a_o" ] && [ -f "$_rt_argv_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_a_o" "$_rt_argv_seed"; then
            _rt_argv_ok=1
            echo "g05_ensure: R1 argv ← $_rt_argv_seed (G-02f-263 seed slice)"
          fi
        fi
        if [ -n "$_rt_e_o" ] && [ -f "$_rt_ef_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_e_o" "$_rt_ef_seed"; then
            _rt_ef_ok=1
            echo "g05_ensure: R5-lite emit_flags ← $_rt_ef_seed (G-02f-264 seed slice)"
          fi
        fi
        if [ -n "$_rt_p_o" ] && [ -f "$_rt_pre_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_p_o" "$_rt_pre_seed"; then
            _rt_pre_ok=1
            echo "g05_ensure: R3 preamble ← $_rt_pre_seed (G-02f-265 seed slice)"
          fi
        fi
        _rt_rest_defs="-DSHUX_RT_CONTENT_FROM_X"
        if [ "$_rt_util_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_UTIL_FROM_X"
        fi
        if [ "$_rt_argv_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_ARGV_FROM_X"
        fi
        if [ "$_rt_ef_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_EMIT_FLAGS_FROM_X"
        fi
        if [ "$_rt_pre_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_PREAMBLE_FROM_X"
        fi
        # shellcheck disable=SC2086
        if [ "$_rt_content_ok" = "1" ] && [ -n "$_rt_rest_o" ] \
          && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc \
               $_rt_rest_defs -c -o "$_rt_rest_o" "$_rt"; then
          _rt_link_objs="$_rt_c_o"
          if [ "$_rt_util_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_u_o"
          fi
          if [ "$_rt_argv_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_a_o"
          fi
          if [ "$_rt_ef_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_e_o"
          fi
          if [ "$_rt_pre_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_p_o"
          fi
          # shellcheck disable=SC2086
          if $CC -r -nostdlib -o "$_rt_o" $_rt_link_objs "$_rt_rest_o" 2>/dev/null; then
            echo "g05_ensure: $_rt_o ← R2/R0/R1/R5-lite/R3 slices + rest (G-02f-265 hybrid)"
            _rt_done=1
          fi
        fi
        if [ "$_rt_done" = "0" ]; then
          echo "g05_ensure: L2 hybrid runtime slices failed; fallback full seed" >&2
        fi
        rm -f "$_rt_c_o" "$_rt_u_o" "$_rt_a_o" "$_rt_e_o" "$_rt_p_o" "$_rt_rest_o"
      fi
      if [ "$_rt_done" = "0" ]; then
        echo "g05_ensure: runtime_driver_no_c.o ← seed + NO_C (G-02f-14)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_o" "$_rt"
      fi
    fi
  fi
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
  # G-02f-256/257 L2 表：1:1 pure TUs（默认 seed；PREFER_X_O=1 优先 .x）
  g05_ensure_l2_or_seed \
    src/lsp/lsp_diag_pipeline_sizes_nostub.o \
    src/lsp/lsp_diag_pipeline_sizes.x \
    seeds/lsp_diag_pipeline_sizes.from_x.c \
    "sizes_nostub"
  # G-02f-6 / G-02f-257：target_cpu.o
  # 默认：整文件 pure seed（含 OS detect）
  # PREFER_X_O=1：flags.x（pending/tolower/eq5/eq6）+ seed 残体 ld -r
  _tcpure=seeds/target_cpu_pure.from_x.c
  _tcflags_x=src/driver/target_cpu_flags.x
  _tc_o=src/driver/target_cpu.o
  if [ -f "$_tcpure" ]; then
    if [ ! -f "$_tc_o" ] || [ "$_tcpure" -nt "$_tc_o" ] \
      || { [ -f src/driver/target_cpu_pure.x ] && [ src/driver/target_cpu_pure.x -nt "$_tc_o" ]; } \
      || { [ -f "$_tcflags_x" ] && [ "$_tcflags_x" -nt "$_tc_o" ]; }; then
      _tc_done=0
      if [ "${SHUX_G05_PREFER_X_O:-0}" = "1" ] && [ -f "$_tcflags_x" ]; then
        _tc_flags_o=$(mktemp "${TMPDIR:-/tmp}/g05_tc_flags_XXXXXX.o") || true
        _tc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_tc_rest_XXXXXX.o") || true
        # shellcheck disable=SC2086
        if [ -n "$_tc_flags_o" ] && [ -n "$_tc_rest_o" ] \
          && g05_try_x_to_o "$_tcflags_x" "$_tc_flags_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_TARGET_CPU_FLAGS_FROM_X \
               -c -o "$_tc_rest_o" "$_tcpure" \
          && $CC -r -nostdlib -o "$_tc_o" "$_tc_flags_o" "$_tc_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_tc_o ← $_tcflags_x + seed-rest (G-02f-257 L2 hybrid flags)"
          _tc_done=1
        else
          echo "g05_ensure: L2 hybrid target_cpu flags failed; fallback full seed" >&2
        fi
        rm -f "$_tc_flags_o" "$_tc_rest_o"
      fi
      if [ "$_tc_done" = "0" ]; then
        echo "g05_ensure: target_cpu.o ← pure.from_x (G-02f-6 single TU)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_tc_o" "$_tcpure"
      fi
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
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
        -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
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
  # G-02f-11 / G-02f-258：strict_glue_stubs.o
  # 默认整 seed；PREFER_X_O=1 时 thin.x（asm_driver/i32/metrics peek）+ seed 残体 ld -r
  _rdss=seeds/runtime_driver_strict_glue_stubs.from_x.c
  _rdss_thin_x=src/runtime_driver_strict_glue_thin.x
  _rdss_o=src/runtime_driver_strict_glue_stubs.o
  if [ -f "$_rdss" ]; then
    if [ ! -f "$_rdss_o" ] || [ "$_rdss" -nt "$_rdss_o" ] \
      || { [ -f seeds/runtime_heap_user.from_x.c ] && [ seeds/runtime_heap_user.from_x.c -nt "$_rdss_o" ]; } \
      || { [ -f "$_rdss_thin_x" ] && [ "$_rdss_thin_x" -nt "$_rdss_o" ]; }; then
      _rdss_done=0
      if [ "${SHUX_G05_PREFER_X_O:-0}" = "1" ] && [ -f "$_rdss_thin_x" ]; then
        _rdss_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdss_thin_XXXXXX.o") || true
        _rdss_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdss_rest_XXXXXX.o") || true
        # shellcheck disable=SC2086
        # thin 符号须 weak，否则与 bootstrap_seed_pipeline_filtered 强符号冲突
        if [ -n "$_rdss_thin_o" ] && [ -n "$_rdss_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_rdss_thin_x" "$_rdss_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_STRICT_GLUE_THIN_FROM_X \
               -c -o "$_rdss_rest_o" "$_rdss" \
          && $CC -r -nostdlib -o "$_rdss_o" "$_rdss_thin_o" "$_rdss_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_rdss_o ← $_rdss_thin_x + seed-rest (G-02f-258 L2 hybrid thin weak)"
          _rdss_done=1
        else
          echo "g05_ensure: L2 hybrid strict_glue thin failed; fallback full seed" >&2
        fi
        rm -f "$_rdss_thin_o" "$_rdss_rest_o"
      fi
      if [ "$_rdss_done" = "0" ]; then
        echo "g05_ensure: runtime_driver_strict_glue_stubs.o ← seed (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rdss_o" "$_rdss"
      fi
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
  # G-02f-15：lsp_diag + USER_ASM seed bridges
  _lspg=seeds/runtime_lsp_glue.from_x.c
  if [ -f "$_lspg" ]; then
    if [ ! -f src/lsp/lsp_diag.o ] || [ "$_lspg" -nt src/lsp/lsp_diag.o ]; then
      echo "g05_ensure: lsp_diag.o ← runtime_lsp_glue seed (G-02f-15)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/lsp/lsp_diag.o "$_lspg"
    fi
  fi
  for _pair in \
    "src/asm/user_asm_seed_bridge.o:seeds/user_asm_seed_bridge.from_x.c" \
    "src/asm/asm_backend_compat_stubs.o:seeds/asm_backend_compat_stubs.from_x.c" \
    "src/asm/backend_x86_64_enc_c.o:seeds/backend_x86_64_enc_c.from_x.c"
  do
    _o="${_pair%%:*}"
    _s="${_pair#*:}"
    if [ -f "$_s" ]; then
      if [ ! -f "$_o" ] || [ "$_s" -nt "$_o" ]; then
        echo "g05_ensure: $_o ← seed (G-02f-15)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_o" "$_s"
      fi
    fi
  done
  # G-02f-16：x_frontend_link_alias 产品 seed
  _xfla=seeds/x_frontend_link_alias.from_x.c
  if [ -f "$_xfla" ]; then
    if [ ! -f x_frontend_link_alias.o ] || [ "$_xfla" -nt x_frontend_link_alias.o ]; then
      echo "g05_ensure: x_frontend_link_alias.o ← seed (G-02f-16)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o x_frontend_link_alias.o "$_xfla"
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
      src/runtime_driver_no_c.o|src/runtime_pipeline_abi.o|src/runtime_link_abi.o|src/runtime_io_abi.o|src/runtime_driver_abi.o|src/runtime_driver_diagnostic.o|src/lsp/lsp_diag_pipeline_ctx.o|src/typeck/typeck_f64_bits.o|src/lsp/lsp_diag_pipeline_sizes_nostub.o|src/driver/target_cpu.o|src/asm/simd_enc.o|src/asm/simd_loop.o|src/asm/backend_enc_dispatch.o|src/asm/backend_arch_emit_dispatch.o|src/asm/backend_try_inline_dispatch.o|src/asm/backend_call_dispatch.o|src/asm/parser_asm_parse_expr_link.o|parser_asm_thin_glue.o|src/diag.o|src/x_seed_bridge.o|src/seed_link_compat.o|src/runtime_driver_strict_glue_stubs.o|src/driver/fmt_check_cmd_driver.o|src/lsp/lsp_diag.o|src/asm/user_asm_seed_bridge.o|src/asm/asm_backend_compat_stubs.o|src/asm/backend_x86_64_enc_c.o|x_frontend_link_alias.o|build_asm/*|*.s) continue ;;
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
