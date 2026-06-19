#!/bin/sh
# smoke_asm_peephole_metric.sh — 对 peephole.sx 的 -backend asm __text 段做一次性字节度量（可作回归基线）。
# 用法：在 compiler 目录执行 SHUX=./shux ./scripts/smoke_asm_peephole_metric.sh
# 产出：单行打印 peephole_text_bytes=N；便于 perf todo 下有数字可比，不靠无度量微优化。

set -e
cd "$(dirname "$0")/.."
SHUX="${SHUX:-./shux}"
TAB=$(printf '\t')
LIBROOT=""
if [ -f "src/asm/asm_build_list.sx" ]; then
  LIBROOT=$(grep '^// LIBROOT:' "src/asm/asm_build_list.sx" | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

OUT="$(mktemp -u /tmp/shux_peephole_XXXXXX).o"
trap 'rm -f "$OUT"' EXIT
eval "$SHUX -backend asm -o \"$OUT\" $LIBROOT \"src/asm/peephole.sx\""
hex=$(objdump -h "$OUT" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
if [ -z "$hex" ]; then
  echo "smoke_asm_peephole_metric: ERROR no __text in $OUT" >&2
  exit 1
fi
n=$(perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0)
echo "peephole_text_bytes=${n}"
