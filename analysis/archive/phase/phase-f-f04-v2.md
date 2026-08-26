# 阶段 F-04 v2（std.net tcp_pool 去 C）

> **F-04 v2**：**`tcp_pool.inc.c`** → **`std/net/tcp_pool.x`**；`mod.x` import 转发；核心 TCP 仍 net.c。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `tcp_pool.x` | create/acquire/release/drain/destroy + smoke（离线） |
| `mod.x` | `import("std.net.tcp_pool")`；无 extern net_tcp_pool_* |
| `net.c` | 不再 `#include tcp_pool.inc.c` |
| 删除 | `std/net/tcp_pool.inc.c` |
| 存量 | F-01 total **102**（较 103 减 1） |

## v2 限制

| 项 | 说明 |
|----|------|
| fork 集成烟测 | C 版 `net_tcp_pool_fork_smoke_c` 未迁；离线 smoke 仍 0 通过 |
| ws.inc.c | 仍于 net.c → **F-04 v3** |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory. No soft `die→exit 0`. Soft
`XLANG_F04_NET_TCP_POOL_FAIL` retired. `xlang check` observational
(check gate paused). Report `static=` / `inventory=` / `check=` /
`skip=`. Live authority = `./xbuild` + mk + ensure (Makefile deleted).

```bash
./tests/run-f04-std-net-tcp-pool-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-tcp-pool-gate.sh
```

## 复现

```bash
XLANG_F04_NET_TCP_POOL_FAIL=1 ./tests/run-f04-std-net-tcp-pool-gate.sh
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=102
```
