# 阶段 F-ffi v1（std.ffi 去 C + F-ZC）

> **F-ffi v1**：删除 **`ffi.c`**；CString/point/回调在 **`ffi.x`**；**F-ZC** 删除 **`ffi_cb_glue.c`**，回调经 **句柄 dispatch**（`FFI_CB_HANDLE_DOUBLE_I32`）。

## 变更

| 项 | 前 | v1 | F-ZC |
|----|----|-----|------|
| 实现 | `ffi.c` | `ffi.x` + glue | **纯 `.x`** |
| 回调 invoke | C fn-ptr | `ffi_cb_glue.c` | **handle dispatch** |
| `ffi.o` | `cc -c ffi.c` | `ld -r` | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_FFI_V1_FAIL` retired. Delegates STD-055 ffi-cstring hard (embeds SAFE-004). STD-151 struct-callback observational (DOC residual).

**2026-08-30 leftover XLANG fallthrough 已收**（f-ffi-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-ffi-cstring-lifecycle／std-ffi-struct-callback 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-ffi-v1-gate.sh
./tests/run-std-ffi-cstring-lifecycle-gate.sh
```

## 备注

- 任意 C 函数地址 `invoke_i32_cb` 待编译器 indirect-call；当前内置回调用句柄。
