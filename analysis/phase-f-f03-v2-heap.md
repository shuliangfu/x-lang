# 阶段 F-03 v2（std.heap libc 层去 C）

> **F-03 v2**：`std/heap/heap.c` 全部逻辑迁至 **`std/heap/heap_libc.sx`**（libc FFI + core.mem + trace）；**删除 heap.c / heap.o**。

## v2 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `heap_libc.sx` | malloc/free/realloc/calloc、typed alloc、copy_*_at、Arena64、SHUX_HEAP_TRACE、alloc_f32 导出 |
| `heap_ops.sx` | F-03 v1：mem/map 算法（不变） |
| `mod.sx` | import heap_libc + heap_ops；无 extern heap_*_c |
| 删除 | `std/heap/heap.c`、`Makefile` heap.o、链接表 heap.o |
| LSP | `lsp_io_std_heap.sx` / `lsp_diag.sx` 直链 libc 或 std_heap_* |
| 链接 | `runtime_link_abi.c` 按需 `-lc`（malloc/heap_alloc_c/getenv） |
| 存量 | F-03 v2 后 std+core 手写 `.c` **105**（较 F-03 v1 107 减 2：含 heap.c 等） |

## 复现

```bash
SHUX_F03_HEAP_LIBC_FAIL=1 ./tests/run-f03-std-heap-libc-gate.sh
SHUX_STD_HEAP_TRACE_FAIL=1 ./tests/run-std-heap-trace-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=105
./tests/run-heap.sh
```
