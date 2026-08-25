# STD-032：std.http POST/HEAD 与响应状态行解析

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`tests/baseline/std-http-methods.tsv`、`tests/http/methods_status.x`

---

## 1. 阅读路径

15 分钟速览：`std/http/mod.x` → `std/http/http_glue.c` → `tests/http/methods_status.x`。

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

## 4. Gate

```bash
./tests/run-std-http-methods-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `methods_status.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）

manifest：`tests/baseline/std-http-methods.tsv`

```
xlang: [XLANG_STD_HTTP_METHODS] status=ok check=0|1 run=1 skip=0
```

### Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；DOC／TSV→`## 4. Gate`；未啃产品 `std/http`）。
- 历史：v1 POST／HEAD／PUT／DELETE／PATCH／OPTIONS＋`parse_status_line` 定版。

## 5. 非目标（v2+）

- 出站 chunked 编码、连接复用状态机 → **STD-033 ✅**（入站解码 + keep-alive 检测）
- HTTPS / TLS → STD-030
