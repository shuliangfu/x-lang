# 阶段 F-08 v1（core/ 手写 C 存量确认）

> **F-08 v1**：确认 **`core/`** 手写 `.c` 与 **mod.x** / 专 gate 对齐。  
> **G-01 闭合**：`find core -name '*.c' | wc -l` = **0**（四文件已迁入 mod.x / 内建）。

## v1 历史存量（已退役；档案）

| 文件（已删） | 模块 | gate |
|------|------|------|
| `core/builtin/builtin.c` | bitops 内建 | `run-core-builtin-bitops-gate.sh` |
| `core/mem/mem.c` | mem intrinsic | `run-core-mem-intrinsic-gate.sh` |
| `core/slice/slice.c` | slice API | `run-core-slice-api-gate.sh` |
| `core/debug/debug.c` | assert 扩展 | `run-core-debug-assert-extend-gate.sh` |

## Gate

Honesty gate (2026-08-26): hard-fail archive DOC + zero-core + F-01
inventory. No soft `die→exit 0`. Soft `XLANG_F08_CORE_INVENTORY_FAIL`
retired. Report `doc=` / `manifest=` / `core_zero=` / `inventory=` /
`skip=`. Live face = this archive path (refuse top-level resurrect).

```bash
./tests/run-f08-core-inventory-gate.sh
./tests/run-std-c-inventory-gate.sh
```

## 终局（v2+ · 已达）

- 四文件迁入编译器内建 / mod.x；`find core -name '*.c' | wc -l` = 0 ✅
