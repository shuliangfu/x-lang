# 阶段 F-hash v2（std.hash 逻辑 .x 下沉）

> **F-hash v2**：SipHash-2-4 / FNV-1a64 / xxHash64 全量在 **`hash.x`**；**删除 `hash_glue.c`**；`hash.o` 纯 `.x` 编译（同 cache/schema）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 算法实现 | `hash_glue.c`（438 行） | **`hash.x`** |
| `hash.o` | `ld -r` glue + x | **纯 xlang → hash.o** |
| 依赖 | libc malloc/free/strcmp/getenv | `extern` 同上 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_HASH_V2_FAIL` retired. STD-056 hasher／STD-105 xxhash／STD-148 default-strategy product residual observational.

**2026-08-30 leftover XLANG fallthrough 已收**（f-hash-v2：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-hash-hasher-trait／std-hash-xxhash／std-hash-default-strategy 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-hash-v2-gate.sh
./tests/run-std-hash-hasher-trait-gate.sh
./tests/run-std-hash-xxhash-gate.sh
./tests/run-std-hash-default-strategy-gate.sh
```

## 下一项

- **F-dynlib v2** / **F-http v2** 等 std 胶层继续下沉
