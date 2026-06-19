# CORE-011 core.fmt f64 NaN/Inf 与精度策略 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-011、`core/fmt/mod.sx`、`std/fmt/mod.sx`

---

## 1. 目标

补齐 `fmt_f64_to_buf` 对 IEEE 754 特殊值的稳定输出，并暴露可配置精度 API，供调试日志与 std.fmt 重导出。

| API | 行为 |
|-----|------|
| `FMT_F64_DEFAULT_PREC` | 常量 `6`；`fmt_f64_to_buf` 默认小数位 |
| `fmt_f64_is_nan` | `x != x` |
| `fmt_f64_is_inf` | 非 NaN、非零且 `x + x == x` |
| `fmt_f64_to_buf_prec` | `prec` 0–9；截断取整；非法 prec 返回 -1 |
| `fmt_f64_to_buf` | 委托 `fmt_f64_to_buf_prec(..., FMT_F64_DEFAULT_PREC)` |

---

## 2. 特殊值金样

| 输入 | 输出 | len |
|------|------|-----|
| NaN | `NaN` | 3 |
| +Inf | `Inf` | 3 |
| -Inf | `-Inf` | 4 |
| 1.5（默认 prec） | `1.500000` | 8 |
| 3.14159（prec=2） | `3.14` | 4 |
| 3.14159（prec=0） | `3` | 1 |
| -2.75（prec=2） | `-2.75` | 5 |

NaN/Inf 检测不依赖 `std.math` 或 OS；烟测用 `0.0/0.0` 与 `1e200*1e200` 构造。

---

## 3. 精度策略

- **范围**：`prec ∈ [0, 9]`；超出返回 -1。
- **截断**：小数位逐位乘 10 后取整，不四舍五入（与 v0 行为一致）。
- **prec=0**：仅写整数部分，无小数点。
- **容量**：不足时返回 -1；特殊值按固定长度校验。

---

## 4. 与 std.fmt 关系

- `std.fmt` 重导出 `fmt_f64_to_buf` / `fmt_f64_to_buf_prec`。
- 特殊值字符串与 Rust `Debug` 风格对齐（`NaN` / `Inf` / `-Inf`）。

---

## 5. Gate

- manifest：`tests/baseline/core-fmt-f64-special.tsv`
- typeck：`shux check tests/fmt/f64_special.sx`
- 报告：`shux: [SHUX_CORE_FMT_F64_SPECIAL] status=ok`

---

## 6. 演进

- 四舍五入模式（`prec` + `Rounding`）留待后续 RFC。
- `f32` 格式化复用本策略（非 CORE-011 范围）。
