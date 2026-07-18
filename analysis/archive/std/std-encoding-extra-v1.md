# STD-127：std.encoding Base32 / percent / URL-Base64 v1

> 状态：**定版（v1，扩展编码族门面）**

## API

| 名称 | 说明 |
|------|------|
| `base32_encode` / `base32_decode` | RFC 4648 Base32（含填充） |
| `percent_encode` / `percent_decode` | RFC 3986 unreserved 子集 percent 编解码 |
| `encode_base32_string` / `decode_base32_string` | 与 `std.string` 互操作 |
| `encode_url_base64_string` / `decode_url_base64_string` | 委托 `std.base64` URL 变体 |
| `encoding_extra_smoke` | C 烟测（`foo` → `MZXW6===` + percent 往返） |

## 门禁

`./tests/run-std-encoding-extra-gate.sh`
