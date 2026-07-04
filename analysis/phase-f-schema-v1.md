# 阶段 F-schema v1（std.schema 去 C）

> **F-schema v1**：删除 **`schema.c`**；锚点 **`schema.x`**；typed decode 在 **`schema_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `schema.c`（680 行） | `schema.x` + `schema_glue.c` |
| `schema.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_SCHEMA_V1_FAIL=1 ./tests/run-f-schema-v1-gate.sh
./tests/run-std-schema-gate.sh
```

## 下一项

- **F-socketio v1** ✅
