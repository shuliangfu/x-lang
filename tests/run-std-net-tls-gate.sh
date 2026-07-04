#!/usr/bin/env bash
# STD-030/083：std.net TLS 门禁（桩 + OpenSSL 握手）
#
# 用法：./tests/run-std-net-tls-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_NET_TLS_DOC:-analysis/std-net-tls-v1.md}"
MANIFEST="${SHUX_STD_NET_TLS_TSV:-tests/baseline/std-net-tls.tsv}"
NET_X="std/net/mod.x"
TLS_STUB_X="std/net/tls_stub.x"
LIB="tests/lib/std-net-tls.sh"
STUB_X="tests/net/tls_stub.x"
RUNTIME_X="tests/net/tls_runtime_link_smoke.x"
SMOKE_C="tests/net/tls_openssl_smoke_ok.c"
MBEDTLS_SMOKE_C="tests/net/tls_mbedtls_smoke_ok.c"
MIN_APIS=7

# shellcheck source=tests/lib/std-net-tls.sh
. "$LIB"

echo "=== STD-030: net TLS prereq manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$NET_X" "$TLS_STUB_X" "$STUB_X" "$RUNTIME_X" "$SMOKE_C" "$MBEDTLS_SMOKE_C" std/net/tls_openssl.x std/net/tls_mbedtls.x std/net/tls_stub.x; do
  if [ ! -f "$f" ]; then
    echo "std-net-tls gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-030 STD-083 STD-085 OpenSSL tls_connect_client tls_read TLS_NOT_IMPL runtime_link; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-net-tls gate FAIL: doc missing '$kw'" >&2
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
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-net-tls gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-net-tls gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_net_tls_symbols_ok "$NET_X" "$TLS_STUB_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_net_tls_emit_report "fail" 0 0 1 0 0
  echo "std-net-tls gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-net-tls manifest OK"

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

STUB_OK=0
TYPECK_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-030: typeck + stub smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  make -C compiler net-o-stub >/dev/null 2>&1 || ensure_std_c_o ../std/net/net.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$STUB_X" >/dev/null 2>&1; then
    echo "std-net-tls gate FAIL: typeck $STUB_X" >&2
    "$SHUX_BIN" check -L . "$STUB_X" 2>&1 | tail -10 >&2 || true
    std_net_tls_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  TYPECK_OK=1
  exe="/tmp/shux_std_net_tls_stub_$$"
  set +e
  link_log=$(SHUX_NET_TLS=stub "$SHUX_BIN" -L . "$STUB_X" -o "$exe" 2>&1)
  link_ec=$?
  set -e
  if [ "$link_ec" -eq 0 ]; then
    set +e
    "$exe" >/dev/null 2>&1
    run_ec=$?
    set -e
    rm -f "$exe"
    if [ "$run_ec" -eq 0 ]; then
      STUB_OK=1
      SKIP=0
    else
      echo "std-net-tls gate FAIL: run exit=$run_ec" >&2
      std_net_tls_emit_report "fail" 0 "$TYPECK_OK" 0 0 0
      exit 1
    fi
  elif echo "$link_log" | grep -qF "library 'zstd' not found"; then
    echo "std-net-tls gate SKIP runnable link (typeck passed)" >&2
    STUB_OK=0
    SKIP=1
  else
    echo "std-net-tls gate FAIL: link $STUB_X" >&2
    echo "$link_log" | tail -8 >&2 || true
    std_net_tls_emit_report "fail" 0 "$TYPECK_OK" 0
    exit 1
  fi
else
  echo "std-net-tls gate SKIP smoke (no native shux-c)" >&2
fi

OPENSSL_OK=0
if std_net_tls_probe_openssl; then
  echo "=== STD-083: OpenSSL TLS handshake smoke ==="
  TLS_PORT="${SHUX_TLS_SMOKE_PORT:-9876}"
  TLS_CERT="/tmp/shux_tls_cert_$$.pem"
  TLS_KEY="/tmp/shux_tls_key_$$.pem"
  TLS_PID="/tmp/shux_tls_spid_$$"
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY" -out "$TLS_CERT" -days 1 -nodes \
    -subj "/CN=localhost" >/dev/null 2>&1; then
    if std_net_tls_build_openssl_o && std_net_tls_start_s_server "$TLS_PID" "$TLS_PORT" "$TLS_CERT" "$TLS_KEY"; then
      make -C compiler ../std/net/net.o >/dev/null 2>&1 || true
      export SHUX_TLS_SMOKE_PORT="$TLS_PORT"
      if std_net_tls_run_openssl_c_smoke; then OPENSSL_OK=1; fi
      std_net_tls_stop_s_server "$TLS_PID"
    fi
    rm -f "$TLS_CERT" "$TLS_KEY"
  fi
  std_net_tls_restore_stub_o
else
  echo "std-net-tls gate SKIP openssl smoke (no libssl)" >&2
fi

MBEDTLS_OK=0
if std_net_tls_probe_mbedtls; then
  echo "=== STD-085: mbedTLS TLS handshake smoke ==="
  TLS_PORT_MB="${SHUX_TLS_SMOKE_PORT_MB:-9877}"
  TLS_CERT_MB="/tmp/shux_tls_cert_mb_$$.pem"
  TLS_KEY_MB="/tmp/shux_tls_key_mb_$$.pem"
  TLS_PID_MB="/tmp/shux_tls_spid_mb_$$"
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY_MB" -out "$TLS_CERT_MB" -days 1 -nodes \
    -subj "/CN=localhost" >/dev/null 2>&1; then
    if std_net_tls_build_mbedtls_o && std_net_tls_start_s_server "$TLS_PID_MB" "$TLS_PORT_MB" "$TLS_CERT_MB" "$TLS_KEY_MB"; then
      make -C compiler ../std/net/net.o >/dev/null 2>&1 || true
      export SHUX_TLS_SMOKE_PORT="$TLS_PORT_MB"
      if std_net_tls_run_mbedtls_c_smoke; then MBEDTLS_OK=1; fi
      std_net_tls_stop_s_server "$TLS_PID_MB"
    fi
    rm -f "$TLS_CERT_MB" "$TLS_KEY_MB"
  fi
  std_net_tls_restore_stub_o
else
  echo "std-net-tls gate SKIP mbedtls smoke (no libmbedtls)" >&2
fi

RUNTIME_LINK_OK=0
if [ -n "$SHUX_BIN" ] && std_net_tls_probe_openssl; then
  echo "=== STD-083: runtime auto TLS link (shux-c + net-o-openssl) ==="
  if std_net_tls_build_openssl_o && std_net_tls_runtime_link_smoke "$SHUX_BIN"; then
    RUNTIME_LINK_OK=1
  fi
  std_net_tls_restore_stub_o
else
  echo "std-net-tls gate SKIP runtime link smoke (no shux or libssl)" >&2
fi

std_net_tls_emit_report "ok" "$STUB_OK" "$TYPECK_OK" "$SKIP" "$OPENSSL_OK" "$MBEDTLS_OK" "$RUNTIME_LINK_OK"
echo "std-net-tls gate OK"
