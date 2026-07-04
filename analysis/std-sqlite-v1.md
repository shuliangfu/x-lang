# STD-057：std.db SQLite3 后端原型 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1 原型）**  
> 关联：STD-010（`analysis/std-db-prereq-v1.md`）、EXC-003 错误码

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读 STD-010 §2 设计层 |
| 2 | 读本文 §2–§4 |
| 3 | `./tests/run-std-db-sqlite-gate.sh` |

---

## 2. SQLite3 后端（v1）

| API | v1 行为 |
|-----|---------|
| `open` / `close` | `sqlite3_open` / `sqlite3_close` |
| `exec` | `sqlite3_exec`（DDL/DML 无结果集） |
| `begin_tx` / `commit` / `rollback` | `BEGIN IMMEDIATE` / `COMMIT` / `ROLLBACK` |
| `query_rows` | 仍 `DB_NOT_IMPL`（行迭代留待 STD-058+） |
| `changes` | `sqlite3_changes`（影响行数） |
| `backend_name` | `"sqlite3"`（stub 为 `"stub"`） |

**编译开关**：`make -C compiler db-o-sqlite`（`-DSHUX_DB_USE_SQLITE3`）；默认 `db.o` 为 stub，STD-010 typeck 仍可用。

**链接**：`runtime.c` 链入 `std/db/db.o` 时追加 `-lsqlite3`。

---

## 3. 错误码

| 码 | 常量 | 说明 |
|----|------|------|
| 0 | `DB_OK` | 成功 |
| -1 | `DB_ERR_NULL` | 空指针 |
| -2 | `DB_ERR_OPEN` | 打开失败 |
| -3 | `DB_ERR_EXEC` | 执行失败 |
| -4 | `DB_ERR_BUSY` | 忙/无法关闭 |
| -9 | `DB_NOT_IMPL` | stub / 未实现 API |

`last_error()` 返回 `db_last_error_code_c` + 静态消息缓冲。

---

## 4. exec 往返金样

| 步骤 | SQL | 期望 |
|------|-----|------|
| 1 | `open(":memory:")` | `handle != 0` |
| 2 | `CREATE TABLE t(k INTEGER)` | `DB_OK` |
| 3 | `INSERT INTO t(k) VALUES (42)` | `DB_OK`，`changes == 1` |
| 4 | `close` | `DB_OK` |

烟测：`tests/std-db/exec_roundtrip_ok.c`（C）、`exec_roundtrip.x`（有 native shux + sqlite 时）。

---

## 5. 门禁

```bash
./tests/run-std-db-sqlite-gate.sh
```

无 `libsqlite3` 时 manifest 仍过，exec 烟测 **SKIP**。
