# 阶段 F-04 v10（std.net DNS/ALPN 去 C）

> **F-04 v10 v1**：从 **`net.c`** 迁出 **DNS** 与 **ALPN 线格式** → **`net_dns.sx`** + **`net_alpn.sx`**；`ld -r` 合并进 `net.o`。

## v10 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `net_alpn.sx` | `net_tls_alpn_h2_http1_wire_c`（RFC 7301 h2 + http/1.1） |
| `net_dns.sx` | `net_resolve_ipv4_c` / `_ex_c` / `net_resolve_ipv6_ex_c`（getaddrinfo FFI） |
| `net.c` | 移除 DNS/ALPN/legacy `net_tls_last_error_c`（~160 行） |
| `Makefile` | `net.o` = `net_main.o` + `net_alpn.o` + `net_dns.o`（须 shux） |
| 存量 | F-01 total **96**（无 .c 增减） |

## v10 限制（v11+）

| 项 | 说明 |
|----|------|
| TCP/UDP/IPv6 socket | 仍在 `net.c`（~920 行）→ v11+ 分批 `.sx` |
| 无 shux | `net.o` 仅 `net_main.o`，缺 DNS/ALPN 符号 |
| `net_map_gai_error` | 按 linux/macos/windows `#[cfg]` 硬编码 EAI 值 |
| io_uring 批量 | Linux connect/accept 仍 net.c + io.o |

## 复现

```bash
SHUX_F04_NET_DNS_ALPN_FAIL=1 ./tests/run-f04-std-net-dns-alpn-gate.sh
SHUX_STD_NET_DNS_FAIL=1 ./tests/run-std-net-dns-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```
