# ENG-002 从体积门禁迁移到质量门禁 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`BOOT-007/008`、`ENG-001`、`COMP-003`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **正确性优先** | CI 硬门禁以功能/符号/链路质量为准，体积膨胀不单独 block PR |
| **体积降级** | B-SIZE / combined-audit ratchet → **advisory（S）** 或 **track-only（T）** |
| **可审计** | 固定矩阵：每个质量门禁对应替代的旧体积 ratchet |
| **防回退** | 删除关键 glue/symbol 仍 CI fail（符号完整性、strict smoke 等） |

验收（NEXT ENG-002）：**功能正确性优先于体积膨胀** + 文档 + 门禁矩阵 + manifest gate。

---

## 2. 门禁 tier

| tier | 含义 | CI 行为 |
|------|------|---------|
| **Q** | Quality 质量硬门禁 | `ci_hard=yes` → Linux CI 必须绿 |
| **Qp** | Quality portable | `ci_hard=portable` → `run-portable-suite.sh` |
| **S** | Size advisory | 超 cap 仅 WARN；默认 `SHUX_SIZE_FAIL=0` |
| **T** | Track-only | 指标追踪，不参与 pass/fail |

---

## 3. 迁移对照（v1）

| 旧策略（体积 ratchet） | 新策略（质量） |
|------------------------|----------------|
| parser combined/audit 字节 ratchet | `parser-thin-glue-symbol-integrity` + second-pass `__text` 下限 |
| B-SIZE shux_asm 8MiB 硬 fail | advisory 追踪（`run-size-shux-asm-gate.sh`，`SHUX_SIZE_FAIL=0`） |
| stretch tier 体积推进 | **停止**（BOOT-007） |
| WPO .text 代理 | `wpo-strict-link` + reach gate（链路完整性） |

---

## 4. 矩阵

文件：`tests/baseline/eng-quality-gate-matrix.tsv`

列：`gate_id` · `tier` · `ci_hard` · `gate_script` · `replaces` · `notes`

---

## 5. 门禁

`tests/run-eng-quality-gate-gate.sh`：

1. manifest：RFC + matrix  
2. 每行 `gate_script` 存在且可执行（`T` 行除外）  
3. `tier=Q` 且 `ci_hard=yes` 计数 ≥ `min_quality_ci`  
4. `run-ci-full-suite.sh` **不得**含 `SHUX_SIZE_FAIL=1`  
5. `run-bootstrap-bstrict-ci.sh` 须调用 symbol-integrity gate  
6. `run-size-shux-asm-gate.sh` 默认 advisory（无 CI 自动 hard fail）

---

## 6. 变更流程

1. 新增 CI 硬门禁 → 增 matrix 行 `tier=Q`，说明 `replaces`（若有）  
2. 体积类指标 → 仅 `S`/`T`，禁止静默升为 hard fail  
3. 本地：`./tests/run-eng-quality-gate-gate.sh`

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/eng-quality-gate-matrix.tsv` |
| 门禁 | `tests/run-eng-quality-gate-gate.sh` |
| 符号完整性 | `tests/run-parser-thin-glue-symbol-integrity-gate.sh` |
| B-SIZE advisory | `tests/run-size-shux-asm-gate.sh` |

**ENG-002 状态：定版 ✅**
