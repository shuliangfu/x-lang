#!/usr/bin/env bash
# B-02：#[cfg] 与 `-target` triple 联动烟测（cross OS/arch 剪枝）。
# 用法：./tests/run-cfg-target-triple-gate.sh
# 环境：SHUX_CFG_TARGET_TRIPLE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_CFG_TARGET_TRIPLE_FAIL:-0}
X="tests/lexer/cfg_attribute_skip.x"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "cfg-target-triple-gate: SKIP (no shux/shux-c)"
  exit 0
fi

OS="$(uname -s)"
ARCH="$(uname -m 2>/dev/null || echo unknown)"
case "$OS" in
  Darwin|Linux) ;;
  *)
    echo "cfg-target-triple-gate: SKIP (unsupported host $OS)"
    exit 0
    ;;
esac

run_expect() {
  local triple="$1"
  local expect="$2"
  local out="/tmp/shux_cfg_triple.$$.out"
  rm -f "$out" 2>/dev/null || true
  if ! "$SHUX" -target "$triple" -o "$out" "$X" 2>/tmp/shux_cfg_triple.log; then
    echo "cfg-target-triple-gate FAIL: compile with -target $triple" >&2
    tail -n 8 /tmp/shux_cfg_triple.log 2>/dev/null || true
    rm -f "$out" 2>/dev/null || true
    return 1
  fi
  if [ ! -x "$out" ]; then
    echo "cfg-target-triple-gate FAIL: no executable for -target $triple" >&2
    rm -f "$out" 2>/dev/null || true
    return 1
  fi
  local rc=0
  "$out" || rc=$?
  rm -f "$out" 2>/dev/null || true
  if [ "$rc" -ne "$expect" ]; then
    echo "cfg-target-triple-gate FAIL: -target $triple expected exit $expect, got $rc" >&2
    return 1
  fi
  echo "cfg-target-triple-gate OK (-target $triple -> exit $expect)"
  return 0
}

# cross 到 Linux：OS=7 + arch 由 triple 决定
if ! run_expect "x86_64-unknown-linux-gnu" 29; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! run_expect "aarch64-unknown-linux-gnu" 18; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# cross 到 macOS（host 为 Linux 时更有区分度；Darwin host 亦须一致）
if ! run_expect "aarch64-apple-darwin" 16; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! run_expect "x86_64-apple-darwin" 27; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# cross 到 FreeBSD
if ! run_expect "x86_64-unknown-freebsd14.0" 31; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! run_expect "aarch64-unknown-freebsd14.0" 20; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "cfg-target-triple-gate OK (#[cfg] follows -target triple on $OS/$ARCH)"
exit 0
