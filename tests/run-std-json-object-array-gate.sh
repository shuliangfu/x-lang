#!/usr/bin/env bash
# STD-034：std.json object/array 解析门禁
#
# 用法：./tests/run-std-json-object-array-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_JOA_DOC:-analysis/std-json-object-array-v1.md}"
MANIFEST="${SHUX_STD_JOA_TSV:-tests/baseline/std-json-object-array.tsv}"
JSON_SX="std/json/mod.sx"
JSON_IMPL="std/json/json.sx"
JSON_SX="std/json/json.sx"
LIB="tests/lib/std-json-object-array.sh"
OA_SX="tests/json/object_array_parse.sx"

# shellcheck source=tests/lib/std-json-object-array.sh
. tests/lib/std-json-object-array.sh

# shellcheck source=tests/lib/std-json.sh
. tests/lib/std-json.sh

echo "=== STD-034: json object/array manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$JSON_SX" "$JSON_SX" "$OA_SX"; do
  if [ ! -f "$f" ]; then
    echo "std-json-object-array gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in JsonCursor skip_value cursor_object_next 大对象 ZC; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-json-object-array gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_joa_symbols_ok "$JSON_SX" "$JSON_IMPL" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_joa_emit_report "fail" 0 1
  echo "std-json-object-array gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-json-object-array manifest OK"

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

OA_OK=0
SKIP=1
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-034: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/json/json.o 2>/dev/null || make -C compiler ../std/json/json.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$OA_SX" >/dev/null 2>&1; then
    echo "std-json-object-array gate FAIL: typeck $OA_SX" >&2
    "$SHUX_BIN" check -L . "$OA_SX" 2>&1 | tail -10 >&2 || true
    std_joa_emit_report "fail" 0 0
    exit 1
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/json/json.o
  if std_json_run_smoke "$SHUX_BIN" "$OA_SX" "object_array"; then
    OA_OK=1
  else
    std_joa_emit_report "fail" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-json-object-array gate SKIP smoke (no native shux-c)" >&2
fi

std_joa_emit_report "ok" "$OA_OK" "$SKIP"
echo "std-json-object-array gate OK"
