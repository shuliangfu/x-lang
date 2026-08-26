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

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory + kv-arrow product. No soft
`die→exit 0`. Soft `XLANG_F05_DB_KV_V2_FAIL` retired. Host-c nm/cc
smoke retired. Report `static=` / `inventory=` / `kv_arrow=` / `skip=`.

```bash
./tests/run-f05-std-db-kv-v2-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f05-std-db-kv-v2-gate.sh
```

## 门禁

Same as **## Gate** (soft `XLANG_F05_DB_KV_V2_FAIL` path retired; gate
always hard):

```bash
./tests/run-f05-std-db-kv-v2-gate.sh
./tests/run-std-db-kv-arrow-gate.sh
```

## 下一项

- **F-05 v3 ✅**：`std/db/sqlite/sqlite.c` 已迁 `sqlite.x` + runtime glue
- **F-05 v4 ✅**：见 `phase-f-f05-v4-closure.md`
