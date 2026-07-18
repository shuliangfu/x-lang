# NEXT-YELLOW 全量 🟡 清除 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` 全部功能表 🟡 项

---

## 1. 交付一览

| ID | 模块 | 交付 |
|----|------|------|
| CORE-018 | core.builtin | `bswap_u32` / `rotl_u32` / `rotr_u32` |
| CORE-019 | core.debug | `debug_assert_eq_i32_diag` / `debug_diag_store` |
| CORE-020 | core.iterator | `SliceIter_u64` + `iterator_protocol_version` |
| STD-159 | std.runtime | `runtime_diag_enabled` / `runtime_diag_collect` |
| STD-160 | std.string | Unicode 桥接 `string_view_case_fold` 等 |
| STD-161 | std.vec | `Vec_u16` 类型族 |
| STD-162 | std.map | `MapIter_i32_i32` + 负载因子 |
| STD-163 | std.queue | `Queue_u8` |
| STD-164 | std.net | `TcpConnPool` idle 复用 |
| STD-165 | std.thread | `thread_pool_stats` |
| STD-166 | std.fmt | `format_template_1_i32` |
| STD-167 | std.db.sqlite | `sqlite_is_available` + stub 烟测 |

---

## 2. 验收

- manifest：`tests/baseline/next-yellow-clear.tsv`
- 门禁：`tests/run-next-yellow-clear-gate.sh`
- 报告：`next-yellow-clear gate OK`

---

## 3. 环境桩说明（§6 证据）

- `std.db.sqlite`：`sqlite_is_available()==0` 于 stub 构建；全量链 `-lsqlite3` 时为 1。
- `std.net` TLS：`tls_is_available()` 已有；无 OpenSSL/mbedTLS 环境仍为桩，行为文档化。
