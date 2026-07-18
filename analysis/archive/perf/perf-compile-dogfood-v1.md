# 编译器 dogfood 不回退 v1（PERF-004）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-001`（基线治理）、`BOOT-012`（自举 perf）、`tests/run-perf-compile-dogfood.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **固定用例** | microbench `-o` + 编译器重模块 `check`（含 typeck） |
| **中位数计时** | 每 case `RUNS=3` 取 `perf_counter` 中位数 |
| **防回退** | median ≤ `tests/baseline/compile-dogfood.tsv` 上限 |
| **PR 自动跑** | GHA `ci.yml` → `run-ci-full-suite.sh` 硬门禁（native Linux x86_64） |

验收标准（NEXT PERF-004）：**每次 PR 自动比较基线，编译变慢则 CI fail**。自举专项接线见 **BOOT-012**（`analysis/boot-perf-regression-v1.md`）。

---

## 2. 用例矩阵（v1）

| case_id | 类型 | 命令 |
|---------|------|------|
| `loop_i32` | microbench `-o` | `shux tests/bench/loop_i32.x -o …` |
| `mem_copy` | microbench `-o` | `shux tests/bench/mem_copy.x -o …` |
| `struct_param` | microbench `-o` | `shux tests/bench/struct_param.x -o …` |
| `call_boundary` | microbench `-o` | `shux tests/bench/call_boundary.x -o …` |
| `perf_main` | perf baseline `-o` | `shux tests/perf-baseline/main.x -o …` |
| `check_backend` | frontend dogfood | `shux check compiler/src/asm/backend.x` |
| `check_parser` | frontend dogfood | `shux check compiler/src/parser/parser.x` |
| `check_typeck` | frontend dogfood | `shux check compiler/src/typeck/typeck.x`（COMP-002 热路径监控） |

**编译器二进制**：优先 `./compiler/shux-c`（与 IO/net perf 一致）；可用 `SHUX=…` 覆盖。

---

## 3. 门禁

### 3.1 PERF-004 专用

```bash
./tests/run-perf-compile-dogfood-gate.sh
# 等价：
SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh
```

| 检查 | 条件 |
|------|------|
| **manifest** | 基线 TSV + 8 个源路径存在 |
| **编译成功** | 每个 case exit 0 |
| **不回退** | `median ≤ baseline`（CI 含 slack，见下） |

### 3.2 CI 集成（PR 自动）

| 路径 | 行为 |
|------|------|
| `.github/workflows/ci.yml` | push/PR → `run-ci-full-suite.sh` |
| native **Linux x86_64** GHA | `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1` **硬失败** |
| macOS / Windows / Docker | 跑 timing 烟测，**不**硬门禁（抖动/环境差异） |
| `run-perf-p1-gate.sh` | 本地 push 前：硬门禁（与 Linux CI 对齐） |

CI slack（防虚拟机抖动误报）：

| 环境 | 乘数 |
|------|------|
| `CI=1`（GHA 原生） | baseline × **1.4** |
| Docker（`/.dockerenv` 或 `SHUX_CI_DOCKER=1`） | baseline × **1.65** |

---

## 4. 基线文件

| 文件 | 用途 |
|------|------|
| `tests/baseline/compile-dogfood.tsv` | 各 case median 上限（秒） |

更新（须 PR 评审，见 ENG-001）：

```bash
SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh
# 自动写入 median×1.5 或 median+0.015 较大者作为新上限
```

---

## 5. 与 BOOT-012 / BOOT-017 关系

| ID | 范围 |
|----|------|
| **PERF-004** | 用户态 `shux`/`shux-c` 编译固定模块/check |
| **BOOT-012**（P1） | 自举链全路径耗时（stage2 / shux_asm refresh 等） |
| **BOOT-017**（P2） | std/core 55 模块 `shux check` 分模块耗时；基线 `stdlib-dogfood.tsv` |

---

## 6. v2 预留

| 项 | 说明 |
|----|------|
| `check_typeck` / `check_pipeline` | 更大 frontend 模块 |
| shux_asm 自编译 dogfood | WPO 路径单独 TSV |
| 趋势上报 | PR comment 输出 delta 表 |

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 跑 bench | `tests/run-perf-compile-dogfood.sh` |
| PERF-004 gate | `tests/run-perf-compile-dogfood-gate.sh` |
| BOOT-017 std dogfood | `analysis/boot-017-stdlib-dogfood-v1.md` |
| CI 入口 | `tests/run-ci-full-suite.sh`（── compile dogfood ──） |
| P1 本地 | `tests/run-perf-p1-gate.sh` |

**PERF-004 状态：定版 ✅**
