# STD-070：std.db.sqlite 预编译 bind + stmt 缓存 v1

> 更新时间：2026-06-18  
> 状态：**可用**  
> 前置：STD-067 `std-sqlite-next-row-v1.md`  
> 关联：STD-010 D2 查询执行、EXC-003

---

## 1. 目标

在列值游标基础上实现 **预编译语句 + 参数绑定 + 连接级 stmt 缓存**。

验收：`tests/run-std-sqlite-stmt-cache-gate.sh` 绿；C 烟测 `bind_c=1`。

---

## 2. stmt API（v1）

| API | v1 行为 |
|-----|---------|
| `prepare` | `sqlite3_prepare_v2`，独立 finalize |
| `prepare_cached` | 同连接同 SQL 复用 stmt；`close` 时自动释放 |
| `stmt_bind_i32` / `stmt_bind_text` | `sqlite3_bind_*`（idx 从 1 起） |
| `stmt_step` | 同 `next_row`：1=有行，0=完成 |
| `stmt_reset` | 重置以便再次 bind |
| `stmt_finalize` | finalize 并从缓存移除 |
| `stmt_cache_clear` | 清空连接缓存 |
| `stmt_col_i32` / `stmt_col_text` | 读当前行列值 |

烟测：`db_sqlite_stmt_bind_smoke_c`（C）、`stmt_bind_roundtrip.sx`（.sx）。

---

## 3. 金样向量

| step_id | 操作 | 期望 |
|---------|------|------|
| `bind_insert` | INSERT(?,?) 两次 bind+step | 两行写入 |
| `cache_hit` | 两次 `prepare_cached` 同 SQL | 同一 handle |
| `bind_select` | SELECT WHERE k=? bind 10/20 | 读 alice / bob |

向量表：`tests/baseline/std-sqlite-stmt-cache-vectors.tsv`。

---

## 4. Gate

```bash
./tests/run-std-sqlite-stmt-cache-gate.sh
```

```
shux: [SHUX_STD070_DB_STMT] status=ok bind_c=1 bind_su=1 skip=0
```

无 `libsqlite3` 时 manifest 仍过，烟测 **SKIP**。

---

## 5. 非目标（v2）

- 连接池
- blob 参数绑定
- LRU 精细驱逐策略
- 跨线程 stmt 共享
