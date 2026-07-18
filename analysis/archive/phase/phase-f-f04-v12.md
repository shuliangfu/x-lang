# 阶段 F-04 v12（std.net socket/UDP 基础去 C）

> **F-04 v12 v1**：从 **`net.c`** 迁出 **close/blocking** 与 **UDP 基础** → **`sock.x`** + **`udp.x`**。

## v12 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `sock.x` | `net_close_socket_c` / `net_set_blocking_c` |
| `udp.x` | `net_udp_bind_c` / `net_udp_send_to_c` / `net_udp_recv_from_c` |
| `net.c` | 移除上述 ~100 行；UDP batch（recvmmsg）仍留 C |
| `Makefile` | `net.o` 合并 7 个 `.x` 模块 |

## v12 限制（v13+）

| 项 | 说明 |
|----|------|
| IPv4 TCP 核心 | connect/listen/accept/accept_workers 仍 net.c |
| UDP batch | `net_udp_recv_many_*` 仍 net.c（recvmmsg/sendmmsg） |
| io_uring | Linux TCP 仍 net.c + io.o |
| Windows UDP poll | v12 recv 超时路径为桩 |

## 复现

```bash
SHUX_F04_NET_SLICE_V12_FAIL=1 ./tests/run-f04-std-net-slice-v12-gate.sh
SHUX_F04_NET_SLICE_V11_FAIL=1 ./tests/run-f04-std-net-slice-v11-gate.sh
./tests/run-net.sh
```
