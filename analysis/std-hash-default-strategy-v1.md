# STD-148：std.hash 默认策略 v1

> 状态：**定版（v1）**  
> 关联：`STD-056` Hasher trait、`STD-105` xxHash64

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-148 | 哈希族选型表 + `recommend_hasher_*` + `SHUX_HASH_ALGO` 文档 + gate |

---

## 2. 默认策略表

| 场景 | 推荐 | 常量 | API |
|------|------|------|-----|
| **Map/Set 默认**（对抗不可信 key） | SipHash | `HASHER_SIPHASH` (0) | `start()` / `recommend_hasher_map()` |
| **内部去重/非对抗表** | xxHash64 | `HASHER_XXHASH` (2) | `xxhash64` / `recommend_hasher_fast()` |
| **轻量快速占位** | FNV-1a64 | `HASHER_AHASH` (1) | `start_algo(HASHER_AHASH)` |
| **Tier-S 稳定** | SipHash | 0 | `start` 族不变 |

**原则**：不可信输入的关联容器用 SipHash；已知安全数据的性能路径用 xxHash64。

---

## 3. SHUX_HASH_ALGO

| 值（前缀匹配） | `default_hasher()` | 说明 |
|----------------|-------------------|------|
| （未设置） | `0` SipHash | 默认 |
| `siphash` / `0` | `0` | 显式 SipHash |
| `ahash` / `1` | `1` | FNV-1a64 占位 |
| `xxhash` / `2` / `x` | `2` | xxHash64 |

环境变量仅影响 `default_hasher()`；`start()` 恒为 SipHash（Tier-S 稳定）。

---

## 4. Gate

```bash
./tests/run-std-hash-default-strategy-gate.sh
```

报告：`shux: [SHUX_STD148_HASH_DEFAULT_STRATEGY]`
