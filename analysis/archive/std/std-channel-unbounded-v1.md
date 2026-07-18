# STD-044：std.channel 无界模式与关闭语义 v1

> 更新时间：2026-06-27  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-channel-api.tsv`（Tier-S）、`tests/sanitize/std_channel_asan.x`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-channel-unbounded.tsv` |
| 3 | `./tests/run-std-channel-unbounded-gate.sh` |
| 4 | 烟测：`tests/channel/unbounded_roundtrip.x` |

---

## 2. 无界模式语义

| API | 说明 |
|-----|------|
| `unbounded()` | 创建无界 channel；失败 0（Windows stub） |
| `send_unbounded(ch, val)` | 委托 `send`；**不因满阻塞**，内部 cap 翻倍扩容 |
| `try_recv_unbounded(ch, out)` | 委托 `try_recv` |

**与有界区别**：

| 操作 | 有界 | 无界 |
|------|------|------|
| send 满 | 阻塞（或 try_send→1） | realloc 扩容 |
| 初始 cap | 用户指定 | 16（`UNBOUNDED_INIT_CAP`） |
| growth | 固定 | ×2 直至容纳 |

v1 仅 **i32** channel；泛型 channel 留待后续 RFC。

---

## 2.3 关闭语义

| API | 说明 |
|-----|------|
| `unbounded_close(ch)` | 委托 `close`；`closed=1` 并 broadcast |
| `unbounded_is_closed(ch)` | 委托 `is_closed` |
| `free(ch)` | 销毁；须先 close 或确认无并发使用 |

**关闭后行为**（金样 `unbounded_roundtrip.x`）：

| 操作 | 队列非空 | 队列空且已关闭 |
|------|----------|----------------|
| `try_recv` | 0，取出值 | **-1** |
| `send` / `send_unbounded` | — | **-1** |
| `recv`（阻塞） | 0 | **-1**（唤醒后） |

`is_closed`：关闭前 0，关闭后 1。

---

## 3. 平台

| 平台 | 行为 |
|------|------|
| POSIX | pthread mutex/cond；完整实现 |
| Windows | v1 stub（create 返回 0）；烟测 skip exit 0 |

---

## 4. 验证与门禁

```bash
./tests/run-std-channel-unbounded-gate.sh
```

```
shux: [SHUX_STD_CHANNEL_UNBOUNDED] status=ok unbounded=1 main=1 skip=0
```

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 无界语义文档 + is_closed + gate |
| v1.1 | 2026-06-27 | API 简写：unbounded/close/free 等 |
