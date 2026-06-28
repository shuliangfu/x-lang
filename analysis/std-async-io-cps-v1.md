# STD-042：std.async IO 与 CPS suspend 统一文档 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-041（language bridge）、`std.io` IO-A5 async API、`std/async/scheduler.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-async-io-cps.tsv` |
| 3 | `./tests/run-std-async-io-cps-gate.sh` |
| 4 | 烟测：`tests/async/io_cps_align.sx`；emit：`tests/parser/async_await_io.sx` |

---

## 2. 三层统一模型

```
language await read/write/read_fd
        ↓ codegen (IO-A5)
  submit_read_async / submit_write_async   ← std.io
  shu_async_cps_suspend_io                 ← scheduler.c
        ↓ drain_until_idle 循环
  shu_io_poll_async_completions            ← std.io/io.c
  resume IO 等待队列 + 就绪环 drain
        ↓ 门面
  import("std.async") → cps_suspend_io / poll_io_completions / drain_until_idle
  import("std.io")    → read_async / complete_* / IO_ASYNC_NOT_READY
```

| 层 | 职责 | 关键符号 |
|----|------|----------|
| **std.io** | 非阻塞 I/O 槽位 submit/complete；CQE poll | `read_async`、`write_async`、`complete_*_slot`、`poll_async_completions`、`IO_ASYNC_NOT_READY`（-2） |
| **scheduler.c** | CPS 帧 suspend/resume；IO 等待队列 | `shu_async_cps_suspend_io`、`shu_async_run_drain_until_idle`、`shu_async_io_waiters_pending` |
| **std.async** | 业务门面；与 language drain 对齐 | `cps_suspend_io`、`poll_io_completions`、`wait_completion`、`drain_until_idle` |

---

## 3. std.io async API 对齐表（v1）

| std.io | 语义 | await codegen 使用 |
|--------|------|-------------------|
| `read_async(h, ptr, len)` | 提交 read 槽；返回 slot≥0 | `await read` / `await read_fd` 首段 |
| `complete_read_async_slot(slot)` | 收割；`-2`=未就绪 | await 恢复后 complete |
| `write_async` / `complete_write_async_slot` | 写路径对称 | `await write` |
| `poll_async_completions(ms)` | 收割 CQE + 唤醒 scheduler | `drain_until_idle` 内 |
| `wait_readable(fds, n, ms)` | 多 fd 就绪等待 | `wait_completion` 门面 |
| `IO_ASYNC_NOT_READY` | 常量 -2 | 轮询未就绪 |

**环境变量**：

| 变量 | 效果 |
|------|------|
| `SHUX_ASYNC_YIELD=1` | `cps_suspend_io` 在 await 边界 yield（返回非 0） |
| `SHUX_IO_ASYNC_SLOTS` | async 槽位数 1..32（默认 8） |

---

## 4. language await IO 代码生成（摘要）

`await read(handle, ptr, len, timeout)`（及 `read_fd`/`write`）：

1. `read_async` / `write_async` 提交 SQE，记录 slot；
2. `shu_async_cps_suspend_io(&__phase, next)` — 协程挂起；
3. `drain_until_idle`：`poll_async_completions` → 唤醒 IO 等待者 → `complete_*_slot`；
4. 帧 resume 后读取完成字节数。

烟测 emit：`tests/parser/async_await_io.sx` 须含 `shu_async_cps_suspend_io` 与 `submit_read_async`。

---

## 5. std.async 新增门面（STD-042）

| API | 委托 |
|-----|------|
| `cps_suspend_io(phase, next_phase)` | `shu_async_cps_suspend_io` |
| `poll_completions(timeout_ms)` | `shux_io_poll_async_completions` |
| `drain_idle()` | `shux_async_run_drain_until_idle` |

与 STD-041 组合：`scheduler_reset` → `run`/`spawn` → `drain_idle`（内含 poll IO；C 层仍称 `drain_until_idle`）。

---

## 6. 验证与门禁

```bash
./tests/run-std-async-io-cps-gate.sh
```

```
shux: [SHUX_STD_ASYNC_IO_CPS] status=ok align=1 emit=1 skip=0
```

---

## 7. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.2 | 2026-06-28 | S9 API 简写：`poll_completions` / `drain_idle` / `uring_ok` / `pump` / `complete_read` |
| v1.1 | 2026-06-19 | STD-049：`io_uring_is_available` / async IO 门面 re-export / `io_pump_once` / `poll_loop_ctx` |
| v1 | 2026-06-17 | IO/CPS 统一 RFC + 门面对齐 + 烟测 |

---

## 8. STD-049 io_uring 完整路径（std.async 门面）

业务侧仅需 `import("std.async")` 即可手动驱动 IO async + CPS，无需同时引用 std.io async 符号。

| API | 委托 |
|-----|------|
| `IO_ASYNC_NOT_READY` | 常量 -2 |
| `uring_ok()` | `std.io.io_uring_is_available`（旧名 `io_uring_is_available`） |
| `read_async` / `write_async` | `std.io` 同名 |
| `read_async_fd` / `write_async_fd` | `handle_from_fd` + async submit |
| `complete_read` / `complete_write` | `std.io.complete_read_async_slot` / `complete_write_async_slot` |
| `pump()` | `poll_completions(0)` + `drain_idle`（旧名 `io_pump_once` + `drain_until_idle`） |
| `poll_loop_ctx(rt, max_rounds)` | Context deadline poll + drain；取消/超时返回 net_err_* |

烟测：`tests/async/io_uring_facade.sx`。
