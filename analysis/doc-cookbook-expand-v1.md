# DOC-006 Cookbook 扩充 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 读者：需覆盖 STD-013～040 与 CORE-006 的开发者  
> 前置：[`doc-stdlib-cookbook-v1.md`](doc-stdlib-cookbook-v1.md)（DOC-001，§2～§5 共 12 食谱）

---

## 1. 阅读路径（扩充版，约 45 分钟）

| 时段 | 章节 | 产出 |
|------|------|------|
| **0–12 min** | DOC-001 §2～§5 | IO / NET / ZC / ASYNC 主路径 |
| **12–20 min** | §7 容器 + 迭代 | map / vec / set / iterator |
| **20–28 min** | §8 字符串与诊断 | StrView / heap trace / fmt / error / env |
| **28–35 min** | §9 系统接口 | path / fs / process / dynlib / runtime |
| **35–42 min** | §10 序列化 | json / csv / unicode / tar / compress / encoding |
| **42–45 min** | §11～§12 | HTTP / DNS / IO 回退 + gate 验证 |
| **45–50 min** | §17 | §11 收口 async/datetime/compress/sqlite |

---

## 7. 容器与迭代（STD-013～015 / CORE-006）

### ITER-01：`examples/cookbook/iter_slice_sum.x`

`core.iterator` 遍历 `i32[]` 求和（CORE-006）。

### MAP-01：`examples/cookbook/map_u64_get.x`

`Map_u64_i32` insert/get/remove（STD-013）。

### VEC-01：`examples/cookbook/vec_i32_push.x`

`Vec_i32` push/pop/append_slice（STD-014）。

### SET-01：`examples/cookbook/set_u64_insert.x`

`Set_u64` insert/contains/remove（STD-015）。

---

## 8. 字符串、堆诊断与格式化（STD-016～020 / STD-025）

### STR-01：`examples/cookbook/strview_subview.x`

`string_view_subview` 零拷贝子视图（STD-016 / ZC-4）。

### HEAP-01：`examples/cookbook/heap_trace_reset.x`

`heap_trace_reset` / `heap_trace_enabled`（STD-017）。

### FMT-01：`examples/cookbook/fmt_two_fields.x`

`format_2` / `format_3` 多类型字段（STD-019）。

### ERR-01：`examples/cookbook/error_module_base.x`

`error_code_to_module_base` 与 sidecar 种类（STD-020）。

### ENV-01：`examples/cookbook/env_args_iter.x`

`args_iter` / `env_iter` 遍历（STD-025）。

---

## 9. 路径、进程与运行时（STD-021～028）

### PATH-01：`examples/cookbook/path_join_basename.x`

`path_join` / `path_basename`（STD-021）。

### FS-01：`examples/cookbook/fs_invalid_handle.x`

`fs_invalid_handle` 哨兵（STD-001 配套）。

### PROC-01：`examples/cookbook/process_getpid.x`

`getpid` 当前进程 ID（STD-023）。

### DYN-01：`examples/cookbook/dynlib_open_sym.x`

`open` / `close` 跨平台系统库（STD-027）。

### RT-01：`examples/cookbook/runtime_panic_hook.x`

`runtime_ready` + `panic_hook_collect`（STD-028）。

---

## 10. 序列化与压缩（STD-034～040）

### JSON-01：`examples/cookbook/json_object_parse.x`

`skip_value` 游标跳过 JSON 值（STD-034）。

### CSV-01：`examples/cookbook/csv_write_row.x`

`write_row` / `parse_row` 往返（STD-036）。

### UNI-01：`examples/cookbook/unicode_nfc_smoke.x`

`is_supplementary` / `rune_utf8_len`（STD-037）。

### TAR-01：`examples/cookbook/tar_append_entry.x`

`append_entry` 构建 UStar 条目（STD-038）。

### CMP-01：`examples/cookbook/compress_gzip_roundtrip.x`

`gzip_compress` / `gzip_decompress`（STD-007 / STD-039）。

### ENC-01：`examples/cookbook/encoding_hex_encode.x`

`hex_encode` 原始缓冲（STD-040）。

---

## 11. 网络与 HTTP 扩展（STD-029 / STD-032 / STD-033）

### NET-04：`examples/cookbook/net_resolve_invalid.x`

`resolve_ex` 对 `invalid.invalid` 须失败（STD-029）。

### HTTP-01：`examples/cookbook/http_parse_status.x`

`parse_status_line` 离线解析（STD-032）。

### HTTP-02：`examples/cookbook/http_chunked_decode.x`

`decode_chunked_body` + `has_chunked_encoding` / `has_keep_alive` 离线金样（STD-033）。

DOC-001 已覆盖 NET-01～03：`examples/cookbook/net_listen_bind.x`、`net_udp_bind.x`、`net_stream_write.x`。

---

## 12. IO 回退与验证

### IO-04：`examples/cookbook/io_fallback_read.x`

`read_fd` / `write_fd` 非 Linux 回退 typeck（STD-026）。  
深潜：`analysis/std-io-fallback-v1.md`。

DOC-001 已覆盖 IO-01～03：`examples/cookbook/io_batch_rw.x`、`io_read_chunk.x`、`io_mmap_read.x`。

```bash
# DOC-006 manifest + 40 食谱 typeck
./tests/run-doc-cookbook-expand-gate.sh

# DOC-001 基线 12 食谱（仍独立门禁）
./tests/run-doc-stdlib-cookbook-gate.sh
```

---

## 13. 全量食谱索引（42）

| ID | 路径 | 模块 |
|----|------|------|
| IO-01 | `examples/cookbook/io_batch_rw.x` | std.io |
| IO-02 | `examples/cookbook/io_read_chunk.x` | std.io |
| IO-03 | `examples/cookbook/io_mmap_read.x` | std.io |
| IO-04 | `examples/cookbook/io_fallback_read.x` | std.io |
| NET-01 | `examples/cookbook/net_listen_bind.x` | std.net |
| NET-02 | `examples/cookbook/net_udp_bind.x` | std.net |
| NET-03 | `examples/cookbook/net_stream_write.x` | std.net |
| NET-04 | `examples/cookbook/net_resolve_invalid.x` | std.net |
| ZC-01 | `examples/cookbook/zc_arena_concat.x` | std.string |
| ZC-02 | `examples/cookbook/zc_read_ptr_slice.x` | std.io |
| ZC-03 | `examples/cookbook/zc_provided_buffers.x` | std.io |
| ASYNC-01 | `examples/cookbook/async_mod_import.x` | std.async |
| ASYNC-02 | `examples/cookbook/async_drain_idle.x` | std.async |
| ASYNC-03 | `examples/cookbook/async_channel_ping.x` | std.async |
| ITER-01 | `examples/cookbook/iter_slice_sum.x` | core.iterator |
| MAP-01 | `examples/cookbook/map_u64_get.x` | std.map |
| VEC-01 | `examples/cookbook/vec_i32_push.x` | std.vec |
| SET-01 | `examples/cookbook/set_u64_insert.x` | std.set |
| STR-01 | `examples/cookbook/strview_subview.x` | std.string |
| HEAP-01 | `examples/cookbook/heap_trace_reset.x` | std.heap |
| FMT-01 | `examples/cookbook/fmt_two_fields.x` | std.fmt |
| ERR-01 | `examples/cookbook/error_module_base.x` | std.error |
| ENV-01 | `examples/cookbook/env_args_iter.x` | std.env |
| PATH-01 | `examples/cookbook/path_join_basename.x` | std.path |
| PATH-02 | `examples/cookbook/path_clean_extreme.x` | std.path |
| FS-01 | `examples/cookbook/fs_invalid_handle.x` | std.fs |
| PROC-01 | `examples/cookbook/process_getpid.x` | std.process |
| DYN-01 | `examples/cookbook/dynlib_open_sym.x` | std.dynlib |
| RT-01 | `examples/cookbook/runtime_panic_hook.x` | std.runtime |
| JSON-01 | `examples/cookbook/json_object_parse.x` | std.json |
| CSV-01 | `examples/cookbook/csv_write_row.x` | std.csv |
| UNI-01 | `examples/cookbook/unicode_nfc_smoke.x` | std.unicode |
| TAR-01 | `examples/cookbook/tar_append_entry.x` | std.tar |
| CMP-01 | `examples/cookbook/compress_gzip_roundtrip.x` | std.compress |
| ENC-01 | `examples/cookbook/encoding_hex_encode.x` | std.encoding |
| HTTP-01 | `examples/cookbook/http_parse_status.x` | std.http |
| HTTP-02 | `examples/cookbook/http_chunked_decode.x` | std.http |
| CSTR-01 | `examples/cookbook/core_str_index.x` | core.str |
| TIME-02 | `examples/cookbook/time_timer_elapsed.x` | std.time |
| TIME-03 | `examples/cookbook/time_rfc3339_format.x` | std.time |
| CTX-01 | `examples/cookbook/context_cancel_deadline.x` | std.context |
| ERR-02 | `examples/cookbook/error_semantic_class.x` | std.error |
| SLICE-02 | `examples/cookbook/slice_u64_subslice.x` | core.slice |
| BUILT-01 | `examples/cookbook/builtin_bitops.x` | core.builtin |
| VEC-02 | `examples/cookbook/vec_u16_push.x` | std.vec |
| MAP-02 | `examples/cookbook/map_iter_load_factor.x` | std.map |
| QUEUE-01 | `examples/cookbook/queue_u8_push.x` | std.queue |
| NET-05 | `examples/cookbook/net_tcp_pool.x` | std.net |
| THREAD-01 | `examples/cookbook/thread_pool_stats.x` | std.thread |
| FMT-02 | `examples/cookbook/fmt_template_i32.x` | std.fmt |
| STR-02 | `examples/cookbook/string_case_fold.x` | std.string |
| DB-01 | `examples/cookbook/sqlite_available.x` | std.db.sqlite |

---

## 14. Phase 2 增量（STD-131～140）

### CSTR-01：`examples/cookbook/core_str_index.x`

`bytes_view_index_of_byte` / `bytes_view_index_of` / `bytes_view_starts_with`（STD-131）。

### TIME-02：`examples/cookbook/time_timer_elapsed.x`

`Timer` + `timer_elapsed_ns` / `timer_reset`（STD-133）。

### TIME-03：`examples/cookbook/time_rfc3339_format.x`

`format_wall_rfc3339` / `wall_local_offset_min`（STD-137）。

### PATH-02：`examples/cookbook/path_clean_extreme.x`

`path_clean` 连续斜杠折叠（STD-140）。

---

## 15. Phase 2 增量（STD-156 / STD-158）

### CTX-01：`examples/cookbook/context_cancel_deadline.x`

`with_cancel` / `with_timeout` / `cancel` / `remaining_ns` / 键值 bag（STD-156）。

### ERR-02：`examples/cookbook/error_semantic_class.x`

`error_semantic_class` / `error_is_timeout` / `error_recommend_retry`（STD-158）。

---

## 16. Phase 2 增量（STD-159～167 / CORE-018）

| ID | 食谱 | 模块 |
|----|------|------|
| SLICE-02 | `examples/cookbook/slice_u64_subslice.x` | core.slice |
| BUILT-01 | `examples/cookbook/builtin_bitops.x` | core.builtin |
| VEC-02 | `examples/cookbook/vec_u16_push.x` | std.vec |
| MAP-02 | `examples/cookbook/map_iter_load_factor.x` | std.map |
| QUEUE-01 | `examples/cookbook/queue_u8_push.x` | std.queue |
| NET-05 | `examples/cookbook/net_tcp_pool.x` | std.net |
| THREAD-01 | `examples/cookbook/thread_pool_stats.x` | std.thread |
| FMT-02 | `examples/cookbook/fmt_template_i32.x` | std.fmt |
| STR-02 | `examples/cookbook/string_case_fold.x` | std.string |
| DB-01 | `examples/cookbook/sqlite_available.x` | std.db.sqlite |

---

## 17. Phase 3 增量（§11 #78～#83 / STD-171）

### ASYNC-04：`examples/cookbook/async_net_fs.x`

`net_fs_async_smoke` — async net/fs fd 路径 pipe 烟测（#79）。

### DT-01：`examples/cookbook/datetime_iana.x`

`timezone_iana` 解析内置 UTC 区（#80）。

### CMP-02：`examples/cookbook/compress_stream_br_zs.x`

`stream_compress_*` brotli/zstd 分块往返；未链库时 skip（#81）。

### DB-02：`examples/cookbook/sqlite_blob_stream.x`

`row_col_blob_len` / `row_col_blob_read` 分块读；stub 时 skip（#82）。

### DB-03：`examples/cookbook/db_kv_arrow.x`

`std.db.kv` WAL→compact→SST 冻结 + `std.db.arrow` SIMD 列归约；mmap 不可用时 skip（#92）。

---

## 18. Phase 3 增量（std.db #90～#92）

DB-03 见 §17；API 见 docs/07 STD-DB-001 与 `std/db/README.md`。

---

## 19. 自检（3 题）

1. Cookbook 总数是否 ≥57？→ `./tests/run-doc-cookbook-expand-gate.sh`
2. §11 收口 API 是否在 docs/07？→ `./tests/run-doc-07-phase3-sync-gate.sh`
3. 与 DOC-001 关系？→ DOC-001 保 12 条基线；DOC-006 扩充至 57
