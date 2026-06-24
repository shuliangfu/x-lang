# 阶段 F-datetime v1（std.datetime 去 C）

> **F-datetime v1**：删除 **`datetime.c`**；锚点 **`datetime.sx`**；RFC3339/时区在 **`datetime_glue.c`**；`timezone_iana.inc.c` 仍 `#include`。  
> **v2** 见 `analysis/phase-f-datetime-v2.md`（逻辑已下沉至 `datetime.sx`）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `datetime.c`（441 行） | `datetime.sx` + `datetime_glue.c` |
| `datetime.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_DATETIME_V1_FAIL=1 ./tests/run-f-datetime-v1-gate.sh
./tests/run-std-datetime-gate.sh
./tests/run-std-datetime-iana-gate.sh
```

## 下一项

- **F-datetime v2** ✅ / **F-elf v1** ✅ / **F-test v1**（`test.c`）
