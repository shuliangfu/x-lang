# 阶段 F-05 v4（std.db 闭合）

> **F-05 v4**：**std.db** 三后端（arrow / kv / sqlite）业务逻辑全在 **`.x`**；**`kv.c` / `arrow.c` / `sqlite.c` 已删除**；仅保留文档化最小胶层 C。

## v4 闭合清单（✅ manifest）

| 模块 | 主逻辑 | 胶层 C | 阶段 |
|------|--------|--------|------|
| arrow | `arrow.x` | `arrow_simd_glue.c`（SSE2/NEON sum/dot） | F-05 v1 |
| kv | `kv.x` | `kv_mmap_glue.c`（mmap open/ftruncate） | F-05 v2 |
| sqlite | `sqlite.x` | `sqlite_glue.c`（libsqlite3 FFI / stub） | F-05 v3 |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/db/kv/kv.c`~~ | v2 删除 |
| ~~`std/db/arrow/arrow.c`~~ | v1 删除 |
| ~~`std/db/sqlite/sqlite.c`~~ | v3 删除 |

## 仍允许的 C（胶层 only）

| 文件 | 原因 |
|------|------|
| `arrow_simd_glue.c` | 平台 SIMD intrinsics（SSE2/NEON） |
| `kv_mmap_glue.c` | `MAP_SHARED` mmap 与 `ftruncate` 胶层（后续可接 `std.sys.mmap` FFI） |
| `sqlite_glue.c` | `libsqlite3` C API / stub 双路径 |

## 构建

```bash
make -C compiler ../std/db/arrow/arrow.o   # ld -r(arrow_simd_glue.o + arrow_main.o)
make -C compiler ../std/db/kv/kv.o       # ld -r(kv_mmap_glue.o + kv_main.o)
make -C compiler ../std/db/sqlite/sqlite.o # ld -r(sqlite_glue.o + sqlite_main.o)
make -C compiler sqlite-o-stub             # glue 无 SHUX_DB_USE_SQLITE3
```

## 门禁

```bash
SHUX_F05_DB_CLOSURE_FAIL=1 ./tests/run-f05-std-db-closure-gate.sh
./tests/run-std-db-kv-arrow-gate.sh
SHUX_STD_SQLITE_MANIFEST_ONLY=1 ./tests/run-std-sqlite-gate.sh
```

## 下一项

- **F-04 crypto v21 ✅** 模块闭合；见 `phase-f-f04-v21-closure.md`
- **F-09 v1 ✅**：全仓库手写 C 审计门禁；见 `phase-f-f09-v1.md`
