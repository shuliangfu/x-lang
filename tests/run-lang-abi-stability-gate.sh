#!/usr/bin/env bash
# LANG-005：ABI 稳定承诺 manifest 门禁
#
# 用法：./tests/run-lang-abi-stability-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_LANG_ABI_DOC:-analysis/lang-abi-stability-v1.md}"
MANIFEST="${SHUX_LANG_ABI_MANIFEST:-tests/baseline/lang-abi-stability.tsv}"
LEVELS="${SHUX_LANG_ABI_LEVELS:-tests/baseline/lang-abi-compat-levels.tsv}"
MIN_LAYERS=6
MIN_CASES=2
MIN_LEVELS=6

# shellcheck source=tests/lib/lang-abi-stability.sh
. tests/lib/lang-abi-stability.sh

echo "=== LANG-005: ABI stability manifest ==="
for f in "$DOC" "$MANIFEST" "$LEVELS" \
  tests/abi/layout_abi.c tests/abi/f32_call_xmm_smoke.sx \
  compiler/docs/F32_XMM_ABI.md compiler/include/shux_std_abi/fs_abi.h \
  tests/baseline/safe-ffi-contract.tsv; do
  if [ ! -f "$f" ]; then
    echo "lang-abi-stability gate FAIL: missing $f" >&2
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

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_levels) MIN_LEVELS="$c2" ;;
  esac
done < "$LEVELS"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-abi-stability FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-abi-stability FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-abi-stability FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-abi-stability FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    docs)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-abi-stability FAIL: missing doc $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-abi-stability FAIL: $path missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-abi-stability FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-abi-stability FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-abi-stability FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-abi-stability FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-abi-stability FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-abi-stability FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

LEVEL_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$LEVELS")
LEVEL_HIT=0
while IFS=$'\t' read -r level_id surface stability bump_policy anchor; do
  [ -z "${level_id:-}" ] && continue
  case "$level_id" in \#*|min_*) continue ;; esac
  LEVEL_HIT=$((LEVEL_HIT + 1))
  if ! grep -qF "$level_id" "$DOC" 2>/dev/null; then
    echo "lang-abi-stability FAIL: doc missing level $level_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qF "$stability" "$DOC" 2>/dev/null; then
    echo "lang-abi-stability FAIL: doc missing stability $stability for $level_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$LEVELS"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "lang-abi-stability gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-abi-stability gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$LEVEL_HIT" -lt "$MIN_LEVELS" ]; then
  echo "lang-abi-stability gate FAIL: levels=${LEVEL_HIT} < min ${MIN_LEVELS}" >&2
  exit 1
fi

for kw in abi stability compatibility release runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-abi-stability gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "lang-abi-stability gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-abi-stability manifest OK (layers=${LAYER_N} cases=${CASE_N} levels=${LEVEL_HIT})"

chmod +x tests/run-lang-abi-stability.sh tests/run-abi-layout.sh
./tests/run-lang-abi-stability.sh

echo "lang-abi-stability gate OK"
