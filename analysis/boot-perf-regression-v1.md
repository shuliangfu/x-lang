# BOOT-012 自举性能回归门禁 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-004`、`ENG-001`、`run-bootstrap-bstrict-ci.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **PR 自动跑** | GHA `ci.yml` → `run-ci-full-suite.sh` → compile dogfood |
| **自举专项** | `check_parser` / `check_typeck` / `check_backend` 三模块 check 耗时 |
| **不回退** | Linux 原生 CI 硬门禁；其它平台 manifest + 软跑 |
| **与 PERF-004 分工** | 数值基线 = `compile-dogfood.tsv`；本任务 = 自举链路与 CI 接线 |

验收（NEXT BOOT-012）：**每次 PR 自动跑 dogfood 指标** + 文档 + manifest gate。

---

## 2. 指标矩阵

文件：`tests/baseline/bootstrap-perf-matrix.tsv`

| tier | 含义 |
|------|------|
| `bootstrap_compiler` | 编译器重模块 `shux check`（自举热路径） |
| `microbench` | codegen microbench `-o` |
| `ci_entry` | CI / 本地 push 入口（接线审计） |

**bootstrap_compiler 三件套**（v1 核心）：

| case_id | 源 | 说明 |
|---------|-----|------|
| `check_parser` | `compiler/src/parser/parser.sx` | parser EMIT_HEAVY |
| `check_typeck` | `compiler/src/typeck/typeck.sx` | typeck 热路径（COMP-002） |
| `check_backend` | `compiler/src/asm/backend.sx` | asm 后端 |

另 5 项 microbench 与 PERF-004 共享同一 `compile-dogfood.tsv`。

---

## 3. CI 接线（PR 自动）

```
push/PR → .github/workflows/ci.yml
       → tests/run-ci-full-suite.sh
       → run-perf-compile-dogfood-gate.sh
            ├─ Linux 原生：SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1（硬失败）
            └─ macOS/Windows/Docker：软跑（manifest + timing 烟测）
```

本地 push 前：`run-pre-push-p0.sh` → `run-perf-p1-gate.sh` → compile dogfood（硬门禁）。

夜跑：`ci-nightly.yml` 同入口。

---

## 4. 基线与治理

| 资源 | 路径 |
|------|------|
| 数值基线 | `tests/baseline/compile-dogfood.tsv` |
| 注册表 | `tests/baseline/perf-baseline-registry.tsv`（`compile-dogfood`） |
| 更新 | `SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh` |
| 评审 | ENG-001 checklist + version bump |

CI slack（PERF-004）：GHA ×1.4；Docker ×1.65。

---

## 5. 门禁

`tests/run-bootstrap-perf-gate.sh`：

1. manifest：RFC + matrix + compile-dogfood + registry  
2. `bootstrap_compiler` case 均在 dogfood TSV  
3. `ci-full-suite` / `ci.yml` / `pre-push-p0` 接线存在  
4. hook：`run-perf-compile-dogfood-gate.sh`（无 shux 时 manifest SKIP bench）

---

## 6. 变更流程

1. 新增自举 perf case → 增 dogfood 行 + matrix 行 + registry version bump  
2. 放宽 cap → ENG-001 PR 评审  
3. 本地：`./tests/run-bootstrap-perf-gate.sh`

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/bootstrap-perf-matrix.tsv` |
| 门禁 | `tests/run-bootstrap-perf-gate.sh` |
| PERF-004 | `analysis/perf-compile-dogfood-v1.md` |
| dogfood gate | `tests/run-perf-compile-dogfood-gate.sh` |

**BOOT-012 状态：定版 ✅**
