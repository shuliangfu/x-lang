# 阶段 F-math v1（std.math 去 C）

> **F-math v1**：删除 **`math.c`**；**`math.x`** + **`compiler/seeds/runtime_math_libm.from_x.c`**（F-ZC）；链接 exe 仍须 **-lm**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `math.c` | `math.x` + `runtime_math_libm.from_x.c` |
| `math.o` | `ld -r` x + glue | 纯 `xlang -backend asm math.x` |
| libm/fenv | `std/math/math_libm_glue.c` | `compiler/runtime_math_libm.o` |
| 存量 | std 83 `.c` | std **53** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/math/math.c`~~ | v1 删除 |
| ~~`std/math/math_libm_glue.c`~~ | F-ZC 迁入 compiler seeds |

## 构建

```bash
./xbuild  # was: make -C compiler ../std/math/math.o
```

## Gate

Honesty (2026-08-27): hard-fail static＋ensure; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_MATH_V1_FAIL` retired. STD-115 special／STD-059 fenv product smoke observational (typeck／product residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-math-v1-gate.sh
```
