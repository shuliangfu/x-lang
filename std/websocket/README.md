# std.websocket

RFC6455 WebSocket 握手与帧编解码（STD-031）。F-04 v3 纯 `.x`：`std/net/ws_codec.x` + `ws_io.x`。

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




 必须补全的底层缺陷与安全防线1. 致命缺陷：缺少“分片帧（Fragmentation / Continuation Frame）”的组合状态机物理盲区： 在真实的 WebSocket 通信中，当发送巨型数据（如一个 50MB 的大图片或持续的流媒体）时，数据会被拆分成多个帧发送：一个 FIN=0 的起始帧，中间是若干个 Opcode=0 (CONTINUATION) 的中间帧，最后是一个 FIN=1, Opcode=0 的结束帧。现状漏洞： 你的 ws_read_frame 只能呆板地单帧读取，一旦对端（比如 Chrome 浏览器）为了节约内存对大包进行了流式分片投递，你的解析器会因为收到大量 Opcode=0 的未知帧而直接迷失，甚至拼装出残缺的数据。必须补足的 API / 常量：ws_opcode_continuation（值为 0x0）ws_read_message(stream, ...) 或在 ws_read_frame 的入参/出参中传出一个 &is_fin 的布尔指针，让应用层或标准库有能力感知并循环拼接分片。2. 安全防线：缺少“最大帧长/消息长（Max Payload Limit）”的熔断保护物理盲区： RFC 6455 允许的单帧 Payload 长度理論上由 8 个字节的扩展长度字段决定（最大可达 $2^{63}-1$ 字节）。黑客攻击： 如果黑客连入你的 shux 服务器，故意伪造一个恶意帧头，声称“我这个帧有 2GB 大小”。你的 ws_read_frame 如果直接拿着帧头里的长度去分配内存（cap 或堆分配），你的进程会瞬间因为 OOM（内存溢出）被操作系统无情击杀。必须补足的 API / 配置：ws_set_max_payload_size(stream, max_bytes)在 ws_decode_frame 或 ws_read_frame 内部，一旦解析到的 payload_len > max_allowed，必须立刻熔断，抛出错误码并向对方发射 ws_encode_close_frame。3. 控制帧的“物理插队”与强制长度约束（Control Frame Invalidation）物理盲区： RFC 6455 明确规定：PING、PONG、CLOSE 等控制帧的 Payload 不能超过 125 字节，并且它们允许在数据分片帧的中间进行“插队”投递（例如在大数据传输过程中，心跳 PING 帧可以随时插进来）。现状漏洞： 清单里没有强制校验控制帧长度。如果收到超过 125 字节的 PING，不予以拒绝就是违反 RFC 规范。必须在内部逻辑或 API 明确：ws_is_control_frame(opcode)确保解包逻辑里有严格断言：如果 opcode >= 0x8 且 len > 125，直接判定为协议错误。4. 握手期（Server端）的 “Origin 域与 Subprotocol 协议协商”能力缺失物理盲区： WebSocket 服务端安全防线最重要的就是检查 Origin 头部（防止跨站 WebSocket 劫持攻击 CSWSH）。另外，很多高级应用需要协商子协议（如 Sec-WebSocket-Protocol: v1.json）。现状漏洞： 你的 ws_validate_upgrade_request 只是干巴巴地检验了是不是 WebSocket 升级，无法让开发者在握手通过前，对跨域的 Origin 或客户端请求的 Subprotocol 进行策略抉择。建议扩展的 API：ws_extract_header(req, "origin", out, cap)ws_build_handshake_response_ex(..., const char* subprotocol)：允许服务端在回复 101 确认时，带上协商成功的子协议。