# 阶段 F-03 闭合（std.heap / std.fs / std.io 核心无 C）

> **F-03**：删除 **`heap.c`**、**`fs.c`**、**`io.c`**；核心路径改纯 `.x` + libc/kernel32 FFI。

## 完成项

| 模块 | 删除 | 新增 `.x` | 门禁 |
|------|------|------------|------|
| **heap** v1 | — | `ops.x` | `run-f03-std-heap-ops-gate.sh` |
| **heap** v2 | `heap.c` | `libc.x` | `run-f03-std-heap-libc-gate.sh` |
| **fs** v2 | `fs.c` | `posix.x`, `win32.x` | `run-f03-std-fs-gate.sh` |
| **io** v2/v3 | `io.c` | `sync.x`, `win32.x`, `read_ptr.x`, `stubs.x`, `backend.x` | `run-f03-std-io-gate.sh` |

## F-01 存量

```bash
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=104
```

（较 F-02 后 107 减 3：`heap.c` + `fs.c` + `io.c`）

## 聚合复现

```bash
SHUX_F03_CORE_FAIL=1 ./tests/run-f03-std-core-gate.sh
```

## v1 限制（io）

| 能力 | F-03 v3 行为 |
|------|----------------|
| io_uring / IOCP / kqueue | **stub** → libc sync read/write |
| timeout_ms | 保留参数，v1 **未实现**超时 |
| provided buffers / async IO | 返回失败；用 sync read/write |
| read_ptr mmap | 模块内缓冲；无 Linux mmap / macOS dispatch_data |

后续 **F-04+** 可在独立模块恢复 io_uring（按需 `-luring`）。

## 与 F-06 关系

- `runtime.c` / `build_shux_asm.sh` 仍含 `std/*/ *.o` 路径字符串（track-only）；`invoke_cc` 跳过缺失 `.o`，改链 **-lc**。
- bootstrap **Makefile** 已移除 heap/fs/io 的 `cc -c` 规则。
