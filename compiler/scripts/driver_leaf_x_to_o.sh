#!/usr/bin/env bash
# driver_leaf_x_to_o.sh — Track L：driver 叶子 .x → .o（符号 rename 与 g05/prove 一致）
#
# 用法：
#   bash scripts/driver_leaf_x_to_o.sh <src.x> <out.o> <rename-map> [cold-seed.c]
#
# rename-map：old1:new1,old2:new2（可空）
# 优先：xlang/xlang-c/bootstrap_xlangc -E → rename → cc -c
# 回退：cold-seed.c（仅 seeds/*，不得依赖工作区 pinned driver_*_gen.c）
set -eu
cd "$(dirname "$0")/.."

X_SRC="${1:?}"
OUT_O="${2:?}"
SYM_RENAME="${3:-}"
COLD_SEED="${4:-}"

if [ ! -f "$X_SRC" ]; then
  echo "driver_leaf_x_to_o: missing $X_SRC" >&2
  exit 1
fi

CC="${CC:-cc}"
BASE_CFLAGS="${BASE_CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
DIRS="${DRIVER_SUBCMD_DIRS:--L .. -L src -L src/lexer -L src/ast}"

pick_xlang() {
  for b in ./xlang ./xlang-c ./bootstrap_xlangc; do
    if [ -x "$b" ]; then
      printf '%s\n' "$b"
      return 0
    fi
  done
  return 1
}

apply_rename() {
  _file="$1"
  _map="$2"
  [ -z "$_map" ] && return 0
  _old_ifs="$IFS"
  IFS=','
  # shellcheck disable=SC2086
  for _pair in $_map; do
    _old="${_pair%%:*}"
    _new="${_pair#*:}"
    if [ -n "$_old" ] && [ -n "$_new" ] && [ "$_old" != "$_new" ]; then
      perl -i -pe "s/\\b${_old}\\b/${_new}/g" "$_file"
    fi
  done
  IFS="$_old_ifs"
}

if XLANG_BIN=$(pick_xlang); then
  tmp="$(mktemp "${TMPDIR:-/tmp}/driver_leaf.XXXXXX.c")"
  # 30s 防死循环（与 prove_module_selfhost / g05 对齐）
  if perl -e 'alarm 30; exec @ARGV' "$XLANG_BIN" -E $DIRS "$X_SRC" >"$tmp" 2>/dev/null \
    && [ -s "$tmp" ]; then
    grep -v '^DBG-' "$tmp" >"${tmp}.clean" && mv "${tmp}.clean" "$tmp"
    apply_rename "$tmp" "$SYM_RENAME"
    {
      echo '/* driver_leaf_x_to_o prologue */'
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
          -e '/^extern char \* getenv(/d' \
          -e '/^extern uint8_t \* getenv(/d' \
          -e '/^extern int32_t unlink(/d' \
          -e '/^extern int unlink(/d' \
          -e '/^extern size_t strlen(/d' \
          "$tmp"
    } >"${tmp}.full" && mv "${tmp}.full" "$tmp"
    # shellcheck disable=SC2086
    if $CC $BASE_CFLAGS -x c -c -o "$OUT_O" "$tmp" 2>/dev/null; then
      rm -f "$tmp"
      echo "driver_leaf_x_to_o: $OUT_O <- $X_SRC (PREFER_X_O)"
      exit 0
    fi
  fi
  rm -f "$tmp"
  echo "driver_leaf_x_to_o: PREFER_X_O failed for $X_SRC; try cold seed" >&2
fi

if [ -n "$COLD_SEED" ] && [ -f "$COLD_SEED" ]; then
  # PLATFORM: SHARED — cold seed may contain extern decls (malloc/free/calloc/etc.)
  # that conflict with system headers on macOS (void* vs uint8_t* return). Strip
  # them before compiling, same as PREFER_X_O path and lsp_io_std_heap_gen.c rule.
  _seed_tmp="$(mktemp "${TMPDIR:-/tmp}/cold_seed.XXXXXX.c")"
  sed -e '/^extern uint8_t \* malloc(/d' \
      -e '/^extern void free(/d' \
      -e '/^extern uint8_t \* calloc(/d' \
      "$COLD_SEED" > "$_seed_tmp"
  # shellcheck disable=SC2086
  if $CC $BASE_CFLAGS -c -o "$OUT_O" "$_seed_tmp" 2>/dev/null; then
    rm -f "$_seed_tmp"
    echo "driver_leaf_x_to_o: $OUT_O <- $COLD_SEED (cold seed, stripped externs)"
    exit 0
  fi
  rm -f "$_seed_tmp"
  # Fallback: try unstripped (Linux often has no conflict)
  # shellcheck disable=SC2086
  $CC $BASE_CFLAGS -c -o "$OUT_O" "$COLD_SEED"
  echo "driver_leaf_x_to_o: $OUT_O <- $COLD_SEED (cold seed)"
  exit 0
fi

echo "driver_leaf_x_to_o: cannot build $OUT_O (no xlang -E and no cold seed)" >&2
exit 1
