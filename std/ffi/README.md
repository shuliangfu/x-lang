# std.ffi — C 互操作

**路径**：`std/ffi/`（mod.sx + ffi.sx，F-ZC 纯 .sx）  
**依赖**：core。

## CString（STD-055）

| API | 说明 |
|-----|------|
| `cstr_len` | NUL 串长度 |
| `cstring_new` / `cstring_try_new` | owned 分配 |
| `cstring_free` / `cstring_destroy` | 释放 |

错误码：`FFI_OK`、`FFI_ERR_NULL`、`FFI_ERR_INVALID_LEN`、`FFI_ERR_OOM`。

## 结构体 / 回调（STD-151）

| API | 说明 |
|-----|------|
| `FfiPoint { x, y }` | 8 字节 POD |
| `point_pack` / `point_unpack` | 有界读写；cap<8 → `FFI_ERR_TOO_SMALL` |
| `cb_double_i32_fn` / `invoke_i32_cb` | usize 回调调用 |

RFC：`analysis/std-ffi-cstring-lifecycle-v1.md` · `analysis/std-ffi-struct-callback-v1.md`

## Gate

```bash
./tests/run-std-ffi-cstring-lifecycle-gate.sh
./tests/run-std-ffi-struct-callback-gate.sh
```
