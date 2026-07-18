# 阶段 F-04 v8（std.net OpenSSL TLS 去 C）

> **F-04 v8**：**`tls_openssl.inc.c`** → **`tls_openssl.x`**（libssl/libcrypto FFI）；net.c 不再 `#include` OpenSSL inc。

## v8 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tls_openssl.x` | OpenSSL 客户端/服务端握手、读写、ALPN、烟测、marker |
| `net.c` | 移除 `SHUX_NET_USE_OPENSSL` + `tls_openssl.inc.c` |
| `Makefile` | `net-o-openssl` 编译 `tls_openssl.x` + `net-o-stub` |
| `runtime_link_abi.c` | `invoke_cc_append_net_tls_ld` 识别 `std/net/tls_openssl.o` |
| 删除 | `std/net/tls_openssl.inc.c` |
| 存量 | F-01 total **96**（较 97 减 1） |

## v8 限制（v9+）

| 项 | 说明 |
|----|------|
| `mod.x` | 仍 `import("std.net.tls_stub")`；OpenSSL 链 tls_openssl.o 与 stub 符号分离（v9 统一 extern） |
| 服务端 ALPN | v8 未移植 `SSL_CTX_set_alpn_select_cb`（C 回调） |
| `tls_mbedtls.inc.c` | 已删；v9 迁 `.x` + `tls_mbedtls_bio.c` |
| Windows | OpenSSL 烟测依赖 `net_tcp_connect_blocking_c`（Unix 路径） |

## 复现

```bash
SHUX_F04_NET_TLS_OPENSSL_FAIL=1 ./tests/run-f04-std-net-tls-openssl-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=96
./tests/run-std-net-tls-gate.sh
```
