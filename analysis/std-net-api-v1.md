# std.net API v1 稳定化（STD-002）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-001`（std.io）、`EXC-001`（错误返回）、`std.http`（协议层占位）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **传输层稳定** | `import("std.net")` 的 TCP/UDP/DNS API 冻结边界 |
| **echo/http/ws 统一用法** | 三类协议共用「net 建连 + io 读写」栈（§4） |
| **兼容矩阵** | Linux / macOS / Windows 差异可查询 |
| **变更流程** | 与 STD-001 同级评审规则 |

验收标准（NEXT STD-002）：**echo/http/ws 统一用法** 文档化 + 兼容矩阵 + 变更流程 + CI 烟测。

---

## 2. 模块分层

```
协议层（按需 import）
  std.http   ← HTTP（Tier E 占位，v1 仅 get 桩）
  std.ws     ← WebSocket（Tier E，未实现；栈约定见 §4.3）
       │
传输层  std.net  ← TcpStream / UdpSocket / connect / listen（Tier S）
       │
 I/O 层  std.io  ← read_fd / write_fd / stream_*_batch / fixed / provided
       │
  C 层   std/net/net.c + std/io/io.c
```

**v1 规则**：**传输与字节流**走 `std.net` + `std.io`；**协议解析**在 `std.http` / 未来 `std.ws`，不得重复实现 socket 生命周期。

---

## 3. 稳定 API 清单（Tier S）

完整符号见 `tests/baseline/std-net-api.tsv`。

### 3.1 类型

| 类型 | 说明 |
|------|------|
| `Ipv4Addr` / `Ipv6Addr` | 地址 |
| `SocketAddrV4` | 地址 + 端口 |
| `TcpStream` / `TcpListener` | TCP 连接 / 监听 |
| `UdpSocket` | UDP |

### 3.2 TCP 生命周期

| 符号 | 说明 |
|------|------|
| `connect` / `connect_blocking` | 客户端；blocking 用于 bulk/echo 热路径 |
| `listen` / `accept` / `close_listener` | 服务端 |
| `close_stream` | 关 TcpStream（Windows 须用此，非 fs_close） |
| `stream_set_blocking` | bulk 前切阻塞 |
| `accept_many` / `connect_many` | 批量建连（最多 `net_batch_max()`=64） |
| `run_accept_workers` | 多线程压测 accept |

### 3.3 数据路径（委托 std.io）

| 符号 | 说明 |
|------|------|
| `stream_read_batch` / `stream_write_batch` | 4 段 batch |
| `stream_read_batch_buf` / `stream_write_batch_buf` | 1..16 段 |
| `stream_read_fixed` / `stream_write_fixed` | fixed 池（须先 register_fixed_buffers） |
| `stream_read_batch_provided` | ZC-1 provided（Linux io_uring） |

亦可直接：`read_fd(stream.fd, ...)` / `write_fd(stream.fd, ...)`（import("std.io")）。

### 3.4 UDP

| 符号 | 说明 |
|------|------|
| `udp_bind` / `close_udp` | 绑定 / 关闭 |
| `udp_send_to` / `udp_recv_from` | 单报文 |
| `udp_recv_many` / `udp_send_many` | 2 段 batch |
| `udp_recv_many_buf` / `udp_send_many_buf` | 1..8 段 slice 化 |

### 3.5 其它

| 符号 | 说明 |
|------|------|
| `resolve` | DNS → IPv4（阻塞） |
| `connect_ipv6` / `listen_ipv6` | IPv6 TCP |
| `local_addr` / `peer_addr` / `listener_local_addr` | 地址查询 |
| `addr_to_u32` / `u32_to_ipv4` | 地址转换 |

---

## 4. echo / http / ws 统一用法（v1 定版）

三类协议 **共用同一栈**，差异仅在应用层 framing。

### 4.1 统一栈（必遵）

| 步骤 | 层 | 操作 |
|------|-----|------|
| 1 | **std.net** | `listen` / `connect(_blocking)` / `accept` → 得到 `TcpStream` |
| 2 | **std.net** | bulk/echo：`stream_set_blocking(stream, 1)` |
| 3 | **std.net 或 std.io** | 字节读写：`stream_*_batch` / `read_fd` / `write_fd` |
| 4 | **协议** | echo：原样回写；http：解析请求行+头；ws：帧封装（未来） |
| 5 | **std.net** | `close_stream` / `close_listener` |

**禁止**：在 `std.http` / 未来 `std.ws` 内直接 `socket()` / 绕过 `TcpStream.fd` 生命周期。

### 4.2 Echo（TCP 回显，Tier S 参考实现）

参考：`tests/bench/net_echo_throughput.sx`

```su
import("std.net");

// 服务端：listen → accept → read batch → write batch → close
// 客户端：connect_blocking → stream_read_batch / stream_write_batch 循环

let stream: TcpStream = connect_blocking(addr, port, 0);
stream_set_blocking(stream, 1);
stream_write_batch(stream, p0, l0, p1, l1, p2, l2, p3, l3, 4, 0);
stream_read_batch(stream, p0, l0, p1, l1, p2, l2, p3, l3, 4, 0);
close_stream(stream);
```

热路径选项：`stream_read_fixed` / `stream_write_fixed`（fixed 池）或 `stream_read_batch_provided`（Linux ZC-1）。

### 4.3 HTTP（Tier E，占位 → 统一栈）

当前 `std.http.get` 为占位（返回 `-1`）。**v1 约定**实现时：

```su
import("std.net");
import("std.io");

let stream: TcpStream = connect_blocking(addr, 80, 5000);
stream_set_blocking(stream, 1);
write_fd(stream.fd, request_buf, request_len);   // 或 write_from_slice
read_fd(stream.fd, response_buf, response_cap);  // 读 status + headers + body
close_stream(stream);
```

`std.http` 仅封装步骤 3–4 的报文格式，**不**新增 socket API。

### 4.4 WebSocket（Tier E，未实现 → 统一栈）

未来 `std.ws`（模块名暂定）须：

1. `TcpStream` 来自 `std.net.connect`（通常 `:443` 先 TLS，TLS 层另议）
2. HTTP Upgrade 握手字节经 `read_fd` / `write_fd`
3. 帧读写仍在同一 `TcpStream` 上 batch 或 fixed
4. 关闭仍用 `close_stream`

与 echo 相同：**一条连接 = 一个 TcpStream + std.io 字节流**。

---

## 5. 兼容矩阵（v1）

| 能力 | Linux | macOS | Windows |
|------|-------|-------|---------|
| TCP connect/accept | ✅ io_uring / poll | ✅ poll | ✅ select/IOCP |
| connect_blocking | ✅ | ✅ | ✅ |
| accept_many / connect_many | ✅ uring 批量 | ⚠️ 循环回退 | ⚠️ 循环回退 |
| stream_*_batch | ✅ readv/uring | ✅ readv | ✅ 多 Overlapped |
| stream_*_fixed | ✅ | ⚠️ | ⚠️ |
| stream_read_batch_provided | ⚠️ 需 uring 5.19+ | ❌ | ❌ |
| UDP recvmmsg/sendmmsg | ✅ | ⚠️ 循环 | ⚠️ 循环 |
| udp_*_many_buf | ✅ | ✅ | ✅ |
| IPv6 listen/connect | ✅ | ✅ | ✅ |
| DNS resolve | ✅ getaddrinfo | ✅ | ✅ |

---

## 6. 错误与返回值（EXC-001 Layer C）

| API | 成功 | 失败 |
|-----|------|------|
| connect/listen/accept | `TcpStream.fd >= 0` | `fd == -1` |
| read/write/batch | `>0` 字节，`0` EOF | `-1` |
| accept_many/connect_many | 返回 u32 计数 | 部分失败时计数 `< n` |
| udp_recv_from | `>0` 字节，`0` 无数据 | `-1` |
| close_* | `0` | `-1` |

---

## 7. API 变更流程

与 `analysis/std-io-api-v1.md` §6 一致：

| 级别 | 清单 | 规则 |
|------|------|------|
| **S** | `std-net-api.tsv` | 禁止破坏性改签名 |
| **P** | §5 矩阵 | 允许 per-OS 差异 |
| **E** | std.http / 未来 std.ws | 协议层可快速迭代 |

破坏性变更：更新 NEXT + 基线 + `run-std-net-api-gate.sh` + `run-net.sh`。

---

## 8. CI 门禁

| 脚本 | 作用 |
|------|------|
| `tests/run-std-net-api-gate.sh` | Tier-S manifest + `run-net.sh` |
| `tests/run-net.sh` | listen + UDP batch smoke |
| `tests/run-perf-net.sh` | echo 吞吐基准 |
| `tests/run-zc1-gate.sh` | net + provided 路径 |

---

## 9. v2 预留

| 项 | 说明 |
|----|------|
| std.http 实装 | 按 §4.3 栈实现 GET/HEAD |
| std.ws | 按 §4.4 栈 + 帧协议 |
| TLS | std.crypto / 平台 SSL |
| Result_i32 化 | 评估后迁移（EXC-001） |

---

## 10. 索引

| 资源 | 路径 |
|------|------|
| 实现 | `std/net/mod.sx`、`net.c` |
| 用户 README | `std/net/README.md` |
| echo 参考 | `tests/bench/net_echo_throughput.sx` |
| 稳定符号 | `tests/baseline/std-net-api.tsv` |
| 性能分析 | `analysis/std.net性能压榨与超越Zig.md` |

**STD-002 状态：定版 ✅**
