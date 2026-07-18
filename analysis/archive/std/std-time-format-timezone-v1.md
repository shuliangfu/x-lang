# STD-137：std.time 墙钟格式化与时区偏移 v1

> 状态：**定版（v1）**  
> 高层 DateTime/命名时区见 `std.datetime`（STD-135）

## API

| 名称 | 说明 |
|------|------|
| `format_wall_rfc3339` | 当前墙钟 UTC → RFC3339（Z） |
| `wall_local_offset_min` | 本地相对 UTC 偏移（分钟） |
| `format_timezone_smoke` | C 金样 |

C 层委托 `datetime_format_rfc3339_c` / `datetime_local_offset_min_c`，避免 `.x` 循环 import。

## 门禁

`./tests/run-std-time-format-timezone-gate.sh`
