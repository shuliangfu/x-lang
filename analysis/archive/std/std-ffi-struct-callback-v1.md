# STD-151：std.ffi 结构体/回调安全封装 v1

> 状态：**定版（v1）**  
> 关联：`STD-055` CString、`TYPE-004` / `SAFE-004`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-151 | `FfiPoint` pack/unpack + `invoke_cb` + `FFI_ERR_TOO_SMALL` + gate |

v1 提供 **POD 结构体** 与 **usize 回调** 安全边界；复杂布局后续扩展。

---

## 2. 结构体与回调 API

| API | 说明 |
|-----|------|
| `point_pack(buf, cap, x, y)` | 写入 8 字节 POD；cap<8 → `FFI_ERR_TOO_SMALL` |
| `point_unpack(buf, cap, out)` | 读出 `FfiPoint` |
| `cb_double_fn()` | 内置 `arg*2` 回调（usize） |
| `invoke_cb(cb, arg)` | 调用回调；cb=0 → `FFI_ERR_NULL` |

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/ffi/ffi.o`＝obs（拒 soft `ensure_std_c_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` UNDEF／SEGV＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `c=`／`x=`）。

```bash
./tests/run-std-ffi-struct-callback-gate.sh
```

```
xlang: [XLANG_STD151_FFI_STRUCT_CALLBACK] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.
