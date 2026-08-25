# STD-072 std.bytes v1

> 更新时间：2026-08-25  
> 状态：**可用** — 动态缓冲 + 读写游标 + StrView/Buffer 桥接 + gate（假权威诚实）

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
| `new` / `with_capacity` | 创建空缓冲或预分配 |
| `append_byte` / `extend` | 追加字节/切片 |
| `length` / `capacity` / `clear` | 长度/容量/清空（产品名 `length`，非化石 `len`） |
| `reserve` / `grow` | 显式扩容策略 |
| `deinit` | 释放堆内存 |
| `as_view` / `from_view` | StrView 零拷贝 / 拷贝构造 |
| `as_buffer` | 转为 std.mem.Buffer（IO 桥接） |
| `reader` / `read` / `seek` / `remaining` | 读游标 `BytesReader` |
| `writer` / `write` / `remaining_cap` | 写游标 `BytesWriter` |

实现：`std/bytes/mod.x`（纯 .x，依赖 `std.heap`）。

### 与 std.heap / Arena

v1 堆路径见 §2；**STD-155**：`from_external` 绑定 `Arena64` bump slab，`is_owned` 区分释放语义。详见 `analysis/archive/std/std-bytes-arena-v1.md`。

### 与 std.codec

- `encode_into_bytes` / `decode_from_bytes` 通过 `clear` + `grow` 复用 cap（STD-139）。
- 解码只读：`as_view`；写通道：`as_buffer` → `std.io`。
- 策略全文见 archive codec 缓冲复用 RFC（勿在 `analysis/` 顶层复活）。

---

## 4. 与 std.codec 协作索引

| 场景 | 推荐 API |
|------|----------|
| 反复编解码 | 单 `Bytes` + `encode_into_bytes` 循环 |
| 已知帧长 | `with_capacity` + L1 `encoder_encode` |
| 只读解析 | `decode_from_bytes` → `as_view` |

---

## 5. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/std-bytes/roundtrip.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。

```
xlang: [XLANG_STD_BYTES] status=ok check=0|1 run=1 skip=0
std-bytes gate OK
```

Round-trip 向量见 `tests/baseline/std-bytes-vectors.tsv`。
