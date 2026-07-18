# STD-069：std.db row_col_blob BLOB 列 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-068 `std-db-row-col-text-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-068 文本列基础上实现 **BLOB 列读取原型**：`row_col_blob` 将当前行 `col` 列二进制数据拷贝到调用方缓冲。

验收：`tests/run-std-db-row-col-blob-gate.sh` 绿；`min_blob_apis=1`；C 烟测 `blob_c=1`。

---

## 2. row_col_blob API（v1）

| API | v1 行为 |
|-----|---------|
| `row_col_blob` | `sqlite3_column_blob` + `sqlite3_column_bytes` 拷贝到 `out` |
| NULL / 空 BLOB | 返回 **0**（不写缓冲） |
| 缓冲不足 | `DB_ERR_EXEC` |

烟测入口：`db_sqlite_row_col_blob_smoke_c`（C）、`row_col_blob_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `blob_row1` | `next_row` + `row_col_blob(0)` | **0x01 0x02 0x03**（3 字节） |
| `blob_row2` | 第二次 `next_row` + `row_col_blob(0)` | **0x0a 0x0b 0x0c 0x0d**（4 字节） |
| `blob_done` | 第三次 `next_row` | `DB_ROW_DONE` |

向量表：`tests/baseline/std-db-row-col-blob-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-db-row-col-blob-gate.sh
```

```
shux: [SHUX_STD069_DB_BLOB_COL] status=ok blob_c=1 blob_x=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 联动

- manifest：`tests/baseline/std-db-row-col-blob.tsv`
- 父门禁：`run-std-db-row-col-text-gate.sh`（STD-068 manifest-only）
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 零拷贝 BLOB 视图
- 预编译语句缓存
- 并发只读连接池
