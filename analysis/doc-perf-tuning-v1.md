# DOC-003 性能调优手册 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 读者：排查编译变慢、IO/NET 回退、自举耗时的开发者  
> 关联：`PERF-001~004`、`OBS-001`、`ENG-001`、`ZC-006`

---

## 1. 阅读路径（约 50 分钟）

| 时段 | 章节 | 产出 |
|------|------|------|
| **0–10 min** | §2 性能维度 | 区分编译时 vs 运行时 |
| **10–25 min** | §3 编译调优流程 | 会用 `SHUX_COMPILE_PHASE_TIMING` |
| **25–40 min** | §4 IO/NET 调优流程 | 知道跑哪条 perf gate |
| **40–50 min** | §5 自举/CI 诊断 + §9 自检 | 会 `./tests/run-bootstrap-stage-diag.sh` |

---

## 2. 性能维度

```
┌─────────────────────────────────────────────────────────┐
│ A — 编译时（compiler dogfood）  PERF-004 / OBS-001       │
├─────────────────────────────────────────────────────────┤
│ B — 运行时 microbench          run-perf-baseline.sh      │
├─────────────────────────────────────────────────────────┤
│ C — IO 吞吐/随机               PERF-002 / io-perf.tsv    │
├─────────────────────────────────────────────────────────┤
│ D — NET 吞吐/延迟              PERF-003 / net-perf.tsv   │
├─────────────────────────────────────────────────────────┤
│ E — 自举构建                   bootstrap-stage-diag      │
└─────────────────────────────────────────────────────────┘
```

| 症状 | 优先维度 | 首条命令 |
|------|----------|----------|
| `shux check` / 编大模块变慢 | A | `SHUX_COMPILE_PHASE_TIMING=1 shux check …` |
| loop/mem_copy bench 变慢 | B | `./tests/run-perf-baseline.sh --bench` |
| 顺序/随机读慢 | C | `./tests/run-perf-io.sh --bench` |
| echo/并发连接慢 | D | `./tests/run-perf-net.sh --bench` |
| bootstrap CI 红 | E | `./tests/run-bootstrap-stage-diag.sh ci.log` |

---

## 3. 编译调优实战流程

### 3.1 阶段拆分（OBS-001）

```bash
SHUX_COMPILE_PHASE_TIMING=1 ./compiler/shux-c check compiler/src/parser/parser.sx
```

期望 stderr 一行：

```text
shux: [SHUX_COMPILE_PHASE_TIMING] parse_ms=… typeck_ms=… codegen_ms=… total_ms=…
```

| 阶段偏高 | 排查方向 |
|----------|----------|
| **parse_ms** | parser emit / second-pass；`run-parser-second-pass-gate.sh` |
| **typeck_ms** | `run-typeck-hotpath-gate.sh`；`SHUX_TYPECK_PTR=1` 调试 |
| **codegen_ms** | WPO/asm；`run-wpo-strict-link-gate.sh` |
| **total 回归** | `run-perf-compile-dogfood-gate.sh` vs `compile-dogfood.tsv` |

### 3.2 编译 dogfood 回归（PERF-004）

```bash
./tests/run-perf-compile-dogfood.sh
SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood-gate.sh
```

固定用例见 `tests/baseline/compile-dogfood.tsv`（bench + `check parser/typeck`）。

### 3.3 调试 env（可选）

| 变量 | 用途 |
|------|------|
| `SHUX_DEBUG_PIPE=1` | pipeline 阶段 marker |
| `SHUX_DEBUG_PARSE=1` | parse skip 列表 |
| `SHUX_TYPECK_PTR=1` | 指针字段 typeck 诊断 |

---

## 4. IO/NET 运行时调优流程

### 4.1 IO（PERF-002）

```bash
./tests/run-perf-io.sh --bench
SHUX_PERF_FAIL_ON_IO_REGRESSION=1 SHUX_PERF_FAIL_ON_IO_ZIG=1 ./tests/run-perf-io-zig-gate.sh
```

| case | 说明 |
|------|------|
| `io_mmap_throughput` | 顺序 mmap 扫描 |
| `io_random_pread` | 随机 pread |
| `zero_copy_sendfile` | 内核零拷贝 |

**零拷贝选型**：见 `analysis/zc-semantics-v1.md` §6 决策树。

基线：`tests/baseline/io-perf.tsv`；对标 Zig：`tests/baseline/zig-perf.tsv`。

### 4.2 NET（PERF-003）

```bash
./tests/run-perf-net.sh --bench
./tests/run-perf-net-zig-gate.sh
```

基线：`net-perf.tsv` + `net-perf-latency.tsv`（P99）。

### 4.3 microbench（PERF-001）

```bash
./tests/run-perf-baseline.sh --bench
```

对比 Zig/C：`SHUX_PERF_FAIL_ON_ZIG=1` / `SHUX_PERF_FAIL_ON_C_O3=1`（见脚本注释）。

---

## 5. 自举与 CI 诊断

### 5.1 阶段 taxonomy（BOOT-004）

```bash
./tests/run-bootstrap-stage-diag.sh path/to/ci.log
./tests/run-bootstrap-repro.sh <case_id>
```

阶段：preprocess → lexer → parser → typeck → codegen → asm → link。

### 5.2 失败分类

`analysis/boot-failure-taxonomy-v1.md` + `run-bootstrap-failure-taxonomy-gate.sh`。

### 5.3 跨平台

`run-bootstrap-crossplatform-gate.sh` — Linux/macOS 报告矩阵。

---

## 6. Baseline 治理（ENG-001）

改 `tests/baseline/*perf*.tsv` **须**：

1. bump `tests/baseline/perf-baseline-registry.tsv` 对应 `version`
2. 跑 registry 中 `gate_script`
3. PR 说明 host / Shu 版本 / median 前后

```bash
./tests/run-eng-baseline-governance-gate.sh
```

---

## 7. 调优命令速查

| 目标 | 命令 |
|------|------|
| 编译阶段耗时 | `SHUX_COMPILE_PHASE_TIMING=1 shux check …` |
| 编译 dogfood | `tests/run-perf-compile-dogfood-gate.sh` |
| 编译阶段 gate | `tests/run-obs-compile-phase-timing-gate.sh` |
| async trace Top20 | `tests/run-obs-async-runtime-trace-gate.sh` |
| flamegraph Top20 | `tests/run-perf-flamegraph-gate.sh` |
| IO 对标 | `tests/run-perf-io-zig-gate.sh` |
| NET 对标 | `tests/run-perf-net-zig-gate.sh` |
| baseline 治理 | `tests/run-eng-baseline-governance-gate.sh` |
| 微基准 | `tests/run-perf-baseline.sh --bench` |
| async | `tests/run-perf-async.sh` |
| 自举阶段 | `tests/run-bootstrap-stage-diag.sh` |
| portable 全套 | `tests/run-portable-suite.sh` |

## 8. 深入阅读

| 主题 | 文档 |
|------|------|
| Zig 基线 | `analysis/perf-zig-baseline-v1.md` |
| IO 对标 | `analysis/perf-io-zig-v1.md` |
| NET 对标 | `analysis/perf-net-zig-v1.md` |
| 编译阶段 | `analysis/obs-compile-phase-timing-v1.md` |
| async trace | `analysis/obs-async-runtime-trace-v1.md` |
| flamegraph Top20 | `analysis/perf-flamegraph-v1.md` |
| 零拷贝 | `analysis/zc-semantics-v1.md` |
| baseline 治理 | `analysis/eng-baseline-governance-v1.md` |
| 自举架构 | `analysis/doc-selfhost-architecture-v1.md` |

---

## 9. 自检（5 题）

1. 编译变慢先看什么 env？→ **`SHUX_COMPILE_PHASE_TIMING=1`**
2. IO 随机读回归跑哪个 gate？→ **`run-perf-io-zig-gate.sh`**
3. 改 io-perf.tsv 还要改什么？→ **registry version + gate**
4. bootstrap 日志如何定位阶段？→ **`run-bootstrap-stage-diag.sh`**
5. 零拷贝读热路径选型文档？→ **`zc-semantics-v1.md`**

**DOC-003 状态：定版 ✅**
