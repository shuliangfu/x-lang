# 阶段 F-http v1（std.http 去 C）

> **F-http v1**：删除 **`http.c`**；模块锚点在 **`http.x`**；HTTP/1.x/H2 在 **`http_glue.c`** + `*.inc.c`。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `http.c`（~1000 行 + inc） | `http.x` + `http_glue.c` |
| `http.o` | `cc -c` | `ld -r` 合并 |

## Gate

Honesty (2026-08-27): hard-fail; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_HTTP_V1_FAIL` retired. Delegates STD-009 http + chunked + methods + https hard. Observational residuals: server-pool / reqresp / h2 / context (listed skip).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-http-v1-gate.sh
./tests/run-std-http-gate.sh
./tests/run-std-http-chunked-gate.sh
./tests/run-std-http-methods-gate.sh
./tests/run-std-http-https-gate.sh
```


## 下一项

- **F-tar v1** ✅ / **F-channel v1**
