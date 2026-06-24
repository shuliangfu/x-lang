# STD-072 std.bytes v1

> 更新时间：2026-06-18  
> 状态：**可用** — 动态缓冲 + 读写游标 + StrView/Buffer 桥接 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-bytes-manifest.tsv` |
| 3 | `./tests/run-std-bytes-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `bytes_new` / `bytes_with_capacity` | 创建空缓冲或预分配 |
| `bytes_append_byte` / `bytes_append_slice` | 追加字节/切片 |
| `bytes_len` / `bytes_capacity` / `bytes_clear` | 长度/容量/清空 |
| `bytes_reserve` / `bytes_grow` | 显式扩容策略 |
| `bytes_deinit` | 释放堆内存 |
| `bytes_as_view` / `bytes_from_view` | StrView 零拷贝 / 拷贝构造 |
| `bytes_as_buffer` | 转为 std.mem.Buffer（IO 桥接） |
| `reader_*` | 读游标 `BytesReader`：read/seek/remaining |
| `writer_*` | 写游标 `BytesWriter`：write/remaining_cap |

实现：`std/bytes/mod.sx`（纯 .sx，依赖 `std.heap`）。

### 与 std.heap / Arena

v1 堆路径见 §2；**STD-155**：`bytes_from_external` 绑定 `Arena64` bump slab，`bytes_is_owned` 区分释放语义。详见 `analysis/std-bytes-arena-v1.md`。

### 与 std.codec

- `encode_into_bytes` / `decode_from_bytes` 通过 `bytes_clear` + `bytes_grow` 复用 cap（STD-139）。
- 解码只读：`bytes_as_view`；写通道：`bytes_as_buffer` → `std.io`。
- 策略全文：`analysis/std-codec-buffer-reuse-v1.md`。

---

## 4. 与 std.codec 协作索引

| 场景 | 推荐 API |
|------|----------|
| 反复编解码 | 单 `Bytes` + `encode_into_bytes` 循环 |
| 已知帧长 | `bytes_with_capacity` + L1 `encoder_encode` |
| 只读解析 | `decode_from_bytes` → `bytes_as_view` |

---

## 5. Gate

```
shux: [SHUX_STD_BYTES] status=ok sx=1 skip=0
std-bytes gate OK
```

Round-trip 向量见 `tests/baseline/std-bytes-vectors.tsv`。
