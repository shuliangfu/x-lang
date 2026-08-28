# STD-039：std.compress gzip 流式 compress/decompress v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-007 一次性 `gzip_compress`/`gzip_decompress`、zlib 可选链入

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；拒 soft SKIP→OK／soft `std_compress_try_libs`／soft auto-make；check＝obs（暂停）；tip 产品 `-o` UNDEF／SEGV＝obs（产品另案；brotli ld 仍跳）。报告 `run=`／`obs=`／`skip=`（退役 `stream=`）。

```bash
./tests/run-std-compress-stream-gate.sh
```

```
xlang: [XLANG_STD_COMPRESS_STREAM] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-compress-stream.tsv` |
| 3 | `./tests/run-std-compress-stream-gate.sh` |
| 4 | 烟测：`tests/std-compress/gzip_stream_roundtrip.x` |

---

## 2. 流式 gzip API（v1）

调用方提供 **opaque 状态缓冲**（`gzip_stream_state_bytes()` 字节），由 C 层持有 `z_stream`。

| API | 说明 |
|-----|------|
| `gzip_stream_state_bytes()` | 状态缓冲最小字节数 |
| `gzip_stream_init_compress` / `gzip_stream_init_decompress` | 初始化；成功 0，失败 -1 |
| `gzip_stream_compress` | 分块压缩；`is_last≠0` 时对最后一块 `Z_FINISH` |
| `gzip_stream_decompress` | 分块解压 |
| `gzip_stream_end` | `deflateEnd` / `inflateEnd` |

**分块约定**：

- 压缩：每块可小于输入总长；最后一块设 `is_last=1`；若 zlib 仍有尾数据，以 `in_len=0, is_last=1` 继续 drain 直至 `ended`。
- 解压：按任意块大小喂入 gzip 帧；`Z_STREAM_END` 时内部标记 `ended`。
- 未启用 `XLANG_USE_ZLIB` 时全部返回 -1；烟测以 exit 0 **skip**（与 STD-007 一致）。

v1 **仅 gzip 流**；zstd/brotli 流式留待后续 RFC。

---

## 3. 验证与门禁

```bash
./tests/run-std-compress-stream-gate.sh
```

```
xlang: [XLANG_STD_COMPRESS_STREAM] status=ok run=N obs=M skip=K  （见 ## Gate）
```

烟测向量：`Hello, gz!!!`（12 字节）分 3×4 字节压缩，再以 5 字节块解压比对原文。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 初版：gzip 流式 API + 分块 round-trip gate |
