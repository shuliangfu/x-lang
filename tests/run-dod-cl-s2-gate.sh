#!/usr/bin/env bash
# DOD-CL-S2 门禁：Arena64 align(64) chunk + SHU_HOT_REORDER=1 热字段重排 hint。
# 用法：
#   ./tests/run-dod-cl-s2-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-dod-cl-s2-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/dod-host-backend.sh
source "$(dirname "$0")/lib/dod-host-backend.sh"

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu-c ./compiler/shu ./compiler/shu_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

CHECK_SHU="$SHU_ABS"
if [ -z "$CHECK_SHU" ] && [ -x ./compiler/shu-c ]; then
  CHECK_SHU=./compiler/shu-c
fi

ARENA_SRC="tests/dod/cl_arena64_smoke.su"
REORDER_SRC="tests/dod/cl_hot_reorder_bad.su"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
ARENA_OUT="$OUT_DIR/shu_dod_cl_arena64"
rm -f "$ARENA_OUT"

echo "=== DOD-CL-S2: Arena64 align(64) + hot-reorder hint ==="

if [ -z "$CHECK_SHU" ] && [ -z "$SHU_ABS" ]; then
  echo "dod-cl-s2 gate SKIP (no shu/shu-c/shu_asm)"
  exit 0
fi

# 确保 heap.o 含 Arena64 符号
if [ ! -f std/heap/heap.o ] || [ std/heap/heap.c -nt std/heap/heap.o ]; then
  cc -Wall -Wextra -Icompiler -Icompiler/include -Isrc -c -o std/heap/heap.o std/heap/heap.c 2>/dev/null || \
    cc -Wall -Wextra -c -o std/heap/heap.o std/heap/heap.c
fi

if [ -n "$CHECK_SHU" ]; then
  if "$CHECK_SHU" check -L . "$ARENA_SRC" >/dev/null 2>&1; then
    echo "dod-cl-s2: cl_arena64 typeck OK"
  else
    echo "dod-cl-s2 FAIL: typeck $ARENA_SRC" >&2
    "$CHECK_SHU" check -L . "$ARENA_SRC" 2>&1 || true
    exit 1
  fi

  reorder_out="$(SHU_HOT_REORDER=1 "$CHECK_SHU" check -L . "$REORDER_SRC" 2>&1)" || true
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

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  echo "dod-cl-s2: typeck-only OK (no native shu_asm for run test)"
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

DOD_EXE_SHU="$(dod_host_exe_shu "$SHU_ABS")"

if ! SHU="$SHU_ABS" "$DOD_EXE_SHU" $DOD_GATE_BACKEND_ARGS -L . "$ARENA_SRC" -o "$ARENA_OUT"; then
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
