# PERF-170 SQLite 性能烟测 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`PERF-169` 每周 DB 支柱、`STD-167` `sqlite_is_available`

---

## 1. 目标

在无/有 libsqlite3 环境下，`sqlite_is_available()` 热路径循环不得明显回退。

---

## 2. 用例

- bench：`tests/bench/sqlite_is_available_loop.sx`（100k 次调用）
- stub 烟测：`tests/stub/sqlite_net_stub.sx`
- baseline：`tests/baseline/perf-sqlite.tsv`（`sqlite_is_available_loop` 中位数秒数上限）

---

## 3. 门禁

```bash
./tests/run-perf-sqlite-gate.sh
```

更新 baseline：`SHUX_PERF_UPDATE_SQLITE_BASELINE=1 ./tests/run-perf-sqlite-gate.sh`
