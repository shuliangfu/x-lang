# STD-106：std.log 日志轮转 + 异步缓冲 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`tests/baseline/std-log-rotate-async.tsv` · STD-053 multi-sink

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-log-rotate-async.tsv` |
| 3 | `./tests/run-std-log-rotate-async-gate.sh` |

---

## 2. 轮转语义

| API | 说明 |
|-----|------|
| `set_rotate_limit(max_bytes, max_backups)` | 文件 sink 超 `max_bytes` 时轮转 |
| `max_backups=0` | 截断当前文件（rename 无备份） |
| `max_backups=1..8` | `path` → `path.1` → … → `path.N` |

须先 `set_file_sink` 并启用 `SINK_FILE`。

---

## 3. 异步缓冲

| API | 说明 |
|-----|------|
| `set_async_enabled(1)` | 日志行入环形缓冲（32 槽 × 512B），不立即 I/O |
| `async_flush()` | 刷出缓冲到活跃 sink（stderr / file） |
| `set_async_enabled(0)` | 恢复同步直写 |

队列满时自动 `async_flush` 再入队。

---

## 4. 金样

| 场景 | 期望 |
|------|------|
| async defer | `flush` 前文件不含 `async1` |
| async flush | flush 后含 `[INFO] async1` |
| rotate | 写满 48B 后备份 `path.1` 存在 |

产品烟测：`tests/std-log/rotate_async.x`（async on → log → flush → rotate limit → async off；exit 0）。

---

## 5. Gate

```bash
./tests/run-std-log-rotate-async-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `rotate_async.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- C smoke **仅观测**（archaeology host-C；非硬绿信号）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）

manifest：`tests/baseline/std-log-rotate-async.tsv`

```
xlang: [XLANG_STD106_LOG_ROTATE_ASYNC] status=ok check=0|1 run=1 skip=0
std-log-rotate-async gate OK
```

### 5.1 Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；C smoke 观测；未啃产品 `std/log`）。
- 2026-06-18：v1 定版（轮转 + 异步缓冲 API／金样）。
