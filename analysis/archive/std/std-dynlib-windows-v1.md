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

## 5. Gate

Honesty gate (2026-08-28 soft fallthrough residual):

- Prefer `./compiler/xlang_asm`; pin `XLANG_LINK_XLANG`.
- Explicit-bad `XLANG` / missing native → hard die (refuse soft fallthrough / prefer-c / soft auto-make / soft SKIP→OK).
- `xlang check` observational only (check gate paused 2026-08-05).
- Hard runnable exit 0 (`run+=`): `open_sym_close.x`, `main.x`, `win_path.x`.
- Observational (`obs+=`): `win_path_smoke.c` host-C archaeology (existing `.o` only; refuse soft ensure rebuild).
- Manifest: `tests/baseline/std-dynlib-windows.tsv`
- Runner: `tests/run-std-dynlib-windows-gate.sh` (+ `tests/run-dynlib.sh` regression)
- Report: `xlang: [XLANG_STD_DYNLIB_WIN] status=ok run=/obs=/skip=`
- Refuse resurrecting top-level `analysis/std-dynlib-windows-v1.md` (live DOC = archive).

**Honesty (2026-08-29 residual auto-make)**：leftover `tests/run-dynlib.sh`（`xlang_compiler_make -q || make` + `dynlib.o` + `xlang-c` + bootstrap-link wrap）retired. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `main`／`open_sym_close`／`last_error` hard；check＝obs；report `run=`／`obs=`／`skip=`。leftover runner report prefix `xlang: [DYNLIB]`。Keep `## 5. Gate`。

---

## 6. Evolution

- `LoadLibraryW` / UTF-16 path (v2 residual); `dynlib_last_error` delivered (STD-096).
