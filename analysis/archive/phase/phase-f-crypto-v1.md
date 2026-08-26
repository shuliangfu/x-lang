# 阶段 F-crypto v1（std.crypto 纳入 F 聚合 batch）

> **F-crypto v1**：`crypto.c` 已在 **F-04 v16～v21** 删除；实现为 **4× `.x` + 2 胶层**（`crypto_inc_glue.c`、`ed25519_ref10_glue.c`）；本 gate 将 F-04 闭合纳入 **§9 F 聚合 batch**。
>
> **2026-08-27 honesty**：闸门 hard-fail（退役 soft `XLANG_F_CRYPTO_V1_FAIL`）；prefer `xlang_asm`＋`XLANG_LINK_XLANG`；硬委托 F-04 closure＋STD-049 aes-gcm＋STD-050 sha512-hmac；STD-113 chacha／STD-126 ed25519 **观测**（产品残／旧 prefer-c 子闸，非 soft 糊绿）。

## 现状（F-04 已闭合）

| 项 | 路径 |
|----|------|
| 核心 | `core.x` |
| AEAD | `aes_gcm.x`、`chacha20_poly1305.x` |
| 签名 | `ed25519.x` |
| 胶层 | `crypto_inc_glue.c`、`ed25519_ref10_glue.c` |
| `crypto.o` | `ld -r` 合并 |

## Gate

```bash
./tests/run-f-crypto-v1-gate.sh
# expect: status=ok static=1 ensure=1 f04=1 aes=1 sha512=1 skip=0
# chacha=/ed25519= may be 0 (observational)
# neg: DOC missing ## Gate → RC=1
./tests/run-f04-std-crypto-closure-gate.sh
./tests/run-std-crypto-aes-gcm-gate.sh
./tests/run-std-crypto-sha512-hmac-gate.sh
```

## 下一项

- **f-* v1 soft FAIL 池空**（本闸收口后）；续 prefer-c／archaeology／f-v2／zc host-c 后置
