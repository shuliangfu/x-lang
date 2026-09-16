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

- 无 native `xlang`：子门禁硬 die（拒 soft SKIP→OK）；汇总 gate 不 grep-SKIP 假绿。
- 子门禁 `obs=`／`skip=` 向上传播；子硬红＝汇总硬红。
- 无 libsqlite3：`sqlite_is_available()==0` 时 DB loop 仍跑 stub 路径。

---

## Gate

Honesty soft→硬绿 (2026-08-27): refuse soft SKIP→OK / soft FAIL=0 simd swallow /
missing top-level DOC; DOC=archive; child hard fail = hard fail; propagate
`obs=`／`skip=`; report `run=`／`obs=`／`skip=`.

`tests/run-perf-weekly-gate.sh`：

1. Archive DOC + manifest（拒顶层 `analysis/perf-weekly-v1.md`）  
2. 五支柱：SIMD／IO／NET／DB／STD 子门禁依次跑  
3. 子门禁已 honesty（io-zig／net-zig／simd／…）
