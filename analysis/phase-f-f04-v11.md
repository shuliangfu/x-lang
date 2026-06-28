# 阶段 F-04 v11（std.net 地址/IPv6/io batch 去 C）

> **F-04 v11 v1**：从 **`net.c`** 迁出 **local/peer 地址**、**IPv6 TCP**、**stream io batch** → 独立 `.sx`；`ld -r` 合并进 `net.o`。

## v11 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `addr.sx` | `net_tcp_local_addr_c` / `net_tcp_peer_addr_c` |
| `ipv6.sx` | `net_tcp_connect_ipv6_c` / `net_tcp_listen_ipv6_c` |
| `io_batch.sx` | `net_stream_*_batch_c`（→ io.o C 符号） |
| `net.c` | 移除上述 ~170 行；**922 → ~750 行** |
| `Makefile` | `net.o` 合并 5 个 `.sx` 模块 |

## v11 限制（v12+）

| 项 | 说明 |
|----|------|
| IPv4 TCP/UDP 核心 | connect/listen/accept、UDP batch 仍 net.c |
| Windows IPv6 connect | v11 `net_ipv6_poll_writable` 为桩；listen 可用 |
| io_uring | Linux connect/accept 仍走 net.c + io.o |
| 无 shux | `net.o` 缺 v10/v11 符号 |

## 复现

```bash
SHUX_F04_NET_SLICE_V11_FAIL=1 ./tests/run-f04-std-net-slice-v11-gate.sh
SHUX_F04_NET_DNS_ALPN_FAIL=1 ./tests/run-f04-std-net-dns-alpn-gate.sh
./tests/run-std-net-dns-gate.sh
./tests/run-net.sh
```
