#!/usr/bin/env bash
# MEM-C1 AL-01/02：default_alloc 块内 scope / 块外 heap 注入烟测。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
FAIL="${SHUX_ALLOC_INJECT_GATE_FAIL:-0}"
SRC="tests/mem/default_alloc.sx"
OUT="/tmp/shux_default_alloc_$$"

if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_alloc_inject_run.log 2>&1; then
  echo "alloc-inject-gate FAIL: build $SRC" >&2
  tail -8 /tmp/shux_alloc_inject_run.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "alloc-inject-gate FAIL: run exit=$rc want 0" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_alloc_inject_run.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "alloc-inject-gate FAIL: missing kept generated C" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q '__shux_scope_al_' "$gen"; then
  echo "alloc-inject-gate FAIL: missing __shux_scope_al_ in with_arena path" >&2
  rm -f "$gen"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -qE '\.kind = 0.*arena' "$gen"; then
  echo "alloc-inject-gate FAIL: missing heap default_alloc emit (kind=0)" >&2
  rm -f "$gen"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rm -f "$gen"
echo "alloc-inject-gate OK (AL-01/02 default_alloc scope/heap)"
