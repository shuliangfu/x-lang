# STD-171：docs/07 + Cookbook Phase 3 同步 v1

> 状态：**定版（v1）**  
> 关联：`DOC-006`、`§11 #78～#83` 收口项

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-171 | `docs/07` 补 §11 收口 API 表；Cookbook +4 食谱（56 条）；gate |

---

## 2. docs/07 增量（#78～#83）

| # | 模块 | 要点 |
|---|------|------|
| 78 | `std.net` | `tcp_pool_*` idle 复用（STD-164，Phase 2 已列） |
| 79 | `std.async` | `await_read_fd` / `net_read_async` / `fs_read_async` |
| 80 | `std.datetime` | `timezone_iana` / `timezone_offset_at` IANA+DST |
| 81 | `std.compress` | `format_brotli/zstd` + `compress_*` |
| 82 | `std.db.sqlite` | `row_col_blob_len` / `row_col_blob_read` |
| 83 | `std.db.sqlite` | stub `DB_NOT_IMPL` + `sqlite_is_available`（STD-139） |

---

## 3. Cookbook 新增（§17）

| ID | 路径 |
|----|------|
| ASYNC-04 | `examples/cookbook/async_net_fs.sx` |
| DT-01 | `examples/cookbook/datetime_iana.sx` |
| CMP-02 | `examples/cookbook/compress_stream_br_zs.sx` |
| DB-02 | `examples/cookbook/sqlite_blob_stream.sx` |

---

## 4. Gate

```bash
./tests/run-doc-07-phase3-sync-gate.sh
```

报告：`shux: [SHUX_STD171_DOC07_PHASE3_SYNC]`
