# STD-HTTP-HTTPS：std.http HTTPS 客户端一体

## 1. 阅读路径（15min）

- `std/http/mod.sx` — `get`/`post`/`head` 与 `get_ctx` 等 Context 版
- `std/http/http_glue.c` — URL 解析、`http_tls_bridge.inc.c` weak 桩
- `std/net/mod.sx` — `tls_connect_client` / `tls_is_available`

## 2. HTTPS 语义

| API | 说明 |
|-----|------|
| `https_is_available()` | 链入 OpenSSL/mbedTLS 时为 true |
| `get("https://host/path", ...)` | TCP + TLS + HTTP/1.0 GET |
| `http_err_tls_not_impl()` | 无 TLS 后端时 https URL 返回 -1221 |

默认端口：`https://` → 443；`http://` → 80。

## 3. 依赖

- **传输**：`std.net` TLS（`net_tls_*`）；`http.o` 单独链时 weak 桩。
- **运行时**：`SHUX_NET_TLS=openssl|mbedtls|auto` 与 net TLS gate 一致。

## 4. 验证与门禁

```bash
./tests/run-std-http-https-gate.sh
```

OpenSSL 可用时 C 烟测经 `SHUX_HTTPS_SMOKE_PORT` 连本地 s_server。
