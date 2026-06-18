# std.sqlite — SQLite 数据库访问

> **RFC**：`analysis/std-sqlite-prereq-v1.md`（设计层）· `analysis/std-sqlite-v1.md`（SQLite3 后端）  
> **文档同步**：STD-154 · `docs/07-内置与标准库.md`

## 构建与后端

| 模式 | 命令 | 行为 |
|------|------|------|
| **默认（SQLite3）** | `make -C compiler ../std/sqlite/sqlite.o` | `-DSHU_DB_USE_SQLITE3` + 链接 `-lsqlite3` |
| **stub（无 libsqlite3）** | `make -C compiler sqlite-o-stub` | API 可链接；运行时 `open`/`exec` 等返回 **`DB_NOT_IMPL`（-9）** |

新代码请 **`import("std.sqlite")`**；`import("std.db")` 为 STD-120 兼容层（deprecated，见 `std/db/README.md`）。

## API 概要

| 层 | API（摘录） |
|----|-------------|
| 连接 | `open` / `close` / `last_error` / `backend_name` |
| 执行 | `exec` / `begin_tx` / `commit` / `rollback` |
| 游标 | `query_begin` / `next_row` / `query_end` / `row_col_*` |
| 预编译 | `prepare_cached` + `bind_*`（STD-070） |
| 连接池 | `pool_acquire` / `pool_release`（STD-084） |

## 测试与门禁

- 主 gate：`./tests/run-std-sqlite-gate.sh`（STD-057）
- 系列：`run-std-sqlite-*-gate.sh`（exec / next_row / stmt-cache / pool 等）
- 烟测：`tests/std-sqlite/`
- 文档 gate：`./tests/run-std-sqlite-docs-sync-gate.sh`（STD-154）
