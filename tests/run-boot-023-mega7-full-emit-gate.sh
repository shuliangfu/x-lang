#!/usr/bin/env bash
# BOOT-023：mega7 7/7 全量 emit 门禁
#
# 用法：./tests/run-boot-023-mega7-full-emit-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT023_DOC:-analysis/boot-023-mega7-full-emit-v1.md}"
MANIFEST="${SHUX_BOOT023_TSV:-tests/baseline/boot-023-mega7-full-emit.tsv}"
WAVE="${SHUX_BOOT023_WAVE_TSV:-tests/baseline/parser-mega7-emit-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
LIB="tests/lib/boot-023-mega7-full-emit.sh"
MIN_EMIT=7
MIN_ROWS=7

# shellcheck source=tests/lib/boot-023-mega7-full-emit.sh
. "$LIB"

echo "=== BOOT-023: mega7 full emit manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" \
  tests/baseline/parser-mega-bisect.tsv \
  tests/run-parser-mega7-emit-wave.sh \
  tests/run-boot-022-mega7-emit-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-023-mega7-full-emit gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_promote_emit) MIN_EMIT="$c2" ;;
    min_emit_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in promote_emit emit_full min_promote_emit full_emit_b1 parse_body_lets_into; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-023-mega7-full-emit gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

ROW_N=0
MISS=0
echo "=== BOOT-023: full emit wave rows ==="
while IFS=$'\t' read -r emit_id mega_fn role hook _notes; do
  [ -z "${emit_id:-}" ] && continue
  case "$emit_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  full_id="full_${emit_id}"
  if ! grep -qF "$full_id" "$DOC" 2>/dev/null; then
    echo "boot-023 FAIL: doc missing $full_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qE "function ${mega_fn}\\(" compiler/src/parser/parser.sx 2>/dev/null; then
    echo "boot-023 FAIL: parser.sx missing $mega_fn" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-023 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-023 OK $full_id -> $mega_fn ($role)"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-023-mega7-full-emit gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
  exit 1
fi

# B1–B7 须均为 emit_target
EMIT_TARGET_N=0
while IFS=$'\t' read -r item_id kind _phase status _hook _notes; do
  [ "$kind" = "mega7" ] || continue
  case "$status" in
    emit_target|emit) EMIT_TARGET_N=$((EMIT_TARGET_N + 1)) ;;
    *)
      echo "boot-023 FAIL: $item_id status=${status} (want emit_target)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MATRIX"
if [ "$EMIT_TARGET_N" -lt 7 ]; then
  echo "boot-023 FAIL: emit_target rows=${EMIT_TARGET_N} < 7" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot023_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-023-mega7-full-emit manifest OK (rows=${ROW_N} emit_target=${EMIT_TARGET_N})"

PROMOTE_EMIT=0
EMIT_FULL=0
SKIP=1

if boot023_mega7_linux_asm; then
  echo "=== BOOT-023: full emit wave (Linux shux_asm) ==="
  chmod +x tests/run-parser-mega7-emit-wave.sh
  WAVE_OUT="/tmp/boot023_emit_wave_$$.log"
  if ./tests/run-parser-mega7-emit-wave.sh 2>&1 | tee "$WAVE_OUT"; then
    PROMOTE_EMIT="$(boot023_count_emit "$WAVE_OUT")"
    EMIT_FULL="$PROMOTE_EMIT"
    SKIP=0
    echo "boot-023 full emit OK (promote_emit=${PROMOTE_EMIT})"
  else
    rm -f "$WAVE_OUT"
    boot023_emit_report "fail" 0 0 0
    exit 1
  fi
  rm -f "$WAVE_OUT"
else
  echo "boot-023-mega7-full-emit gate SKIP wave (Darwin or no shux_asm)" >&2
fi

if [ "$SKIP" -eq 0 ] && [ "$PROMOTE_EMIT" -lt "$MIN_EMIT" ]; then
  echo "boot-023-mega7-full-emit gate FAIL: promote_emit=${PROMOTE_EMIT} < min ${MIN_EMIT}" >&2
  boot023_emit_report "fail" "$PROMOTE_EMIT" "$EMIT_FULL" 0
  exit 1
fi

boot023_emit_report "ok" "$PROMOTE_EMIT" "$EMIT_FULL" "$SKIP"
echo "boot-023-mega7-full-emit gate OK"
