# 阶段 F-04 v4（std.compress zlib 去 C）

> **F-04 v4**：**`zlib/zlib.c`** → **`libz.x`**；`mod.x` import 转发；`compress.o` 不再含 zlib.o。

## v4 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `libz.x` | libz FFI：compress2/uncompress、compress_deflate_c/inflate_c |
| `std/compress/zlib/mod.x` | import zlib_libz 转发 deflate/inflate |
| `runtime_link_abi.c` | asm/invoke 链接扫描用户 .o 的 zlib marker/符号 |
| `compiler/Makefile` | COMPRESS_PARTS 移除 zlib.o |
| 删除 | `std/compress/zlib/zlib.c` |
| 存量 | F-01 total **100**（较 101 减 1） |

## v4 限制

| 项 | 说明 |
|----|------|
| gzip/brotli/zstd | 仍为 `.c`（gzip 仍 -DSHUX_USE_ZLIB 链 libz） |
| 无 libz 环境 | deflate/inflate 链接需 -lz；无库时链接失败（同 heap -lc 模式） |

## 复现

```bash
SHUX_F04_COMPRESS_ZLIB_FAIL=1 ./tests/run-f04-std-compress-zlib-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=100
./tests/run-std-compress-gate.sh
```
