# 网络并发对标 Zig v1（PERF-003）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-001`（Zig 基线）、`PERF-002`（IO 对标）、`STD-002`（std.net）、`tests/run-perf-net.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **连接吞吐** | `net_accept_many`：批量 accept + close（server 侧 Shu vs C） |
| **请求吞吐** | `net_echo_throughput`：单连接 4×4KiB×1024 batch echo（client 侧 Shu vs C vs Zig） |
| **连接/请求混合** | `net_mixed_conns_requests`：256 建连 × 每连接 16 轮 512B echo |
| **P99 延迟** | mixed client 每轮 RTT 采样，门禁 P99 ≤ `net-perf-latency.tsv` |
| **对标 Zig** | Shu client median wall **≤** Zig -O2（echo + mixed） |

验收标准（NEXT PERF-003）：**吞吐（wall 中位数）与 P99 延迟达到基线目标**（越小越好）。

---

## 2. 用例矩阵（v1）

| case_id | 维度 | 规模 | Shu 角色 | 对照 |
|---------|------|------|----------|------|
| `net_accept_many` | **连接** | 1024/4096 建连 | server（accept_many） | C server |
| `net_echo_throughput` | **请求** | 16MiB 双向 | client（stream_*_batch） | C / **Zig** client |
| `net_mixed_conns_requests` | **混合** | 256×16×512B | client | C / **Zig** client + P99 |
| `net_udp_many` | UDP 批量 | 1024 pkts | server | C server |

环境变量：`SHUX_NET_BENCH_CONNS=1024`（CI 默认）、`SHUX_NET_RUNS=3`、`SHUX_PERF_BASELINE_RUNS=3`。

---

## 3. 门禁

### 3.1 PERF-003 专用

```bash
./tests/run-perf-net-zig-gate.sh
# 等价：
SHUX_PERF_FAIL_ON_NET_ZIG=1 \
SHUX_PERF_FAIL_ON_NET_REGRESSION=1 \
SHUX_PERF_FAIL_ON_NET_P99=1 \
  ./tests/run-perf-net.sh --bench
```

| 检查 | 条件 |
|------|------|
| **≥ Zig（吞吐）** | `net_echo_throughput`、`net_mixed_conns_requests`：Shu median ≤ Zig median |
| **Shu 回归** | Shu median ≤ `tests/baseline/net-perf.tsv` |
| **P99** | mixed：`Shu_p99 ≤ net-perf-latency.tsv`（微秒） |
| **Zig 不可用** | 跳过 Zig 列（WARN）；`SHUX_ZIG_BASELINE_STRICT=1` 时 FAIL |

### 3.2 与现有 net 门禁关系

- `run-perf-p1-gate.sh` / `run-zc1-gate.sh`：仍用 `SHUX_PERF_FAIL_ON_NET_REGRESSION=1`
- PERF-003 在 P1 之上叠加 Zig + P99（可选 CI opt-in）

---

## 4. 基线文件

| 文件 | 用途 |
|------|------|
| `tests/baseline/net-perf.tsv` | Shu wall 中位数上限（秒） |
| `tests/baseline/net-perf-latency.tsv` | mixed P99 上限（微秒） |
| `tests/baseline/zig-perf.tsv` | net case 清单（PERF-001 扩展） |

更新：

```bash
SHUX_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench
```

---

## 5. P99 度量说明（v1）

- **采样**：mixed client 每轮 512B write+read 记一次 RTT（`CLOCK_MONOTONIC` / `now_monotonic_us`）
- **聚合**：每轮 bench 输出 `BENCH_P99_US=<n>` 到 stderr；`RUNS` 轮取 P99 中位数
- **v1 不含**：跨机 RTT、TLS、HTTP 层延迟（留给 STD-009 / v2）

---

## 6. 平台说明

| case | Linux | macOS | 备注 |
|------|-------|-------|------|
| net_accept_many | ✅ | ✅ | 动态端口避免 TIME_WAIT |
| net_echo_throughput | ✅ | ✅ | Zig client 需 pin 0.13 |
| net_mixed_conns_requests | ✅ | ✅ | P99 本机 loopback |
| net_echo_throughput_provided | ✅ Linux io_uring | skip | ZC-1 子路径 |
| net_udp_many | ✅ | ✅ | recvmmsg/sendmmsg |

---

## 7. v2 预留

| 项 | 说明 |
|----|------|
| 多连接并发 mixed | 非串行建连 |
| HTTP/WS 层吞吐 | 基于 `std.net` 统一栈 |
| P99/P999 分位报表 | 除 stderr 标记外输出 TSV |

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 跑 bench | `tests/run-perf-net.sh --bench` |
| PERF-003 gate | `tests/run-perf-net-zig-gate.sh` |
| mixed 源 | `tests/bench/net_mixed_conns_requests.{su,c,zig}` |
| echo Zig | `tests/bench/net_echo_throughput.zig` |

**PERF-003 状态：定版 ✅**
