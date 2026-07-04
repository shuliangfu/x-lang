# STD-153：std.simd 自动向量化策略 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-047 shuffle/select、STD-061 prod bench

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | 打开 `tests/baseline/std-simd-autovec-strategy-manifest.tsv` |
| 3 | `./tests/run-std-simd-autovec-strategy-gate.sh` |
| 4 | 金样：`tests/std-simd/autovec_strategy.x` |

---

## 2. 策略表

| 场景 | API | 行为 |
|------|-----|------|
| 探测 HW | `hw_available()` | arm64/x86_64/riscv64 v1 返回 1 |
| 默认推荐 | `recommend_simd_path()` | auto：有 HW → `SIMD_PATH_HW`，否则标量 |
| 强制标量 | 环境 `SHUX_SIMD_HW=0` 或 `SHUX_SIMD_AUTovec=scalar` | 始终 `SIMD_PATH_SCALAR` |
| 强制 HW | `SHUX_SIMD_AUTovec=hw` | 有 HW 则 HW，否则标量 |

常量：`SIMD_PATH_SCALAR`（0）、`SIMD_PATH_HW`（1）。

编译器 emit 仍由 `SHUX_SIMD_HW` / 内联 pass 控制；本模块提供**运行时策略查询**与 gate 验收锚点。

---

## 3. 跨平台性能验收

gate 在具备 native `shux_asm` 时运行：

| Bench | 脚本 | 默认阈值 |
|-------|------|----------|
| Vec4f dot | `run-perf-simd-dot.sh` | Shu ≥ 0.90× C `-O2 -msse2` |
| shuffle/select | `run-perf-simd-shuffle-select.sh` | stub/Shu ≥ 1.0 |

平台向量见 `tests/baseline/std-simd-autovec-strategy.tsv`（可按 OS-ARCH 覆盖 `min_dot_ratio` / `min_ss_ratio`）。  
无 native 编译器或 perf 跳过时 gate 仍可通过（manifest + 策略烟测 OK）。

---

## 4. Gate

```bash
./tests/run-std-simd-autovec-strategy-gate.sh
```

报告：`shux: [SHUX_STD153_SIMD_AUTovec]`

回归：保留 `run-std-simd-shuffle-select-gate.sh`、`run-std-simd-prod-gate.sh`。

---

## 5. 非目标（v1）

- 编译器 loop 自动向量化 pass 本身
- SVE/AVX-512 动态分派表
- Windows MSYS perf 硬失败（向量表标记 skip）
