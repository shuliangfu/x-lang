# COMP-004 WPO v1 设计定版

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `codegen_wpo_reach_compute`、`tests/run-wpo-dce-emit.sh` 对齐  
> 关联：`COMP-002`（typeck 热路径）、`BOOT-006`（parser gate）、`PERF-004`（dogfood）

---

## 1. 阅读路径（约 20 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 阶段 W1–W6 |
| 2 | 打开 `tests/baseline/comp-wpo.tsv` |
| 3 | `./tests/run-comp-wpo-gate.sh` |
| 4 | `./tests/run-wpo-dce-emit.sh`（小规模 DCE 原型） |

---

## 2. 阶段 W1–W6（whole program optimization）

权威：`tests/baseline/comp-wpo.tsv`（**6** 条 `stage_*`）。

| 阶段 | 能力 | 实现锚点 | 烟测 |
|------|------|----------|------|
| **W1-reach-dce** | 全程序 call graph 可达 + dead export DCE | `codegen_wpo_reach_compute` | `run-wpo-dce-emit.sh` |
| **W2-callgraph-s1** | JSON call graph 导出 | `SHUX_WPO_DUMP_CALLGRAPH` | `run-wpo-s1.sh` |
| **W3-const-spec-s2** | 常量实参 call site + const fold | `wpo_const_spec.pl` | `run-wpo-s2.sh` |
| **W4-stack-promote-s3** | struct 栈提升 / await asm | `typeck_wpo_post_scan` | `run-wpo-s3-gate.sh` |
| **W5-pgo-s4** | `.text.hot` / unlikely 分区 | `SHUX_WPO_PGO_HOT` | `run-wpo-s4-gate.sh` |
| **W6-optin-prototype** | `pipeline_wpo` strict_glue 可编可跑 | `pipeline_wpo.o` | `run-pipeline-wpo-optin-smoke.sh` |

**whole program 模型（v1）**：

1. typeck 后构建 **跨模块** reach（入口 `main` + import 依赖闭包）。
2. codegen DCE 用 `CodegenWpoReach` 剔除 unreachable export（含库模块 dead fn）。
3. **prototype 启用**：Linux x86_64 上 `shux_asm` + `ensure-wpo-build-asm-artifacts`；Darwin 烟测 SKIP。

```bash
# 小规模 DCE（shux-c，任意主机可编时）
./compiler/shux-c -E tests/wpo/dead_fn.x   # 无 dead_helper 体

# call graph 导出
SHUX_WPO_DUMP_CALLGRAPH=/tmp/cg.json ./compiler/shux-c check tests/wpo/dead_fn.x
```

---

## 3. 原型目录

`tests/baseline/comp-wpo-prototype.tsv` 登记已闭合能力。

| capability | 脚本 | 状态 |
|------------|------|------|
| `dce_dead_export` | `run-wpo-dce-emit.sh` | done |
| `callgraph_json` | `run-wpo-s1.sh` | done |
| `const_spec_fold` | `run-wpo-s2.sh` | done |
| `stack_promote` | `run-wpo-s3-gate.sh` | asm/Linux |
| `pgo_hot` | `run-wpo-s4-gate.sh` | asm/Linux |
| `pipeline_optin` | `run-pipeline-wpo-optin-smoke.sh` | prototype |

全链 Linux CI：`run-wpo-full-chain-gate.sh`。

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_dead_fn` | `tests/wpo/dead_fn.x` | `-E` 无 `dead_helper` |
| `case_dead_user` | `tests/wpo/dead_user.x` | import 库 dead export 剔除 |
| `case_if_reach` | `tests/wpo/if_block_reach.x` | 分支内 call 计入 reach |
| `case_const_spec` | `tests/wpo/const_spec.x` | graph v2 + const site |

---

## 5. 非目标（v1）

- 跨 TU LTO 级 IPA（仅 Shux 模块图）
- 默认对所有 `shux` 构建开启 asm WPO（仍 opt-in `shux_asm`）
- Windows / riscv WPO 全链

---

## 6. 验证与门禁

```bash
./tests/run-comp-wpo-gate.sh           # runnable：manifest + WPO hooks
./tests/run-comp-wpo.sh                # DCE + S1 轻量烟测
./tests/run-wpo-full-chain-gate.sh     # Linux：全链
```

**gate report**：stdout 须含 `comp-wpo gate OK`；失败打印 `comp-wpo FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-wpo-v1.md` |
| manifest | `tests/baseline/comp-wpo.tsv` |
| prototype | `tests/baseline/comp-wpo-prototype.tsv` |

**COMP-004 状态：定版 ✅**
