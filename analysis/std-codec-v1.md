# STD-073 std.codec v1

> 更新时间：2026-06-18  
> 状态：**可用** — 块/流编解码门面 + 多格式适配 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-codec-manifest.tsv` |
| 3 | `./tests/run-std-codec-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `Encoder` / `Decoder` | 块编解码器（kind 选择后端） |
| `encoder_encode` / `decoder_decode` | 统一块接口 |
| `block_encode` / `block_decode` | BlockCodec 入口 |
| `encode_into_bytes` / `decode_from_bytes` | 与 std.bytes 协作（清空后填充） |
| `StreamCodec` + `codec_*` 流 API | gzip/base64 流式块处理 |
| `adapter_*` | hex/base64/gzip/json/csv 显式适配器（如 `adapter_hex_encode`） |
| `err_*` | 统一错误语义 |

### 零拷贝与缓冲

- 块 API 写入调用方提供的 `out` 缓冲，不隐式堆分配。
- `encode_into_bytes` 复用 `Bytes` 容量；大块前可 `bytes.grow`（见 std.bytes reserve 策略）。
- **STD-139** 完整策略见 `analysis/std-codec-buffer-reuse-v1.md`（L1/L2/L3 分层、cap 复用、流式 state、StrView/IO 桥接）。

---

## 4. 与 std.bytes 协作索引

| std.bytes | std.codec 用法 |
|-----------|----------------|
| `bytes.clear` | L2 编解码前清空 len、保留 cap |
| `bytes.grow` / `bytes.new` | 按 `encode_upper_bound` 预分配 |
| `bytes_as_view` | 解码结果零拷贝读 |
| `bytes_as_buffer` | 编码结果写 IO |

详见 `analysis/std-bytes-v1.md` §4。

---

## 5. Gate

```
shux: [SHUX_STD_CODEC] status=ok sx=1 skip=0
std-codec gate OK
```

Round-trip 向量：`tests/baseline/std-codec-vectors.tsv`。
