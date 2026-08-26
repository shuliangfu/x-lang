# 阶段 F-json v1（std.json 去 C）

> **F-json v1**：删除 **`json.c`**；模块锚点在 **`json.x`**；解析/游标/序列化在 **`json_parse_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `json.c`（884 行） | `json.x` + `json_parse_glue.c` |
| `json.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_JSON_V1_FAIL` retired. Delegates STD-008 json + object-array + serialize hard. Observational residual: typed-decode (listed skip).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-json-v1-gate.sh
./tests/run-std-json-gate.sh
./tests/run-std-json-object-array-gate.sh
./tests/run-std-json-serialize-gate.sh
```


## 下一项

- **F-unicode v1** ✅ / **F-hash v1**
