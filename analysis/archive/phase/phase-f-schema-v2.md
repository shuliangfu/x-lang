# 阶段 F-schema v2（std.schema 逻辑 .x 下沉）

> **F-schema v2**：**JSON/CSV typed decode** 全量在 **`schema.x`**；**删除 `schema_glue.c`**；`schema.o` 纯 `.x` 编译（同 cache/encoding）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| decode 实现 | `schema_glue.c`（677 行） | **`schema.x`** |
| `schema.o` | `ld -r` glue + x | **纯 xlang → schema.o** |
| JSON/CSV 依赖 | glue 链 json.o/csv.o | `extern json_*` / `parse_row` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_SCHEMA_V2_FAIL` retired. STD-090 schema product residual observational (fossil `schema_new` / smoke).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-schema-v2-gate.sh
./tests/run-std-schema-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（其它模块 v2）
