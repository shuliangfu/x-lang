# 阶段 E-06 v1（bootstrap 禁 cc -c 编译器前端 `.c`）

> **E-06 v1**：默认 **B-strict / bootstrap-driver-seed** 路径不得 `cc -c` E-03 软退役的前端 C TU；**链接 ld/clang 除外**。`build_shux_asm` 内 `asm_driver_seed/` 考古与 `shux-c`（`OBJS_CORE`）仍 track-only（见 E-03 v3）。

## v1 完成（✅ manifest + build_shux_asm 日志审计）

| 禁止 `cc -c`（strict 段） | 替代 |
|---------------------------|------|
| `src/parser/parser.c` | `parser_x.o` |
| `src/typeck/typeck.c` | `typeck_x.o` |
| `src/codegen/codegen.c` / `autovec.c` | `codegen_x.o` |
| `src/preprocess.c` | `preprocess_x.o` |
| `src/lexer/lexer.c` | `lexer_x.o` |
| `src/ast/ast.c` | ast_pool / bridge |
| `src/lsp/lsp_diag.c` | `lsp_diag_stubs_no_c.o` |
| `pipeline_gen.c` | C-03 委托 |

## 仍允许 / track-only

| 路径 | 说明 |
|------|------|
| `runtime.c` / `main.c` | E-04 active |
| bridge / stub / `*_gen.c` | 编排与 -E 产物 |
| `asm_driver_seed/*.o` | E-03 v3 考古 |
| `shux-c` / `OBJS_CORE` | 冷启动（日志段外） |

## 复现

```bash
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
SHUX_E06_FAIL=1 SHUX_E06_BUILD_LOG=/tmp/build_bstrict.log ./tests/run-e06-no-compiler-frontend-cc-gate.sh
```

## 延后（E-06 v1）

- 见 `analysis/phase-e-e06-v2.md`（v2 experimental SEED X skip）
