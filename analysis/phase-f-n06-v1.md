# 阶段 F-NL-06 完成标准 v1（freestanding std 首批发）

> **NL-06 v1**：在 NL-01～05 之上，登记 freestanding `.x` 替换模块。**F-03 后**：hosted `heap.c`/`fs.c`/`io.c` 已删；bootstrap 改链 **-lc**（track 见 `nolibc-n06-freestanding-replacements.tsv`）。

## v1 完成（✅ 首批发）

| 项 | 标准 | 产物 |
|----|------|------|
| NL-06 专文档 | 本文件 | `analysis/phase-f-n06-v1.md` |
| 替换 manifest | freestanding `.x` ↔ legacy `.c` 对照 | `tests/baseline/nolibc-n06-freestanding-replacements.tsv` |
| 审计库 | manifest / smoke import / bootstrap track | `tests/lib/nolibc-n06-std-track.sh` |
| NL-06 专 gate | manifest + F-01 委托 + bootstrap track | `tests/run-nolibc-n06-std-track-gate.sh` |
| 聚合 gate | NL-06 委托 | `tests/run-no-libc-gate.sh` |

## v1 已登记 freestanding 替换（用户 `-freestanding`）

| 能力 | freestanding `.x` | legacy `.c`（hosted/bootstrap 仍用） | 烟测 / gate |
|------|-------------------|--------------------------------------|-------------|
| 堆（mmap bump） | `std/heap/page_mmap.x` | `std/heap/libc.x`（hosted） | `linux_heap_mmap_smoke.x` / NL-03 |
| 读文件 | `std/fs/freestanding_linux.x` | `std/fs/posix.x`（hosted） | `linux_fs_freestanding_smoke.x` / NL-04 |
| socket v1 | `std/net/freestanding_linux.x` | `std/net/net.c` | `linux_socket_invoke_smoke.x` / NL-02 |
| syscall 门面 | `std/sys/linux.x` | — | `run-std-sys-gate.sh` |

**约定**：freestanding 程序应 `import std.heap.page_mmap`、`std.fs.freestanding_linux`、`std.net.freestanding_linux`；hosted 走 `heap_libc` / `fs_posix` / `io_backend` 纯 `.x`。

## track-only（不阻塞 NL-06 v1 ✅）

| 项 | 说明 |
|----|------|
| F-01 存量 | baseline **4** total（std **0** + core 4；F-ZC ✅） |
| 编译器 bootstrap | Makefile 已不 `cc -c` heap/fs/io；`build_shux_asm.sh` track 待 F-07 清字符串 |
| hosted 程序 | 仍链 libc + std C 实现 |
| 全量迁移 | 非 bootstrap 模块（crypto/db/compress 等）可延后 |

## 复现

```bash
# NL-06 专 gate（任意平台 manifest OK）
SHUX_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh

# 全链聚合（含 NL-06 track）
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh
```

## 延后（NL-06 v2+ / NL-07 v2）

- 编译器 bootstrap 改链 freestanding `.x` 对象并启用 `-nostdlib`（NL-07 v2）
- `std/io` freestanding 路径（stdout 已由 `std.sys` 覆盖；io_uring 仍 C）
- 按 F-01 inventory 逐模块删除或软退役 `.c`（阶段 F 清场）
