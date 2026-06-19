# PERF-009 网络收发零拷贝优化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-1`（provided buffers）、`PERF-003`（网络并发）、`OBS-003`（结构化日志）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **CPU/byte 下降** | 零拷贝（zero-copy）/ batch 路径 cycles/MiB 低于 naive 对照 |
| **高并发可测** | mixed 256 连接 workload 有 cycles/MiB cap |
| **共享库** | `tests/lib/perf-net-zc.sh` 供 net perf / gate 复用 |
| **可 grep** | `shux: [SHUX_NET_ZC]` 报告行 |

验收（NEXT PERF-009）：**高并发下 CPU/byte 降低** → v1 以 Linux `perf stat cycles` / 传输字节为代理指标；provided echo 须优于 batch echo。

---

## 2. 测量方法（v1）

| 项 | 说明 |
|----|------|
| 工具 | Linux `perf stat -e cycles,instructions` |
| 指标 | `cycles_per_mib = cycles × 1048576 / bytes_xfer` |
| ZC-1 echo | `net_echo_throughput_provided` vs `net_echo_throughput`（各 32MiB） |
| 高并发 | `net_mixed_conns_requests`（256×16×512B×2 ≈ 4MiB） |

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_NET_ZC_FAIL` | `0` | `1` 时超 cap 或 zc≥ref 硬失败 |
| `SHUX_NET_ZC_REQUIRE_PERF` | `0` | CI Linux 可设 `1` 禁止 SKIP |
| `SHUX_NET_ZC_PREFIX` | `shux: [SHUX_NET_ZC]` | 报告前缀 |
| `SHUX_NET_ZC_BASELINE` | `tests/baseline/net-zc-perf.tsv` | cap 表 |

---

## 3. 基线（net-zc-perf.tsv）

| case_id | bytes_xfer | max_cycles_per_mib | zc_lt_ref |
|---------|------------|-------------------|-----------|
| `net_echo_throughput_provided` | 33554432 | 1500000000 | `net_echo_throughput` |
| `net_echo_throughput` | 33554432 | 1800000000 | — |
| `net_mixed_conns_requests` | 4194304 | 2500000000 | — |

---

## 4. 报告行

```text
shux: [SHUX_NET_ZC] case=net_echo_throughput_provided cycles=1234567890 bytes=33554432 cycles_per_mib=38654705.60 cap_cycles_per_mib=1500000000 ref_case=net_echo_throughput ref_cycles_per_mib=45000000.00 ok=1
```

实现：`perf_nz_report_emit()` in `tests/lib/perf-net-zc.sh`。

---

## 5. 治理流程

1. Linux + io_uring：`./tests/run-perf-net-zc.sh`（或 `run-perf-net.sh --bench` ZC-1 段）。
2. provided cycles/MiB 须 **低于** batch 对照且 ≤ cap。
3. mixed 高并发：cycles/MiB ≤ cap。
4. 门禁：`./tests/run-perf-net-zc-gate.sh`。

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-net-zc.tsv` |
| 基线 | `tests/baseline/net-zc-perf.tsv` |
| 库 | `tests/lib/perf-net-zc.sh` |
| runner | `tests/run-perf-net-zc.sh` |
| 门禁 | `tests/run-perf-net-zc-gate.sh` |
| ZC-1 | `tests/run-zc1-gate.sh` |
| NET perf | `tests/run-perf-net.sh` |
| PERF-003 | `tests/run-perf-net-zig-gate.sh` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**PERF-009 状态：定版 ✅**
