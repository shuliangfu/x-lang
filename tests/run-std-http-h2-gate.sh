#!/usr/bin/env bash
# STD-HTTP-H2：std.http HTTP/2 v0 线格式门禁
#
# 用法：./tests/run-std-http-h2-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_H2_DOC:-analysis/std-http-h2-v0.md}"
MANIFEST="${SHUX_STD_HTTP_H2_TSV:-tests/baseline/std-http-h2.tsv}"
MOD_SU="std/http/mod.sx"
HTTP_C="std/http/http.c"
H2_INC="std/http/http2.inc.c"
HPACK_INC="std/http/http2_hpack.inc.c"
HPACK_DYN_INC="std/http/http2_hpack_dyn.inc.c"
CLIENT_INC="std/http/http2_client.inc.c"
NETWORK_INC="std/http/http2_network.inc.c"
FLOW_INC="std/http/http2_flow.inc.c"
FLOW_STATE_INC="std/http/http2_flow_state.inc.c"
FLOW_RECV_INC="std/http/http2_flow_recv.inc.c"
PUSH_H2C_INC="std/http/http2_push_h2c.inc.c"
PUSH_FETCH_INC="std/http/http2_push_fetch.inc.c"
STREAM_REG_INC="std/http/http2_stream_registry.inc.c"
SETTINGS_INC="std/http/http2_settings.inc.c"
MS_CLIENT_INC="std/http/http2_multistream_client.inc.c"
CONN_REUSE_INC="std/http/http2_conn_reuse.inc.c"
CONN_POOL_INC="std/http/http2_conn_pool.inc.c"
GLOBAL_POOL_INC="std/http/http2_global_pool.inc.c"
SERVER_INC="std/http/http2_server.inc.c"
SERVER_PUSH_INC="std/http/http2_server_push.inc.c"
LIB="tests/lib/std-http-h2.sh"
WIRE_SU="tests/http/http2_wire.sx"
CLIENT_SU="tests/http/http2_client.sx"
DYN_SU="tests/http/http2_hpack_dyn.sx"
NETWORK_SU="tests/http/http2_network.sx"
FLOW_STATE_SU="tests/http/http2_flow_state.sx"
RECV_PUSH_SU="tests/http/http2_flow_recv_push_h2c.sx"
H2C_CLIENT_SU="tests/http/h2c_client.sx"
STREAM_REG_SU="tests/http/http2_stream_registry.sx"
MS_CLIENT_SU="tests/http/http2_multistream_client.sx"
CONN_REUSE_SU="tests/http/http2_conn_reuse.sx"
CONN_POOL_SU="tests/http/http2_conn_pool.sx"
GLOBAL_POOL_SU="tests/http/http2_global_pool.sx"
SERVER_SU="tests/http/http2_server.sx"
SERVER_MS_SU="tests/http/http2_server_multistream.sx"
SERVER_PUSH_SU="tests/http/http2_server_push.sx"
SERVER_PUSH_TLS_SU="tests/http/http2_server_push_tls.sx"
SERVER_MS_PUSH_SU="tests/http/http2_server_multistream_push.sx"
SERVER_PUSH_SETTINGS_SU="tests/http/http2_server_push_settings.sx"
SERVER_SETTINGS_FULL_SU="tests/http/http2_server_settings_full.sx"
SERVER_HPACK_DYN_SU="tests/http/http2_server_hpack_dyn.sx"
SERVER_MAX_FRAME_SU="tests/http/http2_server_max_frame.sx"
CONN_GOAWAY_SU="tests/http/http2_conn_goaway.sx"
CONN_PING_SU="tests/http/http2_conn_ping.sx"
CONN_POOL_GOAWAY_SU="tests/http/http2_conn_pool_goaway.sx"
HTTP2_COMPLETE_SU="tests/http/http2_http2_complete.sx"
HPACK_SERVER_DYN_INC="std/http/http2_hpack_server_dyn.inc.c"
FRAME_CAPPED_INC="std/http/http2_frame_capped.inc.c"
GOAWAY_INC="std/http/http2_goaway.inc.c"
PING_INC="std/http/http2_ping.inc.c"
RST_INC="std/http/http2_rst_stream.inc.c"
MIN_APIS=171

# shellcheck source=tests/lib/std-http-h2.sh
. "$LIB"

echo "=== STD-HTTP-H2: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$HTTP_C" "$H2_INC" "$HPACK_INC" "$HPACK_DYN_INC" "$HPACK_SERVER_DYN_INC" "$FRAME_CAPPED_INC" "$GOAWAY_INC" "$PING_INC" "$RST_INC" "$CLIENT_INC" "$NETWORK_INC" "$FLOW_INC" "$FLOW_STATE_INC" "$FLOW_RECV_INC" "$PUSH_H2C_INC" "$PUSH_FETCH_INC" "$STREAM_REG_INC" "$SETTINGS_INC" "$MS_CLIENT_INC" "$CONN_REUSE_INC" "$CONN_POOL_INC" "$GLOBAL_POOL_INC" "$SERVER_INC" "$SERVER_PUSH_INC" "$WIRE_SU" "$CLIENT_SU" "$DYN_SU" "$NETWORK_SU" "$FLOW_STATE_SU" "$RECV_PUSH_SU" "$H2C_CLIENT_SU" "$STREAM_REG_SU" "$MS_CLIENT_SU" "$CONN_REUSE_SU" "$CONN_POOL_SU" "$GLOBAL_POOL_SU" "$SERVER_SU" "$SERVER_MS_SU" "$SERVER_PUSH_SU" "$SERVER_PUSH_TLS_SU" "$SERVER_MS_PUSH_SU" "$SERVER_PUSH_SETTINGS_SU" "$SERVER_SETTINGS_FULL_SU" "$SERVER_HPACK_DYN_SU" "$SERVER_MAX_FRAME_SU" "$CONN_GOAWAY_SU" "$CONN_PING_SU" "$CONN_POOL_GOAWAY_SU" "$HTTP2_COMPLETE_SU" std/http/README.md std/net/mod.sx; do
  if [ ! -f "$f" ]; then
    echo "std-http-h2 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STD-HTTP-H2 http2_is_connection_preface http2_hpack_encode_get_request http2_hpack_encode_request h2_get h2_request client_request_h2 h2c_get client_request_h2c http2_stream_registry_init http2_err_h2c_scheme http2_multistream_client_init http2_build_client_settings http2_build_client_settings_ex http2_build_server_settings http2_setting_enable_push http2_setting_header_table_size http2_setting_max_frame_size http2_peer_settings_enable_push http2_peer_settings_header_table_size http2_peer_settings_max_frame_size http2_err_max_streams http2_conn_init http2_conn_handshake http2_conn_handshake_with_enable_push http2_err_conn_not_ready h2_pool_get h2c_pool_get http2_conn_pool_create_h2 http2_err_pool_scheme http2_global_pool_create http2_global_pool_get http2_err_global_pool_full serve_h2c_one serve_h2_one serve_h2_multi_one serve_h2c_multi_one http2_server_multistream_smoke serve_h2c_one_with_push serve_h2_one_with_push http2_server_push_smoke http2_server_push_settings_smoke http2_server_settings_full_smoke http2_hpack_server_dyn_create http2_server_hpack_dyn_smoke http2_frame_payload_limit http2_server_max_frame_smoke http2_build_goaway http2_conn_shutdown_graceful http2_conn_read_goaway http2_conn_goaway_smoke serve_h2c_one_with_goaway http2_err_goaway http2_build_ping http2_conn_ping http2_conn_ping_smoke serve_h2c_one_ping_echo http2_err_ping http2_conn_goaway_seen http2_conn_is_pool_reusable http2_conn_pool_goaway_smoke http2_build_rst_stream http2_conn_reset_stream http2_http2_complete_smoke http2_err_rst_stream http2_server_push_tls_smoke serve_h2c_multi_one_with_push serve_h2_multi_one_with_push http2_server_multistream_push_smoke http2_err_server_push http2_err_server_push_disabled http2_err_server_tls tls_alpn_h2_http1_wire http2_flow_state_init http2_flow_recv_init http2_err_flow_blocked http2_err_push_not_impl http2_h2c_session_begin http2_push_fetch_smoke http2_h2c_is_available http2_push_network_smoke RFC; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-h2 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

grep -qF "http2_wire_is_available" std/http/README.md 2>/dev/null || {
  echo "std-http-h2 gate FAIL: README missing http2" >&2
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
        echo "std-http-h2 gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-h2 gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_h2_symbols_ok "$MOD_SU" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_h2_emit_report "fail" 0 0 0 0 0
  echo "std-http-h2 gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-http-h2 manifest OK"

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
CLIENT_OK=0
NETWORK_OK=0
FLOW_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-HTTP-H2: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$WIRE_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $WIRE_SU" >&2
    "$SHUX_BIN" check -L . "$WIRE_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CLIENT_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CLIENT_SU" >&2
    "$SHUX_BIN" check -L . "$CLIENT_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$DYN_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $DYN_SU" >&2
    "$SHUX_BIN" check -L . "$DYN_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$NETWORK_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $NETWORK_SU" >&2
    "$SHUX_BIN" check -L . "$NETWORK_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$FLOW_STATE_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $FLOW_STATE_SU" >&2
    "$SHUX_BIN" check -L . "$FLOW_STATE_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$RECV_PUSH_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $RECV_PUSH_SU" >&2
    "$SHUX_BIN" check -L . "$RECV_PUSH_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$H2C_CLIENT_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $H2C_CLIENT_SU" >&2
    "$SHUX_BIN" check -L . "$H2C_CLIENT_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$STREAM_REG_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $STREAM_REG_SU" >&2
    "$SHUX_BIN" check -L . "$STREAM_REG_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$MS_CLIENT_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $MS_CLIENT_SU" >&2
    "$SHUX_BIN" check -L . "$MS_CLIENT_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_REUSE_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_REUSE_SU" >&2
    "$SHUX_BIN" check -L . "$CONN_REUSE_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_POOL_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_POOL_SU" >&2
    "$SHUX_BIN" check -L . "$CONN_POOL_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$GLOBAL_POOL_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $GLOBAL_POOL_SU" >&2
    "$SHUX_BIN" check -L . "$GLOBAL_POOL_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MS_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MS_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_MS_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_TLS_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_TLS_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_TLS_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$WIRE_SU" "wire"; then
    SMOKE_OK=1
  else
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$CLIENT_SU" "client"; then
    CLIENT_OK=1
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$DYN_SU" "dyn"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$NETWORK_SU" "network"; then
    NETWORK_OK=1
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$FLOW_STATE_SU" "flow"; then
    :
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$RECV_PUSH_SU" "recv_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$H2C_CLIENT_SU" "h2c_client"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$STREAM_REG_SU" "stream_reg"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$MS_CLIENT_SU" "multistream"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_REUSE_SU" "conn_reuse"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_POOL_SU" "conn_pool"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$GLOBAL_POOL_SU" "global_pool"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_SU" "h2_server"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MS_SU" "h2_server_ms"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_SU" "h2_server_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_TLS_SU" "h2_server_push_tls"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MS_PUSH_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MS_PUSH_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_MS_PUSH_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MS_PUSH_SU" "h2_server_ms_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_SETTINGS_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_SETTINGS_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_SETTINGS_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_SETTINGS_SU" "h2_push_settings"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_SETTINGS_FULL_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_SETTINGS_FULL_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_SETTINGS_FULL_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_SETTINGS_FULL_SU" "h2_settings_full"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_HPACK_DYN_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_HPACK_DYN_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_HPACK_DYN_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_HPACK_DYN_SU" "h2_server_hpack_dyn"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MAX_FRAME_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MAX_FRAME_SU" >&2
    "$SHUX_BIN" check -L . "$SERVER_MAX_FRAME_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MAX_FRAME_SU" "h2_server_max_frame"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_GOAWAY_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_GOAWAY_SU" >&2
    "$SHUX_BIN" check -L . "$CONN_GOAWAY_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_GOAWAY_SU" "h2_conn_goaway"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_PING_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_PING_SU" >&2
    "$SHUX_BIN" check -L . "$CONN_PING_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_PING_SU" "h2_conn_ping"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_POOL_GOAWAY_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_POOL_GOAWAY_SU" >&2
    "$SHUX_BIN" check -L . "$CONN_POOL_GOAWAY_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_POOL_GOAWAY_SU" "h2_pool_goaway"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$HTTP2_COMPLETE_SU" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $HTTP2_COMPLETE_SU" >&2
    "$SHUX_BIN" check -L . "$HTTP2_COMPLETE_SU" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$HTTP2_COMPLETE_SU" "h2_http2_complete"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  FLOW_OK=1
  SKIP=0
else
  echo "std-http-h2 gate SKIP smoke (no native shux)" >&2
fi

std_http_h2_emit_report "ok" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" "$FLOW_OK" "$SKIP"
echo "std-http-h2 gate OK"
