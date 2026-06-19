# PERF-172：§11 Phase 3 std 微基准 v1

> 更新时间：2026-06-19  
> 状态：**定版（v1）**  
> 关联：PERF-169 weekly、`STD-171` docs Phase 3

---

## 1. 目标

为 #78～#83 收口 API 提供 **可重复 loop 烟测**，挂入 PERF-169 第五支柱 **STD**。

| bench | 循环内容 |
|-------|----------|
| `phase3_std_hotpath_loop` | `timezone_iana(UTC)` + `compress_format_*` + `stream_compress_state_bytes_for` + `tcp_pool_new_simple`/drain/destroy |

---

## 2. Gate

```bash
./tests/run-perf-phase3-gate.sh
```

```
shux: [SHUX_PERF_PHASE3] status=ok check=1 run=1 skip=0
```

无 native shux 时 typeck SKIP；manifest 仍须全绿。

---

## 3. Baseline

`tests/baseline/perf-phase3.tsv` — 中位数 real 秒上限。

更新：`SHUX_PERF_UPDATE_PHASE3_BASELINE=1 ./tests/run-perf-phase3-gate.sh`

---

## 4. 与 PERF-169 关系

`run-perf-weekly-gate.sh` 第五支柱 **STD** 调用本 gate。
