# 阶段 F-context v2（std.context 节点存储 .x 下沉）

> **F-context v2**：**ctx_node 分配/原子/value 槽** 全量在 **`context.x`**；**删除 `context_node_glue.c`**；`context.o` 纯 `.x` 编译（同 cache v2）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 节点/原子 | `context_node_glue.c`（139 行） | **`context.x`** |
| `context.o` | `ld -r` glue + x | **纯 shux → context.o** |
| cancelled | C11 atomic | `extern atomic_load/store_i32_c` |

## 门禁

```bash
SHUX_F_CONTEXT_V2_FAIL=1 ./tests/run-f-context-v2-gate.sh
./tests/run-std-context-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-sync v1**（已有）/ 其余 std 胶层继续 v2 化
