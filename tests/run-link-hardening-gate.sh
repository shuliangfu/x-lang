#!/usr/bin/env bash
# P1-7：链接器硬化烟测 — Linux release 可执行文件须 PIE（Type: DYN）且 GNU_STACK 不可执行。
#
# 用法：./tests/run-link-hardening-gate.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="tests/baseline/link-hardening.tsv"
SRC="tests/link_hardening_smoke.x"

echo "=== P1-7: link hardening manifest ==="
for f in "$MANIFEST" "$SRC"; do
  if [ ! -f "$f" ]; then
    echo "link-hardening gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qF "shux_append_linux_link_harden" compiler/src/runtime_link_abi.inc 2>/dev/null; then
  echo "link-hardening gate FAIL: runtime_link_abi.inc missing shux_append_linux_link_harden" >&2
  exit 1
fi
if grep -qE '^static void shux_append_linux_link_harden\(' compiler/src/runtime.inc 2>/dev/null; then
  echo "link-hardening gate FAIL: runtime.c still defines shux_append_linux_link_harden (expected runtime_link_abi.inc)" >&2
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

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX_BIN="${SHUX:-${RUN_SHUX:-./compiler/shux-c}}"
if [ ! -x "$SHUX_BIN" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX_BIN=./compiler/shux-c
fi

EXE="/tmp/shux_link_harden_$$"
if ! "$SHUX_BIN" -L . "$SRC" -o "$EXE" >/dev/null 2>&1; then
  echo "link-hardening gate FAIL: compile $SRC" >&2
  rm -f "$EXE"
  exit 1
fi

# PIE：ELF Type 须为 DYN（Position-Independent Executable）
ELF_TYPE="$(readelf -h "$EXE" 2>/dev/null | awk '/Type:/ {print $2}')"
if [ "$ELF_TYPE" != "DYN" ]; then
  echo "link-hardening gate FAIL: expected Type DYN (PIE), got ${ELF_TYPE:-?}" >&2
  rm -f "$EXE"
  exit 1
fi

# NX：GNU_STACK 段 Flg 不得含 E（不可执行栈）
STACK_FLG="$(readelf -l -W "$EXE" 2>/dev/null | awk '/GNU_STACK/ {getline; print $NF; exit}')"
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
