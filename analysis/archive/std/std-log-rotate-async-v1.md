# STD-106：std.log 日志轮转 + 异步缓冲 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-log-rotate-async.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
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

---

## 5. 门禁

```bash
make -C compiler ../std/log/log.o
./tests/run-std-log-rotate-async-gate.sh
```
