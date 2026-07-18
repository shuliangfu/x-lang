# 阶段 F-04 v17（std.crypto aes_gcm.inc.c → aes_gcm.x）

> **F-04 v17 v1**：**`std/crypto/aes_gcm.inc.c`** → **`aes_gcm.x`**（AES-128-GCM 纯 .x 实现）。

## 迁移范围

| 文件 | 说明 |
|------|------|
| `std/crypto/aes_gcm.x` | AES-128 加密、GCM GHASH/GCTR、crypto_aes_gcm_seal_c / open_c |
| `std/crypto/core.x` | mem_eq、SHA-256、HMAC-SHA256（v16） |
| `std/crypto/crypto_inc_glue.c` | chacha20_poly1305 / ed25519.inc.c + SHA-512 / HMAC-SHA512 |
| ~~`std/crypto/aes_gcm.inc.c`~~ | 已删除 |

## 构建

```bash
make -C compiler ../std/crypto/crypto.o   # ld -r(glue.o + crypto_main.o + aes_gcm_main.o)
```

无 shux-c 时仅链 glue.o（缺 .x 符号；AEAD 烟测 SKIP）。

## 门禁

```bash
SHUX_F04_CRYPTO_V17_FAIL=1 ./tests/run-f04-std-crypto-v17-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-aes-gcm-gate.sh
```

## 下一项

- **F-04 v18 ✅**：`chacha20_poly1305.inc.c` → `chacha20_poly1305.x`（见 `phase-f-f04-v18.md`）
- **F-04 v19**：`ed25519.inc.c` → `.x` 或分平台 FFI
