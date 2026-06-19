#!/usr/bin/env bash
# STD-040：std.encoding hex/Base64 与 string 互操作门禁
#
# 用法：./tests/run-std-encoding-hex-base64-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_ENCODING_HEX_B64_DOC:-analysis/std-encoding-hex-base64-v1.md}"
MANIFEST="${SHUX_STD_ENCODING_HEX_B64_TSV:-tests/baseline/std-encoding-hex-base64.tsv}"
MOD_SU="std/encoding/mod.sx"
ENCODING_C="std/encoding/encoding.c"
LIB="tests/lib/std-encoding-hex-base64.sh"
SMOKE_SU="tests/encoding/hex_base64_string.sx"
MAIN_SU="tests/encoding/main.sx"
MIN_APIS=8

# shellcheck source=tests/lib/std-encoding-hex-base64.sh
. "$LIB"

echo "=== STD-040: encoding hex/base64 string manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$ENCODING_C" "$SMOKE_SU" "$MAIN_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-encoding-hex-b64 gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-040 std.base64 encode_hex_string decode_base64_string deadbeef; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-encoding-hex-b64 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
        echo "std-encoding-hex-b64 gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-encoding-hex-b64 gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-encoding-hex-b64 gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_encoding_hex_b64_symbols_ok "$MOD_SU" "$ENCODING_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_encoding_hex_b64_emit_report "fail" 0 0 0 0
  echo "std-encoding-hex-b64 gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-encoding-hex-b64 manifest OK"

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

HEX_OK=0
B64_OK=0
MAIN_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-040: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/encoding/encoding.o
  ensure_std_c_o ../std/base64/base64.o
  ensure_std_c_o ../std/string/string.o
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-encoding-hex-b64 gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -12 >&2 || true
    std_encoding_hex_b64_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_encoding_hex_b64_run_smoke "$SHUX_BIN" "$SMOKE_SU" "hex_b64"; then
    HEX_OK=1
    B64_OK=1
  else
    std_encoding_hex_b64_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_encoding_hex_b64_run_smoke "$SHUX_BIN" "$MAIN_SU" "main"; then
    MAIN_OK=1
  else
    std_encoding_hex_b64_emit_report "fail" "$HEX_OK" "$B64_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-encoding-hex-b64 gate SKIP smoke (no native shux)" >&2
fi

std_encoding_hex_b64_emit_report "ok" "$HEX_OK" "$B64_OK" "$MAIN_OK" "$SKIP"
echo "std-encoding-hex-b64 gate OK"
