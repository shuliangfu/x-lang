#!/usr/bin/env bash
# STD-HTTP-H2：std.http HTTP/2 v0 线格式门禁
#
# 用法：./tests/run-std-http-h2-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_H2_DOC:-analysis/std-http-h2-v0.md}"
MANIFEST="${SHUX_STD_HTTP_H2_TSV:-tests/baseline/std-http-h2.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/src/asm/http/runtime_http_glue.c"
H2_INC="compiler/src/asm/http/http2.inc"
HPACK_INC="compiler/src/asm/http/hpack.inc.c"
HPACK_DYN_INC="compiler/src/asm/http/hpack_dyn.inc.c"
CLIENT_INC="compiler/src/asm/http/client.inc.c"
NETWORK_INC="compiler/src/asm/http/network.inc.c"
FLOW_INC="compiler/src/asm/http/flow.inc.c"
FLOW_STATE_INC="compiler/src/asm/http/flow_state.inc.c"
FLOW_RECV_INC="compiler/src/asm/http/flow_recv.inc.c"
PUSH_H2C_INC="compiler/src/asm/http/push_h2c.inc.c"
PUSH_FETCH_INC="compiler/src/asm/http/push_fetch.inc.c"
STREAM_REG_INC="compiler/src/asm/http/stream_registry.inc.c"
SETTINGS_INC="compiler/src/asm/http/settings.inc.c"
MS_CLIENT_INC="compiler/src/asm/http/multistream_client.inc.c"
CONN_REUSE_INC="compiler/src/asm/http/conn_reuse.inc.c"
CONN_POOL_INC="compiler/src/asm/http/conn_pool.inc.c"
GLOBAL_POOL_INC="compiler/src/asm/http/global_pool.inc.c"
SERVER_INC="compiler/src/asm/http/server.inc.c"
SERVER_PUSH_INC="compiler/src/asm/http/server_push.inc.c"
LIB="tests/lib/std-http-h2.sh"
WIRE_X="tests/http/wire.x"
CLIENT_X="tests/http/client.x"
DYN_X="tests/http/hpack_dyn.x"
NETWORK_X="tests/http/network.x"
FLOW_STATE_X="tests/http/flow_state.x"
RECV_PUSH_X="tests/http/flow_recv_push_h2c.x"
H2C_CLIENT_X="tests/http/h2c_client.x"
STREAM_REG_X="tests/http/stream_registry.x"
MS_CLIENT_X="tests/http/multistream_client.x"
CONN_REUSE_X="tests/http/conn_reuse.x"
CONN_POOL_X="tests/http/conn_pool.x"
GLOBAL_POOL_X="tests/http/global_pool.x"
SERVER_X="tests/http/server.x"
SERVER_MS_X="tests/http/server_multistream.x"
SERVER_PUSH_X="tests/http/server_push.x"
SERVER_PUSH_TLS_X="tests/http/server_push_tls.x"
SERVER_MS_PUSH_X="tests/http/server_multistream_push.x"
SERVER_PUSH_SETTINGS_X="tests/http/server_push_settings.x"
SERVER_SETTINGS_FULL_X="tests/http/server_settings_full.x"
SERVER_HPACK_DYN_X="tests/http/server_hpack_dyn.x"
SERVER_MAX_FRAME_X="tests/http/server_max_frame.x"
CONN_GOAWAY_X="tests/http/conn_goaway.x"
CONN_PING_X="tests/http/conn_ping.x"
CONN_POOL_GOAWAY_X="tests/http/conn_pool_goaway.x"
HTTP2_COMPLETE_X="tests/http/http2_complete.x"
HPACK_SERVER_DYN_INC="compiler/src/asm/http/hpack_server_dyn.inc.c"
FRAME_CAPPED_INC="compiler/src/asm/http/frame_capped.inc.c"
GOAWAY_INC="compiler/src/asm/http/goaway.inc.c"
PING_INC="compiler/src/asm/http/ping.inc.c"
RST_INC="compiler/src/asm/http/rst_stream.inc.c"
MIN_APIS=171

# shellcheck source=tests/lib/std-http-h2.sh
. "$LIB"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-HTTP-H2: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$H2_INC" "$HPACK_INC" "$HPACK_DYN_INC" "$HPACK_SERVER_DYN_INC" "$FRAME_CAPPED_INC" "$GOAWAY_INC" "$PING_INC" "$RST_INC" "$CLIENT_INC" "$NETWORK_INC" "$FLOW_INC" "$FLOW_STATE_INC" "$FLOW_RECV_INC" "$PUSH_H2C_INC" "$PUSH_FETCH_INC" "$STREAM_REG_INC" "$SETTINGS_INC" "$MS_CLIENT_INC" "$CONN_REUSE_INC" "$CONN_POOL_INC" "$GLOBAL_POOL_INC" "$SERVER_INC" "$SERVER_PUSH_INC" "$WIRE_X" "$CLIENT_X" "$DYN_X" "$NETWORK_X" "$FLOW_STATE_X" "$RECV_PUSH_X" "$H2C_CLIENT_X" "$STREAM_REG_X" "$MS_CLIENT_X" "$CONN_REUSE_X" "$CONN_POOL_X" "$GLOBAL_POOL_X" "$SERVER_X" "$SERVER_MS_X" "$SERVER_PUSH_X" "$SERVER_PUSH_TLS_X" "$SERVER_MS_PUSH_X" "$SERVER_PUSH_SETTINGS_X" "$SERVER_SETTINGS_FULL_X" "$SERVER_HPACK_DYN_X" "$SERVER_MAX_FRAME_X" "$CONN_GOAWAY_X" "$CONN_PING_X" "$CONN_POOL_GOAWAY_X" "$HTTP2_COMPLETE_X" std/http/README.md std/net/mod.x; do
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

for kw in STD-HTTP-H2 is_connection_preface hpack_encode_get_request hpack_encode_request h2_get h2_request client_request_h2 h2c_get client_request_h2c init err_h2c_scheme client_init build_client_settings build_client_settings_ex build_server_settings setting_enable_push setting_header_table_size setting_max_frame_size peer_settings_enable_push peer_settings_header_table_size peer_settings_max_frame_size err_max_streams conn_init conn_handshake conn_handshake_with_enable_push err_conn_not_ready h2_pool_get h2c_pool_get conn_pool_create_h2 err_pool_scheme global_pool_create global_pool_get err_global_pool_full serve_h2c_one serve_h2_one serve_h2_multi_one serve_h2c_multi_one server_multistream_smoke serve_h2c_one_with_push serve_h2_one_with_push server_push_smoke server_push_settings_smoke server_settings_full_smoke hpack_server_dyn_create server_hpack_dyn_smoke frame_payload_limit server_max_frame_smoke build_goaway conn_shutdown_graceful conn_read_goaway conn_goaway_smoke serve_h2c_one_with_goaway err_goaway build_ping conn_ping conn_ping_smoke serve_h2c_one_ping_echo err_ping conn_goaway_seen conn_is_pool_reusable conn_pool_goaway_smoke build_rst_stream conn_reset_stream complete_smoke err_rst_stream server_push_tls_smoke serve_h2c_multi_one_with_push serve_h2_multi_one_with_push server_multistream_push_smoke err_server_push err_server_push_disabled err_server_tls tls_alpn_h2_http1_wire flow_state_init flow_recv_init err_flow_blocked err_push_not_impl h2c_session_begin push_fetch_smoke h2c_is_available push_network_smoke RFC; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-h2 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

grep -qF "wire_is_available" std/http/README.md 2>/dev/null || {
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

sym_miss="$(std_http_h2_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
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
  if ! "$SHUX_BIN" check -L . "$WIRE_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $WIRE_X" >&2
    "$SHUX_BIN" check -L . "$WIRE_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CLIENT_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CLIENT_X" >&2
    "$SHUX_BIN" check -L . "$CLIENT_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$DYN_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $DYN_X" >&2
    "$SHUX_BIN" check -L . "$DYN_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$NETWORK_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $NETWORK_X" >&2
    "$SHUX_BIN" check -L . "$NETWORK_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$FLOW_STATE_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $FLOW_STATE_X" >&2
    "$SHUX_BIN" check -L . "$FLOW_STATE_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$RECV_PUSH_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $RECV_PUSH_X" >&2
    "$SHUX_BIN" check -L . "$RECV_PUSH_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$H2C_CLIENT_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $H2C_CLIENT_X" >&2
    "$SHUX_BIN" check -L . "$H2C_CLIENT_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$STREAM_REG_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $STREAM_REG_X" >&2
    "$SHUX_BIN" check -L . "$STREAM_REG_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$MS_CLIENT_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $MS_CLIENT_X" >&2
    "$SHUX_BIN" check -L . "$MS_CLIENT_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_REUSE_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_REUSE_X" >&2
    "$SHUX_BIN" check -L . "$CONN_REUSE_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_POOL_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_POOL_X" >&2
    "$SHUX_BIN" check -L . "$CONN_POOL_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$GLOBAL_POOL_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $GLOBAL_POOL_X" >&2
    "$SHUX_BIN" check -L . "$GLOBAL_POOL_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MS_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MS_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_MS_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_TLS_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_TLS_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_TLS_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$WIRE_X" "wire"; then
    SMOKE_OK=1
  else
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$CLIENT_X" "client"; then
    CLIENT_OK=1
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$DYN_X" "dyn"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" 0 0 0
    exit 1
  fi
  # Docker portable：fork+h2 push 集成在容器内易超时；wire/client/dyn 已覆盖离线路径，完整 fork 由 native GHA 承担。
  if ci_is_docker; then
    echo "std-http-h2 gate SKIP network+fork smokes (Docker; native Linux GHA covers HTTP/2 integration)" >&2
    std_http_h2_emit_report "ok" "$SMOKE_OK" "$CLIENT_OK" 0 0 1
    echo "std-http-h2 gate OK"
    exit 0
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$NETWORK_X" "network"; then
    NETWORK_OK=1
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" 0 0 0
    exit 1
  fi
  if std_http_h2_run_smoke "$SHUX_BIN" "$FLOW_STATE_X" "flow"; then
    :
  else
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$RECV_PUSH_X" "recv_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$H2C_CLIENT_X" "h2c_client"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$STREAM_REG_X" "stream_reg"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$MS_CLIENT_X" "multistream"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_REUSE_X" "conn_reuse"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_POOL_X" "conn_pool"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$GLOBAL_POOL_X" "global_pool"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_X" "h2_server"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MS_X" "h2_server_ms"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_X" "h2_server_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_TLS_X" "h2_server_push_tls"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MS_PUSH_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MS_PUSH_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_MS_PUSH_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MS_PUSH_X" "h2_server_ms_push"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_PUSH_SETTINGS_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_PUSH_SETTINGS_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_PUSH_SETTINGS_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_PUSH_SETTINGS_X" "h2_push_settings"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_SETTINGS_FULL_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_SETTINGS_FULL_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_SETTINGS_FULL_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_SETTINGS_FULL_X" "h2_settings_full"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_HPACK_DYN_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_HPACK_DYN_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_HPACK_DYN_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_HPACK_DYN_X" "h2_server_hpack_dyn"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$SERVER_MAX_FRAME_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $SERVER_MAX_FRAME_X" >&2
    "$SHUX_BIN" check -L . "$SERVER_MAX_FRAME_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$SERVER_MAX_FRAME_X" "h2_server_max_frame"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_GOAWAY_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_GOAWAY_X" >&2
    "$SHUX_BIN" check -L . "$CONN_GOAWAY_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_GOAWAY_X" "h2_conn_goaway"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_PING_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_PING_X" >&2
    "$SHUX_BIN" check -L . "$CONN_PING_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_PING_X" "h2_conn_ping"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$CONN_POOL_GOAWAY_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $CONN_POOL_GOAWAY_X" >&2
    "$SHUX_BIN" check -L . "$CONN_POOL_GOAWAY_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$CONN_POOL_GOAWAY_X" "h2_pool_goaway"; then
    std_http_h2_emit_report "fail" "$SMOKE_OK" "$CLIENT_OK" "$NETWORK_OK" 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$HTTP2_COMPLETE_X" >/dev/null 2>&1; then
    echo "std-http-h2 gate FAIL: typeck $HTTP2_COMPLETE_X" >&2
    "$SHUX_BIN" check -L . "$HTTP2_COMPLETE_X" 2>&1 | tail -10 >&2 || true
    std_http_h2_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if ! std_http_h2_run_smoke "$SHUX_BIN" "$HTTP2_COMPLETE_X" "h2_http2_complete"; then
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
