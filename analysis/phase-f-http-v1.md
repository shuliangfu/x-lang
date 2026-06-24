# 阶段 F-http v1（std.http 去 C）

> **F-http v1**：删除 **`http.c`**；模块锚点在 **`http.sx`**；HTTP/1.x/H2 在 **`http_glue.c`** + `*.inc.c`。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `http.c`（~1000 行 + inc） | `http.sx` + `http_glue.c` |
| `http.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_HTTP_V1_FAIL=1 ./tests/run-f-http-v1-gate.sh
./tests/run-std-http-gate.sh
./tests/run-std-http-chunked-gate.sh
./tests/run-std-http-methods-gate.sh
./tests/run-std-http-server-pool-gate.sh
./tests/run-std-http-reqresp-gate.sh
./tests/run-std-http-https-gate.sh
./tests/run-std-http-h2-gate.sh
./tests/run-std-http-context-gate.sh
```

## 下一项

- **F-tar v1** ✅ / **F-channel v1**
