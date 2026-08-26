# 阶段 F-07 v2（std.net net.c 删除硬禁）

> **F-07 v2 v1**：**F-04 v14** 删除 **`std/net/net.c`** 后，扩展 F-07 清单与 gate。

## v2 v1 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `std/net/net.c` | **已删除**（v14） |
| `Makefile` | 已删；`./xbuild` 权威；gate refuse resurrect |
| `f07-no-cc-std-migrated.tsv` | net + path/uuid/sort absent 条目 |
| gate | `run-f07-no-cc-std-migrated-gate.sh` 校验 net.c absent |

## Gate

Honesty gate (2026-08-26): same aggregator as v1 — prefer asm, hard-fail
static + forbidden ensure + f06 + f03-core (both honesty-hard). Soft
`XLANG_F07_NO_CC_MIGRATED_FAIL` retired. Report `static=` / `forbidden=` /
`f06=` / `f03_core=` / `skip=`.

```bash
./tests/run-f07-no-cc-std-migrated-gate.sh
XLANG=./compiler/xlang_asm ./tests/run-f07-no-cc-std-migrated-gate.sh
```

## 复现

Same as **## Gate** (soft FAIL path retired; gate always hard).
