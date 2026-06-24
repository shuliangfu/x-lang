# 阶段 F-atomic v1（std.atomic 去 C）

> **F-atomic v1**：删除 **`atomic.c`**；**`atomic.sx`** + **`compiler/src/asm/runtime_atomic_glue.c`**（F-ZC）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `atomic.c`（357 行） | `atomic.sx` + `runtime_atomic_glue.c` |
| `atomic.o` | `ld -r` 合并 | 纯 `.sx` |
| 原子胶层 | `std/atomic/atomic_glue.c` | `compiler/runtime_atomic_glue.o` |

## 门禁

```bash
SHUX_F_ATOMIC_V1_FAIL=1 ./tests/run-f-atomic-v1-gate.sh
./tests/run-std-atomic-ordering-gate.sh
./tests/run-std-atomic-widen-gate.sh
```

## 下一项

- **F-channel v1** / **F-crypto v1** / **F-thread v1**
