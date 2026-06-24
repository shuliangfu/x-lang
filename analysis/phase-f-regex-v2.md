# 阶段 F-regex v2（std.regex 引擎全量 .sx）

> **F-regex v2**：`regex_min.inc.c`（~1305 行）全量迁入 **`regex.sx`**；**删除 `regex_engine_glue.c`** 与 **`regex_min.inc.c`**；`regex.o` 纯 `.sx` 编译（同 hash/schema）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 引擎实现 | `regex_engine_glue.c` + `regex_min.inc.c` | **`regex.sx`** |
| `regex.o` | `ld -r` glue + sx | **纯 shux → regex.o** |
| 特性 | NFA/回溯、capture、`\p{}`、占有型、`(?>...)` | 同上，逻辑 1:1 迁移 |

## 导出符号（mod.sx extern）

`regex_compile_c`、`regex_match_c`、`regex_group_count_c`、`regex_group_offset_c`、`regex_group_length_c`、`regex_free_c`、`regex_min_smoke_c`

## 门禁

```bash
SHUX_F_REGEX_V2_FAIL=1 ./tests/run-f-regex-v2-gate.sh
./tests/run-std-regex-gate.sh
./tests/run-std-regex-atomic-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-socketio v2** ✅ / 其他 std 胶层继续下沉
