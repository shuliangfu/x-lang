# STD-019 std.fmt 多参数 format 与 core.fmt 对齐 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1，函数重载）**  
> 关联：`NEXT.md` STD-019、`core.fmt` CORE-010

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-019 | `format_2` / `format_3` 通过**函数重载**覆盖 core.fmt 宽度/指针/布尔/浮点类型 |

无占位符解析；按序直接写 `buf`。同名多函数，调用点按实参类型分派，**无** `format_2_i32_i32` 等兼容别名。

---

## 2. API（overload）

### 2.1 format_2

| 重载形参 | 段类型 |
|----------|--------|
| `format_2(..., u64, u64)` | u64 + u64 |
| `format_2(..., usize, usize)` | usize + usize |
| `format_2(..., isize, i32)` | isize + i32 |
| `format_2(..., i32, usize)` | i32 + usize |
| `format_2(..., *u8, i32)` | ptr(0x) + i32 |
| `format_2(..., bool, bool)` | bool + bool |
| `format_2(..., f64, i32)` | f64 + i32 |

另有 i32/u32/i64 等整数组合重载，内部委托 `core.fmt.fmt_scalar_to_buf`。

`fmt_ptr_to_buf` 自 core.fmt 重导出，供指针段格式化复用。

### 2.2 format_3

| 重载形参 | 段类型 |
|----------|--------|
| `format_3(..., i32, i32, i32)` | i32 × 3 |
| `format_3(..., i32, u32, usize)` | i32 + u32 + usize |

---

## 3. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `format_2(10, 20)` | len=4 |
| `format_2(1 as usize, 2 as usize)` | len=3 (`"12"`) |
| `format_2(null_ptr, 0)` | 以 `0x` 开头 |
| `format_3(1, 2, 3)` | len=3 |
| cap 不足 | -1 |

---

## 4. 验收

- manifest：`tests/baseline/std-fmt-multi.tsv`
- 烟测：`tests/fmt-std/format_multi.sx`
- 回归：`tests/run-fmt-std.sh`
- 报告：`shux: [SHUX_STD_FMT_MULTI] status=ok`

---

## 5. 演进

- `format!` 宏与占位符；与 CORE-011 f64 NaN/Inf 策略联动。
