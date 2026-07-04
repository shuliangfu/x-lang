#!/usr/bin/env bash
# 测试 std.vec（vec_len_empty；vec_placeholder_i32 待 typeck relink）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# shellcheck source=lib/vec-asm-gcc-link.sh
. "$(dirname "$0")/lib/vec-asm-gcc-link.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/shux_vec"

if ! vec_link_exe "$LINK_SHUX" tests/vec/main.x "$OUT" 2>&1; then
  echo "vec test: compile failed"
  rm -f "$OUT"
  exit 1
fi
exitcode=0
"$OUT" >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (vec_len_empty), got $exitcode"; exit 1; }

echo "vec test OK"
