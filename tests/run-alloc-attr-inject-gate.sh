#!/usr/bin/env bash
# MEM-C1 #[alloc]：省略 al 首参时 codegen 注入 default_alloc() / scope。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/alloc_attr_inject.sx"
OUT="/tmp/shux_alloc_attr_inject_$$"
rm -f "$OUT"
if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_alloc_attr_run.log 2>&1; then
  echo "alloc-attr-inject-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_alloc_attr_run.log 2>/dev/null || true
  exit 1
fi
gen="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_alloc_attr_run.log | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "alloc-attr-inject-gate FAIL: SHUX_KEEP_C did not retain generated C" >&2
  exit 1
fi
if ! grep -qE 'proxy_bump|bump_alloc|std_heap_bump_alloc' "$gen"; then
  echo "alloc-attr-inject-gate FAIL: proxy_bump/bump_alloc call not found" >&2
  rm -f "$gen"
  exit 1
fi
if ! grep -qE 'kind = 0|__shux_scope_al_' "$gen"; then
  echo "alloc-attr-inject-gate FAIL: injected allocator not found in generated C" >&2
  rm -f "$gen"
  exit 1
fi
rm -f "$gen"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "alloc-attr-inject-gate FAIL: run exit=$rc want 0" >&2
  exit 1
fi
echo "alloc-attr-inject-gate OK (#[alloc] implicit al injection)"
