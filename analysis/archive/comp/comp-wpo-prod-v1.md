# COMP-015：WPO 小规模持续启用（生产 gate）v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-004 `comp-wpo-v1.md`、`comp-wpo.tsv`  
> 关联：S5 build_asm 五模块链、`run-wpo-strict-link-gate.sh`

---

## 1. 目标

在 COMP-004 原型 manifest 上扩展 **生产 tier**：登记 5 条 `hook_prod`，runnable gate 持续追踪 DCE / reach / build_asm chain / strict link。

验收：`tests/run-comp-wpo-prod-gate.sh` 绿；`comp-wpo.tsv` **≥5** 条 `tier=prod` hook（`min_prod_hooks=5`）。

---

## 2. 生产矩阵（prod tier）

| item_id | hook | 平台 | 说明 |
|---------|------|------|------|
| `prod_dce` | `run-wpo-dce-emit.sh` | 全平台 | shux-c DCE 烟测 |
| `prod_reach_typeck` | `run-wpo-typeck-reach-gate.sh` | Linux | typeck_wpo.o reach |
| `prod_reach_pipeline` | `run-wpo-pipeline-reach-gate.sh` | Linux | pipeline_wpo.o reach |
| `prod_chain` | `run-wpo-build-asm-chain-gate.sh` | Linux | 五模块 .text save |
| `prod_strict` | `run-wpo-strict-link-gate.sh` | Linux | strict_glue WPO 链 |

Darwin：manifest 绿 + `prod_dce` SKIP（无 shux-c）+ chain/strict **N/A**；reach 无 `.o` 时 SKIP。

---

## 3. Gate

```bash
./tests/run-comp-wpo-prod-gate.sh
```

```
shux: [SHUX_COMP015_WPO_PROD] status=ok prod_ok=5 prod_skip=3 skip=1
```

- **prod_ok**：prod hook 已登记且父 COMP-004 manifest 绿
- **prod_skip**：本机 SKIP/N/A 的 prod runnable 数
- 无 native `shux`/`shux_asm` 时 manifest 仍须绿

---

## 4. 联动

- 父 manifest：`tests/baseline/comp-wpo.tsv`（`min_prod_hooks=5`）
- 波次表：`tests/baseline/comp-wpo-prod-wave.tsv`
- 父门禁：`run-comp-wpo-gate.sh`
- baseline：`wpo-typeck-o.tsv`、`wpo-pipeline-o.tsv`、`wpo-strict-glue-text.tsv`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- 默认对所有 `shux` 构建开启 asm WPO
- Darwin strict_glue 硬门禁
- 跨 TU LTO 级 IPA
