# std.crypto — 常量时间比较、哈希、HMAC、AEAD、Ed25519

**路径**：`std/crypto/`（mod.sx + core.sx + aes_gcm.sx + chacha20_poly1305.sx + ed25519.sx）  
**依赖**：core。**性能**：restrict、热路径标注，对标 Zig std.crypto。

| API | 说明 |
|-----|------|
| `mem_eq(a, b, len): i32` | 常量时间比较，相等 1 |
| `sha256(msg, len, out): void` | 输出 32 字节（core.sx） |
| `sha512(msg, len, out): void` | 输出 64 字节（runtime glue + ref10/sha512.c） |
| `hmac_sha256(...)` | HMAC-SHA256，out 32 字节 |
| `ed25519_public_from_seed` / `ed25519_sign` / `ed25519_verify` | Ed25519（ed25519.sx + runtime ref10 胶层） |
| `ed25519_smoke(): i32` | C 层烟测 |
| `aes_gcm_seal` / `aes_gcm_open` | AES-128-GCM（12B IV、16B tag；aes_gcm.sx） |
| `chacha20_poly1305_seal` / `open` / `smoke` | ChaCha20-Poly1305 AEAD（chacha20_poly1305.sx） |

**构建**：`make -C compiler ../std/crypto/crypto.o`（ld -r：4× .sx main.o；链入时另加 `runtime_ed25519_ref10_glue.o` + `runtime_crypto_inc_glue.o`）

## F-04 v21 / F-ZC 闭合

- 对外 API 均在 **`.sx`**；SHA-512/ref10 胶层在 **`compiler/src/asm/runtime_*_glue.c`**
- ref10 实现源：`compiler/src/asm/crypto/ed25519/*.c`
- 文档：`analysis/phase-f-f04-v21-closure.md`
- 聚合 gate：`./tests/run-f04-std-crypto-closure-gate.sh`

**门禁**：`tests/run-f04-std-crypto-closure-gate.sh`、`tests/run-f04-std-crypto-v16～v19-gate.sh`、`tests/run-std-crypto-*-gate.sh`
