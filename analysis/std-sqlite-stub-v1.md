# STD-139：std.db.sqlite stub 后端 v1

> 更新时间：2026-06-19  
> 状态：**文档定版**  
> 前置：STD-057 `std-sqlite-v1.md`、STD-167 `sqlite_is_available`

---

## 1. 目标

无 `libsqlite3` 时，`make -C compiler sqlite-o-stub` 产出可链接的 **stub 后端**；运行时全部数据库操作返回 **`DB_NOT_IMPL`（-9）**，并通过 `sqlite_is_available()` / `backend_name()` 探测。

验收：`tests/run-std-sqlite-stub-gate.sh` 绿。

---

## 2. 构建矩阵

| 模式 | 命令 | 链接 | `backend_name()` | `sqlite_is_available()` |
|------|------|------|------------------|-------------------------|
| **默认** | `make -C compiler ../std/db/sqlite/sqlite.o` | `-lsqlite3` | `"sqlite3"` | **1** |
| **stub** | `make -C compiler sqlite-o-stub` | 无 | `"stub"` | **0** |

---

## 3. stub API 行为（v1）

| API | stub 返回值 | `last_error.code` |
|-----|-------------|-------------------|
| `open` | `handle=0` | `DB_NOT_IMPL` (-9) |
| `close` / `exec` / 事务 | `<0` | `DB_NOT_IMPL` |
| `query_begin` / `prepare*` | `handle/cursor=0` | `DB_NOT_IMPL` |
| `next_row` / `row_col_*` / `stmt_*` | `<0` | `DB_NOT_IMPL` |
| `pool_open` / `pool_acquire` | `handle=0` | `DB_NOT_IMPL` |
| `sqlite_is_available()` | **0** | — |
| `backend_name()` | `"stub"` | — |

**推荐模式**：启动时 `if (sqlite_is_available() == 0) { /* 降级或跳过 DB 功能 */ }`。

烟测：`db_sqlite_stub_smoke_c`（C）、`stub_behavior.sx`（.sx 双模式）。

---

## 4. Gate

```bash
./tests/run-std-sqlite-stub-gate.sh
```

```
shux: [SHUX_STD139_DB_STUB] status=ok stub_c=1 stub_sx=1 doc=1
```

---

## 5. 非目标（v2）

- 内存 SQL 模拟器
- 自动 fallback 到文件 KV
- 与 `std.schema` 无 DB 路径合并
