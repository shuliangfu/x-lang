# 阶段 F-trace v2（std.trace 逻辑 .x 下沉）

> **F-trace v2**：**span 栈 / trace_id / text 导出** 全量在 **`trace.x`**；**删除 `trace_span_glue.c`**；`trace.o` 纯 `.x` 编译（同 cache v2）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| span/export 实现 | `trace_span_glue.c`（194 行） | **`trace.x`** |
| `trace.o` | `ld -r` glue + x | **纯 shux → trace.o** |
| text 导出 | glue `snprintf` | **`u8_to_hex2` + `append_u64_dec`** |
| 单调时钟/随机 | glue 链 time.o + random.o | `extern time_now_monotonic_ns_c` / `random_fill_bytes_c` |

## 门禁

```bash
SHUX_F_TRACE_V2_FAIL=1 ./tests/run-f-trace-v2-gate.sh
./tests/run-std-trace-gate.sh
./tests/run-std-trace-hooks-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-sync v1**（trace 已闭合；继续 std 去 C 批次）
