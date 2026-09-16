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

## Gate

```bash
./tests/run-std-crypto-ed25519-gate.sh
```

Honesty (2026-08-28): prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft `ensure_runtime_*_glue_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `std/crypto/crypto.o`＝obs；check＋tip product UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。

```
xlang: [XLANG_STD126_CRYPTO_ED25519] status=ok run=… obs=… skip=0
```

manifest：`tests/baseline/std-crypto-ed25519-manifest.tsv`

关键词锚：`STD-126` · `ed25519_public_from_seed` · `ed25519_sign` · `ed25519_verify` · `ED25519_SEED_LEN`
