#!/usr/bin/env bash
# MEM-D2：with_arena 内 arena ptr 工厂栈 promotion — 无 bump alloc，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/arena_stack_promote.sx"
OUT="/tmp/shux_arena_stack_promote"
rm -f "$OUT"
# 带 import 时 -E 可能 DCE 掉 main；用 SHUX_KEEP_C 保留完整 TU（同 scope_allocator gate）
if ! SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" >/tmp/shux_asp_run.log 2>&1; then
  echo "arena-stack-promote-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_asp_run.log 2>/dev/null || true
  exit 1
fi
GEN="$(grep 'kept generated C:' /tmp/shux_asp_run.log | sed 's/.*: //' | tail -1)"
if [ -z "$GEN" ] || [ ! -f "$GEN" ]; then
  echo "arena-stack-promote-gate FAIL: missing kept generated C" >&2
  exit 1
fi
WA_BODY=$(sed -n '/__shux_scope_al_/,/heap_arena64_deinit_c/p' "$GEN" | head -20)
if ! echo "$WA_BODY" | grep -qE '__shux_asp_p'; then
  echo "arena-stack-promote-gate FAIL: missing ASP stack storage __shux_asp_p in with_arena body" >&2
  exit 1
fi
if echo "$WA_BODY" | grep -qE 'heap_arena64_alloc_c|allocator_alloc\('; then
  echo "arena-stack-promote-gate FAIL: bump alloc still present in promoted with_arena body" >&2
  exit 1
fi
if echo "$WA_BODY" | grep -qE 'make_pair_arena\('; then
  echo "arena-stack-promote-gate FAIL: factory call still present in with_arena body" >&2
  exit 1
fi
if ! echo "$WA_BODY" | grep -qE 'return 7;'; then
  echo "arena-stack-promote-gate FAIL: missing folded return 7 in with_arena body" >&2
  exit 1
fi
if SHUX_NO_ASP=1 SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "${OUT}.scalar" >/tmp/shux_asp_scalar.log 2>&1; then
  GEN2="$(grep 'kept generated C:' /tmp/shux_asp_scalar.log | sed 's/.*: //' | tail -1)"
  if [ -n "$GEN2" ] && [ -f "$GEN2" ] && ! grep -qE 'heap_arena64_alloc_c|allocator_alloc\(' "$GEN2"; then
    echo "arena-stack-promote-gate WARN: SHUX_NO_ASP=1 did not preserve bump alloc" >&2
  fi
fi
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "7" ]; then
  echo "arena-stack-promote-gate FAIL: exit=$rc want 7 (3+4)" >&2
  exit 1
fi
echo "arena-stack-promote-gate OK (MEM-D2 arena ptr factory stack promotion)"

echo "=== MEM-D2.2: alias promote arena_stack_promote_alias ==="
ALIAS_SRC="tests/mem/arena_stack_promote_alias.sx"
ALIAS_OUT="/tmp/shux_arena_stack_promote_alias"
if ! SHUX_KEEP_C=1 "$SHUX" "$ALIAS_SRC" -o "$ALIAS_OUT" >/tmp/shux_asp_alias.log 2>&1; then
  echo "asp-alias-gate FAIL: compile/run failed" >&2
  exit 1
fi
GEN_A="$(grep 'kept generated C:' /tmp/shux_asp_alias.log | sed 's/.*: //' | tail -1)"
WA_ALIAS=$(sed -n '/__shux_scope_al_/,/heap_arena64_deinit_c/p' "$GEN_A" | head -20)
if [ -z "$GEN_A" ] || ! echo "$WA_ALIAS" | grep -q '__shux_asp_p'; then
  echo "asp-alias-gate FAIL: alias flow should still ASP promote" >&2
  exit 1
fi
if ! echo "$WA_ALIAS" | grep -qE 'return 7;'; then
  echo "asp-alias-gate FAIL: alias flow should fold to return 7" >&2
  exit 1
fi
rc=0
"$ALIAS_OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "7" ]; then
  echo "asp-alias-gate FAIL: exit=$rc want 7" >&2
  exit 1
fi
echo "asp-alias-gate OK (block-local alias still promotes)"

echo "=== MEM-D2.2: escape skip arena_stack_promote_escape ==="
ESC_SRC="tests/mem/arena_stack_promote_escape.sx"
ESC_OUT="/tmp/shux_arena_stack_promote_escape"
if ! SHUX_KEEP_C=1 "$SHUX" "$ESC_SRC" -o "$ESC_OUT" >/tmp/shux_asp_escape.log 2>&1; then
  echo "asp-escape-gate FAIL: compile/run failed" >&2
  exit 1
fi
GEN_E="$(grep 'kept generated C:' /tmp/shux_asp_escape.log | sed 's/.*: //' | tail -1)"
WA_ESC=$(sed -n '/__shux_scope_al_/,/heap_arena64_deinit_c/p' "$GEN_E" | head -25)
if echo "$WA_ESC" | grep -q '__shux_asp_p'; then
  echo "asp-escape-gate FAIL: outer assign must skip ASP (__shux_asp_p present)" >&2
  exit 1
fi
if ! echo "$WA_ESC" | grep -qE 'make_pair_arena\(|allocator_alloc\('; then
  echo "asp-escape-gate FAIL: escape path should keep factory/bump alloc in with_arena" >&2
  exit 1
fi
echo "asp-escape-gate OK (outer escape skips stack promotion)"
