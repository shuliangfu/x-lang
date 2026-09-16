# STD-137：std.db.sqlite 大 BLOB 分块读 v1

> 更新时间：2026-08-28  
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
| `col_blob_len` | `sqlite3_column_bytes`；NULL/空返回 **0**（C：`db_row_col_blob_len_c`） |
| `col_blob_read` | 从 `offset` 拷贝最多 `cap` 字节；`offset>=len` 返回 **0**（C：`db_row_col_blob_read_c`） |
| overload on `DbStmt` | 与游标 API 相同，作用于预编译语句当前行 |

小 BLOB 仍可用 `col_blob`／`row_col_blob`；大对象推荐 `col_blob_len` + 循环 `col_blob_read`。

烟测：`db_sqlite_blob_stream_smoke_c`（96 字节、32×3 块）、`blob_stream_roundtrip.x`。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `blob_len96` | `col_blob_len(0)` | **96** |
| `blob_chunk32` | 三次 `col_blob_read(offset=0/32/64, cap=32)` | 累计 96 字节，内容为 0..95 |
| `blob_stream_done` | `query_end` + `close` | `DB_OK` |

向量表：`tests/baseline/std-sqlite-blob-stream-vectors.tsv`。

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/db/sqlite/sqlite.o`＝obs（拒 soft `ensure_std_c_o`／`std_sqlite_build_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` SEGV／UNDEF＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `stream_c=`／`stream_x=`）。

```bash
./tests/run-std-sqlite-blob-stream-gate.sh
```

```
xlang: [XLANG_STD137_DB_BLOB_STREAM] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 5. 非目标（v2）

- 零拷贝 BLOB 视图
- `stmt_bind_blob` 分块写入
- 与 `std.fs` 流式 pipe 直连
