// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

/**
 * Socket.IO C ABI wrappers.
 *
 * All `net_ws_*` / `net_tls_*` / `net_close_socket_*` / `sio_*` / `sio_eio_*`
 * functions below are thin wrappers over the XLANG Socket.IO / WebSocket
 * C implementation (see seeds). They are exposed to XLANG via
 * `extern "C"` declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches the C runtime
 * (WebSocket RFC 6455 framing + TLS integration + Engine.IO v4 packet
 * codec + Socket.IO event packet codec + namespace support + polling
 * transport fallback + room/broadcast routing).
 * PLATFORM: SHARED — pure C with POSIX sockets + optional TLS; available
 * on all targets (macOS arm64 / Ubuntu x86_64 / Windows MSYS2/MinGW
 * with winsock2). POSIX vs winsock dispatch handled in C implementation.
 *
 * Categories:
 *   - net_ws_*            : WebSocket client / server connect + write +
 *                           read frame + close (RFC 6455)
 *   - net_tls_*           : TLS context lifecycle (init / close / read /
 *                           write via mbedTLS or OpenSSL backend)
 *   - net_close_socket_*  : socket fd cleanup (POSIX / winsock)
 *   - sio_eio_*           : Engine.IO v4 packet encode/decode + SID
 *                           extraction + ping/pong + upgrade handshake
 *   - sio_encode_event_*  : Socket.IO event packet encode (with optional
 *                           namespace prefix) for client→server emit
 *   - sio_decode_event_*  : Socket.IO event packet decode for server→
 *                           client inbound events
 *   - sio_room_*          : room join/leave + broadcast fan-out
 *   - sio_poll_*          : polling transport HTTP long-poll helpers
 *   - sio_client_*        : high-level client connect/disconnect/emit/
 *                           on_event with auto-reconnect
 *   - sio_server_*        : high-level server accept/handle/broadcast
 *   - sio_smoke_*         : smoke tests for codec + transport layers
 *
 * Handle model:
 *   - fd (i32)            : socket file descriptor (POSIX int / winsock
 *                           SOCKET cast)
 *   - tls_ctx (i64)       : opaque TLS context handle (mbedTLS or
 *                           OpenSSL backend, see net_tls_init_c)
 *   - sio_pkt (i64)       : opaque Socket.IO session handle (see
 *                           sio_client_connect_c / sio_server_accept_c)
 *
 * Error codes: returns i32; 0 = OK, negative = error
 *   (e.g. -1 invalid argument, -2 connection closed, -3 timeout,
 *    -4 TLS handshake failed, -5 packet decode failed,
 *    -6 namespace not found, -7 room not found, -9 not implemented).
 *
 * Unsafe contract: callers must wrap `net_ws_*` / `sio_*` / `net_tls_*`
 * calls in `unsafe { }` blocks. P0a semantic downgrade currently allows
 * unwrapped calls; P1 typeck enforcement (post-bootstrap) will reject
 * unwrapped calls.
 */

extern "C" function net_ws_connect_url_c(url: *u8, url_len: i32, key: *u8, key_len: i32, timeout_ms: u32, out_fd: *i32,
  out_tls: *i64): i32;
extern "C" function net_ws_write_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern "C" function net_ws_write_server_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern "C" function net_ws_read_frame_c(fd: i32, tls_ctx: i64, out_opcode: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32, timeout_ms: u32): i32;
extern "C" function net_close_socket_c(fd: i32): i32;
extern "C" function net_tls_close_c(ctx_handle: i64): i32;

extern "C" function sio_eio_encode_packet_c(type: i32, payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_eio_decode_packet_c(buf: *u8, len: i32, out_type: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32): i32;
extern "C" function sio_encode_event_packet_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8,
  out_cap: i32): i32;
extern "C" function sio_encode_event_ns_packet_c(ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8,
  data_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_decode_event_packet_c(sio_pkt: *u8, len: i32, out_event: *u8, out_event_cap: i32, out_data: *u8,
  out_data_cap: i32, out_data_len: *i32): i32;
extern "C" function sio_eio_extract_sid_c(open_payload: *u8, len: i32, out_sid: *u8, out_cap: i32): i32;
extern "C" function sio_packet_smoke_c(): i32;
extern "C" function sio_eio_version_c(): i32;
extern "C" function sio_transport_polling_c(): i32;
extern "C" function sio_transport_websocket_c(): i32;
extern "C" function sio_build_eio_url_c(base: *u8, base_len: i32, sid: *u8, sid_len: i32, transport: i32, out: *u8,
  out_cap: i32): i32;
extern "C" function sio_http_extract_body_c(http: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32): i32;
extern "C" function sio_eio_open_has_websocket_c(open_payload: *u8, len: i32): i32;
extern "C" function sio_polling_handshake_parse_c(http: *u8, http_len: i32, out_sid: *u8, sid_cap: i32,
  out_has_ws: *i32): i32;
extern "C" function sio_polling_handshake_c(base_url: *u8, base_len: i32, out_sid: *u8, sid_cap: i32, timeout_ms: u32,
  out_has_ws: *i32): i32;
extern "C" function sio_polling_post_packet_c(base_url: *u8, base_len: i32, sid: *u8, sid_len: i32, packet: *u8,
  packet_len: i32, out_resp: *u8, out_cap: i32, timeout_ms: u32): i32;
extern "C" function sio_polling_smoke_c(): i32;
extern "C" function sio_sio_type_connect_c(): i32;
extern "C" function sio_sio_type_ack_c(): i32;
extern "C" function sio_encode_connect_ns_packet_c(ns: *u8, ns_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_encode_event_ack_packet_c(ack_id: i32, event: *u8, event_len: i32, data: *u8, data_len: i32,
  out: *u8, out_cap: i32): i32;
extern "C" function sio_encode_ack_packet_c(ack_id: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_parse_sio_packet_head_c(pkt: *u8, len: i32, out_type: *i32, out_id: *i32,
  out_payload_off: *i32): i32;
extern "C" function sio_server_is_connect_ns_packet_c(pkt: *u8, len: i32, ns: *u8, ns_len: i32): i32;
extern "C" function sio_ns_ack_smoke_c(): i32;
extern "C" function sio_parse_connect_ns_packet_c(pkt: *u8, len: i32, out_ns: *u8, out_cap: i32): i32;
extern "C" function sio_ns_router_bytes_c(): i32;
extern "C" function sio_ns_router_init_c(r: *SioNsRouter): void;
extern "C" function sio_ns_router_register_c(r: *SioNsRouter, ns: *u8, ns_len: i32, slot_id: i32): i32;
extern "C" function sio_ns_router_lookup_c(r: *SioNsRouter, ns: *u8, ns_len: i32): i32;
extern "C" function sio_ns_router_route_connect_c(r: *SioNsRouter, pkt: *u8, len: i32): i32;
extern "C" function sio_ns_router_smoke_c(): i32;
extern "C" function sio_ns_sessions_bytes_c(): i32;
extern "C" function sio_ns_sessions_init_c(s: *SioNsSessions): void;
extern "C" function sio_ns_sessions_sync_router_c(s: *SioNsSessions, r: *SioNsRouter): i32;
extern "C" function sio_ns_sessions_connect_c(s: *SioNsSessions, r: *SioNsRouter, pkt: *u8, len: i32): i32;
extern "C" function sio_ns_sessions_disconnect_c(s: *SioNsSessions, slot_id: i32): i32;
extern "C" function sio_ns_sessions_active_c(s: *SioNsSessions, slot_id: i32): i32;
extern "C" function sio_ns_sessions_total_c(s: *SioNsSessions): i32;
extern "C" function sio_ns_sessions_smoke_c(): i32;
extern "C" function sio_ws_hub_bytes_c(): i32;
extern "C" function sio_ws_hub_init_c(h: *SioWsHub): void;
extern "C" function sio_ws_hub_register_c(h: *SioWsHub, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32;
extern "C" function sio_ws_hub_unregister_c(h: *SioWsHub, conn_idx: i32): i32;
extern "C" function sio_ws_hub_find_by_sid_c(h: *SioWsHub, sid: *u8, sid_len: i32): i32;
extern "C" function sio_ws_hub_handle_connect_c(h: *SioWsHub, conn_idx: i32, r: *SioNsRouter, s: *SioNsSessions,
  pkt: *u8, len: i32): i32;
extern "C" function sio_ws_hub_emit_event_ns_c(h: *SioWsHub, slot_id: i32, ns: *u8, ns_len: i32, event: *u8,
  event_len: i32, data: *u8, data_len: i32): i32;
extern "C" function sio_ws_hub_smoke_c(): i32;
extern "C" function sio_ws_hub_snapshot_bytes_c(): i32;
extern "C" function sio_ws_hub_export_c(h: *SioWsHub, out: *u8, out_cap: i32): i32;
extern "C" function sio_ws_hub_import_c(h: *SioWsHub, buf: *u8, len: i32): i32;
extern "C" function sio_room_registry_bytes_c(): i32;
extern "C" function sio_room_registry_init_c(reg: *SioRoomRegistry): void;
extern "C" function sio_room_register_c(reg: *SioRoomRegistry, name: *u8, name_len: i32, room_id: i32): i32;
extern "C" function sio_room_join_c(reg: *SioRoomRegistry, room_id: i32, conn_idx: i32): i32;
extern "C" function sio_room_leave_c(reg: *SioRoomRegistry, room_id: i32, conn_idx: i32): i32;
extern "C" function sio_room_leave_all_c(reg: *SioRoomRegistry, conn_idx: i32): i32;
extern "C" function sio_room_member_count_c(reg: *SioRoomRegistry, room_id: i32): i32;
extern "C" function sio_room_broadcast_ns_c(reg: *SioRoomRegistry, h: *SioWsHub, room_id: i32, ns: *u8, ns_len: i32,
  event: *u8, event_len: i32, data: *u8, data_len: i32): i32;
extern "C" function sio_room_smoke_c(): i32;
extern "C" function sio_ws_hub_rebind_c(h: *SioWsHub, conn_idx: i32, fd: i32, tls_ctx: i64): i32;
extern "C" function sio_room_registry_snapshot_bytes_c(): i32;
extern "C" function sio_room_registry_export_c(reg: *SioRoomRegistry, out: *u8, out_cap: i32): i32;
extern "C" function sio_room_registry_import_c(reg: *SioRoomRegistry, buf: *u8, len: i32): i32;
extern "C" function sio_hub_sync_smoke_c(): i32;
extern "C" function sio_ws_hub_register_or_rebind_c(h: *SioWsHub, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32;
extern "C" function sio_session_bundle_bytes_c(): i32;
extern "C" function sio_session_bundle_export_c(h: *SioWsHub, reg: *SioRoomRegistry, out: *u8, out_cap: i32): i32;
extern "C" function sio_session_bundle_import_c(h: *SioWsHub, reg: *SioRoomRegistry, buf: *u8, len: i32): i32;
extern "C" function sio_session_sync_smoke_c(): i32;
extern "C" function sio_ws_hub_append_from_c(dst: *SioWsHub, src: *SioWsHub): i32;
extern "C" function sio_room_registry_merge_offset_c(dst: *SioRoomRegistry, src: *SioRoomRegistry, conn_offset: i32): i32;
extern "C" function sio_cluster_sync_c(h: *SioWsHub, reg: *SioRoomRegistry, bundle_a: *u8, len_a: i32, bundle_b: *u8,
  len_b: i32): i32;
extern "C" function sio_cluster_sync_smoke_c(): i32;
extern "C" function sio_cluster_adapter_bytes_c(): i32;
extern "C" function sio_cluster_adapter_init_c(a: *SioClusterAdapter, node_id: i32): void;
extern "C" function sio_cluster_adapter_publish_ns_c(a: *SioClusterAdapter, src_node_id: i32, room_id: i32, ns: *u8,
  ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32): i32;
extern "C" function sio_cluster_adapter_drain_apply_c(a: *SioClusterAdapter, h: *SioWsHub, reg: *SioRoomRegistry,
  local_node_id: i32): i32;
extern "C" function sio_cluster_adapter_smoke_c(): i32;
extern "C" function sio_cluster_adapter_snapshot_bytes_c(): i32;
extern "C" function sio_cluster_adapter_export_c(a: *SioClusterAdapter, out: *u8, out_cap: i32): i32;
extern "C" function sio_cluster_adapter_import_merge_c(a: *SioClusterAdapter, buf: *u8, len: i32): i32;
extern "C" function sio_cluster_ring_sync_smoke_c(): i32;
extern "C" function sio_p3_complete_smoke_c(): i32;
extern "C" function sio_server_build_connect_ns_ack_c(ns: *u8, ns_len: i32, sid: *u8, sid_len: i32, out: *u8,
  out_cap: i32): i32;
extern "C" function sio_http_to_ws_base_c(http_base: *u8, len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_build_ws_connect_url_c(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, out: *u8,
  out_cap: i32): i32;
extern "C" function sio_eio_ws_upgrade_c(fd: i32, tls_ctx: i64, timeout_ms: u32): i32;
extern "C" function sio_encode_connect_packet_c(out: *u8, out_cap: i32): i32;
extern "C" function sio_reconnect_delay_ms_c(attempt: i32, cap_ms: i32): i32;
extern "C" function sio_connect_smoke_c(): i32;
extern "C" function sio_node_interop_smoke_c(): i32;
extern "C" function sio_server_build_open_packet_c(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_server_build_http_open_response_c(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32;
extern "C" function sio_server_is_polling_handshake_c(path: *u8, len: i32): i32;
extern "C" function sio_server_is_connect_packet_c(pkt: *u8, len: i32): i32;
extern "C" function sio_server_smoke_c(): i32;
extern "C" function sio_server_emit_event_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8,
  out_cap: i32): i32;
extern "C" function sio_server_build_http_event_response_c(event: *u8, event_len: i32, data: *u8, data_len: i32,
  out: *u8, out_cap: i32): i32;
extern "C" function sio_server_emit_smoke_c(): i32;

/* See implementation. */
allow(padding) struct SioClient {
  sid_len: i32;
  transport: i32;
  reconnect_attempt: i32;
  max_reconnect: i32;
  has_websocket: i32;
}

/* See implementation. */
allow(padding) struct SioWsStream {
  fd: i32;
  tls_ctx: i64;
}

/* See implementation. */
allow(padding) struct SioNsRouter {
  count: i32;
  ns_len_0: i32;
  ns_len_1: i32;
  ns_len_2: i32;
  ns_len_3: i32;
  slot_id_0: i32;
  slot_id_1: i32;
  slot_id_2: i32;
  slot_id_3: i32;
  ns_0: u8[24];
  ns_1: u8[24];
  ns_2: u8[24];
  ns_3: u8[24];
}

/* See implementation. */
allow(padding) struct SioNsSessions {
  count: i32;
  slot_id_0: i32;
  slot_id_1: i32;
  slot_id_2: i32;
  slot_id_3: i32;
  active_0: i32;
  active_1: i32;
  active_2: i32;
  active_3: i32;
}

/* See implementation. */
allow(padding) struct SioWsHubSlot {
  in_use: i32;
  fd: i32;
  sid_len: i32;
  slot_id: i32;
  tls_ctx: i64;
  sid: u8[24];
}

/* See implementation. */
allow(padding) struct SioWsHub {
  count: i32;
  pad_count: i32;
  slot_0: SioWsHubSlot;
  slot_1: SioWsHubSlot;
  slot_2: SioWsHubSlot;
  slot_3: SioWsHubSlot;
}

/* See implementation. */
allow(padding) struct SioRoom {
  in_use: i32;
  name_len: i32;
  room_id: i32;
  member_count: i32;
  name: u8[16];
  member_0: i32;
  member_1: i32;
  member_2: i32;
  member_3: i32;
}

/* See implementation. */
allow(padding) struct SioRoomRegistry {
  count: i32;
  room_0: SioRoom;
  room_1: SioRoom;
  room_2: SioRoom;
  room_3: SioRoom;
}

/* See implementation. */
allow(padding) struct SioClusterAdapterMsg {
  in_use: i32;
  src_node_id: i32;
  room_id: i32;
  ns_len: i32;
  event_len: i32;
  data_len: i32;
  ns: u8[16];
  event: u8[16];
  data: u8[16];
}

/* See implementation. */
allow(padding) struct SioClusterAdapter {
  count: i32;
  node_id: i32;
  msg_0: SioClusterAdapterMsg;
  msg_1: SioClusterAdapterMsg;
  msg_2: SioClusterAdapterMsg;
  msg_3: SioClusterAdapterMsg;
}

/** Engine.IO open。 */
export function eio_type_open(): i32 { return 0; }
/** Engine.IO close。 */
export function eio_type_close(): i32 { return 1; }
/** Engine.IO ping。 */
export function eio_type_ping(): i32 { return 2; }
/** Engine.IO pong。 */
export function eio_type_pong(): i32 { return 3; }
/** Exported function `eio_type_message`.
 * Implements `eio_type_message`.
 * @return i32
 */
export function eio_type_message(): i32 { return 4; }
/** Engine.IO upgrade。 */
export function eio_type_upgrade(): i32 { return 5; }
/** Engine.IO noop。 */
export function eio_type_noop(): i32 { return 6; }

/** Socket.IO EVENT。 */
export function sio_type_event(): i32 { return 2; }

/** Exported function `sio_type_ack`.
 * Implements `sio_type_ack`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = sio_sio_type_ack_c(
 * @return void
 */
export function sio_type_ack(): i32 { let _rc: i32 = 0; unsafe { _rc = sio_sio_type_ack_c(); } return _rc; }

/** Exported function `eio_version`.
 * Implements `eio_version`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = sio_eio_version_c(
 * @return void
 */
export function eio_version(): i32 { let _rc: i32 = 0; unsafe { _rc = sio_eio_version_c(); } return _rc; }

/** Exported function `transport_polling`.
 * Implements `transport_polling`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = sio_transport_polling_c(
 * @return void
 */
export function transport_polling(): i32 { let _rc: i32 = 0; unsafe { _rc = sio_transport_polling_c(); } return _rc; }

/** Exported function `transport_websocket`.
 * Implements `transport_websocket`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = sio_transport_websocket_c(
 * @return void
 */
export function transport_websocket(): i32 { let _rc: i32 = 0; unsafe { _rc = sio_transport_websocket_c(); } return _rc; }

/** Exported function `build_eio_url`.
 * Implements `build_eio_url`.
 * @param base *u8
 * @param base_len i32
 * @param sid *u8
 * @param sid_len i32
 * @param transport i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_eio_url(base: *u8, base_len: i32, sid: *u8, sid_len: i32, transport: i32, out: *u8, out_cap: i32): i32 {
  if (base == 0 || out == 0) { return -1; }
  unsafe { return sio_build_eio_url_c(base, base_len, sid, sid_len, transport, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_extract_body`.
 * Implements `http_extract_body`.
 * @param http *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @param out_len *i32
 * @return i32
 */
export function http_extract_body(http: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32): i32 {
  if (http == 0 || out == 0 || out_len == 0) { return -1; }
  unsafe { return sio_http_extract_body_c(http, len, out, out_cap, out_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `open_has_websocket`.
 * Implements `open_has_websocket`.
 * @param open_payload *u8
 * @param len i32
 * @return i32
 */
export function open_has_websocket(open_payload: *u8, len: i32): i32 {
  if (open_payload == 0) { return -1; }
  unsafe { return sio_eio_open_has_websocket_c(open_payload, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `polling_handshake_parse`.
 * Implements `polling_handshake_parse`.
 * @param http *u8
 * @param http_len i32
 * @param out_sid *u8
 * @param sid_cap i32
 * @param out_has_ws *i32
 * @return i32
 */
export function polling_handshake_parse(http: *u8, http_len: i32, out_sid: *u8, sid_cap: i32, out_has_ws: *i32): i32 {
  if (http == 0 || out_sid == 0) { return -1; }
  unsafe { return sio_polling_handshake_parse_c(http, http_len, out_sid, sid_cap, out_has_ws); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function polling_handshake(base_url: *u8, base_len: i32, out_sid: *u8, sid_cap: i32, timeout_ms: u32,
  out_has_ws: *i32): i32 {
  if (base_url == 0 || out_sid == 0) { return -1; }
  unsafe { return sio_polling_handshake_c(base_url, base_len, out_sid, sid_cap, timeout_ms, out_has_ws); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function polling_post_packet(base_url: *u8, base_len: i32, sid: *u8, sid_len: i32, packet: *u8, packet_len: i32,
  out_resp: *u8, out_cap: i32, timeout_ms: u32): i32 {
  if (base_url == 0 || sid == 0 || packet == 0 || out_resp == 0) { return -1; }
  unsafe { return sio_polling_post_packet_c(base_url, base_len, sid, sid_len, packet, packet_len, out_resp, out_cap,
    timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `polling_smoke`.
 * Implements `polling_smoke`.
 * @return i32
 */
export function polling_smoke(): i32 {
  unsafe { return sio_polling_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `sio_type_connect`.
 * Implements `sio_type_connect`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = sio_sio_type_connect_c(
 * @return void
 */
export function sio_type_connect(): i32 { let _rc: i32 = 0; unsafe { _rc = sio_sio_type_connect_c(); } return _rc; }

/** Exported function `http_to_ws_base`.
 * Implements `http_to_ws_base`.
 * @param http_base *u8
 * @param base_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http_to_ws_base(http_base: *u8, base_len: i32, out: *u8, out_cap: i32): i32 {
  if (http_base == 0 || out == 0) { return -1; }
  unsafe { return sio_http_to_ws_base_c(http_base, base_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `build_ws_connect_url`.
 * Implements `build_ws_connect_url`.
 * @param http_base *u8
 * @param base_len i32
 * @param sid *u8
 * @param sid_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_ws_connect_url(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {
  if (http_base == 0 || sid == 0 || out == 0) { return -1; }
  unsafe { return sio_build_ws_connect_url_c(http_base, base_len, sid, sid_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `encode_connect_packet`.
 * Implements `encode_connect_packet`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encode_connect_packet(out: *u8, out_cap: i32): i32 {
  if (out == 0) { return -1; }
  unsafe { return sio_encode_connect_packet_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `encode_connect_ns_packet`.
 * Implements `encode_connect_ns_packet`.
 * @param ns *u8
 * @param ns_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encode_connect_ns_packet(ns: *u8, ns_len: i32, out: *u8, out_cap: i32): i32 {
  if (out == 0) { return -1; }
  unsafe { return sio_encode_connect_ns_packet_c(ns, ns_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `reconnect_delay_ms`.
 * Implements `reconnect_delay_ms`.
 * @param attempt i32
 * @param cap_ms i32
 * @return i32
 */
export function reconnect_delay_ms(attempt: i32, cap_ms: i32): i32 {
  unsafe { return sio_reconnect_delay_ms_c(attempt, cap_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `connect_smoke`.
 * Implements `connect_smoke`.
 * @return i32
 */
export function connect_smoke(): i32 {
  unsafe { return sio_connect_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `client_init`.
 * Implements `client_init`.
 * @param c *SioClient
 * @param max_reconnect i32
 * @return void
 */
export function client_init(c: *SioClient, max_reconnect: i32): void {
  if (c == 0) { return; }
  c.sid_len = 0;
  c.transport = transport_polling();
  c.reconnect_attempt = 0;
  c.max_reconnect = max_reconnect;
  c.has_websocket = 0;
}

/* See implementation. */
export function connect_handshake(c: *SioClient, base_url: *u8, base_len: i32, sid_out: *u8, sid_cap: i32,
  timeout_ms: u32): i32 {
  let has_ws: i32 = 0;
  let sl: i32 = 0;
  if (c == 0 || base_url == 0 || sid_out == 0) { return -1; }
  sl = polling_handshake(base_url, base_len, sid_out, sid_cap, timeout_ms, &has_ws);
  if (sl <= 0) { return -1; }
  c.sid_len = sl;
  c.has_websocket = has_ws;
  return sl;
}

/** Exported function `ws_finish_eio_upgrade`.
 * Implements `ws_finish_eio_upgrade`.
 * @param stream SioWsStream
 * @param timeout_ms u32
 * @return i32
 */
export function ws_finish_eio_upgrade(stream: SioWsStream, timeout_ms: u32): i32 {
  if (stream.fd < 0) { return -1; }
  unsafe { return sio_eio_ws_upgrade_c(stream.fd, stream.tls_ctx, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function connect_ws(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, url_buf: *u8, url_cap: i32,
  timeout_ms: u32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let fd: i32 = -1;
  let tls: i64 = 0;
  let n: i32 = 0;
  let key: u8[1] = [0];
  if (http_base == 0 || sid == 0 || url_buf == 0) { return bad; }
  n = build_ws_connect_url(http_base, base_len, sid, sid_len, url_buf, url_cap);
  if (n <= 0) { return bad; }
  /* See implementation. */
  let ws_rc: i32 = 0;
  unsafe { ws_rc = net_ws_connect_url_c(url_buf, n, &key[0], 0, timeout_ms, &fd, &tls); }
  if (ws_rc != 0) { return bad; }
  /* See implementation. */
  if (ws_finish_eio_upgrade(SioWsStream { fd: fd, tls_ctx: tls }, timeout_ms) != 0) {
    let probe_skip: i32 = 0;
    probe_skip = probe_skip + 0;
  }
  return SioWsStream { fd: fd, tls_ctx: tls };
}

/** Exported function `send_connect_packet`.
 * Implements `send_connect_packet`.
 * @param stream SioWsStream
 * @return i32
 */
export function send_connect_packet(stream: SioWsStream): i32 {
  let pkt: u8[8] = [];
  let n: i32 = encode_connect_packet(&pkt[0], 8);
  if (n <= 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &pkt[0], n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `send_connect_ns_packet`.
 * Implements `send_connect_ns_packet`.
 * @param stream SioWsStream
 * @param ns *u8
 * @param ns_len i32
 * @return i32
 */
export function send_connect_ns_packet(stream: SioWsStream, ns: *u8, ns_len: i32): i32 {
  let pkt: u8[64] = [];
  let n: i32 = encode_connect_ns_packet(ns, ns_len, &pkt[0], 64);
  if (n <= 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &pkt[0], n); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function connect_ws_ns(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, ns: *u8, ns_len: i32,
  url_buf: *u8, url_cap: i32, timeout_ms: u32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let stream: SioWsStream = bad;
  let pre: u8[256] = [];
  let plen: i32 = 0;
  if (http_base == 0 || sid == 0 || url_buf == 0) { return bad; }
  stream = connect_ws(http_base, base_len, sid, sid_len, url_buf, url_cap, timeout_ms);
  if (stream.fd < 0) { return bad; }
  /* See implementation. */
  if (ws_read_text(stream, &pre[0], 256, timeout_ms, &plen) != 0) {
    plen = 0;
  }
  if (send_connect_ns_packet(stream, ns, ns_len) < 0) {
    ws_close_stream(stream);
    return bad;
  }
  return stream;
}

/** Exported function `ws_read_text`.
 * Read path helper `ws_read_text`.
 * @param stream SioWsStream
 * @param buf *u8
 * @param cap i32
 * @param timeout_ms u32
 * @param out_len *i32
 * @return i32
 */
export function ws_read_text(stream: SioWsStream, buf: *u8, cap: i32, timeout_ms: u32, out_len: *i32): i32 {
  let opcode: i32 = 0;
  if (buf == 0 || out_len == 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  unsafe { return net_ws_read_frame_c(stream.fd, stream.tls_ctx, &opcode, buf, cap, out_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_close_stream`.
 * Implements `ws_close_stream`.
 * @param stream SioWsStream
 * @return i32
 */
export function ws_close_stream(stream: SioWsStream): i32 {
  let zero: i64 = 0;
  if (stream.tls_ctx != zero) {
    unsafe { net_tls_close_c(stream.tls_ctx); }
  }
  if (stream.fd < 0) { return 0; }
  unsafe { return net_close_socket_c(stream.fd); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 * See implementation.
 */
export function client_ws_ns_event_roundtrip(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, ns: *u8, ns_len: i32,
  event: *u8, event_len: i32, data: *u8, data_len: i32, url_buf: *u8, url_cap: i32, reply_event: *u8,
  reply_event_cap: i32, reply_data: *u8, reply_data_cap: i32, reply_data_len: *i32, timeout_ms: u32): i32 {
  let stream: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let frame: u8[256] = [];
  let payload: u8[128] = [];
  let flen: i32 = 0;
  let etype: i32 = -1;
  let plen: i32 = 0;
  if (http_base == 0 || sid == 0 || event == 0 || url_buf == 0) { return -1; }
  if (reply_event == 0 || reply_data == 0 || reply_data_len == 0) { return -1; }
  stream = connect_ws_ns(http_base, base_len, sid, sid_len, ns, ns_len, url_buf, url_cap, timeout_ms);
  if (stream.fd < 0) { return -1; }
  if (emit_event_ws(stream, event, event_len, data, data_len) < 0) {
    ws_close_stream(stream);
    return -2;
  }
  if (ws_read_text(stream, &frame[0], 256, timeout_ms, &flen) != 0) {
    ws_close_stream(stream);
    return -3;
  }
  if (flen < 4) {
    ws_close_stream(stream);
    return -4;
  }
  if (eio_decode_packet(&frame[0], flen, &etype, &payload[0], 128, &plen) != 0) {
    ws_close_stream(stream);
    return -5;
  }
  if (etype != eio_type_message()) {
    ws_close_stream(stream);
    return -6;
  }
  if (sio_decode_event(&payload[0], plen, reply_event, reply_event_cap, reply_data, reply_data_cap,
    reply_data_len) != 0) {
    ws_close_stream(stream);
    return -7;
  }
  ws_close_stream(stream);
  return 0;
}

/** Exported function `build_ws_eio_url_fresh`.
 * Implements `build_ws_eio_url_fresh`.
 * @param http_base *u8
 * @param base_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_ws_eio_url_fresh(http_base: *u8, base_len: i32, out: *u8, out_cap: i32): i32 {
  let ws: u8[128] = [];
  let wl: i32 = 0;
  let empty: u8[1] = [0];
  if (http_base == 0 || out == 0) { return -1; }
  wl = http_to_ws_base(http_base, base_len, &ws[0], 128);
  if (wl <= 0) { return -1; }
  return build_eio_url(&ws[0], wl, &empty[0], 0, transport_websocket(), out, out_cap);
}

/** Exported function `connect_ws_fresh`.
 * Implements `connect_ws_fresh`.
 * @param http_base *u8
 * @param base_len i32
 * @param url_buf *u8
 * @param url_cap i32
 * @param timeout_ms u32
 * @return SioWsStream
 */
export function connect_ws_fresh(http_base: *u8, base_len: i32, url_buf: *u8, url_cap: i32, timeout_ms: u32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let fd: i32 = -1;
  let tls: i64 = 0;
  let n: i32 = 0;
  let key: u8[1] = [0];
  let open_buf: u8[512] = [];
  let olen: i32 = 0;
  let stream: SioWsStream = bad;
  if (http_base == 0 || url_buf == 0) { return bad; }
  n = build_ws_eio_url_fresh(http_base, base_len, url_buf, url_cap);
  if (n <= 0) { return bad; }
  let ws_rc: i32 = 0;
  unsafe { ws_rc = net_ws_connect_url_c(url_buf, n, &key[0], 0, timeout_ms, &fd, &tls); }
  if (ws_rc != 0) { return bad; }
  stream.fd = fd;
  stream.tls_ctx = tls;
  if (ws_read_text(stream, &open_buf[0], 512, timeout_ms, &olen) != 0) {
    ws_close_stream(stream);
    return bad;
  }
  if (olen < 2 || open_buf[0] != 48) {
    ws_close_stream(stream);
    return bad;
  }
  return stream;
}

/* See implementation. */
export function connect_ws_fresh_ns(http_base: *u8, base_len: i32, ns: *u8, ns_len: i32, url_buf: *u8, url_cap: i32,
  timeout_ms: u32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let stream: SioWsStream = bad;
  let ack: u8[256] = [];
  let alen: i32 = 0;
  stream = connect_ws_fresh(http_base, base_len, url_buf, url_cap, timeout_ms);
  if (stream.fd < 0) { return bad; }
  if (send_connect_ns_packet(stream, ns, ns_len) < 0) {
    ws_close_stream(stream);
    return bad;
  }
  /* See implementation. */
  if (ws_read_text(stream, &ack[0], 256, timeout_ms, &alen) != 0) {
    alen = 0;
  }
  return stream;
}

/* See implementation. */
export function client_ws_fresh_ns_event_roundtrip(http_base: *u8, base_len: i32, ns: *u8, ns_len: i32, event: *u8,
  event_len: i32, data: *u8, data_len: i32, url_buf: *u8, url_cap: i32, reply_event: *u8, reply_event_cap: i32,
  reply_data: *u8, reply_data_cap: i32, reply_data_len: *i32, timeout_ms: u32): i32 {
  let stream: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let frame: u8[256] = [];
  let payload: u8[128] = [];
  let flen: i32 = 0;
  let etype: i32 = -1;
  let plen: i32 = 0;
  if (http_base == 0 || event == 0 || url_buf == 0) { return -1; }
  if (reply_event == 0 || reply_data == 0 || reply_data_len == 0) { return -1; }
  stream = connect_ws_fresh_ns(http_base, base_len, ns, ns_len, url_buf, url_cap, timeout_ms);
  if (stream.fd < 0) { return -1; }
  if (emit_event_ws_ns(stream, ns, ns_len, event, event_len, data, data_len) < 0) {
    ws_close_stream(stream);
    return -2;
  }
  if (ws_read_text(stream, &frame[0], 256, timeout_ms, &flen) != 0) {
    ws_close_stream(stream);
    return -3;
  }
  if (flen < 4) {
    ws_close_stream(stream);
    return -4;
  }
  if (eio_decode_packet(&frame[0], flen, &etype, &payload[0], 128, &plen) != 0) {
    ws_close_stream(stream);
    return -5;
  }
  if (etype != eio_type_message()) {
    ws_close_stream(stream);
    return -6;
  }
  if (sio_decode_event(&payload[0], plen, reply_event, reply_event_cap, reply_data, reply_data_cap,
    reply_data_len) != 0) {
    ws_close_stream(stream);
    return -7;
  }
  ws_close_stream(stream);
  return 0;
}

/* See implementation. */
export function client_ws_fresh_ns_mw_roundtrip(http_base: *u8, base_len: i32, ns: *u8, ns_len: i32, auth_tok: *u8,
  auth_tok_len: i32, ping_event: *u8, ping_event_len: i32, url_buf: *u8, url_cap: i32, reply_event: *u8,
  reply_event_cap: i32, reply_data: *u8, reply_data_cap: i32, reply_data_len: *i32, timeout_ms: u32): i32 {
  let stream: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let frame: u8[256] = [];
  let payload: u8[128] = [];
  let flen: i32 = 0;
  let etype: i32 = -1;
  let plen: i32 = 0;
  let auth_ev: u8[8] = [97, 117, 116, 104, 0];
  if (http_base == 0 || auth_tok == 0 || ping_event == 0 || url_buf == 0) { return -1; }
  if (reply_event == 0 || reply_data == 0 || reply_data_len == 0) { return -1; }
  stream = connect_ws_fresh_ns(http_base, base_len, ns, ns_len, url_buf, url_cap, timeout_ms);
  if (stream.fd < 0) { return -1; }
  if (emit_event_ws_ns(stream, ns, ns_len, &auth_ev[0], 4, auth_tok, auth_tok_len) < 0) {
    ws_close_stream(stream);
    return -2;
  }
  if (ws_read_text(stream, &frame[0], 256, timeout_ms, &flen) != 0) {
    ws_close_stream(stream);
    return -3;
  }
  if (flen < 4 || eio_decode_packet(&frame[0], flen, &etype, &payload[0], 128, &plen) != 0) {
    ws_close_stream(stream);
    return -4;
  }
  if (etype != eio_type_message()) {
    ws_close_stream(stream);
    return -5;
  }
  if (sio_decode_event(&payload[0], plen, reply_event, reply_event_cap, reply_data, reply_data_cap,
    reply_data_len) != 0) {
    ws_close_stream(stream);
    return -6;
  }
  if (emit_event_ws_ns(stream, ns, ns_len, ping_event, ping_event_len, auth_tok, 1) < 0) {
    ws_close_stream(stream);
    return -7;
  }
  flen = 0;
  plen = 0;
  if (ws_read_text(stream, &frame[0], 256, timeout_ms, &flen) != 0) {
    ws_close_stream(stream);
    return -8;
  }
  if (flen < 4 || eio_decode_packet(&frame[0], flen, &etype, &payload[0], 128, &plen) != 0) {
    ws_close_stream(stream);
    return -9;
  }
  if (etype != eio_type_message()) {
    ws_close_stream(stream);
    return -10;
  }
  if (sio_decode_event(&payload[0], plen, reply_event, reply_event_cap, reply_data, reply_data_cap,
    reply_data_len) != 0) {
    ws_close_stream(stream);
    return -11;
  }
  ws_close_stream(stream);
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function connect(c: *SioClient, base_url: *u8, base_len: i32, sid_out: *u8, sid_cap: i32, url_buf: *u8, url_cap: i32,
  timeout_ms: u32, prefer_ws: i32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let stream: SioWsStream = bad;
  if (c == 0 || base_url == 0 || sid_out == 0 || url_buf == 0) { return bad; }
  if (connect_handshake(c, base_url, base_len, sid_out, sid_cap, timeout_ms) <= 0) { return bad; }
  if (prefer_ws != 0 && c.has_websocket != 0) {
    c.transport = transport_websocket();
    stream = connect_ws(base_url, base_len, sid_out, c.sid_len, url_buf, url_cap, timeout_ms);
    if (stream.fd >= 0) {
      if (send_connect_packet(stream) >= 0) {
        reconnect_reset(c);
        return stream;
      }
      ws_close_stream(stream);
    }
  }
  c.transport = transport_polling();
  return bad;
}

/**
 * See implementation.
 * See implementation.
 */
export function connect_ns(c: *SioClient, base_url: *u8, base_len: i32, sid_out: *u8, sid_cap: i32, ns: *u8, ns_len: i32,
  url_buf: *u8, url_cap: i32, timeout_ms: u32, prefer_ws: i32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  let stream: SioWsStream = bad;
  if (c == 0 || base_url == 0 || sid_out == 0 || url_buf == 0) { return bad; }
  if (connect_handshake(c, base_url, base_len, sid_out, sid_cap, timeout_ms) <= 0) { return bad; }
  if (prefer_ws != 0 && c.has_websocket != 0) {
    c.transport = transport_websocket();
    stream = connect_ws_ns(base_url, base_len, sid_out, c.sid_len, ns, ns_len, url_buf, url_cap, timeout_ms);
    if (stream.fd >= 0) {
      reconnect_reset(c);
      return stream;
    }
  }
  c.transport = transport_polling();
  return bad;
}

/** Exported function `reconnect_delay`.
 * Implements `reconnect_delay`.
 * @param c *SioClient
 * @param cap_ms i32
 * @return i32
 */
export function reconnect_delay(c: *SioClient, cap_ms: i32): i32 {
  if (c == 0) { return -1; }
  let d: i32 = reconnect_delay_ms(c.reconnect_attempt, cap_ms);
  c.reconnect_attempt = c.reconnect_attempt + 1;
  return d;
}

/** Exported function `can_reconnect`.
 * Implements `can_reconnect`.
 * @param c *SioClient
 * @return bool
 */
export function can_reconnect(c: *SioClient): bool {
  if (c == 0) { return false; }
  if (c.max_reconnect < 0) { return true; }
  if (c.reconnect_attempt < c.max_reconnect) { return true; }
  return false;
}

/** Exported function `reconnect_reset`.
 * Implements `reconnect_reset`.
 * @param c *SioClient
 * @return void
 */
export function reconnect_reset(c: *SioClient): void {
  if (c == 0) { return; }
  c.reconnect_attempt = 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function reconnect_once(c: *SioClient, base_url: *u8, base_len: i32, sid_out: *u8, sid_cap: i32, url_buf: *u8,
  url_cap: i32, timeout_ms: u32, prefer_ws: i32): SioWsStream {
  let bad: SioWsStream = SioWsStream { fd: -1, tls_ctx: 0 };
  if (c == 0) { return bad; }
  if (!can_reconnect(c)) { return bad; }
  c.sid_len = 0;
  return connect(c, base_url, base_len, sid_out, sid_cap, url_buf, url_cap, timeout_ms, prefer_ws);
}

/** Exported function `emit_event_ws`.
 * Implements `emit_event_ws`.
 * @param stream SioWsStream
 * @param event *u8
 * @param event_len i32
 * @param data *u8
 * @param data_len i32
 * @return i32
 */
export function emit_event_ws(stream: SioWsStream, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (event == 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  n = sio_encode_event(event, event_len, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function emit_event_ws_ns(stream: SioWsStream, ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8,
  data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (event == 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  n = sio_encode_event_ns(ns, ns_len, event, event_len, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function emit_event_ack_ws(stream: SioWsStream, ack_id: i32, event: *u8, event_len: i32, data: *u8,
  data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (event == 0) { return -1; }
  if (stream.fd < 0) { return -1; }
  n = encode_event_ack_packet(ack_id, event, event_len, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `emit_ack_ws`.
 * Implements `emit_ack_ws`.
 * @param stream SioWsStream
 * @param ack_id i32
 * @param data *u8
 * @param data_len i32
 * @return i32
 */
export function emit_ack_ws(stream: SioWsStream, ack_id: i32, data: *u8, data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (stream.fd < 0) { return -1; }
  n = encode_ack_packet(ack_id, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_text_c(stream.fd, stream.tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `node_golden_smoke`.
 * Implements `node_golden_smoke`.
 * @return i32
 */
export function node_golden_smoke(): i32 {
  unsafe { return sio_node_interop_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_build_open_packet`.
 * Implements `server_build_open_packet`.
 * @param sid *u8
 * @param sid_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function server_build_open_packet(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {
  if (sid == 0 || out == 0) { return -1; }
  unsafe { return sio_server_build_open_packet_c(sid, sid_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_build_http_open_response`.
 * Implements `server_build_http_open_response`.
 * @param sid *u8
 * @param sid_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function server_build_http_open_response(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {
  if (sid == 0 || out == 0) { return -1; }
  unsafe { return sio_server_build_http_open_response_c(sid, sid_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_is_polling_handshake`.
 * Implements `server_is_polling_handshake`.
 * @param path *u8
 * @param len i32
 * @return i32
 */
export function server_is_polling_handshake(path: *u8, len: i32): i32 {
  if (path == 0) { return -1; }
  unsafe { return sio_server_is_polling_handshake_c(path, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_is_connect_packet`.
 * Implements `server_is_connect_packet`.
 * @param pkt *u8
 * @param len i32
 * @return i32
 */
export function server_is_connect_packet(pkt: *u8, len: i32): i32 {
  if (pkt == 0) { return -1; }
  unsafe { return sio_server_is_connect_packet_c(pkt, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_is_connect_ns_packet`.
 * Implements `server_is_connect_ns_packet`.
 * @param pkt *u8
 * @param len i32
 * @param ns *u8
 * @param ns_len i32
 * @return i32
 */
export function server_is_connect_ns_packet(pkt: *u8, len: i32, ns: *u8, ns_len: i32): i32 {
  if (pkt == 0) { return -1; }
  unsafe { return sio_server_is_connect_ns_packet_c(pkt, len, ns, ns_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_smoke`.
 * Implements `server_smoke`.
 * @return i32
 */
export function server_smoke(): i32 {
  unsafe { return sio_server_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_emit_event`.
 * Implements `server_emit_event`.
 * @param event *u8
 * @param event_len i32
 * @param data *u8
 * @param data_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function server_emit_event(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {
  if (event == 0 || out == 0) { return -1; }
  unsafe { return sio_server_emit_event_c(event, event_len, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function server_build_http_event_response(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8,
  out_cap: i32): i32 {
  if (event == 0 || out == 0) { return -1; }
  unsafe { return sio_server_build_http_event_response_c(event, event_len, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_emit_smoke`.
 * Implements `server_emit_smoke`.
 * @return i32
 */
export function server_emit_smoke(): i32 {
  unsafe { return sio_server_emit_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_emit_event_ws`.
 * Implements `server_emit_event_ws`.
 * @param fd i32
 * @param tls_ctx i64
 * @param event *u8
 * @param event_len i32
 * @param data *u8
 * @param data_len i32
 * @return i32
 */
export function server_emit_event_ws(fd: i32, tls_ctx: i64, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (event == 0) { return -1; }
  if (fd < 0) { return -1; }
  n = server_emit_event(event, event_len, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_server_text_c(fd, tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function server_emit_event_ws_ns(fd: i32, tls_ctx: i64, ns: *u8, ns_len: i32, event: *u8, event_len: i32,
  data: *u8, data_len: i32): i32 {
  let frame: u8[256] = [];
  let n: i32 = 0;
  if (event == 0) { return -1; }
  if (fd < 0) { return -1; }
  n = sio_encode_event_ns(ns, ns_len, event, event_len, data, data_len, &frame[0], 256);
  if (n <= 0) { return -1; }
  unsafe { return net_ws_write_server_text_c(fd, tls_ctx, &frame[0], n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `server_build_connect_ns_ack`.
 * Implements `server_build_connect_ns_ack`.
 * @param ns *u8
 * @param ns_len i32
 * @param sid *u8
 * @param sid_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function server_build_connect_ns_ack(ns: *u8, ns_len: i32, sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {
  if (sid == 0 || out == 0) { return -1; }
  unsafe { return sio_server_build_connect_ns_ack_c(ns, ns_len, sid, sid_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function encode_event_ack_packet(ack_id: i32, event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8,
  out_cap: i32): i32 {
  if (event == 0 || out == 0) { return -1; }
  unsafe { return sio_encode_event_ack_packet_c(ack_id, event, event_len, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `encode_ack_packet`.
 * Implements `encode_ack_packet`.
 * @param ack_id i32
 * @param data *u8
 * @param data_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encode_ack_packet(ack_id: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {
  if (out == 0) { return -1; }
  unsafe { return sio_encode_ack_packet_c(ack_id, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `parse_sio_packet_head`.
 * Implements `parse_sio_packet_head`.
 * @param pkt *u8
 * @param len i32
 * @param out_type *i32
 * @param out_id *i32
 * @param out_payload_off *i32
 * @return i32
 */
export function parse_sio_packet_head(pkt: *u8, len: i32, out_type: *i32, out_id: *i32, out_payload_off: *i32): i32 {
  if (pkt == 0 || out_type == 0 || out_payload_off == 0) { return -1; }
  unsafe { return sio_parse_sio_packet_head_c(pkt, len, out_type, out_id, out_payload_off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_ack_smoke`.
 * Implements `ns_ack_smoke`.
 * @return i32
 */
export function ns_ack_smoke(): i32 {
  unsafe { return sio_ns_ack_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `parse_connect_ns`.
 * Implements `parse_connect_ns`.
 * @param pkt *u8
 * @param len i32
 * @param out_ns *u8
 * @param out_cap i32
 * @return i32
 */
export function parse_connect_ns(pkt: *u8, len: i32, out_ns: *u8, out_cap: i32): i32 {
  if (pkt == 0 || out_ns == 0) { return -1; }
  unsafe { return sio_parse_connect_ns_packet_c(pkt, len, out_ns, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_router_bytes`.
 * Implements `ns_router_bytes`.
 * @return i32
 */
export function ns_router_bytes(): i32 {
  unsafe { return sio_ns_router_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_router_init`.
 * Implements `ns_router_init`.
 * @param r *SioNsRouter
 * @return void
 */
export function ns_router_init(r: *SioNsRouter): void {
  if (r == 0) { return; }
  unsafe { sio_ns_router_init_c(r); }
}

/** Exported function `ns_router_register`.
 * Registration helper `ns_router_register`.
 * @param r *SioNsRouter
 * @param ns *u8
 * @param ns_len i32
 * @param slot_id i32
 * @return i32
 */
export function ns_router_register(r: *SioNsRouter, ns: *u8, ns_len: i32, slot_id: i32): i32 {
  if (r == 0) { return -1; }
  unsafe { return sio_ns_router_register_c(r, ns, ns_len, slot_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_router_lookup`.
 * Implements `ns_router_lookup`.
 * @param r *SioNsRouter
 * @param ns *u8
 * @param ns_len i32
 * @return i32
 */
export function ns_router_lookup(r: *SioNsRouter, ns: *u8, ns_len: i32): i32 {
  if (r == 0) { return -1; }
  unsafe { return sio_ns_router_lookup_c(r, ns, ns_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_router_route_connect`.
 * Implements `ns_router_route_connect`.
 * @param r *SioNsRouter
 * @param pkt *u8
 * @param len i32
 * @return i32
 */
export function ns_router_route_connect(r: *SioNsRouter, pkt: *u8, len: i32): i32 {
  if (r == 0) { return -1; }
  unsafe { return sio_ns_router_route_connect_c(r, pkt, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_router_smoke`.
 * Implements `ns_router_smoke`.
 * @return i32
 */
export function ns_router_smoke(): i32 {
  unsafe { return sio_ns_router_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_bytes`.
 * Implements `ns_sessions_bytes`.
 * @return i32
 */
export function ns_sessions_bytes(): i32 {
  unsafe { return sio_ns_sessions_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_init`.
 * Implements `ns_sessions_init`.
 * @param s *SioNsSessions
 * @return void
 */
export function ns_sessions_init(s: *SioNsSessions): void {
  if (s == 0) { return; }
  unsafe { sio_ns_sessions_init_c(s); }
}

/** Exported function `ns_sessions_sync_router`.
 * Implements `ns_sessions_sync_router`.
 * @param s *SioNsSessions
 * @param r *SioNsRouter
 * @return i32
 */
export function ns_sessions_sync_router(s: *SioNsSessions, r: *SioNsRouter): i32 {
  if (s == 0 || r == 0) { return -1; }
  unsafe { return sio_ns_sessions_sync_router_c(s, r); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_connect`.
 * Implements `ns_sessions_connect`.
 * @param s *SioNsSessions
 * @param r *SioNsRouter
 * @param pkt *u8
 * @param len i32
 * @return i32
 */
export function ns_sessions_connect(s: *SioNsSessions, r: *SioNsRouter, pkt: *u8, len: i32): i32 {
  if (s == 0 || r == 0) { return -1; }
  unsafe { return sio_ns_sessions_connect_c(s, r, pkt, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_disconnect`.
 * Implements `ns_sessions_disconnect`.
 * @param s *SioNsSessions
 * @param slot_id i32
 * @return i32
 */
export function ns_sessions_disconnect(s: *SioNsSessions, slot_id: i32): i32 {
  if (s == 0) { return -1; }
  unsafe { return sio_ns_sessions_disconnect_c(s, slot_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_active`.
 * Implements `ns_sessions_active`.
 * @param s *SioNsSessions
 * @param slot_id i32
 * @return i32
 */
export function ns_sessions_active(s: *SioNsSessions, slot_id: i32): i32 {
  if (s == 0) { return -1; }
  unsafe { return sio_ns_sessions_active_c(s, slot_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_total`.
 * Implements `ns_sessions_total`.
 * @param s *SioNsSessions
 * @return i32
 */
export function ns_sessions_total(s: *SioNsSessions): i32 {
  if (s == 0) { return -1; }
  unsafe { return sio_ns_sessions_total_c(s); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ns_sessions_smoke`.
 * Implements `ns_sessions_smoke`.
 * @return i32
 */
export function ns_sessions_smoke(): i32 {
  unsafe { return sio_ns_sessions_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_bytes`.
 * Implements `ws_hub_bytes`.
 * @return i32
 */
export function ws_hub_bytes(): i32 {
  unsafe { return sio_ws_hub_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_init`.
 * Implements `ws_hub_init`.
 * @param h *SioWsHub
 * @return void
 */
export function ws_hub_init(h: *SioWsHub): void {
  if (h == 0) { return; }
  unsafe { sio_ws_hub_init_c(h); }
}

/** Exported function `ws_hub_register`.
 * Registration helper `ws_hub_register`.
 * @param h *SioWsHub
 * @param fd i32
 * @param tls_ctx i64
 * @param sid *u8
 * @param sid_len i32
 * @return i32
 */
export function ws_hub_register(h: *SioWsHub, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32 {
  if (h == 0 || sid == 0) { return -1; }
  unsafe { return sio_ws_hub_register_c(h, fd, tls_ctx, sid, sid_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_unregister`.
 * Registration helper `ws_hub_unregister`.
 * @param h *SioWsHub
 * @param conn_idx i32
 * @return i32
 */
export function ws_hub_unregister(h: *SioWsHub, conn_idx: i32): i32 {
  if (h == 0) { return -1; }
  unsafe { return sio_ws_hub_unregister_c(h, conn_idx); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_find_by_sid`.
 * Implements `ws_hub_find_by_sid`.
 * @param h *SioWsHub
 * @param sid *u8
 * @param sid_len i32
 * @return i32
 */
export function ws_hub_find_by_sid(h: *SioWsHub, sid: *u8, sid_len: i32): i32 {
  if (h == 0 || sid == 0) { return -1; }
  unsafe { return sio_ws_hub_find_by_sid_c(h, sid, sid_len); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function ws_hub_handle_connect(h: *SioWsHub, conn_idx: i32, r: *SioNsRouter, s: *SioNsSessions, pkt: *u8,
  len: i32): i32 {
  if (h == 0 || r == 0 || s == 0) { return -1; }
  unsafe { return sio_ws_hub_handle_connect_c(h, conn_idx, r, s, pkt, len); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function ws_hub_emit_to_slot(h: *SioWsHub, slot_id: i32, ns: *u8, ns_len: i32, event: *u8, event_len: i32,
  data: *u8, data_len: i32): i32 {
  if (h == 0 || event == 0) { return -1; }
  unsafe { return sio_ws_hub_emit_event_ns_c(h, slot_id, ns, ns_len, event, event_len, data, data_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_smoke`.
 * Implements `ws_hub_smoke`.
 * @return i32
 */
export function ws_hub_smoke(): i32 {
  unsafe { return sio_ws_hub_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_snapshot_bytes`.
 * Implements `ws_hub_snapshot_bytes`.
 * @return i32
 */
export function ws_hub_snapshot_bytes(): i32 {
  unsafe { return sio_ws_hub_snapshot_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_export`.
 * Implements `ws_hub_export`.
 * @param h *SioWsHub
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_hub_export(h: *SioWsHub, out: *u8, out_cap: i32): i32 {
  if (h == 0 || out == 0) { return -1; }
  unsafe { return sio_ws_hub_export_c(h, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_import`.
 * Implements `ws_hub_import`.
 * @param h *SioWsHub
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function ws_hub_import(h: *SioWsHub, buf: *u8, len: i32): i32 {
  if (h == 0 || buf == 0) { return -1; }
  unsafe { return sio_ws_hub_import_c(h, buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_bytes`.
 * Implements `room_registry_bytes`.
 * @return i32
 */
export function room_registry_bytes(): i32 {
  unsafe { return sio_room_registry_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_init`.
 * Implements `room_registry_init`.
 * @param reg *SioRoomRegistry
 * @return void
 */
export function room_registry_init(reg: *SioRoomRegistry): void {
  if (reg == 0) { return; }
  unsafe { sio_room_registry_init_c(reg); }
}

/** Exported function `room_register`.
 * Registration helper `room_register`.
 * @param reg *SioRoomRegistry
 * @param name *u8
 * @param name_len i32
 * @param room_id i32
 * @return i32
 */
export function room_register(reg: *SioRoomRegistry, name: *u8, name_len: i32, room_id: i32): i32 {
  if (reg == 0 || name == 0) { return -1; }
  unsafe { return sio_room_register_c(reg, name, name_len, room_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_join`.
 * Implements `room_join`.
 * @param reg *SioRoomRegistry
 * @param room_id i32
 * @param conn_idx i32
 * @return i32
 */
export function room_join(reg: *SioRoomRegistry, room_id: i32, conn_idx: i32): i32 {
  if (reg == 0) { return -1; }
  unsafe { return sio_room_join_c(reg, room_id, conn_idx); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_leave`.
 * Implements `room_leave`.
 * @param reg *SioRoomRegistry
 * @param room_id i32
 * @param conn_idx i32
 * @return i32
 */
export function room_leave(reg: *SioRoomRegistry, room_id: i32, conn_idx: i32): i32 {
  if (reg == 0) { return -1; }
  unsafe { return sio_room_leave_c(reg, room_id, conn_idx); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_leave_all`.
 * Implements `room_leave_all`.
 * @param reg *SioRoomRegistry
 * @param conn_idx i32
 * @return i32
 */
export function room_leave_all(reg: *SioRoomRegistry, conn_idx: i32): i32 {
  if (reg == 0) { return -1; }
  unsafe { return sio_room_leave_all_c(reg, conn_idx); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_member_count`.
 * Implements `room_member_count`.
 * @param reg *SioRoomRegistry
 * @param room_id i32
 * @return i32
 */
export function room_member_count(reg: *SioRoomRegistry, room_id: i32): i32 {
  if (reg == 0) { return -1; }
  unsafe { return sio_room_member_count_c(reg, room_id); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function room_broadcast_ns(reg: *SioRoomRegistry, h: *SioWsHub, room_id: i32, ns: *u8, ns_len: i32, event: *u8,
  event_len: i32, data: *u8, data_len: i32): i32 {
  if (reg == 0 || h == 0 || event == 0) { return -1; }
  unsafe { return sio_room_broadcast_ns_c(reg, h, room_id, ns, ns_len, event, event_len, data, data_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_smoke`.
 * Implements `room_smoke`.
 * @return i32
 */
export function room_smoke(): i32 {
  unsafe { return sio_room_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_rebind`.
 * Implements `ws_hub_rebind`.
 * @param h *SioWsHub
 * @param conn_idx i32
 * @param fd i32
 * @param tls_ctx i64
 * @return i32
 */
export function ws_hub_rebind(h: *SioWsHub, conn_idx: i32, fd: i32, tls_ctx: i64): i32 {
  if (h == 0 || fd < 0) { return -1; }
  unsafe { return sio_ws_hub_rebind_c(h, conn_idx, fd, tls_ctx); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_snapshot_bytes`.
 * Implements `room_registry_snapshot_bytes`.
 * @return i32
 */
export function room_registry_snapshot_bytes(): i32 {
  unsafe { return sio_room_registry_snapshot_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_export`.
 * Implements `room_registry_export`.
 * @param reg *SioRoomRegistry
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function room_registry_export(reg: *SioRoomRegistry, out: *u8, out_cap: i32): i32 {
  if (reg == 0 || out == 0) { return -1; }
  unsafe { return sio_room_registry_export_c(reg, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_import`.
 * Implements `room_registry_import`.
 * @param reg *SioRoomRegistry
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function room_registry_import(reg: *SioRoomRegistry, buf: *u8, len: i32): i32 {
  if (reg == 0 || buf == 0) { return -1; }
  unsafe { return sio_room_registry_import_c(reg, buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `hub_sync_smoke`.
 * Implements `hub_sync_smoke`.
 * @return i32
 */
export function hub_sync_smoke(): i32 {
  unsafe { return sio_hub_sync_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_register_or_rebind`.
 * Registration helper `ws_hub_register_or_rebind`.
 * @param h *SioWsHub
 * @param fd i32
 * @param tls_ctx i64
 * @param sid *u8
 * @param sid_len i32
 * @return i32
 */
export function ws_hub_register_or_rebind(h: *SioWsHub, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32 {
  if (h == 0 || sid == 0 || fd < 0) { return -1; }
  unsafe { return sio_ws_hub_register_or_rebind_c(h, fd, tls_ctx, sid, sid_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `session_bundle_bytes`.
 * Implements `session_bundle_bytes`.
 * @return i32
 */
export function session_bundle_bytes(): i32 {
  unsafe { return sio_session_bundle_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `session_bundle_export`.
 * Implements `session_bundle_export`.
 * @param h *SioWsHub
 * @param reg *SioRoomRegistry
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function session_bundle_export(h: *SioWsHub, reg: *SioRoomRegistry, out: *u8, out_cap: i32): i32 {
  if (h == 0 || reg == 0 || out == 0) { return -1; }
  unsafe { return sio_session_bundle_export_c(h, reg, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `session_bundle_import`.
 * Implements `session_bundle_import`.
 * @param h *SioWsHub
 * @param reg *SioRoomRegistry
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function session_bundle_import(h: *SioWsHub, reg: *SioRoomRegistry, buf: *u8, len: i32): i32 {
  if (h == 0 || reg == 0 || buf == 0) { return -1; }
  unsafe { return sio_session_bundle_import_c(h, reg, buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `session_sync_smoke`.
 * Implements `session_sync_smoke`.
 * @return i32
 */
export function session_sync_smoke(): i32 {
  unsafe { return sio_session_sync_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_hub_append_from`.
 * Implements `ws_hub_append_from`.
 * @param dst *SioWsHub
 * @param src *SioWsHub
 * @return i32
 */
export function ws_hub_append_from(dst: *SioWsHub, src: *SioWsHub): i32 {
  if (dst == 0 || src == 0) { return -1; }
  unsafe { return sio_ws_hub_append_from_c(dst, src); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `room_registry_merge_offset`.
 * Implements `room_registry_merge_offset`.
 * @param dst *SioRoomRegistry
 * @param src *SioRoomRegistry
 * @param conn_offset i32
 * @return i32
 */
export function room_registry_merge_offset(dst: *SioRoomRegistry, src: *SioRoomRegistry, conn_offset: i32): i32 {
  if (dst == 0 || src == 0 || conn_offset < 0) { return -1; }
  unsafe { return sio_room_registry_merge_offset_c(dst, src, conn_offset); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_sync`.
 * Implements `cluster_sync`.
 * @param h *SioWsHub
 * @param reg *SioRoomRegistry
 * @param bundle_a *u8
 * @param len_a i32
 * @param bundle_b *u8
 * @param len_b i32
 * @return i32
 */
export function cluster_sync(h: *SioWsHub, reg: *SioRoomRegistry, bundle_a: *u8, len_a: i32, bundle_b: *u8, len_b: i32): i32 {
  if (h == 0 || reg == 0 || bundle_a == 0 || bundle_b == 0) { return -1; }
  unsafe { return sio_cluster_sync_c(h, reg, bundle_a, len_a, bundle_b, len_b); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_sync_smoke`.
 * Implements `cluster_sync_smoke`.
 * @return i32
 */
export function cluster_sync_smoke(): i32 {
  unsafe { return sio_cluster_sync_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_bytes`.
 * Implements `cluster_adapter_bytes`.
 * @return i32
 */
export function cluster_adapter_bytes(): i32 {
  unsafe { return sio_cluster_adapter_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_init`.
 * Implements `cluster_adapter_init`.
 * @param a *SioClusterAdapter
 * @param node_id i32
 * @return void
 */
export function cluster_adapter_init(a: *SioClusterAdapter, node_id: i32): void {
  if (a == 0) { return; }
  unsafe { sio_cluster_adapter_init_c(a, node_id); }
}

/* See implementation. */
export function cluster_adapter_publish_ns(a: *SioClusterAdapter, src_node_id: i32, room_id: i32, ns: *u8, ns_len: i32,
  event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {
  if (a == 0 || event == 0) { return -1; }
  unsafe { return sio_cluster_adapter_publish_ns_c(a, src_node_id, room_id, ns, ns_len, event, event_len, data, data_len); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function cluster_adapter_drain_apply(a: *SioClusterAdapter, h: *SioWsHub, reg: *SioRoomRegistry,
  local_node_id: i32): i32 {
  if (a == 0 || h == 0 || reg == 0) { return -1; }
  unsafe { return sio_cluster_adapter_drain_apply_c(a, h, reg, local_node_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_smoke`.
 * Implements `cluster_adapter_smoke`.
 * @return i32
 */
export function cluster_adapter_smoke(): i32 {
  unsafe { return sio_cluster_adapter_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_snapshot_bytes`.
 * Implements `cluster_adapter_snapshot_bytes`.
 * @return i32
 */
export function cluster_adapter_snapshot_bytes(): i32 {
  unsafe { return sio_cluster_adapter_snapshot_bytes_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_export`.
 * Implements `cluster_adapter_export`.
 * @param a *SioClusterAdapter
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function cluster_adapter_export(a: *SioClusterAdapter, out: *u8, out_cap: i32): i32 {
  if (a == 0 || out == 0) { return -1; }
  unsafe { return sio_cluster_adapter_export_c(a, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_adapter_import_merge`.
 * Implements `cluster_adapter_import_merge`.
 * @param a *SioClusterAdapter
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function cluster_adapter_import_merge(a: *SioClusterAdapter, buf: *u8, len: i32): i32 {
  if (a == 0 || buf == 0) { return -1; }
  unsafe { return sio_cluster_adapter_import_merge_c(a, buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cluster_ring_sync_smoke`.
 * Implements `cluster_ring_sync_smoke`.
 * @return i32
 */
export function cluster_ring_sync_smoke(): i32 {
  unsafe { return sio_cluster_ring_sync_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `p3_complete_smoke`.
 * Implements `p3_complete_smoke`.
 * @return i32
 */
export function p3_complete_smoke(): i32 {
  unsafe { return sio_p3_complete_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `eio_encode_packet`.
 * Implements `eio_encode_packet`.
 * @param type i32
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function eio_encode_packet(type: i32, payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return sio_eio_encode_packet_c(type, payload, payload_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function eio_decode_packet(buf: *u8, len: i32, out_type: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32): i32 {
  if (buf == 0 || out_type == 0 || out_payload_len == 0) { return -1; }
  unsafe { return sio_eio_decode_packet_c(buf, len, out_type, out_payload, out_cap, out_payload_len); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 * See implementation.
 */
export function sio_encode_event(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {
  if (event == 0) { return -1; }
  unsafe { return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function sio_encode_event_ns(ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32,
  out: *u8, out_cap: i32): i32 {
  if (event == 0) { return -1; }
  unsafe { return sio_encode_event_ns_packet_c(ns, ns_len, event, event_len, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function sio_decode_event(sio_pkt: *u8, len: i32, out_event: *u8, out_event_cap: i32, out_data: *u8,
  out_data_cap: i32, out_data_len: *i32): i32 {
  if (sio_pkt == 0 || out_event == 0 || out_data == 0 || out_data_len == 0) { return -1; }
  unsafe { return sio_decode_event_packet_c(sio_pkt, len, out_event, out_event_cap, out_data, out_data_cap, out_data_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `eio_extract_sid`.
 * Implements `eio_extract_sid`.
 * @param open_payload *u8
 * @param len i32
 * @param out_sid *u8
 * @param out_cap i32
 * @return i32
 */
export function eio_extract_sid(open_payload: *u8, len: i32, out_sid: *u8, out_cap: i32): i32 {
  if (open_payload == 0 || out_sid == 0) { return -1; }
  unsafe { return sio_eio_extract_sid_c(open_payload, len, out_sid, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `socketio_packet_smoke`.
 * Implements `socketio_packet_smoke`.
 * @return i32
 */
export function socketio_packet_smoke(): i32 {
  unsafe { return sio_packet_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `socketio_is_implemented`.
 * Implements `socketio_is_implemented`.
 * @return i32
 */
export function socketio_is_implemented(): i32 { return 1; }
