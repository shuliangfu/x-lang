# 阶段 F-08 v1（core/ 手写 C 存量确认）

> **F-08 v1**：确认 **`core/`** 仅保留 **4** 个手写 `.c`（builtin/mem/slice/debug），各有 **mod.x** 与专 gate；终局目标为编译器内建替代（零 core `.c`）。

## v1 存量（✅ manifest）

| 文件 | 模块 | gate |
|------|------|------|
| `core/builtin/builtin.c` | bitops 内建 | `run-core-builtin-bitops-gate.sh` |
| `core/mem/mem.c` | mem intrinsic | `run-core-mem-intrinsic-gate.sh` |
| `core/slice/slice.c` | slice API | `run-core-slice-api-gate.sh` |
| `core/debug/debug.c` | assert 扩展 | `run-core-debug-assert-extend-gate.sh` |

## 门禁

```bash
SHUX_F08_CORE_INVENTORY_FAIL=1 ./tests/run-f08-core-inventory-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 终局（v2+）

- 四文件迁入编译器内建 / mod.x；`find core -name '*.c' | wc -l` = 0
