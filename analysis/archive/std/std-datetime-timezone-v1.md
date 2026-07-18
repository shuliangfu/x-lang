# STD-135：std.datetime 固定偏移时区 v1

> 状态：**定版（v1，内置名 + ±HH:MM；无 IANA DST 表）**

## API

| 名称 | 说明 |
|------|------|
| `TimeZone` | 固定 offset_min（东为正） |
| `timezone_utc` / `timezone_local` / `timezone_fixed` | 构造 |
| `timezone_from_name` | UTC/JST/CST/HKT/IST/CET/EST/PST 等 |
| `parse_offset_min` | `+08:00` / `-0500` / `Z` |
| `to_zoned_fields` / `from_zoned_fields` | UTC ↔ 墙钟字段 |
| `timezone_smoke` | C 金样 |

完整 IANA 时区表与 DST 规则留待后续；v1 覆盖工程常见固定偏移与 RFC3339 偏移文本。

## 门禁

`./tests/run-std-datetime-timezone-gate.sh`
