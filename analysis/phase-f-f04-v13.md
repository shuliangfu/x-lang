# 阶段 F-04 v13（std.net IPv4 TCP 核心去 C）

> **F-04 v13 v1**：从 **`net.c`** 迁出 **IPv4 TCP connect/listen/accept/batch** → **`net_tcp.sx`**。

## v13 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `net_tcp.sx` | `net_tcp_connect_c` / `net_tcp_connect_blocking_c` / `net_tcp_listen_c` / `net_accept_c` / `net_accept_many_c` / `net_connect_many_c` |
| `net.c` | 移除 ~220 行 TCP 实现；保留 `net_run_accept_workers_c*` 与 UDP batch |
| `Makefile` | `net.o` 合并 **8** 个 `.sx` 模块（含 `net_tcp`） |
| 依赖 | `net_sock.sx`（`net_set_blocking_c` / `net_close_socket_c`）；Linux `io.o` io_uring |

## v13 限制（v13b+）

| 项 | 说明 |
|----|------|
| accept workers | `net_run_accept_workers_c*` 仍 net.c（pthread/Win32 线程） |
| UDP batch | **F-04 v13b ✅** 见 `net_udp_batch.sx` |
| Windows TCP poll | connect/accept 超时路径 poll 仍为桩（与 v12 UDP 同类） |

## 复现

```bash
SHUX_F04_NET_SLICE_V13_FAIL=1 ./tests/run-f04-std-net-slice-v13-gate.sh
SHUX_F04_NET_SLICE_V12_FAIL=1 ./tests/run-f04-std-net-slice-v12-gate.sh
./tests/run-net.sh
```
