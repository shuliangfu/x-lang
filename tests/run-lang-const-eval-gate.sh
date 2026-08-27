#!/usr/bin/env bash
# LANG-006: compile-time const eval manifest + runnable gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c retired. Prefer
# product xlang_asm via lib resolve; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die (CTFE face is live). DOC authority =
# archive/lang. Report run=/skip=.
#
# Usage: ./tests/run-lang-const-eval-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/lang/;
# typeck.c/codegen.c retired — live CTFE = typeck.x / codegen.x.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_LANG_CONST_EVAL_DOC:-analysis/archive/lang/lang-const-eval-v1.md}"
MANIFEST="${XLANG_LANG_CONST_EVAL_MANIFEST:-tests/baseline/lang-const-eval.tsv}"
RUNNER="tests/lib/lang-const-eval.sh"
TYPECK_X="compiler/src/typeck/typeck.x"
CODEGEN_X="compiler/src/codegen/codegen.x"
MIN_LAYERS=6
MIN_CASES=10
PREFIX="xlang: [XLANG_LANG_CONST_EVAL]"

RUN_OK=0
SKIP=0

# shellcheck source=tests/lib/lang-const-eval.sh
. tests/lib/lang-const-eval.sh

die() {
  echo "lang-const-eval gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== LANG-006: const eval manifest (c retired) ==="
if [ -f analysis/lang-const-eval-v1.md ]; then
  die "top-level DOC resurrected (live = archive/lang/)"
fi
if [ -f compiler/src/typeck/typeck.c ]; then
  die "typeck.c resurrected (live = typeck.x)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x)"
fi
for f in "$DOC" "$MANIFEST" "$RUNNER" tests/lang-const "$TYPECK_X" "$CODEGEN_X"; do
  if [ ! -e "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in runnable report C1-literal C6-codegen; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
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
  die "layers=${LAYER_N} < min_layers=${MIN_LAYERS}"
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASE_N} < min_cases=${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "lang-const-eval manifest OK (layers=${LAYER_N} cases=${CASE_N})"

chmod +x "$RUNNER" 2>/dev/null || true

echo "=== LANG-006: runnable report ==="
# Hard gate: goldens must match live product CTFE. Refuse soft SKIP→OK.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
set +e
lang_const_eval_main
ec=$?
set -e
if [ "$ec" -eq 2 ]; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
fi
if [ "$ec" -ne 0 ]; then
  die "runnable (CTFE residual)"
fi
RUN_OK=1
echo "lang-const-eval runnable OK"

ok_report
echo "lang-const-eval gate OK"
