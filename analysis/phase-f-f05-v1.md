# 阶段 F-05 v1（std.db.arrow 去 C）

> **F-05 v1 v1**：**`std/db/arrow/arrow.c`** → **`arrow.x`** + **`arrow_simd_glue.c`**（SIMD 归约胶层）。

## v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `arrow.x` | 列/batch 生命周期、adopt、烟测 |
| `arrow_simd_glue.c` | SSE2/NEON sum/dot/null-aware 内核 |
| `arrow.c` | **已删除**（656 行） |
| `Makefile` | `arrow.o` = `ld -r(arrow_main.o + arrow_simd_glue.o)` |

## v1 限制（v2+）

| 项 | 说明 |
|----|------|
| `std/db/kv/kv.c` | ~975 行，仍 C（F-05 v2） |
| `std/db/sqlite/sqlite.c` | ~1539 行，仍 C + libsqlite3 |
| 无 shux | `arrow.o` 仅胶层符号 |

## 复现

```bash
SHUX_F05_DB_ARROW_V1_FAIL=1 ./tests/run-f05-std-db-arrow-v1-gate.sh
./tests/run-std-db-kv-arrow-gate.sh
```

## 下一步

- **F-05 v2**：`std/db/kv/kv.c` 分批迁 `.x`（mmap/WAL 可复用 std.sys.mmap）
