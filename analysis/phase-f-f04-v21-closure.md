# 阶段 F-04 v21（std.crypto 模块闭合）

> **F-04 v21**：**std.crypto** 对外 API 全在 **`.sx`**；**`crypto.c` 及全部 `.inc.c` 已删除**；仅保留文档化最小胶层 C。

## v21 闭合清单（✅ manifest）

| 模块 | 主逻辑 (.sx) | 阶段 |
|------|--------------|------|
| 核心 | `crypto_core.sx`（mem_eq / SHA-256 / HMAC-SHA256） | v16 |
| AES-GCM | `aes_gcm.sx` | v17 |
| ChaCha20-Poly1305 | `chacha20_poly1305.sx` | v18 |
| Ed25519 API | `ed25519.sx` | v19 |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/crypto/crypto.c`~~ | v16 删除 |
| ~~`std/crypto/aes_gcm.inc.c`~~ | v17 删除 |
| ~~`std/crypto/chacha20_poly1305.inc.c`~~ | v18 删除 |
| ~~`std/crypto/ed25519.inc.c`~~ | v19 删除 |

## 仍允许的 C（胶层 only）

| 文件 | 原因 |
|------|------|
| `crypto_inc_glue.c` | SHA-512 / HMAC-SHA512（委托 ref10 内 sha512） |
| `ed25519_ref10_glue.c` | Ed25519 ref10 曲线（fe/ge/sc 等 #include） |
| `std/crypto/ed25519/*.c` | glue 内部实现源（v20 可迁 .sx） |
| `std/crypto/ed25519/*.h` | glue 内部头文件 |

## 构建

```bash
make -C compiler ../std/crypto/crypto.o
# ld -r(crypto_inc_glue.o + ed25519_ref10_glue.o + 4× .sx main.o)
```

## 门禁

```bash
SHUX_F04_CRYPTO_CLOSURE_FAIL=1 ./tests/run-f04-std-crypto-closure-gate.sh
SHUX_STD_CRYPTO_MANIFEST_ONLY=1 ./tests/run-std-crypto-gate.sh
```

## 下一项

- **F-04 v20**（可选深化）：ref10 fe/ge/sc 迁 `.sx`，清零 `ed25519/*.c`
- **F-09 v1 ✅**：全仓库手写 C 审计门禁；见 `phase-f-f09-v1.md`
