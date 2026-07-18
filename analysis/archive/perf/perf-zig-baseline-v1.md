# Zig 对标基线 v1（PERF-001）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`PERF-002`（IO 吞吐对标）、`PERF-003`（网络对标）、`analysis/perf-vs-zig-baseline.md`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **版本固定** | 官方对照 Zig **0.13.0**（与 CI tarball 一致） |
| **参数固定** | `-O2`；失败回退 `-O ReleaseFast`（0.13+） |
| **机器可追溯** | 参考宿主 **Linux/x86_64**；录制时写入 `reference_date` |
| **可复现** | 单一 TSV + 共享 lib + 门禁脚本 |

验收标准（NEXT PERF-001）：**基线可复现可追溯**。

---

## 2. 固定参数

| 项 | 值 |
|----|-----|
| Zig 版本 | **0.13.0**（`SHUX_CI_ZIG_VERSION` / `ci_install_zig_tarball`） |
| 允许版本 | 0.13.x、0.14.x（WARN）；`SHUX_ZIG_BASELINE_STRICT=1` 仅允许 pin 主次版本 |
| 优化 | `-O2` → 回退 `-O ReleaseFast` |
| 运行次数 | **3** 次取 real 中位数（`meta runs=3`） |
| 编译命令 | `zig build-exe … -femit-bin=…` |
| Shu 对照编译 | `./compiler/shux-c -O2`（`run-perf-baseline.sh`） |

**注意**：Zig **0.16+** 移除 `-O2` 且 `tests/bench/*.zig` 面向 0.13 API；录制/严格对标须用 **0.13.0**。

---

## 3. 基线文件

| 文件 | 用途 |
|------|------|
| `tests/baseline/zig-perf.tsv` | meta + case 清单（median 可 `--record` 填充） |
| `tests/lib/zig-baseline.sh` | 版本检查、`zig_build_exe_o2`、median 工具 |
| `tests/run-zig-baseline-gate.sh` | manifest / 版本 / 可选 verify / record |

**版本治理（ENG-001）**：`zig-perf` 已登记于 `tests/baseline/perf-baseline-registry.tsv`；改 median 须 bump registry `version`。

### 3.1 case 清单（v1）

| case_id | 类别 | 源文件 |
|---------|------|--------|
| loop_i32 | microbench | tests/bench/loop_i32.zig |
| mem_copy | microbench | tests/bench/mem_copy.zig |
| struct_param | microbench | tests/bench/struct_param.zig |
| call_boundary | microbench | tests/bench/call_boundary.zig |
| io_mmap_throughput | io | tests/bench/io_mmap_throughput.zig |
| io_batch_readv | io | tests/bench/io_batch_readv.zig |
| io_random_pread | io | tests/bench/io_random_pread.zig |
| io_write_throughput | io | tests/bench/io_write_throughput.zig |
| zero_copy_sendfile | io | tests/bench/zero_copy_sendfile.zig |
| net_echo_throughput | net | tests/bench/net_echo_throughput.zig |
| net_mixed_conns_requests | net | tests/bench/net_mixed_conns_requests.zig |

网络 Zig 对照见 `analysis/perf-net-zig-v1.md`（PERF-003）；门禁 `tests/run-perf-net-zig-gate.sh`。

---

## 4. 跑法

### 4.1 安装 pin 版 Zig（本地）

```bash
SHUX_CI_ZIG_VERSION=0.13.0 ./tests/run-ci-full-suite.sh   # 或 ci_install_zig_tarball 逻辑
export PATH="$PWD/.ci-zig/zig-linux-x86_64-0.13.0:$PATH"
zig version   # 0.13.0
```

### 4.2 门禁（默认）

```bash
./tests/run-zig-baseline-gate.sh
SHUX_ZIG_BASELINE_STRICT=1 ./tests/run-zig-baseline-gate.sh
```

### 4.3 录制 reference median（Linux x86_64 推荐）

```bash
SHUX_ZIG_BASELINE_RECORD=1 ./tests/run-zig-baseline-gate.sh --record
# 更新 zig-perf.tsv 第 5 列后 commit
```

### 4.4 与现有 perf 脚本关系

| 脚本 | Zig 对照 |
|------|----------|
| `run-perf-baseline.sh --bench` | P0 microbench；`SHUX_PERF_FAIL_ON_ZIG=1` |
| `run-perf-io.sh --bench` | IO；`SHUX_PERF_FAIL_ON_IO_ZIG=1` |
| `run-perf-net.sh --bench` | 仅 Shu 回归（net-perf.tsv） |

三者均应 `source tests/lib/zig-baseline.sh` 并使用 `zig_build_exe_o2`。

---

## 5. 变更流程

1. 增删 case → 改 `zig-perf.tsv` + 补 `tests/bench/*.zig`
2. 换 Zig 主次版本 → 改 `meta zig_version_pin` + 全量 `--record`
3. 换参考机器 → 改 `reference_host` / `reference_date` 并重录
4. CI：`run-zig-baseline-gate.sh` 纳入 portable / full suite（manifest 硬门禁）

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 微 bench 说明 | `analysis/perf-vs-zig-baseline.md` |
| IO Shu 上限 | `tests/baseline/io-perf.tsv` |
| Net Shu 上限 | `tests/baseline/net-perf.tsv` |
| 路线图 | `NEXT.md` PERF-001 / PERF-002 |

**PERF-001 状态：定版 ✅**（median 列由 Linux x86_64 + zig 0.13.0 `--record` 填充；manifest/版本/trace 已就绪。）
