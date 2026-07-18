# BOOT-029：std.sys OS 原语 v0

> 更新时间：2026-06-19  
> 状态：**可用（Linux freestanding write + macOS POSIX write）**  
> 关联：`自举分析.md` 关卡三、`compiler/docs/SELFHOST.md` S4

---

## 1. 目标

| ID | 交付 |
|----|------|
| BOOT-029 | `import("std.sys")` + `os_write*` freestanding 门面 + gate |

---

## 2. API（v0）

| API | Linux freestanding |
|-----|-------------------|
| `os_write` | `shux_sys_write` 按需链入 |
| `os_write_stdout` | fd=1 |
| `freestanding_write_available` | 文档化探测 |

---

## 3. Gate

```bash
./tests/run-std-sys-gate.sh
```

Linux x86_64 + `shux -freestanding -backend asm`：编译运行 stdout 烟测。  
Darwin + 常规 `-o exe`：`macos_write_stdout` 烟测。  
其他宿主：manifest + typeck OK，runtime SKIP。

---

## 4. 非目标（v3 前）

- `#[cfg(target_os)]` 条件编译子模块
- Windows `WriteFile` 子模块（v2 剩余）
- `os_read` / `os_open` / mmap 统一门面

---

## 5. 自举路线

1. ✅ **v0**（本 RFC）：freestanding write 门面  
2. ✅ **v1**：`std/sys/linux.x` syscall 号表（x86_64 + aarch64）+ `linux_syscall_nr_*` 薄转发  
3. ✅ **v2（macOS）**：`std/sys/macos.x` → libSystem `write(2)`  
4. **v2（Windows）**：`std/sys/win32.x` → `WriteFile`  
5. **v3**：编译器读源码改走 `std.sys` 而非 C `fopen`

---

## 6. v1（Linux syscall 号表）

| API | 说明 |
|-----|------|
| `import("std.sys.linux")` | read/write/open/close/exit/mmap 号表 |
| `linux_syscall_table_available()` | mod + linux 子模块探测 |
| `linux_syscall_nr_write_amd64()` | 恒 1（与 `freestanding_io_x86_64.s` 一致） |

烟测：`tests/sys/linux_syscall_nr_smoke.x`（typeck + 常量断言）。  
实际 syscall invoke 仍由汇编桩完成；`.x` 内联 asm 为后续项。

---

## 7. v2（macOS POSIX write）

| API | 说明 |
|-----|------|
| `import("std.sys.macos")` | `macos_write` / `macos_write_stdout` |
| `macos_write_available()` | mod + macos 子模块探测 |
| `extern write` | libSystem POSIX write(2) |

烟测：`tests/sys/macos_posix_write_smoke.x`（Darwin `-o exe` 运行）。  
与 `os_write`（freestanding Linux）并存；无 `#[cfg]` 时由调用方选择路径。
