# STD-006 std.crypto 最小安全集 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — hash + CSPRNG + MAC 签验最小闭环  
> 关联：`std/crypto/crypto.c`、`std/random/`、`tests/run-crypto.sh`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 安全层 K1–K3 |
| 2 | 打开 `tests/baseline/std-crypto-manifest.tsv` |
| 3 | `./tests/run-std-crypto-gate.sh` |
| 4 | `./tests/run-std-crypto.sh` |

---

## 2. 安全层 K1–K3

权威：`tests/baseline/std-crypto-manifest.tsv`（**3** 条 `layer_*`）。

| 层级 | 能力 | 模块/API | v1 状态 |
|------|------|----------|---------|
| **K1-hash** | SHA-256/512、HMAC、常量时间比较 | `std.crypto`：`sha256` `sha512` `hmac_sha256` `mem_eq` | ✅ |
| **K2-rand** | 密码学安全随机（CSPRNG） | `std.random`：`fill_bytes` `u32` `u64` | ✅ |
| **K3-sig** | 消息认证码签验（对称 MAC） | `std.crypto`：`mac_sign` `mac_verify` | ✅ |

**v1 签名模型**：对称 **HMAC-SHA256** MAC（非 Ed25519）；`mac_sign` 生成 tag，`mac_verify` 重算并 `mem_eq` 常量时间比对。

```su
import("std.crypto");
let tag: u8[32] = [];
mac_sign(&key[0], key_len, &msg[0], msg_len, &tag[0]);
if (mac_verify(&key[0], key_len, &msg[0], msg_len, &tag[0]) != 1) { return 1; }
```

**v1 非目标**：非对称签名（Ed25519/ECDSA）、AEAD（ChaCha20-Poly1305 占位见 `crypto.c` 注释）、TLS 握手。

---

## 3. Golden 向量

| case_id | 文件 | 期望 |
|---------|------|------|
| `smoke_sha256_abc` | `tests/std-crypto/sha256_abc.x` | SHA-256(`abc`) FIPS 向量 |
| `smoke_hmac_key_msg` | `tests/std-crypto/hmac_key_msg.x` | HMAC 金样 |
| `smoke_mac_verify` | `tests/std-crypto/mac_verify_smoke.x` | sign + verify 闭环 |
| `smoke_mem_eq` | `tests/std-crypto/mem_eq_ct.x` | 常量时间比较 |
| `smoke_rand_fill` | `tests/std-crypto/rand_fill_smoke.x` | `std.random` fill_bytes |
| `hook_crypto` | `tests/run-crypto.sh` | 回归 |
| `hook_random` | `tests/run-random.sh` | 回归 |

向量表：`tests/baseline/std-crypto-vectors.tsv`。

---

## 4. Gate 与 report

| 组件 | 路径 |
|------|------|
| manifest | `tests/baseline/std-crypto-manifest.tsv` |
| runner | `tests/lib/std-crypto.sh` |
| gate | `tests/run-std-crypto-gate.sh` |

gate 输出 **`std-crypto gate OK`**；无 native `shux` 时 manifest 仍过、**runnable** bench SKIP。

---

## 5. 验收

- [x] RFC + manifest **5** API + **3** layer
- [x] Golden SHA-256 / HMAC 向量烟测
- [x] `mac_sign` / `mac_verify` 闭环
- [x] 联动 `std.random` CSPRNG
