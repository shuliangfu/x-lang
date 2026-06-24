# 阶段 F-json v2（std.json 逻辑 .sx 下沉）

> **F-json v2**：解析/游标/序列化/类型化 decode 全量迁入 **`json.sx`**；**纯 .sx**（无 OS/pthread/malloc；仅 extern memcmp）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| 解析/游标/序列化 | `json_parse_glue.c`（~883 行） | **`json.sx`** |
| `json.o` | `ld -r` glue + sx | **仅 sx（`json_main.o`）** |
| mod.sx | extern json_*_c | **不变** |

## 门禁

```bash
SHUX_F_JSON_V2_FAIL=1 ./tests/run-f-json-v2-gate.sh
./tests/run-std-json-gate.sh
./tests/run-std-json-object-array-gate.sh
./tests/run-std-json-serialize-gate.sh
./tests/run-std-json-typed-decode-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（http / async / channel 等胶层）
