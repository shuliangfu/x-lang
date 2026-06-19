# STD-116：std.json 类型化 decode v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-json-typed-decode.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-json-typed-decode.tsv` |
| 3 | `./tests/run-std-json-typed-decode-gate.sh` |

---

## 2. 类型化 decode

| API | 说明 |
|-----|------|
| `cursor_value_type` | 窥视值种类（null/bool/number/string/object/array） |
| `decode_i32_at` / `decode_f64_at` / `decode_bool_at` / `decode_string_at` | 游标处标量解码 |
| `object_decode_i32` / `object_decode_bool` / `object_decode_string` | 按 key 解码 object 字段 |
| `json_decode_missing` / `json_decode_type` | 缺字段 / 类型不匹配 |

---

## 3. 金样

文档 `{"name":"alice","age":30,"ok":true}`：

- `object_decode_i32(..., "age", 30)`
- `object_decode_bool(..., "ok", true)`
- `object_decode_string(..., "name", "alice")`

---

## 4. 验证与门禁

```bash
./tests/run-std-json-typed-decode-gate.sh
```
