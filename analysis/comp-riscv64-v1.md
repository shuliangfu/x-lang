# COMP-012 riscv64 回归 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 汇编文本 + ELF .o 烟测；Linux 上可选 link+run  
> 关联：`compiler/src/asm/arch/riscv64.sx`、`tests/run-asm.sh`、`COMP-006`（isel）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 回归层 R1–R6 |
| 2 | 打开 `tests/baseline/comp-riscv64-matrix.tsv` |
| 3 | `./tests/run-comp-riscv64-gate.sh` |
| 4 | `./tests/run-comp-riscv64.sh` |

---

## 2. 回归层 R1–R6（riscv64 regression）

权威：`tests/baseline/comp-riscv64.tsv`（**6** 条 `layer_*`）。

| 层级 | 能力 | 实现 | 验证 |
|------|------|------|------|
| **R1-asm-text** | `.s` 文本发射 | `arch/riscv64.sx` | `.text` + `main` + `ret` |
| **R2-elf-o** | ELF 可重定位 `.o` | `platform/elf.sx` + `target_arch=2` | `file` ELF relocatable |
| **R3-enc-dispatch** | 机器码 enc 分派 | `riscv64_enc.sx` / `backend.sx` | `ta == 2` |
| **R4-min-sample** | 最小样例 | `tests/asm/riscv64_min.sx` | exit **42**（link 可用时） |
| **R5-matrix** | 多用例矩阵 | `main`/`expr`/`local` 等 | 与 `run-asm.sh` 一致 |
| **R6-link-run** | 链接运行 | `riscv64-linux-gnu-ld` 等 | Linux optional |

**regression 原则**：

1. **稳定 SKIP**：非 Linux / 无 native shux / 无 riscv ld 时 SKIP，不 fail manifest。
2. **Linux 硬检**：`HOST=Linux` 时 `.o` 必须为 ELF relocatable（与 `run-asm.sh` 对齐）。
3. **矩阵固定**：`comp-riscv64-matrix.tsv` 登记样例；新增 riscv 路径须增 case。
4. **报告**：stderr 打印 `comp-riscv64: case=… status=OK|SKIP`。

---

## 3. 回归矩阵（stable report）

`tests/baseline/comp-riscv64-matrix.tsv`（**11** 条 `case_*`；COMP-016 wave ×3 + COMP-018 qemu ×2）。

| case_id | 样例 | 检查 | 期望 |
|---------|------|------|------|
| `case_riscv_min` | `riscv64_min.sx` | asm_text + elf_o | COMP-012 锚点 |
| `case_main` | `main.sx` | asm_text | `.text/main/ret` |
| `case_expr` | `expr.sx` | asm_text | 同上 |
| `case_local` | `local.sx` | asm_text | 同上 |
| `case_elf_main` | `main.sx` | elf_o | ELF relocatable |
| `case_run_asm` | `run-asm.sh` | hook | riscv64 段 |
| `case_wave_binop` | `binop_return_four_add.sx` | asm_text | COMP-016 加链 |
| `case_wave_cfg` | `binop_if_plus_eq_merge.sx` | asm_text | COMP-016 cfg |
| `case_wave_index` | `binop_field_index_fast.sx` | asm_text | COMP-016 index |
| `case_qemu_min` | `riscv64_min.sx` | qemu_run | exit **42**（COMP-018） |
| `case_qemu_binop` | `binop_return_four_add.sx` | qemu_run | exit **10**（COMP-018） |

Wave 深化 RFC：`analysis/comp-riscv64-wave-v1.md`（COMP-016）。  
QEMU user 仿真：`analysis/comp-riscv64-qemu-v1.md`（COMP-018；`run-comp-riscv64-qemu-gate.sh`）。

---

## 4. Golden 锚点

| 锚点 | 路径 |
|------|------|
| 汇编文本 | `compiler/src/asm/arch/riscv64.sx` |
| ELF enc | `compiler/src/asm/arch/riscv64_enc.sx` |
| 分派 | `compiler/src/asm/backend.sx`（`ta == 2`） |
| 最小样例 | `tests/asm/riscv64_min.sx` |
| 既有回归 | `tests/run-asm.sh`（riscv64 段） |

---

## 5. 非目标（v1）

- RVV / 向量扩展回归
- riscv32 / embedded bare-metal
- QEMU user 仿真自动化由 COMP-018 独立 gate 承担（矩阵登记 `case_qemu_*`；CI 可选）

---

## 6. 验证与门禁

```bash
./tests/run-comp-riscv64-gate.sh   # runnable：manifest + regression smoke
./tests/run-comp-riscv64.sh        # 矩阵烟测
./tests/run-asm.sh                 # 全量 asm（含 riscv64，SHUX_CI_FORCE_ASM=1）
```

**gate report**：stdout 须含 `comp-riscv64 gate OK`；失败打印 `comp-riscv64 FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-riscv64-v1.md` |
| manifest | `tests/baseline/comp-riscv64.tsv` |
| matrix | `tests/baseline/comp-riscv64-matrix.tsv` |

**COMP-012 状态：定版 ✅**
