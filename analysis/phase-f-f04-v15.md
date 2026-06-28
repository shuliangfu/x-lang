# 阶段 F-04 v15（std.net 宿主路径闭合）

> **F-04 v15 v1**：**std.net** 宿主 API 自 **v1～v14** 全部迁 `.sx`；**`net.c` 已删除**；仅保留最小胶层 C。

## v15 闭合清单（✅ manifest）

| 模块 | 文件 | 阶段 |
|------|------|------|
| TLS stub | `tls_stub.sx` | v1 |
| TCP pool | `tcp_pool.sx` | v2 |
| WebSocket | `ws_codec.sx` + `ws_io.sx` | v3 |
| compress 族 | 已完成（独立 F-04 v4～v7） | — |
| OpenSSL TLS | `tls_openssl.sx` | v8 |
| mbedTLS TLS | `tls_mbedtls.sx` + `tls_mbedtls_bio.c` | v9 |
| DNS / ALPN | `dns.sx` + `alpn.sx` | v10 |
| addr / IPv6 / io batch | `addr.sx` + `ipv6.sx` + `io_batch.sx` | v11 |
| sock / UDP 基础 | `sock.sx` + `udp.sx` | v12 |
| IPv4 TCP | `tcp.sx` | v13 |
| UDP batch | `udp_batch.sx` + `runtime_net_udp_batch.c` | v13b / F-ZC |
| accept workers | `workers.sx` + `runtime_net_workers.c` | v14 / F-ZC |

## 仍允许的 C（胶层 only）

| 文件 | 原因 |
|------|------|
| `tls_mbedtls_bio.c` | mbedTLS `ssl_set_bio` 函数指针 |
| `compiler/.../runtime_net_udp_batch.c` | Linux `recvmmsg`/`sendmmsg` mmsghdr |
| `compiler/.../runtime_net_workers.c` | pthread/Win32 线程入口指针 |

## 构建

`net.o` = 10× `.sx`（`ld -r`）；`runtime_net_udp_batch.o` + `runtime_net_workers.o` 与 `net.o` 同链；TLS OpenSSL/mbedTLS 为独立 `tls_*.o`。

## 复现

```bash
SHUX_F04_NET_CLOSURE_FAIL=1 ./tests/run-f04-std-net-closure-gate.sh
SHUX_F04_NET_SLICE_V14_FAIL=1 ./tests/run-f04-std-net-slice-v14-gate.sh
./tests/run-net.sh
```

## 下一步（F-04 族外）

- **F-05**：`std/db`（kv/arrow/sqlite）
- **F-04 续**：`std/crypto` `.inc.c` 分批
- **NL-06 v2**：freestanding hosted 双路径文档化（`freestanding_linux.sx` 已存在）
