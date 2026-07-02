# std.http

HTTP/1.x 客户端与服务辅助（对标 Zig `std.http` 最小子集）。

## 客户端

| API | 说明 |
|-----|------|
| `get(url, url_len, out, cap)` | HTTP/HTTPS GET（`https://` 须链入 std.net TLS） |
| `post(url, url_len, body, body_len, out, cap)` | HTTP/HTTPS POST |
| `head(url, url_len, out, cap)` | HTTP/HTTPS HEAD |
| `put(url, url_len, body, body_len, out, cap)` | HTTP/HTTPS PUT |
| `delete(url, url_len, out, cap)` | HTTP/HTTPS DELETE |
| `patch(url, url_len, body, body_len, out, cap)` | HTTP/HTTPS PATCH |
| `options(url, url_len, out, cap)` | HTTP/HTTPS OPTIONS |
| `client_request(method, url, …)` | 统一入口（`Method` 枚举） |
| `Method` / `method(m)` / `method(tag)` | 方法枚举 ↔ u8 判别值重载（GET=0 … OPTIONS=6） |
| `https_is_available()` | TLS 后端是否可用 |
| `err_tls_not_impl()` | 无 TLS 时 https URL 错误码（-1221） |
| `parse_status_line(line, len, &code)` | 解析状态行 |
| `headers_body_offset(buf, len, &off)` | 头结束偏移 |
| `has_chunked_encoding(buf, len)` | 是否 chunked |
| `has_keep_alive(buf, len)` | 是否 keep-alive |
| `decode_chunked_body(...)` | 解码 chunked body |

## 服务端 / 连接池（STD-009/107）

| API | 说明 |
|-----|------|
| `respond_get_ok(fd, body, body_len)` | 200 OK 响应 |
| `listen(addr_u32, port, backlog)` | TCP listen |
| `serve_one(listener, body, body_len, timeout_ms)` | accept + respond |
| `client_pool_create/destroy/get` | keep-alive 连接池 |

## WebSocket 辅助（供 std.websocket）

| API | 说明 |
|-----|------|
| `is_upgrade_websocket(buf, len)` | 检测 Upgrade: websocket |
| `build_ws_upgrade(accept, out, cap)` | 101 响应头 |

## Context 版客户端（STD-094/095）

| API | 说明 |
|-----|------|
| `get_ctx` / `post_ctx` / `head_ctx` | 带 std.context 超时/取消 |
| `put_ctx` / `delete_ctx` / `patch_ctx` / `options_ctx` / `client_request_ctx` | 其余方法与统一入口 + Context |
| `timeout_ms_for_http(ctx)` | 推导超时毫秒 |
| `ctx_check_for_http(ctx)` | 请求前检查取消/过期 |
| `map_http_c_result(c_code)` | C 错误码映射（-1220→http_err_timeout） |
| `listen_on` | `listen` 别名（STD-107 manifest） |

实现：`std/http/http_glue.c`（含 `http_server_pool.inc.c`、`http2*.inc.c`）。

## HTTP/2 v0–v3（STD-HTTP-H2 · TLS ALPN 网络）

| API | 说明 |
|-----|------|
| `is_connection_preface(buf, len)` | RFC 7540 连接 preface 检测 |
| `parse_frame_header(...)` | 9 字节帧头解析 |
| `build_settings_ack(out, cap)` | SETTINGS ACK 帧 |
| `build_settings_one(id, value, out, cap)` | 单条 SETTINGS |
| `wire_is_available()` | 线格式层可用 |
| `client_is_available()` | v1+ 编解码层可用 |
| `hpack_encode_get_request` / `hpack_decode_status` | GET 头块 / :status |
| `hpack_encode_request` / `hpack_dyn_smoke` | v3 多 method + 动态表 |
| `build_headers_frame` / `build_data_frame` | HEADERS/DATA 帧 |
| `build_request_headers_frame` | v3 多 method HEADERS（POST 无 END_STREAM） |
| `client_smoke()` | 多路复用烟测 |
| `err_network_h2()` | TLS ALPN 网络路径（-1231） |
| `h2_get` / `h2_request` / `client_request_h2` | HTTPS+h2 全 method |
| `network_is_available()` | TLS 后端链入时为 true |

## HTTP/2 v5 流控（STD-HTTP-H2-v5）

| API | 说明 |
|-----|------|
| `Http2FlowState` | 连接/流发送窗口 |
| `flow_state_init` / `max_send` / `can_send` / `consume_send` | 背压跟踪 |
| `flow_state_apply_window_update` | WINDOW_UPDATE 应用 |
| `err_flow_blocked()` | 背压错误码（-1232） |
| `flow_state_smoke()` | 离线烟测 |

## HTTP/2 v7 h2c / push 资源（STD-HTTP-H2-v7）

| API | 说明 |
|-----|------|
| `h2c_wire_is_available()` | cleartext preface 构建可用 |
| `h2c_session_begin` | 写连接 preface（24B） |
| `push_fetch_smoke` | promised stream DATA 离线收集 |
| `Http2PushResource` | push 资源视图 struct |

## HTTP/2 v6 接收侧 / push / h2c（STD-HTTP-H2-v6）

| API | 说明 |
|-----|------|
| `Http2FlowRecvState` | 接收侧剩余窗口 |
| `flow_recv_on_data` / `flow_recv_release` | 收 DATA + WINDOW_UPDATE |
| `is_push_promise_frame` / `parse_push_promise_stream` | server push 帧 |
| `is_h2c_upgrade_response` | h2c 101 升级识别 |
| `err_push_not_impl()` / `err_h2c_not_impl()` | -1233 / -1234 |

## HTTP/2 v8 h2c TCP / push 网络（STD-HTTP-H2-v8）

| API | 说明 |
|-----|------|
| `h2c_is_available()` | cleartext TCP 会话 API |
| `push_last_copy` / `push_last_reset` | 读路径 push 资源 |
| `push_network_smoke` / `h2c_network_smoke` | 烟测 |

## HTTP/2 v9 h2c URL 客户端 / 多 stream（STD-HTTP-H2-v9）

| API | 说明 |
|-----|------|
| `h2c_get` / `h2c_request` / `client_request_h2c` | `http://` 明文 h2c；`https://` → `err_h2c_scheme()` |
| `Http2StreamRegistry` / `stream_registry_*` | 多 stream 注册表 v0 |
| `h2c_client_smoke` / `registry_smoke` | 烟测 |

## HTTP/2 v10 SETTINGS 协商 / 并发客户端（STD-HTTP-H2-v10）

| API | 说明 |
|-----|------|
| `Http2PeerSettings` / `build_client_settings` | SETTINGS 解析与客户端协商帧 |
| `Http2MultistreamClient` / `multistream_client_*` | 多 stream 并发 open + 并行 GET 帧 |
| `err_max_streams()` | 超 SETTINGS 并发上限 -1236 |

## HTTP/2 v11 单连接复用（STD-HTTP-H2-v11）

| API | 说明 |
|-----|------|
| `Http2Conn` / `conn_handshake` / `conn_request` | 单 TCP/TLS 多 stream 往返 |
| `err_conn_not_ready()` | 未 handshake -1237 |

## HTTP/2 v12 连接池 / 长连接 URL（STD-HTTP-H2-v12）

| API | 说明 |
|-----|------|
| `conn_pool_create_h2c` / `conn_pool_create_h2` | h2c / h2 长连接池 |
| `h2c_pool_get` / `h2_pool_get` | 池化 GET URL 请求 |
| `err_pool_scheme()` | scheme 不匹配 -1238 |

## HTTP/2 v13 全局连接池 / URL 路由（STD-HTTP-H2-v13）

| API | 说明 |
|-----|------|
| `global_pool_create` / `global_pool_destroy` | 多 host:port 全局池 |
| `global_pool_get` | URL 自动路由 GET |
| `err_global_pool_full()` | 子池条目已满 -1239 |

## HTTP/2 v14 h2c server（STD-HTTP-H2-v14）

| API | 说明 |
|-----|------|
| `serve_h2c_one` / `server_serve_h2c` | listen+accept 或已连接 fd 上 h2c GET serve |
| `err_server()` | server 协议错误 -1240 |

## HTTP/2 v15 h2 over TLS server（STD-HTTP-H2-v15）

| API | 说明 |
|-----|------|
| `serve_h2_one` / `tls_server_ctx_create` | ALPN h2 TLS listen+serve |
| `err_server_tls()` | TLS/ALPN 不可用 -1241 |

## HTTP/2 v16 server 多 stream（STD-HTTP-H2-v16）

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one` / `serve_h2_multi_one` | 单连接顺序 serve N 个 GET |
| `server_multistream_smoke` | 双 stream 集成烟测 |

## HTTP/2 v17 server push 响应（STD-HTTP-H2-v17）

| API | 说明 |
|-----|------|
| `serve_h2c_one_with_push` / `server_serve_h2c_with_push` | PUSH_PROMISE + promised stream 200+body |
| `err_server_push()` | push 发送侧参数错误 -1242 |
| `server_push_smoke` | 线格式 + fork h2c 集成烟测 |

## HTTP/2 v18 TLS server push 响应（STD-HTTP-H2-v18）

| API | 说明 |
|-----|------|
| `serve_h2_one_with_push` / `server_serve_h2_with_push` | ALPN h2 + PUSH_PROMISE + promised stream 200+body |
| `server_push_tls_smoke` | TLS fork 集成烟测（TLS 不可用时跳过） |

## HTTP/2 v19 server 多 stream + push（STD-HTTP-H2-v19）

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one_with_push` / `serve_h2_multi_one_with_push` | 长连接顺序 N 个 GET，各带 PUSH_PROMISE |
| `server_multistream_push_smoke` | h2c + TLS 双 stream push 烟测 |

## HTTP/2 v20 push ENABLE_PUSH 协商（STD-HTTP-H2-v20）

| API | 说明 |
|-----|------|
| `peer_settings_enable_push` / `build_client_settings_ex` | 解析/发送 ENABLE_PUSH |
| `conn_handshake_with_enable_push` | client 显式拒绝 push |
| `err_server_push_disabled()` | client ENABLE_PUSH=0 时 server 跳过 push（-1243） |
| `server_push_settings_smoke` | fork 软拒绝烟测 |

## HTTP/2 v21 server SETTINGS 全量协商（STD-HTTP-H2-v21）

| API | 说明 |
|-----|------|
| `build_server_settings` | server 发 HEADER_TABLE_SIZE/ENABLE_PUSH/MAX_CONCURRENT/INITIAL_WINDOW/MAX_FRAME_SIZE |
| `peer_settings_header_table_size` / `peer_settings_max_frame_size` | 对端协商读回 |
| `server_settings_full_smoke` | fork 集成烟测 |

## HTTP/2 v22 server HPACK 动态表 / HEADER_TABLE_SIZE（STD-HTTP-H2-v22）

| API | 说明 |
|-----|------|
| `hpack_server_dyn_create` / `hpack_server_dyn_set_table_size` | 对端 SETTINGS 联动动态表上限 |
| `hpack_server_encode_status` | server 响应 :status（动态表复用） |
| `hpack_server_dyn_smoke` / `server_hpack_dyn_smoke` | 离线 + h2c 多 stream 烟测 |

## HTTP/2 v23 server MAX_FRAME_SIZE 分片 DATA（STD-HTTP-H2-v23）

| API | 说明 |
|-----|------|
| `frame_payload_limit` / `frame_count_data_chunks` | 分片上限与帧数 |
| `build_client_settings_with_max_frame` | client SETTINGS 含 MAX_FRAME_SIZE |
| `server_max_frame_smoke` | 16385B body 双 DATA 帧 fork 烟测 |

## HTTP/2 v24 GOAWAY / 连接优雅关闭（STD-HTTP-H2-v24）

| API | 说明 |
|-----|------|
| `build_goaway` / `parse_goaway` | GOAWAY 帧编解码 |
| `conn_shutdown_graceful` / `conn_read_goaway` | client 优雅关闭与读 GOAWAY |
| `serve_h2c_one_with_goaway` | accept + GET + GOAWAY fork 烟测 |
| `conn_goaway_smoke` | 离线 + h2c 集成烟测 |

## HTTP/2 v25 PING/PONG 连接保活（STD-HTTP-H2-v25）

| API | 说明 |
|-----|------|
| `build_ping` / `build_ping_ack` | PING/PONG 帧编解码 |
| `conn_ping` | client 发 PING 等匹配 PONG |
| `serve_h2c_one_ping_echo` | accept + PONG fork 烟测 |
| `conn_ping_smoke` | 离线 + h2c 集成烟测 |

## HTTP/2 v26 连接池 GOAWAY 感知（STD-HTTP-H2-v26）

| API | 说明 |
|-----|------|
| `conn_goaway_seen` / `conn_is_pool_reusable` | GOAWAY 后不可复用判定 |
| `conn_pool_connect_count` | 池新建连计数 |
| `conn_pool_goaway_smoke` | GOAWAY 后自动重连 fork 烟测 |

## HTTP/2 v27 v1 收口（STD-HTTP-H2-v27 · **最终步**）

| API | 说明 |
|-----|------|
| `build_rst_stream` / `conn_reset_stream` | RST_STREAM 取消 stream |
| `global_pool_connect_count` | 全局池子池累计新建连 |
| `complete_smoke` | v1 收口烟测（RST + 全局池 GOAWAY） |

> **HTTP/2 v1 已收口**：client/server/h2c/h2/push/SETTINGS/流控/GOAWAY/PING/RST/连接池/全局池均已 gate。远期 HTTP/3 等**不在** std.http v1 范围。

## Request/Response v0（STD-HTTP-REQRESP）

| API | 说明 |
|-----|------|
| `HttpRequest` / `HttpResponse` | 请求/响应视图 struct |
| `HttpBodyView` / `HttpBodyOwned` | body 零拷贝视图 / 堆分配 |
| `request_init` / `execute` / `execute_ctx` | 构造、执行、Context 版 |
| `response_body_view` / `response_body_owned` / `body_owned_free` | body 访问与堆释放 |
| `HttpUrlOwned` / `url_owned_from_slice` / `request_bind_url_owned` | >256B 堆 URL |
| `HttpRequestOwned` / `request_owned_init` / `execute_owned` | 一体堆 URL+body |
| `HttpResponseOwned` / `response_owned_from_parse` / `push_last_body_owned` | 一体堆响应 + push body |
| `hpack_huffman_decode` / `build_window_update` | H2 Huffman + 流控 v4 |





缺少的核心底层功能与隐漏排查
1. HTTP/1.x 巨型响应的“背压流控”断层（Streaming Body）
现状漏洞： 你的 HTTP/1.x 客户端 API 诸如 get(url, ..., out, cap)，要求用户传入一个固定的 out 缓冲区。

物理隐患： 如果对方服务器疯狂喷射一个 4GB 的超大文件，或者是一个永不结束的流数据（如 SSE 实时推送），你的 out 缓冲区会直接被打爆（溢出），或者因为内存不足被操作系统强行杀掉。

必须补全的 API：

Http1Reader 结构体，以及 http1_read_chunk(fd, buf, size) 的迭代器/流式读取机制。允许开发者每次只读几 KB，消费完再读下一步。

2. HTTP/2 真正要命的并发红利：WINDOW_UPDATE 的“主动发射”
现状漏洞： 方案里写了 flow_state_apply_window_update（解析对端发来的窗口更新以便自己发送数据），也写了 flow_recv_on_data（接收侧收数据计数）。

物理隐患： 当你的 shux 服务器作为接收端，高频收到了用户的巨型 POST 上传时，你的本地接收缓冲区（Http2FlowRecvState）在不断减少。如果你不主动调用底层的 write() 向对端发送一个 WINDOW_UPDATE 帧，对端的发送客户端就会因为流控死锁永远挂起。

必须补足的 API：

build_window_update_frame(stream_id, increment, out, cap)：接收数据消费后，必须能够主动合成并吐出 WINDOW_UPDATE 帧来疏通管道。

3. 连接池（v12/v13）的“死连接清理与惊群防御”（Keep-Alive Reaper）
现状漏洞： 方案里包含了长连接池和全局路由池。

物理隐患： 互联网上的长连接是极不可靠的。如果一个 TCP 连接在你的池子里躺了 5 分钟，对方服务器可能早就悄悄断开了（半关闭状态 FIN）。如果没有检测，当 shux 的 global_pool_get 捞出这个死连接直接发起 GET 请求时，会瞬间触发 EPIPE / ECONNRESET 崩溃。

必须补足的 API：

conn_pool_reap_dead_connections(pool)：基于时间戳或非阻塞 recv(..., MSG_PEEK) 剔除死连接的保活清理器。

4. 恶意的“慢速攻击防范”（Slowloris Header Timeout）
现状漏洞： 服务端包含 serve_one(listener, ..., timeout_ms)。

物理隐患： 传统的 timeout_ms 通常只卡在 accept 那一下。如果黑客连进来之后，每隔 10 秒钟只发 1 个字节的 HTTP Header（慢速攻击），你的 headers_body_offset 就永远等不到结束符，这个线程/协程就会被永远拖死。

必须补足的 API：

server_set_header_read_timeout(...)：限定必须在 X 毫秒内完整收完 HTTP 请求头的安全防线。

5. 自举后的“类型大对齐”：零拷贝切片视图（String Slice Binding）
自举隐患： 方案里提到了 HttpBodyView 零拷贝视图。因为当前阶段你用 C 写胶水，C 语言是用 char* + len 表达的。当大后期 shux 自举后，自举前端的字符串结构（比如 []u8 切片）必须能和 C 端的 HttpBodyView 实现指针级无损对接。

必须在方案中写明： HttpBodyView 的内存对齐结构必须是：

C
struct HttpBodyView { const uint8_t *ptr; size_t len; };
这样未来用 .sx 重写自举时，这个结构体在内存里可以直接强转成 shux 的原生数组切片，不需要发生任何数据复制，守住性能大关。

🏁 终极裁决：全了吗？可以开工了吗？
答案是：作为 v1 版本的标准库规范，它不仅写全了，甚至全得有些过分（超额完成了大后期的工程量）。

你把 HTTP/2 里面最硬核的 HPACK 动态表（v22）和数据分片（v23）都列进去了，这说明你对整个网络协议栈的物理细节有着绝对的掌控力。上面的 5 点缺失，属于工业级高并发调优和防御性编程的安全补丁，完全可以在具体写 C 胶水代码（http_glue.c）时顺手补上，不需要推翻你的表格框架。