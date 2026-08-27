# PERF-005 perf flamegraph 自动化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`COMP-002`（typeck 热路径）、`PERF-004`（compile dogfood）、`OBS-001`（阶段耗时）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **Top20 自动报告** | 对固定编译用例 `perf record`，输出 Top-20 符号 TSV |
| **可复现矩阵** | manifest 锁定用例与命令，PR 可对比热点漂移 |
| **零强依赖 SVG** | v1 以符号 Top-N 为主；系统有 FlameGraph 时可另存 SVG |
| **CI 友好** | 无 Linux perf 或无 native xlang 时 gate manifest 仍绿，hook SKIP |

验收（NEXT PERF-005）：**Top20 热点报告自动生成** → manifest + runner + gate 烟测。

---

## 2. 平台与工具

| 平台 | v1 支持 |
|------|---------|
| **Linux x86_64 / aarch64** | `perf record` + `perf report --sort=symbol` |
| **macOS / 无 perf** | runner/gate **SKIP**（manifest 本地必过） |

环境变量：

| 变量 | 默认 | 说明 |
|------|------|------|
| `XLANG_PERF_FLAMEGRAPH_TOPN` | `20` | Top 行数 |
| `XLANG_PERF_FLAMEGRAPH_FREQ` | `997` | 采样频率 Hz |
| `XLANG_PERF_FLAMEGRAPH_CASE` | 空 | 仅跑指定 `case_id` |
| `XLANG_PERF_FLAMEGRAPH_OUT_DIR` | `/tmp/xlang-perf-flamegraph` | 报告输出目录 |
| `XLANG_PERF_FLAMEGRAPH_PREFIX` | `xlang: [XLANG_PERF_FLAMEGRAPH]` | stderr 摘要前缀 |

---

## 3. 剖析用例（v1）

文件：`tests/baseline/perf-flamegraph.tsv`

| case_id | 命令 | 用途 |
|---------|------|------|
| `loop_i32_compile` | `xlang bench/r01_loop_i32.x -o …` | 微基准全链路（**gate 烟测**；避 check 暂停闸门） |
| `check_typeck` | `xlang check compiler/src/typeck/typeck.x` | typeck dogfood（profile；check 闸门自举期暂停） |
| `check_parser` | `xlang check compiler/src/parser/parser.x` | parser 体量热点（profile） |

与 `compile-dogfood.tsv` 中 `check_typeck` / `check_parser` 对齐，便于 PERF-004 回归后对照 flamegraph。

---

## 4. 输出格式

### 4.1 TSV（每用例 `{case_id}-top20.tsv`）

列：`case_id` · `rank` · `pct` · `symbol`

```text
check_typeck	1	18.42	typeck_x_ast
check_typeck	2	9.11	check_expr_impl_mega
...
```

### 4.2 stderr 摘要

```text
xlang: [XLANG_PERF_FLAMEGRAPH] case=check_typeck top20_done rows=20
xlang: [XLANG_PERF_FLAMEGRAPH] case=check_typeck report=/tmp/xlang-perf-flamegraph/check_typeck-top20.tsv
```

汇总：`{OUT_DIR}/top20-summary.tsv`（所有用例拼接）。

### 4.3 可选 SVG

若 PATH 含 `stackcollapse-perf.pl` 与 `flamegraph.pl`，可在本地对 `perf.data` 另存 SVG（v1 gate 不强制）。

---

## 5. 用法

```bash
# 全矩阵（Linux + perf + native xlang）
./tests/run-perf-flamegraph.sh

# 单用例
XLANG=./compiler/xlang_asm XLANG_PERF_FLAMEGRAPH_CASE=loop_i32_compile ./tests/run-perf-flamegraph.sh

# 门禁
./tests/run-perf-flamegraph-gate.sh
```

推荐流程（与 `doc-perf-tuning-v1.md` §3 编译调优联动）：

1. `XLANG_COMPILE_PHASE_TIMING=1` 看 parse/typeck/codegen 哪段慢  
2. 对慢阶段对应模块跑 flamegraph Top20  
3. 对照 `typeck-hotpath-matrix.tsv` 中 `monitor`/`planned` 行开优化 PR  

---

## Gate

Honesty soft→硬绿 (2026-08-27): prefer `xlang_asm`; refuse soft SKIP→OK /
soft prefer-xlang-c / fossil `bench/loop_i32.x` + top-level DOC/cross-refs;
explicit bad XLANG = hard die; no-perf host = skip=1; partial Top-N = obs;
smoke=`loop_i32_compile` (check-bound profile cases left; check gate paused);
DOC=archive; report `run=`／`obs=`／`skip=`.

`tests/run-perf-flamegraph-gate.sh`：

1. Archive DOC + manifest + `tests/lib/perf-flamegraph.sh` + runner（拒顶层 `analysis/perf-flamegraph-v1.md`）  
2. 文档含 `perf record`、`Top20`、`XLANG_PERF_FLAMEGRAPH`  
3. profile_case ≥ `min_cases`；cross-ref → archive 路径  
4. Linux + perf + native xlang：`loop_i32_compile` 烟测须 `top20_done`；其它平台 skip=1  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-flamegraph.tsv` |
| 共享库 | `tests/lib/perf-flamegraph.sh` |
| runner | `tests/run-perf-flamegraph.sh` |
| 门禁 | `tests/run-perf-flamegraph-gate.sh` |
| typeck 热路径 | `analysis/archive/comp/comp-typeck-hotpath-v1.md` |
| compile dogfood | `analysis/archive/perf/perf-compile-dogfood-v1.md` |
| 阶段耗时 | `analysis/archive/obs/obs-compile-phase-timing-v1.md` |

**PERF-005 状态：定版 ✅**
