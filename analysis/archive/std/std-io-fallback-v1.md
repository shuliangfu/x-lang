# STD-026 std.io 非 Linux io_uring 回退统一文档 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-026、`std/io/io.c`、`STD-042` async IO

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-026 | 统一描述 Linux io_uring 与 **macOS / Windows** read/write 回退路径 |

实现锚点：`std/io/io.c` 文件头 — *io_uring（Linux）/ kqueue（macOS）/ IOCP（Windows）；失败或不可用时回退到 read/write*。

---

## 2. 分层模型

```
std.io API（read_fd / read_batch_fd / read_async …）
        ↓
std.io.driver → std.io.core → io.c
        ↓
┌─────────────┬──────────────────┬─────────────────────┐
│ Linux       │ macOS            │ Windows             │
│ io_uring    │ kqueue + readv   │ IOCP + ReadFile     │
│ ↓ fallback  │ ↓ fallback       │ ↓ fallback          │
│ read/write  │ read/write       │ ReadFile 同步       │
└─────────────┴──────────────────┴─────────────────────┘
```

**铁律**：非 Linux **无** io_uring；`register_provided_buffers` / `read_provided_fd` 仅 Linux 5.19+；macOS/Windows 须回退 `read_fixed_fd` 或 `read_batch_fd`。

---

## 3. 三平台 read/write 矩阵

| API（io.c / mod.x） | Linux 主路径 | Linux 回退 | macOS 主路径 | macOS 回退 | Windows 主路径 | Windows 回退 |
|----------------------|-------------|-----------|-------------|-----------|---------------|-------------|
| `io_read` / `read_fd` | `io_uring_prep_read` | `FALLBACK_READ` → `read(2)` | `kqueue` + `EVFILT_READ`（fd≥3） | `FALLBACK_READ` | `IOCP` + `ReadFile` overlapped | `FALLBACK_READ` |
| `io_write` / `write_fd` | `io_uring_prep_write` | `FALLBACK_WRITE` → `write(2)` | `kqueue` + `EVFILT_WRITE`（fd≥3） | `FALLBACK_WRITE` | `IOCP` + `WriteFile` | `FALLBACK_WRITE` |
| `io_read_batch` / `read_batch_fd` | `io_uring` multi-SQE / `prep_readv` | 逐段 `io_read` | `readv`（`io_readv_all`） | 逐段 `io_read` | `IOCP` 批量 `ReadFile` | 逐段 `io_read` |
| `io_write_batch` / `write_batch_fd` | `prep_writev` / multi-SQE | 逐段 `io_write` | `writev`（`io_writev_all`） | 逐段 `io_write` | `IOCP` 批量 `WriteFile` | 逐段 `io_write` |
| `io_read_fixed` / `read_fixed_fd` | `io_uring_prep_read_fixed` | `FALLBACK_READ` | TLS `fixed_pool_t` → `io_read` | — | TLS `win_fixed_pool_t` → `io_read` | — |
| `io_write_fixed` / `write_fixed_fd` | `io_uring_prep_write_fixed` | `FALLBACK_WRITE` | TLS iov 池 → `io_write` | — | TLS 池 → `io_write` | — |
| `register_provided_buffers` | `IORING_OP_PROVIDE_BUFFERS` | 失败返回 0 | **不支持**（mod.x 文档：回退 read_fixed_fd） | — | **不支持** | — |
| `read_async` / `complete_read_async_slot` | `io_uring` 异步 SQE | — | `complete` 时 **同步** `io_read` | — | `complete` 时 **同步** `io_read` | — |
| `io_read_ptr` | `mmap` 文件视图 | TLS `g_io_read_ptr_buf` | `dispatch_data` 文件视图 | TLS 缓冲 | TLS 缓冲（无 mmap/dispatch） | TLS 缓冲 |
| `io_wait_readable` | `poll` | — | `kqueue` `EVFILT_READ` | — | `select` / `WSA` `FD_SET` | — |

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

## 5. 验收

- manifest：`tests/baseline/std-io-fallback.tsv`
- 烟测：`tests/io/fallback_matrix.x`（`read_fd`/`write_fd` typeck）
- 回归：`tests/run-io.sh`
- 报告：`shux: [SHUX_STD_IO_FALLBACK] status=ok`

---

## 6. 演进

- Windows IOCP 与 std.net accept 路径统一文档；BSD / 嵌入式 freestanding 矩阵扩展。
