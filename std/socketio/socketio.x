// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std/socketio/socketio.x — F-socketio v2：Engine.IO/SIO 协议逻辑（纯 .x）
//
// 【文件职责】
// EIO/SIO 编解码、polling/WS URL、namespace 路由、WS hub、room、cluster adapter 与全部烟测。
// HTTP/WS IO 经 extern http_* / net_ws_*；经 ld -r 单独编译为 socketio_main.o 再合并 socketio.o。
// 对外 API 在 mod.x（sio_*_c 符号供 mod extern 绑定）。



const SIO_EIO_OPEN: i32 = 0;
const SIO_EIO_CLOSE: i32 = 1;
const SIO_EIO_PING: i32 = 2;
const SIO_EIO_PONG: i32 = 3;
const SIO_EIO_MESSAGE: i32 = 4;
const SIO_EIO_UPGRADE: i32 = 5;
const SIO_EIO_NOOP: i32 = 6;
const SIO_SIO_EVENT: i32 = 2;
const SIO_SIO_CONNECT: i32 = 0;
const SIO_SIO_ACK: i32 = 3;
const SIO_EIO_VERSION: i32 = 4;
const SIO_TRANSPORT_POLLING: i32 = 0;
const SIO_TRANSPORT_WEBSOCKET: i32 = 1;
const SIO_NS_ROUTER_MAX: i32 = 4;
const SIO_NS_NAME_CAP: i32 = 24;
const SIO_WS_HUB_MAX: i32 = 4;
const SIO_WS_SID_CAP: i32 = 24;
const SIO_ROOM_MAX: i32 = 4;
const SIO_ROOM_NAME_CAP: i32 = 16;
const SIO_ROOM_MEMBERS_MAX: i32 = 4;
const SIO_HUB_SNAP_MAGIC: u32 = 0x53494F48;
const SIO_HUB_SNAP_VERSION: i32 = 1;
const SIO_ROOM_SNAP_MAGIC: u32 = 0x53494F52;
const SIO_ROOM_SNAP_VERSION: i32 = 1;
const SIO_SESSION_SNAP_MAGIC: u32 = 0x53494F53;
const SIO_SESSION_SNAP_VERSION: i32 = 1;
const SIO_CLUSTER_ADAPTER_MAX: i32 = 4;
const SIO_CLUSTER_ADAPTER_NS_CAP: i32 = 16;
const SIO_CLUSTER_ADAPTER_EVT_CAP: i32 = 16;
const SIO_CLUSTER_ADAPTER_DATA_CAP: i32 = 16;
const SIO_ADAPTER_SNAP_MAGIC: u32 = 0x53494F41;
const SIO_ADAPTER_SNAP_VERSION: i32 = 1;

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const SIO_LIT_JSON_SID_PREFIX: u8[9] = [123, 34, 115, 105, 100, 34, 58, 34, 0];
const SIO_LIT_JSON_SID_SUFFIX: u8[3] = [34, 125, 0];
const SIO_LIT_SID_QUERY: u8[5] = [115, 105, 100, 61, 0];
const SIO_LIT_NS_ROOT: u8[2] = [47, 0];
const SIO_LIT_NULL: u8[5] = [110, 117, 108, 108, 0];
const SIO_LIT_OK: u8[3] = [111, 107, 0];
const SIO_LIT_MSG: u8[4] = [109, 115, 103, 0];
const SIO_LIT_HI: u8[3] = [104, 105, 0];
const SIO_LIT_X: u8[2] = [120, 0];
const SIO_LIT_WORLD: u8[6] = [119, 111, 114, 108, 100, 0];
const SIO_LIT_N40: u8[3] = [52, 48, 0];
const SIO_LIT_N3PROBE: u8[7] = [51, 112, 114, 111, 98, 101, 0];
const SIO_LIT_HTTP_127_0_0_1_3000_SOCKET_IO_EIO_4_TRANSPORT_POLLING: u8[57] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 51, 48, 48, 48, 47, 115, 111, 99, 107, 101, 116, 46, 105, 111, 47, 63, 69, 73, 79, 61, 52, 38, 116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 112, 111, 108, 108, 105, 110, 103, 0];
const SIO_LIT_WS_127_0_0_1_3000: u8[20] = [119, 115, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 51, 48, 48, 48, 0];
const SIO_LIT_WSS_EXAMPLE_COM_8443: u8[23] = [119, 115, 115, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109, 58, 56, 52, 52, 51, 0];
/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const SIO_LIT_ADMIN: u8[7] = [47, 97, 100, 109, 105, 110, 0];
const SIO_LIT_UNKNOWN: u8[9] = [47, 117, 110, 107, 110, 111, 119, 110, 0];
const SIO_LIT_SUB: u8[4] = [115, 117, 98, 0];
const SIO_LIT_CHAT: u8[6] = [47, 99, 104, 97, 116, 0];
const SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING: u8[36] = [47, 115, 111, 99, 107, 101, 116, 46, 105, 111, 47, 63, 69, 73, 79, 61, 52, 38, 116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 112, 111, 108, 108, 105, 110, 103, 0];
const SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING_SID_X: u8[42] = [47, 115, 111, 99, 107, 101, 116, 46, 105, 111, 47, 63, 69, 73, 79, 61, 52, 38, 116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 112, 111, 108, 108, 105, 110, 103, 38, 115, 105, 100, 61, 120, 0];
const SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING_T_ABC: u8[42] = [47, 115, 111, 99, 107, 101, 116, 46, 105, 111, 47, 63, 69, 73, 79, 61, 52, 38, 116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 112, 111, 108, 108, 105, 110, 103, 38, 116, 61, 97, 98, 99, 0];
const SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_WEBSOCKET: u8[38] = [47, 115, 111, 99, 107, 101, 116, 46, 105, 111, 47, 63, 69, 73, 79, 61, 52, 38, 116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 119, 101, 98, 115, 111, 99, 107, 101, 116, 0];
const SIO_LIT_N0: u8[2] = [48, 0];
const SIO_LIT_N2PROBE: u8[7] = [50, 112, 114, 111, 98, 101, 0];
const SIO_LIT_N40_CHAT: u8[9] = [52, 48, 47, 99, 104, 97, 116, 44, 0];
const SIO_LIT_N42_CHAT_MESSAGE_HELLO: u8[27] = [52, 50, 91, 34, 99, 104, 97, 116, 32, 109, 101, 115, 115, 97, 103, 101, 34, 44, 34, 104, 101, 108, 108, 111, 34, 93, 0];
const SIO_LIT_N42_NEWS_UPDATE: u8[20] = [52, 50, 91, 34, 110, 101, 119, 115, 34, 44, 34, 117, 112, 100, 97, 116, 101, 34, 93, 0];
const SIO_LIT_N5: u8[2] = [53, 0];
const SIO_LIT_EIO_4: u8[6] = [69, 73, 79, 61, 52, 0];
const SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_CHARSET_UTF_8_R_CONNECTION_KEEP_ALIVE_R_CONTENT_LENGTH: u8[102] = [72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 48, 32, 79, 75, 92, 114, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 116, 101, 120, 116, 47, 112, 108, 97, 105, 110, 59, 32, 99, 104, 97, 114, 115, 101, 116, 61, 85, 84, 70, 45, 56, 92, 114, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32, 107, 101, 101, 112, 45, 97, 108, 105, 118, 101, 92, 114, 10, 67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32, 0];
const SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_CHARSET_UTF_8_R_CONNECTION_KEEP_ALIVE_R_R_0_SID_OXLMYI_UPGRADES_WEBSOCKET_PINGINTERVAL_25000_PINGTIMEOUT_20000_MAXPAYLOAD_1000000: u8[193] = [72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 48, 32, 79, 75, 92, 114, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 116, 101, 120, 116, 47, 112, 108, 97, 105, 110, 59, 32, 99, 104, 97, 114, 115, 101, 116, 61, 85, 84, 70, 45, 56, 92, 114, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32, 107, 101, 101, 112, 45, 97, 108, 105, 118, 101, 92, 114, 10, 92, 114, 10, 48, 123, 34, 115, 105, 100, 34, 58, 34, 111, 88, 76, 77, 121, 105, 34, 44, 34, 117, 112, 103, 114, 97, 100, 101, 115, 34, 58, 91, 34, 119, 101, 98, 115, 111, 99, 107, 101, 116, 34, 93, 44, 34, 112, 105, 110, 103, 73, 110, 116, 101, 114, 118, 97, 108, 34, 58, 50, 53, 48, 48, 48, 44, 34, 112, 105, 110, 103, 84, 105, 109, 101, 111, 117, 116, 34, 58, 50, 48, 48, 48, 48, 44, 34, 109, 97, 120, 80, 97, 121, 108, 111, 97, 100, 34, 58, 49, 48, 48, 48, 48, 48, 48, 125, 0];
const SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_R_CONTENT_LENGTH_52_R_R_0_SID_ABC123_UPGRADES_WEBSOCKET_PINGINTERVAL_25000: u8[133] = [72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 48, 32, 79, 75, 92, 114, 10, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 116, 101, 120, 116, 47, 112, 108, 97, 105, 110, 92, 114, 10, 67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32, 53, 50, 92, 114, 10, 92, 114, 10, 48, 123, 34, 115, 105, 100, 34, 58, 34, 97, 98, 99, 49, 50, 51, 34, 44, 34, 117, 112, 103, 114, 97, 100, 101, 115, 34, 58, 91, 34, 119, 101, 98, 115, 111, 99, 107, 101, 116, 34, 93, 44, 34, 112, 105, 110, 103, 73, 110, 116, 101, 114, 118, 97, 108, 34, 58, 50, 53, 48, 48, 48, 125, 0];
const SIO_LIT_UPGRADES_WEBSOCKET_PINGINTERVAL_25000_PINGTIMEOUT_20000: u8[69] = [34, 44, 34, 117, 112, 103, 114, 97, 100, 101, 115, 34, 58, 91, 34, 119, 101, 98, 115, 111, 99, 107, 101, 116, 34, 93, 44, 34, 112, 105, 110, 103, 73, 110, 116, 101, 114, 118, 97, 108, 34, 58, 50, 53, 48, 48, 48, 44, 34, 112, 105, 110, 103, 84, 105, 109, 101, 111, 117, 116, 34, 58, 50, 48, 48, 48, 48, 125, 0];
const SIO_LIT_WEBSOCKET: u8[12] = [34, 119, 101, 98, 115, 111, 99, 107, 101, 116, 34, 0];
const SIO_LIT_R_R: u8[7] = [92, 114, 10, 92, 114, 10, 0];
const SIO_LIT_ABC: u8[4] = [97, 98, 99, 0];
const SIO_LIT_ABC123: u8[7] = [97, 98, 99, 49, 50, 51, 0];
const SIO_LIT_CHAT_MESSAGE: u8[13] = [99, 104, 97, 116, 32, 109, 101, 115, 115, 97, 103, 101, 0];
const SIO_LIT_HELLO: u8[6] = [104, 101, 108, 108, 111, 0];
const SIO_LIT_HTTP: u8[8] = [104, 116, 116, 112, 58, 47, 47, 0];
const SIO_LIT_HTTP_127_0_0_1_3000: u8[22] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 51, 48, 48, 48, 0];
const SIO_LIT_HTTPS: u8[9] = [104, 116, 116, 112, 115, 58, 47, 47, 0];
const SIO_LIT_HTTPS_EXAMPLE_COM_8443: u8[25] = [104, 116, 116, 112, 115, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109, 58, 56, 52, 52, 51, 0];
const SIO_LIT_HUBA: u8[5] = [104, 117, 98, 65, 0];
const SIO_LIT_HUBB: u8[5] = [104, 117, 98, 66, 0];
const SIO_LIT_LOBBY: u8[6] = [108, 111, 98, 98, 121, 0];
const SIO_LIT_ND2: u8[4] = [110, 100, 50, 0];
const SIO_LIT_NEWS: u8[5] = [110, 101, 119, 115, 0];
const SIO_LIT_NODEA: u8[6] = [110, 111, 100, 101, 65, 0];
const SIO_LIT_NODEB: u8[6] = [110, 111, 100, 101, 66, 0];
const SIO_LIT_OXLMYI: u8[7] = [111, 88, 76, 77, 121, 105, 0];
const SIO_LIT_PING: u8[5] = [112, 105, 110, 103, 0];
const SIO_LIT_PONG: u8[5] = [112, 111, 110, 103, 0];
const SIO_LIT_SESS1: u8[6] = [115, 101, 115, 115, 49, 0];
const SIO_LIT_SESS42: u8[7] = [115, 101, 115, 115, 52, 50, 0];
const SIO_LIT_SNAPA: u8[6] = [115, 110, 97, 112, 65, 0];
const SIO_LIT_SNAPB: u8[6] = [115, 110, 97, 112, 66, 0];
const SIO_LIT_SRV001: u8[7] = [115, 114, 118, 48, 48, 49, 0];
const SIO_LIT_SYNC1: u8[6] = [115, 121, 110, 99, 49, 0];
const SIO_LIT_TRANSPORT_POLLING: u8[18] = [116, 114, 97, 110, 115, 112, 111, 114, 116, 61, 112, 111, 108, 108, 105, 110, 103, 0];
const SIO_LIT_UPDATE: u8[7] = [117, 112, 100, 97, 116, 101, 0];
const SIO_LIT_WS: u8[6] = [119, 115, 58, 47, 47, 0];
const SIO_LIT_WSS: u8[7] = [119, 115, 115, 58, 47, 47, 0];

/** 多 namespace 路由表（CONNECT 包 → slot_id；布局与 mod.x SioNsRouter 一致）。 */
allow(padding) struct SioNsRouterMem {
  count: i32;
  ns_len: i32[4];
  slot_id: i32[4];
  ns: u8[4][24];
}

/** 多 namespace 并发会话表（布局与 mod.x SioNsSessions 一致）。 */
allow(padding) struct SioNsSessionsMem {
  count: i32;
  slot_id: i32[4];
  active: i32[4];
}

/** WS hub 单槽（布局与 mod.x SioWsHubSlot 一致，48 字节）。 */
allow(padding) struct SioWsHubSlotMem {
  in_use: i32;
  fd: i32;
  sid_len: i32;
  slot_id: i32;
  tls_ctx: i64;
  sid: u8[24];
}

/** WS hub（count + 对齐填充 + 4 槽；200 字节，与 mod.x SioWsHub 一致）。 */
allow(padding) struct SioWsHubMem {
  count: i32;
  pad_count: i32;
  slot: SioWsHubSlotMem[4];
}

/** 单个 room（布局与 mod.x SioRoom 一致）。 */
allow(padding) struct SioRoomMem {
  in_use: i32;
  name_len: i32;
  room_id: i32;
  member_count: i32;
  name: u8[16];
  members: i32[4];
}

/** room 注册表（布局与 mod.x SioRoomRegistry 一致）。 */
allow(padding) struct SioRoomRegistryMem {
  count: i32;
  room: SioRoomMem[4];
}

/** hub 快照单槽。 */
allow(padding) struct SioWsHubSnapSlotMem {
  in_use: i32;
  sid_len: i32;
  slot_id: i32;
  sid: u8[24];
}

/** hub 二进制快照。 */
allow(padding) struct SioWsHubSnapshotMem {
  magic: i32;
  version: i32;
  slot: SioWsHubSnapSlotMem[4];
}

/** room 二进制快照。 */
allow(padding) struct SioRoomRegistrySnapshotMem {
  magic: i32;
  version: i32;
  count: i32;
  room: SioRoomMem[4];
}

/** hub + room 一体快照。 */
allow(padding) struct SioSessionBundleMem {
  magic: i32;
  version: i32;
  hub: SioWsHubSnapshotMem;
  room: SioRoomRegistrySnapshotMem;
}

/** cluster adapter 单条消息。 */
allow(padding) struct SioClusterAdapterMsgMem {
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

/** 内存 cluster adapter。 */
allow(padding) struct SioClusterAdapterMem {
  count: i32;
  node_id: i32;
  msg: SioClusterAdapterMsgMem[4];
}

/** cluster adapter 二进制快照。 */
allow(padding) struct SioClusterAdapterSnapshotMem {
  magic: i32;
  version: i32;
  count: i32;
  node_id: i32;
  msg: SioClusterAdapterMsgMem[4];
}


extern function http_get_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_post_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32,
  timeout_ms: u32): i32;
extern function net_ws_write_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern function net_ws_write_server_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern function net_ws_read_frame_c(fd: i32, tls_ctx: i64, out_opcode: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32, timeout_ms: u32): i32;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function strlen(s: *u8): usize;


/** F-socketio v1 版本标记；供聚合 gate 校验 socketio.x 已参与编译。 */
function socketio_f_socketio_v1_marker_c(): i32 { return 1; }

/** F-socketio v2 逻辑下沉标记；protocol 全量在 socketio.x。 */
function socketio_f_socketio_v2_marker_c(): i32 { return 1; }


function sio_bump_off(off: *i32): void { *off = *off + 1; }

function sio_append_bytes(out: *u8, cap: i32, off: *i32, s: *u8, slen: i32): i32 {
  let i: i32 = 0;
  if (out == 0 || off == 0 || *off < 0) { return -1; }
  if (slen > 0 && s == 0) { return -1; }
  while (i < slen) {
    if (*off >= cap) { return -1; }
    out[*off] = s[i];
    sio_bump_off(off);
    i = i + 1;
  }
  return 0;
}

function sio_append_u32_dec(out: *u8, cap: i32, off: *i32, v: u32): i32 {
  let tmp: u8[12] = [];
  let n: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let vv: u32 = v;
  if (out == 0 || off == 0 || *off < 0) { return -1; }
  if (vv == 0) { tmp[0] = 48; n = 1; }
  else {
    while (vv > 0 && n < 12) { tmp[n] = (48 + (vv % 10)) as u8; n = n + 1; vv = vv / 10; }
    i = 0;
    while (i < n / 2) {
      let t: u8 = tmp[i];
      tmp[i] = tmp[(n - 1 - i)];
      tmp[(n - 1 - i)] = t;
      i = i + 1;
    }
  }
  return sio_append_bytes(out, cap, off, &tmp[0], n);
}

function sio_server_wrap_http_body_c(body: *u8, blen: i32, out: *u8, out_cap: i32): i32 {
  let off: i32 = 0;
  let prefix: *u8 = &SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_CHARSET_UTF_8_R_CONNECTION_KEEP_ALIVE_R_CONTENT_LENGTH[0];
  let suffix: *u8 = &SIO_LIT_R_R[0];
  if (body == 0 || blen <= 0 || out == 0 || out_cap < blen + 64) { return -1; }
  if (sio_append_bytes(out, out_cap, &off, prefix, unsafe { strlen(prefix) as i32 }) != 0) { return -1; }
  if (sio_append_u32_dec(out, out_cap, &off, blen as u32) != 0) { return -1; }
  if (sio_append_bytes(out, out_cap, &off, suffix, unsafe { strlen(suffix) as i32 }) != 0) { return -1; }
  if (off + blen > out_cap) { return -1; }
  if (blen > 0) { unsafe { memcpy(out + off, body, blen); } }
  return off + blen;
}

function sio_eio_version_c(): i32 {
 return SIO_EIO_VERSION;
}

function sio_transport_polling_c(): i32 {
 return SIO_TRANSPORT_POLLING;
}

function sio_transport_websocket_c(): i32 {
 return SIO_TRANSPORT_WEBSOCKET;
}

function sio_build_eio_url_c(base: *u8, base_len: i32, sid: *u8, sid_len: i32, transport: i32, out: *u8, out_cap: i32): i32 {

    let path_poll: *u8 = &SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING[0];
    let path_ws: *u8 = &SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_WEBSOCKET[0];
    let sid_q: *u8 = &SIO_LIT_SID_QUERY[0];
    let off: i32 = 0;
    let i: i32 = 0;
    let has_slash: i32 = 0;
    let suffix: *u8 = 0;
    let suffix_len: i32 = 0;
    if ((base == 0) || base_len <= 0 || (out == 0) || out_cap < 32)
        {
          return -1;
        }
    if (sid_len < 0)
        {
          return -1;
        }
    if (sid_len > 0 && (sid == 0))
        {
          return -1;
        }
    if (transport == SIO_TRANSPORT_WEBSOCKET) {
        suffix = path_ws;
        unsafe { suffix_len = ((strlen(path_ws) as i32)); }
    } else {
        suffix = path_poll;
        unsafe { suffix_len = ((strlen(path_poll) as i32)); }
    }
    i = base_len - 1;
    while (i >= 0) {
        if (base[i] == (47 as u8)) {
            has_slash = 1;
            break;
        }
        i = i - 1;
    }
    if (sio_append_bytes(out, out_cap, &off, base, base_len) != 0)
        {
          return -1;
        }
    if ((has_slash == 0)) {
        if (off >= out_cap)
            {
              return -1;
            }
        out[off] = 47 as u8;
        sio_bump_off(&off);
    }
    if (sio_append_bytes(out, out_cap, &off, suffix, suffix_len) != 0)
        {
          return -1;
        }
    if (sid_len > 0) {
        if (sio_append_bytes(out, out_cap, &off, sid_q, unsafe { ((strlen(sid_q) as i32)) }) != 0)
            {
              return -1;
            }
        if (sio_append_bytes(out, out_cap, &off, sid, sid_len) != 0)
            {
              return -1;
            }
    }
    return off;
}

function sio_http_extract_body_c(http: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32): i32 {

    let i: i32 = 0;
    let body_off: i32 = -1;
    let blen: i32 = 0;
    if ((http == 0) || len <= 0 || (out == 0) || (out_len == 0))
        {
          return -1;
        }
    for (i = 0; i + 3 < len; i = i + 1) {
        if (http[i] == (13 as u8) && http[i + 1] == (10 as u8) && http[i + 2] == (13 as u8) &&
            http[i + 3] == (10 as u8)) {
            body_off = i + 4;
            break;
        }
    }
    if (body_off < 0 || body_off >= len)
        {
          return -1;
        }
    blen = len - body_off;
    if (blen > out_cap)
        {
          return -1;
        }
    if (blen > 0)
        {
          unsafe { memcpy(out, http + body_off,  (blen as usize)); }
        }
    out_len[0] = blen;
    return 0;
}

function sio_eio_open_has_websocket_c(open_payload: *u8, len: i32): i32 {

    let needle: *u8 = &SIO_LIT_WEBSOCKET[0];
    let i: i32 = 0;
    if ((open_payload == 0) || len <= 0)
        {
          return -1;
        }
    for (i = 0; i + 11 <= len; i = i + 1) {
        if (unsafe { memcmp(open_payload + i, needle, 11) } == 0)
            {
              return 1;
            }
    }
    return 0;
}

function sio_polling_handshake_parse_c(http: *u8, http_len: i32, out_sid: *u8, sid_cap: i32, out_has_ws: *i32): i32 {

    let body: u8[512] = [];
    let payload: u8[480] = [];
    let blen: i32 = 0;
    let etype: i32 = -1;
    let plen: i32 = 0;
    let sid_len: i32 = 0;
    let has_ws: i32 = 0;
    if ((http == 0) || http_len <= 0 || (out_sid == 0) || sid_cap < 2)
        {
          return -1;
        }
    if (sio_http_extract_body_c(http, http_len, body,  ((body as usize) as i32), &blen) != 0)
        {
          return -1;
        }
    if (sio_eio_decode_packet_c(body, blen, &etype, payload,  ((payload as usize) as i32), &plen) != 0)
        {
          return -1;
        }
    if (etype != SIO_EIO_OPEN)
        {
          return -1;
        }
    sid_len = sio_eio_extract_sid_c(payload, plen, out_sid, sid_cap);
    if (sid_len <= 0)
        {
          return -1;
        }
    has_ws = sio_eio_open_has_websocket_c(payload, plen);
    if (out_has_ws != 0)
        {
          out_has_ws[0] = has_ws > 0 ? 1 : 0;
        }
    return sid_len;
}

function sio_polling_handshake_c(base_url: *u8, base_len: i32, out_sid: *u8, sid_cap: i32, timeout_ms: u32, out_has_ws: *i32): i32 {

    let url: u8[384] = [];
    let resp: u8[4096] = [];
    let url_len: i32 = 0;
    let n: i32 = 0;
    if ((base_url == 0) || base_len <= 0 || (out_sid == 0) || sid_cap < 2)
        {
          return -1;
        }
    url_len = sio_build_eio_url_c(base_url, base_len, 0, 0, SIO_TRANSPORT_POLLING, url,
                                   ((url as usize) as i32));
    if (url_len <= 0)
        {
          return -1;
        }
    unsafe { n = http_get_timeout_c(url, url_len, resp,  ((resp as usize) as i32), timeout_ms); }
    if (n <= 0)
        {
          return -1;
        }
    return sio_polling_handshake_parse_c(resp, n, out_sid, sid_cap, out_has_ws);
}

function sio_polling_post_packet_c(base_url: *u8, base_len: i32, sid: *u8, sid_len: i32, packet: *u8, packet_len: i32, out_resp: *u8, out_cap: i32, timeout_ms: u32): i32 {

    let url: u8[384] = [];
    let url_len: i32 = 0;
    let n: i32 = 0;
    if ((base_url == 0) || base_len <= 0 || sid_len <= 0 || (sid == 0) || packet_len <= 0 || (packet == 0))
        {
          return -1;
        }
    if ((out_resp == 0) || out_cap <= 0)
        {
          return -1;
        }
    url_len = sio_build_eio_url_c(base_url, base_len, sid, sid_len, SIO_TRANSPORT_POLLING, url,
                                   ((url as usize) as i32));
    if (url_len <= 0)
        {
          return -1;
        }
    unsafe { n = http_post_timeout_c(url, url_len, packet, packet_len, out_resp, out_cap, timeout_ms); }
    return n;
}

function sio_polling_smoke_c(): i32 {

    let base: *u8 = &SIO_LIT_HTTP_127_0_0_1_3000[0];
    let sid: *u8 = &SIO_LIT_ABC123[0];
    let http_ok: *u8 = &SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_R_CONTENT_LENGTH_52_R_R_0_SID_ABC123_UPGRADES_WEBSOCKET_PINGINTERVAL_25000[0];
    let url: u8[128] = [];
    let url2: u8[128] = [];
    let sid_out: u8[16] = [];
    let has_ws: i32 = 0;
    let n: i32 = 0;
    n = sio_build_eio_url_c(base, unsafe { ((strlen(base) as i32)) }, 0, 0, SIO_TRANSPORT_POLLING, url,
                            128);
    if (n <= 0)
        {
          return 1;
        }
    if (unsafe { memcmp(url, &SIO_LIT_HTTP_127_0_0_1_3000_SOCKET_IO_EIO_4_TRANSPORT_POLLING[0],  (n as usize)) } != 0)
        {
          return 2;
        }
    n = sio_build_eio_url_c(base, unsafe { ((strlen(base) as i32)) }, sid, 6, SIO_TRANSPORT_WEBSOCKET, url2, 128);
    if (n <= 0)
        {
          return 3;
        }
    if (url2[n - 1] != (51 as u8) || url2[n - 2] != (50 as u8))
        {
          return 4;
        }
    n = sio_polling_handshake_parse_c(http_ok, unsafe { ((strlen(http_ok) as i32)) }, sid_out, 16, &has_ws);
    if (n != 6 || has_ws != 1)
        {
          return 5;
        }
    if (unsafe { memcmp(sid_out, sid, 6) } != 0)
        {
          return 6;
        }
    if (sio_eio_version_c() != 4)
        {
          return 7;
        }
    return 0;
}

function sio_sio_type_connect_c(): i32 {
 return SIO_SIO_CONNECT;
}

function sio_sio_type_ack_c(): i32 {
 return SIO_SIO_ACK;
}

function sio_http_to_ws_base_c(http_base: *u8, len: i32, out: *u8, out_cap: i32): i32 {

    let https_p: *u8 = &SIO_LIT_HTTPS[0];
    let wss_p: *u8 = &SIO_LIT_WSS[0];
    let http_p: *u8 = &SIO_LIT_HTTP[0];
    let ws_p: *u8 = &SIO_LIT_WS[0];
    let src_suffix: *u8 = 0;
    let suffix_len: i32 = 0;
    let dst_p: *u8 = 0;
    let dst_len: i32 = 0;
    let off: i32 = 0;
    if ((http_base == 0) || len <= 0 || (out == 0) || out_cap < 8)
        {
          return -1;
        }
    if (len >= 8 && unsafe { memcmp(http_base, https_p, 8) } == 0) {
        dst_p = wss_p;
        dst_len = 6;
        src_suffix = http_base + 8;
        suffix_len = len - 8;
    } else if (len >= 7 && unsafe { memcmp(http_base, http_p, 7) } == 0) {
        dst_p = ws_p;
        dst_len = 5;
        src_suffix = http_base + 7;
        suffix_len = len - 7;
    } else {
        return -1;
    }
    if (dst_len + suffix_len > out_cap)
        {
          return -1;
        }
    if (sio_append_bytes(out, out_cap, &off, dst_p, dst_len) != 0)
        {
          return -1;
        }
    if (sio_append_bytes(out, out_cap, &off, src_suffix, suffix_len) != 0)
        {
          return -1;
        }
    return off;
}

function sio_build_ws_connect_url_c(http_base: *u8, base_len: i32, sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {

    let ws_base: u8[384] = [];
    let wl: i32 = 0;
    if ((http_base == 0) || base_len <= 0 || sid_len <= 0 || (sid == 0) || (out == 0))
        {
          return -1;
        }
    wl = sio_http_to_ws_base_c(http_base, base_len, ws_base,  ((ws_base as usize) as i32));
    if (wl <= 0)
        {
          return -1;
        }
    return sio_build_eio_url_c(ws_base, wl, sid, sid_len, SIO_TRANSPORT_WEBSOCKET, out, out_cap);
}

function sio_eio_ws_upgrade_c(fd: i32, tls_ctx: i64, timeout_ms: u32): i32 {

    let probe: *u8 = &SIO_LIT_N2PROBE[0];
    let upgrade: *u8 = &SIO_LIT_N5[0];
    let buf: u8[16] = [];
    let opcode: i32 = 0;
    let plen: i32 = 0;
    if (fd < 0)
        {
          return -1;
        }
    if (unsafe { net_ws_write_text_c(fd, tls_ctx, probe, 6) } != 0)
        {
          return -1;
        }
    if (unsafe { net_ws_read_frame_c(fd, tls_ctx, &opcode, buf, 16, &plen, timeout_ms) } != 0)
        {
          return -1;
        }
    if (plen != 6 || unsafe { memcmp(buf, &SIO_LIT_N3PROBE[0], 6) } != 0)
        {
          return -1;
        }
    if (unsafe { net_ws_write_text_c(fd, tls_ctx, upgrade, 1) } != 0)
        {
          return -1;
        }
    return 0;
}

function sio_encode_connect_packet_c(out: *u8, out_cap: i32): i32 {

    let sio_connect: *u8 = &SIO_LIT_N0[0];
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, sio_connect, 1, out, out_cap);
}

function sio_reconnect_delay_ms_c(attempt: i32, cap_ms: i32): i32 {

    let delay: i32 = 0;
    if (attempt < 0)
        {
          attempt = 0;
        }
    if (cap_ms <= 0)
        {
          cap_ms = 5000;
        }
    delay = 1000 * (attempt + 1);
    if (delay > cap_ms)
        {
          delay = cap_ms;
        }
    return delay;
}

function sio_connect_smoke_c(): i32 {

    let http_base: *u8 = &SIO_LIT_HTTP_127_0_0_1_3000[0];
    let https_base: *u8 = &SIO_LIT_HTTPS_EXAMPLE_COM_8443[0];
    let sid: *u8 = &SIO_LIT_SESS42[0];
    let ws_base: u8[64] = [];
    let url: u8[160] = [];
    let pkt: u8[8] = [];
    let n: i32 = 0;
    n = sio_http_to_ws_base_c(http_base, unsafe { ((strlen(http_base) as i32)) }, ws_base, 64);
    if (n != 19 || unsafe { memcmp(ws_base, &SIO_LIT_WS_127_0_0_1_3000[0], 19) } != 0)
        {
          return 1;
        }
    n = sio_http_to_ws_base_c(https_base, unsafe { ((strlen(https_base) as i32)) }, ws_base, 64);
    if (n != 22 || unsafe { memcmp(ws_base, &SIO_LIT_WSS_EXAMPLE_COM_8443[0], 22) } != 0)
        {
          return 2;
        }
    n = sio_build_ws_connect_url_c(http_base, unsafe { ((strlen(http_base) as i32)) }, sid, 6, url, 160);
    if (n <= 0 || url[0] != (119 as u8) || url[n - 1] != (50 as u8))
        {
          return 3;
        }
    n = sio_encode_connect_packet_c(pkt, 8);
    if (n != 2 || pkt[0] != (52 as u8) || pkt[1] != (48 as u8))
        {
          return 4;
        }
    if (sio_reconnect_delay_ms_c(0, 5000) != 1000)
        {
          return 5;
        }
    if (sio_reconnect_delay_ms_c(10, 5000) != 5000)
        {
          return 6;
        }
    return 0;
}

function sio_node_interop_smoke_c(): i32 {

    let node_http_open: *u8 = &SIO_LIT_HTTP_1_1_200_OK_R_CONTENT_TYPE_TEXT_PLAIN_CHARSET_UTF_8_R_CONNECTION_KEEP_ALIVE_R_R_0_SID_OXLMYI_UPGRADES_WEBSOCKET_PINGINTERVAL_25000_PINGTIMEOUT_20000_MAXPAYLOAD_1000000[0];
    let node_sid: *u8 = &SIO_LIT_OXLMYI[0];
    let node_ws_event: *u8 = &SIO_LIT_N42_CHAT_MESSAGE_HELLO[0];
    let evt_name: *u8 = &SIO_LIT_CHAT_MESSAGE[0];
    let evt_data: *u8 = &SIO_LIT_HELLO[0];
    let sid: u8[16] = [];
    let evt: u8[32] = [];
    let data: u8[32] = [];
    let enc: u8[64] = [];
    let eio_payload: u8[32] = [];
    let pong: u8[4] = [];
    let has_ws: i32 = 0;
    let dlen: i32 = 0;
    let n: i32 = 0;
    let etype: i32 = -1;
    let plen: i32 = 0;
    let node_evt_len: i32 = unsafe { ((strlen(node_ws_event) as i32)) };

    n = sio_polling_handshake_parse_c(node_http_open, unsafe { ((strlen(node_http_open) as i32)) }, sid, 16, &has_ws);
    if (n != 6 || has_ws != 1 || unsafe { memcmp(sid, node_sid, 6) } != 0)
        {
          return 1;
        }
    if (sio_eio_decode_packet_c(node_ws_event, node_evt_len, &etype, eio_payload, 32, &plen) != 0)
        {
          return 2;
        }
    if (etype != SIO_EIO_MESSAGE || plen != node_evt_len - 1)
        {
          return 3;
        }
    if (sio_decode_event_packet_c(node_ws_event + 1, node_evt_len - 1, &evt[0], 32, &data[0], 32, &dlen) != 0)
        {
          return 4;
        }
    if (dlen != 5 || data[0] != (104 as u8) || evt[0] != (99 as u8))
        {
          return 5;
        }
    n = sio_encode_event_packet_c(evt_name, 12, evt_data, 5, enc, 64);
    if (n != node_evt_len || unsafe { memcmp(enc, node_ws_event,  (n as usize)) } != 0)
        {
          return 6;
        }
    n = sio_encode_connect_packet_c(enc, 64);
    if (n != 2 || enc[0] != (52 as u8) || enc[1] != (48 as u8))
        {
          return 7;
        }
    n = sio_eio_encode_packet_c(SIO_EIO_PONG, 0, 0, pong, 4);
    if (n != 1 || pong[0] != ((48 as u8) +  SIO_EIO_PONG))
        {
          return 8;
        }
    return 0;
}

function sio_server_build_open_json_c(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {

    let prefix: *u8 = &SIO_LIT_JSON_SID_PREFIX[0];
    let suffix: *u8 = &SIO_LIT_UPGRADES_WEBSOCKET_PINGINTERVAL_25000_PINGTIMEOUT_20000[0];
    let need: i32 = 0;
    if ((sid == 0) || sid_len <= 0 || sid_len > 64 || (out == 0) || out_cap < 32)
        {
          return -1;
        }
    need = unsafe { ((strlen(prefix) as i32)) + sid_len + ((strlen(suffix) as i32)) };
    if (need >= out_cap)
        {
          return -1;
        }
    unsafe { memcpy(out, prefix, (strlen(prefix) as i32)); }
    unsafe { memcpy(out + ((strlen(prefix) as i32)), sid,  (sid_len as usize)); }
    unsafe { memcpy(out + ((strlen(prefix) as i32)) +  (sid_len), suffix, (strlen(suffix) as usize)); }
    return need;
}

function sio_server_build_open_packet_c(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {

    let json: u8[128] = [];
    let jl: i32 = 0;
    if ((out == 0))
        {
          return -1;
        }
    jl = sio_server_build_open_json_c(sid, sid_len, json,  ((json as usize) as i32));
    if (jl <= 0)
        {
          return -1;
        }
    return sio_eio_encode_packet_c(SIO_EIO_OPEN, json, jl, out, out_cap);
}

function sio_server_build_http_open_response_c(sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {

    let body: u8[160] = [];
    let blen: i32 = 0;
    if ((out == 0) || out_cap < 64)
        {
          return -1;
        }
    blen = sio_server_build_open_packet_c(sid, sid_len, body,  ((body as usize) as i32));
    if (blen <= 0)
        {
          return -1;
        }
    return sio_server_wrap_http_body_c(body, blen, out, out_cap);
}

function sio_server_is_polling_handshake_c(path: *u8, len: i32): i32 {

    let eio: *u8 = &SIO_LIT_EIO_4[0];
    let tp: *u8 = &SIO_LIT_TRANSPORT_POLLING[0];
    let sid_q: *u8 = &SIO_LIT_SID_QUERY[0];
    let has_eio: i32 = 0;
    let has_tp: i32 = 0;
    let i: i32 = 0;
    if ((path == 0) || len <= 0)
        {
          return -1;
        }
    for (i = 0; i + 4 <= len; i = i + 1) {
        if (unsafe { memcmp(path + i, eio, 4) } == 0)
            {
              has_eio = 1;
            }
    }
    for (i = 0; i + 17 <= len; i = i + 1) {
        if (unsafe { memcmp(path + i, tp, 17) } == 0)
            {
              has_tp = 1;
            }
    }
    for (i = 0; i + 4 <= len; i = i + 1) {
        if (unsafe { memcmp(path + i, sid_q, 4) } == 0)
            {
              return 0;
            }
    }
    return (has_eio != 0 && has_tp != 0) ? 1 : 0;
}

function sio_server_is_connect_packet_c(pkt: *u8, len: i32): i32 {

    let etype: i32 = -1;
    let plen: i32 = 0;
    let inner: u8[128] = [];
    if ((pkt == 0) || len <= 0)
        {
          return -1;
        }
    if (len == 2 && pkt[0] == ((48 as u8) +  SIO_EIO_MESSAGE) && pkt[1] == ((48 as u8) +  SIO_SIO_CONNECT))
        {
          return 1;
        }
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner,  ((inner as usize) as i32), &plen) != 0)
        {
          return 0;
        }
    if (etype != SIO_EIO_MESSAGE || plen < 1)
        {
          return 0;
        }
    return (inner[0] == ((48 as u8) +  SIO_SIO_CONNECT)) ? 1 : 0;
}

function sio_server_emit_event_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    if ((event == 0) || event_len <= 0 || (out == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
}

function sio_server_build_http_event_response_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let body: u8[512] = [];
    let blen: i32 = 0;
    if ((out == 0) || out_cap < 64)
        {
          return -1;
        }
    blen = sio_server_emit_event_c(event, event_len, data, data_len, body,  ((body as usize) as i32));
    if (blen <= 0)
        {
          return -1;
        }
    return sio_server_wrap_http_body_c(body, blen, out, out_cap);
}

function sio_server_emit_smoke_c(): i32 {

    let evt: *u8 = &SIO_LIT_NEWS[0];
    let payload: *u8 = &SIO_LIT_UPDATE[0];
    let expect: *u8 = &SIO_LIT_N42_NEWS_UPDATE[0];
    let frame: u8[64] = [];
    let http: u8[256] = [];
    let body: u8[128] = [];
    let out_evt: u8[16] = [];
    let out_data: u8[16] = [];
    let body_len: i32 = 0;
    let dlen: i32 = 0;
    let n: i32 = 0;
    n = sio_server_emit_event_c(evt, 4, payload, 6, frame, 64);
    if (n != unsafe { ((strlen(expect) as i32)) } || unsafe { memcmp(frame, expect,  (n as usize)) } != 0)
        {
          return 1;
        }
    n = sio_server_build_http_event_response_c(evt, 4, payload, 6, http, 256);
    if (n <= 0)
        {
          return 2;
        }
    if (sio_http_extract_body_c(http, n, body, 128, &body_len) != 0)
        {
          return 3;
        }
    if (body_len < 2 || body[0] != ((48 as u8) +  SIO_EIO_MESSAGE))
        {
          return 4;
        }
    if (sio_decode_event_packet_c(&body[1], body_len - 1, &out_evt[0], 16, &out_data[0], 16, &dlen) != 0)
        {
          return 5;
        }
    if (dlen != 6 || out_evt[0] != (110 as u8) || out_data[0] != (117 as u8))
        {
          return 6;
        }
    return 0;
}

function sio_server_smoke_c(): i32 {

    let sid: *u8 = &SIO_LIT_SRV001[0];
    let path_ok: *u8 = &SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING_T_ABC[0];
    let path_sid: *u8 = &SIO_LIT_SOCKET_IO_EIO_4_TRANSPORT_POLLING_SID_X[0];
    let body: u8[160] = [];
    let http: u8[256] = [];
    let sid_out: u8[16] = [];
    let has_ws: i32 = 0;
    let n: i32 = 0;
    n = sio_server_build_open_packet_c(sid, 6, body, 160);
    if (n <= 0 || body[0] != ((48 as u8) +  SIO_EIO_OPEN))
        {
          return 1;
        }
    n = sio_server_build_http_open_response_c(sid, 6, http, 256);
    if (n <= 0)
        {
          return 2;
        }
    if (sio_polling_handshake_parse_c(http, n, sid_out, 16, &has_ws) != 6)
        {
          return 3;
        }
    if (unsafe { memcmp(sid_out, sid, 6) } != 0 || has_ws != 1)
        {
          return 4;
        }
    if (sio_server_is_polling_handshake_c(path_ok, unsafe { ((strlen(path_ok) as i32)) }) != 1)
        {
          return 5;
        }
    if (sio_server_is_polling_handshake_c(path_sid, unsafe { ((strlen(path_sid) as i32)) }) != 0)
        {
          return 6;
        }
    if (sio_server_is_connect_packet_c(&SIO_LIT_N40[0], 2) != 1)
        {
          return 7;
        }
    if (sio_server_emit_smoke_c() != 0)
        {
          return 8;
        }
    return 0;
}

function sio_encode_connect_ns_packet_c(ns: *u8, ns_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[128] = [];
    let off: i32 = 0;
    if ((out == 0) || out_cap < 2)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8)))
        {
          return sio_encode_connect_packet_c(out, out_cap);
        }
    if (ns[0] != (47 as u8))
        {
          return -1;
        }
    inner[off] = ((48 as u8) +  SIO_SIO_CONNECT);
    off = off + 1;
    if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, ns, ns_len) != 0)
        {
          return -1;
        }
    if (off + 1 >=  ((inner) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_parse_sio_packet_head_c(pkt: *u8, len: i32, out_type: *i32, out_id: *i32, out_payload_off: *i32): i32 {

    let i: i32 = 0;
    let type: i32 = 0;
    let id: i32 = 0;
    if ((pkt == 0) || len <= 0 || (out_type == 0) || (out_payload_off == 0))
        {
          return -1;
        }
    if (pkt[0] < (48 as u8) || pkt[0] > (57 as u8))
        {
          return -1;
        }
    type = (pkt[0] - (48 as u8));
    i = 1;
    id = -1;
    if (i < len && pkt[i] >= (48 as u8) && pkt[i] <= (57 as u8)) {
        id = 0;
        while (i < len && pkt[i] >= (48 as u8) && pkt[i] <= (57 as u8)) {
            id = id * 10 + (pkt[i] - (48 as u8));
            i = i + 1;
        }
    }
    out_type[0] = type;
    if (out_id != 0)
        {
          out_id[0] = id;
        }
    out_payload_off[0] = i;
    return 0;
}

function sio_server_is_connect_ns_packet_c(pkt: *u8, len: i32, ns: *u8, ns_len: i32): i32 {

    let etype: i32 = -1;
    let plen: i32 = 0;
    let inner: u8[128] = [];
    let expect_inner: i32 = 0;
    if ((pkt == 0) || len <= 0)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    if (len == 2 && pkt[0] == ((48 as u8) +  SIO_EIO_MESSAGE) && pkt[1] == ((48 as u8) +  SIO_SIO_CONNECT))
        {
          return ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8))) ? 1 : 0;
        }
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner,  ((inner as usize) as i32), &plen) != 0)
        {
          return 0;
        }
    if (etype != SIO_EIO_MESSAGE || plen < 1 || inner[0] != ((48 as u8) +  SIO_SIO_CONNECT))
        {
          return 0;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8)))
        {
          return (plen == 1) ? 1 : 0;
        }
    expect_inner = 1 + ns_len + 1;
    if (plen != expect_inner)
        {
          return 0;
        }
    if (unsafe { memcmp(&inner[1], ns, (ns_len as usize)) } != 0)
        {
          return 0;
        }
    return (inner[plen - 1] == (44 as u8)) ? 1 : 0;
}

function sio_parse_connect_ns_packet_c(pkt: *u8, len: i32, out_ns: *u8, out_cap: i32): i32 {

    let etype: i32 = -1;
    let plen: i32 = 0;
    let inner: u8[128] = [];
    let ns_len: i32 = 0;
    if ((out_ns == 0) || out_cap < 2)
        {
          return -1;
        }
    if ((pkt == 0) || len <= 0)
        {
          return -1;
        }
    if (len == 2 && pkt[0] == ((48 as u8) +  SIO_EIO_MESSAGE) && pkt[1] == ((48 as u8) +  SIO_SIO_CONNECT)) {
        out_ns[0] = (47 as u8);
        return 1;
    }
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner,  ((inner as usize) as i32), &plen) != 0)
        {
          return -1;
        }
    if (etype != SIO_EIO_MESSAGE || plen < 1 || inner[0] != ((48 as u8) +  SIO_SIO_CONNECT))
        {
          return -1;
        }
    if (plen == 1) {
        out_ns[0] = (47 as u8);
        return 1;
    }
    if (inner[plen - 1] != (44 as u8))
        {
          return -1;
        }
    ns_len = plen - 2;
    if (ns_len <= 0 || ns_len >= out_cap)
        {
          return -1;
        }
    unsafe { memcpy(out_ns, &inner[1], (ns_len as usize)); }
    return ns_len;
}

function sio_ns_router_bytes_c(): i32 {
 return 132;
}

function sio_ns_router_init_c(r: *SioNsRouterMem): void {

    if ((r == 0))
        {
          return;
        }
    unsafe { memset(r as *u8, 0, (sio_ns_router_bytes_c() as usize)); }
}

function sio_ns_equal_c(a: *u8, alen: i32, b: *u8, blen: i32): i32 {

    let root: *u8 = &SIO_LIT_NS_ROOT[0];
    if (alen <= 0 || (alen == 1 && a[0] == (47 as u8))) {
        alen = 1;
        a = root;
    }
    if (blen <= 0 || (blen == 1 && b[0] == (47 as u8))) {
        blen = 1;
        b = root;
    }
    return (alen == blen && unsafe { memcmp(a, b,  (alen as usize)) } == 0) ? 1 : 0;
}

function sio_ns_router_register_c(r: *SioNsRouterMem, ns: *u8, ns_len: i32, slot_id: i32): i32 {

    let root: *u8 = &SIO_LIT_NS_ROOT[0];
    if ((r == 0) || slot_id < 0)
        {
          return -1;
        }
    if (r.count >= SIO_NS_ROUTER_MAX)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8))) {
        ns = root;
        ns_len = 1;
    }
    if (ns_len <= 0 || ns_len >= SIO_NS_NAME_CAP)
        {
          return -1;
        }
    r.ns_len[r.count] = ns_len;
    r.slot_id[r.count] = slot_id;
    unsafe { memcpy(r.ns[r.count], ns,  (ns_len as usize)); }
    r.count = r.count + 1;
    return 0;
}

function sio_ns_router_lookup_c(r: *SioNsRouterMem, ns: *u8, ns_len: i32): i32 {

    let i: i32 = 0;
    if ((r == 0))
        {
          return -1;
        }
    for (i = 0; i < r.count; i = i + 1) {
        if (sio_ns_equal_c(r.ns[i], r.ns_len[i], ns, ns_len) != 0)
            {
              return r.slot_id[i];
            }
    }
    return -1;
}

function sio_ns_router_route_connect_c(r: *SioNsRouterMem, pkt: *u8, len: i32): i32 {

    let ns: u8[24] = [];
    let nl: i32 = 0;
    if ((r == 0))
        {
          return -1;
        }
    nl = sio_parse_connect_ns_packet_c(pkt, len, ns, SIO_NS_NAME_CAP);
    if (nl <= 0)
        {
          return -1;
        }
    return sio_ns_router_lookup_c(r, ns, nl);
}

function sio_ns_router_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let ns_admin: *u8 = &SIO_LIT_ADMIN[0];
    let router: SioNsRouterMem;
    let pkt_root: u8[8] = [];
    let pkt_chat: u8[16] = [];
    let pkt_admin: u8[16] = [];
    let ns_out: u8[24] = [];
    let n: i32 = 0;
    let slot: i32 = 0;
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, &SIO_LIT_NS_ROOT[0], 1, 0) != 0)
        {
          return 1;
        }
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        {
          return 2;
        }
    if (sio_ns_router_register_c(&router, ns_admin, 6, 20) != 0)
        {
          return 3;
        }
    n = sio_encode_connect_packet_c(pkt_root, 8);
    if (n <= 0)
        {
          return 4;
        }
    if (sio_parse_connect_ns_packet_c(pkt_root, n, ns_out, 24) != 1 || ns_out[0] != (47 as u8))
        {
          return 5;
        }
    if (sio_ns_router_route_connect_c(&router, pkt_root, n) != 0)
        {
          return 6;
        }
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0)
        {
          return 7;
        }
    if (sio_parse_connect_ns_packet_c(pkt_chat, n, ns_out, 24) != 5)
        {
          return 8;
        }
    if (ns_out[0] != (47 as u8) || ns_out[1] != (99 as u8))
        {
          return 9;
        }
    slot = sio_ns_router_route_connect_c(&router, pkt_chat, n);
    if (slot != 10)
        {
          return 10;
        }
    n = sio_encode_connect_ns_packet_c(ns_admin, 6, pkt_admin, 16);
    if (n <= 0)
        {
          return 11;
        }
    slot = sio_ns_router_route_connect_c(&router, pkt_admin, n);
    if (slot != 20)
        {
          return 12;
        }
    if (sio_ns_router_lookup_c(&router, ns_chat, 5) != 10)
        {
          return 13;
        }
    if (sio_ns_router_lookup_c(&router, &SIO_LIT_UNKNOWN[0], 8) != -1)
        {
          return 14;
        }
    return 0;
}

function sio_ns_sessions_bytes_c(): i32 {
 return 36;
}

function sio_ns_sessions_init_c(s: *SioNsSessionsMem): void {

    if ((s == 0))
        {
          return;
        }
    unsafe { memset(s as *u8, 0, (sio_ns_sessions_bytes_c() as usize)); }
}

function sio_ns_sessions_sync_router_c(s: *SioNsSessionsMem, r: *SioNsRouterMem): i32 {

    let i: i32 = 0;
    if ((s == 0) || (r == 0))
        {
          return -1;
        }
    sio_ns_sessions_init_c(s);
    if (r.count > SIO_NS_ROUTER_MAX)
        {
          return -1;
        }
    s.count = r.count;
    for (i = 0; i < r.count; i = i + 1) {
        s.slot_id[i] = r.slot_id[i];
    }
    return 0;
}

function sio_ns_sessions_slot_index_c(s: *SioNsSessionsMem, slot_id: i32): i32 {

    let i: i32 = 0;
    if ((s == 0) || slot_id < 0)
        {
          return -1;
        }
    for (i = 0; i < s.count; i = i + 1) {
        if (s.slot_id[i] == slot_id)
            {
              return i;
            }
    }
    return -1;
}

function sio_ns_sessions_connect_c(s: *SioNsSessionsMem, r: *SioNsRouterMem, pkt: *u8, len: i32): i32 {

    let slot: i32 = 0;
    let idx: i32 = 0;
    if ((s == 0) || (r == 0))
        {
          return -1;
        }
    slot = sio_ns_router_route_connect_c(r, pkt, len);
    if (slot < 0)
        {
          return -1;
        }
    idx = sio_ns_sessions_slot_index_c(s, slot);
    if (idx < 0)
        {
          return -1;
        }
    s.active[idx] = s.active[idx] + 1;
    return slot;
}

function sio_ns_sessions_disconnect_c(s: *SioNsSessionsMem, slot_id: i32): i32 {

    let idx: i32 = 0;
    if ((s == 0))
        {
          return -1;
        }
    idx = sio_ns_sessions_slot_index_c(s, slot_id);
    if (idx < 0)
        {
          return -1;
        }
    if (s.active[idx] > 0)
        {
          s.active[idx] = s.active[idx] - 1;
        }
    return 0;
}

function sio_ns_sessions_active_c(s: *SioNsSessionsMem, slot_id: i32): i32 {

    let idx: i32 = 0;
    if ((s == 0))
        {
          return -1;
        }
    idx = sio_ns_sessions_slot_index_c(s, slot_id);
    if (idx < 0)
        {
          return -1;
        }
    return s.active[idx];
}

function sio_ns_sessions_total_c(s: *SioNsSessionsMem): i32 {

    let i: i32 = 0;
    let total: i32 = 0;
    if ((s == 0))
        {
          return -1;
        }
    for (i = 0; i < s.count; i = i + 1) {
        total = total + s.active[i];
    }
    return total;
}

function sio_ns_sessions_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let ns_admin: *u8 = &SIO_LIT_ADMIN[0];
    let router: SioNsRouterMem;
    let sessions: SioNsSessionsMem;
    let pkt_root: u8[8] = [];
    let pkt_chat: u8[16] = [];
    let pkt_admin: u8[16] = [];
    let n: i32 = 0;
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, &SIO_LIT_NS_ROOT[0], 1, 0) != 0)
        {
          return 1;
        }
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        {
          return 2;
        }
    if (sio_ns_router_register_c(&router, ns_admin, 6, 20) != 0)
        {
          return 3;
        }
    if (sio_ns_sessions_sync_router_c(&sessions, &router) != 0)
        {
          return 4;
        }
    n = sio_encode_connect_packet_c(pkt_root, 8);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_root, n) != 0)
        {
          return 5;
        }
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_chat, n) != 10)
        {
          return 6;
        }
    n = sio_encode_connect_ns_packet_c(ns_admin, 6, pkt_admin, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_admin, n) != 20)
        {
          return 7;
        }
    if (sio_ns_sessions_total_c(&sessions) != 3)
        {
          return 8;
        }
    if (sio_ns_sessions_active_c(&sessions, 10) != 1)
        {
          return 9;
        }
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_chat, n) != 10)
        {
          return 10;
        }
    if (sio_ns_sessions_active_c(&sessions, 10) != 2)
        {
          return 11;
        }
    if (sio_ns_sessions_total_c(&sessions) != 4)
        {
          return 12;
        }
    if (sio_ns_sessions_disconnect_c(&sessions, 10) != 0)
        {
          return 13;
        }
    if (sio_ns_sessions_active_c(&sessions, 10) != 1 || sio_ns_sessions_total_c(&sessions) != 3)
        {
          return 14;
        }
    return 0;
}

function sio_ws_hub_bytes_c(): i32 {
 return 200;
}

function sio_ws_hub_init_c(h: *SioWsHubMem): void {

    let i: i32 = 0;
    if ((h == 0))
        {
          return;
        }
    unsafe { memset(h as *u8, 0, (sio_ws_hub_bytes_c() as usize)); }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        h.slot[i].fd = -1;
    }
}

function sio_ws_hub_alloc_slot_c(h: *SioWsHubMem): i32 {

    let i: i32 = 0;
    if ((h == 0))
        {
          return -1;
        }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        if (h.slot[i].in_use == 0)
            {
              return i;
            }
    }
    return -1;
}

function sio_ws_hub_register_c(h: *SioWsHubMem, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32 {

    let idx: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || fd < 0)
        {
          return -1;
        }
    if (sid_len <= 0 || sid_len > SIO_WS_SID_CAP || (sid == 0))
        {
          return -1;
        }
    idx = sio_ws_hub_alloc_slot_c(h);
    if (idx < 0)
        {
          return -1;
        }
    sl = &h.slot[idx];
    sl.in_use = 1;
    sl.fd = fd;
    sl.tls_ctx = tls_ctx;
    sl.sid_len = sid_len;
    unsafe { memcpy(sl.sid, sid,  (sid_len as usize)); }
    sl.slot_id = -1;
    h.count = h.count + 1;
    return idx;
}

function sio_ws_hub_unregister_c(h: *SioWsHubMem, conn_idx: i32): i32 {

    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        {
          return -1;
        }
    sl = &h.slot[conn_idx];
    if (sl.in_use == 0)
        {
          return -1;
        }
    sl.in_use = 0;
    sl.fd = -1;
    sl.tls_ctx = 0;
    sl.sid_len = 0;
    sl.slot_id = -1;
    if (h.count > 0)
        {
          h.count = h.count - 1;
        }
    return 0;
}

function sio_ws_hub_find_by_sid_c(h: *SioWsHubMem, sid: *u8, sid_len: i32): i32 {

    let i: i32 = 0;
    if ((h == 0) || sid_len <= 0 || (sid == 0))
        {
          return -1;
        }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        let sl: *SioWsHubSlotMem = &h.slot[i];
        if (sl.in_use == 0)
            {
              continue;
            }
        if (sl.sid_len != sid_len)
            {
              continue;
            }
        if (unsafe { memcmp(sl.sid, sid,  (sid_len as usize)) } == 0)
            {
              return i;
            }
    }
    return -1;
}

function sio_ws_hub_register_or_rebind_c(h: *SioWsHubMem, fd: i32, tls_ctx: i64, sid: *u8, sid_len: i32): i32 {

    let idx: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || fd < 0 || sid_len <= 0 || sid_len > SIO_WS_SID_CAP || (sid == 0))
        {
          return -1;
        }
    idx = sio_ws_hub_find_by_sid_c(h, sid, sid_len);
    if (idx >= 0) {
        sl = &h.slot[idx];
        if (sl.in_use != 0) {
            sl.fd = fd;
            sl.tls_ctx = tls_ctx;
            return idx;
        }
    }
    return sio_ws_hub_register_c(h, fd, tls_ctx, sid, sid_len);
}

function sio_ws_hub_handle_connect_c(h: *SioWsHubMem, conn_idx: i32, r: *SioNsRouterMem, s: *SioNsSessionsMem, pkt: *u8, len: i32): i32 {

    let slot: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || (r == 0) || (s == 0) || (pkt == 0) || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        {
          return -1;
        }
    sl = &h.slot[conn_idx];
    if (sl.in_use == 0)
        {
          return -1;
        }
    slot = sio_ns_router_route_connect_c(r, pkt, len);
    if (slot < 0)
        {
          return -1;
        }
    if (sio_ns_sessions_connect_c(s, r, pkt, len) < 0)
        {
          return -1;
        }
    sl.slot_id = slot;
    return slot;
}

function sio_ws_hub_emit_event_ns_c(h: *SioWsHubMem, slot_id: i32, ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {

    let frame: u8[256] = [];
    let n: i32 = 0;
    let i: i32 = 0;
    let sent: i32 = 0;
    if ((h == 0) || slot_id < 0 || event_len <= 0 || (event == 0))
        {
          return -1;
        }
    n = sio_encode_event_ns_packet_c(ns, ns_len, event, event_len, data, data_len, frame,  ((frame as usize) as i32));
    if (n <= 0)
        {
          return -1;
        }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        let sl: *SioWsHubSlotMem = &h.slot[i];
        if (sl.in_use == 0 || sl.slot_id != slot_id || sl.fd < 0)
            {
              continue;
            }
        if (unsafe { net_ws_write_server_text_c(sl.fd, sl.tls_ctx, frame, n) } == n)
            {
              sent = sent + 1;
            }
    }
    return sent;
}

function sio_server_build_connect_ns_ack_c(ns: *u8, ns_len: i32, sid: *u8, sid_len: i32, out: *u8, out_cap: i32): i32 {

    let jp: *u8 = &SIO_LIT_JSON_SID_PREFIX[0];
    let js: *u8 = &SIO_LIT_JSON_SID_SUFFIX[0];
    let inner: u8[128] = [];
    let off: i32 = 0;
    let jl: i32 = 0;
    if ((out == 0) || out_cap < 8)
        {
          return -1;
        }
    if ((sid == 0) || sid_len <= 0 || sid_len > 64)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    jl = unsafe { ((strlen(jp) as i32)) + sid_len + ((strlen(js) as i32)) };
    if (jl + 16 >=  ((inner) as i32))
        {
          return -1;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8))) {
        inner[off] = ((48 as u8) +  SIO_SIO_CONNECT);
    off = off + 1;
        if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, jp, unsafe { ((strlen(jp) as i32)) }) != 0)
            {
              return -1;
            }
        if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, sid, sid_len) != 0)
            {
              return -1;
            }
        if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, js, unsafe { ((strlen(js) as i32)) }) != 0)
            {
              return -1;
            }
        return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
    }
    if (ns[0] != (47 as u8))
        {
          return -1;
        }
    inner[off] = ((48 as u8) +  SIO_SIO_CONNECT);
    off = off + 1;
    if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, ns, ns_len) != 0)
        {
          return -1;
        }
    if (off + 1 >=  ((inner) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, jp, unsafe { ((strlen(jp) as i32)) }) != 0)
        {
          return -1;
        }
    if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, sid, sid_len) != 0)
        {
          return -1;
        }
    if (sio_append_bytes(inner,  ((inner as usize) as i32), &off, js, unsafe { ((strlen(js) as i32)) }) != 0)
        {
          return -1;
        }
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_ws_hub_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let sid_a: *u8 = &SIO_LIT_HUBA[0];
    let sid_b: *u8 = &SIO_LIT_HUBB[0];
    let expect_ack: u8[21] = [52, 48, 47, 99, 104, 97, 116, 44, 123, 34, 115, 105, 100, 34, 58, 34, 115, 117, 98, 34, 125];
    let hub: SioWsHubMem;
    let router: SioNsRouterMem;
    let sessions: SioNsSessionsMem;
    let pkt_chat: u8[16] = [];
    let ack: u8[64] = [];
    let pkt_len: i32 = 0;
    let ack_len: i32 = 0;
    let c0: i32 = 0;
    let c1: i32 = 0;
    let slot: i32 = 0;
    let sent: i32 = 0;
    sio_ws_hub_init_c(&hub);
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        {
          return 1;
        }
    if (sio_ns_sessions_sync_router_c(&sessions, &router) != 0)
        {
          return 2;
        }
    c0 = sio_ws_hub_register_c(&hub, 10, 0, sid_a, 4);
    c1 = sio_ws_hub_register_c(&hub, 11, 0, sid_b, 4);
    if (c0 != 0 || c1 != 1 || hub.count != 2)
        {
          return 3;
        }
    if (sio_ws_hub_find_by_sid_c(&hub, sid_b, 4) != 1)
        {
          return 4;
        }
    pkt_len = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (pkt_len <= 0)
        {
          return 5;
        }
    slot = sio_ws_hub_handle_connect_c(&hub, c0, &router, &sessions, pkt_chat, pkt_len);
    if (slot != 10 || hub.slot[c0].slot_id != 10)
        {
          return 6;
        }
    if (sio_ns_sessions_active_c(&sessions, 10) != 1)
        {
          return 7;
        }
    ack_len = sio_server_build_connect_ns_ack_c(ns_chat, 5, &SIO_LIT_SUB[0], 3, ack, 64);
    if (ack_len != 21 || unsafe { memcmp(&ack[0], &expect_ack[0], 21) } != 0)
        {
          return 8;
        }
    if (sio_ws_hub_handle_connect_c(&hub, c1, &router, &sessions, pkt_chat, pkt_len) != 10)
        {
          return 9;
        }
    sent = sio_ws_hub_emit_event_ns_c(&hub, 10, ns_chat, 5, &SIO_LIT_PING[0], 4, &SIO_LIT_OK[0], 2);
    if (sent < 0)
        {
          return 10;
        }
    if (sio_ws_hub_unregister_c(&hub, c0) != 0 || hub.count != 1)
        {
          return 11;
        }
    return 0;
}

function sio_ws_hub_emit_event_ns_conn_c(h: *SioWsHubMem, conn_idx: i32, ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {

    let frame: u8[256] = [];
    let n: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX || event_len <= 0 || (event == 0))
        {
          return -1;
        }
    sl = &h.slot[conn_idx];
    if (sl.in_use == 0 || sl.fd < 0)
        {
          return 0;
        }
    n = sio_encode_event_ns_packet_c(ns, ns_len, event, event_len, data, data_len, frame,  ((frame as usize) as i32));
    if (n <= 0)
        {
          return -1;
        }
    if (unsafe { net_ws_write_server_text_c(sl.fd, sl.tls_ctx, frame, n) } == n)
        {
          return 1;
        }
    return 0;
}

function sio_ws_hub_snapshot_bytes_c(): i32 {
 return 184;
}

function sio_ws_hub_export_c(h: *SioWsHubMem, out: *u8, out_cap: i32): i32 {

    let snap: *SioWsHubSnapshotMem = 0;
    let i: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || (out == 0) || out_cap < 184)
        {
          return -1;
        }
    snap = out as *SioWsHubSnapshotMem;
    snap.magic = (SIO_HUB_SNAP_MAGIC as i32);
    snap.version = SIO_HUB_SNAP_VERSION;
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        sl = &h.slot[i];
        snap.slot[i].in_use = sl.in_use;
        snap.slot[i].sid_len = sl.sid_len;
        snap.slot[i].slot_id = sl.slot_id;
        if (sl.sid_len > 0)
            {
              unsafe { memcpy(&snap.slot[i].sid[0], &sl.sid[0], (sl.sid_len as usize)); }
            }
    }
    return 184;
}

function sio_ws_hub_import_c(h: *SioWsHubMem, buf: *u8, len: i32): i32 {

    let snap: *SioWsHubSnapshotMem = 0;
    let i: i32 = 0;
    let active: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    let ss: *SioWsHubSnapSlotMem = 0;
    if ((h == 0) || (buf == 0) || len < 184)
        {
          return -1;
        }
    snap = buf as *SioWsHubSnapshotMem;
    if (snap.magic != (SIO_HUB_SNAP_MAGIC as i32) || snap.version != SIO_HUB_SNAP_VERSION)
        {
          return -1;
        }
    sio_ws_hub_init_c(h);
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        sl = &h.slot[i];
        ss = &snap.slot[i];
        if (ss.in_use != 0) {
            if (ss.sid_len <= 0 || ss.sid_len > SIO_WS_SID_CAP)
                {
                  return -1;
                }
            sl.in_use = 1;
            sl.fd = -1;
            sl.tls_ctx = 0;
            sl.sid_len = ss.sid_len;
            sl.slot_id = ss.slot_id;
            unsafe { memcpy(&sl.sid[0], &ss.sid[0], (ss.sid_len as usize)); }
            active = active + 1;
        }
    }
    h.count = active;
    return 0;
}

function sio_room_registry_bytes_c(): i32 {
 return 196;
}

function sio_room_registry_init_c(reg: *SioRoomRegistryMem): void {

    if ((reg == 0))
        {
          return;
        }
    unsafe { memset(reg as *u8, 0, (sio_room_registry_bytes_c() as usize)); }
}

function sio_room_alloc_slot_c(reg: *SioRoomRegistryMem): i32 {

    let i: i32 = 0;
    if ((reg == 0))
        {
          return -1;
        }
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        if (reg.room[i].in_use == 0)
            {
              return i;
            }
    }
    return -1;
}

function sio_room_find_id_c(reg: *SioRoomRegistryMem, room_id: i32): i32 {

    let i: i32 = 0;
    if ((reg == 0) || room_id < 0)
        {
          return -1;
        }
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        if (reg.room[i].in_use != 0 && reg.room[i].room_id == room_id)
            {
              return i;
            }
    }
    return -1;
}

function sio_room_register_c(reg: *SioRoomRegistryMem, name: *u8, name_len: i32, room_id: i32): i32 {

    let idx: i32 = 0;
    let rm: *SioRoomMem = 0;
    if ((reg == 0) || room_id < 0)
        {
          return -1;
        }
    if (name_len <= 0 || name_len > SIO_ROOM_NAME_CAP || (name == 0))
        {
          return -1;
        }
    if (sio_room_find_id_c(reg, room_id) >= 0)
        {
          return -1;
        }
    idx = sio_room_alloc_slot_c(reg);
    if (idx < 0)
        {
          return -1;
        }
    rm = &reg.room[idx];
    rm.in_use = 1;
    rm.room_id = room_id;
    rm.name_len = name_len;
    rm.member_count = 0;
    unsafe { memcpy(rm.name, name,  (name_len as usize)); }
    reg.count = reg.count + 1;
    return 0;
}

function sio_room_join_c(reg: *SioRoomRegistryMem, room_id: i32, conn_idx: i32): i32 {

    let idx: i32 = 0;
    let rm: *SioRoomMem = 0;
    let i: i32 = 0;
    if ((reg == 0) || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        {
          return -1;
        }
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        {
          return -1;
        }
    rm = &reg.room[idx];
    for (i = 0; i < rm.member_count; i = i + 1) {
        if (rm.members[i] == conn_idx)
            {
              return 0;
            }
    }
    if (rm.member_count >= SIO_ROOM_MEMBERS_MAX)
        {
          return -1;
        }
    rm.members[rm.member_count] = conn_idx;
    rm.member_count = rm.member_count + 1;
    return 0;
}

function sio_room_leave_c(reg: *SioRoomRegistryMem, room_id: i32, conn_idx: i32): i32 {

    let idx: i32 = 0;
    let rm: *SioRoomMem = 0;
    let i: i32 = 0;
    let j: i32 = 0;
    if ((reg == 0) || conn_idx < 0)
        {
          return -1;
        }
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        {
          return -1;
        }
    rm = &reg.room[idx];
    for (i = 0; i < rm.member_count; i = i + 1) {
        if (rm.members[i] == conn_idx) {
            j = i;
            while (j + 1 < rm.member_count) {
                rm.members[j] = rm.members[j + 1];
                j = j + 1;
            }
            rm.member_count = rm.member_count - 1;
            return 0;
        }
    }
    return 0;
}

function sio_room_leave_all_c(reg: *SioRoomRegistryMem, conn_idx: i32): i32 {

    let i: i32 = 0;
    let n: i32 = 0;
    if ((reg == 0) || conn_idx < 0)
        {
          return -1;
        }
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        if (reg.room[i].in_use == 0)
            {
              continue;
            }
        if (sio_room_leave_c(reg, reg.room[i].room_id, conn_idx) == 0)
            {
              n = n + 1;
            }
    }
    return n;
}

function sio_room_member_count_c(reg: *SioRoomRegistryMem, room_id: i32): i32 {

    let idx: i32 = 0;
    if ((reg == 0))
        {
          return -1;
        }
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        {
          return -1;
        }
    return reg.room[idx].member_count;
}

function sio_room_broadcast_ns_c(reg: *SioRoomRegistryMem, h: *SioWsHubMem, room_id: i32, ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {

    let idx: i32 = 0;
    let rm: *SioRoomMem = 0;
    let i: i32 = 0;
    let sent: i32 = 0;
    let rc: i32 = 0;
    if ((reg == 0) || (h == 0) || event_len <= 0 || (event == 0))
        {
          return -1;
        }
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        {
          return -1;
        }
    rm = &reg.room[idx];
    for (i = 0; i < rm.member_count; i = i + 1) {
        rc = sio_ws_hub_emit_event_ns_conn_c(h, rm.members[i], ns, ns_len, event, event_len, data, data_len);
        if (rc < 0)
            {
              return -1;
            }
        if (rc > 0)
            {
              sent = sent + 1;
            }
    }
    return sent;
}

function sio_room_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let sid_a: *u8 = &SIO_LIT_SNAPA[0];
    let sid_b: *u8 = &SIO_LIT_SNAPB[0];
    let hub: SioWsHubMem;
    let reg: SioRoomRegistryMem;
    let snap: u8[256] = [];
    let snap_len: i32 = 0;
    let c0: i32 = 0;
    let c1: i32 = 0;
    let sent: i32 = 0;
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    c0 = sio_ws_hub_register_c(&hub, 10, 0, sid_a, 5);
    c1 = sio_ws_hub_register_c(&hub, 11, 0, sid_b, 5);
    if (c0 != 0 || c1 != 1)
        {
          return 1;
        }
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg, 1, c0) != 0 || sio_room_join_c(&reg, 1, c1) != 0)
        {
          return 3;
        }
    if (sio_room_member_count_c(&reg, 1) != 2)
        {
          return 4;
        }
    sent = sio_room_broadcast_ns_c(&reg, &hub, 1, ns_chat, 5, &SIO_LIT_MSG[0], 3, &SIO_LIT_HI[0], 2);
    if (sent < 0)
        {
          return 5;
        }
    snap_len = sio_ws_hub_export_c(&hub, snap, 256);
    if (snap_len != sio_ws_hub_snapshot_bytes_c())
        {
          return 6;
        }
    sio_ws_hub_init_c(&hub);
    if (sio_ws_hub_import_c(&hub, snap, snap_len) != 0)
        {
          return 7;
        }
    if (sio_ws_hub_find_by_sid_c(&hub, sid_b, 5) < 0 || hub.count != 2)
        {
          return 8;
        }
    if (hub.slot[0].fd != -1 || hub.slot[0].sid_len != 5)
        {
          return 9;
        }
    if (sio_room_leave_c(&reg, 1, c0) != 0 || sio_room_member_count_c(&reg, 1) != 1)
        {
          return 10;
        }
    if (sio_room_leave_all_c(&reg, c1) < 0 || sio_room_member_count_c(&reg, 1) != 0)
        {
          return 11;
        }
    return 0;
}

function sio_ws_hub_rebind_c(h: *SioWsHubMem, conn_idx: i32, fd: i32, tls_ctx: i64): i32 {

    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX || fd < 0)
        {
          return -1;
        }
    sl = &h.slot[conn_idx];
    if (sl.in_use == 0)
        {
          return -1;
        }
    sl.fd = fd;
    sl.tls_ctx = tls_ctx;
    return 0;
}

function sio_room_registry_snapshot_bytes_c(): i32 {
 return 204;
}

function sio_room_registry_export_c(reg: *SioRoomRegistryMem, out: *u8, out_cap: i32): i32 {

    let snap: *SioRoomRegistrySnapshotMem = 0;
    let i: i32 = 0;
    if ((reg == 0) || (out == 0) || out_cap < 204)
        {
          return -1;
        }
    snap = out as *SioRoomRegistrySnapshotMem;
    snap.magic = (SIO_ROOM_SNAP_MAGIC as i32);
    snap.version = SIO_ROOM_SNAP_VERSION;
    snap.count = reg.count;
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        snap.room[i] = reg.room[i];
    }
    return sio_room_registry_snapshot_bytes_c();
}

function sio_room_registry_import_c(reg: *SioRoomRegistryMem, buf: *u8, len: i32): i32 {

    let snap: *SioRoomRegistrySnapshotMem = 0;
    let i: i32 = 0;
    if ((reg == 0) || (buf == 0) || len <  204)
        {
          return -1;
        }
    snap = buf as *SioRoomRegistrySnapshotMem;
    if (snap.magic != (SIO_ROOM_SNAP_MAGIC as i32) || snap.version != SIO_ROOM_SNAP_VERSION)
        {
          return -1;
        }
    sio_room_registry_init_c(reg);
    reg.count = snap.count;
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        reg.room[i] = snap.room[i];
    }
    return 0;
}

function sio_hub_sync_smoke_c(): i32 {

    let sid: *u8 = &SIO_LIT_SYNC1[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let hub_a: SioWsHubMem;
    let hub_b: SioWsHubMem;
    let reg_a: SioRoomRegistryMem;
    let reg_b: SioRoomRegistryMem;
    let hub_snap: u8[256] = [];
    let room_snap: u8[256] = [];
    let hl: i32 = 0;
    let rl: i32 = 0;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 20, 0, sid, 5) != 0)
        {
          return 1;
        }
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        {
          return 3;
        }
    hl = sio_ws_hub_export_c(&hub_a, hub_snap, 256);
    rl = sio_room_registry_export_c(&reg_a, room_snap, 256);
    if (hl != sio_ws_hub_snapshot_bytes_c() || rl != sio_room_registry_snapshot_bytes_c())
        {
          return 4;
        }
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_ws_hub_import_c(&hub_b, hub_snap, hl) != 0)
        {
          return 5;
        }
    if (sio_room_registry_import_c(&reg_b, room_snap, rl) != 0)
        {
          return 6;
        }
    if (sio_ws_hub_find_by_sid_c(&hub_b, sid, 5) != 0 || hub_b.count != 1)
        {
          return 7;
        }
    if (hub_b.slot[0].fd != -1)
        {
          return 8;
        }
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        {
          return 9;
        }
    if (sio_ws_hub_rebind_c(&hub_b, 0, 99, 0) != 0 || hub_b.slot[0].fd != 99)
        {
          return 10;
        }
    return 0;
}

function sio_session_bundle_bytes_c(): i32 {
 return 396;
}

function sio_session_bundle_export_c(h: *SioWsHubMem, reg: *SioRoomRegistryMem, out: *u8, out_cap: i32): i32 {

    let bundle: *SioSessionBundleMem = 0;
    let i: i32 = 0;
    let sl: *SioWsHubSlotMem = 0;
    if ((h == 0) || (reg == 0) || (out == 0) || out_cap < 396)
        {
          return -1;
        }
    bundle = out as *SioSessionBundleMem;
    bundle.magic = (SIO_SESSION_SNAP_MAGIC as i32);
    bundle.version = SIO_SESSION_SNAP_VERSION;
    bundle.hub.magic = (SIO_HUB_SNAP_MAGIC as i32);
    bundle.hub.version = SIO_HUB_SNAP_VERSION;
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        sl = &h.slot[i];
        bundle.hub.slot[i].in_use = sl.in_use;
        bundle.hub.slot[i].sid_len = sl.sid_len;
        bundle.hub.slot[i].slot_id = sl.slot_id;
        if (sl.sid_len > 0)
            {
              unsafe { memcpy(&bundle.hub.slot[i].sid[0], &sl.sid[0], (sl.sid_len as usize)); }
            }
    }
    bundle.room.magic = (SIO_ROOM_SNAP_MAGIC as i32);
    bundle.room.version = SIO_ROOM_SNAP_VERSION;
    bundle.room.count = reg.count;
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        bundle.room.room[i] = reg.room[i];
    }
    return sio_session_bundle_bytes_c();
}

function sio_session_bundle_import_c(h: *SioWsHubMem, reg: *SioRoomRegistryMem, buf: *u8, len: i32): i32 {

    let bundle: *SioSessionBundleMem = 0;
    if ((h == 0) || (reg == 0) || (buf == 0) || len <  396)
        {
          return -1;
        }
    bundle = buf as *SioSessionBundleMem;
    if (bundle.magic != (SIO_SESSION_SNAP_MAGIC as i32) || bundle.version != SIO_SESSION_SNAP_VERSION)
        {
          return -1;
        }
    if (sio_ws_hub_import_c(h, (&bundle.hub) as *u8, sio_ws_hub_snapshot_bytes_c()) != 0)
        {
          return -1;
        }
    if (sio_room_registry_import_c(reg, (&bundle.room) as *u8, sio_room_registry_snapshot_bytes_c()) != 0)
        {
          return -1;
        }
    return 0;
}

function sio_session_sync_smoke_c(): i32 {

    let sid: *u8 = &SIO_LIT_SESS1[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let hub_a: SioWsHubMem;
    let hub_b: SioWsHubMem;
    let reg_a: SioRoomRegistryMem;
    let reg_b: SioRoomRegistryMem;
    let bundle_buf: u8[512] = [];
    let blen: i32 = 0;
    let idx: i32 = 0;
    let sent: i32 = 0;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 30, 0, sid, 5) != 0)
        {
          return 1;
        }
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        {
          return 3;
        }
    blen = sio_session_bundle_export_c(&hub_a, &reg_a, bundle_buf, 512);
    if (blen != sio_session_bundle_bytes_c())
        {
          return 4;
        }
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_session_bundle_import_c(&hub_b, &reg_b, bundle_buf, blen) != 0)
        {
          return 5;
        }
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        {
          return 6;
        }
    idx = sio_ws_hub_register_or_rebind_c(&hub_b, 88, 0, sid, 5);
    if (idx != 0 || hub_b.slot[0].fd != 88)
        {
          return 7;
        }
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        {
          return 8;
        }
    sent = sio_room_broadcast_ns_c(&reg_b, &hub_b, 1, ns_chat, 5, &SIO_LIT_MSG[0], 3, &SIO_LIT_HI[0], 2);
    if (sent < 0)
        {
          return 9;
        }
    return 0;
}

function sio_ws_hub_recount_c(h: *SioWsHubMem): void {

    let i: i32 = 0;
    let c: i32 = 0;
    if ((h == 0))
        {
          return;
        }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        if (h.slot[i].in_use != 0)
            {
              c = c + 1;
            }
    }
    h.count = c;
}

function sio_ws_hub_append_from_c(dst: *SioWsHubMem, src: *SioWsHubMem): i32 {

    let i: i32 = 0;
    let j: i32 = 0;
    let start: i32 = -1;
    if ((dst == 0) || (src == 0))
        {
          return -1;
        }
    for (i = 0; i < SIO_WS_HUB_MAX; i = i + 1) {
        let sl: *SioWsHubSlotMem = &src.slot[i];
        if (sl.in_use == 0)
            {
              continue;
            }
        j = sio_ws_hub_alloc_slot_c(dst);
        if (j < 0)
            {
              return -1;
            }
        if (start < 0)
            {
              start = j;
            }
        dst.slot[j] = *sl;
        dst.slot[j].fd = -1;
        dst.slot[j].tls_ctx = 0;
    }
    sio_ws_hub_recount_c(dst);
    return start >= 0 ? start : 0;
}

function sio_room_registry_merge_offset_c(dst: *SioRoomRegistryMem, src: *SioRoomRegistryMem, conn_offset: i32): i32 {

    let i: i32 = 0;
    let j: i32 = 0;
    let k: i32 = 0;
    let room_id: i32 = 0;
    let sr: *SioRoomMem = 0;
    if ((dst == 0) || (src == 0) || conn_offset < 0)
        {
          return -1;
        }
    for (i = 0; i < SIO_ROOM_MAX; i = i + 1) {
        sr = &src.room[i];
        if (sr.in_use != 0) {
            room_id = sr.room_id;
            if (sio_room_find_id_c(dst, room_id) < 0) {
                if (sio_room_register_c(dst, sr.name, sr.name_len, room_id) != 0)
                    {
                      return -1;
                    }
            }
            j = 0;
            while (j < sr.member_count) {
                k = sr.members[j] + conn_offset;
                if (k < 0 || k >= SIO_WS_HUB_MAX)
                    {
                      return -1;
                    }
                if (sio_room_join_c(dst, room_id, k) != 0)
                    {
                      return -1;
                    }
                j = j + 1;
            }
        }
    }
    return 0;
}

function sio_cluster_sync_c(h: *SioWsHubMem, reg: *SioRoomRegistryMem, bundle_a: *u8, len_a: i32, bundle_b: *u8, len_b: i32): i32 {

    let hub_b: SioWsHubMem;
    let reg_b: SioRoomRegistryMem;
    let off: i32 = 0;
    if ((h == 0) || (reg == 0) || (bundle_a == 0) || (bundle_b == 0))
        {
          return -1;
        }
    if (sio_session_bundle_import_c(h, reg, bundle_a, len_a) != 0)
        {
          return -1;
        }
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_session_bundle_import_c(&hub_b, &reg_b, bundle_b, len_b) != 0)
        {
          return -1;
        }
    off = sio_ws_hub_append_from_c(h, &hub_b);
    if (off < 0)
        {
          return -1;
        }
    return sio_room_registry_merge_offset_c(reg, &reg_b, off);
}

function sio_cluster_sync_smoke_c(): i32 {

    let sid_a: *u8 = &SIO_LIT_NODEA[0];
    let sid_b: *u8 = &SIO_LIT_NODEB[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let hub_a: SioWsHubMem;
    let hub_b: SioWsHubMem;
    let hub_c: SioWsHubMem;
    let reg_a: SioRoomRegistryMem;
    let reg_b: SioRoomRegistryMem;
    let reg_c: SioRoomRegistryMem;
    let bundle_a: u8[512] = [];
    let bundle_b: u8[512] = [];
    let len_a: i32 = 0;
    let len_b: i32 = 0;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 40, 0, sid_a, 5) != 0)
        {
          return 1;
        }
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        {
          return 3;
        }
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_ws_hub_register_c(&hub_b, 41, 0, sid_b, 5) != 0)
        {
          return 4;
        }
    if (sio_room_register_c(&reg_b, room_name, 5, 1) != 0)
        {
          return 5;
        }
    if (sio_room_join_c(&reg_b, 1, 0) != 0)
        {
          return 6;
        }
    len_a = sio_session_bundle_export_c(&hub_a, &reg_a, bundle_a, 512);
    len_b = sio_session_bundle_export_c(&hub_b, &reg_b, bundle_b, 512);
    if (len_a != sio_session_bundle_bytes_c() || len_b != sio_session_bundle_bytes_c())
        {
          return 7;
        }
    sio_ws_hub_init_c(&hub_c);
    sio_room_registry_init_c(&reg_c);
    if (sio_cluster_sync_c(&hub_c, &reg_c, bundle_a, len_a, bundle_b, len_b) != 0)
        {
          return 8;
        }
    if (hub_c.count != 2 || sio_room_member_count_c(&reg_c, 1) != 2)
        {
          return 9;
        }
    if (sio_ws_hub_find_by_sid_c(&hub_c, sid_a, 5) != 0 || sio_ws_hub_find_by_sid_c(&hub_c, sid_b, 5) != 1)
        {
          return 10;
        }
    if (hub_c.slot[0].fd != -1 || hub_c.slot[1].fd != -1)
        {
          return 11;
        }
    return 0;
}

function sio_cluster_adapter_bytes_c(): i32 {
 return 296;
}

function sio_cluster_adapter_init_c(a: *SioClusterAdapterMem, node_id: i32): void {

    if ((a == 0))
        {
          return;
        }
    unsafe { memset(a as *u8, 0, (sio_cluster_adapter_bytes_c() as usize)); }
    a.node_id = node_id;
}

function sio_cluster_adapter_alloc_c(a: *SioClusterAdapterMem): i32 {

    let i: i32 = 0;
    if ((a == 0))
        {
          return -1;
        }
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i = i + 1) {
        if (a.msg[i].in_use == 0)
            {
              return i;
            }
    }
    return -1;
}

function sio_cluster_adapter_publish_ns_c(a: *SioClusterAdapterMem, src_node_id: i32, room_id: i32, ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32): i32 {

    let idx: i32 = 0;
    let m: *SioClusterAdapterMsgMem = 0;
    if ((a == 0) || src_node_id < 0 || room_id < 0 || event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (ns_len < 0 || ns_len > SIO_CLUSTER_ADAPTER_NS_CAP)
        {
          return -1;
        }
    if (event_len > SIO_CLUSTER_ADAPTER_EVT_CAP)
        {
          return -1;
        }
    if (data_len < 0 || data_len > SIO_CLUSTER_ADAPTER_DATA_CAP)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    idx = sio_cluster_adapter_alloc_c(a);
    if (idx < 0)
        {
          return -1;
        }
    m = &a.msg[idx];
    m.in_use = 1;
    m.src_node_id = src_node_id;
    m.room_id = room_id;
    m.ns_len = ns_len;
    m.event_len = event_len;
    m.data_len = data_len;
    if (ns_len > 0 && ns != 0)
        {
          unsafe { memcpy(&m.ns[0], ns, (ns_len as usize)); }
        }
    unsafe { memcpy(&m.event[0], event, (event_len as usize)); }
    if (data_len > 0)
        {
          unsafe { memcpy(&m.data[0], data, (data_len as usize)); }
        }
    a.count = a.count + 1;
    return 0;
}

function sio_cluster_adapter_drain_apply_c(a: *SioClusterAdapterMem, h: *SioWsHubMem, reg: *SioRoomRegistryMem, local_node_id: i32): i32 {

    let i: i32 = 0;
    let applied: i32 = 0;
    let sent: i32 = 0;
    let m: *SioClusterAdapterMsgMem = 0;
    if ((a == 0) || (h == 0) || (reg == 0) || local_node_id < 0)
        {
          return -1;
        }
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i = i + 1) {
        m = &a.msg[i];
        if (m.in_use == 0)
            {
              continue;
            }
        if (m.src_node_id == local_node_id)
            {
              continue;
            }
        sent = sio_room_broadcast_ns_c(reg, h, m.room_id, m.ns, m.ns_len, m.event, m.event_len, m.data,
                                       m.data_len);
        if (sent < 0)
            {
              return -1;
            }
        m.in_use = 0;
        if (a.count > 0)
            {
              a.count = a.count - 1;
            }
        applied = applied + 1;
    }
    return applied;
}

function sio_cluster_adapter_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let sid: *u8 = &SIO_LIT_ND2[0];
    let adapter: SioClusterAdapterMem;
    let hub: SioWsHubMem;
    let reg: SioRoomRegistryMem;
    let applied: i32 = 0;
    sio_cluster_adapter_init_c(&adapter, 2);
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    if (sio_ws_hub_register_c(&hub, 50, 0, sid, 3) != 0)
        {
          return 1;
        }
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg, 1, 0) != 0)
        {
          return 3;
        }
    if (sio_cluster_adapter_publish_ns_c(&adapter, 1, 1, ns_chat, 5, &SIO_LIT_MSG[0], 3, &SIO_LIT_HI[0], 2) != 0)
        {
          return 4;
        }
    applied = sio_cluster_adapter_drain_apply_c(&adapter, &hub, &reg, 2);
    if (applied != 1)
        {
          return 5;
        }
    if (adapter.count != 0)
        {
          return 6;
        }
    return 0;
}

function sio_cluster_adapter_snapshot_bytes_c(): i32 {
 return 304;
}

function sio_cluster_adapter_export_c(a: *SioClusterAdapterMem, out: *u8, out_cap: i32): i32 {

    let snap: *SioClusterAdapterSnapshotMem = 0;
    let i: i32 = 0;
    if ((a == 0) || (out == 0) || out_cap < 304)
        {
          return -1;
        }
    snap = out as *SioClusterAdapterSnapshotMem;
    snap.magic = (SIO_ADAPTER_SNAP_MAGIC as i32);
    snap.version = SIO_ADAPTER_SNAP_VERSION;
    snap.count = a.count;
    snap.node_id = a.node_id;
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i = i + 1) {
        snap.msg[i] = a.msg[i];
    }
    return sio_cluster_adapter_snapshot_bytes_c();
}

function sio_cluster_adapter_import_merge_c(a: *SioClusterAdapterMem, buf: *u8, len: i32): i32 {

    let snap: *SioClusterAdapterSnapshotMem = 0;
    let i: i32 = 0;
    let j: i32 = 0;
    let merged: i32 = 0;
    let dst: *SioClusterAdapterMsgMem = 0;
    let src: *SioClusterAdapterMsgMem = 0;
    if ((a == 0) || (buf == 0) || len <  304)
        {
          return -1;
        }
    snap = buf as *SioClusterAdapterSnapshotMem;
    if (snap.magic != (SIO_ADAPTER_SNAP_MAGIC as i32) || snap.version != SIO_ADAPTER_SNAP_VERSION)
        {
          return -1;
        }
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i = i + 1) {
        src = &snap.msg[i];
        if (src.in_use == 0)
            {
              continue;
            }
        j = sio_cluster_adapter_alloc_c(a);
        if (j < 0)
            {
              return -1;
            }
        dst = &a.msg[j];
        *dst = *src;
        merged = merged + 1;
        a.count = a.count + 1;
    }
    return merged;
}

function sio_cluster_ring_sync_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let room_name: *u8 = &SIO_LIT_LOBBY[0];
    let sid: *u8 = &SIO_LIT_ND2[0];
    let adapter_a: SioClusterAdapterMem;
    let adapter_b: SioClusterAdapterMem;
    let hub: SioWsHubMem;
    let reg: SioRoomRegistryMem;
    let snap: u8[512] = [];
    let slen: i32 = 0;
    let merged: i32 = 0;
    let applied: i32 = 0;
    sio_cluster_adapter_init_c(&adapter_a, 1);
    sio_cluster_adapter_init_c(&adapter_b, 2);
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    if (sio_ws_hub_register_c(&hub, 60, 0, sid, 3) != 0)
        {
          return 1;
        }
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        {
          return 2;
        }
    if (sio_room_join_c(&reg, 1, 0) != 0)
        {
          return 3;
        }
    if (sio_cluster_adapter_publish_ns_c(&adapter_a, 1, 1, ns_chat, 5, &SIO_LIT_MSG[0], 3, &SIO_LIT_HI[0], 2) != 0)
        {
          return 4;
        }
    slen = sio_cluster_adapter_export_c(&adapter_a, snap, 512);
    if (slen != sio_cluster_adapter_snapshot_bytes_c())
        {
          return 5;
        }
    merged = sio_cluster_adapter_import_merge_c(&adapter_b, snap, slen);
    if (merged != 1)
        {
          return 6;
        }
    applied = sio_cluster_adapter_drain_apply_c(&adapter_b, &hub, &reg, 2);
    if (applied != 1)
        {
          return 7;
        }
    return 0;
}


function sio_eio_encode_packet_c(type: i32, payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {

    let n: i32 = 0;
    if ((out == 0) || out_cap < 1)
        {
          return -1;
        }
    if (type < 0 || type > 9)
        {
          return -1;
        }
    if (payload_len < 0)
        {
          return -1;
        }
    if (payload_len > 0 && (payload == 0))
        {
          return -1;
        }
    if (1 + payload_len > out_cap)
        {
          return -1;
        }
    out[0] = (48 + type) as u8;
    n = 1;
    if (payload_len > 0) {
        unsafe { memcpy(out + 1, payload, (payload_len as usize)); }
        n = n + payload_len;
    }
    return n;
}

function sio_eio_decode_packet_c(buf: *u8, len: i32, out_type: *i32, out_payload: *u8, out_cap: i32, out_payload_len: *i32): i32 {

    let type: i32 = 0;
    let plen: i32 = 0;
    if ((buf == 0) || len <= 0 || (out_type == 0) || (out_payload_len == 0))
        {
          return -1;
        }
    if (buf[0] < (48 as u8) || buf[0] > (57 as u8))
        {
          return -1;
        }
    type = (buf[0] - (48 as u8)) as i32;
    plen = len - 1;
    if (plen < 0)
        {
          plen = 0;
        }
    if (plen > 0) {
        if ((out_payload == 0))
            {
              return -1;
            }
        if (plen > out_cap)
            {
              return -1;
            }
        unsafe { memcpy(out_payload, buf + 1, (plen as usize)); }
    }
    out_type[0] = type;
    out_payload_len[0] = plen;
    return 0;
}

function sio_append_json_string(out: *u8, cap: i32, off: *i32, s: *u8, slen: i32): i32 {

    let i: i32 = 0;
    let c: u8 = 0;
    if ((out == 0) || (off == 0) || *off < 0)
        {
          return -1;
        }
    if (slen > 0 && (s == 0))
        {
          return -1;
        }
    if (*off + 1 >= cap)
        {
          return -1;
        }
    out[sio_bump_off(off)] = (34 as u8);
    for (i = 0; i < slen; i = i + 1) {
        c = s[i];
        if (c == (34 as u8) || c == (92 as u8)) {
            if (*off + 2 >= cap)
                {
                  return -1;
                }
            out[sio_bump_off(off)] = (92 as u8);
            out[sio_bump_off(off)] = c;
            continue;
        }
        if (*off >= cap)
            {
              return -1;
            }
        out[sio_bump_off(off)] = c;
    }
    if (*off >= cap)
        {
          return -1;
        }
    out[sio_bump_off(off)] = (34 as u8);
    return 0;
}

function sio_encode_event_packet_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if ((out == 0) || out_cap < 4)
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_encode_event_ns_packet_c(ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if ((out == 0) || out_cap < 4)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8)))
        {
          return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
        }
    if (ns[0] != (47 as u8))
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    if (sio_append_bytes(inner, ((inner as usize) as i32), &off, ns, ns_len) != 0)
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_encode_event_ack_packet_c(ack_id: i32, event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if (ack_id < 0 || (out == 0))
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    if (sio_append_u32_dec(inner, ((inner as usize) as i32), &off, ack_id as u32) != 0)
        {
          return -1;
        }
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}
function sio_encode_ack_packet_c(ack_id: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[256] = [];
    let off: i32 = 0;
    if (ack_id < 0 || (out == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = ((48 as u8) +  SIO_SIO_ACK);
    off = off + 1;
    if (sio_append_u32_dec(inner,  ((inner as usize) as i32), &off, ack_id as u32) != 0)
        {
          return -1;
        }
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner,  ((inner as usize) as i32), &off, data, data_len) != 0)
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_ns_ack_smoke_c(): i32 {

    let ns_chat: *u8 = &SIO_LIT_CHAT[0];
    let expect_ns: *u8 = &SIO_LIT_N40_CHAT[0];
    let evt: *u8 = &SIO_LIT_PING[0];
    let data: *u8 = &SIO_LIT_PONG[0];
    let expect_evt_ack: u8[20] = [52, 50, 49, 50, 51, 91, 34, 112, 105, 110, 103, 34, 44, 34, 112, 111, 110, 103, 34, 93];
    let expect_evt_ns: u8[21] = [52, 50, 47, 99, 104, 97, 116, 44, 91, 34, 112, 105, 110, 103, 34, 44, 34, 120, 34, 93];
    let expect_ack: u8[10] = [52, 51, 53, 51, 91, 34, 111, 107, 34, 93];
    let enc: u8[64] = [];
    let evt_out: u8[16] = [];
    let data_out: u8[16] = [];
    let stype: i32 = -1;
    let sid: i32 = -1;
    let poff: i32 = 0;
    let dlen: i32 = 0;
    let n: i32 = 0;
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, enc, 64);
    if (n != unsafe { ((strlen(expect_ns) as i32)) } || unsafe { memcmp(&enc[0], expect_ns, (n as usize)) } != 0)
        {
          return 1;
        }
    if (sio_server_is_connect_ns_packet_c(enc, n, ns_chat, 5) != 1)
        {
          return 2;
        }
    if (sio_server_is_connect_ns_packet_c(&SIO_LIT_N40[0], 2, &SIO_LIT_NS_ROOT[0], 1) != 1)
        {
          return 3;
        }
    n = sio_encode_event_ack_packet_c(123, evt, 4, data, 4, enc, 64);
    if (n != 20 || unsafe { memcmp(&enc[0], &expect_evt_ack[0], 20) } != 0)
        {
          return 4;
        }
    if (sio_parse_sio_packet_head_c(&enc[1], n - 1, &stype, &sid, &poff) != 0)
        {
          return 5;
        }
    if (stype != SIO_SIO_EVENT || sid != 123 || enc[1 + poff] != (91 as u8))
        {
          return 6;
        }
    if (sio_decode_event_packet_c(&enc[1], n - 1, &evt_out[0], 16, &data_out[0], 16, &dlen) != 0)
        {
          return 7;
        }
    n = sio_encode_event_ns_packet_c(ns_chat, 5, evt, 4, &SIO_LIT_X[0], 1, enc, 64);
    if (n != 21 || unsafe { memcmp(&enc[0], &expect_evt_ns[0], 21) } != 0)
        {
          return 11;
        }
    if (sio_decode_event_packet_c(&enc[1], n - 1, &evt_out[0], 16, &data_out[0], 16, &dlen) != 0)
        {
          return 12;
        }
    if (dlen != 1 || data_out[0] != (120 as u8))
        {
          return 13;
        }
    n = sio_encode_ack_packet_c(53, &SIO_LIT_OK[0], 2, enc, 64);
    if (n != 10 || unsafe { memcmp(&enc[0], &expect_ack[0], 10) } != 0)
        {
          return 8;
        }
    if (sio_parse_sio_packet_head_c(&enc[1], n - 1, &stype, &sid, &poff) != 0)
        {
          return 9;
        }
    if (stype != SIO_SIO_ACK || sid != 53)
        {
          return 10;
        }
    return 0;
}


function sio_decode_event_packet_c(sio_pkt: *u8, len: i32, out_event: *u8, out_event_cap: i32, out_data: *u8, out_data_cap: i32, out_data_len: *i32): i32 {

    let i: i32 = 0;
    let ei: i32 = 0;
    let di: i32 = 0;
    let c: u8 = 0;
    if ((sio_pkt == 0) || len < 5 || (out_event == 0) || (out_data == 0) || (out_data_len == 0))
        {
          return -1;
        }
    if (sio_pkt[0] != (48 + SIO_SIO_EVENT) as u8)
        {
          return -1;
        }
    i = 1;
    while (i < len && sio_pkt[i] >= (48 as u8) && sio_pkt[i] <= (57 as u8)) {
        i = i + 1;
    }
    if (i < len && sio_pkt[i] == (47 as u8)) {
        while (i < len && sio_pkt[i] != (44 as u8)) {
            i = i + 1;
        }
        if (i >= len)
            {
              return -1;
            }
        i = i + 1;
    }
    if (i + 3 >= len || sio_pkt[i] != (91 as u8) || sio_pkt[i + 1] != (34 as u8))
        {
          return -1;
        }
    i = i + 2;
    while (i < len) {
        c = sio_pkt[i];
        if (c == (34 as u8))
            {
              break;
            }
        if (c == (92 as u8) && i + 1 < len) {
            if (ei + 1 >= out_event_cap)
                {
                  return -1;
                }
            i = i + 1;
            out_event[ei] = sio_pkt[i];
            ei = ei + 1;
        } else {
            if (ei + 1 >= out_event_cap)
                {
                  return -1;
                }
            out_event[ei] = c;
            ei = ei + 1;
            i = i + 1;
        }
    }
    if (i >= len || ei <= 0)
        {
          return -1;
        }
    out_event[ei] = (0 as u8);
    i = i + 2;
    if (i >= len)
        {
          return -1;
        }
    if (sio_pkt[i] == (110 as u8) && i + 3 < len && sio_pkt[i + 1] == (117 as u8)) {
        out_data_len[0] = 0;
        return 0;
    }
    if (sio_pkt[i] != (34 as u8))
        {
          return -1;
        }
    i = i + 1;
    while (i < len) {
        c = sio_pkt[i];
        if (c == (34 as u8))
            {
              break;
            }
        if (c == (92 as u8) && i + 1 < len) {
            if (di >= out_data_cap)
                {
                  return -1;
                }
            i = i + 1;
            out_data[di] = sio_pkt[i];
            di = di + 1;
        } else {
            if (di >= out_data_cap)
                {
                  return -1;
                }
            out_data[di] = c;
            di = di + 1;
            i = i + 1;
        }
    }
    if (i >= len)
        {
          return -1;
        }
    out_data_len[0] = di;
    return 0;
}

function sio_eio_extract_sid_c(open_payload: *u8, len: i32, out_sid: *u8, out_cap: i32): i32 {

    let needle: *u8 = &SIO_LIT_JSON_SID_PREFIX[0];
    let i: i32 = 0;
    let j: i32 = 0;
    let sid_len: i32 = 0;
    if ((open_payload == 0) || len <= 0 || (out_sid == 0) || out_cap < 2)
        {
          return -1;
        }
    for (i = 0; i + 7 <= len; i = i + 1) {
        if (unsafe { memcmp(open_payload + i, needle, 7) } == 0) {
            j = i + 7;
            sid_len = 0;
            while (j < len && open_payload[j] != (34 as u8)) {
                if (sid_len + 1 >= out_cap)
                    {
                      return -1;
                    }
                out_sid[sid_len] = open_payload[j];
                sid_len = sid_len + 1;
                j = j + 1;
            }
            if (sid_len <= 0)
                {
                  return -1;
                }
            return sid_len;
        }
    }
    return -1;
}

function sio_packet_smoke_c(): i32 {

    let open_json: u8[128] = [];
    let enc: u8[64] = [];
    let dec_payload: u8[64] = [];
    let evt: u8[32] = [];
    let data: u8[32] = [];
    let sid: u8[16] = [];
    let sid_expect: *u8 = &SIO_LIT_ABC[0];
    let n: i32 = 0;
    let type: i32 = -1;
    let plen: i32 = 0;
    let dlen: i32 = 0;
    let jl: i32 = 0;
    jl = sio_server_build_open_json_c(sid_expect, 3, open_json, ((open_json as usize) as i32));
    if (jl <= 0)
        {
          return 1;
        }
    n = sio_eio_encode_packet_c(SIO_EIO_OPEN, &open_json[0], jl, &enc[0], 64);
    if (n <= 0)
        {
          return 1;
        }
    if (sio_eio_decode_packet_c(&enc[0], n, &type, &dec_payload[0], 64, &plen) != 0)
        {
          return 2;
        }
    if (type != SIO_EIO_OPEN || plen != jl)
        {
          return 3;
        }
    if (sio_eio_extract_sid_c(&dec_payload[0], plen, &sid[0], 16) != 3)
        {
          return 4;
        }
    if (unsafe { memcmp(&sid[0], sid_expect, 3) } != 0)
        {
          return 5;
        }
    n = sio_encode_event_packet_c(&SIO_LIT_HELLO[0], 5, &SIO_LIT_WORLD[0], 5, &enc[0], 64);
    if (n <= 0)
        {
          return 6;
        }
    if (enc[0] != (48 + SIO_EIO_MESSAGE) as u8)
        {
          return 7;
        }
    if (sio_decode_event_packet_c(&enc[1], n - 1, &evt[0], 32, &data[0], 32, &dlen) != 0)
        {
          return 8;
        }
    if (evt[0] != (104 as u8) || dlen != 5 || data[0] != (119 as u8))
        {
          return 9;
        }
    n = sio_eio_encode_packet_c(SIO_EIO_PING, 0, 0, &enc[0], 64);
    if (n != 1 || enc[0] != (48 + SIO_EIO_PING) as u8)
        {
          return 10;
        }
    if (sio_polling_smoke_c() != 0)
        {
          return 11;
        }
    if (sio_connect_smoke_c() != 0)
        {
          return 12;
        }
    if (sio_node_interop_smoke_c() != 0)
        {
          return 13;
        }
    if (sio_server_smoke_c() != 0)
        {
          return 14;
        }
    if (sio_ns_ack_smoke_c() != 0)
        {
          return 15;
        }
    if (sio_ns_router_smoke_c() != 0)
        {
          return 16;
        }
    if (sio_ns_sessions_smoke_c() != 0)
        {
          return 17;
        }
    return 0;
}

function sio_p3_complete_smoke_c(): i32 {

    if (sio_ws_hub_smoke_c() != 0)
        {
          return 1;
        }
    if (sio_room_smoke_c() != 0)
        {
          return 2;
        }
    if (sio_hub_sync_smoke_c() != 0)
        {
          return 3;
        }
    if (sio_session_sync_smoke_c() != 0)
        {
          return 4;
        }
    if (sio_cluster_sync_smoke_c() != 0)
        {
          return 5;
        }
    if (sio_cluster_adapter_smoke_c() != 0)
        {
          return 6;
        }
    if (sio_cluster_ring_sync_smoke_c() != 0)
        {
          return 7;
        }
    return 0;
}
