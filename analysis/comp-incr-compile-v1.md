# COMP-007 编译缓存 / 增量编译策略 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1 策略 + 原型登记）** — 可测量二次编译；全量 `.sx.dep.o` 缓存为 v2  
> 关联：`OBS-001`（阶段计时）、`PERF-004`（dogfood）、`PERF-010`（冷编译优化）、`COMP-009`（FE/BE 契约）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 策略层 C1–C6 |
| 2 | 打开 `tests/baseline/comp-incr-compile-prototype.tsv` |
| 3 | `./tests/run-comp-incr-compile-gate.sh` |
| 4 | `SHUX_COMPILE_PHASE_TIMING=1 ./tests/run-comp-incr-compile.sh` |

---

## 2. 策略层 C1–C6（incremental compile）

权威：`tests/baseline/comp-incr-compile.tsv`（**6** 条 `layer_*`）。

| 层级 | 策略 | v1 状态 | 锚点 |
|------|------|---------|------|
| **C1-dep-seed** | 依赖模块 C 预跑槽位，跳过重复 read/parse | **done** | `driver_dep_seeded_get` |
| **C2-lsp-cache** | LSP 同源 hash 复用 `ASTModule` | **done** | `lsp_diag_invalidate_cache` |
| **C3-asm-preserve** | 自举第二遍失败时保留非空 `__text` | **done** | `build_shux_asm.sh` |
| **C4-std-prelink** | 预编译 `std/*.o` 链入，用户增量不重编 std | **done** | `runtime.c` `get_std_*_o_path` |
| **C5-phase-timing** | 分阶段计时衡量增量收益 | **done** | `SHUX_COMPILE_PHASE_TIMING` |
| **C6-object-cache** | 按内容 hash 复用 `.o`（import 闭包） | **planned** | v2 RFC |

**incremental 原则**：

1. **先观测再缓存**：用 `SHUX_COMPILE_PHASE_TIMING` 定位 parse/typeck/codegen 占比，再决定 cache 粒度。
2. **dep 优先**：多文件项目重复成本在 import 闭包；v1 以 `driver_dep_*` 预填为主。
3. **check 与 -o 分轨**：`shux check` 可走 LSP 级 cache；`-o` 链路 v1 仅保证**二次编译可测量且不回退**（ratio ≤1.0）。
4. **v2 目标**：二次编译 median ≤ **0.85×** 首次（`comp-incr-compile-bench.tsv` `target_ratio`）。

---

## 3. 原型登记（prototype report）

`tests/baseline/comp-incr-compile-prototype.tsv`（**6** 条 `proto_*`）。

| proto_id | 能力 | status | 文件 |
|----------|------|--------|------|
| `proto_dep_seed` | dep 预跑跳过 parse | done | `pipeline.sx` |
| `proto_lsp_cache` | 源 hash 模块 cache | done | `lsp_diag.c` |
| `proto_asm_preserve` | build_asm __text 保留 | done | `build_shux_asm.sh` |
| `proto_std_prelink` | std 预链 .o | done | `runtime.c` |
| `proto_phase_timing` | 阶段计时 | done | `obs-compile-phase-timing-v1.md` |
| `proto_object_cache` | 内容寻址 .o | planned | — |

---

## 4. 二次编译 bench（v1）

`tests/baseline/comp-incr-compile-bench.tsv`（**5** 条）。

| bench_id | 用例 | 命令 | v1 阈值 |
|----------|------|------|---------|
| `bench_double_check` | `loop_i32.sx` | `check` ×2 | second/first ≤ **1.0** |
| `bench_double_o` | `loop_i32.sx` | `-o` ×2 | second/first ≤ **1.0** |
| `bench_timing` | 同上 | `SHUX_COMPILE_PHASE_TIMING=1` | 须输出 timing 行 |
| `bench_make_q` | `compiler/` | `make -q` | exit 0（构建 cache 代理） |
| `bench_dogfood_check` | `tests/wpo/dead_fn.sx` | `check` ×2 | second/first ≤ **1.1**（扩面 v1） |

**report 行**：

```text
comp-incr-compile: bench_double_check ratio=0.92 first_ms=120 second_ms=110 OK
```

---

## 5. 非目标（v1）

- 全仓库 `.sx.dep.o` 内容寻址缓存
- 分布式编译缓存 / 远程 cache
- Windows 专用增量链接器集成

---

## 6. 验证与门禁

```bash
./tests/run-comp-incr-compile-gate.sh   # runnable：manifest + prototype + bench
./tests/run-comp-incr-compile.sh        # 二次编译烟测 + ratio report
./tests/run-obs-compile-phase-timing-gate.sh  # 阶段计时联动
```

**gate report**：stdout 须含 `comp-incr-compile gate OK`；失败打印 `comp-incr-compile FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-incr-compile-v1.md` |
| manifest | `tests/baseline/comp-incr-compile.tsv` |
| prototype | `tests/baseline/comp-incr-compile-prototype.tsv` |
| bench | `tests/baseline/comp-incr-compile-bench.tsv` |

**COMP-007 状态：定版 ✅（v1 策略）**
