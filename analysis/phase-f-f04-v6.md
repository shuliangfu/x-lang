# 阶段 F-04 v6（std.compress Brotli 去 C）

> **F-04 v6**：**`brotli/brotli.c`** → **`lib.x`**；`mod.x` import 转发；`compress.o` 不再含 brotli.o。

## v6 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `lib.x` | libbrotli FFI：块 + 流式 API、smoke、marker |
| `std/compress/brotli/mod.x` | import brotli_lib 转发 |
| `runtime_link_abi.c` | 用户 .o 扫描 brotli/zstd marker 与符号 |
| `compiler/Makefile` | COMPRESS_PARTS 仅 zstd.o |
| 删除 | `std/compress/brotli/brotli.c` |
| 存量 | F-01 total **98**（较 99 减 1） |

## v6 限制

| 项 | 说明 |
|----|------|
| zstd | 仍为 `.c`（下一 F-04 v7） |
| C 烟测 | `brotli_smoke_ok.c` 经 compress.o 路径已废弃，改 .x 烟测 |
| 无 libbrotli | 链接需 -lbrotlienc -lbrotlidec |

## 复现

```bash
SHUX_F04_COMPRESS_BROTLI_FAIL=1 ./tests/run-f04-std-compress-brotli-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh   # total=98
./tests/run-std-compress-brotli-gate.sh
```
