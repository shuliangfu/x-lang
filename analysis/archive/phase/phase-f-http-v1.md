# 阶段 F-http v1（std.http 去 C）

> **F-http v1**：删除 **`http.c`**；模块锚点在 **`http.x`**；HTTP/1.x/H2 在 **`http_glue.c`** + `*.inc.c`。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `http.c`（~1000 行 + inc） | `http.x` + `http_glue.c` |
| `http.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_HTTP_V1_FAIL` retired. Delegates STD-009 http + chunked + methods + https hard. Observational residuals: server-pool / reqresp / h2 / context (listed skip).

**2026-08-30 leftover XLANG fallthrough 已收**（f-http-v1：`for cand in "${XLANG:-}"` 退役；prefer asm＋`XLANG_LINK_XLANG`；显式坏 XLANG 先硬 die；缺 native 硬 die；leftover nested xlang_compiler_make／std-http／std-http-chunked／std-http-methods／std-http-https／observational server-pool／reqresp／h2／context 不重写）。

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-http-v1-gate.sh
./tests/run-std-http-gate.sh
./tests/run-std-http-chunked-gate.sh
./tests/run-std-http-methods-gate.sh
./tests/run-std-http-https-gate.sh
```


## 下一项

- **F-tar v1** ✅ / **F-channel v1**
