# STD-026 std.io 非 Linux io_uring 回退统一文档 v1

> 更新时间：2026-08-26（v1.1 honesty）· 定版正文 2026-06-18  
> 状态：**定版（v1）+ Gate honesty**  
> 关联：`analysis/自举进度.md`／`C迁移追踪.md` STD-026、`std/io/backend.x`、`STD-042` async IO  
> **live DOC** = 本归档路径；禁止顶层 `analysis/std-io-fallback-v1.md` 复活  
> **产品权威**：`std/io/backend.x`（replaces io.c + io.o）+ `sync.x`（POSIX）+ `win32.x`（Windows）；**`io.c` 已退役**

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-026 | 统一描述 Linux io_uring 与 **macOS / Windows** read/write 回退路径 |

实现锚点：`std/io/backend.x` 按 `target_os` 选 `std.io.sync`／`std.io.win32`；探测面 `xlang_io_uring_is_available_c`；批量／等待走 `io_libc_readv`／`io_libc_poll`；Windows 走 `ReadFile`／`WSAStartup`。

---

## 2. 分层模型

```
std.io API（read_fd / read_batch_fd / read_async …）
        ↓
std.io.driver → std.io.core → std.io.backend
        ↓
┌─────────────┬──────────────────┬─────────────────────┐
│ Linux       │ macOS            │ Windows             │
│ sync.x      │ sync.x           │ win32.x             │
│ io_uring*   │ readv + poll     │ ReadFile + WSA      │
│ ↓ fallback  │ ↓ fallback       │ ↓ fallback          │
│ read/write  │ read/write       │ ReadFile 同步       │
└─────────────┴──────────────────┴─────────────────────┘
* io_uring 探测：stubs／backend `xlang_io_uring_is_available_c`；不可用时同 POSIX 回退。
```

**铁律**：非 Linux **无** io_uring 主路径；`register_provided_buffers` / `read_provided_fd` 仅 Linux 5.19+；macOS/Windows 须回退 `read_fixed_fd` 或 `read_batch_fd`。

---

## 3. 三平台 read/write 矩阵

| API（backend／mod.x） | Linux 主路径 | Linux 回退 | macOS 主路径 | macOS 回退 | Windows 主路径 | Windows 回退 |
|----------------------|-------------|-----------|-------------|-----------|---------------|-------------|
| `io_read` / `read_fd` | sync `io_read`（io_uring 探测） | POSIX `read` | sync `io_read`（kqueue 历史路径） | POSIX `read` | win32 `ReadFile` | 同步 `ReadFile` |
| `io_write` / `write_fd` | sync `io_write` | POSIX `write` | sync `io_write` | POSIX `write` | win32 `WriteFile` | 同步写 |
| `io_read_batch` / `read_batch_fd` | `io_libc_readv`／逐段 | 逐段 `io_read` | `io_libc_readv`（readv） | 逐段 `io_read` | win32 `io_read_batch` | 逐段 `io_read` |
| `io_write_batch` / `write_batch_fd` | writev／逐段 | 逐段 `io_write` | writev／逐段 | 逐段 `io_write` | win32 `io_write_batch` | 逐段 `io_write` |
| `io_read_fixed` / `read_fixed_fd` | sync fixed → `io_read` | `io_read` | sync fixed → `io_read` | — | win32 fixed → `io_read` | — |
| `io_write_fixed` / `write_fixed_fd` | sync fixed → `io_write` | `io_write` | sync fixed → `io_write` | — | win32 fixed → `io_write` | — |
| `register_provided_buffers` | Linux provided（IORING） | 失败返回 0 | **不支持**（回退 read_fixed_fd） | — | **不支持** | — |
| `read_async` / `complete_read_async_slot` | submit／complete stubs | — | complete **同步** `io_read` | — | complete **同步** `io_read` | — |
| `io_read_ptr` | TLS／mmap 视图 | TLS `g_io_read_ptr_buf` | TLS（dispatch 历史） | TLS 缓冲 | TLS 缓冲 | TLS 缓冲 |
| `io_wait_readable` | `io_libc_poll` | — | poll／kqueue 历史 | — | WSA／select 历史 | — |

### 3.1 macOS 特例

- **标准流**（fd 0/1/2）：跳过 kqueue，直接 `FALLBACK_READ` / `FALLBACK_WRITE`。
- **批量读**：`timeout_ms=0` 且 n≥2 时走 `readv`；`EAGAIN` 时 `poll` 重试（`io_readv_all`）。
- **零拷贝读**：常规文件优先 `io_read_ptr_try_dispatch_data`；否则 TLS 单缓冲。

### 3.2 Windows 特例

- **IOCP**：全局 `g_iocp` + 每线程 `OVERLAPPED` 池（`IO_BATCH_MAX_WIN=8`）。
- **`FILE_SKIP_COMPLETION_PORT_ON_SUCCESS`**：已缓存 handle 跳过同步完成端口通知。
- **批量**：`GetQueuedCompletionStatusEx` 收割多 overlapped。

### 3.3 Linux 回退触发

- `io_uring_queue_init` 失败 → 全程 `FALLBACK_*`。
- `/proc/sys/kernel/io_uring_disabled` 非 0 → 关闭 SQPOLL / Provided Buffers。
- 管理员禁用或 ring 不可用：与 macOS/Windows 一样落到 POSIX `read`/`write`。

---

## 4. 用户选型（Cookbook）

| 场景 | Linux | macOS / Windows |
|------|-------|-----------------|
| 热路径 fd 读写 | `read_fd` / `write_fd` | 同左（自动 kqueue/IOCP） |
| 多段一次 syscall | `read_batch_fd` | `read_batch_fd`（readv/IOCP） |
| 预注册缓冲 | `register_fixed_buffers` + `read_fixed_fd` | `register_fixed_buffers`（TLS 池）+ `read_fixed_fd` |
| 内核 provided 池 | `register_provided_buffers` | **勿用**；用 fixed/batch |
| async/await IO | `read_async` + `poll_async_completions` | `read_async`（complete 同步读，见 STD-042） |

---

## 5. 验收（考古索引）

- manifest：`tests/baseline/std-io-fallback.tsv`
- 烟测：`tests/io/fallback_matrix.x`（`read_fd`/`write_fd`）
- 回归：`tests/run-io.sh`
- 闸：`tests/run-std-io-fallback-gate.sh`
- 报告：见 **§6 Gate**（`check=`／`run=`／`skip=`）

---

## 6. Gate

Honesty template（2026-08-26 · soft→硬绿）：

| 字段 | 含义 |
|------|------|
| prefer | `xlang_asm`（再 `xlang-c`／`xlang`）；钉 `XLANG_LINK_XLANG` |
| check | **观测**（自举期 check 闸门暂停；CHK 红不硬失败） |
| run | `fallback_matrix.x` **exit 0 硬失败**（有 native 时禁止 soft SKIP→OK） |
| skip | 仅 `MANIFEST_ONLY=1` 时可 1；有 native 跑烟测时必须 0 |
| refuse | 顶层 `analysis/std-io-fallback-v1.md` 复活 → FAIL |

报告行：

```text
xlang: [XLANG_STD_IO_FALLBACK] status=ok matrix=1 code=1 readme=1 check=? run=1 skip=0
```

Changelog v1.1：DOC／TSV→`## 6. Gate`；权威改锚 `backend.x`／`sync.x`／`win32.x`（`io.c` 退役）；闸 prefer asm＋LINK；check 观测；`fallback_matrix` exit0 硬失败；报告 `check=`／`run=`／`skip=`。

---

## 7. 演进

- Windows IOCP 与 std.net accept 路径统一文档；BSD / 嵌入式 freestanding 矩阵扩展。
