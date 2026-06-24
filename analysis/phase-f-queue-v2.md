# 阶段 F-queue v2（std.queue 竞争烟测 .sx 下沉）

> **F-queue v2 / F-ZC**：STD-048 双线程 push 烟测在 **`queue.sx`**；**`queue_contention_os_glue.c` 已删除**；pthread 在 **`runtime_queue_contention.c`**（compiler runtime）。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| 烟测逻辑 | `queue_glue.c` | **`queue.sx`** |
| OS 线程/mutex | glue 内联 | **`runtime_queue_contention.c`** |
| `queue.o` | `ld -r` sx + glue | **纯 `.sx`** |

## 符号

- `queue_os_mutex_*_c` / `queue_os_run_two_workers_c` — compiler runtime
- `queue_contention_worker_push_c` / `sync_queue_contention_smoke_c` — `queue.sx`

## 门禁

```bash
SHUX_F_QUEUE_V2_FAIL=1 ./tests/run-f-queue-v2-gate.sh
./tests/run-std-queue-concurrent-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **Z8** 其它 OS 胶层（`log_os_glue.c`、`log_os_glue.c` 等）
