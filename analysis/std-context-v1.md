# STD-071 std.context v1

> 更新时间：2026-06-18  
> 状态：**可用** — 取消/deadline 传播 + value bag + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-context-manifest.tsv` |
| 3 | `./tests/run-std-context-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `background()` | 根上下文，永不取消 |
| `with_cancel(parent)` | 可取消子上下文 |
| `with_deadline(parent, ns)` | 绝对单调 deadline |
| `with_timeout(parent, ns)` | 相对超时 |
| `cancel(ctx)` | 取消 |
| `is_cancelled(ctx)` | 1/0，沿父链检查 |
| `deadline_ns(ctx)` | 有效 deadline，0=无 |
| `remaining_ns(ctx)` | 剩余纳秒，过期/取消=0 |
| `set_value` / `get_value` | 轻量键值 bag（8 槽） |
| `free(ctx)` | 释放派生节点 |

实现：`std/context/mod.x` + `std/context/context.x`（F-context v2 纯 .x）；依赖 `std.time` 单调时钟。

---

## 3. Gate

```
shux: [SHUX_STD_CONTEXT] status=ok c_smoke=1 x=1 skip=0
std-context gate OK
```

---

## 4. 后续集成（非 v1 阻塞）

- `std.io` / `std.net` / `std.http` 接受 Context 或 deadline
- `std.async` spawn 绑定 Context 传播取消
