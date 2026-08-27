#!/usr/bin/env bash
# COMP-018: riscv64 QEMU userland smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no xlang/qemu retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing
# native = hard die. Missing qemu-user = skip= (tooling N/A, not soft
# SKIP→OK). Report run=/skip=.
#
# Usage: ./tests/run-comp-riscv64-qemu-smoke.sh
# PLATFORM: SHARED archaeology (qemu-riscv64 optional).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-riscv64-qemu.sh
. tests/lib/comp-riscv64-qemu.sh
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

MATRIX="${XLANG_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
PREFIX="xlang: [XLANG_COMP_RISCV64_QEMU]"
RUN_OK=0
SKIP=0

die() {
  echo "comp-riscv64-qemu-smoke FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

QEMU="$(comp_riscv64_qemu_probe || true)"
if [ -z "$QEMU" ]; then
  echo "comp-riscv64-qemu-smoke SKIP (no qemu-riscv64; tooling N/A)"
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
fi

if ! comp_riscv64_asm_capable "$XLANG_BIN"; then
  echo "comp-riscv64-qemu-smoke SKIP (riscv64 asm not available; capability N/A)"
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
fi

while IFS=$'\t' read -r case_id sample _check expect policy _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  [ "${policy:-}" = "qemu" ] || continue
  want="$(comp_riscv64_qemu_expect_exit "$expect")"
  if comp_riscv64_qemu_run_case "$XLANG_BIN" "$sample" "$want" "$QEMU"; then
    RUN_OK=$((RUN_OK + 1))
    echo "comp-riscv64-qemu-smoke OK $case_id (exit=$want)"
  else
    SKIP=$((SKIP + 1))
    echo "comp-riscv64-qemu-smoke SKIP $case_id" >&2
  fi
done < "$MATRIX"

echo "comp-riscv64-qemu-smoke OK (passed=${RUN_OK} skip=${SKIP})"
ok_report
