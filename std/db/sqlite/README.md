# std.db.sqlite — SQLite 数据库访问

> **路径**：`import("std.db.sqlite")`；`import("std.sqlite")` 为 deprecated 兼容层。  
> **RFC**：`analysis/std-sqlite-prereq-v1.md` · `analysis/std-sqlite-v1.md`

## 构建与后端

| 模式 | 命令 | 行为 |
|------|------|------|
| **默认（SQLite3）** | `make -C compiler ../std/db/sqlite/sqlite.o` | `-DSHUX_DB_USE_SQLITE3` + 链接 `-lsqlite3` |
| **stub（无 libsqlite3）** | `make -C compiler sqlite-o-stub` | API 可链接；运行时返回 **`DB_NOT_IMPL`（-9）** |

## API 概要

| 层 | API（摘录） |
|----|-------------|
| 连接 | `open` / `close` / `last_error` / `backend_name` |
| 执行 | `exec` / `begin_tx` / `commit` / `rollback` |
| 游标 | `query_begin` / `next_row` / `query_end` / `row_col_*` |
| BLOB 流 | `row_col_blob_len` / `row_col_blob_read`（STD-137） |
| 预编译 | `prepare_cached` + `bind_*` |
| 连接池 | `pool_acquire` / `pool_release` |

## 测试与门禁

- `./tests/run-std-sqlite-gate.sh`
- 烟测：`tests/std-sqlite/`
