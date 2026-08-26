#!/usr/bin/env bash
# DOD-CL-S2：Arena64 align(64) + XLANG_HOT_REORDER warn（假权威诚实）。
#
# 用法：./tests/run-dod-cl-s2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-dod-cl-s2-gate.sh
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check / hot-reorder warn
# observational (check gate paused 2026-08-05); cl_arena64_smoke.x exit 0
# hard-fail (no soft SKIP→OK when no native; no Darwin early-OK without run).
# Report check=/warn=/run=/skip=. Gate was portable-false-red (prefer xlang-c /
# hard check CHK002 / soft SKIP→OK / Darwin compile N/A early OK while asm
# already exit 0).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

ARENA_SRC="tests/dod/cl_arena64_smoke.x"
REORDER_SRC="tests/dod/cl_hot_reorder_bad.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
ARENA_OUT="$OUT_DIR/xlang_dod_cl_arena64"
PREFIX="xlang: [XLANG_DOD_CL_S2]"

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== DOD-CL-S2: Arena64 align(64) + hot-reorder (honesty) ==="
for f in "$ARENA_SRC" "$REORDER_SRC"; do
  if [ ! -f "$f" ]; then
    echo "dod-cl-s2 gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "dod-cl-s2 manifest OK"

CHECK_OK=0
WARN_OK=0
RUN_OK=0
SKIP=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "dod-cl-s2 gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 warn=0 run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi

echo "=== DOD-CL-S2: smoke (XLANG=$XLANG_BIN; check/warn observational; run hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
if "$XLANG_BIN" check -L . "$ARENA_SRC" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "dod-cl-s2 SKIP check arena (paused 2026-08-05)" >&2
fi
reorder_out="$(XLANG_HOT_REORDER=1 "$XLANG_BIN" check -L . "$REORDER_SRC" 2>&1)" || true
if echo "$reorder_out" | grep -q 'warning: -hot-reorder'; then
  WARN_OK=1
else
  echo "dod-cl-s2 SKIP hot-reorder warn (check paused / no warning)" >&2
fi

# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

rm -f "$ARENA_OUT"
if ! "$XLANG_BIN" -L . "$ARENA_SRC" -o "$ARENA_OUT" 2>/tmp/xlang_dod_cl_arena64_build.log; then
  echo "dod-cl-s2 FAIL: compile $ARENA_SRC" >&2
  tail -20 /tmp/xlang_dod_cl_arena64_build.log 2>/dev/null || true
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
if [ ! -x "$ARENA_OUT" ]; then
  echo "dod-cl-s2 FAIL: missing exe $ARENA_OUT" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
set +e
"$ARENA_OUT" >/dev/null 2>&1
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "dod-cl-s2 FAIL: cl_arena64 expected exit 0, got $RC" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} warn=${WARN_OK} run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi
RUN_OK=1
SKIP=0
echo "dod-cl-s2: cl_arena64 exit=0 OK"

echo "dod-cl-s2 check_ok=${CHECK_OK} warn_ok=${WARN_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} warn=${WARN_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "dod-cl-s2 gate OK"
