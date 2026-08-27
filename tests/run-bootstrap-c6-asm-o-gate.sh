#!/usr/bin/env bash
# C6 / P0#2: asm -o direct link smoke (no gcc fallback).
#
# Honesty: soft SKIP→OK when no native xlang_asm retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. XLANG_BOOTSTRAP_C6_SKIP=1 = skip (counted). DOC live =
# analysis/archive/narrative/自举前必须清单.md with ## Gate (refuse
# top-level resurrect). Report run=/obs=/skip=.
#
# Usage: ./tests/run-bootstrap-c6-asm-o-gate.sh
# Env:   XLANG_BOOTSTRAP_C6_SKIP=1  → skip=1 status=ok
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu x86_64 gold for freestanding asm -o;
# Darwin runs the same smoke when native xlang_asm is present.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_BOOTSTRAP_C6_PREFIX:-xlang: [XLANG_BOOTSTRAP_C6]}"
DOC="${XLANG_BOOTSTRAP_C6_DOC:-analysis/archive/narrative/自举前必须清单.md}"
RV="tests/return-value/main.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "bootstrap-c6-asm-o-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# C6 contract is product xlang_asm -backend asm -o. Explicit XLANG wins only
# when it is a native exe; otherwise require ./compiler/xlang_asm.
resolve_asm() {
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
  abs="$root/compiler/xlang_asm"
  if dod_native_exe "$abs"; then
    echo "$abs"
    return 0
  fi
  return 1
}

echo "=== C6: asm -o return-value ==="
if [ -f analysis/自举前必须清单.md ]; then
  die "top-level DOC resurrected (live = archive/narrative/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF "C6" "$DOC" || die "doc missing C6"
[ -f "$RV" ] || die "missing $RV"

if [ "${XLANG_BOOTSTRAP_C6_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "bootstrap-c6-asm-o-gate: SKIP (XLANG_BOOTSTRAP_C6_SKIP=1)"
  echo "bootstrap-c6-asm-o-gate OK"
  ok_report
  exit 0
fi

ASM="$(resolve_asm)" || die "no native xlang_asm (refuse soft SKIP→OK)"
export XLANG="$ASM"
export XLANG_LINK_XLANG="$ASM"

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true
EXE="/tmp/xlang_c6_asm_rv_$$"
rm -f "$EXE"
gate_progress "C6: $ASM -backend asm -o return-value ..."
set +e
"$ASM" -backend asm -L . "$RV" -o "$EXE" >/tmp/xlang_c6_asm_o.log 2>&1
ec=$?
set -e
if [ "$ec" -ne 0 ] || [ ! -x "$EXE" ]; then
  tail -8 /tmp/xlang_c6_asm_o.log >&2 || true
  die "asm -o ec=$ec (refuse soft SKIP→OK)"
fi
run_ec=0
"$EXE" >/dev/null 2>&1 || run_ec=$?
rm -f "$EXE"
if [ "$run_ec" -ne 42 ]; then
  die "run exit=$run_ec want=42"
fi
RUN_OK=$((RUN_OK + 1))
gate_progress "bootstrap-c6-asm-o-gate OK (asm -o exit=42)"
echo "bootstrap-c6-asm-o-gate OK"
ok_report
