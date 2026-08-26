# 阶段 F-04 v7（std.compress zstd 去 C + compress.o 退役）

> **F-04 v7**：**`zstd/zstd.c`** → **`lib.x`**；`compress.o` 不再构建；四格式全 `.x`。

## v7 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `lib.x` | libzstd FFI：块 + 流式 API、smoke、marker |
| `std/compress/zstd/mod.x` | import zstd_lib 转发 |
| `runtime_link_abi.c` | `link_abi_user_o_needs_compress_libs` 按需 -lz/-lzstd/-lbrotli* |
| `compiler/Makefile` | 移除 compress.o / zstd.o；`compress-o-*` 保留为 no-op |
| `STD_AND_PANIC_O` | 不再含 compress.o |
| 删除 | `std/compress/zstd/zstd.c` |
| 存量 | F-01 total **97**（较 98 减 1） |

## v7 限制

| 项 | 说明 |
|----|------|
| compress.o 残留引用 | runtime.c 仍传 compress_o 路径（缺失则 skip） |
| 旧 C 烟测 | 经 compress.o 的路径已废弃，改 .x 烟测 |

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory + STD-007 compress. No soft
`die→exit 0`. Soft `XLANG_F04_COMPRESS_ZSTD_FAIL` retired. brotli/zstd
stream smoke is **observational** (`bz_stream=`; product-red residual — not
soft false-green). Report `static=` / `inventory=` / `compress=` /
`bz_stream=` / `skip=`.

```bash
./tests/run-f04-std-compress-zstd-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f04-std-compress-zstd-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F04_COMPRESS_ZSTD_FAIL` path retired; gate
always hard). Neighbor inventory / STD-007 still own their own FAIL knives
when run standalone:

```bash
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
./tests/run-std-compress-gate.sh
```
