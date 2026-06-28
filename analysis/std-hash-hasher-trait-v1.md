# STD-056：std.hash Hasher trait 化与 SipHash / aHash 切换 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1 预研）**  
> 关联：STBL `tests/baseline/std-hash-api.tsv`（Tier-S 稳定 API 不变）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-hash-hasher-trait.tsv` |
| 3 | `./tests/run-std-hash-hasher-trait-gate.sh` |

---

## 2. Hasher trait 抽象（v1）

Shux 尚无语言级 `trait`，v1 以**统一 C 状态机 + `.sx` 工厂 API** 表达 Hasher：

| 概念 | v1 映射 |
|------|---------|
| `Hasher::new()` | `start_algo(algo)` |
| `write_bytes` | `write_bytes_algo` |
| `finish` | `finish_algo` |
| `drop` | `free_algo` |
| 默认算法 | `default_hasher()` / `SHUX_HASH_ALGO` |

**Tier-S 稳定 API**（`start` / `bytes` 等）**始终走 SipHash**，与既有 HashMap / 回归兼容。

| 常量 | 值 | 说明 |
|------|-----|------|
| `HASHER_SIPHASH` | 0 | 默认；抗哈希碰撞，适合持久化键 |
| `HASHER_AHASH` | 1 | 快速路径预研；v1 用 **FNV-1a 64** 占位，后续可换真 aHash |

环境变量 **`SHUX_HASH_ALGO`**：

- 未设置 / `siphash` → `HASHER_SIPHASH`
- `ahash` / `1` → `HASHER_AHASH`

---

## 3. 选型说明（SipHash vs aHash）

| 维度 | SipHash | aHash（目标） | v1 FNV-1a 占位 |
|------|---------|---------------|----------------|
| 速度 | 中 | 快 | 最快 |
| 抗碰撞 | 强（Keyed） | 非加密、表内够用 | 弱，仅烟测 |
| 默认 | ✅ `start` | 可选 `start_algo(1)` | 同左 |

**结论**：生产默认保持 SipHash；需要吞吐的内存表可在预研阶段显式选 `HASHER_AHASH`，待真 aHash 落地后替换 `hash_glue.c` 内实现而不改 `.sx` API。

---

## 4. 金样向量

| ID | 输入 | 算法 | 期望 u64 |
|----|------|------|----------|
| `ahash_abc` | `"abc"` | aHash(FNV-1a) | `0xe71fa2190541574b` |
| `sip_ne_ahash` | `"abc"` | SipHash ≠ aHash | `rs != ra` |

---

## 5. 门禁

```bash
./tests/run-std-hash-hasher-trait-gate.sh
```

manifest 校验 API / 常量 / C 符号；**C 烟测** `hasher_switch_ok.c` 校验 aHash 金样；有 native `shux-c` 时跑 `hasher_switch.sx`（仅 SipHash≠aHash 与默认算法）。
