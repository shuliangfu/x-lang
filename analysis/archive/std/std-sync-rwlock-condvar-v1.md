# STD-045：std.sync RwLock/Condvar 最小 API v1

> 更新时间：2026-08-28（honesty residual XLANG fallthrough／auto-make →硬绿）· 原稿 2026-06-18  
> 状态：**定版（v1.2）** · Gate honesty residual XLANG fallthrough／auto-make →硬绿  
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

`tests/sync/sync_tsan_ok.c` 文件存在仍 TSV 必有；compile/run **不是**绿信号（观测；拒 `ensure_std_c_o`／auto-make）。

---

## 5. Gate

```bash
./tests/run-std-sync-rwlock-condvar-gate.sh
```

Honesty residual（2026-08-28）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- 显式坏 `XLANG`／缺 native **硬 die**（拒 XLANG fallthrough／soft auto-make／prefer-c／soft SKIP→OK／soft `ensure_std_c_o` 重建／extra CLI `.o`／TSAN ensure／auto-make）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `rwlock_condvar.x` + `main.x` 产品 `-o` **exit 0 硬失败**（硬绿信号＝`run=`）
- Host-C archaeology **仅观测**（现成 `std/sync/sync.o`＋`compiler/runtime_sync_os.o`＋`compiler/runtime_sync_lock_diag_tls.o` only；拒 ensure／auto-make 重建；不传 extra CLI `.o`；TSAN C 文件存在仍 TSV 必有，compile/run 非绿）
- 报告行：`run=`／`obs=`／`skip=`（退役 `check=`／`rwlock=`／`condvar=`／`main=`／`tsan=` 当硬绿）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）
- 保留 `## 5. Gate`
- 关键词：STD-045／new_rwlock／wait／sync_tsan_ok／rwlock_contention_smoke

manifest：`tests/baseline/std-sync-rwlock-condvar.tsv`

```
xlang: [XLANG_STD_SYNC_RWLOCK_CONDVAR] status=ok run=2 obs=0|1|2 skip=0
std-sync-rwlock-condvar gate OK
```

F-sync v1 仍硬委托本闸（须保持 exit 0）。

**Honesty (2026-08-29 residual auto-make)**：leftover `tests/run-sync.sh`（`xlang_compiler_make -q || xlang_compiler_make` + `ensure_std_c_o sync.o` + bootstrap-link wrap）retired. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `tests/sync/main.x` hard；check＝obs；report `run=`／`obs=`／`skip=`。leftover runner report prefix `xlang: [SYNC]`。Keep `## 5. Gate`。

### 5.1 Changelog

- 2026-06-18：v1 RwLock/Condvar + 竞争烟测 + TSAN 正例。
- 2026-08-26：Honesty v1.1（prefer asm；check 观测；API 锚对齐产品短名；`## 5. Gate`；报告 `check=`／`rwlock=`／`condvar=`／`main=`／`tsan=`）。
- 2026-08-28：Honesty residual v1.2（拒 XLANG fallthrough／auto-make／bootstrap-link／ensure 重建／TSAN ensure；报告 `run=`／`obs=`／`skip=`；未啃产品 `std/sync`）。

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | RwLock/Condvar + 竞争烟测 + TSAN 正例 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；API 锚对齐产品短名；`## 5. Gate` |
| v1.2 | 2026-08-28 | Honesty residual：拒 XLANG fallthrough／auto-make／ensure；报告 `run=`／`obs=`／`skip=` |
