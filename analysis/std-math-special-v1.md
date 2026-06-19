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

## 4. 验证与门禁

```bash
make -C compiler ../std/math/math.o
./tests/run-std-math-special-gate.sh
```
