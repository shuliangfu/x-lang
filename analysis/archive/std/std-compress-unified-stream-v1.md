# STD-122：std.compress 统一流式 API v1

> 更新时间：2026-06-27  
> 状态：**定版（v1）**

---

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；拒 soft SKIP→OK／soft `std_compress_try_libs`／soft auto-make；check＝obs（暂停）；tip 产品 `-o` UNDEF／SEGV＝obs（产品另案；brotli ld 仍跳）。报告 `run=`／`obs=`／`skip=`（退役 `stream=`）。

```bash
./tests/run-std-compress-unified-stream-gate.sh
```

```
xlang: [XLANG_STD122_COMPRESS_UNIFIED] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 |
| 2 | `tests/baseline/std-compress-unified-stream-manifest.tsv` |
| 3 | `./tests/run-std-compress-unified-stream-gate.sh` |

---

## 2. 统一流 API（STD-122）

| API | 说明 |
|-----|------|
| `StreamCompress` | 绑定外置 state 缓冲 + format/mode |
| `format_gzip()` | 流格式常量（v1 唯一） |
| `mode_compress()` / `mode_decompress()` | 流模式 |
| `compress_state_bytes()` | 状态缓冲最小字节数 |
| `compress_init` | 绑定 `StreamCompress` + 初始化底层流 |
| `compress_process` | 分块 compress/decompress；`is_last≠0` 为压缩末块 |
| `compress_end` | 释放底层状态 |

扩展（STD-136）：`format_brotli()` / `format_zstd()` + `compress_state_bytes_for(format)`。

烟测向量：`Hello, gz!!!`（12 字节）经 `compress_*` 分块往返。

---

## 4. Gate（见文首 ## Gate）

```bash
./tests/run-std-compress-unified-stream-gate.sh
```
