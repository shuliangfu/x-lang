# STD-019 std.fmt 多参数 format 与 core.fmt 对齐 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1，函数重载）**  
> 关联：`NEXT.md` STD-019、`core.fmt` CORE-010

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-019 | `format` 多字段重载（原两/三字段）通过**函数重载**覆盖 core.fmt 宽度/指针/布尔/浮点类型 |

无占位符解析；按序直接写 `buf`。同名多函数，调用点按实参类型分派，**无** `format_i32_i32` 等兼容别名。

---

## 2. API（overload）

### 2.1 format（两字段）

| 重载形参 | 段类型 |
|----------|--------|
| `format(..., u64, u64)` | u64 + u64 |
| `format(..., usize, usize)` | usize + usize |
| `format(..., isize, i32)` | isize + i32 |
| `format(..., i32, usize)` | i32 + usize |
| `format(..., *u8, i32)` | ptr(0x) + i32 |
| `format(..., bool, bool)` | bool + bool |
| `format(..., f64, i32)` | f64 + i32 |

另有 i32/u32/i64 等整数组合重载，内部委托 `core.fmt.fmt_scalar_to_buf`。

`ptr_to_buf` 自 core.fmt 重导出，供指针段格式化复用。

### 2.2 format（三字段）

| 重载形参 | 段类型 |
|----------|--------|
| `format(..., i32, i32, i32)` | i32 × 3 |
| `format(..., i32, u32, usize)` | i32 + u32 + usize |

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `format(10, 20)` | len=4 |
| `format(1 as usize, 2 as usize)` | len=3 (`"12"`) |
| `format(null_ptr, 0)` | 以 `0x` 开头 |
| `format(1, 2, 3)` | len=3 |
| cap 不足 | -1 |

---

## 4. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/fmt-std/format_multi.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。
- 构建入口：`./xbuild`／闸脚本（**拒** `make -C compiler` 复活为活权威）。

```
xlang: [XLANG_STD_FMT_MULTI] status=ok check=0|1 run=1 skip=0
std-fmt-multi gate OK
```

- manifest：`tests/baseline/std-fmt-multi.tsv`
- 烟测：`tests/fmt-std/format_multi.x`
- 回归：`tests/run-fmt-std.sh`
- 闸：`tests/run-std-fmt-multi-gate.sh`

---

## 5. 演进

- `format!` 宏与占位符；与 CORE-011 f64 NaN/Inf 策略联动。
