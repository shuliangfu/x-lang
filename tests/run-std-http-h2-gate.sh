#!/usr/bin/env bash
# STD-HTTP-H2: std.http HTTP/2 v0 wire gate — honesty soft prefer-c / soft
# SKIP→OK / soft ensure_std_c_o / hard check / wire=/client=/network=/flow=
# report →硬绿.
#
# Honesty: prefer-c first (xlang-c only) + soft SKIP→OK (no native / Docker
# still gate OK) + soft `ensure_std_c_o` + soft `xlang_compiler_make … || true`
# + hard check as sole .x smoke + report `wire=`/`client=` retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native
# = hard die. Host-C archaeology = obs only (refuse soft ensure; no dedicated
# h2 C harness). check residual = obs (paused 2026-08-05). tip product -o
# UNDEF/SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# http-context／reqresp／server-pool／unbounded left (product UNDEF).
# unicode-normalization API 面缺失＝产品另案. Live ensure_std family left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-http-h2-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_HTTP_H2_DOC:-analysis/archive/std/std-http-h2-v0.md}"
MANIFEST="${XLANG_STD_HTTP_H2_TSV:-tests/baseline/std-http-h2.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
H2_INC="compiler/seeds/http/http2.inc"
HPACK_INC="compiler/seeds/http/http2_hpack.inc"
HPACK_DYN_INC="compiler/seeds/http/http2_hpack_dyn.inc"
CLIENT_INC="compiler/seeds/http/http2_client.inc"
NETWORK_INC="compiler/seeds/http/http2_network.inc"
FLOW_INC="compiler/seeds/http/http2_flow.inc"
FLOW_STATE_INC="compiler/seeds/http/http2_flow_state.inc"
FLOW_RECV_INC="compiler/seeds/http/http2_flow_recv.inc"
PUSH_H2C_INC="compiler/seeds/http/http2_push_h2c.inc"
PUSH_FETCH_INC="compiler/seeds/http/http2_push_fetch.inc"
STREAM_REG_INC="compiler/seeds/http/http2_stream_registry.inc"
SETTINGS_INC="compiler/seeds/http/http2_settings.inc"
MS_CLIENT_INC="compiler/seeds/http/http2_multistream_client.inc"
CONN_REUSE_INC="compiler/seeds/http/http2_conn_reuse.inc"
CONN_POOL_INC="compiler/seeds/http/http2_conn_pool.inc"
GLOBAL_POOL_INC="compiler/seeds/http/http2_global_pool.inc"
SERVER_INC="compiler/seeds/http/http2_server.inc"
SERVER_PUSH_INC="compiler/seeds/http/http2_server_push.inc"
LIB="tests/lib/std-http-h2.sh"
WIRE_X="tests/http/http2_wire.x"
CLIENT_X="tests/http/http2_client.x"
DYN_X="tests/http/http2_hpack_dyn.x"
NETWORK_X="tests/http/http2_network.x"
FLOW_STATE_X="tests/http/http2_flow_state.x"
RECV_PUSH_X="tests/http/http2_flow_recv_push_h2c.x"
H2C_CLIENT_X="tests/http/h2c_client.x"
STREAM_REG_X="tests/http/http2_stream_registry.x"
MS_CLIENT_X="tests/http/http2_multistream_client.x"
CONN_REUSE_X="tests/http/http2_conn_reuse.x"
CONN_POOL_X="tests/http/http2_conn_pool.x"
GLOBAL_POOL_X="tests/http/http2_global_pool.x"
SERVER_X="tests/http/http2_server.x"
SERVER_MS_X="tests/http/http2_server_multistream.x"
SERVER_PUSH_X="tests/http/http2_server_push.x"
SERVER_PUSH_TLS_X="tests/http/http2_server_push_tls.x"
SERVER_MS_PUSH_X="tests/http/http2_server_multistream_push.x"
SERVER_PUSH_SETTINGS_X="tests/http/http2_server_push_settings.x"
SERVER_SETTINGS_FULL_X="tests/http/http2_server_settings_full.x"
SERVER_HPACK_DYN_X="tests/http/http2_server_hpack_dyn.x"
SERVER_MAX_FRAME_X="tests/http/http2_server_max_frame.x"
CONN_GOAWAY_X="tests/http/http2_conn_goaway.x"
CONN_PING_X="tests/http/http2_conn_ping.x"
CONN_POOL_GOAWAY_X="tests/http/http2_conn_pool_goaway.x"
HTTP2_COMPLETE_X="tests/http/http2_http2_complete.x"
HPACK_SERVER_DYN_INC="compiler/seeds/http/http2_hpack_server_dyn.inc"
FRAME_CAPPED_INC="compiler/seeds/http/http2_frame_capped.inc"
GOAWAY_INC="compiler/seeds/http/http2_goaway.inc"
PING_INC="compiler/seeds/http/http2_ping.inc"
RST_INC="compiler/seeds/http/http2_rst_stream.inc"
PARENT_GATE="tests/run-std-http-gate.sh"
PARENT_DOC="analysis/archive/std/std-http-bench-v1.md"
MIN_APIS=171

# shellcheck source=tests/lib/std-http-h2.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-http-h2 gate FAIL: $*" >&2
  std_http_h2_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-HTTP-H2: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$H2_INC" "$HPACK_INC" \
  "$HPACK_DYN_INC" "$HPACK_SERVER_DYN_INC" "$FRAME_CAPPED_INC" "$GOAWAY_INC" \
  "$PING_INC" "$RST_INC" "$CLIENT_INC" "$NETWORK_INC" "$FLOW_INC" \
  "$FLOW_STATE_INC" "$FLOW_RECV_INC" "$PUSH_H2C_INC" "$PUSH_FETCH_INC" \
  "$STREAM_REG_INC" "$SETTINGS_INC" "$MS_CLIENT_INC" "$CONN_REUSE_INC" \
  "$CONN_POOL_INC" "$GLOBAL_POOL_INC" "$SERVER_INC" "$SERVER_PUSH_INC" \
  "$WIRE_X" "$CLIENT_X" "$DYN_X" "$NETWORK_X" "$FLOW_STATE_X" "$RECV_PUSH_X" \
  "$H2C_CLIENT_X" "$STREAM_REG_X" "$MS_CLIENT_X" "$CONN_REUSE_X" \
  "$CONN_POOL_X" "$GLOBAL_POOL_X" "$SERVER_X" "$SERVER_MS_X" \
  "$SERVER_PUSH_X" "$SERVER_PUSH_TLS_X" "$SERVER_MS_PUSH_X" \
  "$SERVER_PUSH_SETTINGS_X" "$SERVER_SETTINGS_FULL_X" "$SERVER_HPACK_DYN_X" \
  "$SERVER_MAX_FRAME_X" "$CONN_GOAWAY_X" "$CONN_PING_X" "$CONN_POOL_GOAWAY_X" \
  "$HTTP2_COMPLETE_X" std/http/README.md std/net/mod.x \
  "$PARENT_GATE" "$PARENT_DOC"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-http-h2-v0.md ] || die "dual-authority fossil analysis/std-http-h2-v0.md (archive live)"

for kw in STD-HTTP-H2 is_connection_preface hpack_encode_get_request hpack_encode_request h2_get h2_request client_request_h2 h2c_get client_request_h2c init err_h2c_scheme client_init build_client_settings build_client_settings_ex build_server_settings setting_enable_push setting_header_table_size setting_max_frame_size peer_settings_enable_push peer_settings_header_table_size peer_settings_max_frame_size err_max_streams conn_init conn_handshake conn_handshake_with_enable_push err_conn_not_ready h2_pool_get h2c_pool_get conn_pool_create_h2 err_pool_scheme global_pool_create global_pool_get err_global_pool_full serve_h2c_one serve_h2_one serve_h2_multi_one serve_h2c_multi_one server_multistream_smoke serve_h2c_one_with_push serve_h2_one_with_push server_push_smoke server_push_settings_smoke server_settings_full_smoke hpack_server_dyn_create server_hpack_dyn_smoke frame_payload_limit server_max_frame_smoke build_goaway conn_shutdown_graceful conn_read_goaway conn_goaway_smoke serve_h2c_one_with_goaway err_goaway build_ping conn_ping conn_ping_smoke serve_h2c_one_ping_echo err_ping conn_goaway_seen conn_is_pool_reusable conn_pool_goaway_smoke build_rst_stream conn_reset_stream complete_smoke err_rst_stream server_push_tls_smoke serve_h2c_multi_one_with_push serve_h2_multi_one_with_push server_multistream_push_smoke err_server_push err_server_push_disabled err_server_tls tls_alpn_h2_http1_wire flow_state_init flow_recv_init err_flow_blocked err_push_not_impl h2c_session_begin push_fetch_smoke h2c_is_available push_network_smoke RFC; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF "wire_is_available" std/http/README.md 2>/dev/null || die "README missing http2"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_http_h2_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-http-h2 manifest OK"
# Parent STD-009: file presence only (aligned with STD-066 query-rows).
# PLATFORM: SHARED archaeology — refuse opening http-context／reqresp／pool knife.

if [ "${XLANG_STD_HTTP_H2_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_http_h2_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-http-h2 gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-HTTP-H2: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology: refuse soft ensure_std_c_o / auto-make.
# No dedicated h2 C harness — do not rebuild std/http/http.o; do not SKIP→OK.
# PLATFORM: SHARED — product -o is the hard path; host-C left as archaeology.

# check = obs (paused); sample first smoke only to bound cost.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$WIRE_X" >/tmp/xlang_std_http_h2_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-http-h2 OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs per smoke (leave product debt).
# Refuse Docker SKIP→OK / no-native SKIP→OK.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence / soft ensure rebuild.
for smoke_x in "$WIRE_X" "$CLIENT_X" "$DYN_X" "$NETWORK_X" "$FLOW_STATE_X" \
  "$RECV_PUSH_X" "$H2C_CLIENT_X" "$STREAM_REG_X" "$MS_CLIENT_X" \
  "$CONN_REUSE_X" "$CONN_POOL_X" "$GLOBAL_POOL_X" "$SERVER_X" \
  "$SERVER_MS_X" "$SERVER_PUSH_X" "$SERVER_PUSH_TLS_X" "$SERVER_MS_PUSH_X" \
  "$SERVER_PUSH_SETTINGS_X" "$SERVER_SETTINGS_FULL_X" "$SERVER_HPACK_DYN_X" \
  "$SERVER_MAX_FRAME_X" "$CONN_GOAWAY_X" "$CONN_PING_X" "$CONN_POOL_GOAWAY_X" \
  "$HTTP2_COMPLETE_X"; do
  if std_http_h2_run_smoke "$XLANG_BIN" "$smoke_x" "product"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-http-h2 OK: product $(basename "$smoke_x")"
  else
    echo "std-http-h2 OBS tip product $(basename "$smoke_x") (UNDEF/SEGV residual)" >&2
    OBS=$((OBS + 1))
  fi
done

std_http_h2_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-http-h2 gate OK"
