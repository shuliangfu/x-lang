#!/usr/bin/env bash
# DOD-CL-S2 门禁：Arena64 align(64) chunk + XLANG_HOT_REORDER=1 热字段重排 hint。
# 用法：
#   ./tests/run-dod-cl-s2-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-dod-cl-s2-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/dod-host-backend.sh
source "$(dirname "$0")/lib/dod-host-backend.sh"

XLANG_BIN="${XLANG:-}"
case "$XLANG_BIN" in
  /*) XLANG_ABS="$XLANG_BIN" ;;
  "") XLANG_ABS="" ;;
  *) XLANG_ABS="$(pwd)/$XLANG_BIN" ;;
esac

if [ -z "$XLANG_ABS" ] || ! dod_native_exe "$XLANG_ABS"; then
  XLANG_ABS=""
  for cand in ./compiler/xlang-c ./compiler/xlang ./compiler/xlang_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      XLANG_ABS="$abs"
      break
    fi
  done
fi

CHECK_XLANG="$XLANG_ABS"
if [ -z "$CHECK_XLANG" ] && [ -x ./compiler/xlang-c ]; then
  CHECK_XLANG=./compiler/xlang-c
fi

ARENA_SRC="tests/dod/cl_arena64_smoke.x"
REORDER_SRC="tests/dod/cl_hot_reorder_bad.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
ARENA_OUT="$OUT_DIR/xlang_dod_cl_arena64"
rm -f "$ARENA_OUT"

echo "=== DOD-CL-S2: Arena64 align(64) + hot-reorder hint ==="

if [ -z "$CHECK_XLANG" ] && [ -z "$XLANG_ABS" ]; then
  echo "dod-cl-s2 gate SKIP (no xlang/xlang-c/xlang_asm)"
  exit 0
fi

# F-03 v2：heap 已纯 .x，不再 cc -c heap.c

if [ -n "$CHECK_XLANG" ]; then
  if "$CHECK_XLANG" check -L . "$ARENA_SRC" >/dev/null 2>&1; then
    echo "dod-cl-s2: cl_arena64 typeck OK"
  else
    echo "dod-cl-s2 FAIL: typeck $ARENA_SRC" >&2
    "$CHECK_XLANG" check -L . "$ARENA_SRC" 2>&1 || true
    exit 1
  fi

  reorder_out="$(XLANG_HOT_REORDER=1 "$CHECK_XLANG" check -L . "$REORDER_SRC" 2>&1)" || true
  if echo "$reorder_out" | grep -q 'warning: -hot-reorder'; then
    echo "dod-cl-s2: -hot-reorder warning OK"
  else
    echo "dod-cl-s2 FAIL: expected -hot-reorder warning on $REORDER_SRC" >&2
    echo "$reorder_out" >&2
    exit 1
  fi
else
  echo "dod-cl-s2: typeck SKIP (no check-capable compiler)"
fi

if [ -z "$XLANG_ABS" ] || ! dod_native_exe "$XLANG_ABS"; then
  echo "dod-cl-s2: typeck-only OK (no native xlang_asm for run test)"
  echo "dod-cl-s2 gate OK"
  exit 0
fi

case "$(uname -s 2>/dev/null)" in
  Darwin)
    echo "dod-cl-s2: compile/run N/A on Darwin (import + gen_driver hybrid; Linux covers)"
    echo "dod-cl-s2 gate OK"
    exit 0
    ;;
esac

DOD_EXE_XLANG="$(dod_host_exe_shu "$XLANG_ABS")"

if ! XLANG="$XLANG_ABS" "$DOD_EXE_XLANG" $DOD_GATE_BACKEND_ARGS -L . "$ARENA_SRC" -o "$ARENA_OUT"; then
  echo "dod-cl-s2 FAIL: compile $ARENA_SRC" >&2
  exit 1
fi
if [ ! -x "$ARENA_OUT" ]; then
  echo "dod-cl-s2 FAIL: missing exe $ARENA_OUT" >&2
  exit 1
fi
RC=0
"$ARENA_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "dod-cl-s2 FAIL: cl_arena64 expected exit 0, got $RC" >&2
  exit 1
fi
echo "dod-cl-s2: cl_arena64 exit=0 OK"
echo "dod-cl-s2 gate OK"
