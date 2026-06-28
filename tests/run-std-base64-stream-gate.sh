#!/usr/bin/env bash
# STD-109：std.base64 流式编解码门禁
#
# 用法：./tests/run-std-base64-stream-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD109_DOC:-analysis/std-base64-stream-v1.md}"
MANIFEST="${SHUX_STD109_TSV:-tests/baseline/std-base64-stream.tsv}"
VECTORS="${SHUX_STD109_VECTORS:-tests/baseline/std-base64-stream-vectors.tsv}"
MOD_SX="std/base64/mod.sx"
B64_SX="${SHUX_STD_BASE64_IMPL:-std/base64/base64.sx}"
LIB="tests/lib/std-base64-stream.sh"
SMOKE_SX="tests/std-base64/stream.sx"
SMOKE_C="tests/std-base64/stream_smoke_ok.c"
MIN_APIS=5

# shellcheck source=tests/lib/std-base64-stream.sh
. "$LIB"

echo "=== STD-109: base64 stream manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$B64_SX" "$SMOKE_SX" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-base64-stream gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-109 enc_update dec_update aGVsbG8; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-base64-stream gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'aGVsbG8=' "$VECTORS" 2>/dev/null; then
  echo "std-base64-stream gate FAIL: vectors missing hello_enc gold" >&2
  exit 1
fi

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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-base64-stream FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-base64-stream gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_base64_stream_symbols_ok "$MOD_SX" "$B64_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_base64_stream_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-base64-stream manifest OK"

C_OK=0
SX_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/base64/base64.o
  if std_base64_stream_run_c_smoke "$B64_SX"; then
    C_OK=1
  else
    std_base64_stream_emit_report "fail" 0 0 0
    exit 1
  fi
else
  echo "std-base64-stream gate SKIP c/su smoke (no shux-c; manifest OK)" >&2
  SKIP=1
fi

SHUX_BIN=""
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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-109: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-base64-stream gate FAIL: typeck $SMOKE_SX" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_base64_stream_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_base64_stream_run_sx_smoke "$SHUX_BIN" "$SMOKE_SX" "b64"; then
    SX_OK=1
  else
    std_base64_stream_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_base64_stream_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-base64-stream gate OK"
