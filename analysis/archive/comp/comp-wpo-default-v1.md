# COMP-017：WPO 持续扩面（default tier）v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-015 `comp-wpo-prod-v1.md`、`comp-wpo.tsv` prod tier  
> 关联：S5 full-chain、`run-wpo-backend-o-gate.sh`

---

## 1. 目标

在 COMP-015 **prod tier** 上扩展 **default tier**：登记 5 条 `hook_default`，持续追踪 backend reach / 模块 `.o` 代理 / 全链 gate。

验收：`tests/run-comp-wpo-default-gate.sh` 绿；`comp-wpo.tsv` **≥5** 条 `tier=default` hook（`min_default_hooks=5`）。

---

## 2. 默认矩阵（default tier）

| item_id | hook | 平台 | 说明 |
|---------|------|------|------|
| `default_backend_reach` | `run-wpo-backend-reach-gate.sh` | Linux | backend_wpo.o reach |
| `default_backend_o` | `run-wpo-backend-o-gate.sh` | Linux | backend .text 代理 |
| `default_main_o` | `run-wpo-main-o-gate.sh` | Linux | main .text 代理 |
| `default_driver_o` | `run-wpo-driver-o-gate.sh` | Linux | driver .text 代理 |
| `default_full_chain` | `run-wpo-full-chain-gate.sh` | Linux | 五模块 + strict 全链 |

Darwin：manifest 绿 + default hook **N/A/SKIP**（无 build_asm 产物时）。

---

## 3. Gate

```bash
./tests/run-comp-wpo-default-gate.sh
```

```
shux: [SHUX_COMP017_WPO_DEFAULT] status=ok default_ok=5 default_skip=5 skip=1
```

- **default_ok**：default hook 已登记且父 COMP-015 manifest 绿
- **default_skip**：本机 SKIP/N/A 的 default runnable 数
- 无 `shux_asm` / `.o` 产物时 manifest 仍须绿

---

## 4. 联动

- 父 manifest：`tests/baseline/comp-wpo.tsv`（`min_default_hooks=5`）
- 波次表：`tests/baseline/comp-wpo-default-wave.tsv`
- 父门禁：`run-comp-wpo-prod-gate.sh`
- baseline：`wpo-backend-o.tsv`（若存在）、`run-wpo-full-chain-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- 默认对所有 `shux` 用户构建强制开启 asm WPO
- Darwin strict_glue 硬门禁
- 跨 TU LTO 级 IPA
