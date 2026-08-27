# 阶段 G-FFI-5（业务零裸 extern + §8 unsafe 债务冻结）

> **G-FFI-5**：业务 `tests/` 无裸 `extern` 调用（须 `unsafe` 或 allowlist）；std 业务层 unsafe 债务冻结（infra 边界排除）；硬委托 `std/ffi`+`std/sys` wrap grep。
>
> **Honesty（2026-08-27）**：soft `XLANG_G_FFI5_FAIL`（business die→exit0）已退役。缺 allowlist／baseline 曾 portable 假绿。活权威 = 本 archive DOC + baseline TSV + wrap gate。`xlang check` 闸门自举期暂停 → release-ci 默认 `SKIP_LANG_UNSAFE=1`（policy only）；`XLANG_G_FFI5_RUN_LANG_UNSAFE=1` 才跑 LANG-007 全套（仍绑 check，后置）。

## v1 完成（✅ policy）

| 项 | 说明 |
|----|------|
| business gate | 零裸 extern + §8 freeze（52 baseline） |
| allowlist | `tests/baseline/g-ffi-5-business-extern-allowlist.tsv` |
| §8 baseline | `tests/baseline/g-ffi-5-std-business-unsafe-baseline.tsv` |
| wrap | `run-g-ffi-5-std-wrap-gate.sh`（hard；ffi/sys unsafe 包裹） |
| release-ci | policy hard；lang-unsafe 默认 skip（check 暂停） |

## Gate

```bash
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
# Manifest-only:
#   XLANG_G_FFI5_MANIFEST_ONLY=1 ./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
# Release CI (policy; skip lang-unsafe by default):
#   ./tests/run-g-ffi-5-release-ci-gate.sh
# Full LANG-007 (opt-in; check-gate paused → often red):
#   XLANG_G_FFI5_RUN_LANG_UNSAFE=1 ./tests/run-g-ffi-5-release-ci-gate.sh
# Report: doc=/allow=/baseline=/bare=/freeze=/wrap=/skip=
# Soft XLANG_G_FFI5_FAIL retired (die always hard).
```

PLATFORM: SHARED archaeology.

## 限制

| 项 | 说明 |
|----|------|
| lang-unsafe / check | 自举期 check 闸门暂停；CHK002／诊断债后置；非本闸根修 |
| STRICT_ZERO_UNSAFE | 终局清零仍红（52 业务 unsafe）；设 `XLANG_G_FFI5_STRICT_ZERO_UNSAFE=1` 才硬验 |
| TYPECK | wrap 默认 SKIP；`XLANG_G_FFI5_TYPECK=1` 观测 |

## 复现

```bash
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
./tests/run-g-ffi-5-std-wrap-gate.sh
XLANG_G_FFI5_SKIP_LANG_UNSAFE=1 ./tests/run-g-ffi-5-release-ci-gate.sh
```
