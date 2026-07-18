# 阶段 E-03 v5（OBJS_CORE 增加 runtime_link_abi.o）

> **E-03 v5**：冷启动 `shux-c`（`OBJS_CORE`）与默认 bootstrap 链入 **E-04 v5** `runtime_link_abi.o`，避免 invoke_cc 链接辅助迁 TU 后 undefined 符号。

## v5 完成（✅）

| OBJS_CORE 新增 | 说明 |
|----------------|------|
| `runtime_link_abi.o` | invoke_cc argv 辅助（E-04 v5） |

## 仍 track-only（E-03 v6+）

| 项 | 说明 |
|----|------|
| `OBJS_CORE` C 前端 | parser/typeck/codegen 等仍 cc -c |
| `runtime.o` vs `runtime_driver_no_c.o` | 冷启动仍全量 runtime.c |

## 复现

```bash
grep '^OBJS_CORE' compiler/Makefile | grep runtime_link_abi
SHUX_E03_V3_FAIL=1 ./tests/run-e03-v3-coldstart-track-gate.sh
```
