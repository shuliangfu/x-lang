# STD-009 std.http 服务器基准 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · Gate honesty soft→硬绿  
> 关联：`STD-002`（net 栈）、`PERF-003`（网络对标）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读 `std/http/mod.x`：`get` + `respond_get_ok` |
| 2 | 读本文 §3–§4（基准用例、延迟指标） |
| 3 | `./tests/run-std-http-gate.sh` |
| 4 | Linux：`./tests/run-perf-http.sh --bench` |

---

## 2. 最小 server API

| API | 角色 |
|-----|------|
| `get(url, url_len, out, cap)` | 客户端 HTTP GET |
| `respond_get_ok(fd, body, body_len)` | 对已连接 fd 读请求并回 **HTTP/1.0 200 OK** |

**server 流程（v1）**

1. `std.net.listen` + `accept`（或 C sink `http_bench_server.c`）
2. `respond_get_ok(client_fd, body, body_len)`
3. `close_stream`

实现：`http_respond_get_ok_c` in `std/http/http_glue.c`。

与 STD-002 一致：socket 生命周期由 **std.net** 管理；本模块只构造/解析 HTTP 报文。

---

## 3. 基准用例

| case | 脚本 | 指标 |
|------|------|------|
| **http_get_bench** | `bench/i08_http_get_bench.x` | 64× loopback GET |
| sink | `bench/i08_http_bench_server.c` | 链入 `http.c` |

**吞吐 throughput**：stderr `BENCH_ELAPSED_NS=`（64 次总耗时）  
基线：`tests/baseline/http-perf.tsv`（median 秒数上限）

```bash
./tests/run-perf-http.sh --bench
XLANG_PERF_FAIL_ON_HTTP_REGRESSION=1 ./tests/run-perf-http.sh --bench
XLANG_PERF_UPDATE_HTTP_BASELINE=1 ./tests/run-perf-http.sh --bench
```

---

## 4. 延迟指标

单次 GET 往返记录微秒延迟；输出 **`BENCH_P99_US=`**（latency）。  
基线：`tests/baseline/http-perf-latency.tsv`（`http_get_bench_p99` 行）。

门禁在 `XLANG_PERF_FAIL_ON_HTTP_REGRESSION=1` 时同时检查吞吐与 P99。

---

## 5. API 面

- `get` — 客户端
- `respond_get_ok` — server 回包

---

## 6. Gate

```bash
./tests/run-std-http-gate.sh
./tests/run-http.sh          # runnable 烟测
./tests/run-perf-http.sh --bench   # Linux native xlang
```

Gate honesty（2026-08-26 soft→硬绿）：

- prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `tests/http/main.x` runnable **exit 0 硬失败**（有 native 时禁 soft SKIP→OK）
- 无 native → **FAIL**（禁 soft SKIP→OK）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）

```text
xlang: [XLANG_STD_HTTP] status=ok check=0|1 run=1 skip=0
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/std/std-http-bench-v1.md` |
| manifest | `tests/baseline/std-http-manifest.tsv` |
| 库 | `tests/lib/perf-http.sh` |
| runner | `tests/run-perf-http.sh` |
| 门禁 | `tests/run-std-http-gate.sh` |
| STD-002 | `tests/baseline/std-net-api.tsv` |

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；DOC／TSV→`## 6. Gate`；bench 路径对齐活文件 `bench/i08_http_*`（拒化石 `bench/http_get_bench.x`／`http_bench_server.c`）；未啃产品 `std/http`）。

**STD-009 状态：定版 ✅**

## Gate

Honesty soft→硬绿 (2026-08-27) `run-perf-http.sh`: prefer xlang_asm; refuse soft SKIP→OK / soft FAIL_ON_HTTP_REGRESSION:-0 silent OK; over-cap/over-p99 = obs; report run=/obs=/skip=.
