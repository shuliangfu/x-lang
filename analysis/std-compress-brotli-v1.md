# STD-125：std.compress Brotli 可选后端 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-007 gzip/zstd、STD-122 统一流式 API

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-compress-brotli-manifest.tsv` |
| 3 | `./tests/run-std-compress-brotli-gate.sh` |

---

## 2. 默认策略与构建矩阵（v1）

**默认 `compress.o` 不含 Brotli**（与 gzip/zstd 可选链入一致）；`brotli_*` 在未启用时返回 **-1**，烟测 **skip**（exit 0）。

| Make 目标 | 宏 | 链接库 | 用途 |
|-----------|-----|--------|------|
| `compress-o-zlib-zstd` | `SHUX_USE_ZLIB` + `SHUX_USE_ZSTD` | `-lz` `-lzstd` | STD-007 默认推荐 |
| `compress-o-brotli` | `SHUX_USE_BROTLI` | `-lbrotlienc` `-lbrotlidec` | 仅 Brotli |
| `compress-o-zlib-zstd-brotli` | 三者 | 上述全部 | 全格式 CI/本地 |

| API | 说明 |
|-----|------|
| `brotli_compress` / `brotli_decompress` | 块压缩/解压 |
| `brotli_available()` | 1=后端已编译进 compress.o |
| `brotli_smoke()` | C 往返烟测；未启用时 0 |

v1 **不含** Brotli 流式（见 STD-122 `compress_err_unsupported()`）。

---

## 3. Gate

```bash
make -C compiler compress-o-brotli   # 需系统 libbrotli
./tests/run-std-compress-brotli-gate.sh
```

```
shux: [SHUX_STD125_COMPRESS_BROTLI] status=ok brotli=1 skip=0
std-compress-brotli gate OK
```

无 Brotli 库时 gate 仍通过（`brotli=0 skip=1`）。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | 构建矩阵 + available/smoke + round-trip gate |
