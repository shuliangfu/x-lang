#!/usr/bin/env bash
# BOOT-022：mega7 B1–B7 emit 晋升门禁
#
# 用法：./tests/run-boot-022-mega7-emit-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT022_DOC:-analysis/boot-022-mega7-emit-v1.md}"
MANIFEST="${SHUX_BOOT022_TSV:-tests/baseline/boot-022-mega7-emit.tsv}"
WAVE="${SHUX_BOOT022_WAVE_TSV:-tests/baseline/parser-mega7-emit-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
LIB="tests/lib/boot-022-mega7-emit.sh"
MIN_EMIT=1
MIN_ROWS=7
EMIT_LEAD_EXPECT="parse_body_lets_into"

# shellcheck source=tests/lib/boot-022-mega7-emit.sh
. "$LIB"

echo "=== BOOT-022: mega7 emit manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" \
  tests/baseline/parser-mega-bisect.tsv \
  tests/run-parser-mega7-emit-wave.sh \
  tests/run-boot-021-mega7-promote-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-022-mega7-emit gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_promote_emit) MIN_EMIT="$c2" ;;
    min_emit_rows) MIN_ROWS="$c2" ;;
    emit_lead) EMIT_LEAD_EXPECT="$c2" ;;
  esac
done < "$WAVE"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_promote_emit) MIN_EMIT="$c2" ;;
  esac
done < "$MANIFEST"

for kw in promote_emit emit_lead min_promote_emit parse_body_lets_into; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-022-mega7-emit gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

ROW_N=0
MISS=0
echo "=== BOOT-022: emit wave rows ==="
while IFS=$'\t' read -r emit_id mega_fn role hook _notes; do
  [ -z "${emit_id:-}" ] && continue
  case "$emit_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$emit_id" "$DOC" 2>/dev/null; then
    echo "boot-022 FAIL: doc missing $emit_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qE "function ${mega_fn}\\(" compiler/src/parser/parser.sx 2>/dev/null; then
    echo "boot-022 FAIL: parser.sx missing $mega_fn" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-022 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-022 OK $emit_id -> $mega_fn ($role)"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-022-mega7-emit gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
  exit 1
fi

# B1 须为 emit_target
if ! grep -F 'B1_parse_body_lets' "$MATRIX" 2>/dev/null | grep -qF 'emit_target'; then
  echo "boot-022 FAIL: B1_parse_body_lets not emit_target in mega7 matrix" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot022_emit_report "fail" 0 "" 0
  exit 1
fi
echo "boot-022-mega7-emit manifest OK (rows=${ROW_N})"

PROMOTE_EMIT=0
EMIT_LEAD=""
SKIP=1

if boot022_mega7_linux_asm; then
  echo "=== BOOT-022: emit wave (Linux shux_asm) ==="
  chmod +x tests/run-parser-mega7-emit-wave.sh
  WAVE_OUT="/tmp/boot022_emit_wave_$$.log"
  if ./tests/run-parser-mega7-emit-wave.sh 2>&1 | tee "$WAVE_OUT"; then
    PROMOTE_EMIT=$(grep -cE 'status=emit' "$WAVE_OUT" 2>/dev/null || echo 0)
    EMIT_LEAD="$(boot022_parse_emit_lead "$WAVE_OUT")"
    SKIP=0
    echo "boot-022 emit OK (promote_emit=${PROMOTE_EMIT} lead=${EMIT_LEAD:-none})"
  else
    rm -f "$WAVE_OUT"
    boot022_emit_report "fail" 0 "" 0
    exit 1
  fi
  rm -f "$WAVE_OUT"
else
  echo "boot-022-mega7-emit gate SKIP wave (Darwin or no shux_asm)" >&2
fi

if [ "$SKIP" -eq 0 ] && [ "$PROMOTE_EMIT" -lt "$MIN_EMIT" ]; then
  echo "boot-022-mega7-emit gate FAIL: promote_emit=${PROMOTE_EMIT} < min ${MIN_EMIT}" >&2
  boot022_emit_report "fail" "$PROMOTE_EMIT" "${EMIT_LEAD:-none}" 0
  exit 1
fi

if [ "$SKIP" -eq 0 ] && [ -n "$EMIT_LEAD" ] && [ "$EMIT_LEAD" != "$EMIT_LEAD_EXPECT" ]; then
  echo "boot-022 WARN: emit_lead=${EMIT_LEAD} expected ${EMIT_LEAD_EXPECT}" >&2
fi

boot022_emit_report "ok" "$PROMOTE_EMIT" "${EMIT_LEAD:-${EMIT_LEAD_EXPECT}}" "$SKIP"
echo "boot-022-mega7-emit gate OK"
