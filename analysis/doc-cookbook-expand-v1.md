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

### ITER-01：`examples/cookbook/iter_slice_sum.sx`

`core.iterator` 遍历 `[]i32` 求和（CORE-006）。

### MAP-01：`examples/cookbook/map_u64_get.sx`

`Map_u64_i32` insert/get/remove（STD-013）。

### VEC-01：`examples/cookbook/vec_i32_push.sx`

`Vec_i32` push/pop/append_slice（STD-014）。

### SET-01：`examples/cookbook/set_u64_insert.sx`

`Set_u64` insert/contains/remove（STD-015）。

---

## 8. 字符串、堆诊断与格式化（STD-016～020 / STD-025）

### STR-01：`examples/cookbook/strview_subview.sx`

`string_view_subview` 零拷贝子视图（STD-016 / ZC-4）。

### HEAP-01：`examples/cookbook/heap_trace_reset.sx`

`heap_trace_reset` / `heap_trace_enabled`（STD-017）。

### FMT-01：`examples/cookbook/fmt_two_fields.sx`

`format_2` / `format_3` 多类型字段（STD-019）。

### ERR-01：`examples/cookbook/error_module_base.sx`

`error_code_to_module_base` 与 sidecar 种类（STD-020）。

### ENV-01：`examples/cookbook/env_args_iter.sx`

`args_iter` / `env_iter` 遍历（STD-025）。

---

## 9. 路径、进程与运行时（STD-021～028）

### PATH-01：`examples/cookbook/path_join_basename.sx`

`path_join` / `path_basename`（STD-021）。

### FS-01：`examples/cookbook/fs_invalid_handle.sx`

`fs_invalid_handle` 哨兵（STD-001 配套）。

### PROC-01：`examples/cookbook/process_getpid.sx`

`getpid` 当前进程 ID（STD-023）。

### DYN-01：`examples/cookbook/dynlib_open_sym.sx`

`open` / `close` 跨平台系统库（STD-027）。

### RT-01：`examples/cookbook/runtime_panic_hook.sx`

`runtime_ready` + `panic_hook_collect`（STD-028）。

---

## 10. 序列化与压缩（STD-034～040）

### JSON-01：`examples/cookbook/json_object_parse.sx`

`skip_value` 游标跳过 JSON 值（STD-034）。

### CSV-01：`examples/cookbook/csv_write_row.sx`

`write_row` / `parse_row` 往返（STD-036）。

### UNI-01：`examples/cookbook/unicode_nfc_smoke.sx`

`is_supplementary` / `rune_utf8_len`（STD-037）。

### TAR-01：`examples/cookbook/tar_append_entry.sx`

`append_entry` 构建 UStar 条目（STD-038）。

### CMP-01：`examples/cookbook/compress_gzip_roundtrip.sx`

`gzip_compress` / `gzip_decompress`（STD-007 / STD-039）。

### ENC-01：`examples/cookbook/encoding_hex_encode.sx`

`hex_encode` 原始缓冲（STD-040）。

---

## 11. 网络与 HTTP 扩展（STD-029 / STD-032 / STD-033）

### NET-04：`examples/cookbook/net_resolve_invalid.sx`

`resolve_ex` 对 `invalid.invalid` 须失败（STD-029）。

### HTTP-01：`examples/cookbook/http_parse_status.sx`

`parse_status_line` 离线解析（STD-032）。

### HTTP-02：`examples/cookbook/http_chunked_decode.sx`

`decode_chunked_body` + `has_chunked_encoding` / `has_keep_alive` 离线金样（STD-033）。

DOC-001 已覆盖 NET-01～03：`examples/cookbook/net_listen_bind.sx`、`net_udp_bind.sx`、`net_stream_write.sx`。

---

## 12. IO 回退与验证

### IO-04：`examples/cookbook/io_fallback_read.sx`

`read_fd` / `write_fd` 非 Linux 回退 typeck（STD-026）。  
深潜：`analysis/std-io-fallback-v1.md`。

DOC-001 已覆盖 IO-01～03：`examples/cookbook/io_batch_rw.sx`、`io_read_chunk.sx`、`io_mmap_read.sx`。

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
| IO-01 | `examples/cookbook/io_batch_rw.sx` | std.io |
| IO-02 | `examples/cookbook/io_read_chunk.sx` | std.io |
| IO-03 | `examples/cookbook/io_mmap_read.sx` | std.io |
| IO-04 | `examples/cookbook/io_fallback_read.sx` | std.io |
| NET-01 | `examples/cookbook/net_listen_bind.sx` | std.net |
| NET-02 | `examples/cookbook/net_udp_bind.sx` | std.net |
| NET-03 | `examples/cookbook/net_stream_write.sx` | std.net |
| NET-04 | `examples/cookbook/net_resolve_invalid.sx` | std.net |
| ZC-01 | `examples/cookbook/zc_arena_concat.sx` | std.string |
| ZC-02 | `examples/cookbook/zc_read_ptr_slice.sx` | std.io |
| ZC-03 | `examples/cookbook/zc_provided_buffers.sx` | std.io |
| ASYNC-01 | `examples/cookbook/async_mod_import.sx` | std.async |
| ASYNC-02 | `examples/cookbook/async_drain_idle.sx` | std.async |
| ASYNC-03 | `examples/cookbook/async_channel_ping.sx` | std.async |
| ITER-01 | `examples/cookbook/iter_slice_sum.sx` | core.iterator |
| MAP-01 | `examples/cookbook/map_u64_get.sx` | std.map |
| VEC-01 | `examples/cookbook/vec_i32_push.sx` | std.vec |
| SET-01 | `examples/cookbook/set_u64_insert.sx` | std.set |
| STR-01 | `examples/cookbook/strview_subview.sx` | std.string |
| HEAP-01 | `examples/cookbook/heap_trace_reset.sx` | std.heap |
| FMT-01 | `examples/cookbook/fmt_two_fields.sx` | std.fmt |
| ERR-01 | `examples/cookbook/error_module_base.sx` | std.error |
| ENV-01 | `examples/cookbook/env_args_iter.sx` | std.env |
| PATH-01 | `examples/cookbook/path_join_basename.sx` | std.path |
| PATH-02 | `examples/cookbook/path_clean_extreme.sx` | std.path |
| FS-01 | `examples/cookbook/fs_invalid_handle.sx` | std.fs |
| PROC-01 | `examples/cookbook/process_getpid.sx` | std.process |
| DYN-01 | `examples/cookbook/dynlib_open_sym.sx` | std.dynlib |
| RT-01 | `examples/cookbook/runtime_panic_hook.sx` | std.runtime |
| JSON-01 | `examples/cookbook/json_object_parse.sx` | std.json |
| CSV-01 | `examples/cookbook/csv_write_row.sx` | std.csv |
| UNI-01 | `examples/cookbook/unicode_nfc_smoke.sx` | std.unicode |
| TAR-01 | `examples/cookbook/tar_append_entry.sx` | std.tar |
| CMP-01 | `examples/cookbook/compress_gzip_roundtrip.sx` | std.compress |
| ENC-01 | `examples/cookbook/encoding_hex_encode.sx` | std.encoding |
| HTTP-01 | `examples/cookbook/http_parse_status.sx` | std.http |
| HTTP-02 | `examples/cookbook/http_chunked_decode.sx` | std.http |
| CSTR-01 | `examples/cookbook/core_str_index.sx` | core.str |
| TIME-02 | `examples/cookbook/time_timer_elapsed.sx` | std.time |
| TIME-03 | `examples/cookbook/time_rfc3339_format.sx` | std.time |
| CTX-01 | `examples/cookbook/context_cancel_deadline.sx` | std.context |
| ERR-02 | `examples/cookbook/error_semantic_class.sx` | std.error |
| SLICE-02 | `examples/cookbook/slice_u64_subslice.sx` | core.slice |
| BUILT-01 | `examples/cookbook/builtin_bitops.sx` | core.builtin |
| VEC-02 | `examples/cookbook/vec_u16_push.sx` | std.vec |
| MAP-02 | `examples/cookbook/map_iter_load_factor.sx` | std.map |
| QUEUE-01 | `examples/cookbook/queue_u8_push.sx` | std.queue |
| NET-05 | `examples/cookbook/net_tcp_pool.sx` | std.net |
| THREAD-01 | `examples/cookbook/thread_pool_stats.sx` | std.thread |
| FMT-02 | `examples/cookbook/fmt_template_i32.sx` | std.fmt |
| STR-02 | `examples/cookbook/string_case_fold.sx` | std.string |
| DB-01 | `examples/cookbook/sqlite_available.sx` | std.db.sqlite |

---

## 14. Phase 2 增量（STD-131～140）

### CSTR-01：`examples/cookbook/core_str_index.sx`

`bytes_view_index_of_byte` / `bytes_view_index_of` / `bytes_view_starts_with`（STD-131）。

### TIME-02：`examples/cookbook/time_timer_elapsed.sx`

`Timer` + `timer_elapsed_ns` / `timer_reset`（STD-133）。

### TIME-03：`examples/cookbook/time_rfc3339_format.sx`

`format_wall_rfc3339` / `wall_local_offset_min`（STD-137）。

### PATH-02：`examples/cookbook/path_clean_extreme.sx`

`path_clean` 连续斜杠折叠（STD-140）。

---

## 15. Phase 2 增量（STD-156 / STD-158）

### CTX-01：`examples/cookbook/context_cancel_deadline.sx`

`with_cancel` / `with_timeout` / `cancel` / `remaining_ns` / 键值 bag（STD-156）。

### ERR-02：`examples/cookbook/error_semantic_class.sx`

`error_semantic_class` / `error_is_timeout` / `error_recommend_retry`（STD-158）。

---

## 16. Phase 2 增量（STD-159～167 / CORE-018）

| ID | 食谱 | 模块 |
|----|------|------|
| SLICE-02 | `examples/cookbook/slice_u64_subslice.sx` | core.slice |
| BUILT-01 | `examples/cookbook/builtin_bitops.sx` | core.builtin |
| VEC-02 | `examples/cookbook/vec_u16_push.sx` | std.vec |
| MAP-02 | `examples/cookbook/map_iter_load_factor.sx` | std.map |
| QUEUE-01 | `examples/cookbook/queue_u8_push.sx` | std.queue |
| NET-05 | `examples/cookbook/net_tcp_pool.sx` | std.net |
| THREAD-01 | `examples/cookbook/thread_pool_stats.sx` | std.thread |
| FMT-02 | `examples/cookbook/fmt_template_i32.sx` | std.fmt |
| STR-02 | `examples/cookbook/string_case_fold.sx` | std.string |
| DB-01 | `examples/cookbook/sqlite_available.sx` | std.db.sqlite |

---

## 17. Phase 3 增量（§11 #78～#83 / STD-171）

### ASYNC-04：`examples/cookbook/async_net_fs.sx`

`net_fs_async_smoke` — async net/fs fd 路径 pipe 烟测（#79）。

### DT-01：`examples/cookbook/datetime_iana.sx`

`timezone_iana` 解析内置 UTC 区（#80）。

### CMP-02：`examples/cookbook/compress_stream_br_zs.sx`

`stream_compress_*` brotli/zstd 分块往返；未链库时 skip（#81）。

### DB-02：`examples/cookbook/sqlite_blob_stream.sx`

`row_col_blob_len` / `row_col_blob_read` 分块读；stub 时 skip（#82）。

### DB-03：`examples/cookbook/db_kv_arrow.sx`

`std.db.kv` WAL→compact→SST 冻结 + `std.db.arrow` SIMD 列归约；mmap 不可用时 skip（#92）。

---

## 18. Phase 3 增量（std.db #90～#92）

DB-03 见 §17；API 见 docs/07 STD-DB-001 与 `std/db/README.md`。

---

## 19. 自检（3 题）

1. Cookbook 总数是否 ≥57？→ `./tests/run-doc-cookbook-expand-gate.sh`
2. §11 收口 API 是否在 docs/07？→ `./tests/run-doc-07-phase3-sync-gate.sh`
3. 与 DOC-001 关系？→ DOC-001 保 12 条基线；DOC-006 扩充至 57
