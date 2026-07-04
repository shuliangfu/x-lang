# 阶段 F-queue v1（std.queue 去 C）

> **F-queue v1**：删除 **`queue.c`**；模块锚点在 **`queue.x`**；STD-048 并发烟测在 **`queue_glue.c`**；`Queue_i32` API 仍在 **`mod.x`**（纯 .x）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `queue.c`（142 行，仅 C 烟测） | `queue.x` + `queue_glue.c` |
| `queue.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_QUEUE_V1_FAIL=1 ./tests/run-f-queue-v1-gate.sh
./tests/run-std-queue-concurrent-gate.sh
```

## 下一项

- **F-async v1** ✅
