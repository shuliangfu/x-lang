# Async 平台矩阵硬标准

> **日期**：2026-07-28
> **状态**：活文档（随三端后端成熟度更新）
> **目的**：为全面异步架构（T\*）的 T5（高性能后端可选）立硬标准，画清 Linux/macOS/Windows/freestanding 各自的 Evented 后端成熟度与验收门禁。
> **关联**：[全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §4.5 · [async-freestanding-符号依赖.md](async-freestanding-符号依赖.md)

---

## 0. 一句话结论

**当前只有 Linux io_uring 是金标主路径**；macOS kqueue 与 Windows IOCP 仅探针/回退，未进主回归套件。T\* 要求三端 Evented 矩阵进 gate，freestanding Linux 子集有硬标准。自举期准备：把 async 门禁加进 `run-all.sh` 主白名单，让三端回归不再靠手动跑。

---

## 1. 三端 Evented 后端现状

### 1.1 Linux io_uring（金标主路径）

| 项 | 状态 |
|----|------|
| 后端实现 | `std/sys/linux_io_uring.x`（liburing 薄封装）+ `std/io/core.x` 调用 |
| 弱桩 | `runtime_asm_io_stubs.from_x.c` 提供 `io_uring_connect/accept/accept_many/connect_many/prefetch_fd` 弱桩 |
| 门禁 | `tests/run-async.sh`（Linux 自动加 `-luring -lpthread`） |
| 成熟度 | ✅ 生产可用（bench + run-async 验证） |
| freestanding | ❌ 依赖 liburing 符号；需直 syscall 替代（见 [async-freestanding-符号依赖.md](async-freestanding-符号依赖.md) §2.2） |
| 验收金标 | **Ubuntu x86_64** |

### 1.2 macOS kqueue（⚠️ 回退）

| 项 | 状态 |
|----|------|
| 后端实现 | `std/io/backend.x` 平台分流指向 sync.x（libc 同步），kqueue 无独立实现 |
| 门禁 | 无独立门禁；run-async.sh 在 macOS 跑但走 sync 路径 |
| 成熟度 | ⚠️ 回退到 sync（无真正 Evented） |
| 阻塞 T\* | T5 要求 macOS 有 Evented 后端；当前缺 |
| 落地路径 | 新增 `std/sys/macos_kqueue.x`（kqueue/kevent 直包装）+ `std/io/evented_macos.x` |

### 1.3 Windows IOCP（探针）

| 项 | 状态 |
|----|------|
| 后端实现 | `std/io/win32.x`（ReadFile/WriteFile，同步） |
| 门禁 | `tests/run-iocp-gate.sh` + `tests/run-iocp-smoke.sh`（独立门禁，未进 run-all.sh） |
| bench | `tests/bench/iocp_pipe_loop.c`（探针） |
| 成熟度 | ⚠️ 探针级，非生产可用 |
| 阻塞 T\* | T5 要求 Windows 有 Evented 后端；当前缺 |
| 落地路径 | 新增 `std/sys/windows_iocp.x`（CreateIoCompletionPort/GetQueuedCompletionStatus 直包装）+ `std/io/evented_windows.x` |

### 1.4 freestanding Linux 子集

| 项 | 状态 |
|----|------|
| 零 libc L2 | ✅ 已绿（NL-07，Linux x86_64 nostdlib 无 UNDEF） |
| async freestanding | ❌ 未对齐（scheduler 依赖 pthread，io_uring 依赖 liburing） |
| 硬标准 | 待 NL-async-1～5 全绿（见 [async-freestanding-符号依赖.md](async-freestanding-符号依赖.md) §3.2） |

---

## 2. 平台矩阵硬标准（T\* 目标态）

| 后端能力 | Linux | macOS | Windows | freestanding Linux |
|----------|-------|-------|---------|---------------------|
| 阻塞 Threaded Io | ✅ | ✅ | ✅ | ⚠️ 需 syscall 面 |
| Evented 主路径 | io_uring | kqueue | IOCP | io_uring 子集（直 syscall） |
| multishot / batch | 部分已有 | 回退 | 回退 | 按需 |
| cancel 中止 in-flight Io | ⚠️ 部分 | ❌ | ❌ | ⚠️ |
| 验收金标 | **Ubuntu** | 产品 SHARED | 探针 / 后 G | NL 金标对齐 |
| 门禁进 run-all.sh | ❌ 待加 | ❌ 待加 | ❌ 待加 | ❌ 待加 |

**所有新 Io 代码必须**：
- `PLATFORM:` 注释标注三端行为
- SHARED 改动双端验证（mac + Ubuntu）
- 不得只 mac 绿就宣称产品放行

---

## 3. 自举期准备清单（不破闸门）

### 3.1 P0：门禁进主套件

把以下脚本加进 `tests/run-all.sh` 的 L5 白名单（`run_all_l5_whitelist_case`）：
- `run-async.sh`（async 语法 + scheduler + IO 兼容性 smoke）
- `run-iocp-gate.sh`（Windows IOCP 专项）
- `run-no-libc-gate.sh`（零 libc 门禁）

**注意**：
- `run-io-driver.sh` 已在白名单
- `run-perf-async.sh` / `run-perf-iocp.sh` 是性能基准，不进白名单（避免拖慢 CI）
- `run-iocp-smoke.sh` 与 `run-iocp-gate.sh` 二选一（避免重复）

### 3.2 P1：平台行为文档化

每个 async 原语在 `std/io/` 与 `std/async/` 的注释里加 `PLATFORM:` 标注三端行为差异。

### 3.3 P2：freestanding 硬标准设计

落 NL-async-1～5 验收点（见 [async-freestanding-符号依赖.md](async-freestanding-符号依赖.md) §3.2），不实现，只定标准。

---

## 4. 三端后端落地路径（自举后）

### 4.1 阶段 2（L-inject）优先级

1. **ThreadedIo**（先）：三端同步 syscall，证明"一套业务代码"
2. **EventedIo-Linux**：内部接今日 io_uring 路径
3. **EventedIo-macOS**：新增 kqueue 后端
4. **EventedIo-Windows**：新增 IOCP 后端
5. **TestIo**：录制/回放，门禁友好

### 4.2 阶段 3（L-full）矩阵进 gate

- 三端 Evented 矩阵进 `run-all.sh` 主白名单
- freestanding Evented 子集有硬标准（NL-async-4/5）
- cancel 中止 in-flight Io 统一契约

---

## 5. 风险

| 风险 | 缓解 |
|------|------|
| 三端后端行为分叉 | 同一 Io 接口，后端切换；对照测试同输入同输出 |
| macOS kqueue 落地拖延 | 阶段 2 先 ThreadedIo 三端绿，Evented-macOS 可后置 |
| Windows IOCP 落地拖延 | 探针级可接受；阶段 3 前必须升级 |
| freestanding 硬标准空设 | NL-async-1～5 必须有可执行验收命令，不止文档 |

---

## 6. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：三端 Evented 现状 + T\* 硬标准 + 自举期准备清单 |
