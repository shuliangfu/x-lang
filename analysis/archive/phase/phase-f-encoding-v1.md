# 阶段 F-encoding v1（std.encoding 去 C）

> **F-encoding v1**：删除 **`encoding.c`**；UTF-8/hex/base32/percent 全在 **`encoding.x`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `encoding.c`（397 行） | `encoding.x` |
| `encoding.o` | `cc -c encoding.c` | `xlang -backend asm encoding.x` |
| UTF-8 首字节表 | 256 字节静态表 | 范围判定函数 |
| 存量 | std 87 `.c` | std **86** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/encoding/encoding.c`~~ | v1 删除 |

## 构建

```bash
./xbuild  # was: make -C compiler ../std/encoding/encoding.o
```

## Gate

Honesty (2026-08-26): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_ENCODING_V1_FAIL` retired. Orphan Makefile `die/fi` syntax fixed.


```bash
XLANG=./compiler/xlang_asm ./tests/run-f-encoding-v1-gate.sh
./tests/run-std-encoding-hex-base64-gate.sh  # observational (product residual)
./tests/run-std-encoding-extra-gate.sh      # observational (product residual)
```

## 下一项

- **F-env v1** / **F-log v1** 等小模块
- **F-process v2**：getcwd/self_exe 缓存迁 `.x`
