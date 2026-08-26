# 阶段 F-simd v1（std.simd 去 C + F-ZC）

> **F-simd v1**：删除 **`simd.c`**；策略/HW/烟测均在 **`simd.x`**；**F-ZC** 删除 **`simd_os_glue.c`**。

## 变更

| 项 | 前 | v1 | F-ZC |
|----|----|-----|------|
| 实现 | `simd.c` | `simd.x` + glue | **纯 `.x`** |
| HW/烟测 | C #if | `simd_os_glue.c` | **`.x` 内** |
| `simd.o` | `cc -c` | `ld -r` | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SIMD_V1_FAIL` retired. Delegates STD-153 autovec + STD-061 prod + intrinsic + shuffle-select hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-simd-v1-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
./tests/run-std-simd-prod-gate.sh
./tests/run-std-simd-intrinsic-gate.sh
./tests/run-std-simd-shuffle-select-gate.sh
```

## 下一项

- **F-ZC** process_arg / test_glue / Z2 async
