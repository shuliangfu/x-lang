# std.websocket

RFC6455 WebSocket 握手与帧编解码（STD-031）。C 实现在 `std/net/ws.inc.c`，链入 `std/net/net.o`。

## 依赖

- **std.net** — `TcpStream` 字节读写
- **std.http** — HTTP Upgrade 辅助（101 / Sec-WebSocket-*）

## API（`import("std.websocket")`）

| 函数 | 说明 |
|------|------|
| `ws_compute_accept(key, key_len, out, cap)` | Sec-WebSocket-Accept |
| `ws_build_handshake_request(host, path, key, out, cap)` | 客户端握手请求 |
| `ws_validate_handshake_response(resp, resp_len, key, key_len)` | 校验 101 响应 |
| `ws_encode_text_frame(payload, len, out, cap)` | 编码 text 帧 |
| `ws_encode_binary_frame(payload, len, out, cap)` | 编码 binary 帧 |
| `ws_encode_ping_frame` / `ws_encode_pong_frame` | PING/PONG 心跳帧 |
| `ws_encode_close_frame(status, reason, len, out, cap)` | CLOSE 帧 |
| `ws_connect(host, port, path, ...)` | ws:// TCP + 握手（port=0 → 80） |
| `ws_connect_tls` / `ws_connect_url` | wss://（TLS + 握手；URL 含 ws/wss） |
| `wss_is_available()` | TLS 后端是否可用 |
| `ws_parse_url` | 解析 ws(s)://host[:port]/path |
| `ws_client_handshake(fd, host, path, key, key_len, timeout_ms)` | 已连接 fd 上完成握手 |
| `ws_generate_key(out, cap)` | 生成 Sec-WebSocket-Key |
| `ws_write_text(stream, payload, len)` | 发送 TEXT 帧 |
| `ws_write_binary(stream, payload, len)` | 发送 BINARY 帧 |
| `ws_read_frame(stream, &opcode, buf, cap, &len, timeout_ms)` | 读取一帧 |
| `ws_timeout_ms_from_ctx` / `ws_ctx_check` | Context → 超时/取消（对齐 std.net） |
| `ws_connect_ctx_fd` / `ws_connect_url_ctx` | 带 Context 的连接 |
| `ws_read_frame_ctx` / `ws_write_text_ctx` / `ws_write_binary_ctx` | 带 Context 读写 |
| `ws_client_handshake_ctx` / `ws_server_accept_ctx` / `ws_server_handshake_ctx` | 带 Context 握手 |
| `ws_close(stream)` | 关闭会话 |
| `ws_extract_key_from_request(req, len, out, cap)` | 从 Upgrade 请求提取 Key |
| `ws_validate_upgrade_request(req, len)` | 校验客户端 Upgrade 请求 |
| `ws_server_accept(fd, tls_ctx, req, len, timeout_ms)` | 服务端回复 101 并交接到帧层 |
| `ws_server_handshake(fd, tls_ctx, timeout_ms)` | 服务端读请求并完成 101 |
| `ws_encode_server_text_frame(payload, len, out, cap)` | 编码服务端 TEXT 帧（无 MASK） |
| `ws_encode_server_binary_frame(payload, len, out, cap)` | 编码服务端 BINARY 帧（无 MASK） |
| `ws_server_write_text(fd, tls_ctx, payload, len)` | 服务端发送 TEXT 帧 |
| `ws_server_write_binary(fd, tls_ctx, payload, len)` | 服务端发送 BINARY 帧 |
| `ws_opcode_text/binary/ping/pong/close` | RFC6455 opcode 常量 |
| `ws_decode_frame(buf, len, &opcode, out, cap, &payload_len)` | 解码一帧 |
| `ws_is_implemented()` | C 已链入时返回 1 |

## 测试

```bash
./tests/run-std-websocket-gate.sh
# 或
./tests/run-std-net-ws-gate.sh
```
