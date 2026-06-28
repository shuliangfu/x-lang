# 阶段 F-04 v18（std.crypto chacha20_poly1305.inc.c → chacha20_poly1305.sx）

> **F-04 v18 v1**：**`std/crypto/chacha20_poly1305.inc.c`** → **`chacha20_poly1305.sx`**（ChaCha20-Poly1305 AEAD 纯 .sx 实现）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/crypto/chacha20_poly1305.sx` | ChaCha20、Poly1305、seal/open/smoke C ABI |
| `std/crypto/core.sx` | mem_eq、SHA-256、HMAC-SHA256（v16） |
| `std/crypto/aes_gcm.sx` | AES-128-GCM（v17） |
| `std/crypto/crypto_inc_glue.c` | ed25519.inc.c + SHA-512 / HMAC-SHA512 |
| ~~`std/crypto/chacha20_poly1305.inc.c`~~ | 已删除 |

## 构建

```bash
make -C compiler ../std/crypto/crypto.o   # ld -r(glue.o + crypto_main.o + aes_gcm_main.o + chacha_main.o)
```

无 shux-c 时仅链 glue.o（缺 .sx 符号；AEAD 烟测 SKIP）。

## 门禁

```bash
SHUX_F04_CRYPTO_V18_FAIL=1 ./tests/run-f04-std-crypto-v18-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-chacha20-poly1305-gate.sh
```

## 下一项

- **F-04 v19 ✅**：`ed25519.sx` + `ed25519_ref10_glue.c`；见 `phase-f-f04-v19.md`
