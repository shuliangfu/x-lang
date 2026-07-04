# 阶段 F-simd v1（std.simd 去 C + F-ZC）

> **F-simd v1**：删除 **`simd.c`**；策略/HW/烟测均在 **`simd.x`**；**F-ZC** 删除 **`simd_os_glue.c`**。

## 变更

| 项 | 前 | v1 | F-ZC |
|----|----|-----|------|
| 实现 | `simd.c` | `simd.x` + glue | **纯 `.x`** |
| HW/烟测 | C #if | `simd_os_glue.c` | **`.x` 内** |
| `simd.o` | `cc -c` | `ld -r` | **纯 `.x`** |

## 门禁

```bash
SHUX_F_SIMD_V1_FAIL=1 ./tests/run-f-simd-v1-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```

## 下一项

- **F-ZC** process_arg / test_glue / Z2 async
