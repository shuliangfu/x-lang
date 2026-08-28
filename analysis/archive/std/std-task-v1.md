# STD-089 std.task v1

> 更新时间：2026-08-28  
> 状态：**可用** — TaskGroup/JoinSet + context 取消 + leak 检测 + gate（soft→硬绿）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-task-manifest.tsv` |
| 3 | `./tests/run-std-task-gate.sh` |

---

## 2. API

产品短名（`std/task/mod.x`）：

| API | 说明 |
|-----|------|
| `new` / `spawn` / `join` | 组内 spawn + drain |
| `bind` / `cancel` | Context 取消传播 |
| `check_leak` | 结构化并发边界 |
| `set_new` / `set_spawn` / `set_join` | JoinSet 批量 join |
| `retry` | 失败重试 + 退避 |

实现：`std/task/mod.x` + `std/task/task.x`（F-task v2 纯 .x）；链入 scheduler + context + time。

---

## Gate

Honesty（2026-08-28）：prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／`c_smoke=`／`x=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C／tip product `-o` UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。

```
xlang: [XLANG_STD_TASK] status=ok run=N obs=M skip=0
std-task gate OK
```

---

## 4. 后续（非 v1 阻塞）

- language `spawn` 语法糖直接入组  
- 1M task 压测纳入 CI  
- 与 std.trace span 自动绑定  
- tip `std_task_*` 产品 UNDEF 另案  
