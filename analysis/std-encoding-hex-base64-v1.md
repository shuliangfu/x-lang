# STD-040：std.encoding hex/Base64 与 std.string 互操作 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`std.base64`（STD-007）、`std.string`（STD-016 StrView）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4（职责划分） |
| 2 | `tests/baseline/std-encoding-hex-base64.tsv` |
| 3 | `./tests/run-std-encoding-hex-base64-gate.sh` |
| 4 | 烟测：`tests/encoding/hex_base64_string.sx` |

---

## 2. 与 std.base64 职责划分

| 模块 | 职责 | 典型调用方 |
|------|------|------------|
| **std.base64** | 字节缓冲级标准/URL Base64 `encode_*` / `decode_*`；无 `String` 依赖 | 协议栈、固定缓冲、性能热路径 |
| **std.encoding** | UTF-8/ASCII 校验与分类；**hex** 编解码；**String/StrView 门面** | 应用层、日志、配置、人类可读串 |

**规则（v1）**：

1. 需要 **仅字节 API** → `import("std.base64")` 或 `encoding.hex_encode`。
2. 需要 **写入 `String` 或从 `StrView` 解码** → `import("std.encoding")` 的 `encode_*_string` / `decode_*_string`。
3. `std.encoding` **不**复制 `std.base64` 表驱动实现；Base64 门面委托 `std.base64`。
4. hex **仅**在 `std.encoding`（`encoding.c`），`std.base64` 不含 hex。

---

## 3. API

### 3.1 十六进制（缓冲）

| API | 说明 |
|-----|------|
| `hex_encode` / `hex_decode` | 小写 `a-f`；奇数长度或非法字符 → -1 |
| `hex_encoded_len` / `hex_decoded_len` | 长度辅助 |

### 3.2 String 互操作

| API | 说明 |
|-----|------|
| `encode_hex_string(src, src_len, out: *String)` | 清空后写入；成功 0 |
| `decode_hex_string(hex: StrView, out, out_cap)` | 返回字节数 |
| `encode_base64_string` | 委托 `encode_standard` |
| `decode_base64_string` | 委托 `decode_standard` |

**容量**：`String` 上限 `string_capacity()`=256；更长数据用 `(ptr,len)` + `hex_encode` / `std.base64`。

---

## 4. 验证与门禁

```bash
./tests/run-std-encoding-hex-base64-gate.sh
```

```
shux: [SHUX_STD_ENCODING_HEX_B64] status=ok hex=1 b64=1 main=1 skip=0
```

金样：`deadbeef` 往返；`foo` → `Zm9v` Base64 String 往返。

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | hex + String 门面 + 职责划分文档 |
