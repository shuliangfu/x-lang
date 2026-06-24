# 阶段 F-regex v1（std.regex 去 C）

> **F-regex v1**：删除 **`regex.c`**；模块锚点在 **`regex.sx`**。  
> **F-regex v2** ✅：引擎自 **`regex_min.inc.c`** 全量迁入 **`regex.sx`**；已删 glue/inc。

## 变更

| 项 | 前 | v1 | v2 |
|----|----|-----|-----|
| 实现 | `regex.c` | `regex.sx` + glue/inc | **`regex.sx` 纯 .sx** |
| `regex.o` | `cc -c` | `ld -r` | **纯 shux** |

## 门禁

```bash
SHUX_F_REGEX_V1_FAIL=1 ./tests/run-f-regex-v1-gate.sh
SHUX_F_REGEX_V2_FAIL=1 ./tests/run-f-regex-v2-gate.sh
./tests/run-std-regex-gate.sh
```

## 下一项

- **F-regex v2** ✅
