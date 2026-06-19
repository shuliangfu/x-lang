# STD-137：std.sqlite 大 BLOB 分块读 v1

> 更新时间：2026-06-19  
> 状态：**可用**  
> 前置：STD-069 `std-sqlite-row-col-blob-v1.md`

---

## 1. 目标

在 `row_col_blob` 一次性拷贝基础上，提供 **长度查询 + offset 分块读**，避免大 BLOB 须预分配整块缓冲。

验收：`tests/run-std-sqlite-blob-stream-gate.sh` 绿。

---

## 2. blob stream API（v1）

| API | v1 行为 |
|-----|---------|
| `row_col_blob_len` | `sqlite3_column_bytes`；NULL/空返回 **0** |
| `row_col_blob_read` | 从 `offset` 拷贝最多 `cap` 字节；`offset>=len` 返回 **0** |
| `stmt_col_blob_len` / `stmt_col_blob_read` | 与游标 API 相同，作用于预编译语句当前行 |

小 BLOB 仍可用 `row_col_blob`；大对象推荐 `len` + 循环 `read`。

烟测：`db_sqlite_blob_stream_smoke_c`（96 字节、32×3 块）、`blob_stream_roundtrip.sx`。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `blob_len96` | `row_col_blob_len(0)` | **96** |
| `blob_chunk32` | 三次 `read(offset=0/32/64, cap=32)` | 累计 96 字节，内容为 0..95 |
| `blob_stream_done` | `query_end` + `close` | `DB_OK` |

向量表：`tests/baseline/std-sqlite-blob-stream-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-sqlite-blob-stream-gate.sh
```

```
shux: [SHUX_STD137_DB_BLOB_STREAM] status=ok stream_c=1 stream_su=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 非目标（v2）

- 零拷贝 BLOB 视图
- `stmt_bind_blob` 分块写入
- 与 `std.fs` 流式 pipe 直连
