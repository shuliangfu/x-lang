# std.hash — Hasher 与哈希算法

对标 **Zig** `std.hash`、**Rust** `std::hash::Hasher`。

**模块路径**：`std/hash/mod.sx` + `std/hash/hash.sx`（F-hash v2 纯 .sx）

## 算法族

| 常量 | 值 | 算法 | 用途 |
|------|-----|------|------|
| `HASHER_SIPHASH` | 0 | SipHash-2-4 | Map/Set 默认（对抗性） |
| `HASHER_AHASH` | 1 | FNV-1a64 占位 | 轻量快速 |
| `HASHER_XXHASH` | 2 | xxHash64 | 非对抗快速路径 |

## 默认策略（STD-148）

| 场景 | 推荐 API |
|------|----------|
| Map/Set / 不可信 key | `recommend_hasher_map()` → SipHash |
| 内部去重 / checksum | `recommend_hasher_fast()` → xxHash64 |
| Tier-S 稳定 | `start()`（恒 SipHash） |

环境变量 **`SHUX_HASH_ALGO`**：`siphash`（默认）/ `ahash` / `xxhash` — 仅影响 `default_hasher()`。

## API 摘要

- **稳定（Tier-S）**：`start` / `write` / `write_bytes` / `finish` / `free` / `bytes`
- **多算法 trait**：`start_algo` / `write_algo` / `write_bytes_algo` / `finish_algo` / `free_algo`
- **一次性**：`xxhash64` / `xxhash64_seed`

RFC：`analysis/std-hash-default-strategy-v1.md`（STD-148）· `analysis/std-hash-hasher-trait-v1.md`（STD-056）· `analysis/std-hash-xxhash-v1.md`（STD-105）

## Gate

```bash
./tests/run-std-hash-hasher-trait-gate.sh
./tests/run-std-hash-xxhash-gate.sh
./tests/run-std-hash-default-strategy-gate.sh
```
