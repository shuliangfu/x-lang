# std.db kv + arrow 门禁 v1（F-05 soft residual）

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · 假权威闸诚实化  
> 关联：`tests/baseline/std-db-kv-arrow.tsv` · F-05 v4 closure · `std/db/README.md`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-db-kv-arrow.tsv` |
| 3 | `./tests/run-std-db-kv-arrow-gate.sh` |
| 4 | 烟测：`tests/std-db/kv_tick_smoke.x` · `arrow_column_smoke.x` · `examples/cookbook/db_kv_arrow.x` |

---

## 2. API（产品短名）

### std.db.kv

| API | 说明 |
|-----|------|
| `mmap_available` | 平台 mmap 能力探测 |
| `open` / `close` | 打开／关闭 `KvStore` |
| `append_ts` / `get` | Append-Only 时序写／读 |
| `wal_flush` / `compact` / `sync` | WAL 合并／SST 压缩／fsync |
| `sst_level_count` / `wal_bytes` / `compact_generation` | 观测计数 |

### std.db.arrow

| API | 说明 |
|-----|------|
| `new_i32` / `new_f32` | 分配列缓冲 |
| `adopt` | 零拷贝接管外部 f32／i32 buffer |
| `append` / `append_null` / `valid` / `null_bitmap` | 写入与 null 位图 |
| `sum` / `dot` / `sum_valid_i32` | SIMD／标量归约 |
| `batch` / `add` / `length` / `get` / `free` | 批／生命周期 |

C archaeology：`db_kv_smoke_c` · `arrow_smoke_c`（host-C 入口；**非**硬绿信号）。

---

## 3. 金样

| 场景 | 期望 |
|------|------|
| `kv_tick_smoke.x` | append_ts → wal → compact → get；exit **0** |
| `arrow_column_smoke.x` | null bitmap + adopt + batch；exit **0** |
| `db_kv_arrow.x`（cookbook DB-03） | kv Tick + arrow SIMD sum／dot；exit **0** |

产品布局债（`ArrowColumnMem` 32B pack）已于先前波次根修；本波只收闸假权威。

---

## 4. Gate

### 假权威诚实验收（2026-08-26）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `kv_tick_smoke.x`／`arrow_column_smoke.x`／`db_kv_arrow.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- C smoke（`db_kv_smoke_c`／`arrow_smoke_c`）仅观测（archaeology host-C；非硬绿）。
- 无原生 xlang → **FAIL**（禁止 soft SKIP→OK）。
- 报告：`check=`／`kv=`／`arrow=`／`cb=`／`c=`／`skip=`（`kv=1`＋`arrow=1`＋`cb=1` 为硬绿信号）。
- 构建入口：`./xbuild`／闸脚本（**拒** `make -C compiler` 复活为活权威）。

```
xlang: [XLANG_STD_DB_KV_ARROW] status=ok check=0|1 kv=1 arrow=1 cb=1 c=0|1 skip=0
std-db-kv-arrow gate OK
```

- manifest：`tests/baseline/std-db-kv-arrow.tsv`
- 烟测：`tests/std-db/kv_tick_smoke.x` · `tests/std-db/arrow_column_smoke.x` · `examples/cookbook/db_kv_arrow.x`
- 闸：`tests/run-std-db-kv-arrow-gate.sh`
- lib：`tests/lib/std-db-kv-arrow.sh`

---

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-08-26 | Gate honesty：`## 4. Gate`；prefer asm；三路 `.x` 硬绿；C 观测；禁 soft SKIP |
