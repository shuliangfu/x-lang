# 阶段 F-thread v1（std.thread 去 C）

> **F-thread v1**：删除 **`thread.c`**；模块锚点在 **`thread.x`**；pthread/CreateThread 封装在 **`thread_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `thread.c`（465 行） | `thread.x` + `thread_glue.c` |
| `thread.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_THREAD_V1_FAIL` retired. Delegates STD-043 thread-pool hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-thread-v1-gate.sh
./tests/run-std-thread-pool-gate.sh
```

## 下一项

- **F-async v1** ✅ / **F-cache v1**（`cache.c`）
