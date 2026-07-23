# 阶段 E-03 v2（lexer.c / ast_seed 软退役）

> **E-03 v2 lexer/ast**：默认 bootstrap **不链** `src/lexer/lexer.o` / `src/ast/ast_seed.o`；X 前端用 `lexer_x.o` + `lexer_x_link_alias.o` 与 ast_pool / x_seed_bridge。文件保留。

## v2 lexer/ast 完成（✅）

| 项 | 标准 | 产物 |
|----|------|------|
| Makefile | `LEXER_LINK_O` / `AST_LINK_O` 默认空 | `compiler/Makefile` |
| 考古开关 | `XLANG_LEGACY_SEED_LEXER_AST=1` 或 `XLANG_LEGACY_C_FRONTEND=1` | Makefile |
| 文件头 | Phase E soft-retired 标记 | `lexer.c` / `ast.c` |
| Gate | manifest + Makefile 审计 | `tests/run-e03-lexer-ast-soft-gate.sh` |

## 复现

```bash
XLANG_E03_LEXER_AST_FAIL=1 ./tests/run-e03-lexer-ast-soft-gate.sh
make -C compiler bootstrap-driver-seed   # 默认不链 lexer.o / ast_seed.o
XLANG_LEGACY_SEED_LEXER_AST=1 make -C compiler bootstrap-driver-seed  # 考古 C 路径
```

## 延后（E-03 v3+）

- `OBJS_CORE`（xlang-c）改默认 X lexer/ast
- `build_xlang_asm` strict 路径去 `SEED_O/lexer.o` / `ast_seed.o`
