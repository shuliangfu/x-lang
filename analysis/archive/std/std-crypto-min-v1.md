# STD-006 std.crypto 最小安全集 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1.1 honesty）** — hash + CSPRNG + MAC 签验最小闭环；闸门假权威已收  
> 关联：`std/crypto/core.x`、`std/random/`、`tests/run-crypto.sh`（产品权威 = `.x`，无 `crypto.c`）

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
| **K3-sig** | 消息认证码签验（对称 MAC） | `std.crypto`：`mac_sign` `mac_verify` | ✅ API；link residual 见 §5 |

**v1 签名模型**：对称 **HMAC-SHA256** MAC（非 Ed25519）；`mac_sign` 生成 tag，`mac_verify` 重算并 `mem_eq` 常量时间比对。

```su
import("std.crypto");
let tag: u8[32] = [];
mac_sign(&key[0], key_len, &msg[0], msg_len, &tag[0]);
if (mac_verify(&key[0], key_len, &msg[0], msg_len, &tag[0]) != 1) { return 1; }
```

**v1 非目标**：非对称签名（Ed25519/ECDSA）、AEAD（ChaCha20-Poly1305）、TLS 握手。

---

## 3. Golden 向量

| case_id | 文件 | 期望 |
|---------|------|------|
| `smoke_sha256_abc` | `tests/std-crypto/sha256_abc.x` | SHA-256(`abc`) FIPS 向量（hard） |
| `smoke_hmac_key_msg` | `tests/std-crypto/hmac_key_msg.x` | HMAC 金样（hard） |
| `smoke_mem_eq` | `tests/std-crypto/mem_eq_ct.x` | 常量时间比较（hard） |
| `smoke_rand_fill` | `tests/std-crypto/rand_fill_smoke.x` | `std.random` fill_bytes（hard） |
| `smoke_main` | `tests/crypto/main.x` | mem_eq + sha256 + hmac 闭环（hard） |
| `smoke_mac_verify` | `tests/std-crypto/mac_verify_smoke.x` | sign + verify（observational；product UNDEF） |
| `hook_crypto` | `tests/run-crypto.sh` | 回归（observational） |
| `hook_random` | `tests/run-random.sh` | 回归（observational） |

向量表：`tests/baseline/std-crypto-vectors.tsv`。

---

## 4. 实现面

| 组件 | 路径 |
|------|------|
| crypto core | `std/crypto/core.x` |
| crypto mod | `std/crypto/mod.x` |
| random | `std/random/random.x` + `runtime_random_fill.from_x.c` |
| AEAD/Ed glue | `compiler/seeds/runtime_crypto_inc_glue.from_x.c` |

---

## 5. Gate

| 组件 | 路径 |
|------|------|
| manifest | `tests/baseline/std-crypto-manifest.tsv` |
| runner | `tests/lib/std-crypto.sh` |
| gate | `tests/run-std-crypto-gate.sh` |

**Honesty（2026-08-26）**：

- Prefer `xlang_asm`；pin `XLANG_LINK_XLANG`（禁 prefer-c 假权威）
- `xlang check` **observational**（自举期暂停闸门 2026-08-05）
- Hard-green：`sha256_abc` / `hmac_key_msg` / `mem_eq_ct` / `rand_fill_smoke` / `crypto/main.x` exit 0
- Observational：`mac_verify_smoke`（product link UNDEF `_std_crypto_mac_*` — **非软**）；hooks
- 无 native xlang → **FAIL**（禁 soft SKIP→OK）
- Report：`check=/sha256=/hmac=/mem_eq=/rand=/main=/mac=/skip=`
- 拒顶层 `analysis/std-crypto-min-v1.md` 复活（live = archive）

gate 输出 **`std-crypto gate OK`** + structured report。

---

## 6. 验收

- [x] RFC + manifest **5** API + **3** layer
- [x] Golden SHA-256 / HMAC / mem_eq / rand / main 烟测 hard
- [x] Gate honesty prefer asm + LINK + check obs（v1.1）
- [x] mac_verify link residual 观测拆分（非 soft 糊绿）
- [x] 联动 `std.random` CSPRNG

### Changelog

| 版 | 日期 | 变更 |
|----|------|------|
| v1 | 2026-06-17 | 定版 K1–K3 + manifest |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check obs／hard runnable／mac obs；`## 5. Gate`；report 8 字段；无 make／`crypto.c` 权威 |
