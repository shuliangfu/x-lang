# PERF-008 syscall 路径批处理优化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-5`（splice）、`PERF-002`（IO 吞吐）、`OBS-003`（结构化日志）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **同吞吐少 syscall** | 批处理 / 零拷贝路径 `io_total` 低于 naive read/write |
| **可测可 cap** | Linux `strace` 统计 read/write/readv/writev/splice/sendfile |
| **共享库** | `tests/lib/perf-syscall-batch.sh` 供 bench / gate / ZC-5 复用 |
| **可 grep** | `shux: [SHUX_SYSCALL_BATCH]` 报告行 |

验收（NEXT PERF-008）：**同吞吐下降低 syscall 次数** → v1 以 A/B strace 对比 + cap 为可执行代理指标。

---

## 2. 测量方法（v1）

| 项 | 说明 |
|----|------|
| 工具 | Linux `strace -e trace=read,write,readv,writev,splice,sendfile` |
| 指标 | `io_total = read + write + readv + writev + splice + sendfile` |
| 文件 batch | `io_batch_readv`（4×4KiB `read_batch_fd`）vs `io_read_chunked`（4KiB `fs_read`） |
| 网络 batch | `zero_copy_splice` vs `zero_copy_readwrite`（64KiB read+write） |

环境：

| 变量 | 默认 | 说明 |
|------|------|------|
| `SHUX_SYSCALL_BATCH_FAIL` | `0` | `1` 时超 cap 或 batch≥ref 硬失败 |
| `SHUX_SYSCALL_BATCH_REQUIRE_STRACE` | `0` | CI Linux 可设 `1` 禁止 SKIP |
| `SHUX_SYSCALL_BATCH_PREFIX` | `shux: [SHUX_SYSCALL_BATCH]` | 报告前缀 |
| `SHUX_SYSCALL_BATCH_BASELINE` | `tests/baseline/syscall-batch-perf.tsv` | cap 表 |
| `SHUX_IO_BENCH_MB` | `16` | bench 文件大小（MiB） |

---

## 3. 基线（syscall-batch-perf.tsv）

| case_id | 路径 | cap 要点 | batch_lt_ref |
|---------|------|----------|--------------|
| `io_batch_readv` | `tests/bench/io_batch_readv.sx` | readv≤1100 | `io_read_chunked` |
| `io_read_chunked` | `tests/bench/io_read_chunked.sx` | read≤4200 | — |
| `zero_copy_splice` | `tests/bench/zero_copy_splice.sx` | splice≥1, ≤20 | `zero_copy_readwrite` |
| `zero_copy_readwrite` | `tests/bench/zero_copy_readwrite.sx` | read/write≤300 | — |

---

## 4. 报告行

```text
shux: [SHUX_SYSCALL_BATCH] case=io_batch_readv read=2 write=0 readv=1024 writev=0 splice=0 sendfile=0 io_total=1026 ref_case=io_read_chunked ref_io_total=4098 ok=1
```

实现：`perf_sb_report_emit()` in `tests/lib/perf-syscall-batch.sh`。

---

## 5. 治理流程

1. 新 I/O 热路径：优先 `read_batch_fd` / `fs_pipe_splice` / `fs_sendfile`。
2. 本地 / CI Linux：`./tests/run-perf-syscall-batch.sh`。
3. 超 cap 或 batch 未优于 ref：调 chunk / batch 宽度或改 API。
4. 门禁：`./tests/run-perf-syscall-batch-gate.sh`。

---

## 6. 门禁

`tests/run-perf-syscall-batch-gate.sh`：

1. RFC + manifest + baseline + lib  
2. `run-zc5-gate.sh` 引用 `perf-syscall-batch.sh`  
3. Linux + strace 可选烟测；其它平台 manifest OK + SKIP bench  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/perf-syscall-batch.tsv` |
| 基线 | `tests/baseline/syscall-batch-perf.tsv` |
| 库 | `tests/lib/perf-syscall-batch.sh` |
| runner | `tests/run-perf-syscall-batch.sh` |
| 门禁 | `tests/run-perf-syscall-batch-gate.sh` |
| ZC-5 | `tests/run-zc5-gate.sh` |
| IO perf | `tests/run-perf-io.sh` |
| 结构化日志 | `analysis/obs-structured-log-v1.md` |

**PERF-008 状态：定版 ✅**
