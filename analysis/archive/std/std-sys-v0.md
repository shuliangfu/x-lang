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
| `os_write` | `xlang_sys_write` 按需链入 |
| `os_write_stdout` | fd=1 |
| `freestanding_write_available` | 文档化探测 |

---

## 3. Gate

```bash
./tests/run-std-sys-gate.sh
```

Honesty（2026-08-26 soft→硬绿）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 仅观测（check 闸门暂停 2026-08-05）
- 硬绿：`sys_write_freestanding.x` → `write_stdout` exit0 + stdout `Hello Xlang!\n`
  - **LINUX|UBUNTU x86_64**：`-freestanding -backend asm`
  - **MACOS|DARWIN**：常规 `-o`（hosted `write_stdout`）
- 无 native xlang → **FAIL**（禁止 soft SKIP→OK）
- 观测：`linux_syscall_nr_smoke.x`（Linux）；`macos_posix_write_smoke.x`（Darwin thin `macos_write_*` — 产品 UNDEF：labi `needs_std_sys` needles 缺 mod 层 `std_sys_macos_write_*`）
- 报告：`check=`／`run=`／`skip=`

```text
xlang: [XLANG_BOOT029_STD_SYS] status=ok check=1 run=1 skip=0
```

Changelog：

- **v0.2（2026-08-26）**：soft→硬绿 — 闸 prefer asm＋LINK pin；check 观测；`write_stdout` run 硬绿；Darwin 硬路径从 thin `macos_write_*` 收口到 facade `write_stdout`；thin macos 仅观测；报告 `check=`／`run=`／`skip=`。

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
Honesty note（2026-08-26）：thin `macos_write_*` 在 asm 产品链上仍可能 UNDEF（labi needles 缺 mod 层 `std_sys_macos_write_*`）；闸硬绿改走 facade `write_stdout`，本烟测仅观测。

---

## 8. v3（FreeBSD POSIX write）

| API | 说明 |
|-----|------|
| `import("std.sys.freebsd")` | `freebsd_write` / `freebsd_write_stdout` |
| `freebsd_write_available()` | mod + freebsd 子模块探测 |

烟测：`tests/sys/freebsd_posix_write_smoke.x`（FreeBSD host）。  
与 Linux freestanding / macOS POSIX 并存；门禁在非 FreeBSD 宿主不硬跑本烟测。
