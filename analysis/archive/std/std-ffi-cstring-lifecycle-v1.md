# STD-055：std.ffi CString 生命周期与错误码 v1

> 状态：**定版（v1）** · soft→硬绿 honesty（2026-08-25）  
> 关联：**TYPE-004**（`*u8` 桥接）、**SAFE-004**（C1–C7 契约）；live roadmap = `analysis/自举进度.md`（勿复活顶层 NEXT.md）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-ffi-cstring-lifecycle.tsv` |
| 3 | `./tests/run-std-ffi-cstring-lifecycle-gate.sh` |

---

## 2. 错误码（与 cstr_len / try_new 对齐）

| 常量 | 值 | 含义 |
|------|-----|------|
| `FFI_OK` | 0 | 成功 |
| `FFI_ERR_NULL` | -1 | 空指针（`cstr_len(null)` 同值） |
| `FFI_ERR_INVALID_LEN` | -2 | `len < 0` |
| `FFI_ERR_OOM` | -3 | `malloc` 失败 |

TYPE-004：跨边界传递 `*u8` + `len`；owned 缓冲用 `cstring_try_new` 显式错误码，避免仅判 null。

---

## 3. 生命周期 API

| API | 说明 |
|-----|------|
| `cstring_new` | 失败返回 null（SAFE-004 兼容） |
| `cstring_try_new(ptr, len, out: *usize)` | 成功 `FFI_OK` 且 `*out` 为指针位模式 |
| `cstring_free` / `cstring_destroy` | 释放 owned；**恰好一次**（C6） |

```su
let owned: usize = 0;
let ec: i32 = cstring_try_new(&src[0], 3, &owned);
if (ec != 0) { return 1; }
let p: *u8 = owned as *u8;
cstring_destroy(p);
```

---

## 4. SAFE-004 映射

| 规则 | STD-055 |
|------|---------|
| C1-null | `cstr_len` → `FFI_ERR_NULL` |
| C3/C4 | `cstring_try_new` + `FFI_OK` |
| C5/C6 | `cstring_destroy` |

回归：`tests/run-safe-ffi-contract-gate.sh` 仍须通过（闸门硬失败）。

---

## 5. Gate

Honesty（2026-08-25）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c 静默 remap）。
- `xlang check` **观测**（自举期暂停闸门 2026-08-05）；CHK002 等不得硬红。
- 产品烟测 `cstring_try_new.x` **exit 0 硬失败**（有原生 xlang 时禁止 soft SKIP）。
- Host-C smoke **仅观测**（archaeology；非硬绿信号）。
- SAFE-004 回归 **硬失败**。
- 报告：`check=`／`run=`／`safe004=`／`skip=`（`run=1`＋`safe004=1` 为硬绿信号）。

```
xlang: [XLANG_STD_FFI_CSTRING] status=ok check=0|1 run=1 safe004=1 skip=0
std-ffi-cstring gate OK
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | FFI_ERR_* + cstring_try_new + cstring_destroy |
| v1.1 | 2026-08-25 | soft→硬绿 honesty：prefer asm／check 观测／runnable+SAFE-004 硬失败 |
