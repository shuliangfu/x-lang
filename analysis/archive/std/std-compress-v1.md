# STD-007 std.compress 基础能力 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`std/compress/*.x`（F-04 v7；无 `compress.c`／无 `compress.o`）、`tests/run-std-compress-gate.sh`、`tests/compress/main.x`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 格式层 M1–M4 |
| 2 | 打开 `tests/baseline/std-compress-manifest.tsv` |
| 3 | `./tests/run-std-compress-gate.sh` |
| 4 | 模块回归：`./tests/run-compress.sh`（hook；观测） |

---

## 2. 格式层 M1–M4

权威：`tests/baseline/std-compress-manifest.tsv`（**4** 条 `layer_*`）。

| 层级 | 格式 | API | 依赖 | v1 |
|------|------|-----|------|-----|
| **M1-gzip** | `.gz` deflate 流 | `gzip_compress` / `gzip_decompress` | zlib (`-lz`) | ✅ |
| **M2-zstd** | Zstandard 帧 | `zstd_compress` / `zstd_decompress` | libzstd (`-lzstd`) | ✅ |
| **M3-zlib** | raw zlib | `deflate` / `inflate` | zlib | ✅ 可选 |
| **M4-skip** | 未链库占位 | 返回 **-1** | 烟测跳过分支 | ✅ |

**构建**（MF 已物理删除）：

```bash
# hub no-op phony（compat）；真权威 = .x + runtime marker 链 -lz/-lzstd/-lbrotli*
xlang_compiler_make compress-o-zlib-zstd
./tests/run-std-compress-gate.sh
```

链接：runtime 扫描用户 `.o` marker／符号按需追加 `-lz`／`-lzstd`／`-lbrotli*`。

**v1 非目标**：流式字典训练、帧级 checksum 暴露、Brotli 纳入本 gate 硬信号（仍保留 API／legacy 分支）；compress-stream／unified-stream 另闸（本波跳过产品红／UNDEF）。

---

## 3. Golden 烟测

| case_id | 文件 | 期望 |
|---------|------|------|
| `smoke_gzip` | `tests/std-compress/gzip_roundtrip.x` | exit 0 硬失败（往返或库未链时分支跳过仍 0） |
| `smoke_zstd` | `tests/std-compress/zstd_roundtrip.x` | exit 0 硬失败 |
| `smoke_legacy` | `tests/compress/main.x` | gzip＋zstd＋brotli 往返；exit 0 硬失败 |
| `hook_compress` | `tests/run-compress.sh` | hook（观测；硬绿信号＝三烟测） |

---

## 4. 验收

- [x] RFC + manifest **4** API 核心 + **2** 格式层烟测
- [x] `zstd_*` API + hub `compress-o-zlib-zstd` no-op
- [x] `run-std-compress-gate.sh` + runnable report
- [x] Gate honesty soft→硬绿（prefer asm／LINK／check 观测／硬烟测）

---

## 5. 资源

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/std/std-compress-v1.md` |
| manifest | `tests/baseline/std-compress-manifest.tsv` |
| 库 | `tests/lib/std-compress.sh` |
| 门禁 | `tests/run-std-compress-gate.sh` |
| 烟测 | `tests/std-compress/gzip_roundtrip.x`、`zstd_roundtrip.x`、`tests/compress/main.x` |
| README | `std/compress/README.md` |

旧闸偏 `xlang-c`／无 native 则 soft SKIP 却报 OK／section `## 4. Gate 与 report`＝portable 假红；产品 asm 烟测本绿（`main.x` BUILD=0 RUN=0）。

---

## 6. Gate

```bash
./tests/run-std-compress-gate.sh
```

Honesty（2026-08-26 · soft→硬绿）：

| 字段 | 含义 |
|------|------|
| prefer | `xlang_asm`（再 `xlang-c`／`xlang`）；钉 `XLANG_LINK_XLANG` |
| check | **观测**（自举期 check 闸门暂停；CHK 红不硬失败） |
| gzip／zstd／legacy | 三烟测 **exit 0 硬失败**（有 native 时禁止 soft SKIP→OK） |
| skip | 仅 `MANIFEST_ONLY=1` 时可 1；有 native 跑烟测时必须 0 |
| refuse | 顶层 `analysis/std-compress-v1.md` 复活 → FAIL |

报告行（runnable report）：

```text
xlang: [XLANG_STD_COMPRESS] status=ok check=? gzip=1 zstd=1 legacy=1 skip=0
```

硬绿信号＝`gzip=`／`zstd=`／`legacy=`（`check=` 仅观测）。

**STD-007 状态：定版 ✅ · Gate honesty soft→硬绿**

### Changelog

| Ver | Date | Note |
|-----|------|------|
| v1.0 | 2026-06-17 | 定版：gzip + zstd 往返烟测，可选 zlib/Brotli |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；DOC／TSV→`## 6. Gate`；gzip／zstd／legacy exit0 硬失败；报告 `check=`／`gzip=`／`zstd=`／`legacy=`／`skip=`；禁 soft SKIP→OK／顶层 DOC 复活 |
