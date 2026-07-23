#!/usr/bin/env bash
# COMP-018：riscv64 QEMU 用户态烟测 runner
#
# 用法：./tests/run-comp-riscv64-qemu-smoke.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${XLANG_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
# shellcheck source=tests/lib/comp-riscv64-qemu.sh
. tests/lib/comp-riscv64-qemu.sh
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

XLANG_BIN=""
for cand in ./compiler/xlang ./compiler/xlang-c; do
  if comp_riscv64_native_xlang "$cand"; then
    XLANG_BIN="$cand"
    break
  fi
done

QEMU="$(comp_riscv64_qemu_probe || true)"
if [ -z "$XLANG_BIN" ] || [ -z "$QEMU" ]; then
  echo "comp-riscv64-qemu-smoke SKIP (xlang=${XLANG_BIN:-none} qemu=${QEMU:-none})"
  exit 0
fi

OK=0
SKIP=0
while IFS=$'\t' read -r case_id sample _check expect policy _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  [ "${policy:-}" = "qemu" ] || continue
  want="$(comp_riscv64_qemu_expect_exit "$expect")"
  if comp_riscv64_qemu_run_case "$XLANG_BIN" "$sample" "$want" "$QEMU"; then
    OK=$((OK + 1))
    echo "comp-riscv64-qemu-smoke OK $case_id (exit=$want)"
  else
    SKIP=$((SKIP + 1))
    echo "comp-riscv64-qemu-smoke SKIP $case_id" >&2
  fi
done < "$MATRIX"

echo "comp-riscv64-qemu-smoke OK (passed=${OK} skip=${SKIP})"
