# 阶段 F-cache v2（std.cache 逻辑 .x 下沉）

> **F-cache v2**：**LRU/TTL + 对象池** 全量在 **`cache.x`**；**删除 `cache_glue.c`**；`cache.o` 纯 `.x` 编译（同 encoding）。

## 变更

| 项 | v1 | v2 |
|----|----|-----|
| LRU/池实现 | `cache_glue.c`（395 行） | **`cache.x`** |
| `cache.o` | `ld -r` glue + x | **纯 shux → cache.o** |
| 单调时钟 | glue 链 time.o | `extern time_now_monotonic_ns_c` |

## 门禁

```bash
SHUX_F_CACHE_V2_FAIL=1 ./tests/run-f-cache-v2-gate.sh
./tests/run-std-cache-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 下一项

- **F-url v2**（URL 解析逻辑下沉）
