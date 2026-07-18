# 阶段 C-09 完成标准 v1（NEXT §6）

> **C-09 v1**：B-strict / bootstrap **默认**链 `parser_x.o`，无静默 C `parser.o` 回退；force_stub 与 mega7 改造 **manifest 登记**闭环。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 默认 seed 链 | `DRIVER_SEED_X_FRONTEND_OBJS` 不含 C `parser.o` | 委托 `run-c06-x-frontend-default-gate.sh` |
| strict 链覆盖 | `build_shux_asm.sh` 调用 `ensure_parser_x_o_for_strict_link` | `run-c09-parser-no-c-fallback-gate.sh` |
| pipeline_x 链 | `PIPELINE_X_LINK_OBJS` 以 `parser_x.o` 为 parser TU | 同上 |
| force_stub | 6 项矩阵 + `boot-force-stub-v1.md` | manifest 审计 + portable `run-boot-force-stub-gate.sh` |
| mega7 emit | 7/7 BOOT-023 manifest + `comp-parser-mega7-matrix.tsv` | manifest 审计 + portable `run-boot-023-mega7-full-emit-gate.sh` |
| parser_x 符号 | strict 链 `parser_parse_into_*` 非 U 桩 | `run-parser-x-strict-gate.sh`（bstrict CI） |

## 盘点（track-only，不阻塞 v1 ✅）

| 路径 | 说明 |
|------|------|
| `OBJS_CORE` → `src/parser/parser.o` | `shux-c` 冷启动 seed 仍用 C parser |
| `boot-mega7-gap.md` | mega7 七函数生产仍 **C glue + ret0**（bisect delta=0） |
| `SHUX_LEGACY_C_FRONTEND=1` | 显式 opt-in 恢复 C 双轨前端 |
| `PIPELINE_X_BASE_OBJS` | 仍含 `src/parser/parser.o`（pipeline 瘦 TU 分链，由 `parser_x.o` 覆盖符号） |

## 延后（C-09 v2+）

- mega7 **7/7 真 X emit**（BOOT-023 `promote_emit` 全绿且运行时无 C glue）
- 删 `OBJS_CORE` / 冷启动路径中的 C `parser.o`
- force_stub 六项逐步去 `force_stub` / 改真 emit
