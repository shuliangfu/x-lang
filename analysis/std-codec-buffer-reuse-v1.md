# STD-139：std.codec 缓冲复用与零拷贝策略 v1

> 状态：**定版（v1）**  
> 关联：`analysis/std-codec-v1.md`、`analysis/std-bytes-v1.md`、`NEXT.md` std.codec 🟡 项

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-139 | codec ↔ bytes 缓冲复用/零拷贝策略文档 + 烟测 + gate |

统一块/流编解码与 `std.bytes` 的协作约定，避免隐式堆分配与重复扩容。

---

## 2. 三层 API 与拷贝边界

| 层级 | 入口 | 分配 | 零拷贝 |
|------|------|------|--------|
| L1 块 | `encoder_encode` / `decoder_decode` | 调用方提供 `out` | ✅ 写入用户缓冲 |
| L2 Bytes 桥 | `encode_into_bytes` / `decode_from_bytes` | `Bytes` 堆（`bytes_grow`） | 复用 `Bytes.cap`，不清空容量 |
| L3 流 | `stream_codec_process` | 调用方 `state` + `out` | 分块增量，无整包拷贝 |

**原则**：codec 不在 L1/L3 隐式 `malloc`；L2 仅通过 `std.bytes` 扩容。

---

## 3. 缓冲复用（与 std.bytes 对齐）

### 3.1 `encode_into_bytes` / `decode_from_bytes`

1. 内部先 `bytes_clear`（`len=0`，**保留 cap**）。
2. `encode_upper_bound` 估算上界 → `bytes_grow(b, need)`。
3. 块编解码写入 `b.ptr`，最后设 `b.len`。

**热路径**：同一 `Bytes` 反复编解码时，第二次起通常不再 `realloc`（cap 已足够）。

### 3.2 预分配

大块或固定大小协议帧：先 `bytes_with_capacity` 或 `bytes_grow`，再 L1 直接 `encoder_encode` 到 `b.ptr`（跳过 L2 的 clear+grow 组合亦可）。

### 3.3 流式

`StreamCodec` 的 `state` 由调用方提供（`stream_codec_state_bytes()` 取最小尺寸）；`out` 为每块输出缓冲。gzip/base64 stream 均不持有堆指针。

### 3.4 与 StrView / IO

- 解码结果在 `Bytes` 内：用 `bytes_as_view` 零拷贝读（生命周期 ≤ `Bytes`）。
- 写 socket/file：用 `bytes_as_buffer` 桥接 `std.mem.Buffer` → `io.write`。

---

## 4. 反模式

| 避免 | 推荐 |
|------|------|
| 每帧 `bytes_new` + `bytes_deinit` | 循环外建 `Bytes`，循环内 L2 或 L1 |
| 未知上界反复小步 `append` | `encode_upper_bound` + 一次 `bytes_grow` |
| 块 API 传入栈上过小缓冲 | 先 `encode_upper_bound` 或走 L2 |

---

## 5. Gate

```bash
./tests/run-std-codec-buffer-reuse-gate.sh
```

烟测：`tests/std-codec/buffer_reuse.sx`（连续两次 `encode_into_bytes` 验证 cap 复用）。

报告：`shux: [SHUX_STD139_CODEC_BUFFER_REUSE]`
