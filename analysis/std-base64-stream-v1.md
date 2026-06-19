# STD-109：std.base64 流式编解码 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-base64-stream.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-base64-stream.tsv` |
| 3 | `./tests/run-std-base64-stream-gate.sh` |

---

## 2. 流式语义

| API | 说明 |
|-----|------|
| `stream_state_bytes()` | 状态缓冲最小字节数 |
| `stream_enc_init(state, cap, url)` | 初始化编码流（url=1 为 URL 变体） |
| `stream_dec_init(state, cap, url)` | 初始化解码流 |
| `stream_enc_update(..., is_last, in_consumed)` | 增量编码；`is_last=1` flush padding |
| `stream_dec_update(..., is_last, in_consumed)` | 增量解码；`is_last=1` flush 尾部 |

块 API（`encode_standard` 等）与流式结果在相同输入下一致。

---

## 3. 金样

| 输入 | 标准 Base64 |
|------|-------------|
| `"hello"` | `aGVsbG8=` |

烟测：`"he"` + `"llo"` 分块流式编码 ≡ 一次性 `encode_standard`。

---

## 4. 门禁

```bash
make -C compiler ../std/base64/base64.o
./tests/run-std-base64-stream-gate.sh
```
