# std.schema — typed decode/validate

结构化 Schema 注册 + JSON/CSV/SQLite 列映射 typed decode；字段级错误路径。

## API

| API | 说明 |
|-----|------|
| `schema_new` / `schema_free` / `schema_clear` | 创建/释放/清空 |
| `schema_add_field` | 注册字段（类型、optional、CSV col_index） |
| `decode_json` | JSON object typed decode |
| `decode_csv_row` / `map_columns` | CSV / SQLite 列映射 |
| `get_string` / `get_i32` / `get_bool` / `get_f64` | 类型化读取 |
| `last_error_field` / `last_error_message` | 字段级错误 |

## JSON 嵌套与数组（v1）

解码时递归展开键名：

| JSON 形状 | 注册字段示例 |
|-----------|--------------|
| 嵌套 object | `user.name`、`user.age` |
| 标量数组 | `items.0`、`items.1` |
| object 数组 | `users.0.name`、`users.1.name` |

未注册字段会被跳过；必填缺失返回 `schema_err_not_found()`。

## Gate

```bash
./tests/run-std-schema-gate.sh
```

## 参考

- 设计：`analysis/std-schema-v1.md`
