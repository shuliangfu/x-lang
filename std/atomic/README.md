# std.atomic — 原子操作

与 **Rust** `std::sync::atomic`、**Zig** `std.atomic` 对标。

**模块路径**：`std/atomic/mod.x` + `std/atomic/atomic.x` + `compiler/src/asm/runtime_atomic_glue.c`（F-atomic v2 / F-ZC）

## 类型覆盖

| 宽度 | load/store | compare_exchange | fetch_add | fetch_sub |
|------|------------|------------------|-----------|-----------|
| i32 / u32 | ✅ | ✅ | ✅ | i32 ✅ |
| **i16 / u16** | ✅ STD-146 | ✅ | ✅ | - |
| **i64 / u64** | ✅ | ✅ STD-146 | ✅ STD-146 | ✅ STD-146 |

## Ordering / Fence（STD-046）

| API | 说明 |
|-----|------|
| `ORDER_RELAXED` … `ORDER_SEQ_CST` | 与 C11 memory_order 数值对齐 |
| `fence_seq_cst` / `fence_acquire` / `fence_release` | 内存栅栏 |

v1 默认 **seq_cst**；带 Ordering 参数的重载后续扩展。

## 文档

- `analysis/std-atomic-ordering-v1.md`（STD-046）
- `analysis/std-atomic-widen-v1.md`（STD-146）

## Gate

```bash
./tests/run-std-atomic-ordering-gate.sh
./tests/run-std-atomic-widen-gate.sh
./tests/run-f-atomic-v1-gate.sh
```
