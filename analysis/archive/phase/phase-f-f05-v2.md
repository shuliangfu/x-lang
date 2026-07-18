# 阶段 F-05 v2（std.db.kv 去 C）

> **F-05 v2**：**`std/db/kv/kv.c`** → **`kv.x`** + **`kv_mmap_glue.c`**（mmap 胶层）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/db/kv/kv.x` | WAL + LSM + SST + compact + smoke 全量逻辑 |
| `std/db/kv/kv_mmap_glue.c` | open/ftruncate/mmap/munmap/msync 胶层 |
| ~~`std/db/kv/kv.c`~~ | 已删除 |

## 构建

```bash
make -C compiler ../std/db/kv/kv.o   # ld -r(kv_mmap_glue.o + kv_main.o)
```

## 门禁

```bash
SHUX_F05_DB_KV_V2_FAIL=1 ./tests/run-f05-std-db-kv-v2-gate.sh
./tests/run-std-db-kv-arrow-gate.sh
```

## 下一项

- **F-05 v3 ✅**：`std/db/sqlite/sqlite.c` 已迁 `sqlite.x` + `sqlite_glue.c`
