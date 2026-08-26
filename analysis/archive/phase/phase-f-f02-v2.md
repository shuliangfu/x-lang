# 阶段 F-02 v2（std.sys Windows 去 C：移除 win32*.inc.c）

> **F-02 v2**：Windows I/O / WSA 改走 **`std/sys/win32.x` / `win32_net.x` 直接 kernel32/ws2_32 FFI**（对齐 macOS `macos.x`）；**删除** `win32.inc.c`、`win32_net.inc.c`。

## v2 完成（✅ manifest / Windows 烟测 N/A 于非 Windows 宿主）

| 项 | 说明 |
|----|------|
| `GetStdHandle` / `WriteFile` / `CreateFileA` / `ReadFile` / `ExitProcess` | `std/sys/win32.x` extern kernel32 |
| `WSAStartup` / `WSACleanup` | `std/sys/win32_net.x` extern ws2_32 |
| 删除 | `win32.inc.c`、`win32_net.inc.c`、`Makefile` 中 `win32.o` 规则 |
| 链接 | `runtime_link_abi.c` 按需 `-lkernel32` / `-lws2_32`（无 `std/sys/win32.o`） |
| 烟测 | `run-win32-write-gate.sh` / `run-win32-read-file-gate.sh`（Windows/MSYS2） |

## F-02 闭合

| 模块 | 状态 |
|------|------|
| mmap（Linux/macOS） | ✅ v1 |
| win32 I/O + WSA | ✅ v2 |
| **std/sys 手写 .c** | **0**（F-03 起 io/fs/mem） |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + B-17/B-18 facades + F-01 inventory. No soft
`die→exit 0`. Soft `XLANG_F02_WIN32_FAIL` retired. Report `static=` /
`b17=` / `b18=` / `inventory=` / `skip=`. Windows hosted smoke remains N/A
on non-Windows; facade static checks run on all hosts.

```bash
./tests/run-f02-std-sys-win32-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f02-std-sys-win32-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F02_WIN32_FAIL` path retired; gate always
hard). Neighbor inventory still owns its own FAIL knife when run standalone:

```bash
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```
