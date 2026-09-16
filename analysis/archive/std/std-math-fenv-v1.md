# STD-059：std.math 浮点环境异常标志 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1 可选）**  
> 关联：`std/math/math.c`（`-lm`）、ISO C `<fenv.h>`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-math-fenv.tsv` |
| 3 | `./tests/run-std-math-fenv-gate.sh` |

---

## 2. fenv API（v1 可选）

| API | C 映射 | 说明 |
|-----|--------|------|
| `test_exceptions(mask)` | `fetestexcept` | 读 sticky 异常 |
| `clear_exceptions(mask)` | `feclearexcept` | 清除标志 |
| `raise_exceptions(mask)` | `feraiseexcept` | 诊断置位 |

**平台**：macOS / Linux（glibc）启用；无 `<fenv.h>` 时返回 `FENV_NOT_IMPL`（`-9`）。

**v1 非目标**：舍入模式 `fesetround`、异常 trap `feenableexcept`（留待后续）。

---

## 3. 异常掩码

| 常量 | 值（Darwin/glibc） | 含义 |
|------|---------------------|------|
| `FENV_INVALID` | 1 | 无效运算 |
| `FENV_DIVBYZERO` | 2 | 除零 |
| `FENV_OVERFLOW` | 4 | 上溢 |
| `FENV_UNDERFLOW` | 8 | 下溢 |
| `FENV_INEXACT` | 16 | 不精确 |
| `FENV_ALL` | 31 | 低 5 位组合 |

---

## 4. 金样烟测

| 步骤 | 期望 |
|------|------|
| `0.0/0.0` | `FE_INVALID` 置位 |
| `clear_exceptions(FENV_INVALID)` | 清除成功 |
| `raise_exceptions(FENV_OVERFLOW)` | `FE_OVERFLOW` 置位 |

烟测：`tests/std-math/fenv_smoke_ok.c`（C）、`fenv_clear.x`（clear/test 路径）。

---

## Gate

```bash
./tests/run-std-math-fenv-gate.sh
```

Honesty (2026-08-28): prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。无 fenv／缺预编 runtime：C 烟测＝obs（非 soft SKIP→OK）。
