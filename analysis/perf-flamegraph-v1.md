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
| **CI 友好** | 无 Linux perf 或无 native shux 时 gate manifest 仍绿，hook SKIP |

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
| `SHUX_PERF_FLAMEGRAPH_TOPN` | `20` | Top 行数 |
| `SHUX_PERF_FLAMEGRAPH_FREQ` | `997` | 采样频率 Hz |
| `SHUX_PERF_FLAMEGRAPH_CASE` | 空 | 仅跑指定 `case_id` |
| `SHUX_PERF_FLAMEGRAPH_OUT_DIR` | `/tmp/shux-perf-flamegraph` | 报告输出目录 |
| `SHUX_PERF_FLAMEGRAPH_PREFIX` | `shux: [SHUX_PERF_FLAMEGRAPH]` | stderr 摘要前缀 |

---

## 3. 剖析用例（v1）

文件：`tests/baseline/perf-flamegraph.tsv`

| case_id | 命令 | 用途 |
|---------|------|------|
| `check_typeck` | `shux check compiler/src/typeck/typeck.sx` | typeck dogfood（gate 烟测） |
| `loop_i32_compile` | `shux compile tests/bench/loop_i32.sx` | 微基准全链路 |
| `check_parser` | `shux check compiler/src/parser/parser.sx` | parser 体量热点 |

与 `compile-dogfood.tsv` 中 `check_typeck` / `check_parser` 对齐，便于 PERF-004 回归后对照 flamegraph。

---

## 4. 输出格式

### 4.1 TSV（每用例 `{case_id}-top20.tsv`）

列：`case_id` · `rank` · `pct` · `symbol`

```text
check_typeck	1	18.42	typeck_sx_ast
check_typeck	2	9.11	check_expr_impl_mega
...
```

### 4.2 stderr 摘要

```text
shux: [SHUX_PERF_FLAMEGRAPH] case=check_typeck top20_done rows=20
shux: [SHUX_PERF_FLAMEGRAPH] case=check_typeck report=/tmp/shux-perf-flamegraph/check_typeck-top20.tsv
```

汇总：`{OUT_DIR}/top20-summary.tsv`（所有用例拼接）。

### 4.3 可选 SVG

若 PATH 含 `stackcollapse-perf.pl` 与 `flamegraph.pl`，可在本地对 `perf.data` 另存 SVG（v1 gate 不强制）。

---

## 5. 用法

```bash
# 全矩阵（Linux + perf + native shux）
./tests/run-perf-flamegraph.sh

# 单用例
SHUX=./compiler/shux-c SHUX_PERF_FLAMEGRAPH_CASE=check_typeck ./tests/run-perf-flamegraph.sh

# 门禁
./tests/run-perf-flamegraph-gate.sh
```

推荐流程（与 `doc-perf-tuning-v1.md` §3 编译调优联动）：

1. `SHUX_COMPILE_PHASE_TIMING=1` 看 parse/typeck/codegen 哪段慢  
2. 对慢阶段对应模块跑 flamegraph Top20  
3. 对照 `typeck-hotpath-matrix.tsv` 中 `monitor`/`planned` 行开优化 PR  

---

## 6. 门禁

`tests/run-perf-flamegraph-gate.sh`：

1. RFC + manifest + `tests/lib/perf-flamegraph.sh` + runner 存在  
2. 文档含 `perf record`、`Top20`、`SHUX_PERF_FLAMEGRAPH`  
3. profile_case ≥ `min_cases`；cross-ref 文件存在  
4. Linux + perf + native shux：`check_typeck` 烟测须 `top20_done rows=20`  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-flamegraph.tsv` |
| 共享库 | `tests/lib/perf-flamegraph.sh` |
| runner | `tests/run-perf-flamegraph.sh` |
| 门禁 | `tests/run-perf-flamegraph-gate.sh` |
| typeck 热路径 | `analysis/comp-typeck-hotpath-v1.md` |
| compile dogfood | `analysis/perf-compile-dogfood-v1.md` |
| 阶段耗时 | `analysis/obs-compile-phase-timing-v1.md` |

**PERF-005 状态：定版 ✅**
