#!/usr/bin/env bash
# MEM-AUTO-004 / MEM-C1：with_arena 作用域 Arena codegen 烟测。
# 用法：./tests/run-scope-allocator-gate.sh
# 环境：SHUX_SCOPE_ALLOC_GATE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
FAIL="${SHUX_SCOPE_ALLOC_GATE_FAIL:-0}"
SRC="tests/mem/with_arena_smoke.sx"
OUT="/tmp/shux_with_arena_smoke_$$"

check_emit() {
  local gen
  gen="$(mktemp /tmp/shux_scope_alloc_gate_XXXXXX.c)"
  if ! "$SHUX" -E "$SRC" >"$gen" 2>/tmp/shux_scope_alloc_gate_build.log; then
    echo "scope-allocator-gate FAIL: compile -E $SRC" >&2
    tail -8 /tmp/shux_scope_alloc_gate_build.log 2>/dev/null || true
    rm -f "$gen"
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  if ! grep -q 'heap_arena_init_c((struct std_heap_Arena64 \*)&__shux_wa_' "$gen"; then
    echo "scope-allocator-gate FAIL: missing with_arena init emit" >&2
    rm -f "$gen"
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  if ! grep -q 'heap_arena64_deinit_c((struct std_heap_Arena64 \*)&__shux_wa_' "$gen"; then
    echo "scope-allocator-gate FAIL: missing with_arena deinit emit" >&2
    rm -f "$gen"
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  rm -f "$gen"
  echo "scope-allocator-gate OK with_arena emit"
}

check_emit

if ! "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_scope_alloc_run.log 2>&1; then
  echo "scope-allocator-gate FAIL: build $SRC" >&2
  tail -8 /tmp/shux_scope_alloc_run.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "scope-allocator-gate FAIL: run exit=$rc want 0" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
echo "scope-allocator-gate OK run exit=0"

# MEM-C1：scope_alloc 展开（SHUX_KEEP_C 保留生成 C 供 emit 断言；带 import 时 -E 会 DCE 掉入口 main）
SCOPE_SRC="tests/mem/scope_alloc.sx"
SCOPE_OUT="/tmp/shux_scope_alloc_$$"
if ! SHUX_KEEP_C=1 "$SHUX" "$SCOPE_SRC" -o "$SCOPE_OUT" >/tmp/shux_scope_alloc_scope_run.log 2>&1; then
  echo "scope-allocator-gate FAIL: build $SCOPE_SRC" >&2
  tail -8 /tmp/shux_scope_alloc_scope_run.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
gen2="$(grep -oE '/tmp/shux_[A-Za-z0-9]+\.c' /tmp/shux_scope_alloc_scope_run.log | tail -1)"
if [ -z "$gen2" ] || [ ! -f "$gen2" ] || ! grep -q '__shux_scope_al_' "$gen2"; then
  echo "scope-allocator-gate FAIL: missing __shux_scope_al_ emit" >&2
  [ -n "$gen2" ] && rm -f "$gen2"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rm -f "$gen2"
echo "scope-allocator-gate OK scope_alloc emit"
rc=0
"$SCOPE_OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "scope-allocator-gate FAIL: scope_alloc run exit=$rc want 0" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
echo "scope-allocator-gate OK scope_alloc run exit=0"

echo "scope-allocator-gate OK (MEM-C1 with_arena v1)"
