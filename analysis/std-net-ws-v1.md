# STD-031：std.net WebSocket 客户端草案 v1

> 更新时间：2026-06-18  
> 状态：**草案定版（v1）**  
> 关联：STD-002（std.net）、STD-030（TLS）、`std/http` Upgrade

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/std-net-ws.tsv` |
| 3 | `./tests/run-std-net-ws-gate.sh` |
| 4 | 烟测：`tests/net/ws_frame.x` |

---

## 2. 栈位置

```
std.net TcpStream → HTTP Upgrade 握手 → WebSocket 帧读写
```

v1 **无独立 `std.ws` 模块**；API 挂在 `import("std.net")`（`ws_*` 前缀），C 实现在 `std/net/ws.inc.c`。

---

## 3. API（v1）

| API | 说明 |
|-----|------|
| `WS_OPCODE_TEXT` / `WS_OPCODE_CLOSE` / `WS_OPCODE_PING` / `WS_OPCODE_PONG` | 帧 opcode 常量 |
| `ws_compute_accept` | Sec-WebSocket-Accept（SHA-1 + Base64） |
| `ws_build_handshake_request` | 客户端 Upgrade HTTP 请求 |
| `ws_validate_handshake_response` | 校验 `101` + Accept |
| `ws_encode_text_frame` | 客户端 MASKED TEXT 帧 |
| `ws_encode_ping_frame` / `ws_encode_pong_frame` | 心跳 PING/PONG |
| `ws_encode_close_frame` | CLOSE（2 字节 status + 可选 reason） |
| `ws_connect` / `ws_connect_tls` / `ws_connect_url` | ws:// 与 wss:// 一站式 |
| `wss_is_available` | TLS 后端探测 |
| `ws_parse_url` | ws(s):// URL 解析 |
| `ws_write_text` / `ws_read_frame` | 帧读写 |
| `ws_generate_key` | Sec-WebSocket-Key |
| `ws_extract_key_from_request` | 从 Upgrade 请求提取 Key |
| `ws_validate_upgrade_request` | 校验 GET + Upgrade + Version 13 |
| `ws_server_accept` / `ws_server_handshake` | 服务端 101 握手 |
| `ws_encode_server_text_frame` / `ws_server_write_text` | 服务端 TEXT 帧（无 MASK） |
| `ws_timeout_ms_from_ctx` / `ws_ctx_check` | Context 取消/超时推导 |
| `ws_connect_ctx_fd` / `ws_connect_url_ctx` | 带 Context 连接 |
| `ws_read_frame_ctx` / `ws_write_text_ctx` | 带 Context 读写 |

数据面：`ws_write_text` / `ws_read_frame` 封装帧层；带 deadline 时用 `ws_*_ctx` 变体。`ws://` / `wss://` 用 `ws_connect_url` 或 `ws_connect` / `ws_connect_tls`。

---

## 4. 金样向量

| 场景 | 期望 |
|------|------|
| Key `dGhlIHNhbXBsZSBub25jZQ==` | Accept `s3pPLMBiTxlZ9bKI4hkFqO5zfXM=` |
| TEXT `"hello"` round-trip | encode → decode → 相同 5 字节 |
| PING 空负载 | opcode=9，payload_len=0 |
| PING→PONG echo | ping `"hi"` → pong 相同 2 字节 |
| CLOSE 1000 | opcode=8，payload `[3,232]` |
| 握手 socketpair 烟测 | `ws_client_handshake_smoke` → 0 |
| URL 解析 | `ws://localhost/chat`、`wss://example.com:8443/ws` |
| 握手请求 | 含 `Upgrade: websocket` 与 Key |
| 服务端 Upgrade 校验 | `ws_validate_upgrade_request` + Key 提取 |
| 服务端 TEXT 帧 | 无 MASK encode → decode round-trip |
| 服务端 accept 烟测 | `ws_server_accept_smoke` → 0 |

---

## 5. Gate

```bash
./tests/run-std-net-ws-gate.sh
```

```
shux: [SHUX_STD_NET_WS] status=ok accept=1 frame=1 typeck=1 skip=0
```

---

## 6. 非目标（v1）

- WSS 一站式 connect（v2 已 ✅）；分片帧 / 扩展协商
- 服务端 WebSocket
- 二进制帧与消息 > 125 字节（扩展长度留 v2）

---

## 7. 演进

1. `ws_connect(host, path)`：TCP + 握手
2. STD-030 TLS 封装后 `wss://`
3. 与 STD-033 Keep-Alive HTTP 共用读循环
