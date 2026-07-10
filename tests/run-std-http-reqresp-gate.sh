#!/usr/bin/env bash
# STD-HTTP-REQRESP：std.http Request/Response v0 + H2 Huffman/flow 门禁
#
# 用法：./tests/run-std-http-reqresp-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_REQRESP_DOC:-analysis/std-http-reqresp-v0.md}"
MANIFEST="${SHUX_STD_HTTP_REQRESP_TSV:-tests/baseline/std-http-reqresp.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
REQRESP_INC="compiler/seeds/http/http_reqresp.inc"
HUFF_INC="compiler/seeds/http/hpack_huffman.inc.c"
FLOW_INC="compiler/seeds/http/flow.inc.c"
LIB="tests/lib/std-http-reqresp.sh"
SMOKE_X="tests/http/request_response.x"
URL_OWNED_X="tests/http/request_url_owned.x"
OWNED_X="tests/http/request_owned.x"
RESP_OWNED_X="tests/http/response_owned.x"
MIN_APIS=24

# shellcheck source=tests/lib/std-http-reqresp.sh
. "$LIB"

echo "=== STD-HTTP-REQRESP: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$REQRESP_INC" "$HUFF_INC" "$FLOW_INC" "$SMOKE_X" "$URL_OWNED_X" "$OWNED_X" "$RESP_OWNED_X" std/http/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-http-reqresp gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STD-HTTP-REQRESP HttpRequest HttpResponse HttpBodyOwned HttpUrlOwned HttpRequestOwned HttpResponseOwned request_init execute execute_ctx response_body_owned response_owned_from_parse push_last_body_owned url_owned_from_slice request_owned_init execute_owned hpack_huffman build_window_update; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-reqresp gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

grep -qF "HttpRequest" std/http/README.md 2>/dev/null || {
  echo "std-http-reqresp gate FAIL: README missing HttpRequest" >&2
  exit 1
}

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http-reqresp gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-reqresp gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_reqresp_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_reqresp_emit_report "fail" 0 0
  echo "std-http-reqresp gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-http-reqresp manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/http/http.o

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

SMOKE_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-HTTP-REQRESP: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-http-reqresp gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -15 >&2 || true
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$URL_OWNED_X" >/dev/null 2>&1; then
    echo "std-http-reqresp gate FAIL: typeck $URL_OWNED_X" >&2
    "$SHUX_BIN" check -L . "$URL_OWNED_X" 2>&1 | tail -15 >&2 || true
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$OWNED_X" >/dev/null 2>&1; then
    echo "std-http-reqresp gate FAIL: typeck $OWNED_X" >&2
    "$SHUX_BIN" check -L . "$OWNED_X" 2>&1 | tail -15 >&2 || true
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$RESP_OWNED_X" >/dev/null 2>&1; then
    echo "std-http-reqresp gate FAIL: typeck $RESP_OWNED_X" >&2
    "$SHUX_BIN" check -L . "$RESP_OWNED_X" 2>&1 | tail -15 >&2 || true
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if std_http_reqresp_run_smoke "$SHUX_BIN" "$SMOKE_X" "reqresp"; then
    :
  else
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if std_http_reqresp_run_smoke "$SHUX_BIN" "$URL_OWNED_X" "url_owned"; then
    :
  else
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if std_http_reqresp_run_smoke "$SHUX_BIN" "$OWNED_X" "owned"; then
    :
  else
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  if std_http_reqresp_run_smoke "$SHUX_BIN" "$RESP_OWNED_X" "response_owned"; then
    SMOKE_OK=1
  else
    std_http_reqresp_emit_report "fail" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-http-reqresp gate SKIP smoke (no native shux)" >&2
fi

std_http_reqresp_emit_report "ok" "$SMOKE_OK" "$SKIP"
echo "std-http-reqresp gate OK"
