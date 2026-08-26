# 阶段 F-03 v2（std.heap libc 层去 C）

> **F-03 v2**：`std/heap/heap.c` 全部逻辑迁至 **`std/heap/libc.x`**（libc FFI + core.mem + trace）；**删除 heap.c / heap.o**。本闸钉 **libc.x 权威**＋产品烟测，不吞其它 STD UNDEF／`check` 债。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `libc.x` | malloc/free/realloc/calloc、typed alloc、copy_*_at、Arena64、XLANG_HEAP_TRACE、alloc_f32 导出 |
| `ops.x` | F-03 v1：mem/map 算法（见 `phase-f-f03-v1.md`） |
| `mod.x` | import heap_libc + heap_ops；无 extern heap_*_c |
| 删除 | `std/heap/heap.c`、链接表无 always-resolve `heap.o` |
| LSP | `lsp_io_std_heap.x` 直链 malloc／libc 面 |
| 存量 | F-01 inventory 由闸硬钉（baseline 回归） |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`, hard-fail
static manifest + F-01 inventory + `tests/run-heap.sh` + STD-017
`run-std-heap-trace-gate.sh` (no soft `die→exit 0`, no prefer-c, no SKIP→OK
when no native). Soft `XLANG_F03_HEAP_LIBC_FAIL` retired. Report
`inventory=` / `run=` / `trace=` / `skip=`.

```bash
./tests/run-f03-std-heap-libc-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f03-std-heap-libc-gate.sh
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-heap.sh
XLANG=./compiler/xlang_asm XLANG_SKIP_SUBSCRIPT_MAKE=1 ./tests/run-std-heap-trace-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F03_HEAP_LIBC_FAIL` path retired; gate always hard).
