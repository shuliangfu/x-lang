# STD-139：std.db.sqlite stub 后端 v1

> 更新时间：2026-08-26  
> 状态：**Gate honesty soft→硬绿**  
> 前置：STD-057 `std-sqlite-v1.md`、STD-167 availability 探测

---

## 1. 目标

无 `libsqlite3` 时，`make -C compiler sqlite-o-stub` 产出可链接的 **stub 后端**；运行时全部数据库操作返回 **`DB_NOT_IMPL`（-9）**，并通过产品短名 `is_available()` / `backend_name()` 探测（旧文档名 `sqlite_is_available` 已弃用）。

验收：`tests/run-std-sqlite-stub-gate.sh` 绿。

---

## 2. 构建矩阵

| 模式 | 命令 | 链接 | `backend_name()` | `is_available()` |
|------|------|------|------------------|------------------|
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
| `is_available()` | **0** | — |
| `backend_name()` | `"stub"` | — |

**推荐模式**：启动时 `if (is_available() == 0) { /* 降级或跳过 DB 功能 */ }`。

烟测：`db_sqlite_stub_smoke_c`（C）、`stub_behavior.x`（.x 双模式）。

---

## 4. Gate

Honesty (2026-08-26): prefer `xlang_asm` + `XLANG_LINK_XLANG`; `xlang check`
observational (check gate paused); `stub_behavior.x` exit 0 hard-fail; C stub
smoke observational. Report `check=` / `run=` / `stub_c=` / `skip=`.

```bash
./tests/run-std-sqlite-stub-gate.sh
```

```
xlang: [XLANG_STD139_DB_STUB] status=ok check=0 run=1 stub_c=0 skip=0
```

---

## 5. 非目标（v2）

- 内存 SQL 模拟器
- 自动 fallback 到文件 KV
- 与 `std.schema` 无 DB 路径合并
