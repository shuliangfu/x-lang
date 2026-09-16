# STD-048：std.queue 并发安全可选封装 v1

> 更新时间：2026-08-28（honesty residual XLANG fallthrough／auto-make →硬绿）· 原稿 2026-06-18  
> 状态：**定版（v1.2）** · Gate honesty residual XLANG fallthrough／auto-make →硬绿  
> 关联：`Queue_i32`（单线程）、`std.sync`、`std.channel`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-queue-concurrent.tsv` |
| 3 | `./tests/run-std-queue-concurrent-gate.sh` |
| 4 | 烟测：`tests/queue/sync_queue_roundtrip.x` |

---

## 2. SyncQueue_i32 API（可选封装）

在既有 `Queue_i32` 外包一层 `mutex`（`std.sync`），**不**改变单线程 API。

| API | 说明 |
|-----|------|
| `sync_new` / `sync_deinit` | 创建/销毁 |
| `sync_push` | 加锁 `push_back` |
| `sync_try_pop` | 加锁弹出；0 成功，1 空，-1 失败 |
| `length` / `is_empty`（`SyncQueue_i32` overload） | 加锁读状态（旧名 `sync_queue_len` / `sync_queue_is_empty`） |
| `sync_smoke` | 门面；委托 C `sync_queue_contention_smoke_c` 双线程 push 烟测 |

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

## 4. Gate

```bash
./tests/run-std-queue-concurrent-gate.sh
```

Honesty residual（2026-08-28）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- 显式坏 `XLANG`／缺 native **硬 die**（拒 XLANG fallthrough／soft auto-make／prefer-c／soft SKIP→OK／soft `ensure_std_c_o` 重建／extra CLI `.o`／C contention auto-make）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `tests/queue/main.x`（`Queue_i32`）产品 `-o` **exit 0 硬失败**（硬绿信号＝`run=`）
- `sync_queue_roundtrip.x` **观测**（SyncQueue / queue-sync 产品 UNDEF residual — not soft）
- Host-C archaeology **仅观测**（现成 `std/queue/queue.o`＋`std/sync/sync.o`＋`compiler/runtime_queue_contention.o` only；拒 ensure／auto-make 重建；不传 extra CLI `.o`；C smoke 文件存在仍 TSV 必有，compile/run 非绿）
- 报告行：`run=`／`obs=`／`skip=`（退役 `check=`／`main=`／`sync=`／`c=` 当硬绿）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）
- 保留 `## 4. Gate`
- 关键词：STD-048／SyncQueue_i32／std.channel／sync_smoke／sync_queue_contention_smoke_c

manifest：`tests/baseline/std-queue-concurrent.tsv`

```
xlang: [XLANG_STD_QUEUE_CONCURRENT] status=ok run=1 obs=0|1|2 skip=0
std-queue-concurrent gate OK
```

F-queue v1／v2 仍硬委托本闸（须保持 exit 0）。

### 4.1 Changelog

- 2026-06-18：v1 SyncQueue_i32 + 选型文档 + 竞争烟测。
- 2026-08-26：Honesty v1.1（prefer asm；check／sync／C 观测；`## 4. Gate`；报告 `check=`／`main=`／`sync=`／`c=`）。
- 2026-08-28：Honesty residual v1.2（拒 XLANG fallthrough／auto-make／bootstrap-link／ensure 重建／C contention auto-make；报告 `run=`／`obs=`／`skip=`；未啃产品 `std/queue`）。

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | SyncQueue_i32 + 选型文档 + 竞争烟测 |
| v1.1 | 2026-08-26 | Gate honesty：`## 4. Gate`；prefer asm；main 硬绿；sync／C 观测 |
| v1.2 | 2026-08-28 | Honesty residual：拒 XLANG fallthrough／auto-make／ensure；报告 `run=`／`obs=`／`skip=` |
