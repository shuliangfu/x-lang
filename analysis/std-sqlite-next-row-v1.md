# STD-067：std.db next_row 列值游标 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-066 `std-db-query-rows-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-066 `query_rows` 行计数基础上实现 **列值游标原型**：`query_begin` / `next_row` / `row_col_i32` / `query_end`。

验收：`tests/run-std-db-next-row-gate.sh` 绿；`min_cursor_apis=3`；C 烟测 `cursor_c=1`。

---

## 2. next_row API（v1）

| API | v1 行为 |
|-----|---------|
| `query_begin` | `sqlite3_prepare_v2`，返回 `DbRowCursor` |
| `next_row` | `sqlite3_step`：`DB_ROW_OK`(1) 有行，`DB_ROW_DONE`(0) 结束 |
| `row_col_i32` | 读当前行第 `col` 列整型值 |
| `query_end` | `sqlite3_finalize` 释放游标 |

烟测入口：`db_sqlite_next_row_smoke_c`（C）、`next_row_roundtrip.sx`（.sx）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `cursor_row1` | `next_row` + `row_col_i32(0)` | 值 **1** |
| `cursor_row2` | 第二次 `next_row` + `row_col_i32(0)` | 值 **2** |
| `cursor_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-db-next-row-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-db-next-row-gate.sh
```

```
shux: [SHUX_STD067_DB_CURSOR] status=ok cursor_c=1 cursor_su=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 联动

- manifest：`tests/baseline/std-db-next-row.tsv`
- 父门禁：`run-std-db-query-rows-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 文本列见 STD-068 `std-db-row-col-text-v1.md`
- BLOB 列类型
- 预编译语句缓存见 **STD-070**
- 并发只读连接池
