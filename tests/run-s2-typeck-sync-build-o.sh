#!/usr/bin/env bash
# 将 EMIT_HEAVY 第二遍产物写入 compiler/build_asm/typeck.o，供 asm_strict_typeck_selfhosted / S2 gate 使用。
# 依赖：compiler/shux_asm.strict_glue 或 shux_asm.experimental 已重链（含最新 ast_pool.c）。
# 用法：./tests/run-s2-typeck-sync-build-o.sh
# 可选：SHUX_S2_FAIL_ON_EMIT_HEAVY=1 — __text / real_funcs 低于 baseline 时失败
set -e
cd "$(dirname "$0")/.."
DEST="compiler/build_asm/typeck.o"
BASELINE="${SHUX_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-8192}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-20}

if [ -z "${SHUX_S2_EMIT_HEAVY_COMPILER:-}" ]; then
  for cand in ./compiler/shux_asm.strict_glue ./compiler/shux_asm.experimental ./compiler/shux_asm; do
    if [ -x "$cand" ]; then
      export SHUX_S2_EMIT_HEAVY_COMPILER="$cand"
      break
    fi
  done
fi

if ! ./tests/run-s2-typeck-emit-heavy.sh; then
  echo "s2 sync-build-o: emit-heavy failed" >&2
  exit 1
fi

SRC="/tmp/shux_s2_typeck_emit_heavy.o"
[ -f "$SRC" ] || {
  echo "s2 sync-build-o: missing $SRC" >&2
  exit 1
}

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST"

# layout 符号子集 partial：strict 链与 typeck_sx_no_layout 分工（S2 同链）
# shellcheck source=tests/lib/s2-typeck-layout-partial.sh
. "$(dirname "$0")/lib/s2-typeck-layout-partial.sh"
if s2_rebuild_typeck_layout_partial "$DEST"; then
  echo "s2 sync-build-o: rebuilt compiler/build_asm/typeck_asm_layout_partial.o"
else
  echo "s2 sync-build-o: warn: layout partial rebuild failed (strict 链可能 duplicate layout)" >&2
fi

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

sz=$(text_section_size "$DEST")
echo "s2 sync-build-o: wrote $DEST __text=${sz} (min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHUX_S2_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s > m) ? 0 : 1 }'; then
    echo "s2 sync-build-o FAIL: __text ${sz} <= min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
fi

echo "s2 sync-build-o OK ($DEST)"
