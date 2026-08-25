# STD-043：std.thread 线程池与命名线程 v1

> 更新时间：2026-08-26（honesty soft→硬绿）· 原稿 2026-06-17  
> 状态：**定版（v1）+ gate honesty**  
> 关联：STD-041/042 async worker、`std.net` 多 worker

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 + §5 Gate |
| 2 | `tests/baseline/std-thread-pool.tsv` |
| 3 | `./tests/run-std-thread-pool-gate.sh` |
| 4 | 烟测：`tests/thread/pool_roundtrip.x` |

---

## 2. 命名线程

| 产品短名（`std.thread`） | C / glue | 说明 |
|--------------------------|----------|------|
| `set_name_self(name, len)` | `thread_set_name_self_c` | 当前线程名，≤15 字节 + NUL |

| 平台 | 实现 |
|------|------|
| Linux | `pthread_setname_np(self, name)` |
| macOS | `pthread_setname_np(name)` |
| Windows | v1 返回 -1（后续 `SetThreadDescription`） |

化石名 `thread_set_name_self` 已退役；TSV／闸 API 锚对齐产品短名。

---

## 3. 固定 worker 线程池（v1）

| 产品短名（`std.thread`） | C / glue | 说明 |
|--------------------------|----------|------|
| `start(workers)` | `thread_pool_start_c` | 1..8 worker；POSIX 0 成功 |
| `submit(entry, arg)` | `thread_pool_submit_c` | C 入口 `void* (*)(void*)` |
| `drain()` | `thread_pool_drain_c` | 阻塞至队列与 in-flight 皆空 |
| `stop()` | `thread_pool_stop_c` | 停止并 join；可再次 start |
| `pending()` | `thread_pool_pending_c` | 观测：队列 + in-flight |

**语义**：

- 全局单例池；`submit` 队列满时阻塞（cap=128）。
- entry 须为 C 函数地址（与 `thread_create` 相同约束）；`.x` 烟测用 `thread.dummy_entry_ptr()`。
- **Windows v1**：池 API 返回 -1；烟测 skip（exit 0）。

与 `thread.create` 区别：池复用 worker，适合大量短任务；长阻塞任务仍用独立 `create`。

化石前缀 `thread_pool_*` 仅保留在 C glue／`extern`；产品 export 为短名（上表）。`thread_pool_start` 等词仍可出现在本文 changelog／历史叙述。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 命名线程 + POSIX 线程池 + gate |
| honesty | 2026-08-26 | soft→硬绿：prefer asm；API 锚对齐短名；`## 5. Gate`；check 观测 |

---

## 5. Gate

```bash
./tests/run-std-thread-pool-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期暂停闸门，2026-08-05）；CHK 红不硬失败。
- `pool_roundtrip.x` + `main.x` **exit 0 硬失败**（有 native xlang 时 **无 soft SKIP**）。
- API 锚 = 产品短名 `set_name_self`／`start`／`submit`／`drain`／`stop`／`pending`。

期望报告：

```
xlang: [XLANG_STD_THREAD_POOL] status=ok check=? pool=1 name=1 main=1 skip=0
```

- `check=` 观测（Darwin 常 0／Ubuntu 常 1，均不挡硬绿）。
- 硬绿信号 = `pool=1` + `main=1` + `skip=0`。

烟测：`pool_roundtrip.x` — 2 worker × 8 submit + drain + stop；`set_name_self("shu-main")`。

回归：`tests/thread/main.x`（spawn/join）。
