# 阶段 F-ffi v1（std.ffi 去 C + F-ZC）

> **F-ffi v1**：删除 **`ffi.c`**；CString/point/回调在 **`ffi.sx`**；**F-ZC** 删除 **`ffi_cb_glue.c`**，回调经 **句柄 dispatch**（`FFI_CB_HANDLE_DOUBLE_I32`）。

## 变更

| 项 | 前 | v1 | F-ZC |
|----|----|-----|------|
| 实现 | `ffi.c` | `ffi.sx` + glue | **纯 `.sx`** |
| 回调 invoke | C fn-ptr | `ffi_cb_glue.c` | **handle dispatch** |
| `ffi.o` | `cc -c ffi.c` | `ld -r` | **纯 `.sx`** |

## 门禁

```bash
SHUX_F_FFI_V1_FAIL=1 ./tests/run-f-ffi-v1-gate.sh
./tests/run-std-ffi-cstring-lifecycle-gate.sh
./tests/run-std-ffi-struct-callback-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```

## 备注

- 任意 C 函数地址 `invoke_i32_cb` 待编译器 indirect-call；当前内置回调用句柄。
