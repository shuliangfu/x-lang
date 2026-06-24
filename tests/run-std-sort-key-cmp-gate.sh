#!/usr/bin/env bash
# STD-150：std.sort 复杂 key 比较器策略门禁
#
# 用法：./tests/run-std-sort-key-cmp-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-sort-key-cmp-v1.md"
MANIFEST="tests/baseline/std-sort-key-cmp-manifest.tsv"
VECTORS="tests/baseline/std-sort-key-cmp.tsv"
MOD_SX="std/sort/mod.sx"
SORT_SX="std/sort/sort.sx"
LIB="tests/lib/std-sort-key-cmp.sh"
SMOKE_SX="tests/std-sort/key_stable.sx"
SMOKE_C="tests/std-sort/key_cmp_ok.c"

# shellcheck source=tests/lib/std-sort-key-cmp.sh
. "$LIB"

echo "=== STD-150: sort key cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$SORT_SX" "$SMOKE_SX" "$SMOKE_C" std/sort/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sort-key-cmp gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-150 sort_stable_by_key cmp_key_i32_fn KeyTag; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sort-key-cmp gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "sort_stable_by_key" std/sort/README.md 2>/dev/null; then
  echo "std-sort-key-cmp gate FAIL: README missing sort_stable_by_key" >&2
  exit 1
fi

[ ! -f std/sort/sort.c ] || { echo "std-sort-key-cmp gate FAIL: sort.c should be deleted" >&2; exit 1; }

sym_miss="$(std_sort_key_cmp_symbols_ok "$MOD_SX" "$SORT_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sort_key_cmp_emit_report "fail" 0 0 0
  exit 1
fi

if ! std_sort_key_cmp_vectors_ok "$VECTORS" 3; then
  std_sort_key_cmp_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sort-key-cmp registry OK"

if [ "${SHUX_STD_SORT_KEY_CMP_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sort_key_cmp_emit_report "ok" 0 0 1
  echo "std-sort-key-cmp gate OK (manifest only)"
  exit 0
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  ensure_std_c_o ../std/sort/sort.o
fi
SORT_O="$(cd compiler && pwd)/../std/sort/sort.o"

C_OK=0
if [ -f "$SORT_O" ] && strings "$SORT_O" 2>/dev/null | grep -q 'sort_key_cmp_smoke'; then
  if std_sort_key_cmp_run_c_smoke "$SORT_SX"; then
    C_OK=1
  else
    std_sort_key_cmp_emit_report "fail" 0 0 0
    exit 1
  fi
else
  echo "std-sort-key-cmp SKIP c smoke (sort.o missing .sx symbols; need shux-c)" >&2
fi

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-sort-key-cmp gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_sort_key_cmp_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_sort_key_cmp_run_sx_smoke "$SHUX_BIN" "$SMOKE_SX" "$SORT_O"; then
    SX_OK=1
  else
    std_sort_key_cmp_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_sort_key_cmp_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-sort-key-cmp gate OK"
