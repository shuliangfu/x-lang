# 阶段 F-time v1（std.time 去 C）

> **F-time v1 / F-ZC**：删除 **`time.c`**；锚点 **`time.sx`**（纯 .sx → **`time.o`**）；OS syscall 在 **`runtime_time_os.c`**（compiler runtime）。

## 变更

| 项 | 旧 | 现 |
|----|----|-----|
| 派生单位 / duration / 烟测 | `time.c` | **`time.sx`** |
| OS 单调/墙钟/sleep/format/offset | `time_os_glue.c` | **`runtime_time_os.c`**（已迁出 std/） |
| `time.o` | ld -r glue + .sx | **纯 `.sx`** |

## 符号

- `time_now_monotonic_ns_c` 等 5 个 OS 符号 — compiler runtime
- `time_now_monotonic_us_c` / `time_sleep_ms_c` / `time_format_timezone_smoke_c` — `time.sx`

## 门禁

```bash
SHUX_F_TIME_V1_FAIL=1 ./tests/run-f-time-v1-gate.sh
./tests/run-std-time-gate.sh
./tests/run-std-time-format-timezone-gate.sh
```

## 下一项

- **Z8** 其它 OS 胶层（`log_os_glue.c`、`log_os_glue.c` 等）
