# STD-105：std.hash xxHash64 非加密快速哈希 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-hash-xxhash.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-hash-xxhash.tsv` |
| 3 | `./tests/run-std-hash-xxhash-gate.sh` |

---

## 2. xxHash64 语义

| API | 说明 |
|-----|------|
| `hash_xxhash64(ptr, len)` | 一次性 xxHash64（seed=0） |
| `hash_xxhash64_seed(ptr, len, seed)` | 一次性 xxHash64（指定 seed） |
| `hash_start_algo(HASHER_XXHASH)` | 增量 Hasher（与 STD-056 工厂 API 共用） |

**常量**：`HASHER_XXHASH = 2`；环境变量 `SHUX_HASH_ALGO=xxhash` / `2` 可选。

Tier-S API（`hash_start` / `hash_bytes`）**仍仅 SipHash**。

---

## 3. 金样

| 输入 | seed | 期望 u64 |
|------|------|----------|
| `""` | 0 | `0xef46db3751d8e999` |
| `"abc"` | 0 | `0x44bc2cf5ad770999` |

---

## 4. 门禁

```bash
make -C compiler ../std/hash/hash.o
./tests/run-std-hash-xxhash-gate.sh
```
