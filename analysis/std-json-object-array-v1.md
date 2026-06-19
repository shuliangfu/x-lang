# STD-034 std.json object/array 解析 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-008`（`parse_string_view` ZC）、`STD-016`（StrView）

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-034 | `std.json` object/array **游标遍历** + `skip_value` |
| 文档 | 大对象 ZC 策略：mmap 缓冲 + cursor + `parse_string_view` |

---

## 2. API（STD-034 新增）

| API | 说明 |
|-----|------|
| `JsonCursor` | `{ ptr, len, off }` 与 C `json_cursor_t` 同布局 |
| `skip_value` | 跳过单个完整 JSON 值 |
| `cursor_init` | 初始化游标 |
| `cursor_enter_object` / `cursor_enter_array` | 进入复合类型 |
| `cursor_object_next` | 读下一 key，游标停在 value |
| `cursor_array_has_elem` | array 是否还有元素 |
| `cursor_skip_value` | 跳过当前 value + 可选逗号 |
| `cursor_peek` | 窥视下一记号 |

实现：`json_skip_value_c`、`json_cursor_*_c` in `std/json/json.c`。

---

## 3. 大对象 ZC 策略

```
fs_mmap_ro / read_ptr  →  buf[len]
       ↓
cursor_init + cursor_enter_object
       ↓
cursor_object_next → parse_string_view（无转义字段零拷贝）
                  → parse_number / skip_value（未知字段）
```

| 场景 | 策略 |
|------|------|
| 已知 string 字段无 `\\` | `parse_string_view` @ `cur.ptr[cur.off]` |
| 含转义字符串 | `parse_string` 拷贝到 arena |
| 未知/嵌套字段 | `cursor_skip_value` 跳过，不分配 |

与 STD-008 一致：**能 view 不 copy**；object/array 遍历不构建 DOM 树。

---

## 4. 烟测

`tests/json/object_array_parse.sx`：

- `skip_value` 整文档
- 遍历 `{"name":"alice","age":30,"tags":["a","b"]}`
- name → `parse_string_view`；age → `parse_number`；tags → array 2 元素

---

## 5. 验收

- manifest：`tests/baseline/std-json-object-array.tsv`
- 门禁：`tests/run-std-json-object-array-gate.sh`
- 报告：`shux: [SHUX_STD_JSON_OBJECT_ARRAY] status=ok`
- CI：`tests/run-portable-suite.sh`（与 STD-008 gate 并存）

---

## 6. 演进（STD-035）

- `append_object` / `append_array` 序列化
- `cursor_object_find` 快捷路径
- 与 `std.string.StrView` 类型别名衔接
