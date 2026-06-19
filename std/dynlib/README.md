# std.dynlib — 动态库加载

**模块路径**：`std/dynlib/`（mod.sx + dynlib.c）  
**对标**：Zig `std.DynLib`、Rust `libloading`。

## API

| 函数 | 说明 |
|------|------|
| `open(path: *u8): *u8` | 打开 `.so` / `.dll`；失败 0；空路径 0 |
| `sym(lib: *u8, name: *u8): *u8` | 符号地址；失败 0 |
| `close(lib: *u8): void` | 释放句柄 |

## 平台

| 平台 | 实现 |
|------|------|
| Windows | `LoadLibraryA` / `GetProcAddress` / `FreeLibrary` |
| POSIX | `dlopen` / `dlsym` / `dlclose`（Linux 链 `-ldl`） |

详 `analysis/std-dynlib-windows-v1.md`（STD-027）。

## 测试

```bash
./tests/run-dynlib.sh
./tests/run-std-dynlib-windows-gate.sh
```
