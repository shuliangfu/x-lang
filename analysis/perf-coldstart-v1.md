# PERF-010 启动与冷编译时间 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 复用 `run-perf-coldstart.sh` + `coldstart-perf.tsv` 基线  
> 关联：`PERF-004`（首编译 dogfood）、`COMP-007`（增量编译）、`ENG-001`（baseline 治理）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 优化层 T1–T6 |
| 2 | 打开 `tests/baseline/coldstart-perf.tsv` |
| 3 | `./tests/run-perf-coldstart-gate.sh` |
| 4 | `SHUX_COLDSTART_RUNS=5 ./tests/run-perf-coldstart.sh` |

---

## 2. 优化层 T1–T6（coldstart / first compile）

权威：`tests/baseline/perf-coldstart.tsv`（**6** 条 `layer_*`）。

| 层级 | 指标 | 含义 | 基线键 | 脚本 |
|------|------|------|--------|------|
| **T1-exec-latency** | 进程冷启动 startup | strip 后 `hello` 执行 median μs | `hello_stripped_us` | `run-perf-coldstart.sh` |
| **T2-fs-min** | 最小 freestanding | `return42` 无 std | `fs_return42_stripped_us` | 同上 |
| **T3-fs-io** | freestanding + syscall | `tests/freestanding/hello` | `fs_hello_stripped_*` | 同上 |
| **T4-first-compile** | 首编译耗时 | 编译器编 `.sx` median s | `compile-dogfood.tsv` | `PERF-004` |
| **T5-stripped-size** | 冷启动体积 | stripped bytes cap | `*_stripped_bytes` | 同上 |
| **T6-ci-wire** | CI 回归 | `run-ci-full-suite.sh` B-BOOT 段 | registry | `ENG-001` |

**coldstart 原则**：

1. **执行 vs 编译分离**：T1–T3 测**已生成二进制**的启动延迟；T4 测**编译器自身**编源码（PERF-004）。
2. **median 抗抖**：默认 `SHUX_COLDSTART_RUNS=20`；gate 烟测可用 `3`。
3. **平台放宽**：Darwin/MSYS 对 `hello_stripped_us` 乘 slack（见 `baseline_cap()`）。
4. **优化方向**：预链 `std/*.o`（`runtime.c`）、`-freestanding` 减链、COMP-007 增量减二次编译。

---

## 3. 基线矩阵（median report）

`tests/baseline/coldstart-perf.tsv`（**5** 个 metric）。

| metric_id | cap | 样例 |
|-----------|-----|------|
| `hello_stripped_us` | 15000 μs | `examples/hello.sx` |
| `fs_return42_stripped_us` | 1500 μs | `tests/freestanding/return42/main.sx` |
| `fs_return42_stripped_bytes` | 65536 B | 同上 |
| `fs_hello_stripped_us` | 2000 μs | `tests/freestanding/hello/main.sx` |
| `fs_hello_stripped_bytes` | 131072 B | 同上 |

更新（须 PR 评审）：

```bash
SHUX_PERF_UPDATE_COLDSTART_BASELINE=1 ./tests/run-perf-coldstart.sh --bench
```

---

## 4. 门禁环境

| 变量 | 说明 |
|------|------|
| `SHUX_PERF_FAIL_ON_COLDSTART_REGRESSION=1` | 实测 ≤ baseline cap |
| `SHUX_COLDSTART_RUNS` | median 采样次数（默认 20） |
| `SHUX_COLDSTART_FREESTANDING_ONLY=1` | 仅 freestanding（shux_asm CI 段） |
| `SHUX_COLDSTART_STD_ONLY=1` | 仅 std hello |

**gate report**：`coldstart OK` / `perf-coldstart gate OK`（runnable manifest + 烟测）。

---

## 5. 非目标（v1）

- 全平台 freestanding 硬门禁（仅 Linux x86_64 强测）
- 编译器进程自身 RSS 峰值
- 与 Zig 冷启动对标（见 PERF-011 看板）

---

## 6. 验证与门禁

```bash
./tests/run-perf-coldstart-gate.sh
SHUX_PERF_FAIL_ON_COLDSTART_REGRESSION=1 ./tests/run-perf-coldstart.sh   # Linux CI
./tests/run-perf-compile-dogfood-gate.sh   # T4 首编译（PERF-004）
```

注册表：`tests/baseline/perf-baseline-registry.tsv` 条目 `coldstart-perf`。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/perf-coldstart-v1.md` |
| manifest | `tests/baseline/perf-coldstart.tsv` |
| cap | `tests/baseline/coldstart-perf.tsv` |

**PERF-010 状态：定版 ✅**
