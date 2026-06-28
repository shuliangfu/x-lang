# std.math — 数学函数与 fenv

对标 **Zig** `std.math`、**Rust** `std::f64::consts` + libm。

## 初等函数

`pi` / `e` / `tau`；`floor` / `ceil` / `trunc` / `round`；三角/反三角；`sqrt` / `cbrt` / `pow` / `exp` / `log`；`erf` / `log1p` / `expm1`（STD-115）。

## 实现

- **公开 API**（`mod.sx`）：`pi` / `floor` / `sin` / `erf` / `fenv_available` 等短名；`extern math_*_c` 经 `unsafe` 包装。
- **C 层**（`math_*_c`）：常量 `math_pi_c` 等在 `math.sx`；libm / signum / special_smoke 在 `runtime_math_libm.c`。
- 链接需 **`-lm`** 与 `runtime_math_libm.o`。

## fenv（STD-059 / STD-149）

| API | 说明 |
|-----|------|
| `fenv_available()` | 1=平台支持 fenv，0=stub |
| `test_exceptions` / `clear_exceptions` / `raise_exceptions` | sticky 异常标志 |
| `FENV_NOT_IMPL` (-9) | stub 平台返回值 |

| 平台 | `fenv_available()` |
|------|-------------------|
| Darwin / Linux | 1 |
| Windows / Android | 0 |

RFC：`analysis/std-math-fenv-v1.md` · `analysis/std-math-fenv-capability-v1.md`

## Gate

```bash
./tests/run-std-math-fenv-gate.sh
./tests/run-std-math-fenv-capability-gate.sh
./tests/run-std-math-special-gate.sh
```
