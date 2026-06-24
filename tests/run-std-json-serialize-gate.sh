#!/usr/bin/env bash
# STD-035：std.json object/array 序列化门禁
#
# 用法：./tests/run-std-json-serialize-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_JSZ_DOC:-analysis/std-json-serialize-v1.md}"
MANIFEST="${SHUX_STD_JSZ_TSV:-tests/baseline/std-json-serialize.tsv}"
JSON_SX="std/json/mod.sx"
JSON_IMPL="std/json/json.sx"
JSON_SX="std/json/json.sx"
LIB="tests/lib/std-json-serialize.sh"
RT_SX="tests/json/object_array_roundtrip.sx"

# shellcheck source=tests/lib/std-json-serialize.sh
. tests/lib/std-json-serialize.sh
# shellcheck source=tests/lib/std-json.sh
. tests/lib/std-json.sh

echo "=== STD-035: json serialize manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$JSON_SX" "$JSON_SX" "$RT_SX"; do
  if [ ! -f "$f" ]; then
    echo "std-json-serialize gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in append_object append_array round-trip object_array_roundtrip; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-json-serialize gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_jsz_symbols_ok "$JSON_SX" "$JSON_IMPL" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_jsz_emit_report "fail" 0 1
  echo "std-json-serialize gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-json-serialize manifest OK"

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

RT_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-035: typeck + round-trip smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/json/json.o 2>/dev/null || make -C compiler ../std/json/json.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$RT_SX" >/dev/null 2>&1; then
    echo "std-json-serialize gate FAIL: typeck $RT_SX" >&2
    "$SHUX_BIN" check -L . "$RT_SX" 2>&1 | tail -10 >&2 || true
    std_jsz_emit_report "fail" 0 0
    exit 1
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/json/json.o
  if std_json_run_smoke "$SHUX_BIN" "$RT_SX" "object_array_roundtrip"; then
    RT_OK=1
  else
    std_jsz_emit_report "fail" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-json-serialize gate SKIP smoke (no native shux-c)" >&2
fi

std_jsz_emit_report "ok" "$RT_OK" "$SKIP"
echo "std-json-serialize gate OK"
