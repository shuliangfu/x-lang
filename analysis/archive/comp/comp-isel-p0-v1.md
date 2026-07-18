# COMP-014：isel 回归矩阵 P0 扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-006 `comp-isel-v1.md`、`comp-isel.tsv`  
> 关联：asm 7.3、`run-asm-73-gate.sh`、COMP-013 regalloc wave

---

## 1. 目标

在 COMP-006 manifest 基础上扩展 **P0 isel 回归矩阵**：新增 4 条 golden case + 3 bench + 4 hook，runnable gate 逐条执行。

验收：`tests/run-comp-isel-p0-gate.sh` 绿；`comp-isel.tsv` **≥4** 条 `tier=P0` case（`min_p0_cases=4`）。

---

## 2. P0 回归矩阵

| case_id | 文件 | exit | hook | isel 层 |
|---------|------|------|------|---------|
| `case_field_p0` | `binop_field_index_fast.x` | **205** | `run-asm-binop-field-index.sh` | I7 FIELD+INDEX |
| `case_nested_p0` | `binop_nested_var_return.x` | **20** | `run-asm-binop-nested-var.sh` | I8 nested VAR |
| `case_div_index_p0` | `binop_div_index_binop.x` | **2** | `run-asm-binop-div-index.sh` | I5 div/index |
| `case_cfg_p0` | `binop_if_plus_eq_merge.x` | **13** | `run-asm-binop-cfg-merge.sh` | I3 cmp+phi |

bench 扩展见 `comp-isel-bench.tsv`（`bench_field_p0`、`bench_nested_p0`、`bench_div_index_p0`）。

---

## 3. Gate

```bash
./tests/run-comp-isel-p0-gate.sh
```

```
shux: [SHUX_COMP014_ISEL_P0] status=ok p0_ok=4 p0_skip=0 skip=0
```

无 native `shux_asm`/`shux` 时 manifest 仍须绿；runnable SKIP。

---

## 4. 联动

- manifest：`tests/baseline/comp-isel-p0-wave.tsv`
- 父表：`comp-isel.tsv`（`min_cases=8`）、`comp-isel-bench.tsv`（`min_benches=9`）
- 父门禁：`run-comp-isel-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- SIMD isel P0
- riscv64 isel 矩阵
- 全量 cfg-merge 40+ 用例纳入 P0 gate（仅抽样 `binop_if_plus_eq_merge`）
