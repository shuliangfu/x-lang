#!/usr/bin/env bash
# LANG-006：编译期常量求值 manifest + runnable 门禁（假权威诚实）。
#
# 用法：./tests/run-lang-const-eval-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/lang/;
# typeck.c/codegen.c retired — live CTFE = typeck.x / codegen.x.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_LANG_CONST_EVAL_DOC:-analysis/archive/lang/lang-const-eval-v1.md}"
MANIFEST="${XLANG_LANG_CONST_EVAL_MANIFEST:-tests/baseline/lang-const-eval.tsv}"
RUNNER="tests/lib/lang-const-eval.sh"
TYPECK_X="compiler/src/typeck/typeck.x"
CODEGEN_X="compiler/src/codegen/codegen.x"
MIN_LAYERS=6
MIN_CASES=10

# shellcheck source=tests/lib/lang-const-eval.sh
. tests/lib/lang-const-eval.sh

echo "=== LANG-006: const eval manifest (c retired) ==="
if [ -f analysis/lang-const-eval-v1.md ]; then
  echo "lang-const-eval gate FAIL: top-level DOC resurrected (live = archive/lang/)" >&2
  exit 1
fi
if [ -f compiler/src/typeck/typeck.c ]; then
  echo "lang-const-eval gate FAIL: typeck.c resurrected (live = typeck.x)" >&2
  exit 1
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  echo "lang-const-eval gate FAIL: codegen.c resurrected (live = codegen.x)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$RUNNER" tests/lang-const "$TYPECK_X" "$CODEGEN_X"; do
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
  # Hard gate: goldens must match live product CTFE (C5 array-len coerce + match subject).
  # Manifest + live typeck.x / codegen.x anchors remain required above.
  if lang_const_eval_main; then
    echo "lang-const-eval runnable OK"
  else
    echo "lang-const-eval gate FAIL runnable (CTFE residual)" >&2
    exit 1
  fi
else
  echo "lang-const-eval gate SKIP bench (no native xlang)" >&2
fi
echo "lang-const-eval gate OK"
