# 阶段 D-04 完成标准 v1（NEXT §7）

> **D-04 v1**：同一 `.x` 用例在 **Stage1**（`shux_asm_stage1`）与 **Stage2**（`shux_asm2`）上 **check / link+run 结果一致**——扩面 portable 子集，非全量 `run-portable-suite`。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 矩阵 | BOOT-019 parser/typeck + BOOT-015 vec/map/heap + hello | `d04-stage2-portable-matrix.tsv` |
| 两代 diff | 每行 stage1 vs stage2  outcome 相同 | `run-d04-stage2-portable-diff-gate.sh` |
| 委托 | check/link 复用 BOOT-019 辅助 | `tests/lib/d04-stage2-portable-diff.sh` |
| 登记 | `bootstrap-repro.tsv` | bstrict CI（Linux） |

## 矩阵范围（v1）

- **Tier P 入口**：`examples/hello.x`（check）
- **BOOT-019**：6 条 parser/typeck dogfood（3 check + 3 link_run）
- **BOOT-015**：vec / map / heap（check）

## 复现命令

```bash
# 须已有 stage1/stage2（verify-selfhost-stage2-bstrict 或 run-linux-a09-a11-gate）
SHUX_D04_FAIL=1 ./tests/run-d04-stage2-portable-diff-gate.sh
```

## track-only / 平台

| 项 | 说明 |
|----|------|
| macOS 宿主 | gate N/A；Docker Linux 覆盖 |
| link_run | 非 x86_64 / 无 liburing 时两代可同时 `link:skip`，仍算一致 |
| 全量 portable | **延后 D-04 v2**（完整 `run-portable-suite` 两代 diff） |

## 延后（D-04 v2+）

- 全量 `run-portable-suite.sh` / `make test_x` 两代 diff
- stage1 vs stage2 **诊断文本** diff（v1 仅 outcome / exit code）
- Windows / ARM64 原生 stage 产物扩面

## 与 BOOT-025 关系

- **BOOT-025**：parser C3 gen12 波次登记 + stage2-bstrict 委托
- **D-04**：显式 **逐用例** stage1/stage2 portable 子集 diff（行为扩面金样）
