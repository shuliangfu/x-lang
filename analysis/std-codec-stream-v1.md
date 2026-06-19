# STD-110：std.codec compress/base64 流式编解码适配 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-codec-stream.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-codec-stream.tsv` |
| 3 | `./tests/run-std-codec-stream-gate.sh` |

---

## 2. 流式适配

块 API（`adapter_*_encode/decode`）与流 API 并存，统一经 `StreamCodec` 门面：

| API | 说明 |
|-----|------|
| `codec_kind_base64_stream()` | Base64 流 kind |
| `stream_codec_init_base64(sc, state, cap, url, mode)` | 绑定 base64 流；mode=compress 编码 / decompress 解码 |
| `stream_codec_state_bytes()` | gzip 与 base64 流状态取较大值 |
| `stream_codec_process` / `stream_codec_end` | 按 kind 分发 gzip 或 base64 流 |
| `adapter_compress_stream_init` | gzip 流 init |
| `adapter_compress_stream_process` | gzip 流 process |
| `adapter_compress_stream_end` | gzip 流 end |
| `adapter_base64_stream_init` | base64 流 init |
| `adapter_base64_stream_process` | base64 流 process |
| `adapter_base64_stream_end` | base64 流 end |

gzip 流在未链 zlib 时 `init` 失败；烟测与 `std.compress` 一致，**exit 0 skip**。

---

## 3. 金样

| 输入 | 标准 Base64 |
|------|-------------|
| `"hello"` | `aGVsbG8=` |

烟测：`adapter_base64_stream_*` 分块 `"he"` + `"llo"` 编码后分块解码 ≡ 原文。

---

## 4. 验证与门禁

```bash
./tests/run-std-codec-stream-gate.sh
```
