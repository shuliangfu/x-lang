# STD-115：std.math 特殊函数 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-math-special.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-math-special.tsv` |
| 3 | `./tests/run-std-math-special-gate.sh` |

---

## 2. 特殊函数

| API | 说明 |
|-----|------|
| `erf` | 误差函数 |
| `erfc` | 互补误差函数 1-erf(x) |
| `log1p` | log(1+x)，小 x 稳定 |
| `expm1` | exp(x)-1，小 x 稳定 |
| `special_smoke` | C 金样烟测 |

实现委托 libm（链接 `-lm`）。

---

## 3. 金样

| x | erf(x) |
|---|--------|
| 0 | 0 |
| 1 | 0.8427007929497149 |

---

## Gate

```bash
./tests/run-std-math-special-gate.sh
```

Honesty (2026-08-28): prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `math.o`＋`runtime_math_libm.o`＋`runtime_process_argv.o`＝obs；check＋tip product UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。
