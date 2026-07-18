# STD-007 std.compress 基础能力 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — gzip + zstd 往返烟测，可选 zlib/Brotli  
> 关联：`std/compress/compress.c`、`tests/run-compress.sh`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 格式层 M1–M4 |
| 2 | 打开 `tests/baseline/std-compress-manifest.tsv` |
| 3 | `./tests/run-std-compress-gate.sh` |
| 4 | `make -C compiler compress-o-zlib-zstd && ./tests/run-compress.sh` |

---

## 2. 格式层 M1–M4

权威：`tests/baseline/std-compress-manifest.tsv`（**4** 条 `layer_*`）。

| 层级 | 格式 | API | 依赖 | v1 |
|------|------|-----|------|-----|
| **M1-gzip** | `.gz` deflate 流 | `gzip_compress` / `gzip_decompress` | zlib (`-lz`) | ✅ |
| **M2-zstd** | Zstandard 帧 | `zstd_compress` / `zstd_decompress` | libzstd (`-lzstd`) | ✅ |
| **M3-zlib** | raw zlib | `deflate` / `inflate` | zlib | ✅ 可选 |
| **M4-skip** | 未链库占位 | 返回 **-1** | 烟测跳过 | ✅ |

**构建**：

```bash
make -C compiler compress-o-zlib        # 仅 gzip/zlib
make -C compiler compress-o-zlib-zstd # gzip + zstd（STD-007 推荐）
```

链接：`runtime.c` 在链入 `compress.o` 时追加 `-lz` 与 `-lzstd`。

**v1 非目标**：流式字典训练、帧级 checksum 暴露、Brotli 纳入本 gate（仍保留 API）。

---

## 3. Golden 烟测

| case_id | 文件 | 期望 |
|---------|------|------|
| `smoke_gzip` | `tests/std-compress/gzip_roundtrip.x` | 往返一致或 SKIP（-1） |
| `smoke_zstd` | `tests/std-compress/zstd_roundtrip.x` | 往返一致或 SKIP（-1） |
| `smoke_legacy` | `tests/compress/main.x` | gzip+brotli 回归 |
| `hook_compress` | `tests/run-compress.sh` | hook |

---

## 4. Gate 与 report

gate 输出 **`std-compress gate OK`**；**runnable** report 含 `gzip=` / `zstd=`（`ok`/`skip`）。无 native `shux` 时 manifest 仍过。

---

## 5. 验收

- [x] RFC + manifest **4** API 核心 + **2** 格式层烟测
- [x] `zstd_*` C/API + `compress-o-zlib-zstd` 目标
- [x] `run-std-compress-gate.sh` + `run-portable-suite.sh`
