# 阶段 F-schema v2（std.schema 逻辑 .x 下沉）

> **F-schema v2**：**JSON/CSV typed decode** 全量在 **`schema.x`**；**删除 `schema_glue.c`**；`schema.o` 纯 `.x` 编译（同 cache/encoding）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| decode 实现 | `schema_glue.c`（677 行） | **`schema.x`** |
| `schema.o` | `ld -r` glue + x | **纯 shux → schema.o** |
| JSON/CSV 依赖 | glue 链 json.o/csv.o | `extern json_*` / `parse_row` |

## 门禁

```bash
SHUX_F_SCHEMA_V2_FAIL=1 ./tests/run-f-schema-v2-gate.sh
./tests/run-std-schema-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-config v2**（TOML/YAML/ENV 逻辑下沉）
