# std.net — 高吞吐 TCP/UDP 传输层

与 **Zig** std.net、**Rust** std::net 对标。用户通过 `import("std.net")` 使用。

## 职责

- **TCP**：`connect` / `listen` / `accept` / `TcpStream` / `TcpListener`
- **批量建连**：`accept_many` / `connect_many`（Linux io_uring 真批量）
- **数据路径**：`stream_read_batch` / `stream_write_batch` 等（委托 **std.io** 后端）
- **UDP**：`udp_bind` / `udp_send_to` / `udp_recv_many_buf`
- **DNS / IPv6**：`resolve_ex` / `resolve_ipv6`（STD-029 可诊断错误码）、`ipv6_loopback`、`connect_ipv6`

## echo / http / ws 统一栈

所有面向连接的协议共用：

1. **std.net** 建连 → `TcpStream`
2. **std.io** 或 **stream_*** 读写字节
3. 协议层（echo 回写 / **std.http** / **std.net ws_***（STD-031））只处理报文格式

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
- **WebSocket（STD-031）**：`analysis/std-net-ws-v1.md`、`tests/run-std-net-ws-gate.sh`（Accept + 帧 + 握手烟测）

## 相关模块

| 模块 | 关系 |
|------|------|
| `std.io` | 字节读写后端 |
| `std.http` | HTTP 协议（占位，基于本模块 + std.io） |
| `std.fs` | 文件 fd 可走 io 联合路径，非 net 替代 |
