# STD-050：std.crypto SHA-512 与 HMAC 扩展 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-006（hash/HMAC 256 路径）、STD-049（AES-GCM）、`std/crypto/crypto.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2（统一命名表） |
| 2 | `tests/baseline/std-crypto-sha512-hmac-vectors.tsv` |
| 3 | `./tests/run-std-crypto-sha512-hmac-gate.sh` |
| 4 | 烟测：`sha512_abc.sx`、`hmac_sha512_rfc4231_tc1.sx`、`mac_verify_512_smoke.sx` |

---

## 2. 统一命名（SHA-256 / SHA-512 对称）

| 摘要 | 输出长度 | Hash | HMAC | MAC 签 | MAC 验 | Tag |
|------|----------|------|------|--------|--------|-----|
| SHA-256 | 32 B | `sha256` | `hmac_sha256` | `mac_sign` | `mac_verify` | 32 B |
| SHA-512 | 64 B | `sha512` | `hmac_sha512` | `mac_sign_512` | `mac_verify_512` | 64 B |

模块常量（`std/crypto/mod.sx`）：`SHA256_DIGEST_LEN=32`、`SHA512_DIGEST_LEN=64`。

实现：`crypto_sha512_c` / `crypto_hmac_sha512_c`（`std/crypto/crypto.c`）；HMAC block=128（RFC 4231）。

**填充注意**：SHA-512 在 128 字节块末附加 **128-bit** 比特长度：高 64 位（字节 112–119）为 0，低 64 位（字节 120–127）为大端比特数（FIPS 180-4）。

---

## 3. 金样向量

| ID | 来源 | 验证 |
|----|------|------|
| `sha512_abc` | FIPS 180-4 / NIST `abc` | `sha512_abc.sx` |
| `hmac_rfc4231_tc1` | RFC 4231 Test Case 1（key=20×0x0b，msg=`Hi There`） | `hmac_sha512_rfc4231_tc1.sx` |
| `mac_verify_512` | `mac_sign_512` + `mac_verify_512` 签验闭环 | `mac_verify_512_smoke.sx` |

详见 `tests/baseline/std-crypto-sha512-hmac-vectors.tsv`。

---

## 4. 可选链入

与 STD-006/049 一致：引用 `sha512` / `hmac_sha512` / `mac_*_512` 时链接 `std/crypto/crypto.o`；未引用不增体积。

---

## 5. 门禁

```bash
./tests/run-std-crypto-sha512-hmac-gate.sh
```

```
shux: [SHUX_STD_CRYPTO_SHA512_HMAC] status=ok sha512=1 hmac=1 mac512=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | SHA-512 + HMAC-SHA512 + mac_sign_512/mac_verify_512；修复 128-bit 长度字段字节序 |
