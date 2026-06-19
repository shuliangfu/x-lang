# COMP-005 寄存器分配策略评估 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 asm **7.3**、`pipeline_glue.c` `glue_asm73_*`、`run-asm-73-gate.sh` 对齐  
> 关联：`COMP-004`（WPO）、`compiler/src/asm/README.md` §7.3

---

## 1. 阅读路径（约 20 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 评估层 R1–R6 |
| 2 | 打开 `tests/baseline/comp-regalloc-quality.tsv`（**quality** 对比表） |
| 3 | `./tests/run-comp-regalloc-gate.sh` |
| 4 | `SHUX=./compiler/shux_asm ./tests/run-asm-73-gate.sh`（Linux/arm64 全量） |

---

## 2. 评估层 R1–R6（register allocation）

权威：`tests/baseline/comp-regalloc.tsv`（**6** 条 `layer_*`）。

| 层级 | 策略 | x86_64 | arm64 | 锚点 |
|------|------|--------|-------|------|
| **R1-linear-scan** | 峰值 live 驱动 spill 槽选择 | rbx 右操作数 cache | x10 起线性扩展 | `glue_asm73_linear_max_live_n` |
| **R2-chaitin-k6** | K=6 干涉着色 | 共享 glue 路径 | x10–**x15** 固定池 | `glue_asm73_compute_spill_color_chaitin` |
| **R3-stack-spill** | 物理槽用尽 → 栈帧 push | `sub rsp` 临时保存 | `sub sp,#16` | `run-asm-binop-stack-spill.sh` |
| **R4-cfg-phi** | if/while/for 汇合 live ∪ | 同算法 | ldur 计数门禁 | `run-asm-binop-cfg-merge.sh` |
| **R5-peephole** | spill 往返 mov 消除 | peephole_elf | x10↔x0/x1 对消 | `compiler/src/asm/README.md` |
| **R6-quality-report** | exit + 反汇编指标 | exit code | exit + **无** binop stack push | `comp-regalloc-quality.tsv` |

**regalloc 质量对比（v1 report）**：

| 指标 | arm64 期望 | x86_64 期望 | 验证 |
|------|------------|-------------|------|
| binop 无栈 push | `_main` 无 `sub sp,#0x10` | 同左（AArch64 形态）或 SKIP | `run-asm-binop-block-var.sh` |
| 长链 exit | 1+…+n 精确 | 同 | 各 `binop_return_*_add.sx` |
| 栈帧 spill 允许 | ≥12 VAR 可 `sub sp` | 同 | `run-asm-binop-stack-spill.sh` |
| cfg 汇合 | if/for 分支 exit 精确 | 同 | `run-asm-binop-cfg-merge.sh` |

v1 **quality report** 以 **arm64 反汇编门禁**为主（CI Linux arm64 + Darwin arm64）；x86_64 Linux 以 **exit code + 无 crash** 为副指标。

---

## 3. 质量对比表（report）

机器可读：`tests/baseline/comp-regalloc-quality.tsv`（**9** 条 `metric_*`，COMP-013 wave2）。

| metric_id | arch | 策略 | 阈值 | 脚本 |
|-----------|------|------|------|------|
| `metric_no_push` | arm64 | linear+x10-15 | 无 stack push | `run-asm-binop-block-var.sh` |
| `metric_var_fast` | arm64 | direct ldr | 无 push | `run-asm-binop-var.sh` |
| `metric_stack_ok` | arm64 | stack spill | exit 精确 | `run-asm-binop-stack-spill.sh` |
| `metric_cfg` | arm64 | cfg+phi | exit 精确 | `run-asm-binop-cfg-merge.sh` |
| `metric_chaitin` | arm64 | K=6 | x12/x15 用例 | `run-asm-binop-block-var.sh` |
| `metric_nested_var` | arm64 | nested VAR | 无 x2 | `run-asm-binop-nested-var.sh` |
| `metric_field_index` | arm64 | FIELD+INDEX | exit 205 | `run-asm-binop-field-index.sh` |
| `metric_index_lit` | arm64 | INDEX+lit | 无 push | `run-asm-binop-index-lit.sh` |
| `metric_full` | both | 全矩阵 | 10 scripts | `run-asm-73-gate.sh` |

波次 runnable：`tests/run-comp-regalloc-quality-gate.sh`（COMP-013）。

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_four_mul` | `binop_return_four_mul.sx` | exit **24**；rbx 换载 spill x10 |
| `case_seven_add` | `binop_return_seven_add.sx` | exit **28**；第三 spill x12 |
| `case_fourteen` | `binop_return_fourteen_add.sx` | exit **105**；x15/栈帧 |
| `case_cfg_if` | `binop_if_return_twelve_add.sx` | cfg-merge exit **78** |

---

## 5. 非目标（v1）

- GCC/LLVM regalloc 数值对标
- 全局图着色跨函数
- riscv64 7.3 扩展报告

---

## 6. 验证与门禁

```bash
./tests/run-comp-regalloc-gate.sh      # manifest + regalloc hooks（COMP-005）
./tests/run-comp-regalloc-quality-gate.sh  # 质量波次 runnable（COMP-013）
./tests/run-comp-regalloc.sh           # 轻量烟测（有 shux_asm 时）
./tests/run-asm-73-gate.sh             # 全量 10 脚本
```

**gate report**：stdout 须含 `comp-regalloc gate OK`；失败打印 `comp-regalloc FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-regalloc-v1.md` |
| manifest | `tests/baseline/comp-regalloc.tsv` |
| quality | `tests/baseline/comp-regalloc-quality.tsv` |

**COMP-005 状态：定版 ✅**
