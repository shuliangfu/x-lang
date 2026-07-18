# STD-041 std.async 与 language async/await 对接 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-004`（scheduler API）、`tests/run-async.sh`、`compiler/src/async/`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-041 | 语言 `async`/`await`/`run`/`spawn` 与 `std.async` scheduler **对接文档 + 烟测 + 1M gate** |
| 验收 | `run-std-async-language-gate.sh` 全绿；`run-std-async-1m-gate.sh` 持续绿 |

---

## 2. 分层对接

```
.x 源码
  async function f(...) { await ... }
  run f(args)  /  spawn f(args)
        ↓ codegen (async_cps_codegen.c)
  static 帧 + switch(__phase)
  shu_async_cps_suspend[_io]
  shu_async_sched_<name> → shu_async_run_i32 / shu_async_task_submit
        ↓ 链接
  std/async/scheduler.c
        ↓ 门面
  import("std.async")  →  scheduler_reset / drain_idle / coop_pingpong
```

| 语言构造 | codegen / 运行时 | std.async 门面 |
|----------|------------------|----------------|
| `async fn` | CPS 帧、`shu_async_sched_<fn>` | — |
| `await expr` | `shu_async_cps_suspend` | `SHUX_ASYNC_SUSPENDED` |
| `await read(...)` 等 | `shu_async_cps_suspend_io` + IO 槽 | `wait_completion` |
| `run async_fn(args)` | seed 队列 + `shu_async_run_i32` | `scheduler_reset`（批次前） |
| `spawn async_fn(args)` | seed + `shu_async_task_submit` | `drain_idle` |
| `import("std.async")` | runtime `nm -u` 按需链入 `scheduler.o` | 模块符号 |

---

## 3. std.async 新增门面（STD-041）

| API | 说明 |
|-----|------|
| `scheduler_reset()` | `shu_async_run_seed_reset` + `shu_async_queue_reset` |
| `drain_idle()` | `shu_async_run_drain_until_idle`（spawn 后批量完成） |

**extern 重声明注意**：含 `run`/`spawn` 的 `.x` 与 `import("std.async")` **同文件**时，codegen 会 emit `int32_t (*)(void)` 形参的 `shu_async_run_i32` 等，与 `mod.x` 中 `*u8` extern **冲突**。v1 约定：

- **语言烟测**（`run`/`spawn`）：单 TU 不 `import("std.async")`，或仅本地 `extern` drain/reset。
- **模块烟测**（`import("std.async")`）：调用门面函数，不在同文件使用 `run`/`spawn`。

后续语言阶段可统一 function-pointer extern 类型（见 NEXT LANG 待办）。

---

## 4. 烟测

| 脚本 | 验证 |
|------|------|
| `tests/async/await_scheduler_run.x` | `run add_two` 双 await + seed 队列 → 42 |
| `tests/async/await_scheduler_mod.x` | `import("std.async")` + `scheduler_reset` + `coop_pingpong` |

---

## 5. 1M task 压测

委托 `tests/run-std-async-1m-gate.sh`（STD-004 矩阵）：

- `async_1m_coop`：`import("std.async")` + `coop_pingpong` 各 1M
- `async_switch`：手工 CoopFrame 2M steps

---

## 6. 门禁

```bash
./tests/run-std-async-language-gate.sh
```

manifest：`tests/baseline/std-async-language.tsv`

**STD-042**：IO await 与 CPS suspend 统一见 `analysis/std-async-io-cps-v1.md`。
