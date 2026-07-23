#!/usr/bin/env bash
# DOD-CL-S1 门禁：struct align(64) 字段 + XLANG_PAD_FIELDS=1 伪共享 warning。
# 用法：
#   ./tests/run-dod-cl-s1-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-dod-cl-s1-gate.sh
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

ALIGN_SRC="tests/dod/cl_align64_smoke.x"
PAD_SRC="tests/dod/cl_pad_fields_bad.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
ALIGN_OUT="$OUT_DIR/xlang_dod_cl_align64"
rm -f "$ALIGN_OUT"

echo "=== DOD-CL-S1: align(64) + -pad-fields warning ==="

if [ -z "$CHECK_XLANG" ] && [ -z "$XLANG_ABS" ]; then
  echo "dod-cl-s1 gate SKIP (no xlang/xlang-c/xlang_asm)"
  exit 0
fi

if [ -n "$CHECK_XLANG" ]; then
  if "$CHECK_XLANG" check "$ALIGN_SRC" >/dev/null 2>&1; then
    echo "dod-cl-s1: cl_align64 typeck OK"
  else
    echo "dod-cl-s1 FAIL: typeck $ALIGN_SRC" >&2
    "$CHECK_XLANG" check "$ALIGN_SRC" 2>&1 || true
    exit 1
  fi

  pad_out="$(XLANG_PAD_FIELDS=1 "$CHECK_XLANG" check "$PAD_SRC" 2>&1)" || true
  if echo "$pad_out" | grep -q 'warning: -pad-fields'; then
    echo "dod-cl-s1: -pad-fields warning OK"
  else
    echo "dod-cl-s1 FAIL: expected -pad-fields warning on $PAD_SRC" >&2
    echo "$pad_out" >&2
    exit 1
  fi
else
  echo "dod-cl-s1: typeck SKIP (no check-capable compiler)"
fi

if [ -z "$XLANG_ABS" ] || ! dod_native_exe "$XLANG_ABS"; then
  echo "dod-cl-s1: typeck-only OK (no native xlang_asm for run/disasm)"
  echo "dod-cl-s1 gate OK"
  exit 0
fi

case "$(uname -s 2>/dev/null)" in
  Darwin)
    echo "dod-cl-s1: compile/run N/A on Darwin (gen_driver hybrid asm exe SIGILL; Linux covers)"
    echo "dod-cl-s1 gate OK"
    exit 0
    ;;
esac

DOD_EXE_XLANG="$(dod_host_exe_shu "$XLANG_ABS")"

if ! XLANG="$XLANG_ABS" "$DOD_EXE_XLANG" $DOD_GATE_BACKEND_ARGS "$ALIGN_SRC" -o "$ALIGN_OUT" 2>/tmp/xlang_dod_cl_align64_build.log; then
  echo "dod-cl-s1 FAIL: compile $ALIGN_SRC" >&2
  tail -8 /tmp/xlang_dod_cl_align64_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$ALIGN_OUT" ]; then
  echo "dod-cl-s1 FAIL: missing exe $ALIGN_OUT" >&2
  exit 1
fi
RC=0
"$ALIGN_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 64 ]; then
  echo "dod-cl-s1 FAIL: cl_align64 expected exit 64, got $RC" >&2
  exit 1
fi
echo "dod-cl-s1: cl_align64 exit=64 OK"

# tail 字段应落在 offset 64（0x40）
if command -v objdump >/dev/null 2>&1; then
  if objdump -d "$ALIGN_OUT" 2>/dev/null | grep -qE '0x40|\+64\('; then
    echo "dod-cl-s1: disasm tail@64 hint OK"
  else
    echo "dod-cl-s1 WARN: disasm missing +64/0x40 offset (non-fatal)" >&2
  fi
fi

echo "dod-cl-s1 gate OK"
