# STD-045：std.sync RwLock/Condvar 最小 API v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）**  
> 关联：既有 `mutex_*`、SAFE-006 TSAN 探针

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-sync-rwlock-condvar.tsv` |
| 3 | `./tests/run-std-sync-rwlock-condvar-gate.sh` |
| 4 | 烟测：`tests/sync/rwlock_condvar.x` |

---

## 2. RwLock API

| API | 说明 |
|-----|------|
| `new_rwlock` / `free_rwlock` | 创建/销毁 |
| `read_lock` / `read_unlock` | 共享读锁 |
| `write_lock` / `write_unlock` | 独占写锁 |

产品短名在 `std/sync/mod.x`；C 实现 `sync_rwlock_*_c`（`runtime_sync_os.from_x.c`）。

| 平台 | 实现 |
|------|------|
| POSIX | `pthread_rwlock_t` |
| Windows | `SRWLOCK` |

---

## 3. Condvar API

| API | 说明 |
|-----|------|
| `new_condvar` / `free_condvar` | 创建/销毁 |
| `wait(cv, mutex)` | **已持有** `mutex` 时调用；唤醒后重新持有 |
| `notify_one` / `notify_all` | 唤醒一个/全部 |

配对 `mutex_*` 句柄（同模块 `sync_mutex_new_c`）。  
化石名 `condvar_wait`／`condvar_signal`／`condvar_broadcast` 已对齐为产品 `wait`／`notify_one`／`notify_all`。

---

## 4. 竞争烟测与 TSAN 正例

| 用例 | 说明 |
|------|------|
| `rwlock_contention_smoke` | 2×500 写锁递增 → counter==1000 |
| `condvar_contention_smoke` | waiter `wait` + signaler `notify_one` |
| `tests/sync/sync_tsan_ok.c` | RwLock 保护共享计数；**TSAN 下 exit 0**（正例） |

门禁在检测到 TSAN 工具链时编译运行 `sync_tsan_ok.c`；无 TSAN 时 `tsan=0`（观测，非硬失败）。

---

## 5. Gate

```bash
./tests/run-std-sync-rwlock-condvar-gate.sh
```

manifest：`tests/baseline/std-sync-rwlock-condvar.tsv`

**Honesty (2026-08-26)**：prefer `xlang_asm`＋`XLANG_LINK_XLANG`；`check` 观测（闸门暂停 2026-08-05）；`rwlock_condvar.x`／`main.x` exit0 硬失败（无 soft SKIP）；TSV／DOC API 锚对齐产品 `new_rwlock`／`wait`／`notify_*`（旧 `rwlock_new`／`condvar_wait`＝portable 假红）；报告 `check=`／`rwlock=`／`condvar=`／`main=`／`tsan=`／`skip=`。

**report** 示例：

```
xlang: [XLANG_STD_SYNC_RWLOCK_CONDVAR] status=ok check=1 rwlock=1 condvar=1 main=1 tsan=0 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | RwLock/Condvar + 竞争烟测 + TSAN 正例 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；API 锚对齐产品短名；`## 5. Gate` |
