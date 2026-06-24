# 阶段 F-datetime v2（std.datetime 逻辑 .sx 下沉 + F-ZC）

> **F-datetime v2**：RFC3339/Duration/固定偏移/IANA DST 迁入 **`datetime.sx`**；**F-ZC** 删除 **`datetime_tz_glue.c`**，本地偏移经 **`time_wall_local_offset_min_c`**（std.time）。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| datetime 逻辑 | `datetime_glue.c` | **`datetime.sx`** | 同 v2 |
| 本地时区偏移 | glue 内联 | `datetime_tz_glue.c` | **`.sx` → std.time extern** |
| `datetime.o` | `ld -r` glue + sx | `ld -r` tz glue + sx | **纯 `.sx`** |

## 门禁

```bash
SHUX_F_DATETIME_V2_FAIL=1 ./tests/run-f-datetime-v2-gate.sh
./tests/run-std-datetime-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场 ffi_cb_glue / process_arg 等
