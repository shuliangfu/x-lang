# STD-033：std.http 分块传输与 Keep-Alive 基础 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：STD-032（POST/HEAD/状态行）、STD-009（GET bench）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-http-chunked.tsv` |
| 3 | `./tests/run-std-http-chunked-gate.sh` |
| 4 | 烟测：`tests/http/chunked_keepalive.x` |

---

## 2. API（v1）

| API | 说明 |
|-----|------|
| `headers_body_offset` | 定位 `\r\n\r\n` 后 body 偏移 |
| `has_chunked_encoding` | 检测 `Transfer-Encoding: chunked` |
| `has_keep_alive` | 检测 `Connection: keep-alive` |
| `decode_chunked_body` | 从缓冲解码 chunked 实体（hex 行 + 数据块） |
| `build_get_keep_alive` | 构建 HTTP/1.1 GET + keep-alive 请求 |

C 实现：`compiler/seeds/http/http_chunked.inc`（由 `runtime_http_glue.from_x.c` include）。

可复现 bench：`bench/i08_http_chunked_decode_bench.x`（循环解码固定向量；门禁仅观测 check，非硬绿信号）。

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

## 4. Gate

```bash
./tests/run-std-http-chunked-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `chunked_keepalive.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- Bench 路径对齐活文件 `bench/i08_http_chunked_decode_bench.x`（拒化石 `http_chunked_decode_bench.x`）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）

manifest：`tests/baseline/std-http-chunked.tsv`

```
xlang: [XLANG_STD_HTTP_CHUNKED] status=ok check=0|1 run=1 skip=0
```

### Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；DOC／TSV→`## 4. Gate`；bench→`i08_*`；未啃产品 `std/http`）。
- 历史：v1 入站 chunked 解码 + keep-alive 检测定版。

---

## 5. 非目标（v2）

- 出站 chunked 编码（客户端发送）
- 多请求连接复用状态机
- Trailer 头解析
- HTTPS
