# 阶段 F-05 v3（std.db.sqlite 去 C）

> **F-05 v3**：**`std/db/sqlite/sqlite.c`** → **`sqlite.x`** + **`sqlite_glue.c`**（libsqlite3 胶层）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/db/sqlite/sqlite.x` | open/close/exec/事务/游标/stmt 缓存/连接池/全量烟测 |
| `std/db/sqlite/sqlite_glue.c` | `shu_sqlite3_*_c` FFI；`-DSHUX_DB_USE_SQLITE3` 或 stub |
| ~~`std/db/sqlite/sqlite.c`~~ | 已删除 |

## 构建

```bash
make -C compiler ../std/db/sqlite/sqlite.o   # ld -r(sqlite_glue.o + sqlite_main.o), -DSHUX_DB_USE_SQLITE3
make -C compiler sqlite-o-stub               # glue 无 SQLITE3；运行时 DB_NOT_IMPL
```

## 门禁

```bash
SHUX_F05_DB_SQLITE_V3_FAIL=1 ./tests/run-f05-std-db-sqlite-v3-gate.sh
./tests/run-std-sqlite-gate.sh
./tests/run-std-sqlite-stub-gate.sh
```

## 下一项

- **F-05 v4 ✅**：`phase-f-f05-v4-closure.md` + `run-f05-std-db-closure-gate.sh`
