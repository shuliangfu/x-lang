#!/usr/bin/env bash
# P1-7：链接器硬化烟测 — Linux release 可执行文件须 PIE（Type: DYN）且 GNU_STACK 不可执行。
#
# 用法：./tests/run-link-hardening-gate.sh
# wave honesty (2026-08-24 #5): monofile seeds/runtime.from_x.c retired wave321;
# harden authority = runtime_link_abi.from_x.c（refuse monofile resurrect）。
# PLATFORM: SHARED archaeology / LINUX smoke.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

MANIFEST="tests/baseline/link-hardening.tsv"
SRC="tests/link_hardening_smoke.x"
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"

echo "=== P1-7: link hardening manifest ==="
for f in "$MANIFEST" "$SRC" "$LINK_ABI"; do
  if [ ! -f "$f" ]; then
    echo "link-hardening gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f compiler/seeds/runtime.from_x.c ]; then
  echo "link-hardening gate FAIL: seeds/runtime.from_x.c resurrected (harden live = runtime_link_abi)" >&2
  exit 1
fi
if ! grep -qF "xlang_append_linux_link_harden" "$LINK_ABI" 2>/dev/null; then
  echo "link-hardening gate FAIL: runtime_link_abi.inc missing xlang_append_linux_link_harden" >&2
  exit 1
fi
echo "link-hardening manifest OK"

if [ "$(uname -s)" != "Linux" ]; then
  echo "link-hardening gate SKIP (non-Linux host)"
  exit 0
fi
if ! command -v readelf >/dev/null 2>&1; then
  echo "link-hardening gate SKIP (no readelf)"
  exit 0
fi

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
XLANG_BIN="${XLANG:-${RUN_XLANG:-./compiler/xlang-c}}"
if [ ! -x "$XLANG_BIN" ]; then
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c
  XLANG_BIN=./compiler/xlang-c
fi

EXE="/tmp/xlang_link_harden_$$"
if ! "$XLANG_BIN" -L . "$SRC" -o "$EXE" >/dev/null 2>&1; then
  echo "link-hardening gate FAIL: compile $SRC" >&2
  rm -f "$EXE"
  exit 1
fi

# PIE：ELF Type 须为 DYN（Position-Independent Executable）
# 强制 C locale：zh_CN 等环境下 readelf 输出「类型:」而非 Type:，awk 会空匹配成假红。
ELF_TYPE="$(LC_ALL=C readelf -h "$EXE" 2>/dev/null | awk '/Type:/ {print $2}')"
if [ "$ELF_TYPE" != "DYN" ]; then
  echo "link-hardening gate FAIL: expected Type DYN (PIE), got ${ELF_TYPE:-?}" >&2
  rm -f "$EXE"
  exit 1
fi

# NX：GNU_STACK 段 Flg 不得含 E（不可执行栈）
STACK_FLG="$(LC_ALL=C readelf -l -W "$EXE" 2>/dev/null | awk '/GNU_STACK/ {getline; print $NF; exit}')"
case "$STACK_FLG" in
  *E*)
    echo "link-hardening gate FAIL: GNU_STACK executable (Flg=$STACK_FLG)" >&2
    rm -f "$EXE"
    exit 1
    ;;
esac

EC=0
"$EXE" >/dev/null 2>&1 || EC=$?
rm -f "$EXE"
if [ "$EC" -ne 42 ]; then
  echo "link-hardening gate FAIL: expected exit 42, got $EC" >&2
  exit 1
fi

echo "link-hardening gate OK (Type=DYN stack=${STACK_FLG:-RW})"
