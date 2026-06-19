# BOOT-025：parser C3 gen1/gen2 三代一致性 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-024 bootstrap emit、`verify-selfhost-stage2-bstrict.sh`  
> 关联：`boot-mega7-gap.md` 阶段 C3、BOOT-019

---

## 1. 目标

在 BOOT-024 C2 bootstrap 基础上登记 **gen1/gen2 三代一致性** 门禁：`shux_asm`（gen1）→ `shux_asm2`（gen2）行为对齐。

验收：`tests/run-boot-025-parser-gen12-consistency-gate.sh` 绿；`min_consistency_hooks=3`；Linux `gen12_ok=1`。

---

## 2. 一致性矩阵

| ID | hook | 说明 |
|----|------|------|
| `consist_stage2` | `run-stage2-bstrict-gate.sh` | gen1/gen2 42 + hello + struct_mk |
| `consist_dogfood` | `run-bootstrap-stage2-dogfood-parser-typeck.sh` | parser/typeck 子集 check |
| `consist_boot024` | `run-boot-024-parser-bootstrap-emit-gate.sh` | C2 bootstrap 父波次 |

复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot025_stage2_gen12`。

---

## 3. Gate

```bash
./tests/run-boot-025-parser-gen12-consistency-gate.sh
```

```
shux: [SHUX_BOOT025] status=ok gen12_ok=1 dogfood_ok=0 skip=1
```

- **gen12_ok**：`stage2-bstrict` 通过（Linux + `shux_asm`）
- Darwin / 无 `shux_asm`：manifest 绿 + **SKIP**

---

## 4. 联动

- manifest：`tests/baseline/boot-025-parser-gen12-consistency.tsv`
- 波次表：`tests/baseline/parser-gen12-consistency-wave.tsv`
- 父波次：`run-boot-024-parser-bootstrap-emit-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（C4 `gen12_target`）

---

## 5. 非目标（v2）

- C4 全量 SU bootstrap 无 C TU（见 BOOT-026）
- Darwin stage2 硬门禁
- 跨平台 shux_asm2 二进制发布
