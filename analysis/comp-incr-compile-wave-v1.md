# COMP-020：incr-compile 二次编译烟测扩面（wave tier）v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-007 `comp-incr-compile-v1.md`、`comp-incr-compile.tsv`  
> 关联：OBS-001 阶段计时、PERF-004 dogfood

---

## 1. 目标

在 COMP-007 增量编译 manifest 上扩展 **wave tier**：登记 4 条 `hook_wave`，持续追踪二次编译烟测、阶段计时 gate、父 COMP-007 manifest 与 **dogfood** bench 扩面。

验收：`tests/run-comp-incr-compile-wave-gate.sh` 绿；`comp-incr-compile.tsv` **≥4** 条 `tier=wave` hook（`min_wave_hooks=4`）；bench **≥5** 条。

---

## 2. Wave 矩阵（wave tier）

| item_id | hook | 平台 | 说明 |
|---------|------|------|------|
| `wave_incr_smoke` | `run-comp-incr-compile.sh` | 全平台 | 二次编译 ratio 烟测 |
| `wave_timing` | `run-obs-compile-phase-timing-gate.sh` | 全平台 | `SHUX_COMPILE_PHASE_TIMING` gate |
| `wave_comp007` | `run-comp-incr-compile-gate.sh` | 全平台 | COMP-007 父 manifest |
| `wave_dogfood` | `run-comp-incr-compile.sh` | 全平台 | `bench_dogfood_check` 扩面 |

Darwin / 无 native `shux`：manifest 绿 + wave runnable **SKIP**。

---

## 3. Gate

```bash
./tests/run-comp-incr-compile-wave-gate.sh
```

```
shux: [SHUX_COMP020_INCR_WAVE] status=ok wave_ok=4 wave_run=2 wave_skip=2 skip=1
```

- **wave_ok**：wave hook 已登记且父 COMP-007 manifest 绿
- **wave_run**：本机 runnable 通过的 wave hook 数
- **wave_skip**：SKIP/N/A 的 wave runnable 数

---

## 4. 联动

- 父 manifest：`tests/baseline/comp-incr-compile.tsv`（`min_wave_hooks=4`）
- 波次表：`tests/baseline/comp-incr-compile-wave.tsv`
- bench：`tests/baseline/comp-incr-compile-bench.tsv`（含 `bench_dogfood_check`）
- 父门禁：`run-comp-incr-compile-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- incr-compile **prod tier** 见 COMP-021 `comp-incr-compile-prod-v1.md`
- C6 内容寻址 `.o` 缓存硬门禁
- 二次编译 median ≤0.85× 全平台硬阈值
- 分布式编译缓存
