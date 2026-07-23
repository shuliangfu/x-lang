#!/usr/bin/env bash
# ZC-3 门禁：编译期 slice 域（M-3 region + M-5 read_ptr）+ 数组→slice 运行时 smoke。
# 用法：
#   ./tests/run-zc3-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-zc3-gate.sh
set -e
cd "$(dirname "$0")/.."

XLANG_BIN="${XLANG:-}"
case "$XLANG_BIN" in
  /*) XLANG_ABS="$XLANG_BIN" ;;
  "") XLANG_ABS="" ;;
  *) XLANG_ABS="$(pwd)/$XLANG_BIN" ;;
esac

zc3_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if [ -z "$XLANG_ABS" ] || ! zc3_native_exe "$XLANG_ABS"; then
  XLANG_ABS=""
  for cand in ./compiler/xlang-c ./compiler/xlang ./compiler/xlang_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if zc3_native_exe "$abs"; then
      XLANG_ABS="$abs"
      break
    fi
  done
fi

CHECK_XLANG="$XLANG_ABS"
if [ -z "$CHECK_XLANG" ] && [ -x ./compiler/xlang-c ]; then
  CHECK_XLANG=./compiler/xlang-c
fi

REGION_SMOKE="tests/slice/region_array_smoke.x"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
REGION_OUT="$OUT_DIR/xlang_zc3_region_array"
rm -f "$REGION_OUT"

echo "=== ZC-3: compile-time slice region + array→slice smoke ==="

if [ -z "$CHECK_XLANG" ]; then
  if make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null; then
    if [ -x ./compiler/xlang-c ]; then
      CHECK_XLANG=./compiler/xlang-c
    fi
  fi
fi

if [ -z "$CHECK_XLANG" ] || ! "$CHECK_XLANG" check tests/slice/main.x >/dev/null 2>&1; then
  echo "zc3 gate SKIP (no working xlang-c/xlang; rebuild native compiler or use Linux docker)"
  exit 0
fi

# M-3/M-5：slice 域 typeck（含 read_ptr_region_*）
chmod +x tests/run-typeck-region.sh
XLANG="$CHECK_XLANG" ./tests/run-typeck-region.sh
echo "zc3: region typeck OK"

# 数组→slice + .data/.length 字段
chmod +x tests/run-slice-field.sh
XLANG="$CHECK_XLANG" ./tests/run-slice-field.sh
echo "zc3: slice field OK"

# M-5：read_ptr_slice 运行时 + slice 字段 codegen
make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o
chmod +x tests/run-io-read-ptr-slice.sh
XLANG="$CHECK_XLANG" ./tests/run-io-read-ptr-slice.sh
echo "zc3: read_ptr_slice OK"

# region 内 array→slice 运行时（-o 链接须 xlang-c/xlang，xlang_asm 缺 slice 字段 codegen）
LINK_XLANG="$CHECK_XLANG"
case "$(basename "$CHECK_XLANG")" in
  xlang_asm|xlang)
    if [ -x ./compiler/xlang-c ]; then
      LINK_XLANG=./compiler/xlang-c
    fi
    ;;
esac
if ! XLANG="$LINK_XLANG" "$LINK_XLANG" build "$REGION_SMOKE" -o "$REGION_OUT" 2>/tmp/xlang_zc3_region_build.log; then
  echo "zc3 FAIL: compile $REGION_SMOKE" >&2
  tail -8 /tmp/xlang_zc3_region_build.log 2>/dev/null || true
  exit 1
fi
if [ ! -x "$REGION_OUT" ]; then
  echo "zc3 FAIL: missing exe $REGION_OUT" >&2
  exit 1
fi
RC=0
"$REGION_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 20 ]; then
  echo "zc3 FAIL: region_array_smoke expected exit 20, got $RC" >&2
  exit 1
fi
echo "zc3: region_array_smoke exit=20 OK"

echo "zc3 gate OK"
