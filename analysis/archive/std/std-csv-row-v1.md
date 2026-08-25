# STD-036 std.csv 整行解析与 write_row v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`next_field` / `escape` / `unescape`（既有）、RFC 4180

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-036 | `parse_row` 整行解析 + `write_row` 行写入 |
| 验收 | RFC 4180 边界金样 + `run-std-csv-row-gate.sh` 全绿（`check=`／`run=`／`skip=`） |

---

## 2. API

| API | 说明 |
|-----|------|
| `next_field` | 单字段增量解析（既有） |
| `parse_row` | 从 `offset` 解析一整行至换行；输出 `field_starts`/`field_lens`/`out_count` |
| `write_row` | 将 `count` 个字段（`data` + `starts`/`lens` 切片）写入 `buf` 并追加 `\n` |
| `escape` / `unescape` | 字段级转义（既有） |

`write_row` 在字段含 `,` `"` 或换行时自动调用 `csv_escape_c` 引号包裹。

实现：`std/csv/csv.x`（F-csv v1 纯 .x）；`.x` 门面 `std/csv/mod.x` extern；链接与既有 `csv.o` 相同。

---

## 3. 边界向量（金样）

`tests/csv/row_roundtrip.x`：

1. `alice,bob,1` write → parse round-trip  
2. 含逗号字段 `a,b` 引号包裹  
3. 空字段 `a,,b`

既有 `tests/csv/main.x` 覆盖 `next_field` / `escape` / `unescape` 回归。

---

## 4. Gate

```bash
./tests/run-std-csv-row-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `row_roundtrip.x` + `main.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`；两路烟测都过才 `run=1`）

manifest：`tests/baseline/std-csv-row.tsv`

### Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；未啃产品 `std/csv`）。
