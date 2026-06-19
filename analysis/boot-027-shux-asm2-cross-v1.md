# BOOT-027：parser C5 shux_asm2 跨平台发布烟测 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-026 C4 SU bootstrap、`run-stage2-bstrict-gate.sh`  
> 关联：`boot-crossplatform-v1.md`、Stage2 `shux_asm2` 二进制

---

## 1. 目标

在 BOOT-026 C4 基础上登记 **C5 shux_asm2 跨平台发布波次**：native `shux_asm2` 存在性 + return-value 烟测 + 父波次 C4 + 跨平台矩阵承前。

验收：`tests/run-boot-027-shux-asm2-cross-gate.sh` 绿；`min_c5_hooks=4`；Linux `c5_ok=1`。

---

## 2. C5 跨平台矩阵

| ID | hook | 说明 |
|----|------|------|
| `c5_smoke` | `run-shux-asm2-cross-smoke.sh` | `shux_asm2` 编译 return 42 |
| `c5_stage2` | `run-stage2-bstrict-gate.sh` | Stage2 产出 gen2 |
| `c5_cross` | `run-bootstrap-crossplatform-gate.sh` | BOOT-011 矩阵 manifest |
| `c5_boot026` | `run-boot-026-parser-c4-bootstrap-gate.sh` | C4 父波次 |

复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot027_shux_asm2_cross`。

---

## 3. Gate

```bash
./tests/run-boot-027-shux-asm2-cross-gate.sh
```

```
shux: [SHUX_BOOT027] status=ok c5_ok=1 c5_smoke=1 skip=0
```

- **c5_ok**：`shux_asm2` return-value 烟测通过（exit=42）
- **c5_smoke**：烟测脚本已执行且 PASS
- Darwin / 无 native `shux_asm2`：manifest 绿 + wave **SKIP**

---

## 4. 联动

- manifest：`tests/baseline/boot-027-shux-asm2-cross.tsv`
- 波次表：`tests/baseline/shux-asm2-cross-wave.tsv`
- 父波次：`run-boot-026-parser-c4-bootstrap-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（C6 `shux_asm2_cross_target`）
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- Windows native shux_asm2 烟测（见 BOOT-028 CI 矩阵）
- GHA 自动构建 `shux_asm2` 制品缓存
- FULL Stage2 每次 gate 重跑 bootstrap
