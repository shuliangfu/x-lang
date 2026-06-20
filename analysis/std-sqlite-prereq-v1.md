# STD-010 std.db.sqlite 接口预研 v1（RFC 草案）

> 更新时间：2026-06-18  
> 状态：**RFC 草案（draft）** — API 面 + typeck 金样 + SQLite3 默认后端  
> 关联：`EXC-003`（错误码分层）、`STD-001`（IO）、`DOC-005`（Q3 预览）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 设计层 D1–D4 |
| 2 | 打开 `tests/baseline/std-sqlite-manifest.tsv` |
| 3 | 浏览 `std/db/sqlite/mod.sx` API |
| 4 | `./tests/run-std-sqlite-prereq-gate.sh` |

---

## 2. 设计层 D1–D4

权威：`tests/baseline/std-sqlite-manifest.tsv`（**4** 条 `layer_*`）。

| 层级 | 职责 | v1 |
|------|------|-----|
| **D1-connection** | 打开/关闭、连接句柄 | `open` / `close` |
| **D2-query-exec** | 执行 DDL/DML、行集 | `exec` / `query_rows` / 游标 |
| **D3-transaction** | 显式事务边界 | `begin_tx` / `commit` / `rollback` |
| **D4-backend** | SQLite3 后端 | `backend_name` / `DB_NOT_IMPL`（stub 构建） |

**错误模型**（对齐 `analysis/exc-error-code-layer-v1.md` / EXC-003）：

| 码域 | 约定 |
|------|------|
| `0` | `DB_OK` 成功 |
| `-9` | `DB_NOT_IMPL` stub 构建回退 |
| `<0` | `DB_ERR_*` 库级错误 |

---

## 3. 草案 API 表

| API | 签名要点 | 说明 |
|-----|----------|------|
| `open` | `(*u8) -> DbConn` | 路径 UTF-8 C 串 |
| `close` | `(DbConn) -> i32` | 释放句柄 |
| `exec` | `(DbConn, *u8) -> i32` | 无结果集 SQL |
| `query_rows` | `(DbConn, *u8) -> i32` | SELECT 行数 |
| `begin_tx` | `(DbConn) -> i32` | 开始事务 |
| `commit` | `(DbConn) -> i32` | 提交 |
| `rollback` | `(DbConn) -> i32` | 回滚 |
| `last_error` | `() -> DbError` | 线程局部错误快照 |
| `backend_name` | `() -> *u8` | `"sqlite3"` 或 `"stub"` |

实现文件：`std/db/sqlite/mod.sx` + `std/db/sqlite/sqlite.c`；说明见 `std/db/sqlite/README.md`。

公开路线图见 `analysis/doc-public-roadmap-v1.md`（DOC-005）。

---

## 4. 后端路线

| 阶段 | 后端 | 依赖 | 状态 |
|------|------|------|------|
| P3 预研 | stub | 无 | 可选 `sqlite-o-stub` |
| P2 原型 | SQLite 3 | `-lsqlite3` | ✅ 默认构建 |

---

## 5. Golden typeck 金样

| case_id | 文件 | 期望 |
|---------|------|------|
| `draft_typeck` | `tests/std-sqlite/draft_typeck.sx` | `shux check` 通过 |

---

## 6. Gate 与 report

gate 输出 **`std-sqlite prereq gate OK`**；**runnable** report：

```
shux: [SHUX_STD_SQLITE] status=ok apis=9 layers=4 typeck=ok|skip
```

工具：`tests/lib/std-sqlite.sh`、`tests/run-std-sqlite.sh`、`tests/run-std-sqlite-prereq-gate.sh`；便携回归：`tests/run-portable-suite.sh`。

无 native `shux` 时 manifest 仍过，typeck **SKIP**。

---

## 7. 验收（NEXT STD-010）

- [x] **RFC 草案**完成（D1–D4 + API 表 + 后端路线）
- [x] manifest + `std/db/sqlite/mod.sx` API 面
- [x] `run-std-sqlite-prereq-gate.sh` + `run-portable-suite.sh`

**非目标**：ORM、连接池、异步查询、分布式事务。
