# std.db.sqlite — SQLite 数据库访问

> **路径**：`import("std.db.sqlite")`。
> **RFC**：`analysis/std-sqlite-prereq-v1.md` · `analysis/std-sqlite-v1.md`

## 构建与后端

| 模式 | 命令 | 行为 |
|------|------|------|
| **默认（SQLite3）** | `make -C compiler ../std/db/sqlite/sqlite.o` | `sqlite.sx` + `sqlite_glue.c`（`-DSHUX_DB_USE_SQLITE3`）+ 链接 `-lsqlite3` |
| **stub（无 libsqlite3）** | `make -C compiler sqlite-o-stub` | 同上但 glue 无 `SHUX_DB_USE_SQLITE3`；运行时返回 **`DB_NOT_IMPL`（-9）** |

## API 概要

| 层 | API（摘录） |
|----|-------------|
| 连接 | `open` / `close` / `last_error` / `backend_name` |
| 执行 | `exec` / `begin_tx` / `commit` / `rollback` |
| 游标 | `query_begin` / `next_row` / `query_end` / `row_col_*` |
| BLOB 流 | `row_col_blob_len` / `row_col_blob_read`（STD-137） |
| 预编译 | `prepare_cached` + `bind_*` |
| 连接池 | `pool_acquire` / `pool_release` |

## 跨线程（STD-138）

v1 **单进程多线程** 约束见 [`analysis/std-sqlite-threading-v1.md`](../../analysis/std-sqlite-threading-v1.md)：

- `DbConn` / `DbRowCursor` / `DbStmt`：**禁止**多线程共享同一 handle
- `DbPool`：多线程可创建；每线程 `pool_acquire` 后独占至 `pool_release`
- `last_error()`：进程静态缓冲，并发场景勿依赖
- `prepare_cached`：per-connection，仅持有连接的线程可复用

## 测试与门禁

- `./tests/run-std-sqlite-gate.sh`
- 烟测：`tests/std-sqlite/`
