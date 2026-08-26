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
| 无 xlang | `arrow.o` 仅胶层符号 |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory + kv-arrow product. No soft
`die→exit 0`. Soft `XLANG_F05_DB_ARROW_V1_FAIL` retired. Host-c nm/cc
smoke retired. Report `static=` / `inventory=` / `kv_arrow=` / `skip=`.

```bash
./tests/run-f05-std-db-arrow-v1-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f05-std-db-arrow-v1-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F05_DB_ARROW_V1_FAIL` path retired; gate
always hard). Neighbor inventory / kv-arrow still own their own FAIL knives
when run standalone:

```bash
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
./tests/run-std-db-kv-arrow-gate.sh
```

## 下一步

- **F-05 v2 ✅**：`std/db/kv/kv.c` → `kv.x` + runtime mmap glue
- **F-05 v3 ✅** / **F-05 v4 ✅**：见 `phase-f-f05-v3.md` / `phase-f-f05-v4-closure.md`
