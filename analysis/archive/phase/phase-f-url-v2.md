# 阶段 F-url v2（std.url 逻辑 .x 下沉 + F-ZC）

> **F-url v2**：**parse/build/query/resolve** 迁入 **`url.x`**；**F-ZC** 删除 **`url_glue.c`**，IPv6 转换经 **`inet_pton` / `inet_ntop` extern**。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| URL 逻辑 | `url_glue.c`（456 行） | **`url.x`** | 同 v2 |
| IPv6 文本转换 | glue 内联 | `url_glue.c` | **`.x` + libc extern** |
| `url.o` | `ld -r` glue + x | `ld -r` inet glue + x | **纯 `.x`** |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_URL_V2_FAIL` retired. Delegates STD-076 url + STD-134 ipv6-host hard.

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-url-v2-gate.sh
./tests/run-std-url-gate.sh
./tests/run-std-url-ipv6-host-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场 security_os_glue / ffi_cb_glue 等
