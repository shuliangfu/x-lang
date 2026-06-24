# 阶段 F-json v1（std.json 去 C）

> **F-json v1**：删除 **`json.c`**；模块锚点在 **`json.sx`**；解析/游标/序列化在 **`json_parse_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `json.c`（884 行） | `json.sx` + `json_parse_glue.c` |
| `json.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_JSON_V1_FAIL=1 ./tests/run-f-json-v1-gate.sh
./tests/run-std-json-gate.sh
./tests/run-std-json-object-array-gate.sh
./tests/run-std-json-serialize-gate.sh
./tests/run-std-json-typed-decode-gate.sh
```

## 下一项

- **F-unicode v1** ✅ / **F-hash v1**
