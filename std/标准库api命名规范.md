# 标准库 API 命名规范

> **硬性规则**：函数名**不得出现标量类型名**（`i32` `u32` `i64` `usize` `u8` `f32` `f64` `bool` 等）。
> 类型仅通过参数、返回值、容器（`Vec_i32`）或**函数重载**表达。
> **书写目标**：绑定 import 后，Tier-S 日常 API 函数名 **3～12 字符**；语义后缀仅表达参数无法区分的差异。
> 模块 70 · API 3193 · **三轮精简**（2026-06）已更新简化名对照表

---

## 一、核心原则

### 1. 绑定导入：去模块前缀

```su
const io = import("std.io");     io.read(...);      // not io.io_read / io.read_into
const socket = import("std.socketio"); socket.connect(...);
const vec = import("std.vec");    vec.push(&v, x);   // not vec.vec_i32_push
const sync = import("std.sync");  sync.new_mutex();  // not sync.sync_mutex_new
```

### 2. 函数名：去一切类型名（硬性）


| ❌ 禁止                             | ✅ 简化名            | 类型如何表达         |
| -------------------------------- | ---------------- | -------------- |
| `run_seed_push_i32` / `_u32` / … | `run_seed_push`  | 函数重载      |
| `vec_i32_push` / `push_i32`      | `push`           | `*Vec_i32`     |
| `map_i32_i32_get`                | `get`            | `*Map_i32_i32` |
| `channel_i32_send`               | `send`           | `*Channel_i32` |
| `expect_eq_u32`                  | `assert_eq`      | 重载             |
| `load_i64` / `store_u32`         | `load` / `store` | `*T` 指针        |
| `alloc_u8` / `alloc_f64`         | `alloc`          | 重载返回 `*T`      |
| `print_i32`                      | `print`          | 重载             |


**保留**：`connect_ipv6`、`resolve_ipv4` 等**协议/语义**后缀（不是标量类型名）。

---

### 3. 参数个数后缀：一律去掉（硬性）


| ❌ 禁止                    | ✅ 简化名             | 说明               |
| ----------------------- | ----------------- | ---------------- |
| `format_2` / `format_3` | `format`          | 由重载承载不同实参数量 |
| `select_recv_2`         | `select_recv`     | 双路/多路由参数容器承载     |
| `format_template_1`     | `format_template` | 占位数量不进函数名        |

---

### 4. 绑定 import 后：去模块内冗余前缀（三轮精简）

模块绑定名已提供命名空间，函数名**不再重复**模块名或容器类型名（标量类型 token 仍禁止）。

| ❌ 冗余（绑定 `const io = import("std.io")` 后） | ✅ 简化名 | 说明 |
| --- | --- | --- |
| `io_read` / `read_into` | `read` | 同义合并为重载 |
| `read_ptr_len` / `read_ptr_gen` | `ptr_len` / `ptr_gen` | 模块内省略 `read_` |
| `mutex_new` / `mutex_lock` | `new_mutex` / `lock` | 多原语并存时保留**短类型前缀**防歧义 |
| `task_submit` | `submit` | async 模块内动词即可 |
| `registry_register_counter` | `counter` | metrics 模块内省略 `registry_register_` |
| `extend_from_slice` | `extend` | 容器模块内最短可读动词 |

**歧义规则**：同一 `mod.sx` 内简化名不得冲突；若 `create`/`reset`/`new` 会撞车，保留**最短消歧前缀**（如 `new_mutex` vs `new_rwlock`，`runtime_reset` vs `scheduler_reset`）。

---

### 5. 生命周期动词统一

| 场景 | 创建 | 销毁 | 示例 |
| --- | --- | --- | --- |
| 堆 / 容器 | `new` | `deinit` | `vec.new` / `vec.deinit` |
| OS 句柄 / 文件 | `open` / `create` | `close` | `fs.open` / `fs.close` |
| 同步原语 | `new_mutex` 等 | `free_mutex` 等 | 未来子模块 `mtx.lock()` |
| Arena | `arena_init` | `arena_deinit` | `heap.arena64_init` |
| 超时 / 取消 | — | — | `read_ctx`（`_ctx` 表 Context 语义） |

---

## 二、规则汇总

1. 去模块前缀（`io_` `net_` `fs_` `sio_` …）
2. **去函数名中所有标量类型 token**（任意位置的 `_i32` `_u32` …）
3. 标量仅类型不同 → 函数重载，不拆函数
4. 参数位数仅不同（如 `_2`/`_3`）→ 合并为同名函数，靠重载区分
5. 容器单态化 → 方法名不含类型（`Vec_i32.push` 未来语法，现为 `push(&vec_i32, …)`）
6. 动词对齐 Rust/Go（`starts_with` `extend` `contains_key`）
7. **三轮精简**：绑定 import 后去模块内冗余前缀；`_with_timeout` 并入 `timeout_ms` 参数；`_with_allocator` 并入容器 `.al` 字段
8. **Tier 分级**：Tier-S 日常 export；Tier-A 性能/协议路径；Tier-X（`*_smoke` / `lock_diag_*`）**不 export**

### 推荐绑定名（顶层）

- `std.compress` → `compress`
- `std.datetime` → `dt`
- `std.encoding` → `enc`
- `std.error` → `err`
- `std.socketio` → `socket`
- `std.string` → `str`
- `std.websocket` → `ws`
- 其余 → 模块短名

### 推荐绑定名（大模块子路径 — 避免超长函数名）

| 导入路径 | 绑定名 | 典型调用 |
| --- | --- | --- |
| `std.http.h2` / client 子模块 | `h2` / `hcli` | `hcli.parallel_get(urls)` |
| `std.sync.mutex` | `mtx` | `mtx.lock()` |
| `std.sync.rwlock` | `rw` | `rw.read_lock()` |
| `std.io.async` | `aio` | `aio.read(fd, buf)` |
| `std.random.prng` | `prng` | `prng.seed(42)` |

---

## 三、各模块 API 清单

### std.async

`std/async/mod.sx` · 125 APIs · `const async = import("std.async")`


| 当前名称                              | 功能说明                                                                                                                                         | 简化名称                        | 说明             | 绑定调用                                   |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------------- | -------------------------------------- |
| `wait_completion`                 | —                                                                                                                                            | `wait_completion`           | 已符合命名          | `async.wait_completion(...)`           |
| `submit_read_sync`                | —                                                                                                                                            | `submit_read_sync`          | 已符合命名          | `async.submit_read_sync(...)`          |
| `submit_write_sync`               | —                                                                                                                                            | `submit_write_sync`         | 已符合命名          | `async.submit_write_sync(...)`         |
| `shux_async_coop_pingpong`        | ─── A1/A2 协作调度（scheduler_glue.c）：无栈 ping-pong bench ───                                                                                      | `coop_pingpong`             | 去模块前缀+去类型名     | `async.coop_pingpong(...)`             |
| `shux_async_coop_pingpong_jmp`    | extern C/平台                                                                                                                                  | `coop_pingpong_jmp`         | 去模块前缀+去类型名     | `async.coop_pingpong_jmp(...)`         |
| `shux_async_cps_suspend`          | ─── A3 CPS suspend/resume（scheduler_glue.c；SHUX_ASYNC_YIELD=1 时 await 边界 yield）───                                                           | `cps_suspend`               | 去模块前缀+去类型名     | `async.cps_suspend(...)`               |
| `shux_async_cps_suspend_io`       | IO-A5：await IO 边界 suspend；yield 时进 IO 等待队列。                                                                                                  | `cps_suspend_io`            | 去模块前缀+去类型名     | `async.cps_suspend_io(...)`            |
| `shux_async_run_i32`              | extern C/平台                                                                                                                                  | `run`                       | 去模块前缀+去类型名     | `async.run(...)`                       |
| `shux_async_spawn_i32`            | IO-A5 v5：push seed 并 submit 协程（spawn C 侧等价）。                                                                                             | `submit`                    | 与 task_submit 合并为 submit 重载（fn, seed）；`spawn` 为语言关键字     | `async.submit(fn, seed)`                     |
| `shux_async_run_drain_until_idle` | IO-A5 v4：poll + drain 直至就绪环与 IO 等待队列皆空；返回已完成任务结果之和。 | `drain_idle` | 去模块前缀+去类型名；三轮精简 | `async.drain_idle(...)` |
| `shux_async_run_seed_reset`       | run v4：实参 seed 队列（i32/u32/i64/usize）。                                                                                                        | `run_seed_reset`            | 去模块前缀+去类型名     | `async.run_seed_reset(...)`            |
| `shux_async_run_seed_push_i32`    | extern C/平台                                                                                                                                  | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shux_async_run_seed_push_u32`    | extern C/平台                                                                                                                                  | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shux_async_run_seed_push_i64`    | extern C/平台                                                                                                                                  | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shux_async_run_seed_push_usize`  | extern C/平台                                                                                                                                  | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shux_async_run_seed_set_i32`     | run v1 兼容：单 i32 实参 seed。                                                                                                                     | `run_seed_set`              | 去模块前缀+去类型名     | `async.run_seed_set(...)`              |
| `shux_async_run_seed_valid`       | extern C/平台                                                                                                                                  | `run_seed_valid`            | 去模块前缀+去类型名     | `async.run_seed_valid(...)`            |
| `shux_async_run_seed_take_i32`    | extern C/平台                                                                                                                                  | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shux_async_run_seed_take_u32`    | extern C/平台                                                                                                                                  | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shux_async_run_seed_take_i64`    | extern C/平台                                                                                                                                  | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shux_async_run_seed_take_usize`  | extern C/平台                                                                                                                                  | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shux_async_task_submit` | ─── A4 就绪队列（MPSC ring；per-worker 环 + worker_drain）─── DOD-CL-S2：C 侧 shux_async_task_queue_t 已 align(64) head/tail/slots（见 scheduler_glue.c）。 | `submit` | 去模块前缀+去类型名；三轮精简 | `async.submit(...)` |
| `shux_async_task_submit_to`       | 提交到指定 worker 环（0..worker_count-1）。                                                                                                           | `task_submit_to`            | 去模块前缀+去类型名     | `async.task_submit_to(...)`            |
| `shux_async_scheduler_drain`      | extern C/平台                                                                                                                                  | `scheduler_drain`           | 去模块前缀+去类型名     | `async.scheduler_drain(...)`           |
| `shux_async_worker_drain`         | 单 worker consumer drain（A4 v2 多 consumer）。                                                                                                   | `worker_drain`              | 去模块前缀+去类型名     | `async.worker_drain(...)`              |
| `shux_async_worker_count` | extern C/平台 | `workers` | 去模块前缀+去类型名；三轮精简 | `async.workers(...)` |
| `shux_async_worker_pending` | extern C/平台 | `pending` | 去模块前缀+去类型名；三轮精简 | `async.pending(...)` |
| `shux_async_queue_reset`          | extern C/平台                                                                                                                                  | `queue_reset` | 去模块前缀+去类型名 | `async.queue_reset(...)` |
| `shux_async_scheduler_pending` | extern C/平台 | `pending` | 去模块前缀+去类型名；三轮精简 | `async.pending(...)` |
| `shux_async_io_wake_all`          | extern C/平台                                                                                                                                  | `io_wake_all`               | 去模块前缀+去类型名     | `async.io_wake_all(...)`               |
| `shux_async_io_waiters_pending`   | extern C/平台                                                                                                                                  | `waiters_pending`           | 去模块前缀+去类型名     | `async.waiters_pending(...)`           |
| `shux_io_poll_async_completions` | IO-A5 v3：poll io_uring CQE（未链 io.o 时为 weak 桩）。 | `poll_completions` | 去模块前缀+去类型名；三轮精简 | `async.poll_completions(...)` |
| `shux_async_bind_context_c` | ─── STD-090/093：Context 绑定与取消传播（scheduler_glue.c ctx_slots）─── | `bind_ctx` | 去模块前缀+去类型名（C层） | `async.bind_ctx(...)` |
| `shux_async_unbind_context_c` | extern C/平台 | `unbind_ctx` | 去模块前缀+去类型名（C层） | `async.unbind_ctx(...)` |
| `shux_async_current_context_c` | extern C/平台 | `current_ctx` | 去模块前缀+去类型名（C层） | `async.current_ctx(...)` |
| `shux_async_task_submit_with_ctx` | extern C/平台 | `submit_ctx` | 去模块前缀+去类型名；三轮精简 | `async.submit_ctx(...)` |
| `shux_async_spawn_ctx_smoke_c` | extern C/平台 | `spawn_ctx_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `async.spawn_ctx_smoke(...)` |
| `async_err_ctx_abort`             | 返回 Context 取消时 drain 的错误码。                                                                                                                   | `err_ctx_abort`             | 去模块前缀+去类型名     | `async.err_ctx_abort(...)`             |
| `bind_context` | 绑定 Context 到当前 async 运行时（spawn/drain 取消传播）。 | `bind_ctx` | 三轮精简 | `async.bind_ctx(...)` |
| `unbind_context` | 弹出最近一次 bind_context。 | `unbind_ctx` | 三轮精简 | `async.unbind_ctx(...)` |
| `current_context` | 返回当前绑定的 Context 句柄；未绑定返回 0。 | `current_ctx` | 三轮精简 | `async.current_ctx(...)` |
| `runtime_new` | 创建带默认 Context 的 AsyncRuntime。 | `runtime` | 三轮精简 | `async.runtime(...)` |
| `runtime_reset` | 重置就绪环/seed 并重新绑定 runtime 的 Context。 | `runtime_reset` | 三轮精简：保留 runtime 前缀 | `async.runtime_reset(...)` |
| `runtime_drain` | drain 直至空闲；Context 已取消时返回 async_err_ctx_abort()。 | `drain` | 三轮精简 | `async.drain(...)` |
| `task_submit` | 提交 async 任务到就绪环；0 成功。 | `submit` | 三轮精简 | `async.submit(...)` |
| `task_submit_with_context` | 提交任务并绑定 Context；ctx 已取消时返回 -2。 | `submit_ctx` | 三轮精简 | `async.submit_ctx(...)` |
| `spawn_context_smoke` | STD-093：spawn 自动继承 bind_context 烟测；0 通过。 | `spawn_ctx_smoke` | 已符合命名；Tier-X 不 export | `async.spawn_ctx_smoke(...)` |
| `scheduler_reset` | 清空就绪环与 IO 等待队列（保留 run seed 时见 shux_async_queue_reset_impl）。 | `scheduler_reset` | 三轮精简 | `async.scheduler_reset(...)` |
| `drain_until_idle` | poll + drain 直至就绪环与 IO 等待队列皆空。 | `drain_idle` | 三轮精简 | `async.drain_idle(...)` |
| `cps_suspend_io`                  | await IO 边界 suspend 门面。                                                                                                                      | `cps_suspend_io`            | 已符合命名          | `async.cps_suspend_io(...)`            |
| `poll_io_completions` | poll io_uring completion 并唤醒 IO 等待任务。 | `poll_completions` | 三轮精简 | `async.poll_completions(...)` |
| `io_uring_is_available` | 当前线程 io_uring 是否可用；1 是，0 否（非 Linux 恒 0）。 | `uring_ok` | 语义重命名；三轮精简 | `async.uring_ok(...)` |
| `read_async`                      | 提交非阻塞 read；成功返回 slot>=0，失败 -1。                                                                                                               | `read_async`                | 已符合命名          | `async.read_async(...)`                |
| `write_async`                     | 提交非阻塞 write；成功返回 slot>=0，失败 -1。                                                                                                              | `write_async`               | 已符合命名          | `async.write_async(...)`               |
| `read_async_fd`                   | 按 fd 提交非阻塞 read（handle=fd）。                                                                                                                  | `read_async_fd`             | 已符合命名          | `async.read_async_fd(...)`             |
| `write_async_fd`                  | 按 fd 提交非阻塞 write（handle=fd）。                                                                                                                 | `write_async_fd`            | 已符合命名          | `async.write_async_fd(...)`            |
| `complete_read_async_slot` | 收割指定 slot 的 read_async；未就绪返回 IO_ASYNC_NOT_READY。 | `complete_read` | 三轮精简 | `async.complete_read(...)` |
| `complete_write_async_slot` | 收割指定 slot 的 write_async；未就绪返回 IO_ASYNC_NOT_READY。 | `complete_write` | 三轮精简 | `async.complete_write(...)` |
| `io_pump_once` | 单轮 IO pump：poll CQE + drain 就绪环/IO 等待队列；返回 drain 结果。 | `pump` | 语义重命名；三轮精简 | `async.pump(...)` |
| `io_timeout_ms_from_ctx` | — | `timeout_from_ctx` | 三轮精简 | `async.timeout_from_ctx(...)` |
| `io_ctx_check` | IO pump 前检查 Context；0 可继续，否则 net_err_cancelled/timeout。 | `ctx_check` | 三轮精简 | `async.ctx_check(...)` |
| `await_read_fd`                   | —                                                                                                                                            | `await_read_fd`             | 已符合命名          | `async.await_read_fd(...)`             |
| `await_write_fd`                  | —                                                                                                                                            | `await_write_fd`            | 已符合命名          | `async.await_write_fd(...)`            |
| `net_read_async`                  | net TcpStream fd 异步读（await_read_fd 别名，语义同 std.io read_async_fd + poll）。                                                                      | `net_read_async`            | 已符合命名          | `async.net_read_async(...)`            |
| `net_write_async`                 | net TcpStream fd 异步写（await_write_fd 别名）。                                                                                                     | `net_write_async`           | 已符合命名          | `async.net_write_async(...)`           |
| `fs_read_async`                   | fs 已打开 fd 异步读（await_read_fd 别名）。                                                                                                             | `fs_read_async`             | 已符合命名          | `async.fs_read_async(...)`             |
| `fs_write_async`                  | fs 已打开 fd 异步写（await_write_fd 别名）。                                                                                                            | `fs_write_async`            | 已符合命名          | `async.fs_write_async(...)`            |
| `shux_async_net_fs_smoke_c` | extern C/平台 | `net_fs_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `async.net_fs_smoke(...)` |
| `net_fs_async_smoke` | async net/fs fd 路径 C 烟测（pipe 模拟）；0 通过。 | `net_fs_async_smoke` | 已符合命名；Tier-X 不 export | `async.net_fs_async_smoke(...)` |
| `io_waiters_pending` | IO 等待队列深度。 | `waiters` | 语义重命名；三轮精简 | `async.waiters(...)` |
| `shux_async_future_create_c` | extern C/平台 | `future_create` | 去模块前缀+去类型名（C层） | `async.future_create(...)` |
| `shux_async_future_poll_c` | extern C/平台 | `future_poll` | 去模块前缀+去类型名（C层） | `async.future_poll(...)` |
| `shux_async_future_complete_c` | extern C/平台 | `future_complete` | 去模块前缀+去类型名（C层） | `async.future_complete(...)` |
| `shux_async_future_take_c` | extern C/平台 | `future_take` | 去模块前缀+去类型名（C层） | `async.future_take(...)` |
| `shux_async_future_reset_c` | extern C/平台 | `future_reset` | 去模块前缀+去类型名（C层） | `async.future_reset(...)` |
| `shux_async_future_wait_c` | extern C/平台 | `future_wait` | 去模块前缀+去类型名（C层） | `async.future_wait(...)` |
| `shux_async_future_smoke_c` | extern C/平台 | `future_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `async.future_smoke(...)` |
| `poll_pending`                    | 返回 Poll::Pending 常量。                                                                                                                         | `poll_pending`              | 已符合命名          | `async.poll_pending(...)`              |
| `poll_ready`                      | 返回 Poll::Ready 常量。                                                                                                                           | `poll_ready`                | 已符合命名          | `async.poll_ready(...)`                |
| `future_new` | 创建 pending Future；池满时 handle=0。 | `new` | 三轮精简 | `async.new(...)` |
| `future_poll`                     | —                                                                                                                                            | `future_poll`               | 已符合命名          | `async.future_poll(...)`               |
| `future_complete`                 | 完成 Future 并写入 i32 结果。                                                                                                                        | `future_complete`           | 已符合命名          | `async.future_complete(...)`           |
| `future_take`                     | —                                                                                                                                            | `future_take`               | 已符合命名          | `async.future_take(...)`               |
| `future_reset` | 重置 Future 池（烟测/同进程二次 poll）。 | `future_reset` | 三轮精简 | `async.future_reset(...)` |
| `future_smoke` | C 侧 Future 烟测；0 通过。 | `future_smoke` | 已符合命名；Tier-X 不 export | `async.future_smoke(...)` |
| `future_wait`                     | —                                                                                                                                            | `future_wait`               | 已符合命名          | `async.future_wait(...)`               |
| `runtime_wait_future` | — | `wait_future` | 三轮精简 | `async.wait_future(...)` |
| `poll_loop`                       | —                                                                                                                                            | `poll_loop`                 | 已符合命名          | `async.poll_loop(...)`                 |
| `poll_loop_ctx` | — | `poll_loop` | 三轮精简 | `async.poll_loop(...)` |
| `coop_pingpong`                   | A1：switch dispatch 双任务 ping-pong；rounds 轮返回总 ops（2*rounds）。                                                                                  | `coop_pingpong`             | 已符合命名          | `async.coop_pingpong(...)`             |
| `coop_pingpong_jmp`               | A2：computed-goto 跳转表 dispatch；语义同 coop_pingpong。                                                                                             | `coop_pingpong_jmp`         | 已符合命名          | `async.coop_pingpong_jmp(...)`         |
| `placeholder` | 模块可 import 锚点（Future/Poll 见 future_* / poll_*）。 | `placeholder` | 已符合命名；Tier-X 不 export | `async.placeholder(...)` |
| `shu_async_bind_context_c` | 绑定 Context（C 别名）。 | `bind_ctx` | 去模块前缀+去类型名（C层） | `async.bind_ctx(...)` |
| `shu_async_current_context_c` | 当前 Context 句柄（C 别名）。 | `current_context` | 去模块前缀+去类型名（C层） | `async.current_context(...)` |
| `shu_async_unbind_context_c` | 解绑 Context（C 别名）。 | `unbind_context` | 去模块前缀+去类型名（C层） | `async.unbind_context(...)` |
| `shu_async_coop_pingpong`         | A1 ping-pong（C 别名）。                                                                                                                          | `coop_pingpong`             | 去模块前缀+去类型名     | `async.coop_pingpong(...)`             |
| `shu_async_coop_pingpong_jmp`     | A2 jmp ping-pong（C 别名）。                                                                                                                      | `coop_pingpong_jmp`         | 去模块前缀+去类型名     | `async.coop_pingpong_jmp(...)`         |
| `shu_async_cps_suspend`           | CPS suspend（C 别名）。                                                                                                                           | `cps_suspend`               | 去模块前缀+去类型名     | `async.cps_suspend(...)`               |
| `shu_async_cps_suspend_io`        | CPS suspend IO（C 别名）。                                                                                                                        | `cps_suspend_io`            | 去模块前缀+去类型名     | `async.cps_suspend_io(...)`            |
| `shu_async_run_i32`               | run i32 协程（C 别名）。                                                                                                                            | `run`                       | 去模块前缀+去类型名     | `async.run(...)`                       |
| `shu_async_spawn_i32`             | spawn seed 并 submit（C 别名）。                                                                                                                        | `submit`                    | 与 task_submit 合并为 submit 重载（fn, seed）     | `async.submit(fn, seed)`                     |
| `shu_async_run_drain_until_idle`  | drain 直至空闲（C 别名）。                                                                                                                            | `run_drain_until_idle`      | 去模块前缀+去类型名     | `async.run_drain_until_idle(...)`      |
| `shu_async_run_seed_reset`        | 重置 run seed 队列（C 别名）。                                                                                                                        | `run_seed_reset`            | 去模块前缀+去类型名     | `async.run_seed_reset(...)`            |
| `shu_async_run_seed_push_i32`     | —                                                                                                                                            | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shu_async_run_seed_push_u32`     | —                                                                                                                                            | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shu_async_run_seed_push_i64`     | —                                                                                                                                            | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shu_async_run_seed_push_usize`   | —                                                                                                                                            | `run_seed_push`             | 去模块前缀+去类型名     | `async.run_seed_push(...)`             |
| `shu_async_run_seed_set_i32`      | —                                                                                                                                            | `run_seed_set`              | 去模块前缀+去类型名     | `async.run_seed_set(...)`              |
| `shu_async_run_seed_valid`        | —                                                                                                                                            | `run_seed_valid`            | 去模块前缀+去类型名     | `async.run_seed_valid(...)`            |
| `shu_async_run_seed_take_i32`     | —                                                                                                                                            | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shu_async_run_seed_take_u32`     | —                                                                                                                                            | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shu_async_run_seed_take_i64`     | —                                                                                                                                            | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shu_async_run_seed_take_usize`   | —                                                                                                                                            | `run_seed_take`             | 去模块前缀+去类型名     | `async.run_seed_take(...)`             |
| `shu_async_task_submit` | 提交任务（C 别名）。 | `submit` | 去模块前缀+去类型名；三轮精简 | `async.submit(...)` |
| `shu_async_task_submit_with_ctx`  | 带 Context 提交（C 别名）。                                                                                                                          | `task_submit_with_ctx`      | 去模块前缀+去类型名     | `async.task_submit_with_ctx(...)`      |
| `shu_async_spawn_ctx_smoke_c` | spawn context 烟测（C 别名）。 | `spawn_ctx_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `async.spawn_ctx_smoke(...)` |
| `shu_async_task_submit_to`        | 提交到指定 worker（C 别名）。                                                                                                                          | `task_submit_to`            | 去模块前缀+去类型名     | `async.task_submit_to(...)`            |
| `shu_async_scheduler_drain`       | —                                                                                                                                            | `scheduler_drain`           | 去模块前缀+去类型名     | `async.scheduler_drain(...)`           |
| `shu_async_worker_drain`          | —                                                                                                                                            | `worker_drain`              | 去模块前缀+去类型名     | `async.worker_drain(...)`              |
| `shu_async_worker_count`          | —                                                                                                                                            | `worker_count`              | 去模块前缀+去类型名     | `async.worker_count(...)`              |
| `shu_async_worker_pending`        | —                                                                                                                                            | `worker_pending`            | 去模块前缀+去类型名     | `async.worker_pending(...)`            |
| `shu_async_queue_reset`           | —                                                                                                                                            | `queue_reset`               | 去模块前缀+去类型名     | `async.queue_reset(...)`               |
| `shu_async_scheduler_pending`     | —                                                                                                                                            | `scheduler_pending`         | 去模块前缀+去类型名     | `async.scheduler_pending(...)`         |
| `shu_async_io_wake_all`           | —                                                                                                                                            | `io_wake_all`               | 去模块前缀+去类型名     | `async.io_wake_all(...)`               |
| `shu_async_io_waiters_pending`    | —                                                                                                                                            | `waiters_pending`           | 去模块前缀+去类型名     | `async.waiters_pending(...)`           |


### std.atomic

`std/atomic/mod.sx` · 60 APIs · `const atomic = import("std.atomic")`


| 当前名称                            | 功能说明                                                                                                                               | 简化名称               | 说明             | 绑定调用                           |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------------------ | -------------- | ------------------------------ |
| `atomic_load_i32_c` | std.atomic — 原子操作（对标 Rust std::sync::atomic、Zig std.atomic） 【文件职责】load/store、compare_exchange、fetch_add/sub（i32/u32/i64/u64）；顺序一致� | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_i32_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_compare_exchange_i32_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `atomic_fetch_add_i32_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `atomic_fetch_sub_i32_c` | extern C/平台 | `fetch_sub` | 去模块前缀+去类型名（C层） | `atomic.fetch_sub(...)` |
| `atomic_load_u32_c` | extern C/平台 | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_u32_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_compare_exchange_u32_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `atomic_fetch_add_u32_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `atomic_load_i64_c` | extern C/平台 | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_i64_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_load_u64_c` | extern C/平台 | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_u64_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_fetch_add_i64_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `load_i32`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_i32`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `compare_exchange_i32`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |
| `fetch_add_i32`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `fetch_sub_i32`                 | —                                                                                                                                  | `fetch_sub`        | 去模块前缀+去类型名     | `atomic.fetch_sub(...)`        |
| `load_u32`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_u32`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `compare_exchange_u32`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |
| `fetch_add_u32`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `load_i64`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_i64`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `load_u64`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_u64`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `fetch_add_i64`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `atomic_fence_seq_cst_c` | extern C/平台 | `fence_seq_cst` | 去模块前缀+去类型名（C层） | `atomic.fence_seq_cst(...)` |
| `atomic_fence_acquire_c` | extern C/平台 | `fence_acquire` | 去模块前缀+去类型名（C层） | `atomic.fence_acquire(...)` |
| `atomic_fence_release_c` | extern C/平台 | `fence_release` | 去模块前缀+去类型名（C层） | `atomic.fence_release(...)` |
| `fence_seq_cst`                 | 全序内存栅栏。                                                                                                                            | `fence_seq_cst`    | 已符合命名          | `atomic.fence_seq_cst(...)`    |
| `fence_acquire`                 | 获取侧内存栅栏。                                                                                                                           | `fence_acquire`    | 已符合命名          | `atomic.fence_acquire(...)`    |
| `fence_release`                 | 释放侧内存栅栏。                                                                                                                           | `fence_release`    | 已符合命名          | `atomic.fence_release(...)`    |
| `atomic_load_i16_c` | extern C/平台 | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_i16_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_fetch_add_i16_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `atomic_compare_exchange_i16_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `atomic_load_u16_c` | extern C/平台 | `load` | 去模块前缀+去类型名（C层） | `atomic.load(...)` |
| `atomic_store_u16_c` | extern C/平台 | `store` | 去模块前缀+去类型名（C层） | `atomic.store(...)` |
| `atomic_fetch_add_u16_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `atomic_compare_exchange_u16_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `atomic_compare_exchange_i64_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `atomic_fetch_sub_i64_c` | extern C/平台 | `fetch_sub` | 去模块前缀+去类型名（C层） | `atomic.fetch_sub(...)` |
| `atomic_fetch_add_u64_c` | extern C/平台 | `fetch_add` | 去模块前缀+去类型名（C层） | `atomic.fetch_add(...)` |
| `atomic_fetch_sub_u64_c` | extern C/平台 | `fetch_sub` | 去模块前缀+去类型名（C层） | `atomic.fetch_sub(...)` |
| `atomic_compare_exchange_u64_c` | extern C/平台                                                                                                                        | `compare_exchange` | 去模块前缀+去类型名（C层） | `atomic.compare_exchange(...)` |
| `load_i16`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_i16`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `fetch_add_i16`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `compare_exchange_i16`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |
| `load_u16`                      | —                                                                                                                                  | `load`             | 去模块前缀+去类型名     | `atomic.load(...)`             |
| `store_u16`                     | —                                                                                                                                  | `store`            | 去模块前缀+去类型名     | `atomic.store(...)`            |
| `fetch_add_u16`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `compare_exchange_u16`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |
| `compare_exchange_i64`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |
| `fetch_sub_i64`                 | —                                                                                                                                  | `fetch_sub`        | 去模块前缀+去类型名     | `atomic.fetch_sub(...)`        |
| `fetch_add_u64`                 | —                                                                                                                                  | `fetch_add`        | 去模块前缀+去类型名     | `atomic.fetch_add(...)`        |
| `fetch_sub_u64`                 | —                                                                                                                                  | `fetch_sub`        | 去模块前缀+去类型名     | `atomic.fetch_sub(...)`        |
| `compare_exchange_u64`          | —                                                                                                                                  | `compare_exchange` | 去模块前缀+去类型名     | `atomic.compare_exchange(...)` |


### std.backtrace

`std/backtrace/mod.sx` · 6 APIs · `const backtrace = import("std.backtrace")`


| 当前名称                            | 功能说明                                                                                     | 简化名称                     | 说明             | 绑定调用                                    |
| ------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------ | -------------- | --------------------------------------- |
| `backtrace_capture_c` | std.backtrace — 调用栈捕获（对标 Rust std::backtrace） 【文件职责】capture 将当前栈帧写入 buf（每帧 sizeof(void*) | `capture` | 去模块前缀+去类型名（C层） | `backtrace.capture(...)` |
| `backtrace_symbolicate_c` | extern C/平台 | `symbolicate` | 去模块前缀+去类型名（C层） | `backtrace.symbolicate(...)` |
| `capture`                       | —                                                                                        | `capture`                | 已符合命名          | `backtrace.capture(...)`                |
| `symbolicate`                   | —                                                                                        | `symbolicate`            | 已符合命名          | `backtrace.symbolicate(...)`            |
| `shux_crash_evidence_collect_c` | SAFE-007：收集崩溃证据（须环境变量 SHUX_CRASH_EVIDENCE=1；可选 SHUX_CRASH_EVIDENCE_DIR 落盘）。              | `crash_evidence_collect` | 去模块前缀+去类型名（C层） | `backtrace.crash_evidence_collect(...)` |
| `collect_crash_evidence`        | 手动或 panic 路径登记证据；has_msg 非 0 时 msg_val 为消息码。                                             | `collect_crash_evidence` | 已符合命名          | `backtrace.collect_crash_evidence(...)` |


### std.base64

`std/base64/mod.sx` · 18 APIs · `const base64 = import("std.base64")`


| 当前名称                          | 功能说明                                                                                                       | 简化名称              | 说明             | 绑定调用                          |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------- | ----------------- | -------------- | ----------------------------- |
| `base64_encode_standard_c` | std.base64 — Base64 编解码（标准/URL 变体，单遍无分配，对标 Zig std.base64） 【文件职责】encode/decode standard 与 URL；单遍、静态表、无堆分配。 | `encode_standard` | 去模块前缀+去类型名（C层） | `base64.encode_standard(...)` |
| `base64_encode_url_c` | extern C/平台 | `encode_url` | 去模块前缀+去类型名（C层） | `base64.encode_url(...)` |
| `base64_decode_standard_c` | extern C/平台 | `decode_standard` | 去模块前缀+去类型名（C层） | `base64.decode_standard(...)` |
| `base64_decode_url_c` | extern C/平台 | `decode_url` | 去模块前缀+去类型名（C层） | `base64.decode_url(...)` |
| `encode_standard`             | 标准 Base64 编码；返回写入字节数，缓冲区不足返回 -1。                                                                           | `encode_standard` | 已符合命名          | `base64.encode_standard(...)` |
| `encode_url`                  | URL 安全 Base64 编码（无填充）；返回写入字节数。                                                                             | `encode_url`      | 已符合命名          | `base64.encode_url(...)`      |
| `decode_standard`             | 标准 Base64 解码；返回写入 out 的字节数，非法输入返回 -1。                                                                      | `decode_standard` | 已符合命名          | `base64.decode_standard(...)` |
| `decode_url`                  | URL 变体解码；返回写入字节数，非法返回 -1。                                                                                  | `decode_url`      | 已符合命名          | `base64.decode_url(...)`      |
| `base64_stream_state_bytes_c` | extern C/平台 | `state_bytes` | 去模块前缀+去类型名（C层） | `base64.state_bytes(...)` |
| `base64_stream_enc_init_c` | extern C/平台 | `enc_init` | 去模块前缀+去类型名（C层） | `base64.enc_init(...)` |
| `base64_stream_dec_init_c` | extern C/平台 | `dec_init` | 去模块前缀+去类型名（C层） | `base64.dec_init(...)` |
| `base64_stream_enc_update_c` | extern C/平台 | `enc_update` | 去模块前缀+去类型名（C层） | `base64.enc_update(...)` |
| `base64_stream_dec_update_c` | extern C/平台 | `dec_update` | 去模块前缀+去类型名（C层） | `base64.dec_update(...)` |
| `stream_state_bytes`          | 流状态缓冲最小字节数（STD-109）。                                                                                       | `state_bytes`     | 二次精简：去对象前缀     | `base64.state_bytes(...)`     |
| `stream_enc_init`             | 初始化 Base64 编码流；url 非 0 为 URL 变体。                                                                           | `enc_init`        | 二次精简：去对象前缀     | `base64.enc_init(...)`        |
| `stream_dec_init`             | 初始化 Base64 解码流。                                                                                            | `dec_init`        | 二次精简：去对象前缀     | `base64.dec_init(...)`        |
| `stream_enc_update`           | 流式 Base64 编码 update；is_last=1 时 flush padding。                                                             | `enc_update`      | 二次精简：去对象前缀     | `base64.enc_update(...)`      |
| `stream_dec_update`           | 流式 Base64 解码 update；is_last=1 时 flush 尾部。                                                                  | `dec_update`      | 二次精简：去对象前缀     | `base64.dec_update(...)`      |


### std.bytes

`std/bytes/mod.sx` · 28 APIs · `const bytes = import("std.bytes")`


| 当前名称                          | 功能说明                                           | 简化名称                          | 说明         | 绑定调用                                     |
| ----------------------------- | ---------------------------------------------- | ----------------------------- | ---------- | ---------------------------------------- |
| `bytes_default_capacity`      | 默认初始容量（字节）。                                    | `default_capacity`            | 去模块前缀+去类型名 | `bytes.default_capacity(...)`            |
| `bytes_new`                   | 新建空 Bytes（堆拥有，尚未分配）。                           | `new`                         | 去模块前缀+去类型名 | `bytes.new(...)`                         |
| `bytes_from_external`         | —                                              | `from_external`               | 去模块前缀+去类型名 | `bytes.from_external(...)`               |
| `bytes_is_owned`              | 返回 1 若 Bytes 拥有堆内存，0 若为外部/Arena 绑定。            | `is_owned`                    | 去模块前缀+去类型名 | `bytes.is_owned(...)`                    |
| `recommend_bytes_alloc`       | —                                              | `recommend_bytes_alloc`       | 已符合命名      | `bytes.recommend_bytes_alloc(...)`       |
| `recommend_bytes_alloc_arena` | Arena 批处理路径常量（与 `recommend_bytes_alloc` 对照文档）。 | `recommend_bytes_alloc_arena` | 已符合命名      | `bytes.recommend_bytes_alloc_arena(...)` |
| `bytes_with_capacity`         | 预分配容量；失败返回 -1。外部绑定 Bytes 不可扩容。                 | `with_capacity`               | 去模块前缀+去类型名 | `bytes.with_capacity(...)`               |
| `bytes_reserve_one`           | 确保至少再追加 1 字节容量；不足则 2 倍扩容（外部绑定不可扩容）。            | `reserve_one`                 | 去模块前缀+去类型名 | `bytes.reserve_one(...)`                 |
| `bytes_reserve`               | 确保容量至少 new_cap；失败 -1（外部绑定且 new_cap > cap 时失败）。 | `reserve`                     | 去模块前缀+去类型名 | `bytes.reserve(...)`                     |
| `bytes_grow`                  | 扩容至至少 len+extra（大块 append 前调用）。                | `grow`                        | 去模块前缀+去类型名 | `bytes.grow(...)`                        |
| `bytes_append_byte`           | 追加单字节；0 成功，-1 失败。                              | `append_byte`                 | 去模块前缀+去类型名 | `bytes.append_byte(...)`                 |
| `bytes_append_slice` | 追加切片；0 成功，-1 失败。 | `extend` | 去模块前缀+去类型名；三轮精简 | `bytes.extend(...)` |
| `bytes_from_slice`            | 从切片构造 Bytes（拷贝）。                               | `from_slice`                  | 去模块前缀+去类型名 | `bytes.from_slice(...)`                  |
| `bytes_len`                   | 当前长度。                                          | `len`                         | 去模块前缀+去类型名 | `bytes.len(...)`                         |
| `bytes_capacity`              | 当前容量。                                          | `capacity`                    | 去模块前缀+去类型名 | `bytes.capacity(...)`                    |
| `bytes_clear`                 | 清空长度，不释放内存。                                    | `clear`                       | 去模块前缀+去类型名 | `bytes.clear(...)`                       |
| `bytes_deinit`                | 释放堆内存；外部/Arena 绑定仅清零字段，不 free ptr。             | `deinit`                      | 去模块前缀+去类型名 | `bytes.deinit(...)`                      |
| `bytes_as_view`               | 零拷贝 StrView（生命周期不超过 Bytes 存活期）。                | `as_view`                     | 去模块前缀+去类型名 | `bytes.as_view(...)`                     |
| `bytes_from_view`             | 从 StrView 拷贝构造 Bytes。                          | `from_view`                   | 去模块前缀+去类型名 | `bytes.from_view(...)`                   |
| `bytes_as_buffer`             | 转为 std.mem.Buffer（IO 桥接；handle=0）。             | `as_buffer`                   | 去模块前缀+去类型名 | `bytes.as_buffer(...)`                   |
| `reader_new`                  | 构造读游标。                                         | `new`                         | 二次精简：去对象前缀 | `bytes.new(...)`                         |
| `reader_read`                 | 读至多 n 字节到 out；返回实际读取数。                         | `read`                        | 二次精简：去对象前缀 | `bytes.read(...)`                        |
| `reader_remaining`            | 读游标剩余可读字节数。                                    | `remaining`                   | 二次精简：去对象前缀 | `bytes.remaining(...)`                   |
| `reader_seek`                 | 设置读位置；越界返回 -1。                                 | `seek`                        | 二次精简：去对象前缀 | `bytes.seek(...)`                        |
| `writer_new`                  | 构造写游标（追加模式）。                                   | `new`                         | 二次精简：去对象前缀 | `bytes.new(...)`                         |
| `writer_write`                | 写入 n 字节；0 成功，-1 失败。                            | `write`                       | 二次精简：去对象前缀 | `bytes.write(...)`                       |
| `writer_remaining_cap`        | 写游标剩余可写容量（cap - len）。                          | `remaining_cap`               | 二次精简：去对象前缀 | `bytes.remaining_cap(...)`               |
| `bytes_eq`                    | —                                              | `eq`                          | 去模块前缀+去类型名 | `bytes.eq(...)`                          |


### std.cache

`std/cache/mod.sx` · 35 APIs · `const cache = import("std.cache")`


| 当前名称                          | 功能说明                                | 简化名称                | 说明             | 绑定调用                           |
| ----------------------------- | ----------------------------------- | ------------------- | -------------- | ------------------------------ |
| `cache_err_ok`                | 成功。                                 | `err_ok`            | 去模块前缀+去类型名     | `cache.err_ok(...)`            |
| `cache_err_null`              | 空指针/非法句柄。                           | `err_null`          | 去模块前缀+去类型名     | `cache.err_null(...)`          |
| `cache_err_not_found`         | 未命中或无可用资源。                          | `err_not_found`     | 去模块前缀+去类型名     | `cache.err_not_found(...)`     |
| `cache_err_full`              | 容量已满。                               | `err_full`          | 去模块前缀+去类型名     | `cache.err_full(...)`          |
| `cache_err_invalid`           | 参数非法或重复。                            | `err_invalid`       | 去模块前缀+去类型名     | `cache.err_invalid(...)`       |
| `cache_lru_create_c` | extern C/平台 | `lru_create` | 去模块前缀+去类型名（C层） | `cache.lru_create(...)` |
| `cache_lru_free_c` | extern C/平台 | `lru_free` | 去模块前缀+去类型名（C层） | `cache.lru_free(...)` |
| `cache_lru_get_c` | extern C/平台 | `lru_get` | 去模块前缀+去类型名（C层） | `cache.lru_get(...)` |
| `cache_lru_put_c` | extern C/平台 | `lru_put` | 去模块前缀+去类型名（C层） | `cache.lru_put(...)` |
| `cache_lru_remove_c` | extern C/平台 | `lru_remove` | 去模块前缀+去类型名（C层） | `cache.lru_remove(...)` |
| `cache_lru_purge_expired_c` | extern C/平台 | `lru_purge_expired` | 去模块前缀+去类型名（C层） | `cache.lru_purge_expired(...)` |
| `cache_lru_stats_c` | extern C/平台 | `lru_stats` | 去模块前缀+去类型名（C层） | `cache.lru_stats(...)` |
| `cache_pool_create_c` | extern C/平台 | `create` | 二次精简：去对象前缀 | `cache.create(...)` |
| `cache_pool_free_c` | extern C/平台 | `free` | 二次精简：去对象前缀 | `cache.free(...)` |
| `cache_pool_add_c` | extern C/平台 | `add` | 二次精简：去对象前缀 | `cache.add(...)` |
| `cache_pool_acquire_c` | extern C/平台 | `acquire` | 二次精简：去对象前缀 | `cache.acquire(...)` |
| `cache_pool_release_c` | extern C/平台 | `release` | 二次精简：去对象前缀 | `cache.release(...)` |
| `cache_pool_mark_unhealthy_c` | extern C/平台 | `mark_unhealthy` | 二次精简：去对象前缀 | `cache.mark_unhealthy(...)` |
| `cache_pool_idle_c` | extern C/平台 | `idle` | 二次精简：去对象前缀 | `cache.idle(...)` |
| `cache_pool_stats_c` | extern C/平台 | `stats` | 二次精简：去对象前缀 | `cache.stats(...)` |
| `lru_new`                     | 创建 LRU 缓存；capacity 默认上限 64。         | `lru_new`           | 已符合命名          | `cache.lru_new(...)`           |
| `lru_free`                    | 释放 LRU 缓存。                          | `lru_free`          | 已符合命名          | `cache.lru_free(...)`          |
| `lru_get`                     | LRU 读取；未命中返回 cache_err_not_found()。 | `lru_get`           | 已符合命名          | `cache.lru_get(...)`           |
| `lru_put`                     | LRU 写入；ttl_ns=0 表示永不过期。             | `lru_put`           | 已符合命名          | `cache.lru_put(...)`           |
| `lru_remove`                  | 删除键。                                | `lru_remove`        | 已符合命名          | `cache.lru_remove(...)`        |
| `lru_purge_expired`           | 惰性清理过期条目；返回删除数。                     | `lru_purge_expired` | 已符合命名          | `cache.lru_purge_expired(...)` |
| `lru_stats`                   | 读取 LRU 统计。                          | `lru_stats`         | 已符合命名          | `cache.lru_stats(...)`         |
| `pool_new`                    | 创建对象池。                              | `new`               | 二次精简：去对象前缀     | `cache.new(...)`               |
| `pool_free`                   | 释放对象池。                              | `free`              | 二次精简：去对象前缀     | `cache.free(...)`              |
| `pool_add`                    | 注册空闲资源到池。                           | `add`               | 二次精简：去对象前缀     | `cache.add(...)`               |
| `pool_acquire`                | 获取空闲健康资源。                           | `acquire`           | 二次精简：去对象前缀     | `cache.acquire(...)`           |
| `pool_release`                | 归还资源；不健康资源会被丢弃。                     | `release`           | 二次精简：去对象前缀     | `cache.release(...)`           |
| `pool_mark_unhealthy`         | 标记资源不健康。                            | `mark_unhealthy`    | 二次精简：去对象前缀     | `cache.mark_unhealthy(...)`    |
| `pool_idle`                   | 当前空闲资源数。                            | `idle`              | 二次精简：去对象前缀     | `cache.idle(...)`              |
| `pool_stats`                  | 读取对象池统计。                            | `stats`             | 二次精简：去对象前缀     | `cache.stats(...)`             |


### std.channel

`std/channel/mod.sx` · 51 APIs · `const channel = import("std.channel")`


| 当前名称                           | 功能说明                                              | 简化名称                  | 说明             | 绑定调用                               |
| ------------------------------ | ------------------------------------------------- | --------------------- | -------------- | ---------------------------------- |
| `channel_i32_bounded_c` | extern C/平台 | `bounded` | 去模块前缀+去类型名（C层） | `channel.bounded(...)` |
| `channel_i32_unbounded_c` | extern C/平台 | `unbounded` | 去模块前缀+去类型名（C层） | `channel.unbounded(...)` |
| `channel_i32_send_c` | extern C/平台 | `send` | 去模块前缀+去类型名（C层） | `channel.send(...)` |
| `channel_i32_recv_c` | extern C/平台 | `recv` | 去模块前缀+去类型名（C层） | `channel.recv(...)` |
| `channel_i32_try_send_c` | extern C/平台 | `try_send` | 去模块前缀+去类型名（C层） | `channel.try_send(...)` |
| `channel_i32_try_recv_c` | extern C/平台 | `try_recv` | 去模块前缀+去类型名（C层） | `channel.try_recv(...)` |
| `channel_i32_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `channel.close(...)` |
| `channel_i32_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `channel.free(...)` |
| `channel_i32_bounded`          | 创建容量为 cap 的有界 channel；失败返回 0。                     | `bounded`             | 去模块前缀+去类型名     | `channel.bounded(...)`             |
| `channel_i32_unbounded`        | 创建无界 channel；失败返回 0。                              | `unbounded`           | 去模块前缀+去类型名     | `channel.unbounded(...)`           |
| `channel_i32_send`             | 发送；有界且满时阻塞。返回 0 成功，-1 已关闭。                        | `send`                | 去模块前缀+去类型名     | `channel.send(...)`                |
| `channel_i32_recv`             | 接收；空时阻塞。返回 0 成功且 *out 有效，-1 已关闭。                  | `recv`                | 去模块前缀+去类型名     | `channel.recv(...)`                |
| `channel_i32_try_send`         | 非阻塞发送。返回 0 成功，1 满，-1 已关闭。                         | `try_send`            | 去模块前缀+去类型名     | `channel.try_send(...)`            |
| `channel_i32_try_recv`         | 非阻塞接收。返回 0 成功，1 空，-1 已关闭。                         | `try_recv`            | 去模块前缀+去类型名     | `channel.try_recv(...)`            |
| `channel_i32_close`            | 关闭 channel，唤醒阻塞的 recv。                            | `close`               | 去模块前缀+去类型名     | `channel.close(...)`               |
| `channel_i32_free`             | 释放 channel；关闭后调用。                                 | `free`                | 去模块前缀+去类型名     | `channel.free(...)`                |
| `channel_i32_is_closed_c` | extern C/平台 | `is_closed` | 去模块前缀+去类型名（C层） | `channel.is_closed(...)` |
| `send_unbounded`               | 无界 channel 发送；等同 channel_i32_send。                | `send_unbounded`      | 已符合命名          | `channel.send_unbounded(...)`      |
| `try_recv_unbounded`           | 无界 channel 非阻塞接收；等同 channel_i32_try_recv。         | `try_recv_unbounded`  | 已符合命名          | `channel.try_recv_unbounded(...)`  |
| `channel_unbounded_close`      | 关闭无界 channel。                                     | `unbounded_close`     | 去模块前缀+去类型名     | `channel.unbounded_close(...)`     |
| `channel_unbounded_is_closed`  | 无界 channel 是否已关闭；1=是，0=否。                         | `unbounded_is_closed` | 去模块前缀+去类型名     | `channel.unbounded_is_closed(...)` |
| `channel_i32_is_closed`        | 通用 channel 是否已关闭；1=是，0=否。                         | `is_closed`           | 去模块前缀+去类型名     | `channel.is_closed(...)`           |
| `channel_select_chs_set_c` | extern C/平台 | `select_chs_set` | 去模块前缀+去类型名（C层） | `channel.select_chs_set(...)` |
| `channel_select_dirs_set_c` | extern C/平台 | `select_dirs_set` | 去模块前缀+去类型名（C层） | `channel.select_dirs_set(...)` |
| `channel_select_try_recv_2_c` | extern C/平台 | `select_try_recv` | 去模块前缀+去类型名（C层） | `channel.select_try_recv(...)` |
| `channel_select_recv_2_c` | extern C/平台 | `select_recv` | 去模块前缀+去类型名（C层） | `channel.select_recv(...)` |
| `channel_select_try_recv_n_c` | extern C/平台 | `select_try_recv_n` | 去模块前缀+去类型名（C层） | `channel.select_try_recv_n(...)` |
| `channel_select_recv_n_c` | extern C/平台 | `select_recv_n` | 去模块前缀+去类型名（C层） | `channel.select_recv_n(...)` |
| `channel_select_try_send_2_c` | extern C/平台 | `select_try_send` | 去模块前缀+去类型名（C层） | `channel.select_try_send(...)` |
| `channel_select_send_2_c` | extern C/平台 | `select_send` | 去模块前缀+去类型名（C层） | `channel.select_send(...)` |
| `channel_select_try_send_n_c` | extern C/平台 | `select_try_send_n` | 去模块前缀+去类型名（C层） | `channel.select_try_send_n(...)` |
| `channel_select_send_n_c` | extern C/平台 | `select_send_n` | 去模块前缀+去类型名（C层） | `channel.select_send_n(...)` |
| `channel_select_try_mixed_2_c` | extern C/平台 | `select_try_mixed` | 去模块前缀+去类型名（C层） | `channel.select_try_mixed(...)` |
| `channel_select_mixed_2_c` | extern C/平台 | `select_mixed` | 去模块前缀+去类型名（C层） | `channel.select_mixed(...)` |
| `channel_select_try_mixed_n_c` | extern C/平台 | `select_try_mixed_n` | 去模块前缀+去类型名（C层） | `channel.select_try_mixed_n(...)` |
| `channel_select_mixed_n_c` | extern C/平台 | `select_mixed_n` | 去模块前缀+去类型名（C层） | `channel.select_mixed_n(...)` |
| `channel_select_max`           | select 最大路数（CHANNEL_SELECT_MAX）。                  | `select_max`          | 去模块前缀+去类型名     | `channel.select_max(...)`          |
| `channel_select_chs_set`       | 将 channel 句柄写入 i64 槽（64 位 LE，与 C void* 布局兼容）。     | `select_chs_set`      | 去模块前缀+去类型名     | `channel.select_chs_set(...)`      |
| `channel_select_dirs_set`      | 写入 select 方向槽（SELECT_DIR_RECV / SELECT_DIR_SEND）。 | `select_dirs_set`     | 去模块前缀+去类型名     | `channel.select_dirs_set(...)`     |
| `channel_select_try_recv_2`    | 非阻塞双路 recv；ch0 优先。返回 0 成功，1 暂无，-1 皆已关闭。           | `select_try_recv`     | 去模块前缀+去类型名     | `channel.select_try_recv(...)`     |
| `channel_select_recv_2`        | 阻塞双路 recv 直至任一路有数据。返回 0 成功，-1 皆已关闭。               | `select_recv`         | 去模块前缀+去类型名     | `channel.select_recv(...)`         |
| `channel_select_try_recv_n`    | 非阻塞 N 路 recv；index 升序优先。                          | `select_try_recv_n`   | 去模块前缀+去类型名     | `channel.select_try_recv_n(...)`   |
| `channel_select_recv_n`        | 阻塞 N 路 recv 直至任一路有数据。                             | `select_recv_n`       | 去模块前缀+去类型名     | `channel.select_recv_n(...)`       |
| `channel_select_try_send_2`    | 非阻塞双路 send；ch0 优先。返回 0 成功，1 暂满，-1 皆已关闭。           | `select_try_send`     | 去模块前缀+去类型名     | `channel.select_try_send(...)`     |
| `channel_select_send_2`        | 阻塞双路 send 直至任一路可写。                                | `select_send`         | 去模块前缀+去类型名     | `channel.select_send(...)`         |
| `channel_select_try_send_n`    | 非阻塞 N 路 send；index 升序优先。                          | `select_try_send_n`   | 去模块前缀+去类型名     | `channel.select_try_send_n(...)`   |
| `channel_select_send_n`        | 阻塞 N 路 send 直至任一路可写。                              | `select_send_n`       | 去模块前缀+去类型名     | `channel.select_send_n(...)`       |
| `channel_select_try_mixed_2`   | 非阻塞混合双路；recv 优先于 send。                            | `select_try_mixed`    | 去模块前缀+去类型名     | `channel.select_try_mixed(...)`    |
| `channel_select_mixed_2`       | 阻塞混合双路；recv 优先于 send。                             | `select_mixed`        | 去模块前缀+去类型名     | `channel.select_mixed(...)`        |
| `channel_select_try_mixed_n`   | 非阻塞 N 路混合；index 升序优先，同下标 recv 先于 send。            | `select_try_mixed_n`  | 去模块前缀+去类型名     | `channel.select_try_mixed_n(...)`  |
| `channel_select_mixed_n`       | 阻塞 N 路混合。                                         | `select_mixed_n`      | 去模块前缀+去类型名     | `channel.select_mixed_n(...)`      |


### std.cli

`std/cli/mod.sx` · 15 APIs · `const cli = import("std.cli")`


| 当前名称                | 功能说明                                                 | 简化名称              | 说明             | 绑定调用                       |
| ------------------- | ---------------------------------------------------- | ----------------- | -------------- | -------------------------- |
| `cli_is_help_c` | extern C/平台 | `is_help` | 去模块前缀+去类型名（C层） | `cli.is_help(...)` |
| `cli_is_version_c` | extern C/平台 | `is_version` | 去模块前缀+去类型名（C层） | `cli.is_version(...)` |
| `cli_match_long_c` | extern C/平台 | `match_long` | 去模块前缀+去类型名（C层） | `cli.match_long(...)` |
| `cli_match_short_c` | extern C/平台 | `match_short` | 去模块前缀+去类型名（C层） | `cli.match_short(...)` |
| `cli_write_usage_c` | extern C/平台 | `write_usage` | 去模块前缀+去类型名（C层） | `cli.write_usage(...)` |
| `cli_err_ok`        | 成功完成解析。                                              | `err_ok`          | 去模块前缀+去类型名     | `cli.err_ok(...)`          |
| `cli_err_help`      | 用户请求 --help。                                         | `err_help`        | 去模块前缀+去类型名     | `cli.err_help(...)`        |
| `cli_err_unknown`   | 未知或非法参数。                                             | `err_unknown`     | 去模块前缀+去类型名     | `cli.err_unknown(...)`     |
| `arg_len`           | 计算 C 串长度（不含 NUL）。                                    | `arg_len`         | 已符合命名          | `cli.arg_len(...)`         |
| `is_help`           | 是否为 help 选项。                                         | `is_help`         | 已符合命名          | `cli.is_help(...)`         |
| `is_version`        | 是否为 version 选项。                                      | `is_version`      | 已符合命名          | `cli.is_version(...)`      |
| `match_long`        | 匹配长选项 --name。                                        | `match_long`      | 已符合命名          | `cli.match_long(...)`      |
| `match_short`       | 匹配短选项 -x。                                            | `match_short`     | 已符合命名          | `cli.match_short(...)`     |
| `write_usage`       | 写入 usage 文本；返回长度。                                    | `write_usage`     | 已符合命名          | `cli.write_usage(...)`     |
| `parse_from_iter`   | 从 args_iter 解析（跳过 argv[0] 程序名）；expect_sub 可为空 len=0。 | `parse_from_iter` | 已符合命名          | `cli.parse_from_iter(...)` |


### std.codec

`std/codec/mod.sx` · 41 APIs · `const codec = import("std.codec")`


| 当前名称                              | 功能说明                                                         | 简化名称                              | 说明         | 绑定调用                                         |
| --------------------------------- | ------------------------------------------------------------ | --------------------------------- | ---------- | -------------------------------------------- |
| `codec_err_ok`                    | 成功（块操作返回值为写入字节数，非本常量）。                                       | `err_ok`                          | 去模块前缀+去类型名 | `codec.err_ok(...)`                          |
| `codec_err_buffer`                | 输出缓冲不足或分配失败。                                                 | `err_buffer`                      | 去模块前缀+去类型名 | `codec.err_buffer(...)`                      |
| `codec_err_input`                 | 输入非法或校验失败。                                                   | `err_input`                       | 去模块前缀+去类型名 | `codec.err_input(...)`                       |
| `codec_err_unsupported`           | 后端未链入或格式不支持。                                                 | `err_unsupported`                 | 去模块前缀+去类型名 | `codec.err_unsupported(...)`                 |
| `codec_kind_hex`                  | 十六进制（小写 ASCII）。                                              | `kind_hex`                        | 去模块前缀+去类型名 | `codec.kind_hex(...)`                        |
| `codec_kind_base64_standard`      | 标准 Base64（含填充）。                                              | `kind_base64_standard`            | 去模块前缀+去类型名 | `codec.kind_base64_standard(...)`            |
| `codec_kind_gzip`                 | gzip 块压缩（依赖 zlib）。                                           | `kind_gzip`                       | 去模块前缀+去类型名 | `codec.kind_gzip(...)`                       |
| `codec_kind_json_escape`          | JSON 字符串转义（encode-only）。                                     | `kind_json_escape`                | 去模块前缀+去类型名 | `codec.kind_json_escape(...)`                |
| `codec_kind_csv_escape`           | CSV 字段引号转义（encode-only）。                                     | `kind_csv_escape`                 | 去模块前缀+去类型名 | `codec.kind_csv_escape(...)`                 |
| `codec_kind_base64_stream`        | STD-110：Base64 流式编解码（standard/url 由 init 参数 url 选择）。         | `kind_base64_stream`              | 去模块前缀+去类型名 | `codec.kind_base64_stream(...)`              |
| `stream_mode_compress`            | 流模式：压缩。                                                      | `mode_compress`                   | 二次精简：去对象前缀 | `codec.mode_compress(...)`                   |
| `stream_mode_decompress`          | 流模式：解压。                                                      | `mode_decompress`                 | 二次精简：去对象前缀 | `codec.mode_decompress(...)`                 |
| `block_codec_new`                 | 构造块 codec。                                                   | `block_codec_new`                 | 已符合命名      | `codec.block_codec_new(...)`                 |
| `encoder_new`                     | 构造编码器。                                                       | `encoder_new`                     | 已符合命名      | `codec.encoder_new(...)`                     |
| `decoder_new`                     | 构造解码器。                                                       | `decoder_new`                     | 已符合命名      | `codec.decoder_new(...)`                     |
| `block_encode`                    | 块编码：返回写入 out 字节数，失败为负错误码。                                    | `block_encode`                    | 已符合命名      | `codec.block_encode(...)`                    |
| `block_decode`                    | 块解码：返回写入 out 字节数，失败为负错误码。                                    | `block_decode`                    | 已符合命名      | `codec.block_decode(...)`                    |
| `encoder_encode`                  | 编码器块编码。                                                      | `encoder_encode`                  | 已符合命名      | `codec.encoder_encode(...)`                  |
| `decoder_decode`                  | 解码器块解码。                                                      | `decoder_decode`                  | 已符合命名      | `codec.decoder_decode(...)`                  |
| `encode_upper_bound`              | 估算块编码输出上界（保守；失败 -1）。                                         | `encode_upper_bound`              | 已符合命名      | `codec.encode_upper_bound(...)`              |
| `encode_into_bytes`               | 编码写入 Bytes（清空后填充）；成功返回写入字节数。                                 | `encode_into_bytes`               | 已符合命名      | `codec.encode_into_bytes(...)`               |
| `decode_from_bytes`               | 从 Bytes 解码（清空后填充）；成功返回写入字节数。                                 | `decode_from_bytes`               | 已符合命名      | `codec.decode_from_bytes(...)`               |
| `stream_codec_state_bytes`        | 流状态缓冲最小字节数（gzip 与 base64 stream 取较大值）。                       | `codec_state_bytes`               | 二次精简：去对象前缀 | `codec.codec_state_bytes(...)`               |
| `stream_codec_init_gzip`          | 绑定 gzip 流 codec；mode 为 compress/decompress；成功 0。             | `codec_init_gzip`                 | 二次精简：去对象前缀 | `codec.codec_init_gzip(...)`                 |
| `stream_codec_init_base64`        | —                                                            | `codec_init_base64`               | 二次精简：去对象前缀 | `codec.codec_init_base64(...)`               |
| `stream_codec_process`            | 流式处理一块；is_last 非 0 表示末块（压缩/编码 padding）；返回写入 out 字节数。         | `codec_process`                   | 二次精简：去对象前缀 | `codec.codec_process(...)`                   |
| `stream_codec_end`                | 结束流并释放底层状态（gzip）；base64 stream 无额外清理。                        | `codec_end`                       | 二次精简：去对象前缀 | `codec.codec_end(...)`                       |
| `adapter_hex_encode`              | hex 适配：编码。                                                   | `adapter_hex_encode`              | 已符合命名      | `codec.adapter_hex_encode(...)`              |
| `adapter_hex_decode`              | hex 适配：解码。                                                   | `adapter_hex_decode`              | 已符合命名      | `codec.adapter_hex_decode(...)`              |
| `adapter_base64_encode`           | base64 标准适配：编码。                                              | `adapter_base64_encode`           | 已符合命名      | `codec.adapter_base64_encode(...)`           |
| `adapter_base64_decode`           | base64 标准适配：解码。                                              | `adapter_base64_decode`           | 已符合命名      | `codec.adapter_base64_decode(...)`           |
| `adapter_gzip_encode`             | gzip 块适配：压缩。                                                 | `adapter_gzip_encode`             | 已符合命名      | `codec.adapter_gzip_encode(...)`             |
| `adapter_gzip_decode`             | gzip 块适配：解压。                                                 | `adapter_gzip_decode`             | 已符合命名      | `codec.adapter_gzip_decode(...)`             |
| `adapter_compress_stream_init`    | STD-110：compress 流式 init（委托 stream_codec_init_gzip）。         | `adapter_compress_stream_init`    | 已符合命名      | `codec.adapter_compress_stream_init(...)`    |
| `adapter_compress_stream_process` | STD-110：compress/base64 流式 process（委托 stream_codec_process）。 | `adapter_compress_stream_process` | 已符合命名      | `codec.adapter_compress_stream_process(...)` |
| `adapter_compress_stream_end`     | STD-110：流式 end（委托 stream_codec_end）。                         | `adapter_compress_stream_end`     | 已符合命名      | `codec.adapter_compress_stream_end(...)`     |
| `adapter_base64_stream_init`      | STD-110：base64 流式 init；encode_mode 非 0 为编码，否则解码。             | `adapter_base64_stream_init`      | 已符合命名      | `codec.adapter_base64_stream_init(...)`      |
| `adapter_base64_stream_process`   | STD-110：base64 流式 process。                                   | `adapter_base64_stream_process`   | 已符合命名      | `codec.adapter_base64_stream_process(...)`   |
| `adapter_base64_stream_end`       | STD-110：base64 流式 end。                                       | `adapter_base64_stream_end`       | 已符合命名      | `codec.adapter_base64_stream_end(...)`       |
| `adapter_json_escape`             | JSON 字符串转义适配（encode-only）。                                   | `adapter_json_escape`             | 已符合命名      | `codec.adapter_json_escape(...)`             |
| `adapter_csv_escape`              | CSV 字段转义适配（encode-only）。                                     | `adapter_csv_escape`              | 已符合命名      | `codec.adapter_csv_escape(...)`              |


### std.compress

`std/compress/mod.sx` · 40 APIs · `const compress = import("std.compress")`


| 当前名称                              | 功能说明                                         | 简化名称                            | 说明         | 绑定调用                                          |
| --------------------------------- | -------------------------------------------- | ------------------------------- | ---------- | --------------------------------------------- |
| `deflate`                         | 压缩为 zlib 格式，返回写入字节数，失败 -1。                   | `deflate`                       | 已符合命名      | `compress.deflate(...)`                       |
| `inflate`                         | 解压 zlib 流，返回写入字节数，失败 -1。                     | `inflate`                       | 已符合命名      | `compress.inflate(...)`                       |
| `gzip_compress`                   | 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。              | `gzip_compress`                 | 已符合命名      | `compress.gzip_compress(...)`                 |
| `gzip_decompress`                 | 解压 gzip 流，返回写入字节数，失败 -1。                     | `gzip_decompress`               | 已符合命名      | `compress.gzip_decompress(...)`               |
| `brotli_compress`                 | 压缩为 Brotli 格式（.br），返回写入字节数，失败 -1。            | `brotli_compress`               | 已符合命名      | `compress.brotli_compress(...)`               |
| `brotli_decompress`               | 解压 Brotli 流，返回写入字节数，失败 -1。                   | `brotli_decompress`             | 已符合命名      | `compress.brotli_decompress(...)`             |
| `brotli_available`                | 探测 Brotli 是否已在编译期启用；1=可用，0=占位 stub。          | `brotli_available`              | 已符合命名      | `compress.brotli_available(...)`              |
| `brotli_smoke` | Brotli 往返烟测；未启用时返回 0（skip）。 | `brotli_smoke` | 已符合命名；Tier-X 不 export | `compress.brotli_smoke(...)` |
| `zstd_compress`                   | 压缩为 zstd 帧，返回写入字节数，失败 -1。                    | `zstd_compress`                 | 已符合命名      | `compress.zstd_compress(...)`                 |
| `zstd_decompress`                 | 解压 zstd 帧，返回写入字节数，失败 -1。                     | `zstd_decompress`               | 已符合命名      | `compress.zstd_decompress(...)`               |
| `zstd_available`                  | 探测 zstd 是否已在编译期启用；1=可用，0=占位 stub。            | `zstd_available`                | 已符合命名      | `compress.zstd_available(...)`                |
| `zstd_smoke` | zstd 往返烟测；未启用时返回 0（skip）。 | `zstd_smoke` | 已符合命名；Tier-X 不 export | `compress.zstd_smoke(...)` |
| `zstd_stream_state_bytes`         | zstd 流状态缓冲最小字节数。                             | `zstd_stream_state_bytes`       | 已符合命名      | `compress.zstd_stream_state_bytes(...)`       |
| `zstd_stream_init_compress`       | 初始化 zstd 压缩流；成功 0。                           | `zstd_stream_init_compress`     | 已符合命名      | `compress.zstd_stream_init_compress(...)`     |
| `zstd_stream_init_decompress`     | 初始化 zstd 解压流；成功 0。                           | `zstd_stream_init_decompress`   | 已符合命名      | `compress.zstd_stream_init_decompress(...)`   |
| `zstd_stream_compress`            | 分块 zstd 压缩。                                  | `zstd_stream_compress`          | 已符合命名      | `compress.zstd_stream_compress(...)`          |
| `zstd_stream_decompress`          | 分块 zstd 解压。                                  | `zstd_stream_decompress`        | 已符合命名      | `compress.zstd_stream_decompress(...)`        |
| `zstd_stream_end`                 | 释放 zstd 流。                                   | `zstd_stream_end`               | 已符合命名      | `compress.zstd_stream_end(...)`               |
| `brotli_stream_state_bytes`       | brotli 流状态缓冲最小字节数。                           | `brotli_stream_state_bytes`     | 已符合命名      | `compress.brotli_stream_state_bytes(...)`     |
| `brotli_stream_init_compress`     | 初始化 brotli 压缩流；成功 0。                         | `brotli_stream_init_compress`   | 已符合命名      | `compress.brotli_stream_init_compress(...)`   |
| `brotli_stream_init_decompress`   | 初始化 brotli 解压流；成功 0。                         | `brotli_stream_init_decompress` | 已符合命名      | `compress.brotli_stream_init_decompress(...)` |
| `brotli_stream_compress`          | 分块 brotli 压缩。                                | `brotli_stream_compress`        | 已符合命名      | `compress.brotli_stream_compress(...)`        |
| `brotli_stream_decompress`        | 分块 brotli 解压。                                | `brotli_stream_decompress`      | 已符合命名      | `compress.brotli_stream_decompress(...)`      |
| `brotli_stream_end`               | 释放 brotli 流。                                 | `brotli_stream_end`             | 已符合命名      | `compress.brotli_stream_end(...)`             |
| `gzip_stream_state_bytes`         | gzip 流状态缓冲最小字节数（STD-039）。                    | `gzip_stream_state_bytes`       | 已符合命名      | `compress.gzip_stream_state_bytes(...)`       |
| `gzip_stream_init_compress`       | 初始化 gzip 压缩流；成功 0，未链 zlib 时 -1。              | `gzip_stream_init_compress`     | 已符合命名      | `compress.gzip_stream_init_compress(...)`     |
| `gzip_stream_init_decompress`     | 初始化 gzip 解压流；成功 0，未链 zlib 时 -1。              | `gzip_stream_init_decompress`   | 已符合命名      | `compress.gzip_stream_init_decompress(...)`   |
| `gzip_stream_compress`            | 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH。          | `gzip_stream_compress`          | 已符合命名      | `compress.gzip_stream_compress(...)`          |
| `gzip_stream_decompress`          | 分块 gzip 解压。                                  | `gzip_stream_decompress`        | 已符合命名      | `compress.gzip_stream_decompress(...)`        |
| `gzip_stream_end`                 | 释放 gzip 流底层 z_stream。                        | `gzip_stream_end`               | 已符合命名      | `compress.gzip_stream_end(...)`               |
| `compress_format_gzip`            | 流格式：gzip。                                    | `format_gzip`                   | 去模块前缀+去类型名 | `compress.format_gzip(...)`                   |
| `compress_format_brotli`          | 流格式：brotli。                                  | `format_brotli`                 | 去模块前缀+去类型名 | `compress.format_brotli(...)`                 |
| `compress_format_zstd`            | 流格式：zstd。                                    | `format_zstd`                   | 去模块前缀+去类型名 | `compress.format_zstd(...)`                   |
| `compress_stream_mode_compress`   | 流模式：压缩。                                      | `mode_compress`                 | 二次精简：去对象前缀 | `compress.mode_compress(...)`                 |
| `compress_stream_mode_decompress` | 流模式：解压。                                      | `mode_decompress`               | 二次精简：去对象前缀 | `compress.mode_decompress(...)`               |
| `stream_compress_state_bytes_for` | 指定格式的流状态缓冲最小字节数。                             | `compress_state_bytes_for`      | 二次精简：去对象前缀 | `compress.compress_state_bytes_for(...)`      |
| `stream_compress_state_bytes`     | 统一流状态缓冲最小字节数（取 gzip/brotli/zstd 最大值，便于通用缓冲）。 | `compress_state_bytes`          | 二次精简：去对象前缀 | `compress.compress_state_bytes(...)`          |
| `stream_compress_init`            | —                                            | `compress_init`                 | 二次精简：去对象前缀 | `compress.compress_init(...)`                 |
| `stream_compress_process`         | —                                            | `compress_process`              | 二次精简：去对象前缀 | `compress.compress_process(...)`              |
| `stream_compress_end`             | 结束流并释放底层状态；成功 0。                             | `compress_end`                  | 二次精简：去对象前缀 | `compress.compress_end(...)`                  |


### std.compress.brotli

`std/compress/brotli/mod.sx` · 10 APIs · `const brotli = import("std.compress.brotli")`


| 当前名称                            | 功能说明                                | 简化名称              | 说明         | 绑定调用                          |
| ------------------------------- | ----------------------------------- | ----------------- | ---------- | ----------------------------- |
| `brotli_compress`               | 压缩为 Brotli 格式（.br），返回写入字节数，失败 -1。   | `compress`        | 去模块前缀+去类型名 | `brotli.compress(...)`        |
| `brotli_decompress`             | 解压 Brotli 流，返回写入字节数，失败 -1。          | `decompress`      | 去模块前缀+去类型名 | `brotli.decompress(...)`      |
| `brotli_available`              | 探测 Brotli 是否已在编译期启用；1=可用，0=占位 stub。 | `available`       | 去模块前缀+去类型名 | `brotli.available(...)`       |
| `brotli_smoke` | Brotli 往返烟测；未启用时返回 0（skip）。 | `smoke` | 去模块前缀+去类型名；Tier-X 不 export | `brotli.smoke(...)` |
| `brotli_stream_state_bytes`     | brotli 流状态缓冲最小字节数。                  | `state_bytes`     | 去模块前缀+去类型名 | `brotli.state_bytes(...)`     |
| `brotli_stream_init_compress`   | 初始化 brotli 压缩流；成功 0。                | `init_compress`   | 去模块前缀+去类型名 | `brotli.init_compress(...)`   |
| `brotli_stream_init_decompress` | 初始化 brotli 解压流；成功 0。                | `init_decompress` | 去模块前缀+去类型名 | `brotli.init_decompress(...)` |
| `brotli_stream_compress`        | 分块 brotli 压缩；is_last≠0 时 FINISH。    | `compress`        | 去模块前缀+去类型名 | `brotli.compress(...)`        |
| `brotli_stream_decompress`      | 分块 brotli 解压。                       | `decompress`      | 去模块前缀+去类型名 | `brotli.decompress(...)`      |
| `brotli_stream_end`             | 释放 brotli 流。                        | `end`             | 去模块前缀+去类型名 | `brotli.end(...)`             |


### std.compress.gzip

`std/compress/gzip/mod.sx` · 8 APIs · `const gzip = import("std.compress.gzip")`


| 当前名称                          | 功能说明                                | 简化名称              | 说明         | 绑定调用                        |
| ----------------------------- | ----------------------------------- | ----------------- | ---------- | --------------------------- |
| `gzip_compress`               | 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。     | `compress`        | 去模块前缀+去类型名 | `gzip.compress(...)`        |
| `gzip_decompress`             | 解压 gzip 流，返回写入字节数，失败 -1。            | `decompress`      | 去模块前缀+去类型名 | `gzip.decompress(...)`      |
| `gzip_stream_state_bytes`     | gzip 流状态缓冲最小字节数（STD-039）。           | `state_bytes`     | 去模块前缀+去类型名 | `gzip.state_bytes(...)`     |
| `gzip_stream_init_compress`   | 初始化 gzip 压缩流；成功 0，未链 libz 时 -1。     | `init_compress`   | 去模块前缀+去类型名 | `gzip.init_compress(...)`   |
| `gzip_stream_init_decompress` | 初始化 gzip 解压流；成功 0，未链 libz 时 -1。     | `init_decompress` | 去模块前缀+去类型名 | `gzip.init_decompress(...)` |
| `gzip_stream_compress`        | 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH。 | `compress`        | 去模块前缀+去类型名 | `gzip.compress(...)`        |
| `gzip_stream_decompress`      | 分块 gzip 解压。                         | `decompress`      | 去模块前缀+去类型名 | `gzip.decompress(...)`      |
| `gzip_stream_end`             | 释放 gzip 流底层 z_stream。               | `end`             | 去模块前缀+去类型名 | `gzip.end(...)`             |


### std.compress.zlib

`std/compress/zlib/mod.sx` · 2 APIs · `const zlib = import("std.compress.zlib")`


| 当前名称      | 功能说明                       | 简化名称      | 说明    | 绑定调用                |
| --------- | -------------------------- | --------- | ----- | ------------------- |
| `deflate` | 压缩为 zlib 格式，返回写入字节数，失败 -1。 | `deflate` | 已符合命名 | `zlib.deflate(...)` |
| `inflate` | 解压 zlib 流，返回写入字节数，失败 -1。   | `inflate` | 已符合命名 | `zlib.inflate(...)` |
### std.compress.zstd

`std/compress/zstd/mod.sx` · 10 APIs · `const zstd = import("std.compress.zstd")`


| 当前名称                          | 功能说明                               | 简化名称              | 说明         | 绑定调用                        |
| ----------------------------- | ---------------------------------- | ----------------- | ---------- | --------------------------- |
| `zstd_compress`               | 压缩为 zstd 帧，返回写入字节数，失败 -1。          | `compress`        | 去模块前缀+去类型名 | `zstd.compress(...)`        |
| `zstd_decompress`             | 解压 zstd 帧，返回写入字节数，失败 -1。           | `decompress`      | 去模块前缀+去类型名 | `zstd.decompress(...)`      |
| `zstd_available`              | 探测 zstd 是否已在编译期启用；1=可用，0=占位 stub。  | `available`       | 去模块前缀+去类型名 | `zstd.available(...)`       |
| `zstd_smoke` | zstd 块 + 流往返烟测；未启用时返回 0（skip）。 | `smoke` | 去模块前缀+去类型名；Tier-X 不 export | `zstd.smoke(...)` |
| `zstd_stream_state_bytes`     | zstd 流状态缓冲最小字节数。                   | `state_bytes`     | 去模块前缀+去类型名 | `zstd.state_bytes(...)`     |
| `zstd_stream_init_compress`   | 初始化 zstd 压缩流；成功 0。                 | `init_compress`   | 去模块前缀+去类型名 | `zstd.init_compress(...)`   |
| `zstd_stream_init_decompress` | 初始化 zstd 解压流；成功 0。                 | `init_decompress` | 去模块前缀+去类型名 | `zstd.init_decompress(...)` |
| `zstd_stream_compress`        | 分块 zstd 压缩；is_last≠0 时 ZSTD_e_end。 | `compress`        | 去模块前缀+去类型名 | `zstd.compress(...)`        |
| `zstd_stream_decompress`      | 分块 zstd 解压。                        | `decompress`      | 去模块前缀+去类型名 | `zstd.decompress(...)`      |
| `zstd_stream_end`             | 释放 zstd 流。                         | `end`             | 去模块前缀+去类型名 | `zstd.end(...)`             |


### std.config

`std/config/mod.sx` · 49 APIs · `const config = import("std.config")`


| 当前名称                       | 功能说明                                           | 简化名称              | 说明             | 绑定调用                          |
| -------------------------- | ---------------------------------------------- | ----------------- | -------------- | ----------------------------- |
| `config_err_ok`            | 成功。                                            | `err_ok`          | 去模块前缀+去类型名     | `config.err_ok(...)`          |
| `config_err_null`          | 空指针参数。                                         | `err_null`        | 去模块前缀+去类型名     | `config.err_null(...)`        |
| `config_err_not_found`     | 键不存在。                                          | `err_not_found`   | 去模块前缀+去类型名     | `config.err_not_found(...)`   |
| `config_err_invalid`       | 值非法或解析失败。                                      | `err_invalid`     | 去模块前缀+去类型名     | `config.err_invalid(...)`     |
| `config_err_io`            | 文件 IO 失败。                                      | `err_io`          | 去模块前缀+去类型名     | `config.err_io(...)`          |
| `config_err_full`          | 条目数超限。                                         | `err_full`        | 去模块前缀+去类型名     | `config.err_full(...)`        |
| `config_source_unknown`    | 值来源：未知 / 未记录。                                  | `source_unknown`  | 去模块前缀+去类型名     | `config.source_unknown(...)`  |
| `config_source_toml`       | 值来源：TOML 文件或缓冲。                                | `source_toml`     | 去模块前缀+去类型名     | `config.source_toml(...)`     |
| `config_source_yaml`       | 值来源：YAML 文件或缓冲。                                | `source_yaml`     | 去模块前缀+去类型名     | `config.source_yaml(...)`     |
| `config_source_env`        | 值来源：环境变量。                                      | `source_env`      | 去模块前缀+去类型名     | `config.source_env(...)`      |
| `config_source_set`        | 值来源：显式 set_string / CLI 层。                     | `source_set`      | 去模块前缀+去类型名     | `config.source_set(...)`      |
| `config_create_c` | extern C/平台 | `create` | 去模块前缀+去类型名（C层） | `config.create(...)` |
| `config_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `config.free(...)` |
| `config_clear_c` | extern C/平台 | `clear` | 去模块前缀+去类型名（C层） | `config.clear(...)` |
| `config_load_toml_buf_c` | extern C/平台 | `load_toml_buf` | 去模块前缀+去类型名（C层） | `config.load_toml_buf(...)` |
| `config_load_toml_file_c` | extern C/平台 | `load_toml_file` | 去模块前缀+去类型名（C层） | `config.load_toml_file(...)` |
| `config_load_env_prefix_c` | extern C/平台                                    | `load_env_prefix` | 去模块前缀+去类型名（C层） | `config.load_env_prefix(...)` |
| `config_merge_c` | extern C/平台 | `merge` | 去模块前缀+去类型名（C层） | `config.merge(...)` |
| `config_set_string_c` | extern C/平台 | `set_string` | 去模块前缀+去类型名（C层） | `config.set_string(...)` |
| `config_get_string_c` | extern C/平台 | `get_string` | 去模块前缀+去类型名（C层） | `config.get_string(...)` |
| `config_get_i32_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `config.get(...)` |
| `config_get_bool_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `config.get(...)` |
| `config_get_source_c` | extern C/平台 | `get_source` | 去模块前缀+去类型名（C层） | `config.get_source(...)` |
| `config_get_i32_meta_c` | extern C/平台 | `get_meta` | 去模块前缀+去类型名（C层） | `config.get_meta(...)` |
| `config_get_bool_meta_c` | extern C/平台 | `get_meta` | 去模块前缀+去类型名（C层） | `config.get_meta(...)` |
| `config_get_string_meta_c` | extern C/平台                                    | `get_string_meta` | 去模块前缀+去类型名（C层） | `config.get_string_meta(...)` |
| `config_new`               | 创建空配置；失败 handle=0。                             | `new`             | 去模块前缀+去类型名     | `config.new(...)`             |
| `config_free`              | 释放配置存储。                                        | `free`            | 去模块前缀+去类型名     | `config.free(...)`            |
| `config_clear`             | 清空所有键值。                                        | `clear`           | 去模块前缀+去类型名     | `config.clear(...)`           |
| `load_toml_buf`            | 从内存 TOML 缓冲加载；override 非 0 时覆盖已有键。             | `load_toml_buf`   | 已符合命名          | `config.load_toml_buf(...)`   |
| `load_toml_file`           | 从 NUL 结尾路径加载 TOML 文件。                          | `load_toml_file`  | 已符合命名          | `config.load_toml_file(...)`  |
| `load_env_prefix`          | 加载环境变量前缀（如 APP_ → 键 PORT）；返回加载条数，失败负数。         | `load_env_prefix` | 已符合命名          | `config.load_env_prefix(...)` |
| `merge`                    | 将 src 合并进 dst；override 非 0 时 src 覆盖同名键（CLI 层）。 | `merge`           | 已符合命名          | `config.merge(...)`           |
| `set_string`               | 设置字符串键值（最高优先级）。                                | `set_string`      | 已符合命名          | `config.set_string(...)`      |
| `get_string`               | 读取字符串；返回长度，未找到 config_err_not_found()。         | `get_string`      | 已符合命名          | `config.get_string(...)`      |
| `get_i32`                  | 读取 i32 标量。                                     | `get`             | 语义重命名          | `config.get(...)`             |
| `get_bool`                 | 读取 bool 标量。                                    | `get`             | 已符合命名          | `config.get(...)`             |
| `get_source`               | 读取键值来源层（kind）与可选 label（如 env 全名或文件路径）。         | `get_source`      | 已符合命名          | `config.get_source(...)`      |
| `get_i32_meta`             | 读取 i32 并附带来源 meta（out_kind 可传 0 跳过）。           | `get_meta`        | 语义重命名          | `config.get_meta(...)`        |
| `get_bool_meta`            | 读取 bool 并附带来源 meta。                            | `get_meta`        | 已符合命名          | `config.get_meta(...)`        |
| `get_string_meta`          | 读取字符串并附带来源 meta；返回值同 get_string。               | `get_string_meta` | 已符合命名          | `config.get_string_meta(...)` |
| `config_backend_toml`      | 配置后端：TOML。                                     | `backend_toml`    | 去模块前缀+去类型名     | `config.backend_toml(...)`    |
| `config_backend_yaml`      | 配置后端：YAML（可选链入，与 TOML 共享键空间）。                  | `backend_yaml`    | 去模块前缀+去类型名     | `config.backend_yaml(...)`    |
| `config_load_yaml_buf_c` | extern C/平台 | `load_yaml_buf` | 去模块前缀+去类型名（C层） | `config.load_yaml_buf(...)` |
| `config_load_yaml_file_c` | extern C/平台 | `load_yaml_file` | 去模块前缀+去类型名（C层） | `config.load_yaml_file(...)` |
| `config_yaml_smoke_c` | extern C/平台 | `yaml_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `config.yaml_smoke(...)` |
| `load_yaml_buf`            | 从内存 YAML 缓冲加载；override 非 0 时覆盖已有键。             | `load_yaml_buf`   | 已符合命名          | `config.load_yaml_buf(...)`   |
| `load_yaml_file`           | 从 NUL 结尾路径加载 YAML 文件。                          | `load_yaml_file`  | 已符合命名          | `config.load_yaml_file(...)`  |
| `yaml_smoke` | STD-119：YAML 后端 C 烟测；0 通过。 | `yaml_smoke` | 已符合命名；Tier-X 不 export | `config.yaml_smoke(...)` |


### std.context

`std/context/mod.sx` · 23 APIs · `const context = import("std.context")`


| 当前名称                  | 功能说明                              | 简化名称            | 说明             | 绑定调用                         |
| --------------------- | --------------------------------- | --------------- | -------------- | ---------------------------- |
| `ctx_background_c` | extern C/平台 | `background` | 去模块前缀+去类型名（C层） | `context.background(...)` |
| `ctx_with_cancel_c` | extern C/平台 | `with_cancel` | 去模块前缀+去类型名（C层） | `context.with_cancel(...)` |
| `ctx_with_deadline_c` | extern C/平台                       | `with_deadline` | 去模块前缀+去类型名（C层） | `context.with_deadline(...)` |
| `ctx_with_timeout_c` | extern C/平台 | `with_timeout` | 去模块前缀+去类型名（C层） | `context.with_timeout(...)` |
| `ctx_cancel_c` | extern C/平台 | `cancel` | 去模块前缀+去类型名（C层） | `context.cancel(...)` |
| `ctx_is_cancelled_c` | extern C/平台 | `is_cancelled` | 去模块前缀+去类型名（C层） | `context.is_cancelled(...)` |
| `ctx_deadline_ns_c` | extern C/平台 | `deadline_ns` | 去模块前缀+去类型名（C层） | `context.deadline_ns(...)` |
| `ctx_remaining_ns_c` | extern C/平台 | `remaining_ns` | 去模块前缀+去类型名（C层） | `context.remaining_ns(...)` |
| `ctx_set_value_c` | extern C/平台 | `set_value` | 去模块前缀+去类型名（C层） | `context.set_value(...)` |
| `ctx_get_value_c` | extern C/平台 | `get_value` | 去模块前缀+去类型名（C层） | `context.get_value(...)` |
| `ctx_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `context.free(...)` |
| `ctx_smoke_c` | extern C/平台 | `smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `context.smoke(...)` |
| `background`          | 根上下文：永不取消、无 deadline。             | `background`    | 已符合命名          | `context.background(...)`    |
| `with_cancel`         | 派生可取消子上下文；失败 handle=0。            | `with_cancel`   | 已符合命名          | `context.with_cancel(...)`   |
| `with_deadline`       | 派生带绝对 deadline（单调纳秒）的子上下文。        | `with_deadline` | 已符合命名          | `context.with_deadline(...)` |
| `with_timeout`        | 派生相对超时子上下文（now + timeout_ns）。     | `with_timeout`  | 已符合命名          | `context.with_timeout(...)`  |
| `cancel`              | 取消上下文（本节点及子链查询可见）。                | `cancel`        | 已符合命名          | `context.cancel(...)`        |
| `is_cancelled`        | 是否已取消：1 是，0 否。                    | `is_cancelled`  | 已符合命名          | `context.is_cancelled(...)`  |
| `deadline_ns`         | 有效 deadline（单调纳秒）；0 表示无 deadline。 | `deadline_ns`   | 已符合命名          | `context.deadline_ns(...)`   |
| `remaining_ns`        | 剩余时间（纳秒）；已取消或过期返回 0。              | `remaining_ns`  | 已符合命名          | `context.remaining_ns(...)`  |
| `set_value`           | 设置键值；成功 CTX_OK，槽满 -1。             | `set_value`     | 已符合命名          | `context.set_value(...)`     |
| `get_value`           | 读取键值；找到返回 1 并写 *out，否则 0。         | `get_value`     | 已符合命名          | `context.get_value(...)`     |
| `free`                | 释放派生上下文（不可释放 background）。         | `free`          | 已符合命名          | `context.free(...)`          |


### std.crypto

`std/crypto/mod.sx` · 34 APIs · `const crypto = import("std.crypto")`


| 当前名称                                | 功能说明                                                                                                                                             | 简化名称                        | 说明                | 绑定调用                                    |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- | ----------------- | --------------------------------------- |
| `crypto_mem_eq_c` | std.crypto — 常量时间比较、SHA-256/512、HMAC、AES-GCM、ChaCha20-Poly1305、Ed25519 【文件职责】mem_eq、sha256、sha512、hmac_sha256、ed25519、aes_gcm、chacha20_poly1305。 | `mem_eq` | 去模块前缀+去类型名（C层） | `crypto.mem_eq(...)` |
| `crypto_sha256_c` | extern C/平台 | `sha256` | 去模块前缀+去类型名（C层） | `crypto.sha256(...)` |
| `crypto_sha512_c` | extern C/平台 | `sha512` | 去模块前缀+去类型名（C层） | `crypto.sha512(...)` |
| `crypto_hmac_sha256_c` | extern C/平台 | `hmac_sha256` | 去模块前缀+去类型名（C层） | `crypto.hmac_sha256(...)` |
| `crypto_hmac_sha512_c` | extern C/平台 | `hmac_sha512` | 去模块前缀+去类型名（C层） | `crypto.hmac_sha512(...)` |
| `crypto_ed25519_public_from_seed_c` | extern C/平台 | `ed25519_public_from_seed` | 去模块前缀+去类型名（C层） | `crypto.ed25519_public_from_seed(...)` |
| `crypto_ed25519_sign_c` | extern C/平台 | `ed25519_sign` | 去模块前缀+去类型名（C层） | `crypto.ed25519_sign(...)` |
| `crypto_ed25519_verify_c` | extern C/平台 | `ed25519_verify` | 去模块前缀+去类型名（C层） | `crypto.ed25519_verify(...)` |
| `crypto_ed25519_smoke_c` | extern C/平台 | `ed25519_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `crypto.ed25519_smoke(...)` |
| `crypto_aes_gcm_seal_c` | extern C/平台 | `aes_gcm_seal` | 去模块前缀+去类型名（C层） | `crypto.aes_gcm_seal(...)` |
| `crypto_aes_gcm_open_c` | extern C/平台 | `aes_gcm_open` | 去模块前缀+去类型名（C层） | `crypto.aes_gcm_open(...)` |
| `crypto_chacha20_poly1305_seal_c` | extern C/平台 | `chacha20_poly1305_seal` | 去模块前缀+去类型名（C层） | `crypto.chacha20_poly1305_seal(...)` |
| `crypto_chacha20_poly1305_open_c` | extern C/平台 | `chacha20_poly1305_open` | 去模块前缀+去类型名（C层） | `crypto.chacha20_poly1305_open(...)` |
| `crypto_chacha20_poly1305_smoke_c` | extern C/平台 | `chacha20_poly1305_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `crypto.chacha20_poly1305_smoke(...)` |
| `ED25519_SEED_LEN`                  | Ed25519 seed 长度（字节）。                                                                                                                             | `ED25519_SEED_LEN`          | 已符合命名             | `crypto.ED25519_SEED_LEN(...)`          |
| `CHACHA20_POLY1305_KEY_LEN`         | ChaCha20-Poly1305 密钥长度（字节）。                                                                                                                      | `CHACHA20_POLY1305_KEY_LEN` | 已符合命名             | `crypto.CHACHA20_POLY1305_KEY_LEN(...)` |
| `mem_eq`                            | 常量时间比较 a[0..len] 与 b[0..len]；相等返回 1，否则 0。                                                                                                        | `mem_eq`                    | 已符合命名             | `crypto.mem_eq(...)`                    |
| `sha256`                            | SHA-256 哈希，写入 out[0..32]。                                                                                                                        | `sha256`                    | 已符合命名             | `crypto.sha256(...)`                    |
| `sha512`                            | SHA-512 哈希，写入 out[0..64]。                                                                                                                        | `sha512`                    | 已符合命名             | `crypto.sha512(...)`                    |
| `hmac_sha512`                       | HMAC-SHA512(key, msg)，结果写入 out[0..64]（STD-050）。                                                                                                  | `hmac_sha512`               | 已符合命名             | `crypto.hmac_sha512(...)`               |
| `hmac_sha256`                       | HMAC-SHA256(key, msg)，结果写入 out[0..32]。                                                                                                           | `hmac_sha256`               | 已符合命名             | `crypto.hmac_sha256(...)`               |
| `mac_sign`                          | MAC 签名校验别名（256-bit，等同 hmac_sha256）。                                                                                                              | `mac_sign`                  | 已符合命名             | `crypto.mac_sign(...)`                  |
| `mac_sign_512`                      | MAC 签名 512-bit（STD-050：等同 hmac_sha512）。                                                                                                          | `mac_sign`                  | 二次精简：去算法/版本/分段数后缀 | `crypto.mac_sign(...)`                  |
| `mac_verify`                        | MAC 校验：重算 HMAC 与 tag[0..32] 常量时间比较；相等 1，否则 0。                                                                                                    | `mac_verify`                | 已符合命名             | `crypto.mac_verify(...)`                |
| `mac_verify_512`                    | MAC 512-bit 校验：重算 HMAC-SHA512 与 tag[0..64] 比较（STD-050）。                                                                                          | `mac_verify`                | 二次精简：去算法/版本/分段数后缀 | `crypto.mac_verify(...)`                |
| `ed25519_public_from_seed`          | 由 32 字节 seed 导出 Ed25519 公钥至 pub[0..32]。                                                                                                          | `ed25519_public_from_seed`  | 已符合命名             | `crypto.ed25519_public_from_seed(...)`  |
| `ed25519_sign`                      | 使用 seed 对 msg 签名；sig 写入 64 字节；成功 0，失败 -1。                                                                                                        | `ed25519_sign`              | 已符合命名             | `crypto.ed25519_sign(...)`              |
| `ed25519_verify`                    | 验签；成功 0，失败 -1。                                                                                                                                   | `ed25519_verify`            | 已符合命名             | `crypto.ed25519_verify(...)`            |
| `ed25519_smoke` | Ed25519 C 层烟测（RFC 8032 TEST 1）；0 通过。 | `ed25519_smoke` | 已符合命名；Tier-X 不 export | `crypto.ed25519_smoke(...)` |
| `aes_gcm_seal`                      | AES-128-GCM 加密；key_len=16、iv_len=12、tag 16B；成功 0。                                                                                                | `aes_gcm_seal`              | 已符合命名             | `crypto.aes_gcm_seal(...)`              |
| `aes_gcm_open`                      | AES-128-GCM 解密并校验 tag；成功 0，tag 错误 -1。                                                                                                            | `aes_gcm_open`              | 已符合命名             | `crypto.aes_gcm_open(...)`              |
| `chacha20_poly1305_seal`            | ChaCha20-Poly1305 加密；key_len=32、nonce_len=12、tag 16B；成功 0。                                                                                       | `chacha20_poly1305_seal`    | 已符合命名             | `crypto.chacha20_poly1305_seal(...)`    |
| `chacha20_poly1305_open`            | ChaCha20-Poly1305 解密并校验 tag；成功 0，失败 -1。                                                                                                          | `chacha20_poly1305_open`    | 已符合命名             | `crypto.chacha20_poly1305_open(...)`    |
| `chacha20_poly1305_smoke` | ChaCha20-Poly1305 C 层烟测；0 通过。 | `chacha20_poly1305_smoke` | 已符合命名；Tier-X 不 export | `crypto.chacha20_poly1305_smoke(...)` |


### std.csv

`std/csv/mod.sx` · 18 APIs · `const csv = import("std.csv")`


| 当前名称                             | 功能说明                                                                                                   | 简化名称                 | 说明             | 绑定调用                          |
| -------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------------- | -------------- | ----------------------------- |
| `next_field`                     | std.csv — CSV 解析与写回（RFC 4180） next_field / unescape / parse_row / write_row / stream：csv.sx（F-csv v1）。 | `next_field`         | 已符合命名          | `csv.next_field(...)`         |
| `unescape`                       | extern C/平台                                                                                            | `unescape`           | 已符合命名          | `csv.unescape(...)`           |
| `csv_test_quoted_first`          | extern C/平台                                                                                            | `test_quoted_first`  | 去模块前缀+去类型名     | `csv.test_quoted_first(...)`  |
| `csv_test_quoted_second`         | extern C/平台                                                                                            | `test_quoted_second` | 去模块前缀+去类型名     | `csv.test_quoted_second(...)` |
| `csv_test_unescape_ok`           | extern C/平台                                                                                            | `test_unescape_ok`   | 去模块前缀+去类型名     | `csv.test_unescape_ok(...)`   |
| `csv_test_unescape_fail`         | extern C/平台                                                                                            | `test_unescape_fail` | 去模块前缀+去类型名     | `csv.test_unescape_fail(...)` |
| `parse_row`                      | extern C/平台                                                                                            | `parse_row`          | 已符合命名          | `csv.parse_row(...)`          |
| `write_row`                      | extern C/平台                                                                                            | `write_row`          | 已符合命名          | `csv.write_row(...)`          |
| `escape`                         | 将字段转义为带引号的 CSV 单元写入 buf；返回写入长度，失败 -1。                                                                  | `escape`             | 已符合命名          | `csv.escape(...)`             |
| `stream_reader_init`             | 绑定读缓冲；offset 置 0。                                                                                      | `init`               | 二次精简：去对象前缀     | `csv.init(...)`               |
| `stream_reader_next_row`         | —                                                                                                      | `next_row`           | 二次精简：去对象前缀     | `csv.next_row(...)`           |
| `stream_reader_eof`              | 是否已读完（offset >= len）。                                                                                  | `eof`                | 二次精简：去对象前缀     | `csv.eof(...)`                |
| `stream_writer_init`             | 绑定写缓冲；out_len 置 0。                                                                                     | `init`               | 二次精简：去对象前缀     | `csv.init(...)`               |
| `csv_stream_smoke_c` | extern C/平台 | `smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `csv.smoke(...)` |
| `csv_stream_writer_append_row_c` | extern C/平台 | `append_row` | 二次精简：去对象前缀 | `csv.append_row(...)` |
| `stream_writer_append_row`       | —                                                                                                      | `append_row`         | 二次精简：去对象前缀     | `csv.append_row(...)`         |
| `stream_writer_len`              | 当前已写入字节数（含行尾换行）。                                                                                       | `len`                | 二次精简：去对象前缀     | `csv.len(...)`                |
| `csv_stream_smoke` | STD-128：C 层多行流式烟测；0 通过。 | `smoke` | 去模块前缀+去类型名；Tier-X 不 export | `csv.smoke(...)` |


### std.datetime

`std/datetime/mod.sx` · 46 APIs · `const dt = import("std.datetime")`


| 当前名称                                | 功能说明                                             | 简化名称                      | 说明             | 绑定调用                              |
| ----------------------------------- | ------------------------------------------------ | ------------------------- | -------------- | --------------------------------- |
| `datetime_now_utc_c` | extern C/平台 | `now_utc` | 去模块前缀+去类型名（C层） | `dt.now_utc(...)` |
| `datetime_utc_fields_c` | extern C/平台 | `utc_fields` | 去模块前缀+去类型名（C层） | `dt.utc_fields(...)` |
| `datetime_from_utc_fields_c` | extern C/平台 | `from_utc_fields` | 去模块前缀+去类型名（C层） | `dt.from_utc_fields(...)` |
| `datetime_compare_c` | extern C/平台 | `compare` | 去模块前缀+去类型名（C层） | `dt.compare(...)` |
| `datetime_parse_rfc3339_c` | extern C/平台 | `parse_rfc3339` | 去模块前缀+去类型名（C层） | `dt.parse_rfc3339(...)` |
| `datetime_format_rfc3339_c` | extern C/平台 | `format_rfc3339` | 去模块前缀+去类型名（C层） | `dt.format_rfc3339(...)` |
| `datetime_format_rfc3339_nano_c` | extern C/平台 | `format_rfc3339_nano` | 去模块前缀+去类型名（C层） | `dt.format_rfc3339_nano(...)` |
| `datetime_local_offset_min_c` | extern C/平台 | `local_offset_min` | 去模块前缀+去类型名（C层） | `dt.local_offset_min(...)` |
| `datetime_local_fields_c` | extern C/平台 | `local_fields` | 去模块前缀+去类型名（C层） | `dt.local_fields(...)` |
| `datetime_duration_between_ns_c` | extern C/平台 | `duration_between_ns` | 去模块前缀+去类型名（C层） | `dt.duration_between_ns(...)` |
| `datetime_add_duration_ns_c` | extern C/平台 | `add_duration_ns` | 去模块前缀+去类型名（C层） | `dt.add_duration_ns(...)` |
| `datetime_timezone_from_name_c` | extern C/平台 | `timezone_from_name` | 去模块前缀+去类型名（C层） | `dt.timezone_from_name(...)` |
| `datetime_parse_offset_min_c` | extern C/平台 | `parse_offset_min` | 去模块前缀+去类型名（C层） | `dt.parse_offset_min(...)` |
| `datetime_from_zoned_fields_c` | extern C/平台 | `from_zoned_fields` | 去模块前缀+去类型名（C层） | `dt.from_zoned_fields(...)` |
| `datetime_iana_from_name_c` | extern C/平台 | `iana_from_name` | 去模块前缀+去类型名（C层） | `dt.iana_from_name(...)` |
| `datetime_iana_offset_at_c` | extern C/平台 | `iana_offset_at` | 去模块前缀+去类型名（C层） | `dt.iana_offset_at(...)` |
| `datetime_from_iana_zoned_fields_c` | extern C/平台 | `from_iana_zoned_fields` | 去模块前缀+去类型名（C层） | `dt.from_iana_zoned_fields(...)` |
| `datetime_iana_dst_smoke_c` | extern C/平台 | `iana_dst_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `dt.iana_dst_smoke(...)` |
| `datetime_timezone_smoke_c` | extern C/平台 | `timezone_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `dt.timezone_smoke(...)` |
| `now_utc`                           | 当前 UTC 时刻。                                       | `now_utc`                 | 已符合命名          | `dt.now_utc(...)`                 |
| `from_unix`                         | 由 Unix 秒构造 UTC DateTime。                         | `from_unix`               | 已符合命名          | `dt.from_unix(...)`               |
| `from_utc_fields`                   | 由 UTC 日历字段构造；失败返回 sec=-1。                        | `from_utc_fields`         | 已符合命名          | `dt.from_utc_fields(...)`         |
| `to_utc_fields`                     | 分解为 UTC 日历字段。                                    | `to_utc_fields`           | 已符合命名          | `dt.to_utc_fields(...)`           |
| `compare`                           | 比较两个 DateTime：-1/0/1。                            | `compare`                 | 已符合命名          | `dt.compare(...)`                 |
| `parse_rfc3339`                     | 解析 RFC3339 / RFC3339Nano；0 成功，-1 失败。             | `parse_rfc3339`           | 已符合命名          | `dt.parse_rfc3339(...)`           |
| `format_rfc3339`                    | 格式化为 RFC3339 UTC（Z）；返回写入长度，失败 -1。                | `format_rfc3339`          | 已符合命名          | `dt.format_rfc3339(...)`          |
| `format_rfc3339_nano`               | 格式化为 RFC3339Nano UTC；返回写入长度，失败 -1。               | `format_rfc3339_nano`     | 已符合命名          | `dt.format_rfc3339_nano(...)`     |
| `local_offset_min`                  | 本地时区相对 UTC 偏移（分钟，东为正）。                           | `local_offset_min`        | 已符合命名          | `dt.local_offset_min(...)`        |
| `to_local_fields`                   | 按本地偏移分解日历字段。                                     | `to_local_fields`         | 已符合命名          | `dt.to_local_fields(...)`         |
| `duration_from_ns`                  | 构造 Duration（纳秒）。                                 | `duration_from_ns`        | 已符合命名          | `dt.duration_from_ns(...)`        |
| `duration_from_sec`                 | 构造 Duration（秒）。                                  | `duration_from_sec`       | 已符合命名          | `dt.duration_from_sec(...)`       |
| `duration_between`                  | 两 DateTime 之差（b - a）。                            | `duration_between`        | 已符合命名          | `dt.duration_between(...)`        |
| `add_duration`                      | DateTime 加 Duration。                             | `add_duration`            | 已符合命名          | `dt.add_duration(...)`            |
| `duration_sleep`                    | Duration 睡眠（委托 std.time.sleep_ns）。               | `duration_sleep`          | 已符合命名          | `dt.duration_sleep(...)`          |
| `duration_from_monotonic`           | 单调时钟差 → Duration。                                | `duration_from_monotonic` | 已符合命名          | `dt.duration_from_monotonic(...)` |
| `timezone_utc`                      | UTC 时区（offset 0）。                                | `timezone_utc`            | 已符合命名          | `dt.timezone_utc(...)`            |
| `timezone_local`                    | 平台本地时区偏移（固定，无 IANA）。                             | `timezone_local`          | 已符合命名          | `dt.timezone_local(...)`          |
| `timezone_fixed`                    | 指定固定偏移（分钟）；iana_id=-1。                           | `timezone_fixed`          | 已符合命名          | `dt.timezone_fixed(...)`          |
| `timezone_from_name`                | —                                                | `timezone_from_name`      | 已符合命名          | `dt.timezone_from_name(...)`      |
| `timezone_iana`                     | —                                                | `timezone_iana`           | 已符合命名          | `dt.timezone_iana(...)`           |
| `timezone_offset_at`                | 指定 UTC 时刻在时区下的偏移（分钟；IANA 含 DST，固定区用 offset_min）。 | `timezone_offset_at`      | 已符合命名          | `dt.timezone_offset_at(...)`      |
| `parse_offset_min`                  | 解析 ±HH:MM / ±HHMM / Z 或内置时区名；成功 0。               | `parse_offset_min`        | 已符合命名          | `dt.parse_offset_min(...)`        |
| `to_zoned_fields`                   | UTC DateTime → 时区墙钟日历字段（IANA 按 t.sec 查 DST）。     | `to_zoned_fields`         | 已符合命名          | `dt.to_zoned_fields(...)`         |
| `from_zoned_fields`                 | 时区墙钟日历字段 → UTC DateTime；IANA 含 DST refinement。   | `from_zoned_fields`       | 已符合命名          | `dt.from_zoned_fields(...)`       |
| `iana_dst_smoke` | IANA DST 烟测；0 通过。 | `iana_dst_smoke` | 已符合命名；Tier-X 不 export | `dt.iana_dst_smoke(...)` |
| `timezone_smoke` | STD-135 C 金样。 | `timezone_smoke` | 已符合命名；Tier-X 不 export | `dt.timezone_smoke(...)` |


### std.db

`std/db/mod.sx` · 13 APIs · `const db = import("std.db")`


| 当前名称                      | 功能说明                                   | 简化名称                      | 说明             | 绑定调用                              |
| ------------------------- | -------------------------------------- | ------------------------- | -------------- | --------------------------------- |
| `db_open_c` | extern C/平台 | `open` | 去模块前缀+去类型名（C层） | `db.open(...)` |
| `db_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `db.close(...)` |
| `db_exec_c` | extern C/平台 | `exec` | 去模块前缀+去类型名（C层） | `db.exec(...)` |
| `db_changes_c` | extern C/平台 | `changes` | 去模块前缀+去类型名（C层） | `db.changes(...)` |
| `db_is_deprecated`        | STD-120：import("std.db") 已废弃；恒 1。      | `is_deprecated`           | 去模块前缀+去类型名     | `db.is_deprecated(...)`           |
| `open`                    | 打开数据库（转发 std.db.sqlite / db_open_c）。   | `open`                    | 已符合命名          | `db.open(...)`                    |
| `close`                   | 关闭连接。                                  | `close`                   | 已符合命名          | `db.close(...)`                   |
| `exec`                    | 执行无结果集 SQL。                            | `exec`                    | 已符合命名          | `db.exec(...)`                    |
| `changes`                 | 最近一次 exec 影响行数。                        | `changes`                 | 已符合命名          | `db.changes(...)`                 |
| `sqlite_is_available`     | SQLite 后端是否可用（委托 std.db.sqlite）。       | `sqlite_is_available`     | 已符合命名          | `db.sqlite_is_available(...)`     |
| `kv_mmap_available`       | KV mmap 引擎是否导出（委托 std.db.kv）。          | `kv_mmap_available`       | 已符合命名          | `db.kv_mmap_available(...)`       |
| `arrow_available`         | Arrow 列式模块是否导出（恒 1）。                   | `arrow_available`         | 已符合命名          | `db.arrow_available(...)`         |
| `arrow_simd_hw_available` | SIMD 是否可用于 Arrow 列计算（委托 std.db.arrow）。 | `arrow_simd_hw_available` | 已符合命名          | `db.arrow_simd_hw_available(...)` |
### std.db.arrow

`std/db/arrow/mod.sx` · 56 APIs · `const arrow = import("std.db.arrow")`


| 当前名称                             | 功能说明                                      | 简化名称                     | 说明             | 绑定调用                                |
| -------------------------------- | ----------------------------------------- | ------------------------ | -------------- | ----------------------------------- |
| `arrow_column_i32_create_c` | extern C/平台 | `column_create` | 去模块前缀+去类型名（C层） | `arrow.column_create(...)` |
| `arrow_column_f32_create_c` | extern C/平台 | `column_create` | 去模块前缀+去类型名（C层） | `arrow.column_create(...)` |
| `arrow_column_f64_create_c` | extern C/平台 | `column_create` | 去模块前缀+去类型名（C层） | `arrow.column_create(...)` |
| `arrow_column_adopt_f32_c` | extern C/平台 | `column_adopt` | 去模块前缀+去类型名（C层） | `arrow.column_adopt(...)` |
| `arrow_column_adopt_i32_c` | extern C/平台 | `column_adopt` | 去模块前缀+去类型名（C层） | `arrow.column_adopt(...)` |
| `arrow_column_type_c` | extern C/平台 | `column_type` | 去模块前缀+去类型名（C层） | `arrow.column_type(...)` |
| `arrow_column_len_c` | extern C/平台 | `column_len` | 去模块前缀+去类型名（C层） | `arrow.column_len(...)` |
| `arrow_column_capacity_c` | extern C/平台 | `column_capacity` | 去模块前缀+去类型名（C层） | `arrow.column_capacity(...)` |
| `arrow_column_data_owned_c` | extern C/平台 | `column_data_owned` | 去模块前缀+去类型名（C层） | `arrow.column_data_owned(...)` |
| `arrow_column_null_bitmap_c` | extern C/平台 | `column_null_bitmap` | 去模块前缀+去类型名（C层） | `arrow.column_null_bitmap(...)` |
| `arrow_column_is_valid_c` | extern C/平台 | `column_is_valid` | 去模块前缀+去类型名（C层） | `arrow.column_is_valid(...)` |
| `arrow_column_i32_data_c` | extern C/平台 | `column_data` | 去模块前缀+去类型名（C层） | `arrow.column_data(...)` |
| `arrow_column_f32_data_c` | extern C/平台 | `column_data` | 去模块前缀+去类型名（C层） | `arrow.column_data(...)` |
| `arrow_column_f64_data_c` | extern C/平台 | `column_data` | 去模块前缀+去类型名（C层） | `arrow.column_data(...)` |
| `arrow_column_i32_append_c` | extern C/平台 | `column_append` | 去模块前缀+去类型名（C层） | `arrow.column_append(...)` |
| `arrow_column_i32_append_null_c` | extern C/平台 | `column_append_null` | 去模块前缀+去类型名（C层） | `arrow.column_append_null(...)` |
| `arrow_column_f32_append_c` | extern C/平台 | `column_append` | 去模块前缀+去类型名（C层） | `arrow.column_append(...)` |
| `arrow_column_f64_append_c` | extern C/平台 | `column_append` | 去模块前缀+去类型名（C层） | `arrow.column_append(...)` |
| `arrow_column_destroy_c` | extern C/平台 | `column_destroy` | 去模块前缀+去类型名（C层） | `arrow.column_destroy(...)` |
| `arrow_batch_create_c` | extern C/平台 | `batch_create` | 去模块前缀+去类型名（C层） | `arrow.batch_create(...)` |
| `arrow_batch_add_column_c` | extern C/平台 | `batch_add_column` | 去模块前缀+去类型名（C层） | `arrow.batch_add_column(...)` |
| `arrow_batch_column_c` | extern C/平台 | `batch_column` | 去模块前缀+去类型名（C层） | `arrow.batch_column(...)` |
| `arrow_batch_len_c` | extern C/平台 | `batch_len` | 去模块前缀+去类型名（C层） | `arrow.batch_len(...)` |
| `arrow_batch_destroy_c` | extern C/平台 | `batch_destroy` | 去模块前缀+去类型名（C层） | `arrow.batch_destroy(...)` |
| `arrow_column_i32_sum_valid_c` | extern C/平台 | `column_sum_valid` | 去模块前缀+去类型名（C层） | `arrow.column_sum_valid(...)` |
| `arrow_column_f32_sum_c` | extern C/平台 | `column_sum` | 去模块前缀+去类型名（C层） | `arrow.column_sum(...)` |
| `arrow_column_f32_sum_valid_c` | extern C/平台 | `column_sum_valid` | 去模块前缀+去类型名（C层） | `arrow.column_sum_valid(...)` |
| `arrow_column_f32_dot_c` | extern C/平台 | `column_dot` | 去模块前缀+去类型名（C层） | `arrow.column_dot(...)` |
| `arrow_smoke_c` | extern C/平台 | `smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `arrow.smoke(...)` |
| `column_i32_new`                 | 创建 Int32 列。                               | `column_new`             | 去模块前缀+去类型名     | `arrow.column_new(...)`             |
| `column_f32_new`                 | 创建 Float32 列。                             | `column_new`             | 去模块前缀+去类型名     | `arrow.column_new(...)`             |
| `column_f64_new`                 | 创建 Float64 列。                             | `column_new`             | 去模块前缀+去类型名     | `arrow.column_new(...)`             |
| `column_adopt_f32`               | —                                         | `column_adopt`           | 去模块前缀+去类型名     | `arrow.column_adopt(...)`           |
| `column_adopt_i32`               | 零拷贝：接管外部 I32 buffer。                      | `column_adopt`           | 去模块前缀+去类型名     | `arrow.column_adopt(...)`           |
| `column_len`                     | 列当前元素个数。                                  | `column_len`             | 已符合命名          | `arrow.column_len(...)`             |
| `column_data_owned`              | data 是否由 arrow 模块拥有（adopt 列为 0）。          | `column_data_owned`      | 已符合命名          | `arrow.column_data_owned(...)`      |
| `column_null_bitmap`             | null bitmap 指针（bit=1 表示有效值）。              | `column_null_bitmap`     | 已符合命名          | `arrow.column_null_bitmap(...)`     |
| `column_is_valid`                | 索引处元素是否有效（非 null）。                        | `column_is_valid`        | 已符合命名          | `arrow.column_is_valid(...)`        |
| `column_i32_data`                | 零拷贝 Int32 data 指针。                        | `column_data`            | 语义重命名          | `arrow.column_data(...)`            |
| `column_f32_data`                | 零拷贝 Float32 data 指针。                      | `column_data`            | 语义重命名          | `arrow.column_data(...)`            |
| `column_f64_data`                | 零拷贝 Float64 data 指针。                      | `column_data`            | 语义重命名          | `arrow.column_data(...)`            |
| `column_i32_append`              | 追加 Int32（非 null）。                         | `column_append`          | 去模块前缀+去类型名     | `arrow.column_append(...)`          |
| `column_i32_append_nullable`     | 追加 Int32 并可标记 null（is_valid=0 表示 null）。   | `column_append_nullable` | 去模块前缀+去类型名     | `arrow.column_append_nullable(...)` |
| `column_f32_append`              | 追加 Float32。                               | `column_append`          | 去模块前缀+去类型名     | `arrow.column_append(...)`          |
| `column_f64_append`              | 追加 Float64。                               | `column_append`          | 去模块前缀+去类型名     | `arrow.column_append(...)`          |
| `column_destroy`                 | 释放列（adopt 列不 free 外部 data）。               | `column_destroy`         | 已符合命名          | `arrow.column_destroy(...)`         |
| `batch_new`                      | 创建 RecordBatch。                           | `batch_new`              | 已符合命名          | `arrow.batch_new(...)`              |
| `batch_add_column`               | 向 batch 添加列（batch 取得所有权）。                 | `batch_add_column`       | 已符合命名          | `arrow.batch_add_column(...)`       |
| `batch_column`                   | 按索引取列。                                    | `batch_column`           | 已符合命名          | `arrow.batch_column(...)`           |
| `batch_len`                      | batch 列数。                                 | `batch_len`              | 已符合命名          | `arrow.batch_len(...)`              |
| `batch_destroy`                  | 销毁 batch 及所含列。                            | `batch_destroy`          | 已符合命名          | `arrow.batch_destroy(...)`          |
| `column_i32_sum_valid`           | —                                         | `column_sum_valid`       | 去模块前缀+去类型名     | `arrow.column_sum_valid(...)`       |
| `column_f32_sum`                 | Float32 列前 n 元素求和（SIMD 内核）。               | `column_sum`             | 去模块前缀+去类型名     | `arrow.column_sum(...)`             |
| `column_f32_sum_valid`           | Float32 列前 n 个有效元素求和（null-aware SIMD 内核）。 | `column_sum_valid`       | 去模块前缀+去类型名     | `arrow.column_sum_valid(...)`       |
| `column_f32_dot`                 | 两列 Float32 点积 sum(a[i]*b[i])（SIMD 内核）。    | `column_dot`             | 去模块前缀+去类型名     | `arrow.column_dot(...)`             |
| `simd_hw_available`              | SIMD 硬件是否可用。                              | `simd_hw_available`      | 已符合命名          | `arrow.simd_hw_available(...)`      |


### std.db.kv

`std/db/kv/mod.sx` · 24 APIs · `const kv = import("std.db.kv")`


| 当前名称                      | 功能说明                                                     | 简化名称                 | 说明             | 绑定调用                         |
| ------------------------- | -------------------------------------------------------- | -------------------- | -------------- | ---------------------------- |
| `db_kv_open_c` | extern C/平台 | `open` | 二次精简：去对象前缀 | `kv.open(...)` |
| `db_kv_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `kv.close(...)` |
| `db_kv_sync_c` | extern C/平台 | `sync` | 二次精简：去对象前缀 | `kv.sync(...)` |
| `db_kv_put_c` | extern C/平台 | `put` | 二次精简：去对象前缀 | `kv.put(...)` |
| `db_kv_append_ts_c` | extern C/平台 | `append_ts` | 二次精简：去对象前缀 | `kv.append_ts(...)` |
| `db_kv_get_c` | extern C/平台 | `get` | 二次精简：去对象前缀 | `kv.get(...)` |
| `db_kv_wal_flush_c` | extern C/平台 | `wal_flush` | 二次精简：去对象前缀 | `kv.wal_flush(...)` |
| `db_kv_compact_c` | extern C/平台 | `compact` | 去模块前缀+去类型名（C层） | `kv.compact(...)` |
| `db_kv_compact_gen_c` | extern C/平台 | `compact_gen` | 去模块前缀+去类型名（C层） | `kv.compact_gen(...)` |
| `db_kv_wal_bytes_c` | extern C/平台 | `wal_bytes` | 二次精简：去对象前缀 | `kv.wal_bytes(...)` |
| `db_kv_sst_level_count_c` | extern C/平台 | `sst_level_count` | 去模块前缀+去类型名（C层） | `kv.sst_level_count(...)` |
| `db_kv_smoke_c` | extern C/平台 | `smoke` | 二次精简：去对象前缀；Tier-X 不 export | `kv.smoke(...)` |
| `mmap_available`          | mmap 子系统是否可用（委托 std.sys.mmap）。                           | `mmap_available`     | 已符合命名          | `kv.mmap_available(...)`     |
| `open`                    | 打开/创建 mmap KV + WAL（path.wal）；capacity_bytes 建议 ≥ 64KiB。 | `open`               | 已符合命名          | `kv.open(...)`               |
| `close`                   | 关闭并 munmap 主文件与 WAL。                                     | `close`              | 已符合命名          | `kv.close(...)`              |
| `sync`                    | msync 刷盘（主文件 + WAL）。                                     | `sync`               | 已符合命名          | `kv.sync(...)`               |
| `put`                     | 写入键值（ts_ns=0）；热路径写 WAL 层。                                | `put`                | 已符合命名          | `kv.put(...)`                |
| `append_ts`               | —                                                        | `append_ts`          | 已符合命名          | `kv.append_ts(...)`          |
| `get`                     | 读取最新值；成功返回字节数，KV_ERR_NOT_FOUND 等 <0。                     | `get`                | 已符合命名          | `kv.get(...)`                |
| `wal_flush`               | WAL 刷入主文件（L0→L1 分层合并）。                                   | `wal_flush`          | 已符合命名          | `kv.wal_flush(...)`          |
| `compact`                 | LSM 压实：主文件去重保留最新 key，清空 WAL。                             | `compact`            | 已符合命名          | `kv.compact(...)`            |
| `compact_generation`      | 压实世代号（每次 compact +1）。                                    | `compact_generation` | 已符合命名          | `kv.compact_generation(...)` |
| `wal_bytes`               | 当前 WAL 区已用字节数（不含 4KiB 头）。                                | `wal_bytes`          | 已符合命名          | `kv.wal_bytes(...)`          |
| `sst_level_count`         | 已冻结 SST 层数（L2+ 侧车 *.sst.N；compact 后递增）。                  | `sst_level_count`    | 已符合命名          | `kv.sst_level_count(...)`    |


### std.db.sqlite

`std/db/sqlite/mod.sx` · 68 APIs · `const sqlite = import("std.db.sqlite")`


| 当前名称                     | 功能说明                                                    | 简化名称              | 说明             | 绑定调用                          |
| ------------------------ | ------------------------------------------------------- | ----------------- | -------------- | ----------------------------- |
| `db_open_c` | extern C/平台 | `open` | 二次精简：去对象前缀 | `sqlite.open(...)` |
| `db_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `sqlite.close(...)` |
| `db_exec_c` | extern C/平台 | `exec` | 二次精简：去对象前缀 | `sqlite.exec(...)` |
| `db_query_rows_c` | extern C/平台 | `rows` | 二次精简：去对象前缀 | `sqlite.rows(...)` |
| `db_query_begin_c` | extern C/平台 | `begin` | 二次精简：去对象前缀 | `sqlite.begin(...)` |
| `db_next_row_c` | extern C/平台 | `next_row` | 二次精简：去对象前缀 | `sqlite.next_row(...)` |
| `db_row_col_i32_c` | extern C/平台 | `col` | 去模块前缀+去类型名（C层） | `sqlite.col(...)` |
| `db_row_col_text_c` | extern C/平台 | `col_text` | 去模块前缀+去类型名（C层） | `sqlite.col_text(...)` |
| `db_row_col_blob_c` | extern C/平台 | `col_blob` | 去模块前缀+去类型名（C层） | `sqlite.col_blob(...)` |
| `db_row_col_blob_len_c` | extern C/平台 | `col_blob_len` | 去模块前缀+去类型名（C层） | `sqlite.col_blob_len(...)` |
| `db_row_col_blob_read_c` | extern C/平台 | `col_blob_read` | 去模块前缀+去类型名（C层） | `sqlite.col_blob_read(...)` |
| `db_query_end_c` | extern C/平台 | `end` | 二次精简：去对象前缀 | `sqlite.end(...)` |
| `db_begin_tx_c` | extern C/平台 | `begin_tx` | 二次精简：去对象前缀 | `sqlite.begin_tx(...)` |
| `db_commit_c` | extern C/平台 | `commit` | 去模块前缀+去类型名（C层） | `sqlite.commit(...)` |
| `db_rollback_c` | extern C/平台 | `rollback` | 二次精简：去对象前缀 | `sqlite.rollback(...)` |
| `db_last_error_code_c` | extern C/平台 | `last_error_code` | 去模块前缀+去类型名（C层） | `sqlite.last_error_code(...)` |
| `db_last_error_msg_c` | extern C/平台 | `last_error_msg` | 二次精简：去对象前缀 | `sqlite.last_error_msg(...)` |
| `db_backend_name_c` | extern C/平台 | `backend_name` | 二次精简：去对象前缀 | `sqlite.backend_name(...)` |
| `db_changes_c` | extern C/平台 | `changes` | 去模块前缀+去类型名（C层） | `sqlite.changes(...)` |
| `db_prepare_c` | extern C/平台 | `prepare` | 二次精简：去对象前缀 | `sqlite.prepare(...)` |
| `db_prepare_cached_c` | extern C/平台 | `prepare_cached` | 去模块前缀+去类型名（C层） | `sqlite.prepare_cached(...)` |
| `db_stmt_bind_i32_c` | extern C/平台 | `bind` | 去模块前缀+去类型名（C层） | `sqlite.bind(...)` |
| `db_stmt_bind_text_c` | extern C/平台 | `bind_text` | 二次精简：去对象前缀 | `sqlite.bind_text(...)` |
| `db_stmt_step_c` | extern C/平台 | `step` | 二次精简：去对象前缀 | `sqlite.step(...)` |
| `db_stmt_reset_c` | extern C/平台 | `reset` | 二次精简：去对象前缀 | `sqlite.reset(...)` |
| `db_stmt_finalize_c` | extern C/平台 | `finalize` | 二次精简：去对象前缀 | `sqlite.finalize(...)` |
| `db_stmt_cache_clear_c` | extern C/平台 | `cache_clear` | 去模块前缀+去类型名（C层） | `sqlite.cache_clear(...)` |
| `db_pool_open_c` | extern C/平台 | `open` | 二次精简：去对象前缀 | `sqlite.open(...)` |
| `db_pool_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `sqlite.close(...)` |
| `db_pool_acquire_c` | extern C/平台 | `acquire` | 二次精简：去对象前缀 | `sqlite.acquire(...)` |
| `db_pool_release_c` | extern C/平台 | `release` | 二次精简：去对象前缀 | `sqlite.release(...)` |
| `db_pool_idle_c` | extern C/平台 | `idle` | 二次精简：去对象前缀 | `sqlite.idle(...)` |
| `open`                   | 打开数据库文件路径（UTF-8 C 串）；失败 handle=0。                       | `open`            | 已符合命名          | `sqlite.open(...)`            |
| `close`                  | 关闭连接。                                                   | `close`           | 已符合命名          | `sqlite.close(...)`           |
| `exec`                   | 执行无结果集 SQL（DDL/DML）。                                    | `exec`            | 已符合命名          | `sqlite.exec(...)`            |
| `query_rows`             | 执行查询并返回匹配行数（v1 原型：sqlite3 回调迭代计数）。                      | `rows`            | 二次精简：去对象前缀     | `sqlite.rows(...)`            |
| `query_begin`            | 准备 SELECT 游标；失败 cursor=0。                               | `begin`           | 二次精简：去对象前缀     | `sqlite.begin(...)`           |
| `next_row`               | 推进游标：DB_ROW_OK=有行，DB_ROW_DONE=结束，<0=错误。                 | `next_row`        | 已符合命名          | `sqlite.next_row(...)`        |
| `row_col_i32`            | 读取当前行列值（i32）。                                           | `col`             | 去模块前缀+去类型名     | `sqlite.col(...)`             |
| `row_col_text`           | 读取当前行文本列到 out（UTF-8）；成功返回字节长度，<0 为错误。                   | `col_text`        | 二次精简：去对象前缀     | `sqlite.col_text(...)`        |
| `row_col_blob`           | 读取当前行 BLOB 列到 out；成功返回字节长度，<0 为错误。                      | `col_blob`        | 二次精简：去对象前缀     | `sqlite.col_blob(...)`        |
| `row_col_blob_len`       | 返回当前行 BLOB 列总字节数（NULL/空列返回 0）。                          | `col_blob_len`    | 二次精简：去对象前缀     | `sqlite.col_blob_len(...)`    |
| `row_col_blob_read`      | 分块读取 BLOB 列：从 offset 起最多 cap 字节；返回写入字节数。                | `col_blob_read`   | 二次精简：去对象前缀     | `sqlite.col_blob_read(...)`   |
| `query_end`              | 释放游标。                                                   | `end`             | 二次精简：去对象前缀     | `sqlite.end(...)`             |
| `begin_tx`               | 开始显式事务。                                                 | `begin_tx`        | 已符合命名          | `sqlite.begin_tx(...)`        |
| `commit`                 | 提交事务。                                                   | `commit`          | 已符合命名          | `sqlite.commit(...)`          |
| `rollback`               | 回滚事务。                                                   | `rollback`        | 已符合命名          | `sqlite.rollback(...)`        |
| `last_error`             | 读取线程局部最后一次库错误。                                          | `last_os_error`   | 语义重命名          | `sqlite.last_os_error(...)`   |
| `backend_name`           | 当前链接后端名称（"sqlite3" 或 "stub"）。                           | `backend_name`    | 已符合命名          | `sqlite.backend_name(...)`    |
| `changes`                | 最近一次 exec 影响行数（SQLite 路径）。                              | `changes`         | 已符合命名          | `sqlite.changes(...)`         |
| `prepare`                | 预编译 SQL（须 stmt_finalize 释放；不入连接缓存）。                     | `prepare`         | 已符合命名          | `sqlite.prepare(...)`         |
| `prepare_cached`         | 预编译并缓存（同连接同 SQL 复用；关闭连接或 stmt_cache_clear 失效）。          | `prepare_cached`  | 已符合命名          | `sqlite.prepare_cached(...)`  |
| `stmt_bind_i32`          | 绑定整型参数（idx 从 1 起，SQLite 约定）。                            | `bind`            | 去模块前缀+去类型名     | `sqlite.bind(...)`            |
| `stmt_bind_text`         | 绑定 UTF-8 文本参数（idx 从 1 起）。                               | `bind_text`       | 二次精简：去对象前缀     | `sqlite.bind_text(...)`       |
| `stmt_step`              | 执行预编译一步：DB_ROW_OK=有行，DB_ROW_DONE=完成，<0=错误。              | `step`            | 二次精简：去对象前缀     | `sqlite.step(...)`            |
| `stmt_reset`             | 重置预编译语句以便再次 bind/step。                                  | `reset`           | 二次精简：去对象前缀     | `sqlite.reset(...)`           |
| `stmt_finalize`          | 释放预编译语句（缓存项一并移除）。                                       | `finalize`        | 二次精简：去对象前缀     | `sqlite.finalize(...)`        |
| `stmt_cache_clear`       | 清空连接上全部 stmt 缓存（不关闭连接）。                                 | `cache_clear`     | 二次精简：去对象前缀     | `sqlite.cache_clear(...)`     |
| `stmt_col_i32`           | 读预编译当前行列值（i32）；须先 stmt_step 返回 DB_ROW_OK。               | `col`             | 去模块前缀+去类型名     | `sqlite.col(...)`             |
| `stmt_col_text`          | 读预编译当前行文本列；须先 stmt_step 返回 DB_ROW_OK。                   | `col_text`        | 二次精简：去对象前缀     | `sqlite.col_text(...)`        |
| `stmt_col_blob_len`      | 读预编译当前行 BLOB 列总字节数。                                     | `col_blob_len`    | 二次精简：去对象前缀     | `sqlite.col_blob_len(...)`    |
| `stmt_col_blob_read`     | 分块读预编译当前行 BLOB 列。                                       | `col_blob_read`   | 二次精简：去对象前缀     | `sqlite.col_blob_read(...)`   |
| `pool_open`              | 打开连接池（惰性建连；max_conns 上限 8）。                             | `open`            | 二次精简：去对象前缀     | `sqlite.open(...)`            |
| `pool_close`             | 关闭连接池（须先 release 全部借出连接）。                               | `close`           | 二次精简：去对象前缀     | `sqlite.close(...)`           |
| `pool_acquire`           | 从池借连接；失败 handle=0（池耗尽时为 DB_ERR_BUSY）。                   | `acquire`         | 二次精简：去对象前缀     | `sqlite.acquire(...)`         |
| `pool_release`           | 归还连接到池 idle 队列。                                         | `release`         | 二次精简：去对象前缀     | `sqlite.release(...)`         |
| `pool_idle`              | 当前 idle 连接数（烟测/诊断）。                                     | `idle`            | 二次精简：去对象前缀     | `sqlite.idle(...)`            |
| `sqlite_is_available`    | STD-167：SQLite 后端是否可用（"sqlite3" 全量 vs "stub"）；1 可用，0 桩。 | `is_available`    | 去模块前缀+去类型名     | `sqlite.is_available(...)`    |


### std.dynlib

`std/dynlib/mod.sx` · 8 APIs · `const dynlib = import("std.dynlib")`


| 当前名称                       | 功能说明                                                                                                           | 简化名称              | 说明             | 绑定调用                          |
| -------------------------- | -------------------------------------------------------------------------------------------------------------- | ----------------- | -------------- | ----------------------------- |
| `dynlib_open_c` | std.dynlib — 动态加载 .so/.dll（对标 Zig std.DynLib、Rust libloading） 【文件职责】open(path)、sym(lib, name)、close(lib)。按需链接。 | `open` | 去模块前缀+去类型名（C层） | `dynlib.open(...)` |
| `dynlib_sym_c` | extern C/平台 | `sym` | 去模块前缀+去类型名（C层） | `dynlib.sym(...)` |
| `dynlib_close_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `dynlib.close(...)` |
| `dynlib_last_error_copy_c` | extern C/平台                                                                                                    | `last_error_copy` | 去模块前缀+去类型名（C层） | `dynlib.last_error_copy(...)` |
| `open`                     | 打开动态库 path（NUL 结尾）；失败返回 0。                                                                                     | `open`            | 已符合命名          | `dynlib.open(...)`            |
| `sym`                      | 取符号 name（NUL 结尾）；失败返回 0。                                                                                       | `sym`             | 已符合命名          | `dynlib.sym(...)`             |
| `close`                    | 关闭动态库。                                                                                                         | `close`           | 已符合命名          | `dynlib.close(...)`           |
| `last_error`               | 复制最近一次 open/sym 失败诊断到 buf；返回写入字节数，无内容返回 0（STD-096）。                                                            | `last_os_error`   | 语义重命名          | `dynlib.last_os_error(...)`   |


### std.elf

`std/elf/mod.sx` · 29 APIs · `const elf = import("std.elf")`


| 当前名称                           | 功能说明                   | 简化名称                         | 说明         | 绑定调用                                  |
| ------------------------------ | ---------------------- | ---------------------------- | ---------- | ------------------------------------- |
| `elf64_parse_hdr_c` | extern C/平台 | `elf64_parse_hdr` | 已符合命名 | `elf.elf64_parse_hdr(...)` |
| `elf64_read_phdr_c` | extern C/平台 | `elf64_read_phdr` | 已符合命名 | `elf.elf64_read_phdr(...)` |
| `elf64_read_shdr_c` | extern C/平台 | `elf64_read_shdr` | 已符合命名 | `elf.elf64_read_shdr(...)` |
| `elf64_sec_name_c` | extern C/平台 | `elf64_sec_name` | 已符合命名 | `elf.elf64_sec_name(...)` |
| `elf64_find_section_c` | extern C/平台 | `elf64_find_section` | 已符合命名 | `elf.elf64_find_section(...)` |
| `elf64_read_sec_byte_c` | extern C/平台 | `elf64_read_sec_byte` | 已符合命名 | `elf.elf64_read_sec_byte(...)` |
| `elf64_read_sym_c` | extern C/平台 | `elf64_read_sym` | 已符合命名 | `elf.elf64_read_sym(...)` |
| `elf64_read_rela_c` | extern C/平台 | `elf64_read_rela` | 已符合命名 | `elf.elf64_read_rela(...)` |
| `elf64_write_min_reloc_size_c` | extern C/平台            | `elf64_write_min_reloc_size` | 已符合命名 | `elf.elf64_write_min_reloc_size(...)` |
| `elf64_write_min_reloc_c` | extern C/平台 | `elf64_write_min_reloc` | 已符合命名 | `elf.elf64_write_min_reloc(...)` |
| `elf64_write_smoke_c` | extern C/平台 | `elf64_write_smoke` | 已符合命名；Tier-X 不 export | `elf.elf64_write_smoke(...)` |
| `elf64_parse_smoke_c` | extern C/平台 | `elf64_parse_smoke` | 已符合命名；Tier-X 不 export | `elf.elf64_parse_smoke(...)` |
| `elf_is_implemented`           | ELF 模块已实现（对接 elf.c）。   | `is_implemented`             | 去模块前缀+去类型名 | `elf.is_implemented(...)`             |
| `parse_hdr`                    | 解析 ELF64 文件头。          | `parse_hdr`                  | 已符合命名      | `elf.parse_hdr(...)`                  |
| `read_section`                 | 读取第 idx 个 section 头。   | `read_section`               | 已符合命名      | `elf.read_section(...)`               |
| `sec_name`                     | 从 shstrtab 取节名。        | `sec_name`                   | 已符合命名      | `elf.sec_name(...)`                   |
| `find_section_idx`             | 按节名查找索引。               | `find_section_idx`           | 已符合命名      | `elf.find_section_idx(...)`           |
| `read_sec_byte`                | 读取节体内字节。               | `read_sec_byte`              | 已符合命名      | `elf.read_sec_byte(...)`              |
| `read_phdr`                    | 读取 program 头。          | `read_phdr`                  | 已符合命名      | `elf.read_phdr(...)`                  |
| `read_sym`                     | 读取 symtab 条目。          | `read_sym`                   | 已符合命名      | `elf.read_sym(...)`                   |
| `sym_name`                     | 从 strtab 节取符号名。        | `sym_name`                   | 已符合命名      | `elf.sym_name(...)`                   |
| `symtab_entry_count`           | symtab 条目数（每符号 24 字节）。 | `symtab_entry_count`         | 已符合命名      | `elf.symtab_entry_count(...)`         |
| `read_rela`                    | 读取 rela 条目。            | `read_rela`                  | 已符合命名      | `elf.read_rela(...)`                  |
| `rela_entry_count`             | rela 条目数。              | `rela_entry_count`           | 已符合命名      | `elf.rela_entry_count(...)`           |
| `elf_write_err_ok`             | write_min_reloc 成功码。   | `write_err_ok`               | 去模块前缀+去类型名 | `elf.write_err_ok(...)`               |
| `write_min_reloc_size`         | —                      | `write_min_reloc_size`       | 已符合命名      | `elf.write_min_reloc_size(...)`       |
| `write_min_reloc`              | —                      | `write_min_reloc`            | 已符合命名      | `elf.write_min_reloc(...)`            |
| `write_smoke` | — | `write_smoke` | 已符合命名；Tier-X 不 export | `elf.write_smoke(...)` |
| `parse_smoke` | — | `parse_smoke` | 已符合命名；Tier-X 不 export | `elf.parse_smoke(...)` |


### std.encoding

`std/encoding/mod.sx` · 47 APIs · `const enc = import("std.encoding")`


| 当前名称                          | 功能说明                                                  | 简化名称                       | 说明             | 绑定调用                                |
| ----------------------------- | ----------------------------------------------------- | -------------------------- | -------------- | ----------------------------------- |
| `encoding_utf8_valid_c` | extern C/平台 | `utf8_valid` | 去模块前缀+去类型名（C层） | `enc.utf8_valid(...)` |
| `encoding_utf8_len_chars_c` | extern C/平台 | `utf8_len_chars` | 去模块前缀+去类型名（C层） | `enc.utf8_len_chars(...)` |
| `encoding_utf8_encode_rune_c` | extern C/平台 | `utf8_encode_rune` | 去模块前缀+去类型名（C层） | `enc.utf8_encode_rune(...)` |
| `encoding_utf8_decode_rune_c` | extern C/平台 | `utf8_decode_rune` | 去模块前缀+去类型名（C层） | `enc.utf8_decode_rune(...)` |
| `encoding_ascii_is_alpha_c` | extern C/平台 | `ascii_is_alpha` | 去模块前缀+去类型名（C层） | `enc.ascii_is_alpha(...)` |
| `encoding_ascii_is_digit_c` | extern C/平台 | `ascii_is_digit` | 去模块前缀+去类型名（C层） | `enc.ascii_is_digit(...)` |
| `encoding_ascii_is_alnum_c` | extern C/平台 | `ascii_is_alnum` | 去模块前缀+去类型名（C层） | `enc.ascii_is_alnum(...)` |
| `encoding_ascii_is_lower_c` | extern C/平台 | `ascii_is_lower` | 去模块前缀+去类型名（C层） | `enc.ascii_is_lower(...)` |
| `encoding_ascii_is_upper_c` | extern C/平台 | `ascii_is_upper` | 去模块前缀+去类型名（C层） | `enc.ascii_is_upper(...)` |
| `encoding_ascii_to_lower_c` | extern C/平台 | `ascii_to_lower` | 去模块前缀+去类型名（C层） | `enc.ascii_to_lower(...)` |
| `encoding_ascii_to_upper_c` | extern C/平台 | `ascii_to_upper` | 去模块前缀+去类型名（C层） | `enc.ascii_to_upper(...)` |
| `utf8_valid`                  | UTF-8 校验 ptr[0..len)；合法返回 1，非法返回 0。单遍、表驱动。            | `utf8_valid`               | 已符合命名          | `enc.utf8_valid(...)`               |
| `utf8_len_chars`              | UTF-8 码点个数；非法序列返回 -1。                                 | `utf8_len_chars`           | 已符合命名          | `enc.utf8_len_chars(...)`           |
| `utf8_encode_rune`            | 将码点 r 编码到 out，返回写入字节数 1..4，非法 r 返回 0。                 | `utf8_encode_rune`         | 已符合命名          | `enc.utf8_encode_rune(...)`         |
| `utf8_decode_rune`            | 从 ptr 解码一个 rune 到 *out_r，返回消费字节数 1..4，非法返回 0。         | `utf8_decode_rune`         | 已符合命名          | `enc.utf8_decode_rune(...)`         |
| `ascii_is_alpha`              | —                                                     | `ascii_is_alpha`           | 已符合命名          | `enc.ascii_is_alpha(...)`           |
| `ascii_is_digit`              | —                                                     | `ascii_is_digit`           | 已符合命名          | `enc.ascii_is_digit(...)`           |
| `ascii_is_alnum`              | —                                                     | `ascii_is_alnum`           | 已符合命名          | `enc.ascii_is_alnum(...)`           |
| `ascii_is_lower`              | —                                                     | `ascii_is_lower`           | 已符合命名          | `enc.ascii_is_lower(...)`           |
| `ascii_is_upper`              | —                                                     | `ascii_is_upper`           | 已符合命名          | `enc.ascii_is_upper(...)`           |
| `ascii_to_lower`              | —                                                     | `ascii_to_lower`           | 已符合命名          | `enc.ascii_to_lower(...)`           |
| `ascii_to_upper`              | —                                                     | `ascii_to_upper`           | 已符合命名          | `enc.ascii_to_upper(...)`           |
| `encoding_hex_encode_c` | extern C/平台 | `hex_encode` | 去模块前缀+去类型名（C层） | `enc.hex_encode(...)` |
| `encoding_hex_decode_c` | extern C/平台 | `hex_decode` | 去模块前缀+去类型名（C层） | `enc.hex_decode(...)` |
| `encoding_hex_encoded_len_c` | extern C/平台 | `hex_encoded_len` | 去模块前缀+去类型名（C层） | `enc.hex_encoded_len(...)` |
| `hex_encode`                  | 原始字节缓冲 hex 编码（小写）；返回写入字符数或 -1（STD-040）。               | `hex_encode`               | 已符合命名          | `enc.hex_encode(...)`               |
| `hex_decode`                  | hex 解码；返回写入字节数，非法输入 -1。                               | `hex_decode`               | 已符合命名          | `enc.hex_decode(...)`               |
| `hex_encoded_len`             | hex 编码输出长度上界（src_len 为输入字节数）。                         | `hex_encoded_len`          | 已符合命名          | `enc.hex_encoded_len(...)`          |
| `hex_decoded_len`             | hex 解码输出字节数上界（hex_len 为 hex 字符数；奇数或负返回 -1）。           | `hex_decoded_len`          | 已符合命名          | `enc.hex_decoded_len(...)`          |
| `encode_hex_string`           | 将原始字节 hex 编码写入 String（清空后写入）；成功 0，失败 -1（STD-040）。     | `encode_hex_string`        | 已符合命名          | `enc.encode_hex_string(...)`        |
| `decode_hex_string`           | 从 StrView hex 解码到 out 缓冲；返回写入字节数，非法 -1（STD-040）。      | `decode_hex_string`        | 已符合命名          | `enc.decode_hex_string(...)`        |
| `encode_base64_string`        | 将原始字节标准 Base64 编码写入 String；成功 0，失败 -1（委托 std.base64）。 | `encode_base64_string`     | 已符合命名          | `enc.encode_base64_string(...)`     |
| `decode_base64_string`        | 从 StrView 标准 Base64 解码；返回写入字节数，非法 -1（委托 std.base64）。  | `decode_base64_string`     | 已符合命名          | `enc.decode_base64_string(...)`     |
| `encoding_base32_encode_c` | extern C/平台 | `base32_encode` | 去模块前缀+去类型名（C层） | `enc.base32_encode(...)` |
| `encoding_base32_decode_c` | extern C/平台 | `base32_decode` | 去模块前缀+去类型名（C层） | `enc.base32_decode(...)` |
| `encoding_percent_encode_c` | extern C/平台 | `percent_encode` | 去模块前缀+去类型名（C层） | `enc.percent_encode(...)` |
| `encoding_percent_decode_c` | extern C/平台 | `percent_decode` | 去模块前缀+去类型名（C层） | `enc.percent_decode(...)` |
| `encoding_extra_smoke_c` | extern C/平台 | `extra_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `enc.extra_smoke(...)` |
| `base32_encode`               | RFC 4648 Base32 编码（含填充）；返回写入字符数，失败 -1。                | `base32_encode`            | 已符合命名          | `enc.base32_encode(...)`            |
| `base32_decode`               | RFC 4648 Base32 解码；返回写入字节数，非法 -1。                     | `base32_decode`            | 已符合命名          | `enc.base32_decode(...)`            |
| `percent_encode`              | percent 编码（unreserved 保留）；返回写入长度，失败 -1。               | `percent_encode`           | 已符合命名          | `enc.percent_encode(...)`           |
| `percent_decode`              | percent 解码；返回写入字节数，非法 -1。                             | `percent_decode`           | 已符合命名          | `enc.percent_decode(...)`           |
| `encode_base32_string`        | 将原始字节 Base32 编码写入 String；成功 0，失败 -1。                  | `encode_base32_string`     | 已符合命名          | `enc.encode_base32_string(...)`     |
| `decode_base32_string`        | 从 StrView Base32 解码；返回写入字节数，非法 -1。                    | `decode_base32_string`     | 已符合命名          | `enc.decode_base32_string(...)`     |
| `encode_url_base64_string`    | 将原始字节 URL Base64 编码写入 String；成功 0，失败 -1。              | `encode_url_base64_string` | 已符合命名          | `enc.encode_url_base64_string(...)` |
| `decode_url_base64_string`    | 从 StrView URL Base64 解码；返回写入字节数，非法 -1。                | `decode_url_base64_string` | 已符合命名          | `enc.decode_url_base64_string(...)` |
| `encoding_extra_smoke` | STD-127 C 烟测门面；成功 0。 | `extra_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `enc.extra_smoke(...)` |


### std.env

`std/env/mod.sx` · 24 APIs · `const env = import("std.env")`


| 当前名称                  | 功能说明                                             | 简化名称              | 说明             | 绑定调用                       |
| --------------------- | ------------------------------------------------ | ----------------- | -------------- | -------------------------- |
| `env_getenv_c` | std.env — 环境变量与临时目录（对标 Zig/Rust std.env） 【文件职责】 | `getenv` | 去模块前缀+去类型名（C层） | `env.getenv(...)` |
| `env_getenv_ptr_c` | extern C/平台 | `getenv_ptr` | 去模块前缀+去类型名（C层） | `env.getenv_ptr(...)` |
| `env_getenv_z_c` | extern C/平台 | `getenv_z` | 去模块前缀+去类型名（C层） | `env.getenv_z(...)` |
| `env_getenv_exists_c` | extern C/平台 | `getenv_exists` | 去模块前缀+去类型名（C层） | `env.getenv_exists(...)` |
| `env_setenv_c` | extern C/平台 | `setenv` | 去模块前缀+去类型名（C层） | `env.setenv(...)` |
| `env_unsetenv_c` | extern C/平台 | `unsetenv` | 去模块前缀+去类型名（C层） | `env.unsetenv(...)` |
| `env_temp_dir_c` | extern C/平台 | `temp_dir` | 去模块前缀+去类型名（C层） | `env.temp_dir(...)` |
| `getenv`              | —                                                | `getenv`          | 已符合命名          | `env.getenv(...)`          |
| `getenv_ptr`          | —                                                | `getenv_ptr`      | 已符合命名          | `env.getenv_ptr(...)`      |
| `getenv_z`            | —                                                | `getenv_z`        | 已符合命名          | `env.getenv_z(...)`        |
| `getenv_exists`       | —                                                | `getenv_exists`   | 已符合命名          | `env.getenv_exists(...)`   |
| `setenv`              | —                                                | `setenv`          | 已符合命名          | `env.setenv(...)`          |
| `unsetenv`            | 删除环境变量 name（NUL 结尾）。返回 0 成功，-1 失败。对标 remove_var。 | `unsetenv`        | 已符合命名          | `env.unsetenv(...)`        |
| `temp_dir`            | —                                                | `temp_dir`        | 已符合命名          | `env.temp_dir(...)`        |
| `env_iter_count_c` | extern C/平台 | `iter_count` | 去模块前缀+去类型名（C层） | `env.iter_count(...)` |
| `env_iter_at_c` | extern C/平台 | `iter_at` | 去模块前缀+去类型名（C层） | `env.iter_at(...)` |
| `args_iter_count_c` | extern C/平台 | `args_iter_count` | 去模块前缀+去类型名（C层） | `env.args_iter_count(...)` |
| `args_iter_at_c` | extern C/平台 | `args_iter_at` | 已符合命名 | `env.args_iter_at(...)` |
| `env_iter`            | 创建环境变量迭代器（从 0 开始）。                               | `iter`            | 去模块前缀+去类型名     | `env.iter(...)`            |
| `env_iter_count`      | 当前进程环境变量条目数。                                     | `iter_count`      | 去模块前缀+去类型名     | `env.iter_count(...)`      |
| `env_iter_next`       | 读取下一环境变量；成功 1，结束 0，错误 -1。缓冲不足时跳过该条目。             | `iter_next`       | 去模块前缀+去类型名     | `env.iter_next(...)`       |
| `args_iter`           | 创建命令行参数迭代器。                                      | `args_iter`       | 已符合命名          | `env.args_iter(...)`       |
| `args_iter_count`     | 命令行参数个数（含 argv[0]）。                              | `args_iter_count` | 已符合命名          | `env.args_iter_count(...)` |
| `args_iter_next`      | 读取下一 argv 指针；结束返回 0。                             | `args_iter_next`  | 已符合命名          | `env.args_iter_next(...)`  |


### std.error

`std/error/mod.sx` · 56 APIs · `const err = import("std.error")`


| 当前名称                           | 功能说明                                     | 简化名称                     | 说明         | 绑定调用                              |
| ------------------------------ | ---------------------------------------- | ------------------------ | ---------- | --------------------------------- |
| `error_ok`                     | —                                        | `ok`                     | 去模块前缀+去类型名 | `err.ok(...)`                     |
| `error_code_alloc_fail`        | 常用错误码：分配失败（与 std.heap/vec/map 一致）。       | `code_alloc_fail`        | 去模块前缀+去类型名 | `err.code_alloc_fail(...)`        |
| `error_code_invalid`           | 常用错误码：无效参数或越界。                           | `code_invalid`           | 去模块前缀+去类型名 | `err.code_invalid(...)`           |
| `error_code_not_found`         | 常用错误码：未找到（如 map get 无默认、文件不存在等）。         | `code_not_found`         | 去模块前缀+去类型名 | `err.code_not_found(...)`         |
| `error_ok_value`               | 构造“无错误”。                                 | `ok_value`               | 去模块前缀+去类型名 | `err.ok_value(...)`               |
| `error_from_code`              | 从错误码构造 Error。                            | `from_code`              | 去模块前缀+去类型名 | `err.from_code(...)`              |
| `error_code`                   | 取错误码。                                    | `code`                   | 去模块前缀+去类型名 | `err.code(...)`                   |
| `error_is_ok`                  | 是否表示成功（code == 0）。返回 1 是，0 否。            | `is_ok`                  | 去模块前缀+去类型名 | `err.is_ok(...)`                  |
| `error_is_err`                 | 是否表示错误（code != 0）。返回 1 是，0 否。            | `is_err`                 | 去模块前缀+去类型名 | `err.is_err(...)`                 |
| `error_base_io`                | std.io 模块错误段起点。                          | `base_io`                | 去模块前缀+去类型名 | `err.base_io(...)`                |
| `io_err_timeout`               | I/O 超时（Context deadline 或 wait 超时）。      | `timeout`                | 语义重命名      | `err.timeout(...)`                |
| `io_err_cancelled`             | I/O 已取消（Context cancel）。                 | `cancelled`              | 语义重命名      | `err.cancelled(...)`              |
| `io_err_generic`               | std.io 模块通用错误码（段起点占位，STD-011 / EXC-003）。 | `generic`                | 去模块前缀+去类型名 | `err.generic(...)`                |
| `error_base_net`               | std.net 模块错误段起点。                         | `base_net`               | 去模块前缀+去类型名 | `err.base_net(...)`               |
| `net_err_timeout`              | 网络操作超时。                                  | `timeout`                | 去模块前缀+去类型名 | `err.timeout(...)`                |
| `net_err_cancelled`            | 网络操作已取消。                                 | `cancelled`              | 去模块前缀+去类型名 | `err.cancelled(...)`              |
| `net_err_generic`              | std.net 模块通用错误码（段起点占位，STD-011）。          | `generic`                | 去模块前缀+去类型名 | `err.generic(...)`                |
| `error_base_async`             | std.async 模块错误段起点（EXC-003）。              | `base_async`             | 去模块前缀+去类型名 | `err.base_async(...)`             |
| `async_err_generic`            | std.async 模块通用错误码占位。                     | `generic`                | 去模块前缀+去类型名 | `err.generic(...)`                |
| `error_base_coll`              | std.coll（vec/map/heap）模块错误段起点（EXC-003）。  | `base_coll`              | 去模块前缀+去类型名 | `err.base_coll(...)`              |
| `coll_err_generic`             | std.coll 模块通用错误码占位。                      | `coll_err_generic`       | 已符合命名      | `err.coll_err_generic(...)`       |
| `error_base_fs`                | std.fs 模块错误段起点。                          | `base_fs`                | 去模块前缀+去类型名 | `err.base_fs(...)`                |
| `fs_err_not_found`             | 文件/路径不存在。                                | `not_found`              | 去模块前缀+去类型名 | `err.not_found(...)`              |
| `error_mod_tag_io`             | 模块标签：std.io。                             | `mod_tag_io`             | 去模块前缀+去类型名 | `err.mod_tag_io(...)`             |
| `error_mod_tag_fs`             | 模块标签：std.fs。                             | `mod_tag_fs`             | 去模块前缀+去类型名 | `err.mod_tag_fs(...)`             |
| `error_mod_tag_db`             | 模块标签：std.db（无 B 层 base v1）。              | `mod_tag_db`             | 去模块前缀+去类型名 | `err.mod_tag_db(...)`             |
| `error_sidecar_none`           | 侧车种类：无。                                  | `sidecar_none`           | 去模块前缀+去类型名 | `err.sidecar_none(...)`           |
| `error_sidecar_errno_i32`      | 侧车种类：errno i32（如 fs_last_error）。         | `sidecar_errno`          | 去模块前缀+去类型名 | `err.sidecar_errno(...)`          |
| `error_sidecar_db_struct`      | 侧车种类：DbError 结构体。                        | `sidecar_db_struct`      | 去模块前缀+去类型名 | `err.sidecar_db_struct(...)`      |
| `error_code_to_module_base`    | 负码 → 所属 error_base_*；L 层/未知 → 0。         | `code_to_module_base`    | 去模块前缀+去类型名 | `err.code_to_module_base(...)`    |
| `error_code_in_global_range`   | —                                        | `code_in_global_range`   | 去模块前缀+去类型名 | `err.code_in_global_range(...)`   |
| `error_code_in_module_span`    | —                                        | `code_in_module_span`    | 去模块前缀+去类型名 | `err.code_in_module_span(...)`    |
| `error_code_is_platform_errno` | —                                        | `code_is_platform_errno` | 去模块前缀+去类型名 | `err.code_is_platform_errno(...)` |
| `error_mod_tag_from_base`      | base → 模块标签；未知 base → 0。                 | `mod_tag_from_base`      | 去模块前缀+去类型名 | `err.mod_tag_from_base(...)`      |
| `error_mod_base_from_tag`      | 标签 → base；db 等无 B 层段 → 0。                | `mod_base_from_tag`      | 去模块前缀+去类型名 | `err.mod_base_from_tag(...)`      |
| `error_module_sidecar_kind`    | 模块标签 → last_error 侧车种类。                  | `module_sidecar_kind`    | 去模块前缀+去类型名 | `err.module_sidecar_kind(...)`    |
| `error_sem_none`               | 语义类：无/未知。                                | `sem_none`               | 去模块前缀+去类型名 | `err.sem_none(...)`               |
| `error_sem_timeout`            | 语义类：超时。                                  | `sem_timeout`            | 去模块前缀+去类型名 | `err.sem_timeout(...)`            |
| `error_sem_cancelled`          | 语义类：取消。                                  | `sem_cancelled`          | 去模块前缀+去类型名 | `err.sem_cancelled(...)`          |
| `error_sem_not_found`          | 语义类：未找到。                                 | `sem_not_found`          | 去模块前缀+去类型名 | `err.sem_not_found(...)`          |
| `http_err_timeout`             | std.http 超时（映射 net 段）。                   | `timeout`                | 去模块前缀+去类型名 | `err.timeout(...)`                |
| `http_err_cancelled`           | std.http 取消（映射 net 段）。                   | `cancelled`              | 去模块前缀+去类型名 | `err.cancelled(...)`              |
| `error_semantic_class`         | 错误码 → 跨模块语义类。                            | `semantic_class`         | 去模块前缀+去类型名 | `err.semantic_class(...)`         |
| `error_is_timeout`             | 是否为超时语义（1/0）。                            | `is_timeout`             | 去模块前缀+去类型名 | `err.is_timeout(...)`             |
| `error_is_cancelled`           | 是否为取消语义（1/0）。                            | `is_cancelled`           | 去模块前缀+去类型名 | `err.is_cancelled(...)`           |
| `error_is_not_found`           | 是否为未找到语义（1/0）。                           | `is_not_found`           | 去模块前缀+去类型名 | `err.is_not_found(...)`           |
| `error_recommend_retry`        | v1：仅超时建议重试（1/0）。                         | `recommend_retry`        | 去模块前缀+去类型名 | `err.recommend_retry(...)`        |
| `error_chain_max_depth`        | ErrorChain 最大深度（栈上 c0..c3）。              | `chain_max_depth`        | 去模块前缀+去类型名 | `err.chain_max_depth(...)`        |
| `error_chain_empty`            | 空链（depth=0）。                             | `chain_empty`            | 去模块前缀+去类型名 | `err.chain_empty(...)`            |
| `error_chain_from_code`        | 单码链。                                     | `chain_from_code`        | 去模块前缀+去类型名 | `err.chain_from_code(...)`        |
| `error_chain_from_result`      | 自 Result_i32.err 构造单节点链。                 | `chain_from_result`      | 去模块前缀+去类型名 | `err.chain_from_result(...)`      |
| `error_chain_depth`            | 链深度 0..max。                              | `chain_depth`            | 去模块前缀+去类型名 | `err.chain_depth(...)`            |
| `error_chain_root`             | 最外层码（c0）；空链返回 0。                         | `chain_root`             | 去模块前缀+去类型名 | `err.chain_root(...)`             |
| `error_chain_code_at`          | 按外→内下标取码；越界返回 0。                         | `chain_code_at`          | 去模块前缀+去类型名 | `err.chain_code_at(...)`          |
| `error_chain_leaf`             | 最内层根因码；空链返回 0。                           | `chain_leaf`             | 去模块前缀+去类型名 | `err.chain_leaf(...)`             |
| `error_chain_wrap`             | —                                        | `chain_wrap`             | 去模块前缀+去类型名 | `err.chain_wrap(...)`             |


### std.ffi

`std/ffi/mod.sx` · 17 APIs · `const ffi = import("std.ffi")`


| 当前名称                     | 功能说明                                                                                                    | 简化名称              | 说明             | 绑定调用                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------- | ----------------- | -------------- | -------------------------- |
| `ffi_cstr_len_c` | std.ffi — C 字符串互操作（对标 Zig std.cstr、Rust std::ffi） 【文件职责】cstr_len、cstring_new/free；FfiPoint pack/unpack； | `cstr_len` | 去模块前缀+去类型名（C层） | `ffi.cstr_len(...)` |
| `ffi_cstring_new_c` | extern C/平台 | `cstring_new` | 去模块前缀+去类型名（C层） | `ffi.cstring_new(...)` |
| `ffi_cstring_free_c` | extern C/平台 | `cstring_free` | 去模块前缀+去类型名（C层） | `ffi.cstring_free(...)` |
| `ffi_cstring_try_new_c` | extern C/平台 | `cstring_try_new` | 去模块前缀+去类型名（C层） | `ffi.cstring_try_new(...)` |
| `ffi_point_pack_c` | extern C/平台 | `point_pack` | 去模块前缀+去类型名（C层） | `ffi.point_pack(...)` |
| `ffi_point_unpack_c` | extern C/平台 | `point_unpack` | 去模块前缀+去类型名（C层） | `ffi.point_unpack(...)` |
| `ffi_cb_double_i32_fn_c` | extern C/平台 | `cb_double_fn` | 去模块前缀+去类型名（C层） | `ffi.cb_double_fn(...)` |
| `ffi_invoke_i32_cb_c` | extern C/平台 | `invoke_cb` | 去模块前缀+去类型名（C层） | `ffi.invoke_cb(...)` |
| `cstr_len`               | 返回 NUL 结尾字符串的字节长度（不含 NUL）；ptr 为 0 返回 -1。                                                                | `cstr_len`        | 已符合命名          | `ffi.cstr_len(...)`        |
| `cstring_new`            | 分配并复制 ptr[0..len]，末尾加 NUL；失败返回 0。需用 cstring_free 释放。                                                    | `cstring_new`     | 已符合命名          | `ffi.cstring_new(...)`     |
| `cstring_try_new`        | 显式错误码分配 owned CString；成功 FFI_OK 且 *out 为指针位模式（STD-055）。                                                 | `cstring_try_new` | 已符合命名          | `ffi.cstring_try_new(...)` |
| `cstring_free`           | 释放由 cstring_new / cstring_try_new 返回的指针。                                                                | `cstring_free`    | 已符合命名          | `ffi.cstring_free(...)`    |
| `cstring_destroy`        | cstring_free 别名（SAFE-004 C6：恰好一次释放）。                                                                    | `cstring_destroy` | 已符合命名          | `ffi.cstring_destroy(...)` |
| `point_pack`             | 将 x/y 以小端写入 buf；cap<8 返回 FFI_ERR_TOO_SMALL。                                                             | `point_pack`      | 已符合命名          | `ffi.point_pack(...)`      |
| `point_unpack`           | 从 buf 读出 FfiPoint 到 out；cap<8 返回 FFI_ERR_TOO_SMALL。                                                     | `point_unpack`    | 已符合命名          | `ffi.point_unpack(...)`    |
| `cb_double_i32_fn`       | 返回内置 arg*2 回调函数地址（usize）。                                                                               | `cb_double_fn`    | 去模块前缀+去类型名     | `ffi.cb_double_fn(...)`    |
| `invoke_i32_cb`          | 调用 usize 承载的 i32→i32 回调；cb=0 返回 FFI_ERR_NULL。                                                           | `invoke_cb`       | 去模块前缀+去类型名     | `ffi.invoke_cb(...)`       |


### std.fmt

`std/fmt/mod.sx` · 35 APIs · `const fmt = import("std.fmt")`


| 当前名称                    | 功能说明                                                      | 简化名称              | 说明               | 绑定调用                       |
| ----------------------- | --------------------------------------------------------- | ----------------- | ---------------- | -------------------------- |
| `placeholder` | Tier-S 烟测钩子。 | `placeholder` | 已符合命名；Tier-X 不 export | `fmt.placeholder(...)` |
| `fmt_i32`               | 重导出 core.fmt：整型/浮点/指针格式化（薄转发，供 `import("std.fmt")` 直接调用）。 | `format`          | 去模块前缀+去类型名       | `fmt.format(...)`          |
| `fmt_i32_to_buf`        | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_u32_to_buf`        | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_i64_to_buf`        | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_u64_to_buf`        | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_usize_to_buf`      | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_isize_to_buf`      | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_bool_to_buf`       | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_f64_to_buf`        | —                                                         | `to_buf`          | 去模块前缀+去类型名       | `fmt.to_buf(...)`          |
| `fmt_f64_to_buf_prec`   | —                                                         | `to_buf_prec`     | 去模块前缀+去类型名       | `fmt.to_buf_prec(...)`     |
| `fmt_u32_hex_to_buf`    | —                                                         | `hex_to_buf`      | 去模块前缀+去类型名       | `fmt.hex_to_buf(...)`      |
| `fmt_u64_hex_to_buf`    | —                                                         | `hex_to_buf`      | 去模块前缀+去类型名       | `fmt.hex_to_buf(...)`      |
| `fmt_append_i32_to_buf` | —                                                         | `append_to_buf`   | 去模块前缀+去类型名       | `fmt.append_to_buf(...)`   |
| `fmt_append_i64_to_buf` | —                                                         | `append_to_buf`   | 去模块前缀+去类型名       | `fmt.append_to_buf(...)`   |
| `format_template_1_i32` | 单占位模板：pat 中首个 brace-pair 替换为 i32 十进制（STD-166）。            | `format_template` | 去模块前缀+去类型名       | `fmt.format_template(...)` |
| `print`                 | —                                                         | `print`           | 已符合命名            | `fmt.print(...)`           |
| `println`               | —                                                         | `println`         | 已符合命名            | `fmt.println(...)`         |
| `format_2`              | format_2 整数 overload 共用体：按形参类型调用 fmt_scalar_to_buf。       | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_2`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_3`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `format_3`              | —                                                         | `format`          | 二次精简：去参数位数/固定值后缀 | `fmt.format(...)`          |
| `fmt_ptr_to_buf`        | 重导出 core.fmt 指针格式化。                                       | `ptr_to_buf`      | 去模块前缀+去类型名       | `fmt.ptr_to_buf(...)`      |


### std.fs

`std/fs/mod.sx` · 87 APIs · `const fs = import("std.fs")`


| 当前名称                          | 功能说明                                                                                                                    | 简化名称                          | 说明                | 绑定调用                                  |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ----------------- | ------------------------------------- |
| `open`                        | 与 POSIX open/read/write/close 一致；链接时需 -lc。fs_*_c 由 posix/win32 提供。 fs_readv_buf/fs_writev_buf 的 bufs 与 Buffer ABI | `open`                        | 已符合命名             | `fs.open(...)`                        |
| `close`                       | extern C/平台                                                                                                             | `close`                       | 已符合命名             | `fs.close(...)`                       |
| `pread`                       | extern C/平台                                                                                                             | `pread`                       | 已符合命名             | `fs.pread(...)`                       |
| `pwrite`                      | extern C/平台                                                                                                             | `pwrite`                      | 已符合命名             | `fs.pwrite(...)`                      |
| `fs_open_read_c` | 只读打开（F-03 v2 纯 .sx）；asm 跳过 std.fs emit 时由 std_fs.o 提供。 | `open` | 去模块前缀+去类型名（C层） | `fs.open(...)` |
| `fs_posix_read_c` | — | `pread` | 去模块前缀+去类型名（C层） | `fs.pread(...)` |
| `fs_posix_write_c` | — | `pwrite` | 去模块前缀+去类型名（C层） | `fs.pwrite(...)` |
| `fs_mmap_ro_c` | — | `mmap_ro` | 去模块前缀+去类型名（C层） | `fs.mmap_ro(...)` |
| `fs_mmap_rw_c` | — | `mmap_rw` | 去模块前缀+去类型名（C层） | `fs.mmap_rw(...)` |
| `fs_munmap_c` | — | `munmap` | 去模块前缀+去类型名（C层） | `fs.munmap(...)` |
| `fs_open_read_direct_c` | — | `open_read_direct` | 去模块前缀+去类型名（C层） | `fs.open_read_direct(...)` |
| `fs_direct_align_c` | — | `direct_align` | 去模块前缀+去类型名（C层） | `fs.direct_align(...)` |
| `fs_fadvise_sequential_c` | — | `fadvise_sequential` | 去模块前缀+去类型名（C层） | `fs.fadvise_sequential(...)` |
| `fs_fadvise_willneed_c` | — | `fadvise_willneed` | 去模块前缀+去类型名（C层） | `fs.fadvise_willneed(...)` |
| `fs_copy_file_range_c` | — | `copy_file_range` | 去模块前缀+去类型名（C层） | `fs.copy_file_range(...)` |
| `fs_readv2_c` | — | `readv` | 二次精简：去算法/版本/分段数后缀 | `fs.readv(...)` |
| `fs_writev2_c` | — | `writev` | 二次精简：去算法/版本/分段数后缀 | `fs.writev(...)` |
| `fs_sendfile_c` | — | `sendfile` | 去模块前缀+去类型名（C层） | `fs.sendfile(...)` |
| `fs_pipe_splice_c` | ZC-5：经 pipe splice 中转（Linux 内核零拷贝；非 Linux read/write 回退）。 | `pipe_splice` | 去模块前缀+去类型名（C层） | `fs.pipe_splice(...)` |
| `fs_sync_range_c` | — | `sync_range` | 去模块前缀+去类型名（C层） | `fs.sync_range(...)` |
| `fs_sync_c` | — | `sync` | 去模块前缀+去类型名（C层） | `fs.sync(...)` |
| `fs_fallocate_c` | — | `fallocate` | 去模块前缀+去类型名（C层） | `fs.fallocate(...)` |
| `fs_open_write_c` | — | `create` | 去模块前缀+去类型名（C层） | `fs.create(...)` |
| `fs_open_append_c` | — | `open_append` | 去模块前缀+去类型名（C层） | `fs.open_append(...)` |
| `fs_open_create_c` | — | `open_create` | 去模块前缀+去类型名（C层） | `fs.open_create(...)` |
| `fs_last_error_c` | — | `last_error` | 去模块前缀+去类型名（C层） | `fs.last_error(...)` |
| `fs_readv4_c` | — | `readv` | 二次精简：去算法/版本/分段数后缀 | `fs.readv(...)` |
| `fs_writev4_c` | — | `writev` | 二次精简：去算法/版本/分段数后缀 | `fs.writev(...)` |
| `fs_readv_buf_c` | — | `readv_buf` | 去模块前缀+去类型名（C层） | `fs.readv_buf(...)` |
| `fs_writev_buf_c` | — | `writev_buf` | 去模块前缀+去类型名（C层） | `fs.writev_buf(...)` |
| `fs_invalid_handle` | — | `invalid` | 去模块前缀+去类型名；三轮精简 | `fs.invalid(...)` |
| `fs_read_chunk` | 推荐大块读单次字节数（1MiB），极致压榨时用此大小循环 fs_read。 | `chunk_size` | 去模块前缀+去类型名；三轮精简 | `fs.chunk_size(...)` |
| `fs_open_read`                | 只读打开 path（NUL 结尾）；失败返回 -1。                                                                                              | `open`                        | 去模块前缀+去类型名        | `fs.open(...)`                        |
| `fs_open_write`               | —                                                                                                                       | `create`                      | 去模块前缀+去类型名        | `fs.create(...)`                      |
| `fs_close`                    | —                                                                                                                       | `close`                       | 去模块前缀+去类型名        | `fs.close(...)`                       |
| `fs_read`                     | —                                                                                                                       | `read`                        | 去模块前缀+去类型名        | `fs.read(...)`                        |
| `fs_write`                    | 大块写：将 buf[0..count-1] 写入 fd。返回写入字节数，-1=错误。                                                                              | `write`                       | 去模块前缀+去类型名        | `fs.write(...)`                       |
| `fs_pread`                    | —                                                                                                                       | `pread`                       | 去模块前缀+去类型名        | `fs.pread(...)`                       |
| `fs_pwrite`                   | —                                                                                                                       | `pwrite`                      | 去模块前缀+去类型名        | `fs.pwrite(...)`                      |
| `fs_open_read_direct`         | —                                                                                                                       | `open_read_direct`            | 去模块前缀+去类型名        | `fs.open_read_direct(...)`            |
| `fs_direct_align`             | —                                                                                                                       | `direct_align`                | 去模块前缀+去类型名        | `fs.direct_align(...)`                |
| `fs_fadvise_sequential`       | —                                                                                                                       | `fadvise_sequential`          | 去模块前缀+去类型名        | `fs.fadvise_sequential(...)`          |
| `fs_fadvise_willneed`         | 提示内核即将访问 [offset, offset+len)，可预取页；0 成功，-1 失败。                                                                          | `fadvise_willneed`            | 去模块前缀+去类型名        | `fs.fadvise_willneed(...)`            |
| `fs_copy_file_range`          | —                                                                                                                       | `copy_file_range`             | 去模块前缀+去类型名        | `fs.copy_file_range(...)`             |
| `fs_readv2`                   | —                                                                                                                       | `readv`                       | 二次精简：去算法/版本/分段数后缀 | `fs.readv(...)`                       |
| `fs_writev2`                  | —                                                                                                                       | `writev`                      | 二次精简：去算法/版本/分段数后缀 | `fs.writev(...)`                      |
| `fs_sendfile`                 | —                                                                                                                       | `sendfile`                    | 去模块前缀+去类型名        | `fs.sendfile(...)`                    |
| `fs_pipe_splice`              | —                                                                                                                       | `pipe_splice`                 | 去模块前缀+去类型名        | `fs.pipe_splice(...)`                 |
| `fs_sync_range`               | —                                                                                                                       | `sync_range`                  | 去模块前缀+去类型名        | `fs.sync_range(...)`                  |
| `fs_sync`                     | —                                                                                                                       | `sync`                        | 去模块前缀+去类型名        | `fs.sync(...)`                        |
| `fs_fallocate`                | —                                                                                                                       | `fallocate`                   | 去模块前缀+去类型名        | `fs.fallocate(...)`                   |
| `fs_open_append`              | 追加写打开 path（不存在则创建）；失败返回 -1。                                                                                             | `open_append`                 | 去模块前缀+去类型名        | `fs.open_append(...)`                 |
| `fs_open_create`              | 写打开 path，不存在则创建、存在则不截断；失败返回 -1。                                                                                         | `open_create`                 | 去模块前缀+去类型名        | `fs.open_create(...)`                 |
| `fs_last_error` | — | `last_error` | 去模块前缀+去类型名；三轮精简 | `fs.last_error(...)` |
| `fs_readv4`                   | —                                                                                                                       | `readv`                       | 二次精简：去算法/版本/分段数后缀 | `fs.readv(...)`                       |
| `fs_writev4`                  | 集中写：一次 syscall 写出四段 [p0,l0]..[p3,l3]；返回总字节数，-1 错误。                                                                      | `writev`                      | 二次精简：去算法/版本/分段数后缀 | `fs.writev(...)`                      |
| `fs_readv_buf`                | —                                                                                                                       | `readv_buf`                   | 去模块前缀+去类型名        | `fs.readv_buf(...)`                   |
| `fs_writev_buf`               | —                                                                                                                       | `writev_buf`                  | 去模块前缀+去类型名        | `fs.writev_buf(...)`                  |
| `fs_mmap_ro` | — | `mmap_ro` | 去模块前缀+去类型名；三轮精简 | `fs.mmap_ro(...)` |
| `fs_mmap_rw` | — | `mmap_rw` | 去模块前缀+去类型名；三轮精简 | `fs.mmap_rw(...)` |
| `fs_munmap`                   | —                                                                                                                       | `munmap`                      | 去模块前缀+去类型名        | `fs.munmap(...)`                      |
| `handle_from_fd`              | 与 std.io 一致，第二参 unused，调用处传 0。                                                                                          | `from_fd`                     | 语义重命名             | `fs.from_fd(...)`                     |
| `read_fd`                     | —                                                                                                                       | `read_fd`                     | 已符合命名             | `fs.read_fd(...)`                     |
| `write_fd`                    | —                                                                                                                       | `write_fd`                    | 已符合命名             | `fs.write_fd(...)`                    |
| `read_batch_fd`               | —                                                                                                                       | `read_batch_fd`               | 已符合命名             | `fs.read_batch_fd(...)`               |
| `write_batch_fd`              | —                                                                                                                       | `write_batch_fd`              | 已符合命名             | `fs.write_batch_fd(...)`              |
| `fs_path_readable`            | —                                                                                                                       | `path_readable`               | 去模块前缀+去类型名        | `fs.path_readable(...)`               |
| `fs_stat_c` | — | `stat` | 去模块前缀+去类型名（C层） | `fs.stat(...)` |
| `fs_chmod_c` | — | `chmod` | 去模块前缀+去类型名（C层） | `fs.chmod(...)` |
| `fs_mkdir_c` | — | `mkdir` | 去模块前缀+去类型名（C层） | `fs.mkdir(...)` |
| `fs_unlink_c` | — | `remove_file` | 去模块前缀+去类型名（C层） | `fs.remove_file(...)` |
| `fs_rmdir_c` | — | `remove_dir` | 去模块前缀+去类型名（C层） | `fs.remove_dir(...)` |
| `fs_dir_open_c` | — | `dir_open` | 去模块前缀+去类型名（C层） | `fs.dir_open(...)` |
| `fs_dir_read_c` | — | `dir_read` | 去模块前缀+去类型名（C层） | `fs.dir_read(...)` |
| `fs_dir_close_c` | — | `dir_close` | 去模块前缀+去类型名（C层） | `fs.dir_close(...)` |
| `fs_mode_file_default`        | 默认文件权限 0644。                                                                                                            | `mode_file_default`           | 去模块前缀+去类型名        | `fs.mode_file_default(...)`           |
| `fs_mode_dir_default`         | 默认目录权限 0755。                                                                                                            | `mode_dir_default`            | 去模块前缀+去类型名        | `fs.mode_dir_default(...)`            |
| `fs_stat`                     | 路径 stat；成功 0。                                                                                                           | `stat`                        | 去模块前缀+去类型名        | `fs.stat(...)`                        |
| `fs_chmod`                    | 修改权限；成功 0。                                                                                                              | `chmod`                       | 去模块前缀+去类型名        | `fs.chmod(...)`                       |
| `fs_mkdir`                    | 创建目录；成功 0。                                                                                                              | `mkdir`                       | 去模块前缀+去类型名        | `fs.mkdir(...)`                       |
| `fs_unlink`                   | 删除文件；成功 0（不存在时仍尝试）。                                                                                                     | `remove_file`                 | 去模块前缀+去类型名        | `fs.remove_file(...)`                 |
| `fs_rmdir`                    | 删除空目录；成功 0。                                                                                                             | `remove_dir`                  | 去模块前缀+去类型名        | `fs.remove_dir(...)`                  |
| `fs_dir_open`                 | 打开目录遍历；失败 -1。                                                                                                           | `dir_open`                    | 去模块前缀+去类型名        | `fs.dir_open(...)`                    |
| `fs_dir_read`                 | 读下一目录项：1=有项，0=EOF，-1=错误。                                                                                                | `dir_read`                    | 去模块前缀+去类型名        | `fs.dir_read(...)`                    |
| `fs_dir_close`                | 关闭目录句柄；成功 0。                                                                                                            | `dir_close`                   | 去模块前缀+去类型名        | `fs.dir_close(...)`                   |
| `freestanding_fs_available`   | —                                                                                                                       | `freestanding_fs_available`   | 已符合命名             | `fs.freestanding_fs_available(...)`   |
| `freestanding_read_file_into` | —                                                                                                                       | `read_file` | 三轮精简 | fs.freestanding_read_file_into(...) |
### std.hash

`std/hash/mod.sx` · 34 APIs · `const hash = import("std.hash")`


| 当前名称                           | 功能说明                                                                                                                                              | 简化名称                    | 说明             | 绑定调用                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | -------------- | --------------------------------- |
| `hash_sip_new_c` | std.hash — Hasher 抽象与 SipHash-2-4（对标 Zig std.hash、Rust std::hash::Hasher） STD-056：统一 Hasher 工厂 hash_start_algo / default_hasher / SHUX_HASH_ALGO。 | `sip_new` | 去模块前缀+去类型名（C层） | `hash.sip_new(...)` |
| `hash_sip_write_u32_c` | extern C/平台 | `sip_write` | 去模块前缀+去类型名（C层） | `hash.sip_write(...)` |
| `hash_sip_write_u64_c` | extern C/平台 | `sip_write` | 去模块前缀+去类型名（C层） | `hash.sip_write(...)` |
| `hash_sip_write_bytes_c` | extern C/平台 | `sip_write_bytes` | 去模块前缀+去类型名（C层） | `hash.sip_write_bytes(...)` |
| `hash_sip_finish_c` | extern C/平台 | `sip_finish` | 去模块前缀+去类型名（C层） | `hash.sip_finish(...)` |
| `hash_sip_free_c` | extern C/平台 | `sip_free` | 去模块前缀+去类型名（C层） | `hash.sip_free(...)` |
| `hash_sip_bytes_c` | extern C/平台 | `sip_bytes` | 去模块前缀+去类型名（C层） | `hash.sip_bytes(...)` |
| `hash_default_algo_c` | extern C/平台 | `default_algo` | 去模块前缀+去类型名（C层） | `hash.default_algo(...)` |
| `hash_unified_new_c` | extern C/平台 | `unified_new` | 去模块前缀+去类型名（C层） | `hash.unified_new(...)` |
| `hash_unified_write_bytes_c` | extern C/平台 | `unified_write_bytes` | 去模块前缀+去类型名（C层） | `hash.unified_write_bytes(...)` |
| `hash_unified_write_u32_c` | extern C/平台 | `unified_write` | 去模块前缀+去类型名（C层） | `hash.unified_write(...)` |
| `hash_unified_finish_c` | extern C/平台 | `unified_finish` | 去模块前缀+去类型名（C层） | `hash.unified_finish(...)` |
| `hash_unified_free_c` | extern C/平台 | `unified_free` | 去模块前缀+去类型名（C层） | `hash.unified_free(...)` |
| `hash_xxhash64_bytes_c` | extern C/平台 | `xxhash64_bytes` | 去模块前缀+去类型名（C层） | `hash.xxhash64_bytes(...)` |
| `hash_xxhash64_seed_bytes_c` | extern C/平台 | `xxhash64_seed_bytes` | 去模块前缀+去类型名（C层） | `hash.xxhash64_seed_bytes(...)` |
| `hash_recommend_hasher_map_c` | extern C/平台 | `recommend_hasher_map` | 去模块前缀+去类型名（C层） | `hash.recommend_hasher_map(...)` |
| `hash_recommend_hasher_fast_c` | extern C/平台                                                                                                                                       | `recommend_hasher_fast` | 去模块前缀+去类型名（C层） | `hash.recommend_hasher_fast(...)` |
| `default_hasher`               | 读取 SHUX_HASH_ALGO 环境变量，返回默认 Hasher 算法 id。                                                                                                         | `default_hasher`        | 已符合命名          | `hash.default_hasher(...)`        |
| `recommend_hasher_map`         | Map/Set 场景推荐 Hasher（SipHash）。                                                                                                                     | `recommend_hasher_map`  | 已符合命名          | `hash.recommend_hasher_map(...)`  |
| `recommend_hasher_fast`        | 内部去重/checksum 推荐 Hasher（xxHash64）。                                                                                                                | `recommend_hasher_fast` | 已符合命名          | `hash.recommend_hasher_fast(...)` |
| `hash_start_algo`              | 按算法创建 Hasher 状态；失败返回 0。                                                                                                                           | `start_algo`            | 去模块前缀+去类型名     | `hash.start_algo(...)`            |
| `hash_write_bytes_algo`        | 向 algo Hasher 写入字节 ptr[0..len)。                                                                                                                   | `write_bytes_algo`      | 去模块前缀+去类型名     | `hash.write_bytes_algo(...)`      |
| `hash_write_u32_algo`          | 向 algo Hasher 写入 u32（小端）。                                                                                                                         | `write_algo`            | 去模块前缀+去类型名     | `hash.write_algo(...)`            |
| `hash_finish_algo`             | 完成 algo Hasher，返回 u64 摘要。                                                                                                                         | `finish_algo`           | 去模块前缀+去类型名     | `hash.finish_algo(...)`           |
| `hash_free_algo`               | 释放 algo Hasher 状态。                                                                                                                                | `free_algo`             | 去模块前缀+去类型名     | `hash.free_algo(...)`             |
| `hash_start`                   | 创建 Hasher 状态（Tier-S：恒 SipHash）；失败返回 0。                                                                                                            | `start`                 | 去模块前缀+去类型名     | `hash.start(...)`                 |
| `hash_write_u32`               | 写入 u32（小端）。                                                                                                                                       | `write`                 | 去模块前缀+去类型名     | `hash.write(...)`                 |
| `hash_write_u64`               | 写入 u64（小端）。                                                                                                                                       | `write`                 | 去模块前缀+去类型名     | `hash.write(...)`                 |
| `hash_write_bytes`             | 写入字节 ptr[0..len)。                                                                                                                                 | `write_bytes`           | 去模块前缀+去类型名     | `hash.write_bytes(...)`           |
| `hash_finish`                  | 完成哈希，返回 u64；调用后 h 仍可继续写。                                                                                                                          | `finish`                | 去模块前缀+去类型名     | `hash.finish(...)`                |
| `hash_free`                    | 释放 Hasher 状态。                                                                                                                                     | `free`                  | 去模块前缀+去类型名     | `hash.free(...)`                  |
| `hash_bytes`                   | 单次对 ptr[0..len) 做 SipHash-2-4，返回 u64。                                                                                                             | `bytes`                 | 去模块前缀+去类型名     | `hash.bytes(...)`                 |
| `hash_xxhash64`                | 一次性 xxHash64（seed=0）。                                                                                                                             | `xxhash64`              | 去模块前缀+去类型名     | `hash.xxhash64(...)`              |
| `hash_xxhash64_seed`           | 一次性 xxHash64（指定 seed）。                                                                                                                            | `xxhash64_seed`         | 去模块前缀+去类型名     | `hash.xxhash64_seed(...)`         |


### std.heap

`std/heap/mod.sx` · 51 APIs · `const heap = import("std.heap")`


| 当前名称                               | 功能说明                                                          | 简化名称                               | 说明             | 绑定调用                                         |
| ---------------------------------- | ------------------------------------------------------------- | ---------------------------------- | -------------- | -------------------------------------------- |
| `heap_mem_set_c` | F-03 v1：纯 .sx 实现（ops.sx）；保留名供 std.mem 链接。 | `mem_set` | 去模块前缀+去类型名（C层） | `heap.mem_set(...)` |
| `heap_mem_compare_c` | F-03 v1：纯 .sx 实现（ops.sx）。 | `mem_compare` | 去模块前缀+去类型名（C层） | `heap.mem_compare(...)` |
| `map_i32_i32_find_c` | 线性探测查找 key；F-03 v1 纯 .sx（ops.sx）。 | `map_find` | 去模块前缀+去类型名（C层） | `heap.map_find(...)` |
| `heap_trace_enabled` | trace 是否启用（1/0）。 | `trace_on` | 去模块前缀+去类型名；三轮精简 | `heap.trace_on(...)` |
| `heap_trace_reset`                 | 重置 trace 计数器。                                                 | `trace_reset`                      | 去模块前缀+去类型名     | `heap.trace_reset(...)`                      |
| `heap_trace_stats`                 | 读取 trace 统计到 st。                                              | `trace_stats`                      | 去模块前缀+去类型名     | `heap.trace_stats(...)`                      |
| `alloc_u64`                        | 分配 count 个 u64；失败 null。供 Map_u64 / Set_u64 使用。                | `alloc`                            | 去模块前缀+去类型名     | `heap.alloc(...)`                            |
| `free_u64`                         | 释放 alloc_u64 分配的 ptr。                                         | `free`                             | 去模块前缀+去类型名     | `heap.free(...)`                             |
| `realloc_u64`                      | 将 ptr 调整为 new_count 个 u64；失败 null 且原 ptr 未释放。供 Vec_u64 扩容。    | `realloc`                          | 去模块前缀+去类型名     | `heap.realloc(...)`                          |
| `copy_u64_at`                      | 块拷贝 u64；供 std.vec append_slice/from_slice 快路径。                | `copy`                          | 去模块前缀+去类型名     | `heap.copy(...)`                          |
| `alloc_f64`                        | 分配 count 个 f64；失败 null。供 Vec_f64 使用（STD-014）。                 | `alloc`                            | 去模块前缀+去类型名     | `heap.alloc(...)`                            |
| `realloc_f64`                      | 将 ptr 调整为 new_count 个 f64；失败 null 且原 ptr 未释放。                 | `realloc`                          | 去模块前缀+去类型名     | `heap.realloc(...)`                          |
| `free_f64`                         | 释放 alloc_f64/realloc_f64 分配的 ptr；ptr 可为 null。                 | `free`                             | 去模块前缀+去类型名     | `heap.free(...)`                             |
| `copy_f64_at`                      | 块拷贝 f64；供 std.vec append_slice/from_slice 快路径。                | `copy`                          | 去模块前缀+去类型名     | `heap.copy(...)`                          |
| `allocator_kind_heap` | 堆分配器 kind 常量（0）。 | `kind_heap` | 三轮精简 | `heap.kind_heap(...)` |
| `allocator_kind_arena` | Arena bump 分配器 kind 常量（1）。 | `kind_arena` | 三轮精简 | `heap.kind_arena(...)` |
| `allocator_heap` | 默认 libc 堆分配器。 | `heap_alloc` | 三轮精简 | `heap.heap_alloc(...)` |
| `allocator_from_arena` | 将 Arena64 包装为 bump 分配器（单独 free 为 no-op）。 | `from_arena` | 三轮精简 | `heap.from_arena(...)` |
| `scope_allocator` | — | `scope_alloc` | 三轮精简 | `heap.scope_alloc(...)` |
| `default_allocator` | — | `default_alloc` | 三轮精简 | `heap.default_alloc(...)` |
| `allocator_alloc` | 按 Allocator 分配 size 字节；失败 null。 | `alloc` | 三轮精简 | `heap.alloc(...)` |
| `allocator_free` | 释放 ptr；arena 分配器为 no-op。 | `free` | 三轮精简 | `heap.free(...)` |
| `allocator_realloc` | 调整块大小；仅堆分配器支持，arena 返回 null。 | `realloc` | 三轮精简 | `heap.realloc(...)` |
| `bump_alloc`                       | —                                                             | `bump` | 已符合命名；三轮精简 | `heap.bump(...)` |
| `arena64_empty` | 未初始化 Arena64 占位；调用方须随后 arena64_init。 | `arena_empty` | 三轮精简 | `heap.arena64_empty(...)` |
| `arena64_init` | — | `arena_init` | 三轮精简 | `heap.arena64_init(...)` |
| `arena64_alloc` | — | `arena_alloc` | 三轮精简 | `heap.arena64_alloc(...)` |
| `arena64_deinit` | 释放 arena chunk 并重置 off/cap。 | `arena_deinit` | 三轮精简 | `heap.arena64_deinit(...)` |
| `ptr_mod`                          | 指针对 mod 取模；mod=64 验证 cache line 对齐。                           | `ptr_mod`                          | 已符合命名          | `heap.ptr_mod(...)`                          |
| `alloc_aligned`                    | posix_memalign 薄封装；供 ring slot 等全局 64B 分配。                    | `alloc_align` | 已符合命名；三轮精简 | `heap.alloc_align(...)` |
| `alloc`                            | —                                                             | `alloc`                            | 已符合命名          | `heap.alloc(...)`                            |
| `free`                             | 释放 ptr；ptr 可为 null（无操作）。对标 Zig free、Rust dealloc。             | `free`                             | 已符合命名          | `heap.free(...)`                             |
| `realloc`                          | —                                                             | `realloc`                          | 已符合命名          | `heap.realloc(...)`                          |
| `alloc_zeroed`                     | —                                                             | `alloc_zero` | 三轮精简 | `heap.alloc_zero(...)` |
| `alloc_i32`                        | 分配 count 个 i32，未初始化；失败返回 null。供 std.vec Vec_i32 使用。           | `alloc`                            | 去模块前缀+去类型名     | `heap.alloc(...)`                            |
| `realloc_i32`                      | 将 ptr 调整为 new_count 个 i32；失败返回 null 且原 ptr 未释放。               | `realloc`                          | 去模块前缀+去类型名     | `heap.realloc(...)`                          |
| `free_i32`                         | 释放由 alloc_i32/realloc_i32 分配的 ptr；ptr 可为 null。                | `free`                             | 去模块前缀+去类型名     | `heap.free(...)`                             |
| `alloc_u8`                         | 分配 count 个 u8，未初始化；失败返回 null。供 std.vec Vec_u8 使用。             | `alloc`                            | 去模块前缀+去类型名     | `heap.alloc(...)`                            |
| `realloc_u8`                       | 将 ptr 调整为 new_count 个 u8；失败返回 null 且原 ptr 未释放。                | `realloc`                          | 去模块前缀+去类型名     | `heap.realloc(...)`                          |
| `free_u8`                          | 释放由 alloc_u8/realloc_u8 分配的 ptr；ptr 可为 null。                  | `free`                             | 去模块前缀+去类型名     | `heap.free(...)`                             |
| `copy_i32_at`                      | —                                                             | `copy`                          | 去模块前缀+去类型名     | `heap.copy(...)`                          |
| `copy_u8_at`                       | 块拷贝：dst[dst_offset..] = src[0..count-1]（u8 元素）；供 std.vec 快路径。 | `copy`                          | 去模块前缀+去类型名     | `heap.copy(...)`                          |
| `alloc_f32`                        | 分配 count 个 f32，未初始化；失败返回 null。DOD-S2：std.vec SoA 列存储。         | `alloc`                            | 去模块前缀+去类型名     | `heap.alloc(...)`                            |
| `realloc_f32`                      | 将 ptr 调整为 new_count 个 f32；失败返回 null 且原 ptr 未释放。               | `realloc`                          | 去模块前缀+去类型名     | `heap.realloc(...)`                          |
| `free_f32`                         | 释放由 alloc_f32/realloc_f32 分配的 ptr；ptr 可为 null。                | `free`                             | 去模块前缀+去类型名     | `heap.free(...)`                             |
| `copy_f32_at`                      | 块拷贝 f32 列；供 std.vec SoA/AoS 扩容与 append。                       | `copy`                          | 去模块前缀+去类型名     | `heap.copy(...)`                          |
| `alloc_size_zero`                  | 表示“分配大小 0”占位；保留兼容（测试用）。                                       | `alloc_size_zero`                  | 已符合命名          | `heap.alloc_size_zero(...)`                  |
| `freestanding_page_heap_available` | —                                                             | `page_heap_ok` | 三轮精简 | heap.page_heap_ok(...) |
| `freestanding_page_heap_init`      | —                                                             | `freestanding_page_heap_init`      | 已符合命名          | `heap.freestanding_page_heap_init(...)`      |
| `freestanding_page_heap_alloc`     | —                                                             | `freestanding_page_heap_alloc`     | 已符合命名          | `heap.freestanding_page_heap_alloc(...)`     |
| `freestanding_page_heap_deinit`    | —                                                             | `freestanding_page_heap_deinit`    | 已符合命名          | `heap.freestanding_page_heap_deinit(...)`    |


### std.http

`std/http/mod.sx` · 540 APIs · `const http = import("std.http")`


| 当前名称                                            | 功能说明                                                                      | 简化名称                                    | 说明                        | 绑定调用                                              |
| ----------------------------------------------- | ------------------------------------------------------------------------- | --------------------------------------- | ------------------------- | ------------------------------------------------- |
| `method_as_u8` / `method_from_u8`             | Method ↔ u8 判别值（GET=0 … OPTIONS=6）；非法 tag 回退 GET。                      | `method`（重载）                        | 双向合一、按形参类型分派           | `http.method(m)` / `http.method(tag)`             |
| `http_get_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `http.get(...)` |
| `http_post_c` | extern C/平台 | `post` | 去模块前缀+去类型名（C层） | `http.post(...)` |
| `http_head_c` | extern C/平台 | `head` | 去模块前缀+去类型名（C层） | `http.head(...)` |
| `http_put_c` | extern C/平台 | `put` | 去模块前缀+去类型名（C层） | `http.put(...)` |
| `http_delete_c` | extern C/平台 | `delete` | 去模块前缀+去类型名（C层） | `http.delete(...)` |
| `http_patch_c` | extern C/平台 | `patch` | 去模块前缀+去类型名（C层） | `http.patch(...)` |
| `http_options_c` | extern C/平台 | `options` | 去模块前缀+去类型名（C层） | `http.options(...)` |
| `http_get_timeout_c` | extern C/平台 | `get_timeout` | 去模块前缀+去类型名（C层） | `http.get_timeout(...)` |
| `http_post_timeout_c` | extern C/平台 | `post_timeout` | 去模块前缀+去类型名（C层） | `http.post_timeout(...)` |
| `http_head_timeout_c` | extern C/平台 | `head_timeout` | 去模块前缀+去类型名（C层） | `http.head_timeout(...)` |
| `http_put_timeout_c` | extern C/平台 | `put_timeout` | 去模块前缀+去类型名（C层） | `http.put_timeout(...)` |
| `http_delete_timeout_c` | extern C/平台 | `delete_timeout` | 去模块前缀+去类型名（C层） | `http.delete_timeout(...)` |
| `http_patch_timeout_c` | extern C/平台 | `patch_timeout` | 去模块前缀+去类型名（C层） | `http.patch_timeout(...)` |
| `http_options_timeout_c` | extern C/平台 | `options_timeout` | 去模块前缀+去类型名（C层） | `http.options_timeout(...)` |
| `http_request_ex_c` | extern C/平台 | `request_ex` | 去模块前缀+去类型名（C层） | `http.request_ex(...)` |
| `http_request_method_c` | extern C/平台 | `request_method` | 去模块前缀+去类型名（C层） | `http.request_method(...)` |
| `http_request_method_timeout_c` | extern C/平台 | `request_method_timeout` | 去模块前缀+去类型名（C层） | `http.request_method_timeout(...)` |
| `http_respond_get_ok_c` | extern C/平台 | `respond_get_ok` | 去模块前缀+去类型名（C层） | `http.respond_get_ok(...)` |
| `http_listen_c` | extern C/平台 | `listen` | 去模块前缀+去类型名（C层） | `http.listen(...)` |
| `http_serve_one_c` | extern C/平台 | `serve_one` | 去模块前缀+去类型名（C层） | `http.serve_one(...)` |
| `http_client_pool_create_c` | extern C/平台 | `client_pool_create` | 去模块前缀+去类型名（C层） | `http.client_pool_create(...)` |
| `http_client_pool_destroy_c` | extern C/平台 | `client_pool_destroy` | 去模块前缀+去类型名（C层） | `http.client_pool_destroy(...)` |
| `http_client_pool_get_c` | extern C/平台 | `client_pool_get` | 去模块前缀+去类型名（C层） | `http.client_pool_get(...)` |
| `http_parse_status_line_c` | extern C/平台 | `parse_status_line` | 去模块前缀+去类型名（C层） | `http.parse_status_line(...)` |
| `http_headers_body_offset_c` | extern C/平台 | `headers_body_offset` | 去模块前缀+去类型名（C层） | `http.headers_body_offset(...)` |
| `http_has_chunked_encoding_c` | extern C/平台 | `has_chunked_encoding` | 去模块前缀+去类型名（C层） | `http.has_chunked_encoding(...)` |
| `http_has_keep_alive_c` | extern C/平台 | `has_keep_alive` | 去模块前缀+去类型名（C层） | `http.has_keep_alive(...)` |
| `http_decode_chunked_body_c` | extern C/平台 | `decode_chunked_body` | 去模块前缀+去类型名（C层） | `http.decode_chunked_body(...)` |
| `http_build_get_keep_alive_c` | extern C/平台 | `build_get_keep_alive` | 去模块前缀+去类型名（C层） | `http.build_get_keep_alive(...)` |
| `http_is_upgrade_websocket_c` | extern C/平台 | `is_upgrade_websocket` | 去模块前缀+去类型名（C层） | `http.is_upgrade_websocket(...)` |
| `http_build_ws_upgrade_101_c` | extern C/平台 | `build_ws_upgrade` | 去模块前缀+去类型名（C层） | `http.build_ws_upgrade(...)` |
| `http_is_https_available_c` | extern C/平台 | `is_https_available` | 去模块前缀+去类型名（C层） | `http.is_https_available(...)` |
| `http_https_smoke_c` | extern C/平台 | `https_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.https_smoke(...)` |
| `http_err_tls_not_impl`                         | C 层 TLS 不可用（须链入 std.net TLS 后端）。                                          | `err_tls_not_impl`                      | 去模块前缀+去类型名                | `http.err_tls_not_impl(...)`                      |
| `https_is_available`                            | HTTPS 是否可用（OpenSSL/mbedTLS 链入时为 true）。                                    | `https_is_available`                    | 已符合命名                     | `http.https_is_available(...)`（已简洁）               |
| `https_smoke` | HTTPS C 烟测钩子（STD-HTTP-HTTPS）。 | `https_smoke` | 已符合命名；Tier-X 不 export | `http.https_smoke(...)`（已简洁） |
| `get`                                           | HTTP GET；返回写入 out_buf 的字节数，失败 -1。                                         | `get`                                   | 已符合命名                     | `http.get(...)`（已简洁）                              |
| `post`                                          | HTTP POST。                                                                | `post`                                  | 已符合命名                     | `http.post(...)`（已简洁）                             |
| `head`                                          | HTTP HEAD。                                                                | `head`                                  | 已符合命名                     | `http.head(...)`（已简洁）                             |
| `put`                                           | HTTP PUT（带 Content-Length 请求体）。                                           | `put`                                   | 已符合命名                     | `http.put(...)`（已简洁）                              |
| `delete`                                        | HTTP DELETE。                                                              | `delete`                                | 已符合命名                     | `http.delete(...)`（已简洁）                           |
| `patch`                                         | HTTP PATCH（带 Content-Length 请求体）。                                         | `patch`                                 | 已符合命名                     | `http.patch(...)`（已简洁）                            |
| `options`                                       | HTTP OPTIONS。                                                             | `options`                               | 已符合命名                     | `http.options(...)`（已简洁）                          |
| `client_request`                                | —                                                                         | `client_request`                        | 已符合命名                     | `http.client_request(...)`（已简洁）                   |
| `http_response_parse_c` | extern C/平台 | `response_parse` | 去模块前缀+去类型名（C层） | `http.response_parse(...)` |
| `http_response_parse_smoke_c` | extern C/平台 | `response_parse_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.response_parse_smoke(...)` |
| `http_response_body_ptr_c` | extern C/平台 | `response_body_ptr` | 去模块前缀+去类型名（C层） | `http.response_body_ptr(...)` |
| `http_response_body_copy_c` | extern C/平台 | `response_body_copy` | 去模块前缀+去类型名（C层） | `http.response_body_copy(...)` |
| `http_response_body_owned_smoke_c` | extern C/平台 | `response_body_owned_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.response_body_owned_smoke(...)` |
| `http_url_exceeds_string_cap_c` | extern C/平台 | `url_exceeds_string_cap` | 去模块前缀+去类型名（C层） | `http.url_exceeds_string_cap(...)` |
| `http_url_copy_c` | extern C/平台 | `url_copy` | 去模块前缀+去类型名（C层） | `http.url_copy(...)` |
| `http_url_owned_smoke_c` | extern C/平台 | `url_owned_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.url_owned_smoke(...)` |
| `http_request_owned_smoke_c` | extern C/平台 | `request_owned_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.request_owned_smoke(...)` |
| `http_url_string_cap`                           | std.string.String 固定容量（256）。                                              | `url_string_cap`                        | 去模块前缀+去类型名                | `http.url_string_cap(...)`                        |
| `request_init`                                  | —                                                                         | `request_init`                          | 已符合命名                     | `http.request_init(...)`（已简洁）                     |
| `parse_response`                                | 从 raw HTTP/1.x 响应缓冲解析 HttpResponse；成功返回 raw_len，失败 -1。                    | `parse_response`                        | 已符合命名                     | `http.parse_response(...)`（已简洁）                   |
| `execute`                                       | —                                                                         | `execute`                               | 已符合命名                     | `http.execute(...)`（已简洁）                          |
| `response_body_decode`                          | —                                                                         | `response_body_decode`                  | 已符合命名                     | `http.response_body_decode(...)`（已简洁）             |
| `response_parse_smoke` | Request/Response 解析 C 烟测；0 通过。 | `response_parse_smoke` | 已符合命名；Tier-X 不 export | `http.response_parse_smoke(...)`（已简洁） |
| `respond_get_ok`                                | 对已连接 fd 回 200 OK + body（STD-009 server）。                                  | `respond_get_ok`                        | 已符合命名                     | `http.respond_get_ok(...)`（已简洁）                   |
| `listen`                                        | IPv4 listen（addr 主机序，如 127.0.0.1 = 0x7f000001）。                           | `listen`                                | 已符合命名                     | `http.listen(...)`（已简洁）                           |
| `serve_one`                                     | accept 一个连接并 respond_get_ok。                                              | `serve_one`                             | 已符合命名                     | `http.serve_one(...)`（已简洁）                        |
| `client_pool_create`                            | 创建 client 连接池句柄。                                                          | `client_pool_create`                    | 已符合命名                     | `http.client_pool_create(...)`（已简洁）               |
| `client_pool_destroy`                           | 释放连接池。                                                                    | `client_pool_destroy`                   | 已符合命名                     | `http.client_pool_destroy(...)`（已简洁）              |
| `client_pool_get`                               | 经连接池 GET。                                                                 | `client_pool_get`                       | 已符合命名                     | `http.client_pool_get(...)`（已简洁）                  |
| `parse_status_line`                             | —                                                                         | `parse_status_line`                     | 已符合命名                     | `http.parse_status_line(...)`（已简洁）                |
| `headers_body_offset`                           | —                                                                         | `headers_body_offset`                   | 已符合命名                     | `http.headers_body_offset(...)`（已简洁）              |
| `has_chunked_encoding`                          | —                                                                         | `has_chunked_encoding`                  | 已符合命名                     | `http.has_chunked_encoding(...)`（已简洁）             |
| `has_keep_alive`                                | —                                                                         | `has_keep_alive`                        | 已符合命名                     | `http.has_keep_alive(...)`（已简洁）                   |
| `decode_chunked_body`                           | —                                                                         | `decode_chunked_body`                   | 已符合命名                     | `http.decode_chunked_body(...)`（已简洁）              |
| `is_upgrade_websocket`                          | 是否含 Upgrade: websocket（供 std.websocket 握手检测）。                             | `is_upgrade_websocket`                  | 已符合命名                     | `http.is_upgrade_websocket(...)`（已简洁）             |
| `build_ws_upgrade_101`                          | 构建 101 Switching Protocols 响应头。                                           | `build_ws_upgrade`                      | 二次精简：去参数位数/固定值后缀          | `http.build_ws_upgrade(...)`                      |
| `build_get_keep_alive`                          | —                                                                         | `build_get_keep_alive`                  | 已符合命名                     | `http.build_get_keep_alive(...)`（已简洁）             |
| `timeout_ms_for_http`                           | 从 Context 推导 HTTP 超时毫秒；无 deadline 返回 0；取消/过期返回 HTTP_CTX_MS_*。             | `timeout_ms_for_http`                   | 已符合命名                     | `http.timeout_ms_for_http(...)`（已简洁）              |
| `ctx_check_for_http`                            | 请求前检查 Context；0 可继续，否则返回 http_err_cancelled/timeout。                      | `ctx_check_for_http`                    | 已符合命名                     | `http.ctx_check_for_http(...)`（已简洁）               |
| `request_timeout_ms_for_ctx`                    | 从 Context 推导请求超时；已取消/过期直接返回 http_err_*（STD-095）。                          | `request_timeout_ms_for_ctx`            | 已符合命名                     | `http.request_timeout_ms_for_ctx(...)`（已简洁）       |
| `map_http_c_result`                             | 将 C 层 HTTP 错误码映射为 std.error 风格（-1220 → http_err_timeout；-1221 → TLS 不可用）。 | `map_http_c_result`                     | 已符合命名                     | `http.map_http_c_result(...)`（已简洁）                |
| `get_ctx`                                       | 带 Context 的 GET；取消/过期短路，不建连。                                              | `get_ctx`                               | 已符合命名                     | `http.get_ctx(...)`（已简洁）                          |
| `post_ctx`                                      | 带 Context 的 POST。                                                         | `post_ctx`                              | 已符合命名                     | `http.post_ctx(...)`（已简洁）                         |
| `head_ctx`                                      | 带 Context 的 HEAD。                                                         | `head_ctx`                              | 已符合命名                     | `http.head_ctx(...)`（已简洁）                         |
| `put_ctx`                                       | 带 Context 的 PUT。                                                          | `put_ctx`                               | 已符合命名                     | `http.put_ctx(...)`（已简洁）                          |
| `delete_ctx`                                    | 带 Context 的 DELETE。                                                       | `delete_ctx`                            | 已符合命名                     | `http.delete_ctx(...)`（已简洁）                       |
| `patch_ctx`                                     | 带 Context 的 PATCH。                                                        | `patch_ctx`                             | 已符合命名                     | `http.patch_ctx(...)`（已简洁）                        |
| `options_ctx`                                   | 带 Context 的 OPTIONS。                                                      | `options_ctx`                           | 已符合命名                     | `http.options_ctx(...)`（已简洁）                      |
| `client_request_ctx`                            | 带 Context 的统一 request（Method 分发 + 超时/取消）。                                 | `client_request_ctx`                    | 已符合命名                     | `http.client_request_ctx(...)`（已简洁）               |
| `execute_ctx`                                   | —                                                                         | `execute_ctx`                           | 已符合命名                     | `http.execute_ctx(...)`（已简洁）                      |
| `response_body_view`                            | identity 响应 body 零拷贝视图（chunked 须先 response_body_owned/decode）。            | `response_body_view`                    | 已符合命名                     | `http.response_body_view(...)`（已简洁）               |
| `response_body_owned`                           | —                                                                         | `response_body_owned`                   | 已符合命名                     | `http.response_body_owned(...)`（已简洁）              |
| `body_owned_free`                               | 释放 response_body_owned 分配的堆内存。                                            | `body_owned_free`                       | 已符合命名                     | `http.body_owned_free(...)`（已简洁）                  |
| `url_exceeds_string_cap`                        | url_len 是否超过 std.string.String 固定 256 字节。                                 | `url_exceeds_string_cap`                | 已符合命名                     | `http.url_exceeds_string_cap(...)`（已简洁）           |
| `url_owned_from_slice`                          | —                                                                         | `url_owned_from_slice`                  | 已符合命名                     | `http.url_owned_from_slice(...)`（已简洁）             |
| `url_owned_free`                                | 释放 url_owned_from_slice 分配的堆内存。                                           | `url_owned_free`                        | 已符合命名                     | `http.url_owned_free(...)`（已简洁）                   |
| `request_bind_url_owned`                        | —                                                                         | `request_bind_url_owned`                | 已符合命名                     | `http.request_bind_url_owned(...)`（已简洁）           |
| `url_owned_smoke` | 堆 URL 复制 C 烟测；0 通过。 | `url_owned_smoke` | 已符合命名；Tier-X 不 export | `http.url_owned_smoke(...)`（已简洁） |
| `request_owned_init`                            | —                                                                         | `request_owned_init`                    | 已符合命名                     | `http.request_owned_init(...)`（已简洁）               |
| `request_owned_free`                            | 释放 HttpRequestOwned 堆 URL/body。                                           | `request_owned_free`                    | 已符合命名                     | `http.request_owned_free(...)`（已简洁）               |
| `execute_owned`                                 | —                                                                         | `execute_owned`                         | 已符合命名                     | `http.execute_owned(...)`（已简洁）                    |
| `request_owned_smoke` | HttpRequestOwned C 烟测；0 通过。 | `request_owned_smoke` | 已符合命名；Tier-X 不 export | `http.request_owned_smoke(...)`（已简洁） |
| `response_body_owned_smoke` | 堆 body 复制 C 烟测；0 通过。 | `response_body_owned_smoke` | 已符合命名；Tier-X 不 export | `http.response_body_owned_smoke(...)`（已简洁） |
| `response_owned_from_parse`                     | —                                                                         | `response_owned_from_parse`             | 已符合命名                     | `http.response_owned_from_parse(...)`（已简洁）        |
| `response_owned_free`                           | 释放 HttpResponseOwned 堆 body。                                              | `response_owned_free`                   | 已符合命名                     | `http.response_owned_free(...)`（已简洁）              |
| `listen_on`                                     | IPv4 listen 别名（STD-107 manifest 名 listen_on）。                             | `listen_on`                             | 已符合命名                     | `http.listen_on(...)`（已简洁）                        |
| `http2_preface_len_c` | extern C/平台 | `preface_len` | 去模块前缀+去类型名（C层） | `http.preface_len(...)` |
| `http2_is_connection_preface_c` | extern C/平台 | `is_connection_preface` | 去模块前缀+去类型名（C层） | `http.is_connection_preface(...)` |
| `http2_parse_frame_header_c` | extern C/平台 | `parse_frame_header` | 去模块前缀+去类型名（C层） | `http.parse_frame_header(...)` |
| `http2_build_settings_ack_c` | extern C/平台 | `build_settings_ack` | 去模块前缀+去类型名（C层） | `http.build_settings_ack(...)` |
| `http2_build_settings_one_c` | extern C/平台 | `build_settings_one` | 去模块前缀+去类型名（C层） | `http.build_settings_one(...)` |
| `http2_wire_is_available_c` | extern C/平台 | `wire_is_available` | 去模块前缀+去类型名（C层） | `http.wire_is_available(...)` |
| `http2_client_is_available_c` | extern C/平台 | `client_is_available` | 去模块前缀+去类型名（C层） | `http.client_is_available(...)` |
| `http2_alpn_h2_len_c` | extern C/平台 | `alpn_h2_len` | 去模块前缀+去类型名（C层） | `http.alpn_h2_len(...)` |
| `http2_write_alpn_h2_c` | extern C/平台 | `write_alpn_h2` | 去模块前缀+去类型名（C层） | `http.write_alpn_h2(...)` |
| `http2_smoke_c` | extern C/平台 | `smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.smoke(...)` |
| `http2_hpack_encode_indexed_c` | extern C/平台 | `hpack_encode_indexed` | 去模块前缀+去类型名（C层） | `http.hpack_encode_indexed(...)` |
| `http2_hpack_encode_literal_c` | extern C/平台 | `hpack_encode_literal` | 去模块前缀+去类型名（C层） | `http.hpack_encode_literal(...)` |
| `http2_hpack_encode_get_request_c` | extern C/平台 | `hpack_encode_get_request` | 去模块前缀+去类型名（C层） | `http.hpack_encode_get_request(...)` |
| `http2_hpack_decode_status_c` | extern C/平台 | `hpack_decode_status` | 去模块前缀+去类型名（C层） | `http.hpack_decode_status(...)` |
| `http2_hpack_smoke_c` | extern C/平台 | `hpack_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.hpack_smoke(...)` |
| `http2_hpack_dyn_reset_c` | extern C/平台 | `hpack_dyn_reset` | 去模块前缀+去类型名（C层） | `http.hpack_dyn_reset(...)` |
| `http2_hpack_dyn_count_c` | extern C/平台 | `hpack_dyn_count` | 去模块前缀+去类型名（C层） | `http.hpack_dyn_count(...)` |
| `http2_hpack_encode_literal_incremental_c` | extern C/平台 | `hpack_encode_literal_incremental` | 去模块前缀+去类型名（C层） | `http.hpack_encode_literal_incremental(...)` |
| `http2_hpack_encode_indexed_any_c` | extern C/平台 | `hpack_encode_indexed_any` | 去模块前缀+去类型名（C层） | `http.hpack_encode_indexed_any(...)` |
| `http2_hpack_encode_request_c` | extern C/平台 | `hpack_encode_request` | 去模块前缀+去类型名（C层） | `http.hpack_encode_request(...)` |
| `http2_hpack_dyn_smoke_c` | extern C/平台 | `hpack_dyn_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.hpack_dyn_smoke(...)` |
| `http2_hpack_server_dyn_create_c` | extern C/平台 | `hpack_server_dyn_create` | 去模块前缀+去类型名（C层） | `http.hpack_server_dyn_create(...)` |
| `http2_hpack_server_dyn_destroy_c` | extern C/平台 | `hpack_server_dyn_destroy` | 去模块前缀+去类型名（C层） | `http.hpack_server_dyn_destroy(...)` |
| `http2_hpack_server_dyn_set_table_size_h_c` | extern C/平台 | `hpack_server_dyn_set_table_size_h` | 去模块前缀+去类型名（C层） | `http.hpack_server_dyn_set_table_size_h(...)` |
| `http2_hpack_server_dyn_max_size_h_c` | extern C/平台 | `hpack_server_dyn_max_size_h` | 去模块前缀+去类型名（C层） | `http.hpack_server_dyn_max_size_h(...)` |
| `http2_hpack_server_dyn_count_h_c` | extern C/平台 | `hpack_server_dyn_count_h` | 去模块前缀+去类型名（C层） | `http.hpack_server_dyn_count_h(...)` |
| `http2_hpack_server_encode_status_h_c` | extern C/平台 | `hpack_server_encode_status_h` | 去模块前缀+去类型名（C层） | `http.hpack_server_encode_status_h(...)` |
| `http2_hpack_server_dyn_smoke_c` | extern C/平台 | `hpack_server_dyn_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.hpack_server_dyn_smoke(...)` |
| `http2_frame_payload_limit_c` | extern C/平台 | `frame_payload_limit` | 去模块前缀+去类型名（C层） | `http.frame_payload_limit(...)` |
| `http2_frame_check_payload_c` | extern C/平台 | `frame_check_payload` | 去模块前缀+去类型名（C层） | `http.frame_check_payload(...)` |
| `http2_frame_count_data_chunks_c` | extern C/平台 | `frame_count_data_chunks` | 去模块前缀+去类型名（C层） | `http.frame_count_data_chunks(...)` |
| `http2_frame_capped_smoke_c` | extern C/平台 | `frame_capped_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.frame_capped_smoke(...)` |
| `http2_frame_goaway_c` | extern C/平台 | `frame_goaway` | 去模块前缀+去类型名（C层） | `http.frame_goaway(...)` |
| `http2_goaway_error_no_error_c` | extern C/平台 | `goaway_error_no_error` | 去模块前缀+去类型名（C层） | `http.goaway_error_no_error(...)` |
| `http2_err_goaway_c` | extern C/平台 | `err_goaway` | 去模块前缀+去类型名（C层） | `http.err_goaway(...)` |
| `http2_build_goaway_c` | extern C/平台 | `build_goaway` | 去模块前缀+去类型名（C层） | `http.build_goaway(...)` |
| `http2_parse_goaway_c` | extern C/平台 | `parse_goaway` | 去模块前缀+去类型名（C层） | `http.parse_goaway(...)` |
| `http2_goaway_smoke_c` | extern C/平台 | `goaway_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.goaway_smoke(...)` |
| `http2_frame_ping_c` | extern C/平台 | `frame_ping` | 去模块前缀+去类型名（C层） | `http.frame_ping(...)` |
| `http2_err_ping_c` | extern C/平台 | `err_ping` | 去模块前缀+去类型名（C层） | `http.err_ping(...)` |
| `http2_build_ping_c` | extern C/平台 | `build_ping` | 去模块前缀+去类型名（C层） | `http.build_ping(...)` |
| `http2_build_ping_ack_c` | extern C/平台 | `build_ping_ack` | 去模块前缀+去类型名（C层） | `http.build_ping_ack(...)` |
| `http2_parse_ping_c` | extern C/平台 | `parse_ping` | 去模块前缀+去类型名（C层） | `http.parse_ping(...)` |
| `http2_ping_opaque_match_c` | extern C/平台 | `ping_opaque_match` | 去模块前缀+去类型名（C层） | `http.ping_opaque_match(...)` |
| `http2_ping_smoke_c` | extern C/平台 | `ping_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.ping_smoke(...)` |
| `http2_frame_rst_stream_c` | extern C/平台 | `frame_rst_stream` | 去模块前缀+去类型名（C层） | `http.frame_rst_stream(...)` |
| `http2_rst_error_cancel_c` | extern C/平台 | `rst_error_cancel` | 去模块前缀+去类型名（C层） | `http.rst_error_cancel(...)` |
| `http2_err_rst_stream_c` | extern C/平台 | `err_rst_stream` | 去模块前缀+去类型名（C层） | `http.err_rst_stream(...)` |
| `http2_build_rst_stream_c` | extern C/平台 | `build_rst_stream` | 去模块前缀+去类型名（C层） | `http.build_rst_stream(...)` |
| `http2_parse_rst_stream_c` | extern C/平台 | `parse_rst_stream` | 去模块前缀+去类型名（C层） | `http.parse_rst_stream(...)` |
| `http2_rst_stream_smoke_c` | extern C/平台 | `rst_stream_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.rst_stream_smoke(...)` |
| `http2_conn_reset_stream_c` | extern C/平台 | `conn_reset_stream` | 去模块前缀+去类型名（C层） | `http.conn_reset_stream(...)` |
| `http2_http2_complete_smoke_c` | extern C/平台 | `complete_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.complete_smoke(...)` |
| `http2_build_headers_frame_c` | extern C/平台 | `build_headers_frame` | 去模块前缀+去类型名（C层） | `http.build_headers_frame(...)` |
| `http2_build_data_frame_c` | extern C/平台 | `build_data_frame` | 去模块前缀+去类型名（C层） | `http.build_data_frame(...)` |
| `http2_build_get_headers_frame_c` | extern C/平台 | `build_get_headers_frame` | 去模块前缀+去类型名（C层） | `http.build_get_headers_frame(...)` |
| `http2_build_request_headers_frame_c` | extern C/平台 | `build_request_headers_frame` | 去模块前缀+去类型名（C层） | `http.build_request_headers_frame(...)` |
| `http2_client_smoke_c` | extern C/平台 | `client_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.client_smoke(...)` |
| `http2_network_is_available_c` | extern C/平台 | `network_is_available` | 去模块前缀+去类型名（C层） | `http.network_is_available(...)` |
| `http2_network_smoke_c` | extern C/平台 | `network_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.network_smoke(...)` |
| `http_h2_get_c` | extern C/平台 | `h2_get` | 去模块前缀+去类型名（C层） | `http.h2_get(...)` |
| `http_h2_request_c` | extern C/平台 | `h2_request` | 去模块前缀+去类型名（C层） | `http.h2_request(...)` |
| `http_request_method_h2_c` | extern C/平台 | `request_method_h2` | 去模块前缀+去类型名（C层） | `http.request_method_h2(...)` |
| `http2_hpack_huffman_decode_c` | extern C/平台 | `hpack_huffman_decode` | 去模块前缀+去类型名（C层） | `http.hpack_huffman_decode(...)` |
| `http2_hpack_huffman_is_available_c` | extern C/平台 | `hpack_huffman_is_available` | 去模块前缀+去类型名（C层） | `http.hpack_huffman_is_available(...)` |
| `http2_hpack_huffman_smoke_c` | extern C/平台 | `hpack_huffman_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.hpack_huffman_smoke(...)` |
| `http2_build_window_update_c` | extern C/平台 | `build_window_update` | 去模块前缀+去类型名（C层） | `http.build_window_update(...)` |
| `http2_default_initial_window_c` | extern C/平台 | `default_initial_window` | 去模块前缀+去类型名（C层） | `http.default_initial_window(...)` |
| `http2_flow_control_smoke_c` | extern C/平台 | `flow_control_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.flow_control_smoke(...)` |
| `http2_flow_state_init_c` | extern C/平台 | `flow_state_init` | 去模块前缀+去类型名（C层） | `http.flow_state_init(...)` |
| `http2_flow_state_reset_stream_c` | extern C/平台 | `flow_state_reset_stream` | 去模块前缀+去类型名（C层） | `http.flow_state_reset_stream(...)` |
| `http2_flow_state_apply_initial_window_c` | extern C/平台 | `flow_state_apply_initial_window` | 去模块前缀+去类型名（C层） | `http.flow_state_apply_initial_window(...)` |
| `http2_flow_state_apply_window_update_c` | extern C/平台 | `flow_state_apply_window_update` | 去模块前缀+去类型名（C层） | `http.flow_state_apply_window_update(...)` |
| `http2_flow_state_max_send_c` | extern C/平台 | `flow_state_max_send` | 去模块前缀+去类型名（C层） | `http.flow_state_max_send(...)` |
| `http2_flow_state_can_send_c` | extern C/平台 | `flow_state_can_send` | 去模块前缀+去类型名（C层） | `http.flow_state_can_send(...)` |
| `http2_flow_state_consume_send_c` | extern C/平台 | `flow_state_consume_send` | 去模块前缀+去类型名（C层） | `http.flow_state_consume_send(...)` |
| `http2_parse_window_update_payload_c` | extern C/平台 | `parse_window_update_payload` | 去模块前缀+去类型名（C层） | `http.parse_window_update_payload(...)` |
| `http2_flow_state_smoke_c` | extern C/平台 | `flow_state_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.flow_state_smoke(...)` |
| `http2_flow_recv_init_c` | extern C/平台 | `flow_recv_init` | 去模块前缀+去类型名（C层） | `http.flow_recv_init(...)` |
| `http2_flow_recv_reset_stream_c` | extern C/平台 | `flow_recv_reset_stream` | 去模块前缀+去类型名（C层） | `http.flow_recv_reset_stream(...)` |
| `http2_flow_recv_on_data_c` | extern C/平台 | `flow_recv_on_data` | 去模块前缀+去类型名（C层） | `http.flow_recv_on_data(...)` |
| `http2_flow_recv_release_c` | extern C/平台 | `flow_recv_release` | 去模块前缀+去类型名（C层） | `http.flow_recv_release(...)` |
| `http2_flow_recv_smoke_c` | extern C/平台 | `flow_recv_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.flow_recv_smoke(...)` |
| `http2_frame_push_promise_c` | extern C/平台 | `frame_push_promise` | 去模块前缀+去类型名（C层） | `http.frame_push_promise(...)` |
| `http2_is_push_promise_frame_c` | extern C/平台 | `is_push_promise_frame` | 去模块前缀+去类型名（C层） | `http.is_push_promise_frame(...)` |
| `http2_parse_push_promise_stream_c` | extern C/平台 | `parse_push_promise_stream` | 去模块前缀+去类型名（C层） | `http.parse_push_promise_stream(...)` |
| `http2_is_h2c_upgrade_response_c` | extern C/平台 | `is_h2c_upgrade_response` | 去模块前缀+去类型名（C层） | `http.is_h2c_upgrade_response(...)` |
| `http2_h2c_is_available_c` | extern C/平台 | `h2c_is_available` | 去模块前缀+去类型名（C层） | `http.h2c_is_available(...)` |
| `http2_push_h2c_smoke_c` | extern C/平台 | `push_h2c_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.push_h2c_smoke(...)` |
| `http2_h2c_wire_is_available_c` | extern C/平台 | `h2c_wire_is_available` | 去模块前缀+去类型名（C层） | `http.h2c_wire_is_available(...)` |
| `http2_h2c_session_begin_c` | extern C/平台 | `h2c_session_begin` | 去模块前缀+去类型名（C层） | `http.h2c_session_begin(...)` |
| `http2_push_collect_data_c` | extern C/平台 | `push_collect_data` | 去模块前缀+去类型名（C层） | `http.push_collect_data(...)` |
| `http2_push_fetch_smoke_c` | extern C/平台 | `push_fetch_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.push_fetch_smoke(...)` |
| `http2_push_last_reset_c` | extern C/平台 | `push_last_reset` | 去模块前缀+去类型名（C层） | `http.push_last_reset(...)` |
| `http2_push_last_copy_c` | extern C/平台 | `push_last_copy` | 去模块前缀+去类型名（C层） | `http.push_last_copy(...)` |
| `http2_push_network_smoke_c` | extern C/平台 | `push_network_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.push_network_smoke(...)` |
| `http2_session_request_h2c_c` | extern C/平台 | `session_request_h2c` | 去模块前缀+去类型名（C层） | `http.session_request_h2c(...)` |
| `http2_h2c_network_smoke_c` | extern C/平台 | `h2c_network_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.h2c_network_smoke(...)` |
| `http_h2c_get_c` | extern C/平台 | `h2c_get` | 去模块前缀+去类型名（C层） | `http.h2c_get(...)` |
| `http_h2c_request_c` | extern C/平台 | `h2c_request` | 去模块前缀+去类型名（C层） | `http.h2c_request(...)` |
| `http_request_method_h2c_c` | extern C/平台 | `request_method_h2c` | 去模块前缀+去类型名（C层） | `http.request_method_h2c(...)` |
| `http_h2c_client_smoke_c` | extern C/平台 | `h2c_client_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.h2c_client_smoke(...)` |
| `http2_stream_registry_init_c` | extern C/平台 | `init` | 二次精简：去对象前缀 | `http.init(...)` |
| `http2_stream_registry_open_c` | extern C/平台 | `open` | 二次精简：去对象前缀 | `http.open(...)` |
| `http2_stream_registry_close_c` | extern C/平台 | `close` | 二次精简：去对象前缀 | `http.close(...)` |
| `http2_stream_registry_is_open_c` | extern C/平台 | `is_open` | 二次精简：去对象前缀 | `http.is_open(...)` |
| `http2_stream_registry_smoke_c` | extern C/平台 | `smoke` | 二次精简：去对象前缀；Tier-X 不 export | `http.smoke(...)` |
| `http2_peer_settings_init_c` | extern C/平台 | `peer_settings_init` | 去模块前缀+去类型名（C层） | `http.peer_settings_init(...)` |
| `http2_settings_entry_count_c` | extern C/平台 | `settings_entry_count` | 去模块前缀+去类型名（C层） | `http.settings_entry_count(...)` |
| `http2_parse_settings_entry_c` | extern C/平台 | `parse_settings_entry` | 去模块前缀+去类型名（C层） | `http.parse_settings_entry(...)` |
| `http2_peer_settings_apply_entry_c` | extern C/平台 | `peer_settings_apply_entry` | 去模块前缀+去类型名（C层） | `http.peer_settings_apply_entry(...)` |
| `http2_peer_settings_consume_payload_c` | extern C/平台 | `peer_settings_consume_payload` | 去模块前缀+去类型名（C层） | `http.peer_settings_consume_payload(...)` |
| `http2_build_client_settings_c` | extern C/平台 | `build_client_settings` | 去模块前缀+去类型名（C层） | `http.build_client_settings(...)` |
| `http2_build_client_settings_ex_c` | extern C/平台 | `build_client_settings_ex` | 去模块前缀+去类型名（C层） | `http.build_client_settings_ex(...)` |
| `http2_build_client_settings_with_max_frame_c` | extern C/平台 | `build_client_settings_with_max_frame` | 去模块前缀+去类型名（C层） | `http.build_client_settings_with_max_frame(...)` |
| `http2_build_server_settings_c` | extern C/平台 | `build_server_settings` | 去模块前缀+去类型名（C层） | `http.build_server_settings(...)` |
| `http2_setting_enable_push_c` | extern C/平台 | `setting_enable_push` | 去模块前缀+去类型名（C层） | `http.setting_enable_push(...)` |
| `http2_setting_header_table_size_c` | extern C/平台 | `setting_header_table_size` | 去模块前缀+去类型名（C层） | `http.setting_header_table_size(...)` |
| `http2_setting_max_frame_size_c` | extern C/平台 | `setting_max_frame_size` | 去模块前缀+去类型名（C层） | `http.setting_max_frame_size(...)` |
| `http2_setting_max_header_list_size_c` | extern C/平台 | `setting_max_header_list_size` | 去模块前缀+去类型名（C层） | `http.setting_max_header_list_size(...)` |
| `http2_peer_settings_enable_push_c` | extern C/平台 | `peer_settings_enable_push` | 去模块前缀+去类型名（C层） | `http.peer_settings_enable_push(...)` |
| `http2_peer_settings_header_table_size_c` | extern C/平台 | `peer_settings_header_table_size` | 去模块前缀+去类型名（C层） | `http.peer_settings_header_table_size(...)` |
| `http2_peer_settings_max_frame_size_c` | extern C/平台 | `peer_settings_max_frame_size` | 去模块前缀+去类型名（C层） | `http.peer_settings_max_frame_size(...)` |
| `http2_peer_settings_max_header_list_size_c` | extern C/平台 | `peer_settings_max_header_list_size` | 去模块前缀+去类型名（C层） | `http.peer_settings_max_header_list_size(...)` |
| `http2_peer_settings_max_streams_c` | extern C/平台 | `peer_settings_max_streams` | 去模块前缀+去类型名（C层） | `http.peer_settings_max_streams(...)` |
| `http2_peer_settings_initial_window_c` | extern C/平台 | `peer_settings_initial_window` | 去模块前缀+去类型名（C层） | `http.peer_settings_initial_window(...)` |
| `http2_settings_smoke_c` | extern C/平台 | `settings_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.settings_smoke(...)` |
| `http2_multistream_client_init_c` | extern C/平台 | `client_init` | 去模块前缀+去类型名（C层） | `http.client_init(...)` |
| `http2_multistream_client_on_settings_c` | extern C/平台 | `client_on_settings` | 去模块前缀+去类型名（C层）；三轮精简 | `http.client_on_settings(...)` |
| `http2_multistream_client_open_stream_c` | extern C/平台 | `client_open` | 去模块前缀+去类型名（C层） | `http.client_open(...)` |
| `http2_multistream_client_close_stream_c` | extern C/平台 | `client_close` | 去模块前缀+去类型名（C层） | `http.client_close(...)` |
| `http2_multistream_client_build_get_c` | extern C/平台 | `client_get` | 去模块前缀+去类型名（C层） | `http.client_get(...)` |
| `http2_multistream_client_build_parallel_get_c` | extern C/平台                                                               | `client_parallel_get` | 去模块前缀+去类型名（C层） | http.multistream_client_build_parallel_get(...) |
| `http2_multistream_client_smoke_c` | extern C/平台 | `client_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.client_smoke(...)` |
| `http2_conn_init_c` | extern C/平台 | `conn_init` | 去模块前缀+去类型名（C层） | `http.conn_init(...)` |
| `http2_conn_attach_h2c_c` | extern C/平台 | `conn_attach_h2c` | 去模块前缀+去类型名（C层） | `http.conn_attach_h2c(...)` |
| `http2_conn_attach_tls_c` | extern C/平台 | `conn_attach_tls` | 去模块前缀+去类型名（C层） | `http.conn_attach_tls(...)` |
| `http2_conn_is_ready_c` | extern C/平台 | `conn_is_ready` | 去模块前缀+去类型名（C层） | `http.conn_is_ready(...)` |
| `http2_conn_handshake_c` | extern C/平台 | `conn_handshake` | 去模块前缀+去类型名（C层） | `http.conn_handshake(...)` |
| `http2_conn_handshake_with_enable_push_c` | extern C/平台 | `conn_handshake_with_enable_push` | 去模块前缀+去类型名（C层） | `http.conn_handshake_with_enable_push(...)` |
| `http2_conn_handshake_with_max_frame_c` | extern C/平台 | `conn_handshake_with_max_frame` | 去模块前缀+去类型名（C层） | `http.conn_handshake_with_max_frame(...)` |
| `http2_conn_request_c` | extern C/平台 | `conn_request` | 去模块前缀+去类型名（C层） | `http.conn_request(...)` |
| `http2_conn_close_c` | extern C/平台 | `conn_close` | 去模块前缀+去类型名（C层） | `http.conn_close(...)` |
| `http2_conn_shutdown_graceful_c` | extern C/平台 | `conn_shutdown_graceful` | 去模块前缀+去类型名（C层） | `http.conn_shutdown_graceful(...)` |
| `http2_conn_read_goaway_c` | extern C/平台 | `conn_read_goaway` | 去模块前缀+去类型名（C层） | `http.conn_read_goaway(...)` |
| `http2_conn_ping_c` | extern C/平台 | `conn_ping` | 去模块前缀+去类型名（C层） | `http.conn_ping(...)` |
| `http2_conn_goaway_seen_c` | extern C/平台 | `conn_goaway_seen` | 去模块前缀+去类型名（C层） | `http.conn_goaway_seen(...)` |
| `http2_conn_is_pool_reusable_c` | extern C/平台 | `conn_is_pool_reusable` | 去模块前缀+去类型名（C层） | `http.conn_is_pool_reusable(...)` |
| `http2_conn_goaway_smoke_c` | extern C/平台 | `conn_goaway_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.conn_goaway_smoke(...)` |
| `http2_conn_ping_smoke_c` | extern C/平台 | `conn_ping_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.conn_ping_smoke(...)` |
| `http2_conn_reuse_smoke_c` | extern C/平台 | `conn_reuse_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.conn_reuse_smoke(...)` |
| `http2_conn_reuse_is_available_c` | extern C/平台 | `conn_reuse_is_available` | 去模块前缀+去类型名（C层） | `http.conn_reuse_is_available(...)` |
| `http2_conn_pool_create_h2c_c` | extern C/平台 | `conn_pool_create_h2c` | 去模块前缀+去类型名（C层） | `http.conn_pool_create_h2c(...)` |
| `http2_conn_pool_create_h2_c` | extern C/平台 | `conn_pool_create_h2` | 去模块前缀+去类型名（C层） | `http.conn_pool_create_h2(...)` |
| `http2_conn_pool_destroy_c` | extern C/平台 | `conn_pool_destroy` | 去模块前缀+去类型名（C层） | `http.conn_pool_destroy(...)` |
| `http2_conn_pool_request_c` | extern C/平台 | `conn_pool_request` | 去模块前缀+去类型名（C层） | `http.conn_pool_request(...)` |
| `http_h2c_pool_get_c` | extern C/平台 | `h2c_pool_get` | 去模块前缀+去类型名（C层） | `http.h2c_pool_get(...)` |
| `http_h2_pool_get_c` | extern C/平台 | `h2_pool_get` | 去模块前缀+去类型名（C层） | `http.h2_pool_get(...)` |
| `http2_conn_pool_smoke_c` | extern C/平台 | `conn_pool_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.conn_pool_smoke(...)` |
| `http2_conn_pool_goaway_smoke_c` | extern C/平台 | `conn_pool_goaway_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.conn_pool_goaway_smoke(...)` |
| `http2_conn_pool_connect_count_c` | extern C/平台 | `conn_pool_connect_count` | 去模块前缀+去类型名（C层） | `http.conn_pool_connect_count(...)` |
| `http2_conn_pool_is_available_c` | extern C/平台 | `conn_pool_is_available` | 去模块前缀+去类型名（C层） | `http.conn_pool_is_available(...)` |
| `http2_global_pool_create_c` | extern C/平台 | `global_pool_create` | 去模块前缀+去类型名（C层） | `http.global_pool_create(...)` |
| `http2_global_pool_destroy_c` | extern C/平台 | `global_pool_destroy` | 去模块前缀+去类型名（C层） | `http.global_pool_destroy(...)` |
| `http2_global_pool_get_c` | extern C/平台 | `global_pool_get` | 去模块前缀+去类型名（C层） | `http.global_pool_get(...)` |
| `http2_global_pool_request_c` | extern C/平台 | `global_pool_request` | 去模块前缀+去类型名（C层） | `http.global_pool_request(...)` |
| `http2_global_pool_entry_count_c` | extern C/平台 | `global_pool_entry_count` | 去模块前缀+去类型名（C层） | `http.global_pool_entry_count(...)` |
| `http2_global_pool_connect_count_c` | extern C/平台 | `global_pool_connect_count` | 去模块前缀+去类型名（C层） | `http.global_pool_connect_count(...)` |
| `http2_global_pool_smoke_c` | extern C/平台 | `global_pool_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.global_pool_smoke(...)` |
| `http2_global_pool_is_available_c` | extern C/平台 | `global_pool_is_available` | 去模块前缀+去类型名（C层） | `http.global_pool_is_available(...)` |
| `http2_serve_h2c_one_c` | extern C/平台 | `serve_h2c_one` | 去模块前缀+去类型名（C层） | `http.serve_h2c_one(...)` |
| `http2_serve_h2c_one_with_goaway_c` | extern C/平台 | `serve_h2c_one_with_goaway` | 去模块前缀+去类型名（C层） | `http.serve_h2c_one_with_goaway(...)` |
| `http2_server_serve_h2c_c` | extern C/平台 | `server_serve_h2c` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c(...)` |
| `http2_server_serve_h2c_with_goaway_c` | extern C/平台 | `server_serve_h2c_with_goaway` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c_with_goaway(...)` |
| `http2_serve_h2c_one_ping_echo_c` | extern C/平台 | `serve_h2c_one_ping_echo` | 去模块前缀+去类型名（C层） | `http.serve_h2c_one_ping_echo(...)` |
| `http2_server_serve_h2c_ping_echo_c` | extern C/平台 | `server_serve_h2c_ping_echo` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c_ping_echo(...)` |
| `http2_serve_h2c_one_with_push_c` | extern C/平台 | `serve_h2c_one_with_push` | 去模块前缀+去类型名（C层） | `http.serve_h2c_one_with_push(...)` |
| `http2_server_serve_h2c_with_push_c` | extern C/平台 | `server_serve_h2c_with_push` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c_with_push(...)` |
| `http2_server_serve_h2_with_push_c` | extern C/平台 | `server_serve_h2_with_push` | 去模块前缀+去类型名（C层） | `http.server_serve_h2_with_push(...)` |
| `http2_serve_h2_one_with_push_c` | extern C/平台 | `serve_h2_one_with_push` | 去模块前缀+去类型名（C层） | `http.serve_h2_one_with_push(...)` |
| `http2_server_push_smoke_c` | extern C/平台 | `server_push_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_push_smoke(...)` |
| `http2_server_push_tls_smoke_c` | extern C/平台 | `server_push_tls_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_push_tls_smoke(...)` |
| `http2_server_push_settings_smoke_c` | extern C/平台 | `server_push_settings_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_push_settings_smoke(...)` |
| `http2_server_settings_full_smoke_c` | extern C/平台 | `server_settings_full_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_settings_full_smoke(...)` |
| `http2_server_hpack_dyn_smoke_c` | extern C/平台 | `server_hpack_dyn_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_hpack_dyn_smoke(...)` |
| `http2_server_max_frame_smoke_c` | extern C/平台 | `server_max_frame_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_max_frame_smoke(...)` |
| `http2_server_push_is_available_c` | extern C/平台 | `server_push_is_available` | 去模块前缀+去类型名（C层） | `http.server_push_is_available(...)` |
| `http2_serve_h2c_multi_one_c` | extern C/平台 | `serve_h2c_multi_one` | 去模块前缀+去类型名（C层） | `http.serve_h2c_multi_one(...)` |
| `http2_server_serve_h2c_multi_c` | extern C/平台 | `server_serve_h2c_multi` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c_multi(...)` |
| `http2_serve_h2c_multi_one_with_push_c` | extern C/平台 | `serve_h2c_multi_one_with_push` | 去模块前缀+去类型名（C层） | `http.serve_h2c_multi_one_with_push(...)` |
| `http2_server_serve_h2c_multi_with_push_c` | extern C/平台 | `server_serve_h2c_multi_with_push` | 去模块前缀+去类型名（C层） | `http.server_serve_h2c_multi_with_push(...)` |
| `http2_serve_h2_multi_one_c` | extern C/平台 | `serve_h2_multi_one` | 去模块前缀+去类型名（C层） | `http.serve_h2_multi_one(...)` |
| `http2_server_serve_h2_multi_c` | extern C/平台 | `server_serve_h2_multi` | 去模块前缀+去类型名（C层） | `http.server_serve_h2_multi(...)` |
| `http2_serve_h2_multi_one_with_push_c` | extern C/平台 | `serve_h2_multi_one_with_push` | 去模块前缀+去类型名（C层） | `http.serve_h2_multi_one_with_push(...)` |
| `http2_server_serve_h2_multi_with_push_c` | extern C/平台 | `server_serve_h2_multi_with_push` | 去模块前缀+去类型名（C层） | `http.server_serve_h2_multi_with_push(...)` |
| `http2_server_multistream_push_smoke_c` | extern C/平台 | `server_multistream_push_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_multistream_push_smoke(...)` |
| `http2_server_multistream_push_is_available_c` | extern C/平台 | `server_multistream_push_is_available` | 去模块前缀+去类型名（C层） | `http.server_multistream_push_is_available(...)` |
| `http2_server_multistream_smoke_c` | extern C/平台 | `server_multistream_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_multistream_smoke(...)` |
| `http2_server_multistream_is_available_c` | extern C/平台 | `server_multistream_is_available` | 去模块前缀+去类型名（C层） | `http.server_multistream_is_available(...)` |
| `http2_server_smoke_c` | extern C/平台 | `server_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `http.server_smoke(...)` |
| `http2_server_is_available_c` | extern C/平台 | `server_is_available` | 去模块前缀+去类型名（C层） | `http.server_is_available(...)` |
| `http2_serve_h2_one_c` | extern C/平台 | `serve_h2_one` | 去模块前缀+去类型名（C层） | `http.serve_h2_one(...)` |
| `http2_server_serve_h2_c` | extern C/平台 | `server_serve_h2` | 去模块前缀+去类型名（C层） | `http.server_serve_h2(...)` |
| `http2_tls_server_ctx_create_c` | extern C/平台 | `tls_server_ctx_create` | 去模块前缀+去类型名（C层） | `http.tls_server_ctx_create(...)` |
| `http2_tls_server_ctx_destroy_c` | extern C/平台 | `tls_server_ctx_destroy` | 去模块前缀+去类型名（C层） | `http.tls_server_ctx_destroy(...)` |
| `http2_hpack_decode_get_request_c` | extern C/平台 | `hpack_decode_get_request` | 去模块前缀+去类型名（C层） | `http.hpack_decode_get_request(...)` |
| `http2_hpack_encode_status_c` | extern C/平台 | `hpack_encode_status` | 去模块前缀+去类型名（C层） | `http.hpack_encode_status(...)` |
| `err_push_not_impl`                       | HTTP/2 server push 未实现（旧 API；读路径已可收集）。                                    | `err_push_not_impl`                     | 去模块前缀+去类型名                | `http.err_push_not_impl(...)`                     |
| `err_h2c_not_impl`                        | HTTP/2 h2c 升级路径未实现（直连 preface 见 h2c_session_begin）。                 | `err_h2c_not_impl`                      | 去模块前缀+去类型名                | `http.err_h2c_not_impl(...)`                      |
| `err_h2c_scheme`                          | h2c 仅支持 http://；https:// URL 返回此错误（-1235）。                                | `err_h2c_scheme`                        | 去模块前缀+去类型名                | `http.err_h2c_scheme(...)`                        |
| `err_max_streams`                         | 并发 stream 已达对端 SETTINGS 上限（-1236）。                                        | `err_max_streams`                       | 去模块前缀+去类型名                | `http.err_max_streams(...)`                       |
| `err_conn_not_ready`                      | 连接未完成 handshake（-1237）。                                                   | `err_conn_not_ready`                    | 去模块前缀+去类型名                | `http.err_conn_not_ready(...)`                    |
| `err_pool_scheme`                         | URL scheme 与 H2 连接池类型不匹配（-1238）。                                          | `err_pool_scheme`                       | 去模块前缀+去类型名                | `http.err_pool_scheme(...)`                       |
| `err_global_pool_full`                    | 全局 H2 连接池 host:port 条目已满（-1239）。                                          | `err_global_pool_full`                  | 去模块前缀+去类型名                | `http.err_global_pool_full(...)`                  |
| `err_server`                              | HTTP/2 h2c server 协议/请求错误（-1240）。                                         | `err_server`                            | 去模块前缀+去类型名                | `http.err_server(...)`                            |
| `err_server_push`                         | HTTP/2 server push 发送侧参数非法（-1242）。                                        | `err_server_push`                       | 去模块前缀+去类型名                | `http.err_server_push(...)`                       |
| `err_server_push_disabled`                | client SETTINGS ENABLE_PUSH=0，server 软拒绝 push（-1243）。                     | `err_server_push_disabled`              | 去模块前缀+去类型名                | `http.err_server_push_disabled(...)`              |
| `err_goaway`                              | 对端发送 GOAWAY / 期望 GOAWAY 时语义码（-1244）。                                      | `err_goaway`                            | 去模块前缀+去类型名                | `http.err_goaway(...)`                            |
| `err_ping`                                | PING 往返失败 / 未收到匹配 PONG（-1245）。                                            | `err_ping`                              | 去模块前缀+去类型名                | `http.err_ping(...)`                              |
| `err_rst_stream`                          | 对端 RST_STREAM / stream 被取消（-1246）。                                        | `err_rst_stream`                        | 去模块前缀+去类型名                | `http.err_rst_stream(...)`                        |
| `err_server_tls`                          | HTTP/2 over TLS server 不可用或 ALPN 非 h2（-1241）。                             | `err_server_tls`                        | 去模块前缀+去类型名                | `http.err_server_tls(...)`                        |
| `err_flow_blocked`                        | HTTP/2 发送窗口耗尽（须 WINDOW_UPDATE；v5 流控状态机）。                                  | `err_flow_blocked`                      | 去模块前缀+去类型名                | `http.err_flow_blocked(...)`                      |
| `err_network_h2`                          | HTTP/2 网络 h2 over TLS 不可用（须 std.net ALPN；v2）。                             | `err_network_h2`                        | 去模块前缀+去类型名                | `http.err_network_h2(...)`                        |
| `err_not_impl`                            | HTTP/2 完整编解码层不可用（v1 前占位；现与 client_is_available 对齐）。                       | `err_not_impl`                          | 去模块前缀+去类型名                | `http.err_not_impl(...)`                          |
| `frame_data`                              | DATA 帧类型。                                                                 | `frame_data`                            | 去模块前缀+去类型名                | `http.frame_data(...)`                            |
| `frame_headers`                           | HEADERS 帧类型。                                                              | `frame_headers`                         | 去模块前缀+去类型名                | `http.frame_headers(...)`                         |
| `frame_settings`                          | SETTINGS 帧类型（RFC 7540）。                                                   | `frame_settings`                        | 去模块前缀+去类型名                | `http.frame_settings(...)`                        |
| `flag_end_stream`                         | END_STREAM 标志。                                                            | `flag_end_stream`                       | 去模块前缀+去类型名                | `http.flag_end_stream(...)`                       |
| `flag_end_headers`                        | END_HEADERS 标志。                                                           | `flag_end_headers`                      | 去模块前缀+去类型名                | `http.flag_end_headers(...)`                      |
| `flag_ack`                                | SETTINGS ACK 标志。                                                          | `flag_ack`                              | 去模块前缀+去类型名                | `http.flag_ack(...)`                              |
| `setting_max_concurrent_streams`          | SETTINGS MAX_CONCURRENT_STREAMS id（0x0003）。                               | `setting_max_concurrent_streams`        | 去模块前缀+去类型名                | `http.setting_max_concurrent_streams(...)`        |
| `setting_initial_window_size`             | SETTINGS INITIAL_WINDOW_SIZE id（0x0004）。                                  | `setting_initial_window_size`           | 去模块前缀+去类型名                | `http.setting_initial_window_size(...)`           |
| `setting_enable_push`                     | SETTINGS ENABLE_PUSH id（0x0002；RFC 7540 §6.5.2）。                          | `setting_enable_push`                   | 去模块前缀+去类型名                | `http.setting_enable_push(...)`                   |
| `setting_header_table_size`               | SETTINGS HEADER_TABLE_SIZE id（0x0001）。                                    | `setting_header_table_size`             | 去模块前缀+去类型名                | `http.setting_header_table_size(...)`             |
| `setting_max_frame_size`                  | SETTINGS MAX_FRAME_SIZE id（0x0005）。                                       | `setting_max_frame_size`                | 去模块前缀+去类型名                | `http.setting_max_frame_size(...)`                |
| `setting_max_header_list_size`            | SETTINGS MAX_HEADER_LIST_SIZE id（0x0006）。                                 | `setting_max_header_list_size`          | 去模块前缀+去类型名                | `http.setting_max_header_list_size(...)`          |
| `preface_len`                             | 连接 preface 长度（24）。                                                        | `preface_len`                           | 去模块前缀+去类型名                | `http.preface_len(...)`                           |
| `is_connection_preface`                   | 检测 buf 是否为 HTTP/2 连接 preface；1 是，0 否。                                     | `is_connection_preface`                 | 去模块前缀+去类型名                | `http.is_connection_preface(...)`                 |
| `parse_frame_header`                      | 解析 9 字节帧头；成功 0，失败 -1。                                                     | `parse_frame_header`                    | 去模块前缀+去类型名                | `http.parse_frame_header(...)`                    |
| `build_settings_ack`                      | 构建 SETTINGS ACK 帧（9 字节）；成功返回写入长度。                                         | `build_settings_ack`                    | 去模块前缀+去类型名                | `http.build_settings_ack(...)`                    |
| `build_settings_one`                      | 构建含一条 SETTINGS 的帧（15 字节）。                                                 | `build_settings_one`                    | 去模块前缀+去类型名                | `http.build_settings_one(...)`                    |
| `wire_is_available`                       | 线格式层（preface/帧头）是否可用。                                                     | `wire_is_available`                     | 去模块前缀+去类型名                | `http.wire_is_available(...)`                     |
| `client_is_available`                     | 完整 HTTP/2 客户端编解码是否可用（v1+ HPACK+帧；v3 动态表；网络 ALPN v2）。                      | `client_is_available`                   | 去模块前缀+去类型名                | `http.client_is_available(...)`                   |
| `hpack_encode_indexed`                    | HPACK indexed 头字段编码；成功返回写入字节数。                                            | `hpack_encode_indexed`                  | 去模块前缀+去类型名                | `http.hpack_encode_indexed(...)`                  |
| `hpack_encode_literal`                    | HPACK literal 头字段（不索引，indexed name）编码。                                    | `hpack_encode_literal`                  | 去模块前缀+去类型名                | `http.hpack_encode_literal(...)`                  |
| `hpack_encode_get_request`                | 编码 GET 请求 HPACK 块（:method/:scheme/:path/:authority）。                      | `hpack_encode_get_request`              | 去模块前缀+去类型名                | `http.hpack_encode_get_request(...)`              |
| `hpack_dyn_reset`                         | 清空 HPACK 动态表（v3 FIFO 16 条目）。                                              | `hpack_dyn_reset`                       | 去模块前缀+去类型名                | `http.hpack_dyn_reset(...)`                       |
| `hpack_dyn_count`                         | 返回 HPACK 动态表当前条目数。                                                        | `hpack_dyn_count`                       | 去模块前缀+去类型名                | `http.hpack_dyn_count(...)`                       |
| `hpack_encode_literal_incremental`        | HPACK incremental indexing + indexed name 编码（并写入动态表）。                     | `hpack_encode_literal_incremental`      | 去模块前缀+去类型名                | `http.hpack_encode_literal_incremental(...)`      |
| `hpack_encode_indexed_any`                | HPACK indexed 头（静态或动态 index≥62）。                                          | `hpack_encode_indexed_any`              | 去模块前缀+去类型名                | `http.hpack_encode_indexed_any(...)`              |
| `hpack_encode_request`                    | 编码多 method 请求 HPACK 块（复用 authority/path 动态表）。method_u8 与 Method 一致。       | `hpack_encode_request`                  | 去模块前缀+去类型名                | `http.hpack_encode_request(...)`                  |
| `hpack_dyn_smoke` | HPACK 动态表 C 烟测；0 通过。 | `hpack_dyn_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.hpack_dyn_smoke(...)` |
| `hpack_server_dyn_create`                 | 由对端 SETTINGS 创建 server 响应 HPACK 动态表句柄；失败 0。                               | `hpack_server_dyn_create`               | 去模块前缀+去类型名                | `http.hpack_server_dyn_create(...)`               |
| `hpack_server_dyn_destroy`                | 释放 server HPACK 动态表句柄。                                                    | `hpack_server_dyn_destroy`              | 去模块前缀+去类型名                | `http.hpack_server_dyn_destroy(...)`              |
| `hpack_server_dyn_set_table_size`         | 更新 server 动态表上限（HEADER_TABLE_SIZE 联动）。                                    | `hpack_server_dyn_set_table_size`       | 去模块前缀+去类型名                | `http.hpack_server_dyn_set_table_size(...)`       |
| `hpack_server_dyn_max_size`               | 返回 server 动态表 HEADER_TABLE_SIZE 上限。                                       | `hpack_server_dyn_max_size`             | 去模块前缀+去类型名                | `http.hpack_server_dyn_max_size(...)`             |
| `hpack_server_dyn_count`                  | 返回 server 动态表条目数。                                                         | `hpack_server_dyn_count`                | 去模块前缀+去类型名                | `http.hpack_server_dyn_count(...)`                |
| `hpack_server_encode_status`              | 使用 server 动态表编码 :status 响应 HPACK 块。                                       | `hpack_server_encode_status`            | 去模块前缀+去类型名                | `http.hpack_server_encode_status(...)`            |
| `hpack_server_dyn_smoke` | server HPACK 动态表离线烟测；0 通过。 | `hpack_server_dyn_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.hpack_server_dyn_smoke(...)` |
| `frame_payload_limit`                     | 返回有效单帧 payload 上限（RFC 7540 MAX_FRAME_SIZE）。                               | `frame_payload_limit`                   | 去模块前缀+去类型名                | `http.frame_payload_limit(...)`                   |
| `frame_check_payload`                     | 校验 payload 是否不超过 max_frame_size；合法 0，超限 -1。                               | `frame_check_payload`                   | 去模块前缀+去类型名                | `http.frame_check_payload(...)`                   |
| `frame_count_data_chunks`                 | 计算 DATA 按 max_frame_size 分片后的帧数。                                          | `frame_count_data_chunks`               | 去模块前缀+去类型名                | `http.frame_count_data_chunks(...)`               |
| `frame_capped_smoke` | MAX_FRAME_SIZE 分片计算烟测；0 通过。 | `frame_capped_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.frame_capped_smoke(...)` |
| `frame_goaway`                            | GOAWAY 帧类型（RFC 7540 §6.8，0x07）。                                           | `frame_goaway`                          | 去模块前缀+去类型名                | `http.frame_goaway(...)`                          |
| `goaway_error_no_error`                   | GOAWAY NO_ERROR 错误码（0）。                                                   | `goaway_error_no_error`                 | 去模块前缀+去类型名                | `http.goaway_error_no_error(...)`                 |
| `build_goaway`                            | 构建 GOAWAY 帧；成功返回 17。                                                      | `build_goaway`                          | 去模块前缀+去类型名                | `http.build_goaway(...)`                          |
| `parse_goaway`                            | 解析 GOAWAY payload（8 字节）；成功 0。                                             | `parse_goaway`                          | 去模块前缀+去类型名                | `http.parse_goaway(...)`                          |
| `goaway_smoke` | GOAWAY 编解码离线烟测；0 通过。 | `goaway_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.goaway_smoke(...)` |
| `frame_ping`                              | PING 帧类型（RFC 7540 §6.7，0x06）。                                             | `frame_ping`                            | 去模块前缀+去类型名                | `http.frame_ping(...)`                            |
| `build_ping`                              | 构建 PING 帧（8 字节 opaque）；成功返回 17。                                           | `build_ping`                            | 去模块前缀+去类型名                | `http.build_ping(...)`                            |
| `build_ping_ack`                          | 构建 PONG（PING+ACK）帧；成功返回 17。                                               | `build_ping_ack`                        | 去模块前缀+去类型名                | `http.build_ping_ack(...)`                        |
| `parse_ping`                              | 解析 PING payload（8 字节）；成功 0。                                               | `parse_ping`                            | 去模块前缀+去类型名                | `http.parse_ping(...)`                            |
| `ping_smoke` | PING/PONG 编解码离线烟测；0 通过。 | `ping_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.ping_smoke(...)` |
| `frame_rst_stream`                        | RST_STREAM 帧类型（RFC 7540 §6.4，0x03）。                                       | `frame_rst_stream`                      | 去模块前缀+去类型名                | `http.frame_rst_stream(...)`                      |
| `rst_error_cancel`                        | RST_STREAM CANCEL 错误码（8）。                                                 | `rst_error_cancel`                      | 去模块前缀+去类型名                | `http.rst_error_cancel(...)`                      |
| `build_rst_stream`                        | 构建 RST_STREAM 帧；成功返回 13。                                                  | `build_rst_stream`                      | 去模块前缀+去类型名                | `http.build_rst_stream(...)`                      |
| `parse_rst_stream`                        | 解析 RST_STREAM payload（4 字节）；成功 0。                                         | `parse_rst_stream`                      | 去模块前缀+去类型名                | `http.parse_rst_stream(...)`                      |
| `rst_stream_smoke` | RST_STREAM 编解码离线烟测；0 通过。 | `rst_stream_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.rst_stream_smoke(...)` |
| `hpack_decode_status`                     | 从 HPACK 头块解析 :status；成功 0，未找到 -2，失败 -1。                                   | `hpack_decode_status`                   | 去模块前缀+去类型名                | `http.hpack_decode_status(...)`                   |
| `hpack_decode_get_request`                | 从 HPACK 请求头块解析 GET 与 :path；非 GET 返回 1。                                    | `hpack_decode_get_request`              | 去模块前缀+去类型名                | `http.hpack_decode_get_request(...)`              |
| `hpack_encode_status`                     | 编码 :status 响应 HPACK 块（200 用 indexed）。                                     | `hpack_encode_status`                   | 去模块前缀+去类型名                | `http.hpack_encode_status(...)`                   |
| `build_headers_frame`                     | 构建 HEADERS 帧（9 字节头 + HPACK payload）。                                      | `build_headers_frame`                   | 去模块前缀+去类型名                | `http.build_headers_frame(...)`                   |
| `build_data_frame`                        | 构建 DATA 帧。                                                                | `build_data_frame`                      | 去模块前缀+去类型名                | `http.build_data_frame(...)`                      |
| `build_get_headers_frame`                 | 构建 stream 1 GET HEADERS 帧（END_STREAM|END_HEADERS）。                        | `build_get_headers_frame`               | `http.END_HEADERS）。(...)` | `http.build_get_headers_frame(...)`               |
| `build_request_headers_frame`             | —                                                                         | `build_request_headers_frame`           | 去模块前缀+去类型名                | `http.build_request_headers_frame(...)`           |
| `hpack_smoke` | HPACK 编解码 C 烟测；0 通过。 | `hpack_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.hpack_smoke(...)` |
| `client_smoke` | HTTP/2 客户端多路复用 C 烟测；0 通过。 | `client_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.client_smoke(...)` |
| `network_is_available`                    | h2 over TLS 网络栈是否可用（须链入 std.net TLS）。                                     | `network_is_available`                  | 去模块前缀+去类型名                | `http.network_is_available(...)`                  |
| `network_smoke` | 网络层烟测（ALPN wire + HPACK；不建连）；0 通过。 | `network_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.network_smoke(...)` |
| `h2_get`                                        | —                                                                         | `h2_get`                                | 已符合命名                     | `http.h2_get(...)`（已简洁）                           |
| `h2_request`                                    | —                                                                         | `h2_request`                            | 已符合命名                     | `http.h2_request(...)`（已简洁）                       |
| `client_request_h2`                             | —                                                                         | `client_request_h2`                     | 已符合命名                     | `http.client_request_h2(...)`（已简洁）                |
| `h2c_get`                                       | —                                                                         | `h2c_get`                               | 已符合命名                     | `http.h2c_get(...)`（已简洁）                          |
| `h2c_request`                                   | —                                                                         | `h2c_request`                           | 已符合命名                     | `http.h2c_request(...)`（已简洁）                      |
| `client_request_h2c`                            | —                                                                         | `client_request_h2c`                    | 已符合命名                     | `http.client_request_h2c(...)`（已简洁）               |
| `conn_pool_create_h2c`                    | —                                                                         | `conn_pool_create_h2c`                  | 去模块前缀+去类型名                | `http.conn_pool_create_h2c(...)`                  |
| `conn_pool_create_h2`                     | —                                                                         | `conn_pool_create_h2`                   | 去模块前缀+去类型名                | `http.conn_pool_create_h2(...)`                   |
| `conn_pool_destroy`                       | 销毁 H2 连接池并关闭 idle 连接。                                                     | `conn_pool_destroy`                     | 去模块前缀+去类型名                | `http.conn_pool_destroy(...)`                     |
| `conn_pool_request`                       | —                                                                         | `conn_pool_request`                     | 去模块前缀+去类型名                | `http.conn_pool_request(...)`                     |
| `h2c_pool_get`                                  | h2c 长连接池 GET。                                                             | `h2c_pool_get`                          | 已符合命名                     | `http.h2c_pool_get(...)`（已简洁）                     |
| `h2_pool_get`                                   | h2 over TLS 长连接池 GET。                                                     | `h2_pool_get`                           | 已符合命名                     | `http.h2_pool_get(...)`（已简洁）                      |
| `conn_pool_is_available`                  | H2 连接池 API 是否可用。                                                          | `conn_pool_is_available`                | 去模块前缀+去类型名                | `http.conn_pool_is_available(...)`                |
| `conn_pool_smoke` | H2 连接池 C 烟测；0 通过。 | `conn_pool_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.conn_pool_smoke(...)` |
| `conn_pool_goaway_smoke` | 连接池 GOAWAY 感知烟测（离线 + h2c fork 双连）；0 通过。 | `conn_pool_goaway_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.conn_pool_goaway_smoke(...)` |
| `conn_pool_connect_count`                 | 池累计新建 TCP/TLS 连接次数（烟测/诊断）。                                                | `conn_pool_connect_count`               | 去模块前缀+去类型名                | `http.conn_pool_connect_count(...)`               |
| `global_pool_create`                      | —                                                                         | `global_pool_create`                    | 去模块前缀+去类型名                | `http.global_pool_create(...)`                    |
| `global_pool_destroy`                     | 销毁全局池及全部子连接池。                                                             | `global_pool_destroy`                   | 去模块前缀+去类型名                | `http.global_pool_destroy(...)`                   |
| `global_pool_get`                         | —                                                                         | `global_pool_get`                       | 去模块前缀+去类型名                | `http.global_pool_get(...)`                       |
| `global_pool_request`                     | —                                                                         | `global_pool_request`                   | 去模块前缀+去类型名                | `http.global_pool_request(...)`                   |
| `global_pool_entry_count`                 | 全局池已登记的不同 host:port 子池数量。                                                 | `global_pool_entry_count`               | 去模块前缀+去类型名                | `http.global_pool_entry_count(...)`               |
| `global_pool_connect_count`               | 全局池内全部子池累计新建连接次数。                                                         | `global_pool_connect_count`             | 去模块前缀+去类型名                | `http.global_pool_connect_count(...)`             |
| `global_pool_is_available`                | 全局 H2 连接池 API 是否可用。                                                       | `global_pool_is_available`              | 去模块前缀+去类型名                | `http.global_pool_is_available(...)`              |
| `global_pool_smoke` | 全局 H2 连接池 C 烟测；0 通过。 | `global_pool_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.global_pool_smoke(...)` |
| `complete_smoke` | HTTP/2 v1 收口烟测（RST + 全局池 GOAWAY）；0 通过。 | `complete_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.complete_smoke(...)` |
| `serve_h2c_one`                                 | —                                                                         | `serve_h2c_one`                         | 已符合命名                     | `http.serve_h2c_one(...)`（已简洁）                    |
| `serve_h2c_one_with_goaway`                     | —                                                                         | `serve_h2c_one_with_goaway`             | 已符合命名                     | `http.serve_h2c_one_with_goaway(...)`（已简洁）        |
| `server_serve_h2c`                        | 对已 accept 的 h2c client fd 处理单次 GET 并回 200+body。                           | `server_serve_h2c`                      | 去模块前缀+去类型名                | `http.server_serve_h2c(...)`                      |
| `server_serve_h2c_with_goaway`            | 对已连接 h2c fd：单次 GET 200+body 后发 GOAWAY（NO_ERROR）。                          | `server_serve_h2c_with_goaway`          | 去模块前缀+去类型名                | `http.server_serve_h2c_with_goaway(...)`          |
| `serve_h2c_one_ping_echo`                       | accept 一个 h2c 连接并回显单次 client PING（PONG）。                                  | `serve_h2c_one_ping_echo`               | 已符合命名                     | `http.serve_h2c_one_ping_echo(...)`（已简洁）          |
| `server_serve_h2c_ping_echo`              | 对已连接 h2c fd：handshake 后读 PING 并回 PONG。                                    | `server_serve_h2c_ping_echo`            | 去模块前缀+去类型名                | `http.server_serve_h2c_ping_echo(...)`            |
| `serve_h2c_one_with_push`                       | —                                                                         | `serve_h2c_one_with_push`               | 已符合命名                     | `http.serve_h2c_one_with_push(...)`（已简洁）          |
| `server_serve_h2c_with_push`              | 对已连接 h2c fd：PUSH_PROMISE + push body + 主 GET 200+body。                    | `server_serve_h2c_with_push`            | 去模块前缀+去类型名                | `http.server_serve_h2c_with_push(...)`            |
| `server_push_is_available`                | HTTP/2 server push 发送侧 API 是否可用（v17）。                                     | `server_push_is_available`              | 去模块前缀+去类型名                | `http.server_push_is_available(...)`              |
| `server_push_smoke` | server push 烟测（离线 PUSH_PROMISE + fork h2c/h2 集成）；0 通过。 | `server_push_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_push_smoke(...)` |
| `server_push_tls_smoke` | TLS h2 server push fork 烟测；TLS 不可用时 C 层跳过返回 0。 | `server_push_tls_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_push_tls_smoke(...)` |
| `server_push_settings_smoke` | server push ENABLE_PUSH 协商烟测（client=0 时软拒绝）；0 通过。 | `server_push_settings_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_push_settings_smoke(...)` |
| `server_settings_full_smoke` | server 全量 SETTINGS 协商烟测（fork 读 server SETTINGS）；0 通过。 | `server_settings_full_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_settings_full_smoke(...)` |
| `server_hpack_dyn_smoke` | server HPACK 动态表 + 多 stream 集成烟测；0 通过。 | `server_hpack_dyn_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_hpack_dyn_smoke(...)` |
| `server_max_frame_smoke` | server MAX_FRAME_SIZE 分片 DATA 烟测；0 通过。 | `server_max_frame_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_max_frame_smoke(...)` |
| `conn_goaway_smoke` | GOAWAY 编解码 + h2c fork 集成烟测；0 通过。 | `conn_goaway_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.conn_goaway_smoke(...)` |
| `conn_ping_smoke` | PING/PONG 编解码 + h2c fork 集成烟测；0 通过。 | `conn_ping_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.conn_ping_smoke(...)` |
| `serve_h2c_multi_one`                           | —                                                                         | `serve_h2c_multi_one`                   | 已符合命名                     | `http.serve_h2c_multi_one(...)`（已简洁）              |
| `server_serve_h2c_multi`                  | 对已连接 h2c fd 顺序 serve 至多 max_requests 个 GET。                               | `server_serve_h2c_multi`                | 去模块前缀+去类型名                | `http.server_serve_h2c_multi(...)`                |
| `serve_h2c_multi_one_with_push`                 | —                                                                         | `serve_h2c_multi_one_with_push`         | 已符合命名                     | `http.serve_h2c_multi_one_with_push(...)`（已简洁）    |
| `server_serve_h2c_multi_with_push`        | 对已连接 h2c fd 顺序 serve 至多 max_requests 个带 push 的 GET。                       | `server_serve_h2c_multi_with_push`      | 去模块前缀+去类型名                | `http.server_serve_h2c_multi_with_push(...)`      |
| `server_is_available`                     | HTTP/2 h2c server API 是否可用。                                               | `server_is_available`                   | 去模块前缀+去类型名                | `http.server_is_available(...)`                   |
| `server_smoke` | HTTP/2 h2c server C 烟测（含 fork 集成）；0 通过。 | `server_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_smoke(...)` |
| `tls_server_ctx_create`                   | —                                                                         | `tls_server_ctx_create`                 | 去模块前缀+去类型名                | `http.tls_server_ctx_create(...)`                 |
| `tls_server_ctx_destroy`                  | 销毁 h2 TLS 服务端上下文。                                                         | `tls_server_ctx_destroy`                | 去模块前缀+去类型名                | `http.tls_server_ctx_destroy(...)`                |
| `serve_h2_one`                                  | —                                                                         | `serve_h2_one`                          | 已符合命名                     | `http.serve_h2_one(...)`（已简洁）                     |
| `serve_h2_one_with_push`                        | —                                                                         | `serve_h2_one_with_push`                | 已符合命名                     | `http.serve_h2_one_with_push(...)`（已简洁）           |
| `server_serve_h2`                         | 对已 TLS+ALPN h2 会话处理单次 GET 并回 200+body。                                    | `server_serve_h2`                       | 去模块前缀+去类型名                | `http.server_serve_h2(...)`                       |
| `server_serve_h2_with_push`               | 对已 TLS+h2 会话：PUSH_PROMISE + push body + 主 GET 200+body。                   | `server_serve_h2_with_push`             | 去模块前缀+去类型名                | `http.server_serve_h2_with_push(...)`             |
| `serve_h2_multi_one`                            | —                                                                         | `serve_h2_multi_one`                    | 已符合命名                     | `http.serve_h2_multi_one(...)`（已简洁）               |
| `server_serve_h2_multi`                   | 对已 TLS+h2 会话顺序 serve 至多 max_requests 个 GET。                               | `server_serve_h2_multi`                 | 去模块前缀+去类型名                | `http.server_serve_h2_multi(...)`                 |
| `serve_h2_multi_one_with_push`                  | —                                                                         | `serve_h2_multi_one_with_push`          | 已符合命名                     | `http.serve_h2_multi_one_with_push(...)`（已简洁）     |
| `server_serve_h2_multi_with_push`         | 对已 TLS+h2 会话顺序 serve 至多 max_requests 个带 push 的 GET。                       | `server_serve_h2_multi_with_push`       | 去模块前缀+去类型名                | `http.server_serve_h2_multi_with_push(...)`       |
| `server_multistream_is_available`         | server 多 stream API 是否可用。                                                 | `server_multistream_is_available`       | 去模块前缀+去类型名                | `http.server_multistream_is_available(...)`       |
| `server_multistream_smoke` | server 多 stream C 烟测；0 通过。 | `server_multistream_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_multistream_smoke(...)` |
| `server_multistream_push_is_available`    | HTTP/2 server 多 stream + push API 是否可用（v19）。                              | `server_multistream_push_is_available`  | 去模块前缀+去类型名                | `http.server_multistream_push_is_available(...)`  |
| `server_multistream_push_smoke` | server 多 stream + push 烟测（h2c + TLS fork 集成）；0 通过。 | `server_multistream_push_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.server_multistream_push_smoke(...)` |
| `h2c_client_smoke` | h2c URL 客户端 C 烟测（https 须 SCHEME 错误）；0 通过。 | `h2c_client_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.h2c_client_smoke(...)` |
| `registry_max`                     | 注册表最大 stream 槽位数（8）。                                                      | `max`                                   | 二次精简：去对象前缀                | `http.max(...)`                                   |
| `init`                    | 初始化 stream 注册表；下一 id 从 1（奇数）开始。                                           | `init`                                  | 二次精简：去对象前缀                | `http.init(...)`                                  |
| `open`                    | 分配并登记新 stream id；表满 -1。                                                   | `open`                                  | 二次精简：去对象前缀                | `http.open(...)`                                  |
| `close`                   | 关闭 stream（保留槽位）。                                                          | `close`                                 | 二次精简：去对象前缀                | `http.close(...)`                                 |
| `is_open`                 | stream 是否 open；1 是，0 否。                                                   | `is_open`                               | 二次精简：去对象前缀                | `http.is_open(...)`                               |
| `registry_smoke` | 多 stream 注册表 C 烟测；0 通过。 | `smoke` | 二次精简：去对象前缀；Tier-X 不 export | `http.smoke(...)` |
| `peer_settings_init`                      | 初始化对端 SETTINGS 视图。                                                        | `peer_settings_init`                    | 去模块前缀+去类型名                | `http.peer_settings_init(...)`                    |
| `settings_entry_count`                    | SETTINGS payload 6 字节条目数；plen 非 6 倍数 -1。                                  | `settings_entry_count`                  | 去模块前缀+去类型名                | `http.settings_entry_count(...)`                  |
| `parse_settings_entry`                    | 读取 SETTINGS payload 第 entry_index 条；无条目 -2。                               | `parse_settings_entry`                  | 去模块前缀+去类型名                | `http.parse_settings_entry(...)`                  |
| `peer_settings_apply_entry`               | 应用单条 SETTINGS 到对端视图。                                                      | `peer_settings_apply_entry`             | 去模块前缀+去类型名                | `http.peer_settings_apply_entry(...)`             |
| `peer_settings_consume_payload`           | 解析完整 SETTINGS payload 并累加。                                                | `peer_settings_consume_payload`         | 去模块前缀+去类型名                | `http.peer_settings_consume_payload(...)`         |
| `build_client_settings`                   | 构建客户端 SETTINGS（含 ENABLE_PUSH=1）；成功 27。                                    | `build_client_settings`                 | 去模块前缀+去类型名                | `http.build_client_settings(...)`                 |
| `build_client_settings_ex`                | 构建含 ENABLE_PUSH 的客户端 SETTINGS 帧；enable_push 0=拒绝 server push。             | `build_client_settings_ex`              | 去模块前缀+去类型名                | `http.build_client_settings_ex(...)`              |
| `build_client_settings_with_max_frame`    | 构建含 MAX_FRAME_SIZE 的 client SETTINGS 帧；成功 33。                             | `build_client_settings_with_max_frame`  | 去模块前缀+去类型名                | `http.build_client_settings_with_max_frame(...)`  |
| `build_server_settings`                   | 构建 server 全量 SETTINGS 帧（含 HEADER_TABLE_SIZE/MAX_FRAME_SIZE）；成功 39。        | `build_server_settings`                 | 去模块前缀+去类型名                | `http.build_server_settings(...)`                 |
| `peer_settings_enable_push`               | 对端是否允许 server push（ENABLE_PUSH=0 时 false）。                                | `peer_settings_enable_push`             | 去模块前缀+去类型名                | `http.peer_settings_enable_push(...)`             |
| `peer_settings_header_table_size`         | 对端 HEADER_TABLE_SIZE（未设置时 4096）。                                          | `peer_settings_header_table_size`       | 去模块前缀+去类型名                | `http.peer_settings_header_table_size(...)`       |
| `peer_settings_max_frame_size`            | 对端 MAX_FRAME_SIZE（未设置时 16384）。                                            | `peer_settings_max_frame_size`          | 去模块前缀+去类型名                | `http.peer_settings_max_frame_size(...)`          |
| `peer_settings_max_header_list_size`      | 对端 MAX_HEADER_LIST_SIZE（未设置时 0=无限制）。                                      | `peer_settings_max_header_list_size`    | 去模块前缀+去类型名                | `http.peer_settings_max_header_list_size(...)`    |
| `peer_settings_max_streams`               | 有效并发 stream 上限（未设置时默认 100）。                                               | `peer_settings_max_streams`             | 去模块前缀+去类型名                | `http.peer_settings_max_streams(...)`             |
| `peer_settings_initial_window`            | 有效初始窗口（未设置时 65535）。                                                       | `peer_settings_initial_window`          | 去模块前缀+去类型名                | `http.peer_settings_initial_window(...)`          |
| `settings_smoke` | SETTINGS 解析 C 烟测；0 通过。 | `settings_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.settings_smoke(...)` |
| `client_init` | 初始化多 stream 并发客户端。 | `client_init` | 去模块前缀+去类型名；三轮精简 | `http.client_init(...)` |
| `client_on_settings`          | 应用对端 SETTINGS payload。                                                    | `multistream_client_on_settings`        | 去模块前缀+去类型名                | `http.multistream_client_on_settings(...)`        |
| `client_open` | 在 SETTINGS 限制内 open stream；超上限 err_max_streams(-1236)。 | `client_open` | 去模块前缀+去类型名；三轮精简 | `http.client_open(...)` |
| `client_close` | 关闭 stream。 | `client_close` | 去模块前缀+去类型名；三轮精简 | `http.client_close(...)` |
| `client_get` | 在指定 stream 构建 GET HEADERS 帧。 | `client_get` | 去模块前缀+去类型名；三轮精简 | `http.client_get(...)` |
| `client_parallel_get` | 并发构建 n 个 GET HEADERS 帧（依次 open stream）。 | `client_parallel_get` | 去模块前缀+去类型名；三轮精简 | `http.client_parallel_get(...)` |
| `multistream_client_smoke` | 多 stream 并发客户端 C 烟测；0 通过。 | `multistream_client_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.multistream_client_smoke(...)` |
| `conn_reuse_is_available`                 | 单连接复用 API 是否可用。                                                           | `conn_reuse_is_available`               | 去模块前缀+去类型名                | `http.conn_reuse_is_available(...)`               |
| `conn_init`                               | 初始化可复用 HTTP/2 连接。                                                         | `conn_init`                             | 去模块前缀+去类型名                | `http.conn_init(...)`                             |
| `conn_attach_h2c`                         | 绑定 cleartext h2c fd（须已 connect）。                                          | `conn_attach_h2c`                       | 去模块前缀+去类型名                | `http.conn_attach_h2c(...)`                       |
| `conn_attach_tls`                         | 绑定已协商 h2 的 TLS ctx。                                                       | `conn_attach_tls`                       | 去模块前缀+去类型名                | `http.conn_attach_tls(...)`                       |
| `conn_is_ready`                           | 连接是否已完成 handshake。                                                        | `conn_is_ready`                         | 去模块前缀+去类型名                | `http.conn_is_ready(...)`                         |
| `conn_handshake`                          | 发送 preface + SETTINGS 并完成协商；成功 0。                                         | `conn_handshake`                        | 去模块前缀+去类型名                | `http.conn_handshake(...)`                        |
| `conn_handshake_with_enable_push`         | handshake 并显式设置 client ENABLE_PUSH（0=拒绝 server push）。                     | `conn_handshake_with_enable_push`       | 去模块前缀+去类型名                | `http.conn_handshake_with_enable_push(...)`       |
| `conn_handshake_with_max_frame`           | handshake 并声明 client MAX_FRAME_SIZE（server 分片 DATA 联动）。                   | `conn_handshake_with_max_frame`         | 去模块前缀+去类型名                | `http.conn_handshake_with_max_frame(...)`         |
| `conn_request`                            | —                                                                         | `conn_request`                          | 去模块前缀+去类型名                | `http.conn_request(...)`                          |
| `conn_close`                              | 标记连接关闭（不 shutdown 底层 fd/TLS）。                                             | `conn_close`                            | 去模块前缀+去类型名                | `http.conn_close(...)`                            |
| `conn_shutdown_graceful`                  | —                                                                         | `conn_shutdown_graceful`                | 去模块前缀+去类型名                | `http.conn_shutdown_graceful(...)`                |
| `conn_read_goaway`                        | 读下一 GOAWAY 帧；非 GOAWAY 返回 err_goaway(-1244)。                         | `conn_read_goaway`                      | 去模块前缀+去类型名                | `http.conn_read_goaway(...)`                      |
| `conn_ping`                               | 在已 ready 连接上发 PING 并等待匹配 PONG；失败 err_ping(-1245)。                   | `conn_ping`                             | 去模块前缀+去类型名                | `http.conn_ping(...)`                             |
| `conn_goaway_seen`                        | 连接是否已收到对端 GOAWAY（不可再复用）。                                                  | `conn_goaway_seen`                      | 去模块前缀+去类型名                | `http.conn_goaway_seen(...)`                      |
| `conn_is_pool_reusable`                   | 连接是否可归还 H2 连接池 idle 栈。                                                    | `conn_is_pool_reusable`                 | 去模块前缀+去类型名                | `http.conn_is_pool_reusable(...)`                 |
| `conn_reset_stream`                       | 向对端发送 RST_STREAM 取消 stream；失败 err_rst_stream(-1246) 读路径。            | `conn_reset_stream`                     | 去模块前缀+去类型名                | `http.conn_reset_stream(...)`                     |
| `conn_reuse_smoke` | 单连接复用 C 烟测；0 通过。 | `conn_reuse_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.conn_reuse_smoke(...)` |
| `alpn_h2_len`                             | ALPN 协议名 "h2" 长度（2）。                                                      | `alpn_h2_len`                           | 去模块前缀+去类型名                | `http.alpn_h2_len(...)`                           |
| `write_alpn_h2`                           | 将 ALPN "h2" 写入 out；成功返回 2。                                                | `write_alpn_h2`                         | 去模块前缀+去类型名                | `http.write_alpn_h2(...)`                         |
| `smoke` | HTTP/2 线格式 C 烟测；0 通过。 | `smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.smoke(...)` |
| `frame_window_update`                     | WINDOW_UPDATE 帧类型（RFC 7540 §6.9）。                                         | `frame_window_update`                   | 去模块前缀+去类型名                | `http.frame_window_update(...)`                   |
| `default_initial_window`                  | 默认初始流控窗口（65535）。                                                          | `default_initial_window`                | 去模块前缀+去类型名                | `http.default_initial_window(...)`                |
| `build_window_update`                     | 构建 WINDOW_UPDATE 帧；成功返回 13。                                               | `build_window_update`                   | 去模块前缀+去类型名                | `http.build_window_update(...)`                   |
| `hpack_huffman_decode`                    | HPACK Huffman 解码（RFC 7541）；成功返回解码字节数。                                     | `hpack_huffman_decode`                  | 去模块前缀+去类型名                | `http.hpack_huffman_decode(...)`                  |
| `hpack_huffman_is_available`              | HPACK Huffman 是否可用。                                                       | `hpack_huffman_is_available`            | 去模块前缀+去类型名                | `http.hpack_huffman_is_available(...)`            |
| `hpack_huffman_smoke` | Huffman + 流控 C 烟测（含于 network_smoke）。 | `hpack_huffman_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.hpack_huffman_smoke(...)` |
| `flow_control_smoke` | 流控 WINDOW_UPDATE C 烟测；0 通过。 | `flow_control_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.flow_control_smoke(...)` |
| `flow_state_init`                         | 初始化连接/流窗口为默认 65535。                                                       | `flow_state_init`                       | 去模块前缀+去类型名                | `http.flow_state_init(...)`                       |
| `flow_state_reset_stream`                 | 重置流窗口（保留连接窗口）；用于新 stream。                                                 | `flow_state_reset_stream`               | 去模块前缀+去类型名                | `http.flow_state_reset_stream(...)`               |
| `flow_state_apply_initial_window`         | 应用 SETTINGS INITIAL_WINDOW_SIZE 到新 stream 基准。                             | `flow_state_apply_initial_window`       | 去模块前缀+去类型名                | `http.flow_state_apply_initial_window(...)`       |
| `flow_state_apply_window_update`          | —                                                                         | `flow_state_apply_window_update`        | 去模块前缀+去类型名                | `http.flow_state_apply_window_update(...)`        |
| `flow_state_max_send`                     | 返回当前可发送字节数 min(conn, stream, want)；0 表示背压阻塞。                              | `flow_state_max_send`                   | 去模块前缀+去类型名                | `http.flow_state_max_send(...)`                   |
| `flow_state_can_send`                     | want 字节是否可发送（true 可发，false 背压）。                                           | `flow_state_can_send`                   | 去模块前缀+去类型名                | `http.flow_state_can_send(...)`                   |
| `flow_state_consume_send`                 | —                                                                         | `flow_state_consume_send`               | 去模块前缀+去类型名                | `http.flow_state_consume_send(...)`               |
| `parse_window_update_payload`             | 解析 WINDOW_UPDATE payload（4 字节）；成功 0，失败 -1。                                | `parse_window_update_payload`           | 去模块前缀+去类型名                | `http.parse_window_update_payload(...)`           |
| `flow_state_smoke` | 流控状态机 C 烟测；0 通过。 | `flow_state_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.flow_state_smoke(...)` |
| `frame_push_promise`                      | PUSH_PROMISE 帧类型（RFC 7540 §6.6）。                                          | `frame_push_promise`                    | 去模块前缀+去类型名                | `http.frame_push_promise(...)`                    |
| `is_push_promise_frame`                   | ftype 是否为 PUSH_PROMISE。                                                   | `is_push_promise_frame`                 | 去模块前缀+去类型名                | `http.is_push_promise_frame(...)`                 |
| `parse_push_promise_stream`               | 解析 PUSH_PROMISE promised stream id；成功 0。                                  | `parse_push_promise_stream`             | 去模块前缀+去类型名                | `http.parse_push_promise_stream(...)`             |
| `is_h2c_upgrade_response`                 | 检测 HTTP/1.1 101 + Upgrade: h2c 响应。                                        | `is_h2c_upgrade_response`               | 去模块前缀+去类型名                | `http.is_h2c_upgrade_response(...)`               |
| `h2c_is_available`                        | cleartext h2c TCP 会话 API 是否可用（v8）。                                        | `h2c_is_available`                      | 去模块前缀+去类型名                | `http.h2c_is_available(...)`                      |
| `push_h2c_smoke` | push + h2c wire C 烟测；0 通过。 | `push_h2c_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.push_h2c_smoke(...)` |
| `h2c_wire_is_available`                   | cleartext h2c 起始 preface 是否可用（v7 wire）。                                   | `h2c_wire_is_available`                 | 去模块前缀+去类型名                | `http.h2c_wire_is_available(...)`                 |
| `h2c_session_begin`                       | 构建 h2c 直连起始 preface（24 字节）；成功返回 24。                                       | `h2c_session_begin`                     | 去模块前缀+去类型名                | `http.h2c_session_begin(...)`                     |
| `push_fetch_smoke` | push 资源离线收集 C 烟测；0 通过。 | `push_fetch_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.push_fetch_smoke(...)` |
| `push_last_reset`                         | 重置读路径 push 收集状态。                                                          | `push_last_reset`                       | 去模块前缀+去类型名                | `http.push_last_reset(...)`                       |
| `push_last_copy`                          | 复制最近一次 push body；成功返回 body_len，无 push 返回 0。                               | `push_last_copy`                        | 去模块前缀+去类型名                | `http.push_last_copy(...)`                        |
| `push_last_body_owned`                          | —                                                                         | `push_last_body_owned`                  | 已符合命名                     | `http.push_last_body_owned(...)`（已简洁）             |
| `push_network_smoke` | push 网络拉取 C 烟测；0 通过。 | `push_network_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.push_network_smoke(...)` |
| `h2c_network_smoke` | h2c 明文 TCP 会话 C 烟测；0 通过。 | `h2c_network_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.h2c_network_smoke(...)` |
| `flow_recv_init`                          | 初始化 recv 窗口为默认 65535。                                                     | `flow_recv_init`                        | 去模块前缀+去类型名                | `http.flow_recv_init(...)`                        |
| `flow_recv_reset_stream`                  | 重置流 recv 窗口。                                                              | `flow_recv_reset_stream`                | 去模块前缀+去类型名                | `http.flow_recv_reset_stream(...)`                |
| `flow_recv_on_data`                       | 收到 DATA 后扣减 recv 窗口；成功 0。                                                 | `flow_recv_on_data`                     | 去模块前缀+去类型名                | `http.flow_recv_on_data(...)`                     |
| `flow_recv_release`                       | 释放已消费字节并构建 WINDOW_UPDATE；成功返回帧长度 13。                                      | `flow_recv_release`                     | 去模块前缀+去类型名                | `http.flow_recv_release(...)`                     |
| `flow_recv_smoke` | 接收侧流控 C 烟测；0 通过。 | `flow_recv_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `http.flow_recv_smoke(...)` |


### std.io

`std/io/mod.sx` · 59 APIs · `const io = import("std.io")`


| 当前名称                          | 功能说明                                                                                                                              | 简化名称                          | 说明         | 绑定调用                                  |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ---------- | ------------------------------------- |
| `handle_stdin`                | SX 流水线 return 字面量可由 typeck 隐式升格为 usize（与 std 内 read(数字,…) 的常见写法等价）。                                                               | `stdin`                       | 语义重命名      | `io.stdin(...)`                       |
| `handle_stdout`               | —                                                                                                                                 | `stdout`                      | 语义重命名      | `io.stdout(...)`                      |
| `handle_stderr`               | —                                                                                                                                 | `stderr`                      | 语义重命名      | `io.stderr(...)`                      |
| `handle_from_fd`              | fd 转 handle；第二参 unused 与 codegen 产出一致，调用处传 0。                                                                                     | `from_fd`                     | 语义重命名      | `io.from_fd(...)`                     |
| `read`                        | 从 handle 读入至 ptr[0..len]，timeout_ms 毫秒（0=无超时）。返回读入字节数，0=EOF，-1=错误。                                                                | `read`                        | 已符合命名      | `io.read(...)`                        |
| `write`                       | 将 ptr[0..len] 写入 handle，timeout_ms 毫秒（0=无超时）。返回写入字节数，-1=错误。                                                                       | `write`                       | 已符合命名      | `io.write(...)`                       |
| `read_into`                   | 与 read 同义；供 std.fs 等模块调用，避免与 libc read(fd,buf,count) 同名冲突。                                                                        | `read`                        | 语义重命名      | `io.read(...)`                        |
| `write_from`                  | 与 write 同义；供 std.fs 等模块调用，避免与 libc write(fd,buf,count) 同名冲突。                                                                      | `write`                       | 语义重命名      | `io.write(...)`                       |
| `timeout_ms_for_context` | 从 Context 推导 read/write 超时毫秒；无 deadline 返回 0；取消/过期返回 IO_CTX_MS_*。 | `timeout_from_ctx` | 三轮精简 | `io.timeout_from_ctx(...)` |
| `read_ctx`                    | 带 Context 的 read：已取消返回 io_err_cancelled，已过期返回 io_err_timeout。                                                                     | `read_ctx`                    | 已符合命名      | `io.read_ctx(...)`                    |
| `write_ctx`                   | 带 Context 的 write：语义同 read_ctx。                                                                                                   | `write_ctx`                   | 已符合命名      | `io.write_ctx(...)`                   |
| `read_stdin`                  | —                                                                                                                                 | `read_stdin`                  | 已符合命名      | `io.read_stdin(...)`                  |
| `read_ptr`                    | 零拷贝读：读入内部缓冲，返回只读指针；失败返回 0。生命周期见文件头 Z2 约定。                                                                                         | `read_ptr`                    | 已符合命名      | `io.read_ptr(...)`                    |
| `read_ptr_len` | 返回最近一次 read_ptr/read_stdin_ptr 成功读入的字节数；与 read_ptr/read_stdin_ptr 配套使用。 | `ptr_len` | 三轮精简 | `io.ptr_len(...)` |
| `read_ptr_gen` | — | `ptr_gen` | 三轮精简 | `io.ptr_gen(...)` |
| `read_ptr_gen_valid` | ZC-2：saved 与当前 generation 相等返回 1（视图仍有效），否则 0。 | `ptr_valid` | 三轮精简 | `io.ptr_valid(...)` |
| `read_ptr_backend` | ZC-2：上次 read_ptr 后端：0=TLS，1=mmap(Linux)，2=dispatch_data(macOS)。 | `ptr_backend` | 三轮精简 | `io.ptr_backend(...)` |
| `read_ptr_view` | — | `ptr_view` | 三轮精简 | `io.ptr_view(...)` |
| `read_ptr_view_valid` | ZC-2：ReadPtrView 是否仍对应当前有效 read_ptr 视图。 | `ptr_view_valid` | 三轮精简 | `io.ptr_view_valid(...)` |
| `read_stdin_ptr_view` | ZC-2：stdin 版 read_ptr_view。 | `stdin_ptr_view` | 三轮精简 | `io.stdin_ptr_view(...)` |
| `read_ptr_slice` | — | `ptr_slice` | 三轮精简 | `io.ptr_slice(...)` |
| `read_stdin_ptr_slice` | 零拷贝读 stdin slice；等价 read_ptr_slice(handle_stdin(), 0)。 | `stdin_ptr_slice` | 三轮精简 | `io.stdin_ptr_slice(...)` |
| `read_stdin_ptr`              | 零拷贝读 stdin：读入内部缓冲，返回只读指针；失败返回 0。指针在下次 read_stdin_ptr/read_ptr 前有效；长度用 read_ptr_len()。                                             | `read_stdin_ptr`              | 已符合命名      | `io.read_stdin_ptr(...)`              |
| `write_stdout`                | —                                                                                                                                 | `write_stdout`                | 已符合命名      | `io.write_stdout(...)`                |
| `write_stderr`                | —                                                                                                                                 | `write_stderr`                | 已符合命名      | `io.write_stderr(...)`                |
| `read_with_timeout` | — | `read` | 三轮精简 | `io.read(...)` |
| `write_with_timeout` | — | `write` | 三轮精简 | `io.write(...)` |
| `write_stderr_with_timeout` | 向 stderr 写入 ptr[0..len]，超时 timeout_ms（0=无超时）。返回写入字节数，-1=错误。 | `write_stderr` | 三轮精简 | `io.write_stderr(...)` |
| `read_fd`                     | 从 fd 读入至 ptr[0..len]（timeout=0）；fd 可为 std.fs 打开的文件。推荐 len ≥ std.fs.fs_read_chunk() 压榨 syscall。返回读入字节数，0=EOF，-1=错误。                | `read_fd`                     | 已符合命名      | `io.read_fd(...)`                     |
| `write_fd`                    | 将 ptr[0..len] 写入 fd（timeout=0）；fd 可为 std.fs 打开的文件。返回写入字节数，-1=错误。                                                                  | `write_fd`                    | 已符合命名      | `io.write_fd(...)`                    |
| `read_batch_fd`               | 从 fd 批量读：一次 submit 最多 4 段 (p0,l0)..(p3,l3)，n 为段数 1..4。Linux 走 io_uring 多 SQE 或 readv，极致压榨。返回总字节数，-1=错误。                           | `read_batch_fd`               | 已符合命名      | `io.read_batch_fd(...)`               |
| `write_batch_fd`              | 向 fd 批量写：一次 submit 最多 4 段 (p0,l0)..(p3,l3)，n 为段数 1..4。Linux 走 io_uring 多 SQE 或 writev，极致压榨。返回总字节数，-1=错误。                          | `write_batch_fd`              | 已符合命名      | `io.write_batch_fd(...)`              |
| `read_batch_fd_buf`           | 与 Zig/Rust 对齐：从 fd 按「指针+段数」批量读；buffers 指向至少 n 个 Buffer（ptr/len 有效），n 为 1..16。timeout=0。返回总字节数，-1=错误。                              | `readv` | 已符合命名；三轮精简 | `io.readv(...)` |
| `write_batch_fd_buf`          | 与 Zig/Rust 对齐：向 fd 按「指针+段数」批量写；buffers 同上，n 为 1..16。返回总字节数，-1=错误。                                                                 | `writev` | 已符合命名；三轮精简 | `io.writev(...)` |
| `print_str` | — | `print` | 三轮精简 | `io.print(...)` |
| `register_fixed_buffers` | 与 std.io.driver 中曾重复的同名实现已移到仅保留在 mod；asm 合并 dep 时仍依赖 runtime merge 对同 import 路径去重。 | `register_buffers` | 三轮精简 | `io.register_buffers(...)` |
| `register_fixed_buffers_buf` | 与 Zig/Rust 对齐：按「指针+块数」注册固定 buffer 池；bufs 指向至少 nr 个 Buffer（ptr/len 有效），nr 为 1..8。返回 1 成功，0 失败。 | `register_buffers` | 三轮精简 | `io.register_buffers(...)` |
| `read_fixed_fd`               | 阶段 4 性能压榨：从 fd 用已注册 fixed buffer 读；buf_index 为 register_fixed_buffers 池下标，offset+len 须 ≤ 该块长度。返回读入字节数，0=EOF，-1=错误。供 std.net 热路径用。 | `read_fixed_fd`               | 已符合命名      | `io.read_fixed_fd(...)`               |
| `write_fixed_fd`              | 阶段 4 性能压榨：向 fd 用已注册 fixed buffer 写；buf_index/offset/len 同上。返回写入字节数，-1=错误。                                                         | `write_fixed_fd`              | 已符合命名      | `io.write_fixed_fd(...)`              |
| `register_provided_buffers` | 注册 provided 池；nr 1..32，bufsz 建议 4096。成功 1，失败/不支持 0。 | `register_provided` | 三轮精简 | `io.register_provided(...)` |
| `unregister_provided_buffers` | 注销 provided 池。                                                                                                                    | `unregister_provided` | 三轮精简 | io.unregister_provided_buffers(...) |
| `provided_buffer_ptr`         | 返回 bid 块只读指针；生命周期至该块被再次 recv 覆盖。                                                                                                  | `provided_buffer_ptr`         | 已符合命名      | `io.provided_buffer_ptr(...)`         |
| `provided_buffer_size`        | provided 单块容量。                                                                                                                    | `provided_buffer_size`        | 已符合命名      | `io.provided_buffer_size(...)`        |
| `read_provided_fd`            | 单次 provided recv；out_bid/out_len 可传 0。返回字节数，0=EOF，-1=错误。                                                                          | `read_provided_fd`            | 已符合命名      | `io.read_provided_fd(...)`            |
| `read_batch_provided_fd`      | 批量 provided recv（n=1..4）；out_bids/out_lens 各 n 元素。返回总字节数，-1=错误。                                                                   | `read_batch_provided_fd`      | 已符合命名      | `io.read_batch_provided_fd(...)`      |
| `wait_readable`               | —                                                                                                                                 | `wait_readable`               | 已符合命名      | `io.wait_readable(...)`               |
| `read_async`                  | 提交非阻塞 read；成功返回 slot>=0，失败 -1。                                                                                                    | `read_async`                  | 已符合命名      | `io.read_async(...)`                  |
| `complete_read_async` | 收割在途 read_async（单 in-flight 兼容）；见 IO_ASYNC_NOT_READY。 | `complete_read` | 三轮精简 | `io.complete_read(...)` |
| `complete_read_async_slot` | 收割指定 slot 的 read_async。 | `complete_read` | 三轮精简 | `io.complete_read(...)` |
| `write_async`                 | 提交非阻塞 write；成功返回 slot>=0，失败 -1。                                                                                                   | `write_async`                 | 已符合命名      | `io.write_async(...)`                 |
| `complete_write_async` | 收割在途 write_async（单 in-flight 兼容）；见 IO_ASYNC_NOT_READY。 | `complete_write` | 三轮精简 | `io.complete_write(...)` |
| `complete_write_async_slot` | 收割指定 slot 的 write_async。 | `complete_write` | 三轮精简 | `io.complete_write(...)` |
| `poll_async_completions` | poll io_uring async CQE 并唤醒 scheduler；返回本次收割的 async 完成数。 | `poll_completions` | 三轮精简 | `io.poll_completions(...)` |
| `io_uring_is_available` | 当前线程 io_uring 是否可用（Linux 且 ring 初始化成功）；1 是，0 否。 | `uring_ok` | 语义重命名；三轮精简 | `io.uring_ok(...)` |
| `read_into_slice`             | 从 stdin 读入至 buf[0..buf.length]，timeout_ms 毫秒（0=无超时）。返回读入字节数，0=EOF，-1=错误。                                                          | `read_slice` | 已符合命名；三轮精简 | `io.read_slice(...)` |
| `write_from_slice`            | 将 buf[0..buf.length] 写入 stdout，timeout_ms 毫秒（0=无超时）。返回写入字节数，-1=错误。                                                                | `write_slice` | 已符合命名；三轮精简 | `io.write_slice(...)` |
| `print_i32`                   | —                                                                                                                                 | `print`                       | 去模块前缀+去类型名 | `io.print(...)`                       |
| `print_u32`                   | —                                                                                                                                 | `print`                       | 去模块前缀+去类型名 | `io.print(...)`                       |
| `print_i64`                   | —                                                                                                                                 | `print`                       | 去模块前缀+去类型名 | `io.print(...)`                       |


### std.json

`std/json/mod.sx` · 76 APIs · `const json = import("std.json")`


| 当前名称                                 | 功能说明                                                               | 简化名称                          | 说明             | 绑定调用                                    |
| ------------------------------------ | ------------------------------------------------------------------ | ----------------------------- | -------------- | --------------------------------------- |
| `json_parse_number_c` | extern C/平台 | `parse_number` | 去模块前缀+去类型名（C层） | `json.parse_number(...)` |
| `json_parse_null_c` | extern C/平台 | `parse_null` | 去模块前缀+去类型名（C层） | `json.parse_null(...)` |
| `json_parse_bool_c` | extern C/平台 | `parse` | 去模块前缀+去类型名（C层） | `json.parse(...)` |
| `json_parse_string_c` | extern C/平台 | `parse_string` | 去模块前缀+去类型名（C层） | `json.parse_string(...)` |
| `json_escape_c` | extern C/平台 | `escape` | 去模块前缀+去类型名（C层） | `json.escape(...)` |
| `json_append_null_c` | extern C/平台 | `append_null` | 去模块前缀+去类型名（C层） | `json.append_null(...)` |
| `json_append_bool_c` | extern C/平台 | `append` | 去模块前缀+去类型名（C层） | `json.append(...)` |
| `json_append_number_c` | extern C/平台 | `append_number` | 去模块前缀+去类型名（C层） | `json.append_number(...)` |
| `json_skip_value_c` | extern C/平台 | `skip_value` | 去模块前缀+去类型名（C层） | `json.skip_value(...)` |
| `json_parse_string_view_c` | extern C/平台 | `parse_string_view` | 去模块前缀+去类型名（C层） | `json.parse_string_view(...)` |
| `json_cursor_init_c` | extern C/平台 | `cursor_init` | 去模块前缀+去类型名（C层） | `json.cursor_init(...)` |
| `json_cursor_enter_object_c` | extern C/平台 | `cursor_enter_object` | 去模块前缀+去类型名（C层） | `json.cursor_enter_object(...)` |
| `json_cursor_object_next_c` | extern C/平台 | `cursor_object_next` | 去模块前缀+去类型名（C层） | `json.cursor_object_next(...)` |
| `json_cursor_skip_value_c` | extern C/平台 | `cursor_skip_value` | 去模块前缀+去类型名（C层） | `json.cursor_skip_value(...)` |
| `json_cursor_enter_array_c` | extern C/平台 | `cursor_enter_array` | 去模块前缀+去类型名（C层） | `json.cursor_enter_array(...)` |
| `json_cursor_array_has_elem_c` | extern C/平台 | `cursor_array_has_elem` | 去模块前缀+去类型名（C层） | `json.cursor_array_has_elem(...)` |
| `json_cursor_value_type_c` | extern C/平台 | `cursor_value_type` | 去模块前缀+去类型名（C层） | `json.cursor_value_type(...)` |
| `json_decode_i32_at_c` | extern C/平台 | `decode_at` | 去模块前缀+去类型名（C层） | `json.decode_at(...)` |
| `json_decode_f64_at_c` | extern C/平台 | `decode_at` | 去模块前缀+去类型名（C层） | `json.decode_at(...)` |
| `json_decode_bool_at_c` | extern C/平台 | `decode_at` | 去模块前缀+去类型名（C层） | `json.decode_at(...)` |
| `json_decode_string_at_c` | extern C/平台 | `decode_string_at` | 去模块前缀+去类型名（C层） | `json.decode_string_at(...)` |
| `json_object_decode_i32_c` | extern C/平台 | `object_decode` | 去模块前缀+去类型名（C层） | `json.object_decode(...)` |
| `json_object_decode_bool_c` | extern C/平台 | `object_decode` | 去模块前缀+去类型名（C层） | `json.object_decode(...)` |
| `json_object_decode_string_c` | extern C/平台 | `object_decode_string` | 去模块前缀+去类型名（C层） | `json.object_decode_string(...)` |
| `json_object_decode_dotted_i32_c` | extern C/平台 | `object_decode_dotted` | 去模块前缀+去类型名（C层） | `json.object_decode_dotted(...)` |
| `json_object_decode_dotted_string_c` | extern C/平台                                                        | `object_decode_dotted_string` | 去模块前缀+去类型名（C层） | `json.object_decode_dotted_string(...)` |
| `json_object_decode_dotted_bool_c` | extern C/平台 | `object_decode_dotted` | 去模块前缀+去类型名（C层） | `json.object_decode_dotted(...)` |
| `json_object_decode_dotted_f64_c` | extern C/平台 | `object_decode_dotted` | 去模块前缀+去类型名（C层） | `json.object_decode_dotted(...)` |
| `json_typed_decode_smoke_c` | extern C/平台 | `typed_decode_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `json.typed_decode_smoke(...)` |
| `json_append_object_c` | extern C/平台 | `append_object` | 去模块前缀+去类型名（C层） | `json.append_object(...)` |
| `json_append_object_end_c` | extern C/平台 | `append_object_end` | 去模块前缀+去类型名（C层） | `json.append_object_end(...)` |
| `json_append_array_c` | extern C/平台 | `append_array` | 去模块前缀+去类型名（C层） | `json.append_array(...)` |
| `json_append_array_end_c` | extern C/平台 | `append_array_end` | 去模块前缀+去类型名（C层） | `json.append_array_end(...)` |
| `json_append_comma_c` | extern C/平台 | `append_comma` | 去模块前缀+去类型名（C层） | `json.append_comma(...)` |
| `json_append_key_c` | extern C/平台 | `append_key` | 去模块前缀+去类型名（C层） | `json.append_key(...)` |
| `json_append_string_value_c` | extern C/平台 | `append_string_value` | 去模块前缀+去类型名（C层） | `json.append_string_value(...)` |
| `json_append_number_at_c` | extern C/平台 | `append_number_at` | 去模块前缀+去类型名（C层） | `json.append_number_at(...)` |
| `json_view_needs_copy`               | 零拷贝视图需拷贝时的 out_len 哨兵（STD-008）。                                    | `needs_copy`                  | 二次精简：去对象前缀     | `json.needs_copy(...)`                  |
| `json_decode_missing`                | object 字段缺失时的返回码（STD-116）。                                         | `decode_missing`              | 去模块前缀+去类型名     | `json.decode_missing(...)`              |
| `parse_number`                       | —                                                                  | `parse_number`                | 已符合命名          | `json.parse_number(...)`                |
| `parse_null`                         | —                                                                  | `parse_null`                  | 已符合命名          | `json.parse_null(...)`                  |
| `parse_bool`                         | —                                                                  | `parse`                       | 已符合命名          | `json.parse(...)`                       |
| `parse_string`                       | 解析 JSON 字符串 "..."（含 n r t uXXXX）；内容写入 out，返回内容长度，失败 -1。            | `parse_string`                | 已符合命名          | `json.parse_string(...)`                |
| `escape_string` | — | `escape` | 三轮精简 | `json.escape(...)` |
| `append_null`                        | —                                                                  | `append_null`                 | 已符合命名          | `json.append_null(...)`                 |
| `append_bool`                        | —                                                                  | `append`                      | 已符合命名          | `json.append(...)`                      |
| `append_number`                      | —                                                                  | `append_number`               | 已符合命名          | `json.append_number(...)`               |
| `skip_value`                         | 跳过 ptr[0..len) 处完整 JSON 值；成功 0 并写 consumed 字节数，失败 -1（STD-034）。     | `skip_value`                  | 已符合命名          | `json.skip_value(...)`                  |
| `parse_string_view`                  | 无转义 JSON 字符串零拷贝视图；含转义时返回 null 且 *out_len = json_view_needs_copy()。 | `parse_string_view`           | 已符合命名          | `json.parse_string_view(...)`           |
| `cursor_init`                        | 初始化 JSON 游标。                                                       | `cursor_init`                 | 已符合命名          | `json.cursor_init(...)`                 |
| `cursor_enter_object`                | 进入 object；期望 leading `{`。                                          | `cursor_enter_object`         | 已符合命名          | `json.cursor_enter_object(...)`         |
| `cursor_object_next`                 | 读取下一 object 键；成功 1，结束 0，错误 -1。                                     | `cursor_object_next`          | 已符合命名          | `json.cursor_object_next(...)`          |
| `cursor_skip_value`                  | 跳过当前 value。                                                        | `cursor_skip_value`           | 已符合命名          | `json.cursor_skip_value(...)`           |
| `cursor_enter_array`                 | 进入 array；期望 leading `[`。                                           | `cursor_enter_array`          | 已符合命名          | `json.cursor_enter_array(...)`          |
| `cursor_array_has_elem`              | 数组内是否还有元素：1 有，0 已到 `]`。                                            | `cursor_array_has_elem`       | 已符合命名          | `json.cursor_array_has_elem(...)`       |
| `cursor_value_type`                  | 游标处 JSON 值种类（STD-116）。                                             | `cursor_value_type`           | 已符合命名          | `json.cursor_value_type(...)`           |
| `decode_i32_at`                      | 在 ptr 起点解码 i32。                                                    | `decode_at`                   | 去模块前缀+去类型名     | `json.decode_at(...)`                   |
| `decode_f64_at`                      | 在 ptr 起点解码 f64。                                                    | `decode_at`                   | 去模块前缀+去类型名     | `json.decode_at(...)`                   |
| `decode_bool_at`                     | 在 ptr 起点解码 bool。                                                   | `decode_at`                   | 已符合命名          | `json.decode_at(...)`                   |
| `decode_string_at`                   | 在 ptr 起点解码 string。                                                 | `decode_string_at`            | 已符合命名          | `json.decode_string_at(...)`            |
| `object_decode_i32`                  | object 内按 key 解码 i32 字段。                                           | `object_decode`               | 去模块前缀+去类型名     | `json.object_decode(...)`               |
| `object_decode_bool`                 | object 内按 key 解码 bool 字段。                                          | `object_decode`               | 已符合命名          | `json.object_decode(...)`               |
| `object_decode_string`               | object 内按 key 解码 string 字段。                                        | `object_decode_string`        | 已符合命名          | `json.object_decode_string(...)`        |
| `object_decode_dotted_i32`           | object 内按点分路径解码 i32（如 user.age）。                                   | `object_decode_dotted`        | 去模块前缀+去类型名     | `json.object_decode_dotted(...)`        |
| `object_decode_dotted_string`        | object 内按点分路径解码 string（如 user.name）。                               | `object_decode_dotted_string` | 已符合命名          | `json.object_decode_dotted_string(...)` |
| `object_decode_dotted_bool`          | object 内按点分路径解码 bool（如 ok / flags.0）。                              | `object_decode_dotted`        | 已符合命名          | `json.object_decode_dotted(...)`        |
| `object_decode_dotted_f64`           | object 内按点分路径解码 f64（如 metrics.cpu / values.0）。                     | `object_decode_dotted`        | 去模块前缀+去类型名     | `json.object_decode_dotted(...)`        |
| `typed_decode_smoke` | 类型化 decode C 烟测钩子（STD-116）。 | `typed_decode_smoke` | 已符合命名；Tier-X 不 export | `json.typed_decode_smoke(...)` |
| `append_object`                      | 在 buf[off] 写入 `{`。                                                 | `append_object`               | 已符合命名          | `json.append_object(...)`               |
| `append_object_end`                  | 在 buf[off] 写入 `}`。                                                 | `append_object_end`           | 已符合命名          | `json.append_object_end(...)`           |
| `append_array`                       | 在 buf[off] 写入 `[`。                                                 | `append_array`                | 已符合命名          | `json.append_array(...)`                |
| `append_array_end`                   | 在 buf[off] 写入 `]`。                                                 | `append_array_end`            | 已符合命名          | `json.append_array_end(...)`            |
| `append_comma`                       | 在 buf[off] 写入 `,`。                                                 | `append_comma`                | 已符合命名          | `json.append_comma(...)`                |
| `append_key`                         | 在 buf[off] 写入 `"key":`。                                            | `append_key`                  | 已符合命名          | `json.append_key(...)`                  |
| `append_string_value`                | 在 buf[off] 写入 `"value"`。                                           | `append_string_value`         | 已符合命名          | `json.append_string_value(...)`         |
| `append_number_at`                   | 在 buf[off] 写入 number。                                              | `append_number_at`            | 已符合命名          | `json.append_number_at(...)`            |


### std.log

`std/log/mod.sx` · 22 APIs · `const log = import("std.log")`


| 当前名称                        | 功能说明                                                                                                                      | 简化名称                  | 说明                                             | 绑定调用                           |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------- | --------------------- | ---------------------------------------------- | ------------------------------ |
| `log_set_min_level_c` | std.log — 日志级别与 stderr/文件输出（对标 Zig std.log、Rust log，零分配） STD-053：多 sink（SINK_STDERR | `SINK_FILE）+ 级别过滤 + 结构化 KV（OBS-003）。` | `set_min_level` | `log.SINK_FILE）+ 级别过滤 + 结构化 KV（OBS-003）。(...)` |
| `log_write_c` | extern C/平台 | `write` | 去模块前缀+去类型名（C层） | `log.write(...)` |
| `log_set_sink_mask_c` | extern C/平台 | `set_sink_mask` | 去模块前缀+去类型名（C层） | `log.set_sink_mask(...)` |
| `log_set_file_sink_c` | extern C/平台 | `set_file_sink` | 去模块前缀+去类型名（C层） | `log.set_file_sink(...)` |
| `log_close_file_sink_c` | extern C/平台 | `close_file_sink` | 去模块前缀+去类型名（C层） | `log.close_file_sink(...)` |
| `log_write_structured_kv_c` | extern C/平台                                                                                                               | `write_structured_kv` | 去模块前缀+去类型名（C层） | `log.write_structured_kv(...)` |
| `log_set_rotate_c` | extern C/平台 | `set_rotate` | 去模块前缀+去类型名（C层） | `log.set_rotate(...)` |
| `log_set_async_enabled_c` | extern C/平台 | `set_async_enabled` | 去模块前缀+去类型名（C层） | `log.set_async_enabled(...)` |
| `log_async_flush_c` | extern C/平台 | `async_flush` | 去模块前缀+去类型名（C层） | `log.async_flush(...)` |
| `level_debug`               | —                                                                                                                         | `level_debug`         | 已符合命名                                          | `log.level_debug(...)`         |
| `level_info`                | —                                                                                                                         | `level_info`          | 已符合命名                                          | `log.level_info(...)`          |
| `level_warn`                | —                                                                                                                         | `level_warn`          | 已符合命名                                          | `log.level_warn(...)`          |
| `level_error`               | —                                                                                                                         | `level_error`         | 已符合命名                                          | `log.level_error(...)`         |
| `set_min_level`             | 设置最小输出级别；低于此级别的 log 不写。0=DEBUG, 1=INFO, 2=WARN, 3=ERROR。                                                                  | `set_min_level`       | 已符合命名                                          | `log.set_min_level(...)`       |
| `set_sink_mask`             | 设置活跃 sink 掩码：SINK_STDERR | SINK_FILE。                                                                                     | `set_sink_mask`       | `log.SINK_FILE。(...)`                          | `log.set_sink_mask(...)`（已简洁）  |
| `set_file_sink`             | 打开追加写文件 sink；path 为字节路径，len 为长度。成功 0，失败 -1。                                                                               | `set_file_sink`       | 已符合命名                                          | `log.set_file_sink(...)`       |
| `close_file_sink`           | 关闭文件 sink（若已打开）。                                                                                                          | `close_file_sink`     | 已符合命名                                          | `log.close_file_sink(...)`     |
| `log`                       | 写一条人类可读日志："[LEVEL] " + ptr[0..len] + 换行。返回 0 成功，-1 失败。                                                                    | `log`                 | 已符合命名                                          | `log.log(...)`                 |
| `log_structured_kv`         | 写一条 OBS-003 结构化行：shux: level=… component=… kv…；comp/kv 为 NUL 结尾字节串。                                                       | `structured_kv`       | 去模块前缀+去类型名                                     | `log.structured_kv(...)`       |
| `set_rotate_limit`          | 设置文件 sink 轮转阈值（须先 set_file_sink）；max_backups 0=截断，1..8=备份。                                                                | `set_rotate_limit`    | 已符合命名                                          | `log.set_rotate_limit(...)`    |
| `set_async_enabled`         | 启用/关闭异步缓冲（32 槽环形队列）；关闭前自动 flush。                                                                                          | `set_async_enabled`   | 已符合命名                                          | `log.set_async_enabled(...)`   |
| `async_flush`               | 刷出异步缓冲到活跃 sink。                                                                                                           | `async_flush`         | 已符合命名                                          | `log.async_flush(...)`         |


### std.map

`std/map/mod.sx` · 46 APIs · `const map = import("std.map")`


| 当前名称                          | 功能说明                                                    | 简化名称                | 说明         | 绑定调用                         |
| ----------------------------- | ------------------------------------------------------- | ------------------- | ---------- | ---------------------------- |
| `map_default_capacity`        | 默认初始容量（槽位数）；负载因子超过约 0.7 时扩容。                            | `default_capacity`  | 去模块前缀+去类型名 | `map.default_capacity(...)`  |
| `map_i32_i32_slot`            | 取 key 的槽位下标（0..cap-1）；仅用于内部。                            | `slot`              | 去模块前缀+去类型名 | `map.slot(...)`              |
| `map_i32_i32_find`            | 查找 key 所在槽位；若存在返回槽位下标，否则返回 -1。F-03 v1：ops.sx 线性探测。 | `find`              | 去模块前缀+去类型名 | `map.find(...)`              |
| `map_i32_i32_new`             | 新建空 Map_i32_i32（cap 0，ptr 均为 null）。                     | `new`               | 去模块前缀+去类型名 | `map.new(...)`               |
| `map_i32_i32_with_capacity`   | 预分配 capacity 个槽位；失败返回 -1，成功返回 0。                        | `with_capacity`     | 去模块前缀+去类型名 | `map.with_capacity(...)`     |
| `map_i32_i32_grow`            | 扩容为 new_cap 并 rehash 所有条目；失败返回 -1，成功返回 0。               | `grow`              | 去模块前缀+去类型名 | `map.grow(...)`              |
| `map_i32_i32_reserve_one`     | —                                                       | `reserve_one`       | 去模块前缀+去类型名 | `map.reserve_one(...)`       |
| `map_i32_i32_insert`          | 插入 key -> value；若 key 已存在则覆盖。成功返回 0，失败返回 -1。            | `insert`            | 去模块前缀+去类型名 | `map.insert(...)`            |
| `map_i32_i32_get`             | 取 key 对应的 value；不存在则返回 default_val。                     | `get`               | 去模块前缀+去类型名 | `map.get(...)`               |
| `map_i32_i32_contains`        | 是否包含 key。返回 1 是，0 否。                                    | `contains_key`      | 去模块前缀+去类型名 | `map.contains_key(...)`      |
| `map_i32_i32_remove`          | 移除 key；若存在则移除并返回 1，否则返回 0。                              | `remove`            | 去模块前缀+去类型名 | `map.remove(...)`            |
| `map_i32_i32_len`             | 条目数。                                                    | `len`               | 去模块前缀+去类型名 | `map.len(...)`               |
| `map_i32_i32_len_ptr`         | 热路径：指针取 len，避免按值传 Map 结构体。                              | `len_ptr`           | 去模块前缀+去类型名 | `map.len_ptr(...)`           |
| `map_i32_i32_is_empty`        | 是否为空。返回 1 是，0 否。                                        | `is_empty`          | 去模块前缀+去类型名 | `map.is_empty(...)`          |
| `map_i32_i32_clear`           | 清空所有条目，不释放内存。                                           | `clear`             | 去模块前缀+去类型名 | `map.clear(...)`             |
| `map_i32_i32_reserve`         | 确保容量至少 new_cap 个槽位；失败返回 -1。                             | `reserve`           | 去模块前缀+去类型名 | `map.reserve(...)`           |
| `map_i32_i32_deinit`          | 释放堆内存并将 ptr 置为 null；调用后不可再使用。                           | `deinit`            | 去模块前缀+去类型名 | `map.deinit(...)`            |
| `map_i32_i32_iter_init`       | 初始化 map 迭代器（从 slot 0 扫描）。                               | `iter_init`         | 去模块前缀+去类型名 | `map.iter_init(...)`         |
| `map_i32_i32_iter_next`       | 读取下一 occupied 槽；结束 ok=0。                                | `iter_next`         | 去模块前缀+去类型名 | `map.iter_next(...)`         |
| `map_i32_i32_load_factor_pct` | 负载因子百分比（len*100/cap）；空表返回 0。                            | `load_factor_pct`   | 去模块前缀+去类型名 | `map.load_factor_pct(...)`   |
| `map_empty_size`              | 空 map 的 size 为 0。                                       | `empty_size`        | 去模块前缀+去类型名 | `map.empty_size(...)`        |
| `map_u64_i32_slot`            | u64 key 槽位下标。                                           | `slot`              | 去模块前缀+去类型名 | `map.slot(...)`              |
| `map_u64_i32_find`            | 线性探测查找 u64 key。                                         | `find`              | 去模块前缀+去类型名 | `map.find(...)`              |
| `map_u64_i32_new`             | 新建空 Map_u64_i32。                                        | `new`               | 去模块前缀+去类型名 | `map.new(...)`               |
| `map_u64_i32_with_capacity`   | 预分配 capacity 槽位；失败 -1。                                  | `with_capacity`     | 去模块前缀+去类型名 | `map.with_capacity(...)`     |
| `map_u64_i32_grow`            | 扩容并 rehash。                                             | `grow`              | 去模块前缀+去类型名 | `map.grow(...)`              |
| `map_u64_i32_reserve_one`     | 负载因子超 0.75 时扩容。                                         | `reserve_one`       | 去模块前缀+去类型名 | `map.reserve_one(...)`       |
| `map_u64_i32_insert`          | 插入 u64→i32；已存在则覆盖。                                      | `insert`            | 去模块前缀+去类型名 | `map.insert(...)`            |
| `map_u64_i32_get`             | 取 u64 key 对应 value；不存在返回 default_val。                   | `get`               | 去模块前缀+去类型名 | `map.get(...)`               |
| `map_u64_i32_contains`        | 是否包含 u64 key。                                           | `contains_key`      | 去模块前缀+去类型名 | `map.contains_key(...)`      |
| `map_u64_i32_remove`          | 移除 u64 key；存在返回 1。                                      | `remove`            | 去模块前缀+去类型名 | `map.remove(...)`            |
| `map_u64_i32_deinit`          | 释放 Map_u64_i32 堆内存。                                     | `deinit`            | 去模块前缀+去类型名 | `map.deinit(...)`            |
| `map_str_key_cap`             | 每槽键字节上限；超长键 insert 返回 -1。                               | `str_key_cap`       | 去模块前缀+去类型名 | `map.str_key_cap(...)`       |
| `map_str_i32_hash`            | djb2 哈希（key 字节序列）。                                      | `str_hash`          | 去模块前缀+去类型名 | `map.str_hash(...)`          |
| `map_str_i32_slot`            | 槽位下标（开放寻址起点）。                                           | `str_slot`          | 去模块前缀+去类型名 | `map.str_slot(...)`          |
| `map_str_i32_key_eq`          | 比较槽 slot 内键与 (key,key_len) 是否相等。                        | `str_key_eq`        | 去模块前缀+去类型名 | `map.str_key_eq(...)`        |
| `map_str_i32_find`            | 线性探测查找字符串键；存在返回槽位，否则 -1。                                | `str_find`          | 去模块前缀+去类型名 | `map.str_find(...)`          |
| `map_str_i32_new`             | 新建空 Map_str_i32。                                        | `str_new`           | 去模块前缀+去类型名 | `map.str_new(...)`           |
| `map_str_i32_with_capacity`   | 预分配 capacity 槽位；失败 -1。                                  | `str_with_capacity` | 去模块前缀+去类型名 | `map.str_with_capacity(...)` |
| `map_str_i32_grow`            | 扩容并 rehash 所有字符串键。                                      | `str_grow`          | 去模块前缀+去类型名 | `map.str_grow(...)`          |
| `map_str_i32_reserve_one`     | 负载因子超 0.75 时扩容。                                         | `str_reserve_one`   | 去模块前缀+去类型名 | `map.str_reserve_one(...)`   |
| `map_str_i32_insert`          | 插入字符串键→i32；key_len>map_str_key_cap() 或分配失败返回 -1。        | `str_insert`        | 去模块前缀+去类型名 | `map.str_insert(...)`        |
| `map_str_i32_get`             | 取字符串键对应 value；不存在返回 default_val。                        | `str_get`           | 去模块前缀+去类型名 | `map.str_get(...)`           |
| `map_str_i32_contains`        | 是否包含字符串键。                                               | `str_contains`      | 去模块前缀+去类型名 | `map.str_contains(...)`      |
| `map_str_i32_remove`          | 移除字符串键；存在返回 1。                                          | `str_remove`        | 去模块前缀+去类型名 | `map.str_remove(...)`        |
| `map_str_i32_deinit`          | 释放 Map_str_i32 堆内存。                                     | `str_deinit`        | 去模块前缀+去类型名 | `map.str_deinit(...)`        |


### std.math

`std/math/mod.sx` · 64 APIs · `const math = import("std.math")`


| 当前名称                    | 功能说明                                                                                                                         | 简化名称               | 说明             | 绑定调用                         |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------ | -------------- | ---------------------------- |
| `math_pi_c` | std.math — 数学常量与函数（对标 Zig std.math、Rust std::f64） 【文件职责】PI、E、Tau；floor/ceil/trunc/round；sin/cos/tan、asin/acos/atan、atan2；sqr | `pi` | 去模块前缀+去类型名（C层） | `math.pi(...)` |
| `math_e_c` | extern C/平台 | `e` | 去模块前缀+去类型名（C层） | `math.e(...)` |
| `math_tau_c` | extern C/平台 | `tau` | 去模块前缀+去类型名（C层） | `math.tau(...)` |
| `math_floor_c` | extern C/平台 | `floor` | 去模块前缀+去类型名（C层） | `math.floor(...)` |
| `math_ceil_c` | extern C/平台 | `ceil` | 去模块前缀+去类型名（C层） | `math.ceil(...)` |
| `math_trunc_c` | extern C/平台 | `trunc` | 去模块前缀+去类型名（C层） | `math.trunc(...)` |
| `math_round_c` | extern C/平台 | `round` | 去模块前缀+去类型名（C层） | `math.round(...)` |
| `math_sin_c` | extern C/平台 | `sin` | 去模块前缀+去类型名（C层） | `math.sin(...)` |
| `math_cos_c` | extern C/平台 | `cos` | 去模块前缀+去类型名（C层） | `math.cos(...)` |
| `math_tan_c` | extern C/平台 | `tan` | 去模块前缀+去类型名（C层） | `math.tan(...)` |
| `math_asin_c` | extern C/平台 | `asin` | 去模块前缀+去类型名（C层） | `math.asin(...)` |
| `math_acos_c` | extern C/平台 | `acos` | 去模块前缀+去类型名（C层） | `math.acos(...)` |
| `math_atan_c` | extern C/平台 | `atan` | 去模块前缀+去类型名（C层） | `math.atan(...)` |
| `math_atan2_c` | extern C/平台 | `atan2` | 去模块前缀+去类型名（C层） | `math.atan2(...)` |
| `math_sqrt_c` | extern C/平台 | `sqrt` | 去模块前缀+去类型名（C层） | `math.sqrt(...)` |
| `math_cbrt_c` | extern C/平台 | `cbrt` | 去模块前缀+去类型名（C层） | `math.cbrt(...)` |
| `math_pow_c` | extern C/平台 | `pow` | 去模块前缀+去类型名（C层） | `math.pow(...)` |
| `math_exp_c` | extern C/平台 | `exp` | 去模块前缀+去类型名（C层） | `math.exp(...)` |
| `math_log_c` | extern C/平台 | `log` | 去模块前缀+去类型名（C层） | `math.log(...)` |
| `math_fabs_c` | extern C/平台 | `fabs` | 去模块前缀+去类型名（C层） | `math.fabs(...)` |
| `math_signum_c` | extern C/平台 | `signum` | 去模块前缀+去类型名（C层） | `math.signum(...)` |
| `math_fmin_c` | extern C/平台 | `fmin` | 去模块前缀+去类型名（C层） | `math.fmin(...)` |
| `math_fmax_c` | extern C/平台 | `fmax` | 去模块前缀+去类型名（C层） | `math.fmax(...)` |
| `pi`                    | —                                                                                                                            | `pi`               | 已符合命名          | `math.pi(...)`               |
| `e`                     | —                                                                                                                            | `e`                | 已符合命名          | `math.e(...)`                |
| `tau`                   | —                                                                                                                            | `tau`              | 已符合命名          | `math.tau(...)`              |
| `floor`                 | —                                                                                                                            | `floor`            | 已符合命名          | `math.floor(...)`            |
| `ceil`                  | —                                                                                                                            | `ceil`             | 已符合命名          | `math.ceil(...)`             |
| `trunc`                 | —                                                                                                                            | `trunc`            | 已符合命名          | `math.trunc(...)`            |
| `round`                 | —                                                                                                                            | `round`            | 已符合命名          | `math.round(...)`            |
| `sin`                   | —                                                                                                                            | `sin`              | 已符合命名          | `math.sin(...)`              |
| `cos`                   | —                                                                                                                            | `cos`              | 已符合命名          | `math.cos(...)`              |
| `tan`                   | —                                                                                                                            | `tan`              | 已符合命名          | `math.tan(...)`              |
| `asin`                  | —                                                                                                                            | `asin`             | 已符合命名          | `math.asin(...)`             |
| `acos`                  | —                                                                                                                            | `acos`             | 已符合命名          | `math.acos(...)`             |
| `atan`                  | —                                                                                                                            | `atan`             | 已符合命名          | `math.atan(...)`             |
| `atan2`                 | —                                                                                                                            | `atan2`            | 已符合命名          | `math.atan2(...)`            |
| `sqrt`                  | —                                                                                                                            | `sqrt`             | 已符合命名          | `math.sqrt(...)`             |
| `cbrt`                  | —                                                                                                                            | `cbrt`             | 已符合命名          | `math.cbrt(...)`             |
| `pow`                   | —                                                                                                                            | `pow`              | 已符合命名          | `math.pow(...)`              |
| `exp`                   | —                                                                                                                            | `exp`              | 已符合命名          | `math.exp(...)`              |
| `log`                   | —                                                                                                                            | `log`              | 已符合命名          | `math.log(...)`              |
| `abs`                   | —                                                                                                                            | `abs`              | 已符合命名          | `math.abs(...)`              |
| `signum`                | —                                                                                                                            | `signum`           | 已符合命名          | `math.signum(...)`           |
| `min`                   | —                                                                                                                            | `min`              | 已符合命名          | `math.min(...)`              |
| `max`                   | —                                                                                                                            | `max`              | 已符合命名          | `math.max(...)`              |
| `math_erf_c` | extern C/平台 | `erf` | 去模块前缀+去类型名（C层） | `math.erf(...)` |
| `math_erfc_c` | extern C/平台 | `erfc` | 去模块前缀+去类型名（C层） | `math.erfc(...)` |
| `math_log1p_c` | extern C/平台 | `log1p` | 去模块前缀+去类型名（C层） | `math.log1p(...)` |
| `math_expm1_c` | extern C/平台 | `expm1` | 去模块前缀+去类型名（C层） | `math.expm1(...)` |
| `math_special_smoke_c` | extern C/平台 | `special_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `math.special_smoke(...)` |
| `erf`                   | 误差函数 erf(x)。                                                                                                                 | `erf`              | 已符合命名          | `math.erf(...)`              |
| `erfc`                  | 互补误差函数 erfc(x) = 1 - erf(x)。                                                                                                 | `erfc`             | 已符合命名          | `math.erfc(...)`             |
| `log1p`                 | log(1+x)，小 x 数值稳定。                                                                                                           | `log1p`            | 已符合命名          | `math.log1p(...)`            |
| `expm1`                 | exp(x)-1，小 x 数值稳定。                                                                                                           | `expm1`            | 已符合命名          | `math.expm1(...)`            |
| `special_smoke` | C 金样烟测；0=通过。 | `special_smoke` | 已符合命名；Tier-X 不 export | `math.special_smoke(...)` |
| `math_fenv_available_c` | extern C/平台 | `fenv_available` | 去模块前缀+去类型名（C层） | `math.fenv_available(...)` |
| `math_fenv_test_c` | extern C/平台 | `fenv_test` | 去模块前缀+去类型名（C层） | `math.fenv_test(...)` |
| `math_fenv_clear_c` | extern C/平台 | `fenv_clear` | 去模块前缀+去类型名（C层） | `math.fenv_clear(...)` |
| `math_fenv_raise_c` | extern C/平台 | `fenv_raise` | 去模块前缀+去类型名（C层） | `math.fenv_raise(...)` |
| `fenv_available`        | 平台是否支持 fenv：1=是，0=stub。                                                                                                      | `fenv_available`   | 已符合命名          | `math.fenv_available(...)`   |
| `test_exceptions`       | 读取 sticky 异常标志；stub 返回 FENV_NOT_IMPL。                                                                                        | `test_exceptions`  | 已符合命名          | `math.test_exceptions(...)`  |
| `clear_exceptions`      | 清除异常标志；成功 0；stub 返回 FENV_NOT_IMPL。                                                                                           | `clear_exceptions` | 已符合命名          | `math.clear_exceptions(...)` |
| `raise_exceptions`      | 置位异常标志（诊断）；成功 0；stub 返回 FENV_NOT_IMPL。                                                                                       | `raise_exceptions` | 已符合命名          | `math.raise_exceptions(...)` |


### std.mem

`std/mem/mod.sx` · 8 APIs · `const mem = import("std.mem")`


| 当前名称              | 功能说明                                          | 简化名称              | 说明    | 绑定调用                       |
| ----------------- | --------------------------------------------- | ----------------- | ----- | -------------------------- |
| `register_buffer` | —                                             | `register_buffer` | 已符合命名 | `mem.register_buffer(...)` |
| `copy`            | —                                             | `copy`            | 已符合命名 | `mem.copy(...)`            |
| `set`             | —                                             | `set`             | 已符合命名 | `mem.set(...)`             |
| `compare`         | —                                             | `compare`         | 已符合命名 | `mem.compare(...)`         |
| `copy_bounded`    | 有界拷贝：n>dst_cap 返回 -1；n<=0 返回 0；否则 copy 并返回 n。 | `copy_bounded`    | 已符合命名 | `mem.copy_bounded(...)`    |
| `set_bounded`     | 有界填充：n>cap 返回 -1；n<=0 返回 0；否则 set 并返回 n。      | `set_bounded`     | 已符合命名 | `mem.set_bounded(...)`     |
| `compare_bounded` | 有界比较：先比公共前缀，再按长度决胜。                           | `compare_bounded` | 已符合命名 | `mem.compare_bounded(...)` |
| `buffer_from`     | 从 ptr/len 构造 Buffer（handle=0）。                | `buffer_from`     | 已符合命名 | `mem.buffer_from(...)`     |


### std.metrics

`std/metrics/mod.sx` · 44 APIs · `const metrics = import("std.metrics")`


| 当前名称                             | 功能说明                                                           | 简化名称                             | 说明         | 绑定调用                                          |
| -------------------------------- | -------------------------------------------------------------- | -------------------------------- | ---------- | --------------------------------------------- |
| `metrics_err_ok`                 | 成功。                                                            | `err_ok`                         | 去模块前缀+去类型名 | `metrics.err_ok(...)`                         |
| `metrics_err_full`               | 注册表已满。                                                         | `err_full`                       | 去模块前缀+去类型名 | `metrics.err_full(...)`                       |
| `metrics_err_not_found`          | 索引或名称无效。                                                       | `err_not_found`                  | 去模块前缀+去类型名 | `metrics.err_not_found(...)`                  |
| `metrics_err_buffer`             | 输出缓冲不足。                                                        | `err_buffer`                     | 去模块前缀+去类型名 | `metrics.err_buffer(...)`                     |
| `metric_kind_counter`            | 指标种类：单调递增计数。                                                   | `metric_kind_counter`            | 已符合命名      | `metrics.metric_kind_counter(...)`            |
| `metric_kind_gauge`              | 指标种类：可增可减瞬时值。                                                  | `metric_kind_gauge`              | 已符合命名      | `metrics.metric_kind_gauge(...)`              |
| `metric_kind_histogram`          | 指标种类：分桶分布。                                                     | `metric_kind_histogram`          | 已符合命名      | `metrics.metric_kind_histogram(...)`          |
| `histogram_default_bucket_count` | 默认直方图桶上界（毫秒等任意单位，最后一档为 +Inf）。                                  | `histogram_default_bucket_count` | 已符合命名      | `metrics.histogram_default_bucket_count(...)` |
| `metrics_copy_bytes`             | 复制字节到固定缓冲；返回写入长度，失败 -1。                                        | `copy_bytes`                     | 去模块前缀+去类型名 | `metrics.copy_bytes(...)`                     |
| `label_empty`                    | 初始化空 label。                                                    | `label_empty`                    | 已符合命名      | `metrics.label_empty(...)`                    |
| `label_set`                      | 设置 label 键值（长度截断至 31）。                                         | `label_set`                      | 已符合命名      | `metrics.label_set(...)`                      |
| `registry_new`                   | 新建空注册表。                                                        | `registry_new`                   | 已符合命名      | `metrics.registry_new(...)`                   |
| `counter_init`                   | 初始化 Counter 名称与 label。                                         | `counter_init`                   | 已符合命名      | `metrics.counter_init(...)`                   |
| `counter_inc`                    | 递增 Counter（原子 add）。                                            | `counter_inc`                    | 已符合命名      | `metrics.counter_inc(...)`                    |
| `counter_snapshot`               | 读取 Counter 快照。                                                 | `counter_snapshot`               | 已符合命名      | `metrics.counter_snapshot(...)`               |
| `gauge_init`                     | 初始化 Gauge。                                                     | `gauge_init`                     | 已符合命名      | `metrics.gauge_init(...)`                     |
| `gauge_set`                      | 设置 Gauge 值。                                                    | `gauge_set`                      | 已符合命名      | `metrics.gauge_set(...)`                      |
| `gauge_add`                      | Gauge 加减。                                                      | `gauge_add`                      | 已符合命名      | `metrics.gauge_add(...)`                      |
| `gauge_snapshot`                 | 读取 Gauge 快照。                                                   | `gauge_snapshot`                 | 已符合命名      | `metrics.gauge_snapshot(...)`                 |
| `histogram_init_default_buckets` | 安装默认直方图桶：1, 5, 10, 50, +Inf。                                   | `histogram_init_default_buckets` | 已符合命名      | `metrics.histogram_init_default_buckets(...)` |
| `histogram_init`                 | 初始化 Histogram 名称与 label。                                       | `histogram_init`                 | 已符合命名      | `metrics.histogram_init(...)`                 |
| `histogram_observe`              | 记录一次观测值（写入首个匹配桶并更新 sum/count）。                                 | `histogram_observe`              | 已符合命名      | `metrics.histogram_observe(...)`              |
| `registry_register_counter` | 注册 Counter 到 Registry；返回索引或负错误码。 | `counter` | 三轮精简 | `metrics.counter(...)` |
| `registry_register_gauge` | 注册 Gauge。 | `gauge` | 三轮精简 | `metrics.gauge(...)` |
| `registry_register_histogram` | 注册 Histogram。 | `histogram` | 三轮精简 | `metrics.histogram(...)` |
| `metrics_append_slice` | 追加 slice 到 out；返回新 offset，失败 -1。 | `extend` | 去模块前缀+去类型名；三轮精简 | `metrics.extend(...)` |
| `metrics_append_byte`            | 追加单字节；返回新 offset，失败 -1。                                        | `append_byte`                    | 去模块前缀+去类型名 | `metrics.append_byte(...)`                    |
| `metrics_append_label_suffix`    | 追加 label 片段 key="val"（不含花括号）；无 label 时返回原 offset。              | `append_label_suffix`            | 去模块前缀+去类型名 | `metrics.append_label_suffix(...)`            |
| `export_counter_prometheus`      | 导出单个 Counter 的 Prometheus 行。                                   | `export_counter_prometheus`      | 已符合命名      | `metrics.export_counter_prometheus(...)`      |
| `export_gauge_prometheus`        | 导出单个 Gauge 的 Prometheus 行。                                     | `export_gauge_prometheus`        | 已符合命名      | `metrics.export_gauge_prometheus(...)`        |
| `export_histogram_prometheus`    | 导出 Histogram（累积桶 + sum + count）。                               | `export_histogram_prometheus`    | 已符合命名      | `metrics.export_histogram_prometheus(...)`    |
| `export_prometheus`              | 导出 Registry 内全部指标为 Prometheus 文本；返回总长度。                        | `export_prometheus`              | 已符合命名      | `metrics.export_prometheus(...)`              |
| `obs_ctx_key_trace_len`          | Context value bag 键 "trace"（与 std.trace.attach_to_context 一致）。 | `obs_ctx_key_trace_len`          | 已符合命名      | `metrics.obs_ctx_key_trace_len(...)`          |
| `obs_ctx_key_span_len`           | Context value bag 键 "span"（span_id i64）。                       | `obs_ctx_key_span_len`           | 已符合命名      | `metrics.obs_ctx_key_span_len(...)`           |
| `obs_ctx_write_key_trace`        | 写入 trace 键到 buf；返回写入长度。                                        | `obs_ctx_write_key_trace`        | 已符合命名      | `metrics.obs_ctx_write_key_trace(...)`        |
| `obs_ctx_write_key_span`         | 写入 span 键到 buf；返回写入长度。                                         | `obs_ctx_write_key_span`         | 已符合命名      | `metrics.obs_ctx_write_key_span(...)`         |
| `obs_ctx_empty`                  | 空观测上下文。                                                        | `obs_ctx_empty`                  | 已符合命名      | `metrics.obs_ctx_empty(...)`                  |
| `obs_encode_trace_id_hex`        | 将 trace_id 16 字节编码为 32 字符 hex 写入 obs.trace_id_hex；返回长度。        | `obs_encode_trace_id_hex`        | 已符合命名      | `metrics.obs_encode_trace_id_hex(...)`        |
| `obs_encode_span_id_hex`         | 将 span_id 编码为 hex 写入 obs.span_id_hex；返回长度。                     | `obs_encode_span_id_hex`         | 已符合命名      | `metrics.obs_encode_span_id_hex(...)`         |
| `obs_ctx_from_trace`             | 从 Trace + Span 构建观测上下文。                                        | `obs_ctx_from_trace`             | 已符合命名      | `metrics.obs_ctx_from_trace(...)`             |
| `obs_ctx_attach_context`         | 将观测上下文写入 Context value bag（trace 句柄 + span_id）。                | `obs_ctx_attach_context`         | 已符合命名      | `metrics.obs_ctx_attach_context(...)`         |
| `obs_ctx_from_context`           | 从 Context 恢复观测上下文；tr 用于读取 trace_id hex。                        | `obs_ctx_from_context`           | 已符合命名      | `metrics.obs_ctx_from_context(...)`           |
| `obs_ctx_format_log_kv`          | —                                                              | `obs_ctx_format_log_kv`          | 已符合命名      | `metrics.obs_ctx_format_log_kv(...)`          |
| `obs_ctx_apply_trace_label`      | —                                                              | `obs_ctx_apply_trace_label`      | 已符合命名      | `metrics.obs_ctx_apply_trace_label(...)`      |


### std.net

`std/net/mod.sx` · 94 APIs · `const net = import("std.net")`


| 当前名称                               | 功能说明                                                                                                                                                                         | 简化名称                         | 说明             | 绑定调用                                  |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------------- | ------------------------------------- |
| `net_tcp_connect_c` | extern C/平台 | `connect` | 去模块前缀+去类型名（C层） | `net.connect(...)` |
| `net_tcp_connect_blocking_c` | 阻塞 TCP 连接（bulk 传输快路径）；timeout_ms 毫秒（0=无超时）。 | `connect_blocking` | 去模块前缀+去类型名（C层） | `net.connect_blocking(...)` |
| `net_tcp_listen_c` | extern C/平台 | `listen` | 去模块前缀+去类型名（C层） | `net.listen(...)` |
| `net_accept_c` | extern C/平台 | `accept` | 去模块前缀+去类型名（C层） | `net.accept(...)` |
| `net_accept_many_c` | 阶段 2：批量接受，out_fds 至少 n 个，返回成功数量。 | `accept_many` | 去模块前缀+去类型名（C层） | `net.accept_many(...)` |
| `net_run_accept_workers_c` | 多核易用：起 n_workers 个线程，每线程循环 accept_many 后立即 close；主线程阻塞直至 join（永不返回）。失败返回 -1。 | `run_accept_workers` | 去模块前缀+去类型名（C层） | `net.run_accept_workers(...)` |
| `net_connect_many_c` | 阶段 2：批量建连，out_fds 至少 n 个，返回成功数量。 | `connect_many` | 去模块前缀+去类型名（C层） | `net.connect_many(...)` |
| `net_close_socket_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `net.close(...)` |
| `net_set_blocking_c` | 设置 socket 阻塞/非阻塞；blocking：1=阻塞，0=非阻塞。0 成功，-1 失败。 | `set_blocking` | 去模块前缀+去类型名（C层） | `net.set_blocking(...)` |
| `net_udp_bind_c` | extern C/平台 | `bind` | 去模块前缀+去类型名（C层） | `net.bind(...)` |
| `net_udp_send_to_c` | extern C/平台 | `send_to` | 去模块前缀+去类型名（C层） | `net.send_to(...)` |
| `net_udp_recv_from_c` | extern C/平台 | `recv_from` | 去模块前缀+去类型名（C层） | `net.recv_from(...)` |
| `net_udp_recv_many_c` | 阶段 5：UDP 批量接收，最多 2 段 (p0,l0),(p1,l1)，n 为 1..2；out_sizes/out_addrs/out_ports 至少 n 个元素。返回收到报文数，-1=错误。 | `recv_many` | 去模块前缀+去类型名（C层） | `net.recv_many(...)` |
| `net_udp_send_many_c` | 阶段 5：UDP 批量发送，n 条 (addr, port, buf, len)，n 为 1..2。返回发送报文数，-1=错误。 | `send_many` | 去模块前缀+去类型名（C层） | `net.send_many(...)` |
| `net_udp_recv_many_buf_c` | 阶段 5 切片化：UDP 批量接收，bufs 为 Buffer 数组（与 Buffer ABI 一致），n 为 1..8；out_sizes/out_addrs/out_ports 至少 n 个。返回收到报文数，-1=错误。 | `recv_many_buf` | 去模块前缀+去类型名（C层） | `net.recv_many_buf(...)` |
| `net_udp_send_many_buf_c` | 阶段 5 切片化：UDP 批量发送，addrs/ports/bufs 各 n 个，n 为 1..8。返回发送报文数，-1=错误。 | `send_many_buf` | 去模块前缀+去类型名（C层） | `net.send_many_buf(...)` |
| `net_tcp_local_addr_c` | extern C/平台 | `local_addr` | 去模块前缀+去类型名（C层） | `net.local_addr(...)` |
| `net_tcp_peer_addr_c` | extern C/平台 | `peer_addr` | 去模块前缀+去类型名（C层） | `net.peer_addr(...)` |
| `net_tcp_connect_ipv6_c` | extern C/平台 | `connect_ipv6` | 去模块前缀+去类型名（C层） | `net.connect_ipv6(...)` |
| `net_tcp_listen_ipv6_c` | extern C/平台 | `listen_ipv6` | 去模块前缀+去类型名（C层） | `net.listen_ipv6(...)` |
| `net_resolve_ipv4_c` | extern C/平台 | `resolve_ipv4` | 去模块前缀+去类型名（C层） | `net.resolve_ipv4(...)` |
| `net_resolve_ipv4_ex_c` | STD-029：可诊断 IPv4 DNS；失败 -1 并写 out_err。 | `resolve_ipv4_ex` | 去模块前缀+去类型名（C层） | `net.resolve_ipv4_ex(...)` |
| `net_resolve_ipv6_ex_c` | STD-029：可诊断 IPv6 DNS；失败 -1 并写 out_err；成功写 16 字节地址。 | `resolve_ipv6_ex` | 去模块前缀+去类型名（C层） | `net.resolve_ipv6_ex(...)` |
| `net_stream_read_batch_provided_c` | ZC-1：批量 provided recv 薄包装（Linux io_uring）。 | `read_batch_provided` | 二次精简：去对象前缀 | `net.read_batch_provided(...)` |
| `net_tls_alpn_h2_http1_wire_c` | ALPN 线格式（h2 + http/1.1）；由 alpn.sx 提供（F-04 v10）。 | `tls_alpn_h2_http1_wire` | 去模块前缀+去类型名（C层） | `net.tls_alpn_h2_http1_wire(...)` |
| `addr_to_u32`                      | 将 Ipv4Addr 转为 C 层使用的 u32（大端：(a<<24)|(b<<16)|(c<<8)| `net.(b<<16)\(...)`                                                                                                      | `addr_to_packed`             | 语义重命名          | `net.addr_to_packed(...)`             |
| `u32_to_ipv4`                      | 将 C 层返回的 u32（主机序）转为 Ipv4Addr。                                                                                                                                                | `packed_to_ipv4`             | 语义重命名          | `net.packed_to_ipv4(...)`             |
| `connect`                          | 连接至 addr:port；timeout_ms 毫秒（0=无超时）。返回 TcpStream（失败 fd=-1）；Socket 为非阻塞。                                                                                                       | `connect`                    | 已符合命名          | `net.connect(...)`                    |
| `connect_blocking`                 | 阻塞连接（sendfile / 大块 writev 快路径）；与 C bench 的 blocking connect 对齐。                                                                                                              | `connect_blocking`           | 已符合命名          | `net.connect_blocking(...)`           |
| `listen`                           | 在 addr:port 上监听；返回 TcpListener（失败 fd=-1）；Socket 为非阻塞。                                                                                                                        | `listen`                     | 已符合命名          | `net.listen(...)`                     |
| `accept`                           | 从 listener 接受一个连接；timeout_ms 毫秒（0=无超时）。返回 TcpStream（失败 fd=-1）；Client 为非阻塞。                                                                                                   | `accept`                     | 已符合命名          | `net.accept(...)`                     |
| `close_stream`                     | 关闭 TcpStream；须用此而非 std.fs.fs_close，以便 Windows 下走 closesocket。返回 0 成功，-1 失败。                                                                                                  | `close_stream`               | 已符合命名          | `net.close_stream(...)`               |
| `stream_set_blocking`              | bulk 传输快路径：切阻塞模式（sendfile / 大块 writev）；async 路径保持 connect 默认非阻塞。                                                                                                             | `set_blocking`               | 二次精简：去对象前缀     | `net.set_blocking(...)`               |
| `stream_read_batch`                | 阶段 3 性能压榨：从 TcpStream 批量读，一次 submit 最多 4 段 (p0,l0)..(p3,l3)，n 为段数 1..4；timeout_ms 毫秒（0=无超时）。走 io_uring/readv。热路径建议打满 4 段减少 syscall。返回总字节数，-1=错误。                             | `read_batch`                 | 二次精简：去对象前缀     | `net.read_batch(...)`                 |
| `stream_write_batch`               | 阶段 3 性能压榨：向 TcpStream 批量写，一次 submit 最多 4 段 (p0,l0)..(p3,l3)，n 为段数 1..4；timeout_ms 毫秒（0=无超时）。走 io_uring/writev。热路径建议打满 4 段减少 syscall。返回总字节数，-1=错误。                            | `write_batch`                | 二次精简：去对象前缀     | `net.write_batch(...)`                |
| `stream_read_batch_buf`            | 与 Zig/Rust 对齐：按「指针+段数」批量读；buffers 指向至少 n 个 Buffer（ptr/len 由调用方填充，handle 可忽略），n 为 1..16。一次 readv/io_uring 覆盖多段。返回总字节数，-1=错误。                                                  | `read_batch_buf`             | 二次精简：去对象前缀     | `net.read_batch_buf(...)`             |
| `stream_write_batch_buf`           | 与 Zig/Rust 对齐：按「指针+段数」批量写；buffers 同上。返回总字节数，-1=错误。                                                                                                                           | `write_batch_buf`            | 二次精简：去对象前缀     | `net.write_batch_buf(...)`            |
| `stream_read_fixed`                | 阶段 4 性能压榨：从 TcpStream 用已注册 fixed buffer 读；须先 io.register_fixed_buffers。buf_index 为池下标，offset+len 须 ≤ 该块长度。echo/代理热路径推荐：固定池 + read_fixed/write_fixed 零拷贝。返回读入字节数，0=EOF，-1=错误。 | `read_fixed`                 | 二次精简：去对象前缀     | `net.read_fixed(...)`                 |
| `stream_write_fixed`               | 阶段 4 性能压榨：向 TcpStream 用已注册 fixed buffer 写；buf_index/offset/len 同上。echo/代理热路径推荐与 stream_read_fixed 配对使用。返回写入字节数，-1=错误。                                                        | `write_fixed`                | 二次精简：去对象前缀     | `net.write_fixed(...)`                |
| `stream_read_batch_provided`       | ZC-1：批量 provided recv（n=1..4）；须先 io.register_provided_buffers。数据在 provided_buffer_ptr(bid)。                                                                                  | `read_batch_provided`        | 二次精简：去对象前缀     | `net.read_batch_provided(...)`        |
| `close_listener`                   | 关闭 TcpListener。返回 0 成功，-1 失败。                                                                                                                                                | `close_listener`             | 已符合命名          | `net.close_listener(...)`             |
| `run_accept_workers`               | —                                                                                                                                                                            | `run_accept_workers`         | 已符合命名          | `net.run_accept_workers(...)`         |
| `local_addr`                       | 获取 TcpStream 或 TcpListener 的本地地址与端口；失败返回 addr=0.0.0.0、port=0。                                                                                                                | `local_addr`                 | 已符合命名          | `net.local_addr(...)`                 |
| `peer_addr`                        | 获取 TcpStream 的远端地址与端口；失败返回 addr=0.0.0.0、port=0。                                                                                                                              | `peer_addr`                  | 已符合命名          | `net.peer_addr(...)`                  |
| `listener_local_addr`              | 获取 TcpListener 的本地地址与端口。                                                                                                                                                     | `listener_local_addr`        | 已符合命名          | `net.listener_local_addr(...)`        |
| `udp_bind`                         | 在 addr:port 上绑定 UDP；addr 为 0.0.0.0 表示监听所有接口。返回 UdpSocket（失败 fd=-1）。非阻塞。                                                                                                      | `udp_bind`                   | 已符合命名          | `net.udp_bind(...)`                   |
| `udp_send_to`                      | 向 addr:port 发送 buf[0..len]。返回发送字节数，失败 -1。                                                                                                                                    | `send_to`                    | 语义重命名          | `net.send_to(...)`                    |
| `udp_recv_from`                    | 从 sock 接收至 buf[0..len]，timeout_ms 毫秒（0=无超时）。返回接收字节数，0=无数据，-1=错误；成功时写入 *out_addr 与 *out_port。                                                                                 | `recv_from`                  | 语义重命名          | `net.recv_from(...)`                  |
| `udp_recv_many`                    | 阶段 5 性能压榨：UDP 批量接收，最多 2 段 (p0,l0),(p1,l1)，n 为 1..2；timeout_ms 毫秒（0=无超时）。out_sizes[i]=第 i 条字节数，out_addrs/out_ports 为发送方。Linux 走 recvmmsg。返回收到报文数，-1=错误。                       | `udp_recv_many`              | 已符合命名          | `net.udp_recv_many(...)`              |
| `udp_send_many`                    | 阶段 5 性能压榨：UDP 批量发送，n 条 (addr_i, port_i, p_i, l_i)，n 为 1..2。Linux 走 sendmmsg。返回发送报文数，-1=错误。                                                                                   | `udp_send_many`              | 已符合命名          | `net.udp_send_many(...)`              |
| `udp_recv_many_buf`                | 阶段 5 切片化：UDP 批量接收，bufs 为 Buffer 数组（ptr+len+handle），n 为 1..8；out_sizes/out_addrs/out_ports 至少 n 个。返回收到报文数，-1=错误。                                                              | `udp_recv_many_buf`          | 已符合命名          | `net.udp_recv_many_buf(...)`          |
| `udp_send_many_buf`                | 阶段 5 切片化：UDP 批量发送，addrs[i]/ports[i]/bufs[i] 为第 i 条目标与负载，n 为 1..8。返回发送报文数，-1=错误。                                                                                              | `udp_send_many_buf`          | 已符合命名          | `net.udp_send_many_buf(...)`          |
| `close_udp`                        | 关闭 UdpSocket。返回 0 成功，-1 失败。                                                                                                                                                  | `close_udp`                  | 已符合命名          | `net.close_udp(...)`                  |
| `ipv6_loopback`                    | IPv6 环回地址 ::1（与 connect_ipv6_ctx_fd 烟测一致）。                                                                                                                                   | `ipv6_loopback`              | 已符合命名          | `net.ipv6_loopback(...)`              |
| `connect_ipv6`                     | 连接至 IPv6 addr:port；timeout_ms 毫秒（0=无超时）。返回 TcpStream（失败 fd=-1）。非阻塞。                                                                                                          | `connect_ipv6`               | 已符合命名          | `net.connect_ipv6(...)`               |
| `listen_ipv6`                      | 在 IPv6 addr:port 上监听。返回 TcpListener（失败 fd=-1）。非阻塞。                                                                                                                           | `listen_ipv6`                | 已符合命名          | `net.listen_ipv6(...)`                |
| `resolve`                          | 将 hostname（NUL 结尾字符串）解析为 IPv4 地址；失败返回 0.0.0.0。                                                                                                                               | `resolve`                    | 已符合命名          | `net.resolve(...)`                    |
| `resolve_err_ok`                   | resolve_ex 成功错误码。                                                                                                                                                            | `resolve_err_ok`             | 已符合命名          | `net.resolve_err_ok(...)`             |
| `resolve_err_host_not_found`       | 主机名不存在（EAI_NONAME）。                                                                                                                                                          | `resolve_err_host_not_found` | 已符合命名          | `net.resolve_err_host_not_found(...)` |
| `resolve_err_no_data`              | 无 A/AAAA 数据（EAI_NODATA）。                                                                                                                                                     | `resolve_err_no_data`        | 已符合命名          | `net.resolve_err_no_data(...)`        |
| `resolve_err_try_again`            | 临时失败（EAI_AGAIN）。                                                                                                                                                             | `resolve_err_try_again`      | 已符合命名          | `net.resolve_err_try_again(...)`      |
| `resolve_err_system`               | 其它系统错误。                                                                                                                                                                      | `resolve_err_system`         | 已符合命名          | `net.resolve_err_system(...)`         |
| `resolve_ex`                       | —                                                                                                                                                                            | `resolve_ex`                 | 已符合命名          | `net.resolve_ex(...)`                 |
| `resolve_ipv6`                     | —                                                                                                                                                                            | `resolve_ipv6`               | 已符合命名          | `net.resolve_ipv6(...)`               |
| `net_batch_max`                    | —                                                                                                                                                                            | `batch_max`                  | 去模块前缀+去类型名     | `net.batch_max(...)`                  |
| `accept_many`                      | —                                                                                                                                                                            | `accept_many`                | 已符合命名          | `net.accept_many(...)`                |
| `connect_many`                     | —                                                                                                                                                                            | `connect_many`               | 已符合命名          | `net.connect_many(...)`               |
| `net_timeout_ms_from_ctx`          | 从 Context 推导 TCP 超时毫秒；已取消/过期返回对应 net_err_*（负值），否则返回 0 或正毫秒。                                                                                                                  | `timeout_ms_from_ctx`        | 去模块前缀+去类型名     | `net.timeout_ms_from_ctx(...)`        |
| `connect_ctx_fd`                   | 带 Context 的 IPv4 TCP 连接；取消/过期返回 net_err_*，成功返回 fd（失败 fd=-1）。                                                                                                                 | `connect_ctx_fd`             | 已符合命名          | `net.connect_ctx_fd(...)`             |
| `connect_ipv6_ctx_fd`              | 带 Context 的 IPv6 TCP 连接；语义同 connect_ctx_fd。                                                                                                                                  | `connect_ipv6_ctx_fd`        | 已符合命名          | `net.connect_ipv6_ctx_fd(...)`        |
| `accept_ctx_fd`                    | 带 Context 的 accept；取消/过期返回 net_err_*，成功返回 client fd。                                                                                                                         | `accept_ctx_fd`              | 已符合命名          | `net.accept_ctx_fd(...)`              |
| `stream_read_ctx`                  | 带 Context 的 TcpStream 读；取消/过期返回 net_err_*。                                                                                                                                   | `read_ctx`                   | 二次精简：去对象前缀     | `net.read_ctx(...)`                   |
| `stream_write_ctx`                 | 带 Context 的 TcpStream 写；语义同 stream_read_ctx。                                                                                                                                 | `write_ctx`                  | 二次精简：去对象前缀     | `net.write_ctx(...)`                  |
| `TLS_NOT_IMPL`                     | TLS 桩：未链入 OpenSSL/mbedTLS 时 connect/read/write 返回此码。                                                                                                                         | `TLS_NOT_IMPL`               | 已符合命名          | `net.TLS_NOT_IMPL(...)`               |
| `tls_is_available`                 | TLS 后端是否可用；1 可用，0 桩。                                                                                                                                                         | `tls_is_available`           | 已符合命名          | `net.tls_is_available(...)`           |
| `tls_backend_name`                 | TLS 后端名称（NUL 结尾）；桩时为 "stub"。                                                                                                                                                 | `tls_backend_name`           | 已符合命名          | `net.tls_backend_name(...)`           |
| `tls_connect_client`               | 在已有 TCP 连接上执行 TLS 客户端握手；sni 可为 NUL 或主机名字符串。                                                                                                                                  | `tls_connect_client`         | 已符合命名          | `net.tls_connect_client(...)`         |
| `tls_alpn_h2_http1_wire`           | ALPN 线格式（h2 + http/1.1）；成功返回写入字节数（12）。                                                                                                                                       | `tls_alpn_h2_http1_wire`     | 已符合命名          | `net.tls_alpn_h2_http1_wire(...)`     |
| `tls_connect_client_alpn`          | 带 ALPN 的 TLS 客户端握手；alpn_wire 为 RFC 7301 长度前缀列表。                                                                                                                              | `tls_connect_client_alpn`    | 已符合命名          | `net.tls_connect_client_alpn(...)`    |
| `tls_alpn_selected`                | 读取协商后的 ALPN 协议名长度；可选写入 out。                                                                                                                                                  | `tls_alpn_selected`          | 已符合命名          | `net.tls_alpn_selected(...)`          |
| `tls_alpn_is_h2`                   | 协商协议是否为 h2。                                                                                                                                                                  | `tls_alpn_is_h2`             | 已符合命名          | `net.tls_alpn_is_h2(...)`             |
| `tls_read`                         | 从 TLS 会话读解密数据；返回字节数，0=EOF，负值为错误（桩为 TLS_NOT_IMPL）。                                                                                                                            | `tls_read`                   | 已符合命名          | `net.tls_read(...)`                   |
| `tls_write`                        | 向 TLS 会话写明文；返回写入字节数，负值为错误。                                                                                                                                                   | `tls_write`                  | 已符合命名          | `net.tls_write(...)`                  |
| `tls_close`                        | 关闭 TLS 会话；成功 0。                                                                                                                                                              | `tls_close`                  | 已符合命名          | `net.tls_close(...)`                  |
| `tls_last_error`                   | 读取 TLS 最后一次错误码（如 TLS_NOT_IMPL、参数 -2）。                                                                                                                                        | `tls_last_error`             | 已符合命名          | `net.tls_last_error(...)`             |
| `tcp_pool_new`                     | 创建 TCP 连接池；host 为 Ipv4Addr 数值（同 addr_to_u32）；max_idle 默认 1。                                                                                                                  | `tcp_pool_new`               | 已符合命名          | `net.tcp_pool_new(...)`               |
| `tcp_pool_acquire`                 | 从池取连接（idle 复用或新建 TCP）；失败 -1。                                                                                                                                                 | `tcp_pool_acquire`           | 已符合命名          | `net.tcp_pool_acquire(...)`           |
| `tcp_pool_release`                 | 归还 fd 到 idle 栈；栈满则 close。                                                                                                                                                    | `tcp_pool_release`           | 已符合命名          | `net.tcp_pool_release(...)`           |
| `tcp_pool_drain`                   | 关闭并清空 idle 连接（不销毁池对象）。                                                                                                                                                       | `tcp_pool_drain`             | 已符合命名          | `net.tcp_pool_drain(...)`             |
| `tcp_pool_destroy`                 | 销毁连接池。                                                                                                                                                                       | `tcp_pool_destroy`           | 已符合命名          | `net.tcp_pool_destroy(...)`           |
| `tcp_pool_connect_count`           | 累计新建 TCP 连接次数。                                                                                                                                                               | `tcp_pool_connect_count`     | 已符合命名          | `net.tcp_pool_connect_count(...)`     |
| `tcp_pool_idle_count`              | 当前 idle 连接数。                                                                                                                                                                 | `tcp_pool_idle_count`        | 已符合命名          | `net.tcp_pool_idle_count(...)`        |
| `tcp_pool_smoke` | TCP 连接池烟测；0 通过。 | `tcp_pool_smoke` | 已符合命名；Tier-X 不 export | `net.tcp_pool_smoke(...)` |


### std.option

`std/option/mod.sx` · 11 APIs · `const option = import("std.option")`


| 当前名称                     | 功能说明                                   | 简化名称          | 说明         | 绑定调用                      |
| ------------------------ | -------------------------------------- | ------------- | ---------- | ------------------------- |
| `none_i32`               | 构造无值 Option_i32。                       | `none`        | 去模块前缀+去类型名 | `option.none(...)`        |
| `some_i32`               | 构造有值 Option_i32。                       | `some`        | 去模块前缀+去类型名 | `option.some(...)`        |
| `unwrap_or_i32`          | 有值返回值，否则 default。                      | `unwrap_or`   | 去模块前缀+去类型名 | `option.unwrap_or(...)`   |
| `is_some_i32`            | 是否为 Some。                              | `is_some`     | 去模块前缀+去类型名 | `option.is_some(...)`     |
| `is_none_i32`            | 是否为 None。                              | `is_none`     | 去模块前缀+去类型名 | `option.is_none(...)`     |
| `map_i32`                | eager map：有值则 some(mapped)，否则 none。    | `map`         | 去模块前缀+去类型名 | `option.map(...)`         |
| `and_then_i32`           | eager and_then：有值则 next，否则 none。       | `and_then`    | 去模块前缀+去类型名 | `option.and_then(...)`    |
| `or_i32`                 | 取第一个 Some，否则 other。                    | `or`          | 去模块前缀+去类型名 | `option.or(...)`          |
| `option_from_result_i32` | Result 成功转 Some(value)，失败转 None。       | `from_result` | 去模块前缀+去类型名 | `option.from_result(...)` |
| `option_from_result_u8`  | Result_u8 成功转 Some，失败转 None。           | `from_result` | 去模块前缀+去类型名 | `option.from_result(...)` |
| `option_to_result_i32`   | Option 有值转 Ok，None 转 Err(err_if_none)。 | `to_result`   | 去模块前缀+去类型名 | `option.to_result(...)`   |


### std.path

`std/path/mod.sx` · 15 APIs · `const path = import("std.path")`


| 当前名称                      | 功能说明                                                                                                  | 简化名称                 | 说明             | 绑定调用                           |
| ------------------------- | ----------------------------------------------------------------------------------------------------- | -------------------- | -------------- | ------------------------------ |
| `path_empty_len`          | 空路径长度 0；与 path_join 等配合使用。                                                                            | `empty_len`          | 去模块前缀+去类型名     | `path.empty_len(...)`          |
| `path_sep_c` | 平台主路径分隔符：POSIX '/'(47)；Windows ''(92)。F-path v1：原 path.c 已内联 .sx。 | `sep` | 去模块前缀+去类型名（C层） | `path.sep(...)` |
| `path_sep`                | 当前平台路径分隔符（POSIX '/'=47；Windows ''=92；对标 Zig sep、Go filepath.Separator）。                               | `sep`                | 去模块前缀+去类型名     | `path.sep(...)`                |
| `path_join`               | 路径拼接：将 a[0..a_len-1] 与 b[0..b_len-1] 写入 out，中间按需加 '/'，不超过 out_max。返回写入长度，溢出返回 -1。                     | `join`               | 去模块前缀+去类型名     | `path.join(...)`               |
| `path_last_slash`         | 找 path[0..path_len-1] 中最后一个 '/' 的下标，不存在返回 -1。                                                         | `last_slash`         | 去模块前缀+去类型名     | `path.last_slash(...)`         |
| `path_dirname`            | 目录部分：path 的最后一个 '/' 之前（不含该 '/'）。写入 out[0..out_max-1]，返回写入长度；无 slash 则写 0 字节返回 0。                      | `dirname`            | 去模块前缀+去类型名     | `path.dirname(...)`            |
| `path_basename`           | 最后一段（basename）：path 的最后一个 '/' 之后到结尾。写入 out，返回写入长度；无 slash 则整段为 basename（对标 Go Base、Rust file_name、Zig | `basename`           | 去模块前缀+去类型名     | `path.basename(...)`           |
| `path_is_absolute`        | 是否绝对路径（POSIX '/'；Windows UNC `\\` 或 `C:\`/`C:/` 盘符根）。返回 1 是，0 否。                                      | `is_absolute`        | 去模块前缀+去类型名     | `path.is_absolute(...)`        |
| `path_is_sep`             | 是否为路径分隔符（'/' 或 ''）。                                                                                   | `is_sep`             | 去模块前缀+去类型名     | `path.is_sep(...)`             |
| `path_last_dot`           | 在 path[start..start+len) 中找最后一个 '.' 的下标（相对 start），不存在返回 -1。                                           | `last_dot`           | 去模块前缀+去类型名     | `path.last_dot(...)`           |
| `path_extension`          | —                                                                                                     | `extension`          | 去模块前缀+去类型名     | `path.extension(...)`          |
| `path_stem`               | —                                                                                                     | `stem`               | 去模块前缀+去类型名     | `path.stem(...)`               |
| `path_extension_and_stem` | —                                                                                                     | `extension_and_stem` | 去模块前缀+去类型名     | `path.extension_and_stem(...)` |
| `path_clean`              | —                                                                                                     | `clean`              | 去模块前缀+去类型名     | `path.clean(...)`              |
| `path_resolve`            | —                                                                                                     | `resolve`            | 去模块前缀+去类型名     | `path.resolve(...)`            |


### std.process

`std/process/mod.sx` · 43 APIs · `const process = import("std.process")`


| 当前名称                                 | 功能说明                                                        | 简化名称                       | 说明             | 绑定调用                                    |
| ------------------------------------ | ----------------------------------------------------------- | -------------------------- | -------------- | --------------------------------------- |
| `process_args_count_c` | std.process — 进程控制、命令行参数、环境变量、工作目录、spawn/exec/waitpid（对齐 | `args_count` | 去模块前缀+去类型名（C层） | `process.args_count(...)` |
| `process_arg_c` | extern C/平台 | `arg` | 去模块前缀+去类型名（C层） | `process.arg(...)` |
| `process_getenv_c` | extern C/平台 | `getenv` | 去模块前缀+去类型名（C层） | `process.getenv(...)` |
| `process_setenv_c` | extern C/平台 | `setenv` | 去模块前缀+去类型名（C层） | `process.setenv(...)` |
| `process_unsetenv_c` | extern C/平台 | `unsetenv` | 去模块前缀+去类型名（C层） | `process.unsetenv(...)` |
| `process_getpid_c` | extern C/平台 | `getpid` | 去模块前缀+去类型名（C层） | `process.getpid(...)` |
| `process_getppid_c` | extern C/平台 | `getppid` | 去模块前缀+去类型名（C层） | `process.getppid(...)` |
| `process_getcwd_c` | extern C/平台 | `getcwd` | 去模块前缀+去类型名（C层） | `process.getcwd(...)` |
| `process_getcwd_ptr_c` | extern C/平台 | `getcwd_ptr` | 去模块前缀+去类型名（C层） | `process.getcwd_ptr(...)` |
| `process_getcwd_cached_len_c` | extern C/平台 | `getcwd_cached_len` | 去模块前缀+去类型名（C层） | `process.getcwd_cached_len(...)` |
| `process_chdir_c` | extern C/平台 | `chdir` | 去模块前缀+去类型名（C层） | `process.chdir(...)` |
| `process_self_exe_path_c` | extern C/平台 | `self_exe_path` | 去模块前缀+去类型名（C层） | `process.self_exe_path(...)` |
| `process_self_exe_path_ptr_c` | extern C/平台 | `self_exe_path_ptr` | 去模块前缀+去类型名（C层） | `process.self_exe_path_ptr(...)` |
| `process_self_exe_path_cached_len_c` | extern C/平台                                                 | `self_exe_path_cached_len` | 去模块前缀+去类型名（C层） | `process.self_exe_path_cached_len(...)` |
| `process_spawn_c` | extern C/平台 | `spawn` | 去模块前缀+去类型名（C层） | `process.spawn(...)` |
| `process_spawn_io_c` | extern C/平台 | `spawn_io` | 去模块前缀+去类型名（C层） | `process.spawn_io(...)` |
| `process_exec_c` | extern C/平台 | `exec` | 去模块前缀+去类型名（C层） | `process.exec(...)` |
| `process_waitpid_c` | extern C/平台 | `waitpid` | 去模块前缀+去类型名（C层） | `process.waitpid(...)` |
| `process_spawn_simple_c` | extern C/平台 | `spawn_simple` | 去模块前缀+去类型名（C层） | `process.spawn_simple(...)` |
| `process_exec_simple_c` | extern C/平台 | `exec_simple` | 去模块前缀+去类型名（C层） | `process.exec_simple(...)` |
| `exit`                               | 终止进程，退出码为 code（noreturn；C 侧调用 exit(code)）。                  | `exit`                     | 已符合命名          | `process.exit(...)`                     |
| `args_count`                         | —                                                           | `args_count`               | 已符合命名          | `process.args_count(...)`               |
| `arg`                                | —                                                           | `arg`                      | 已符合命名          | `process.arg(...)`                      |
| `getenv`                             | 返回环境变量 name（NUL 结尾）的值；不存在返回 0。                              | `getenv`                   | 已符合命名          | `process.getenv(...)`                   |
| `setenv`                             | —                                                           | `setenv`                   | 已符合命名          | `process.setenv(...)`                   |
| `unsetenv`                           | 删除环境变量 name。返回 0 成功，-1 失败。                                  | `unsetenv`                 | 已符合命名          | `process.unsetenv(...)`                 |
| `getpid`                             | 返回当前进程 ID（Rust id() / Go Getpid / Zig 同）。                   | `getpid`                   | 已符合命名          | `process.getpid(...)`                   |
| `getppid`                            | 返回父进程 ID；Windows 无简单 API 返回 -1（Go Getppid / POSIX getppid）。 | `getppid`                  | 已符合命名          | `process.getppid(...)`                  |
| `getcwd`                             | —                                                           | `getcwd`                   | 已符合命名          | `process.getcwd(...)`                   |
| `getcwd_ptr`                         | —                                                           | `getcwd_ptr`               | 已符合命名          | `process.getcwd_ptr(...)`               |
| `getcwd_cached_len`                  | —                                                           | `getcwd_cached_len`        | 已符合命名          | `process.getcwd_cached_len(...)`        |
| `chdir`                              | —                                                           | `chdir`                    | 已符合命名          | `process.chdir(...)`                    |
| `self_exe_path`                      | —                                                           | `self_exe_path`            | 已符合命名          | `process.self_exe_path(...)`            |
| `self_exe_path_ptr`                  | —                                                           | `self_exe_path_ptr`        | 已符合命名          | `process.self_exe_path_ptr(...)`        |
| `self_exe_path_cached_len`           | —                                                           | `self_exe_path_cached_len` | 已符合命名          | `process.self_exe_path_cached_len(...)` |
| `spawn`                              | —                                                           | `spawn`                    | 已符合命名          | `process.spawn(...)`                    |
| `spawn_io`                           | —                                                           | `spawn_io`                 | 已符合命名          | `process.spawn_io(...)`                 |
| `exec`                               | —                                                           | `exec`                     | 已符合命名          | `process.exec(...)`                     |
| `waitpid`                            | 等待子进程 pid 结束，返回其退出码（低 8 位）；失败返回 -1。                         | `waitpid`                  | 已符合命名          | `process.waitpid(...)`                  |
| `spawn_simple`                       | 简化 spawn：argv = [program, NULL]。返回 pid 或 -1。                | `spawn_simple`             | 已符合命名          | `process.spawn_simple(...)`             |
| `exec_simple`                        | 简化 exec：argv = [program, NULL]。成功不返回；失败返回 -1。               | `exec_simple`              | 已符合命名          | `process.exec_simple(...)`              |
| `process_pipe_c` | extern C/平台 | `pipe` | 去模块前缀+去类型名（C层） | `process.pipe(...)` |
| `pipe`                               | —                                                           | `pipe`                     | 已符合命名          | `process.pipe(...)`                     |


### std.queue

`std/queue/mod.sx` · 29 APIs · `const queue = import("std.queue")`


| 当前名称                            | 功能说明                                                                | 简化名称                          | 说明             | 绑定调用                                     |
| ------------------------------- | ------------------------------------------------------------------- | ----------------------------- | -------------- | ---------------------------------------- |
| `queue_i32_new`                 | 新建空队列。                                                              | `new`                         | 去模块前缀+去类型名     | `queue.new(...)`                         |
| `queue_i32_with_capacity`       | 预分配 capacity；失败返回 -1。                                               | `with_capacity`               | 去模块前缀+去类型名     | `queue.with_capacity(...)`               |
| `queue_i32_at`                  | 逻辑下标 i 对应的物理下标。                                                     | `at`                          | 去模块前缀+去类型名     | `queue.at(...)`                          |
| `queue_i32_grow`                | 扩容至至少能再放 1 个元素；内部复制为 head=0 布局。失败返回 -1。                             | `grow`                        | 去模块前缀+去类型名     | `queue.grow(...)`                        |
| `queue_i32_push_back`           | 队尾插入。失败返回 -1。                                                       | `push_back`                   | 去模块前缀+去类型名     | `queue.push_back(...)`                   |
| `queue_i32_push_front`          | 队首插入。失败返回 -1。                                                       | `push_front`                  | 去模块前缀+去类型名     | `queue.push_front(...)`                  |
| `queue_i32_pop_back`            | 队尾弹出；空队列返回 0（调用方须保证 len>0）。                                         | `pop_back`                    | 去模块前缀+去类型名     | `queue.pop_back(...)`                    |
| `queue_i32_pop_front`           | 队首弹出；空队列返回 0。                                                       | `pop_front`                   | 去模块前缀+去类型名     | `queue.pop_front(...)`                   |
| `queue_i32_get`                 | 取第 i 个元素（0..len-1）；越界返回 0。                                          | `get`                         | 去模块前缀+去类型名     | `queue.get(...)`                         |
| `queue_i32_len`                 | 元素个数。                                                               | `len`                         | 去模块前缀+去类型名     | `queue.len(...)`                         |
| `queue_i32_is_empty`            | 是否为空。返回 1 是，0 否。                                                    | `is_empty`                    | 去模块前缀+去类型名     | `queue.is_empty(...)`                    |
| `queue_i32_clear`               | 清空，不释放内存。                                                           | `clear`                       | 去模块前缀+去类型名     | `queue.clear(...)`                       |
| `queue_i32_reserve`             | 确保容量至少 new_cap；失败返回 -1。                                             | `reserve`                     | 去模块前缀+去类型名     | `queue.reserve(...)`                     |
| `queue_i32_deinit`              | 释放；调用后不可再用。                                                         | `deinit`                      | 去模块前缀+去类型名     | `queue.deinit(...)`                      |
| `sync_queue_contention_smoke_c` | C 层双线程竞争 push 烟测（queue.sx + runtime_queue_contention.c）；0 通过，-1 失败。 | `sync_queue_contention_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `queue.sync_queue_contention_smoke(...)` |
| `sync_queue_i32_new` | 创建空 SyncQueue_i32；mutex 分配失败时 lock 为 null。 | `sync_new` | 去模块前缀+去类型名；三轮精简 | `queue.sync_new(...)` |
| `sync_queue_i32_deinit` | 销毁队列并释放 mutex。 | `sync_deinit` | 去模块前缀+去类型名；三轮精简 | `queue.sync_deinit(...)` |
| `sync_queue_i32_push_back` | 加锁队尾插入；失败 -1。 | `sync_push` | 去模块前缀+去类型名；三轮精简 | `queue.sync_push(...)` |
| `sync_queue_i32_try_pop_front` | — | `sync_try_pop` | 去模块前缀+去类型名；三轮精简 | `queue.sync_try_pop(...)` |
| `sync_queue_i32_len`            | 加锁读元素个数。                                                            | `sync_queue_len`              | 去模块前缀+去类型名     | `queue.sync_queue_len(...)`              |
| `sync_queue_i32_is_empty`       | 加锁判空：1 空，0 非空。                                                      | `sync_queue_is_empty`         | 去模块前缀+去类型名     | `queue.sync_queue_is_empty(...)`         |
| `sync_queue_contention_smoke` | 门面：C 层 sync_queue_contention_smoke_c 烟测。 | `sync_queue_contention_smoke` | 已符合命名；Tier-X 不 export | `queue.sync_queue_contention_smoke(...)` |
| `queue_u8_new`                  | 新建空 Queue_u8。                                                       | `new`                         | 去模块前缀+去类型名     | `queue.new(...)`                         |
| `queue_u8_at`                   | Queue_u8 逻辑下标转物理下标。                                                 | `at`                          | 去模块前缀+去类型名     | `queue.at(...)`                          |
| `queue_u8_grow`                 | Queue_u8 扩容；失败 -1。                                                  | `grow`                        | 去模块前缀+去类型名     | `queue.grow(...)`                        |
| `queue_u8_push_back`            | 队尾插入 u8；失败 -1。                                                      | `push_back`                   | 去模块前缀+去类型名     | `queue.push_back(...)`                   |
| `queue_u8_pop_front`            | 队首弹出 u8；空队列返回 0。                                                    | `pop_front`                   | 去模块前缀+去类型名     | `queue.pop_front(...)`                   |
| `queue_u8_len`                  | Queue_u8 元素个数。                                                      | `len`                         | 去模块前缀+去类型名     | `queue.len(...)`                         |
| `queue_u8_deinit`               | 释放 Queue_u8。                                                        | `deinit`                      | 去模块前缀+去类型名     | `queue.deinit(...)`                      |


### std.random

`std/random/mod.sx` · 18 APIs · `const random = import("std.random")`


| 当前名称                  | 功能说明                                                      | 简化名称             | 说明             | 绑定调用                         |
| --------------------- | --------------------------------------------------------- | ---------------- | -------------- | ---------------------------- |
| `random_fill_bytes_c` | std.random — CSPRNG + 可复现 PRNG（SplitMix64，STD-130） 【文件职责】 | `fill_bytes` | 去模块前缀+去类型名（C层） | `random.fill_bytes(...)` |
| `random_u32_c` | extern C/平台 | `next` | 去模块前缀+去类型名（C层） | `random.next(...)` |
| `random_u64_c` | extern C/平台 | `next` | 去模块前缀+去类型名（C层） | `random.next(...)` |
| `fill_bytes`          | —                                                         | `fill_bytes`     | 已符合命名          | `random.fill_bytes(...)`     |
| `next_u32`            | —                                                         | `next`           | 去模块前缀+去类型名     | `random.next(...)`           |
| `next_u64`            | —                                                         | `next`           | 去模块前缀+去类型名     | `random.next(...)`           |
| `range_u32`           | —                                                         | `range`          | 去模块前缀+去类型名     | `random.range(...)`          |
| `gen_bool`            | 生成均匀随机布尔，返回 0 或 1。单次 u32 取低位。对标 gen_bool。                 | `gen`            | 已符合命名          | `random.gen(...)`            |
| `u32`                 | Tier-S 公开名：密码学安全 u32（别名 next_u32）。                        | `next`           | 已符合命名          | `random.next(...)`           |
| `u64`                 | Tier-S 公开名：密码学安全 u64（别名 next_u64）。                        | `next`           | 已符合命名          | `random.next(...)`           |
| `bool`                | Tier-S 公开名：均匀随机布尔 0/1（别名 gen_bool）。                       | `flip`           | 已符合命名          | `random.flip(...)`           |
| `random_rng_smoke_c` | extern C/平台 | `rng_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `random.rng_smoke(...)` |
| `rng_next_u64` | SplitMix64 单步；更新 *r 并返回下一个 u64。 | `step` | 去模块前缀+去类型名；三轮精简 | `random.step(...)` |
| `rng_init` | 用 seed 初始化 PRNG；同 seed 产生同序列。 | `seed` | 三轮精简 | `random.seed(...)` |
| `rng_from_seed` | rng_init 别名；烟测与文档沿用 from_seed 命名。 | `seed` | 三轮精简 | `random.seed(...)` |
| `rng_fill_bytes` | 用 PRNG 字节填充 buf[0..len)。 | `fill` | 三轮精简 | `random.fill(...)` |
| `rng_range_u32` | [lo, hi] 闭区间均匀 u32；lo > hi 时返回 lo。 | `range` | 去模块前缀+去类型名；三轮精简 | `random.range(...)` |
| `rng_smoke` | C 层 PRNG 烟测；0 成功，非 0 失败。 | `rng_smoke` | 已符合命名；Tier-X 不 export | `random.rng_smoke(...)` |


### std.regex

`std/regex/mod.sx` · 12 APIs · `const regex = import("std.regex")`


| 当前名称                   | 功能说明                                                                                                 | 简化名称           | 说明             | 绑定调用                      |
| ---------------------- | ---------------------------------------------------------------------------------------------------- | -------------- | -------------- | ------------------------- |
| `regex_compile_c` | std.regex — 最小正则（字面量/字符类/量词/分组/capture，纯 C 引擎） STD-062：match 引擎 perf 优化（字面量快路径 + 首字节跳跃）生产级 bench 锚点。 | `compile` | 去模块前缀+去类型名（C层） | `regex.compile(...)` |
| `regex_match_c` | extern C/平台 | `match` | 去模块前缀+去类型名（C层） | `regex.match(...)` |
| `regex_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `regex.free(...)` |
| `regex_group_count_c` | extern C/平台 | `group_count` | 去模块前缀+去类型名（C层） | `regex.group_count(...)` |
| `regex_group_offset_c` | extern C/平台                                                                                          | `group_offset` | 去模块前缀+去类型名（C层） | `regex.group_offset(...)` |
| `regex_group_length_c` | extern C/平台                                                                                          | `group_length` | 去模块前缀+去类型名（C层） | `regex.group_length(...)` |
| `compile`              | 编译模式；失败返回 null。                                                                                      | `compile`      | 已符合命名          | `regex.compile(...)`      |
| `regex_match`          | 子串匹配；成功 0，失败 -1（对标 Rust is_match；避开关键字 match）。                                                       | `match`        | 去模块前缀+去类型名     | `regex.match(...)`        |
| `free`                 | 释放 compile 返回的句柄。                                                                                    | `free`         | 已符合命名          | `regex.free(...)`         |
| `group_count`          | 返回 capture 槽数（含 group 0 全匹配）；compile 后即可读。                                                           | `group_count`  | 已符合命名          | `regex.group_count(...)`  |
| `group_offset`         | 读上次 match 的 group 起始字节偏移；无有效 capture 时 -1。                                                           | `group_offset` | 已符合命名          | `regex.group_offset(...)` |
| `group_length`         | 读上次 match 的 group 匹配长度；无有效 capture 时 -1。                                                             | `group_length` | 已符合命名          | `regex.group_length(...)` |


### std.result

`std/result/mod.sx` · 11 APIs · `const result = import("std.result")`


| 当前名称                     | 功能说明                                              | 简化名称              | 说明         | 绑定调用                          |
| ------------------------ | ------------------------------------------------- | ----------------- | ---------- | ----------------------------- |
| `ok_i32`                 | 构造 Ok(i32)。                                       | `ok`              | 去模块前缀+去类型名 | `result.ok(...)`              |
| `err_i32`                | 构造 Err(i32)。                                      | `err`             | 去模块前缀+去类型名 | `result.err(...)`             |
| `is_ok_i32`              | 是否 Ok。                                            | `is_ok`           | 去模块前缀+去类型名 | `result.is_ok(...)`           |
| `is_err_i32`             | 是否 Err。                                           | `is_err`          | 去模块前缀+去类型名 | `result.is_err(...)`          |
| `unwrap_or_i32`          | 成功返回值，否则 default。                                 | `unwrap_or`       | 去模块前缀+去类型名 | `result.unwrap_or(...)`       |
| `result_map_i32`         | eager map（Result 侧；避免与 std.option.map_i32 重名）。    | `map`             | 去模块前缀+去类型名 | `result.map(...)`             |
| `result_and_then_i32`    | eager and_then（Result 侧）。                         | `and_then`        | 去模块前缀+去类型名 | `result.and_then(...)`        |
| `result_or_else_i32`     | eager or_else（Result 侧）。                          | `or_else`         | 去模块前缀+去类型名 | `result.or_else(...)`         |
| `result_from_error_code` | 从 std.error 风格错误码构造 Result；0=Ok(0)，非 0=Err(code)。 | `from_error_code` | 去模块前缀+去类型名 | `result.from_error_code(...)` |
| `result_from_value_i32`  | 错误码为 0 时 Ok(value)，否则 Err(err_code)。              | `from_value`      | 去模块前缀+去类型名 | `result.from_value(...)`      |
| `result_err_code`        | 提取 Result 错误码（Ok 时返回 error_ok()）。                 | `err_code`        | 去模块前缀+去类型名 | `result.err_code(...)`        |


### std.runtime

`std/runtime/mod.sx` · 9 APIs · `const runtime = import("std.runtime")`


| 当前名称                               | 功能说明                                                                                      | 简化名称                     | 说明             | 绑定调用                                  |
| ---------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------ | -------------- | ------------------------------------- |
| `runtime_panic`                    | std.runtime — 运行时初始化、panic/abort（对标 Zig @panic、Rust std::panic/process::abort、Go runtime） | `panic`                  | 去模块前缀+去类型名     | `runtime.panic(...)`                  |
| `runtime_abort`                    | extern C/平台                                                                               | `abort`                  | 去模块前缀+去类型名     | `runtime.abort(...)`                  |
| `panic`                            | —                                                                                         | `panic`                  | 已符合命名          | `runtime.panic(...)`                  |
| `abort`                            | —                                                                                         | `abort`                  | 已符合命名          | `runtime.abort(...)`                  |
| `runtime_ready`                    | —                                                                                         | `ready`                  | 去模块前缀+去类型名     | `runtime.ready(...)`                  |
| `runtime_diag_enabled`             | 运行时诊断是否启用；当前恒为 1（STD-159）。                                                                | `diag_enabled`           | 去模块前缀+去类型名     | `runtime.diag_enabled(...)`           |
| `runtime_diag_collect`             | 收集运行时诊断事件（占位；code/detail 保留扩展）。                                                           | `diag_collect`           | 去模块前缀+去类型名     | `runtime.diag_collect(...)`           |
| `runtime_crash_evidence_collect_c` | STD-028：panic 前收集崩溃证据（弱符号 shux_crash_evidence_collect_c）。                                 | `crash_evidence_collect` | 去模块前缀+去类型名（C层） | `runtime.crash_evidence_collect(...)` |
| `panic_hook_collect`               | 用户/测试可调用：登记 panic 钩子参数（has_msg/msg_val 透传 runtime）。                                       | `panic_hook_collect`     | 已符合命名          | `runtime.panic_hook_collect(...)`     |


### std.schema

`std/schema/mod.sx` · 37 APIs · `const schema = import("std.schema")`


| 当前名称                          | 功能说明                                                  | 简化名称                 | 说明             | 绑定调用                             |
| ----------------------------- | ----------------------------------------------------- | -------------------- | -------------- | -------------------------------- |
| `schema_type_string`          | 字段类型：字符串。                                             | `type_string`        | 去模块前缀+去类型名     | `schema.type_string(...)`        |
| `schema_type_i32`             | 字段类型：i32。                                             | `type`               | 去模块前缀+去类型名     | `schema.type(...)`               |
| `schema_type_bool`            | 字段类型：bool。                                            | `type`               | 去模块前缀+去类型名     | `schema.type(...)`               |
| `schema_type_f64`             | 字段类型：f64。                                             | `type`               | 去模块前缀+去类型名     | `schema.type(...)`               |
| `schema_err_ok`               | 成功。                                                   | `err_ok`             | 去模块前缀+去类型名     | `schema.err_ok(...)`             |
| `schema_err_null`             | 空指针/非法句柄。                                             | `err_null`           | 去模块前缀+去类型名     | `schema.err_null(...)`           |
| `schema_err_not_found`        | 必填字段缺失。                                               | `err_not_found`      | 去模块前缀+去类型名     | `schema.err_not_found(...)`      |
| `schema_err_type`             | 类型不匹配。                                                | `err_type`           | 去模块前缀+去类型名     | `schema.err_type(...)`           |
| `schema_err_invalid`          | 解析/格式非法。                                              | `err_invalid`        | 去模块前缀+去类型名     | `schema.err_invalid(...)`        |
| `schema_err_full`             | 字段数超限。                                                | `err_full`           | 去模块前缀+去类型名     | `schema.err_full(...)`           |
| `schema_create_c` | extern C/平台 | `create` | 去模块前缀+去类型名（C层） | `schema.create(...)` |
| `schema_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `schema.free(...)` |
| `schema_clear_c` | extern C/平台 | `clear` | 去模块前缀+去类型名（C层） | `schema.clear(...)` |
| `schema_add_field_c` | extern C/平台 | `add_field` | 去模块前缀+去类型名（C层） | `schema.add_field(...)` |
| `schema_decode_json_c` | extern C/平台 | `decode_json` | 去模块前缀+去类型名（C层） | `schema.decode_json(...)` |
| `schema_decode_csv_row_c` | extern C/平台 | `decode_csv_row` | 去模块前缀+去类型名（C层） | `schema.decode_csv_row(...)` |
| `schema_map_columns_c` | extern C/平台 | `map_columns` | 去模块前缀+去类型名（C层） | `schema.map_columns(...)` |
| `schema_get_string_c` | extern C/平台 | `get_string` | 去模块前缀+去类型名（C层） | `schema.get_string(...)` |
| `schema_get_i32_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `schema.get(...)` |
| `schema_get_bool_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `schema.get(...)` |
| `schema_get_f64_c` | extern C/平台 | `get` | 去模块前缀+去类型名（C层） | `schema.get(...)` |
| `schema_last_error_field_c` | extern C/平台 | `last_error_field` | 去模块前缀+去类型名（C层） | `schema.last_error_field(...)` |
| `schema_last_error_message_c` | extern C/平台                                           | `last_error_message` | 去模块前缀+去类型名（C层） | `schema.last_error_message(...)` |
| `schema_new`                  | 创建空 Schema。                                           | `new`                | 去模块前缀+去类型名     | `schema.new(...)`                |
| `schema_free`                 | 释放 Schema。                                            | `free`               | 去模块前缀+去类型名     | `schema.free(...)`               |
| `schema_clear`                | 清空字段定义与 decode 缓存。                                    | `clear`              | 去模块前缀+去类型名     | `schema.clear(...)`              |
| `schema_add_field`            | —                                                     | `add_field`          | 去模块前缀+去类型名     | `schema.add_field(...)`          |
| `decode_json`                 | 从 JSON 对象缓冲 typed decode；嵌套 object/array 递归展开为点分/索引键。 | `decode_json`        | 已符合命名          | `schema.decode_json(...)`        |
| `decode_csv_row`              | 从 CSV 行 decode（按 col_index 映射）。                       | `decode_csv_row`     | 已符合命名          | `schema.decode_csv_row(...)`     |
| `map_columns`                 | 从列偏移/长度数组映射（CSV 解析后或 SQLite row_col_text 联用）。         | `map_columns`        | 已符合命名          | `schema.map_columns(...)`        |
| `get_string`                  | 读取 decode 后的 string 字段。                               | `get_string`         | 已符合命名          | `schema.get_string(...)`         |
| `get_i32`                     | 读取 decode 后的 i32 字段。                                  | `get`                | 语义重命名          | `schema.get(...)`                |
| `get_bool`                    | 读取 decode 后的 bool 字段。                                 | `get`                | 已符合命名          | `schema.get(...)`                |
| `get_f64`                     | 读取 decode 后的 f64 字段。                                  | `get`                | 去模块前缀+去类型名     | `schema.get(...)`                |
| `last_error_field`            | 最近错误字段名；无错误返回 0 长度。                                   | `last_error_field`   | 已符合命名          | `schema.last_error_field(...)`   |
| `last_error_message`          | 最近错误消息。                                               | `last_error_message` | 已符合命名          | `schema.last_error_message(...)` |
| `schema_to_error_code`        | 将 schema 本地错误码映射为 std.error 风格负码（-1500 段占位）。          | `to_error_code`      | 去模块前缀+去类型名     | `schema.to_error_code(...)`      |


### std.security

`std/security/mod.sx` · 20 APIs · `const security = import("std.security")`


| 当前名称                        | 功能说明                                                | 简化名称                 | 说明                | 绑定调用                               |
| --------------------------- | --------------------------------------------------- | -------------------- | ----------------- | ---------------------------------- |
| `security_key_len_256`      | 推荐 AES-256 密钥长度（字节）。                                | `key_len`            | 去模块前缀+去类型名        | `security.key_len(...)`            |
| `security_salt_len_default` | 默认盐长度（字节）。                                          | `salt_len_default`   | 去模块前缀+去类型名        | `security.salt_len_default(...)`   |
| `security_min_secret_len`   | 最小可接受密钥/盐长度。                                        | `min_secret_len`     | 去模块前缀+去类型名        | `security.min_secret_len(...)`     |
| `security_err_ok`           | 成功。                                                 | `err_ok`             | 去模块前缀+去类型名        | `security.err_ok(...)`             |
| `security_err_invalid`      | 参数非法。                                               | `err_invalid`        | 去模块前缀+去类型名        | `security.err_invalid(...)`        |
| `security_err_random`       | 随机源失败。                                              | `err_random`         | 去模块前缀+去类型名        | `security.err_random(...)`         |
| `security_err_buffer`       | 输出缓冲不足。                                             | `err_buffer`         | 去模块前缀+去类型名        | `security.err_buffer(...)`         |
| `security_secure_zero_c` | extern C/平台 | `secure_zero` | 去模块前缀+去类型名（C层） | `security.secure_zero(...)` |
| `security_mlock_c` | extern C/平台 | `mlock` | 去模块前缀+去类型名（C层） | `security.mlock(...)` |
| `security_munlock_c` | extern C/平台 | `munlock` | 去模块前缀+去类型名（C层） | `security.munlock(...)` |
| `security_hkdf_sha256_c` | extern C/平台 | `hkdf` | 二次精简：去算法/版本/分段数后缀 | `security.hkdf(...)` |
| `ct_compare`                | 常量时间比较；与 std.crypto.mem_eq 同义，语义别名便于安全审计。           | `ct_compare`         | 已符合命名             | `security.ct_compare(...)`         |
| `random_key`                | 用 CSPRNG 填充密钥材料；len 须 >= security_min_secret_len()。 | `random_key`         | 已符合命名             | `security.random_key(...)`         |
| `random_salt`               | 用 CSPRNG 填充盐；len 须 >= security_min_secret_len()。    | `random_salt`        | 已符合命名             | `security.random_salt(...)`        |
| `hkdf_sha256`               | HKDF-SHA256 派生；okm_len 须 > 0。                       | `hkdf`               | 二次精简：去算法/版本/分段数后缀 | `security.hkdf(...)`               |
| `secure_zero`               | 安全清零缓冲（密钥释放前调用）。                                    | `secure_zero`        | 已符合命名             | `security.secure_zero(...)`        |
| `sensitive_lock`            | 尝试锁定敏感页；不支持时返回 0（静默回退）。                             | `sensitive_lock`     | 已符合命名             | `security.sensitive_lock(...)`     |
| `sensitive_unlock`          | 解除敏感页锁定。                                            | `sensitive_unlock`   | 已符合命名             | `security.sensitive_unlock(...)`   |
| `sensitive_buf_init`        | 绑定 SensitiveBuf 并可选 mlock。                          | `sensitive_buf_init` | 已符合命名             | `security.sensitive_buf_init(...)` |
| `sensitive_buf_wipe`        | 释放 SensitiveBuf：unlock + secure_zero。               | `sensitive_buf_wipe` | 已符合命名             | `security.sensitive_buf_wipe(...)` |


### std.set

`std/set/mod.sx` · 42 APIs · `const set = import("std.set")`


| 当前名称                      | 功能说明                                                                          | 简化名称                | 说明         | 绑定调用                         |
| ------------------------- | ----------------------------------------------------------------------------- | ------------------- | ---------- | ---------------------------- |
| `set_i32_slot`            | 取 key 的槽位下标（0..cap-1）；仅用于内部。                                                  | `slot`              | 去模块前缀+去类型名 | `set.slot(...)`              |
| `set_i32_find`            | 查找 key 所在槽位；若存在返回槽位下标，否则返回 -1。复用 heap 的 map_i32_i32_find_c（仅用 keys/occupied）。 | `find`              | 去模块前缀+去类型名 | `set.find(...)`              |
| `set_i32_new`             | 新建空 Set_i32（cap 0，ptr 均为 null）。                                               | `new`               | 去模块前缀+去类型名 | `set.new(...)`               |
| `set_i32_with_capacity`   | 预分配 capacity 个槽位；失败返回 -1，成功返回 0。                                              | `with_capacity`     | 去模块前缀+去类型名 | `set.with_capacity(...)`     |
| `set_i32_grow`            | 扩容为 new_cap 并 rehash 所有条目；失败返回 -1，成功返回 0。                                     | `grow`              | 去模块前缀+去类型名 | `set.grow(...)`              |
| `set_i32_reserve_one`     | 确保可再放至少 1 条；负载因子 > 0.75 时扩容。失败返回 -1。                                          | `reserve_one`       | 去模块前缀+去类型名 | `set.reserve_one(...)`       |
| `set_i32_insert`          | 插入 key；若已存在则无操作。成功返回 0，失败返回 -1。                                               | `insert`            | 去模块前缀+去类型名 | `set.insert(...)`            |
| `set_i32_contains`        | 是否包含 key。返回 1 是，0 否。                                                          | `contains_key`      | 去模块前缀+去类型名 | `set.contains_key(...)`      |
| `set_i32_remove`          | 移除 key；若存在则移除并返回 1，否则返回 0。                                                    | `remove`            | 去模块前缀+去类型名 | `set.remove(...)`            |
| `set_i32_len`             | 元素个数。                                                                         | `len`               | 去模块前缀+去类型名 | `set.len(...)`               |
| `set_i32_is_empty`        | 是否为空。返回 1 是，0 否。                                                              | `is_empty`          | 去模块前缀+去类型名 | `set.is_empty(...)`          |
| `set_i32_clear`           | 清空所有元素，不释放内存。                                                                 | `clear`             | 去模块前缀+去类型名 | `set.clear(...)`             |
| `set_i32_reserve`         | 确保容量至少 new_cap 个槽位；失败返回 -1。                                                   | `reserve`           | 去模块前缀+去类型名 | `set.reserve(...)`           |
| `set_i32_deinit`          | 释放堆内存；调用后不可再使用。                                                               | `deinit`            | 去模块前缀+去类型名 | `set.deinit(...)`            |
| `set_i32_union_into`      | 清空 dst 并写入 a∪b（去重）；成功 0，分配失败 -1。                                              | `union_into`        | 去模块前缀+去类型名 | `set.union_into(...)`        |
| `set_i32_intersect_into`  | 清空 dst 并写入 a∩b；成功 0，失败 -1。                                                    | `intersect_into`    | 去模块前缀+去类型名 | `set.intersect_into(...)`    |
| `set_i32_difference_into` | 清空 dst 并写入 a 减 b（在 a 中但不在 b 中）；成功 0，失败 -1。                                    | `difference_into`   | 去模块前缀+去类型名 | `set.difference_into(...)`   |
| `set_u64_slot`            | u64 key 槽位。                                                                   | `slot`              | 去模块前缀+去类型名 | `set.slot(...)`              |
| `set_u64_find`            | 查找 u64 key 槽位。                                                                | `find`              | 去模块前缀+去类型名 | `set.find(...)`              |
| `set_u64_new`             | 新建空 Set_u64。                                                                  | `new`               | 去模块前缀+去类型名 | `set.new(...)`               |
| `set_u64_with_capacity`   | 预分配 capacity 槽位。                                                              | `with_capacity`     | 去模块前缀+去类型名 | `set.with_capacity(...)`     |
| `set_u64_grow`            | 扩容 rehash。                                                                    | `grow`              | 去模块前缀+去类型名 | `set.grow(...)`              |
| `set_u64_reserve_one`     | 确保可再放 1 条。                                                                    | `reserve_one`       | 去模块前缀+去类型名 | `set.reserve_one(...)`       |
| `set_u64_insert`          | 插入 u64 key。                                                                   | `insert`            | 去模块前缀+去类型名 | `set.insert(...)`            |
| `set_u64_contains`        | 是否包含 u64 key。                                                                 | `contains_key`      | 去模块前缀+去类型名 | `set.contains_key(...)`      |
| `set_u64_remove`          | 移除 u64 key。                                                                   | `remove`            | 去模块前缀+去类型名 | `set.remove(...)`            |
| `set_u64_len`             | u64 集合元素个数。                                                                   | `len`               | 去模块前缀+去类型名 | `set.len(...)`               |
| `set_u64_deinit`          | 释放 Set_u64。                                                                   | `deinit`            | 去模块前缀+去类型名 | `set.deinit(...)`            |
| `set_str_key_cap`         | Set_str 单键最大字节数（含不含 NUL 的原始字节）。                                               | `str_key_cap`       | 去模块前缀+去类型名 | `set.str_key_cap(...)`       |
| `hash_bytes`              | 字符串集合键哈希；Tier-S 与 std.hash 联动锚点。                                              | `hash_bytes`        | 已符合命名      | `set.hash_bytes(...)`        |
| `set_str_new`             | 新建空 Set_str。                                                                  | `str_new`           | 去模块前缀+去类型名 | `set.str_new(...)`           |
| `set_str_with_capacity`   | 预分配 capacity 槽；失败 -1，成功 0。                                                    | `str_with_capacity` | 去模块前缀+去类型名 | `set.str_with_capacity(...)` |
| `set_str_slot`            | 计算 (ptr,len) 的起始槽位（hash mod cap）。                                             | `str_slot`          | 去模块前缀+去类型名 | `set.str_slot(...)`          |
| `set_str_key_eq`          | 槽内键与 (ptr,len) 是否相等。                                                          | `str_key_eq`        | 去模块前缀+去类型名 | `set.str_key_eq(...)`        |
| `set_str_find`            | 查找 (ptr,len)；存在返回槽位，否则 -1。                                                    | `str_find`          | 去模块前缀+去类型名 | `set.str_find(...)`          |
| `set_str_grow`            | 扩容并 rehash；失败 -1。                                                             | `str_grow`          | 去模块前缀+去类型名 | `set.str_grow(...)`          |
| `set_str_reserve_one`     | 负载 >0.75 时扩容。                                                                 | `str_reserve_one`   | 去模块前缀+去类型名 | `set.str_reserve_one(...)`   |
| `set_str_insert`          | 插入 (ptr,len)；键过长返回 -1。                                                        | `str_insert`        | 去模块前缀+去类型名 | `set.str_insert(...)`        |
| `set_str_contains`        | 是否包含 (ptr,len)。                                                               | `str_contains`      | 去模块前缀+去类型名 | `set.str_contains(...)`      |
| `set_str_remove`          | 移除 (ptr,len)；成功 1，不存在 0。                                                      | `str_remove`        | 去模块前缀+去类型名 | `set.str_remove(...)`        |
| `set_str_len`             | 元素个数。                                                                         | `str_len`           | 去模块前缀+去类型名 | `set.str_len(...)`           |
| `set_str_deinit`          | 释放堆内存。                                                                        | `str_deinit`        | 去模块前缀+去类型名 | `set.str_deinit(...)`        |


### std.simd

`std/simd/mod.sx` · 31 APIs · `const simd = import("std.simd")`


| 当前名称                    | 功能说明                                                                                                                                                       | 简化名称                  | 说明             | 绑定调用                            |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | -------------- | ------------------------------- |
| `simd_hw_available_c` | std.simd — SIMD-S2：标准向量类型 Vec4f / Vec8i（映射 f32x4 / i32x8 语义） STD-047：vec4f_shuffle / vec8i_select lane-scalar 实装；STD-061：shuffle/select 生产级 perf bench 锚点。 | `hw_available` | 去模块前缀+去类型名（C层） | `simd.hw_available(...)` |
| `simd_recommend_path_c` | extern C/平台 | `recommend_path` | 去模块前缀+去类型名（C层） | `simd.recommend_path(...)` |
| `SIMD_PATH_SCALAR`      | lane-scalar 回退路径常量（与 simd.c SIMD_PATH_SCALAR 一致）。                                                                                                          | `SIMD_PATH_SCALAR`    | 已符合命名          | `simd.SIMD_PATH_SCALAR(...)`    |
| `SIMD_PATH_HW`          | 硬件向量 emit 路径常量（与 simd.c SIMD_PATH_HW 一致）。                                                                                                                  | `SIMD_PATH_HW`        | 已符合命名          | `simd.SIMD_PATH_HW(...)`        |
| `hw_available`          | 宿主是否具备已知 SIMD 能力（1/0）。                                                                                                                                     | `hw_available`        | 已符合命名          | `simd.hw_available(...)`        |
| `recommend_simd_path`   | STD-153：推荐向量化路径（0=scalar，1=hw）。                                                                                                                            | `recommend_simd_path` | 已符合命名          | `simd.recommend_simd_path(...)` |
| `vec8i_add`             | Vec8i 逐 lane 加法（当前 lane-scalar emit；SIMD-S3 起可矢量化）。                                                                                                        | `vec8i_add`           | 已符合命名          | `simd.vec8i_add(...)`           |
| `vec8i_sub`             | Vec8i 逐 lane 减法（SIMD-S3 binop 内联：psubd/vpsubd）。                                                                                                            | `vec8i_sub`           | 已符合命名          | `simd.vec8i_sub(...)`           |
| `vec8i_mul`             | Vec8i 逐 lane 乘法（SIMD-S3 binop 内联：pmulld/vpmulld）。                                                                                                          | `vec8i_mul`           | 已符合命名          | `simd.vec8i_mul(...)`           |
| `vec8i_splat`           | Vec8i 广播单值到 8 lane。                                                                                                                                        | `vec8i_splat`         | 已符合命名          | `simd.vec8i_splat(...)`         |
| `vec4f_add`             | Vec4f 逐 lane 加法。                                                                                                                                           | `vec4f_add`           | 已符合命名          | `simd.vec4f_add(...)`           |
| `vec4f_sub`             | Vec4f 逐 lane 减法（SIMD-S3 binop 内联：mulps/subps）。                                                                                                             | `vec4f_sub`           | 已符合命名          | `simd.vec4f_sub(...)`           |
| `vec4f_mul`             | Vec4f 逐 lane 乘法（SIMD-S3 binop 内联：mulps）。                                                                                                                   | `vec4f_mul`           | 已符合命名          | `simd.vec4f_mul(...)`           |
| `vec4f_hsum`            | Vec4f 四 lane 水平求和（dot 归约 epilogue）。                                                                                                                        | `vec4f_hsum`          | 已符合命名          | `simd.vec4f_hsum(...)`          |
| `vec4f_dot`             | Vec4f 点积：sum(a[i]*b[i])。                                                                                                                                   | `vec4f_dot`           | 已符合命名          | `simd.vec4f_dot(...)`           |
| `vec4f_fma`             | —                                                                                                                                                          | `vec4f_fma`           | 已符合命名          | `simd.vec4f_fma(...)`           |
| `vec4f_madd`            | Vec4f multiply-add 别名（同 vec4f_fma）。                                                                                                                        | `vec4f_madd`          | 已符合命名          | `simd.vec4f_madd(...)`          |
| `vec4f_splat`           | Vec4f 广播单值到 4 lane。                                                                                                                                        | `vec4f_splat`         | 已符合命名          | `simd.vec4f_splat(...)`         |
| `vec4f_shuffle`         | —                                                                                                                                                          | `vec4f_shuffle`       | 已符合命名          | `simd.vec4f_shuffle(...)`       |
| `vec8i_shuffle`         | —                                                                                                                                                          | `vec8i_shuffle`       | 已符合命名          | `simd.vec8i_shuffle(...)`       |
| `vec8i_select_lane`     | 单 lane select：mask lane 非 0 取 a，否则 b。                                                                                                                      | `vec8i_select_lane`   | 已符合命名          | `simd.vec8i_select_lane(...)`   |
| `vec8i_select`          | —                                                                                                                                                          | `vec8i_select`        | 已符合命名          | `simd.vec8i_select(...)`        |
| `vec4f_select_lane`     | 单 lane f32 select：mask 非 0 取 a。                                                                                                                            | `vec4f_select_lane`   | 已符合命名          | `simd.vec4f_select_lane(...)`   |
| `vec4f_select`          | —                                                                                                                                                          | `vec4f_select`        | 已符合命名          | `simd.vec4f_select(...)`        |
| `simd_shuffle`          | —                                                                                                                                                          | `shuffle`             | 去模块前缀+去类型名     | `simd.shuffle(...)`             |
| `simd_select`           | —                                                                                                                                                          | `select`              | 去模块前缀+去类型名     | `simd.select(...)`              |
| `simd_mul`              | @shuffle / @select 语法糖：Vec4f mul/sub/dot 分派。                                                                                                               | `mul`                 | 去模块前缀+去类型名     | `simd.mul(...)`                 |
| `simd_sub`              | —                                                                                                                                                          | `sub`                 | 去模块前缀+去类型名     | `simd.sub(...)`                 |
| `simd_dot`              | —                                                                                                                                                          | `dot`                 | 去模块前缀+去类型名     | `simd.dot(...)`                 |
| `simd_fma`              | Vec4f FMA 语法糖分派。                                                                                                                                           | `fma`                 | 去模块前缀+去类型名     | `simd.fma(...)`                 |
| `simd_placeholder` | 占位：模块加载 smoke（import("std.simd") 链）。 | `placeholder` | 去模块前缀+去类型名 | `simd.placeholder(...)` |


### std.socketio

`std/socketio/mod.sx` · 241 APIs · `const socket = import("std.socketio")`


| 当前名称                                     | 功能说明                                                                                                                                                                                 | 简化名称                                 | 说明             | 绑定调用                                             |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ | -------------- | ------------------------------------------------ |
| `net_ws_connect_url_c` | std.socketio — Engine.IO / Socket.IO v0 包 + v1 polling + v2 connect + v7 ns 路由 + v11 hub sync（STD-SOCKETIO-001 · P3 可选） 【文件职责】导出 socketio.sx（F-socketio v2 纯 .sx 逻辑）；v2 connect 编排 s | `connect_url` | 去模块前缀+去类型名（C层） | `socket.connect_url(...)` |
| `net_ws_write_text_c` | extern C/平台 | `write_text` | 去模块前缀+去类型名（C层） | `socket.write_text(...)` |
| `net_ws_write_server_text_c` | extern C/平台 | `write_server_text` | 去模块前缀+去类型名（C层） | `socket.write_server_text(...)` |
| `net_ws_read_frame_c` | extern C/平台 | `read_frame` | 去模块前缀+去类型名（C层） | `socket.read_frame(...)` |
| `net_close_socket_c` | extern C/平台 | `close` | 去模块前缀+去类型名（C层） | `socket.close(...)` |
| `net_tls_close_c` | extern C/平台 | `tls_close` | 去模块前缀+去类型名（C层） | `socket.tls_close(...)` |
| `sio_eio_encode_packet_c` | extern C/平台 | `eio_encode_packet` | 去模块前缀+去类型名（C层） | `socket.eio_encode_packet(...)` |
| `sio_eio_decode_packet_c` | extern C/平台 | `eio_decode_packet` | 去模块前缀+去类型名（C层） | `socket.eio_decode_packet(...)` |
| `sio_encode_event_packet_c` | extern C/平台 | `encode_event_packet` | 去模块前缀+去类型名（C层） | `socket.encode_event_packet(...)` |
| `sio_encode_event_ns_packet_c` | extern C/平台 | `encode_event_ns_packet` | 去模块前缀+去类型名（C层） | `socket.encode_event_ns_packet(...)` |
| `sio_decode_event_packet_c` | extern C/平台 | `decode_event_packet` | 去模块前缀+去类型名（C层） | `socket.decode_event_packet(...)` |
| `sio_eio_extract_sid_c` | extern C/平台 | `eio_extract_sid` | 去模块前缀+去类型名（C层） | `socket.eio_extract_sid(...)` |
| `sio_packet_smoke_c` | extern C/平台 | `packet_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.packet_smoke(...)` |
| `sio_eio_version_c` | extern C/平台 | `eio_version` | 去模块前缀+去类型名（C层） | `socket.eio_version(...)` |
| `sio_transport_polling_c` | extern C/平台 | `transport_polling` | 去模块前缀+去类型名（C层） | `socket.transport_polling(...)` |
| `sio_transport_websocket_c` | extern C/平台 | `transport_websocket` | 去模块前缀+去类型名（C层） | `socket.transport_websocket(...)` |
| `sio_build_eio_url_c` | extern C/平台 | `build_eio_url` | 去模块前缀+去类型名（C层） | `socket.build_eio_url(...)` |
| `sio_http_extract_body_c` | extern C/平台 | `http_extract_body` | 去模块前缀+去类型名（C层） | `socket.http_extract_body(...)` |
| `sio_eio_open_has_websocket_c` | extern C/平台 | `eio_open_has_websocket` | 去模块前缀+去类型名（C层） | `socket.eio_open_has_websocket(...)` |
| `sio_polling_handshake_parse_c` | extern C/平台 | `polling_handshake_parse` | 去模块前缀+去类型名（C层） | `socket.polling_handshake_parse(...)` |
| `sio_polling_handshake_c` | extern C/平台 | `polling_handshake` | 去模块前缀+去类型名（C层） | `socket.polling_handshake(...)` |
| `sio_polling_post_packet_c` | extern C/平台 | `polling_post_packet` | 去模块前缀+去类型名（C层） | `socket.polling_post_packet(...)` |
| `sio_polling_smoke_c` | extern C/平台 | `polling_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.polling_smoke(...)` |
| `sio_sio_type_connect_c` | extern C/平台 | `type_connect` | 去模块前缀+去类型名（C层） | `socket.type_connect(...)` |
| `sio_sio_type_ack_c` | extern C/平台 | `type_ack` | 去模块前缀+去类型名（C层） | `socket.type_ack(...)` |
| `sio_encode_connect_ns_packet_c` | extern C/平台 | `encode_connect_ns_packet` | 去模块前缀+去类型名（C层） | `socket.encode_connect_ns_packet(...)` |
| `sio_encode_event_ack_packet_c` | extern C/平台 | `encode_event_ack_packet` | 去模块前缀+去类型名（C层） | `socket.encode_event_ack_packet(...)` |
| `sio_encode_ack_packet_c` | extern C/平台 | `encode_ack_packet` | 去模块前缀+去类型名（C层） | `socket.encode_ack_packet(...)` |
| `sio_parse_sio_packet_head_c` | extern C/平台 | `parse_sio_packet_head` | 去模块前缀+去类型名（C层） | `socket.parse_sio_packet_head(...)` |
| `sio_server_is_connect_ns_packet_c` | extern C/平台 | `server_is_connect_ns_packet` | 去模块前缀+去类型名（C层） | `socket.server_is_connect_ns_packet(...)` |
| `sio_ns_ack_smoke_c` | extern C/平台 | `ns_ack_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.ns_ack_smoke(...)` |
| `sio_parse_connect_ns_packet_c` | extern C/平台 | `parse_connect_ns_packet` | 去模块前缀+去类型名（C层） | `socket.parse_connect_ns_packet(...)` |
| `sio_ns_router_bytes_c` | extern C/平台 | `ns_router_bytes` | 去模块前缀+去类型名（C层） | `socket.ns_router_bytes(...)` |
| `sio_ns_router_init_c` | extern C/平台 | `ns_router_init` | 去模块前缀+去类型名（C层） | `socket.ns_router_init(...)` |
| `sio_ns_router_register_c` | extern C/平台 | `ns_router_register` | 去模块前缀+去类型名（C层） | `socket.ns_router_register(...)` |
| `sio_ns_router_lookup_c` | extern C/平台 | `ns_router_lookup` | 去模块前缀+去类型名（C层） | `socket.ns_router_lookup(...)` |
| `sio_ns_router_route_connect_c` | extern C/平台 | `ns_router_route_connect` | 去模块前缀+去类型名（C层） | `socket.ns_router_route_connect(...)` |
| `sio_ns_router_smoke_c` | extern C/平台 | `ns_router_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.ns_router_smoke(...)` |
| `sio_ns_sessions_bytes_c` | extern C/平台 | `ns_sessions_bytes` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_bytes(...)` |
| `sio_ns_sessions_init_c` | extern C/平台 | `ns_sessions_init` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_init(...)` |
| `sio_ns_sessions_sync_router_c` | extern C/平台 | `ns_sessions_sync_router` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_sync_router(...)` |
| `sio_ns_sessions_connect_c` | extern C/平台 | `ns_sessions_connect` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_connect(...)` |
| `sio_ns_sessions_disconnect_c` | extern C/平台 | `ns_sessions_disconnect` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_disconnect(...)` |
| `sio_ns_sessions_active_c` | extern C/平台 | `ns_sessions_active` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_active(...)` |
| `sio_ns_sessions_total_c` | extern C/平台 | `ns_sessions_total` | 去模块前缀+去类型名（C层） | `socket.ns_sessions_total(...)` |
| `sio_ns_sessions_smoke_c` | extern C/平台 | `ns_sessions_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.ns_sessions_smoke(...)` |
| `sio_ws_hub_bytes_c` | extern C/平台 | `ws_hub_bytes` | 去模块前缀+去类型名（C层） | `socket.ws_hub_bytes(...)` |
| `sio_ws_hub_init_c` | extern C/平台 | `ws_hub_init` | 去模块前缀+去类型名（C层） | `socket.ws_hub_init(...)` |
| `sio_ws_hub_register_c` | extern C/平台 | `ws_hub_register` | 去模块前缀+去类型名（C层） | `socket.ws_hub_register(...)` |
| `sio_ws_hub_unregister_c` | extern C/平台 | `ws_hub_unregister` | 去模块前缀+去类型名（C层） | `socket.ws_hub_unregister(...)` |
| `sio_ws_hub_find_by_sid_c` | extern C/平台 | `ws_hub_find_by_sid` | 去模块前缀+去类型名（C层） | `socket.ws_hub_find_by_sid(...)` |
| `sio_ws_hub_handle_connect_c` | extern C/平台 | `ws_hub_handle_connect` | 去模块前缀+去类型名（C层） | `socket.ws_hub_handle_connect(...)` |
| `sio_ws_hub_emit_event_ns_c` | extern C/平台 | `ws_hub_emit_event_ns` | 去模块前缀+去类型名（C层） | `socket.ws_hub_emit_event_ns(...)` |
| `sio_ws_hub_smoke_c` | extern C/平台 | `ws_hub_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.ws_hub_smoke(...)` |
| `sio_ws_hub_snapshot_bytes_c` | extern C/平台 | `ws_hub_snapshot_bytes` | 去模块前缀+去类型名（C层） | `socket.ws_hub_snapshot_bytes(...)` |
| `sio_ws_hub_export_c` | extern C/平台 | `ws_hub_export` | 去模块前缀+去类型名（C层） | `socket.ws_hub_export(...)` |
| `sio_ws_hub_import_c` | extern C/平台 | `ws_hub_import` | 去模块前缀+去类型名（C层） | `socket.ws_hub_import(...)` |
| `sio_room_registry_bytes_c` | extern C/平台 | `room_registry_bytes` | 去模块前缀+去类型名（C层） | `socket.room_registry_bytes(...)` |
| `sio_room_registry_init_c` | extern C/平台 | `room_registry_init` | 去模块前缀+去类型名（C层） | `socket.room_registry_init(...)` |
| `sio_room_register_c` | extern C/平台 | `room_register` | 去模块前缀+去类型名（C层） | `socket.room_register(...)` |
| `sio_room_join_c` | extern C/平台 | `room_join` | 去模块前缀+去类型名（C层） | `socket.room_join(...)` |
| `sio_room_leave_c` | extern C/平台 | `room_leave` | 去模块前缀+去类型名（C层） | `socket.room_leave(...)` |
| `sio_room_leave_all_c` | extern C/平台 | `room_leave_all` | 去模块前缀+去类型名（C层） | `socket.room_leave_all(...)` |
| `sio_room_member_count_c` | extern C/平台 | `room_member_count` | 去模块前缀+去类型名（C层） | `socket.room_member_count(...)` |
| `sio_room_broadcast_ns_c` | extern C/平台 | `room_broadcast_ns` | 去模块前缀+去类型名（C层） | `socket.room_broadcast_ns(...)` |
| `sio_room_smoke_c` | extern C/平台 | `room_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.room_smoke(...)` |
| `sio_ws_hub_rebind_c` | extern C/平台 | `ws_hub_rebind` | 去模块前缀+去类型名（C层） | `socket.ws_hub_rebind(...)` |
| `sio_room_registry_snapshot_bytes_c` | extern C/平台 | `room_registry_snapshot_bytes` | 去模块前缀+去类型名（C层） | `socket.room_registry_snapshot_bytes(...)` |
| `sio_room_registry_export_c` | extern C/平台 | `room_registry_export` | 去模块前缀+去类型名（C层） | `socket.room_registry_export(...)` |
| `sio_room_registry_import_c` | extern C/平台 | `room_registry_import` | 去模块前缀+去类型名（C层） | `socket.room_registry_import(...)` |
| `sio_hub_sync_smoke_c` | extern C/平台 | `hub_sync_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.hub_sync_smoke(...)` |
| `sio_ws_hub_register_or_rebind_c` | extern C/平台 | `ws_hub_register_or_rebind` | 去模块前缀+去类型名（C层） | `socket.ws_hub_register_or_rebind(...)` |
| `sio_session_bundle_bytes_c` | extern C/平台 | `session_bundle_bytes` | 去模块前缀+去类型名（C层） | `socket.session_bundle_bytes(...)` |
| `sio_session_bundle_export_c` | extern C/平台 | `session_bundle_export` | 去模块前缀+去类型名（C层） | `socket.session_bundle_export(...)` |
| `sio_session_bundle_import_c` | extern C/平台 | `session_bundle_import` | 去模块前缀+去类型名（C层） | `socket.session_bundle_import(...)` |
| `sio_session_sync_smoke_c` | extern C/平台 | `session_sync_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.session_sync_smoke(...)` |
| `sio_ws_hub_append_from_c` | extern C/平台 | `ws_hub_append_from` | 去模块前缀+去类型名（C层） | `socket.ws_hub_append_from(...)` |
| `sio_room_registry_merge_offset_c` | extern C/平台 | `room_registry_merge_offset` | 去模块前缀+去类型名（C层） | `socket.room_registry_merge_offset(...)` |
| `sio_cluster_sync_c` | extern C/平台 | `cluster_sync` | 去模块前缀+去类型名（C层） | `socket.cluster_sync(...)` |
| `sio_cluster_sync_smoke_c` | extern C/平台 | `cluster_sync_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.cluster_sync_smoke(...)` |
| `sio_cluster_adapter_bytes_c` | extern C/平台 | `cluster_adapter_bytes` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_bytes(...)` |
| `sio_cluster_adapter_init_c` | extern C/平台 | `cluster_adapter_init` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_init(...)` |
| `sio_cluster_adapter_publish_ns_c` | extern C/平台 | `cluster_adapter_publish_ns` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_publish_ns(...)` |
| `sio_cluster_adapter_drain_apply_c` | extern C/平台 | `cluster_adapter_drain_apply` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_drain_apply(...)` |
| `sio_cluster_adapter_smoke_c` | extern C/平台 | `cluster_adapter_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.cluster_adapter_smoke(...)` |
| `sio_cluster_adapter_snapshot_bytes_c` | extern C/平台 | `cluster_adapter_snapshot_bytes` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_snapshot_bytes(...)` |
| `sio_cluster_adapter_export_c` | extern C/平台 | `cluster_adapter_export` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_export(...)` |
| `sio_cluster_adapter_import_merge_c` | extern C/平台 | `cluster_adapter_import_merge` | 去模块前缀+去类型名（C层） | `socket.cluster_adapter_import_merge(...)` |
| `sio_cluster_ring_sync_smoke_c` | extern C/平台 | `cluster_ring_sync_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.cluster_ring_sync_smoke(...)` |
| `sio_p3_complete_smoke_c` | extern C/平台 | `p3_complete_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.p3_complete_smoke(...)` |
| `sio_server_build_connect_ns_ack_c` | extern C/平台 | `server_build_connect_ns_ack` | 去模块前缀+去类型名（C层） | `socket.server_build_connect_ns_ack(...)` |
| `sio_http_to_ws_base_c` | extern C/平台 | `http_to_ws_base` | 去模块前缀+去类型名（C层） | `socket.http_to_ws_base(...)` |
| `sio_build_ws_connect_url_c` | extern C/平台 | `build_ws_connect_url` | 去模块前缀+去类型名（C层） | `socket.build_ws_connect_url(...)` |
| `sio_eio_ws_upgrade_c` | extern C/平台 | `eio_ws_upgrade` | 去模块前缀+去类型名（C层） | `socket.eio_ws_upgrade(...)` |
| `sio_encode_connect_packet_c` | extern C/平台 | `encode_connect_packet` | 去模块前缀+去类型名（C层） | `socket.encode_connect_packet(...)` |
| `sio_reconnect_delay_ms_c` | extern C/平台 | `reconnect_delay_ms` | 去模块前缀+去类型名（C层） | `socket.reconnect_delay_ms(...)` |
| `sio_connect_smoke_c` | extern C/平台 | `connect_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.connect_smoke(...)` |
| `sio_node_interop_smoke_c` | extern C/平台 | `node_interop_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.node_interop_smoke(...)` |
| `sio_server_build_open_packet_c` | extern C/平台 | `server_build_open_packet` | 去模块前缀+去类型名（C层） | `socket.server_build_open_packet(...)` |
| `sio_server_build_http_open_response_c` | extern C/平台 | `server_build_http_open_response` | 去模块前缀+去类型名（C层） | `socket.server_build_http_open_response(...)` |
| `sio_server_is_polling_handshake_c` | extern C/平台 | `server_is_polling_handshake` | 去模块前缀+去类型名（C层） | `socket.server_is_polling_handshake(...)` |
| `sio_server_is_connect_packet_c` | extern C/平台 | `server_is_connect_packet` | 去模块前缀+去类型名（C层） | `socket.server_is_connect_packet(...)` |
| `sio_server_smoke_c` | extern C/平台 | `server_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.server_smoke(...)` |
| `sio_server_emit_event_c` | extern C/平台 | `server_emit_event` | 去模块前缀+去类型名（C层） | `socket.server_emit_event(...)` |
| `sio_server_build_http_event_response_c` | extern C/平台 | `server_build_http_event_response` | 去模块前缀+去类型名（C层） | `socket.server_build_http_event_response(...)` |
| `sio_server_emit_smoke_c` | extern C/平台 | `server_emit_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `socket.server_emit_smoke(...)` |
| `eio_type_open`                          | Engine.IO open。                                                                                                                                                                      | `eio_type_open`                      | 已符合命名          | `socket.eio_type_open(...)`                      |
| `eio_type_close`                         | Engine.IO close。                                                                                                                                                                     | `eio_type_close`                     | 已符合命名          | `socket.eio_type_close(...)`                     |
| `eio_type_ping`                          | Engine.IO ping。                                                                                                                                                                      | `eio_type_ping`                      | 已符合命名          | `socket.eio_type_ping(...)`                      |
| `eio_type_pong`                          | Engine.IO pong。                                                                                                                                                                      | `eio_type_pong`                      | 已符合命名          | `socket.eio_type_pong(...)`                      |
| `eio_type_message`                       | Engine.IO message（Socket.IO 载荷）。                                                                                                                                                     | `eio_type_message`                   | 已符合命名          | `socket.eio_type_message(...)`                   |
| `eio_type_upgrade`                       | Engine.IO upgrade。                                                                                                                                                                   | `eio_type_upgrade`                   | 已符合命名          | `socket.eio_type_upgrade(...)`                   |
| `eio_type_noop`                          | Engine.IO noop。                                                                                                                                                                      | `eio_type_noop`                      | 已符合命名          | `socket.eio_type_noop(...)`                      |
| `sio_type_event`                         | Socket.IO EVENT。                                                                                                                                                                     | `type_event`                         | 去模块前缀+去类型名     | `socket.type_event(...)`                         |
| `sio_type_ack`                           | Socket.IO ACK（带 packet id 应答）。                                                                                                                                                       | `type_ack`                           | 去模块前缀+去类型名     | `socket.type_ack(...)`                           |
| `eio_version`                            | Engine.IO 协议版本（4）。                                                                                                                                                                   | `eio_version`                        | 已符合命名          | `socket.eio_version(...)`                        |
| `transport_polling`                      | 传输常量：HTTP long-polling。                                                                                                                                                              | `transport_polling`                  | 已符合命名          | `socket.transport_polling(...)`                  |
| `transport_websocket`                    | 传输常量：WebSocket upgrade。                                                                                                                                                              | `transport_websocket`                | 已符合命名          | `socket.transport_websocket(...)`                |
| `build_eio_url`                          | 构建 Engine.IO URL（polling 或 websocket；sid 可选）。                                                                                                                                        | `build_eio_url`                      | 已符合命名          | `socket.build_eio_url(...)`                      |
| `http_extract_body`                      | 从 HTTP/1.x 响应提取 body。                                                                                                                                                                | `http_extract_body`                  | 已符合命名          | `socket.http_extract_body(...)`                  |
| `open_has_websocket`                     | open JSON 是否声明 websocket upgrade。                                                                                                                                                    | `open_has_websocket`                 | 已符合命名          | `socket.open_has_websocket(...)`                 |
| `polling_handshake_parse`                | 解析 polling 握手 HTTP 响应；返回 sid 长度。                                                                                                                                                     | `polling_handshake_parse`            | 已符合命名          | `socket.polling_handshake_parse(...)`            |
| `polling_handshake`                      | Engine.IO polling 握手（HTTP GET）；需链入 std.http。                                                                                                                                         | `polling_handshake`                  | 已符合命名          | `socket.polling_handshake(...)`                  |
| `polling_post_packet`                    | 经 polling POST 发送 EIO 包；返回 HTTP 响应字节数。                                                                                                                                               | `polling_post_packet`                | 已符合命名          | `socket.polling_post_packet(...)`                |
| `polling_smoke` | polling 传输层烟测（URL + canned HTTP；不依赖 live server）。 | `polling_smoke` | 已符合命名；Tier-X 不 export | `socket.polling_smoke(...)` |
| `sio_type_connect`                       | Socket.IO CONNECT 类型常量（0）。                                                                                                                                                           | `type_connect`                       | 去模块前缀+去类型名     | `socket.type_connect(...)`                       |
| `http_to_ws_base`                        | http(s):// base 转为 ws(s):// 前缀。                                                                                                                                                      | `http_to_ws_base`                    | 已符合命名          | `socket.http_to_ws_base(...)`                    |
| `build_ws_connect_url`                   | 构建 WebSocket 升级 URL（须已有 sid）。                                                                                                                                                        | `build_ws_connect_url`               | 已符合命名          | `socket.build_ws_connect_url(...)`               |
| `encode_connect_packet`                  | 编码 Socket.IO CONNECT 包（默认 namespace `40`）。                                                                                                                                           | `encode_connect_packet`              | 已符合命名          | `socket.encode_connect_packet(...)`              |
| `encode_connect_ns_packet`               | 编码指定 namespace 的 CONNECT 包（例 `/chat` → `40/chat,`）。                                                                                                                                  | `encode_connect_ns_packet`           | 已符合命名          | `socket.encode_connect_ns_packet(...)`           |
| `reconnect_delay_ms`                     | 重连退避毫秒（线性递增，带上限）。                                                                                                                                                                    | `reconnect_delay_ms`                 | 已符合命名          | `socket.reconnect_delay_ms(...)`                 |
| `connect_smoke` | connect v2 烟测（无 live server）。 | `connect_smoke` | 已符合命名；Tier-X 不 export | `socket.connect_smoke(...)` |
| `client_init`                            | 初始化客户端状态。max_reconnect < 0 表示不限次数。                                                                                                                                                   | `client_init`                        | 已符合命名          | `socket.client_init(...)`                        |
| `connect_handshake`                      | polling 握手；成功返回 sid 长度并写 c.has_websocket。                                                                                                                                            | `connect_handshake`                  | 已符合命名          | `socket.connect_handshake(...)`                  |
| `ws_finish_eio_upgrade`                  | 完成 polling→WebSocket Engine.IO 升级 probe（`2probe`/`3probe`/`5`）。                                                                                                                      | `ws_finish_eio_upgrade`              | 已符合命名          | `socket.ws_finish_eio_upgrade(...)`              |
| `connect_ws`                             | WebSocket 升级连接（须先 connect_handshake）；失败 fd=-1。                                                                                                                                       | `connect`                            | 语义重命名          | `socket.connect(...)`                            |
| `send_connect_packet`                    | 经 WebSocket 发送 Socket.IO CONNECT（`40`）。                                                                                                                                              | `send_connect_packet`                | 已符合命名          | `socket.send_connect_packet(...)`                |
| `send_connect_ns_packet`                 | 经 WebSocket 发送指定 namespace 的 CONNECT 包。                                                                                                                                              | `send_connect_ns_packet`             | 已符合命名          | `socket.send_connect_ns_packet(...)`             |
| `connect_ws_ns`                          | WebSocket 升级并按 namespace 发送 CONNECT（须先 polling 握手拿到 sid）。                                                                                                                            | `connect_ns`                         | 语义重命名          | `socket.connect_ns(...)`                         |
| `ws_read_text`                           | 读取 WebSocket TEXT 帧 payload（Engine.IO / Socket.IO 文本帧）。                                                                                                                              | `ws_read_text`                       | 已符合命名          | `socket.ws_read_text(...)`                       |
| `ws_close_stream`                        | 关闭 WebSocket 会话（TLS + TCP）。                                                                                                                                                          | `ws_close_stream`                    | 已符合命名          | `socket.ws_close_stream(...)`                    |
| `client_ws_ns_event_roundtrip`           | —                                                                                                                                                                                    | `client_ws_ns_event_roundtrip`       | 已符合命名          | `socket.client_ws_ns_event_roundtrip(...)`       |
| `build_ws_eio_url_fresh`                 | 构建无 sid 的 WebSocket EIO URL（transport=websocket）。                                                                                                                                    | `build_ws_eio_url_fresh`             | 已符合命名          | `socket.build_ws_eio_url_fresh(...)`             |
| `connect_ws_fresh`                       | WebSocket 直连（无 polling sid）；读并丢弃 open 首帧后返回 stream。                                                                                                                                  | `connect_ws_fresh`                   | 已符合命名          | `socket.connect_ws_fresh(...)`                   |
| `connect_ws_fresh_ns`                    | WebSocket 直连 + namespace CONNECT（读并丢弃 CONNECT ACK）。                                                                                                                                  | `connect_ws_fresh_ns`                | 已符合命名          | `socket.connect_ws_fresh_ns(...)`                |
| `client_ws_fresh_ns_event_roundtrip`     | WS 直连 + namespace CONNECT → emit → read（npm WS live）。                                                                                                                                | `client_ws_fresh_ns_event_roundtrip` | 已符合命名          | `socket.client_ws_fresh_ns_event_roundtrip(...)` |
| `client_ws_fresh_ns_mw_roundtrip`        | WS 直连 + ns CONNECT → auth → mw_ping → read mw_pong（npm mw live）。                                                                                                                     | `client_ws_fresh_ns_mw_roundtrip`    | 已符合命名          | `socket.client_ws_fresh_ns_mw_roundtrip(...)`    |
| `connect`                                | —                                                                                                                                                                                    | `connect`                            | 已符合命名          | `socket.connect(...)`                            |
| `connect_ns`                             | —                                                                                                                                                                                    | `connect_ns`                         | 已符合命名          | `socket.connect_ns(...)`                         |
| `reconnect_delay`                        | 取下一次重连退避毫秒并递增 reconnect_attempt。                                                                                                                                                     | `reconnect_delay`                    | 已符合命名          | `socket.reconnect_delay(...)`                    |
| `can_reconnect`                          | 是否还可重连（max_reconnect < 0 为无限）。                                                                                                                                                       | `can_reconnect`                      | 已符合命名          | `socket.can_reconnect(...)`                      |
| `reconnect_reset`                        | 连接成功后重置重连计数。                                                                                                                                                                         | `reconnect_reset`                    | 已符合命名          | `socket.reconnect_reset(...)`                    |
| `reconnect_once`                         | —                                                                                                                                                                                    | `reconnect_once`                     | 已符合命名          | `socket.reconnect_once(...)`                     |
| `emit_event_ws`                          | 经 WebSocket 发送 Socket.IO EVENT（Engine.IO message 帧）。                                                                                                                                 | `emit_event_ws`                      | 已符合命名          | `socket.emit_event_ws(...)`                      |
| `emit_event_ws_ns`                       | 经 WebSocket 发送指定 namespace 的 EVENT（例 `/chat` → `42/chat,[...]`）。                                                                                                                     | `emit_event_ws_ns`                   | 已符合命名          | `socket.emit_event_ws_ns(...)`                   |
| `emit_event_ack_ws`                      | 经 WebSocket 发送带 packet id 的 EVENT（ack_id<0 时等同 emit_event_ws）。                                                                                                                       | `emit_event_ack_ws`                  | 已符合命名          | `socket.emit_event_ack_ws(...)`                  |
| `emit_ack_ws`                            | 经 WebSocket 发送 ACK 包（type=3 + id + JSON 数组）。                                                                                                                                         | `emit_ack_ws`                        | 已符合命名          | `socket.emit_ack_ws(...)`                        |
| `node_golden_smoke` | Node socket.io-client v4 金样烟测（无 live Node）。 | `node_golden_smoke` | 已符合命名；Tier-X 不 export | `socket.node_golden_smoke(...)` |
| `server_build_open_packet`               | 构建 Engine.IO open 包（服务端；0 + JSON）。                                                                                                                                                   | `server_build_open_packet`           | 已符合命名          | `socket.server_build_open_packet(...)`           |
| `server_build_http_open_response`        | 构建 polling 握手 HTTP 200 响应（body 为 open 包）。                                                                                                                                            | `server_build_http_open_response`    | 已符合命名          | `socket.server_build_http_open_response(...)`    |
| `server_is_polling_handshake`            | 检测 path/query 是否为 polling 初始握手（无 sid）。                                                                                                                                               | `server_is_polling_handshake`        | 已符合命名          | `socket.server_is_polling_handshake(...)`        |
| `server_is_connect_packet`               | 检测客户端 CONNECT 包（`40` 或 namespace）。                                                                                                                                                   | `server_is_connect_packet`           | 已符合命名          | `socket.server_is_connect_packet(...)`           |
| `server_is_connect_ns_packet`            | 检测 CONNECT 是否匹配指定 namespace。                                                                                                                                                         | `server_is_connect_ns_packet`        | 已符合命名          | `socket.server_is_connect_ns_packet(...)`        |
| `server_smoke` | server v2 烟测。 | `server_smoke` | 已符合命名；Tier-X 不 export | `socket.server_smoke(...)` |
| `server_emit_event`                      | 服务端推送 Socket.IO EVENT（`42["event","data"]`）。                                                                                                                                         | `server_emit_event`                  | 已符合命名          | `socket.server_emit_event(...)`                  |
| `server_build_http_event_response`       | 构建 polling 推送 EVENT 的 HTTP 200 响应。                                                                                                                                                   | `server_build_http_event_response`   | 已符合命名          | `socket.server_build_http_event_response(...)`   |
| `server_emit_smoke` | server emit 烟测。 | `server_emit_smoke` | 已符合命名；Tier-X 不 export | `socket.server_emit_smoke(...)` |
| `server_emit_event_ws`                   | 经已握手的 WebSocket 服务端连接推送 EVENT（`42[...]`）。                                                                                                                                            | `server_emit_event_ws`               | 已符合命名          | `socket.server_emit_event_ws(...)`               |
| `server_emit_event_ws_ns`                | 经 WebSocket 服务端连接推送 namespace EVENT（`42/ns,[...]`）。                                                                                                                                  | `server_emit_event_ws_ns`            | 已符合命名          | `socket.server_emit_event_ws_ns(...)`            |
| `server_build_connect_ns_ack`            | 构建 namespace CONNECT ACK（`40/chat,{"sid":"..."}`）。                                                                                                                                   | `server_build_connect_ns_ack`        | 已符合命名          | `socket.server_build_connect_ns_ack(...)`        |
| `encode_event_ack_packet`                | 编码带 packet id 的 EVENT 并封装为 EIO message 帧。                                                                                                                                            | `encode_event_ack_packet`            | 已符合命名          | `socket.encode_event_ack_packet(...)`            |
| `encode_ack_packet`                      | 编码 ACK 包（453["data"] 形式）。                                                                                                                                                            | `encode_ack_packet`                  | 已符合命名          | `socket.encode_ack_packet(...)`                  |
| `parse_sio_packet_head`                  | 解析 Socket.IO 包 type / 可选 id / payload 起始偏移（相对 SIO payload）。                                                                                                                          | `parse_sio_packet_head`              | 已符合命名          | `socket.parse_sio_packet_head(...)`              |
| `ns_ack_smoke` | namespace / ACK / 带 id EVENT 烟测。 | `ns_ack_smoke` | 已符合命名；Tier-X 不 export | `socket.ns_ack_smoke(...)` |
| `parse_connect_ns`                       | 从 CONNECT EIO 帧解析 namespace；成功返回路径字节数。                                                                                                                                               | `parse_connect_ns`                   | 已符合命名          | `socket.parse_connect_ns(...)`                   |
| `ns_router_bytes`                        | 路由表 storage 字节数（与 SioNsRouter 一致）。                                                                                                                                                   | `ns_router_bytes`                    | 已符合命名          | `socket.ns_router_bytes(...)`                    |
| `ns_router_init`                         | 初始化多 namespace 路由表。                                                                                                                                                                  | `ns_router_init`                     | 已符合命名          | `socket.ns_router_init(...)`                     |
| `ns_router_register`                     | 注册 namespace → slot_id。                                                                                                                                                              | `ns_router_register`                 | 已符合命名          | `socket.ns_router_register(...)`                 |
| `ns_router_lookup`                       | 按 namespace 查 slot_id。                                                                                                                                                               | `ns_router_lookup`                   | 已符合命名          | `socket.ns_router_lookup(...)`                   |
| `ns_router_route_connect`                | CONNECT 包解析 namespace 并查路由 slot。                                                                                                                                                     | `ns_router_route_connect`            | 已符合命名          | `socket.ns_router_route_connect(...)`            |
| `ns_router_smoke` | 多 namespace 路由烟测。 | `ns_router_smoke` | 已符合命名；Tier-X 不 export | `socket.ns_router_smoke(...)` |
| `ns_sessions_bytes`                      | 并发会话表 storage 字节数（与 SioNsSessions 一致）。                                                                                                                                               | `ns_sessions_bytes`                  | 已符合命名          | `socket.ns_sessions_bytes(...)`                  |
| `ns_sessions_init`                       | 初始化并发会话表。                                                                                                                                                                            | `ns_sessions_init`                   | 已符合命名          | `socket.ns_sessions_init(...)`                   |
| `ns_sessions_sync_router`                | 从路由表同步 slot 列表。                                                                                                                                                                      | `ns_sessions_sync_router`            | 已符合命名          | `socket.ns_sessions_sync_router(...)`            |
| `ns_sessions_connect`                    | CONNECT 包路由并递增 active。                                                                                                                                                               | `ns_sessions_connect`                | 已符合命名          | `socket.ns_sessions_connect(...)`                |
| `ns_sessions_disconnect`                 | 递减 slot active 计数。                                                                                                                                                                   | `ns_sessions_disconnect`             | 已符合命名          | `socket.ns_sessions_disconnect(...)`             |
| `ns_sessions_active`                     | 查询 slot active 数。                                                                                                                                                                    | `ns_sessions_active`                 | 已符合命名          | `socket.ns_sessions_active(...)`                 |
| `ns_sessions_total`                      | 全部 namespace active 总数。                                                                                                                                                              | `ns_sessions_total`                  | 已符合命名          | `socket.ns_sessions_total(...)`                  |
| `ns_sessions_smoke` | 多 namespace 并发会话烟测。 | `ns_sessions_smoke` | 已符合命名；Tier-X 不 export | `socket.ns_sessions_smoke(...)` |
| `ws_hub_bytes`                           | WS hub storage 字节数（与 C sio_ws_hub_t 一致）。                                                                                                                                             | `ws_hub_bytes`                       | 已符合命名          | `socket.ws_hub_bytes(...)`                       |
| `ws_hub_init`                            | 初始化 WS hub。                                                                                                                                                                          | `ws_hub_init`                        | 已符合命名          | `socket.ws_hub_init(...)`                        |
| `ws_hub_register`                        | 注册 WS 连接并持久化 sid；返回槽位下标。                                                                                                                                                             | `ws_hub_register`                    | 已符合命名          | `socket.ws_hub_register(...)`                    |
| `ws_hub_unregister`                      | 注销 hub 槽位。                                                                                                                                                                           | `ws_hub_unregister`                  | 已符合命名          | `socket.ws_hub_unregister(...)`                  |
| `ws_hub_find_by_sid`                     | 按 sid 查 hub 槽位。                                                                                                                                                                      | `ws_hub_find_by_sid`                 | 已符合命名          | `socket.ws_hub_find_by_sid(...)`                 |
| `ws_hub_handle_connect`                  | CONNECT 路由 + sessions 计数 + 绑定 hub.slot_id。                                                                                                                                           | `ws_hub_handle_connect`              | 已符合命名          | `socket.ws_hub_handle_connect(...)`              |
| `ws_hub_emit_to_slot`                    | 向 hub 内匹配 slot 的全部连接推送 namespace EVENT；返回成功写入数。                                                                                                                                      | `ws_hub_emit_to_slot`                | 已符合命名          | `socket.ws_hub_emit_to_slot(...)`                |
| `ws_hub_smoke` | WS hub + CONNECT ACK 烟测。 | `ws_hub_smoke` | 已符合命名；Tier-X 不 export | `socket.ws_hub_smoke(...)` |
| `ws_hub_snapshot_bytes`                  | hub 快照字节数（二进制 SIOH 格式）。                                                                                                                                                              | `ws_hub_snapshot_bytes`              | 已符合命名          | `socket.ws_hub_snapshot_bytes(...)`              |
| `ws_hub_export`                          | 导出 hub 会话快照（sid/slot_id；调用方可写 std.fs 持久化）。                                                                                                                                           | `ws_hub_export`                      | 已符合命名          | `socket.ws_hub_export(...)`                      |
| `ws_hub_import`                          | 从快照恢复 hub 元数据（fd=-1，须 re-register 绑定 fd）。                                                                                                                                            | `ws_hub_import`                      | 已符合命名          | `socket.ws_hub_import(...)`                      |
| `room_registry_bytes`                    | room 注册表字节数。                                                                                                                                                                         | `room_registry_bytes`                | 已符合命名          | `socket.room_registry_bytes(...)`                |
| `room_registry_init`                     | 初始化 room 注册表。                                                                                                                                                                        | `room_registry_init`                 | 已符合命名          | `socket.room_registry_init(...)`                 |
| `room_register`                          | 注册 room 名称与 id。                                                                                                                                                                      | `room_register`                      | 已符合命名          | `socket.room_register(...)`                      |
| `room_join`                              | hub 连接加入 room。                                                                                                                                                                       | `room_join`                          | 已符合命名          | `socket.room_join(...)`                          |
| `room_leave`                             | hub 连接离开 room。                                                                                                                                                                       | `room_leave`                         | 已符合命名          | `socket.room_leave(...)`                         |
| `room_leave_all`                         | 从全部 room 移除 hub 连接（unregister 前）。                                                                                                                                                    | `room_leave_all`                     | 已符合命名          | `socket.room_leave_all(...)`                     |
| `room_member_count`                      | 查询 room 成员数。                                                                                                                                                                         | `room_member_count`                  | 已符合命名          | `socket.room_member_count(...)`                  |
| `room_broadcast_ns`                      | 向 room 内全部成员广播 namespace EVENT。                                                                                                                                                      | `room_broadcast_ns`                  | 已符合命名          | `socket.room_broadcast_ns(...)`                  |
| `room_smoke` | room + hub 快照烟测。 | `room_smoke` | 已符合命名；Tier-X 不 export | `socket.room_smoke(...)` |
| `ws_hub_rebind`                          | import 后重绑 hub 槽位 fd/tls（跨进程恢复 WS）。                                                                                                                                                  | `ws_hub_rebind`                      | 已符合命名          | `socket.ws_hub_rebind(...)`                      |
| `room_registry_snapshot_bytes`           | room 快照字节数（二进制 SIOR 格式）。                                                                                                                                                             | `room_registry_snapshot_bytes`       | 已符合命名          | `socket.room_registry_snapshot_bytes(...)`       |
| `room_registry_export`                   | 导出 room 注册表快照（可与 hub 快照一并写 std.fs）。                                                                                                                                                  | `room_registry_export`               | 已符合命名          | `socket.room_registry_export(...)`               |
| `room_registry_import`                   | 从快照恢复 room 注册表。                                                                                                                                                                      | `room_registry_import`               | 已符合命名          | `socket.room_registry_import(...)`               |
| `hub_sync_smoke` | hub + room 跨进程同步烟测。 | `hub_sync_smoke` | 已符合命名；Tier-X 不 export | `socket.hub_sync_smoke(...)` |
| `ws_hub_register_or_rebind`              | 注册或按 sid 重绑（import 后重连保持 room 成员 slot）。                                                                                                                                              | `ws_hub_register_or_rebind`          | 已符合命名          | `socket.ws_hub_register_or_rebind(...)`          |
| `session_bundle_bytes`                   | session 一体快照字节数（SIOS：hub + room）。                                                                                                                                                    | `session_bundle_bytes`               | 已符合命名          | `socket.session_bundle_bytes(...)`               |
| `session_bundle_export`                  | 导出 hub + room 一体快照。                                                                                                                                                                  | `session_bundle_export`              | 已符合命名          | `socket.session_bundle_export(...)`              |
| `session_bundle_import`                  | 从一体快照恢复 hub + room。                                                                                                                                                                  | `session_bundle_import`              | 已符合命名          | `socket.session_bundle_import(...)`              |
| `session_sync_smoke` | session 一体快照 + register_or_rebind 烟测。 | `session_sync_smoke` | 已符合命名；Tier-X 不 export | `socket.session_sync_smoke(...)` |
| `ws_hub_append_from`                     | 将 src hub 槽追加到 dst（集群节点合并）。                                                                                                                                                          | `ws_hub_append_from`                 | 已符合命名          | `socket.ws_hub_append_from(...)`                 |
| `room_registry_merge_offset`             | 合并 src room 表到 dst（conn_idx 加 offset）。                                                                                                                                               | `room_registry_merge_offset`         | 已符合命名          | `socket.room_registry_merge_offset(...)`         |
| `cluster_sync`                           | 集群合并两节点 session bundle。                                                                                                                                                              | `cluster_sync`                       | 已符合命名          | `socket.cluster_sync(...)`                       |
| `cluster_sync_smoke` | 集群 session 合并烟测。 | `cluster_sync_smoke` | 已符合命名；Tier-X 不 export | `socket.cluster_sync_smoke(...)` |
| `cluster_adapter_bytes`                  | cluster adapter 字节数。                                                                                                                                                                 | `cluster_adapter_bytes`              | 已符合命名          | `socket.cluster_adapter_bytes(...)`              |
| `cluster_adapter_init`                   | 初始化内存 cluster adapter（node_id 标识本节点）。                                                                                                                                                | `cluster_adapter_init`               | 已符合命名          | `socket.cluster_adapter_init(...)`               |
| `cluster_adapter_publish_ns`             | 发布跨节点 room EVENT（对标 Redis adapter publish）。                                                                                                                                          | `cluster_adapter_publish_ns`         | 已符合命名          | `socket.cluster_adapter_publish_ns(...)`         |
| `cluster_adapter_drain_apply`            | 消费 adapter 队列并本地 room 广播。                                                                                                                                                            | `cluster_adapter_drain_apply`        | 已符合命名          | `socket.cluster_adapter_drain_apply(...)`        |
| `cluster_adapter_smoke` | cluster adapter 烟测。 | `cluster_adapter_smoke` | 已符合命名；Tier-X 不 export | `socket.cluster_adapter_smoke(...)` |
| `cluster_adapter_snapshot_bytes`         | adapter 快照字节数（SIOA 格式）。                                                                                                                                                              | `cluster_adapter_snapshot_bytes`     | 已符合命名          | `socket.cluster_adapter_snapshot_bytes(...)`     |
| `cluster_adapter_export`                 | 导出 adapter 快照（跨节点 ring 同步；可写 std.fs）。                                                                                                                                                | `cluster_adapter_export`             | 已符合命名          | `socket.cluster_adapter_export(...)`             |
| `cluster_adapter_import_merge`           | 从快照合并消息到 adapter。                                                                                                                                                                    | `cluster_adapter_import_merge`       | 已符合命名          | `socket.cluster_adapter_import_merge(...)`       |
| `cluster_ring_sync_smoke` | cluster ring 烟测（export → import_merge → drain）。 | `cluster_ring_sync_smoke` | 已符合命名；Tier-X 不 export | `socket.cluster_ring_sync_smoke(...)` |
| `p3_complete_smoke` | P3 收口烟测（v9–v15 server/hub/room/cluster 金样串联）。 | `p3_complete_smoke` | 已符合命名；Tier-X 不 export | `socket.p3_complete_smoke(...)` |
| `eio_encode_packet`                      | 编码 Engine.IO 包（type 字符 + payload）；返回写入字节数。                                                                                                                                           | `eio_encode_packet`                  | 已符合命名          | `socket.eio_encode_packet(...)`                  |
| `eio_decode_packet`                      | 解码 Engine.IO 包；成功 0。                                                                                                                                                                 | `eio_decode_packet`                  | 已符合命名          | `socket.eio_decode_packet(...)`                  |
| `sio_encode_event`                       | —                                                                                                                                                                                    | `encode_event`                       | 去模块前缀+去类型名     | `socket.encode_event(...)`                       |
| `sio_encode_event_ns`                    | 编码指定 namespace 的 EVENT EIO 包（例 `42/chat,["ping","x"]`）。                                                                                                                              | `encode_event_ns`                    | 去模块前缀+去类型名     | `socket.encode_event_ns(...)`                    |
| `sio_decode_event`                       | 从 Socket.IO EVENT 包（EIO payload，不含 leading '4'）解析 event 与 data。                                                                                                                      | `decode_event`                       | 去模块前缀+去类型名     | `socket.decode_event(...)`                       |
| `eio_extract_sid`                        | 从 open 包 JSON 提取 sid；成功返回 sid 长度。                                                                                                                                                    | `eio_extract_sid`                    | 已符合命名          | `socket.eio_extract_sid(...)`                    |
| `socketio_packet_smoke` | C 层编解码烟测；0 通过。 | `packet_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `socket.packet_smoke(...)` |
| `socketio_is_implemented`                | 模块 C 已链入时为 1。                                                                                                                                                                        | `is_implemented`                     | 去模块前缀+去类型名     | `socket.is_implemented(...)`                     |


### std.sort

`std/sort/mod.sx` · 18 APIs · `const sort = import("std.sort")`


| 当前名称                     | 功能说明                                                                                             | 简化名称             | 说明             | 绑定调用                       |
| ------------------------ | ------------------------------------------------------------------------------------------------ | ---------------- | -------------- | -------------------------- |
| `sort_i32_c` | std.sort — 排序（对标 Zig std.sort、Rust Vec::sort） 【文件职责】sort_i32、sort_u8 原地不稳定升序；sort_stable_* 稳定归并； | `sort` | 去模块前缀+去类型名（C层） | `sort.sort(...)` |
| `sort_u8_c` | extern C/平台 | `sort` | 去模块前缀+去类型名（C层） | `sort.sort(...)` |
| `sort_stable_i32_c` | extern C/平台 | `stable` | 去模块前缀+去类型名（C层） | `sort.stable(...)` |
| `sort_stable_u8_c` | extern C/平台 | `stable` | 去模块前缀+去类型名（C层） | `sort.stable(...)` |
| `sort_i32_cmp_c` | extern C/平台 | `cmp` | 去模块前缀+去类型名（C层） | `sort.cmp(...)` |
| `sort_stable_key_tag_c` | extern C/平台 | `stable_key_tag` | 去模块前缀+去类型名（C层） | `sort.stable_key_tag(...)` |
| `sort_cmp_i32_desc_fn_c` | extern C/平台 | `cmp_desc_fn` | 去模块前缀+去类型名（C层） | `sort.cmp_desc_fn(...)` |
| `sort_cmp_i32_asc_fn_c` | extern C/平台 | `cmp_asc_fn` | 去模块前缀+去类型名（C层） | `sort.cmp_asc_fn(...)` |
| `sort_cmp_key_i32_fn_c` | extern C/平台 | `cmp_key_fn` | 去模块前缀+去类型名（C层） | `sort.cmp_key_fn(...)` |
| `sort_i32`               | 原地对 ptr[0..len] 升序排序（i32）；不稳定。                                                                   | `sort`           | 去模块前缀+去类型名     | `sort.sort(...)`           |
| `sort_u8`                | 原地对 ptr[0..len] 升序排序（u8）；不稳定。                                                                    | `sort`           | 去模块前缀+去类型名     | `sort.sort(...)`           |
| `sort_stable_i32`        | 原地稳定升序排序 ptr[0..len]（i32）。                                                                       | `stable`         | 去模块前缀+去类型名     | `sort.stable(...)`         |
| `sort_stable_u8`         | 原地稳定升序排序 ptr[0..len]（u8）。                                                                        | `stable`         | 去模块前缀+去类型名     | `sort.stable(...)`         |
| `sort_i32_cmp`           | 原地稳定排序 ptr[0..len]（i32）；cmp_fn 为 usize 承载的 C 比较器。                                                | `cmp`            | 去模块前缀+去类型名     | `sort.cmp(...)`            |
| `sort_stable_by_key`     | KeyTag 数组按 key 稳定升序排序。                                                                           | `stable_by_key`  | 去模块前缀+去类型名     | `sort.stable_by_key(...)`  |
| `cmp_i32_desc_fn`        | 返回降序 i32 比较器函数地址（usize）。                                                                         | `cmp_desc_fn`    | 去模块前缀+去类型名     | `sort.cmp_desc_fn(...)`    |
| `cmp_i32_asc_fn`         | 返回升序 i32 比较器函数地址（usize）。                                                                         | `cmp_asc_fn`     | 去模块前缀+去类型名     | `sort.cmp_asc_fn(...)`     |
| `cmp_key_i32_fn`         | 返回 KeyTag key 比较器函数地址（usize）。                                                                    | `cmp_key_fn`     | 去模块前缀+去类型名     | `sort.cmp_key_fn(...)`     |


### std.string

`std/string/mod.sx` · 62 APIs · `const str = import("std.string")`


| 当前名称                        | 功能说明                                                           | 简化名称                | 说明             | 绑定调用                         |
| --------------------------- | -------------------------------------------------------------- | ------------------- | -------------- | ---------------------------- |
| `string_long_threshold`     | —                                                              | `long_threshold`    | 去模块前缀+去类型名     | `str.long_threshold(...)`    |
| `string_copy_threshold`     | —                                                              | `copy_threshold`    | 去模块前缀+去类型名     | `str.copy_threshold(...)`    |
| `shux_string_memcmp_c` | extern C/平台 | `memcmp` | 去模块前缀+去类型名（C层） | `str.memcmp(...)` |
| `shux_string_memmem_c` | extern C/平台 | `memmem` | 去模块前缀+去类型名（C层） | `str.memmem(...)` |
| `shux_string_copy_c` | extern C/平台 | `copy` | 去模块前缀+去类型名（C层） | `str.copy(...)` |
| `shux_string_memchr_c` | extern C/平台 | `memchr` | 去模块前缀+去类型名（C层） | `str.memchr(...)` |
| `shux_string_memrchr_c` | extern C/平台 | `memrchr` | 去模块前缀+去类型名（C层） | `str.memrchr(...)` |
| `shux_string_memcmp_at_c` | extern C/平台 | `memcmp_at` | 去模块前缀+去类型名（C层） | `str.memcmp_at(...)` |
| `shux_string_ptr_at_c` | 指针偏移 ptr+off；供 subview 与 arena concat 写入第二段。 | `ptr_at` | 去模块前缀+去类型名（C层） | `str.ptr_at(...)` |
| `string_capacity`           | 固定缓冲容量（字节）；不分配堆，超过请用 StrView。                                  | `capacity`          | 去模块前缀+去类型名     | `str.capacity(...)`          |
| `string_empty`              | 空字符串长度常量 0。                                                    | `empty`             | 去模块前缀+去类型名     | `str.empty(...)`             |
| `string_view`               | 从 (ptr, len) 构造只读视图，零拷贝（不复制内存）。                                | `from_raw_parts`    | 去模块前缀+去类型名     | `str.from_raw_parts(...)`    |
| `string_view_len`           | 视图字节数。                                                         | `len`               | 去模块前缀+去类型名     | `str.len(...)`               |
| `string_view_is_empty`      | 视图是否为空。返回 1 是，0 否。                                             | `is_empty`          | 去模块前缀+去类型名     | `str.is_empty(...)`          |
| `string_view_case_fold`     | ASCII 小写化写入 out；返回写入字节数，缓冲不足 -1（STD-160）。                      | `case_fold`         | 去模块前缀+去类型名     | `str.case_fold(...)`         |
| `string_view_is_valid_utf8` | 校验 UTF-8 合法性；合法 1，非法 0（STD-160 烟测：ASCII 子集）。                   | `is_valid_utf8`     | 去模块前缀+去类型名     | `str.is_valid_utf8(...)`     |
| `string_view_get`           | 取视图中第 i 字节；i 越界未定义。                                            | `get`               | 去模块前缀+去类型名     | `str.get(...)`               |
| `string_view_subview`       | —                                                              | `subview`           | 去模块前缀+去类型名     | `str.subview(...)`           |
| `string_view_concat_arena`  | —                                                              | `concat_arena`      | 去模块前缀+去类型名     | `str.concat_arena(...)`      |
| `string_view_eq`            | —                                                              | `eq`                | 去模块前缀+去类型名     | `str.eq(...)`                |
| `string_view_eq_slice`      | —                                                              | `eq_slice`          | 去模块前缀+去类型名     | `str.eq_slice(...)`          |
| `string_view_compare`       | 视图字典序比较。返回 <0 / 0 / >0。长串走 C memcmp 快路径。                       | `compare`           | 去模块前缀+去类型名     | `str.compare(...)`           |
| `string_view_find_char`     | 视图中字节 c 首次出现下标，不存在返回 -1。                                       | `find_char`         | 去模块前缀+去类型名     | `str.find_char(...)`         |
| `string_view_starts_with`   | —                                                              | `starts_with`       | 去模块前缀+去类型名     | `str.starts_with(...)`       |
| `string_view_ends_with`     | —                                                              | `ends_with`         | 去模块前缀+去类型名     | `str.ends_with(...)`         |
| `string_view_find_slice`    | —                                                              | `find_slice`        | 去模块前缀+去类型名     | `str.find_slice(...)`        |
| `string_view_contains`      | 视图是否包含子串 sub。返回 1 是，0 否。                                       | `contains`          | 去模块前缀+去类型名     | `str.contains(...)`          |
| `string_eq_view`            | —                                                              | `eq_view`           | 去模块前缀+去类型名     | `str.eq_view(...)`           |
| `string_compare_view`       | String 与 StrView 字典序比较。返回 <0 / 0 / >0。长串走 C memcmp。            | `compare_view`      | 去模块前缀+去类型名     | `str.compare_view(...)`      |
| `stack_str_capacity`        | StackStr 内联容量（字节）；超出请用 StrView + Arena64 或 String(256)。        | `str_capacity`      | 二次精简：去对象前缀     | `str.str_capacity(...)`      |
| `stack_str_new`             | 新建空 StackStr。                                                  | `str_new`           | 二次精简：去对象前缀     | `str.str_new(...)`           |
| `stack_str_len`             | 当前字节数。                                                         | `str_len`           | 二次精简：去对象前缀     | `str.str_len(...)`           |
| `stack_str_view`            | 零拷贝转为 StrView；视图生命周期须不超出 StackStr 所在栈帧。                        | `str_view`          | 二次精简：去对象前缀     | `str.str_view(...)`          |
| `stack_str_from_slice`      | —                                                              | `str_from_slice`    | 二次精简：去对象前缀     | `str.str_from_slice(...)`    |
| `stack_str_append_char`     | 追加一字节；溢出返回 -1，成功返回 0。                                          | `str_append_char`   | 二次精简：去对象前缀     | `str.str_append_char(...)`   |
| `string_new`                | 新建空字符串。                                                        | `new`               | 去模块前缀+去类型名     | `str.new(...)`               |
| `string_len`                | 当前字节数（对标 Rust len()、Go len(s)）。                                | `len`               | 去模块前缀+去类型名     | `str.len(...)`               |
| `string_len_ptr`            | 只读热路径：通过指针取长度，避免 36 字节结构体按值传递。                                 | `len_ptr`           | 去模块前缀+去类型名     | `str.len_ptr(...)`           |
| `string_is_empty`           | 是否为空（len==0）。返回 1 是，0 否。                                       | `is_empty`          | 去模块前缀+去类型名     | `str.is_empty(...)`          |
| `string_is_empty_ptr`       | 热路径：指针版 is_empty，避免 260 字节按值传递。                                | `is_empty_ptr`      | 去模块前缀+去类型名     | `str.is_empty_ptr(...)`      |
| `string_from_char`          | 单字符构造。                                                         | `from_char`         | 去模块前缀+去类型名     | `str.from_char(...)`         |
| `string_from_slice`         | —                                                              | `from_slice`        | 去模块前缀+去类型名     | `str.from_slice(...)`        |
| `string_get`                | 取第 i 字节；i 越界未定义。                                               | `get`               | 去模块前缀+去类型名     | `str.get(...)`               |
| `string_eq`                 | —                                                              | `eq`                | 去模块前缀+去类型名     | `str.eq(...)`                |
| `string_eq_ptr`             | —                                                              | `eq_ptr`            | 去模块前缀+去类型名     | `str.eq_ptr(...)`            |
| `string_compare`            | 字典序比较。返回 <0 / 0 / >0。长串走 C memcmp 快路径。                         | `compare`           | 去模块前缀+去类型名     | `str.compare(...)`           |
| `string_compare_ptr`        | —                                                              | `compare_ptr`       | 去模块前缀+去类型名     | `str.compare_ptr(...)`       |
| `string_clear`              | 清空，len 置 0。                                                    | `clear`             | 去模块前缀+去类型名     | `str.clear(...)`             |
| `string_append_char`        | 追加单字符。返回 0 成功，-1 溢出（已满）。                                       | `append_char`       | 去模块前缀+去类型名     | `str.append_char(...)`       |
| `string_append_slice` | — | `extend` | 去模块前缀+去类型名；三轮精简 | `str.extend(...)` |
| `string_data_ptr`           | —                                                              | `data_ptr`          | 去模块前缀+去类型名     | `str.data_ptr(...)`          |
| `string_view_from_string`   | —                                                              | `from_string`       | 去模块前缀+去类型名     | `str.from_string(...)`       |
| `string_copy_to`            | —                                                              | `copy_to`           | 去模块前缀+去类型名     | `str.copy_to(...)`           |
| `string_copy_to_ptr`        | 热路径：指针版 copy_to，避免 260 字节按值传递；长块走 C memcpy。                    | `copy_to_ptr`       | 去模块前缀+去类型名     | `str.copy_to_ptr(...)`       |
| `string_find_char`          | 首次出现字节 c 的下标，不存在返回 -1。长串走 C memchr 快路径。                        | `find_char`         | 去模块前缀+去类型名     | `str.find_char(...)`         |
| `string_starts_with`        | 是否以 prefix[0..prefix_len-1] 开头。返回 1 是，0 否。长 prefix 走 C memcmp。 | `starts_with`       | 去模块前缀+去类型名     | `str.starts_with(...)`       |
| `string_ends_with`          | 是否以 suffix[0..suffix_len-1] 结尾。返回 1 是，0 否。长 suffix 走 C memcmp。 | `ends_with`         | 去模块前缀+去类型名     | `str.ends_with(...)`         |
| `string_contains`           | —                                                              | `contains_key`      | 去模块前缀+去类型名     | `str.contains_key(...)`      |
| `string_find_slice`         | —                                                              | `find_slice`        | 去模块前缀+去类型名     | `str.find_slice(...)`        |
| `string_rfind_char`         | 字节 c 最后一次出现的下标，不存在返回 -1。长串走 C 快路径。                             | `rfind_char`        | 去模块前缀+去类型名     | `str.rfind_char(...)`        |
| `string_trim_space`         | —                                                              | `trim`              | 去模块前缀+去类型名     | `str.trim(...)`              |
| `string_replace_char`       | —                                                              | `replace_char`      | 去模块前缀+去类型名     | `str.replace_char(...)`      |


### std.sync

`std/sync/mod.sx` · 53 APIs · `const sync = import("std.sync")`


| 当前名称                              | 功能说明                                                                  | 简化名称                       | 说明             | 绑定调用                                 |
| --------------------------------- | --------------------------------------------------------------------- | -------------------------- | -------------- | ------------------------------------ |
| `sync_mutex_new_c` | std.sync — 互斥锁与同步原语（对标 Rust std::sync::Mutex、Zig Thread.Mutex） 【文件职责】 | `new_mutex` | 去模块前缀+去类型名（C层） | `sync.new_mutex(...)` |
| `sync_mutex_lock_c` | extern C/平台 | `lock` | 去模块前缀+去类型名（C层） | `sync.lock(...)` |
| `sync_mutex_try_lock_c` | extern C/平台 | `try_lock` | 去模块前缀+去类型名（C层） | `sync.try_lock(...)` |
| `sync_mutex_unlock_c` | extern C/平台 | `unlock` | 去模块前缀+去类型名（C层） | `sync.unlock(...)` |
| `sync_mutex_free_c` | extern C/平台 | `free_mutex` | 去模块前缀+去类型名（C层） | `sync.free_mutex(...)` |
| `mutex_new` | — | `new_mutex` | 三轮精简：类型短前缀 | `sync.new_mutex(...)` |
| `mutex_lock` | — | `lock` | 三轮精简 | `sync.lock(...)` |
| `mutex_try_lock` | — | `try_lock` | 三轮精简 | `sync.try_lock(...)` |
| `mutex_unlock` | 解锁；必须在已持有锁的线程内调用。返回 0 成功，-1 失败。 | `unlock` | 三轮精简 | `sync.unlock(...)` |
| `mutex_free` | — | `free_mutex` | 三轮精简 | `sync.free_mutex(...)` |
| `sync_rwlock_new_c` | extern C/平台 | `new_rwlock` | 去模块前缀+去类型名（C层） | `sync.new_rwlock(...)` |
| `sync_rwlock_read_lock_c` | extern C/平台 | `read_lock` | 去模块前缀+去类型名（C层） | `sync.read_lock(...)` |
| `sync_rwlock_write_lock_c` | extern C/平台 | `write_lock` | 去模块前缀+去类型名（C层） | `sync.write_lock(...)` |
| `sync_rwlock_read_unlock_c` | extern C/平台 | `read_unlock` | 去模块前缀+去类型名（C层） | `sync.read_unlock(...)` |
| `sync_rwlock_write_unlock_c` | extern C/平台 | `write_unlock` | 去模块前缀+去类型名（C层） | `sync.write_unlock(...)` |
| `sync_rwlock_free_c` | extern C/平台 | `free_rwlock` | 去模块前缀+去类型名（C层） | `sync.free_rwlock(...)` |
| `sync_condvar_new_c` | extern C/平台 | `new_condvar` | 去模块前缀+去类型名（C层） | `sync.new_condvar(...)` |
| `sync_condvar_wait_c` | extern C/平台 | `wait` | 去模块前缀+去类型名（C层） | `sync.wait(...)` |
| `sync_condvar_signal_c` | extern C/平台 | `notify_one` | 去模块前缀+去类型名（C层） | `sync.notify_one(...)` |
| `sync_condvar_broadcast_c` | extern C/平台 | `notify_all` | 去模块前缀+去类型名（C层） | `sync.notify_all(...)` |
| `sync_condvar_free_c` | extern C/平台 | `free_condvar` | 去模块前缀+去类型名（C层） | `sync.free_condvar(...)` |
| `sync_rwlock_contention_smoke_c` | extern C/平台 | `rwlock_contention_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.rwlock_contention_smoke(...)` |
| `sync_condvar_contention_smoke_c` | extern C/平台                                                           | `condvar_contention_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.condvar_contention_smoke(...)` |
| `rwlock_new` | 创建 RwLock；失败 0。 | `new_rwlock` | 三轮精简 | `sync.new_rwlock(...)` |
| `rwlock_free` | 销毁 RwLock。 | `free_rwlock` | 三轮精简 | `sync.free_rwlock(...)` |
| `rwlock_read_lock` | 获取读锁；成功 0。 | `read_lock` | 三轮精简 | `sync.read_lock(...)` |
| `rwlock_write_lock` | 获取写锁；成功 0。 | `write_lock` | 三轮精简 | `sync.write_lock(...)` |
| `rwlock_read_unlock` | 释放读锁；成功 0。 | `read_unlock` | 三轮精简 | `sync.read_unlock(...)` |
| `rwlock_write_unlock` | 释放写锁；成功 0。 | `write_unlock` | 三轮精简 | `sync.write_unlock(...)` |
| `condvar_new` | 创建 Condvar；失败 0。 | `new_condvar` | 三轮精简 | `sync.new_condvar(...)` |
| `condvar_wait` | 在已持有 mutex 时等待 condvar；唤醒后重新持有 mutex。 | `wait` | 三轮精简 | `sync.wait(...)` |
| `condvar_signal`                  | 唤醒一个等待线程。                                                             | `notify_one`               | 语义重命名          | `sync.notify_one(...)`               |
| `condvar_broadcast`               | 唤醒全部等待线程。                                                             | `notify_all`               | 语义重命名          | `sync.notify_all(...)`               |
| `condvar_free` | 销毁 Condvar。 | `free_condvar` | 三轮精简 | `sync.free_condvar(...)` |
| `rwlock_contention_smoke` | RwLock 竞争烟测；成功 0。 | `rwlock_contention_smoke` | 已符合命名；Tier-X 不 export | `sync.rwlock_contention_smoke(...)` |
| `condvar_contention_smoke` | Condvar 竞争烟测；成功 0。 | `condvar_contention_smoke` | 已符合命名；Tier-X 不 export | `sync.condvar_contention_smoke(...)` |
| `sync_lock_diag_set_enabled_c` | extern C/平台 | `lock_diag_set_enabled` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_set_enabled(...)` |
| `sync_lock_diag_is_enabled_c` | extern C/平台 | `lock_diag_is_enabled` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_is_enabled(...)` |
| `sync_lock_diag_mutex_set_id_c` | extern C/平台 | `lock_diag_mutex_set_id` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_mutex_set_id(...)` |
| `sync_lock_diag_last_err_c` | extern C/平台 | `lock_diag_last_err` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_last_err(...)` |
| `sync_lock_diag_clear_c` | extern C/平台 | `lock_diag_clear` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_clear(...)` |
| `sync_lock_diag_snapshot_c` | extern C/平台 | `lock_diag_snapshot` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_snapshot(...)` |
| `sync_lock_diag_smoke_c` | extern C/平台 | `lock_diag_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `sync.lock_diag_smoke(...)` |
| `lock_diag_err_recursive` | 递归加锁错误码 -1。 | `lock_diag_err_recursive` | 已符合命名；Tier-X 不 export | `sync.lock_diag_err_recursive(...)` |
| `lock_diag_err_order` | 锁序违规错误码 -2。 | `lock_diag_err_order` | 已符合命名；Tier-X 不 export | `sync.lock_diag_err_order(...)` |
| `lock_diag_err_unlock` | 解锁顺序错误码 -3。 | `lock_diag_err_unlock` | 已符合命名；Tier-X 不 export | `sync.lock_diag_err_unlock(...)` |
| `lock_diag_set_enabled` | 开启/关闭锁诊断。 | `lock_diag_set_enabled` | 已符合命名；Tier-X 不 export | `sync.lock_diag_set_enabled(...)` |
| `lock_diag_is_enabled` | 查询锁诊断是否开启。 | `lock_diag_is_enabled` | 已符合命名；Tier-X 不 export | `sync.lock_diag_is_enabled(...)` |
| `lock_diag_mutex_set_id` | 为 mutex 绑定锁序 id。 | `lock_diag_mutex_set_id` | 已符合命名；Tier-X 不 export | `sync.lock_diag_mutex_set_id(...)` |
| `lock_diag_last_err` | 最近诊断错误码。 | `lock_diag_last_err` | 已符合命名；Tier-X 不 export | `sync.lock_diag_last_err(...)` |
| `lock_diag_clear` | 清空诊断状态。 | `lock_diag_clear` | 已符合命名；Tier-X 不 export | `sync.lock_diag_clear(...)` |
| `lock_diag_snapshot` | 写入文本快照；返回写入字节数。 | `lock_diag_snapshot` | 已符合命名；Tier-X 不 export | `sync.lock_diag_snapshot(...)` |
| `lock_diag_smoke` | C 烟测门面。 | `lock_diag_smoke` | 已符合命名；Tier-X 不 export | `sync.lock_diag_smoke(...)` |


### std.sys

`std/sys/mod.sx` · 37 APIs · `const sys = import("std.sys")`


| 当前名称                            | 功能说明                                     | 简化名称                            | 说明         | 绑定调用                                     |
| ------------------------------- | ---------------------------------------- | ------------------------------- | ---------- | ---------------------------------------- |
| `shux_sys_write`                | extern C/平台                              | `write`                         | 去模块前缀+去类型名 | `sys.write(...)`                         |
| `freestanding_write_available`  | —                                        | `freestanding_write_available`  | 已符合命名      | `sys.freestanding_write_available(...)`  |
| `freestanding_write_available`  | —                                        | `freestanding_write_available`  | 已符合命名      | `sys.freestanding_write_available(...)`  |
| `os_write`                      | —                                        | `os_write`                      | 已符合命名      | `sys.os_write(...)`                      |
| `os_write`                      | —                                        | `os_write`                      | 已符合命名      | `sys.os_write(...)`                      |
| `os_write`                      | —                                        | `os_write`                      | 已符合命名      | `sys.os_write(...)`                      |
| `os_write_stdout`               | —                                        | `os_write_stdout`               | 已符合命名      | `sys.os_write_stdout(...)`               |
| `os_write_stdout`               | —                                        | `os_write_stdout`               | 已符合命名      | `sys.os_write_stdout(...)`               |
| `os_write_stdout`               | —                                        | `os_write_stdout`               | 已符合命名      | `sys.os_write_stdout(...)`               |
| `os_write_stderr`               | —                                        | `os_write_stderr`               | 已符合命名      | `sys.os_write_stderr(...)`               |
| `os_write_stderr`               | —                                        | `os_write_stderr`               | 已符合命名      | `sys.os_write_stderr(...)`               |
| `os_write_stderr`               | —                                        | `os_write_stderr`               | 已符合命名      | `sys.os_write_stderr(...)`               |
| `linux_syscall_table_available` | —                                        | `linux_syscall_table_available` | 已符合命名      | `sys.linux_syscall_table_available(...)` |
| `linux_syscall_nr_write_amd64`  | —                                        | `linux_syscall_nr_write_amd64`  | 已符合命名      | `sys.linux_syscall_nr_write_amd64(...)`  |
| `linux_syscall_nr_write_arm64`  | —                                        | `linux_syscall_nr_write_arm64`  | 已符合命名      | `sys.linux_syscall_nr_write_arm64(...)`  |
| `macos_write_available`         | —                                        | `macos_write_available`         | 已符合命名      | `sys.macos_write_available(...)`         |
| `macos_write`                   | —                                        | `macos_write`                   | 已符合命名      | `sys.macos_write(...)`                   |
| `macos_write_stdout`            | —                                        | `macos_write_stdout`            | 已符合命名      | `sys.macos_write_stdout(...)`            |
| `macos_write_stderr`            | —                                        | `macos_write_stderr`            | 已符合命名      | `sys.macos_write_stderr(...)`            |
| `macos_mmap_available`          | —                                        | `macos_mmap_available`          | 已符合命名      | `sys.macos_mmap_available(...)`          |
| `mmap_available`                | —                                        | `mmap_available`                | 已符合命名      | `sys.mmap_available(...)`                |
| `os_mmap_rw`                    | 可写 mmap 薄转发。                             | `os_mmap_rw`                    | 已符合命名      | `sys.os_mmap_rw(...)`                    |
| `os_munmap`                     | 解除 mmap 薄转发。                             | `os_munmap`                     | 已符合命名      | `sys.os_munmap(...)`                     |
| `os_msync`                      | msync 薄转发。                               | `os_msync`                      | 已符合命名      | `sys.os_msync(...)`                      |
| `os_read_file_into`             | —                                        | `os_read_file_into`             | 已符合命名      | `sys.os_read_file_into(...)`             |
| `os_read_file_into`             | —                                        | `os_read_file_into`             | 已符合命名      | `sys.os_read_file_into(...)`             |
| `os_read_file_into`             | —                                        | `os_read_file_into`             | 已符合命名      | `sys.os_read_file_into(...)`             |
| `os_read`                       | —                                        | `os_read`                       | 已符合命名      | `sys.os_read(...)`                       |
| `os_read`                       | —                                        | `os_read`                       | 已符合命名      | `sys.os_read(...)`                       |
| `os_read`                       | —                                        | `os_read`                       | 已符合命名      | `sys.os_read(...)`                       |
| `os_close`                      | —                                        | `os_close`                      | 已符合命名      | `sys.os_close(...)`                      |
| `os_close`                      | —                                        | `os_close`                      | 已符合命名      | `sys.os_close(...)`                      |
| `os_close`                      | —                                        | `os_close`                      | 已符合命名      | `sys.os_close(...)`                      |
| `os_exit`                       | —                                        | `os_exit`                       | 已符合命名      | `sys.os_exit(...)`                       |
| `os_exit`                       | —                                        | `os_exit`                       | 已符合命名      | `sys.os_exit(...)`                       |
| `os_exit`                       | —                                        | `os_exit`                       | 已符合命名      | `sys.os_exit(...)`                       |
| `os_mmap`                       | B-19：os_mmap 为 os_mmap_rw 别名（可写文件 mmap）。 | `os_mmap`                       | 已符合命名      | `sys.os_mmap(...)`                       |


### std.tar

`std/tar/mod.sx` · 12 APIs · `const tar = import("std.tar")`


| 当前名称                    | 功能说明                           | 简化名称              | 说明             | 绑定调用                       |
| ----------------------- | ------------------------------ | ----------------- | -------------- | -------------------------- |
| `tar_path_max_c` | extern C/平台 | `path_max` | 去模块前缀+去类型名（C层） | `tar.path_max(...)` |
| `tar_read_header_c` | extern C/平台 | `read_header` | 去模块前缀+去类型名（C层） | `tar.read_header(...)` |
| `tar_write_header_c` | extern C/平台 | `write_header` | 去模块前缀+去类型名（C层） | `tar.write_header(...)` |
| `tar_append_entry_c` | extern C/平台 | `append_entry` | 去模块前缀+去类型名（C层） | `tar.append_entry(...)` |
| `tar_next_entry_c` | extern C/平台 | `next_entry` | 去模块前缀+去类型名（C层） | `tar.next_entry(...)` |
| `tar_read_entry_data_c` | extern C/平台                    | `read_entry_data` | 去模块前缀+去类型名（C层） | `tar.read_entry_data(...)` |
| `read_header`           | —                              | `read_header`     | 已符合命名          | `tar.read_header(...)`     |
| `write_header`          | —                              | `write_header`    | 已符合命名          | `tar.write_header(...)`    |
| `append_entry`          | 向内存归档追加 UStar 条目；is_dir=1 为目录。 | `append_entry`    | 已符合命名          | `tar.append_entry(...)`    |
| `next_entry`            | 遍历下一条；返回 0 成功，1 结束，-1 错误。      | `next_entry`      | 已符合命名          | `tar.next_entry(...)`      |
| `read_entry_data`       | 从 entry_off 读取文件内容。            | `read_entry_data` | 已符合命名          | `tar.read_entry_data(...)` |
| `path_max`              | 支持的最大完整路径字节数（含 Pax）。           | `path_max`        | 已符合命名          | `tar.path_max(...)`        |


### std.task

`std/task/mod.sx` · 38 APIs · `const task = import("std.task")`


| 当前名称                        | 功能说明                            | 简化名称                  | 说明             | 绑定调用                            |
| --------------------------- | ------------------------------- | --------------------- | -------------- | ------------------------------- |
| `task_err_ok`               | 成功。                             | `err_ok`              | 去模块前缀+去类型名     | `task.err_ok(...)`              |
| `task_err_null`             | 空指针/非法句柄。                       | `err_null`            | 去模块前缀+去类型名     | `task.err_null(...)`            |
| `task_err_full`             | 容量已满。                           | `err_full`            | 去模块前缀+去类型名     | `task.err_full(...)`            |
| `task_err_cancelled`        | 已取消。                            | `err_cancelled`       | 去模块前缀+去类型名     | `task.err_cancelled(...)`       |
| `task_err_leak`             | 未 join 泄漏。                      | `err_leak`            | 去模块前缀+去类型名     | `task.err_leak(...)`            |
| `task_err_invalid`          | 其它非法状态。                         | `err_invalid`         | 去模块前缀+去类型名     | `task.err_invalid(...)`         |
| `task_group_create_c` | extern C/平台 | `create` | 去模块前缀+去类型名（C层） | `task.create(...)` |
| `task_group_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `task.free(...)` |
| `task_group_bind_context_c` | extern C/平台 | `bind_context` | 去模块前缀+去类型名（C层） | `task.bind_context(...)` |
| `task_group_spawn_c` | extern C/平台 | `spawn` | 去模块前缀+去类型名（C层） | `task.spawn(...)` |
| `task_group_join_c` | extern C/平台 | `join` | 去模块前缀+去类型名（C层） | `task.join(...)` |
| `task_group_pending_c` | extern C/平台 | `pending` | 去模块前缀+去类型名（C层） | `task.pending(...)` |
| `task_group_check_leak_c` | extern C/平台 | `check_leak` | 去模块前缀+去类型名（C层） | `task.check_leak(...)` |
| `task_group_cancel_c` | extern C/平台 | `cancel` | 去模块前缀+去类型名（C层） | `task.cancel(...)` |
| `task_group_join_total_c` | extern C/平台 | `join_total` | 去模块前缀+去类型名（C层） | `task.join_total(...)` |
| `join_set_create_c` | extern C/平台 | `join_set_create` | 去模块前缀+去类型名（C层） | `task.join_set_create(...)` |
| `join_set_free_c` | extern C/平台 | `join_set_free` | 已符合命名 | `task.join_set_free(...)` |
| `join_set_spawn_c` | extern C/平台 | `join_set_spawn` | 已符合命名 | `task.join_set_spawn(...)` |
| `join_set_join_c` | extern C/平台 | `join_set_join` | 已符合命名 | `task.join_set_join(...)` |
| `join_set_check_leak_c` | extern C/平台 | `join_set_check_leak` | 去模块前缀+去类型名（C层） | `task.join_set_check_leak(...)` |
| `task_supervise_retry_c` | extern C/平台 | `supervise_retry` | 去模块前缀+去类型名（C层） | `task.supervise_retry(...)` |
| `task_echo_fn_c` | extern C/平台 | `echo_fn` | 去模块前缀+去类型名（C层） | `task.echo_fn(...)` |
| `task_echo_fn_ptr_c` | extern C/平台 | `echo_fn_ptr` | 去模块前缀+去类型名（C层） | `task.echo_fn_ptr(...)` |
| `task_group_new`            | 创建 TaskGroup。                   | `new`                 | 去模块前缀+去类型名     | `task.new(...)`                 |
| `task_group_free`           | 释放 TaskGroup。                   | `free`                | 去模块前缀+去类型名     | `task.free(...)`                |
| `task_group_bind_context`   | 绑定 Context 以传播取消。               | `bind_context`        | 去模块前缀+去类型名     | `task.bind_context(...)`        |
| `task_group_spawn`          | 提交任务（fn 为 C 协程入口指针）。            | `spawn`               | 去模块前缀+去类型名     | `task.spawn(...)`               |
| `task_group_join`           | 等待组内全部任务完成；返回结果之和。              | `join`                | 去模块前缀+去类型名     | `task.join(...)`                |
| `task_group_pending`        | 未 join 的 pending 任务数。           | `pending`             | 去模块前缀+去类型名     | `task.pending(...)`             |
| `task_group_check_leak`     | 结构化并发边界检查；泄漏返回 task_err_leak()。 | `check_leak`          | 去模块前缀+去类型名     | `task.check_leak(...)`          |
| `task_group_cancel`         | 取消绑定 Context。                   | `cancel`              | 去模块前缀+去类型名     | `task.cancel(...)`              |
| `task_group_join_total`     | 上次 join 累计结果。                   | `join_total`          | 去模块前缀+去类型名     | `task.join_total(...)`          |
| `join_set_new`              | 创建 JoinSet。                     | `join_set_new`        | 已符合命名          | `task.join_set_new(...)`        |
| `join_set_free`             | 释放 JoinSet。                     | `join_set_free`       | 已符合命名          | `task.join_set_free(...)`       |
| `join_set_spawn`            | JoinSet 提交任务。                   | `join_set_spawn`      | 已符合命名          | `task.join_set_spawn(...)`      |
| `join_set_join`             | JoinSet 等待全部完成。                 | `join_set_join`       | 已符合命名          | `task.join_set_join(...)`       |
| `join_set_check_leak`       | JoinSet 泄漏检测。                   | `join_set_check_leak` | 已符合命名          | `task.join_set_check_leak(...)` |
| `supervise_retry`           | Supervisor：带退避的重试执行。            | `supervise_retry`     | 已符合命名          | `task.supervise_retry(...)`     |


### std.test

`std/test/mod.sx` · 32 APIs · `const test = import("std.test")`


| 当前名称                        | 功能说明                                                                                                                              | 简化名称                 | 说明             | 绑定调用                           |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | -------------------- | -------------- | ------------------------------ |
| `test_expect_c` | std.test — 测试断言与 runner（对标 Zig std.testing、Rust test） STD-054：bench_run / bench_report / fuzz_seed / fuzz_next / fuzz_run 占位 API。 | `assert` | 去模块前缀+去类型名（C层） | `test.assert(...)` |
| `test_expect_eq_i32_c` | extern C/平台 | `assert_eq` | 去模块前缀+去类型名（C层） | `test.assert_eq(...)` |
| `test_expect_eq_u32_c` | extern C/平台 | `assert_eq` | 去模块前缀+去类型名（C层） | `test.assert_eq(...)` |
| `test_expect_ne_i32_c` | extern C/平台 | `assert_ne` | 去模块前缀+去类型名（C层） | `test.assert_ne(...)` |
| `test_run_c` | extern C/平台 | `run` | 去模块前缀+去类型名（C层） | `test.run(...)` |
| `test_bench_run_c` | extern C/平台 | `bench_run` | 去模块前缀+去类型名（C层） | `test.bench_run(...)` |
| `test_bench_report_c` | extern C/平台 | `bench_report` | 去模块前缀+去类型名（C层） | `test.bench_report(...)` |
| `test_fuzz_seed_c` | extern C/平台 | `fuzz_seed` | 去模块前缀+去类型名（C层） | `test.fuzz_seed(...)` |
| `test_fuzz_next_c` | extern C/平台 | `fuzz_next` | 去模块前缀+去类型名（C层） | `test.fuzz_next(...)` |
| `test_fuzz_run_c` | extern C/平台 | `fuzz_run` | 去模块前缀+去类型名（C层） | `test.fuzz_run(...)` |
| `test_bench_run_noop_c` | extern C/平台 | `bench_run_noop` | 去模块前缀+去类型名（C层） | `test.bench_run_noop(...)` |
| `test_fuzz_run_noop_c` | extern C/平台 | `fuzz_run_noop` | 去模块前缀+去类型名（C层） | `test.fuzz_run_noop(...)` |
| `test_runner_reset_c` | extern C/平台 | `runner_reset` | 去模块前缀+去类型名（C层） | `test.runner_reset(...)` |
| `test_runner_report_case_c` | extern C/平台                                                                                                                       | `runner_report_case` | 去模块前缀+去类型名（C层） | `test.runner_report_case(...)` |
| `test_runner_report_skip_c` | extern C/平台                                                                                                                       | `runner_report_skip` | 去模块前缀+去类型名（C层） | `test.runner_report_skip(...)` |
| `test_runner_finish_c` | extern C/平台 | `runner_finish` | 去模块前缀+去类型名（C层） | `test.runner_finish(...)` |
| `expect`                    | 断言 cond 为真；返回 0 通过，1 失败。                                                                                                          | `assert`             | 语义重命名          | `test.assert(...)`             |
| `expect_eq_i32`             | 断言 a == b（i32）；返回 0 通过，1 失败。                                                                                                      | `assert_eq`          | 去模块前缀+去类型名     | `test.assert_eq(...)`          |
| `expect_eq_u32`             | 断言 a == b（u32）；返回 0 通过，1 失败。                                                                                                      | `assert_eq`          | 去模块前缀+去类型名     | `test.assert_eq(...)`          |
| `expect_ne_i32`             | 断言 a != b（i32）；返回 0 通过，1 失败。                                                                                                      | `assert_ne`          | 去模块前缀+去类型名     | `test.assert_ne(...)`          |
| `test_run`                  | —                                                                                                                                 | `run`                | 去模块前缀+去类型名     | `test.run(...)`                |
| `bench_run`                 | 调用无参 fn 共 iters 次，返回纳秒耗时。                                                                                                         | `bench_run`          | 已符合命名          | `test.bench_run(...)`          |
| `bench_report`              | 写 bench 报告到 stderr：shux: [SHUX_BENCH] name=… ns=…                                                                                 | `bench_report`       | 已符合命名          | `test.bench_report(...)`       |
| `fuzz_seed`                 | 读取 SHUX_FUZZ_SEED 或默认种子。                                                                                                          | `fuzz_seed`          | 已符合命名          | `test.fuzz_seed(...)`          |
| `fuzz_next`                 | LCG 单步；state 为 in/out 种子指针。                                                                                                       | `fuzz_next`          | 已符合命名          | `test.fuzz_next(...)`          |
| `fuzz_run`                  | 每轮推进 PRNG 后调用 fn；全部返回 0 则 0。                                                                                                      | `fuzz_run`           | 已符合命名          | `test.fuzz_run(...)`           |
| `bench_run_noop`            | STD-143：对 C 内置 noop 跑 bench，无需函数指针。                                                                                               | `bench_run_noop`     | 已符合命名          | `test.bench_run_noop(...)`     |
| `fuzz_run_noop`             | STD-143：对 C 内置 noop 跑 fuzz runner。                                                                                                | `fuzz_run_noop`      | 已符合命名          | `test.fuzz_run_noop(...)`      |
| `runner_reset`              | 重置 runner 计数（STD-145）。                                                                                                            | `runner_reset`       | 已符合命名          | `test.runner_reset(...)`       |
| `runner_case`               | 报告单条用例；exit_code=0 为 pass。                                                                                                        | `runner_case`        | 已符合命名          | `test.runner_case(...)`        |
| `runner_skip`               | 报告 skip 用例。                                                                                                                       | `runner_skip`        | 已符合命名          | `test.runner_skip(...)`        |
| `runner_finish`             | 输出汇总行；返回 fail 数。                                                                                                                  | `runner_finish`      | 已符合命名          | `test.runner_finish(...)`      |


### std.thread

`std/thread/mod.sx` · 29 APIs · `const thread = import("std.thread")`


| 当前名称                          | 功能说明                                                 | 简化名称                 | 说明             | 绑定调用                             |
| ----------------------------- | ---------------------------------------------------- | -------------------- | -------------- | -------------------------------- |
| `thread_self_c` | extern C/平台 | `id` | `self` 为语言关键字，改用最接近语义的 `id` | `thread.id(...)` |
| `thread_create_c` | extern C/平台 | `create` | 去模块前缀+去类型名（C层） | `thread.create(...)` |
| `thread_create_with_stack_c` | extern C/平台 | `create_with_stack` | 去模块前缀+去类型名（C层） | `thread.create_with_stack(...)` |
| `thread_join_c` | extern C/平台 | `join` | 去模块前缀+去类型名（C层） | `thread.join(...)` |
| `thread_set_affinity_self_c` | extern C/平台 | `set_affinity_self` | 去模块前缀+去类型名（C层） | `thread.set_affinity_self(...)` |
| `thread_set_affinity_c` | extern C/平台 | `set_affinity` | 去模块前缀+去类型名（C层） | `thread.set_affinity(...)` |
| `thread_set_qos_class_self_c` | extern C/平台                                          | `set_qos_class_self` | 去模块前缀+去类型名（C层） | `thread.set_qos_class_self(...)` |
| `thread_dummy_entry_ptr_c` | extern C/平台 | `dummy_entry_ptr` | 去模块前缀+去类型名（C层） | `thread.dummy_entry_ptr(...)` |
| `thread_self`                 | 返回当前线程 ID（用于区分线程、多核时每线程一 io_uring）。                  | `id`                 | `self` 为语言关键字，改用最接近语义的 `id` | `thread.id(...)`                 |
| `thread_create`               | —                                                    | `create`             | 去模块前缀+去类型名     | `thread.create(...)`             |
| `thread_create_with_stack`    | —                                                    | `create_with_stack`  | 去模块前缀+去类型名     | `thread.create_with_stack(...)`  |
| `thread_join`                 | 等待线程结束；thread_id 为 thread_create 返回值。返回 0 成功，-1 失败。  | `join`               | 去模块前缀+去类型名     | `thread.join(...)`               |
| `thread_set_affinity_self`    | —                                                    | `set_affinity_self`  | 去模块前缀+去类型名     | `thread.set_affinity_self(...)`  |
| `thread_set_affinity`         | —                                                    | `set_affinity`       | 去模块前缀+去类型名     | `thread.set_affinity(...)`       |
| `thread_set_qos_class_self`   | —                                                    | `set_qos_class_self` | 去模块前缀+去类型名     | `thread.set_qos_class_self(...)` |
| `thread_dummy_entry_ptr`      | —                                                    | `dummy_entry_ptr`    | 去模块前缀+去类型名     | `thread.dummy_entry_ptr(...)`    |
| `thread_set_name_self_c` | extern C/平台 | `set_name_self` | 去模块前缀+去类型名（C层） | `thread.set_name_self(...)` |
| `thread_pool_start_c` | extern C/平台 | `start` | 去模块前缀+去类型名（C层） | `thread.start(...)` |
| `thread_pool_submit_c` | extern C/平台 | `submit` | 去模块前缀+去类型名（C层） | `thread.submit(...)` |
| `thread_pool_drain_c` | extern C/平台 | `drain` | 去模块前缀+去类型名（C层） | `thread.drain(...)` |
| `thread_pool_stop_c` | extern C/平台 | `stop` | 去模块前缀+去类型名（C层） | `thread.stop(...)` |
| `thread_pool_pending_c` | extern C/平台 | `pending` | 去模块前缀+去类型名（C层） | `thread.pending(...)` |
| `thread_set_name_self`        | 设置当前线程名（≤15 字节）；成功 0，不支持 -1。                         | `set_name_self`      | 去模块前缀+去类型名     | `thread.set_name_self(...)`      |
| `thread_pool_start`           | 启动固定 worker 线程池；workers 1..8；成功 0（Windows v1 返回 -1）。 | `start`              | 去模块前缀+去类型名     | `thread.start(...)`              |
| `thread_pool_submit`          | 向池提交 C 入口任务；成功 0。                                    | `submit`             | 去模块前缀+去类型名     | `thread.submit(...)`             |
| `thread_pool_drain`           | 阻塞直至队列与 in-flight 皆空；成功 0。                           | `drain`              | 去模块前缀+去类型名     | `thread.drain(...)`              |
| `thread_pool_stop`            | 停止池并 join worker；成功 0。                               | `stop`               | 去模块前缀+去类型名     | `thread.stop(...)`               |
| `thread_pool_pending`         | 观测 pending（队列 + in-flight）；未启动 -1。                   | `pending`            | 去模块前缀+去类型名     | `thread.pending(...)`            |
| `thread_pool_stats`           | 读取全局线程池统计；未启动池时返回 -1。                                | `stats`              | 去模块前缀+去类型名     | `thread.stats(...)`              |


### std.time

`std/time/mod.sx` · 39 APIs · `const time = import("std.time")`


| 当前名称                           | 功能说明                                     | 简化名称                    | 说明             | 绑定调用                              |
| ------------------------------ | ---------------------------------------- | ----------------------- | -------------- | --------------------------------- |
| `time_now_monotonic_ns_c` | std.time — 时间与睡眠（单调时钟、墙钟、sleep） 【文件职责】 | `now_monotonic_ns` | 去模块前缀+去类型名（C层） | `time.now_monotonic_ns(...)` |
| `time_now_monotonic_us_c` | extern C/平台 | `now_monotonic_us` | 去模块前缀+去类型名（C层） | `time.now_monotonic_us(...)` |
| `time_now_monotonic_ms_c` | extern C/平台 | `now_monotonic_ms` | 去模块前缀+去类型名（C层） | `time.now_monotonic_ms(...)` |
| `time_now_monotonic_sec_c` | extern C/平台 | `now_monotonic_sec` | 去模块前缀+去类型名（C层） | `time.now_monotonic_sec(...)` |
| `time_now_wall_sec_c` | extern C/平台 | `now_wall_sec` | 去模块前缀+去类型名（C层） | `time.now_wall_sec(...)` |
| `time_now_wall_ms_c` | extern C/平台 | `now_wall_ms` | 去模块前缀+去类型名（C层） | `time.now_wall_ms(...)` |
| `time_now_wall_us_c` | extern C/平台 | `now_wall_us` | 去模块前缀+去类型名（C层） | `time.now_wall_us(...)` |
| `time_now_wall_ns_c` | extern C/平台 | `now_wall_ns` | 去模块前缀+去类型名（C层） | `time.now_wall_ns(...)` |
| `time_sleep_ns_c` | extern C/平台 | `sleep_ns` | 去模块前缀+去类型名（C层） | `time.sleep_ns(...)` |
| `time_sleep_us_c` | extern C/平台 | `sleep_us` | 去模块前缀+去类型名（C层） | `time.sleep_us(...)` |
| `time_sleep_ms_c` | extern C/平台 | `sleep_ms` | 去模块前缀+去类型名（C层） | `time.sleep_ms(...)` |
| `time_sleep_sec_c` | extern C/平台 | `sleep_sec` | 去模块前缀+去类型名（C层） | `time.sleep_sec(...)` |
| `time_duration_ns_c` | extern C/平台 | `duration_ns` | 去模块前缀+去类型名（C层） | `time.duration_ns(...)` |
| `time_format_wall_rfc3339_c` | extern C/平台 | `format_wall_rfc3339` | 去模块前缀+去类型名（C层） | `time.format_wall_rfc3339(...)` |
| `time_wall_local_offset_min_c` | extern C/平台                              | `wall_local_offset_min` | 去模块前缀+去类型名（C层） | `time.wall_local_offset_min(...)` |
| `time_format_timezone_smoke_c` | extern C/平台                              | `format_timezone_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `time.format_timezone_smoke(...)` |
| `now_monotonic_ns`             | —                                        | `now_monotonic_ns`      | 已符合命名          | `time.now_monotonic_ns(...)`      |
| `now_monotonic_us`             | 单调时钟：微秒。                                 | `now_monotonic_us`      | 已符合命名          | `time.now_monotonic_us(...)`      |
| `now_monotonic_ms`             | 单调时钟：毫秒。                                 | `now_monotonic_ms`      | 已符合命名          | `time.now_monotonic_ms(...)`      |
| `now_monotonic_sec`            | 单调时钟：秒。                                  | `now_monotonic_sec`     | 已符合命名          | `time.now_monotonic_sec(...)`     |
| `now_wall_sec`                 | 墙钟：自 Unix 纪元 1970-01-01 00:00:00 UTC 的秒。 | `now_wall_sec`          | 已符合命名          | `time.now_wall_sec(...)`          |
| `now_wall_ms`                  | 墙钟：毫秒。                                   | `now_wall_ms`           | 已符合命名          | `time.now_wall_ms(...)`           |
| `now_wall_us`                  | 墙钟：微秒。                                   | `now_wall_us`           | 已符合命名          | `time.now_wall_us(...)`           |
| `now_wall_ns`                  | 墙钟：纳秒（Windows 粒度为 100ns）。                | `now_wall_ns`           | 已符合命名          | `time.now_wall_ns(...)`           |
| `sleep_ns`                     | 睡眠：纳秒。可能提前唤醒，不保证精度。                      | `sleep_ns`              | 已符合命名          | `time.sleep_ns(...)`              |
| `sleep_us`                     | 睡眠：微秒。                                   | `sleep_us`              | 已符合命名          | `time.sleep_us(...)`              |
| `sleep_ms`                     | 睡眠：毫秒。                                   | `sleep_ms`              | 已符合命名          | `time.sleep_ms(...)`              |
| `sleep_sec`                    | 睡眠：秒。                                    | `sleep_sec`             | 已符合命名          | `time.sleep_sec(...)`             |
| `duration_ns`                  | 时间差（纳秒）：to_ns - from_ns；纯算术。             | `duration_ns`           | 已符合命名          | `time.duration_ns(...)`           |
| `timer_start`                  | 启动计时器并记录起点。                              | `start`                 | 二次精简：去对象前缀     | `time.start(...)`                 |
| `timer_reset`                  | 重置计时器起点为当前单调时钟。                          | `reset`                 | 二次精简：去对象前缀     | `time.reset(...)`                 |
| `timer_elapsed_ns`             | 自 timer_start/reset 起经过的纳秒数。             | `elapsed_ns`            | 二次精简：去对象前缀     | `time.elapsed_ns(...)`            |
| `timer_elapsed_us`             | 经过的微秒数。                                  | `elapsed_us`            | 二次精简：去对象前缀     | `time.elapsed_us(...)`            |
| `timer_elapsed_ms`             | 经过的毫秒数。                                  | `elapsed_ms`            | 二次精简：去对象前缀     | `time.elapsed_ms(...)`            |
| `timer_elapsed_sec`            | 经过的秒数。                                   | `elapsed_sec`           | 二次精简：去对象前缀     | `time.elapsed_sec(...)`           |
| `timer_lap_ns`                 | 记录 lap 并返回本段纳秒数；同时重置段起点。                 | `lap_ns`                | 二次精简：去对象前缀     | `time.lap_ns(...)`                |
| `format_wall_rfc3339`          | 将当前 UTC 墙钟写入 buf（RFC3339，STD-137）。       | `format_wall_rfc3339`   | 已符合命名          | `time.format_wall_rfc3339(...)`   |
| `wall_local_offset_min`        | 本地时区相对 UTC 偏移（分钟；东为正，STD-137）。           | `wall_local_offset_min` | 已符合命名          | `time.wall_local_offset_min(...)` |
| `format_timezone_smoke` | 时区/格式化烟测；0 成功。 | `format_timezone_smoke` | 已符合命名；Tier-X 不 export | `time.format_timezone_smoke(...)` |


### std.trace

`std/trace/mod.sx` · 34 APIs · `const trace = import("std.trace")`


| 当前名称                       | 功能说明                                            | 简化名称                  | 说明             | 绑定调用                             |
| -------------------------- | ----------------------------------------------- | --------------------- | -------------- | -------------------------------- |
| `trace_err_ok`             | 成功。                                             | `err_ok`              | 去模块前缀+去类型名     | `trace.err_ok(...)`              |
| `trace_err_null`           | 空指针/非法句柄。                                       | `err_null`            | 去模块前缀+去类型名     | `trace.err_null(...)`            |
| `trace_err_not_found`      | 未找到 span。                                       | `err_not_found`       | 去模块前缀+去类型名     | `trace.err_not_found(...)`       |
| `trace_err_full`           | 容量已满。                                           | `err_full`            | 去模块前缀+去类型名     | `trace.err_full(...)`            |
| `trace_err_invalid`        | 参数非法（如非栈顶 end）。                                 | `err_invalid`         | 去模块前缀+去类型名     | `trace.err_invalid(...)`         |
| `trace_create_c` | extern C/平台 | `create` | 去模块前缀+去类型名（C层） | `trace.create(...)` |
| `trace_free_c` | extern C/平台 | `free` | 去模块前缀+去类型名（C层） | `trace.free(...)` |
| `trace_trace_id_c` | extern C/平台 | `id` | 去模块前缀+去类型名（C层） | `trace.id(...)` |
| `trace_current_span_c` | extern C/平台 | `current_span` | 去模块前缀+去类型名（C层） | `trace.current_span(...)` |
| `trace_start_span_c` | extern C/平台 | `start_span` | 去模块前缀+去类型名（C层） | `trace.start_span(...)` |
| `trace_end_span_c` | extern C/平台 | `end_span` | 去模块前缀+去类型名（C层） | `trace.end_span(...)` |
| `trace_start_child_c` | extern C/平台 | `start_child` | 去模块前缀+去类型名（C层） | `trace.start_child(...)` |
| `trace_span_count_c` | extern C/平台 | `count` | 去模块前缀+去类型名（C层） | `trace.count(...)` |
| `trace_export_text_c` | extern C/平台 | `export_text` | 去模块前缀+去类型名（C层） | `trace.export_text(...)` |
| `trace_new`                | 创建新追踪会话。                                        | `new`                 | 去模块前缀+去类型名     | `trace.new(...)`                 |
| `trace_free`               | 释放追踪会话。                                         | `free`                | 去模块前缀+去类型名     | `trace.free(...)`                |
| `trace_id`                 | 读取 trace_id。                                    | `id`                  | 去模块前缀+去类型名     | `trace.id(...)`                  |
| `current_span`             | 当前活跃 span id；无则 0。                              | `current_span`        | 已符合命名          | `trace.current_span(...)`        |
| `span_start`               | 开始 span；parent_id=0 为根 span。                    | `start`               | 二次精简：去对象前缀     | `trace.start(...)`               |
| `span_start_child`         | 以当前栈顶为 parent 开始子 span。                         | `start_child`         | 二次精简：去对象前缀     | `trace.start_child(...)`         |
| `span_end`                 | 结束 span（须为栈顶）。                                  | `end`                 | 二次精简：去对象前缀     | `trace.end(...)`                 |
| `span_count`               | 已完成 span 数量。                                    | `count`               | 二次精简：去对象前缀     | `trace.count(...)`               |
| `export_text`              | 导出 text 格式追踪记录；返回写入长度。                          | `export_text`         | 已符合命名          | `trace.export_text(...)`         |
| `attach_to_context`        | 将 trace 句柄写入 Context value bag。                 | `attach_to_context`   | 已符合命名          | `trace.attach_to_context(...)`   |
| `from_context`             | 从 Context 读取 trace 句柄；未附着则 handle=0。            | `from_context`        | 已符合命名          | `trace.from_context(...)`        |
| `hook_span_begin`          | —                                               | `span_begin`          | 二次精简：去对象前缀     | `trace.span_begin(...)`          |
| `hook_span_end`            | —                                               | `span_end`            | 二次精简：去对象前缀     | `trace.span_end(...)`            |
| `hook_io_read_ctx`         | io.read 自动 span；Context 无 trace 时透传 read_ctx。   | `io_read_ctx`         | 二次精简：去对象前缀     | `trace.io_read_ctx(...)`         |
| `hook_io_write_ctx`        | io.write 自动 span；Context 无 trace 时透传 write_ctx。 | `io_write_ctx`        | 二次精简：去对象前缀     | `trace.io_write_ctx(...)`        |
| `hook_net_connect_ctx`     | net.connect 自动 span；返回 fd 语义同 connect_ctx_fd。   | `net_connect_ctx`     | 二次精简：去对象前缀     | `trace.net_connect_ctx(...)`     |
| `hook_net_stream_read_ctx` | net.stream_read 自动 span；语义同 stream_read_ctx。    | `net_stream_read_ctx` | 二次精简：去对象前缀     | `trace.net_stream_read_ctx(...)` |
| `hook_async_drain_ctx`     | async.drain 自动 span；语义同 runtime_drain。          | `async_drain_ctx`     | 二次精简：去对象前缀     | `trace.async_drain_ctx(...)`     |
| `trace_hooks_smoke_c` | extern C/平台 | `hooks_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `trace.hooks_smoke(...)` |
| `hooks_smoke` | STD-118：挂钩路径 C 烟测；0 通过。 | `hooks_smoke` | 已符合命名；Tier-X 不 export | `trace.hooks_smoke(...)` |


### std.unicode

`std/unicode/mod.sx` · 23 APIs · `const unicode = import("std.unicode")`


| 当前名称                            | 功能说明                                                                                                                        | 简化名称                  | 说明             | 绑定调用                               |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | --------------------- | -------------- | ---------------------------------- |
| `unicode_category_c` | std.unicode — Unicode 分类、大小写、NFC、字素簇（对标 Zig std.unicode、Rust char） 【文件职责】category、to_lower/to_upper、is_whitespace、is_ascii； | `category` | 去模块前缀+去类型名（C层） | `unicode.category(...)` |
| `unicode_is_whitespace_c` | extern C/平台 | `is_whitespace` | 去模块前缀+去类型名（C层） | `unicode.is_whitespace(...)` |
| `unicode_is_ascii_c` | extern C/平台 | `is_ascii` | 去模块前缀+去类型名（C层） | `unicode.is_ascii(...)` |
| `unicode_to_lower_c` | extern C/平台 | `to_lower` | 去模块前缀+去类型名（C层） | `unicode.to_lower(...)` |
| `unicode_to_upper_c` | extern C/平台 | `to_upper` | 去模块前缀+去类型名（C层） | `unicode.to_upper(...)` |
| `unicode_is_supplementary_c` | extern C/平台 | `is_supplementary` | 去模块前缀+去类型名（C层） | `unicode.is_supplementary(...)` |
| `unicode_nfc_buf_c` | extern C/平台 | `nfc_buf` | 去模块前缀+去类型名（C层） | `unicode.nfc_buf(...)` |
| `unicode_grapheme_next_c` | extern C/平台 | `grapheme_next` | 去模块前缀+去类型名（C层） | `unicode.grapheme_next(...)` |
| `unicode_case_fold_rune_c` | extern C/平台 | `case_fold_rune` | 去模块前缀+去类型名（C层） | `unicode.case_fold_rune(...)` |
| `unicode_case_fold_buf_c` | extern C/平台 | `case_fold_buf` | 去模块前缀+去类型名（C层） | `unicode.case_fold_buf(...)` |
| `unicode_grapheme_case_smoke_c` | extern C/平台                                                                                                                 | `grapheme_case_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `unicode.grapheme_case_smoke(...)` |
| `category`                      | rune 分类：0 未知，1 Letter，2 Number，3 Whitespace。                                                                                | `category`            | 已符合命名          | `unicode.category(...)`            |
| `is_whitespace`                 | 是否为空白（t n v f r 空格）。                                                                                                        | `is_whitespace`       | 已符合命名          | `unicode.is_whitespace(...)`       |
| `is_ascii`                      | 是否为 ASCII（rune <= 127）。                                                                                                     | `is_ascii`            | 已符合命名          | `unicode.is_ascii(...)`            |
| `to_lower`                      | rune 转小写；非 ASCII 暂返回原值。                                                                                                     | `to_lower`            | 已符合命名          | `unicode.to_lower(...)`            |
| `to_upper`                      | rune 转大写；非 ASCII 暂返回原值。                                                                                                     | `to_upper`            | 已符合命名          | `unicode.to_upper(...)`            |
| `is_supplementary`              | 是否为 Unicode 增补平面码点（U+10000 及以上）。                                                                                            | `is_supplementary`    | 已符合命名          | `unicode.is_supplementary(...)`    |
| `rune_utf8_len`                 | rune 编码为 UTF-8 所需的字节数（1..4）；非法高位 surrogate 区间按 3 处理。                                                                        | `rune_utf8_len`       | 已符合命名          | `unicode.rune_utf8_len(...)`       |
| `nfc_buf`                       | 缓冲 NFC（v1 拉丁预组合子集）；返回写入 out 的字节数，失败 -1。                                                                                     | `nfc_buf`             | 已符合命名          | `unicode.nfc_buf(...)`             |
| `grapheme_next`                 | 下一字素簇字节数（基字符 + U+0300..036F 附标）。                                                                                            | `grapheme_next`       | 已符合命名          | `unicode.grapheme_next(...)`       |
| `case_fold_rune`                | 单码点 case fold（v1 委托 to_lower）。                                                                                              | `case_fold_rune`      | 已符合命名          | `unicode.case_fold_rune(...)`      |
| `case_fold_buf`                 | 缓冲 case fold 输出 UTF-8；返回写入字节数，失败 -1。                                                                                        | `case_fold_buf`       | 已符合命名          | `unicode.case_fold_buf(...)`       |
| `grapheme_case_smoke` | C 烟测入口（STD-114）；0 表示通过。 | `grapheme_case_smoke` | 已符合命名；Tier-X 不 export | `unicode.grapheme_case_smoke(...)` |


### std.url

`std/url/mod.sx` · 19 APIs · `const url = import("std.url")`


| 当前名称                     | 功能说明                                      | 简化名称               | 说明             | 绑定调用                        |
| ------------------------ | ----------------------------------------- | ------------------ | -------------- | --------------------------- |
| `url_parse_c` | extern C/平台 | `parse` | 去模块前缀+去类型名（C层） | `url.parse(...)` |
| `url_build_c` | extern C/平台 | `serialize` | 去模块前缀+去类型名（C层） | `url.serialize(...)` |
| `url_query_encode_c` | extern C/平台 | `encode` | 去模块前缀+去类型名（C层） | `url.encode(...)` |
| `url_query_decode_c` | extern C/平台 | `decode` | 去模块前缀+去类型名（C层） | `url.decode(...)` |
| `url_resolve_c` | extern C/平台 | `resolve` | 去模块前缀+去类型名（C层） | `url.resolve(...)` |
| `url_host_to_ipv6_c` | extern C/平台 | `to_ipv6` | 去模块前缀+去类型名（C层） | `url.to_ipv6(...)` |
| `url_format_ipv6_host_c` | extern C/平台                               | `format_ipv6_host` | 去模块前缀+去类型名（C层） | `url.format_ipv6_host(...)` |
| `url_host_is_ipv6_c` | extern C/平台 | `is_ipv6` | 去模块前缀+去类型名（C层） | `url.is_ipv6(...)` |
| `url_ipv6_host_smoke_c` | extern C/平台 | `ipv6_host_smoke` | 去模块前缀+去类型名（C层）；Tier-X 不 export | `url.ipv6_host_smoke(...)` |
| `parse`                  | 解析 URL；0 成功，-1 失败。                        | `parse`            | 已符合命名          | `url.parse(...)`            |
| `build`                  | 从组件组装 URL；返回写入长度，失败 -1。                   | `serialize`        | 语义重命名          | `url.serialize(...)`        |
| `stringify`              | 同 build：序列化为字符串。                          | `stringify`        | 已符合命名          | `url.stringify(...)`        |
| `query_encode`           | query 值 percent 编码；返回写入长度。                | `encode`           | 二次精简：去对象前缀     | `url.encode(...)`           |
| `query_decode`           | query 值 percent 解码；返回写入长度。                | `decode`           | 二次精简：去对象前缀     | `url.decode(...)`           |
| `resolve`                | 相对 ref 解析到 base；结果写入 out；0 成功。            | `resolve`          | 已符合命名          | `url.resolve(...)`          |
| `host_to_ipv6`           | —                                         | `to_ipv6`          | 二次精简：去对象前缀     | `url.to_ipv6(...)`          |
| `format_ipv6_host`       | 16 字节 IPv6 格式化为 host 文本（无方括号）；返回长度，失败 -1。 | `format_ipv6_host` | 已符合命名          | `url.format_ipv6_host(...)` |
| `host_is_ipv6`           | host 是否为 IPv6 文本；1 是，0 否。                 | `is_ipv6`          | 二次精简：去对象前缀     | `url.is_ipv6(...)`          |
| `ipv6_host_smoke` | STD-134 C 金样：IPv6 bracket 与 host 字节互转。 | `ipv6_host_smoke` | 已符合命名；Tier-X 不 export | `url.ipv6_host_smoke(...)` |


### std.uuid

`std/uuid/mod.sx` · 13 APIs · `const uuid = import("std.uuid")`


| 当前名称             | 功能说明                                               | 简化名称       | 说明                | 绑定调用                 |
| ---------------- | -------------------------------------------------- | ---------- | ----------------- | -------------------- |
| `uuid_new_v4_c` | extern C/平台 | `new` | 二次精简：去算法/版本/分段数后缀 | `uuid.new(...)` |
| `uuid_new_v7_c` | extern C/平台 | `new` | 二次精简：去算法/版本/分段数后缀 | `uuid.new(...)` |
| `uuid_parse_c` | extern C/平台 | `parse` | 去模块前缀+去类型名（C层） | `uuid.parse(...)` |
| `uuid_format_c` | extern C/平台 | `format` | 去模块前缀+去类型名（C层） | `uuid.format(...)` |
| `uuid_eq_c` | extern C/平台 | `eq` | 去模块前缀+去类型名（C层） | `uuid.eq(...)` |
| `uuid_version_c` | extern C/平台 | `version` | 去模块前缀+去类型名（C层） | `uuid.version(...)` |
| `new_v4`         | 生成 UUID v4；失败返回全零 Uuid。                            | `new`      | 二次精简：去算法/版本/分段数后缀 | `uuid.new(...)`      |
| `new_v7`         | 生成 UUID v7（RFC 9562：墙钟毫秒 + 同毫秒序号单调递增）；失败返回全零 Uuid。 | `new`      | 二次精简：去算法/版本/分段数后缀 | `uuid.new(...)`      |
| `parse`          | 解析 UUID 字符串（36 带连字符或 32 纯 hex）；0 成功，-1 失败。         | `parse`    | 已符合命名             | `uuid.parse(...)`    |
| `format`         | 格式化为小写连字符字符串；返回 36，失败 -1。                          | `format`   | 已符合命名             | `uuid.format(...)`   |
| `eq`             | 128-bit 相等：1 是，0 否。                                | `eq`       | 已符合命名             | `uuid.eq(...)`       |
| `version`        | 版本 nibble（4=v4，7=v7）；非法 -1。                        | `version`  | 已符合命名             | `uuid.version(...)`  |
| `as_bytes`       | 返回 UUID 首字节指针（16 字节连续；零拷贝视图）。                      | `as_bytes` | 已符合命名             | `uuid.as_bytes(...)` |


### std.vec

`std/vec/mod.sx` · 86 APIs · `const vec = import("std.vec")`


| 当前名称                                | 功能说明                                                                 | 简化名称                         | 说明         | 绑定调用                                  |
| ----------------------------------- | -------------------------------------------------------------------- | ---------------------------- | ---------- | ------------------------------------- |
| `vec_default_capacity` | — | `default_cap` | 去模块前缀+去类型名；三轮精简 | `vec.default_cap(...)` |
| `vec_copy_threshold`                | append_slice/from_slice 走 C memcpy 的阈值；≥ 此值时用块拷贝。                    | `copy_threshold`             | 去模块前缀+去类型名 | `vec.copy_threshold(...)`             |
| `vec_i32_new`                       | 新建空 Vec_i32（ptr 为 null，cap 0，al 为 default_allocator）；首次 push 时分配。    | `new`                        | 去模块前缀+去类型名 | `vec.new(...)`                        |
| `vec_i32_with_capacity`             | 预分配容量 capacity；按 v.al 分配；失败时 cap 置 0 并返回 -1，成功返回 0。                  | `with_capacity`              | 去模块前缀+去类型名 | `vec.with_capacity(...)`              |
| `vec_i32_reserve_one`               | —                                                                    | `reserve` | 去模块前缀+去类型名；三轮精简 | `vec.reserve(...)` |
| `vec_i32_push`                      | 追加元素 x；成功返回 0，分配失败返回 -1。                                             | `push`                       | 去模块前缀+去类型名 | `vec.push(...)`                       |
| `vec_i32_push_arena` | MEM-C1 单态化：with_arena 热路径直接 arena64_alloc，无 allocator_alloc kind 分支。 | `push` | 去模块前缀+去类型名；三轮精简 | `vec.push(...)` |
| `vec_i32_pop`                       | 移除并返回最后一个元素；空 vec 未定义。                                               | `pop`                        | 去模块前缀+去类型名 | `vec.pop(...)`                        |
| `vec_i32_len`                       | 长度（元素个数）。                                                            | `len`                        | 去模块前缀+去类型名 | `vec.len(...)`                        |
| `vec_i32_capacity`                  | 容量（可容纳元素个数，不含 realloc）。                                              | `capacity`                   | 去模块前缀+去类型名 | `vec.capacity(...)`                   |
| `vec_i32_get`                       | 取第 i 个元素；i 越界未定义。                                                    | `get`                        | 去模块前缀+去类型名 | `vec.get(...)`                        |
| `vec_i32_set`                       | 写第 i 个元素为 x；i 越界未定义。                                                 | `set`                        | 去模块前缀+去类型名 | `vec.set(...)`                        |
| `vec_i32_is_empty`                  | 是否为空（len==0）。返回 1 是，0 否。                                             | `is_empty`                   | 去模块前缀+去类型名 | `vec.is_empty(...)`                   |
| `vec_i32_clear`                     | 清空长度，不释放内存。                                                          | `clear`                      | 去模块前缀+去类型名 | `vec.clear(...)`                      |
| `vec_i32_truncate`                  | 截断到 new_len；new_len > len 无操作。                                       | `truncate`                   | 去模块前缀+去类型名 | `vec.truncate(...)`                   |
| `vec_i32_reserve`                   | 确保容量至少为 new_cap；按 v.al realloc；arena 已有 ptr 时扩容返回 -1。                | `reserve`                    | 去模块前缀+去类型名 | `vec.reserve(...)`                    |
| `vec_i32_append_slice` | — | `extend` | 去模块前缀+去类型名；三轮精简 | `vec.extend(...)` |
| `vec_i32_from_slice`                | —                                                                    | `from_slice`                 | 去模块前缀+去类型名 | `vec.from_slice(...)`                 |
| `vec_i32_ptr`                       | 零拷贝：返回内部缓冲首指针；与 vec_i32_len 组合即 (ptr, len)。                          | `ptr`                        | 去模块前缀+去类型名 | `vec.ptr(...)`                        |
| `vec_i32_deinit`                    | 释放堆内存并将 ptr 置为 null、len/cap 置 0；按 v.al 释放。                           | `deinit`                     | 去模块前缀+去类型名 | `vec.deinit(...)`                     |
| `vec_u8_new`                        | 新建空 Vec_u8；al 为 default_allocator（with_arena 内为 scope）。              | `new`                        | 去模块前缀+去类型名 | `vec.new(...)`                        |
| `vec_u8_with_capacity`              | 预分配容量 capacity；按 v.al 分配；失败时 cap 置 0 并返回 -1。                         | `with_capacity`              | 去模块前缀+去类型名 | `vec.with_capacity(...)`              |
| `vec_u8_reserve_one`                | 按 v.al 扩容预留 1 个元素；arena 已有 ptr 时不可 realloc（AL-05）。                   | `reserve` | 去模块前缀+去类型名；三轮精简 | `vec.reserve(...)` |
| `vec_u8_push`                       | —                                                                    | `push`                       | 去模块前缀+去类型名 | `vec.push(...)`                       |
| `vec_u8_push_arena` | MEM-C1 单态化：with_arena 热路径直接 arena64_alloc，无 allocator_alloc kind 分支。 | `push` | 去模块前缀+去类型名；三轮精简 | `vec.push(...)` |
| `vec_u8_pop`                        | —                                                                    | `pop`                        | 去模块前缀+去类型名 | `vec.pop(...)`                        |
| `vec_u8_len`                        | —                                                                    | `len`                        | 去模块前缀+去类型名 | `vec.len(...)`                        |
| `vec_u8_len_ptr`                    | 热路径：指针取长，避免按值传 Vec_u8 结构体。                                           | `len_ptr`                    | 去模块前缀+去类型名 | `vec.len_ptr(...)`                    |
| `vec_u8_capacity`                   | —                                                                    | `capacity`                   | 去模块前缀+去类型名 | `vec.capacity(...)`                   |
| `vec_u8_get`                        | —                                                                    | `get`                        | 去模块前缀+去类型名 | `vec.get(...)`                        |
| `vec_u8_set`                        | —                                                                    | `set`                        | 去模块前缀+去类型名 | `vec.set(...)`                        |
| `vec_u8_is_empty`                   | —                                                                    | `is_empty`                   | 去模块前缀+去类型名 | `vec.is_empty(...)`                   |
| `vec_u8_clear`                      | —                                                                    | `clear`                      | 去模块前缀+去类型名 | `vec.clear(...)`                      |
| `vec_u8_truncate`                   | —                                                                    | `truncate`                   | 去模块前缀+去类型名 | `vec.truncate(...)`                   |
| `vec_u8_reserve`                    | —                                                                    | `reserve`                    | 去模块前缀+去类型名 | `vec.reserve(...)`                    |
| `vec_u8_append_slice` | — | `extend` | 去模块前缀+去类型名；三轮精简 | `vec.extend(...)` |
| `vec_u8_from_slice`                 | —                                                                    | `from_slice`                 | 去模块前缀+去类型名 | `vec.from_slice(...)`                 |
| `vec_u8_ptr`                        | —                                                                    | `ptr`                        | 去模块前缀+去类型名 | `vec.ptr(...)`                        |
| `vec_u8_deinit`                     | —                                                                    | `deinit`                     | 去模块前缀+去类型名 | `vec.deinit(...)`                     |
| `vec_u8_with_allocator` | STD-112：按 Allocator 预分配 capacity；写入 v.al 并分配；失败 -1。 | `with_alloc` | 去模块前缀+去类型名；三轮精简 | `vec.with_alloc(...)` |
| `vec_u8_reserve_one_with_allocator` | STD-112：按 Allocator 扩容预留 1 个元素；临时覆盖 v.al 后委托 reserve_one。            | `reserve_one` | 去模块前缀+去类型名；三轮精简 | vec.reserve_one_with_allocator(...) |
| `vec_u8_push_with_allocator` | STD-112：按 Allocator 追加元素；设置 v.al 后委托 push。 | `push` | 去模块前缀+去类型名；三轮精简 | `vec.push(...)` |
| `vec_u8_deinit_with_allocator` | STD-112：按 Allocator 释放；arena 路径为 no-op。 | `deinit` | 去模块前缀+去类型名；三轮精简 | `vec.deinit(...)` |
| `vec_u16_new`                       | 新建空 Vec_u16。                                                         | `new`                        | 去模块前缀+去类型名 | `vec.new(...)`                        |
| `vec_u16_reserve_one`               | Vec_u16 扩容预留 1 个元素；失败 -1。                                            | `reserve` | 去模块前缀+去类型名；三轮精简 | `vec.reserve(...)` |
| `vec_u16_push`                      | 追加 u16；失败 -1。                                                        | `push`                       | 去模块前缀+去类型名 | `vec.push(...)`                       |
| `vec_u16_len`                       | Vec_u16 长度。                                                          | `len`                        | 去模块前缀+去类型名 | `vec.len(...)`                        |
| `vec_u16_get`                       | 取第 i 个 u16。                                                          | `get`                        | 去模块前缀+去类型名 | `vec.get(...)`                        |
| `vec_u16_deinit`                    | 释放 Vec_u16。                                                          | `deinit`                     | 去模块前缀+去类型名 | `vec.deinit(...)`                     |
| `vec_u64_new`                       | 新建空 Vec_u64。                                                         | `new`                        | 去模块前缀+去类型名 | `vec.new(...)`                        |
| `vec_u64_with_capacity`             | 预分配 capacity；失败 -1。                                                  | `with_capacity`              | 去模块前缀+去类型名 | `vec.with_capacity(...)`              |
| `vec_u64_reserve_one`               | 扩容预留 1 个 u64；失败 -1。                                                  | `reserve_one`                | 去模块前缀+去类型名 | `vec.reserve_one(...)`                |
| `vec_u64_reserve`                   | 确保容量至少 new_cap；失败 -1。                                                | `reserve`                    | 去模块前缀+去类型名 | `vec.reserve(...)`                    |
| `vec_u64_append_slice` | 追加 u64 切片；失败 -1。 | `extend` | 去模块前缀+去类型名；三轮精简 | `vec.extend(...)` |
| `vec_u64_from_slice`                | 从 u64 切片构造 Vec_u64；失败 len=-1。                                        | `from_slice`                 | 去模块前缀+去类型名 | `vec.from_slice(...)`                 |
| `vec_u64_len`                       | Vec_u64 长度。                                                          | `len`                        | 去模块前缀+去类型名 | `vec.len(...)`                        |
| `vec_u64_get`                       | 取第 i 个 u64。                                                          | `get`                        | 去模块前缀+去类型名 | `vec.get(...)`                        |
| `vec_u64_deinit`                    | 释放 Vec_u64。                                                          | `deinit`                     | 去模块前缀+去类型名 | `vec.deinit(...)`                     |
| `vec_f64_new`                       | 新建空 Vec_f64。                                                         | `new`                        | 去模块前缀+去类型名 | `vec.new(...)`                        |
| `vec_f64_with_capacity`             | 预分配 capacity；失败 -1。                                                  | `with_capacity`              | 去模块前缀+去类型名 | `vec.with_capacity(...)`              |
| `vec_f64_reserve_one`               | 扩容预留 1 个 f64；失败 -1。                                                  | `reserve_one`                | 去模块前缀+去类型名 | `vec.reserve_one(...)`                |
| `vec_f64_reserve`                   | 确保容量至少 new_cap；失败 -1。                                                | `reserve`                    | 去模块前缀+去类型名 | `vec.reserve(...)`                    |
| `vec_f64_append_slice` | 追加 f64 切片；失败 -1。 | `extend` | 去模块前缀+去类型名；三轮精简 | `vec.extend(...)` |
| `vec_f64_from_slice`                | 从 f64 切片构造 Vec_f64；失败 len=-1。                                        | `from_slice`                 | 去模块前缀+去类型名 | `vec.from_slice(...)`                 |
| `vec_f64_len`                       | Vec_f64 长度。                                                          | `len`                        | 去模块前缀+去类型名 | `vec.len(...)`                        |
| `vec_f64_get`                       | 取第 i 个 f64。                                                          | `get`                        | 去模块前缀+去类型名 | `vec.get(...)`                        |
| `vec_f64_deinit`                    | 释放 Vec_f64。                                                          | `deinit`                     | 去模块前缀+去类型名 | `vec.deinit(...)`                     |
| `vec3f_soa_new`                     | 新建空 Vec3f_soa（三列 ptr 均为 null）。                                       | `vec3f_soa_new`              | 已符合命名      | `vec.vec3f_soa_new(...)`              |
| `vec3f_soa_with_capacity`           | 预分配每列 capacity 个 f32；失败返回 -1。                                        | `vec3f_soa_with_capacity`    | 已符合命名      | `vec.vec3f_soa_with_capacity(...)`    |
| `vec3f_soa_reserve_one`             | 确保至少能再放 1 个三元组；三列同步扩容。                                               | `vec3f_soa_reserve_one`      | 已符合命名      | `vec.vec3f_soa_reserve_one(...)`      |
| `vec3f_soa_push`                    | 追加 (x,y,z)；成功 0，分配失败 -1。                                             | `vec3f_soa_push`             | 已符合命名      | `vec.vec3f_soa_push(...)`             |
| `vec3f_soa_len`                     | 长度（三元组个数）。                                                           | `vec3f_soa_len`              | 已符合命名      | `vec.vec3f_soa_len(...)`              |
| `vec3f_soa_get_x`                   | 读第 i 个 x 分量；i 越界未定义。                                                 | `vec3f_soa_get_x`            | 已符合命名      | `vec.vec3f_soa_get_x(...)`            |
| `vec3f_soa_get_y`                   | 读第 i 个 y 分量。                                                         | `vec3f_soa_get_y`            | 已符合命名      | `vec.vec3f_soa_get_y(...)`            |
| `vec3f_soa_get_z`                   | 读第 i 个 z 分量。                                                         | `vec3f_soa_get_z`            | 已符合命名      | `vec.vec3f_soa_get_z(...)`            |
| `vec3f_soa_set`                     | 写第 i 个三元组；i 越界未定义。                                                   | `vec3f_soa_set`              | 已符合命名      | `vec.vec3f_soa_set(...)`              |
| `vec3f_soa_sum_x`                   | 列扫描：求所有 x 分量之和（SoA 热路径 demo）；*Vec3f_soa 与 push/deinit 一致。            | `vec3f_soa_sum_x`            | 已符合命名      | `vec.vec3f_soa_sum_x(...)`            |
| `vec3f_soa_deinit`                  | 释放三列堆内存。                                                             | `vec3f_soa_deinit`           | 已符合命名      | `vec.vec3f_soa_deinit(...)`           |
| `vec3f_aos_new`                     | 新建空 Vec3f_aos。                                                       | `vec3f_aos_new`              | 已符合命名      | `vec.vec3f_aos_new(...)`              |
| `vec3f_aos_with_capacity`           | 预分配 capacity 个三元组（3*cap f32）；失败 -1。                                  | `vec3f_aos_with_capacity`    | 已符合命名      | `vec.vec3f_aos_with_capacity(...)`    |
| `vec3f_aos_reserve_one`             | AoS 扩容：元素槽 ×3 f32。                                                   | `vec3f_aos_reserve_one`      | 已符合命名      | `vec.vec3f_aos_reserve_one(...)`      |
| `vec3f_aos_push`                    | AoS 追加 (x,y,z)。                                                      | `vec3f_aos_push`             | 已符合命名      | `vec.vec3f_aos_push(...)`             |
| `vec3f_aos_get_x`                   | AoS 读 x 分量（第 i 个三元组）。                                                | `vec3f_aos_get_x`            | 已符合命名      | `vec.vec3f_aos_get_x(...)`            |
| `vec3f_aos_sum_x`                   | AoS 扫描 x 分量之和（对照 SoA 列扫描）。                                           | `vec3f_aos_sum_x`            | 已符合命名      | `vec.vec3f_aos_sum_x(...)`            |
| `vec3f_aos_deinit`                  | 释放 AoS 堆缓冲。                                                          | `vec3f_aos_deinit`           | 已符合命名      | `vec.vec3f_aos_deinit(...)`           |
| `vec_len_empty`                     | 空 vec 长度 0；保留兼容（测试用）。                                                | `len_empty`                  | 去模块前缀+去类型名 | `vec.len_empty(...)`                  |


### std.websocket

`std/websocket/mod.sx` · 58 APIs · `const ws = import("std.websocket")`


| 当前名称                             | 功能说明                                                                         | 简化名称                          | 说明             | 绑定调用                                  |
| -------------------------------- | ---------------------------------------------------------------------------- | ----------------------------- | -------------- | ------------------------------------- |
| `net_close_socket_c` | extern C/平台 | `net_close_socket` | 去模块前缀+去类型名（C层） | `ws.net_close_socket(...)` |
| `ws_err_ok`                      | 成功。                                                                          | `err_ok`                      | 去模块前缀+去类型名     | `ws.err_ok(...)`                      |
| `ws_err_io`                      | IO / 连接失败。                                                                   | `err_io`                      | 去模块前缀+去类型名     | `ws.err_io(...)`                      |
| `ws_err_handshake`               | 握手失败。                                                                        | `err_handshake`               | 去模块前缀+去类型名     | `ws.err_handshake(...)`               |
| `ws_err_null`                    | 空参数。                                                                         | `err_null`                    | 去模块前缀+去类型名     | `ws.err_null(...)`                    |
| `ws_err_tls_not_impl`            | TLS 不可用（须链入 std.net TLS 后端）。                                                 | `err_tls_not_impl`            | 去模块前缀+去类型名     | `ws.err_tls_not_impl(...)`            |
| `ws_timeout_ms_from_ctx`         | 从 Context 推导 WebSocket I/O 超时毫秒；已取消/过期返回 net_err_*，否则 0 或正毫秒。                | `timeout_ms_from_ctx`         | 去模块前缀+去类型名     | `ws.timeout_ms_from_ctx(...)`         |
| `ws_ctx_check`                   | 请求/读写前检查 Context；0 可继续，否则返回 net_err_cancelled/timeout。                       | `ctx_check`                   | 去模块前缀+去类型名     | `ws.ctx_check(...)`                   |
| `ws_map_c_result`                | 将 C 层 TLS 不可用映射为 ws_err_tls_not_impl。                                        | `map_c_result`                | 去模块前缀+去类型名     | `ws.map_c_result(...)`                |
| `ws_opcode_text`                 | RFC6455 帧 opcode：TEXT。                                                       | `opcode_text`                 | 去模块前缀+去类型名     | `ws.opcode_text(...)`                 |
| `ws_opcode_binary`               | RFC6455 帧 opcode：BINARY。                                                     | `opcode_binary`               | 去模块前缀+去类型名     | `ws.opcode_binary(...)`               |
| `ws_opcode_close`                | RFC6455 帧 opcode：CLOSE。                                                      | `opcode_close`                | 去模块前缀+去类型名     | `ws.opcode_close(...)`                |
| `ws_opcode_ping`                 | RFC6455 帧 opcode：PING。                                                       | `opcode_ping`                 | 去模块前缀+去类型名     | `ws.opcode_ping(...)`                 |
| `ws_opcode_pong`                 | RFC6455 帧 opcode：PONG。                                                       | `opcode_pong`                 | 去模块前缀+去类型名     | `ws.opcode_pong(...)`                 |
| `wss_is_available`               | WSS 是否可用（OpenSSL/mbedTLS 链入时为 true）。                                         | `wss_is_available`            | 已符合命名          | `ws.wss_is_available(...)`            |
| `ws_compute_accept`              | 计算 Sec-WebSocket-Accept（RFC 6455 金样烟测）。                                      | `compute_accept`              | 去模块前缀+去类型名     | `ws.compute_accept(...)`              |
| `ws_build_handshake_request`     | 构建客户端握手 HTTP 请求；返回写入字节数（不含 NUL）。                                             | `build_handshake_request`     | 去模块前缀+去类型名     | `ws.build_handshake_request(...)`     |
| `ws_validate_handshake_response` | 校验服务端 101 握手响应；成功 0。                                                         | `validate_handshake_response` | 去模块前缀+去类型名     | `ws.validate_handshake_response(...)` |
| `ws_encode_text_frame`           | 编码客户端 TEXT 帧（MASK=1）；返回帧总字节数。                                                | `encode_text_frame`           | 去模块前缀+去类型名     | `ws.encode_text_frame(...)`           |
| `ws_encode_binary_frame`         | 编码客户端 BINARY 帧（MASK=1）；返回帧总字节数。                                              | `encode_binary_frame`         | 去模块前缀+去类型名     | `ws.encode_binary_frame(...)`         |
| `ws_encode_ping_frame`           | 编码客户端 PING 帧；payload 可为空（0 长度心跳）。                                            | `encode_ping_frame`           | 去模块前缀+去类型名     | `ws.encode_ping_frame(...)`           |
| `ws_encode_pong_frame`           | 编码客户端 PONG 帧；通常 echo ping 负载。                                                | `encode_pong_frame`           | 去模块前缀+去类型名     | `ws.encode_pong_frame(...)`           |
| `ws_encode_close_frame`          | —                                                                            | `encode_close_frame`          | 去模块前缀+去类型名     | `ws.encode_close_frame(...)`          |
| `ws_decode_frame`                | 解析 WebSocket 帧；成功 0 并写 *out_payload_len。                                     | `decode_frame`                | 去模块前缀+去类型名     | `ws.decode_frame(...)`                |
| `ws_generate_key`                | 生成 Sec-WebSocket-Key（24 字符 Base64）；失败 -1。                                    | `generate_key`                | 去模块前缀+去类型名     | `ws.generate_key(...)`                |
| `ws_parse_url`                   | —                                                                            | `parse_url`                   | 去模块前缀+去类型名     | `ws.parse_url(...)`                   |
| `ws_client_handshake`            | —                                                                            | `handshake`                   | 去模块前缀+去类型名     | `ws.handshake(...)`                   |
| `ws_client_handshake_ctx`        | 带 Context 的客户端握手（已连接 fd）。                                                    | `handshake_ctx`               | 去模块前缀+去类型名     | `ws.handshake_ctx(...)`               |
| `ws_connect`                     | —                                                                            | `connect`                     | 去模块前缀+去类型名     | `ws.connect(...)`                     |
| `ws_connect_ctx_fd`              | —                                                                            | `connect_ctx_fd`              | 去模块前缀+去类型名     | `ws.connect_ctx_fd(...)`              |
| `ws_connect_ctx`                 | 带 Context 的 ws:// 连接；返回 WsStream（fd<0 含 net_err_* 负码）。                       | `connect_ctx`                 | 去模块前缀+去类型名     | `ws.connect_ctx(...)`                 |
| `ws_connect_tls`                 | —                                                                            | `connect_tls`                 | 去模块前缀+去类型名     | `ws.connect_tls(...)`                 |
| `ws_connect_tls_ctx_fd`          | 带 Context 的 wss:// 连接；成功返回 fd 并写 *out_tls，取消/过期返回 net_err_*。                 | `connect_tls_ctx_fd`          | 去模块前缀+去类型名     | `ws.connect_tls_ctx_fd(...)`          |
| `ws_connect_tls_ctx`             | 带 Context 的 wss:// 连接；返回 WsStream（fd<0 含 net_err_* 负码）。                      | `connect_tls_ctx`             | 去模块前缀+去类型名     | `ws.connect_tls_ctx(...)`             |
| `ws_connect_url`                 | —                                                                            | `connect_url`                 | 去模块前缀+去类型名     | `ws.connect_url(...)`                 |
| `ws_connect_url_ctx`             | —                                                                            | `connect_url_ctx`             | 去模块前缀+去类型名     | `ws.connect_url_ctx(...)`             |
| `ws_connect_url_ctx_stream`      | 带 Context 的 ws(s):// URL 连接；返回 WsStream。                                     | `connect_url_ctx_stream`      | 去模块前缀+去类型名     | `ws.connect_url_ctx_stream(...)`      |
| `ws_write_text`                  | 发送 TEXT 帧；成功返回写入 payload 字节数，失败 -1。                                          | `write_text`                  | 去模块前缀+去类型名     | `ws.write_text(...)`                  |
| `ws_write_binary`                | 发送 BINARY 帧；成功返回写入 payload 字节数，失败 -1。                                        | `write_binary`                | 去模块前缀+去类型名     | `ws.write_binary(...)`                |
| `ws_write_text_ctx`              | 带 Context 的 TEXT 发送；取消/过期短路，不写入。                                             | `write_text_ctx`              | 去模块前缀+去类型名     | `ws.write_text_ctx(...)`              |
| `ws_write_binary_ctx`            | 带 Context 的 BINARY 发送；取消/过期短路，不写入。                                           | `write_binary_ctx`            | 去模块前缀+去类型名     | `ws.write_binary_ctx(...)`            |
| `ws_read_frame`                  | 读取一帧；成功 ws_err_ok() 并写 opcode/payload_len。                                   | `read_frame`                  | 去模块前缀+去类型名     | `ws.read_frame(...)`                  |
| `ws_read_frame_ctx`              | 带 Context 的读帧；deadline 推导 timeout_ms。                                        | `read_frame_ctx`              | 去模块前缀+去类型名     | `ws.read_frame_ctx(...)`              |
| `ws_close`                       | 关闭 WebSocket 会话（TLS + TCP）。                                                  | `close`                       | 去模块前缀+去类型名     | `ws.close(...)`                       |
| `ws_extract_key_from_request`    | 从 HTTP Upgrade 请求提取 Sec-WebSocket-Key；成功返回 key 长度。                           | `extract_key_from_request`    | 去模块前缀+去类型名     | `ws.extract_key_from_request(...)`    |
| `ws_validate_upgrade_request`    | 校验客户端 WebSocket Upgrade 请求（GET + Upgrade + Version 13 + Key）；成功 ws_err_ok()。 | `validate_upgrade_request`    | 去模块前缀+去类型名     | `ws.validate_upgrade_request(...)`    |
| `ws_server_accept`               | —                                                                            | `accept`                      | 去模块前缀+去类型名     | `ws.accept(...)`                      |
| `ws_server_accept_ctx`           | 带 Context 的服务端 accept（101 + 帧层交接）。                                           | `accept_ctx`                  | 去模块前缀+去类型名     | `ws.accept_ctx(...)`                  |
| `ws_server_handshake`            | 服务端：从 fd 读取 Upgrade 请求并完成 101 握手；成功 ws_err_ok()。                             | `handshake`                   | 去模块前缀+去类型名     | `ws.handshake(...)`                   |
| `ws_server_handshake_ctx`        | 带 Context 的服务端握手。                                                            | `handshake_ctx`               | 去模块前缀+去类型名     | `ws.handshake_ctx(...)`               |
| `ws_encode_server_text_frame`    | 编码服务端 TEXT 帧（MASK=0，payload ≤ 125）；返回帧总字节数。                                  | `encode_server_text_frame`    | 去模块前缀+去类型名     | `ws.encode_server_text_frame(...)`    |
| `ws_encode_server_binary_frame`  | 编码服务端 BINARY 帧（MASK=0，payload ≤ 125）；返回帧总字节数。                                | `encode_server_binary_frame`  | 去模块前缀+去类型名     | `ws.encode_server_binary_frame(...)`  |
| `ws_server_write_text`           | 服务端发送 TEXT 帧（无掩码）；成功返回 payload 字节数。                                          | `write_text`                  | 去模块前缀+去类型名     | `ws.write_text(...)`                  |
| `ws_server_write_binary`         | 服务端发送 BINARY 帧（无掩码）；成功返回 payload 字节数。                                        | `write_binary`                | 去模块前缀+去类型名     | `ws.write_binary(...)`                |
| `ws_client_handshake_smoke` | C 层握手 socketpair 烟测；0 通过。 | `handshake_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `ws.handshake_smoke(...)` |
| `ws_parse_url_smoke` | ws(s):// URL 解析烟测；0 通过。 | `parse_url_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `ws.parse_url_smoke(...)` |
| `ws_server_accept_smoke` | 服务端 accept 烟测（请求解析 + socketpair 101）；0 通过。 | `accept_smoke` | 去模块前缀+去类型名；Tier-X 不 export | `ws.accept_smoke(...)` |
| `ws_is_implemented`              | WebSocket 模块是否可用（F-04 v3 纯 .sx）。                                             | `is_implemented`              | 去模块前缀+去类型名     | `ws.is_implemented(...)`              |


---

## 四、模块索引

- `std.async` (125) → `async`
- `std.atomic` (60) → `atomic`
- `std.backtrace` (6) → `backtrace`
- `std.base64` (18) → `base64`
- `std.bytes` (28) → `bytes`
- `std.cache` (35) → `cache`
- `std.channel` (51) → `channel`
- `std.cli` (15) → `cli`
- `std.codec` (41) → `codec`
- `std.compress` (40) → `compress`
- `std.compress.brotli` (10) → `brotli`
- `std.compress.gzip` (8) → `gzip`
- `std.compress.zlib` (2) → `zlib`
- `std.compress.zstd` (10) → `zstd`
- `std.config` (49) → `config`
- `std.context` (23) → `context`
- `std.crypto` (34) → `crypto`
- `std.csv` (18) → `csv`
- `std.datetime` (46) → `dt`
- `std.db` (13) → `db`
- `std.db.arrow` (56) → `arrow`
- `std.db.kv` (24) → `kv`
- `std.db.sqlite` (68) → `sqlite`
- `std.dynlib` (8) → `dynlib`
- `std.elf` (29) → `elf`
- `std.encoding` (47) → `enc`
- `std.env` (24) → `env`
- `std.error` (56) → `err`
- `std.ffi` (17) → `ffi`
- `std.fmt` (35) → `fmt`
- `std.fs` (87) → `fs`
- `std.hash` (34) → `hash`
- `std.heap` (51) → `heap`
- `std.http` (540) → `http`
- `std.io` (59) → `io`
- `std.json` (76) → `json`
- `std.log` (22) → `log`
- `std.map` (46) → `map`
- `std.math` (64) → `math`
- `std.mem` (8) → `mem`
- `std.metrics` (44) → `metrics`
- `std.net` (94) → `net`
- `std.option` (11) → `option`
- `std.path` (15) → `path`
- `std.process` (43) → `process`
- `std.queue` (29) → `queue`
- `std.random` (18) → `random`
- `std.regex` (12) → `regex`
- `std.result` (11) → `result`
- `std.runtime` (9) → `runtime`
- `std.schema` (37) → `schema`
- `std.security` (20) → `security`
- `std.set` (42) → `set`
- `std.simd` (31) → `simd`
- `std.socketio` (241) → `socket`
- `std.sort` (18) → `sort`
- `std.string` (62) → `str`
- `std.sync` (53) → `sync`
- `std.sys` (37) → `sys`
- `std.tar` (12) → `tar`
- `std.task` (38) → `task`
- `std.test` (32) → `test`
- `std.thread` (29) → `thread`
- `std.time` (39) → `time`
- `std.trace` (34) → `trace`
- `std.unicode` (23) → `unicode`
- `std.url` (19) → `url`
- `std.uuid` (13) → `uuid`
- `std.vec` (86) → `vec`
- `std.websocket` (58) → `ws`

---

> 简化名审计：**已全部符合**「函数名不含标量类型 token」规则（含 `bool`）。
> **一轮**（去 `_i32` / 模块前缀）→ **二轮**（去对象前缀 / `_2` 后缀）→ **三轮**（绑定 import 后去冗余前缀、合并同义 API、Tier 分级）。

## 五、后续实施（代码落地）

> **自举清单**：原则与改名同步义务见 [`analysis/自举前必须清单.md`](../analysis/自举前必须清单.md) **§4.4 S9**。

1. 编译器：函数重载（支撑 `print` / `read` / `heap.alloc` 等同名合并）。
2. `mod.sx` 仅 export **Tier-S / Tier-A** 简化名；**禁止新增**含标量类型 token 的公开 API。
3. 旧 `_*_i32` / 长名保留一版 `@deprecated` alias（自举完成后分批删除）。
4. 大模块（`http` / `socketio`）按 §二子路径表拆子 mod，避免 30+ 字符函数名。

---

## 六、API 可见性分级（Tier）

| 级别 | 字符目标 | export | 示例 |
| --- | --- | --- | --- |
| **Tier-S** 日常 | 3～12 | ✅ | `io.read` `vec.push` `fs.open` `str.trim` |
| **Tier-A** 进阶 | 12～20 | ✅ | `io.read_fixed` `fs.mmap_ro` `net.read_batch_provided` |
| **Tier-B** 子模块 | 按域拆分 | 子 mod | `hcli.client_get` `mtx.lock` |
| **Tier-X** 内部 | 任意 | ❌ | `*_smoke` `lock_diag_*` `coop_pingpong`（bench） |

清单表中「说明」列含 **Tier-X 不 export** 的条目，实施时不写入公开 `mod.sx`。

---

## 七、高频模块三轮精简对照（节选）

### std.io

| 原简化名 | 新简化名 | 绑定调用 |
| --- | --- | --- |
| `handle_stdin` | `stdin` | `io.stdin()` |
| `read_into` / `read_with_timeout` | `read` | `io.read(...)`（重载） |
| `print_str` / `print_i32` | `print` | `io.print(...)` |
| `read_ptr_len` | `ptr_len` | `io.ptr_len()` |
| `register_fixed_buffers` | `register_buffers` | `io.register_buffers(...)` |
| `io_uring_is_available` | `uring_ok` | `io.uring_ok()` |
| `timeout_ms_for_context` | `timeout_from_ctx` | `io.timeout_from_ctx(ctx)` |

### std.fs

| 原简化名 | 新简化名 | 绑定调用 |
| --- | --- | --- |
| `default_read_size` | `chunk_size` | `fs.chunk_size()` |
| `last_os_error` | `last_error` | `fs.last_error()` |
| `mmap_readonly` | `mmap_ro` | `fs.mmap_ro(...)` |
| `read_file_into` | `read_file` | `fs.read_file(...)` |

### std.sync

| 原简化名 | 新简化名 | 绑定调用 |
| --- | --- | --- |
| `mutex_new` | `new_mutex` | `sync.new_mutex()` |
| `mutex_lock` | `lock` | `sync.lock(m)` |
| `condvar_signal` | `notify_one` | `sync.notify_one(cv)` |

### std.async

| 原简化名 | 新简化名 | 绑定调用 |
| --- | --- | --- |
| `task_submit` | `submit` | `async.submit(fn)` |
| `bind_context` | `bind_ctx` | `async.bind_ctx(ctx)` |
| `drain_until_idle` | `drain_idle` | `async.drain_idle()` |
| `runtime_new` | `runtime` | `async.runtime(ctx)` |
| `runtime_drain` | `drain` | `async.drain(&rt)` |
| `io_pump_once` | `pump` | `async.pump()` |
| `multistream_client_build_parallel_get` | `client_parallel_get` | `hcli.client_parallel_get(...)`（Tier-B 子模块） |

### std.vec / std.heap

| 原简化名 | 新简化名 | 绑定调用 |
| --- | --- | --- |
| `extend_from_slice` | `extend` | `vec.extend(&v, slice)` |
| `push_with_allocator` | `push` | `vec.push(&v, x)`（`.al` 已绑定） |
| `arena64_init` | `arena_init` | `heap.arena64_init(&a, cap)` |
| `allocator_alloc` | `alloc` | `heap.alloc(&alloc, n)` |

完整对照见 §三 各模块清单（「简化名称」「绑定调用」列）。
