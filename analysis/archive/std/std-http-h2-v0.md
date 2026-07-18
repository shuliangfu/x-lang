# STD-HTTP-H2：std.http HTTP/2 v0 线格式文档

> 更新时间：2026-06-19  
> 状态：**v8（h2c TCP 会话 + push 读路径 + HttpRequestOwned）**  
> 关联：RFC 7540、`std/http/http2.inc.c`、`std.http` HTTPS/ALPN

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-http-h2.tsv` |
| 3 | `./tests/run-std-http-h2-gate.sh` |
| 4 | 烟测：`tests/http/wire.x` |

---

## 2. v0 范围

**已实现（线格式层）**：

- 连接 preface 检测（`PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n`）
- 9 字节帧头解析/SETTINGS ACK 构建
- 单条 SETTINGS 帧构建（如 MAX_CONCURRENT_STREAMS）
- ALPN 协议名 `h2` 写入（供后续 TLS 升级）

**未实现（远期）**：

- HPACK Huffman 编码、server push 资源拉取、cleartext h2c 会话
- push 缓存/拒绝策略

**v6 已实现**：

- 接收侧流控：`Http2FlowRecvState` + 收 DATA 后自动 WINDOW_UPDATE
- server push：PUSH_PROMISE 帧检测 + promised stream 解析（读路径忽略）
- h2c：HTTP/1.1 101 + `Upgrade: h2c` 响应识别

**v5 已实现（发送侧流控）**：

- `Http2FlowState` 连接/流窗口跟踪
- WINDOW_UPDATE 应用与 payload 解析
- DATA 发送前背压检查（`http2_session_request_tls_c`）

---

## 3. 线格式 API

| API | 说明 |
|-----|------|
| `preface_len()` | preface 长度（24） |
| `is_connection_preface(buf, len)` | preface 检测 |
| `parse_frame_header(...)` | 帧头解析 |
| `build_settings_ack(out, cap)` | SETTINGS ACK（9 字节） |
| `build_settings_one(id, value, out, cap)` | 单条 SETTINGS |
| `wire_is_available()` | 线格式层可用（v0=true） |
| `client_is_available()` | 完整客户端（v0=false） |
| `write_alpn_h2(out, cap)` | ALPN "h2" |
| `err_not_impl()` | 完整客户端错误码（-1230） |
| `smoke()` | C 烟测 |

常量：`frame_settings()`、`flag_ack()`、`setting_max_concurrent_streams()`。

---

## 6. v1 客户端 API（HPACK + HEADERS/DATA）

| API | 说明 |
|-----|------|
| `hpack_encode_indexed` / `hpack_encode_literal` | HPACK 静态表编码 |
| `hpack_encode_get_request` | GET 四元组头块 |
| `hpack_decode_status` | 响应 `:status` 解析 |
| `build_headers_frame` / `build_data_frame` | 帧构建 |
| `build_get_headers_frame` | stream 1 GET HEADERS |
| `client_smoke` / `hpack_smoke` | 离线烟测 |
| `client_is_available()` | v1=true（编解码层） |
| `err_network_h2()` | TLS ALPN 网络路径未就绪（-1231） |

v1 支持多 stream HEADERS 帧组装（烟测 stream 1/3）；不含 Huffman。

---

## 9. v3 动态 HPACK/多方法

| API | 说明 |
|-----|------|
| `hpack_dyn_reset` / `hpack_dyn_count` | FIFO 动态表（16 条目） |
| `hpack_encode_literal_incremental` | incremental indexing |
| `hpack_encode_indexed_any` | 静态或动态 index≥62 |
| `hpack_encode_request` | 多 method 请求头块 |
| `build_request_headers_frame` | POST 等带 body 时不设 END_STREAM |
| `hpack_dyn_smoke` | 动态表复用烟测 |
| `h2_request` / `client_request_h2` | HTTPS+h2 全 method（POST/PUT/PATCH 须 body） |

烟测：`tests/http/hpack_dyn.x`；网络层 `http2_session_request_tls_c` 发 HEADERS+DATA。

---

## 7. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v7 | 2026-06-19 | h2c preface + push 离线收集 + HttpUrlOwned（reqresp v2） |
| v6 | 2026-06-19 | 接收侧流控 + PUSH_PROMISE/h2c wire + 读路径 WU |
| v5 | 2026-06-19 | 流控状态机 + DATA 背压 + `err_flow_blocked` |
| v3 | 2026-06-19 | 动态 HPACK + POST/多 method + `h2_request` |
| v1 | 2026-06-19 | HPACK 静态表 + HEADERS/DATA + 多路复用烟测 |
| v0 | 2026-06-19 | preface/帧头/SETTINGS ACK + gate |

---

## 4. 远期（HTTP/3 等，非 std.http v1 目标）

HTTP/2 v1 生产子集已于 v27 收口（见 §32–33）。以下为**非** std.http v1 范围：

1. HTTP/3 / QUIC
2. PRIORITY 树 / CONTINUATION 完整实现
3. HPACK Huffman **编码**（解码已实现）

当前 `client_is_available()` 为 true；HTTP/1.1 + HTTP/2 v1 gate 全绿。

```bash
./tests/run-std-http-h2-gate.sh
```

## 8. v2 TLS/ALPN 网络

| 层 | API |
|----|-----|
| std.net | `tls_alpn_h2_http1_wire` / `tls_connect_client_alpn` / `tls_alpn_is_h2` |
| std.http | `h2_get` / `h2_request` / `client_request_h2` / `network_smoke` |

`h2_get` / `h2_request` 流程：TCP → TLS+ALPN(h2) → preface → HEADERS(+DATA) → 读 DATA → 格式化为 HTTP/1 风格响应。

烟测：`tests/http/network.x`（离线）。

---

## 10. v5 流控状态机

| API | 说明 |
|-----|------|
| `Http2FlowState` | 连接/流发送窗口（conn_window + stream_window） |
| `flow_state_init` / `flow_state_reset_stream` | 初始化 / 新 stream |
| `flow_state_apply_initial_window` | SETTINGS INITIAL_WINDOW_SIZE |
| `flow_state_apply_window_update` | 应用 WINDOW_UPDATE（sid=0 为连接级） |
| `flow_state_max_send` / `flow_state_can_send` | 背压查询 |
| `flow_state_consume_send` | 发 DATA 后扣减窗口 |
| `parse_window_update_payload` | 解析 4 字节 increment |
| `err_flow_blocked()` | 背压错误码（-1232） |
| `flow_state_smoke` | 离线烟测 |

烟测：`tests/http/flow_state.x`。网络层发 DATA 前检查窗口（`http2_session_request_tls_c`）。

---

## 11. v6 接收侧流控 / push / h2c

| API | 说明 |
|-----|------|
| `Http2FlowRecvState` | 接收侧剩余窗口（conn_left + stream_left） |
| `flow_recv_init` / `flow_recv_on_data` | 收 DATA 扣减 |
| `flow_recv_release` | 释放已消费字节并构建 WINDOW_UPDATE |
| `flow_recv_smoke` | 接收侧流控烟测 |
| `frame_push_promise` / `is_push_promise_frame` | PUSH_PROMISE 检测 |
| `parse_push_promise_stream` | promised stream id 解析 |
| `is_h2c_upgrade_response` | 101 + Upgrade: h2c 识别 |
| `h2c_is_available()` | cleartext 会话（v6 恒 false） |
| `err_push_not_impl()` / `err_h2c_not_impl()` | -1233 / -1234 |
| `push_h2c_smoke` | push/h2c wire 烟测 |

烟测：`tests/http/flow_recv_push_h2c.x`。`read_response_stream1` 收 DATA 后自动发 WINDOW_UPDATE。

---

## 12. v7 h2c/push 资源

| API | 说明 |
|-----|------|
| `h2c_wire_is_available()` | cleartext preface 构建可用 |
| `h2c_session_begin` | TCP 直连后写连接 preface（24B） |
| `push_fetch_smoke` | promised stream DATA 离线累积 |
| `Http2PushResource` | push 资源视图 struct |

---

## 13. v8 h2c TCP/push 网络

| API | 说明 |
|-----|------|
| `h2c_is_available()` | cleartext TCP 会话 API（v8 true） |
| `session_request_h2c` | 已 connect fd 上 preface+请求（C） |
| `push_last_reset` / `push_last_copy` | 读路径 push 资源 |
| `push_network_smoke` / `h2c_network_smoke` | 烟测 |

读路径：收到 PUSH_PROMISE 后收集 promised stream DATA；主响应仍为 stream 1。

---

## 14. v9 h2c URL 客户端 / 多 stream

| API | 说明 |
|-----|------|
| `h2c_get` / `h2c_request` / `client_request_h2c` | `http://` 明文 TCP + preface；`https://` 返回 `err_h2c_scheme()` (-1235) |
| `h2c_client_smoke` | https URL 须 SCHEME 错误；0 通过 |
| `Http2StreamRegistry` / `init` / `open` | 连接级 stream id 分配/跟踪（8 槽，奇数 client-initiated） |
| `registry_smoke` | 多 stream 注册表烟测 |

烟测：`tests/http/h2c_client.x`、`tests/http/stream_registry.x`。

---

## 15. v10 SETTINGS 协商 / 并发客户端

| API | 说明 |
|-----|------|
| `Http2PeerSettings` / `peer_settings_*` | 解析/应用 MAX_CONCURRENT_STREAMS、INITIAL_WINDOW_SIZE |
| `build_client_settings` | 客户端 SETTINGS 帧（双参数，21 字节） |
| `Http2MultistreamClient` / `client_init` / `client_open` | registry + 对端 SETTINGS + 流控；并发 open/build |
| `client_parallel_get` | 离线并行 GET HEADERS 帧 |
| `err_max_streams()` | 超并发上限 -1236 |
| `settings_smoke` / `multistream_client_smoke` | 烟测 |

网络：`session_request_*` 发 client SETTINGS；读路径解析 server SETTINGS 并 ACK。

烟测：`tests/http/multistream_client.x`。

---

## 16. v11 单连接复用

| API | 说明 |
|-----|------|
| `Http2Conn` / `conn_init` / `conn_attach_h2c` / `conn_attach_tls` | 可复用连接对象 |
| `conn_handshake` | preface + client SETTINGS + 读 server SETTINGS ACK |
| `conn_request` | 同一连接上新 stream 请求 + 读该 stream 响应 |
| `conn_close` | 标记连接关闭 |
| `err_conn_not_ready()` | 未 handshake -1237 |
| `conn_reuse_smoke` | 无效 fd 烟测 |

`http_h2_request_c` / `session_request_*` 内部复用 conn 路径（单次请求仍一次 handshake）。

烟测：`tests/http/conn_reuse.x`。

---

## 17. v12 连接池 / 长连接 URL

| API | 说明 |
|-----|------|
| `conn_pool_create_h2c` / `conn_pool_create_h2` | 绑定 host:port 的 h2c / h2 池 |
| `conn_pool_destroy` | 关闭 idle 并释放池 |
| `h2c_pool_get` / `h2_pool_get` | 长连接池 GET（复用 handshake 连接） |
| `conn_pool_request` | 池上多 method 请求 |
| `err_pool_scheme()` | URL scheme 与池不匹配 -1238 |
| `conn_pool_smoke` | 烟测 |

烟测：`tests/http/conn_pool.x`。

---

## 18. v13 全局连接池 / URL 路由

| API | 说明 |
|-----|------|
| `global_pool_create` / `global_pool_destroy` | 多 host:port 全局池 |
| `global_pool_get` / `global_pool_request` | URL 自动选 h2c/h2 子池并发请求 |
| `global_pool_entry_count` | 已登记子池数量 |
| `err_global_pool_full()` | host:port 条目已满 -1239 |
| `global_pool_smoke` | 烟测 |

烟测：`tests/http/global_pool.x`。

---

## 19. v14 h2c server / listen+serve

| API | 说明 |
|-----|------|
| `serve_h2c_one` | accept 一个 h2c 连接并回 200 GET 响应 |
| `server_serve_h2c` | 对已 accept fd 处理单次 GET |
| `hpack_decode_get_request` / `hpack_encode_status` | 请求头解析 / 响应 :status 编码 |
| `err_server()` | server 协议错误 -1240 |
| `server_smoke` | 烟测（含 fork 集成） |

烟测：`tests/http/server.x`。

---

## 20. v15 h2 over TLS server / ALPN

| API | 说明 |
|-----|------|
| `tls_server_ctx_create` / `tls_server_ctx_destroy` | PEM 内存加载 TLS 服务端上下文 |
| `serve_h2_one` | accept + TLS + ALPN h2 + GET serve |
| `server_serve_h2` | 已 TLS 握手会话上单次 GET serve |
| `err_server_tls()` | TLS/ALPN 不可用 -1241 |

烟测：含于 `server_smoke`（TLS 不可用时跳过集成段）。

---

## 21. v16 server 多 stream 并发 serve

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one` / `server_serve_h2c_multi` | h2c 单连接顺序 serve N 个 GET |
| `serve_h2_multi_one` / `server_serve_h2_multi` | TLS h2 同上 |
| `server_multistream_smoke` | 双 stream 集成烟测 |

烟测：`tests/http/server_multistream.x`。

---

## 22. v17 server push 响应

| API | 说明 |
|-----|------|
| `serve_h2c_one_with_push` / `server_serve_h2c_with_push` | h2c GET 响应前发 PUSH_PROMISE + push 资源 |
| `err_server_push()` | push 参数非法 -1242 |
| `server_push_smoke` | 离线 PUSH_PROMISE 线格式 + fork 集成烟测 |

烟测：`tests/http/server_push.x`。

---

## 23. v18 TLS server push 响应

| API | 说明 |
|-----|------|
| `serve_h2_one_with_push` / `server_serve_h2_with_push` | ALPN h2 TLS GET 响应前发 PUSH_PROMISE + push 资源 |
| `server_push_tls_smoke` | fork + 自签 PEM TLS push 集成烟测 |

烟测：`tests/http/server_push_tls.x`。

---

## 24. v19 server 多 stream + push 组合 serve

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one_with_push` / `server_serve_h2c_multi_with_push` | h2c 长连接顺序 N 个 GET，每个带 PUSH_PROMISE |
| `serve_h2_multi_one_with_push` / `server_serve_h2_multi_with_push` | TLS h2 同上 |
| `server_multistream_push_smoke` | fork 双 GET + 双 push 烟测 |

烟测：`tests/http/server_multistream_push.x`。

---

## 25. v20 push ENABLE_PUSH 协商 / 软拒绝

| API | 说明 |
|-----|------|
| `setting_enable_push()` | SETTINGS id 0x0002 |
| `peer_settings_enable_push` | 对端是否允许 server push |
| `build_client_settings_ex` | 客户端 SETTINGS 含 ENABLE_PUSH |
| `conn_handshake_with_enable_push` | client ENABLE_PUSH=0 拒绝 push |
| `err_server_push_disabled()` | 软拒绝语义码 -1243 |
| `server_push_settings_smoke` | fork 烟测（无 PUSH_PROMISE + 主 200） |

烟测：`tests/http/server_push_settings.x`。

---

## 26. v21 server SETTINGS 全量协商

| API | 说明 |
|-----|------|
| `setting_header_table_size` / `setting_max_frame_size` | SETTINGS id 常量 |
| `peer_settings_header_table_size` / `peer_settings_max_frame_size` | 对端协商值（含 RFC 默认） |
| `build_server_settings` | server 5 项 SETTINGS 帧（39 字节） |
| `server_settings_full_smoke` | fork 读 server SETTINGS 烟测 |

烟测：`tests/http/server_settings_full.x`。

---

## 27. v22 server HPACK 动态表 / HEADER_TABLE_SIZE

| API | 说明 |
|-----|------|
| `hpack_server_dyn_create` / `hpack_server_dyn_set_table_size` | 对端 SETTINGS 联动动态表上限 |
| `hpack_server_dyn_max_size` | 读回 HEADER_TABLE_SIZE 上限 |
| `hpack_server_encode_status` | server 响应 :status（200 静态 indexed；其它码写入动态表并复用） |
| `hpack_server_dyn_smoke` / `server_hpack_dyn_smoke` | 离线 + h2c 多 stream 集成烟测 |

烟测：`tests/http/server_hpack_dyn.x`。

---

## 28. v23 server MAX_FRAME_SIZE 分片 DATA

| API | 说明 |
|-----|------|
| `frame_payload_limit` / `frame_check_payload` | 单帧 payload 上限与校验 |
| `frame_count_data_chunks` | DATA 按 MAX_FRAME_SIZE 分片帧数 |
| `build_client_settings_with_max_frame` / `conn_handshake_with_max_frame` | client 声明 MAX_FRAME_SIZE |
| `frame_capped_smoke` / `server_max_frame_smoke` | 离线 + h2c 16385B/16384 分片集成烟测 |

烟测：`tests/http/server_max_frame.x`。

---

## 29. v24 GOAWAY / 连接优雅关闭

| API | 说明 |
|-----|------|
| `frame_goaway` / `goaway_error_no_error` / `err_goaway` | GOAWAY 帧类型与错误码 |
| `build_goaway` / `parse_goaway` | GOAWAY 帧构建/解析 |
| `conn_shutdown_graceful` | client 发 GOAWAY 后 shutdown |
| `conn_read_goaway` | 读对端 GOAWAY 帧 |
| `serve_h2c_one_with_goaway` / `server_serve_h2c_with_goaway` | server 响应后发 GOAWAY |
| `goaway_smoke` / `conn_goaway_smoke` | 离线 + h2c fork 集成烟测 |

烟测：`tests/http/conn_goaway.x`。

---

## 30. v25 PING/PONG 连接保活

| API | 说明 |
|-----|------|
| `frame_ping` / `err_ping` | PING 帧类型与往返失败码 |
| `build_ping` / `build_ping_ack` / `parse_ping` | PING/PONG 编解码 |
| `conn_ping` | client 发 PING 等 PONG |
| `serve_h2c_one_ping_echo` / `server_serve_h2c_ping_echo` | server 回 PONG |
| `ping_smoke` / `conn_ping_smoke` | 离线 + h2c fork 集成烟测 |

烟测：`tests/http/conn_ping.x`。

---

## 31. v26 连接池 GOAWAY 感知

| API | 说明 |
|-----|------|
| `conn_goaway_seen` / `conn_is_pool_reusable` | 连接 GOAWAY 标志与池复用判定 |
| `conn_pool_connect_count` | 池累计新建连接次数 |
| `conn_pool_goaway_smoke` | 离线 + fork 双 TCP 集成烟测 |

烟测：`tests/http/conn_pool_goaway.x`。

---

## 32. v27 HTTP/2 v1 收口（RST + 全局池 GOAWAY）

| API | 说明 |
|-----|------|
| `frame_rst_stream` / `err_rst_stream` | RST_STREAM 帧与语义码 |
| `build_rst_stream` / `conn_reset_stream` | stream 取消 |
| `global_pool_connect_count` | 全局池累计新建连接 |
| `complete_smoke` | v1 收口烟测 |

烟测：`tests/http/http2_complete.x`。

---

## 33. HTTP/2 v1 能力全集（不再逐步扩展）

std.http HTTP/2 生产子集已覆盖 RFC 7540 常用路径：线格式、HPACK（静/动）、client/server、h2c/h2、push、SETTINGS 全协商、流控、GOAWAY、PING、RST、单连接复用、连接池与全局池。  
**远期非目标**：HTTP/3、PRIORITY 树、CONTINUATION 完整实现、连接迁移。

门禁汇总：`complete_smoke()` + `./tests/run-std-http-h2-gate.sh`。

---

## 5. 验证与门禁
