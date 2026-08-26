# 阶段 F-02 v1（std.sys Linux 去 C：移除 mmap.inc.c）

> **F-02 v1**：Linux 文件 MAP_SHARED mmap 改走 **`std/sys/linux.x` libc FFI**（与 macOS `macos.x` 对齐）；**删除** `std/sys/mmap.inc.c`。

## v1 完成（✅ manifest / 非 Linux 宿主 N/A）

| 项 | 说明 |
|----|------|
| `linux_mmap_rw` / `linux_munmap` / `linux_msync_sync` | `std/sys/linux.x` |
| `mmap.x` | Linux 不再 `extern xlang_sys_mmap_*_c` |
| 删除 | `std/sys/mmap.inc.c`、`compiler/Makefile` 中 `mmap.o` 规则 |
| 烟测 | `tests/sys/linux_mmap_file_smoke.x` + `run-linux-mmap-file-gate.sh` |

## 仍留 C（F-03 后续）

| 文件 | 说明 |
|------|------|
| `std/db/kv/kv.c` | KV 引擎本体（F-05 前） |

## F-02 v2（✅ win32 去 C）

见 `analysis/archive/phase/phase-f-f02-v2.md`；`run-f02-std-sys-win32-gate.sh`。

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory + Linux MAP_SHARED smoke. No soft
`die→exit 0`. Soft `XLANG_F02_FAIL` / `XLANG_LINUX_MMAP_FILE_FAIL` retired.
Report `static=` / `inventory=` / `linux=` / `skip=`. Non-Linux hosts keep
`linux=0` (platform N/A, not soft false-green).

```bash
./tests/run-f02-std-sys-mmap-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f02-std-sys-mmap-gate.sh
./tests/run-linux-mmap-file-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F02_FAIL` path retired; gate always hard).
Neighbor inventory still owns its own FAIL knife when run standalone:

```bash
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 延后（F-03+）

- `kv.c` 内联 mmap 改调 `std.sys.mmap` 或纯 `.x` 引擎
