# BOOT-026：parser C4 全量 X bootstrap v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-025 gen12 一致性、`run-parser-parse-bootstrap-x-emit-gate.sh`  
> 关联：`boot-mega7-gap.md` 阶段 C4、BOOT-024 X emit 探测

---

## 1. 目标

在 BOOT-025 C3 gen1/gen2 基础上登记 **C4 X bootstrap 波次**：无 C TU 切片的 `parser.x` 全量 emit 探测 + MINIMAL 白名单轨道 + 父波次 gen12。

验收：`tests/run-boot-026-parser-c4-bootstrap-gate.sh` 绿；`min_c4_hooks=4`；Linux `c4_minimal_ok=1`。

---

## 2. C4 Bootstrap 矩阵

| ID | hook | 说明 |
|----|------|------|
| `c4_x_emit` | `run-parser-parse-bootstrap-x-emit-gate.sh` | X 全量 emit 探测（无 C TU） |
| `c4_bisect` | `run-parser-parse-bootstrap-bisect-gate.sh` | MINIMAL+FULL bisect |
| `c4_boot025` | `run-boot-025-parser-gen12-consistency-gate.sh` | C3 gen12 父波次 |
| `c4_link` | `run-parser-parse-bootstrap-link-smoke.sh` | experimental 链 smoke |

复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot026_x_c4`。

---

## 3. Gate

```bash
./tests/run-boot-026-parser-c4-bootstrap-gate.sh
```

```
shux: [SHUX_BOOT026] status=ok c4_minimal_ok=1 c4_x_probe=1 skip=1
```

- **c4_minimal_ok**：X MINIMAL 白名单轨道通过（`MINIMAL OK`）
- **c4_x_probe**：X emit 探测 gate 已执行且 PASS
- Darwin / 无 `compiler/shux`：manifest 绿 + wave **SKIP**

---

## 4. 联动

- manifest：`tests/baseline/boot-026-parser-c4-bootstrap.tsv`
- 波次表：`tests/baseline/parser-c4-bootstrap-wave.tsv`
- 父波次：`run-boot-025-parser-gen12-consistency-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（C5 `su_bootstrap_target`）
- CI：`tests/run-portable-suite.sh`

---

## 5. 非目标（v2）

- FULL X emit `ec=0` 硬门禁（仍依赖 C TU 默认路径）
- Darwin X bootstrap 硬门禁
- 跨平台 shux_asm2 二进制发布
