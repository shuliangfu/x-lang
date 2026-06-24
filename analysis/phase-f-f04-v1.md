# 阶段 F-04 v1（std.net TLS stub 去 C）

> **F-04 v1**：**`tls_stub.inc.c`** → **`std/net/tls_stub.sx`**；`mod.sx` import 桩后端；OpenSSL/mbedTLS 仍留 `tls_*.inc.c`（v2+）。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tls_stub.sx` | 全部 `net_tls_*_c` 桩 + `net_tls_last_error_c` |
| `mod.sx` | `import("std.net.tls_stub")`；公开 API 经 `tls_plat` 转发 |
| `net.c` | 默认路径不再 `#include tls_stub.inc.c` |
| 删除 | `std/net/tls_stub.inc.c` |
| 存量 | F-01 total **103**（较 104 减 1） |

## v1 限制

| 项 | 说明 |
|----|------|
| OpenSSL/mbedTLS | 仍由 `net-o-openssl` / `net-o-mbedtls` 链 `tls_*.inc.c` |
| runtime auto TLS | `tls_runtime_link_smoke.sx` 在 mod 固定 import stub 时 **暂不绿** → F-04 v2 |
| ws.inc.c | 仍于 net.c；链接时解析 `net_tls_*_c` 自 tls_stub.sx 或 openssl net.o |

## 复现

```bash
SHUX_F04_NET_TLS_STUB_FAIL=1 ./tests/run-f04-std-net-tls-stub-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=103
./tests/run-std-net-tls-gate.sh
```
