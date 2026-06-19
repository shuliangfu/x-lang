# STD-065：std.db SQLite exec 深化 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-057 `std-db-sqlite-v1.md`  
> 关联：STD-010 事务层 D3、EXC-003

---

## 1. 目标

在 STD-057 单条 `exec` 往返上扩展 **事务 exec 烟测**：`begin_tx` / `commit` / `rollback` 与 `changes` 联动。

验收：`tests/run-std-db-exec-deep-gate.sh` 绿；`min_tx_apis=3`；C 烟测 `tx_c=1`。

---

## 2. 事务 Exec API（深化）

| API | 深化行为 |
|-----|----------|
| `begin_tx` | `BEGIN IMMEDIATE` 后允许 DML |
| `commit` | 提交后 `changes` 保留 |
| `rollback` | 回滚后无残留写入 |

烟测入口：`db_sqlite_tx_exec_smoke_c`（C）、`exec_tx_roundtrip.sx`（.sx）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `tx_begin` | `begin_tx` | `DB_OK` |
| `tx_insert` | `exec INSERT` | `DB_OK`，`changes=1` |
| `tx_commit` | `commit` | `DB_OK` |
| `tx_rollback` | `begin` + `INSERT` + `rollback` | `DB_OK` |

向量表：`tests/baseline/std-db-exec-deep-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-db-exec-deep-gate.sh
```

```
shux: [SHUX_STD065_DB_EXEC] status=ok tx_c=1 tx_su=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，exec 烟测 **SKIP**。

---

## 5. 联动

- manifest：`tests/baseline/std-db-exec-deep.tsv`
- 父门禁：`run-std-db-sqlite-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- `query_rows` 行迭代
- 并发 / WAL 模式
- 文件库持久化 bench
