# std.crypto — 常量时间比较、哈希、HMAC、AEAD、Ed25519

**路径**：`std/crypto/`（mod.sx + crypto.c + *.inc.c）  
**依赖**：core。**性能**：restrict、热路径标注，对标 Zig std.crypto。

| API | 说明 |
|-----|------|
| `mem_eq(a, b, len): i32` | 常量时间比较，相等 1 |
| `sha256(msg, len, out): void` | 输出 32 字节 |
| `sha512(msg, len, out): void` | 输出 64 字节 |
| `hmac_sha256(...)` | HMAC-SHA256，out 32 字节 |
| `ed25519_public_from_seed` / `ed25519_sign` / `ed25519_verify` | Ed25519（RFC 8032） |
| `ed25519_smoke(): i32` | C 层烟测 |
| `aes_gcm_seal` / `aes_gcm_open` | AES-128-GCM（12B IV、16B tag） |
| `chacha20_poly1305_seal` / `open` / `smoke` | ChaCha20-Poly1305 AEAD |

**门禁**：`tests/run-std-crypto-*-gate.sh`（ed25519 / aes-gcm / chacha20-poly1305）。
