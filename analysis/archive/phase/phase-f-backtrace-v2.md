# 阶段 F-backtrace v2（std.backtrace 帧辅助与烟测 .x 下沉）

> **F-backtrace v2**：帧 read/write、符号名辅助、gold 烟测编排从 **`backtrace_glue.c`** 迁入 **`backtrace.x`** 后，平台 capture/symbolicate/crash evidence 在 **`compiler/seeds/runtime_backtrace_platform.from_x.c`**（F-ZC）；`backtrace.x` 保留 v1/v2 marker。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| 帧辅助/烟测 | `backtrace_glue.c` | **runtime seed**（F-ZC）+ markers in **`backtrace.x`** |
| 平台 capture | `backtrace_platform_glue.c`（std） | **`runtime_backtrace_platform.from_x.c`**（compiler） |
| `backtrace.o` | `ld -r` x + glue | 纯 **`xlang -backend asm backtrace.x`** |

## runtime 导出

- `backtrace_capture_c` / `backtrace_symbolicate_c` / `backtrace_gold_anchor_c`
- `backtrace_gold_anchor_addr_c` / `backtrace_xplat_quality_c`
- `xlang_crash_evidence_collect_c`（强符号覆盖 `runtime_panic.c` 弱默认）
- `backtrace_read_frame_addr_c` / `backtrace_write_frame_addr_c` / `backtrace_copy_sym_name_c`
- `backtrace_symbolicate_smoke_c` / `backtrace_gold_anchor_smoke_enter_c`

## backtrace.x 导出

- `backtrace_f_backtrace_v1_marker_c` / `backtrace_f_backtrace_v2_marker_c`

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_BACKTRACE_V2_FAIL` retired. Static aligned to F-ZC authority (markers in `.x`; frame helpers in runtime seed). STD-052 symbolicate hard-delegate; STD-147 xplat observational (DOC residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-backtrace-v2-gate.sh
./tests/run-std-backtrace-symbolicate-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（其它模块）
