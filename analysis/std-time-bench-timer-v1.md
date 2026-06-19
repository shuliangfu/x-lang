# STD-133：std.time benchmark 计时器 v1

> 状态：**定版（v1，纯 .sx 封装单调时钟）**

## API

| 名称 | 说明 |
|------|------|
| `Timer` | 单调计时状态（`start_ns`） |
| `timer_start` / `timer_reset` | 起点捕获与重置 |
| `timer_elapsed_ns/us/ms/sec` | 已用时长（多单位） |
| `timer_lap_ns` | 分段计时并推进起点 |

底层仍使用 `now_monotonic_ns` + `duration_ns`；无堆分配、无额外 C 代码。

## 门禁

`./tests/run-std-time-bench-timer-gate.sh`
