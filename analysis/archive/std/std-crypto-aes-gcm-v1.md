# STD-049：std.crypto AES-GCM 最小集 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-006（hash/HMAC）、`std/crypto/aes_gcm.inc.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-crypto-aes-gcm-vectors.tsv` |
| 3 | `./tests/run-std-crypto-aes-gcm-gate.sh` |
| 4 | 烟测：`tests/std-crypto/aes_gcm_nist2.x` |

---

## 2. AES-GCM API（v1 子集）

| API | 说明 |
|-----|------|
| `aes_gcm_seal` | AES-128-GCM 加密；`key_len=16`、`iv_len=12`、tag 16B |
| `aes_gcm_open` | 解密并校验 tag；失败 -1 |
| `AES_GCM_KEY_LEN` / `AES_GCM_IV_LEN` / `AES_GCM_TAG_LEN` | 常量 16 / 12 / 16 |

实现：`std/crypto/aes_gcm.x`（ld -r 链入 crypto.o）。

---

## 3. NIST 金样向量

| ID | 来源 | 验证 |
|----|------|------|
| `nist2_tc` | SP 800-38D Test Case 2（全零 key/iv/pt） | `aes_gcm_nist2.x` |

详见 `tests/baseline/std-crypto-aes-gcm-vectors.tsv`。

---

## 4. 可选链入

与既有 `std.crypto` 一致：使用 `aes_gcm_*` 时由链接器按需拉入 `std/crypto/crypto.o`（`runtime.c` `get_std_crypto_o_path`）。未引用 API 时不增体积。

---

## 5. 门禁

```bash
./tests/run-std-crypto-aes-gcm-gate.sh
```

```
shux: [SHUX_STD_CRYPTO_AES_GCM] status=ok seal=1 open=1 main=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | AES-128-GCM seal/open + NIST TC2 金样 |
