#!/usr/bin/env bash
# F-03 v2/v3：std.io 去 C 门禁（io_backend.sx + 无 io.c/io.o）。
#
# 用法：./tests/run-f03-std-io-gate.sh
# 环境：SHUX_F03_IO_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F03_IO_FAIL:-0}
DOC="analysis/phase-f-f03-v2-io.md"
BACKEND="std/io/io_backend.sx"
CORE="std/io/core.sx"

die() {
  echo "f03-io gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 v2/v3: std.io remove io.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2/v3' "$DOC" || die "doc missing F-03 v2/v3 marker"
[ ! -f std/io/io.c ] || die "io.c should be deleted"
[ -f std/io/io_sync.sx ] || die "missing io_sync.sx"
[ -f std/io/io_win32.sx ] || die "missing io_win32.sx"
[ -f std/io/io_read_ptr.sx ] || die "missing io_read_ptr.sx"
[ -f std/io/io_stubs.sx ] || die "missing io_stubs.sx"
[ -f "$BACKEND" ] || die "missing io_backend.sx"
grep -q 'function io_read(' "$BACKEND" || die "io_backend missing io_read"
grep -q 'import("std.io.io_backend")' "$CORE" || die "core.sx missing io_backend import"
if grep -q 'extern function io_read' "$CORE" 2>/dev/null; then
  die "core.sx still extern io_read"
fi
if grep -q '../std/io/io.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references ../std/io/io.o"
fi
if grep -q 'link_abi_asm_ld_push_obj.*std/io/io.o' compiler/src/runtime_link_abi.c 2>/dev/null; then
  die "runtime_link_abi.c still pushes std/io/io.o"
fi
grep -q 'shux_io_uring_is_available_c' std/io/io_stubs.sx || die "io_stubs missing uring probe"

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v2/v3: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

stdlib_cm_native_shu() {
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
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  export SHUX="$SHUX_BIN"
  if [ -f tests/run-io.sh ]; then
    echo "=== F-03 v2/v3: delegate run-io.sh (SHUX=$SHUX_BIN) ==="
    chmod +x tests/run-io.sh
    if ! tests/run-io.sh; then
      die "run-io sub-gate failed"
    fi
  fi
else
  echo "f03-io: SKIP runtime sub-gates (no native shux on this host)"
fi

echo "f03 std.io gate OK (F-03 v2/v3; io.c removed)"
