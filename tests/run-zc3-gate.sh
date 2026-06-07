#!/usr/bin/env bash
# ZC-3 门禁：编译期 slice 域（M-3 region + M-5 read_ptr）+ 数组→slice 运行时 smoke。
# 用法：
#   ./tests/run-zc3-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-zc3-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
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

if [ -z "$SHU_ABS" ] || ! zc3_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu-c ./compiler/shu ./compiler/shu_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if zc3_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

CHECK_SHU="$SHU_ABS"
if [ -z "$CHECK_SHU" ] && [ -x ./compiler/shu-c ]; then
  CHECK_SHU=./compiler/shu-c
fi

REGION_SMOKE="tests/slice/region_array_smoke.su"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
REGION_OUT="$OUT_DIR/shu_zc3_region_array"
rm -f "$REGION_OUT"

echo "=== ZC-3: compile-time slice region + array→slice smoke ==="

if [ -z "$CHECK_SHU" ]; then
  if make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null; then
    if [ -x ./compiler/shu-c ]; then
      CHECK_SHU=./compiler/shu-c
    fi
  fi
fi

if [ -z "$CHECK_SHU" ] || ! "$CHECK_SHU" check tests/slice/main.su >/dev/null 2>&1; then
  echo "zc3 gate SKIP (no working shu-c/shu; rebuild native compiler or use Linux docker)"
  exit 0
fi

# M-3/M-5：slice 域 typeck（含 read_ptr_region_*）
chmod +x tests/run-typeck-region.sh
SHU="$CHECK_SHU" ./tests/run-typeck-region.sh
echo "zc3: region typeck OK"

# 数组→slice + .data/.length 字段
chmod +x tests/run-slice-field.sh
SHU="$CHECK_SHU" ./tests/run-slice-field.sh
echo "zc3: slice field OK"

# M-5：read_ptr_slice 运行时 + slice 字段 codegen
make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o
chmod +x tests/run-io-read-ptr-slice.sh
SHU="$CHECK_SHU" ./tests/run-io-read-ptr-slice.sh
echo "zc3: read_ptr_slice OK"

# region 内 array→slice 运行时（-o 链接须 shu-c/shu，shu_asm 缺 slice 字段 codegen）
LINK_SHU="$CHECK_SHU"
case "$(basename "$CHECK_SHU")" in
  shu_asm|shu)
    if [ -x ./compiler/shu-c ]; then
      LINK_SHU=./compiler/shu-c
    fi
    ;;
esac
if ! SHU="$LINK_SHU" "$LINK_SHU" "$REGION_SMOKE" -o "$REGION_OUT" 2>/tmp/shu_zc3_region_build.log; then
  echo "zc3 FAIL: compile $REGION_SMOKE" >&2
  tail -8 /tmp/shu_zc3_region_build.log 2>/dev/null || true
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
