# json-object-array std.json object/array 解析 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 历史 ID：`STD-034`（游标解析；与 http-https STD-034 编号撞车，tracker 用 **json-object-array**）  
> 关联：`STD-008`（`parse_string_view` ZC）、`STD-016`（StrView）、`STD-035`（serialize）

---

## 1. 目标

| ID | 交付 |
|----|------|
| json-object-array | `std.json` object/array **游标遍历** + `skip_value` |
| 文档 | 大对象 ZC 策略：mmap 缓冲 + cursor + `parse_string_view` |
| 验收 | `run-std-json-object-array-gate.sh` 全绿（`check=`／`oa=`／`skip=`） |

---

## 2. API（cursor/parse）

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

实现：`json_skip_value_c`、`json_cursor_*_c` in `std/json/json.x`（co-emit／glue）。

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

`tests/json/object_array_parse.x`：

- `skip_value` 整文档
- 遍历 `{"name":"alice","age":30,"tags":["a","b"]}`
- name → `parse_string_view`；age → `parse_number`；tags → array 2 元素

---

## 5. Gate

```bash
./tests/run-std-json-object-array-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `object_array_parse.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- 报告行：`check=`／`oa=`／`skip=`（硬绿信号＝`oa=`）

manifest：`tests/baseline/std-json-object-array.tsv`  
CI：`tests/run-portable-suite.sh`（与 STD-008 gate 并存）

旧闸偏 `xlang-c`／硬 check（CHK002）／无 native c 则 soft SKIP 却报 OK／section `## 5. 验收`＝portable 假红；产品 asm 烟测本绿。

### Changelog

| Ver | Date | Note |
|-----|------|------|
| v1.0 | 2026-06-17 | 定版：cursor/parse + ZC 策略 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；`## 5. Gate`；报告 `check=`／`oa=`／`skip=` |

---

## 6. 演进（STD-035）

- `append_object` / `append_array` 序列化 — **已 soft→硬绿**
- `cursor_object_find` 快捷路径
- 与 `std.string.StrView` 类型别名衔接
