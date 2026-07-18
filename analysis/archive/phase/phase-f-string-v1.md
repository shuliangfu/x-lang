# 阶段 F-string v1（std.string 去 C）

> **F-string v1**：删除 **`string.c`**；长串快路径全在 **`string.x`**；**零胶层 C**（extern libc memcmp/memcpy/memchr）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `string.c`（99 行） | `string.x` |
| `string.o` | `cc -c string.c` | `shux -backend asm string.x` |
| memmem | GNU memmem / 便携 C | `.x` 便携实现（全平台一致） |
| 存量 | std 88 `.c` | std **87** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/string/string.c`~~ | v1 删除 |

## 构建

```bash
make -C compiler ../std/string/string.o
```

## 门禁

```bash
SHUX_F_STRING_V1_FAIL=1 ./tests/run-f-string-v1-gate.sh
./tests/run-perf-string-arena.sh
```
