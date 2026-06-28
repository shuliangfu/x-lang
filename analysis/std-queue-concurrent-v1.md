# STD-048：std.queue 并发安全可选封装 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`Queue_i32`（单线程）、`std.sync`、`std.channel`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-queue-concurrent.tsv` |
| 3 | `./tests/run-std-queue-concurrent-gate.sh` |
| 4 | 烟测：`tests/queue/sync_queue_roundtrip.sx` |

---

## 2. SyncQueue_i32 API（可选封装）

在既有 `Queue_i32` 外包一层 `mutex`（`std.sync`），**不**改变单线程 API。

| API | 说明 |
|-----|------|
| `sync_new` / `sync_deinit` | 创建/销毁 |
| `sync_push` | 加锁 `push_back` |
| `sync_try_pop` | 加锁弹出；0 成功，1 空，-1 失败 |
| `sync_queue_len` / `sync_queue_is_empty` | 加锁读状态 |
| `sync_queue_contention_smoke` | C 层双线程 push 烟测 |

v1 **无阻塞 pop**；需阻塞等待请用 `std.channel`。

---

## 3. 与 sync / channel 选型对比

| 场景 | 推荐 | 原因 |
|------|------|------|
| 单线程 deque / BFS | `Queue_i32` | 零锁开销 |
| 多线程共享 deque、可轮询 | `SyncQueue_i32` | mutex + 既有环形缓冲 |
| 生产者-消费者、阻塞/关闭 | `std.channel` | condvar + 有界/无界语义 |
| 多读单写计数/标志 | `std.atomic` / `RwLock` | 非队列结构 |

| 维度 | `Queue_i32` | `SyncQueue_i32` | `channel_i32` |
|------|-------------|-----------------|---------------|
| 线程安全 | 否 | 是（mutex） | 是 |
| 阻塞 recv | — | 否（仅 try） | 是 |
| 关闭语义 | — | 否 | 是（STD-044） |
| 双端操作 | push/pop 两端 | 同左（加锁） | 单端 FIFO |

---

## 4. 门禁

```bash
./tests/run-std-queue-concurrent-gate.sh
```

```
shux: [SHUX_STD_QUEUE_CONCURRENT] status=ok sync=1 main=1 smoke=1 skip=0
```

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | SyncQueue_i32 + 选型文档 + 竞争烟测 |
