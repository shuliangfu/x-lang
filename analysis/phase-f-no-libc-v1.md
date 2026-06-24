# 阶段 F-no-libc v1（像 Zig freestanding，零 libc）

> **目标**：Linux x86_64 金标准下，用户程序与编译器 bootstrap 路径 **`-nostdlib` 静态链、无 `libc.so`、链接命令无 `-lc`**；OS 能力仅经 `std.sys` syscall / 极薄 `.s`。

## 与阶段 F 关系

| 项 | 阶段 F（无 C 源码） | F-no-libc（本项） |
|----|---------------------|-------------------|
| 仓库内 `.c` | 清零 | 同样要求 |
| 链接 `-lc` | 旧文档允许 | **禁止** |
| `ldd` | 未强制 | **不得** 出现 `libc.so` |
| macOS | libSystem FFI 可接受 | 金标准仍以 **Linux no-libc** 为准 |

## 已有（✅ 可复用）

| 能力 | 实现 |
|------|------|
| crt0 | `compiler/src/asm/crt0_user_x86_64.s` |
| write/read/open/close/exit | `freestanding_io_x86_64.s` |
| openat/mmap/munmap | 同上 |
| `.sx` 门面 | `std/sys/linux.sx`、`std/sys/mod.sx` |
| 烟测 | `tests/run-freestanding-hello.sh`、B-04/B-14/B-31 gates |

## 待写代码（按依赖顺序）

### NL-01 准备（✅ v1）

- 专文档：`analysis/phase-f-n01-v1.md`
- Manifest：`tests/baseline/nolibc-n01-preparation.tsv`
- 专 gate：`tests/run-nolibc-n01-preparation-gate.sh`
- 聚合 gate：`tests/run-no-libc-gate.sh`（委托 NL-01 + NL-02～05）

### NL-02 扩展 syscall（✅ v1 socket）

| syscall | 状态 |
|---------|------|
| socket/connect/bind/listen/accept | ✅ `.s` + `linux.sx` + `std/net/freestanding_linux.sx` |
| futex/clone/brk | ⬜ 后期 |

Gate：`SHUX_NOLIBC_SOCKET_FAIL=1 ./tests/run-no-libc-socket-gate.sh`

### NL-03 堆（✅ v1）

- `std/heap/page_mmap.sx`：`PageMmapHeap` 64KiB 匿名 mmap bump
- Gate：`SHUX_NOLIBC_HEAP_FAIL=1 ./tests/run-no-libc-heap-gate.sh`

### NL-04 文件 IO（✅ v1）

- `std/fs/freestanding_linux.sx`：read/open/close/write 经 `std.sys` syscall
- Gate：`SHUX_NOLIBC_FS_FAIL=1 ./tests/run-no-libc-fs-gate.sh`
- freestanding 程序用 `import("std.fs.freestanding_linux")`，勿拉完整 `std.fs`（含 fs.c extern）

### NL-05 链接策略（✅ v1 用户路径）

- `runtime.c` NL-05 标记块：`ld -nostdlib -static --gc-sections`，**禁止 `-lc`**
- Gate：`SHUX_NOLIBC_LINK_FAIL=1 ./tests/run-no-libc-link-gate.sh`
- **编译器 bootstrap**（`build_shux_asm.sh`）仍 `-lc/-lm` → 延后 **F-07 / NL-06**

### NL-06 freestanding std 首批发（v1 ✅）

- 专文档：`analysis/phase-f-n06-v1.md`
- Manifest：`tests/baseline/nolibc-n06-freestanding-replacements.tsv`（heap/fs/net `.sx` ↔ legacy `.c`）
- Gate：`SHUX_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh`
- v1 **不删** `std/*.c`；编译器 bootstrap 仍链 `fs.o`/`io.o`/`heap.o` → **F-07 / NL-06 v2**

### NL-07 编译器 bootstrap 去 libc 准备（v1 ✅）

- 专文档：`analysis/phase-f-n07-v1.md`
- Manifest：`tests/baseline/nolibc-n07-bootstrap-prep.tsv` + `nolibc-n07-bootstrap-lc-track.tsv`
- Gate：`SHUX_NOLIBC_N07_FAIL=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh`
- `build_shux_asm.sh` **NL-07 BEGIN/END** marker 记录目标 nostdlib 链；v1 **不启用**

### NL-06 v2+ / NL-07 v2 全 std 迁移（待做）

- 按 `tests/baseline/std-c-inventory.tsv`（当前 110）逐个替换或按需不链入
- 非 bootstrap 关键模块可延后（crypto/db/compress）

## v1 完成判据（F-no-libc ✅）

1. `./tests/run-no-libc-gate.sh` 在 Linux x86_64 **硬绿**
2. freestanding hello + open/read + **mmap heap smoke** 均无 `libc.so`
3. `std.heap` freestanding 路径不链 `heap.c`（软删除：`#[cfg]` 或按需符号）
4. 文档与 NEXT §9.4 同步

## 平台说明

- **Linux**：no-libc 金标准（syscall + crt0）
- **macOS 开发**：可继续 libSystem；CI 金标准走 Docker Linux
- **Windows**：无 glibc；`kernel32`/`ws2_32` 仍属 OS DLL（非本项「libc」）

## 复现

```bash
# 准备阶段 gate（manifest + 委托既有 freestanding 烟测）
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh

# 已有 freestanding 子集
./tests/run-freestanding-hello.sh
./tests/run-std-sys-gate.sh
```
