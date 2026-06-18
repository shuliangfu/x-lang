# std.codec

统一编解码抽象：块 `Encoder`/`Decoder`、gzip 流式、`std.bytes` 桥接。

## 缓冲复用与零拷贝（STD-139）

| 层级 | API | 说明 |
|------|-----|------|
| L1 块 | `encoder_encode` / `decoder_decode` | 写入调用方 `out`，无隐式分配 |
| L2 Bytes | `encode_into_bytes` / `decode_from_bytes` | `bytes_clear` 保留 cap + `bytes_grow` |
| L3 流 | `stream_codec_process` | 调用方提供 `state` 与分块 `out` |

策略全文：`analysis/std-codec-buffer-reuse-v1.md`；`std.bytes` 侧见 `analysis/std-bytes-v1.md` §4。

## 适配格式

| kind | 后端 | 双向 |
|------|------|------|
| hex | std.encoding | ✅ |
| base64 | std.base64 | ✅ |
| gzip | std.compress | ✅（需 zlib） |
| base64 stream | std.base64 | ✅（STD-110 流式） |
| json_escape | std.json | encode-only |
| csv_escape | std.csv | encode-only |

## Gate

```bash
./tests/run-std-codec-gate.sh
./tests/run-std-codec-stream-gate.sh
```
