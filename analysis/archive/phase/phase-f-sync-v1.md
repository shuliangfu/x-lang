# 阶段 F-sync v1（std.sync 去 C）

> **F-sync v1**：删除 **`sync.c`**；模块锚点在 **`sync.x`**；Mutex/RwLock/Condvar 在 **`sync_os_glue.c`**；锁诊断 v2 见 **`analysis/phase-f-sync-lock-diag-v2.md`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `sync.c`（631 行） | `sync.x` + `sync_os_glue.c` + `sync_lock_diag_tls_glue.c`（诊断逻辑 v2 在 sync.x） |
| `sync.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SYNC_V1_FAIL` retired. Delegates STD-sync lock-diag + rwlock-condvar + lock-diag-v2 hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-sync-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-sync-lock-diag／std-sync-rwlock-condvar／f-sync-lock-diag-v2 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-sync-v1-gate.sh
./tests/run-std-sync-lock-diag-gate.sh
./tests/run-std-sync-rwlock-condvar-gate.sh
./tests/run-f-sync-lock-diag-v2-gate.sh
```


## 下一项

- **F-sync-lock-diag v2** ✅（诊断逻辑 → sync.x；TLS → tls glue）
- **F-task v1** ✅ / **F-csv v1** ✅ / **F-json v1**
