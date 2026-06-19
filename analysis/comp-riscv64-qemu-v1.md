# COMP-018：riscv64 QEMU 用户态烟测 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-016 `comp-riscv64-wave-v1.md`、`comp-riscv64-matrix.tsv`  
> 关联：`riscv64_min.sx`、`qemu-riscv64`、COMP-012

---

## 1. 目标

在 COMP-016 wave 矩阵上扩展 **QEMU 用户态烟测 2 项**：最小样例 exit 42、binop 加链 exit 10。

验收：`tests/run-comp-riscv64-qemu-gate.sh` 绿；`comp-riscv64-qemu.tsv` + 矩阵 **≥2** 条 `policy=qemu`（`min_qemu_cases=2`）。

---

## 2. QEMU 回归矩阵

| case_id | 样例 | 期望 exit | 说明 |
|---------|------|-----------|------|
| `case_qemu_min` | `riscv64_min.sx` | 42 | COMP-012 最小样例 |
| `case_qemu_binop` | `binop_return_four_add.sx` | 10 | 加链 1+2+3+4 |

流程：`shux -target riscv64` → link → `qemu-riscv64` 用户态执行。

---

## 3. Gate

```bash
./tests/run-comp-riscv64-qemu-gate.sh
```

```
shux: [SHUX_COMP018_RISCV_QEMU] status=ok qemu_ok=2 qemu_skip=0 skip=1
```

无 `qemu-riscv64` / 交叉链接器时 manifest 仍须绿；runnable **SKIP**。

---

## 4. 联动

- manifest：`tests/baseline/comp-riscv64-qemu.tsv`
- 父矩阵：`comp-riscv64-matrix.tsv`（`min_cases=11`）
- 父门禁：`run-comp-riscv64-wave-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- RVV 向量 QEMU 回归
- qemu-system 全系统仿真
- riscv32 bare-metal
