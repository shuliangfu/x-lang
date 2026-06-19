# STD-138：std.sqlite 跨线程连接语义 v1

> 更新时间：2026-06-19  
> 状态：**文档定版**  
> 前置：STD-084 `std-sqlite-pool-v1.md`

---

## 1. 目标

明确 **v1 单进程多线程** 下 `DbConn` / `DbPool` / 游标的使用约束，避免未定义并发访问。

验收：`tests/run-std-sqlite-threading-gate.sh` 绿（文档 + README 同步）。

---

## 2. 语义（v1）

| 对象 | 跨线程 |
|------|--------|
| `DbConn` | **禁止** 多线程共享同一 handle；一连接一线程 |
| `DbRowCursor` / `DbStmt` | 绑定所属连接；**禁止** 跨线程 |
| `DbPool` | 池本身可在多线程创建；**须** `acquire`→专用线程使用→`release` |
| `last_error()` | v1 为**进程静态**缓冲，非 TLS；并发写后读可能覆盖 |
| `prepare_cached` / stmt 缓存 |  per-connection；仅持有该连接的线程可复用 |

### 推荐模式

1. **每线程独立 `open`**：最简单，无池开销。
2. **连接池**：`pool_open(path, N)`，`N`≥并发线程数；每线程 `pool_acquire` 后独占至 `pool_release`。
3. **只读并发**：仍须**每线程独立连接**（SQLite 默认未开 shared cache 时 `:memory:` 不共享）。

### 禁止

- 线程 A `pool_acquire`，线程 B 在同一 `DbConn` 上 `exec` / `query_begin`。
- 一线程 `query_begin`，另一线程 `next_row` / `row_col_*`。
- 依赖 `last_error()` 做并发错误诊断（应改用 API 返回值）。

---

## 3. 与 std.db 兼容层

`import("std.db")` 转发至 `std.sqlite`；线程语义相同。

---

## 4. Gate

```bash
./tests/run-std-sqlite-threading-gate.sh
```

```
shux: [SHUX_STD138_DB_THREADING] status=ok doc=1 readme=1
```

---

## 5. 非目标（v2）

- `sqlite3_open_v2` + `SQLITE_OPEN_NOMUTEX` 封装
- 线程安全 `last_error`（TLS）
- 跨线程只读连接共享（shared cache + 文档化 WAL）
