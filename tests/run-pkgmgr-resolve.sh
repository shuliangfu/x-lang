#!/usr/bin/env bash
# TOOL-007：pkgmgr resolve + demo 编译烟测。
#
# 用法：./tests/run-pkgmgr-resolve.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST=tests/fixtures/pkgmgr/shux.pkg.tsv
MAIN=tests/fixtures/pkgmgr/main.sx

chmod +x scripts/shux-deps-resolve.sh
./scripts/shux-deps-resolve.sh "$MANIFEST"

SHUX="${SHUX:-./compiler/shux}"
native_shu() {
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

if [ -n "$SHUX" ] && native_shu "$SHUX"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  EXE="/tmp/shux_pkgmgr_demo_$$"
  if ! "$SHUX" -L . "$MAIN" -o "$EXE" 2>&1; then
    echo "run-pkgmgr-resolve FAIL: compile $MAIN" >&2
    rm -f "$EXE"
    exit 1
  fi
  ec=0
  "$EXE" >/dev/null 2>&1 || ec=$?
  rm -f "$EXE"
  if [ "$ec" -ne 0 ]; then
    echo "run-pkgmgr-resolve FAIL: expected exit 0, got $ec" >&2
    exit 1
  fi
  echo "pkgmgr-resolve compile OK"
else
  echo "pkgmgr-resolve SKIP compile (no native shux)" >&2
fi

echo "pkgmgr-resolve OK"
