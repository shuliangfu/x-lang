# STD-032：std.http POST/HEAD 与响应状态行解析

## 1. 阅读路径

15 分钟速览：`std/http/mod.sx` → `std/http/http.c` → `tests/http/methods_status.sx`。

## 2. 客户端 API

在 STD-009 `get` / `respond_get_ok` 基础上扩展：

| API | 说明 |
|-----|------|
| `get` / `post` / `head` / `put` / `delete` / `patch` / `options` | 七种 HTTP 方法 |
| `client_request(method, url, url_len, body, body_len, out_buf, out_cap)` | 统一客户端入口 |
| `Method` 枚举 | GET=0, POST=1, HEAD=2, PUT=3, DELETE=4, PATCH=5, OPTIONS=6 |
| `method_as_u8` / `method_from_u8` | 枚举 ↔ u8 判别值 |
| `parse_status_line(buf, len, out_code)` | 解析 `HTTP/x.y CODE ...` 首行，写三位状态码 |

C 实现：`http_*_c`、`http_request_method_c`；共用 `http_request_ex_c`（通用方法字符串 + Content-Length）。

## 3. 状态行解析

- 输入：完整响应缓冲或仅状态行片段。
- 成功：返回 `0`，`*out_code` 为 100–599。
- 失败：返回 `-1`（版本非法、无空格、非三位数字等）。

## 4. 验证与门禁

- manifest：`tests/baseline/std-http-methods.tsv`
- 烟测：`tests/http/methods_status.sx`（离线 204/404 + 可选网络 HEAD/POST）
- 门禁：`tests/run-std-http-methods-gate.sh`（`SHUX_STD_HTTP_METHODS`）
- 与 STD-009 关系：GET/server bench 不变；本 RFC 仅扩展客户端方法与解析。

## 5. 非目标（v2+）

- 出站 chunked 编码、连接复用状态机 → **STD-033 ✅**（入站解码 + keep-alive 检测）
- HTTPS / TLS → STD-030
