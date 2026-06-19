# COMP-019：WPO 默认全局开启烟测（global tier）v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-017 `comp-wpo-default-v1.md`、`comp-wpo.tsv` default tier  
> 关联：S5 full-chain stretch、`run-pipeline-wpo-optin-smoke.sh`

---

## 1. 目标

在 COMP-017 **default tier** 上扩展 **global tier**：登记 5 条 `hook_global`，持续追踪 typeck/pipeline `.o` 代理、strict_glue 实测 `.text`、stretch ≥3% 与 pipeline opt-in 烟测。

验收：`tests/run-comp-wpo-global-gate.sh` 绿；`comp-wpo.tsv` **≥5** 条 `tier=global` hook（`min_global_hooks=5`）。

---

## 2. 全局矩阵（global tier）

| item_id | hook | 平台 | 说明 |
|---------|------|------|------|
| `global_typeck_o` | `run-wpo-typeck-o-gate.sh` | Linux | typeck_wpo.o .text 代理 |
| `global_pipeline_o` | `run-wpo-pipeline-o-gate.sh` | Linux | pipeline_wpo.o .text 代理 |
| `global_strict_glue_text` | `run-wpo-strict-glue-text-gate.sh` | Linux | strict_glue ELF .text A/B |
| `global_stretch` | `run-wpo-stretch-gate.sh` | Linux | 全链 binary proxy ≥3% |
| `global_optin` | `run-pipeline-wpo-optin-smoke.sh` | Linux | W6 pipeline WPO opt-in |

Darwin：manifest 绿 + global hook **N/A/SKIP**（无 build_asm / shux_asm 产物时）。

---

## 3. Gate

```bash
./tests/run-comp-wpo-global-gate.sh
```

```
shux: [SHUX_COMP019_WPO_GLOBAL] status=ok global_ok=5 global_skip=5 skip=1
```

- **global_ok**：global hook 已登记且父 COMP-017 manifest 绿
- **global_skip**：本机 SKIP/N/A 的 global runnable 数
- 无 `shux_asm` / `.o` 产物时 manifest 仍须绿

---

## 4. 联动

- 父 manifest：`tests/baseline/comp-wpo.tsv`（`min_global_hooks=5`）
- 波次表：`tests/baseline/comp-wpo-global-wave.tsv`
- 父门禁：`run-comp-wpo-default-gate.sh`
- baseline：`wpo-typeck-o.tsv`、`wpo-pipeline-o.tsv`、`wpo-strict-glue-text.tsv`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- 默认对所有 `shux` 用户构建强制开启 asm WPO
- Darwin strict_glue 硬门禁
- 跨 TU LTO 级 IPA
