# NEXT-YELLOW 全量 🟡 清除 v1

> 更新时间：2026-06-18 · honesty 2026-08-28  
> 状态：**定版（v1）+ Gate honesty**  
> 关联：历史 `NEXT.md` 功能表 🟡 项（**已退役**；live = `analysis/自举进度.md`）

---

## 1. 交付一览

| ID | 模块 | 交付（live 符号） |
|----|------|------|
| CORE-018 | core.builtin | `bswap_u32` / `rotl_u32` / `rotr_u32` |
| CORE-019 | core.debug | `debug_assert_eq_i32_diag` / `debug_diag_store` |
| CORE-020 | core.iterator | `iter_u64_from_buf` + `SliceIter_u64` |
| STD-159 | std.runtime | `diag_enabled` / `diag_collect` |
| STD-160 | std.string | Unicode 桥接 `string_view_case_fold` 等 |
| STD-161 | std.vec | `Vec_u16` + `push` |
| STD-162 | std.map | `iter_next` + 负载因子 |
| STD-163 | std.queue | `Queue_u8` + `push_back` |
| STD-164 | std.net | `tcp_pool_new` idle 复用 |
| STD-165 | std.thread | `stats`（`ThreadPoolStats`） |
| STD-166 | std.fmt | `format_template` |
| STD-167 | std.db.sqlite | `is_available` + stub 烟测 |

---

## 2. 验收

- manifest：`tests/baseline/next-yellow-clear.tsv`
- 门禁：`tests/run-next-yellow-clear-gate.sh`
- 报告：`next-yellow-clear gate OK` + `run=` / `obs=` / `skip=`

---

## 3. 环境桩说明（§6 证据）

- `std.db.sqlite`：`is_available()==0` 于 stub 构建；全量链 `-lsqlite3` 时为 1。
- `std.net` TLS：stub 烟测可因 TLS UNDEF 落 obs（产品残）；无 OpenSSL/mbedTLS 环境仍为桩。

## Gate

Honesty gate for NEXT-YELLOW (`tests/run-next-yellow-clear-gate.sh`):

- Prefer product `xlang_asm`; pin `XLANG_LINK_XLANG`. Explicit bad XLANG /
  missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
- Manifest symbols + smokes + archive DOC = hard.
- Refuse `NEXT.md` and top-level `analysis/next-yellow-clear-v1.md` resurrect.
- CORE-018 delegates to `run-core-builtin-bitops-gate.sh` (hard).
- Product `-o` hard green: vec / map / net / fmt / iterator / thread /
  runtime_diag / unicode smokes.
- Tip residuals = `obs=`: queue run exit≠0; sqlite stub TLS UNDEF; debug
  diag ld; check path (paused 2026-08-05 / CHK002).
- Report `run=` / `obs=` / `skip=`. PLATFORM: SHARED.
- Live DOC = this archive file.
