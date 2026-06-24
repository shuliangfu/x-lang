# 阶段 F-02 v1（std.sys Linux 去 C：移除 mmap.inc.c）

> **F-02 v1**：Linux 文件 MAP_SHARED mmap 改走 **`std/sys/linux.sx` libc FFI**（与 macOS `macos.sx` 对齐）；**删除** `std/sys/mmap.inc.c`。

## v1 完成（✅ manifest / 非 Linux 宿主 N/A）

| 项 | 说明 |
|----|------|
| `linux_mmap_rw` / `linux_munmap` / `linux_msync_sync` | `std/sys/linux.sx` |
| `mmap.sx` | Linux 不再 `extern shux_sys_mmap_*_c` |
| 删除 | `std/sys/mmap.inc.c`、`compiler/Makefile` 中 `mmap.o` 规则 |
| 烟测 | `tests/sys/linux_mmap_file_smoke.sx` + `run-linux-mmap-file-gate.sh` |

## 仍留 C（F-03 后续）

| 文件 | 说明 |
|------|------|
| `std/db/kv/kv.c` | KV 引擎本体（F-05 前） |

## F-02 v2（✅ win32 去 C）

见 `analysis/phase-f-f02-v2.md`；`run-f02-std-sys-win32-gate.sh`。

## 复现

```bash
# 聚合门禁（manifest + F-01 + Linux 烟测委托）
SHUX_F02_FAIL=1 ./tests/run-f02-std-sys-mmap-gate.sh

# Linux x86_64 hosted
SHUX_LINUX_MMAP_FILE_FAIL=1 ./tests/run-linux-mmap-file-gate.sh

# F-01 存量（应 total=109）
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 延后（F-03+）

- `kv.c` 内联 mmap 改调 `std.sys.mmap` 或纯 `.sx` 引擎
