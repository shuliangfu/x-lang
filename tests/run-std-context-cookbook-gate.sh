#!/usr/bin/env bash
# STD-156：std.context Cookbook 扩展示例门禁
#
# 用法：./tests/run-std-context-cookbook-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-context-cookbook-v1.md"
MANIFEST="tests/baseline/std-context-cookbook.tsv"
MOD_SX="std/context/mod.sx"
LIB="tests/lib/std-context-cookbook.sh"
RECIPE="examples/cookbook/context_cancel_deadline.sx"
MIN_REC=1

# shellcheck source=tests/lib/std-context-cookbook.sh
. "$LIB"

echo "=== STD-156: context cookbook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$RECIPE" \
  analysis/doc-cookbook-expand-v1.md; do
  if [ ! -f "$f" ]; then
    echo "std-context-cookbook gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-156 CTX-01 with_timeout is_cancelled; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-context-cookbook gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "$RECIPE" analysis/doc-cookbook-expand-v1.md 2>/dev/null; then
  echo "std-context-cookbook gate FAIL: cookbook doc missing recipe ref" >&2
  exit 1
fi

REC_N=0
sym_miss="$(std_context_cookbook_symbols_ok "$MOD_SX" "$MANIFEST" || true)"
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "recipe" ] && REC_N=$((REC_N + 1))
done < "$MANIFEST"

if [ "$REC_N" -lt "$MIN_REC" ]; then
  echo "std-context-cookbook gate FAIL: recipes=$REC_N < min $MIN_REC" >&2
  exit 1
fi
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_context_cookbook_emit_report "fail" 0 0
  exit 1
fi
echo "std-context-cookbook manifest OK"

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-156: cookbook typeck (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$RECIPE" >/dev/null 2>&1; then
    echo "std-context-cookbook gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$RECIPE" 2>&1 | tail -10 >&2 || true
    std_context_cookbook_emit_report "fail" 0 0
    exit 1
  fi
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if std_context_cookbook_run_smoke "$RUN_SHUX" "$RECIPE"; then
    SX_OK=1
  else
    std_context_cookbook_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-context-cookbook gate SKIP runnable (no shux)" >&2
  SKIP=1
fi

std_context_cookbook_emit_report "ok" "$SX_OK" "$SKIP"
echo "std-context-cookbook gate OK"
