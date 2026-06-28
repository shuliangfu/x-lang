# 阶段 F-crypto v1（std.crypto 纳入 F 聚合 batch）

> **F-crypto v1**：`crypto.c` 已在 **F-04 v16～v21** 删除；实现为 **4× `.sx` + 2 胶层**（`crypto_inc_glue.c`、`ed25519_ref10_glue.c`）；本 gate 将 F-04 闭合纳入 **§9 F 聚合 batch**。

## 现状（F-04 已闭合）

| 项 | 路径 |
|----|------|
| 核心 | `core.sx` |
| AEAD | `aes_gcm.sx`、`chacha20_poly1305.sx` |
| 签名 | `ed25519.sx` |
| 胶层 | `crypto_inc_glue.c`、`ed25519_ref10_glue.c` |
| `crypto.o` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_CRYPTO_V1_FAIL=1 ./tests/run-f-crypto-v1-gate.sh
./tests/run-f04-std-crypto-closure-gate.sh
./tests/run-std-crypto-gate.sh
```

## 下一项

- **F-async v1** ✅ / **F-cache v1**
