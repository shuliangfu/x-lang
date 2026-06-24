# 阶段 C-06 完成标准 v1（NEXT §6）

> **目标**：`bootstrap-driver-seed` / `relink-shux` / `shux-sx` **默认**只链 `-E-extern` 产出的 `*_sx.o`，不链 C `parser.o` / `typeck.o` / `codegen.o`。

## v1 完成（✅）

| 项 | 标准 |
|----|------|
| Makefile 变量 | `DRIVER_SEED_SX_FRONTEND_OBJS` + 条件 `DRIVER_SEED_RUNTIME_O` |
| 默认 runtime | `runtime_driver_no_c.o`（`-DSHUX_NO_C_FRONTEND`） |
| 默认 support | `codegen_pipeline_stubs.o` + `typeck_f64_bits.o` |
| 别名 | `typeck_sx.o` / `lexer_sx.o` / `ast_sx.o` ← `*_sx.o` / `ast_seed.o` |
| 回退 | `SHUX_LEGACY_C_FRONTEND=1 make bootstrap-driver-seed` 恢复 C 双轨 |
| Gate | `run-c06-sx-frontend-default-gate.sh` |

## 延后

- **OBJS_CORE**（`make all` → `shux-c`）仍链 C 前端 — 冷启动 seed 编译器；阶段 E 删除。
- **build_asm/*.o** 仍由 `.sx` asm 后端产出；与 seed 链 orthogonal。
