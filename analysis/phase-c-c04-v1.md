# 阶段 C-04 完成标准 v1（NEXT §6）

> **C-04 v1**：`-E-extern` 生成 C **自带 extern**；seed 链 **parser / lsp_diag / pipeline / lsp_io / lsp** 零 perl 后处理；不再依赖 `lsp_io_extern.h` / `lsp_gen_extern.h` 编译生成 TU。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| import extern | `lsp_io.sx` / `lsp.sx` 自动 extern + inline wrapper | `run-e-extern-import-gate.sh` |
| pipeline | `pipeline.sx -E-extern` 纯 codegen + `cc -c` | `run-pipeline-e-extern-gate.sh` |
| parser / lsp_diag | Makefile 生成 **无 perl**；须 C-04 marker | `run-c04-no-perl-fallback-gate.sh` |
| lexer | `-E-extern` 烟测 | `run-lexer-e-extern-gate.sh` |
| parser TU | `run-parser-e-extern-gate.sh` | 同上 |
| 聚合 | 子 gate + manifest | `run-c04-e-extern-gate.sh` |

## track-only（不阻塞 v1 ✅）

| 模块 | 说明 |
|------|------|
| **lexer_gen.c** | 仍 `perl fix_slim_arena_gen_c.pl`（v2：codegen 原生 slim arena） |
| **typeck_gen.c / codegen_gen.c / ast_gen2.c** | 同上 |
| **lsp_io_gen.c** | shux-sx 失败时回退 shux-c `-E-extern` |
| **lsp_codegen_extern.c** | C codegen 路径仍内嵌 extern 块（E-01 删 .h 时一并收） |

## 复现

```bash
SHUX_C04_FAIL=1 ./tests/run-c04-e-extern-gate.sh
```

## 延后（C-04 v2）

- 全前端 `*_gen.c` 去 `fix_slim_arena` perl
- 删除 `lsp_io_extern.h` / `lsp_gen_extern.h` 文件（E-01）
