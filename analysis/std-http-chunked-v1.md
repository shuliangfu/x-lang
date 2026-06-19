# STD-033：std.http 分块传输与 Keep-Alive 基础 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-032（POST/HEAD/状态行）、STD-009（GET bench）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/std-http-chunked.tsv` |
| 3 | `./tests/run-std-http-chunked-gate.sh` |
| 4 | 烟测：`tests/http/chunked_keepalive.sx` |

---

## 2. API（v1）

| API | 说明 |
|-----|------|
| `headers_body_offset` | 定位 `\r\n\r\n` 后 body 偏移 |
| `has_chunked_encoding` | 检测 `Transfer-Encoding: chunked` |
| `has_keep_alive` | 检测 `Connection: keep-alive` |
| `decode_chunked_body` | 从缓冲解码 chunked 实体（hex 行 + 数据块） |
| `build_get_keep_alive` | 构建 HTTP/1.1 GET + keep-alive 请求 |

C 实现：`std/http/http_chunked.inc.c`（由 `http.c` include）。

---

## 3. 金样向量（可复现 bench）

合成响应：

```
HTTP/1.1 200 OK\r\n
Transfer-Encoding: chunked\r\n
Connection: keep-alive\r\n
\r\n
5\r\n
hello\r\n
0\r\n
\r\n
```

| 检查 | 期望 |
|------|------|
| `has_chunked_encoding` | true |
| `has_keep_alive` | true |
| `decode_chunked_body` | `"hello"`，len=5 |

---

## 4. Bench

`tests/bench/http_chunked_decode_bench.sx`：循环解码固定向量 1000 次（纯 CPU，无网络）；门禁 typeck + 可选 runnable。

与 STD-009 `http_get_bench` 互补：本 bench 测**解析热路径**，非 socket 吞吐。

---

## 5. Gate

```bash
./tests/run-std-http-chunked-gate.sh
```

```
shux: [SHUX_STD_HTTP_CHUNKED] status=ok chunked=1 keepalive=1 typeck=1 skip=0
```

---

## 6. 非目标（v2）

- 出站 chunked 编码（客户端发送）
- 多请求连接复用状态机
- Trailer 头解析
- HTTPS
