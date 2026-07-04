# std.async

最小异步门面（F4）+ **A1/A2 协作调度 POC**（P2）。

## 模块 API（`mod.x`）

- `wait_completion` / `submit_read_sync` / `submit_write_sync` — 同步 IO 门面
- **STD-049 io_uring 完整路径**：`io_uring_is_available` / `read_async*` / `write_async*` / `complete_*_slot` / `io_pump_once` / `poll_loop_ctx`（re-export std.io async + Context poll）
- **STD-049 / #79 net/fs 集成**：`await_read_fd` / `await_write_fd` / `net_read_async` / `fs_read_async` / `net_fs_async_smoke`（pipe 烟测）
- `coop_pingpong(rounds)` — switch dispatch 双任务 ping-pong（`scheduler_glue.c` + `scheduler.x`）
- `coop_pingpong_jmp(rounds)` — computed-goto 跳转表 dispatch（A2 预览）
- **`future_new` / `future_poll` / `future_complete` / `future_take`** — 手动 i32 Future/Poll（`future.x`，F-async-future v2）
- **`future_wait(fut, max_rounds)`** — poll + IO poll + `drain_until_idle` 轮询等待
- **`runtime_wait_future(rt, fut, max_rounds)`** — Context 绑定 + `future_wait`（await 桥接）
- `shux_async_task_submit` / `shux_async_scheduler_drain` — A4 就绪队列（C extern；`.x` 函数指针待语言支持）

## 调度内核（`scheduler_glue.c` + `scheduler.x`）

无 malloc、无 pthread；单线程协作帧 `{ phase, ops }` + 1M ping-pong 压测入口。

A3 CPS ✅：`shux_async_cps_suspend` / `shux_async_cps_suspend_io` + static 帧 + `SHUX_ASYNC_YIELD` 烟测；`shux_async_run_i32` / **`spawn`** + `shux_async_run_drain_until_idle`。

A4 预览：atomic MPSC 就绪 ring；**A4 v2** `SHUX_ASYNC_WORKERS=N` per-worker 环 + `shux_async_worker_drain`；**`SHUX_ASYNC_AFFINITY=1`** 链 `std.thread` 时 drain 绑核 `worker_id`。

`await read(...)` / `await write(...)` / **`await read_fd(...)`** / **`await write_fd(...)`** emit submit/suspend_io/complete 三阶段；帧内 `__io_rd_slot` / `__io_wr_slot` 支持多协程并行 in-flight（`SHUX_IO_ASYNC_SLOTS`，默认 8）。双协程 read e2e：`async_scheduler_io_read_multi_e2e.c`；write 对称：`async_scheduler_io_write_multi_e2e.c`。`.x` 双 run：`async_await_io_dual.x`。Linux 全链路：`async_run_io_stdin.x`（pipe stdin + `SHUX_ASYNC_YIELD=1`）；双 pipe：`async_run_io_dual_pipe.x` + wrapper（fd 3/4）；`shux_async_run_i32` 不清 seed（`run` 先 push 再 sched）。

含 `await` 的 async 函数 emit **`shux_async_sched_<name>()`**；sync 用 **`run async_fn(...)`**（v4 seed：**i32 / u32 / i64 / usize**，最多 8 个；**usize** 用于 IO handle/fd）。

链接：`import("std.async")` 且调用 `coop_pingpong*` 时，runtime 扫描用户 `.o` 的 `nm -u`，按需链入 `std/async/scheduler.o`（无需手工 `cc ... scheduler.o`）。`async` 为语言关键字时 parser 仍允许 `import("std.async")` 路径段。

IO-A4 multishot accept：`run-io-multishot.sh`（Linux + liburing）；`.x` 双 pipe 全链路：`async_run_io_dual_pipe.x` + wrapper。IO-A5 v3：`shux_io_poll_async_completions` + `run_i32` 自动 poll/wake。IO-A5 v4：**`spawn async_fn(args)`** 非阻塞 submit + **`shux_async_run_drain_until_idle()`**（`.x` 双协程并行：`async_run_io_dual_parallel.x`，**`import("std.async")`**）。IO-A5 v5：**`shux_async_spawn_i32`** C 侧 spawn 等价 + **`async_run_io_spawn_parallel.c`** / **`async_run_io_spawn_workers.c`**（`SHUX_ASYNC_WORKERS=2`）。

## 验收

```bash
./tests/run-async.sh
./tests/run-perf-async.sh --bench
SHUX_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench
```

B-ASYNC 目标：2M steps ≤ **15ns/step**（stretch）；当前 bench ~**1.5ns/step** @ arm64。
