# STD-035 std.json object/array 序列化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-034`（游标解析）、`STD-008`（标量 append）

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-035 | `append_object` / `append_array` 增量序列化 + **round-trip** 金样 |
| 验收 | `run-std-json-serialize-gate.sh` 全绿 |

---

## 2. API（offset 写入 `buf[offset..]`）

| API | 说明 |
|-----|------|
| `append_object` / `append_object_end` | `{` / `}` |
| `append_array` / `append_array_end` | `[` / `]` |
| `append_comma` | `,` |
| `append_key` | `"key":`（键经 escape） |
| `append_string_value` | 转义字符串值 |
| `append_number_at` | 数字值（offset 版） |

标量 `append_null` / `append_bool` / `append_number` 仍从 `buf[0]` 写入；复合构建用 offset API 组合。

---

## 3. round-trip 金样

`tests/json/object_array_roundtrip.sx`：

1. 用 `append_*` 构建 `{"name":"alice","age":30,"tags":["a","b"]}`
2. `skip_value` 校验整文档
3. `JsonCursor` 解析校验 name / age / tags

---

## 4. 门禁

```bash
./tests/run-std-json-serialize-gate.sh
```

manifest：`tests/baseline/std-json-serialize.tsv`
