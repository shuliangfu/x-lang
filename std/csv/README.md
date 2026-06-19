# std.csv — CSV 字段解析（RFC 4180）

**路径**：`std/csv/mod.sx`（**纯 .sx 实现**）

| API | 说明 |
|-----|------|
| `next_field` | 从缓冲区解析下一字段（支持引号字段、`""` 转义） |
| `escape` | 将字段写成带引号的 CSV 单元 |
| `unescape` | 将引号字段 raw 内容中的 `""` 还原为 `"` |

`csv.c` 为历史 C 实现，**新代码不依赖**；用户程序仅 `import("std.csv")` 即可，无需链入 `csv.o`（若 driver 仍链入则为无害冗余）。

**测试**：`SHUX=./compiler/shux-c ./tests/run-csv.sh` 或 `SHUX=./compiler/shux ./tests/run-csv.sh`（2026-05-27 seed 重链后全绿）。
