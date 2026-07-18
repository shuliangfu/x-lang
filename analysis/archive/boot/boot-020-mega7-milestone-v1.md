# BOOT-020：mega7 parser 替换里程碑验收 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：COMP-001 阶段 A（thin glue 符号完整性）、BOOT-018 解耦、BOOT-019 Stage2 dogfood  
> 关联：`parser-thin-glue-symbols.tsv`、`comp-parser-mega7-matrix.tsv`

---

## 1. 里程碑目标

**替换基础设施就绪**（非 B1–B7 全量 X emit）：thin glue / stretch 符号链完整，mega7 七函数与 15+ 能力切片落地，second-pass 烟测不回归。

| 维度 | v1 验收 |
|------|---------|
| **thin glue 符号** | `run-parser-thin-glue-symbol-integrity-gate.sh` 全绿（Linux nm）；Darwin 源文件锚点回退 |
| **mega7 矩阵** | `run-comp-parser-mega7-gate.sh` manifest 绿（7 函数 + ≥15 slice done） |
| **second-pass** | `run-parser-second-pass-gate.sh` 不回归（Linux 实跑；Darwin SKIP） |

B1–B7 仍为 **stub**（阶段 B 待后续迭代）；本里程碑不阻塞 STD P0（见 BOOT-018）。

---

## 2. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §1–§4 |
| 2 | `tests/baseline/boot-020-mega7-milestone.tsv` |
| 3 | `./tests/run-boot-020-mega7-milestone-gate.sh` |

---

## 3. 门禁矩阵

| 门禁 | 锚点 | 平台 |
|------|------|------|
| thin glue 符号 | `run-parser-thin-glue-symbol-integrity-gate.sh` | Linux 硬门禁；Darwin 源锚点 |
| mega7 manifest | `run-comp-parser-mega7-gate.sh` | 全平台 manifest；Linux 附加 hook |
| second-pass | `run-parser-second-pass-gate.sh` | Linux；Darwin SKIP |

基线符号：`tests/baseline/parser-thin-glue-symbols.tsv`（≥80 `parser_asm_stretch_*` + ≥60 `_glue` 计数下限）。

---

## 4. Gate 与 report

```bash
./tests/run-boot-020-mega7-milestone-gate.sh
```

```
shux: [SHUX_BOOT020] status=ok symbol=1 mega7=1 skip=0
```

Darwin 典型：

```
shux: [SHUX_BOOT020] status=ok symbol=source mega7=1 skip=1
```

---

## 5. 非目标（v2）

- B1–B7 mega 深循环 X 真 emit（delta≥8KiB promote）
- 139 func 无 ret0 全量 bootstrap（阶段 C3）
- Darwin nm 硬门禁（待 CI linux-amd64 常驻）
