# std.socketio（P3 可选）

Engine.IO / Socket.IO **v0–v16**（STD-SOCKETIO-001 · **P3 收口**）。

## 层级

| 版本 | 能力 |
|------|------|
| v0 | EIO/SIO 包编解码 |
| v1 | polling URL / GET·POST |
| v2 | `connect` + WS 升级 |
| v3 | `reconnect_once` / Node 金样 |
| v4 | **server** open 响应 / 握手路径检测 |
| v5 | **server emit** + npm live 可选 |
| v6 | **namespace / ACK** + WS server emit |
| v7 | **multi-ns router** + npm live `/chat` CONNECT |
| v8 | **multi-ns sessions** + WS 直连 `/chat` ping/pong npm live |
| v9 | **WS hub** sid 持久映射 + 按 slot 多路复用 server emit |
| v10 | **room** 广播 + hub 二进制快照 export/import |
| v11 | **hub sync** rebind + room 快照 + npm room live |
| v12 | **session bundle** 一体快照 + register_or_rebind + npm mw live |
| v13 | **cluster sync** 两节点合并 + npm plugin live |
| v14 | **cluster adapter** 内存 pub/sub（Redis 接口占位） |
| v15 | **cluster ring** SIOA 快照 export/import_merge |
| v16 | **P3 收口** `p3_complete_smoke` + all-live 编排 |

## P3 收口

| 脚本 | 说明 |
|------|------|
| `./tests/run-std-socketio-gate.sh` | manifest + 14 项 smoke（含 `p3_complete`） |
| `SHUX_SOCKETIO_ALL_LIVE=1 ./tests/run-std-socketio-all-live.sh` | gate + 全部 live 编排 |

## client v8 API（WS 直连）

| 函数 | 说明 |
|------|------|
| `connect_ws_fresh` / `connect_ws_fresh_ns` | 无 polling sid 的 WS 直连 + ns CONNECT |
| `emit_event_ws_ns` / `sio_encode_event_ns` | namespace EVENT（`42/chat,[...]`） |
| `client_ws_fresh_ns_event_roundtrip` | WS 直连 emit/read 往返（npm live gate） |
| `ws_finish_eio_upgrade` | polling→WS probe（`2probe`/`3probe`/`5`） |

## server v9 API（WS hub）

| 函数 | 说明 |
|------|------|
| `ws_hub_init` / `ws_hub_register` / `ws_hub_unregister` | sid→fd 持久映射（内存） |
| `ws_hub_find_by_sid` / `ws_hub_handle_connect` | sid 查找 / CONNECT 绑定 slot |
| `ws_hub_emit_to_slot` | 向同 slot 全部 WS 连接推送 ns EVENT |
| `server_build_connect_ns_ack` / `server_emit_event_ws_ns` | CONNECT ACK / 单连接 ns emit |
| `ws_hub_smoke` | 无网络烟测 |

## server v10 API（room + 快照）

| 函数 | 说明 |
|------|------|
| `room_registry_init` / `room_register` | room 表 init / 注册 |
| `room_join` / `room_leave` / `room_leave_all` | 成员 join/leave |
| `room_member_count` / `room_broadcast_ns` | 成员数 / room 内 ns 广播 |
| `ws_hub_export` / `ws_hub_import` | hub 快照（可写 std.fs 持久化） |
| `room_smoke` | 无网络烟测 |

## server v11 API（跨进程同步）

| 函数 | 说明 |
|------|------|
| `ws_hub_rebind` | import 后重绑 fd/tls |
| `room_registry_export` / `room_registry_import` | room SIOR 快照 |
| `hub_sync_smoke` | 跨进程同步烟测 |

## server v12 API（session 一体快照）

| 函数 | 说明 |
|------|------|
| `session_bundle_export` / `session_bundle_import` | hub + room SIOS 一体快照 |
| `ws_hub_register_or_rebind` | import 后 sid 重绑（room 成员不变） |
| `session_sync_smoke` | 无网络烟测 |

## server v13 API（集群合并）

| 函数 | 说明 |
|------|------|
| `cluster_sync` | 两节点 session bundle 合并 |
| `ws_hub_append_from` / `room_registry_merge_offset` | hub/room 集群合并原语 |
| `cluster_sync_smoke` | 无网络烟测 |

## server v14 API（cluster adapter）

| 函数 | 说明 |
|------|------|
| `cluster_adapter_init` / `cluster_adapter_publish_ns` | 内存 adapter init/publish |
| `cluster_adapter_drain_apply` | 消费并本地 room 广播 |
| `cluster_adapter_smoke` | 无网络烟测 |

## server v15 API（cluster ring）

| 函数 | 说明 |
|------|------|
| `cluster_adapter_export` / `cluster_adapter_import_merge` | SIOA 快照跨节点 ring |
| `cluster_ring_sync_smoke` | 无网络烟测 |

## server v4 API

| 函数 | 说明 |
|------|------|
| `server_build_open_packet` | `0{"sid":...}` |
| `server_build_http_open_response` | HTTP 200 + open body |
| `server_emit_event` / `server_build_http_event_response` | 推送 EVENT |
| `server_emit_event_ws` | WS 服务端推送 |
| `encode_connect_ns_packet` / `encode_event_ack_packet` / `encode_ack_packet` | namespace / ACK |
| `ns_router_*` / `parse_connect_ns` | 多 namespace 路由 |
| `ns_sessions_*` / `connect_ws_ns` / `connect_ns` | 并发会话 + WS ns 连接 |
| `connect_ws_fresh*` / `client_ws_fresh_ns_event_roundtrip` | WS 直连 e2e |
| `emit_event_ws_ns` / `sio_encode_event_ns` | namespace EVENT 编解码 |
| `ws_read_text` | WS 读帧 |
| `server_emit_smoke` / `ns_*_smoke` | 烟测 |

```bash
./tests/run-std-socketio-gate.sh
SHUX_SOCKETIO_LIVE=1 ./tests/run-std-socketio-live.sh
SHUX_SOCKETIO_NPM=1 ./tests/run-std-socketio-npm-live.sh
SHUX_SOCKETIO_NPM_WS=1 ./tests/run-std-socketio-npm-ws-live.sh
SHUX_SOCKETIO_NPM_ROOM=1 ./tests/run-std-socketio-npm-room-live.sh
SHUX_SOCKETIO_NPM_MW=1 ./tests/run-std-socketio-npm-mw-live.sh
SHUX_SOCKETIO_NPM_PLUGIN=1 ./tests/run-std-socketio-npm-plugin-live.sh
SHUX_SOCKETIO_CLUSTER_RING=1 ./tests/run-std-socketio-cluster-ring-live.sh
SHUX_SOCKETIO_ALL_LIVE=1 ./tests/run-std-socketio-all-live.sh
```
