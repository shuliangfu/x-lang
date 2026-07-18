# 阶段 F-context v1（std.context 去 C）

> **F-context v1**：删除 **`context.c`**；Context 树逻辑在 **`context.x`**；节点/原子在 **`context_node_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `context.c`（253 行） | `context.x` + `context_node_glue.c` |
| `context.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_CONTEXT_V1_FAIL=1 ./tests/run-f-context-v1-gate.sh
./tests/run-std-context-gate.sh
```

## 下一项

- **F-context v2** ✅ / **F-sync v1** ✅
