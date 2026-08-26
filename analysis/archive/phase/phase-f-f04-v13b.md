# 阶段 F-04 v13b（std.net UDP batch 去 C）

> **F-04 v13b v1**：从 **`net.c`** 迁出 **UDP 批量 recv/send** → **`udp_batch.x`** + **`compiler/src/asm/runtime_net_udp_batch.c`**（F-ZC）。

## v13b v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `udp_batch.x` | `net_udp_recv_many_c` / `net_udp_send_many_c` / `net_udp_recv_many_buf_c` / `net_udp_send_many_buf_c` |
| `runtime_net_udp_batch.c` | Linux glibc `recvmmsg` / `sendmmsg`（mmsghdr 胶层） |
| `net.c` | 375 → **~115 行**；仅 `net_run_accept_workers_c*` |
| `Makefile` | `net.o` 合并 **9** 个 `.x`；胶层在 `runtime_net_udp_batch.o` |

## v13b 限制（v14+）

| 项 | 说明 |
|----|------|
| accept workers | **F-04 v14 ✅** 见 `workers.x` |
| Linux 非 glibc | 回退 net_udp_recv_from_c 循环（与 macOS 同） |
| Windows UDP poll | 基础 recv 超时路径仍为桩 |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static + ensure `runtime_net_udp_batch.o`. No soft
`die→exit 0`. Soft `XLANG_F04_NET_SLICE_V13B_FAIL` retired. Report
`static=` / `v13=` / `skip=`. Live authority = ensure +
`driver_seed_r_lists.mk` (Makefile deleted).

```bash
./tests/run-f04-std-net-slice-v13b-gate.sh
```

## 复现

```bash
XLANG_F04_NET_SLICE_V13B_FAIL=1 ./tests/run-f04-std-net-slice-v13b-gate.sh
XLANG_F04_NET_SLICE_V13_FAIL=1 ./tests/run-f04-std-net-slice-v13-gate.sh
./tests/run-net.sh
```
