# STD-027 std.dynlib Windows LoadLibrary v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-027、`std/ffi` TYPE-004

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-027 | Windows `LoadLibraryA` / `GetProcAddress` / `FreeLibrary` 与 POSIX `dlopen` 对齐 |

三平台统一 API：`open` / `sym` / `close`（`std/dynlib/mod.x`）。

---

## 2. API

| 函数 | 说明 |
|------|------|
| `open(path: *u8): *u8` | 打开动态库；失败返回 0；`path` 空或 NULL 返回 0 |
| `sym(lib: *u8, name: *u8): *u8` | 取符号地址；失败返回 0 |
| `close(lib: *u8): void` | 关闭句柄 |

**U3 unsafe**：句柄与符号均为不透明 `*u8`；调用方须保证函数指针签名正确（见 `safe-unsafe-api.tsv`）。

---

## 3. 平台实现（`std/dynlib/dynlib_glue.c`）

| 平台 | open | sym | close | 链接 |
|------|------|-----|-------|------|
| **Windows** | `LoadLibraryA` / `LoadLibraryW`（STD-097） | `GetProcAddress` | `FreeLibrary` | 无 `-ldl` |
| **POSIX** | `dlopen(RTLD_NOW)` | `dlsym` | `dlclose` | `-ldl`（Linux） |

### 3.1 Windows 约定

- 路径 **`/` 规范化**为 `\\`（`dynlib_win_normalize_path`）；UTF-8 路径 `LoadLibraryW` 回退。
- 推荐烟测库：`kernel32.dll` + 符号 `GetTickCount`；正斜杠路径：`C:/Windows/System32/kernel32.dll`。
- 失败时 `last_error`（STD-096）暴露 `GetLastError` / `dlerror`。

### 3.2 POSIX 约定

- 烟测：`libc.so.6` / `libSystem.B.dylib` + `malloc`。
- `dlopen("")` **禁止**（避免返回主程序句柄）。

---

## 4. 边界金样

| 场景 | 期望 |
|------|------|
| `open(null)` / 空路径 | 0 |
| `open("kernel32.dll")` + `sym(...,"GetTickCount")`（Windows） | 非 0 |
| `open("libc.so.6")` + `sym(...,"malloc")`（Linux） | 非 0 |
| `close` 后勿再 `sym` | 未定义（文档警告） |

---

## 5. 验收

- manifest：`tests/baseline/std-dynlib-windows.tsv`
- 烟测：`tests/dynlib/open_sym_close.x`；回归：`tests/run-dynlib.sh`
- 报告：`shux: [SHUX_STD_DYNLIB_WIN] status=ok`

---

## 6. 演进

- `LoadLibraryW` / UTF-16 路径（v2）；`dynlib_last_error` 已交付（STD-096）。
