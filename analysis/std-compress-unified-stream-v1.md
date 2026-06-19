# STD-122：std.compress 统一流式 API v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-039 低层 `gzip_stream_*`、STD-110 `std.codec` 流式适配

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-compress-unified-stream-manifest.tsv` |
| 3 | `./tests/run-std-compress-unified-stream-gate.sh` |
| 4 | 烟测：`tests/std-compress/unified_stream_roundtrip.sx` |

---

## 2. 统一流式 API（v1）

在 STD-039 低层 gzip 流之上提供 **format + mode 门面**，与 `std.codec.StreamCodec` 风格对齐，但归属 `std.compress` 模块。

| API | 说明 |
|-----|------|
| `compress_format_gzip()` | 流格式常量（v1 唯一） |
| `compress_stream_mode_compress()` / `compress_stream_mode_decompress()` | 流模式 |
| `stream_compress_state_bytes()` | 状态缓冲最小字节数 |
| `stream_compress_init` | 绑定 `StreamCompress` + 初始化底层流 |
| `stream_compress_process` | 分块 compress/decompress；`is_last≠0` 为压缩末块 |
| `stream_compress_end` | 释放底层状态 |

**错误语义**：`compress_err_ok()` / `compress_err_input()` / `compress_err_unsupported()`；底层 zlib 失败仍返回 -1。

v1 **仅 gzip 流**；zstd/brotli 流式留待后续 RFC（init 返回 `compress_err_unsupported()`）。

未启用 `SHUX_USE_ZLIB` 时 init 失败；烟测以 exit 0 **skip**（与 STD-039 一致）。

---

## 3. 验证与门禁

```bash
./tests/run-std-compress-unified-stream-gate.sh
```

```
shux: [SHUX_STD122_COMPRESS_UNIFIED] status=ok stream=1 skip=0
std-compress-unified-stream gate OK
```

烟测向量：`Hello, gz!!!`（12 字节）经 `stream_compress_*` 分块往返。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | 初版：StreamCompress 门面 + gzip 分块 round-trip gate |
