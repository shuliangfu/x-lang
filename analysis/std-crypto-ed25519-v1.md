# STD-126：std.crypto Ed25519 v1

> 状态：**定版（v1，Ed25519 sign/verify 子集）**

## API

| 名称 | 说明 |
|------|------|
| `ed25519_public_from_seed` | 32B seed → 32B 公钥 |
| `ed25519_sign` | seed + 消息 → 64B 签名 |
| `ed25519_verify` | 公钥 + 消息 + 签名验签 |
| `ed25519_smoke` | RFC 8032 §7.1 TEST 1 C 烟测 |

## 实现

- C 后端：orlp/ref10（`std/crypto/ed25519/`，zlib 许可）
- 由 `std/crypto/ed25519.inc.c` 链入 `crypto.c`

## 门禁

`./tests/run-std-crypto-ed25519-gate.sh`
