# Io/Executor trait 接口 RFC

> **日期**：2026-07-28
> **状态**：设计草案（不实现，自举后落地）
> **目的**：为全面异步架构（T\*）的 T2（可注入执行模型）定接口形状，消除当前"执行模型绑死 scheduler_glue"的根因。
> **关联**：[全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §4.1–4.3 · [async-language-debt.md](async-language-debt.md) L-trait · [async-future-generic-RFC.md](async-future-generic-RFC.md)

---

## 0. 一句话结论

当前执行模型绑死 `runtime_scheduler_glue`（C seed），无可注入 `Io`/`Executor` 抽象，是 T\* 的根因阻塞（G-io-inject）。本 RFC 定 `Io` / `Executor` trait 接口形状、三后端（ThreadedIo / EventedIo / TestIo）职责、迁移路径。自举期落空接口骨架（不改链接默认），自举后阶段 2 落地实现。

---

## 1. 现状

### 1.1 当前执行模型

```
用户 .x (async function / await / run / spawn)
    ↓
compiler async_cps_codegen → CPS 帧 + switch 状态机
    ↓
runtime_scheduler_glue (C seed, thin+rest)
    ├── task queue (pthread_mutex 保护)
    ├── worker pool (pthread_create)
    ├── io wait/wake (io_uring / sync)
    └── Future 槽 (i32×64 静态)
    ↓
std.io.backend (平台分流: sync.x / win32.x)
```

### 1.2 问题

| 问题 | 根因 |
|------|------|
| 执行模型绑死 scheduler_glue | 无 Io/Executor 抽象层 |
| 同步/异步双 API | sync `read`/`write` vs async `submit_*_async` |
| 无法测试隔离 | 无 TestIo，必须真实 io_uring/scheduler |
| 无法换后端 | 用户代码直接调 `xlang_async_*` C ABI |

---

## 2. 目标态：Io / Executor trait

### 2.1 分层

```
L4 用户业务 / 库 API
    └─ 一套 read/write/connect；可选显式 await
L3 能力面 Io / Executor（可注入）
    ├─ Io: read / write / sleep / poll / cancel
    └─ Executor: spawn / block_on / yield_now
    后端：ThreadedIo | EventedIo | TestIo
L2 运行时内核
    └─ 就绪队列 / worker / 完成队列 / Context 绑定
       （演化自 scheduler_glue + io backend）
L1 编译器支持（可选加速）
    └─ CPS 变换 / 栈切 / 帧布局 / liveness
```

### 2.2 Io trait 接口形状（依赖 L-trait）

```xlang
// std/io/io_trait.x（自举期空骨架，自举后实现）

/// Io — 可注入的 I/O 能力面。
/// 后端：ThreadedIo（同步阻塞）/ EventedIo（io_uring/kqueue/IOCP）/ TestIo（录制回放）。
/// PLATFORM: SHARED — 三端后端必须实现此 trait。
export trait Io {
  /// 读字节到 buf，返回读取字节数（≤0 为错误/超时）。
  /// cancel: ctx cancel 时返回 IO_CTX_MS_CANCELLED。
  function read(self, handle: usize, buf: *u8, len: usize, timeout_ms: u32): i32;

  /// 从 buf 写字节，返回写入字节数（≤0 为错误/超时）。
  function write(self, handle: usize, buf: *u8, len: usize, timeout_ms: u32): i32;

  /// 提交异步读，返回 Future<i32>（依赖 L-generic）。
  /// ThreadedIo: 内部同步读后 complete future。
  /// EventedIo: 提交到 io_uring/kqueue/IOCP，complete 在事件循环。
  function read_async(self, handle: usize, buf: *u8, len: usize): i64;

  /// 提交异步写，返回 Future<i32>。
  function write_async(self, handle: usize, buf: *u8, len: usize): i64;

  /// 轮询完成事件，返回完成数。
  function poll_completions(self, timeout_ms: u32): u32;

  /// 中止 in-flight Io 操作（cancel 契约）。
  function cancel(self, handle: usize): i32;

  /// sleep 当前执行流（ThreadedIo: 阻塞；EventedIo: 挂起帧；TestIo: 立即返回）。
  function sleep(self, ns: u64): i32;
}
```

### 2.3 Executor trait 接口形状

```xlang
// std/async/executor_trait.x（自举期空骨架，自举后实现）

/// Executor — 可注入的任务执行能力面。
/// 后端：当前 scheduler_glue（C）/ 未来 pure .x scheduler / TestExecutor（单线程同步）。
/// PLATFORM: SHARED — 执行器必须实现此 trait。
export trait Executor {
  /// 提交任务，返回 Future<T>（依赖 L-generic）。
  /// 当前: 走 xlang_async_task_submit C ABI。
  function spawn<T>(self, fn: fn(T) -> U, arg: T): i64;

  /// 阻塞当前线程直到 future 就绪（ThreadedIo: 阻塞；EventedIo: 跑事件循环）。
  function block_on<T>(self, future: i64): i32;

  /// 让出当前执行流（协作式调度）。
  function yield_now(self): i32;

  /// 当前任务数（用于 shutdown 等待）。
  fn task_count(self): i32;
}
```

### 2.4 三后端职责

| 后端 | Io 实现 | Executor 实现 | 用途 |
|------|---------|---------------|------|
| **ThreadedIo** | 同步 syscall（read/write/poll） | 线程池 + 阻塞 | 简单场景；证明"一套业务代码" |
| **EventedIo** | io_uring / kqueue / IOCP | scheduler_glue + 事件循环 | 高性能；生产主路径 |
| **TestIo** | 录制/回放 | 单线程同步 | 测试隔离；门禁友好 |

### 2.5 与现有 CPS / async 关键字的关系

| 阶段 | CPS 角色 | async 关键字 |
|------|----------|-------------|
| 现在 | 主路径 | 染色（含 await 必须 async） |
| L-inject | Evented 后端内部用 | 仍染色，但用户可调 ThreadedIo 不写 async |
| L-full | 优化路径 | 可选糖；用户不必写 async |

**关键纪律**：Io 后端实现可以内部染色；**用户可见类型世界不染色**。

---

## 3. 迁移路径

### 3.1 阶段 0（自举期，不破闸门）

- 落本 RFC（接口形状）
- 落 `Io` / `Executor` trait 空接口骨架（`std/io/io_trait.x` / `std/async/executor_trait.x`）
  - **不改链接默认**：只加 trait 定义，不强制后端实现
  - **不删现有 C ABI**：`xlang_async_*` / `xlang_io_*` 保留
- 文档：扩展点标注（`std.io`：Reader 为字节流适配，Io 为后端能力）

### 3.2 阶段 1（自举收尾期，L-usable）

- name-gate → typeck 标志位（见 [async-name-gate-typeck-migration.md](async-name-gate-typeck-migration.md)）
- scheduler 继续 thin .x 化（跟 R2 节奏）
- 不实现 Io/Executor 后端

### 3.3 阶段 2（L-inject）

1. 定稿 Io / Executor 接口（依赖 L-trait）
2. 实现 **ThreadedIo**（先）：同步 syscall，证明"一套业务代码"
3. 实现 **EventedIo**：内部接 scheduler_glue + io_uring
4. 实现 **TestIo**：录制/回放
5. 选 1～2 个 std 模块（`std.io` 核心 + `std.net` 一点）做双路径：
   - 旧 API 转调 `default_io()`
   - 新 API 显式 `io` 参数
6. 迁移纪律：一条债一个 commit；Ubuntu L4 + async 门禁 + 产品矩阵

### 3.4 阶段 3（L-full）

- 新库默认只暴露 Io 参数 API
- 旧 `async fn` 语法保留为可选糖
- 删除/收敛 `*_async` 用户面双名（内部符号可留）

---

## 4. 与现有模块的关系

| 现有模块 | T\* 角色 | 迁移动作 |
|----------|----------|----------|
| `std/io/mod.x` Reader/Writer | 字节流适配 | 保留；Io 为后端能力 |
| `std/io/driver.x` | 旧 Io 后端 | 转为 EventedIo 内部实现 |
| `std/io/sync.x` | 旧 sync 后端 | 转为 ThreadedIo 内部实现 |
| `std/async/mod.x` | 用户门面 | re-export Io/Executor |
| `std/async/scheduler.x` | 占位 marker | 转为 EventedIo 内部 |
| `std/async/future.x` | i32×64 静态 | 升级为 Future<T>（见 [async-future-generic-RFC.md](async-future-generic-RFC.md)） |
| `std/task/task.x` | TaskGroup | 与 Executor.spawn 默认合一 |
| `std/context/context.x` | cancel/deadline | 与 Io.cancel 统一契约 |
| `runtime_scheduler_glue` | 调度核心 | R2 后收敛为 Executor 内部 |
| `runtime_link_abi` | 按需链 | 新增 Io/Executor 符号时只改权威表 |

---

## 5. 禁止项

- ❌ 自举期实现 Io/Executor 后端（破闸门）
- ❌ 新建 `std.async2` / `std.runtime_v2`（G.7 双权威）
- ❌ 改 `xlang_async_*` C ABI（产品链依赖）
- ❌ 强制用户改用 Io 参数（阶段 3 才动用户面）
- ❌ 只 mac 验 Evented 当 Linux 金标（G.8）

---

## 6. 风险

| 风险 | 缓解 |
|------|------|
| trait 语言债拖延 | 与 lang-trait 主线对齐 |
| Io 接口设计过度 | 最小方法集（read/write/sleep/poll/cancel）；其余组合子在库层 |
| ThreadedIo 与 EventedIo 行为分叉 | 对照测试同输入同输出 |
| 旧 C ABI 与新 trait 共存期双权威 | 共存期旧 ABI 转调 trait，不保留独立实现 |

---

## 7. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：Io/Executor trait 接口形状、三后端职责、迁移路径、与现有模块关系 |
