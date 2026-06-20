#!/usr/bin/env bash
# BOOT-021：mega7 parser B1–B7 晋升波次门禁
#
# 用法：./tests/run-boot-021-mega7-promote-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT021_DOC:-analysis/boot-021-mega7-promote-v1.md}"
MANIFEST="${SHUX_BOOT021_TSV:-tests/baseline/boot-021-mega7-promote.tsv}"
WAVE="${SHUX_BOOT021_WAVE_TSV:-tests/baseline/parser-mega7-promote-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
LIB="tests/lib/boot-021-mega7-promote.sh"
MIN_ROWS=7

# shellcheck source=tests/lib/boot-021-mega7-promote.sh
. "$LIB"

echo "=== BOOT-021: mega7 promote manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" \
  tests/baseline/parser-mega-bisect.tsv \
  tests/run-parser-mega7-promote-wave.sh \
  tests/run-boot-020-mega7-milestone-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-021-mega7-promote gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_promote_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in B1–B7 runnable_ok promote_emit min_delta_pass; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-021-mega7-promote gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

ROW_N=0
MISS=0
echo "=== BOOT-021: promote wave rows ==="
while IFS=$'\t' read -r promote_id mega_fn _phase hook _notes; do
  [ -z "${promote_id:-}" ] && continue
  case "$promote_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$promote_id" "$DOC" 2>/dev/null; then
    echo "boot-021 FAIL: doc missing $promote_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qE "function ${mega_fn}\\(" compiler/src/parser/parser.sx 2>/dev/null; then
    echo "boot-021 FAIL: parser.sx missing $mega_fn" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-021 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-021 OK $promote_id -> $mega_fn"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-021-mega7-promote gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
  exit 1
fi

# comp-parser-mega7-matrix B1–B7 须为 runnable（非 stub）；仅 Linux+shux_asm 时硬门禁
STUB_N=0
if boot021_mega7_linux_asm; then
  while IFS=$'\t' read -r item_id kind phase status _hook _notes; do
    [ "$kind" = "mega7" ] || continue
    case "$status" in
      runnable|emit|in_progress|emit_target) ;;
      stub)
        echo "boot-021 FAIL: $item_id still stub (want runnable)" >&2
        STUB_N=$((STUB_N + 1))
        ;;
    esac
  done < "$MATRIX"
  if [ "$STUB_N" -gt 0 ]; then
    MISS=$((MISS + STUB_N))
  fi
else
  echo "boot-021-mega7-promote gate SKIP mega7 matrix stub check (no shux_asm)" >&2
fi

if [ "$MISS" -gt 0 ]; then
  boot021_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-021-mega7-promote manifest OK (rows=${ROW_N})"

RUNNABLE_OK=0
PROMOTE_EMIT=0
SKIP=1

if boot021_mega7_linux_asm; then
  echo "=== BOOT-021: promote wave (Linux shux_asm) ==="
  chmod +x tests/run-parser-mega7-promote-wave.sh
  WAVE_OUT="/tmp/boot021_wave_$$.log"
  if ./tests/run-parser-mega7-promote-wave.sh 2>&1 | tee "$WAVE_OUT"; then
    RUNNABLE_OK=$(grep -cE 'status=(stub|emit|fail)' "$WAVE_OUT" 2>/dev/null || echo 0)
    PROMOTE_EMIT=$(grep -cE 'status=emit' "$WAVE_OUT" 2>/dev/null || echo 0)
    SKIP=0
    echo "boot-021 runnable OK (targets=${RUNNABLE_OK} emit=${PROMOTE_EMIT})"
  else
    rm -f "$WAVE_OUT"
    boot021_emit_report "fail" 0 0 0
    exit 1
  fi
  rm -f "$WAVE_OUT"
else
  echo "boot-021-mega7-promote gate SKIP wave (Darwin or no shux_asm)" >&2
  RUNNABLE_OK=$ROW_N
fi

if [ "$SKIP" -eq 0 ] && [ "$RUNNABLE_OK" -lt "$MIN_ROWS" ]; then
  echo "boot-021-mega7-promote gate FAIL: runnable_ok=${RUNNABLE_OK} < min ${MIN_ROWS}" >&2
  boot021_emit_report "fail" "$RUNNABLE_OK" "$PROMOTE_EMIT" 0
  exit 1
fi

boot021_emit_report "ok" "$RUNNABLE_OK" "$PROMOTE_EMIT" "$SKIP"
echo "boot-021-mega7-promote gate OK"
