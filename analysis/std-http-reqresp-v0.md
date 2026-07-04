# STD-HTTP-REQRESP：std.http Request/Response v0

> 更新时间：2026-06-19  
> 状态：**v4（HttpResponseOwned + push 堆 body）**  
> 关联：`std/http/mod.x`、`std/http/http_reqresp.inc.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-http-reqresp.tsv` |
| 3 | `./tests/run-std-http-reqresp-gate.sh` |
| 4 | 烟测：`tests/http/request_response.x` |

---

## 2. Request/Response v0

| API | 说明 |
|-----|------|
| `HttpRequest` | method/url/body/timeout_ms |
| `HttpResponse` | status/raw_len/header_end/body_len/chunked |
| `request_init` | 构造请求 |
| `parse_response` | 离线解析 raw 缓冲 |
| `execute` | 发请求 + 解析响应 |
| `response_body_decode` | chunked 解码或返回 body_len |
| `response_parse_smoke` | C 烟测 |

v0 不分配堆内存；body 仍位于用户提供的 raw 缓冲内（`buf + header_end`）。

---

## 3. HTTP/2 Huffman

| API | 说明 |
|-----|------|
| `hpack_huffman_decode` | RFC 7541 静态表 Huffman 解码 |
| `hpack_huffman_is_available` | 解码层可用 |
| `hpack_huffman_smoke` | 解码 "www.example.com" 烟测 |

`hpack_decode_status` 等路径在 HPACK 字符串 H=1 时自动走 Huffman。

---

## 4. HTTP/2 流控

| API | 说明 |
|-----|------|
| `build_window_update` | WINDOW_UPDATE 帧（13 字节） |
| `default_initial_window` | 65535 |
| `frame_window_update` | 帧类型 8 |
| `flow_control_smoke` | 烟测 |

---

## 6. Request/Response v1

| API | 说明 |
|-----|------|
| `HttpBodyOwned` | 堆分配 body（`std.heap.alloc`） |
| `execute_ctx` | HttpRequest + Context 超时/取消 |
| `response_body_view` | identity body 零拷贝 `HttpBodyView` |
| `response_body_owned` | 复制/解码 body 到堆 |
| `body_owned_free` | 释放堆 body |
| `response_body_owned_smoke` | C 复制烟测 |

## 7. Request/Response v2（HttpUrlOwned）

| API | 说明 |
|-----|------|
| `HttpUrlOwned` | 堆分配 URL（>256B；`std.string.String` 装不下时用） |
| `http_url_string_cap()` | String 固定容量 256 |
| `url_exceeds_string_cap` | 检测是否须堆 URL |
| `url_owned_from_slice` / `url_owned_free` | 复制/释放 |
| `request_bind_url_owned` | 绑定 `HttpRequest.url` |
| `url_owned_smoke` | C 烟测（300 字节） |

烟测：`tests/http/request_url_owned.x`。

---

## 8. Request/Response v3（HttpRequestOwned）

| API | 说明 |
|-----|------|
| `HttpRequestOwned` | 堆 URL + 堆 body + method/timeout |
| `request_owned_init` / `request_owned_free` | 构造/释放 |
| `execute_owned` | 绑定 HttpRequest 后 execute |
| `request_owned_smoke` | C 烟测 |

烟测：`tests/http/request_owned.x`。

---

## 9. Request/Response v4（HttpResponseOwned）

| API | 说明 |
|-----|------|
| `HttpResponseOwned` | status + 堆 body + push 元数据/堆 push body |
| `response_owned_from_parse` | 从 raw buf + `HttpResponse` 构造 |
| `response_owned_free` | 释放堆 body / push body |
| `push_last_body_owned` | 复制最近一次 push 到堆（`push_last_copy` + alloc） |

烟测：`tests/http/response_owned.x`。

---

## 5. 验证与门禁

```bash
./tests/run-std-http-reqresp-gate.sh
```

```
shux: [SHUX_STD_HTTP_REQRESP] status=ok smoke=1 skip=0
```
