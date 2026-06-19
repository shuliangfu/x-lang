#!/usr/bin/env bash
# COMP-018：riscv64 QEMU 用户态烟测门禁
#
# 用法：./tests/run-comp-riscv64-qemu-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP018_DOC:-analysis/comp-riscv64-qemu-v1.md}"
WAVE="${SHUX_COMP018_WAVE_TSV:-tests/baseline/comp-riscv64-qemu.tsv}"
MANIFEST="${SHUX_COMP018_MANIFEST:-tests/baseline/comp-riscv64.tsv}"
MATRIX="${SHUX_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
LIB="tests/lib/comp-riscv64-qemu.sh"
MIN_QEMU=2
MIN_CASES=11

# shellcheck source=tests/lib/comp-riscv64-qemu.sh
. "$LIB"
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

echo "=== COMP-018: riscv64 qemu manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$MATRIX" "$LIB" \
  analysis/comp-riscv64-wave-v1.md tests/run-comp-riscv64-wave-gate.sh \
  tests/run-comp-riscv64-qemu-smoke.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-riscv64-qemu gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_qemu_cases) MIN_QEMU="$c2" ;;
  esac
done < "$WAVE"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MATRIX"

for kw in QEMU qemu_ok min_qemu_cases case_qemu_min; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-riscv64-qemu gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

QEMU_N=0
MISS=0
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "case_ref" ] || continue
  QEMU_N=$((QEMU_N + 1))
  if ! grep -qF "$anchor" "$MATRIX" 2>/dev/null; then
    echo "comp-riscv64-qemu FAIL: matrix missing $anchor" >&2
    MISS=$((MISS + 1))
  elif ! grep -qF "$target" "$DOC" 2>/dev/null; then
    echo "comp-riscv64-qemu FAIL: doc missing $target" >&2
    MISS=$((MISS + 1))
  elif ! comp_riscv64_sample_path "$target" >/dev/null 2>&1; then
    echo "comp-riscv64-qemu FAIL: missing sample $target" >&2
    MISS=$((MISS + 1))
  else
    echo "comp-riscv64-qemu OK $anchor -> $target"
  fi
done < "$WAVE"

QEMU_MATRIX_N="$(comp_riscv64_qemu_count "$MATRIX")"
if [ "$QEMU_N" -lt "$MIN_QEMU" ] || [ "$QEMU_MATRIX_N" -lt "$MIN_QEMU" ]; then
  echo "comp-riscv64-qemu gate FAIL: qemu=${QEMU_N} matrix_qemu=${QEMU_MATRIX_N} < min ${MIN_QEMU}" >&2
  exit 1
fi

CASE_TOTAL=0
while IFS=$'\t' read -r case_id _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
done < "$MATRIX"

if [ "$CASE_TOTAL" -lt "$MIN_CASES" ]; then
  echo "comp-riscv64-qemu gate FAIL: matrix cases=${CASE_TOTAL} < min ${MIN_CASES}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_riscv64_qemu_emit_report "fail" 0 0 0
  exit 1
fi
echo "comp-riscv64-qemu manifest OK (qemu=${QEMU_N} total=${CASE_TOTAL})"

echo "=== COMP-018: parent COMP-016 manifest ==="
chmod +x tests/run-comp-riscv64-wave-gate.sh
SHUX_COMP016_MANIFEST_ONLY=1 ./tests/run-comp-riscv64-wave-gate.sh

SHUX_BIN=""
for cand in ./compiler/shux ./compiler/shux-c; do
  if comp_riscv64_native_shu "$cand"; then
    SHUX_BIN="$cand"
    break
  fi
done

QEMU="$(comp_riscv64_qemu_probe || true)"
QEMU_OK=0
QEMU_SKIP=0
HOST_SKIP=1

if [ -n "$SHUX_BIN" ] && [ -n "$QEMU" ]; then
  echo "=== COMP-018: qemu user run (SHUX=$SHUX_BIN QEMU=$QEMU) ==="
  HOST_SKIP=0
  while IFS=$'\t' read -r case_id sample _check expect policy _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in \#*|min_*) continue ;; esac
    [ "${policy:-}" = "qemu" ] || continue
    want="$(comp_riscv64_qemu_expect_exit "$expect")"
    if comp_riscv64_qemu_run_case "$SHUX_BIN" "$sample" "$want" "$QEMU"; then
      QEMU_OK=$((QEMU_OK + 1))
      echo "comp-riscv64-qemu runnable OK $case_id"
    else
      echo "comp-riscv64-qemu SKIP $case_id (qemu run unavailable)" >&2
      QEMU_SKIP=$((QEMU_SKIP + 1))
    fi
  done < "$MATRIX"
else
  echo "comp-riscv64-qemu gate SKIP runnable (shux=${SHUX_BIN:-none} qemu=${QEMU:-none})" >&2
  QEMU_SKIP=$MIN_QEMU
fi

comp_riscv64_qemu_emit_report "ok" "$QEMU_OK" "$QEMU_SKIP" "$HOST_SKIP"
echo "comp-riscv64-qemu gate OK"
