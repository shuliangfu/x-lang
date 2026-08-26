# 阶段 F-03 v1（std.heap 算法层去 C）

> **F-03 v1**：`heap_mem_set_c` / `heap_mem_compare_c` / `map_i32_i32_find_c` 从 **`heap.c` 迁至 `std/heap/ops.x`**（经 `core.mem`）。后续 F-03 v2（heap-libc）已删 `heap.c`；本闸只钉 **ops.x 算法权威**，不吞 STD-144 mem-safe／`check` 债。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `ops.x` | mem set/compare + map 线性探测 |
| `mod.x` | 薄转发；不再 extern 上述符号 |
| `heap.c` | 算法符号已迁出；整文件删除见 F-03 v2 heap-libc |
| 存量 | F-01 inventory 由闸硬钉（baseline 回归） |

## 延后（F-03 v2+／邻域）

| 模块 | 说明 |
|------|------|
| `heap.c` malloc 层 | → `libc.x`（见 `phase-f-f03-v2-heap.md`） |
| STD-144 mem-safe | 独立闸；自举期 `check` 暂停 + asm UNDEF 残债，不挂本闸硬路径 |
| `std/fs` / `std/io` | 见各自 F-03 闸 |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`, hard-fail
static manifest + F-01 inventory + `tests/run-heap.sh` (no soft `die→exit 0`, no
prefer-c, no SKIP→OK when no native; no mem-safe/`check` sub-gate). Report
`inventory=` / `run=` / `skip=`.

```bash
./tests/run-f03-std-heap-ops-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f03-std-heap-ops-gate.sh
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-heap.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F03_HEAP_OPS_FAIL` path retired; gate always hard).
