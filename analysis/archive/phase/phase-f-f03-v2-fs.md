# 阶段 F-03 v2（std.fs 去 C：删除 fs.c）

> **F-03 v2**：`std/fs/fs.c`（1106 行）迁至 **`posix.x` / `win32.x`** + `mod.x` 薄转发；**删除** `fs.c` / `fs.o`；链接改 **-lc**（POSIX）/ kernel32+ws2_32+mswsock（Windows）。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `posix.x` | Linux/macOS libc FFI：mmap/readv/sendfile/splice/stat/opendir 等 |
| `win32.x` | CreateFile/MapViewOfFile/ReadFile/TransmitFile/FindFirstFile 等 |
| `mod.x` | `#[cfg]` import 平台模块；`fs_*_c` 函数体转发 |
| 删除 | `std/fs/fs.c`、`Makefile` 中 `fs.o` 规则与链入行 |
| 链接 | `runtime_link_abi.c` 移除 `fs.o` push；`have_fs` → `-lc` |
| 存量 | F-01 **105** `.c`（fs.c 已删；与 heap 迁移后基线一致） |

## 已知限制

| 限制 | 说明 |
|------|------|
| `struct stat` 布局 | `fs_posix` 使用平台 cfg 近似布局；非常规 libc 可能需微调 |
| `readdir` d_type | 非 Linux DT_DIR 时 `is_dir_out` 可能为 0 |
| Windows `fs_open_write_c` | v2 新增（原 fs.c Win 分支缺失）；CREATE_ALWAYS 截断 |
| asm 路径 | 正式产品名仍为 `std/fs/fs.o`（`xlang_compile_std_fs_formal`／LABI on-demand）；权威源是 `posix.x`／`win32.x`，**不是**已删的 `fs.c` |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`, hard-fail
static manifest + F-01 inventory + `tests/run-fs.sh` + STD-123
`run-std-fs-dirmeta-gate.sh` + STD-003 `run-std-fs-crossplatform-gate.sh`
(no soft `die→exit 0`, no prefer-c, no SKIP→OK when no native). Soft
`XLANG_F03_FS_FAIL` retired. Report `inventory=` / `run=` / `dirmeta=` /
`xplat=` / `skip=`. Dirmeta no longer bans formal product `std/fs/fs.o`
presence (only `fs.c`).

```bash
./tests/run-f03-std-fs-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f03-std-fs-gate.sh
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-fs.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-std-fs-dirmeta-gate.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-std-fs-crossplatform-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F03_FS_FAIL` path retired; gate always hard).
