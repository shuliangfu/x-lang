# 阶段 F-sync v1（std.sync 去 C）

> **F-sync v1**：删除 **`sync.c`**；模块锚点在 **`sync.sx`**；Mutex/RwLock/Condvar 在 **`sync_os_glue.c`**；锁诊断 v2 见 **`analysis/phase-f-sync-lock-diag-v2.md`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `sync.c`（631 行） | `sync.sx` + `sync_os_glue.c` + `sync_lock_diag_tls_glue.c`（诊断逻辑 v2 在 sync.sx） |
| `sync.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_SYNC_V1_FAIL=1 ./tests/run-f-sync-v1-gate.sh
./tests/run-std-sync-lock-diag-gate.sh
./tests/run-std-sync-rwlock-condvar-gate.sh
```

## 下一项

- **F-sync-lock-diag v2** ✅（诊断逻辑 → sync.sx；TLS → tls glue）
- **F-task v1** ✅ / **F-csv v1** ✅ / **F-json v1**
