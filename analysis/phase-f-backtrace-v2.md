# 阶段 F-backtrace v2（std.backtrace 帧辅助与烟测 .sx 下沉）

> **F-backtrace v2**：帧 read/write、符号名辅助、gold 烟测编排从 **`backtrace_glue.c`** 迁入 **`backtrace.sx`**；平台 capture/symbolicate/crash evidence 在 **`compiler/src/asm/runtime_backtrace_platform.c`**（F-ZC）。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| 帧辅助/烟测 | `backtrace_glue.c` | **`backtrace.sx`** |
| 平台 capture | `backtrace_platform_glue.c`（std） | **`runtime_backtrace_platform.c`**（compiler） |
| `backtrace.o` | `ld -r` sx + glue | 纯 **`shux -backend asm backtrace.sx`** |

## runtime 导出

- `backtrace_capture_c` / `backtrace_symbolicate_c` / `backtrace_gold_anchor_c`
- `backtrace_gold_anchor_addr_c` / `backtrace_xplat_quality_c`
- `shux_crash_evidence_collect_c`（强符号覆盖 `runtime_panic.c` 弱默认）

## backtrace.sx 导出

- `backtrace_read_frame_addr_c` / `backtrace_write_frame_addr_c` / `backtrace_copy_sym_name_c`
- `backtrace_symbolicate_smoke_c` / `backtrace_gold_anchor_smoke_enter_c`

## 门禁

```bash
SHUX_F_BACKTRACE_V2_FAIL=1 ./tests/run-f-backtrace-v2-gate.sh
./tests/run-std-backtrace-symbolicate-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```
