#!/usr/bin/env bash
# MEM-D3：SROA/ASP CTFE 链 — 多步 i32 折叠 + 块内别名 fold。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"

check_ctfe() {
  local src="$1"
  local out="/tmp/shux_ctfe_$(basename "$src" .x)"
  local log="/tmp/shux_ctfe_$(basename "$src" .x).log"
  rm -f "$out"
  if ! SHUX_KEEP_C=1 "$SHUX" "$src" -o "$out" >"$log" 2>&1; then
    echo "sroa-ctfe-gate FAIL: compile $src" >&2
    tail -8 "$log" 2>/dev/null || true
    exit 1
  fi
  local gen
  gen="$(grep 'kept generated C:' "$log" | sed 's/.*: //' | tail -1)"
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' "$log" | tail -1)"
  fi
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    echo "sroa-ctfe-gate FAIL: missing kept C for $src" >&2
    exit 1
  fi
  local main_body
  main_body=$(sed -n '/int main/,/^}/p' "$gen")
  if ! echo "$main_body" | grep -qE 'return 7;'; then
    echo "sroa-ctfe-gate FAIL: $src main missing folded return 7" >&2
    echo "$main_body" | tail -8 >&2
    exit 1
  fi
  if echo "$main_body" | grep -qE 'sum_pair\('; then
    echo "sroa-ctfe-gate FAIL: $src main still has sum_pair call" >&2
    exit 1
  fi
  local rc=0
  "$out" >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "7" ]; then
    echo "sroa-ctfe-gate FAIL: $src exit=$rc want 7" >&2
    exit 1
  fi
  echo "sroa-ctfe-gate OK $src"
}

check_ctfe tests/mem/sroa_ctfe_chain.x
check_ctfe tests/mem/sroa_ctfe_chain_alias.x

echo "sroa-ctfe-gate OK (MEM-D3 CTFE chain fold)"
