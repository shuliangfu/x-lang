# 阶段 F-04 v2（std.net tcp_pool 去 C）

> **F-04 v2**：**`tcp_pool.inc.c`** → **`std/net/tcp_pool.sx`**；`mod.sx` import 转发；核心 TCP 仍 net.c。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tcp_pool.sx` | create/acquire/release/drain/destroy + smoke（离线） |
| `mod.sx` | `import("std.net.tcp_pool")`；无 extern net_tcp_pool_* |
| `net.c` | 不再 `#include tcp_pool.inc.c` |
| 删除 | `std/net/tcp_pool.inc.c` |
| 存量 | F-01 total **102**（较 103 减 1） |

## v2 限制

| 项 | 说明 |
|----|------|
| fork 集成烟测 | C 版 `net_tcp_pool_fork_smoke_c` 未迁；离线 smoke 仍 0 通过 |
| ws.inc.c | 仍于 net.c → **F-04 v3** |

## 复现

```bash
SHUX_F04_NET_TCP_POOL_FAIL=1 ./tests/run-f04-std-net-tcp-pool-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=102
```
