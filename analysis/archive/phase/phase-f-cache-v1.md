# 阶段 F-cache v1（std.cache 去 C）

> **F-cache v1**：删除 **`cache.c`**；模块锚点在 **`cache.x`**；LRU/对象池在 **`cache_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `cache.c`（395 行） | `cache.x` + `cache_glue.c` |
| `cache.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_CACHE_V1_FAIL` retired. Delegates STD-087 cache hard.

**2026-08-30 leftover XLANG fallthrough 已收**（f-cache-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-cache 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-cache-v1-gate.sh
./tests/run-std-cache-gate.sh
```

## 下一项

- **F-cache v2** ✅ / **F-config v1** ✅ / **F-datetime v1** ✅ / **F-elf v1** ✅
