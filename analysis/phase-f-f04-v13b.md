# 阶段 F-04 v13b（std.net UDP batch 去 C）

> **F-04 v13b v1**：从 **`net.c`** 迁出 **UDP 批量 recv/send** → **`net_udp_batch.sx`** + **`compiler/src/asm/runtime_net_udp_batch.c`**（F-ZC）。

## v13b v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `net_udp_batch.sx` | `net_udp_recv_many_c` / `net_udp_send_many_c` / `net_udp_recv_many_buf_c` / `net_udp_send_many_buf_c` |
| `runtime_net_udp_batch.c` | Linux glibc `recvmmsg` / `sendmmsg`（mmsghdr 胶层） |
| `net.c` | 375 → **~115 行**；仅 `net_run_accept_workers_c*` |
| `Makefile` | `net.o` 合并 **9** 个 `.sx`；胶层在 `runtime_net_udp_batch.o` |

## v13b 限制（v14+）

| 项 | 说明 |
|----|------|
| accept workers | **F-04 v14 ✅** 见 `net_workers.sx` |
| Linux 非 glibc | 回退 net_udp_recv_from_c 循环（与 macOS 同） |
| Windows UDP poll | 基础 recv 超时路径仍为桩 |

## 复现

```bash
SHUX_F04_NET_SLICE_V13B_FAIL=1 ./tests/run-f04-std-net-slice-v13b-gate.sh
SHUX_F04_NET_SLICE_V13_FAIL=1 ./tests/run-f04-std-net-slice-v13-gate.sh
./tests/run-net.sh
```
