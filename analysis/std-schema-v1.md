# STD-090 std.schema v1

> 更新时间：2026-06-18  
> 状态：**可用** — Schema 注册 + JSON/CSV/列映射 decode + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-schema-manifest.tsv` |
| 3 | `./tests/run-std-schema-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `schema_new` / `schema_add_field` | 字段类型注册（标量/可选/col_index） |
| `decode_json` | JSON 对象 typed decode + 校验错误 |
| `decode_csv_row` | CSV 行按 col_index 映射 |
| `map_columns` | SQLite/CSV 列文本统一映射 |
| `get_string` / `get_i32` / `get_bool` / `get_f64` | 读取 decode 结果 |
| `last_error_field` / `last_error_message` | 字段级错误路径 |
| `schema_to_error_code` | 与 std.error 负码桥接 |

实现：`std/schema/mod.sx` + `std/schema/schema.c`；链入 json + csv。

---

## 3. Gate

```
shux: [SHUX_STD_SCHEMA] status=ok c_smoke=1 su=1 skip=0
std-schema gate OK
```

---

## 4. 后续（非 v1 阻塞）

- 嵌套 object / array 字段  
- 与 std.sqlite stmt 一步 decode  
- JSON Schema 子集导入  
