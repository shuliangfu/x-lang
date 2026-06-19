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
| 4 | 烟测：`tests/http/http2_wire.sx` |

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
| `http2_preface_len()` | preface 长度（24） |
| `http2_is_connection_preface(buf, len)` | preface 检测 |
| `http2_parse_frame_header(...)` | 帧头解析 |
| `http2_build_settings_ack(out, cap)` | SETTINGS ACK（9 字节） |
| `http2_build_settings_one(id, value, out, cap)` | 单条 SETTINGS |
| `http2_wire_is_available()` | 线格式层可用（v0=true） |
| `http2_client_is_available()` | 完整客户端（v0=false） |
| `http2_write_alpn_h2(out, cap)` | ALPN "h2" |
| `http2_err_not_impl()` | 完整客户端错误码（-1230） |
| `http2_smoke()` | C 烟测 |

常量：`http2_frame_settings()`、`http2_flag_ack()`、`http2_setting_max_concurrent_streams()`。

---

## 6. v1 客户端 API（HPACK + HEADERS/DATA）

| API | 说明 |
|-----|------|
| `http2_hpack_encode_indexed` / `http2_hpack_encode_literal` | HPACK 静态表编码 |
| `http2_hpack_encode_get_request` | GET 四元组头块 |
| `http2_hpack_decode_status` | 响应 `:status` 解析 |
| `http2_build_headers_frame` / `http2_build_data_frame` | 帧构建 |
| `http2_build_get_headers_frame` | stream 1 GET HEADERS |
| `http2_client_smoke` / `http2_hpack_smoke` | 离线烟测 |
| `http2_client_is_available()` | v1=true（编解码层） |
| `http2_err_network_h2()` | TLS ALPN 网络路径未就绪（-1231） |

v1 支持多 stream HEADERS 帧组装（烟测 stream 1/3）；不含 Huffman。

---

## 9. v3 动态 HPACK/多方法

| API | 说明 |
|-----|------|
| `http2_hpack_dyn_reset` / `http2_hpack_dyn_count` | FIFO 动态表（16 条目） |
| `http2_hpack_encode_literal_incremental` | incremental indexing |
| `http2_hpack_encode_indexed_any` | 静态或动态 index≥62 |
| `http2_hpack_encode_request` | 多 method 请求头块 |
| `http2_build_request_headers_frame` | POST 等带 body 时不设 END_STREAM |
| `http2_hpack_dyn_smoke` | 动态表复用烟测 |
| `h2_request` / `client_request_h2` | HTTPS+h2 全 method（POST/PUT/PATCH 须 body） |

烟测：`tests/http/http2_hpack_dyn.sx`；网络层 `http2_session_request_tls_c` 发 HEADERS+DATA。

---

## 7. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v7 | 2026-06-19 | h2c preface + push 离线收集 + HttpUrlOwned（reqresp v2） |
| v6 | 2026-06-19 | 接收侧流控 + PUSH_PROMISE/h2c wire + 读路径 WU |
| v5 | 2026-06-19 | 流控状态机 + DATA 背压 + `http2_err_flow_blocked` |
| v3 | 2026-06-19 | 动态 HPACK + POST/多 method + `h2_request` |
| v1 | 2026-06-19 | HPACK 静态表 + HEADERS/DATA + 多路复用烟测 |
| v0 | 2026-06-19 | preface/帧头/SETTINGS ACK + gate |

---

## 4. 远期（HTTP/3 等，非 std.http v1 目标）

HTTP/2 v1 生产子集已于 v27 收口（见 §32–33）。以下为**非** std.http v1 范围：

1. HTTP/3 / QUIC
2. PRIORITY 树 / CONTINUATION 完整实现
3. HPACK Huffman **编码**（解码已实现）

当前 `http2_client_is_available()` 为 true；HTTP/1.1 + HTTP/2 v1 gate 全绿。

```bash
./tests/run-std-http-h2-gate.sh
```

## 8. v2 TLS/ALPN 网络

| 层 | API |
|----|-----|
| std.net | `tls_alpn_h2_http1_wire` / `tls_connect_client_alpn` / `tls_alpn_is_h2` |
| std.http | `h2_get` / `h2_request` / `client_request_h2` / `http2_network_smoke` |

`h2_get` / `h2_request` 流程：TCP → TLS+ALPN(h2) → preface → HEADERS(+DATA) → 读 DATA → 格式化为 HTTP/1 风格响应。

烟测：`tests/http/http2_network.sx`（离线）。

---

## 10. v5 流控状态机

| API | 说明 |
|-----|------|
| `Http2FlowState` | 连接/流发送窗口（conn_window + stream_window） |
| `http2_flow_state_init` / `http2_flow_state_reset_stream` | 初始化 / 新 stream |
| `http2_flow_state_apply_initial_window` | SETTINGS INITIAL_WINDOW_SIZE |
| `http2_flow_state_apply_window_update` | 应用 WINDOW_UPDATE（sid=0 为连接级） |
| `http2_flow_state_max_send` / `http2_flow_state_can_send` | 背压查询 |
| `http2_flow_state_consume_send` | 发 DATA 后扣减窗口 |
| `http2_parse_window_update_payload` | 解析 4 字节 increment |
| `http2_err_flow_blocked()` | 背压错误码（-1232） |
| `http2_flow_state_smoke` | 离线烟测 |

烟测：`tests/http/http2_flow_state.sx`。网络层发 DATA 前检查窗口（`http2_session_request_tls_c`）。

---

## 11. v6 接收侧流控 / push / h2c

| API | 说明 |
|-----|------|
| `Http2FlowRecvState` | 接收侧剩余窗口（conn_left + stream_left） |
| `http2_flow_recv_init` / `http2_flow_recv_on_data` | 收 DATA 扣减 |
| `http2_flow_recv_release` | 释放已消费字节并构建 WINDOW_UPDATE |
| `http2_flow_recv_smoke` | 接收侧流控烟测 |
| `http2_frame_push_promise` / `http2_is_push_promise_frame` | PUSH_PROMISE 检测 |
| `http2_parse_push_promise_stream` | promised stream id 解析 |
| `http2_is_h2c_upgrade_response` | 101 + Upgrade: h2c 识别 |
| `http2_h2c_is_available()` | cleartext 会话（v6 恒 false） |
| `http2_err_push_not_impl()` / `http2_err_h2c_not_impl()` | -1233 / -1234 |
| `http2_push_h2c_smoke` | push/h2c wire 烟测 |

烟测：`tests/http/http2_flow_recv_push_h2c.sx`。`http2_read_response_stream1` 收 DATA 后自动发 WINDOW_UPDATE。

---

## 12. v7 h2c/push 资源

| API | 说明 |
|-----|------|
| `http2_h2c_wire_is_available()` | cleartext preface 构建可用 |
| `http2_h2c_session_begin` | TCP 直连后写连接 preface（24B） |
| `http2_push_fetch_smoke` | promised stream DATA 离线累积 |
| `Http2PushResource` | push 资源视图 struct |

---

## 13. v8 h2c TCP/push 网络

| API | 说明 |
|-----|------|
| `http2_h2c_is_available()` | cleartext TCP 会话 API（v8 true） |
| `http2_session_request_h2c` | 已 connect fd 上 preface+请求（C） |
| `http2_push_last_reset` / `http2_push_last_copy` | 读路径 push 资源 |
| `http2_push_network_smoke` / `http2_h2c_network_smoke` | 烟测 |

读路径：收到 PUSH_PROMISE 后收集 promised stream DATA；主响应仍为 stream 1。

---

## 14. v9 h2c URL 客户端 / 多 stream

| API | 说明 |
|-----|------|
| `h2c_get` / `h2c_request` / `client_request_h2c` | `http://` 明文 TCP + preface；`https://` 返回 `http2_err_h2c_scheme()` (-1235) |
| `http2_h2c_client_smoke` | https URL 须 SCHEME 错误；0 通过 |
| `Http2StreamRegistry` / `http2_stream_registry_init` / `http2_stream_registry_open` | 连接级 stream id 分配/跟踪（8 槽，奇数 client-initiated） |
| `http2_stream_registry_smoke` | 多 stream 注册表烟测 |

烟测：`tests/http/h2c_client.sx`、`tests/http/http2_stream_registry.sx`。

---

## 15. v10 SETTINGS 协商 / 并发客户端

| API | 说明 |
|-----|------|
| `Http2PeerSettings` / `http2_peer_settings_*` | 解析/应用 MAX_CONCURRENT_STREAMS、INITIAL_WINDOW_SIZE |
| `http2_build_client_settings` | 客户端 SETTINGS 帧（双参数，21 字节） |
| `Http2MultistreamClient` / `http2_multistream_client_init` / `http2_multistream_client_open_stream` | registry + 对端 SETTINGS + 流控；并发 open/build |
| `http2_multistream_client_build_parallel_get` | 离线并行 GET HEADERS 帧 |
| `http2_err_max_streams()` | 超并发上限 -1236 |
| `http2_settings_smoke` / `http2_multistream_client_smoke` | 烟测 |

网络：`http2_session_request_*` 发 client SETTINGS；读路径解析 server SETTINGS 并 ACK。

烟测：`tests/http/http2_multistream_client.sx`。

---

## 16. v11 单连接复用

| API | 说明 |
|-----|------|
| `Http2Conn` / `http2_conn_init` / `http2_conn_attach_h2c` / `http2_conn_attach_tls` | 可复用连接对象 |
| `http2_conn_handshake` | preface + client SETTINGS + 读 server SETTINGS ACK |
| `http2_conn_request` | 同一连接上新 stream 请求 + 读该 stream 响应 |
| `http2_conn_close` | 标记连接关闭 |
| `http2_err_conn_not_ready()` | 未 handshake -1237 |
| `http2_conn_reuse_smoke` | 无效 fd 烟测 |

`http_h2_request_c` / `http2_session_request_*` 内部复用 conn 路径（单次请求仍一次 handshake）。

烟测：`tests/http/http2_conn_reuse.sx`。

---

## 17. v12 连接池 / 长连接 URL

| API | 说明 |
|-----|------|
| `http2_conn_pool_create_h2c` / `http2_conn_pool_create_h2` | 绑定 host:port 的 h2c / h2 池 |
| `http2_conn_pool_destroy` | 关闭 idle 并释放池 |
| `h2c_pool_get` / `h2_pool_get` | 长连接池 GET（复用 handshake 连接） |
| `http2_conn_pool_request` | 池上多 method 请求 |
| `http2_err_pool_scheme()` | URL scheme 与池不匹配 -1238 |
| `http2_conn_pool_smoke` | 烟测 |

烟测：`tests/http/http2_conn_pool.sx`。

---

## 18. v13 全局连接池 / URL 路由

| API | 说明 |
|-----|------|
| `http2_global_pool_create` / `http2_global_pool_destroy` | 多 host:port 全局池 |
| `http2_global_pool_get` / `http2_global_pool_request` | URL 自动选 h2c/h2 子池并发请求 |
| `http2_global_pool_entry_count` | 已登记子池数量 |
| `http2_err_global_pool_full()` | host:port 条目已满 -1239 |
| `http2_global_pool_smoke` | 烟测 |

烟测：`tests/http/http2_global_pool.sx`。

---

## 19. v14 h2c server / listen+serve

| API | 说明 |
|-----|------|
| `serve_h2c_one` | accept 一个 h2c 连接并回 200 GET 响应 |
| `http2_server_serve_h2c` | 对已 accept fd 处理单次 GET |
| `http2_hpack_decode_get_request` / `http2_hpack_encode_status` | 请求头解析 / 响应 :status 编码 |
| `http2_err_server()` | server 协议错误 -1240 |
| `http2_server_smoke` | 烟测（含 fork 集成） |

烟测：`tests/http/http2_server.sx`。

---

## 20. v15 h2 over TLS server / ALPN

| API | 说明 |
|-----|------|
| `http2_tls_server_ctx_create` / `http2_tls_server_ctx_destroy` | PEM 内存加载 TLS 服务端上下文 |
| `serve_h2_one` | accept + TLS + ALPN h2 + GET serve |
| `http2_server_serve_h2` | 已 TLS 握手会话上单次 GET serve |
| `http2_err_server_tls()` | TLS/ALPN 不可用 -1241 |

烟测：含于 `http2_server_smoke`（TLS 不可用时跳过集成段）。

---

## 21. v16 server 多 stream 并发 serve

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one` / `http2_server_serve_h2c_multi` | h2c 单连接顺序 serve N 个 GET |
| `serve_h2_multi_one` / `http2_server_serve_h2_multi` | TLS h2 同上 |
| `http2_server_multistream_smoke` | 双 stream 集成烟测 |

烟测：`tests/http/http2_server_multistream.sx`。

---

## 22. v17 server push 响应

| API | 说明 |
|-----|------|
| `serve_h2c_one_with_push` / `http2_server_serve_h2c_with_push` | h2c GET 响应前发 PUSH_PROMISE + push 资源 |
| `http2_err_server_push()` | push 参数非法 -1242 |
| `http2_server_push_smoke` | 离线 PUSH_PROMISE 线格式 + fork 集成烟测 |

烟测：`tests/http/http2_server_push.sx`。

---

## 23. v18 TLS server push 响应

| API | 说明 |
|-----|------|
| `serve_h2_one_with_push` / `http2_server_serve_h2_with_push` | ALPN h2 TLS GET 响应前发 PUSH_PROMISE + push 资源 |
| `http2_server_push_tls_smoke` | fork + 自签 PEM TLS push 集成烟测 |

烟测：`tests/http/http2_server_push_tls.sx`。

---

## 24. v19 server 多 stream + push 组合 serve

| API | 说明 |
|-----|------|
| `serve_h2c_multi_one_with_push` / `http2_server_serve_h2c_multi_with_push` | h2c 长连接顺序 N 个 GET，每个带 PUSH_PROMISE |
| `serve_h2_multi_one_with_push` / `http2_server_serve_h2_multi_with_push` | TLS h2 同上 |
| `http2_server_multistream_push_smoke` | fork 双 GET + 双 push 烟测 |

烟测：`tests/http/http2_server_multistream_push.sx`。

---

## 25. v20 push ENABLE_PUSH 协商 / 软拒绝

| API | 说明 |
|-----|------|
| `http2_setting_enable_push()` | SETTINGS id 0x0002 |
| `http2_peer_settings_enable_push` | 对端是否允许 server push |
| `http2_build_client_settings_ex` | 客户端 SETTINGS 含 ENABLE_PUSH |
| `http2_conn_handshake_with_enable_push` | client ENABLE_PUSH=0 拒绝 push |
| `http2_err_server_push_disabled()` | 软拒绝语义码 -1243 |
| `http2_server_push_settings_smoke` | fork 烟测（无 PUSH_PROMISE + 主 200） |

烟测：`tests/http/http2_server_push_settings.sx`。

---

## 26. v21 server SETTINGS 全量协商

| API | 说明 |
|-----|------|
| `http2_setting_header_table_size` / `http2_setting_max_frame_size` | SETTINGS id 常量 |
| `http2_peer_settings_header_table_size` / `http2_peer_settings_max_frame_size` | 对端协商值（含 RFC 默认） |
| `http2_build_server_settings` | server 5 项 SETTINGS 帧（39 字节） |
| `http2_server_settings_full_smoke` | fork 读 server SETTINGS 烟测 |

烟测：`tests/http/http2_server_settings_full.sx`。

---

## 27. v22 server HPACK 动态表 / HEADER_TABLE_SIZE

| API | 说明 |
|-----|------|
| `http2_hpack_server_dyn_create` / `http2_hpack_server_dyn_set_table_size` | 对端 SETTINGS 联动动态表上限 |
| `http2_hpack_server_dyn_max_size` | 读回 HEADER_TABLE_SIZE 上限 |
| `http2_hpack_server_encode_status` | server 响应 :status（200 静态 indexed；其它码写入动态表并复用） |
| `http2_hpack_server_dyn_smoke` / `http2_server_hpack_dyn_smoke` | 离线 + h2c 多 stream 集成烟测 |

烟测：`tests/http/http2_server_hpack_dyn.sx`。

---

## 28. v23 server MAX_FRAME_SIZE 分片 DATA

| API | 说明 |
|-----|------|
| `http2_frame_payload_limit` / `http2_frame_check_payload` | 单帧 payload 上限与校验 |
| `http2_frame_count_data_chunks` | DATA 按 MAX_FRAME_SIZE 分片帧数 |
| `http2_build_client_settings_with_max_frame` / `http2_conn_handshake_with_max_frame` | client 声明 MAX_FRAME_SIZE |
| `http2_frame_capped_smoke` / `http2_server_max_frame_smoke` | 离线 + h2c 16385B/16384 分片集成烟测 |

烟测：`tests/http/http2_server_max_frame.sx`。

---

## 29. v24 GOAWAY / 连接优雅关闭

| API | 说明 |
|-----|------|
| `http2_frame_goaway` / `http2_goaway_error_no_error` / `http2_err_goaway` | GOAWAY 帧类型与错误码 |
| `http2_build_goaway` / `http2_parse_goaway` | GOAWAY 帧构建/解析 |
| `http2_conn_shutdown_graceful` | client 发 GOAWAY 后 shutdown |
| `http2_conn_read_goaway` | 读对端 GOAWAY 帧 |
| `serve_h2c_one_with_goaway` / `http2_server_serve_h2c_with_goaway` | server 响应后发 GOAWAY |
| `http2_goaway_smoke` / `http2_conn_goaway_smoke` | 离线 + h2c fork 集成烟测 |

烟测：`tests/http/http2_conn_goaway.sx`。

---

## 30. v25 PING/PONG 连接保活

| API | 说明 |
|-----|------|
| `http2_frame_ping` / `http2_err_ping` | PING 帧类型与往返失败码 |
| `http2_build_ping` / `http2_build_ping_ack` / `http2_parse_ping` | PING/PONG 编解码 |
| `http2_conn_ping` | client 发 PING 等 PONG |
| `serve_h2c_one_ping_echo` / `http2_server_serve_h2c_ping_echo` | server 回 PONG |
| `http2_ping_smoke` / `http2_conn_ping_smoke` | 离线 + h2c fork 集成烟测 |

烟测：`tests/http/http2_conn_ping.sx`。

---

## 31. v26 连接池 GOAWAY 感知

| API | 说明 |
|-----|------|
| `http2_conn_goaway_seen` / `http2_conn_is_pool_reusable` | 连接 GOAWAY 标志与池复用判定 |
| `http2_conn_pool_connect_count` | 池累计新建连接次数 |
| `http2_conn_pool_goaway_smoke` | 离线 + fork 双 TCP 集成烟测 |

烟测：`tests/http/http2_conn_pool_goaway.sx`。

---

## 32. v27 HTTP/2 v1 收口（RST + 全局池 GOAWAY）

| API | 说明 |
|-----|------|
| `http2_frame_rst_stream` / `http2_err_rst_stream` | RST_STREAM 帧与语义码 |
| `http2_build_rst_stream` / `http2_conn_reset_stream` | stream 取消 |
| `http2_global_pool_connect_count` | 全局池累计新建连接 |
| `http2_http2_complete_smoke` | v1 收口烟测 |

烟测：`tests/http/http2_http2_complete.sx`。

---

## 33. HTTP/2 v1 能力全集（不再逐步扩展）

std.http HTTP/2 生产子集已覆盖 RFC 7540 常用路径：线格式、HPACK（静/动）、client/server、h2c/h2、push、SETTINGS 全协商、流控、GOAWAY、PING、RST、单连接复用、连接池与全局池。  
**远期非目标**：HTTP/3、PRIORITY 树、CONTINUATION 完整实现、连接迁移。

门禁汇总：`http2_http2_complete_smoke()` + `./tests/run-std-http-h2-gate.sh`。

---

## 5. 验证与门禁
