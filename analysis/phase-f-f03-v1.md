# 阶段 F-03 v1（std.heap 算法层去 C）

> **F-03 v1**：`heap_mem_set_c` / `heap_mem_compare_c` / `map_i32_i32_find_c` 从 **`heap.c` 迁至 `std/heap/ops.sx`**（经 `core.mem`）；`heap.c` 仍保留 malloc/realloc/copy/arena/trace。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `ops.sx` | mem set/compare + map 线性探测 |
| `mod.sx` | 薄转发；不再 extern 上述符号 |
| `heap.c` | 删除 ~45 行算法；libc 分配层保留 |
| 存量 | F-01 仍为 **107** `.c`（heap.c 未删） |

## 延后（F-03 v2+）

| 模块 | 说明 |
|------|------|
| `heap.c` malloc 层 | → libc FFI `.sx`（bootstrap 链入表 F-06） |
| `std/io/io.c` | 3387 行 |
| `std/fs/fs.c` | 1106 行 |

## 复现

```bash
SHUX_F03_HEAP_OPS_FAIL=1 ./tests/run-f03-std-heap-ops-gate.sh
./tests/run-heap.sh
./tests/run-std-mem-safe-gate.sh
```
