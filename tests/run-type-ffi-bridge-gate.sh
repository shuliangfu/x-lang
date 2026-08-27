#!/usr/bin/env bash
# TYPE-004: FFI type-bridge manifest + runnable gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native + prefer-c + soft auto-make + fossil
# top-level DOC / codegen.c / c_type_to_buf retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. DOC authority = archive/type. Report run=/obs=/skip=.
#
# Usage: ./tests/run-type-ffi-bridge-gate.sh
# wave honesty (2026-08-28): DOC → analysis/archive/type/;
# codegen.c/typeck.c retired → codegen.x/typeck.x; mapping = type_to_c_repr.
# PLATFORM: SHARED archaeology.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_TYPE_FFI_DOC:-analysis/archive/type/type-ffi-bridge-v1.md}"
MANIFEST="${XLANG_TYPE_FFI_MANIFEST:-tests/baseline/type-ffi-bridge.tsv}"
MAP="${XLANG_TYPE_FFI_MAP:-tests/baseline/type-ffi-bridge-map.tsv}"
MIN_LAYERS=6
MIN_CASES=4
MIN_MAPPINGS=12
PREFIX="${XLANG_TYPE_FFI_PREFIX:-xlang: [XLANG_TYPE_FFI_BRIDGE]}"

RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/type-ffi-bridge.sh
. tests/lib/type-ffi-bridge.sh

die() {
  echo "type-ffi-bridge gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== TYPE-004: FFI type bridge manifest ==="
if [ -f analysis/type-ffi-bridge-v1.md ]; then
  die "top-level DOC resurrected (live = archive/type/)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x)"
fi
if [ -f compiler/src/typeck/typeck.c ]; then
  die "typeck.c resurrected (live = typeck.x)"
fi

for f in "$DOC" "$MANIFEST" "$MAP" \
  compiler/src/codegen/codegen.x compiler/src/typeck/typeck.x \
  tests/ffi/putchar.x tests/ffi/main.x \
  analysis/archive/safe/safe-ffi-contract-v1.md; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in ffi bridge mapping interop runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
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
while IFS=$'\t' read -r xlang_type c_type extern_ok notes; do
  [ -z "${xlang_type:-}" ] && continue
  case "$xlang_type" in \#*|min_*) continue ;; esac
  MAP_N=$((MAP_N + 1))
  if ! grep -qF "$xlang_type" "$DOC" 2>/dev/null && [ "$xlang_type" != "ptr_star" ] && [ "$xlang_type" != "ptr_u8_bridge" ] && [ "$xlang_type" != "slice_arr" ]; then
    echo "type-ffi-bridge FAIL: doc missing mapping $xlang_type" >&2
    MISS=$((MISS + 1))
  fi
  if ! type_ffi_mapping_in_codegen "$xlang_type" "$c_type"; then
    echo "type-ffi-bridge FAIL: codegen missing mapping for $xlang_type -> $c_type" >&2
    MISS=$((MISS + 1))
  fi
done < "$MAP"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  die "layers=${LAYER_N} < min ${MIN_LAYERS}"
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASE_N} < min ${MIN_CASES}"
fi
if [ "$MAP_N" -lt "$MIN_MAPPINGS" ]; then
  die "mappings=${MAP_N} < min ${MIN_MAPPINGS}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "type-ffi-bridge manifest OK (layers=${LAYER_N} cases=${CASE_N} mappings=${MAP_N})"

chmod +x tests/run-type-ffi-bridge.sh
set +e
out=$(./tests/run-type-ffi-bridge.sh 2>&1)
ec=$?
set -e
printf '%s\n' "$out"
if printf '%s\n' "$out" | grep -qE 'status=ok.*run='; then
  RUN_OK=$(printf '%s\n' "$out" | sed -nE 's/.*run=([0-9]+).*/\1/p' | tail -1)
  OBS=$(printf '%s\n' "$out" | sed -nE 's/.*obs=([0-9]+).*/\1/p' | tail -1)
  SKIP=$(printf '%s\n' "$out" | sed -nE 's/.*skip=([0-9]+).*/\1/p' | tail -1)
  RUN_OK=${RUN_OK:-0}
  OBS=${OBS:-0}
  SKIP=${SKIP:-0}
fi
if [ "$ec" -ne 0 ]; then
  die "runnable residual (ec=$ec)"
fi

ok_report
echo "type-ffi-bridge gate OK"
