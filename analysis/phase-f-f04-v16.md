# 阶段 F-04 v16（std.crypto crypto.c shell 去 C）

> **F-04 v16 v1**：**`std/crypto/crypto.c`** → **`crypto_core.sx`** + **`crypto_inc_glue.c`**（inc.c 仍 C 胶层）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/crypto/crypto_core.sx` | mem_eq、SHA-256、HMAC-SHA256 |
| `std/crypto/crypto_inc_glue.c` | aes_gcm / chacha20_poly1305 / ed25519.inc.c + SHA-512 / HMAC-SHA512 |
| ~~`std/crypto/crypto.c`~~ | 已删除 |

## 构建

```bash
make -C compiler ../std/crypto/crypto.o   # ld -r(crypto_inc_glue.o + crypto_main.o)
```

无 shux-c 时仅链 glue.o（缺 .sx 符号；烟测 SKIP）。

## 门禁

```bash
SHUX_F04_CRYPTO_V16_FAIL=1 ./tests/run-f04-std-crypto-v16-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-gate.sh
./tests/run-std-crypto-*-gate.sh
```

## 下一项

- **F-04 v17 ✅**：`aes_gcm.inc.c` → `aes_gcm.sx`（见 `phase-f-f04-v17.md`）
- **F-04 v18**：`chacha20_poly1305.inc.c` → `.sx` 或分平台 FFI
