# 阶段 F-csv v1（std.csv 去 C）

> **F-csv v1**：删除 **`csv.c`**；RFC 4180 解析/写回/流式 smoke 全量在 **`csv.sx`**（零胶层）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `csv.c`（271 行） | `csv.sx` |
| `csv.o` | `cc -c` | `shux -backend asm` |

## 门禁

```bash
SHUX_F_CSV_V1_FAIL=1 ./tests/run-f-csv-v1-gate.sh
./tests/run-std-csv-row-gate.sh
./tests/run-std-csv-stream-gate.sh
```

## 下一项

- **F-json v1** ✅ / **F-regex v1** ✅ / **F-unicode v1**
