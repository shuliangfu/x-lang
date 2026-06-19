# COMP-021：incr-compile 生产 tier 烟测 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-020 `comp-incr-compile-wave-v1.md`、`comp-incr-compile.tsv`  
> 关联：OBS-001 阶段计时、PERF-004 dogfood

---

## 1. 目标

在 COMP-020 wave tier 基础上扩展 **生产 tier**：登记 4 条 `hook_prod`，持续追踪二次编译烟测、阶段计时、COMP-007 父 manifest 与 **COMP-020 wave** 父波次。

验收：`tests/run-comp-incr-compile-prod-gate.sh` 绿；`comp-incr-compile.tsv` **≥4** 条 `tier=prod` hook（`min_prod_hooks=4`）。

---

## 2. 生产矩阵（prod tier）

| item_id | hook | 平台 | 说明 |
|---------|------|------|------|
| `prod_incr_smoke` | `run-comp-incr-compile.sh` | 全平台 | 二次编译 ratio 烟测 |
| `prod_timing` | `run-obs-compile-phase-timing-gate.sh` | 全平台 | `SHUX_COMPILE_PHASE_TIMING` gate |
| `prod_comp007` | `run-comp-incr-compile-gate.sh` | 全平台 | COMP-007 父 manifest |
| `prod_comp020` | `run-comp-incr-compile-wave-gate.sh` | 全平台 | COMP-020 wave 父波次 |

Darwin / 无 native `shux`：manifest 绿 + prod runnable **SKIP**。

---

## 3. Gate

```bash
./tests/run-comp-incr-compile-prod-gate.sh
```

```
shux: [SHUX_COMP021_INCR_PROD] status=ok prod_ok=4 prod_run=2 prod_skip=2 skip=1
```

- **prod_ok**：prod hook 已登记且父 COMP-020 manifest 绿
- **prod_run**：本机 runnable 通过的 prod hook 数
- **prod_skip**：SKIP/N/A 的 prod runnable 数

---

## 4. 联动

- 父 manifest：`tests/baseline/comp-incr-compile.tsv`（`min_prod_hooks=4`）
- 波次表：`tests/baseline/comp-incr-compile-prod-wave.tsv`
- 父波次：`run-comp-incr-compile-wave-gate.sh`（COMP-020）
- bench：`tests/baseline/comp-incr-compile-bench.tsv`（承前 5 条）
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- C6 内容寻址 `.o` 缓存硬门禁
- 二次编译 median ≤0.85× 全平台硬阈值
- 分布式编译缓存
