#!/usr/bin/env bash
# STD-112：std.heap Allocator trait 门禁
#
# 用法：./tests/run-std-heap-allocator-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD112_DOC:-analysis/std-heap-allocator-v1.md}"
MANIFEST="${SHUX_STD112_TSV:-tests/baseline/std-heap-allocator.tsv}"
HEAP_SU="std/heap/mod.sx"
VEC_SU="std/vec/mod.sx"
LIB="tests/lib/std-heap-allocator.sh"
SMOKE_SU="tests/heap/allocator_vec.sx"
MIN_APIS=8

# shellcheck source=tests/lib/std-heap-allocator.sh
. "$LIB"

echo "=== STD-112: heap Allocator manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$HEAP_SU" "$VEC_SU" "$SMOKE_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-heap-allocator gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-112 allocator_heap allocator_from_arena vec_u8_with_allocator; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-heap-allocator gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-heap-allocator FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-heap-allocator gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_heap_alloc_symbols_ok "$HEAP_SU" "$VEC_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_heap_alloc_emit_report "fail" 0 0
  exit 1
fi
echo "std-heap-allocator manifest OK"

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-112: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-heap-allocator gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_heap_alloc_emit_report "fail" 0 0
    exit 1
  fi
  if std_heap_alloc_run_smoke "$SHUX_BIN" "$SMOKE_SU" "vec"; then
    SU_OK=1
  else
    std_heap_alloc_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_heap_alloc_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-heap-allocator gate OK"
