# COMP-016：riscv64 后端矩阵扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-012 `comp-riscv64-v1.md`、`comp-riscv64-matrix.tsv`  
> 关联：`riscv64.sx`、`run-asm.sh`、COMP-014 isel P0

---

## 1. 目标

在 COMP-012 六 case 矩阵上扩展 **wave 回归 3 项**：binop / cfg / index，runnable gate 逐条 `asm_text` 烟测。

验收：`tests/run-comp-riscv64-wave-gate.sh` 绿；`comp-riscv64-matrix.tsv` **≥9** case（`min_cases=9`）。

---

## 2. Wave 回归矩阵

| case_id | 样例 | 检查 | isel 层 |
|---------|------|------|---------|
| `case_wave_binop` | `binop_return_four_add.sx` | asm_text | 加链 |
| `case_wave_cfg` | `binop_if_plus_eq_merge.sx` | asm_text | cmp+phi |
| `case_wave_index` | `binop_field_index_fast.sx` | asm_text | FIELD+INDEX |

父矩阵保留 `case_riscv_min` / `case_main` / `case_expr` / `case_local` / `case_elf_main` / `case_run_asm`。

---

## 3. Gate

```bash
./tests/run-comp-riscv64-wave-gate.sh
```

```
shux: [SHUX_COMP016_RISCV_WAVE] status=ok wave_ok=3 wave_skip=0 skip=1
```

无 native `shux` 时 manifest 仍须绿；runnable **SKIP**。

---

## 4. 联动

- manifest：`tests/baseline/comp-riscv64-wave.tsv`
- 父表：`comp-riscv64.tsv`、`comp-riscv64-matrix.tsv`
- 父门禁：`run-comp-riscv64-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- RVV 向量回归
- QEMU user 仿真自动化
- riscv32 bare-metal
