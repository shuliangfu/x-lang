# std.json — JSON 解析与生成

**模块路径**：`std/json/mod.sx` + `std/json/json.sx` + `std/json/json_parse_glue.c`（F-json v1）  
**对标**：Zig std.json、Rust serde_json（最小子集）。

## API 概览

### 标量解析

- `parse_number` / `parse_null` / `parse_bool` / `parse_string` — 单值解析，返回 consumed 字节数。
- `parse_string_view` — 零拷贝 string view（生命周期绑定输入缓冲）。
- `escape` — 转义写入 buf。

### 游标（object/array）

- `cursor_init` / `cursor_enter_object` / `cursor_object_next` / `cursor_skip_value`
- `cursor_enter_array` / `cursor_array_has_elem` / `cursor_value_type`

### 类型化 decode（STD-116）

- `decode_i32_at` / `decode_f64_at` / `decode_bool_at` / `decode_string_at`
- `object_decode_i32` / `object_decode_bool` / `object_decode_string`
- `object_decode_dotted_i32` / `object_decode_dotted_string` / `object_decode_dotted_bool` / `object_decode_dotted_f64` — 点分路径（如 `user.age`、`items.0`、`metrics.cpu`）

### 序列化

- `append_object` / `append_object_end` / `append_array` / `append_array_end`
- `append_key` / `append_string_value` / `append_number_at` / `append_comma`

## 测试

- `bash tests/run-json.sh`
- cookbook：`examples/cookbook/json_object_parse.sx`
