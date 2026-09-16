# 阶段 E-03 v2（lexer.c / ast_seed 软退役 → hard-retired）

> **E-03 v2 lexer/ast**：默认 bootstrap **不链** `src/lexer/lexer.o` / `src/ast/ast_seed.o`；X 前端用 `lexer_x.o` + `lexer_x_link_alias.o` 与 ast_pool / x_seed_bridge。`lexer.c` / `ast.c` 已 G-02a **物理删除**（hard-retired）。

## Gate

Honesty gate (2026-08-26): archive DOC + `compiler/mk/driver_seed_link_picks.mk`
empty default `LEXER_LINK_O` / `AST_LINK_O` + absent `lexer.c` / `ast.c` + live
`lexer.x` / `ast.x`. No soft `die→exit 0`. Soft `XLANG_E03_LEXER_AST_FAIL`
retired. Report `static=` / `mk=` / `absent=` / `skip=`.

```bash
./tests/run-e03-lexer-ast-soft-gate.sh
```

## v2 lexer/ast 完成（✅）

| 项 | 标准 | 产物 |
|----|------|------|
| mk picks | `LEXER_LINK_O` / `AST_LINK_O` 默认空 | `compiler/mk/driver_seed_link_picks.mk` |
| 考古开关 | `XLANG_LEGACY_SEED_LEXER_AST=1` 或 `XLANG_LEGACY_C_FRONTEND=1` | mk picks |
| C 源 | hard-retired（`not_exists`） | `lexer.c` / `ast.c` 已删 |
| X 活面 | `lexer.x` / `ast.x` | `compiler/src/lexer/` / `ast/` |
| Gate | archive DOC + mk 审计 | `tests/run-e03-lexer-ast-soft-gate.sh` |

## 复现

Same as **## Gate** (soft `XLANG_E03_LEXER_AST_FAIL` path retired; gate always hard):

```bash
./tests/run-e03-lexer-ast-soft-gate.sh
./xbuild bootstrap-driver-seed   # 默认不链 lexer.o / ast_seed.o
```

## 延后（E-03 v3+）

- `OBJS_CORE`（xlang-c）改默认 X lexer/ast
- `build_xlang_asm` strict 路径去 `SEED_O/lexer.o` / `ast_seed.o`
