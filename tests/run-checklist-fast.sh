#!/usr/bin/env bash
# Fast bootstrap checklist entry (§三→§九; FAST skips §六 / §9.1).
#
# Honesty: soft default `./compiler/xlang-c` (prefer-c / false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c). Body = run-checklist-sequence.sh (section gates report their
# own run=/obs=/skip=).
# Report: run=/obs=/skip= (wrapper resolve hard; sections delegated)
# Usage: ./tests/run-checklist-fast.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
if [ -z "${XLANG_STDBUF_WRAPPED:-}" ] && command -v stdbuf >/dev/null 2>&1; then
  export XLANG_STDBUF_WRAPPED=1
  exec stdbuf -oL -eL bash "$0" "$@"
fi

set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_CHECKLIST_FAST_PREFIX:-xlang: [XLANG_CHECKLIST_FAST]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "checklist-fast FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_MINIMAL_CC_LINK=1
export XLANG_P0_SKIP_STAGE1="${XLANG_P0_SKIP_STAGE1:-1}"
export XLANG_P0_GATE_O_TIMEOUT="${XLANG_P0_GATE_O_TIMEOUT:-60}"
export XLANG_L9_SKIP_O="${XLANG_L9_SKIP_O:-0}"
export XLANG_S7_TYPECK_TIMEOUT="${XLANG_S7_TYPECK_TIMEOUT:-90}"
export XLANG_P0_GATE_O_HEARTBEAT=10
export XLANG_CHECKLIST_ALLOW_WARN=1
export XLANG_CHECKLIST_STOP_ON_FAIL=0
export XLANG_CHECKLIST_FAST=1
export XLANG_S7_OPTIONAL_SKIP=0
export XLANG_BOOTSTRAP_FRESH_SEED_SKIP=0

gate_progress "checklist FAST 开始 (XLANG=$XLANG; prefer asm; refuse soft prefer-c)"
gate_progress "预计 ~1 分钟（FAST skip §六/§9.1；S7 含 fs/heap；L9/C5 -o 各 ≤60s）"

set +e
./tests/run-checklist-sequence.sh
seq_ec=$?
set -e
if [ "$seq_ec" -ne 0 ]; then
  die "checklist-sequence exit=$seq_ec (refuse soft SKIP→OK)"
fi
RUN_OK=1
echo "checklist-fast OK"
ok_report
