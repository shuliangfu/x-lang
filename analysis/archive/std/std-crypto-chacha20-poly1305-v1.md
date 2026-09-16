# STD-113：std.crypto ChaCha20-Poly1305 v1

> 状态：**定版（v1，ChaCha 子集；ed25519 见 STD-126）**

## API

| 名称 | 说明 |
|------|------|
| `chacha20_poly1305_seal` | 32B key / 12B nonce / 16B tag AEAD 加密 |
| `chacha20_poly1305_open` | 解密并校验 tag |
| `chacha20_poly1305_smoke` | C 往返烟测 |

## Gate

```bash
./tests/run-std-crypto-chacha20-poly1305-gate.sh
```

Honesty (2026-08-28): prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `std/crypto/crypto.o`＝obs；check＋tip product UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。

```
xlang: [XLANG_STD113_CRYPTO_CHACHA] status=ok run=… obs=… skip=0
```

manifest：`tests/baseline/std-crypto-chacha20-poly1305.tsv`

关键词锚：`STD-113` · `chacha20_poly1305_seal` · `chacha20_poly1305_open` · `CHACHA20_POLY1305_KEY_LEN`
