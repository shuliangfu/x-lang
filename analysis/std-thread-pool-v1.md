# STD-043：std.thread 线程池与命名线程 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-041/042 async worker、`std.net` 多 worker

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-thread-pool.tsv` |
| 3 | `./tests/run-std-thread-pool-gate.sh` |
| 4 | 烟测：`tests/thread/pool_roundtrip.x` |

---

## 2. 命名线程

| API | 说明 |
|-----|------|
| `thread_set_name_self(name, len)` | 当前线程名，≤15 字节 + NUL |

| 平台 | 实现 |
|------|------|
| Linux | `pthread_setname_np(self, name)` |
| macOS | `pthread_setname_np(name)` |
| Windows | v1 返回 -1（后续 `SetThreadDescription`） |

---

## 3. 固定 worker 线程池（v1）

| API | 说明 |
|-----|------|
| `thread_pool_start(workers)` | 1..8 worker；POSIX 0 成功 |
| `thread_pool_submit(entry, arg)` | C 入口 `void* (*)(void*)` |
| `thread_pool_drain()` | 阻塞至队列与 in-flight 皆空 |
| `thread_pool_stop()` | 停止并 join；可再次 start |
| `thread_pool_pending()` | 观测：队列 + in-flight |

**语义**：

- 全局单例池；`submit` 队列满时阻塞（cap=128）。
- entry 须为 C 函数地址（与 `thread_create` 相同约束）；`.x` 烟测用 `thread_dummy_entry_ptr()`。
- **Windows v1**：池 API 返回 -1；烟测 skip（exit 0）。

与 `thread_create` 区别：池复用 worker，适合大量短任务；长阻塞任务仍用独立 `thread_create`。

---

## 4. 验证与门禁

```bash
./tests/run-std-thread-pool-gate.sh
```

```
shux: [SHUX_STD_THREAD_POOL] status=ok pool=1 name=1 main=1 skip=0
```

烟测：`pool_roundtrip.x` — 2 worker × 8 submit + drain + stop；`thread_set_name_self("shux-main")`。

回归：`tests/thread/main.x`（spawn/join）。

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 命名线程 + POSIX 线程池 + gate |
