# STD-034（STD-HTTP-HTTPS）：std.http HTTPS 客户端一体

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：STD-032（methods）、STD-033（chunked）、STD-009（GET bench）

---

## 1. 阅读路径（15min）

- `std/http/mod.x` — `get`/`post`/`head` 与 `get_ctx` 等 Context 版
- `std/http/http_glue.c` — URL 解析、`http_tls_bridge.inc.c` weak 桩
- `std/net/mod.x` — `tls_connect_client` / `tls_is_available`

## 2. HTTPS 语义

| API | 说明 |
|-----|------|
| `https_is_available()` | 链入 OpenSSL/mbedTLS 时为 true |
| `get("https://host/path", ...)` | TCP + TLS + HTTP/1.0 GET |
| `http_err_tls_not_impl()` / `err_tls_not_impl()` | 无 TLS 后端时 https URL 返回 -1221 |

默认端口：`https://` → 443；`http://` → 80。

## 3. 依赖

- **传输**：`std.net` TLS（`net_tls_*`）；`http.o` 单独链时 weak 桩。
- **运行时**：`XLANG_NET_TLS=openssl|mbedtls|auto` 与 net TLS gate 一致。

## 4. Gate

```bash
./tests/run-std-http-https-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `https_smoke.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP；offline：无 TLS → `err_tls_not_impl`）
- C stub / OpenSSL s_server 烟测 **仅观测**（非硬绿信号）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）

manifest：`tests/baseline/std-http-https.tsv`

关键词锚：`STD-HTTP-HTTPS` · `https_is_available` · `err_tls_not_impl` · `https://` · `TLS` · `net_tls`

## 5. 变更记录

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；DOC／TSV→`## 4. Gate`；C/OpenSSL 仅观测；未啃产品 `std/http`／`std/net` TLS 后端）。
- 历史：v1 HTTPS 客户端一体（探测 + offline TLS-not-impl + 可选 OpenSSL）。
