# STD-SOCKETIO-001：std.socketio Engine.IO v0 + polling v1（P3）

> 状态：**v16 P3 收口** · P3 可选模块（非 core 默认 std）· v0–v15 能力冻结  
> 关联：std.http、std.websocket、NEXT.md §3.1 std.socketio

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/std-socketio.tsv` |
| 3 | `./tests/run-std-socketio-gate.sh` |
| 4 | 烟测：`tests/socketio/eio_packet.sx` |

---

## 2. 栈位置

```
HTTP GET/POST (polling) ─┐
                         ├→ Engine.IO 帧（0–6 + payload）→ Socket.IO 包（v0：EVENT type=2）
WebSocket upgrade URL ───┘
```

v1 提供 **polling URL 构建**、**HTTP 握手解析**、**GET/POST 传输**；WebSocket 升级路径由 `build_eio_url(..., transport_websocket())` + **std.websocket** 组合。

---

## 3. API（v0 包层）

| API | 说明 |
|-----|------|
| `eio_type_open/close/ping/pong/message/upgrade/noop` | Engine.IO 类型常量 |
| `eio_encode_packet` / `eio_decode_packet` | EIO 文本帧 |
| `sio_encode_event` / `sio_decode_event` | `2["event","data"]` + EIO message 封装 |
| `eio_extract_sid` | open JSON 内 `sid` |
| `socketio_packet_smoke` | C 金样 |

---

## 4. polling v1

| API | 说明 |
|-----|------|
| `build_eio_url` | `{base}/socket.io/?EIO=4&transport=polling\|websocket[&sid=]` |
| `polling_handshake_parse` | canned HTTP → sid + websocket 探测 |
| `polling_handshake` | HTTP GET live 握手 |
| `polling_post_packet` | HTTP POST EIO 包 |
| `polling_smoke` | 无网络烟测 |

---

## 5. connect v2

| API | 说明 |
|-----|------|
| `http_to_ws_base` / `build_ws_connect_url` | http(s) → ws(s) + EIO websocket URL |
| `encode_connect_packet` | Socket.IO CONNECT `40` |
| `client_init` / `connect_handshake` / `connect_ws` / `connect` | 握手 + WS 升级 + CONNECT |
| `reconnect_delay` / `can_reconnect` / `reconnect_reset` | 线性退避重连骨架 |
| `connect_smoke` | 无网络烟测 |

---

## 6. v3 互操作 / 重连

| API | 说明 |
|-----|------|
| `reconnect_once` | 在 `can_reconnect` 内再次 `connect` |
| `emit_event_ws` | WS 发送 `42["event","data"]` |
| `node_golden_smoke` | Node socket.io-client v4 canned 金样 |

---

## 7. 金样向量

| 场景 | 期望 |
|------|------|
| open `{"sid":"abc",...}` | encode → type=0；sid=`abc` |
| EVENT hello/world | `42["hello","world"]` round-trip |
| polling URL | `http://127.0.0.1:3000/socket.io/?EIO=4&transport=polling` |
| canned HTTP 握手 | sid=`abc123`，has_ws=1 |
| Node open + EVENT | sid=`oXLMyi`；`42["chat message","hello"]` round-trip |
| C smoke | packet + polling + connect + node → 0 |

---

---

## 8. server v2

| API | 说明 |
|-----|------|
| `server_build_open_packet` / `server_build_http_open_response` | 服务端 open |
| `server_is_polling_handshake` / `server_is_connect_packet` | 握手 / CONNECT |
| `server_smoke` | 无网络烟测 |

live mock：`SHUX_SOCKETIO_LIVE=1 ./tests/run-std-socketio-live.sh`

---

## 9. server emit v3

| API | 说明 |
|-----|------|
| `server_emit_event` / `server_build_http_event_response` | 服务端推送 EVENT |
| `server_emit_smoke` | 无网络烟测 |

npm live：`SHUX_SOCKETIO_NPM=1 ./tests/run-std-socketio-npm-live.sh`

---

## 12. namespace / ack v6

| API | 说明 |
|-----|------|
| `encode_connect_ns_packet` / `send_connect_ns_packet` | namespace CONNECT `40/chat,` |
| `encode_event_ack_packet` / `emit_event_ack_ws` | 带 packet id 的 EVENT |
| `encode_ack_packet` / `emit_ack_ws` | ACK `453["ok"]` |
| `parse_sio_packet_head` | SIO type / id / payload 偏移 |
| `server_is_connect_ns_packet` | 服务端 namespace CONNECT 检测 |
| `server_emit_event_ws` | WebSocket 服务端推送 EVENT |
| `ns_ack_smoke` | 无网络烟测 |

烟测：`tests/socketio/ns_ack.sx`

---

## 15. multi-ns router v7

| API | 说明 |
|-----|------|
| `parse_connect_ns` | 从 CONNECT 帧解析 namespace |
| `ns_router_init` / `ns_router_register` | 固定 4 槽路由表 |
| `ns_router_lookup` / `ns_router_route_connect` | namespace → slot_id |
| `ns_router_smoke` | 无网络烟测 |

npm live（含 `/chat` CONNECT POST）：`SHUX_SOCKETIO_NPM=1 ./tests/run-std-socketio-npm-live.sh`

烟测：`tests/socketio/ns_router.sx`

---

## 17. multi-ns sessions v8

| API | 说明 |
|-----|------|
| `ns_sessions_init` / `ns_sessions_sync_router` | 并发会话表（按 slot 计数） |
| `ns_sessions_connect` / `ns_sessions_disconnect` | CONNECT 递增 / 断开递减 |
| `ns_sessions_active` / `ns_sessions_total` | 查询 active |
| `connect_ws_ns` / `connect_ns` | WS 升级 + namespace CONNECT |
| `ws_read_text` / `client_ws_ns_event_roundtrip` | WS 读帧 / emit+read 往返 |
| `ws_finish_eio_upgrade` | polling→WS probe 升级 |
| `ns_sessions_smoke` | 无网络烟测 |

npm WS live：`SHUX_SOCKETIO_NPM_WS=1 ./tests/run-std-socketio-npm-ws-live.sh`

烟测：`tests/socketio/ns_sessions.sx`

---

## 19. WS hub v9

| API | 说明 |
|-----|------|
| `ws_hub_init` / `ws_hub_register` / `ws_hub_unregister` | sid→fd/tls 内存持久映射 |
| `ws_hub_find_by_sid` | 按 sid 查槽位 |
| `ws_hub_handle_connect` | CONNECT → router + sessions + 绑定 slot |
| `ws_hub_emit_to_slot` | 向同 slot 全部 WS 连接推送 ns EVENT |
| `server_build_connect_ns_ack` | `40/chat,{"sid":"..."}` |
| `server_emit_event_ws_ns` | 单连接 namespace EVENT |
| `ws_hub_smoke` | 无网络烟测 |

烟测：`tests/socketio/ws_hub.sx`

---

## 21. room v10

| API | 说明 |
|-----|------|
| `room_registry_init` / `room_register` | room 表 init / 注册名称与 id |
| `room_join` / `room_leave` / `room_leave_all` | hub conn_idx 加入/离开 room |
| `room_member_count` | 查询成员数 |
| `room_broadcast_ns` | 向 room 内全部成员广播 ns EVENT |
| `ws_hub_export` / `ws_hub_import` / `ws_hub_snapshot_bytes` | hub 二进制快照（SIOH magic；不含 fd） |
| `room_smoke` | room + hub 快照无网络烟测 |

烟测：`tests/socketio/room.sx`

---

## 23. hub sync v11

| API | 说明 |
|-----|------|
| `ws_hub_rebind` | import 后重绑 fd/tls（跨进程恢复 WS） |
| `room_registry_export` / `room_registry_import` | room 二进制快照（SIOR magic） |
| `hub_sync_smoke` | hub + room export/import + rebind 烟测 |

npm room live：`SHUX_SOCKETIO_NPM_ROOM=1 ./tests/run-std-socketio-npm-room-live.sh`

烟测：`tests/socketio/hub_sync.sx`

---

## 25. session sync v12

| API | 说明 |
|-----|------|
| `session_bundle_export` / `session_bundle_import` | hub + room 一体快照（SIOS magic） |
| `ws_hub_register_or_rebind` | import 后按 sid 重绑，保持 room 成员 slot |
| `session_sync_smoke` | 一体快照 + register_or_rebind 烟测 |

npm middleware live：`SHUX_SOCKETIO_NPM_MW=1 ./tests/run-std-socketio-npm-mw-live.sh`

烟测：`tests/socketio/session_sync.sx`

---

## 27. cluster sync v13

| API | 说明 |
|-----|------|
| `cluster_sync` | 两节点 SIOS bundle 合并（import A + 追加 B hub/room） |
| `ws_hub_append_from` / `room_registry_merge_offset` | hub 槽追加 / room 成员 offset 合并 |
| `cluster_sync_smoke` | 两节点同 room → coordinator 2 成员烟测 |

npm plugin live：`SHUX_SOCKETIO_NPM_PLUGIN=1 ./tests/run-std-socketio-npm-plugin-live.sh`

烟测：`tests/socketio/cluster_sync.sx`

---

## 29. cluster adapter v14

| API | 说明 |
|-----|------|
| `cluster_adapter_init` / `cluster_adapter_publish_ns` | 内存 adapter init / 跨节点 publish |
| `cluster_adapter_drain_apply` | 消费队列并本地 room 广播 |
| `cluster_adapter_smoke` | node1 publish → node2 drain 烟测 |

> 轻量占位，对标 Redis adapter pub/sub；**不**引入 Redis 依赖。

烟测：`tests/socketio/cluster_adapter.sx`

---

## 31. cluster ring v15

| API | 说明 |
|-----|------|
| `cluster_adapter_export` / `cluster_adapter_import_merge` | SIOA 快照 export/merge（跨节点 ring；可写 std.fs） |
| `cluster_ring_sync_smoke` | publish → export → import_merge → drain 烟测 |

cluster ring live：`SHUX_SOCKETIO_CLUSTER_RING=1 ./tests/run-std-socketio-cluster-ring-live.sh`

烟测：`tests/socketio/cluster_ring.sx`

---

## 33. P3 收口 v16

| API / 脚本 | 说明 |
|------------|------|
| `p3_complete_smoke` | 串联 v9–v15 hub/room/cluster 金样 |
| `run-std-socketio-all-live.sh` | gate + 全部 live 编排 |

all-live：`SHUX_SOCKETIO_ALL_LIVE=1 ./tests/run-std-socketio-all-live.sh`

烟测：`tests/socketio/p3_complete.sx`

---

## 16. Gate

```bash
./tests/run-std-socketio-gate.sh
```

---

## 34. 非目标（P3 收口后）

- HTTP/2（见 std.http 远期）
- 真实 Redis / 分布式 npm cluster
