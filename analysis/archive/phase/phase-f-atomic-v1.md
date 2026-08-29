# 阶段 F-atomic v1（std.atomic 去 C）

> **F-atomic v1**：删除 **`atomic.c`**；**`atomic.x`** + **`compiler/src/asm/runtime_atomic_glue.c`**（F-ZC）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `atomic.c`（357 行） | `atomic.x` + `runtime_atomic_glue.c` |
| `atomic.o` | `ld -r` 合并 | 纯 `.x` |
| 原子胶层 | `std/atomic/atomic_glue.c` | `compiler/runtime_atomic_glue.o` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_ATOMIC_V1_FAIL` retired. Delegates STD-046 atomic-ordering hard. STD-146 widen observational (product residual).

**2026-08-30 leftover XLANG fallthrough 已收**（f-atomic-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-atomic-ordering／std-atomic-widen 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-atomic-v1-gate.sh
./tests/run-std-atomic-ordering-gate.sh
```

## 下一项

- **F-channel v1** / **F-crypto v1** / **F-thread v1**
