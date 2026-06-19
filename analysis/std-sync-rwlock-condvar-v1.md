# STD-045：std.sync RwLock/Condvar 最小 API v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：既有 `mutex_*`、SAFE-006 TSAN 探针

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-sync-rwlock-condvar.tsv` |
| 3 | `./tests/run-std-sync-rwlock-condvar-gate.sh` |
| 4 | 烟测：`tests/sync/rwlock_condvar.sx` |

---

## 2. RwLock API

| API | 说明 |
|-----|------|
| `rwlock_new` / `rwlock_free` | 创建/销毁 |
| `rwlock_read_lock` / `rwlock_read_unlock` | 共享读锁 |
| `rwlock_write_lock` / `rwlock_write_unlock` | 独占写锁 |
| `rwlock_try_read_lock` / `rwlock_try_write_lock` | 非阻塞；0 成功，1 忙 |

| 平台 | 实现 |
|------|------|
| POSIX | `pthread_rwlock_t` |
| Windows | `SRWLOCK` |

---

## 3. Condvar API

| API | 说明 |
|-----|------|
| `condvar_new` / `condvar_free` | 创建/销毁 |
| `condvar_wait(cv, mutex)` | **已持有** `mutex` 时调用；唤醒后重新持有 |
| `condvar_signal` / `condvar_broadcast` | 唤醒一个/全部 |

配对 `mutex_*` 句柄（同模块 `sync_mutex_new_c`）。

---

## 4. 竞争烟测与 TSAN 正例

| 用例 | 说明 |
|------|------|
| `rwlock_contention_smoke` | 2×500 写锁递增 → counter==1000 |
| `condvar_contention_smoke` | waiter `condvar_wait` + signaler `condvar_signal` |
| `tests/sync/sync_tsan_ok.c` | RwLock 保护共享计数；**TSAN 下 exit 0**（正例） |

门禁在检测到 TSAN 工具链时编译运行 `sync_tsan_ok.c`；无 TSAN 时 `tsan=skip`。

---

## 5. 门禁

```bash
./tests/run-std-sync-rwlock-condvar-gate.sh
```

```
shux: [SHUX_STD_SYNC_RWLOCK_CONDVAR] status=ok rwlock=1 condvar=1 main=1 tsan=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | RwLock/Condvar + 竞争烟测 + TSAN 正例 |
