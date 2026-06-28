# 阶段 F-04 v7（std.compress zstd 去 C + compress.o 退役）

> **F-04 v7**：**`zstd/zstd.c`** → **`lib.sx`**；`compress.o` 不再构建；四格式全 `.sx`。

## v7 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `lib.sx` | libzstd FFI：块 + 流式 API、smoke、marker |
| `std/compress/zstd/mod.sx` | import zstd_lib 转发 |
| `runtime_link_abi.c` | `link_abi_user_o_needs_compress_libs` 按需 -lz/-lzstd/-lbrotli* |
| `compiler/Makefile` | 移除 compress.o / zstd.o；`compress-o-*` 保留为 no-op |
| `STD_AND_PANIC_O` | 不再含 compress.o |
| 删除 | `std/compress/zstd/zstd.c` |
| 存量 | F-01 total **97**（较 98 减 1） |

## v7 限制

| 项 | 说明 |
|----|------|
| compress.o 残留引用 | runtime.c 仍传 compress_o 路径（缺失则 skip） |
| 旧 C 烟测 | 经 compress.o 的路径已废弃，改 .sx 烟测 |

## 复现

```bash
SHUX_F04_COMPRESS_ZSTD_FAIL=1 ./tests/run-f04-std-compress-zstd-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=97
./tests/run-std-compress-gate.sh
```
