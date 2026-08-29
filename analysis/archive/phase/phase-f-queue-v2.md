# 阶段 F-queue v2（std.queue 竞争烟测 .x 下沉）

> **F-queue v2 / F-ZC**：STD-048 双线程 push 烟测在 **`queue.x`**；**`queue_contention_os_glue.c` 已删除**；pthread 在 **`runtime_queue_contention.c`**（compiler runtime）。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| 烟测逻辑 | `queue_glue.c` | **`queue.x`** |
| OS 线程/mutex | glue 内联 | **`runtime_queue_contention.c`** |
| `queue.o` | `ld -r` x + glue | **纯 `.x`** |

## 符号

- `queue_os_mutex_*_c` / `queue_os_run_two_workers_c` — compiler runtime seed
- `queue_contention_worker_push_c` / `sync_queue_contention_smoke_c` — `runtime_queue_contention` (F-ZC; not `queue.x`)
- `queue_f_queue_v2_marker_c` — `queue.x`

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_QUEUE_V2_FAIL` retired. Delegates STD-048 queue-concurrent hard (sync/c observational inside STD).

**2026-08-30 leftover XLANG fallthrough 已收**（f-queue-v2：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-queue-concurrent 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-queue-v2-gate.sh
./tests/run-std-queue-concurrent-gate.sh
```

## 下一项

- **Z8** 其它 OS 胶层（`log_os_glue.c`、`log_os_glue.c` 等）
