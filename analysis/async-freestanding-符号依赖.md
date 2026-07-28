# Async freestanding 符号依赖清单

> **日期**：2026-07-28
> **状态**：活文档（随 seed/scheduler 迁移更新）
> **目的**：为自举后全面异步架构（T\*）的 freestanding 后端做准备，画清 async 原语当前依赖哪些 libc/pthread/liburing 符号，以便零 libc 路径与 async 全链路对齐。
> **关联**：[零libc产品策略.md](零libc产品策略.md) · [全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §6.1 P1

---

## 0. 一句话结论

**async 全链路 freestanding 当前未与零 libc L2 金标对齐**。零 libc L2 已绿 Linux x86_64（NL-07），但绕开了 async 路径；async scheduler 强依赖 pthread，IO 异步路径依赖 liburing。要达到 T\* 的"freestanding Evented 子集有硬标准"，必须把 pthread 替换为 syscall 直包装（futex/wake 单源），把 liburing 替换为 syscall 直包装 io_uring_setup/submit/enter。

---

## 1. 依赖分类总表

| 类别 | 当前依赖 | 零 libc 替代方案 | 阻塞 T\* 哪条 |
|------|----------|------------------|---------------|
| **pthread 同步** | `pthread_mutex_t` / `pthread_cond_t` / `pthread_create` / `pthread_mutex_lock/unlock` / `pthread_cond_wait/signal` | Linux: futex syscall + 自旋回退；macOS: ulock/futex2；Windows: WaitForSingleObjectEx + InitializeCriticalSection | T5 freestanding |
| **pthread 线程** | `pthread_create` / `pthread_self` / `pthread_join` / `pthread_detach` | Linux: clone syscall；macOS: pthread_workqueue_asm（绕开 libc）；Windows: CreateThread | T5 freestanding |
| **libc 内存** | `malloc` / `realloc` / `free`（scheduler 队列节点） | 已有 mmap-based 堆（NL-07 验证）；scheduler 须切到该堆 | T5 freestanding |
| **libc 时间** | `clock_gettime` / `time`（scheduler deadline） | Linux: `clock_gettime` vDSO 直调用（不依赖 libc 符号）；macOS: mach_absolute_time；Windows: QueryPerformanceCounter | T5 freestanding |
| **liburing** | `io_uring_setup` / `io_uring_submit` / `io_uring_enter` / `io_uring_register` | Linux: 直 syscall（`__NR_io_uring_setup` 等）；非 Linux 不适用 | T5 Linux freestanding |
| **libc IO** | `read` / `write` / `readv` / `writev` / `poll`（sync backend） | Linux: 直 syscall；macOS: 直 syscall；Windows: ReadFile/WriteFile | T5 ThreadedIo |
| **libc 网络** | `socket` / `connect` / `accept` / `bind` / `listen` | 直 syscall（已部分落地于 `std/sys/*`） | T5 ThreadedIo |

---

## 2. 按模块详细依赖

### 2.1 `runtime_scheduler_glue`（调度核心）

**文件**：`compiler/seeds/runtime_scheduler_glue.from_x.c`

**当前 include**：
```c
#include <stdio.h>      // fputs 调试输出（Cap residual: driver_preamble_fputs）
#include <stdlib.h>     // malloc/free（队列节点）
#include <string.h>     // memcpy/memset
#include <stdatomic.h>  // 原子操作（C11 stdatomic）
#include <time.h>       // clock_gettime（deadline）
#include <stddef.h>
#include <stdint.h>
```

**pthread 依赖位置**：scheduler 业务体（task queue / worker pool / io wait）在更深的 C 实现里，通过 `g_pool_mu` / `g_pool_not_empty` / `g_pool_idle` 三个全局同步原语串起 worker pool。具体符号：
- `pthread_mutex_t g_pool_mu` — 保护 task queue
- `pthread_cond_t g_pool_not_empty` — worker 等待任务
- `pthread_cond_t g_pool_idle` — 等待所有 worker idle
- `pthread_create` — 启动 worker 线程
- `pthread_mutex_lock` / `pthread_mutex_unlock`
- `pthread_cond_wait` / `pthread_cond_signal` / `pthread_cond_broadcast`

**零 libc 替代路径**：
1. **futex 直包装**（Linux）：`syscall(__NR_futex, &u32, FUTEX_WAIT/FUTEX_WAKE, ...)`，已有 `std/sys/linux_futex.x` 落地点（若没有则需新增）
2. **clone 直包装**（Linux）：`syscall(__NR_clone, CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD, ...)` + 栈分配
3. **atomic 不依赖**：C11 stdatomic 可用（clang/gcc 内建，不依赖 libc 符号）

**未对齐项**：scheduler_glue 仍是 thin+rest 重度 C（wave554 进行中），rest C 体未清零。R2 完成前，freestanding 路径无法验证。

### 2.2 `runtime_asm_io_stubs`（IO 弱桩）

**文件**：`compiler/seeds/runtime_asm_io_stubs.from_x.c`

**io_uring 弱桩**（XLANG_WEAK）：
- `io_uring_connect(addr_u32, port_u32, timeout_ms)`
- `io_uring_accept(listener_fd, timeout_ms)`
- `io_uring_accept_many(listener_fd, out_fds, n, timeout_ms)`
- `io_uring_connect_many(addr_u32, port_u32, out_fds, n, ...)`
- `io_uring_prefetch_fd(fd)`

**说明**：弱桩满足 `net.o` 合并后的 U 符号；真正的 io_uring 实现在 `std/sys/linux_io_uring.x` + liburing 链接（Linux only）。

**liburing 依赖符号**（来自 `std/sys/linux_io_uring.x` 与 `tests/run-async.sh` `-luring`）：
- `io_uring_setup`
- `io_uring_submit`
- `io_uring_enter`
- `io_uring_register`

**零 libc 替代路径**：liburing 本身是 libc 之上的薄封装，可直接用 syscall 替代：
- `__NR_io_uring_setup` (425)
- `__NR_io_uring_enter` (426)
- `__NR_io_uring_register` (427)

**未对齐项**：当前 `std/sys/linux_io_uring.x` 走 liburing 符号，未直 syscall。freestanding 路径须新增 `std/sys/linux_io_uring_syscall.x`（或等价），用 `syscall()` 直包装三个 io_uring syscall。

### 2.3 `std/io/sync.x`（同步 IO backend）

**依赖**：`read` / `write` / `readv` / `writev` / `poll`（libc 符号）

**零 libc 替代路径**：直 syscall（Linux `__NR_read/write/readv/writev/poll`；macOS `syscall(SYS_read, ...)`；Windows ReadFile/WriteFile）

**未对齐项**：当前 sync.x 走 libc 符号。ThreadedIo 后端要进 freestanding，必须先有 syscall 直包装层（部分已在 `std/sys/*` 落地）。

### 2.4 `std/async/future.x`（Future 槽）

**依赖**：仅 `xlang_io_poll_async_completions` 与 `xlang_async_run_drain_until_idle`（C ABI），无直接 libc 依赖。

**状态**：✅ freestanding 友好（依赖的 C ABI 在 scheduler 侧解决后即可）。

### 2.5 `std/task/task.x` 与 `std/context/context.x`

**依赖**：通过 `xlang_async_task_submit` / `xlang_async_run_drain_until_idle` / `ctx_cancel_c` 等 C ABI，无直接 libc 依赖。

**状态**：✅ freestanding 友好。

---

## 3. 零 libc async 验收路径

### 3.1 当前可验收（NL-07 已绿）

- 用户 `.x` 出 nostdlib 静态可执行（L1）
- 编译器/bootstrap 零 libc（L2，Linux x86_64）—— **绕开 async**

### 3.2 待验收（async freestanding 硬标准）

| 阶段 | 验收点 | 依赖 |
|------|--------|------|
| NL-async-1 | scheduler 不链 pthread（futex + clone 直包装） | scheduler_glue R2 + futex/clone 直包装层 |
| NL-async-2 | io_uring 不链 liburing（直 syscall） | `std/sys/linux_io_uring_syscall.x` 落地 |
| NL-async-3 | sync IO 不链 libc read/write（直 syscall） | `std/sys/linux_syscall.x` 扩展 |
| NL-async-4 | `run-async.sh` 在 nostdlib 静态可执行下绿 | NL-async-1/2/3 全绿 |
| NL-async-5 | `run-no-libc-gate.sh` 扩展 async 用例 | NL-async-4 绿 |

### 3.3 触发条件

- scheduler_glue 完成 R2（rest C 清零）后，立即可做 NL-async-1
- 自举金标（Stage2 纯 .x + 零 seed）后，NL-async-1～5 可并行推进

---

## 4. 风险与纪律

| 风险 | 缓解 |
|------|------|
| pthread 替换引入新双权威 | 单一权威：futex/clone 直包装只落 `std/sys/`，scheduler 通过 C ABI 调用 |
| io_uring 直 syscall 与 liburing 行为分叉 | 同一 .x 接口，后端切换；保留 liburing 后端作 fallback |
| freestanding 验收漏跑 | NL-async-4/5 进 `run-no-libc-gate.sh`，进 run-all.sh 主白名单 |
| scheduler R2 拖延阻塞 NL-async | scheduler_glue R2 是主线 R 的一部分，不另开 async 重构项目 |

---

## 5. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：汇总 scheduler/io_stubs/sync/future/task/context 的 libc/pthread/liburing 依赖与零 libc 替代路径 |
