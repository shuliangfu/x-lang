# 阶段 F-03 v2/v3（std.io 去 C：删除 io.c）

> **F-03 v2/v3**：`std/io/io.c`（3387 行）迁至 **`io_sync.sx` / `io_win32.sx` / `io_read_ptr.sx` / `io_stubs.sx` / `io_backend.sx`**；**删除** `io.c` / `io.o`；链接改 **-lc**（POSIX sync），**不再**默认 **-luring**。

## v2/v3 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `io_sync.sx` | Linux/macOS：read/write/readv/writev、poll、fixed buffer 池 |
| `io_win32.sx` | Windows：ReadFile/WriteFile/_read/_write、fixed 池 |
| `io_read_ptr.sx` | 64KiB 模块缓冲 + generation；v1 无 mmap/dispatch_data |
| `io_stubs.sx` | io_uring/provided/async 桩（返回 0/-1） |
| `io_backend.sx` | 聚合导出 `io_*` 与 bootstrap 符号（原 io.c 弱符号） |
| `core.sx` | `import("std.io.io_backend")` 替代 extern io_* |
| 删除 | `std/io/io.c`、`Makefile` / `runtime_link_abi.c` 中 `io.o` |
| 存量 | F-01 **104** `.c`（io.c 已删） |

## 已知限制（v1 sync fallback）

| 限制 | 说明 |
|------|------|
| io_uring / IOCP / kqueue | 全部 stub；同步路径走 libc read/write |
| timeout_ms | 参数保留；v1 未实现 poll 超时，阻塞 read/write |
| provided buffers | `io_register_provided_buffers` 返回 0；用 read_fixed/read_batch |
| async read/write | submit 返回 -1；用 `shux_io_submit_read` 同步路径 |
| read_ptr mmap | Linux/macOS 绝对视图未实现；backend 恒 0（TLS 缓冲） |
| fixed buffer 池 | 模块级静态，非真 TLS；多线程并发注册不隔离 |
| Win32 wait_readable | v1 返回 -1；需后续 FD_SET/select 完整布局 |

## 复现

```bash
SHUX_F03_IO_FAIL=1 ./tests/run-f03-std-io-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=104
./tests/run-io.sh
```
