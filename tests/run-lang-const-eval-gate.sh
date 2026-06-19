#!/usr/bin/env bash
# LANG-006：编译期常量求值 manifest + runnable 门禁
#
# 用法：./tests/run-lang-const-eval-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_LANG_CONST_EVAL_DOC:-analysis/lang-const-eval-v1.md}"
MANIFEST="${SHUX_LANG_CONST_EVAL_MANIFEST:-tests/baseline/lang-const-eval.tsv}"
RUNNER="tests/lib/lang-const-eval.sh"
MIN_LAYERS=6
MIN_CASES=10

# shellcheck source=tests/lib/lang-const-eval.sh
. tests/lib/lang-const-eval.sh

echo "=== LANG-006: const eval manifest ==="
for f in "$DOC" "$MANIFEST" "$RUNNER" tests/lang-const; do
  if [ ! -e "$f" ]; then
    echo "lang-const-eval gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report C1-literal C6-codegen; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-const-eval gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-const-eval FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-const-eval FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-const-eval FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-const-eval FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-const-eval FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      if [ ! -f "$src" ]; then
        echo "lang-const-eval FAIL: missing script $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "lang-const-eval gate FAIL: layers=${LAYER_N} < min_layers=${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-const-eval gate FAIL: cases=${CASE_N} < min_cases=${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "lang-const-eval gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-const-eval manifest OK (layers=${LAYER_N} cases=${CASE_N})"

chmod +x "$RUNNER" 2>/dev/null || true

if lang_const_eval_resolve_shu >/dev/null 2>&1; then
  echo "=== LANG-006: runnable report ==="
  if lang_const_eval_main; then
    echo "lang-const-eval gate OK"
  else
    echo "lang-const-eval gate FAIL: runner" >&2
    exit 1
  fi
else
  echo "lang-const-eval gate SKIP bench (no native shux)" >&2
  echo "lang-const-eval gate OK"
fi
