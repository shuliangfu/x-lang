# 阶段 F-trace v2（std.trace 逻辑 .x 下沉）

> **F-trace v2**：**span 栈 / trace_id / text 导出** 全量在 **`trace.x`**；**删除 `trace_span_glue.c`**；`trace.o` 纯 `.x` 编译（同 cache v2）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| span/export 实现 | `trace_span_glue.c`（194 行） | **`trace.x`** |
| `trace.o` | `ld -r` glue + x | **纯 xlang → trace.o** |
| text 导出 | glue `snprintf` | **`u8_to_hex2` + `append_u64_dec`** |
| 单调时钟/随机 | glue 链 time.o + random.o | `extern time_now_monotonic_ns_c` / `random_fill_bytes_c` |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_TRACE_V2_FAIL` retired. STD-088／hooks product residual observational (fossil `trace_new` vs live `trace_create_c`).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-trace-v2-gate.sh
./tests/run-std-trace-gate.sh
```

## 下一项

- 继续阶段 F std 去 C（其它模块）
