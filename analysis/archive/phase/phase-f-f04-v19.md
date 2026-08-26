# 阶段 F-04 v19（std.crypto Ed25519 API 去 inc.c）

> **F-04 v19 v1**：**`std/crypto/ed25519.inc.c`** → **`ed25519.x`** + **`ed25519_ref10_glue.c`**（ref10 曲线仍 C 胶层）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/crypto/ed25519.x` | crypto_ed25519_* C ABI + RFC 8032 烟测 |
| `std/crypto/ed25519_ref10_glue.c` | ref10 fe/ge/sc/sha512/keypair/sign/verify（#include 原 ed25519/*.c） |
| `std/crypto/crypto_inc_glue.c` | 仅 SHA-512 / HMAC-SHA512（委托 glue 内 sha512()） |
| ~~`std/crypto/ed25519.inc.c`~~ | 已删除 |

## 仍留 C（v20 目标）

| 路径 | 说明 |
|------|------|
| `std/crypto/ed25519/*.c` | ref10 实现，由 glue #include |
| `std/crypto/ed25519/*.h` | glue 内部头文件 |

## 构建

```bash
make -C compiler ../std/crypto/crypto.o
# ld -r(crypto_inc_glue.o + ed25519_ref10_glue.o + 4× .x main.o)
```

## Gate

Honesty gate (2026-08-26): prefer `xlang_asm`, pin `XLANG_LINK_XLANG`,
hard-fail static TSV + F-01 inventory + STD-006 manifest-only. No soft
`die→exit 0`. Soft `XLANG_F04_CRYPTO_V19_FAIL` retired. Host-c ed25519
smoke observational. Does **not** open `run-std-crypto-ed25519-gate`
(`xlang-c check` still hard there; check gate paused). Report
`static=` / `inventory=` / `crypto=` / `smoke=` / `skip=`. Live authority
= `./xbuild` + `compiler/mk/driver_seed_r_lists.mk` +
`xlang_compile_std_module.sh`.

```bash
./tests/run-f04-std-crypto-v19-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-v19-gate.sh
```

## 复现

Same as **## Gate** (soft `XLANG_F04_CRYPTO_V19_FAIL` path retired; gate
always hard). Neighbor inventory / STD-006 still own their own FAIL knives
when run standalone:

```bash
XLANG_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
XLANG_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-gate.sh
```

## 下一项

- **F-04 v21 ✅**：`phase-f-f04-v21-closure.md` + `run-f04-std-crypto-closure-gate.sh`
- **F-04 v20**（可选）：ref10 fe/ge/sc 迁 `.x`
