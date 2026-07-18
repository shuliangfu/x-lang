# 阶段 F-url v2（std.url 逻辑 .x 下沉 + F-ZC）

> **F-url v2**：**parse/build/query/resolve** 迁入 **`url.x`**；**F-ZC** 删除 **`url_glue.c`**，IPv6 转换经 **`inet_pton` / `inet_ntop` extern**。

## 变更

| 项 | v1 | v2 | F-ZC |
|----|----|-----|------|
| URL 逻辑 | `url_glue.c`（456 行） | **`url.x`** | 同 v2 |
| IPv6 文本转换 | glue 内联 | `url_glue.c` | **`.x` + libc extern** |
| `url.o` | `ld -r` glue + x | `ld -r` inet glue + x | **纯 `.x`** |

## 门禁

```bash
SHUX_F_URL_V2_FAIL=1 ./tests/run-f-url-v2-gate.sh
./tests/run-std-url-gate.sh
./tests/run-std-url-ipv6-host-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
```

## 下一项

- **F-ZC Z8** 继续清场 security_os_glue / ffi_cb_glue 等
