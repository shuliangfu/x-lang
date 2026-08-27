# 阶段 D-04 完成标准 v1（NEXT §7）

> **D-04 v1**：同一 `.x` 用例在 **Stage1**（`xlang_asm_stage1`）与 **Stage2**（`xlang_asm2`）上 **check / link+run 结果一致**——扩面 portable 子集，非全量 `run-portable-suite`。

## v1 完成（✅）

> **Honesty 2026-08-24 #12 / 2026-08-27:** top-level DOC + soft `XLANG_D04_FAIL` retired (early Darwin "OOM" soft exit0 skipped DOC/matrix = portable false-green). Live portable = Linux gold; Darwin = matrix audit + honest skip=1.

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

## Gate

```bash
# Live portable requires native Linux stage1/stage2
./tests/run-d04-stage2-portable-diff-gate.sh
# Optional:
#   XLANG_D04_MANIFEST_ONLY=1 ./tests/run-d04-stage2-portable-diff-gate.sh
# Report: doc=/matrix=/cases_ok=/cases_fail=/skip=
# Soft XLANG_D04_FAIL + early Darwin OOM soft-exit retired (die always hard).
# Darwin / missing bins: static+matrix audited + skip=1.
```

PLATFORM: SHARED archaeology · LINUX live portable · DARWIN static+skip.

## track-only / 平台

| 项 | 说明 |
|----|------|
| macOS 宿主 | static + honest skip；Docker Linux 覆盖 live |
| link_run | 非 x86_64 / 无 liburing 时两代可同时 `link:skip`，仍算一致 |
| 全量 portable | **延后 D-04 v2**（完整 `run-portable-suite` 两代 diff） |

## 延后（D-04 v2+）

- 全量 `run-portable-suite.sh` / `make test_x` 两代 diff
- stage1 vs stage2 **诊断文本** diff（v1 仅 outcome / exit code）
- Windows / ARM64 原生 stage 产物扩面

## 与 BOOT-025 关系

- **BOOT-025**：parser C3 gen12 波次登记 + stage2-bstrict 委托
- **D-04**：显式 **逐用例** stage1/stage2 portable 子集 diff（行为扩面金样）
