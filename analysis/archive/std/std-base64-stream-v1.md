# STD-109：std.base64 流式编解码 v1

> 更新时间：2026-08-25  
> 状态：**定版（v1）** · 假权威闸诚实化  
> 关联：`tests/baseline/std-base64-stream.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-base64-stream.tsv` |
| 3 | `./tests/run-std-base64-stream-gate.sh` |

---

## 2. 流式语义

| API | 说明 |
|-----|------|
| `state_bytes()` | 状态缓冲最小字节数 |
| `enc_init(state, cap, url)` | 初始化编码流（url=1 为 URL 变体） |
| `dec_init(state, cap, url)` | 初始化解码流 |
| `enc_update(..., is_last, in_consumed)` | 增量编码；`is_last=1` flush padding |
| `dec_update(..., is_last, in_consumed)` | 增量解码；`is_last=1` flush 尾部 |

块 API（`encode_standard` 等）与流式结果在相同输入下一致。

---

## 3. 金样

| 输入 | 标准 Base64 |
|------|-------------|
| `"hello"` | `aGVsbG8=` |

烟测：`"he"` + `"llo"` 分块流式编码 ≡ 一次性 `encode_standard`。

---

## 4. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/std-base64/stream.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- C smoke 仅观测（archaeology host-C；非硬绿信号）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。
- 构建入口：`./xbuild`／闸脚本（**拒** `make -C compiler` 复活为活权威）。

```
xlang: [XLANG_STD109_BASE64_STREAM] status=ok check=0|1 run=1 skip=0
std-base64-stream gate OK
```
