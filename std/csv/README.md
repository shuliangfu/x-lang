# std.csv — CSV 字段解析（RFC 4180）

**路径**：`std/csv/mod.sx` + `std/csv/csv.sx`（**F-csv v1 纯 .sx**）

| API | 说明 |
|-----|------|
| `next_field` | 从缓冲区解析下一字段（支持引号字段、`""` 转义） |
| `escape` | 将字段写成带引号的 CSV 单元 |
| `unescape` | 将引号字段 raw 内容中的 `""` 还原为 `"` |

`csv.sx` 提供 RFC 4180 解析/写回/流式 smoke；用户 `import("std.csv")` 即可。

**测试**：`SHUX=./compiler/shux-c ./tests/run-csv.sh` 或 `SHUX=./compiler/shux ./tests/run-csv.sh`（2026-05-27 seed 重链后全绿）。
