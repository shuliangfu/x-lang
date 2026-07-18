# STD-113：std.crypto ChaCha20-Poly1305 v1

> 状态：**定版（v1，ChaCha 子集；ed25519 待后续 STD）**

## API

| 名称 | 说明 |
|------|------|
| `chacha20_poly1305_seal` | 32B key / 12B nonce / 16B tag AEAD 加密 |
| `chacha20_poly1305_open` | 解密并校验 tag |
| `chacha20_poly1305_smoke` | C 往返烟测 |

## 门禁

`./tests/run-std-crypto-chacha20-poly1305-gate.sh`
