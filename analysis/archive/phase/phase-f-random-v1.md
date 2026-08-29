# 阶段 F-random v1（std.random 去 C）

> **F-random v1 / F-ZC**：删除 **`random.c`**；锚点 **`random.x`**（纯 .x → **`random.o`**）；CSPRNG OS fill 在 **`runtime_random_fill.c`**（compiler runtime）。

## 变更

| 项 | 旧 | 现 |
|----|----|-----|
| PRNG / u32/u64 | `random.c` | **`random.x`** |
| OS CSPRNG | `random_os_glue.c` | **`runtime_random_fill.c`**（已迁出 std/） |
| `random.o` | ld -r glue + .x | **纯 `.x`** |

## 符号

- `random_fill_bytes_c` — compiler runtime（getrandom / getentropy / BCryptGenRandom）
- `random_u32_c` / `random_u64_c` / `random_rng_smoke_c` — `random.x`

## Gate

Honesty (2026-08-26): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_RANDOM_V1_FAIL` retired. Orphan Makefile `die/fi` syntax fixed.

**2026-08-30 leftover XLANG fallthrough 已收**（f-random-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-random-rng 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-random-v1-gate.sh
./tests/run-std-random-rng-gate.sh
```

## 下一项

- **F-time v2** / **Z8** 其它 OS 胶层（`log_os_glue.c` 等）
