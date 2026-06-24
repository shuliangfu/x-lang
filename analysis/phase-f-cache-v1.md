# 阶段 F-cache v1（std.cache 去 C）

> **F-cache v1**：删除 **`cache.c`**；模块锚点在 **`cache.sx`**；LRU/对象池在 **`cache_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `cache.c`（395 行） | `cache.sx` + `cache_glue.c` |
| `cache.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_CACHE_V1_FAIL=1 ./tests/run-f-cache-v1-gate.sh
./tests/run-std-cache-gate.sh
```

## 下一项

- **F-cache v2** ✅ / **F-config v1** ✅ / **F-datetime v1** ✅ / **F-elf v1** ✅
