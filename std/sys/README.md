# std.sys — OS 原语（自举底座）

> **RFC**：`analysis/std-sys-v0.md`（BOOT-029）  
> **关联**：`compiler/docs/SELFHOST.md` §5 S4 freestanding、`tests/freestanding/hello/`

## 定位

自举 **关卡三** 的第一步：把 `_stubs.c` / 汇编桩上的 **write** 能力以 **纯 `.sx` 门面** 暴露给用户与上层 std。

| 平台 | v0 | v1 | v2（规划） |
|------|-----|-----|------------|
| Linux x86_64 freestanding | `os_write` → `shux_sys_write` | `std.sys.linux` syscall 号表 | 内联 asm invoke |
| Linux aarch64 | — | syscall 号表（文档） | freestanding .s + asm |
| macOS Darwin | — | — | `macos_write` → libSystem write(2) |
| FreeBSD | — | syscall 号表（文档） | `freebsd_write` → libc write(2) |
| Windows | — | — | `win32_write` → kernel32 WriteFile（F-02 v2 纯 `.sx`） |

## API（v0）

| API | 说明 |
|-----|------|
| `freestanding_write_available()` | mod 导出探测（v0 恒 1） |
| `os_write(fd, buf, len)` | freestanding write |
| `os_write_stdout` / `os_write_stderr` | 便捷封装 |

## v1（Linux syscall 号表）

```sx
const linux = import("std.sys.linux");
// x86_64 write = 1；aarch64 write = 64
let nr: i64 = linux.syscall_nr_write_amd64();
```

或通过 `import("std.sys")` 的 `linux_syscall_nr_write_amd64()` 薄转发。

## v2（macOS POSIX write）

```sx
const macos = import("std.sys.macos");
let n: i32 = macos.macos_write_stdout(&msg[0], 11);
```

Darwin 常规 `-o exe` 链 libSystem；与 Linux freestanding `os_write` 互补。

## 构建

```bash
# Linux x86_64 freestanding 烟测（须 shux -freestanding -backend asm）
./tests/run-std-sys-gate.sh
```

## 测试

- `tests/sys/sys_write_freestanding.sx`
- `tests/sys/linux_syscall_nr_smoke.sx`
- `tests/sys/macos_posix_write_smoke.sx`
- `tests/sys/freebsd_posix_write_smoke.sx`
- 门禁：`tests/run-std-sys-gate.sh`、`tests/run-freebsd-platform-gate.sh`
