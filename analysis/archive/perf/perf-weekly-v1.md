# PERF-169 每周性能基线汇总 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` §7.1、`ENG-001` perf-baseline-registry

---

## 1. 四支柱 + STD 扩展

> v1.2026-06-19：第五支柱 **STD**（PERF-172 Phase 3 热路径）。

| 支柱 | 门禁 | baseline | 说明 |
|------|------|----------|------|
| **SIMD** | `run-std-simd-autovec-strategy-gate.sh` | — | 策略 API + 跨平台向量；可选 `run-perf-simd-shuffle-select.sh` |
| **IO** | `run-perf-io-zig-gate.sh` | `tests/baseline/io-perf.tsv` | 顺序/随机吞吐 vs Zig -O2 |
| **NET** | `run-perf-net-zc-gate.sh` + `run-perf-net-zig-gate.sh` | `net-perf.tsv` / `net-zc-perf.tsv` | echo 吞吐 + 零拷贝 CPU/byte |
| **DB** | `run-perf-sqlite-gate.sh` | `tests/baseline/perf-sqlite.tsv` | `sqlite_is_available` 循环烟测 |
| **STD** | `run-perf-phase3-gate.sh` | `tests/baseline/perf-phase3.tsv` | §11 Phase 3 热路径 loop（PERF-172） |

---

## 2. 汇总入口

```bash
./tests/run-perf-weekly-gate.sh
```

已挂入 `run-comprehensive-check-gate.sh`（STD-168）与 `run-portable-suite.sh`。

---

## 3. 跳过策略

- 无 native `shux`/`shux-c`：IO/NET bench 子步骤 SKIP，manifest 仍须全绿。
- 无 `shux_asm`：SIMD shuffle/select perf SKIP，autovec strategy gate 仍须 OK。
- 无 libsqlite3：`sqlite_is_available()==0` 时 DB loop 仍跑 stub 路径。
