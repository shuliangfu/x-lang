# COMP-013：regalloc 质量波次 gate 扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-005 `comp-regalloc-v1.md`、`comp-regalloc-quality.tsv`  
> 关联：asm 7.3、`run-asm-73-gate.sh`、Phase 3 COMP-013

---

## 1. 目标

在 COMP-005 manifest 基础上，新增 **质量波次 runnable gate**：按 `comp-regalloc-quality.tsv` 逐条执行指标脚本，结构化报告 `metrics_ok` / `metrics_skip`。

验收：`tests/run-comp-regalloc-quality-gate.sh` 绿；`comp-regalloc-quality.tsv` **≥9** 条 `metric_*` 达标。

---

## 2. 质量指标（9 条）

| metric_id | 脚本 | 期望 |
|-----------|------|------|
| `metric_no_push` | `run-asm-binop-block-var.sh` | 块内 binop 无 stack push |
| `metric_var_fast` | `run-asm-binop-var.sh` | VAR 直 ldr |
| `metric_stack_ok` | `run-asm-binop-stack-spill.sh` | 长链栈帧 spill exit 精确 |
| `metric_cfg` | `run-asm-binop-cfg-merge.sh` | if/for cfg+phi |
| `metric_chaitin` | `run-asm-binop-block-var.sh` | K=6 x12/x15 spill |
| `metric_nested_var` | `run-asm-binop-nested-var.sh` | 嵌套 VAR 无 x2 暂存 |
| `metric_field_index` | `run-asm-binop-field-index.sh` | FIELD/INDEX 无 stack push |
| `metric_index_lit` | `run-asm-binop-index-lit.sh` | INDEX+字面量直 load |
| `metric_full` | `run-asm-73-gate.sh` | 全矩阵 10 scripts |

Wave2 新增：`metric_nested_var`、`metric_field_index`、`metric_index_lit`。

---

## 3. Gate

```bash
./tests/run-comp-regalloc-quality-gate.sh
```

```
shux: [SHUX_COMP013_REGALLOC_QUALITY] status=ok metrics_ok=9 metrics_skip=0 skip=0
```

无 native `shux_asm` 时：**manifest 仍须绿**；runnable **SKIP**（与 COMP-005 一致）。

---

## 4. 联动

- manifest：`tests/baseline/comp-regalloc-quality.tsv`（`min_metrics=9`）
- 父门禁：`tests/run-comp-regalloc-gate.sh`（层/用例 manifest）
- 全矩阵：`tests/run-asm-73-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- x86_64 反汇编质量硬门禁
- LLVM/GCC regalloc 数值对标
- riscv64 7.3 扩展
