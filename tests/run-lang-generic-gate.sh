#!/usr/bin/env bash
# LANG-003：泛型/模板最小闭环 manifest 门禁
#
# 用法：./tests/run-lang-generic-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_LANG_GENERIC_DOC:-analysis/lang-generic-v1.md}"
MANIFEST="${SHU_LANG_GENERIC_MANIFEST:-tests/baseline/lang-generic.tsv}"
PROTOTYPE="${SHU_LANG_GENERIC_PROTOTYPE:-tests/baseline/lang-generic-prototype.tsv}"
MIN_LAYERS=6
MIN_CASES=3
MIN_CAPS=4

# shellcheck source=tests/lib/lang-generic.sh
. tests/lib/lang-generic.sh

echo "=== LANG-003: generic monomorph manifest ==="
for f in "$DOC" "$MANIFEST" "$PROTOTYPE" \
  tests/generic/main.su tests/generic/wrong_type_args.su \
  tests/multi-file-generic/main.su tests/multi-file-generic/foo.su \
  tests/bench/generic_id_i32.su \
  compiler/src/codegen/codegen.c compiler/src/typeck/typeck.c; do
  if [ ! -f "$f" ]; then
    echo "lang-generic gate FAIL: missing $f" >&2
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
    min_capabilities) MIN_CAPS="$c2" ;;
  esac
done < "$PROTOTYPE"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-generic FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-generic FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|bench)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-generic FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bench_file)
      if [ ! -f "$src" ]; then
        echo "lang-generic FAIL: missing bench $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing bench $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-generic FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-generic FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-generic FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

CAP_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$PROTOTYPE")
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "lang-generic gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-generic gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$CAP_N" -lt "$MIN_CAPS" ]; then
  echo "lang-generic gate FAIL: capabilities=${CAP_N} < min ${MIN_CAPS}" >&2
  exit 1
fi

for kw in generic monomorph prototype benchmark runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-generic gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "lang-generic gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-generic manifest OK (layers=${LAYER_N} cases=${CASE_N} caps=${CAP_N})"

chmod +x tests/run-lang-generic.sh tests/run-generic.sh tests/run-multi-file-generic.sh
./tests/run-lang-generic.sh

echo "lang-generic gate OK"
