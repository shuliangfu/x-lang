# 阶段 F-sync-lock-diag v2（std.sync 锁诊断逻辑 .x 下沉）

> **F-sync-lock-diag v2**：锁诊断逻辑从 **`sync_lock_diag_glue.c`**（272 行）迁入 **`sync.x`**；**`sync_lock_diag_tls_glue.c`** 仅保留 __thread 持有栈（~80 行）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 诊断逻辑 | `sync_lock_diag_glue.c` | **`sync.x`** |
| TLS 持有栈 | glue 内联 | **`sync_lock_diag_tls_glue.c`** |
| `sync.o` | `ld -r` x + os glue + diag glue | **`ld -r` x + os glue + tls glue** |

## TLS 导出（仅 C 胶层）

- `sync_lock_diag_tls_push_c` / `pop_c` / `has_c` / `max_order_c` / `count_c` / `clear_c`

## sync.x 导出（保留 C 符号名供 sync_os_glue 钩子）

- `sync_lock_diag_before_lock` / `after_lock` / `before_unlock` / `after_unlock`
- `sync_lock_diag_set_enabled_c` / `is_enabled_c` / `mutex_set_id_c` / `last_err_c` / `clear_c` / `snapshot_c` / `smoke_c`
- 全局 `g_sync_lock_diag` 元数据表；快照手动格式化（无 snprintf）

## 门禁

```bash
SHUX_F_SYNC_LOCK_DIAG_V2_FAIL=1 ./tests/run-f-sync-lock-diag-v2-gate.sh
./tests/run-std-sync-lock-diag-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-sync v2** 后续：RwLock/Condvar 逻辑评估（仍留在 sync_os_glue.c）
