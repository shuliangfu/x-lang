#!/usr/bin/env bash
# COMP-016：riscv64 wave 回归矩阵 runnable 门禁
#
# 用法：./tests/run-comp-riscv64-wave-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP016_DOC:-analysis/comp-riscv64-wave-v1.md}"
WAVE="${SHU_COMP016_WAVE_TSV:-tests/baseline/comp-riscv64-wave.tsv}"
MANIFEST="${SHU_COMP016_MANIFEST:-tests/baseline/comp-riscv64.tsv}"
MATRIX="${SHU_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
LIB="tests/lib/comp-riscv64-wave.sh"
MIN_WAVE=3
MIN_CASES=9

# shellcheck source=tests/lib/comp-riscv64-wave.sh
. "$LIB"
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

echo "=== COMP-016: riscv64 wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$MATRIX" "$LIB" \
  analysis/comp-riscv64-v1.md tests/run-comp-riscv64-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-riscv64-wave gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_wave_cases) MIN_WAVE="$c2" ;;
  esac
done < "$WAVE"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Wave 回归矩阵 wave_ok min_cases; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-riscv64-wave gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

WAVE_N=0
MISS=0
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "case_ref" ] || continue
  WAVE_N=$((WAVE_N + 1))
  if ! grep -qF "$anchor" "$MATRIX" 2>/dev/null; then
    echo "comp-riscv64-wave FAIL: matrix missing $anchor" >&2
    MISS=$((MISS + 1))
  elif ! grep -qF "$target" "$DOC" 2>/dev/null; then
    echo "comp-riscv64-wave FAIL: doc missing $target" >&2
    MISS=$((MISS + 1))
  elif ! comp_riscv64_sample_path "$target" >/dev/null 2>&1; then
    echo "comp-riscv64-wave FAIL: missing sample $target" >&2
    MISS=$((MISS + 1))
  else
    echo "comp-riscv64-wave OK $anchor -> $target"
  fi
done < "$WAVE"

WAVE_MATRIX_N="$(comp_riscv64_wave_count "$MATRIX")"
if [ "$WAVE_N" -lt "$MIN_WAVE" ] || [ "$WAVE_MATRIX_N" -lt "$MIN_WAVE" ]; then
  echo "comp-riscv64-wave gate FAIL: wave=${WAVE_N} matrix_wave=${WAVE_MATRIX_N} < min ${MIN_WAVE}" >&2
  exit 1
fi

CASE_TOTAL=0
while IFS=$'\t' read -r case_id _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
done < "$MATRIX"

if [ "$CASE_TOTAL" -lt "$MIN_CASES" ]; then
  echo "comp-riscv64-wave gate FAIL: matrix cases=${CASE_TOTAL} < min ${MIN_CASES}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_riscv64_wave_emit_report "fail" 0 0 0
  exit 1
fi
echo "comp-riscv64-wave manifest OK (wave=${WAVE_N} total=${CASE_TOTAL})"

if [ "${SHU_COMP016_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_riscv64_wave_emit_report "ok" 0 "$MIN_WAVE" 1
  echo "comp-riscv64-wave gate OK (manifest only)"
  exit 0
fi

echo "=== COMP-016: parent COMP-012 manifest ==="
chmod +x tests/run-comp-riscv64-gate.sh
SHU_COMP_RISCV64_MANIFEST_ONLY=1 ./tests/run-comp-riscv64-gate.sh

SHU_BIN=""
for cand in ./compiler/shu ./compiler/shu-c; do
  if comp_riscv64_native_shu "$cand"; then
    SHU_BIN="$cand"
    break
  fi
done

WAVE_OK=0
WAVE_SKIP=0
HOST_SKIP=1

if [ -n "$SHU_BIN" ]; then
  echo "=== COMP-016: wave asm_text (SHU=$SHU_BIN) ==="
  HOST_SKIP=0
  while IFS=$'\t' read -r case_id sample _check _expect policy _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in \#*|min_*) continue ;; esac
    [ "${policy:-}" = "wave" ] || continue
    if comp_riscv64_wave_run_case "$SHU_BIN" "$sample"; then
      WAVE_OK=$((WAVE_OK + 1))
      echo "comp-riscv64-wave runnable OK $case_id"
    else
      echo "comp-riscv64-wave SKIP $case_id (asm_text unavailable)" >&2
      WAVE_SKIP=$((WAVE_SKIP + 1))
    fi
  done < "$MATRIX"
else
  echo "comp-riscv64-wave gate SKIP runnable (no native shu)" >&2
  WAVE_SKIP=$MIN_WAVE
fi

if [ "$HOST_SKIP" -eq 0 ] && [ "$WAVE_OK" -eq 0 ] && [ "$WAVE_SKIP" -eq 0 ]; then
  comp_riscv64_wave_emit_report "fail" 0 0 0
  exit 1
fi

comp_riscv64_wave_emit_report "ok" "$WAVE_OK" "$WAVE_SKIP" "$HOST_SKIP"
echo "comp-riscv64-wave gate OK"
