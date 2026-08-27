# PERF-170 SQLite 性能烟测 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`PERF-169` 每周 DB 支柱、`STD-167` `sqlite_is_available`

---

## 1. 目标

在无/有 libsqlite3 环境下，`sqlite_is_available()` 热路径循环不得明显回退。

---

## 2. 用例

- bench：`tests/bench/sqlite_is_available_loop.x`（100k 次调用）
- stub 烟测：`tests/stub/sqlite_net_stub.x`
- baseline：`tests/baseline/perf-sqlite.tsv`（`sqlite_is_available_loop` 中位数秒数上限）

---

## Gate

Honesty soft→硬绿 (2026-08-27): prefer `xlang_asm`; refuse soft SKIP→OK /
soft prefer-xlang-c / missing top-level DOC; over-cap = obs
(`XLANG_PERF_SQLITE_FAIL=1` still hard); DOC=archive; report
`run=`／`obs=`／`skip=`.

```bash
./tests/run-perf-sqlite-gate.sh
```

更新 baseline：`XLANG_PERF_UPDATE_SQLITE_BASELINE=1 ./tests/run-perf-sqlite-gate.sh`
