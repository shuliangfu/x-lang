#!/usr/bin/env bash
# STD-013/014：std.map / std.vec 常用类型扩展门禁
#
# 用法：./tests/run-std-map-vec-extend-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_MVE_DOC:-analysis/std-map-vec-extend-v1.md}"
MANIFEST="${SHU_STD_MVE_TSV:-tests/baseline/std-map-vec-extend.tsv}"
MAP_SU="std/map/mod.su"
VEC_SU="std/vec/mod.su"
HEAP_SU="std/heap/mod.su"
LIB="tests/lib/std-map-vec-extend.sh"

# shellcheck source=tests/lib/std-map-vec-extend.sh
. tests/lib/std-map-vec-extend.sh

echo "=== STD-013/014: map/vec extend manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MAP_SU" "$VEC_SU" "$HEAP_SU" tests/map/boundary.su tests/vec/append_roundtrip.su; do
  if [ ! -f "$f" ]; then
    echo "std-map-vec-extend gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in Map_u64_i32 Map_str_i32 Vec_u64 Vec_f64 map_str_key_cap; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-map-vec-extend gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_mve_symbols_ok "$MAP_SU" "$VEC_SU" "$HEAP_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_mve_emit_report "fail" 0 0 0
  echo "std-map-vec-extend gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-map-vec-extend manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

MAP_OK=0
VEC_OK=0
SKIP=1
resolve_shu() {
  local cand
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}
if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-013/014: typeck (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if "$SHU_BIN" check -L . tests/map/boundary.su >/dev/null 2>&1; then
    MAP_OK=1
  else
    echo "std-map-vec-extend gate FAIL: map boundary typeck" >&2
    "$SHU_BIN" check -L . tests/map/boundary.su 2>&1 | tail -8 >&2 || true
    std_mve_emit_report "fail" 0 0 0
    exit 1
  fi
  if "$SHU_BIN" check -L . tests/vec/append_roundtrip.su >/dev/null 2>&1; then
    VEC_OK=1
  else
    echo "std-map-vec-extend gate FAIL: vec append typeck" >&2
    "$SHU_BIN" check -L . tests/vec/append_roundtrip.su 2>&1 | tail -8 >&2 || true
    std_mve_emit_report "fail" "$MAP_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-map-vec-extend gate SKIP typeck (no native shu-c)" >&2
fi

std_mve_emit_report "ok" "$MAP_OK" "$VEC_OK" "$SKIP"
echo "std-map-vec-extend gate OK"
