# STD-128：std.csv 流式 reader/writer v1

> 状态：**定版（v1，单缓冲区内 offset 迭代）**

## API

| 名称 | 说明 |
|------|------|
| `StreamCsvReader` | 流式读：维护 `offset` 顺序 `parse_row` |
| `stream_reader_init` / `stream_reader_next_row` / `stream_reader_eof` | 读迭代 |
| `StreamCsvWriter` | 流式写：多行 `write_row` 追加到同一缓冲 |
| `stream_writer_init` / `stream_writer_append_row` / `stream_writer_len` | 写迭代 |
| `csv_stream_smoke` | 多行 C 烟测 |

## 门禁

`./tests/run-std-csv-stream-gate.sh`
