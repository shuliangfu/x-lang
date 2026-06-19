# STD-074 std.datetime v1

> 更新时间：2026-06-18  
> 状态：**可用** — DateTime + RFC3339 + Duration + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-datetime-manifest.tsv` |
| 3 | `./tests/run-std-datetime-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `DateTime` / `now_utc` / `from_unix` | UTC 墙钟表示 |
| `DateFields` / `from_utc_fields` / `to_utc_fields` | 日历字段 |
| `parse_rfc3339` / `format_rfc3339` / `format_rfc3339_nano` | RFC3339 与 Nano |
| `local_offset_min` / `to_local_fields` | 平台本地时区偏移 |
| `Duration` / `add_duration` / `duration_between` | 纳秒算术 |
| `duration_sleep` / `duration_from_monotonic` | 与 std.time 互操作 |
| `compare` | 时刻比较 |

实现：`std/datetime/mod.sx` + `std/datetime/datetime.c`；墙钟复用 `std.time`。

---

## 3. Gate

```
shux: [SHUX_STD_DATETIME] status=ok c_smoke=1 su=1 skip=0
std-datetime gate OK
```

向量：`tests/baseline/std-datetime-vectors.tsv`。
