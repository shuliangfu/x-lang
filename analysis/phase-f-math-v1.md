# 阶段 F-math v1（std.math 去 C）

> **F-math v1**：删除 **`math.c`**；**`math.x`** + **`compiler/src/asm/runtime_math_libm.c`**（F-ZC）；链接 exe 仍须 **-lm**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `math.c` | `math.x` + `runtime_math_libm.c` |
| `math.o` | `ld -r` x + glue | 纯 `shux -backend asm math.x` |
| libm/fenv | `std/math/math_libm_glue.c` | `compiler/runtime_math_libm.o` |
| 存量 | std 83 `.c` | std **53** `.c` |

## 门禁

```bash
SHUX_F_MATH_V1_FAIL=1 ./tests/run-f-math-v1-gate.sh
./tests/run-std-math-special-gate.sh
./tests/run-std-math-fenv-gate.sh
```
