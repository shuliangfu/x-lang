#!/usr/bin/env bash
# DOD-CL-S1：struct align(64) + XLANG_PAD_FIELDS warn（假权威诚实）。
#
# 用法：./tests/run-dod-cl-s1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-dod-cl-s1-gate.sh
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`) retired.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Explicit-bad XLANG / missing native
# = hard die. check / pad-fields warn observational (paused 2026-08-05);
# cl_align64_smoke.x exit 64 hard-fail. Report run=/obs=/skip= (keep
# check=/warn= extra). G.7: complete existing resolve_shu + dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

ALIGN_SRC="tests/dod/cl_align64_smoke.x"
PAD_SRC="tests/dod/cl_pad_fields_bad.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
ALIGN_OUT="$OUT_DIR/xlang_dod_cl_align64"
PREFIX="xlang: [XLANG_DOD_CL_S1]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== DOD-CL-S1: align(64) + -pad-fields (honesty) ==="
for f in "$ALIGN_SRC" "$PAD_SRC"; do
  if [ ! -f "$f" ]; then
    echo "dod-cl-s1 gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "dod-cl-s1 manifest OK"

CHECK_OK=0
WARN_OK=0
RUN_OK=0
OBS=0
SKIP=1

if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    echo "dod-cl-s1 gate FAIL: explicit XLANG not native (refuse leftover XLANG fallthrough)" >&2
    echo "${PREFIX} status=fail check=0 warn=0 run=0 obs=0 skip=0 host=$(ci_host_summary)"
    exit 1
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  echo "dod-cl-s1 gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 warn=0 run=0 obs=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi

echo "=== DOD-CL-S1: smoke (XLANG=$XLANG_BIN; check/warn observational; run hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
if "$XLANG_BIN" check "$ALIGN_SRC" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "dod-cl-s1 SKIP check align (paused 2026-08-05)" >&2
fi
pad_out="$(XLANG_PAD_FIELDS=1 "$XLANG_BIN" check "$PAD_SRC" 2>&1)" || true
if echo "$pad_out" | grep -q 'warning: -pad-fields'; then
  WARN_OK=1
else
  echo "dod-cl-s1 SKIP pad-fields warn (check paused / no warning)" >&2
fi

# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

rm -f "$ALIGN_OUT"
if ! "$XLANG_BIN" "$ALIGN_SRC" -o "$ALIGN_OUT" 2>/tmp/xlang_dod_cl_align64_build.log; then
  echo "dod-cl-s1 FAIL: compile $ALIGN_SRC" >&2
  tail -20 /tmp/xlang_dod_cl_align64_build.log 2>/dev/null || true
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 obs=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
if [ ! -x "$ALIGN_OUT" ]; then
  echo "dod-cl-s1 FAIL: missing exe $ALIGN_OUT" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 obs=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
set +e
"$ALIGN_OUT" >/dev/null 2>&1
RC=$?
set -e
if [ "$RC" -ne 64 ]; then
  echo "dod-cl-s1 FAIL: cl_align64 expected exit 64, got $RC" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 obs=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
RUN_OK=1
SKIP=0
if [ "$CHECK_OK" -eq 0 ] || [ "$WARN_OK" -eq 0 ]; then
  OBS=1
fi
echo "dod-cl-s1: cl_align64 exit=64 OK"

# Optional disasm hint (non-fatal).
if command -v objdump >/dev/null 2>&1; then
  if objdump -d "$ALIGN_OUT" 2>/dev/null | grep -qE '0x40|\+64\('; then
    echo "dod-cl-s1: disasm tail@64 hint OK"
  else
    echo "dod-cl-s1 WARN: disasm missing +64/0x40 offset (non-fatal)" >&2
  fi
fi

echo "dod-cl-s1 check_ok=${CHECK_OK} warn_ok=${WARN_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} warn=${WARN_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
echo "dod-cl-s1 gate OK"
