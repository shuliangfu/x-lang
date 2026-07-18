# COMP-006 指令选择优化 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）** — 与 asm 7.3、`peephole.x`、`run-asm-binop-var.sh` 对齐  
> 关联：`COMP-005`（regalloc）、`COMP-014`（P0 wave）、`PERF-001`（bcmp microbench）、`compiler/src/asm/README.md`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 选择层 I1–I6 |
| 2 | 打开 `tests/baseline/comp-isel-bench.tsv` |
| 3 | `./tests/run-comp-isel-gate.sh` |
| 4 | `./tests/run-asm-binop-var.sh` |

---

## 2. 选择层 I1–I6（instruction selection）

权威：`tests/baseline/comp-isel.tsv`（**6** 条 `layer_*`）。

| 层级 | 模式 | 选择策略 | 验证 |
|------|------|----------|------|
| **I1-imm-binop** | `VAR op VAR` | 直 ldr 栈槽，免 push/pop 左操作数 | `binop_var_fast.x` exit **143** |
| **I2-index-lit** | `arr[k] op expr`（k 字面量） | `add_imm` 下标，免 x2 暂存 | `binop_index_lit_fast.x` exit **75** |
| **I3-cmp-branch** | `if (a < b)` | 字面量/VAR 比较 + 分支 | `binop_var_fast.x` 含 `<` |
| **I4-peephole** | 冗余 mov/push-pop | `peephole_elf` 字节级删除 | `peephole.x` |
| **I5-shift-div** | `<<` `>>` `/` `%` | 专用 emit 路径（非通用 call） | `binop_var_fast.x` |
| **I6-microbench** | 循环/调用链热路径 | 与 C -O3 对标 ≤1.0× | `run-bcmp-gate.sh` |

**selection 原则**：

1. **立即数优先**：二元运算一侧为字面量时走 imm 快路径（`pipeline_glue.c` binop 左/右字面量分支）。
2. **少暂存**：禁止为 binop 左操作数额外 `sub sp`（arm64 反汇编门禁）。
3. **窥孔收尾**：ELF 路径 `peephole_elf_run` 消除 spill 往返 mov。

---

## 3. microbench 矩阵

`tests/baseline/comp-isel-bench.tsv`（**9** 条；COMP-014 新增 3 条 P0 bench）。

| bench_id | 用例 | 策略 | gate |
|----------|------|------|------|
| `bench_var_fast` | `binop_var_fast.x` | I1+I3+I5 | `run-asm-binop-var.sh` |
| `bench_index_lit` | `binop_index_lit_fast.x` | I2 | `run-asm-binop-index-lit.sh` |
| `bench_loop` | `loop_i32.x` | I6 | bcmp |
| `bench_call` | `call_boundary.x` | I6 | bcmp |
| `bench_struct` | `struct_param.x` | I6 | bcmp |
| `bench_peephole` | block-var 无往返 mov | I4 | `run-asm-binop-block-var.sh` |
| `bench_field_p0` | `binop_field_index_fast.x` | I7 | `run-asm-binop-field-index.sh` |
| `bench_nested_p0` | `binop_nested_var_return.x` | I8 | `run-asm-binop-nested-var.sh` |
| `bench_div_index_p0` | `binop_div_index_binop.x` | I5 | `run-asm-binop-div-index.sh` |

P0 波次详情见 `analysis/comp-isel-p0-v1.md`（COMP-014）。

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_var_fast` | `binop_var_fast.x` | exit **143**；无 stack push |
| `case_index_lit` | `binop_index_lit_fast.x` | exit **75**；无 `mov x2` |
| `case_four_add` | `binop_return_four_add.x` | exit **10**（链式 add isel） |
| `case_loop` | `loop_i32.x` | bcmp 对标 C |

**COMP-014 P0 扩展**（`tier=P0`，详见 `comp-isel-p0-v1.md`）：

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_field_p0` | `binop_field_index_fast.x` | exit **205** |
| `case_nested_p0` | `binop_nested_var_return.x` | exit **20** |
| `case_div_index_p0` | `binop_div_index_binop.x` | exit **2** |
| `case_cfg_p0` | `binop_if_plus_eq_merge.x` | exit **13** |

---

## 5. 非目标（v1）

- SIMD 自动向量化 isel
- 跨基本块 CSE
- LLVM 级指令调度

---

## 6. 验证与门禁

```bash
./tests/run-comp-isel-gate.sh        # runnable：manifest + isel hooks
./tests/run-comp-isel-p0-gate.sh     # COMP-014：P0 wave hooks
./tests/run-comp-isel.sh             # asm binop 烟测
./tests/run-bcmp-gate.sh             # microbench（Linux CI）
```

**gate report**：stdout 须含 `comp-isel gate OK`；失败打印 `comp-isel FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-isel-v1.md` |
| manifest | `tests/baseline/comp-isel.tsv` |
| bench | `tests/baseline/comp-isel-bench.tsv` |

**COMP-006 状态：定版 ✅**
