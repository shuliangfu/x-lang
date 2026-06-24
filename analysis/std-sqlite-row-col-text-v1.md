# STD-068：std.db row_col_text 文本列 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-067 `std-db-next-row-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-067 列值游标基础上实现 **文本列读取原型**：`row_col_text` 将当前行 `col` 列 UTF-8 文本拷贝到调用方缓冲。

验收：`tests/run-std-db-row-col-text-gate.sh` 绿；`min_text_apis=1`；C 烟测 `text_c=1`。

---

## 2. row_col_text API（v1）

| API | v1 行为 |
|-----|---------|
| `row_col_text` | `sqlite3_column_text` 拷贝到 `out`；成功返回字节长度（不含 NUL） |
| NULL 列 | 写入空串，返回 **0** |
| 缓冲不足 | `DB_ERR_EXEC`（须容纳 NUL 终止符） |

烟测入口：`db_sqlite_row_col_text_smoke_c`（C）、`row_col_text_roundtrip.sx`（.sx）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `text_row1` | `next_row` + `row_col_text(0)` | **"alpha"**（5 字节） |
| `text_row2` | 第二次 `next_row` + `row_col_text(0)` | **"beta"**（4 字节） |
| `text_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-db-row-col-text-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-db-row-col-text-gate.sh
```

```
shux: [SHUX_STD068_DB_TEXT_COL] status=ok text_c=1 text_sx=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 联动

- manifest：`tests/baseline/std-db-row-col-text.tsv`
- 父门禁：`run-std-db-next-row-gate.sh`（STD-067 manifest-only）
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- BLOB 列见 STD-069 `std-db-row-col-blob-v1.md`
- 预编译语句缓存
- 并发只读连接池
