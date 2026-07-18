# 阶段 E-03 v4（OBJS_CORE ABI TU 对齐）

> **E-03 v4**：冷启动 `shux-c`（`OBJS_CORE`）链入与默认 bootstrap 相同的 **ABI 薄壳 TU**（`runtime_abi.o` / `runtime_io_abi.o` / `runtime_proc_abi.o`），避免 `runtime.o` 拆 TU 后 undefined 符号。

## v4 完成（✅）

| OBJS_CORE 新增 | 说明 |
|----------------|------|
| `runtime_abi.o` | argv/target（E-04 v2） |
| `runtime_io_abi.o` | POSIX I/O（E-04 v3，v3 已加） |
| `runtime_proc_abi.o` | waitpid / link skip（E-04 v4） |
| `runtime_link_abi.o` | invoke_cc argv 辅助（E-04 v5，v5 已加） |

## 仍 track-only（E-03 v6+）

| 项 | 说明 |
|----|------|
| `OBJS_CORE` C 前端 | parser/typeck/codegen 等仍 cc -c |
| `runtime.o` vs `runtime_driver_no_c.o` | 冷启动仍全量 runtime.c |

## 复现

```bash
grep '^OBJS_CORE' compiler/Makefile
SHUX_E03_V3_FAIL=1 ./tests/run-e03-v3-coldstart-track-gate.sh
```
