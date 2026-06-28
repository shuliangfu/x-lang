# STD-128：std.csv 流式 reader/writer v1

> 状态：**定版（v1，单缓冲区内 offset 迭代）**

## API

| 名称 | 说明 |
|------|------|
| `StreamCsvReader` | 流式读：维护 `offset` 顺序 `parse_row` |
| `reader` / `next_row` / `eof` | 读迭代 |
| `StreamCsvWriter` | 流式写：多行 `write_row` 追加到同一缓冲 |
| `writer` / `append_row` / `len` | 写迭代 |
| `smoke` | 多行 C 烟测 |

## 门禁

`./tests/run-std-csv-stream-gate.sh`
