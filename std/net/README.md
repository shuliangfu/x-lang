# std.net — 高吞吐 TCP/UDP 传输层

与 **Zig** std.net、**Rust** std::net 对标。用户通过 `import("std.net")` 使用。

## 职责

- **TCP**：`connect` / `listen` / `accept` / `TcpStream` / `TcpListener`
- **批量建连**：`accept_many` / `connect_many`（Linux io_uring 真批量）
- **数据路径**：`stream_read_batch` / `stream_write_batch` 等（委托 **std.io** 后端）
- **UDP**：`udp_bind` / `udp_send_to` / `udp_recv_many_buf`
- **DNS / IPv6**：`resolve_ex` / `resolve_ipv6`（STD-029 可诊断错误码）、`ipv6_loopback`、`connect_ipv6`

## echo / http / websocket 统一栈

面向连接的协议分层：

1. **std.net** 建连 → `TcpStream`
2. **std.io** 或 **stream_*** 读写字节
3. 协议层：
   - echo 回写
   - **std.http** — HTTP/1.x 客户端与服务辅助（GET/POST/HEAD、Context、server/pool）
   - **std.websocket** — RFC6455 握手与帧（F-04 v3：`ws_codec.x` + `ws_io.x`，公开 API 在 `std/websocket/mod.x`）

> WebSocket **不**再作为 `std.net` 公开 API；STD-031 net-ws gate 测 C 层，用户应 `import("std.websocket")`。

详见 [`analysis/std-net-api-v1.md`](../../analysis/std-net-api-v1.md) §4。

### Echo 最小示例

```su
import("std.net");

let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
let s: TcpStream = connect_blocking(addr, port, 0);
stream_set_blocking(s, 1);
// stream_read_batch / stream_write_batch 或 read_fd/write_fd
close_stream(s);
```

## 与 std.io

- `TcpStream.fd` 可传 `read_fd` / `write_fd`（import("std.io")）
- batch/fixed/provided 已在 mod 薄封装，内部走 std.io.driver

## 稳定化

- **API 矩阵与变更流程**：[`analysis/std-net-api-v1.md`](../../analysis/std-net-api-v1.md)
- **基线**：`tests/baseline/std-net-api.tsv`
- **门禁**：`tests/run-std-net-api-gate.sh`
- **DNS（STD-029）**：`analysis/std-net-dns-v1.md`、`tests/run-std-net-dns-gate.sh`
- **TLS（STD-030/083/085）**：`analysis/std-net-tls-v1.md`、`tests/run-std-net-tls-gate.sh`（桩 + OpenSSL/mbedTLS 握手烟测）
- **TLS ALPN（STD-HTTP-H2-TLS）**：`tls_alpn_h2_http1_wire` / `tls_connect_client_alpn` / `tls_alpn_is_h2`（h2 + http/1.1）
- **WebSocket（STD-031）**：F-04 v3 纯 `.x`（`ws_codec.x` / `ws_io.x`）；用户 API 见 **std.websocket**、`tests/run-std-websocket-gate.sh`

## 相关模块

| 模块 | 关系 |
|------|------|
| `std.io` | 字节读写后端 |
| `std.http` | HTTP/1.x 客户端与服务辅助 |
| `std.websocket` | WebSocket 握手与帧（依赖 net + 可选 http Upgrade） |
| `std.fs` | 文件 fd 可走 io 联合路径，非 net 替代 |
