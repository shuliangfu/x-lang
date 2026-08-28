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

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/encoding/encoding.o`＝obs（拒 soft `ensure_std_c_o`／auto-make）；check＝obs（暂停）；tip 产品 `-o` UNDEF／SEGV＝obs（产品另案；encoding-hex／uuid 仍跳）。报告 `run=`／`obs=`／`skip=`（退役 `c=`／`x=`）。

```bash
./tests/run-std-encoding-extra-gate.sh
```

```
xlang: [XLANG_STD127_ENCODING_EXTRA] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.
