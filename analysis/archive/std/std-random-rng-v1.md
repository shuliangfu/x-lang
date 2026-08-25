# STD-130 std.random PRNG v1

> 更新时间：2026-06-19  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-130、`std/random/mod.x`、`std/random/random.c`

---

## 1. 目标

在 CSPRNG（`fill_bytes` / `next_u32` / `next_u64`）之外，提供**可复现** PRNG，供测试、仿真与确定性回放。算法采用 **SplitMix64**（单 u64 状态，速度快、统计性质足够烟测与基准）。

| API | 说明 |
|-----|------|
| `Rng` | `{ state: u64 }` PRNG 状态 |
| `seed` / `step` | 用 seed 初始化 / 推进状态 |
| `fill` | 用 PRNG 字节填充缓冲 |
| `range` | [lo, hi] 闭区间均匀 u32（拒绝采样） |
| `rng_smoke` | 委托 `random_rng_smoke_c` 做 C 层烟测 |

---

## 2. 与 CSPRNG 的边界

- **CSPRNG**：`random_*_c`，系统熵源（getentropy / getrandom / BCrypt）。
- **PRNG**：纯确定性；**不得**用于密钥、nonce、会话 ID 等安全场景。

---

## 3. 门禁

- Manifest：`tests/baseline/std-random-rng-manifest.tsv`
- 烟测：`tests/random/rng_roundtrip.x`、`tests/random/main.x`
- Gate：`tests/run-std-random-rng-gate.sh`（权威验收见 **§5 Gate**）

---

## 4. 链接

用户 `-o exe` 且引用 `rng_smoke` 或 `extern random_rng_smoke_c` 时，编译器按需链入 `std/random/random.o`（与 CSPRNG 同对象文件）。

---

## 5. Gate

```bash
./tests/run-std-random-rng-gate.sh
```

**Honesty (2026-08-26)**：prefer `xlang_asm`＋`XLANG_LINK_XLANG`；`check` 观测（闸门暂停 2026-08-05）；`rng_roundtrip.x`／`main.x` exit0 硬失败（无 soft SKIP）；C smoke 仅观测；报告 `check=`／`rt=`／`main=`／`skip=`。旧闸偏 `xlang-c`／硬 check（CHK002）／x runnable soft SKIP 却报 OK／section `## 3. 门禁`＝portable 假红；产品 asm 烟测本绿。

**report** 示例：

```
xlang: [XLANG_STD130_RANDOM_RNG] status=ok check=1 rt=1 main=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-19 | SplitMix64 PRNG + manifest + roundtrip 烟测 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；`## 5. Gate`；报告 `check=`／`rt=`／`main=` |
