# std.async API v1 稳定化（STD-004）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-001`（std.io async 槽）、`tests/run-async.sh`、`tests/run-perf-async.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **调度器稳定** | 1M task ping-pong 压测 **无崩溃**、计数正确 exit 0 |
| **API 冻结边界** | `import("std.async")` 门面 + scheduler C 桥接符号 |
| **兼容矩阵** | 单线程协作调度 + IO 等待队列 + 多 worker 预览 |
| **变更流程** | 与 STD-001 同级评审规则 |

验收标准（NEXT STD-004）：**1M task 压测无崩溃** + manifest + 烟测。

---

## 2. 模块分层

```
import("std.async")       ← 用户/语言 codegen 稳定面（§3）
    ├── std.io         ← wait_completion / submit_* 委托
    └── scheduler.c    ← 协作帧、MPSC 环、CPS suspend、IO wake
```

**v1 规则**：无栈协作调度 **单进程单线程默认可用**；`SHUX_ASYNC_WORKERS>1` 为预览（须 `-pthread`）。

---

## 3. 稳定 API 清单（Tier S）

完整符号见 `tests/baseline/std-async-api.tsv`（34 个，门禁校验）。

### 3.1 IO 门面（F4）

| 符号 | 说明 |
|------|------|
| `wait_completion` | 多 fd 就绪等待（委托 `io.wait_readable`） |
| `submit_read_sync` / `submit_write_sync` | 同步 submit+wait |

### 3.2 协作调度（A1/A2）

| 符号 | 说明 |
|------|------|
| `coop_pingpong(rounds)` | switch dispatch 双任务 ping-pong |
| `coop_pingpong_jmp(rounds)` | computed-goto dispatch |
| `SHUX_ASYNC_SUSPENDED` | CPS suspend 哨兵 `0x41535700` |

### 3.3 CPS / run / spawn（A3–A5）

| 符号 | 说明 |
|------|------|
| `shu_async_cps_suspend` / `shu_async_cps_suspend_io` | await 边界 |
| `shu_async_run_i32` / `shu_async_spawn_i32` | 协程入口 |
| `shu_async_run_drain_until_idle` | poll + drain 至空闲 |
| `shu_async_run_seed_*` | run v4 实参队列（i32/u32/i64/usize） |

### 3.4 就绪队列（A4）

| 符号 | 说明 |
|------|------|
| `shu_async_task_submit` / `shu_async_task_submit_to` | MPSC 入队 |
| `shu_async_scheduler_drain` / `shu_async_worker_drain` | consumer drain |
| `shu_async_worker_count` / `shu_async_worker_pending` | worker 状态 |
| `shu_async_queue_reset` / `shu_async_scheduler_pending` | 队列重置/深度 |
| `shu_async_io_wake_all` / `shu_async_io_waiters_pending` | IO 等待队列 |

---

## 4. 1M task 压测（v1）

| case | 脚本 | steps | 说明 |
|------|------|-------|------|
| `async_switch` | `tests/bench/async_switch.sx` | 2M | 手工 CoopFrame 状态机 |
| `async_1m_coop` | `tests/bench/async_1m_coop.sx` | 4M | `coop_pingpong` + `coop_pingpong_jmp` 各 1M |
| `async_switch_sched` | `tests/bench/async_switch_sched.sx` | 2M | extern jmp（Linux x86_64 asm） |

矩阵：`tests/baseline/std-async-1m.tsv`  
门禁：`tests/run-std-async-1m-gate.sh`

**通过条件**：每个 `must` case **exit 0**（无 SIGSEGV/abort；计数 `total == 2*rounds`）。

---

## 5. 性能回归（B-ASYNC，可选）

与 STD-004 正交；perf 上限见 `tests/baseline/async-perf.tsv`：

```bash
SHUX_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench
```

目标 stretch：2M steps ≤ **15ns/step**（~0.03s total）。

---

## 6. 环境变量

| 变量 | 说明 |
|------|------|
| `SHUX_ASYNC_YIELD=1` | await 边界 yield（CPS suspend） |
| `SHUX_ASYNC_IO_WAIT=1` | suspend 进 IO 等待队列 |
| `SHUX_ASYNC_WORKERS=N` | 1..8 per-worker 就绪环 |
| `SHUX_ASYNC_AFFINITY=1` | worker_drain 绑核（须链 std.thread） |

---

## 7. 兼容矩阵（v1）

| 能力 | Linux | macOS | Windows |
|------|-------|-------|---------|
| **1M coop ping-pong** | ✅ | ✅ | ✅ shux-c |
| **scheduler jmp asm** | ✅ x86_64 | skip | skip |
| **import("std.async") 按需链 scheduler.o** | ✅ | ✅ | ✅ |
| **await + IO async** | ✅ io_uring | ⚠️ kqueue | ⚠️ IOCP |
| **MPSC multi-worker** | ✅ -pthread | ✅ | ✅ |

---

## 8. 变更流程（v1）

1. **Tier S 变更**须 PR + 更新 `std-async-api.tsv` + `run-std-async-api-gate.sh`
2. **调度语义变更**须重跑 `run-std-async-1m-gate.sh`
3. **perf 基线变更**须更新 `async-perf.tsv` 并说明原因

---

## 9. 索引

| 资源 | 路径 |
|------|------|
| 用户 README | `std/async/README.md` |
| 调度内核 | `std/async/scheduler.c` |
| API 门禁 | `tests/run-std-async-api-gate.sh` |
| 1M 压测 | `tests/run-std-async-1m-gate.sh` |
| 全量烟测 | `tests/run-async.sh` |

**STD-004 状态：定版 ✅**
