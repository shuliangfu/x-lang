# STD-036 std.csv 整行解析与 write_row v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`next_field` / `escape` / `unescape`（既有）、RFC 4180

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-036 | `parse_row` 整行解析 + `write_row` 行写入 |
| 验收 | RFC 4180 边界金样 + `run-std-csv-row-gate.sh` 全绿 |

---

## 2. API

| API | 说明 |
|-----|------|
| `next_field` | 单字段增量解析（既有） |
| `parse_row` | 从 `offset` 解析一整行至换行；输出 `field_starts`/`field_lens`/`out_count` |
| `write_row` | 将 `count` 个字段（`data` + `starts`/`lens` 切片）写入 `buf` 并追加 `\n` |
| `escape` / `unescape` | 字段级转义（既有） |

`write_row` 在字段含 `,` `"` 或换行时自动调用 `csv_escape_c` 引号包裹。

---

## 3. 边界向量（金样）

`tests/csv/row_roundtrip.sx`：

1. `alice,bob,1` write → parse round-trip  
2. 含逗号字段 `a,b` 引号包裹  
3. 空字段 `a,,b`

既有 `tests/csv/main.sx` 覆盖 `next_field` / `escape` / `unescape` 回归。

---

## 4. 实现

- C：`std/csv/csv.c`（`csv_parse_row_c` / `csv_write_row_c`）
- `.sx`：`std/csv/mod.sx` extern 门面
- 链接：与既有 `csv.o` 相同（`ensure_std_c_o`）

---

## 5. Gate

```bash
./tests/run-std-csv-row-gate.sh
```

manifest：`tests/baseline/std-csv-row.tsv`
