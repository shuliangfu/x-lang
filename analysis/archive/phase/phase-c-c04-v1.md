# 阶段 C-04 完成标准 v1（NEXT §6）· NO_C_FRONTEND honesty

> **Status (2026-08-27):** soft `XLANG_{PIPELINE,LEXER,PARSER,E_EXTERN_IMPORT}_*_FAIL`
> and soft c04 SKIP-when-NO_C exit0 retired. Product binaries are built with
> `-DXLANG_NO_C_FRONTEND`; `-E-extern` is refused with BLD001. Old soft gates
> + `-E-extern`+`cc -c` batches while every product bin refuses the flag =
> portable false-green / prefer-c archaeology dual authority.

> **C-04 v1（历史）**：`-E-extern` 生成 C **自带 extern**；seed 链 **parser /
> lsp_diag / pipeline / lsp_io / lsp** 零 perl 后处理；不再依赖
> `lsp_io_extern.h` / `lsp_gen_extern.h` 编译生成 TU。

## Honesty contract (product prefer-asm)

| Check | Hard? | Notes |
|-------|-------|-------|
| Archive DOC + `## Gate` | yes | this file |
| `./xbuild` present; no `compiler/Makefile` | yes | MG |
| Prefer-asm native binary | yes | `xlang_asm` first |
| Product refuses `-E-extern` with BLD001 / NO_C_FRONTEND | yes | probe per child + aggregate `lsp_io.x` |
| Sub-gates (import／lexer／pipeline／parser／no-perl) | yes | refuse honesty + no-perl audit |
| Full `-E-extern`+`cc -c` batch | **retired** | cannot green on product pure-asm |

## Historical v1 surface (archive)

| 项 | 标准（历史） | Gate（现 honesty） |
|----|--------------|-------------------|
| import extern | `lsp_io.x` / `lsp.x` 自动 extern + inline wrapper | `run-e-extern-import-gate.sh` |
| pipeline | `pipeline.x -E-extern` 纯 codegen + `cc -c` | `run-pipeline-e-extern-gate.sh` |
| parser / lsp_diag | 生成 **无 perl**；须 C-04 marker | `run-c04-no-perl-fallback-gate.sh` |
| lexer | `-E-extern` 烟测 | `run-lexer-e-extern-gate.sh` |
| parser TU | TU aliases + pool + `cc -c` | `run-parser-e-extern-gate.sh` |
| 聚合 | 子 gate + manifest | `run-c04-e-extern-gate.sh` |

## track-only（不阻塞 v1 ✅）

| 模块 | 说明 |
|------|------|
| **lexer_gen.c** | 仍 `perl fix_slim_arena_gen_c.pl`（v2：codegen 原生 slim arena） |
| **typeck_gen.c / codegen_gen.c / ast_gen2.c** | 同上 |
| **lsp_io_gen.c** | xlang-x 失败时回退 xlang-c `-E-extern`（C frontend bin only） |
| **lsp_codegen_extern.c** | C codegen 路径仍内嵌 extern 块（E-01 删 .h 时一并收） |

## Gate

```bash
./tests/run-c04-e-extern-gate.sh
# Children (also runnable alone):
#   ./tests/run-e-extern-import-gate.sh
#   ./tests/run-lexer-e-extern-gate.sh
#   ./tests/run-pipeline-e-extern-gate.sh
#   ./tests/run-parser-e-extern-gate.sh
#   ./tests/run-c04-no-perl-fallback-gate.sh
# Report: refuse=/subs=/noperl=/skip= (aggregate); refuse=/skip= (children)
# Soft XLANG_*_E_EXTERN*_FAIL + soft SKIP-when-NO_C retired (die always hard).
# Authority refuse: tests/lib/prefer-asm-e-extern-refuse.sh
```

PLATFORM: SHARED archaeology.
