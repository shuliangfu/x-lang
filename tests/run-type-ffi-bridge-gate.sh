#!/usr/bin/env bash
# TYPE-004：FFI 类型桥接 manifest 门禁
#
# 用法：./tests/run-type-ffi-bridge-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TYPE_FFI_DOC:-analysis/type-ffi-bridge-v1.md}"
MANIFEST="${SHUX_TYPE_FFI_MANIFEST:-tests/baseline/type-ffi-bridge.tsv}"
MAP="${SHUX_TYPE_FFI_MAP:-tests/baseline/type-ffi-bridge-map.tsv}"
MIN_LAYERS=6
MIN_CASES=4
MIN_MAPPINGS=12

# shellcheck source=tests/lib/type-ffi-bridge.sh
. tests/lib/type-ffi-bridge.sh

echo "=== TYPE-004: FFI type bridge manifest ==="
for f in "$DOC" "$MANIFEST" "$MAP" \
  compiler/src/codegen/codegen.c compiler/src/typeck/typeck.c \
  tests/ffi/putchar.x tests/ffi/main.x \
  analysis/safe-ffi-contract-v1.md; do
  if [ ! -f "$f" ]; then
    echo "type-ffi-bridge gate FAIL: missing $f" >&2
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
    min_mappings) MIN_MAPPINGS="$c2" ;;
  esac
done < "$MAP"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-ffi-bridge FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "type-ffi-bridge FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "type-ffi-bridge FAIL: missing cross_ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-ffi-bridge FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "type-ffi-bridge FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-ffi-bridge FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

MAP_N=0
while IFS=$'\t' read -r shu_type c_type extern_ok notes; do
  [ -z "${shu_type:-}" ] && continue
  case "$shu_type" in \#*|min_*) continue ;; esac
  MAP_N=$((MAP_N + 1))
  if ! grep -qF "$shu_type" "$DOC" 2>/dev/null && [ "$shu_type" != "ptr_star" ] && [ "$shu_type" != "ptr_u8_bridge" ] && [ "$shu_type" != "slice_arr" ]; then
    echo "type-ffi-bridge FAIL: doc missing mapping $shu_type" >&2
    MISS=$((MISS + 1))
  fi
  if ! type_ffi_mapping_in_codegen "$shu_type" "$c_type"; then
    echo "type-ffi-bridge FAIL: codegen missing mapping for $shu_type -> $c_type" >&2
    MISS=$((MISS + 1))
  fi
done < "$MAP"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "type-ffi-bridge gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "type-ffi-bridge gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MAP_N" -lt "$MIN_MAPPINGS" ]; then
  echo "type-ffi-bridge gate FAIL: mappings=${MAP_N} < min ${MIN_MAPPINGS}" >&2
  exit 1
fi

for kw in ffi bridge mapping interop runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "type-ffi-bridge gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "type-ffi-bridge gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "type-ffi-bridge manifest OK (layers=${LAYER_N} cases=${CASE_N} mappings=${MAP_N})"

chmod +x tests/run-type-ffi-bridge.sh
./tests/run-type-ffi-bridge.sh

echo "type-ffi-bridge gate OK"
