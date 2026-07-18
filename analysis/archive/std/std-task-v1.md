# STD-089 std.task v1

> 更新时间：2026-06-18  
> 状态：**可用** — TaskGroup/JoinSet + context 取消 + leak 检测 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-task-manifest.tsv` |
| 3 | `./tests/run-std-task-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `task_group_new` / `task_group_spawn` / `task_group_join` | 组内 spawn + drain |
| `task_group_bind_context/cancel` | Context 取消传播 |
| `task_group_check_leak` | 结构化并发边界 |
| `join_set_*` | 批量 join 集合 |
| `supervise_retry` | 失败重试 + 退避 |

实现：`std/task/mod.x` + `std/task/task.x`（F-task v2 纯 .x）；链入 scheduler + context + time。

---

## 3. Gate

```
shux: [SHUX_STD_TASK] status=ok c_smoke=1 x=1 skip=0
std-task gate OK
```

---

## 4. 后续（非 v1 阻塞）

- language `spawn` 语法糖直接入组  
- 1M task 压测纳入 CI  
- 与 std.trace span 自动绑定  
