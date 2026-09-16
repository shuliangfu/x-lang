# 阶段 F-04 v6（std.compress Brotli 去 C）

> **F-04 v6**：**`brotli/brotli.c`** → **`lib.x`**；`mod.x` import 转发；`compress.o` 不再含 brotli.o。
>
> **Honesty（2026-08-27）**：顶层 `analysis/phase-f-f04-v6.md` 与 `compiler/Makefile` 已退役（MG archive）；活权威 = 本 archive DOC + `std/compress/brotli/{lib,mod}.x` + baseline TSV。soft `XLANG_F04_COMPRESS_BROTLI_FAIL` 已退役（die always hard）。产品 brotli ld 残仍 tip 跳（本闸 = packaging／archaeology）。

## v6 完成（✅ manifest）

| 项 | 说明 |
|----|------|
| `lib.x` | libbrotli FFI：块 + 流式 API、smoke、marker |
| `std/compress/brotli/mod.x` | import brotli_lib 转发 |
| `runtime_link_abi.c` | 用户 .o 扫描 brotli/zstd marker 与符号 |
| MG 后 | 不再锚 `compiler/Makefile` COMPRESS_PARTS；拒 Makefile 复活 |
| 删除 | `std/compress/brotli/brotli.c` |
| 存量 | F-01 inventory 硬委托（基线见 inventory 闸） |

## Gate

```bash
./tests/run-f04-std-compress-brotli-gate.sh
# Manifest-only:
#   XLANG_F04_COMPRESS_BROTLI_MANIFEST_ONLY=1 ./tests/run-f04-std-compress-brotli-gate.sh
# Report: doc=/lib=/mod=/absent_c=/manifest=/std125=/compress=/inv=/skip=
# Soft XLANG_F04_COMPRESS_BROTLI_FAIL + top-level DOC/Makefile anchors retired (die always hard).
# Delegates: STD-125 compress-brotli + std-compress + F-01 inventory (already hard).
```

PLATFORM: SHARED archaeology.

## v6 限制

| 项 | 说明 |
|----|------|
| 产品 brotli ld | tip 跳；需 host `-lbrotlienc/-lbrotlidec`；非本闸根修 |
| C 烟测 | `brotli_smoke_ok.c` 经 compress.o 路径已废弃；STD-125 无 libs 时 skip=1 诚实 |
| zstd 历史 | 另叶 F-04 v7+ |

## 复现

```bash
./tests/run-f04-std-compress-brotli-gate.sh
./tests/run-std-c-inventory-gate.sh
./tests/run-std-compress-brotli-gate.sh
```
