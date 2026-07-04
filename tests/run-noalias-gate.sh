#!/usr/bin/env bash
# MEM-A1：精细 noalias — 单指针可 restrict，多指针保守不标 restrict。
# 用法：./tests/run-noalias-gate.sh
# 环境：SHUX_NOALIAS_GATE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
FAIL="${SHUX_NOALIAS_GATE_FAIL:-0}"

check_emit_c() {
  local src="$1"
  local fn="$2"
  local expect_restrict="$3" # yes | no
  local gen
  gen="$(mktemp /tmp/shux_noalias_gate_XXXXXX.c)"
  if ! "$SHUX" -E "$src" >"$gen" 2>/tmp/shux_noalias_gate_build.log; then
    echo "noalias-gate FAIL: compile -E $src" >&2
    tail -8 /tmp/shux_noalias_gate_build.log 2>/dev/null || true
    rm -f "$gen"
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  local sig
  sig="$(grep -E "void ${fn}\\(" "$gen" | head -1 || true)"
  rm -f "$gen"
  if [ -z "$sig" ]; then
    echo "noalias-gate FAIL: missing function $fn in -E output for $src" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  if [ "$expect_restrict" = "yes" ]; then
    if ! echo "$sig" | grep -q 'restrict'; then
      echo "noalias-gate FAIL: expected restrict on $fn: $sig" >&2
      [ "$FAIL" = "1" ] && exit 1
      exit 0
    fi
  else
    if echo "$sig" | grep -q 'restrict'; then
      echo "noalias-gate FAIL: unexpected restrict on $fn: $sig" >&2
      [ "$FAIL" = "1" ] && exit 1
      exit 0
    fi
  fi
  echo "noalias-gate OK $fn restrict=$expect_restrict"
}

check_emit_c tests/typeck/noalias/one_ptr.x touch_one yes
check_emit_c tests/typeck/noalias/two_ptr.x touch_two no

echo "noalias-gate OK (MEM-A1 fine-grained restrict)"
