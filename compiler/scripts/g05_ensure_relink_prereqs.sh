#!/bin/bash
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
#   SHUX_G05_PREFER_X_O     L2：优先 .x→C(-E)→.o（失败回退 seed；见 analysis/G-02f-L2-x-o-pilot.md）
#                           默认=1（G-02f-437 默认化）；=0 回退纯 seed C 路径
#                           TUs：labi L0+rt 7+L2 thin 17（G-02f-256～436）

set -e
cd "$(dirname "$0")/.."

echo "g05_ensure_relink_prereqs: load env (shell, no make)"
# shellcheck disable=SC2046
eval "$(bash scripts/g05_relink_env.sh)"

# Why: Windows MSYS2/MinGW ships gcc only (no cc alias). Honor caller-provided
#      $CC (e.g. CC=gcc exported by Windows build env), then G05_CC override,
#      then fall back to cc for POSIX. Without this, g05 hot-rebuild emits
#      "cc: command not found" on Windows.
CC="${G05_CC:-${CC:-cc}}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
# 与 Makefile RUNTIME_DRIVER_NO_C_CFLAGS 一致（runtime.c → runtime_driver_no_c.o）
# Cap residual 数据在 RT_SEED_SLICE_OBJS（g05_relink_env）；runtime 开 SHUX_RT_*_FROM_X。
# 须含 PARSE_DIAG_FROM_X：parse_diag 只在 src/runtime/rt_parse_diag.o，禁止再 merge 进 no_c（否则 Darwin 双符号）。
RUNTIME_DRIVER_NO_C_CFLAGS="-DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -DSHUX_NO_C_FRONTEND -DSHUX_ASM_USE_COMPILER_IMPL_C -DSHUX_RT_ARENA_BUF_FROM_X -DSHUX_RT_EMIT_STATE_FROM_X -DSHUX_RT_PREAMBLE_FROM_X -DSHUX_RT_STACK_FROM_X -DSHUX_RT_PARSE_DIAG_FROM_X"

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
      bash scripts/cc_inc_tu.sh "$_c" "$_o" "$@"
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
  # BSD/macOS mktemp 要求 X 串在模板末尾；勿用 XXXXXX.c
  _xtmp=$(mktemp "${TMPDIR:-/tmp}/g05_x.XXXXXX") || return 1
  # 优先默认 -E（Linux 上 -backend c -E 可能 SIGSEGV）；再回退 -backend c -E。
  # Ubuntu 主机偶发 -E SIGSEGV：最多 5 次重试（对齐 prove harness b12bf000）。
  # PLATFORM: SHARED harness
  # shellcheck disable=SC2086
  _e_ok=0
  for _e_try in 1 2 3 4 5; do
    if "$_xshux" -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
    if "$_xshux" -backend c -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
  done
  if [ "$_e_ok" != "1" ]; then
    rm -f "$_xtmp"
    return 1
  fi
  if [ "${G05_X_O_WEAK:-0}" = "1" ]; then
    # 仅改非 static 的简单返回类型函数定义行（-E 产物形态）
    # G-02f-335/336：含 uint8_t * / char * / int64_t 返回（diag_color_prefix / get_source_len 等）
    perl -i -pe 's/^((?:void|int64_t|int32_t|int|size_t|uint32_t|uint64_t|uint8_t \*|uint8_t|const char \*|char \*))\s+(\w+)\s*\(/__attribute__((weak)) $1 $2(/' "$_xtmp" || true
  fi
  # G-02f-458: 前端 *_gen.c .o 的符号重命名
  # 格式：G05_X_O_SYM_RENAME="old1:new1,old2:new2,..."
  # 将 -E 输出中的 .x 函数名重命名为 gen.c 期望的符号名（模块前缀+函数名）
  if [ -n "${G05_X_O_SYM_RENAME:-}" ]; then
    _old_ifs="$IFS"
    IFS=','
    for _pair in $G05_X_O_SYM_RENAME; do
      _old_name="${_pair%%:*}"
      _new_name="${_pair#*:}"
      if [ -n "$_old_name" ] && [ -n "$_new_name" ] && [ "$_old_name" != "$_new_name" ]; then
        perl -i -pe "s/\\b${_old_name}\\b/${_new_name}/g" "$_xtmp" || true
      fi
    done
    IFS="$_old_ifs"
  fi
  # G-02f-332/334：-E 缺 ssize_t / open 原型；前置 POSIX 头，并删掉 -E 里冲突的 libc extern
  {
    echo '/* g05_try_x_to_o prologue (G-02f-332/334 + uio/poll) */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include <sys/types.h>'
    echo '#include <stdlib.h>'
    echo '#include <string.h>'
    echo '#include <stdio.h>'
    echo '#ifndef _WIN32'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    # PLATFORM: POSIX — -E preamble 内联 shux_sys_readv/writev/poll 需原型；
    # 下方 sed 会删掉 -E 自带 #include <poll.h> 等，故在 prologue 补齐。
    echo '#include <sys/uio.h>'
    echo '#include <poll.h>'
    # PLATFORM: POSIX — fmt_check walk/path_stat pure *u8 wrappers (DIR* cast safe).
    echo '#include <dirent.h>'
    echo 'static inline uint8_t *shux_fmt_opendir(uint8_t *name) {'
    echo '  return (uint8_t *)opendir((const char *)name);'
    echo '}'
    echo 'static inline int32_t shux_fmt_closedir(uint8_t *dirp) {'
    echo '  return dirp ? (int32_t)closedir((DIR *)(void *)dirp) : (int32_t)-1;'
    echo '}'
    echo 'static inline int32_t shux_fmt_access(uint8_t *path, int32_t mode) {'
    echo '  return path ? (int32_t)access((const char *)path, (int)mode) : (int32_t)-1;'
    echo '}'
    echo 'static inline uint8_t *shux_fmt_readdir_name(uint8_t *dirp) {'
    echo '  struct dirent *ent;'
    echo '  if (!dirp) return (uint8_t *)0;'
    echo '  ent = readdir((DIR *)(void *)dirp);'
    echo '  return ent ? (uint8_t *)ent->d_name : (uint8_t *)0;'
    echo '}'
    echo '#endif'
    # PLATFORM: SHARED — wave22 Cap residual: opaque *u8 → FILE* fputs cast.
    # .x cannot name FILE*; direct fputs(*u8,*u8) trips -Werror=incompatible-pointer-types.
    # Pure driver_preamble_fputs (runtime_driver_abi_thin.x) calls this harness helper.
    # Outside _WIN32 guard: stdio fputs is available on Windows host-cc too.
    echo 'static inline int32_t shux_driver_fputs_opaque(uint8_t *s, uint8_t *stream) {'
    echo '  return (int32_t)fputs((const char *)(void *)s, (FILE *)(void *)stream);'
    echo '}'
    # PLATFORM: SHARED — wave26 Cap residual: stdout identity + fclose/fwrite for pure
    # driver_parsed_fclose / fclose_rc / write_out (runtime_driver_abi_thin.x).
    # .x cannot name FILE* or compare to stdout without these harness casts.
    echo 'static inline uint8_t *shux_driver_stdout_ptr(void) {'
    echo '  return (uint8_t *)(void *)stdout;'
    echo '}'
    echo 'static inline int32_t shux_driver_fclose_opaque(uint8_t *stream) {'
    echo '  if (!stream) return 0;'
    echo '  return fclose((FILE *)(void *)stream) == 0 ? 0 : 1;'
    echo '}'
    echo 'static inline int32_t shux_driver_fwrite_opaque(uint8_t *data, int32_t len, uint8_t *stream) {'
    echo '  size_t n;'
    echo '  if (!data || len < 0 || !stream) return 1;'
    echo '  if (len == 0) return 0;'
    echo '  n = fwrite((const void *)(void *)data, 1, (size_t)len, (FILE *)(void *)stream);'
    echo '  return n == (size_t)len ? 0 : 1;'
    echo '}'
    # PLATFORM: SHARED — wave27 Cap residual: fopen(path,"w") as opaque *u8 for pure
    # driver_parsed_open_out_file (runtime_driver_abi_thin.x). .x cannot name FILE*.
    echo 'static inline uint8_t *shux_driver_fopen_write_opaque(uint8_t *path) {'
    echo '  if (!path) return (uint8_t *)0;'
    echo '  return (uint8_t *)(void *)fopen((const char *)(void *)path, "w");'
    echo '}'
    # 去掉 -E 自带 #include 与 libc 再声明（与上方头冲突）
    sed -e '/^#include /d' \
        -e '/^extern ssize_t read(/d' \
        -e '/^extern ssize_t write(/d' \
        -e '/^extern int32_t open(/d' \
        -e '/^extern int open(/d' \
        -e '/^extern int32_t fcntl(/d' \
        -e '/^extern int fcntl(/d' \
        -e '/^extern int32_t close(/d' \
        -e '/^extern int close(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern uint8_t \* memcpy(/d' \
        -e '/^extern void \* memcpy(/d' \
        -e '/^extern int32_t memcmp(/d' \
        -e '/^extern int memcmp(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern char \* getcwd(/d' \
        -e '/^extern uint8_t \* getcwd(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        -e '/^extern int32_t strcmp(/d' \
        -e '/^extern int strcmp(/d' \
        -e '/^extern int32_t strncmp(/d' \
        -e '/^extern int strncmp(/d' \
        -e '/^extern uint8_t \* strstr(/d' \
        -e '/^extern char \* strstr(/d' \
        -e '/^extern uint8_t \* memset(/d' \
        -e '/^extern void \* memset(/d' \
        -e '/^extern int32_t setenv(/d' \
        -e '/^extern int setenv(/d' \
        -e '/^extern uint8_t \* strerror(/d' \
        -e '/^extern char \* strerror(/d' \
        -e '/^extern int32_t system(/d' \
        -e '/^extern int system(/d' \
        -e '/^extern int32_t fputs(/d' \
        -e '/^extern int fputs(/d' \
        -e '/^extern uint8_t \* opendir(/d' \
        -e '/^extern void \* opendir(/d' \
        -e '/^extern DIR \* opendir(/d' \
        -e '/^extern int32_t closedir(/d' \
        -e '/^extern int closedir(/d' \
        -e '/^extern int32_t access(/d' \
        -e '/^extern int access(/d' \
        -e '/^extern uint8_t \* shux_fmt_opendir(/d' \
        -e '/^extern int32_t shux_fmt_closedir(/d' \
        -e '/^extern int32_t shux_fmt_access(/d' \
        -e '/^extern uint8_t \* shux_fmt_readdir_name(/d' \
        -e '/^extern int32_t shux_driver_fputs_opaque(/d' \
        -e '/^extern uint8_t \* shux_driver_stdout_ptr(/d' \
        -e '/^extern int32_t shux_driver_fclose_opaque(/d' \
        -e '/^extern int32_t shux_driver_fwrite_opaque(/d' \
        -e '/^extern uint8_t \* shux_driver_fopen_write_opaque(/d' \
        -e '/^extern int32_t mkstemp(/d' \
        -e '/^extern int mkstemp(/d' \
        -e '/^extern int32_t rename(/d' \
        -e '/^extern int rename(/d' \
        "$_xtmp"
  } >"${_xtmp}.full" && mv "${_xtmp}.full" "$_xtmp"
  # shellcheck disable=SC2086
  # -x c：mktemp 无扩展名时 clang 否则不当作 C 源
  if ! $CC $BASE_CFLAGS "$@" -x c -c -o "$_xout" "$_xtmp"; then
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
    if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_l2_x" ]; then
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
  # G-02f-13 / G-02f-267～277：runtime_link_abi.o ← seed（G05 hot）
  # PREFER_X_O=1：L0..L9 + L8b hybrid → rest（SHUX_LABI_*_FROM_X）
  _rlink=seeds/runtime_link_abi.from_x.c
  _labi_l0_seed=seeds/labi_path_pure.from_x.c
  _labi_l0_x=src/runtime/labi_path_pure.x
  _labi_l1_seed=seeds/labi_diag_pure.from_x.c
  _labi_l1_x=src/runtime/labi_diag_pure.x
  _labi_l2_seed=seeds/labi_host_lit.from_x.c
  _labi_l2_x=src/runtime/labi_host_lit.x
  _labi_l3_seed=seeds/labi_path_io.from_x.c
  _labi_l3_x=src/runtime/labi_path_io.x
  _labi_l4_seed=seeds/labi_ensure_list.from_x.c
  _labi_l4_x=src/runtime/labi_ensure_list.x
  _labi_l5_seed=seeds/labi_invoke_cc_list.from_x.c
  _labi_l5_x=src/runtime/labi_invoke_cc_list.x
  _labi_l6_seed=seeds/labi_invoke_ld_list.from_x.c
  _labi_l6_x=src/runtime/labi_invoke_ld_list.x
  _labi_l7_seed=seeds/labi_freestanding_list.from_x.c
  _labi_l7_x=src/runtime/labi_freestanding_list.x
  _labi_l8_seed=seeds/labi_std_list.from_x.c
  _labi_l8_x=src/runtime/labi_std_list.x
  _labi_l8b_seed=seeds/labi_ondemand_list.from_x.c
  _labi_l8b_x=src/runtime/labi_ondemand_list.x
  _labi_l9_seed=seeds/labi_gates.from_x.c
  _labi_l9_x=src/runtime/labi_gates.x
  _labi_o=src/runtime_link_abi.o
  if [ -f "$_rlink" ]; then
    if [ ! -f "$_labi_o" ] || [ "$_rlink" -nt "$_labi_o" ] \
      || { [ -f "$_labi_l0_seed" ] && [ "$_labi_l0_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l0_x" ] && [ "$_labi_l0_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l1_seed" ] && [ "$_labi_l1_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l1_x" ] && [ "$_labi_l1_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l2_seed" ] && [ "$_labi_l2_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l2_x" ] && [ "$_labi_l2_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l3_seed" ] && [ "$_labi_l3_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l3_x" ] && [ "$_labi_l3_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l4_seed" ] && [ "$_labi_l4_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l4_x" ] && [ "$_labi_l4_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l5_seed" ] && [ "$_labi_l5_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l5_x" ] && [ "$_labi_l5_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l6_seed" ] && [ "$_labi_l6_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l6_x" ] && [ "$_labi_l6_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l7_seed" ] && [ "$_labi_l7_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l7_x" ] && [ "$_labi_l7_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8_seed" ] && [ "$_labi_l8_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8_x" ] && [ "$_labi_l8_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8b_seed" ] && [ "$_labi_l8b_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l8b_x" ] && [ "$_labi_l8b_x" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l9_seed" ] && [ "$_labi_l9_seed" -nt "$_labi_o" ]; } \
      || { [ -f "$_labi_l9_x" ] && [ "$_labi_l9_x" -nt "$_labi_o" ]; }; then
      _labi_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l0_seed" ]; then
        _labi_l0_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l0.XXXXXX") || true
        _labi_l1_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l1.XXXXXX") || true
        _labi_l2_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l2.XXXXXX") || true
        _labi_l3_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l3.XXXXXX") || true
        _labi_l4_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l4.XXXXXX") || true
        _labi_l5_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l5.XXXXXX") || true
        _labi_l6_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l6.XXXXXX") || true
        _labi_l7_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l7.XXXXXX") || true
        _labi_l8_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l8.XXXXXX") || true
        _labi_l8b_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l8b.XXXXXX") || true
        _labi_l9_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_l9.XXXXXX") || true
        _labi_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_labi_rest.XXXXXX") || true
        _labi_l0_ok=0
        _labi_l1_ok=0
        _labi_l2_ok=0
        _labi_l3_ok=0
        _labi_l4_ok=0
        _labi_l5_ok=0
        _labi_l6_ok=0
        _labi_l7_ok=0
        _labi_l8_ok=0
        _labi_l8b_ok=0
        _labi_l9_ok=0
        if [ -n "$_labi_l0_o" ]; then
          # R2 labi_path_pure：PREFER_X_O=1 时 full .x（7 门闩真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l0_x" ]; then
            if g05_try_x_to_o "$_labi_l0_x" "$_labi_l0_o"; then
              _labi_l0_ok=1
              echo "g05_ensure: L0 path pure ← $_labi_l0_x (R2 full prefer .x)"
            fi
          fi
          if [ "$_labi_l0_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l0_o" "$_labi_l0_seed"; then
              _labi_l0_ok=1
              echo "g05_ensure: L0 path pure ← $_labi_l0_seed (R2 cold seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l1_o" ]; then
          # R2 labi_diag_pure：PREFER_X_O=1 时 full .x（消息体真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l1_x" ]; then
            if g05_try_x_to_o "$_labi_l1_x" "$_labi_l1_o"; then
              _labi_l1_ok=1
              echo "g05_ensure: L1 diag pure ← $_labi_l1_x (R2 full prefer .x)"
            fi
          fi
          if [ "$_labi_l1_ok" = "0" ] && [ -f "$_labi_l1_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l1_o" "$_labi_l1_seed"; then
              _labi_l1_ok=1
              echo "g05_ensure: L1 diag pure ← $_labi_l1_seed (R2 cold seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l2_o" ]; then
          # R2 labi_host_lit：PREFER_X_O=1 时 full .x（2 门闩真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l2_x" ]; then
            if g05_try_x_to_o "$_labi_l2_x" "$_labi_l2_o"; then
              _labi_l2_ok=1
              echo "g05_ensure: L2 host lit ← $_labi_l2_x (R2 full prefer .x)"
            fi
          fi
          if [ "$_labi_l2_ok" = "0" ] && [ -f "$_labi_l2_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l2_o" "$_labi_l2_seed"; then
              _labi_l2_ok=1
              echo "g05_ensure: L2 host lit ← $_labi_l2_seed (R2 cold seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l3_o" ]; then
          # Track L / R2 full：PREFER_X_O=1 时优先 labi_path_io.x → -E → cc；失败回退 seed C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l3_x" ]; then
            if g05_try_x_to_o "$_labi_l3_x" "$_labi_l3_o"; then
              _labi_l3_ok=1
              echo "g05_ensure: L3 path IO ← $_labi_l3_x (R2 full prefer .x)"
            fi
          fi
          if [ "$_labi_l3_ok" = "0" ] && [ -f "$_labi_l3_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l3_o" "$_labi_l3_seed"; then
              _labi_l3_ok=1
              echo "g05_ensure: L3 path IO ← $_labi_l3_seed (R2 cold seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l4_o" ]; then
          # R2 labi_ensure_list：PREFER_X_O=1 时 full .x（ensure catalog 纯表真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l4_x" ]; then
            if g05_try_x_to_o "$_labi_l4_x" "$_labi_l4_o"; then
              _labi_l4_ok=1
              echo "g05_ensure: L4 ensure list ← $_labi_l4_x (Track L prefer .x)"
            fi
          fi
          if [ "$_labi_l4_ok" = "0" ] && [ -f "$_labi_l4_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l4_o" "$_labi_l4_seed"; then
              _labi_l4_ok=1
              echo "g05_ensure: L4 ensure list ← $_labi_l4_seed (G-02f-273 seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l5_o" ]; then
          # L5 labi_invoke_cc_list：默认冷 seed（rodata 字符串字面量）。
          # 【Why】.x STRING_LIT 曾发栈 compound，return 后悬空 → invoke_cc argv 乱码。
          # 仅当显式 SHUX_G05_PREFER_X_O_LABI=1 且 host STRING_LIT 已 rodata 时才 prefer .x。
          if [ "${SHUX_G05_PREFER_X_O_LABI:-0}" = "1" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l5_x" ]; then
            if g05_try_x_to_o "$_labi_l5_x" "$_labi_l5_o"; then
              _labi_l5_ok=1
              echo "g05_ensure: L5 invoke_cc list ← $_labi_l5_x (opt-in prefer .x)"
            fi
          fi
          if [ "$_labi_l5_ok" = "0" ] && [ -f "$_labi_l5_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l5_o" "$_labi_l5_seed"; then
              _labi_l5_ok=1
              echo "g05_ensure: L5 invoke_cc list ← $_labi_l5_seed (cold seed rodata; default)"
            fi
          fi
        fi
        if [ -n "$_labi_l6_o" ]; then
          # R2 labi_invoke_ld_list：PREFER_X_O=1 时 full .x（纯表真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l6_x" ]; then
            if g05_try_x_to_o "$_labi_l6_x" "$_labi_l6_o"; then
              _labi_l6_ok=1
              echo "g05_ensure: L6 invoke_ld list ← $_labi_l6_x (R2 full prefer .x)"
            fi
          fi
          if [ "$_labi_l6_ok" = "0" ] && [ -f "$_labi_l6_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l6_o" "$_labi_l6_seed"; then
              _labi_l6_ok=1
              echo "g05_ensure: L6 invoke_ld list ← $_labi_l6_seed (G-02f-275 seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l7_o" ]; then
          # R2 labi_freestanding_list：PREFER_X_O=1 时 full .x（freestanding 纯表真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l7_x" ]; then
            if g05_try_x_to_o "$_labi_l7_x" "$_labi_l7_o"; then
              _labi_l7_ok=1
              echo "g05_ensure: L7 freestanding list ← $_labi_l7_x (G-02f-L prefer .x)"
            fi
          fi
          if [ "$_labi_l7_ok" = "0" ] && [ -f "$_labi_l7_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l7_o" "$_labi_l7_seed"; then
              _labi_l7_ok=1
              echo "g05_ensure: L7 freestanding list ← $_labi_l7_seed (G-02f-276 seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l8_o" ]; then
          # R2 labi_std_list：PREFER_X_O=1 时 full .x（59 步 plan 纯表真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l8_x" ]; then
            if g05_try_x_to_o "$_labi_l8_x" "$_labi_l8_o"; then
              _labi_l8_ok=1
              echo "g05_ensure: L8 std list ← $_labi_l8_x (Track L prefer .x)"
            fi
          fi
          if [ "$_labi_l8_ok" = "0" ] && [ -f "$_labi_l8_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l8_o" "$_labi_l8_seed"; then
              _labi_l8_ok=1
              echo "g05_ensure: L8 std list ← $_labi_l8_seed (G-02f-271 seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l8b_o" ]; then
          # R2 labi_ondemand_list：PREFER_X_O=1 时 full .x（on_demand 纯表真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l8b_x" ]; then
            if g05_try_x_to_o "$_labi_l8b_x" "$_labi_l8b_o"; then
              _labi_l8b_ok=1
              echo "g05_ensure: L8b on_demand list ← $_labi_l8b_x (Track L prefer .x)"
            fi
          fi
          if [ "$_labi_l8b_ok" = "0" ] && [ -f "$_labi_l8b_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l8b_o" "$_labi_l8b_seed"; then
              _labi_l8b_ok=1
              echo "g05_ensure: L8b on_demand list ← $_labi_l8b_seed (G-02f-272 seed slice)"
            fi
          fi
        fi
        if [ -n "$_labi_l9_o" ]; then
          # R2 labi_gates：PREFER_X_O=1 时 full .x（6 thin gates 真迁 H=0）；失败回退 seed 冷 C
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_labi_l9_x" ]; then
            if g05_try_x_to_o "$_labi_l9_x" "$_labi_l9_o"; then
              _labi_l9_ok=1
              echo "g05_ensure: L9 gates ← $_labi_l9_x (G-02f-L prefer .x)"
            fi
          fi
          if [ "$_labi_l9_ok" = "0" ] && [ -f "$_labi_l9_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_l9_o" "$_labi_l9_seed"; then
              _labi_l9_ok=1
              echo "g05_ensure: L9 gates ← $_labi_l9_seed (G-02f-277 seed slice)"
            fi
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
        if [ "$_labi_l4_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_ENSURE_LIST_FROM_X"
        fi
        if [ "$_labi_l5_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_INVOKE_CC_LIST_FROM_X"
        fi
        if [ "$_labi_l6_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_INVOKE_LD_LIST_FROM_X"
        fi
        if [ "$_labi_l7_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_FREESTANDING_LIST_FROM_X"
        fi
        if [ "$_labi_l8_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_STD_LIST_FROM_X"
        fi
        if [ "$_labi_l8b_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_ONDEMAND_LIST_FROM_X"
        fi
        if [ "$_labi_l9_ok" = "1" ]; then
          _labi_rest_defs="$_labi_rest_defs -DSHUX_LABI_GATES_FROM_X"
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
          if [ "$_labi_l4_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l4_o"
          fi
          if [ "$_labi_l5_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l5_o"
          fi
          if [ "$_labi_l6_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l6_o"
          fi
          if [ "$_labi_l7_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l7_o"
          fi
          if [ "$_labi_l8_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l8_o"
          fi
          if [ "$_labi_l8b_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l8b_o"
          fi
          if [ "$_labi_l9_ok" = "1" ]; then
            _labi_link="$_labi_link $_labi_l9_o"
          fi
          # shellcheck disable=SC2086
          if $CC -r -nostdlib -o "$_labi_o" $_labi_link "$_labi_rest_o" 2>/dev/null; then
            echo "g05_ensure: $_labi_o ← L0..L9+L8b + link_abi rest (G-02f-277 hybrid)"
            _labi_done=1
          fi
        fi
        if [ "$_labi_done" = "0" ]; then
          echo "g05_ensure: L0..L9+L8b link_abi hybrid failed; fallback full seed" >&2
        fi
        rm -f "$_labi_l0_o" "$_labi_l1_o" "$_labi_l2_o" "$_labi_l3_o" "$_labi_l4_o" "$_labi_l5_o" "$_labi_l6_o" "$_labi_l7_o" "$_labi_l8_o" "$_labi_l8b_o" "$_labi_l9_o" "$_labi_rest_o"
      fi
      if [ "$_labi_done" = "0" ]; then
        echo "g05_ensure: runtime_link_abi.o ← seed (G-02f-13)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_labi_o" "$_rlink"
      fi
    fi
  fi
  # G-02f-14 / G-02f-261～265 / G-02f-291～297：runtime_driver_no_c.o ← seeds/runtime.from_x.c + NO_C flags
  # PREFER_X_O=1：R2/R0/R1/R5-lite/R3/R6/R7-lite 切片 hybrid → rest（SHUX_RT_*_FROM_X）
  # 注：RFC R4 DCE 在 !SHUX_USE_X_DRIVER 下，不进产品 .o；R7 spawn 仍 rest
  _rt=seeds/runtime.from_x.c
  _rt_content_x=src/runtime/rt_content.x
  _rt_content_seed=seeds/rt_content.from_x.c
  _rt_util_seed=seeds/rt_util.from_x.c
  _rt_util_x=src/runtime/rt_util.x
  _rt_argv_seed=seeds/rt_argv.from_x.c
  _rt_argv_x=src/runtime/rt_argv.x
  _rt_ef_seed=seeds/rt_emit_flags.from_x.c
  _rt_ef_x=src/runtime/rt_emit_flags.x
  _rt_pre_seed=seeds/rt_preamble.from_x.c
  _rt_pre_x=src/runtime/rt_preamble.x
  _rt_compile_seed=seeds/rt_compile.from_x.c
  _rt_compile_x=src/runtime/rt_compile.x
  _rt_run_seed=seeds/rt_run_exec.from_x.c
  _rt_run_exec_x=src/runtime/rt_run_exec.x
  _rt_asm_seed=seeds/rt_asm_stub.from_x.c
  _rt_asm_stub_x=src/runtime/rt_asm_stub.x
  _rt_entry_seed=seeds/rt_entry.from_x.c
  _rt_entry_x=src/runtime/rt_entry.x
  _rt_diag_seed=seeds/rt_diag_errno.from_x.c
  _rt_diag_x=src/runtime/rt_diag_errno.x
  _rt_emit_st_seed=seeds/rt_emit_state.from_x.c
  _rt_emit_st_x=src/runtime/rt_emit_state.x
  _rt_elf_diag_seed=seeds/rt_pipeline_elf_diag.from_x.c
  _rt_elf_diag_x=src/runtime/rt_pipeline_elf_diag.x
  _rt_lib_root_seed=seeds/rt_lib_root.from_x.c
  _rt_lib_root_x=src/runtime/rt_lib_root.x
  _rt_parse_diag_seed=seeds/rt_parse_diag.from_x.c
  _rt_parse_diag_x=src/runtime/rt_parse_diag.x
  _rt_fs_open_seed=seeds/rt_fs_open.from_x.c
  _rt_fs_open_x=src/runtime/rt_fs_open.x
  _rt_arena_buf_seed=seeds/rt_arena_buf.from_x.c
  _rt_arena_buf_x=src/runtime/rt_arena_buf.x
  _rt_fmt_one_seed=seeds/rt_fmt_one.from_x.c
  _rt_fmt_one_x=src/runtime/rt_fmt_one.x
  _rt_dispatch_thin_seed=seeds/rt_dispatch_thin.from_x.c
  _rt_dispatch_thin_x=src/runtime/rt_dispatch_thin.x
  _rt_dispatch_impl_seed=seeds/rt_dispatch_impl.from_x.c
  _rt_dispatch_impl_x=src/runtime/rt_dispatch_impl.x
  _rt_run_x_emit_seed=seeds/rt_run_x_emit.from_x.c
  _rt_run_x_emit_x=src/runtime/rt_run_x_emit.x
  _rt_run_asm_backend_seed=seeds/rt_run_asm_backend.from_x.c
  _rt_run_asm_backend_x=src/runtime/rt_run_asm_backend.x
  _rt_run_compiler_parsed_seed=seeds/rt_run_compiler_parsed.from_x.c
  _rt_run_compiler_parsed_x=src/runtime/rt_run_compiler_parsed.x
  _rt_stack_seed=seeds/rt_stack.from_x.c
  _rt_stack_x=src/runtime/rt_stack.x
  _rt_o=src/runtime_driver_no_c.o
  if [ -f "$_rt" ]; then
    if [ ! -f "$_rt_o" ] || [ "$_rt" -nt "$_rt_o" ] \
      || { [ -f "$_rt_content_seed" ] && [ "$_rt_content_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_util_seed" ] && [ "$_rt_util_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_util_x" ] && [ "$_rt_util_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_argv_seed" ] && [ "$_rt_argv_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_argv_x" ] && [ "$_rt_argv_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_ef_seed" ] && [ "$_rt_ef_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_ef_x" ] && [ "$_rt_ef_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_pre_seed" ] && [ "$_rt_pre_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_pre_x" ] && [ "$_rt_pre_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_compile_seed" ] && [ "$_rt_compile_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_compile_x" ] && [ "$_rt_compile_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_seed" ] && [ "$_rt_run_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_exec_x" ] && [ "$_rt_run_exec_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_asm_seed" ] && [ "$_rt_asm_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_asm_stub_x" ] && [ "$_rt_asm_stub_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_entry_seed" ] && [ "$_rt_entry_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_entry_x" ] && [ "$_rt_entry_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_diag_seed" ] && [ "$_rt_diag_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_diag_x" ] && [ "$_rt_diag_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_emit_st_seed" ] && [ "$_rt_emit_st_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_emit_st_x" ] && [ "$_rt_emit_st_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_elf_diag_seed" ] && [ "$_rt_elf_diag_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_elf_diag_x" ] && [ "$_rt_elf_diag_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_lib_root_seed" ] && [ "$_rt_lib_root_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_lib_root_x" ] && [ "$_rt_lib_root_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_parse_diag_seed" ] && [ "$_rt_parse_diag_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_parse_diag_x" ] && [ "$_rt_parse_diag_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_fs_open_seed" ] && [ "$_rt_fs_open_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_fs_open_x" ] && [ "$_rt_fs_open_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_arena_buf_seed" ] && [ "$_rt_arena_buf_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_arena_buf_x" ] && [ "$_rt_arena_buf_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_fmt_one_seed" ] && [ "$_rt_fmt_one_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_fmt_one_x" ] && [ "$_rt_fmt_one_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_dispatch_thin_seed" ] && [ "$_rt_dispatch_thin_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_dispatch_thin_x" ] && [ "$_rt_dispatch_thin_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_dispatch_impl_seed" ] && [ "$_rt_dispatch_impl_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_dispatch_impl_x" ] && [ "$_rt_dispatch_impl_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_x_emit_seed" ] && [ "$_rt_run_x_emit_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_x_emit_x" ] && [ "$_rt_run_x_emit_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_asm_backend_seed" ] && [ "$_rt_run_asm_backend_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_asm_backend_x" ] && [ "$_rt_run_asm_backend_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_compiler_parsed_seed" ] && [ "$_rt_run_compiler_parsed_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_run_compiler_parsed_x" ] && [ "$_rt_run_compiler_parsed_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_stack_seed" ] && [ "$_rt_stack_seed" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_stack_x" ] && [ "$_rt_stack_x" -nt "$_rt_o" ]; } \
      || { [ -f "$_rt_content_x" ] && [ "$_rt_content_x" -nt "$_rt_o" ]; }; then
      _rt_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_content_seed" ]; then
        _rt_c_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_content.XXXXXX") || true
        _rt_u_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_util.XXXXXX") || true
        _rt_a_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_argv.XXXXXX") || true
        _rt_e_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_eflags.XXXXXX") || true
        _rt_p_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_pre.XXXXXX") || true
        _rt_cmp_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_compile.XXXXXX") || true
        _rt_run_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run.XXXXXX") || true
        _rt_asm_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_asm.XXXXXX") || true
        _rt_ent_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_entry.XXXXXX") || true
        _rt_diag_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_diag.XXXXXX") || true
        _rt_est_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_emit_st.XXXXXX") || true
        _rt_elfd_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_elf_diag.XXXXXX") || true
        _rt_lr_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_lib_root.XXXXXX") || true
        _rt_pd_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_parse_diag.XXXXXX") || true
        _rt_fs_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fs_open.XXXXXX") || true
        _rt_ab_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_arena_buf.XXXXXX") || true
        _rt_fo_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fmt_one.XXXXXX") || true
        _rt_dt_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_thin.XXXXXX") || true
        _rt_di_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_impl.XXXXXX") || true
        _rt_xe_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_x_emit.XXXXXX") || true
        _rt_abk_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_asm_backend.XXXXXX") || true
        _rt_rcp_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_compiler_parsed.XXXXXX") || true
        _rt_st_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_stack.XXXXXX") || true
        _rt_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_rest.XXXXXX") || true
        _rt_content_ok=0
        _rt_util_ok=0
        _rt_argv_ok=0
        _rt_ef_ok=0
        _rt_pre_ok=0
        _rt_compile_ok=0
        _rt_run_ok=0
        _rt_asm_ok=0
        _rt_entry_ok=0
        _rt_diag_ok=0
        _rt_est_ok=0
        _rt_elfd_ok=0
        _rt_lr_ok=0
        _rt_pd_ok=0
        _rt_fs_ok=0
        _rt_ab_ok=0
        _rt_fo_ok=0
        _rt_dt_ok=0
        _rt_di_ok=0
        _rt_xe_ok=0
        _rt_abk_ok=0
        _rt_rcp_ok=0
        _rt_st_ok=0
        if [ -n "$_rt_c_o" ]; then
          # G-02f-436：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_content_x" ]; then
            _rt_content_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_content_thin.XXXXXX") || true
            _rt_content_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_content_rest.XXXXXX") || true
            if [ -n "$_rt_content_thin_o" ] && [ -n "$_rt_content_rest_o" ] \
              && g05_try_x_to_o "$_rt_content_x" "$_rt_content_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_CONTENT_FROM_X \
                   -c -o "$_rt_content_rest_o" "$_rt_content_seed" \
              && $CC -r -nostdlib -o "$_rt_c_o" "$_rt_content_thin_o" "$_rt_content_rest_o" 2>/dev/null; then
              _rt_content_ok=1
              echo "g05_ensure: R2 content ← full .x + rest H=0 (path wrappers in .x)"
            fi
            rm -f "$_rt_content_thin_o" "$_rt_content_rest_o"
          fi
          if [ "$_rt_content_ok" = "0" ] && [ -f "$_rt_content_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_c_o" "$_rt_content_seed"; then
              _rt_content_ok=1
              echo "g05_ensure: R2 content ← $_rt_content_seed (G-02f-261/306 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_u_o" ]; then
          # G-02f-435：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_util_x" ]; then
            _rt_util_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_util_thin.XXXXXX") || true
            _rt_util_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_util_rest.XXXXXX") || true
            if [ -n "$_rt_util_thin_o" ] && [ -n "$_rt_util_rest_o" ] \
              && g05_try_x_to_o "$_rt_util_x" "$_rt_util_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_UTIL_FROM_X \
                   -c -o "$_rt_util_rest_o" "$_rt_util_seed" \
              && $CC -r -nostdlib -o "$_rt_u_o" "$_rt_util_thin_o" "$_rt_util_rest_o" 2>/dev/null; then
              _rt_util_ok=1
              echo "g05_ensure: R0 util ← thin .x + rest (G-02f-435 L2 prefer .x)"
            fi
            rm -f "$_rt_util_thin_o" "$_rt_util_rest_o"
          fi
          if [ "$_rt_util_ok" = "0" ] && [ -f "$_rt_util_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_u_o" "$_rt_util_seed"; then
              _rt_util_ok=1
              echo "g05_ensure: R0 util ← $_rt_util_seed (G-02f-262 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_a_o" ]; then
          # R2 full：PREFER_X_O=1 时 full .x + rest seed (-D FROM_X 业务 H=0) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_argv_x" ]; then
            _rt_argv_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_argv_thin.XXXXXX") || true
            _rt_argv_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_argv_rest.XXXXXX") || true
            if [ -n "$_rt_argv_thin_o" ] && [ -n "$_rt_argv_rest_o" ] \
              && g05_try_x_to_o "$_rt_argv_x" "$_rt_argv_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_ARGV_FROM_X \
                   -c -o "$_rt_argv_rest_o" "$_rt_argv_seed" \
              && $CC -r -nostdlib -o "$_rt_a_o" "$_rt_argv_thin_o" "$_rt_argv_rest_o" 2>/dev/null; then
              _rt_argv_ok=1
              echo "g05_ensure: R1 argv ← full .x + rest (R2 full H=0; G-02f-431 PREFER_X_O)"
            fi
            rm -f "$_rt_argv_thin_o" "$_rt_argv_rest_o"
          fi
          if [ "$_rt_argv_ok" = "0" ] && [ -f "$_rt_argv_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_a_o" "$_rt_argv_seed"; then
              _rt_argv_ok=1
              echo "g05_ensure: R1 argv ← $_rt_argv_seed (G-02f-263 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_e_o" ] && [ -f "$_rt_ef_seed" ]; then
          # G-02f-451：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_ef_x" ]; then
            _rt_ef_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_emit_flags_thin.XXXXXX") || true
            _rt_ef_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_emit_flags_rest.XXXXXX") || true
            if [ -n "$_rt_ef_thin_o" ] && [ -n "$_rt_ef_rest_o" ] \
              && g05_try_x_to_o "$_rt_ef_x" "$_rt_ef_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_EMIT_FLAGS_FROM_X \
                   -c -o "$_rt_ef_rest_o" "$_rt_ef_seed" \
              && $CC -r -nostdlib -o "$_rt_e_o" "$_rt_ef_thin_o" "$_rt_ef_rest_o" 2>/dev/null; then
              _rt_ef_ok=1
              echo "g05_ensure: R2 emit_flags ← full .x + rest (G-02f R2 prefer .x; FROM_X rest H=0)"
            fi
            rm -f "$_rt_ef_thin_o" "$_rt_ef_rest_o"
          fi
          if [ "$_rt_ef_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_e_o" "$_rt_ef_seed"; then
              _rt_ef_ok=1
              echo "g05_ensure: R5-lite emit_flags ← $_rt_ef_seed (G-02f-264 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_p_o" ] && [ -f "$_rt_pre_seed" ]; then
          # R2 full：PREFER_X_O=1 时 full .x + rest seed（表+marker）→ cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_pre_x" ]; then
            _rt_p_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_pre_thin.XXXXXX") || true
            _rt_p_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_pre_rest.XXXXXX") || true
            if [ -n "$_rt_p_thin_o" ] && [ -n "$_rt_p_rest_o" ] \
              && g05_try_x_to_o "$_rt_pre_x" "$_rt_p_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_PREAMBLE_FROM_X \
                   -c -o "$_rt_p_rest_o" "$_rt_pre_seed" \
              && $CC -r -nostdlib -o "$_rt_p_o" "$_rt_p_thin_o" "$_rt_p_rest_o" 2>/dev/null; then
              _rt_pre_ok=1
              echo "g05_ensure: R3 preamble ← full .x + rest tables/marker (R2 full H=0)"
            fi
            rm -f "$_rt_p_thin_o" "$_rt_p_rest_o"
          fi
          if [ "$_rt_pre_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_p_o" "$_rt_pre_seed"; then
              _rt_pre_ok=1
              echo "g05_ensure: R3 preamble ← $_rt_pre_seed (G-02f-265 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_cmp_o" ] && [ -f "$_rt_compile_seed" ]; then
          # G-02f-454：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          # 门闩：.x -E 可能「假成功」缺关键 T 符号；FROM_X rest 仅前向声明 → 最终 link U。
          # 合并后必须有 seed 权威入口，否则回退完整 seed 冷编。
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_compile_x" ]; then
            _rt_cmp_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_compile_thin.XXXXXX") || true
            _rt_cmp_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_compile_rest.XXXXXX") || true
            if [ -n "$_rt_cmp_thin_o" ] && [ -n "$_rt_cmp_rest_o" ] \
              && g05_try_x_to_o "$_rt_compile_x" "$_rt_cmp_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_COMPILE_FROM_X \
                   -c -o "$_rt_cmp_rest_o" "$_rt_compile_seed" \
              && $CC -r -nostdlib -o "$_rt_cmp_o" "$_rt_cmp_thin_o" "$_rt_cmp_rest_o" 2>/dev/null \
              && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_compile_state_alloc_c$" \
              && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_deps_are_std_core_closure_only$" \
              && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_compile_parse_argv_impl_c$"; then
              _rt_compile_ok=1
              echo "g05_ensure: R6 compile ← full .x + rest marker (R2 full H=0)"
            else
              echo "g05_ensure: R6 compile .x hybrid incomplete (missing T exports) → seed fallback" >&2
            fi
            rm -f "$_rt_cmp_thin_o" "$_rt_cmp_rest_o"
          fi
          if [ "$_rt_compile_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_cmp_o" "$_rt_compile_seed"; then
              _rt_compile_ok=1
              echo "g05_ensure: R6 compile pure ← $_rt_compile_seed (G-02f-291~296 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_run_o" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          # 门闩：.x -E 假成功缺 driver_run_test 时不得标 FROM_X（否则 driver_test_x 链 U）。
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_exec_x" ]; then
            _rt_run_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_thin.XXXXXX") || true
            _rt_run_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_rest.XXXXXX") || true
            if [ -n "$_rt_run_thin_o" ] && [ -n "$_rt_run_rest_o" ] \
              && g05_try_x_to_o "$_rt_run_exec_x" "$_rt_run_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_RUN_EXEC_FROM_X \
                   -c -o "$_rt_run_rest_o" "$_rt_run_seed" \
              && $CC -r -nostdlib -o "$_rt_run_o" "$_rt_run_thin_o" "$_rt_run_rest_o" 2>/dev/null \
              && nm "$_rt_run_o" 2>/dev/null | grep -q " T driver_run_test$"; then
              _rt_run_ok=1
              echo "g05_ensure: R7 run/exec ← full .x + rest marker (R2 full H=0)"
            else
              echo "g05_ensure: R7 run/exec .x hybrid incomplete (missing driver_run_test) → seed fallback" >&2
            fi
            rm -f "$_rt_run_thin_o" "$_rt_run_rest_o"
          fi
          if [ "$_rt_run_ok" = "0" ] && [ -f "$_rt_run_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_run_o" "$_rt_run_seed"; then
              _rt_run_ok=1
              echo "g05_ensure: R7 run/exec ← $_rt_run_seed (G-02f-297~299/311 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_asm_o" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_asm_stub_x" ]; then
            _rt_asm_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_asm_thin.XXXXXX") || true
            _rt_asm_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_asm_rest.XXXXXX") || true
            if [ -n "$_rt_asm_thin_o" ] && [ -n "$_rt_asm_rest_o" ] \
              && g05_try_x_to_o "$_rt_asm_stub_x" "$_rt_asm_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_ASM_STUB_FROM_X \
                   -c -o "$_rt_asm_rest_o" "$_rt_asm_seed" \
              && $CC -r -nostdlib -o "$_rt_asm_o" "$_rt_asm_thin_o" "$_rt_asm_rest_o" 2>/dev/null; then
              _rt_asm_ok=1
              echo "g05_ensure: R9 asm stub ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_asm_thin_o" "$_rt_asm_rest_o"
          fi
          if [ "$_rt_asm_ok" = "0" ] && [ -f "$_rt_asm_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_asm_o" "$_rt_asm_seed"; then
              _rt_asm_ok=1
              echo "g05_ensure: R9 asm stub ← $_rt_asm_seed (G-02f-300 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_ent_o" ] && [ -f "$_rt_entry_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_entry_x" ]; then
            _rt_ent_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_entry_thin.XXXXXX") || true
            _rt_ent_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_entry_rest.XXXXXX") || true
            if [ -n "$_rt_ent_thin_o" ] && [ -n "$_rt_ent_rest_o" ] \
              && g05_try_x_to_o "$_rt_entry_x" "$_rt_ent_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_ENTRY_FROM_X \
                   -c -o "$_rt_ent_rest_o" "$_rt_entry_seed" \
              && $CC -r -nostdlib -o "$_rt_ent_o" "$_rt_ent_thin_o" "$_rt_ent_rest_o" 2>/dev/null; then
              _rt_entry_ok=1
              echo "g05_ensure: R10 entry ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_ent_thin_o" "$_rt_ent_rest_o"
          fi
          if [ "$_rt_entry_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_ent_o" "$_rt_entry_seed"; then
              _rt_entry_ok=1
              echo "g05_ensure: R10 entry gates ← $_rt_entry_seed (G-02f-301/310 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_diag_o" ] && [ -f "$_rt_diag_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_diag_x" ]; then
            _rt_diag_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_diag_thin.XXXXXX") || true
            _rt_diag_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_diag_rest.XXXXXX") || true
            if [ -n "$_rt_diag_thin_o" ] && [ -n "$_rt_diag_rest_o" ] \
              && g05_try_x_to_o "$_rt_diag_x" "$_rt_diag_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_DIAG_ERRNO_FROM_X \
                   -c -o "$_rt_diag_rest_o" "$_rt_diag_seed" \
              && $CC -r -nostdlib -o "$_rt_diag_o" "$_rt_diag_thin_o" "$_rt_diag_rest_o" 2>/dev/null; then
              _rt_diag_ok=1
              echo "g05_ensure: rest diag_errno ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_diag_thin_o" "$_rt_diag_rest_o"
          fi
          if [ "$_rt_diag_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_diag_o" "$_rt_diag_seed"; then
              _rt_diag_ok=1
              echo "g05_ensure: rest diag errno ← $_rt_diag_seed (G-02f-302 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_est_o" ] && [ -f "$_rt_emit_st_seed" ]; then
          # G-02f-455：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_emit_st_x" ]; then
            _rt_est_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_emit_st_thin.XXXXXX") || true
            _rt_est_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_emit_st_rest.XXXXXX") || true
            if [ -n "$_rt_est_thin_o" ] && [ -n "$_rt_est_rest_o" ] \
              && g05_try_x_to_o "$_rt_emit_st_x" "$_rt_est_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_EMIT_STATE_FROM_X \
                   -c -o "$_rt_est_rest_o" "$_rt_emit_st_seed" \
              && $CC -r -nostdlib -o "$_rt_est_o" "$_rt_est_thin_o" "$_rt_est_rest_o" 2>/dev/null; then
              _rt_est_ok=1
              echo "g05_ensure: rest emit state ← full .x + rest BSS+marker (R2 full H=0)"
            fi
            rm -f "$_rt_est_thin_o" "$_rt_est_rest_o"
          fi
          if [ "$_rt_est_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_est_o" "$_rt_emit_st_seed"; then
              _rt_est_ok=1
              echo "g05_ensure: rest emit state+argv ← $_rt_emit_st_seed (G-02f-303/304 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_elfd_o" ] && [ -f "$_rt_elf_diag_seed" ]; then
          # G-02f-445：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_elf_diag_x" ]; then
            _rt_elfd_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_elf_diag_thin.XXXXXX") || true
            _rt_elfd_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_elf_diag_rest.XXXXXX") || true
            if [ -n "$_rt_elfd_thin_o" ] && [ -n "$_rt_elfd_rest_o" ] \
              && g05_try_x_to_o "$_rt_elf_diag_x" "$_rt_elfd_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_PIPELINE_ELF_DIAG_FROM_X \
                   -c -o "$_rt_elfd_rest_o" "$_rt_elf_diag_seed" \
              && $CC -r -nostdlib -o "$_rt_elfd_o" "$_rt_elfd_thin_o" "$_rt_elfd_rest_o" 2>/dev/null; then
              _rt_elfd_ok=1
              echo "g05_ensure: rest pipeline elf diag ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_elfd_thin_o" "$_rt_elfd_rest_o"
          fi
          if [ "$_rt_elfd_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_elfd_o" "$_rt_elf_diag_seed"; then
              _rt_elfd_ok=1
              echo "g05_ensure: rest pipeline elf diag ← $_rt_elf_diag_seed (G-02f-304 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_lr_o" ]; then
          # G-02f-432：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_lib_root_x" ]; then
            _rt_lr_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_lr_thin.XXXXXX") || true
            _rt_lr_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_lr_rest.XXXXXX") || true
            if [ -n "$_rt_lr_thin_o" ] && [ -n "$_rt_lr_rest_o" ] \
              && g05_try_x_to_o "$_rt_lib_root_x" "$_rt_lr_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_LIB_ROOT_FROM_X \
                   -c -o "$_rt_lr_rest_o" "$_rt_lib_root_seed" \
              && $CC -r -nostdlib -o "$_rt_lr_o" "$_rt_lr_thin_o" "$_rt_lr_rest_o" 2>/dev/null; then
              _rt_lr_ok=1
              echo "g05_ensure: rest lib_root ← thin .x + rest (G-02f-432 L2 prefer .x)"
            fi
            rm -f "$_rt_lr_thin_o" "$_rt_lr_rest_o"
          fi
          if [ "$_rt_lr_ok" = "0" ] && [ -f "$_rt_lib_root_seed" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_lr_o" "$_rt_lib_root_seed"; then
              _rt_lr_ok=1
              echo "g05_ensure: rest lib_root ← $_rt_lib_root_seed (G-02f-305 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_pd_o" ] && [ -f "$_rt_parse_diag_seed" ]; then
          # G-02f-448：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_parse_diag_x" ]; then
            _rt_pd_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_parse_diag_thin.XXXXXX") || true
            _rt_pd_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_parse_diag_rest.XXXXXX") || true
            if [ -n "$_rt_pd_thin_o" ] && [ -n "$_rt_pd_rest_o" ] \
              && g05_try_x_to_o "$_rt_parse_diag_x" "$_rt_pd_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc \
                   -DSHUX_RT_PARSE_DIAG_FROM_X -DSHUX_RT_PARSE_DIAG_PRECISE_BRIDGE \
                   -c -o "$_rt_pd_rest_o" "$_rt_parse_diag_seed" \
              && $CC -r -nostdlib -o "$_rt_pd_o" "$_rt_pd_thin_o" "$_rt_pd_rest_o" 2>/dev/null; then
              _rt_pd_ok=1
              echo "g05_ensure: rest parse_diag ← thin .x + rest (R2 full H=0; G-02f-448 PREFER_X_O)"
            fi
            rm -f "$_rt_pd_thin_o" "$_rt_pd_rest_o"
          fi
          if [ "$_rt_pd_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_pd_o" "$_rt_parse_diag_seed"; then
              _rt_pd_ok=1
              echo "g05_ensure: rest parse diag ← $_rt_parse_diag_seed (G-02f-307 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_fs_o" ] && [ -f "$_rt_fs_open_seed" ]; then
          # G-02f-452：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_fs_open_x" ]; then
            _rt_fs_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fs_open_thin.XXXXXX") || true
            _rt_fs_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fs_open_rest.XXXXXX") || true
            if [ -n "$_rt_fs_thin_o" ] && [ -n "$_rt_fs_rest_o" ] \
              && g05_try_x_to_o "$_rt_fs_open_x" "$_rt_fs_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_FS_OPEN_FROM_X \
                   -c -o "$_rt_fs_rest_o" "$_rt_fs_open_seed" \
              && $CC -r -nostdlib -o "$_rt_fs_o" "$_rt_fs_thin_o" "$_rt_fs_rest_o" 2>/dev/null; then
              _rt_fs_ok=1
              echo "g05_ensure: rest fs open ← thin .x + rest (R2 full H=0; G-02f-452 PREFER_X_O)"
            fi
            rm -f "$_rt_fs_thin_o" "$_rt_fs_rest_o"
          fi
          if [ "$_rt_fs_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_fs_o" "$_rt_fs_open_seed"; then
              _rt_fs_ok=1
              echo "g05_ensure: rest fs open ← $_rt_fs_open_seed (G-02f-308 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_ab_o" ] && [ -f "$_rt_arena_buf_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，BSS+marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_arena_buf_x" ]; then
            _rt_ab_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_arena_thin.XXXXXX") || true
            _rt_ab_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_arena_rest.XXXXXX") || true
            if [ -n "$_rt_ab_thin_o" ] && [ -n "$_rt_ab_rest_o" ] \
              && g05_try_x_to_o "$_rt_arena_buf_x" "$_rt_ab_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_ARENA_BUF_FROM_X \
                   -c -o "$_rt_ab_rest_o" "$_rt_arena_buf_seed" \
              && $CC -r -nostdlib -o "$_rt_ab_o" "$_rt_ab_thin_o" "$_rt_ab_rest_o" 2>/dev/null; then
              _rt_ab_ok=1
              echo "g05_ensure: rest arena_buf ← full .x + rest BSS+marker (R2 full H=0)"
            fi
            rm -f "$_rt_ab_thin_o" "$_rt_ab_rest_o"
          fi
          if [ "$_rt_ab_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_ab_o" "$_rt_arena_buf_seed"; then
              _rt_ab_ok=1
              echo "g05_ensure: rest arena_buf ← $_rt_arena_buf_seed (G-02f-309 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_fo_o" ] && [ -f "$_rt_fmt_one_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_fmt_one_x" ]; then
            _rt_fo_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fmt_one_thin.XXXXXX") || true
            _rt_fo_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_fmt_one_rest.XXXXXX") || true
            if [ -n "$_rt_fo_thin_o" ] && [ -n "$_rt_fo_rest_o" ] \
              && g05_try_x_to_o "$_rt_fmt_one_x" "$_rt_fo_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_FMT_ONE_FROM_X \
                   -c -o "$_rt_fo_rest_o" "$_rt_fmt_one_seed" \
              && $CC -r -nostdlib -o "$_rt_fo_o" "$_rt_fo_thin_o" "$_rt_fo_rest_o" 2>/dev/null; then
              _rt_fo_ok=1
              echo "g05_ensure: rest fmt_one ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_fo_thin_o" "$_rt_fo_rest_o"
          fi
          if [ "$_rt_fo_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_fo_o" "$_rt_fmt_one_seed"; then
              _rt_fo_ok=1
              echo "g05_ensure: rest fmt_one ← $_rt_fmt_one_seed (G-02f-311 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_dt_o" ] && [ -f "$_rt_dispatch_thin_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_dispatch_thin_x" ]; then
            _rt_dt_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_thin_thin.XXXXXX") || true
            _rt_dt_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_thin_rest.XXXXXX") || true
            if [ -n "$_rt_dt_thin_o" ] && [ -n "$_rt_dt_rest_o" ] \
              && g05_try_x_to_o "$_rt_dispatch_thin_x" "$_rt_dt_thin_o" \
              && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_DISPATCH_THIN_FROM_X \
                   -c -o "$_rt_dt_rest_o" "$_rt_dispatch_thin_seed" \
              && $CC -r -nostdlib -o "$_rt_dt_o" "$_rt_dt_thin_o" "$_rt_dt_rest_o" 2>/dev/null; then
              _rt_dt_ok=1
              echo "g05_ensure: rest dispatch_thin ← full .x + rest marker (R2 H=0)"
            fi
            rm -f "$_rt_dt_thin_o" "$_rt_dt_rest_o"
          fi
          if [ "$_rt_dt_ok" = "0" ]; then
            # shellcheck disable=SC2086
            # cold / no PREFER：全 C 体；product 冷路径仍带 ASM_USE_COMPILER_IMPL_C 选 full 分派
            if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_ASM_USE_COMPILER_IMPL_C -c -o "$_rt_dt_o" "$_rt_dispatch_thin_seed"; then
              _rt_dt_ok=1
              echo "g05_ensure: rest dispatch_thin ← $_rt_dispatch_thin_seed (G-02f-312 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_di_o" ] && [ -f "$_rt_dispatch_impl_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_dispatch_impl_x" ]; then
            _rt_di_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_impl_thin.XXXXXX") || true
            _rt_di_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_dispatch_impl_rest.XXXXXX") || true
            if [ -n "$_rt_di_thin_o" ] && [ -n "$_rt_di_rest_o" ] \
              && g05_try_x_to_o "$_rt_dispatch_impl_x" "$_rt_di_thin_o" \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_DISPATCH_IMPL_FROM_X \
                   -c -o "$_rt_di_rest_o" "$_rt_dispatch_impl_seed" \
              && $CC -r -nostdlib -o "$_rt_di_o" "$_rt_di_thin_o" "$_rt_di_rest_o" 2>/dev/null; then
              _rt_di_ok=1
              echo "g05_ensure: rest dispatch_impl ← full .x + rest marker (R2 H=0)"
            fi
            rm -f "$_rt_di_thin_o" "$_rt_di_rest_o"
          fi
          if [ "$_rt_di_ok" = "0" ]; then
            # shellcheck disable=SC2086
            # same product NO_C / pipeline / impl flags as runtime rest
            if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_di_o" "$_rt_dispatch_impl_seed"; then
              _rt_di_ok=1
              echo "g05_ensure: rest dispatch_impl ← $_rt_dispatch_impl_seed (G-02f-313 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_xe_o" ] && [ -f "$_rt_run_x_emit_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_x_emit_x" ]; then
            _rt_xe_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_x_emit_thin.XXXXXX") || true
            _rt_xe_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_run_x_emit_rest.XXXXXX") || true
            if [ -n "$_rt_xe_thin_o" ] && [ -n "$_rt_xe_rest_o" ] \
              && g05_try_x_to_o "$_rt_run_x_emit_x" "$_rt_xe_thin_o" \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_RUN_X_EMIT_FROM_X \
                   -c -o "$_rt_xe_rest_o" "$_rt_run_x_emit_seed" \
              && $CC -r -nostdlib -o "$_rt_xe_o" "$_rt_xe_thin_o" "$_rt_xe_rest_o" 2>/dev/null; then
              _rt_xe_ok=1
              echo "g05_ensure: R2 run_x_emit ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_xe_thin_o" "$_rt_xe_rest_o"
          fi
          if [ "$_rt_xe_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_xe_o" "$_rt_run_x_emit_seed"; then
              _rt_xe_ok=1
              echo "g05_ensure: rest run_x_emit ← $_rt_run_x_emit_seed (G-02f-314 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_abk_o" ] && [ -f "$_rt_run_asm_backend_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_asm_backend_x" ]; then
            _rt_abk_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_abk_thin.XXXXXX") || true
            _rt_abk_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_abk_rest.XXXXXX") || true
            if [ -n "$_rt_abk_thin_o" ] && [ -n "$_rt_abk_rest_o" ] \
              && g05_try_x_to_o "$_rt_run_asm_backend_x" "$_rt_abk_thin_o" \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_RUN_ASM_BACKEND_FROM_X \
                   -c -o "$_rt_abk_rest_o" "$_rt_run_asm_backend_seed" \
              && $CC -r -nostdlib -o "$_rt_abk_o" "$_rt_abk_thin_o" "$_rt_abk_rest_o" 2>/dev/null; then
              _rt_abk_ok=1
              echo "g05_ensure: R2 run_asm_backend ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_abk_thin_o" "$_rt_abk_rest_o"
          fi
          if [ "$_rt_abk_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_abk_o" "$_rt_run_asm_backend_seed"; then
              _rt_abk_ok=1
              echo "g05_ensure: rest run_asm_backend ← $_rt_run_asm_backend_seed (G-02f-315 seed slice)"
            fi
          fi
        fi
        if [ -n "$_rt_rcp_o" ] && [ -f "$_rt_run_compiler_parsed_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_compiler_parsed_x" ]; then
            _rt_rcp_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_rcp_thin.XXXXXX") || true
            _rt_rcp_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_rcp_rest.XXXXXX") || true
            if [ -n "$_rt_rcp_thin_o" ] && [ -n "$_rt_rcp_rest_o" ] \
              && g05_try_x_to_o "$_rt_run_compiler_parsed_x" "$_rt_rcp_thin_o" \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_RUN_COMPILER_PARSED_FROM_X \
                   -c -o "$_rt_rcp_rest_o" "$_rt_run_compiler_parsed_seed" \
              && $CC -r -nostdlib -o "$_rt_rcp_o" "$_rt_rcp_thin_o" "$_rt_rcp_rest_o" 2>/dev/null; then
              _rt_rcp_ok=1
              echo "g05_ensure: R2 run_compiler_parsed ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_rcp_thin_o" "$_rt_rcp_rest_o"
          fi
          if [ "$_rt_rcp_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_rcp_o" "$_rt_run_compiler_parsed_seed"; then
              _rt_rcp_ok=1
              echo "g05_ensure: rest run_compiler_parsed ← $_rt_run_compiler_parsed_seed (G-02f-316 seed slice cold)"
            fi
          fi
        fi
        if [ -n "$_rt_st_o" ] && [ -f "$_rt_stack_seed" ]; then
          # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
          if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_stack_x" ]; then
            _rt_st_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_stack_thin.XXXXXX") || true
            _rt_st_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rt_stack_rest.XXXXXX") || true
            if [ -n "$_rt_st_thin_o" ] && [ -n "$_rt_st_rest_o" ] \
              && g05_try_x_to_o "$_rt_stack_x" "$_rt_st_thin_o" \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DSHUX_RT_STACK_FROM_X \
                   -c -o "$_rt_st_rest_o" "$_rt_stack_seed" \
              && $CC -r -nostdlib -o "$_rt_st_o" "$_rt_st_thin_o" "$_rt_st_rest_o" 2>/dev/null; then
              _rt_st_ok=1
              echo "g05_ensure: rest stack esc ← full .x + rest marker (R2 full H=0)"
            fi
            rm -f "$_rt_st_thin_o" "$_rt_st_rest_o"
          fi
          if [ "$_rt_st_ok" = "0" ]; then
            # shellcheck disable=SC2086
            if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_st_o" "$_rt_stack_seed"; then
              _rt_st_ok=1
              echo "g05_ensure: rest stack esc ← $_rt_stack_seed (G-02f-317 seed slice cold)"
            fi
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
        if [ "$_rt_compile_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_COMPILE_FROM_X"
        fi
        if [ "$_rt_run_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_RUN_EXEC_FROM_X"
        fi
        if [ "$_rt_asm_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_ASM_STUB_FROM_X"
        fi
        if [ "$_rt_entry_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_ENTRY_FROM_X"
        fi
        if [ "$_rt_diag_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_DIAG_ERRNO_FROM_X"
        fi
        if [ "$_rt_est_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_EMIT_STATE_FROM_X"
        fi
        if [ "$_rt_elfd_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_PIPELINE_ELF_DIAG_FROM_X"
        fi
        if [ "$_rt_lr_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_LIB_ROOT_FROM_X"
        fi
        if [ "$_rt_pd_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_PARSE_DIAG_FROM_X"
        fi
        if [ "$_rt_fs_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_FS_OPEN_FROM_X"
        fi
        if [ "$_rt_ab_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_ARENA_BUF_FROM_X"
        fi
        if [ "$_rt_fo_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_FMT_ONE_FROM_X"
        fi
        if [ "$_rt_dt_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_DISPATCH_THIN_FROM_X"
        fi
        if [ "$_rt_di_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_DISPATCH_IMPL_FROM_X"
        fi
        if [ "$_rt_xe_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_RUN_X_EMIT_FROM_X"
        fi
        if [ "$_rt_abk_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_RUN_ASM_BACKEND_FROM_X"
        fi
        if [ "$_rt_rcp_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_RUN_COMPILER_PARSED_FROM_X"
        fi
        if [ "$_rt_st_ok" = "1" ]; then
          _rt_rest_defs="$_rt_rest_defs -DSHUX_RT_STACK_FROM_X"
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
          # PLATFORM: SHARED — do NOT merge RT_SEED_SLICE objs into no_c.
          # g05_relink_env always links:
          #   rt_arena_buf / rt_emit_state / rt_preamble / rt_stack / rt_parse_diag
          # as separate .o. Merging them here caused Darwin 22× duplicate symbols
          # (parse_diag recovery + arena/emit/preamble/stack). Keep FROM_X on rest
          # (above) so no_c leaves those symbols U; permanent slice .o provide them.
          # Still merge non-slice hybrid pieces (content/util/argv/…/fs/fmt/dispatch…).
          if [ "$_rt_compile_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_cmp_o"
          fi
          if [ "$_rt_run_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_run_o"
          fi
          if [ "$_rt_asm_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_asm_o"
          fi
          if [ "$_rt_entry_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_ent_o"
          fi
          if [ "$_rt_diag_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_diag_o"
          fi
          if [ "$_rt_elfd_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_elfd_o"
          fi
          if [ "$_rt_lr_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_lr_o"
          fi
          if [ "$_rt_fs_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_fs_o"
          fi
          if [ "$_rt_fo_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_fo_o"
          fi
          if [ "$_rt_dt_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_dt_o"
          fi
          if [ "$_rt_di_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_di_o"
          fi
          if [ "$_rt_xe_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_xe_o"
          fi
          if [ "$_rt_abk_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_abk_o"
          fi
          if [ "$_rt_rcp_ok" = "1" ]; then
            _rt_link_objs="$_rt_link_objs $_rt_rcp_o"
          fi
          # Do NOT cp hybrid temps over permanent RT_SEED_SLICE .o (Makefile/seed
          # path owns those). Hybrid thin+rest can be incomplete and would
          # poison product asm codegen (CG002 code_len=0 on Darwin).
          # shellcheck disable=SC2086
          if $CC -r -nostdlib -o "$_rt_o" $_rt_link_objs "$_rt_rest_o" 2>/dev/null; then
            echo "g05_ensure: $_rt_o ← R2..R10/diag/…/parsed + rest (G-02f-317 hybrid; slices external)"
            _rt_done=1
          fi
        fi
        if [ "$_rt_done" = "0" ]; then
          echo "g05_ensure: L2 hybrid runtime slices failed; fallback full seed" >&2
        fi
        rm -f "$_rt_c_o" "$_rt_u_o" "$_rt_a_o" "$_rt_e_o" "$_rt_p_o" "$_rt_cmp_o" "$_rt_run_o" "$_rt_asm_o" "$_rt_ent_o" "$_rt_diag_o" "$_rt_est_o" "$_rt_elfd_o" "$_rt_lr_o" "$_rt_pd_o" "$_rt_fs_o" "$_rt_ab_o" "$_rt_fo_o" "$_rt_dt_o" "$_rt_di_o" "$_rt_xe_o" "$_rt_abk_o" "$_rt_rcp_o" "$_rt_st_o" "$_rt_rest_o"
      fi
      if [ "$_rt_done" = "0" ]; then
        # PREFER_X_O=0 / hybrid 失败回退：runtime.from_x.c 单 TU。
        # multi-error recovery 权威在 seeds/rt_parse_diag.from_x.c → 单独链 rt_parse_diag.o
        # （g05_relink_env RT_SEED_SLICE）；NO_C 已带 SHUX_RT_PARSE_DIAG_FROM_X，禁止再 merge。
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
  # G-02f-12 / G-02f-334：runtime_io_abi.o
  # 默认整 seed；PREFER_X_O=1 时 .x thin（fs/path/file_view 门闩）+ seed-rest（_impl / flags_impl）ld -r
  _rio=seeds/runtime_io_abi.from_x.c
  _rio_x=src/runtime_io_abi.x
  _rio_o=src/runtime_io_abi.o
  if [ -f "$_rio" ]; then
    if [ ! -f "$_rio_o" ] || [ "$_rio" -nt "$_rio_o" ] \
      || { [ -f "$_rio_x" ] && [ "$_rio_x" -nt "$_rio_o" ]; }; then
      _rio_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rio_x" ]; then
        _rio_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rio_thin.XXXXXX") || true
        _rio_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rio_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_rio_thin_o" ] && [ -n "$_rio_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_rio_x" "$_rio_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_RIO_THIN_FROM_X \
               -DSHUX_RUNTIME_IO_ABI_FROM_X \
               -c -o "$_rio_rest_o" "$_rio" \
          && $CC -r -nostdlib -o "$_rio_o" "$_rio_thin_o" "$_rio_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_rio_o ← $_rio_x + seed-rest (G-02f-334/rio R2 hybrid runtime_io_abi)"
          _rio_done=1
        else
          echo "g05_ensure: L2 hybrid runtime_io_abi failed; fallback full seed" >&2
        fi
        rm -f "$_rio_thin_o" "$_rio_rest_o"
      fi
      if [ "$_rio_done" = "0" ]; then
        echo "g05_ensure: $_rio_o ← seed (G-02f-12)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rio_o" "$_rio"
      fi
    fi
  fi
  # G-02f-12 / G-02f-343/344/345：runtime_driver_abi.o
  # R2 thin full：PREFER_X_O=1 时 abi_thin.x（61+ 门闩）+ seed-rest（FROM_X）ld -r
  _rdabi=seeds/runtime_driver_abi.from_x.c
  _rdabi_thin_x=src/runtime_driver_abi_thin.x
  _rdabi_o=src/runtime_driver_abi.o
  if [ -f "$_rdabi" ]; then
    if [ ! -f "$_rdabi_o" ] || [ "$_rdabi" -nt "$_rdabi_o" ] \
      || { [ -f "$_rdabi_thin_x" ] && [ "$_rdabi_thin_x" -nt "$_rdabi_o" ]; }; then
      _rdabi_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rdabi_thin_x" ]; then
        _rdabi_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdabi_thin.XXXXXX") || true
        _rdabi_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdabi_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_rdabi_thin_o" ] && [ -n "$_rdabi_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_rdabi_thin_x" "$_rdabi_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_RDABI_THIN_FROM_X \
               -c -o "$_rdabi_rest_o" "$_rdabi" \
          && $CC -r -nostdlib -o "$_rdabi_o" "$_rdabi_thin_o" "$_rdabi_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_rdabi_o ← $_rdabi_thin_x + seed-rest (driver_abi pure 深迁+getenv/数值 env hybrid; rest 无 pure-dup)"
          _rdabi_done=1
        else
          echo "g05_ensure: L2 hybrid runtime_driver_abi failed; fallback full seed" >&2
        fi
        rm -f "$_rdabi_thin_o" "$_rdabi_rest_o"
      fi
      if [ "$_rdabi_done" = "0" ]; then
        echo "g05_ensure: $_rdabi_o ← seed (G-02f-12)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rdabi_o" "$_rdabi"
      fi
    fi
  fi
  # G-02f-12 / G-02f-339：runtime_driver_diagnostic.o
  # R2 thin + Cap residual pure 深迁：PREFER thin.x（门闩 + 固定措辞/pipe orch/拼装 pure）+ seed-rest（FROM_X）ld -r
  _rdd=seeds/runtime_driver_diagnostic.from_x.c
  _rdd_thin_x=src/runtime_driver_diagnostic_thin.x
  _rdd_o=src/runtime_driver_diagnostic.o
  if [ -f "$_rdd" ]; then
    if [ ! -f "$_rdd_o" ] || [ "$_rdd" -nt "$_rdd_o" ] \
      || { [ -f "$_rdd_thin_x" ] && [ "$_rdd_thin_x" -nt "$_rdd_o" ]; }; then
      _rdd_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rdd_thin_x" ]; then
        _rdd_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdd_thin.XXXXXX") || true
        _rdd_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_rdd_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_rdd_thin_o" ] && [ -n "$_rdd_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_rdd_thin_x" "$_rdd_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_RDD_THIN_FROM_X \
               -c -o "$_rdd_rest_o" "$_rdd" \
          && $CC -r -nostdlib -o "$_rdd_o" "$_rdd_thin_o" "$_rdd_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_rdd_o ← $_rdd_thin_x + seed-rest (R2 hybrid diagnostic typeck debug/scratch pure deep)"
          _rdd_done=1
        else
          echo "g05_ensure: L2 hybrid runtime_driver_diagnostic failed; fallback full seed" >&2
        fi
        rm -f "$_rdd_thin_o" "$_rdd_rest_o"
      fi
      if [ "$_rdd_done" = "0" ]; then
        echo "g05_ensure: $_rdd_o ← seed (G-02f-12)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rdd_o" "$_rdd"
      fi
    fi
  fi
  # G-02f-12 / G-02f-331：lsp_diag_pipeline_ctx.o
  # 默认整 seed；PREFER_X_O=1 时 thin.x（别名门闩）+ seed-rest（C 尾 / _impl）ld -r
  _ldpc=seeds/lsp_diag_pipeline_ctx.from_x.c
  _ldpc_x=src/lsp/lsp_diag_pipeline_ctx.x
  _ldpc_o=src/lsp/lsp_diag_pipeline_ctx.o
  if [ -f "$_ldpc" ]; then
    if [ ! -f "$_ldpc_o" ] || [ "$_ldpc" -nt "$_ldpc_o" ] \
      || { [ -f "$_ldpc_x" ] && [ "$_ldpc_x" -nt "$_ldpc_o" ]; }; then
      _ldpc_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_ldpc_x" ]; then
        _ldpc_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_ldpc_thin_XXXXXX.o") || true
        _ldpc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_ldpc_rest_XXXXXX.o") || true
        # shellcheck disable=SC2086
        # thin 别名 weak，避免与 bootstrap/filtered 强符号冲突（对齐 strict_glue）
        if [ -n "$_ldpc_thin_o" ] && [ -n "$_ldpc_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_ldpc_x" "$_ldpc_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_LSP_CTX_THIN_FROM_X \
               -c -o "$_ldpc_rest_o" "$_ldpc" \
          && $CC -r -nostdlib -o "$_ldpc_o" "$_ldpc_thin_o" "$_ldpc_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_ldpc_o ← $_ldpc_x + seed-rest (G-02f-331 L2 hybrid ctx thin)"
          _ldpc_done=1
        else
          echo "g05_ensure: L2 hybrid lsp_diag_pipeline_ctx failed; fallback full seed" >&2
        fi
        rm -f "$_ldpc_thin_o" "$_ldpc_rest_o"
      fi
      if [ "$_ldpc_done" = "0" ]; then
        echo "g05_ensure: $_ldpc_o ← seed (G-02f-12)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_ldpc_o" "$_ldpc"
      fi
    fi
  fi
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
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_tcflags_x" ]; then
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
  # R2 product PREFER：async_liveness.o（独立 TU；非 glue #include）
  # PREFER：full .x + rest (-DSHUX_ASYNC_LIVENESS_FROM_X，仅 slice_marker) ld -r
  # 冷路径：整 seed C。PLATFORM: SHARED
  _aliv_seed=seeds/async_liveness.from_x.c
  _aliv_x=src/async/async_liveness.x
  _aliv_o=src/async/async_liveness.o
  if [ -f "$_aliv_seed" ]; then
    if [ ! -f "$_aliv_o" ] || [ "$_aliv_seed" -nt "$_aliv_o" ] \
      || { [ -f "$_aliv_x" ] && [ "$_aliv_x" -nt "$_aliv_o" ]; }; then
      _aliv_done=0
      mkdir -p src/async
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_aliv_x" ]; then
        _aliv_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_aliv_x.XXXXXX") || true
        _aliv_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_aliv_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_aliv_x_o" ] && [ -n "$_aliv_rest_o" ] \
          && g05_try_x_to_o "$_aliv_x" "$_aliv_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_ASYNC_LIVENESS_FROM_X \
               -c -o "$_aliv_rest_o" "$_aliv_seed" \
          && $CC -r -nostdlib -o "$_aliv_o" "$_aliv_x_o" "$_aliv_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_aliv_o ← $_aliv_x + rest marker (R2 pure+Cap residual PREFER)"
          _aliv_done=1
        else
          echo "g05_ensure: R2 async_liveness PREFER failed; fallback full seed" >&2
        fi
        rm -f "$_aliv_x_o" "$_aliv_rest_o"
      fi
      if [ "$_aliv_done" = "0" ]; then
        echo "g05_ensure: $_aliv_o ← async_liveness.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_aliv_o" "$_aliv_seed"
      fi
    fi
  fi
  # R2 product PREFER：async_cps_codegen.o（独立 TU；非 glue #include）
  # PREFER：full .x + rest (-DSHUX_ASYNC_CPS_CODEGEN_FROM_X，仅 slice_marker) ld -r
  # 冷路径：整 seed C。PLATFORM: SHARED
  _acps_seed=seeds/async_cps_codegen.from_x.c
  _acps_x=src/async/async_cps_codegen.x
  _acps_o=src/async/async_cps_codegen.o
  if [ -f "$_acps_seed" ]; then
    if [ ! -f "$_acps_o" ] || [ "$_acps_seed" -nt "$_acps_o" ] \
      || { [ -f "$_acps_x" ] && [ "$_acps_x" -nt "$_acps_o" ]; }; then
      _acps_done=0
      mkdir -p src/async
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_acps_x" ]; then
        _acps_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_acps_x.XXXXXX") || true
        _acps_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_acps_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_acps_x_o" ] && [ -n "$_acps_rest_o" ] \
          && g05_try_x_to_o "$_acps_x" "$_acps_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_ASYNC_CPS_CODEGEN_FROM_X \
               -c -o "$_acps_rest_o" "$_acps_seed" \
          && $CC -r -nostdlib -o "$_acps_o" "$_acps_x_o" "$_acps_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_acps_o ← $_acps_x + rest marker (R2 pure wave1–5 PREFER)"
          _acps_done=1
        else
          echo "g05_ensure: R2 async_cps_codegen PREFER failed; fallback full seed" >&2
        fi
        rm -f "$_acps_x_o" "$_acps_rest_o"
      fi
      if [ "$_acps_done" = "0" ]; then
        echo "g05_ensure: $_acps_o ← async_cps_codegen.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_acps_o" "$_acps_seed"
      fi
    fi
  fi
  # R2 unbundle：async_asm_pool.o（从 pipeline_glue #include 拆出独立 TU）
  # PREFER：full .x + rest (-DSHUX_ASYNC_ASM_POOL_FROM_X，仅 slice_marker) ld -r
  # 冷路径：整 seed C。产品 glue 只 #include 头，符号由本 .o 提供。
  # PLATFORM: SHARED
  _aap_seed=seeds/async_asm_pool.from_x.c
  _aap_x=src/asm/async_asm_pool.x
  _aap_o=src/async/async_asm_pool.o
  if [ -f "$_aap_seed" ]; then
    if [ ! -f "$_aap_o" ] || [ "$_aap_seed" -nt "$_aap_o" ] \
      || { [ -f "$_aap_x" ] && [ "$_aap_x" -nt "$_aap_o" ]; }; then
      _aap_done=0
      mkdir -p src/async
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_aap_x" ]; then
        _aap_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_aap_x.XXXXXX") || true
        _aap_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_aap_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_aap_x_o" ] && [ -n "$_aap_rest_o" ] \
          && g05_try_x_to_o "$_aap_x" "$_aap_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_ASYNC_ASM_POOL_FROM_X \
               -c -o "$_aap_rest_o" "$_aap_seed" \
          && $CC -r -nostdlib -o "$_aap_o" "$_aap_x_o" "$_aap_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_aap_o ← $_aap_x + rest marker (R2 full async_asm_pool H=0; glue unbundled)"
          _aap_done=1
        else
          echo "g05_ensure: R2 full async_asm_pool PREFER failed; fallback full seed" >&2
        fi
        rm -f "$_aap_x_o" "$_aap_rest_o"
      fi
      if [ "$_aap_done" = "0" ]; then
        echo "g05_ensure: $_aap_o ← async_asm_pool.from_x (cold seed; unbundled)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_aap_o" "$_aap_seed"
      fi
    fi
  fi
  # Unbundle hygiene：pipeline_glue.c 变更后，旧 pipeline_x / filtered / standalone
  # 仍可能内嵌 pool T → Darwin 与 pool.o 双定义红。产品 g05 无 make 时在此重建。
  # PLATFORM: SHARED — Linux 允许多定义时也应以无内嵌为真值。
  if [ -f pipeline_glue.c ] && [ -f pipeline_gen.c ]; then
    if [ ! -f pipeline_x.o ] || [ pipeline_glue.c -nt pipeline_x.o ] \
      || [ pipeline_gen.c -nt pipeline_x.o ]; then
      echo "g05_ensure: pipeline_x.o ← pipeline_gen.c (glue unbundle / stale vs pipeline_glue.c)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Wno-error -c -o pipeline_x.o pipeline_gen.c
      if [ -d build_asm/gen_driver ]; then
        cp -f pipeline_x.o build_asm/gen_driver/pipeline_x.o 2>/dev/null || true
      fi
    fi
  fi
  if [ -f seeds/pipeline_glue_standalone.from_x.c ] && [ -f pipeline_glue.c ]; then
    _pgs_o=build_asm/pipeline_glue_standalone.o
    if [ ! -f "$_pgs_o" ] || [ pipeline_glue.c -nt "$_pgs_o" ] \
      || [ seeds/pipeline_glue_standalone.from_x.c -nt "$_pgs_o" ]; then
      echo "g05_ensure: $_pgs_o ← pipeline_glue_standalone (glue unbundle; no pool embed)"
      mkdir -p build_asm
      # shellcheck disable=SC2086
      sh scripts/cc_inc_tu.sh seeds/pipeline_glue_standalone.from_x.c "$_pgs_o" \
        -Wno-error=return-type -Ibuild_asm
    fi
  fi
  # Darwin product link uses filtered pipeline; must drop stale pool T after unbundle.
  _filt=build_asm/bootstrap_seed_pipeline_filtered.o
  if [ -f pipeline_x.o ] && { [ ! -f "$_filt" ] || [ pipeline_x.o -nt "$_filt" ]; }; then
    if [ -f Makefile ]; then
      echo "g05_ensure: make $_filt (pipeline_x newer; drop embedded pool if any)"
      make -s "$_filt" || echo "g05_ensure: WARN make $_filt failed (Darwin may dual-def pool)" >&2
    fi
  fi
  # G-02f-7 / R2 full：simd_enc.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_SIMD_ENC_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _simd_enc=seeds/simd_enc.from_x.c
  _simd_enc_x=src/asm/simd_enc.x
  _simd_enc_thin_x=src/asm/simd_enc_thin.x
  _simd_enc_o=src/asm/simd_enc.o
  if [ -f "$_simd_enc" ]; then
    if [ ! -f "$_simd_enc_o" ] || [ "$_simd_enc" -nt "$_simd_enc_o" ] \
      || { [ -f "$_simd_enc_x" ] && [ "$_simd_enc_x" -nt "$_simd_enc_o" ]; } \
      || { [ -f "$_simd_enc_thin_x" ] && [ "$_simd_enc_thin_x" -nt "$_simd_enc_o" ]; }; then
      _simd_enc_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_simd_enc_x" ]; then
        _simd_enc_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_enc_x.XXXXXX") || true
        _simd_enc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_enc_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_simd_enc_x_o" ] && [ -n "$_simd_enc_rest_o" ] \
          && g05_try_x_to_o "$_simd_enc_x" "$_simd_enc_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_SIMD_ENC_FROM_X \
               -c -o "$_simd_enc_rest_o" "$_simd_enc" \
          && $CC -r -nostdlib -o "$_simd_enc_o" "$_simd_enc_x_o" "$_simd_enc_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_simd_enc_o ← $_simd_enc_x + rest marker (R2 full simd_enc H=0)"
          _simd_enc_done=1
        else
          echo "g05_ensure: R2 full simd_enc failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_simd_enc_x_o" "$_simd_enc_rest_o"
      fi
      if [ "$_simd_enc_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_simd_enc_thin_x" ]; then
        _simd_enc_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_enc_thin.XXXXXX") || true
        _simd_enc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_enc_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_simd_enc_thin_o" ] && [ -n "$_simd_enc_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_simd_enc_thin_x" "$_simd_enc_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_SIMD_ENC_THIN_FROM_X \
               -c -o "$_simd_enc_rest_o" "$_simd_enc" \
          && $CC -r -nostdlib -o "$_simd_enc_o" "$_simd_enc_thin_o" "$_simd_enc_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_simd_enc_o ← $_simd_enc_thin_x + seed-rest (L2 hybrid simd_enc thin fallback)"
          _simd_enc_done=1
        else
          echo "g05_ensure: L2 hybrid simd_enc thin failed; fallback full seed" >&2
        fi
        rm -f "$_simd_enc_thin_o" "$_simd_enc_rest_o"
      fi
      if [ "$_simd_enc_done" = "0" ]; then
        echo "g05_ensure: $_simd_enc_o ← simd_enc.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_simd_enc_o" "$_simd_enc"
      fi
    fi
  fi
  # G-02f-8 / R2 full：simd_loop.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_SIMD_LOOP_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _simd_loop=seeds/simd_loop.from_x.c
  _simd_loop_x=src/asm/simd_loop.x
  _simd_loop_thin_x=src/asm/simd_loop_thin.x
  _simd_loop_o=src/asm/simd_loop.o
  if [ -f "$_simd_loop" ]; then
    if [ ! -f "$_simd_loop_o" ] || [ "$_simd_loop" -nt "$_simd_loop_o" ] \
      || { [ -f "$_simd_loop_x" ] && [ "$_simd_loop_x" -nt "$_simd_loop_o" ]; } \
      || { [ -f "$_simd_loop_thin_x" ] && [ "$_simd_loop_thin_x" -nt "$_simd_loop_o" ]; }; then
      _simd_loop_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_simd_loop_x" ]; then
        _simd_loop_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_loop_x.XXXXXX") || true
        _simd_loop_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_loop_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_simd_loop_x_o" ] && [ -n "$_simd_loop_rest_o" ] \
          && g05_try_x_to_o "$_simd_loop_x" "$_simd_loop_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_SIMD_LOOP_FROM_X \
               -c -o "$_simd_loop_rest_o" "$_simd_loop" \
          && $CC -r -nostdlib -o "$_simd_loop_o" "$_simd_loop_x_o" "$_simd_loop_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_simd_loop_o ← $_simd_loop_x + rest marker (R2 full simd_loop H=0)"
          _simd_loop_done=1
        else
          echo "g05_ensure: R2 full simd_loop failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_simd_loop_x_o" "$_simd_loop_rest_o"
      fi
      if [ "$_simd_loop_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_simd_loop_thin_x" ]; then
        _simd_loop_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_loop_thin.XXXXXX") || true
        _simd_loop_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_simd_loop_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_simd_loop_thin_o" ] && [ -n "$_simd_loop_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_simd_loop_thin_x" "$_simd_loop_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_SIMD_LOOP_THIN_FROM_X \
               -c -o "$_simd_loop_rest_o" "$_simd_loop" \
          && $CC -r -nostdlib -o "$_simd_loop_o" "$_simd_loop_thin_o" "$_simd_loop_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_simd_loop_o ← $_simd_loop_thin_x + seed-rest (L2 hybrid simd_loop thin fallback)"
          _simd_loop_done=1
        else
          echo "g05_ensure: L2 hybrid simd_loop thin failed; fallback full seed" >&2
        fi
        rm -f "$_simd_loop_thin_o" "$_simd_loop_rest_o"
      fi
      if [ "$_simd_loop_done" = "0" ]; then
        echo "g05_ensure: $_simd_loop_o ← simd_loop.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_simd_loop_o" "$_simd_loop"
      fi
    fi
  fi
  # G-02f-9 / R2 full：backend_enc_dispatch.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_BACKEND_ENC_DISPATCH_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _bed=seeds/backend_enc_dispatch.from_x.c
  _bed_x=src/asm/backend_enc_dispatch.x
  _bed_thin_x=src/asm/backend_enc_dispatch_thin.x
  _bed_o=src/asm/backend_enc_dispatch.o
  if [ -f "$_bed" ]; then
    if [ ! -f "$_bed_o" ] || [ "$_bed" -nt "$_bed_o" ] \
      || { [ -f "$_bed_x" ] && [ "$_bed_x" -nt "$_bed_o" ]; } \
      || { [ -f "$_bed_thin_x" ] && [ "$_bed_thin_x" -nt "$_bed_o" ]; }; then
      _bed_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bed_x" ]; then
        _bed_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_bed_x.XXXXXX") || true
        _bed_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bed_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bed_x_o" ] && [ -n "$_bed_rest_o" ] \
          && g05_try_x_to_o "$_bed_x" "$_bed_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_BACKEND_ENC_DISPATCH_FROM_X \
               -c -o "$_bed_rest_o" "$_bed" \
          && $CC -r -nostdlib -o "$_bed_o" "$_bed_x_o" "$_bed_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bed_o ← $_bed_x + rest marker (R2 full enc_dispatch H=0)"
          _bed_done=1
        else
          echo "g05_ensure: R2 full enc_dispatch failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_bed_x_o" "$_bed_rest_o"
      fi
      if [ "$_bed_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bed_thin_x" ]; then
        _bed_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_bed_thin.XXXXXX") || true
        _bed_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bed_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bed_thin_o" ] && [ -n "$_bed_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_bed_thin_x" "$_bed_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_ENC_DISPATCH_THIN_FROM_X \
               -c -o "$_bed_rest_o" "$_bed" \
          && $CC -r -nostdlib -o "$_bed_o" "$_bed_thin_o" "$_bed_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bed_o ← $_bed_thin_x + seed-rest (L2 hybrid enc_dispatch thin fallback)"
          _bed_done=1
        else
          echo "g05_ensure: L2 hybrid enc_dispatch thin failed; fallback full seed" >&2
        fi
        rm -f "$_bed_thin_o" "$_bed_rest_o"
      fi
      if [ "$_bed_done" = "0" ]; then
        echo "g05_ensure: backend_enc_dispatch.o ← backend_enc_dispatch.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bed_o" "$_bed"
      fi
    fi
  fi
  # G-02f-9 / R2 full：backend_arch_emit_dispatch.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _bae=seeds/backend_arch_emit_dispatch.from_x.c
  _bae_x=src/asm/backend_arch_emit_dispatch.x
  _bae_thin_x=src/asm/backend_arch_emit_dispatch_thin.x
  _bae_o=src/asm/backend_arch_emit_dispatch.o
  if [ -f "$_bae" ]; then
    if [ ! -f "$_bae_o" ] || [ "$_bae" -nt "$_bae_o" ] \
      || { [ -f "$_bae_x" ] && [ "$_bae_x" -nt "$_bae_o" ]; } \
      || { [ -f "$_bae_thin_x" ] && [ "$_bae_thin_x" -nt "$_bae_o" ]; }; then
      _bae_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bae_x" ]; then
        _bae_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_bae_x.XXXXXX") || true
        _bae_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bae_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bae_x_o" ] && [ -n "$_bae_rest_o" ] \
          && g05_try_x_to_o "$_bae_x" "$_bae_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X \
               -c -o "$_bae_rest_o" "$_bae" \
          && $CC -r -nostdlib -o "$_bae_o" "$_bae_x_o" "$_bae_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bae_o ← $_bae_x + rest marker (R2 full arch_emit H=0)"
          _bae_done=1
        else
          echo "g05_ensure: R2 full arch_emit failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_bae_x_o" "$_bae_rest_o"
      fi
      if [ "$_bae_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bae_thin_x" ]; then
        _bae_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_bae_thin.XXXXXX") || true
        _bae_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bae_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bae_thin_o" ] && [ -n "$_bae_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_bae_thin_x" "$_bae_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_ARCH_EMIT_THIN_FROM_X \
               -c -o "$_bae_rest_o" "$_bae" \
          && $CC -r -nostdlib -o "$_bae_o" "$_bae_thin_o" "$_bae_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bae_o ← $_bae_thin_x + seed-rest (L2 hybrid arch_emit thin fallback)"
          _bae_done=1
        else
          echo "g05_ensure: L2 hybrid arch_emit thin failed; fallback full seed" >&2
        fi
        rm -f "$_bae_thin_o" "$_bae_rest_o"
      fi
      if [ "$_bae_done" = "0" ]; then
        echo "g05_ensure: backend_arch_emit_dispatch.o ← backend_arch_emit_dispatch.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bae_o" "$_bae"
      fi
    fi
  fi
  # G-02f-9 / R2 full：backend_try_inline_dispatch.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_BACKEND_TRY_INLINE_DISPATCH_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _bti=seeds/backend_try_inline_dispatch.from_x.c
  _bti_x=src/asm/backend_try_inline_dispatch.x
  _bti_thin_x=src/asm/backend_try_inline_dispatch_thin.x
  _bti_o=src/asm/backend_try_inline_dispatch.o
  if [ -f "$_bti" ]; then
    if [ ! -f "$_bti_o" ] || [ "$_bti" -nt "$_bti_o" ] \
      || { [ -f "$_bti_x" ] && [ "$_bti_x" -nt "$_bti_o" ]; } \
      || { [ -f "$_bti_thin_x" ] && [ "$_bti_thin_x" -nt "$_bti_o" ]; }; then
      _bti_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bti_x" ]; then
        _bti_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_bti_x.XXXXXX") || true
        _bti_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bti_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bti_x_o" ] && [ -n "$_bti_rest_o" ] \
          && g05_try_x_to_o "$_bti_x" "$_bti_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_BACKEND_TRY_INLINE_DISPATCH_FROM_X \
               -c -o "$_bti_rest_o" "$_bti" \
          && $CC -r -nostdlib -o "$_bti_o" "$_bti_x_o" "$_bti_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bti_o ← $_bti_x + rest marker (R2 full try_inline H=0)"
          _bti_done=1
        else
          echo "g05_ensure: R2 full try_inline failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_bti_x_o" "$_bti_rest_o"
      fi
      if [ "$_bti_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bti_thin_x" ]; then
        _bti_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_bti_thin.XXXXXX") || true
        _bti_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bti_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bti_thin_o" ] && [ -n "$_bti_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_bti_thin_x" "$_bti_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_TRY_INLINE_THIN_FROM_X \
               -c -o "$_bti_rest_o" "$_bti" \
          && $CC -r -nostdlib -o "$_bti_o" "$_bti_thin_o" "$_bti_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bti_o ← $_bti_thin_x + seed-rest (L2 hybrid try_inline thin fallback)"
          _bti_done=1
        else
          echo "g05_ensure: L2 hybrid try_inline thin failed; fallback full seed" >&2
        fi
        rm -f "$_bti_thin_o" "$_bti_rest_o"
      fi
      if [ "$_bti_done" = "0" ]; then
        echo "g05_ensure: backend_try_inline_dispatch.o ← backend_try_inline_dispatch.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bti_o" "$_bti"
      fi
    fi
  fi
  # G-02f-9 / R2 full：backend_call_dispatch.o
  # PREFER：full.x 真迁业务 + rest (-DSHUX_BACKEND_CALL_DISPATCH_FROM_X，仅 marker) ld -r
  # full.x 失败时回退 L2 thin hybrid；再失败整 seed 冷路径
  _bcd=seeds/backend_call_dispatch.from_x.c
  _bcd_x=src/asm/backend_call_dispatch.x
  _bcd_thin_x=src/asm/backend_call_dispatch_thin.x
  _bcd_o=src/asm/backend_call_dispatch.o
  if [ -f "$_bcd" ]; then
    if [ ! -f "$_bcd_o" ] || [ "$_bcd" -nt "$_bcd_o" ] \
      || { [ -f "$_bcd_x" ] && [ "$_bcd_x" -nt "$_bcd_o" ]; } \
      || { [ -f "$_bcd_thin_x" ] && [ "$_bcd_thin_x" -nt "$_bcd_o" ]; }; then
      _bcd_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bcd_x" ]; then
        _bcd_x_o=$(mktemp "${TMPDIR:-/tmp}/g05_bcd_x.XXXXXX") || true
        _bcd_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bcd_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bcd_x_o" ] && [ -n "$_bcd_rest_o" ] \
          && g05_try_x_to_o "$_bcd_x" "$_bcd_x_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_BACKEND_CALL_DISPATCH_FROM_X \
               -c -o "$_bcd_rest_o" "$_bcd" \
          && $CC -r -nostdlib -o "$_bcd_o" "$_bcd_x_o" "$_bcd_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bcd_o ← $_bcd_x + rest marker (R2 full call_dispatch H=0)"
          _bcd_done=1
        else
          echo "g05_ensure: R2 full call_dispatch failed; try L2 thin hybrid" >&2
        fi
        rm -f "$_bcd_x_o" "$_bcd_rest_o"
      fi
      if [ "$_bcd_done" = "0" ] && [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bcd_thin_x" ]; then
        _bcd_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_bcd_thin.XXXXXX") || true
        _bcd_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bcd_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_bcd_thin_o" ] && [ -n "$_bcd_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_bcd_thin_x" "$_bcd_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_CALL_DISPATCH_THIN_FROM_X \
               -c -o "$_bcd_rest_o" "$_bcd" \
          && $CC -r -nostdlib -o "$_bcd_o" "$_bcd_thin_o" "$_bcd_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_bcd_o ← $_bcd_thin_x + seed-rest (L2 hybrid call_dispatch thin fallback)"
          _bcd_done=1
        else
          echo "g05_ensure: L2 hybrid call_dispatch thin failed; fallback full seed" >&2
        fi
        rm -f "$_bcd_thin_o" "$_bcd_rest_o"
      fi
      if [ "$_bcd_done" = "0" ]; then
        echo "g05_ensure: backend_call_dispatch.o ← backend_call_dispatch.from_x (cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bcd_o" "$_bcd"
      fi
    fi
  fi
  # G-02f-10 / G-02f-333：parser_asm_parse_expr_link.o
  # 默认整 seed（SKIP_X）；PREFER_X_O=1 时 .x thin（debug_enabled 门闩）+ seed-rest ld -r
  _pel=seeds/parser_asm_parse_expr_link.from_x.c
  _pel_x=src/asm/parser_asm_parse_expr_link.x
  _pel_o=src/asm/parser_asm_parse_expr_link.o
  if [ -f "$_pel" ]; then
    if [ ! -f "$_pel_o" ] || [ "$_pel" -nt "$_pel_o" ] \
      || { [ -f "$_pel_x" ] && [ "$_pel_x" -nt "$_pel_o" ]; }; then
      _pel_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_pel_x" ]; then
        _pel_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pel_thin.XXXXXX") || true
        _pel_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_pel_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_pel_thin_o" ] && [ -n "$_pel_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_pel_x" "$_pel_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS \
               -DSHUX_L2_PEL_THIN_FROM_X -c -o "$_pel_rest_o" "$_pel" \
          && $CC -r -nostdlib -o "$_pel_o" "$_pel_thin_o" "$_pel_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_pel_o ← $_pel_x + seed-rest (G-02f-333 L2 hybrid parse_expr_link thin)"
          _pel_done=1
        else
          echo "g05_ensure: L2 hybrid parse_expr_link failed; fallback full seed" >&2
        fi
        rm -f "$_pel_thin_o" "$_pel_rest_o"
      fi
      if [ "$_pel_done" = "0" ]; then
        echo "g05_ensure: $_pel_o ← seed (G-02f-10 SKIP_X)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS -c -o "$_pel_o" "$_pel"
      fi
    fi
  fi
  # G-02f-10 / G-02f-279～319：parser_asm_thin_glue.o ← thin seed（默认整 TU；prefer 时 P1–P7+P9+P10 hybrid）
  # P8 seed_parse：产品仍 NO_SEED_PARSE（parse_into_buf 由 parser_x 提供）；仅 smoke -c，不 ld -r 进产品 glue
  # P9 stretch+suite hybrid；P10 glue tail hybrid（G-02f-319）
  _pthin=seeds/parser_asm_thin_c.from_x.c
  _pthin_p1_seed=seeds/pthin_lex_skip.from_x.c
  _pthin_p2_seed=seeds/pthin_let_alias.from_x.c
  _pthin_p3_seed=seeds/pthin_type_ref.from_x.c
  _pthin_p4p_seed=seeds/pthin_expr_primary.from_x.c
  _pthin_p4u_seed=seeds/pthin_expr_unary.from_x.c
  _pthin_p4b_seed=seeds/pthin_expr_binop.from_x.c
  _pthin_p4as_seed=seeds/pthin_expr_as_suffix.from_x.c
  _pthin_p4t_seed=seeds/pthin_expr_ternary.from_x.c
  _pthin_p5_seed=seeds/pthin_ctrl.from_x.c
  _pthin_p6_seed=seeds/pthin_fn_block.from_x.c
  _pthin_p7_seed=seeds/pthin_simd.from_x.c
  _pthin_p8_seed=seeds/pthin_seed_parse.from_x.c
  _pthin_p9_seed=seeds/pthin_stretch.from_x.c
  _pthin_p10_seed=seeds/pthin_glue.from_x.c
  _pthin_p11_seed=seeds/pthin_imports.from_x.c
  _pthin_p12_seed=seeds/pthin_skip_tl.from_x.c
  _pthin_p13_seed=seeds/pthin_try_skip_allow.from_x.c
  _pthin_p14_seed=seeds/pthin_skip_if.from_x.c
  _pthin_p15_seed=seeds/pthin_library.from_x.c
  _pthin_p16_seed=seeds/pthin_diag_pipeline.from_x.c
  _pthin_p17_seed=seeds/pthin_diag_late.from_x.c
  _pthin_p18_seed=seeds/pthin_body_tl.from_x.c
  _pthin_p19_seed=seeds/pthin_helpers.from_x.c
  _pthin_p20_seed=seeds/pthin_foundation.from_x.c
  if [ -f "$_pthin" ]; then
    if [ ! -f parser_asm_thin_glue.o ] || [ "$_pthin" -nt parser_asm_thin_glue.o ] \
      || { [ -f "$_pthin_p1_seed" ] && [ "$_pthin_p1_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p2_seed" ] && [ "$_pthin_p2_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p3_seed" ] && [ "$_pthin_p3_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4p_seed" ] && [ "$_pthin_p4p_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4u_seed" ] && [ "$_pthin_p4u_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4b_seed" ] && [ "$_pthin_p4b_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4as_seed" ] && [ "$_pthin_p4as_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4t_seed" ] && [ "$_pthin_p4t_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p5_seed" ] && [ "$_pthin_p5_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p6_seed" ] && [ "$_pthin_p6_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p7_seed" ] && [ "$_pthin_p7_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p8_seed" ] && [ "$_pthin_p8_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p9_seed" ] && [ "$_pthin_p9_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p10_seed" ] && [ "$_pthin_p10_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p11_seed" ] && [ "$_pthin_p11_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p12_seed" ] && [ "$_pthin_p12_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p13_seed" ] && [ "$_pthin_p13_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p14_seed" ] && [ "$_pthin_p14_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p15_seed" ] && [ "$_pthin_p15_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p16_seed" ] && [ "$_pthin_p16_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p17_seed" ] && [ "$_pthin_p17_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p18_seed" ] && [ "$_pthin_p18_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p19_seed" ] && [ "$_pthin_p19_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p20_seed" ] && [ "$_pthin_p20_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_glue_tail_slice.inc ] && [ seeds/parser_asm/parser_asm_glue_tail_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_library_wrap_slice.inc ] && [ seeds/parser_asm/parser_asm_library_wrap_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_body_tl_slice.inc ] && [ seeds/parser_asm/parser_asm_body_tl_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_imports_slice.inc ] && [ seeds/parser_asm/parser_asm_imports_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_skip_tl_slice.inc ] && [ seeds/parser_asm/parser_asm_skip_tl_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_helpers_slice.inc ] && [ seeds/parser_asm/parser_asm_helpers_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_lex_skip_slice.inc ] && [ seeds/parser_asm/parser_asm_lex_skip_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_foundation_slice.inc ] && [ seeds/parser_asm/parser_asm_foundation_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_diag_pipeline_slice.inc ] && [ seeds/parser_asm/parser_asm_diag_pipeline_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_diag_late_slice.inc ] && [ seeds/parser_asm/parser_asm_diag_late_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_try_skip_allow_slice.inc ] && [ seeds/parser_asm/parser_asm_try_skip_allow_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_skip_if_slice.inc ] && [ seeds/parser_asm/parser_asm_skip_if_slice.inc -nt parser_asm_thin_glue.o ]; }; then
      # PLATFORM: SHARED — monothin #includes the .inc files above; hybrid pthin_*
      # .c mtimes alone miss glue_tail/library_wrap edits (Ubuntu UNDEF after M2 re-pin).
      _pthin_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && { [ -f "$_pthin_p1_seed" ] || [ -f "$_pthin_p2_seed" ] || [ -f "$_pthin_p3_seed" ] || [ -f "$_pthin_p4p_seed" ] || [ -f "$_pthin_p4u_seed" ] || [ -f "$_pthin_p4b_seed" ] || [ -f "$_pthin_p4as_seed" ] || [ -f "$_pthin_p4t_seed" ] || [ -f "$_pthin_p5_seed" ] || [ -f "$_pthin_p6_seed" ] || [ -f "$_pthin_p7_seed" ] || [ -f "$_pthin_p9_seed" ] || [ -f "$_pthin_p10_seed" ] || [ -f "$_pthin_p11_seed" ] || [ -f "$_pthin_p12_seed" ] || [ -f "$_pthin_p13_seed" ] || [ -f "$_pthin_p14_seed" ] || [ -f "$_pthin_p15_seed" ] || [ -f "$_pthin_p16_seed" ] || [ -f "$_pthin_p17_seed" ] || [ -f "$_pthin_p18_seed" ] || [ -f "$_pthin_p19_seed" ] || [ -f "$_pthin_p20_seed" ]; }; then
        _pthin_p1_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p1.XXXXXX") || true
        _pthin_p2_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p2.XXXXXX") || true
        _pthin_p3_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p3.XXXXXX") || true
        _pthin_p4p_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4p.XXXXXX") || true
        _pthin_p4u_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4u.XXXXXX") || true
        _pthin_p4b_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4b.XXXXXX") || true
        _pthin_p4as_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4as.XXXXXX") || true
        _pthin_p4t_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4t.XXXXXX") || true
        _pthin_p5_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p5.XXXXXX") || true
        _pthin_p6_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p6.XXXXXX") || true
        _pthin_p7_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p7.XXXXXX") || true
        _pthin_p9_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p9.XXXXXX") || true
        _pthin_p10_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p10.XXXXXX") || true
        _pthin_p11_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p11.XXXXXX") || true
        _pthin_p12_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p12.XXXXXX") || true
        _pthin_p13_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p13.XXXXXX") || true
        _pthin_p14_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p14.XXXXXX") || true
        _pthin_p15_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p15.XXXXXX") || true
        _pthin_p16_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p16.XXXXXX") || true
        _pthin_p17_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p17.XXXXXX") || true
        _pthin_p18_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p18.XXXXXX") || true
        _pthin_p19_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p19.XXXXXX") || true
        _pthin_p20_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p20.XXXXXX") || true
        _pthin_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_rest.XXXXXX") || true
        _pthin_p1_ok=0
        _pthin_p2_ok=0
        _pthin_p3_ok=0
        _pthin_p4p_ok=0
        _pthin_p4u_ok=0
        _pthin_p4b_ok=0
        _pthin_p4as_ok=0
        _pthin_p4t_ok=0
        _pthin_p5_ok=0
        _pthin_p6_ok=0
        _pthin_p7_ok=0
        _pthin_p9_ok=0
        _pthin_p10_ok=0
        _pthin_p11_ok=0
        _pthin_p12_ok=0
        _pthin_p13_ok=0
        _pthin_p14_ok=0
        _pthin_p15_ok=0
        _pthin_p16_ok=0
        _pthin_p17_ok=0
        _pthin_p18_ok=0
        _pthin_p19_ok=0
        _pthin_p20_ok=0
        _pthin_rest_defs="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
        if [ -n "$_pthin_p1_o" ] && [ -f "$_pthin_p1_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p1_o" "$_pthin_p1_seed"; then
            _pthin_p1_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_LEX_SKIP_FROM_X"
            echo "g05_ensure: P1 lex/skip ← $_pthin_p1_seed (G-02f-281 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p2_o" ] && [ -f "$_pthin_p2_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p2_o" "$_pthin_p2_seed"; then
            _pthin_p2_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_LET_ALIAS_FROM_X"
            echo "g05_ensure: P2 let/alias ← $_pthin_p2_seed (G-02f-279 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p3_o" ] && [ -f "$_pthin_p3_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p3_o" "$_pthin_p3_seed"; then
            _pthin_p3_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_TYPE_REF_FROM_X"
            echo "g05_ensure: P3 type_ref ← $_pthin_p3_seed (G-02f-280 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p4p_o" ] && [ -f "$_pthin_p4p_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p4p_o" "$_pthin_p4p_seed"; then
            _pthin_p4p_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_EXPR_PRIMARY_FROM_X"
            echo "g05_ensure: P4 primary ← $_pthin_p4p_seed (G-02f-282 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p4u_o" ] && [ -f "$_pthin_p4u_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p4u_o" "$_pthin_p4u_seed"; then
            _pthin_p4u_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_EXPR_UNARY_FROM_X"
            echo "g05_ensure: P4 unary ← $_pthin_p4u_seed (G-02f-283 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p4b_o" ] && [ -f "$_pthin_p4b_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p4b_o" "$_pthin_p4b_seed"; then
            _pthin_p4b_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_EXPR_BINOP_FROM_X"
            echo "g05_ensure: P4 binop ← $_pthin_p4b_seed (G-02f-284 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p4as_o" ] && [ -f "$_pthin_p4as_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p4as_o" "$_pthin_p4as_seed"; then
            _pthin_p4as_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_EXPR_AS_SUFFIX_FROM_X"
            echo "g05_ensure: P4 as_suffix ← $_pthin_p4as_seed (G-02f-285 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p4t_o" ] && [ -f "$_pthin_p4t_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p4t_o" "$_pthin_p4t_seed"; then
            _pthin_p4t_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_EXPR_TERNARY_FROM_X"
            echo "g05_ensure: P4 ternary ← $_pthin_p4t_seed (G-02f-285 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p5_o" ] && [ -f "$_pthin_p5_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p5_o" "$_pthin_p5_seed"; then
            _pthin_p5_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_CTRL_FROM_X"
            echo "g05_ensure: P5 ctrl ← $_pthin_p5_seed (G-02f-286 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p6_o" ] && [ -f "$_pthin_p6_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p6_o" "$_pthin_p6_seed"; then
            _pthin_p6_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_FN_BLOCK_FROM_X"
            echo "g05_ensure: P6 fn/block ← $_pthin_p6_seed (G-02f-287 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p7_o" ] && [ -f "$_pthin_p7_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p7_o" "$_pthin_p7_seed"; then
            _pthin_p7_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_SIMD_FROM_X"
            echo "g05_ensure: P7 simd ← $_pthin_p7_seed (G-02f-288 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p9_o" ] && [ -f "$_pthin_p9_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p9_o" "$_pthin_p9_seed"; then
            _pthin_p9_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_STRETCH_FROM_X"
            echo "g05_ensure: P9 stretch+suite ← $_pthin_p9_seed (G-02f-318 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p10_o" ] && [ -f "$_pthin_p10_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p10_o" "$_pthin_p10_seed"; then
            _pthin_p10_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_GLUE_FROM_X"
            echo "g05_ensure: P10 glue tail ← $_pthin_p10_seed (G-02f-319 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p11_o" ] && [ -f "$_pthin_p11_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p11_o" "$_pthin_p11_seed"; then
            _pthin_p11_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_IMPORTS_FROM_X"
            echo "g05_ensure: P11 imports ← $_pthin_p11_seed (G-02f-320 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p12_o" ] && [ -f "$_pthin_p12_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p12_o" "$_pthin_p12_seed"; then
            _pthin_p12_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_SKIP_TL_FROM_X"
            echo "g05_ensure: P12 skip_tl ← $_pthin_p12_seed (G-02f-321 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p13_o" ] && [ -f "$_pthin_p13_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p13_o" "$_pthin_p13_seed"; then
            _pthin_p13_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_TRY_SKIP_ALLOW_FROM_X"
            echo "g05_ensure: P13 try_skip_allow ← $_pthin_p13_seed (G-02f-322 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p14_o" ] && [ -f "$_pthin_p14_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p14_o" "$_pthin_p14_seed"; then
            _pthin_p14_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_SKIP_IF_FROM_X"
            echo "g05_ensure: P14 skip_if ← $_pthin_p14_seed (G-02f-323 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p15_o" ] && [ -f "$_pthin_p15_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p15_o" "$_pthin_p15_seed"; then
            _pthin_p15_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_LIBRARY_FROM_X"
            echo "g05_ensure: P15 library ← $_pthin_p15_seed (G-02f-324 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p16_o" ] && [ -f "$_pthin_p16_seed" ]; then
          # shellcheck disable=SC2086
          # NO_SEED_PARSE：抑制 slice 内 parser_get_module_* 别名（产品由 parser_x.o 提供；G-02f-326）
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
               -c -o "$_pthin_p16_o" "$_pthin_p16_seed"; then
            _pthin_p16_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_DIAG_PIPELINE_FROM_X"
            echo "g05_ensure: P16 diag_pipeline ← $_pthin_p16_seed (G-02f-325 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p17_o" ] && [ -f "$_pthin_p17_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p17_o" "$_pthin_p17_seed"; then
            _pthin_p17_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_DIAG_LATE_FROM_X"
            echo "g05_ensure: P17 diag_late ← $_pthin_p17_seed (G-02f-326 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p18_o" ] && [ -f "$_pthin_p18_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p18_o" "$_pthin_p18_seed"; then
            _pthin_p18_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_BODY_TL_FROM_X"
            echo "g05_ensure: P18 body_tl ← $_pthin_p18_seed (G-02f-327 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p19_o" ] && [ -f "$_pthin_p19_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p19_o" "$_pthin_p19_seed"; then
            _pthin_p19_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_HELPERS_FROM_X"
            echo "g05_ensure: P19 helpers ← $_pthin_p19_seed (G-02f-328 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p20_o" ] && [ -f "$_pthin_p20_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p20_o" "$_pthin_p20_seed"; then
            _pthin_p20_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DSHUX_PTHIN_FOUNDATION_FROM_X"
            echo "g05_ensure: P20 foundation ← $_pthin_p20_seed (G-02f-329 seed slice)"
          fi
        fi
        # G-02f-289 P8：仅 smoke -c（不进产品 hybrid ld -r；产品 rest 仍 NO_SEED_PARSE）
        if [ -f "$_pthin_p8_seed" ]; then
          _pthin_p8_smoke=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p8_smoke.XXXXXX") || true
          # shellcheck disable=SC2086
          if [ -n "$_pthin_p8_smoke" ] \
            && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
                 -c -o "$_pthin_p8_smoke" "$_pthin_p8_seed"; then
            echo "g05_ensure: P8 seed_parse smoke -c OK ← $_pthin_p8_seed (G-02f-289; not in product glue)"
          else
            echo "g05_ensure: P8 seed_parse smoke -c failed (non-fatal for product NO_SEED_PARSE glue)" >&2
          fi
          rm -f "$_pthin_p8_smoke"
        fi
        # 拼 hybrid link 列表（P8 smoke-only 不入）
        _pthin_link=""
        if [ "$_pthin_p1_ok" = "1" ]; then
          _pthin_link="$_pthin_p1_o"
        fi
        if [ "$_pthin_p3_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p3_o"
        fi
        if [ "$_pthin_p2_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p2_o"
        fi
        if [ "$_pthin_p6_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p6_o"
        fi
        if [ "$_pthin_p4as_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4as_o"
        fi
        if [ "$_pthin_p4p_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4p_o"
        fi
        if [ "$_pthin_p4u_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4u_o"
        fi
        if [ "$_pthin_p4b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4b_o"
        fi
        if [ "$_pthin_p4t_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4t_o"
        fi
        if [ "$_pthin_p5_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p5_o"
        fi
        if [ "$_pthin_p7_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p7_o"
        fi
        if [ "$_pthin_p9_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p9_o"
        fi
        if [ "$_pthin_p11_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p11_o"
        fi
        if [ "$_pthin_p12_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p12_o"
        fi
        if [ "$_pthin_p14_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p14_o"
        fi
        if [ "$_pthin_p15_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p15_o"
        fi
        if [ "$_pthin_p16_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p16_o"
        fi
        if [ "$_pthin_p17_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p17_o"
        fi
        if [ "$_pthin_p18_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p18_o"
        fi
        if [ "$_pthin_p19_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p19_o"
        fi
        if [ "$_pthin_p20_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p20_o"
        fi
        if [ "$_pthin_p13_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p13_o"
        fi
        if [ "$_pthin_p10_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p10_o"
        fi
        # G-02f-330：全产品切片齐（P1–P7+P9–P20）时 mega rest 无全局 T，跳过 rest 编译与 ld -r
        _pthin_full=0
        if [ "$_pthin_p1_ok" = "1" ] && [ "$_pthin_p2_ok" = "1" ] && [ "$_pthin_p3_ok" = "1" ] \
          && [ "$_pthin_p4p_ok" = "1" ] && [ "$_pthin_p4u_ok" = "1" ] && [ "$_pthin_p4b_ok" = "1" ] \
          && [ "$_pthin_p4as_ok" = "1" ] && [ "$_pthin_p4t_ok" = "1" ] && [ "$_pthin_p5_ok" = "1" ] \
          && [ "$_pthin_p6_ok" = "1" ] && [ "$_pthin_p7_ok" = "1" ] && [ "$_pthin_p9_ok" = "1" ] \
          && [ "$_pthin_p10_ok" = "1" ] && [ "$_pthin_p11_ok" = "1" ] && [ "$_pthin_p12_ok" = "1" ] \
          && [ "$_pthin_p13_ok" = "1" ] && [ "$_pthin_p14_ok" = "1" ] && [ "$_pthin_p15_ok" = "1" ] \
          && [ "$_pthin_p16_ok" = "1" ] && [ "$_pthin_p17_ok" = "1" ] && [ "$_pthin_p18_ok" = "1" ] \
          && [ "$_pthin_p19_ok" = "1" ] && [ "$_pthin_p20_ok" = "1" ] && [ -n "$_pthin_link" ]; then
          _pthin_full=1
        fi
        if [ "$_pthin_full" = "1" ]; then
          # shellcheck disable=SC2086
          if $CC -r -nostdlib -o parser_asm_thin_glue.o $_pthin_link 2>/dev/null; then
            echo "g05_ensure: parser_asm_thin_glue.o ← P1–P7+P9–P20 only (G-02f-330 omit empty rest; P8 smoke-only)"
            _pthin_done=1
          fi
        elif { [ "$_pthin_p1_ok" = "1" ] || [ "$_pthin_p2_ok" = "1" ] || [ "$_pthin_p3_ok" = "1" ] || [ "$_pthin_p4p_ok" = "1" ] || [ "$_pthin_p4u_ok" = "1" ] || [ "$_pthin_p4b_ok" = "1" ] || [ "$_pthin_p4as_ok" = "1" ] || [ "$_pthin_p4t_ok" = "1" ] || [ "$_pthin_p5_ok" = "1" ] || [ "$_pthin_p6_ok" = "1" ] || [ "$_pthin_p7_ok" = "1" ] || [ "$_pthin_p9_ok" = "1" ] || [ "$_pthin_p10_ok" = "1" ] || [ "$_pthin_p11_ok" = "1" ] || [ "$_pthin_p12_ok" = "1" ] || [ "$_pthin_p13_ok" = "1" ] || [ "$_pthin_p14_ok" = "1" ] || [ "$_pthin_p15_ok" = "1" ] || [ "$_pthin_p16_ok" = "1" ] || [ "$_pthin_p17_ok" = "1" ] || [ "$_pthin_p18_ok" = "1" ] || [ "$_pthin_p19_ok" = "1" ] || [ "$_pthin_p20_ok" = "1" ]; } \
          && [ -n "$_pthin_rest_o" ] && [ -n "$_pthin_link" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_rest_defs -c -o "$_pthin_rest_o" "$_pthin"; then
            _pthin_rest_t=$(nm -gU "$_pthin_rest_o" 2>/dev/null | awk '$2=="T"{c++} END{print c+0}')
            # shellcheck disable=SC2086
            if [ "${_pthin_rest_t:-1}" = "0" ]; then
              if $CC -r -nostdlib -o parser_asm_thin_glue.o $_pthin_link 2>/dev/null; then
                echo "g05_ensure: parser_asm_thin_glue.o ← hybrid slices only (rest T=0 omit; G-02f-330)"
                _pthin_done=1
              fi
            elif $CC -r -nostdlib -o parser_asm_thin_glue.o $_pthin_link "$_pthin_rest_o" 2>/dev/null; then
              echo "g05_ensure: parser_asm_thin_glue.o ← hybrid slices + thin rest (G-02f-330 partial; rest T=$_pthin_rest_t)"
              _pthin_done=1
            fi
          fi
        fi
        if [ "$_pthin_done" = "0" ]; then
          echo "g05_ensure: parser thin P1–P7+P9–P20 hybrid failed; fallback full seed" >&2
        fi
        rm -f "$_pthin_p1_o" "$_pthin_p2_o" "$_pthin_p3_o" "$_pthin_p4p_o" "$_pthin_p4u_o" "$_pthin_p4b_o" "$_pthin_p4as_o" "$_pthin_p4t_o" "$_pthin_p5_o" "$_pthin_p6_o" "$_pthin_p7_o" "$_pthin_p9_o" "$_pthin_p10_o" "$_pthin_p11_o" "$_pthin_p12_o" "$_pthin_p13_o" "$_pthin_p14_o" "$_pthin_p15_o" "$_pthin_p16_o" "$_pthin_p17_o" "$_pthin_p18_o" "$_pthin_p19_o" "$_pthin_p20_o" "$_pthin_rest_o"
      fi
      if [ "$_pthin_done" = "0" ]; then
        echo "g05_ensure: parser_asm_thin_glue.o ← thin seed (G-02f-10)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
          -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
          -c -o parser_asm_thin_glue.o "$_pthin"
      fi
    fi
  fi
  # G-02f-11 / G-02f-335～346：diag.o
  # 默认整 seed；PREFER_X_O=1 时 diag_thin.x（76 门闩：+ code_table/entry/stdio）+ seed-rest ld -r
  _diag=seeds/diag.from_x.c
  _diag_thin_x=src/diag_thin.x
  _diag_o=src/diag.o
  if [ -f "$_diag" ]; then
    if [ ! -f "$_diag_o" ] || [ "$_diag" -nt "$_diag_o" ] \
      || { [ -f "$_diag_thin_x" ] && [ "$_diag_thin_x" -nt "$_diag_o" ]; }; then
      _diag_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_diag_thin_x" ]; then
        _diag_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_diag_thin.XXXXXX") || true
        _diag_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_diag_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_diag_thin_o" ] && [ -n "$_diag_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_diag_thin_x" "$_diag_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_DIAG_THIN_FROM_X \
               -c -o "$_diag_rest_o" "$_diag" \
          && $CC -r -nostdlib -o "$_diag_o" "$_diag_thin_o" "$_diag_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_diag_o ← $_diag_thin_x + seed-rest (G-02f-347/420/421 L2 hybrid diag thin)"
          _diag_done=1
        else
          echo "g05_ensure: L2 hybrid diag thin failed; fallback full seed" >&2
        fi
        rm -f "$_diag_thin_o" "$_diag_rest_o"
      fi
      if [ "$_diag_done" = "0" ]; then
        echo "g05_ensure: $_diag_o ← seed (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_diag_o" "$_diag"
      fi
    fi
  fi
  # G-02f-11 / G-02f-332：x_seed_bridge.o
  # 默认整 seed；PREFER_X_O=1 时 .x thin（heap/io 桩）+ seed-rest（C 尾）ld -r
  _xsb=seeds/x_seed_bridge.from_x.c
  _xsb_x=src/x_seed_bridge.x
  _xsb_o=src/x_seed_bridge.o
  if [ -f "$_xsb" ]; then
    if [ ! -f "$_xsb_o" ] || [ "$_xsb" -nt "$_xsb_o" ]       || { [ -f "$_xsb_x" ] && [ "$_xsb_x" -nt "$_xsb_o" ]; }; then
      _xsb_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_xsb_x" ]; then
        _xsb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_xsb_thin.XXXXXX") || true
        _xsb_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_xsb_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_xsb_thin_o" ] && [ -n "$_xsb_rest_o" ]           && G05_X_O_WEAK=1 g05_try_x_to_o "$_xsb_x" "$_xsb_thin_o"           && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_X_SEED_BRIDGE_THIN_FROM_X                -c -o "$_xsb_rest_o" "$_xsb"           && $CC -r -nostdlib -o "$_xsb_o" "$_xsb_thin_o" "$_xsb_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_xsb_o ← $_xsb_x + seed-rest (G-02f-332 L2 hybrid x_seed_bridge thin)"
          _xsb_done=1
        else
          echo "g05_ensure: L2 hybrid x_seed_bridge failed; fallback full seed" >&2
        fi
        rm -f "$_xsb_thin_o" "$_xsb_rest_o"
      fi
      if [ "$_xsb_done" = "0" ]; then
        echo "g05_ensure: $_xsb_o ← seed (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_xsb_o" "$_xsb"
      fi
    fi
  fi
  # G-02f-440：seed_link_compat thin+rest PREFER_X_O
  # 特殊：6 个 weak stub 函数（5 lsp_diag_* + typeck_lsp_main_impl）在 .x 中是 #[no_mangle]（强符号），
  # 但 seed C 中是 __attribute__((weak))，被 lsp_diag_x.o / lsp_diag_pipeline_ctx.o 的强定义覆盖。
  # 需在 thin C 层面注入 __attribute__((weak)) 以保持链接拓扑。
  _slc_o="src/seed_link_compat.o"
  _slc_seed="seeds/seed_link_compat.from_x.c"
  _slc_x="src/seed_link_compat.x"
  if [ -f "$_slc_seed" ]; then
    _slc_need=0
    if [ ! -f "$_slc_o" ] || [ "$_slc_seed" -nt "$_slc_o" ] \
      || { [ -f "$_slc_x" ] && [ "$_slc_x" -nt "$_slc_o" ]; }; then
      _slc_need=1
    fi
    if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_slc_x" ] && [ "$_slc_need" = "1" ]; then
      _slc_thin_c=$(mktemp "${TMPDIR:-/tmp}/g05_slc_c.XXXXXX") || true
      _slc_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_slc_thin.XXXXXX") || true
      _slc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_slc_rest.XXXXXX") || true
      _slc_ok=0
      if [ -n "$_slc_thin_c" ] && [ -n "$_slc_thin_o" ] && [ -n "$_slc_rest_o" ]; then
        _slc_shux=""
        if [ -x ./shux ]; then _slc_shux=./shux
        elif [ -x ./shux-c ]; then _slc_shux=./shux-c
        elif [ -x ./bootstrap_shuxc ]; then _slc_shux=./bootstrap_shuxc
        fi
        if [ -n "$_slc_shux" ] && "$_slc_shux" -E "$_slc_x" >"$_slc_thin_c" 2>/dev/null && [ -s "$_slc_thin_c" ]; then
          # Weaken 6 stub functions overridden by lsp_diag_x.o / lsp_diag_pipeline_ctx.o
          sed -i.bak \
            -e 's/^int32_t lsp_diag_lsp_build_diagnostics_response(/__attribute__((weak)) int32_t lsp_diag_lsp_build_diagnostics_response(/' \
            -e 's/^int32_t lsp_diag_lsp_build_semantic_tokens_response(/__attribute__((weak)) int32_t lsp_diag_lsp_build_semantic_tokens_response(/' \
            -e 's/^int32_t lsp_diag_hover_at(/__attribute__((weak)) int32_t lsp_diag_hover_at(/' \
            -e 's/^int32_t lsp_diag_references_at(/__attribute__((weak)) int32_t lsp_diag_references_at(/' \
            -e 's/^int32_t lsp_diag_definition_at(/__attribute__((weak)) int32_t lsp_diag_definition_at(/' \
            -e 's/^int32_t typeck_lsp_main_impl(/__attribute__((weak)) int32_t typeck_lsp_main_impl(/' \
            "$_slc_thin_c" && rm -f "${_slc_thin_c}.bak"
          # Add POSIX headers + strip conflicting libc externs (same as g05_try_x_to_o)
          {
            echo '/* g05 seed_link_compat thin prologue (G-02f-440 + uio/poll) */'
            echo '#include <stddef.h>'
            echo '#include <stdint.h>'
            echo '#include <sys/types.h>'
            echo '#include <stdlib.h>'
            echo '#include <string.h>'
            echo '#include <stdio.h>'
            echo '#ifndef _WIN32'
            echo '#include <unistd.h>'
            echo '#include <fcntl.h>'
            echo '#include <errno.h>'
            # PLATFORM: POSIX — 与 g05_try_x_to_o 同源：readv/writev/poll 原型
            echo '#include <sys/uio.h>'
            echo '#include <poll.h>'
            echo '#endif'
            sed -e '/^#include /d' \
                -e '/^extern ssize_t read(/d' \
                -e '/^extern ssize_t write(/d' \
                -e '/^extern int32_t open(/d' \
                -e '/^extern int open(/d' \
                -e '/^extern int32_t fcntl(/d' \
                -e '/^extern int fcntl(/d' \
                -e '/^extern int32_t close(/d' \
                -e '/^extern int close(/d' \
                -e '/^extern uint8_t \* calloc(/d' \
                -e '/^extern uint8_t \* malloc(/d' \
                -e '/^extern void free(/d' \
                -e '/^extern int32_t memcmp(/d' \
                -e '/^extern int memcmp(/d' \
                -e '/^extern char \* getenv(/d' \
                -e '/^extern uint8_t \* getenv(/d' \
                -e '/^extern int32_t unlink(/d' \
                -e '/^extern int unlink(/d' \
                -e '/^extern size_t strlen(/d' \
                -e '/^extern int32_t strcmp(/d' \
                -e '/^extern int strcmp(/d' \
                -e '/^extern uint8_t \* strerror(/d' \
                -e '/^extern char \* strerror(/d' \
                -e '/^extern int32_t system(/d' \
                -e '/^extern int system(/d' \
                -e '/^extern int32_t fputs(/d' \
                -e '/^extern int fputs(/d' \
                "$_slc_thin_c"
          } >"${_slc_thin_c}.full" && mv "${_slc_thin_c}.full" "$_slc_thin_c"
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -x c -c -o "$_slc_thin_o" "$_slc_thin_c" \
            && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/asm -Isrc/lexer -DSHUX_SEED_LINK_COMPAT_FROM_X \
                 -c -o "$_slc_rest_o" "$_slc_seed" \
            && $CC -r -nostdlib -o "$_slc_o" "$_slc_thin_o" "$_slc_rest_o" 2>/dev/null; then
            echo "g05_ensure: seed_link_compat ← thin .x + rest (G-02f-440 L2 prefer .x)"
            _slc_ok=1
          fi
        fi
      fi
      if [ "$_slc_ok" = "0" ]; then
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_slc_o" "$_slc_seed"
        echo "g05_ensure: seed_link_compat ← $_slc_seed (G-02f-11 fallback)"
      fi
      rm -f "$_slc_thin_c" "$_slc_thin_o" "$_slc_rest_o"
    elif [ "$_slc_need" = "1" ]; then
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_slc_o" "$_slc_seed"
      echo "g05_ensure: seed_link_compat ← $_slc_seed (G-02f-11)"
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
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rdss_thin_x" ]; then
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
  # G-02f-11 / fmt_check R2 thin + Cap residual pure 深迁（续 append_repo + missing_diag pure）：fmt_check_cmd_driver.o
  # PREFER_X_O=1：thin.x（lit/entry+pure 含 try_walk/resolve_abs/append_repo/missing_diag）+ seed-rest（FROM_X）ld -r
  _fcc=seeds/fmt_check_cmd.from_x.c
  _fcc_thin_x=src/driver/fmt_check_cmd_thin.x
  _fcc_o=src/driver/fmt_check_cmd_driver.o
  if [ -f "$_fcc" ]; then
    if [ ! -f "$_fcc_o" ] || [ "$_fcc" -nt "$_fcc_o" ] \
      || { [ -f "$_fcc_thin_x" ] && [ "$_fcc_thin_x" -nt "$_fcc_o" ]; }; then
      _fcc_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_fcc_thin_x" ]; then
        _fcc_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_fcc_thin.XXXXXX") || true
        _fcc_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_fcc_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_fcc_thin_o" ] && [ -n "$_fcc_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_fcc_thin_x" "$_fcc_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_USE_X_PIPELINE -DSHUX_L2_FMT_CHECK_THIN_FROM_X \
               -c -o "$_fcc_rest_o" "$_fcc" \
          && $CC -r -nostdlib -o "$_fcc_o" "$_fcc_thin_o" "$_fcc_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_fcc_o ← $_fcc_thin_x + seed-rest (G-02f-350/410 R2 hybrid fmt_check thin)"
          _fcc_done=1
        else
          echo "g05_ensure: L2 hybrid fmt_check thin failed; fallback full seed" >&2
        fi
        rm -f "$_fcc_thin_o" "$_fcc_rest_o"
      fi
      if [ "$_fcc_done" = "0" ]; then
        echo "g05_ensure: fmt_check_cmd_driver.o ← seed -DSHUX_USE_X_PIPELINE (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_USE_X_PIPELINE -c -o "$_fcc_o" "$_fcc"
      fi
    fi
  fi
  # G-02f-15 / G-02f-423：lsp_diag + USER_ASM seed bridges
  # 默认整 seed；PREFER_X_O=1 时 thin.x（5 pure leaf）+ seed-rest（-DSHUX_L2_LSP_FMT_THIN_FROM_X）ld -r
  _lspg=seeds/runtime_lsp_glue.from_x.c
  _lspg_thin_x=src/lsp/lsp_fmt_pure_thin.x
  if [ -f "$_lspg" ]; then
    if [ ! -f src/lsp/lsp_diag.o ] || [ "$_lspg" -nt src/lsp/lsp_diag.o ] \
      || { [ -f "$_lspg_thin_x" ] && [ "$_lspg_thin_x" -nt src/lsp/lsp_diag.o ]; }; then
      _lspg_done=0
      if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_lspg_thin_x" ]; then
        _lspg_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_lspg_thin_XXXXXX.o") || true
        _lspg_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_lspg_rest_XXXXXX.o") || true
        if [ -n "$_lspg_thin_o" ] && [ -n "$_lspg_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_lspg_thin_x" "$_lspg_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_L2_LSP_FMT_THIN_FROM_X \
               -c -o "$_lspg_rest_o" "$_lspg" \
          && $CC -r -nostdlib -o src/lsp/lsp_diag.o "$_lspg_thin_o" "$_lspg_rest_o" 2>/dev/null; then
          echo "g05_ensure: src/lsp/lsp_diag.o ← $_lspg_thin_x + seed-rest (G-02f-423 L2 hybrid lsp_fmt pure thin)"
          _lspg_done=1
        else
          echo "g05_ensure: L2 hybrid runtime_lsp_glue failed; fallback full seed" >&2
        fi
        rm -f "$_lspg_thin_o" "$_lspg_rest_o"
      fi
      if [ "$_lspg_done" = "0" ]; then
        echo "g05_ensure: lsp_diag.o ← runtime_lsp_glue seed (G-02f-15)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o src/lsp/lsp_diag.o "$_lspg"
      fi
    fi
  fi
  # G-02f-442：user_asm_seed_bridge thin+rest PREFER_X_O
  _uasb_o="src/asm/user_asm_seed_bridge.o"
  _uasb_seed="seeds/user_asm_seed_bridge.from_x.c"
  _uasb_x="src/asm/user_asm_seed_bridge.x"
  if [ -f "$_uasb_seed" ]; then
    _uasb_need=0
    if [ ! -f "$_uasb_o" ] || [ "$_uasb_seed" -nt "$_uasb_o" ] \
      || { [ -f "$_uasb_x" ] && [ "$_uasb_x" -nt "$_uasb_o" ]; }; then
      _uasb_need=1
    fi
    if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_uasb_x" ] && [ "$_uasb_need" = "1" ]; then
      _uasb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_uasb_thin.XXXXXX") || true
      _uasb_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_uasb_rest.XXXXXX") || true
      if [ -n "$_uasb_thin_o" ] && [ -n "$_uasb_rest_o" ] \
        && g05_try_x_to_o "$_uasb_x" "$_uasb_thin_o" \
        && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_USER_ASM_SEED_BRIDGE_FROM_X \
             -c -o "$_uasb_rest_o" "$_uasb_seed" \
        && $CC -r -nostdlib -o "$_uasb_o" "$_uasb_thin_o" "$_uasb_rest_o" 2>/dev/null; then
        echo "g05_ensure: user_asm_seed_bridge ← thin .x + rest (G-02f-442 L2 prefer .x)"
      else
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_uasb_o" "$_uasb_seed"
        echo "g05_ensure: user_asm_seed_bridge ← $_uasb_seed (G-02f-15 fallback)"
      fi
      rm -f "$_uasb_thin_o" "$_uasb_rest_o"
    elif [ "$_uasb_need" = "1" ]; then
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_uasb_o" "$_uasb_seed"
      echo "g05_ensure: user_asm_seed_bridge ← $_uasb_seed (G-02f-15)"
    fi
  fi
  # G-02f-441：backend_x86_64_enc_c thin+rest PREFER_X_O
  _bxec_o="src/asm/backend_x86_64_enc_c.o"
  _bxec_seed="seeds/backend_x86_64_enc_c.from_x.c"
  _bxec_x="src/asm/backend_x86_64_enc_c.x"
  if [ -f "$_bxec_seed" ]; then
    _bxec_need=0
    if [ ! -f "$_bxec_o" ] || [ "$_bxec_seed" -nt "$_bxec_o" ] \
      || { [ -f "$_bxec_x" ] && [ "$_bxec_x" -nt "$_bxec_o" ]; }; then
      _bxec_need=1
    fi
    if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_bxec_x" ] && [ "$_bxec_need" = "1" ]; then
      _bxec_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_bxec_thin.XXXXXX") || true
      _bxec_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_bxec_rest.XXXXXX") || true
      if [ -n "$_bxec_thin_o" ] && [ -n "$_bxec_rest_o" ] \
        && g05_try_x_to_o "$_bxec_x" "$_bxec_thin_o" \
        && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DSHUX_BACKEND_X86_64_ENC_C_FROM_X \
             -c -o "$_bxec_rest_o" "$_bxec_seed" \
        && $CC -r -nostdlib -o "$_bxec_o" "$_bxec_thin_o" "$_bxec_rest_o" 2>/dev/null; then
        echo "g05_ensure: backend_x86_64_enc_c ← thin .x + rest (G-02f-441 L2 prefer .x)"
      else
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bxec_o" "$_bxec_seed"
        echo "g05_ensure: backend_x86_64_enc_c ← $_bxec_seed (G-02f-15 fallback)"
      fi
      rm -f "$_bxec_thin_o" "$_bxec_rest_o"
    elif [ "$_bxec_need" = "1" ]; then
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_bxec_o" "$_bxec_seed"
      echo "g05_ensure: backend_x86_64_enc_c ← $_bxec_seed (G-02f-15)"
    fi
  fi
  # G-02f-439：asm_backend_compat_stubs thin+rest PREFER_X_O
  _abcs_o="src/asm/asm_backend_compat_stubs.o"
  _abcs_seed="seeds/asm_backend_compat_stubs.from_x.c"
  _abcs_x="src/asm/asm_backend_compat_stubs.x"
  if [ -f "$_abcs_seed" ]; then
    _abcs_need=0
    if [ ! -f "$_abcs_o" ] || [ "$_abcs_seed" -nt "$_abcs_o" ]; then
      _abcs_need=1
    fi
    if [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_abcs_x" ] && [ "$_abcs_need" = "1" ]; then
      _abcs_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_abcs_thin.XXXXXX") || true
      _abcs_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_abcs_rest.XXXXXX") || true
      if [ -n "$_abcs_thin_o" ] && [ -n "$_abcs_rest_o" ] \
        && g05_try_x_to_o "$_abcs_x" "$_abcs_thin_o" \
        && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/asm -Isrc/lexer -DSHUX_ASM_BACKEND_COMPAT_STUBS_FROM_X \
             -c -o "$_abcs_rest_o" "$_abcs_seed" \
        && $CC -r -nostdlib -o "$_abcs_o" "$_abcs_thin_o" "$_abcs_rest_o" 2>/dev/null; then
        echo "g05_ensure: asm_backend_compat_stubs ← thin .x + rest (G-02f-439 L2 prefer .x)"
      else
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_abcs_o" "$_abcs_seed"
        echo "g05_ensure: asm_backend_compat_stubs ← $_abcs_seed (G-02f-15 fallback)"
      fi
      rm -f "$_abcs_thin_o" "$_abcs_rest_o"
    elif [ "$_abcs_need" = "1" ]; then
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_abcs_o" "$_abcs_seed"
      echo "g05_ensure: asm_backend_compat_stubs ← $_abcs_seed (G-02f-15)"
    fi
  fi
  # G-02f-16：x_frontend_link_alias 产品 seed
  _xfla=seeds/x_frontend_link_alias.from_x.c
  if [ -f "$_xfla" ]; then
    if [ ! -f x_frontend_link_alias.o ] || [ "$_xfla" -nt x_frontend_link_alias.o ]; then
      echo "g05_ensure: x_frontend_link_alias.o ← seed (G-02f-16)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o x_frontend_link_alias.o "$_xfla"
    fi
  fi
  # Track L：driver 叶子 + lsp_io_std_heap 构建链退役 — 仅 .x→.o 或 seeds/* 冷启动
  # 不再读取工作区 pinned driver_*_gen.c / lsp_io_std_heap_gen.c
  for _leaf_pair in \
    "src/driver/fmt.x|driver_fmt_x.o|cmd_fmt:driver_cmd_fmt|seeds/driver_fmt_gen.linux.x86_64.c" \
    "src/driver/check.x|driver_check_x.o|cmd_check:driver_cmd_check|seeds/driver_check_gen.linux.x86_64.c" \
    "src/driver/test.x|driver_test_x.o|cmd_test:driver_cmd_test|seeds/driver_test_gen.linux.x86_64.c" \
    "src/driver/build.x|driver_build_x.o|cmd_build:build_cmd_build|seeds/driver_build_gen.linux.x86_64.c" \
    "src/driver/run.x|driver_run_x.o|run_eq_word:driver_run_eq_word,cmd_run:driver_cmd_run|seeds/driver_run_gen.linux.x86_64.c" \
    "src/driver/compile.x|driver_compile_x.o|compile_dispatch_asm_backend:driver_compile_dispatch_asm_backend,compile_dispatch_emit_c_path:driver_compile_dispatch_emit_c_path,eq_minus_o:driver_eq_minus_o,eq_minus_L:driver_eq_minus_L,eq_minus_backend:driver_eq_minus_backend,eq_minus_target:driver_eq_minus_target,eq_minus_target_cpu:driver_eq_minus_target_cpu,eq_print_target_cpu:driver_eq_print_target_cpu,eq_minus_O:driver_eq_minus_O,eq_flto:driver_eq_flto,eq_minus_freestanding:driver_eq_minus_freestanding,eq_legacy_f32_abi:driver_eq_legacy_f32_abi,eq_fsanitize_address:driver_eq_fsanitize_address,eq_asm_word:driver_eq_asm_word,eq_c_word:driver_eq_c_word,path_ends_x:driver_path_ends_x,target_has_arm:driver_target_has_arm,run_compiler_full_x_post_parse:driver_run_compiler_full_x_post_parse,run_compiler_full_x:driver_run_compiler_full_x|seeds/driver_compile_gen.linux.x86_64.c" \
    "src/driver/emit.x|driver_emit_x.o|emit_copy_lib_roots_to_ctx:driver_emit_copy_lib_roots_to_ctx,run_x_emit_x:driver_run_x_emit_x,dispatch_x_emit_to_c:driver_dispatch_x_emit_to_c,emit_state_key:driver_emit_state_key,pipeline_dep_ctx_fill_for_emit:driver_pipeline_dep_ctx_fill_for_emit|seeds/driver_emit_gen.linux.x86_64.c" \
    "src/lsp/lsp_io_std_heap.x|lsp_io_std_heap_x.o|std_heap_alloc:lsp_io_std_heap_std_heap_alloc,std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,std_heap_free:lsp_io_std_heap_std_heap_free|seeds/lsp_io_std_heap_gen.linux.x86_64.c"
  do
    _leaf_x="${_leaf_pair%%|*}"
    _leaf_rest="${_leaf_pair#*|}"
    _leaf_o="${_leaf_rest%%|*}"
    _leaf_rest2="${_leaf_rest#*|}"
    _leaf_rename="${_leaf_rest2%%|*}"
    _leaf_seed="${_leaf_rest2#*|}"
    if [ ! -f "$_leaf_o" ] || { [ -f "$_leaf_x" ] && [ "$_leaf_x" -nt "$_leaf_o" ]; }; then
      if [ -f scripts/driver_leaf_x_to_o.sh ]; then
        # shellcheck disable=SC2086
        DRIVER_SUBCMD_DIRS="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/preprocess -L src/driver" \
          BASE_CFLAGS="$BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS" \
          bash scripts/driver_leaf_x_to_o.sh "$_leaf_x" "$_leaf_o" "$_leaf_rename" "$_leaf_seed" \
          || echo "g05_ensure: Track L leaf failed for $_leaf_o" >&2
      elif [ "${SHUX_G05_PREFER_X_O:-1}" = "1" ] && G05_X_O_SYM_RENAME="$_leaf_rename" g05_try_x_to_o "$_leaf_x" "$_leaf_o"; then
        echo "g05_ensure: $_leaf_o ← $_leaf_x (Track L PREFER_X_O)"
      elif [ -f "$_leaf_seed" ]; then
        echo "g05_ensure: cc -c $_leaf_seed → $_leaf_o (Track L cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o "$_leaf_o" "$_leaf_seed"
      fi
    fi
  done
  # LANG-007：host-local typeck_gen.c 可能缺 S0 边界委托；补丁后若变更则重编 typeck_x.o
  # PLATFORM: SHARED — true cold deletes typeck_x.o but often leaves a stale host-local
  # typeck_gen.c (gitignored). That stale file can predate product contracts (e.g. void main
  # ret_kind allows ord_void=16). Always re-pin seed when typeck_x.o is missing so L4 does
  # not compile an old gen that still returns -4 on `function main(): void`.
  if [ ! -f typeck_x.o ] && [ -f seeds/typeck_gen.linux.x86_64.c ]; then
    cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c
    echo "g05_ensure: typeck_gen.c ← seeds/typeck_gen.linux.x86_64.c (cold: missing typeck_x.o)"
  fi
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
      src/runtime_driver_no_c.o|src/runtime_pipeline_abi.o|src/runtime_link_abi.o|src/runtime_io_abi.o|src/runtime_driver_abi.o|src/runtime_driver_diagnostic.o|src/lsp/lsp_diag_pipeline_ctx.o|src/typeck/typeck_f64_bits.o|src/lsp/lsp_diag_pipeline_sizes_nostub.o|src/driver/target_cpu.o|src/asm/simd_enc.o|src/asm/simd_loop.o|src/asm/backend_enc_dispatch.o|src/asm/backend_arch_emit_dispatch.o|src/asm/backend_try_inline_dispatch.o|src/asm/backend_call_dispatch.o|src/asm/parser_asm_parse_expr_link.o|parser_asm_thin_glue.o|src/diag.o|src/x_seed_bridge.o|src/seed_link_compat.o|src/runtime_driver_strict_glue_stubs.o|src/driver/fmt_check_cmd_driver.o|src/lsp/lsp_diag.o|src/asm/user_asm_seed_bridge.o|src/asm/asm_backend_compat_stubs.o|src/asm/backend_x86_64_enc_c.o|x_frontend_link_alias.o|driver_fmt_x.o|driver_check_x.o|driver_test_x.o|lsp_io_std_heap_x.o|driver_build_x.o|driver_run_x.o|build_asm/*|*.s) continue ;;
    esac

    if [ -n "$src" ]; then
      if [ ! -f "$o" ] || [ "$src" -nt "$o" ]; then
        g05_cc_c "$o" "$src"
      fi
    fi
  done
fi

# --- Darwin bridge (PLATFORM: MACOS) ---
# g05_relink_env USER_ASM_LINK lists build_asm/asm_experimental_symbol_bridge.o for
# Darwin (weak platform_macho_write_macho_o_to_buf). bootstrap-driver-seed does not
# always emit it; after true L4 wipe g05 would MISSING and stop. Build from seed when
# listed in G05_OBJS — same source as build_shux_asm ensure_asm_experimental_symbol_bridge_obj.
case " $G05_OBJS " in
  *" build_asm/asm_experimental_symbol_bridge.o "*)
    if [ ! -f build_asm/asm_experimental_symbol_bridge.o ] \
      && [ -f seeds/asm_experimental_symbol_bridge.from_x.c ]; then
      mkdir -p build_asm
      echo "g05_ensure: asm_experimental_symbol_bridge.o ← seed (Darwin cold L4)"
      bash scripts/cc_inc_tu.sh seeds/asm_experimental_symbol_bridge.from_x.c \
        build_asm/asm_experimental_symbol_bridge.o
    fi
    ;;
esac

# --- NL-07 L10: nostdlib companions for product g05 (PLATFORM: LINUX) ---
# G.7: scripts/bootstrap_nostdlib_shared.sh (same freestanding/stubs/atoi as build_shux_asm).
# Only when G05_OBJS lists them (g05_relink_env after bootstrap_wants_nostdlib).
case " $G05_OBJS " in
  *" src/asm/freestanding_io_x86_64.o "*|*" src/asm/bootstrap_nostdlib_stubs.o "*|*" atoi_stub.o "*)
    # shellcheck disable=SC1091
    . scripts/bootstrap_nostdlib_shared.sh
    echo "g05_ensure: nostdlib companions (freestanding_io + stubs + weak atoi)"
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
    # Capture stdout (atoi path); progress already on stderr.
    _g05_atoi="$(ensure_atoi_stub_obj)"
    # If policy skipped atoi (strong T in runtime_panic), drop from list so miss check passes.
    if [ -z "$_g05_atoi" ]; then
      G05_OBJS="$(printf '%s\n' "$G05_OBJS" | sed 's/[[:space:]]atoi_stub\.o//g')"
    fi
    ;;
esac

# --- asm_full_link_stubs.o freshness check (PLATFORM: WINDOWS | MSYS | MINGW) ---
# Why: PE/MinGW has no weak function symbols (SHUX_WEAK expands empty; stubs are
#      strong). If user_asm_seed_bridge.o is rebuilt (e.g. .x changed) and
#      introduces a new U symbol matching gen_asm_full_link_stubs.pl regex
#      (platform_coff_*, arch_*, peephole_*, enc_*, ...), the existing
#      asm_full_link_stubs.o may be stale — missing the new stub — causing
#      the final g05 link to fail with "undefined reference" on PE. On ELF
#      (Linux/macOS) weak stubs mask this because real impls override, so the
#      race is Windows-only. The Makefile rule regenerates stubs only when its
#      .o prerequisites are newer, but within a single g05 run that rebuilds
#      user_asm_seed_bridge.o the stubs rule may not fire in the right order.
#      Fix at the root: regenerate stubs here (idempotent — gen_asm_full_link_stubs.pl
#      now writes a temp file and replaces only on content change; no-op when
#      symbol set is unchanged, so mtime stays stable and no spurious rebuilds).
#      Mirror of Makefile L1503-1509 stubs recipe. G.7: single authority is
#      gen_asm_full_link_stubs.pl; this is the shell-path equivalent of the
#      Makefile rule, not a second generator.
mkdir -p build_asm/seed_host
if [ -f build_asm/seed_host/asm_backend_partial.o ] && [ -x scripts/gen_asm_full_link_stubs.pl ]; then
  _stubs_scan="pipeline_x.o build_asm/pipeline_glue_standalone.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  [ -f build_asm/seed_host/asm_full.o ] && _stubs_scan="build_asm/seed_host/asm_full.o $_stubs_scan"
  _stubs_scan="build_asm/seed_host/asm_backend_partial.o $_stubs_scan"
  if perl scripts/gen_asm_full_link_stubs.pl build_asm/seed_host/asm_full_link_stubs.c $_stubs_scan 2>&1; then
    if [ build_asm/seed_host/asm_full_link_stubs.c -nt build_asm/seed_host/asm_full_link_stubs.o ] 2>/dev/null; then
      echo "g05_ensure: cc -c build_asm/seed_host/asm_full_link_stubs.o (stubs.c updated)" >&2
      $CC $BASE_CFLAGS -c -o build_asm/seed_host/asm_full_link_stubs.o build_asm/seed_host/asm_full_link_stubs.c
    fi
  fi
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
