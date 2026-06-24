# 阶段 F-04 v5（std.compress gzip 去 C）

> **F-04 v5**：**`gzip/gzip.c`** → **`gzip_libz.sx`**；`mod.sx` import 转发；`compress.o` 不再含 gzip.o。

## v5 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `gzip_libz.sx` | libz FFI：块 gzip 压缩/解压 + gzip_stream_*（ZStream 布局） |
| `std/compress/gzip/mod.sx` | import gzip_libz 转发 |
| `compiler/Makefile` | COMPRESS_PARTS 仅 brotli+zstd |
| 删除 | `std/compress/gzip/gzip.c` |
| 存量 | F-01 total **99**（较 100 减 1） |

## v5 限制

| 项 | 说明 |
|----|------|
| brotli/zstd | 仍为 `.c` |
| ZStream 布局 | 依赖 64 位 hosted ABI（与 zlib z_stream 一致） |
| 无 libz | gzip API 链接需 -lz（runtime 扫描 deflate/inflate 符号） |

## 复现

```bash
SHUX_F04_COMPRESS_GZIP_FAIL=1 ./tests/run-f04-std-compress-gzip-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=99
./tests/run-std-compress-gate.sh
./tests/run-std-compress-stream-gate.sh
```
