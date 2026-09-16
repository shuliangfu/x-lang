#!/usr/bin/env bash
# Bootstrap checklist sequence — run §三→§九 section gates in order.
#
# Honesty: soft default seed/`./compiler/xlang-c` (prefer-c / false authority)
# when XLANG unset retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Section bodies remain in
# run-bootstrap-checklist-gate.sh (their own soft residuals = follow-up).
#
# Env:
#   XLANG_CHECKLIST_FROM=3   start section (default 3)
#   XLANG_CHECKLIST_TO=9     end section (default 9)
#   XLANG_CHECKLIST_ALLOW_WARN=1  WARN/SKIP sections do not fail total (default 1)
#   XLANG=./compiler/xlang_asm    override compiler (prefer asm when unset)
# Report: run=/obs=/skip=
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
# shellcheck source=tests/lib/p0-gate-xlang.sh
. tests/lib/p0-gate-xlang.sh

PREFIX="${XLANG_CHECKLIST_SEQ_PREFIX:-xlang: [XLANG_CHECKLIST_SEQ]}"
FROM="${XLANG_CHECKLIST_FROM:-3}"
TO="${XLANG_CHECKLIST_TO:-9}"
ALLOW="${XLANG_CHECKLIST_ALLOW_WARN:-1}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "checklist-sequence FAIL: $*" >&2
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
  # Prefer product asm; refuse soft seed/xlang-c-first default.
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

export XLANG_MINIMAL_CC_LINK="${XLANG_MINIMAL_CC_LINK:-1}"
export XLANG_P0_SKIP_STAGE1="${XLANG_P0_SKIP_STAGE1:-1}"
export XLANG_P0_GATE_O_HEARTBEAT="${XLANG_P0_GATE_O_HEARTBEAT:-15}"
export XLANG_P0_GATE_O_TIMEOUT="${XLANG_P0_GATE_O_TIMEOUT:-120}"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
gate_progress "checklist-sequence XLANG=$XLANG (prefer asm; refuse soft prefer-c)"

TOTAL_FAIL=0
for n in $(seq "$FROM" "$TO"); do
  echo ""
  echo "################################################################"
  gate_progress "顺序跑 §$n / $FROM..$TO"
  echo "################################################################"
  set +e
  XLANG_CHECKLIST_SECTION="$n" \
    XLANG_CHECKLIST_ALLOW_WARN="$ALLOW" \
    XLANG_CHECKLIST_STOP_ON_FAIL=0 \
    ./tests/run-bootstrap-checklist-gate.sh
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    gate_progress "§$n 未全绿 (exit=$ec)"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    # Section residual under ALLOW_WARN = obs (refuse silent soft SKIP→OK
    # without a counter); hard fail only when ALLOW!=1.
    OBS=$((OBS + 1))
  else
    gate_progress "§$n 本节 OK"
    RUN_OK=$((RUN_OK + 1))
  fi
done

echo ""
gate_progress "顺序跑完成: $((TO - FROM + 1)) 节, FAIL节=$TOTAL_FAIL run=${RUN_OK} obs=${OBS}"
if [ "$TOTAL_FAIL" -gt 0 ] && [ "$ALLOW" != "1" ]; then
  die "FAIL节=$TOTAL_FAIL (ALLOW_WARN=$ALLOW)"
fi
ok_report
exit 0
