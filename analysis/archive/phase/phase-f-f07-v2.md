# 阶段 F-07 v2（std.net net.c 删除硬禁）

> **F-07 v2 v1**：**F-04 v14** 删除 **`std/net/net.c`** 后，扩展 F-07 清单与 gate。

## v2 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `std/net/net.c` | **已删除**（v14） |
| `Makefile` | `net.o` 不再 `cc -c net.c` |
| `f07-no-cc-std-migrated.tsv` | 增加 net 条目 |
| gate | `run-f07-no-cc-std-migrated-gate.sh` 校验 net.c  absent |

## 复现

```bash
SHUX_F07_NO_CC_MIGRATED_FAIL=1 ./tests/run-f07-no-cc-std-migrated-gate.sh
SHUX_F04_NET_SLICE_V14_FAIL=1 ./tests/run-f04-std-net-slice-v14-gate.sh
```
