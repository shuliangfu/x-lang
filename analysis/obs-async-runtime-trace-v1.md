# OBS-002 async/runtime trace 采样 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-004`（async 调度）、`PERF-004`（async perf）、`OBS-001`（编译阶段耗时）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **长尾可见** | 调度 drain / task_run / IO poll / wake 慢路径可采样 |
| **Top-N 报告** | flush 时 stderr 输出最慢 N 条事件（默认 20） |
| **零默认开销** | 未设 `SHUX_ASYNC_RUNTIME_TRACE` 时不计时、不打印 |
| **可 grep** | 固定前缀，gate / CI / 脚本聚合 |

验收（NEXT OBS-002）：**可定位长尾延迟** → manifest + scheduler 埋点 + gate 烟测。

---

## 2. 环境变量

| 变量 | 默认 | 行为 |
|------|------|------|
| `SHUX_ASYNC_RUNTIME_TRACE` | 关 | 非空且非 `0` 启用采样 |
| `SHUX_ASYNC_RUNTIME_TRACE_TOPN` | `20` | flush 时输出的慢事件行数（1..64） |
| `SHUX_ASYNC_RUNTIME_TRACE_SAMPLE` | `1` | 每 N 次事件采 1 次（低于慢阈值的普通事件） |
| `SHUX_ASYNC_RUNTIME_TRACE_SLOW_US` | `500` | ≥ 该微秒数的事件**必**记录 |

与 `SHUX_ASYNC_YIELD` / `SHUX_ASYNC_IO_WAIT` 独立；可同时开启。

---

## 3. 事件种类（v1）

| kind | 触发点 | extra 含义 |
|------|--------|------------|
| `task_run` | `shu_async_drain_queue` 内 `fn()` | 0 |
| `suspend` | 任务返回 `SHUX_ASYNC_SUSPENDED` | 0 |
| `io_wake` | `shu_async_io_wake` | 唤醒任务数 |
| `poll_completions` | `shu_io_poll_async_completions` 返回 >0 | stall 轮次 |
| `drain_idle` | poll=0 的空转轮 | stall 轮次 |

实现：`std/async/scheduler.c`  
flush：`shu_async_runtime_trace_flush()`（`scheduler_drain` / `run_drain_until_idle` 结束自动调用）

---

## 4. 输出格式

摘要行：

```text
shux: [SHUX_ASYNC_RUNTIME_TRACE] summary events=42 slow_top=5
```

明细行（按 `us` 降序）：

```text
shux: [SHUX_ASYNC_RUNTIME_TRACE] rank=1 kind=task_run worker=0 us=1234 extra=0 fn=0x...
```

---

## 5. 矩阵

文件：`tests/baseline/obs-async-runtime-trace.tsv`

---

## 6. 门禁

`tests/run-obs-async-runtime-trace-gate.sh`：

1. RFC + manifest + `scheduler.c` 符号/env 锚点  
2. 烟测：`async_runtime_trace_smoke.c` + `SHUX_ASYNC_RUNTIME_TRACE=1` grep summary/rank  

---

## 7. 用法示例

```bash
# 调度队列烟测 + trace
SHUX_ASYNC_RUNTIME_TRACE=1 cc -std=gnu11 -o /tmp/fg_trace \
  tests/bench/async_runtime_trace_smoke.c std/async/scheduler.o
SHUX_ASYNC_RUNTIME_TRACE=1 /tmp/fg_trace 2>&1 | grep SHUX_ASYNC_RUNTIME_TRACE

# IO spawn 长尾（与 run-async.sh harness 联动）
SHUX_ASYNC_RUNTIME_TRACE=1 SHUX_ASYNC_YIELD=1 ./tests/bench/async_run_io_spawn_parallel
```

排查流程（配合 `doc-perf-tuning-v1.md`）：

1. async perf 回归异常 → 开 trace 复现  
2. 看 `slow_top` 中 `poll_completions` / `drain_idle` / `task_run` 占比  
3. 对照 `run-perf-async.sh` 中位数与 `async-perf.tsv`  

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/obs-async-runtime-trace.tsv` |
| 调度器 | `std/async/scheduler.c` |
| 门面 | `std/async/README.md` |
| 烟测 | `tests/bench/async_runtime_trace_smoke.c` |
| 门禁 | `tests/run-obs-async-runtime-trace-gate.sh` |
| async perf | `tests/baseline/async-perf.tsv` |
| compile dogfood | `analysis/perf-compile-dogfood-v1.md` |

**OBS-002 状态：定版 ✅**
