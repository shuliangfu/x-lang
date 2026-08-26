# 阶段 F-datetime v2（std.datetime 逻辑 .x 下沉 + F-ZC）

> **F-datetime v2**：RFC3339/Duration/固定偏移/IANA DST 迁入 **`datetime.x`**；**F-ZC** 删除 **`datetime_tz_glue.c`**，本地偏移经 **`time_wall_local_offset_min_c`**（std.time）。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| datetime 逻辑 | `datetime_glue.c` | **`datetime.x`** | 同 v2 |
| 本地时区偏移 | glue 内联 | `datetime_tz_glue.c` | **`.x` → std.time extern** |
| `datetime.o` | `ld -r` glue + x | `ld -r` tz glue + x | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_DATETIME_V2_FAIL` retired. Delegates STD-074 datetime + STD-135 timezone + STD-136 iana hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-datetime-v2-gate.sh
./tests/run-std-datetime-gate.sh
./tests/run-std-datetime-timezone-gate.sh
./tests/run-std-datetime-iana-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场 ffi_cb_glue / process_arg 等
