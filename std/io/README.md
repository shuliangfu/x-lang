# std.io — 高性能 I/O API 层

与 **Zig** std.io、**Rust** std::io 对标。用户通过 `import("std.io")` 使用本模块。

## 职责

- **Reader/Writer** trait、标准流（stdin/stdout/stderr）
- **同步读写**：`read` / `write` / `read_fd` / `write_fd`
- **批量**：`read_batch_fd` / `read_batch_fd_buf`（io_uring / readv / IOCP）
- **零拷贝读**：`read_ptr` / `read_ptr_slice`（`[]u8<io_read_ptr>`，见 TYPE-002）
- **fixed / provided buffer 池**：热路径与 ZC-1
- **异步 submit/complete**：`read_async` / `complete_read_async_slot`

底层：`std.io.core` + `std.io.driver` + `io.c`（Linux io_uring / macOS kqueue / Windows IOCP）。

## 快速示例

```su
import("std.io");

function main(): i32 {
  let mut buf: [64]u8 = [];
  let n: i32 = read_stdin(buf.data, 64);
  if (n > 0) {
    write_stdout(buf.data, n as usize);
  }
  return 0;
}
```

零拷贝读（注意生命周期，见 mod.su 文件头）：

```su
let s: []u8<io_read_ptr> = read_stdin_ptr_slice();
// 勿赋给未标注 []u8；同线程下次 read_ptr 前有效
```

## 返回值

与 [EXC-001](../../analysis/exc-result-error-v1-rfc.md) Layer C 一致：`>0` 字节，`0`=EOF（读），`-1` 错误。

## 稳定化与兼容

- **API 分级、三平台矩阵、变更流程**：[`analysis/std-io-api-v1.md`](../../analysis/std-io-api-v1.md)
- **非 Linux io_uring 回退（STD-026）**：[`analysis/std-io-fallback-v1.md`](../../analysis/std-io-fallback-v1.md) — macOS kqueue/readv、Windows IOCP 矩阵
- **稳定符号清单**：`tests/baseline/std-io-api.tsv`
- **CI**：`tests/run-std-io-api-gate.sh`、`tests/run-std-io-fallback-gate.sh`、`tests/run-io-unified-gate.sh`

## 与 std.fs

`std.fs` 内置联合 `read_fd` / `write_fd` / `read_batch_fd`；大文件 mmap 用 `std.fs`，fd 热路径走 std.io 后端。
