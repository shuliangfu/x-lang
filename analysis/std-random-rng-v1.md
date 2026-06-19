# STD-130：std.random 可复现 PRNG v1

> 状态：**定版（v1，SplitMix64；非 CSPRNG）**

## API

| 名称 | 说明 |
|------|------|
| `Rng` | PRNG 状态（u64 seed 链） |
| `rng_init` / `rng_from_seed` | 初始化 |
| `rng_next_u32` / `rng_next_u64` | 顺序随机数 |
| `rng_fill_bytes` / `rng_range_u32` | 字节填充与区间采样 |
| `rng_smoke` | SplitMix64 金样 C 烟测 |

CSPRNG（`fill_bytes` / `u32` / `u64`）路径不变。

## 门禁

`./tests/run-std-random-rng-gate.sh`
