#!/usr/bin/env bash
# STD-HTTP-HTTPS：std.http HTTPS 客户端门禁
#
# 用法：./tests/run-std-http-https-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-http-https-v1.md"
MANIFEST="tests/baseline/std-http-https.tsv"
MOD_SU="std/http/mod.sx"
HTTP_C="std/http/http.c"
LIB="tests/lib/std-http-https.sh"
SMOKE_SU="tests/http/https_smoke.sx"
SMOKE_C="tests/http/https_smoke_ok.c"
MIN_APIS=2

# shellcheck source=tests/lib/std-http-https.sh
. "$LIB"
# shellcheck source=tests/lib/std-net-tls.sh
. tests/lib/std-net-tls.sh

echo "=== STD-HTTP-HTTPS: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$HTTP_C" "$SMOKE_SU" "$SMOKE_C" \
  std/http/http_tls_bridge.inc.c std/http/README.md; do
  [ -f "$f" ] || { echo "std-http-https gate FAIL: missing $f" >&2; exit 1; }
done

for kw in STD-HTTP-HTTPS https_is_available http_err_tls_not_impl https:// TLS net_tls; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || {
    echo "std-http-https gate FAIL: doc missing '$kw'" >&2
    exit 1
  }
done

grep -qF "https://" std/http/README.md 2>/dev/null || {
  echo "std-http-https gate FAIL: README missing https" >&2
  exit 1
}

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || {
  echo "std-http-https gate FAIL: api count $API_N < $MIN_APIS" >&2
  exit 1
}

sym_miss="$(std_http_https_symbols_ok "$MOD_SU" "$HTTP_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || {
  std_http_https_emit_report fail 0 0 0 0
  echo "std-http-https gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
}
echo "std-http-https manifest OK"

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/http/http.o
HTTP_O="$(cd compiler && pwd)/../std/http/http.o"

C_OK=0
OPENSSL_OK=0
if cc -std=c11 -O1 -o /tmp/shux_http_https_stub_$$ tests/http/https_smoke_ok.c "$HTTP_O" 2>/dev/null; then
  /tmp/shux_http_https_stub_$$ >/dev/null 2>&1 && C_OK=1
  rm -f /tmp/shux_http_https_stub_$$
fi
[ "$C_OK" -eq 1 ] || { std_http_https_emit_report fail 0 0 0 0; exit 1; }

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi
if [ -n "$SHUX_BIN" ]; then
  "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null
  std_http_https_run_sx_smoke "$SHUX_BIN" "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

if std_net_tls_probe_openssl; then
  TLS_PORT="${SHUX_HTTPS_SMOKE_PORT:-9888}"
  TLS_CERT="/tmp/shux_https_cert_$$.pem"
  TLS_KEY="/tmp/shux_https_key_$$.pem"
  TLS_PID="/tmp/shux_https_spid_$$"
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY" -out "$TLS_CERT" -days 1 -nodes \
    -subj "/CN=localhost" 2>/dev/null; then
    if std_net_tls_build_openssl_o && std_net_tls_start_s_server "$TLS_PID" "$TLS_PORT" "$TLS_CERT" "$TLS_KEY"; then
      NET_O="$(cd compiler && pwd)/../std/net/net.o"
      export SHUX_HTTPS_SMOKE_PORT="$TLS_PORT"
      ldflags="$(std_net_tls_openssl_ldflags)"
      if std_http_https_run_c_smoke "$HTTP_O" "$NET_O" "$ldflags"; then
        OPENSSL_OK=1
      fi
      std_net_tls_stop_s_server "$TLS_PID"
    fi
  fi
  rm -f "$TLS_CERT" "$TLS_KEY"
  std_net_tls_restore_stub_o 2>/dev/null || true
fi

std_http_https_emit_report ok "$C_OK" "$SU_OK" "$SKIP" "$OPENSSL_OK"
echo "std-http-https gate OK"
