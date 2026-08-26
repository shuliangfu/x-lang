# 阶段 F-queue v1（std.queue 去 C）

> **F-queue v1**：删除 **`queue.c`**；模块锚点在 **`queue.x`**；STD-048 并发烟测在 **`queue_glue.c`**；`Queue_i32` API 仍在 **`mod.x`**（纯 .x）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `queue.c`（142 行，仅 C 烟测） | `queue.x` + `queue_glue.c` |
| `queue.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_QUEUE_V1_FAIL` retired. Delegates STD-048 queue-concurrent hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-queue-v1-gate.sh
./tests/run-std-queue-concurrent-gate.sh
```


## 下一项

- **F-async v1** ✅
