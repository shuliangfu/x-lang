# STD-066：std.db query_rows 行迭代原型 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-065 `std-db-exec-deep-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在 STD-065 事务 exec 基础上实现 **`query_rows` 行迭代原型**：`sqlite3_exec` 回调计数，返回 SELECT 匹配行数。

验收：`tests/run-std-db-query-rows-gate.sh` 绿；`min_query_apis=1`；C 烟测 `rows_c=1`。

---

## 2. query_rows API（v1）

| API | v1 行为 |
|-----|---------|
| `query_rows` | 执行 SELECT，返回**行数**（≥0）；失败返回 `DB_ERR_*` |

非游标句柄；列值迭代留待 v2。

烟测入口：`db_sqlite_query_rows_smoke_c`（C）、`query_rows_roundtrip.x`（.x）。

---

## 3. 金样向量

| step_id | SQL | 期望行数 |
|---------|-----|----------|
| `rows_all` | `SELECT k FROM t;` | 2 |
| `rows_filter` | `SELECT k FROM t WHERE k=1;` | 1 |

向量表：`tests/baseline/std-db-query-rows-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-db-query-rows-gate.sh
```

```
shux: [SHUX_STD066_DB_ROWS] status=ok rows_c=1 rows_x=0 skip=1
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 联动

- manifest：`tests/baseline/std-db-query-rows.tsv`
- 父门禁：`run-std-db-exec-deep-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 列值游标 / `next_row`
- 预编译语句缓存
- 并发只读连接池
