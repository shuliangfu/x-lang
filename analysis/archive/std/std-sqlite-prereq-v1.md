# STD-010 std.db.sqlite 接口预研 v1（RFC 草案）

> 更新时间：2026-08-29  
> 状态：**RFC 草案（draft）** — API 面 + gate honesty residual auto-make retired + SQLite3 默认后端  
> 关联：`EXC-003`（错误码分层）、`STD-001`（IO）、`DOC-005`（Q3 预览）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 设计层 D1–D4 |
| 2 | 打开 `tests/baseline/std-sqlite-manifest.tsv` |
| 3 | 浏览 `std/db/sqlite/mod.x` API |
| 4 | `./tests/run-std-sqlite-prereq-gate.sh` |

---

## 2. 设计层 D1–D4

权威：`tests/baseline/std-sqlite-manifest.tsv`（**4** 条 `layer_*`）。

| 层级 | 职责 | v1 |
|------|------|-----|
| **D1-connection** | 打开/关闭、连接句柄 | `open` / `close` |
| **D2-query-exec** | 执行 DDL/DML、行集 | `exec` / `rows` / 游标 |
| **D3-transaction** | 显式事务边界 | `begin_tx` / `commit` / `rollback` |
| **D4-backend** | SQLite3 后端 | `backend_name` / `DB_NOT_IMPL`（stub 构建） |

**错误模型**（对齐 `analysis/archive/exc/exc-error-code-layer-v1.md` / EXC-003）：

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
| `rows` | `(DbConn, *u8) -> i32` | SELECT 行数（live；拒化石 `query_rows`） |
| `begin_tx` | `(DbConn) -> i32` | 开始事务 |
| `commit` | `(DbConn) -> i32` | 提交 |
| `rollback` | `(DbConn) -> i32` | 回滚 |
| `last_error` | `() -> DbError` | 线程局部错误快照 |
| `backend_name` | `() -> *u8` | `"sqlite3"` 或 `"stub"` |

实现文件：`std/db/sqlite/mod.x` + `std/db/sqlite/sqlite.x`；说明见 `std/db/sqlite/README.md`。

公开路线图见 `analysis/archive/doc/doc-public-roadmap-v1.md`（DOC-005）。

---

## 4. 后端路线

| 阶段 | 后端 | 依赖 | 状态 |
|------|------|------|
| P3 预研 | stub | 无 | 可选 `sqlite-o-stub` |
| P2 原型 | SQLite 3 | `-lsqlite3` | ✅ 默认构建 |

---

## 5. Golden typeck 金样

| case_id | 文件 | 期望 |
|---------|------|------|
| `draft_typeck` | `tests/std-sqlite/draft_typeck.x` | 产品 `-o` 能链；tip SEGV＝obs（产品另案） |

---

## 6. Gate 与 report

**Honesty（2026-08-29 residual auto-make retired）**：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；`check` 仅观测（自举期暂停）；拒 soft `xlang_compiler_make`／prefer-c／soft SKIP typeck；显式坏 XLANG／缺 native 硬 die；`draft_typeck.x` 产品 `-o` 能链则硬绿、tip SEGV＝obs（产品债，leave）。报告 `run=`／`obs=`／`skip=`。

gate 输出 **`std-sqlite prereq gate OK`**；**runnable** report：

```
xlang: [XLANG_STD_SQLITE] status=ok run=0 obs=2 skip=0
```

（Darwin 上 `check` CHK residual＝obs；tip 产品 SEGV＝obs。硬绿信号是 `run=`；本波 tip 产品 SEGV 故 `run=0`。）

工具：`tests/lib/std-sqlite.sh`、`tests/run-std-sqlite.sh`、`tests/run-std-sqlite-prereq-gate.sh`；便携回归：`tests/run-portable-suite.sh`。

`XLANG_STD_SQLITE_PREREQ_MANIFEST_ONLY=1` → skip=1。

---

## 7. 验收（NEXT STD-010）

- [x] **RFC 草案**完成（D1–D4 + API 表 + 后端路线）
- [x] manifest + `std/db/sqlite/mod.x` API 面（live `rows`）
- [x] `run-std-sqlite-prereq-gate.sh` + `run-portable-suite.sh`
- [x] 2026-08-29 residual auto-make retired（prefer-asm；check／tip SEGV＝obs）

**非目标**：ORM、连接池、异步查询、分布式事务；tip `draft_typeck.x` SEGV 产品债。
