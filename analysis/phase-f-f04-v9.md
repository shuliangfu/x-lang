# 阶段 F-04 v9（std.net mbedTLS TLS 去 C）

> **F-04 v9**：**`tls_mbedtls.inc.c`** → **`tls_mbedtls.sx`** + 最小 **`tls_mbedtls_bio.c`**（BIO fn ptr 胶层）。

## v9 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tls_mbedtls.sx` | mbedTLS 客户端/服务端握手、读写、ALPN、烟测、marker |
| `tls_mbedtls_bio.c` | `shu_mbedtls_ssl_bind_fd_c`（set_bio send/recv，~50 行） |
| `net.c` | 移除 `SHUX_NET_USE_MBEDTLS` + `tls_mbedtls.inc.c` |
| `Makefile` | `net-o-mbedtls`：`ld -r` 合并 `tls_mbedtls_main.o` + `tls_mbedtls_bio.o` |
| `runtime_link_abi.c` | 识别/链入 `std/net/tls_mbedtls.o` |
| 删除 | `std/net/tls_mbedtls.inc.c` |
| 存量 | F-01 total **96**（删 inc.c、增 bio.c 对抵） |

## v9 限制（v10+）

| 项 | 说明 |
|----|------|
| `tls_mbedtls_bio.c` | .sx 暂不支持 fn ptr 取址；待语言支持后并入 `.sx` |
| `mod.sx` | 仍 `import("std.net.tls_stub")`；TLS 符号在独立 `.o` |
| Windows | BIO / 烟测依赖 Unix socket 路径 |
| struct 尺寸 | ssl/conf/x509/pk 字节数组按 Homebrew mbedtls 4.x + margin |

## 复现

```bash
SHUX_F04_NET_TLS_MBEDTLS_FAIL=1 ./tests/run-f04-std-net-tls-mbedtls-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=96
./tests/run-std-net-tls-gate.sh
```
