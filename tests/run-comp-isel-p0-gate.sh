#!/usr/bin/env bash
# COMP-014：isel P0 回归波次 runnable 门禁
#
# 1) comp-isel-p0-v1.md + comp-isel-p0-wave.tsv + comp-isel.tsv P0 行
# 2) 有 native shu/shu_asm 时逐条执行 P0 hook
#
# 用法：./tests/run-comp-isel-p0-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP014_DOC:-analysis/comp-isel-p0-v1.md}"
WAVE="${SHU_COMP014_WAVE_TSV:-tests/baseline/comp-isel-p0-wave.tsv}"
MANIFEST="${SHU_COMP014_MANIFEST:-tests/baseline/comp-isel.tsv}"
LIB="tests/lib/comp-isel-p0.sh"
MIN_P0=4

# shellcheck source=tests/lib/comp-isel-p0.sh
. tests/lib/comp-isel-p0.sh
# shellcheck source=tests/lib/comp-isel.sh
. tests/lib/comp-isel.sh

echo "=== COMP-014: isel P0 wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$LIB" \
  analysis/comp-isel-v1.md tests/run-comp-isel-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-isel-p0 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_p0_cases) MIN_P0="$c2" ;;
  esac
done < "$MANIFEST"

for kw in P0 回归矩阵 comp-isel-p0 min_p0_cases; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-isel-p0 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

P0_CASE_N=0
P0_HOOK_N=0
MISS=0
echo "=== COMP-014: P0 cases + hooks ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "P0" ] || continue
  case "$kind" in
    case)
      P0_CASE_N=$((P0_CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-isel-p0 FAIL: missing $src ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-isel-p0 FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-isel-p0 OK case $item_id -> $src"
      fi
      ;;
    hook_script)
      P0_HOOK_N=$((P0_HOOK_N + 1))
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-isel-p0 FAIL: missing tests/$anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-isel-p0 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-isel-p0 OK hook $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$P0_CASE_N" -lt "$MIN_P0" ]; then
  echo "comp-isel-p0 gate FAIL: p0_cases=${P0_CASE_N} < min ${MIN_P0}" >&2
  exit 1
fi
if [ "$P0_HOOK_N" -lt "$MIN_P0" ]; then
  echo "comp-isel-p0 gate FAIL: p0_hooks=${P0_HOOK_N} < min ${MIN_P0}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "comp-isel-p0 gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-isel-p0 manifest OK (p0_cases=${P0_CASE_N} p0_hooks=${P0_HOOK_N})"

SHU_ASM="${SHU:-./compiler/shu_asm}"
P0_OK=0
P0_SKIP=0
SKIP=1

if comp_isel_native_shu "$SHU_ASM"; then
  echo "=== COMP-014: run P0 hooks (SHU=$SHU_ASM) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  while IFS=$'\t' read -r item_id kind anchor _src tier _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    [ "${tier:-}" = "P0" ] || continue
    [ "$kind" = "hook_script" ] || continue
    if comp_isel_p0_run_hook "$SHU_ASM" "$anchor"; then
      P0_OK=$((P0_OK + 1))
      echo "comp-isel-p0 runnable OK $anchor"
    else
      comp_isel_p0_emit_report "fail" "$P0_OK" 0 0
      exit 1
    fi
  done < "$MANIFEST"
  SKIP=0
else
  echo "comp-isel-p0 gate SKIP runnable (no native shu_asm)" >&2
  P0_SKIP=$P0_HOOK_N
fi

if [ "$SKIP" -eq 0 ] && [ "$P0_OK" -lt "$MIN_P0" ]; then
  echo "comp-isel-p0 gate FAIL: p0_ok=${P0_OK} < min ${MIN_P0}" >&2
  exit 1
fi

comp_isel_p0_emit_report "ok" "$P0_OK" "$P0_SKIP" "$SKIP"
echo "comp-isel-p0 gate OK"
