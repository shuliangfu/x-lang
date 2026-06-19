# IO 吞吐对标 Zig v1（PERF-002）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-001`（Zig 基线）、`STD-001`（std.io）、`tests/run-perf-io.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **顺序 IO** | mmap 扫描、readv batch、顺序 write |
| **随机 IO** | 随机 offset pread（模拟非顺序访问） |
| **对标 Zig** | Shu median real **≤** Zig -O2（同用例） |
| **Shu 回归** | median ≤ `tests/baseline/io-perf.tsv` 上限 |

验收标准（NEXT PERF-002）：**中位吞吐达到并稳定 ≥ Zig**（以 wall time 中位数衡量，越小越好）。

---

## 2. 用例矩阵（v1）

| case_id | 类型 | 数据量 | Shu 源 | Zig/C 对照 |
|---------|------|--------|--------|------------|
| `io_mmap_throughput` | **顺序** | 16MiB mmap 全扫描 | `.sx` | `.c` / `.zig` |
| `io_batch_readv` | **顺序** | 16MiB，4×4KiB×1024 轮 readv | `.sx` | `.c` / `.zig` |
| `io_random_pread` | **随机** | 16MiB 文件，1024×4KiB 随机 pread | `.sx` | `.c` / `.zig` |
| `io_write_throughput` | **顺序** | 16MiB 顺序 write | `.sx` | `.c` / `.zig` |
| `zero_copy_sendfile` | 零拷贝 | 16MiB file→socket | `.sx` | `.c` / `.zig` |
| `zero_copy_splice` | 零拷贝 | Linux splice | `.sx` | — |

环境变量：`SHUX_IO_BENCH_MB=16`（默认）、`SHUX_PERF_BASELINE_RUNS=3`。

---

## 3. 门禁

### 3.1 PERF-002 专用

```bash
./tests/run-perf-io-zig-gate.sh
# 等价：
SHUX_PERF_FAIL_ON_IO_ZIG=1 SHUX_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench
```

| 检查 | 条件 |
|------|------|
| **≥ Zig** | 每个有 `.zig` 的 case：`Shu_median ≤ Zig_median` |
| **Shu 回归** | `Shu_median ≤ io-perf.tsv` 上限 |
| **Zig 不可用** | 跳过 Zig 列（WARN）；`SHUX_PERF_IO_ZIG_REQUIRED=1` 时 FAIL |

### 3.2 CI 集成

- `run-io-unified-gate.sh --perf`：Linux 可设 `SHUX_PERF_FAIL_ON_IO_ZIG=1`
- `run-ci-full-suite.sh`：full perf 路径

---

## 4. 基线文件

| 文件 | 用途 |
|------|------|
| `tests/baseline/io-perf.tsv` | Shu 中位数上限（秒） |
| `tests/baseline/zig-perf.tsv` | Zig pin 版本 + IO case 清单（PERF-001） |

更新 Shu 上限：

```bash
SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-io.sh --bench
```

---

## 5. 平台说明

| case | Linux | macOS | Windows |
|------|-------|-------|---------|
| io_mmap_throughput | ✅ | ✅ | ✅ |
| io_batch_readv | ✅ readv | ✅ | ✅ |
| io_random_pread | ✅ pread | ✅ | ✅ |
| io_write_throughput | ✅ | ✅ | ✅ |
| zero_copy_sendfile | ✅ | ⚠️ | ⚠️ |
| zero_copy_splice | ✅ | skip | skip |

---

## 6. v2 预留

| 项 | 说明 |
|----|------|
| 多线程 random pread | fs_pread 并发 |
| io_uring 随机读 | 与 provided 路径对比 |
| 吞吐 MB/s 指标 | 除 wall time 外输出带宽 |

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 跑 bench | `tests/run-perf-io.sh --bench` |
| PERF-002 gate | `tests/run-perf-io-zig-gate.sh` |
| Zig pin | `analysis/perf-zig-baseline-v1.md` |

**PERF-002 状态：定版 ✅**
