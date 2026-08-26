# 阶段 F-async v1（std.async 去 C）

> **F-async v1**：删除 **`scheduler.c`** / **`future.c`**；锚点 **`scheduler.x`** / **`future.x`**；调度与 Future 胶层在 **`scheduler_glue.c`** / **`future_glue.c`**；`async_net_fs.inc.c` 仍由胶层 `#include`。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 调度 | `scheduler.c`（~1000 行） | `scheduler.x` + `scheduler_glue.c` |
| Future | `future.c`（~162 行） | `future.x` + `future_glue.c` |
| `scheduler.o` / `future.o` | `cc -c` | 各自 `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_ASYNC_V1_FAIL` retired. Delegates STD-004 async-api hard. future／io-cps／context／language observational (product UNDEF residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-async-v1-gate.sh
./tests/run-std-async-api-gate.sh
```

## 下一项

- **F-cache v1** ✅ / **F-config v1**（`config.c`）
