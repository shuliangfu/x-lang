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

## 复现

```bash
SHUX_F02_WIN32_FAIL=1 ./tests/run-f02-std-sys-win32-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=107
```
