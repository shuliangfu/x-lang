# 阶段 F-03 v2（std.fs 去 C：删除 fs.c）

> **F-03 v2**：`std/fs/fs.c`（1106 行）迁至 **`posix.sx` / `win32.sx`** + `mod.sx` 薄转发；**删除** `fs.c` / `fs.o`；链接改 **-lc**（POSIX）/ kernel32+ws2_32+mswsock（Windows）。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `posix.sx` | Linux/macOS libc FFI：mmap/readv/sendfile/splice/stat/opendir 等 |
| `win32.sx` | CreateFile/MapViewOfFile/ReadFile/TransmitFile/FindFirstFile 等 |
| `mod.sx` | `#[cfg]` import 平台模块；`fs_*_c` 函数体转发 |
| 删除 | `std/fs/fs.c`、`Makefile` 中 `fs.o` 规则与链入行 |
| 链接 | `runtime_link_abi.c` 移除 `fs.o` push；`have_fs` → `-lc` |
| 存量 | F-01 **105** `.c`（fs.c 已删；与 heap 迁移后基线一致） |

## 已知限制

| 限制 | 说明 |
|------|------|
| `struct stat` 布局 | `fs_posix` 使用平台 cfg 近似布局；非常规 libc 可能需微调 |
| `readdir` d_type | 非 Linux DT_DIR 时 `is_dir_out` 可能为 0 |
| Windows `fs_open_write_c` | v2 新增（原 fs.c Win 分支缺失）；CREATE_ALWAYS 截断 |
| asm 路径 | `fs_*_c` 由 `std_fs.o`（mod.sx 编译）提供，非独立 fs.o |

## 复现

```bash
SHUX_F03_FS_FAIL=1 ./tests/run-f03-std-fs-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=105
./tests/run-std-fs-dirmeta-gate.sh
```
