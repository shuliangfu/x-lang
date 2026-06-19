# COMP-009 前端/后端接口契约 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `pipeline.sx`、`pipeline_glue.c`、`doc-selfhost-architecture-v1.md` 对齐  
> 关联：`COMP-008`（link 归因）、`DOC-002`（自举全景）、`compiler/docs/整项目影响与依赖分析.md`

---

## 1. 阅读路径（约 20 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 契约层 B1–B6 |
| 2 | 打开 `tests/baseline/comp-feb-contract-boundary.tsv` |
| 3 | `./tests/run-comp-feb-contract-gate.sh` |
| 4 | 对照 `compiler/pipeline_glue.c` 文件头 glue 表 |

---

## 2. 契约层 B1–B6（frontend / backend boundary）

权威：`tests/baseline/comp-feb-contract.tsv`（**6** 条 `layer_*`）。

| 层级 | 边界 | 上游 → 下游 | 载荷（data contract） | 锚点符号 |
|------|------|-------------|----------------------|----------|
| **B1-parser-ast** | 词法/语法 → AST | lexer/parser → `ast` | `Module` + `ASTArena` + `ParseIntoResult` | `parse_into_buf` |
| **B2-typeck-ast** | 类型检查 | parser → typeck | 已填充 `Module`；跨模块 `PipelineDepCtx` | `typeck_su_ast` |
| **B3-codegen-out** | IR/文本发射 | typeck → codegen | `CodegenOutBuf`（C/asm 文本或 .o 路径） | `codegen_sx_ast` |
| **B4-asm-backend** | 机器码后端 | codegen/asm 编排 → backend | `Module` + `CodegenOutBuf` + `PipelineDepCtx` | `asm_codegen_ast` |
| **B5-pipeline** | 流水线编排 | driver → 各阶段 | `source_data`/`source_len` → `out_buf` | `run_sx_pipeline_impl` |
| **B6-glue-c** | C ↔ .sx 桥接 | runtime/glue → .sx frontend | `ptr+len` → `[]u8` slice；weak 符号覆盖 | `parser_slice_from_buf` |

**contract 原则**：

1. **单一所有权**：`ASTArena` 由 driver 分配；各阶段只读/追加 arena 槽，不 `free` 跨模块指针。
2. **显式上下文**：多文件编译时 `PipelineDepCtx` 携带 `ndep`、import 路径、lib_root；typeck/codegen 不得隐式全局。
3. **后端可替换**：同一 `Module` 可走 `codegen_sx_ast`（C 文本）或 `asm_codegen_ast`（asm）；driver 按 `-backend` 分支。
4. **glue 薄层**：`pipeline_glue.c` 仅承载语言子集暂缺 ABI（slice 构造、metrics、weak 转发），业务逻辑留在 `.sx`。

---

## 3. 边界矩阵（boundary report）

`tests/baseline/comp-feb-contract-boundary.tsv`（**8** 条 `bd_*`）。

| boundary_id | upstream | downstream | symbol | payload |
|-------------|----------|------------|--------|---------|
| `bd_parse_module` | parser | ast | `parse_into_buf` | Module, ASTArena, ParseIntoResult |
| `bd_parse_slice` | pipeline_glue | parser | `parser_slice_from_buf` | ptr+len → []u8 |
| `bd_typeck_entry` | pipeline | typeck | `typeck_su_ast` | Module, ASTArena, PipelineDepCtx |
| `bd_typeck_layout` | typeck | typeck | `typeck_merge_dep_struct_layouts_into_entry` | Module, ASTArena |
| `bd_codegen_emit` | pipeline | codegen | `codegen_sx_ast` | CodegenOutBuf, dep_index |
| `bd_asm_emit` | asm | backend | `asm_codegen_ast` | CodegenOutBuf, elf_ctx |
| `bd_pipeline_orchestrate` | driver | pipeline | `run_sx_pipeline_impl` | 全阶段串联 |
| `bd_dep_ctx` | ast_pool | pipeline | `pipeline_dep_ctx_set_module` | PipelineDepCtx, Module |

---

## 4. 核心数据结构（data contract）

| 类型 | 定义位置 | 消费方 |
|------|----------|--------|
| `Module` | `compiler/src/ast/ast.sx` | parser, typeck, codegen, asm |
| `ASTArena` | `compiler/src/ast/ast.sx` | 全前端 |
| `PipelineDepCtx` | `compiler/src/ast/ast.sx` | pipeline, typeck, codegen |
| `CodegenOutBuf` | `compiler/src/codegen/codegen.sx` | codegen, asm, peephole |
| `ParseIntoResult` | `compiler/src/parser/parser.sx` | parser, pipeline |

---

## 5. Golden 源码锚点

| case_id | 文件 | 验证 |
|---------|------|------|
| `case_pipeline` | `compiler/src/pipeline/pipeline.sx` | `run_sx_pipeline_impl` 存在 |
| `case_parser` | `compiler/src/parser/parser.sx` | `parse_into_buf` 签名 |
| `case_typeck` | `compiler/src/typeck/typeck.sx` | `typeck_su_ast` |
| `case_codegen` | `compiler/src/codegen/codegen.sx` | `codegen_sx_ast` |
| `case_asm` | `compiler/src/asm/backend.sx` | `asm_codegen_ast` |
| `case_glue` | `compiler/pipeline_glue.c` | glue 表 + slice 桥 |

---

## 6. 非目标（v1）

- LSP 协议字段级契约
- std 库模块 ABI 全表
- riscv64 / Windows COFF 专用 backend 契约

---

## 7. 验证与门禁

```bash
./tests/run-comp-feb-contract-gate.sh   # runnable：manifest + boundary symbol 完整性
./tests/run-comp-feb-contract.sh        # 边界符号烟测
./tests/run-s3-pipeline-gate.sh         # pipeline.o EMIT_HEAVY 契约回归
```

**gate report**：stdout 须含 `comp-feb-contract gate OK`；失败打印 `comp-feb-contract FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-feb-contract-v1.md` |
| manifest | `tests/baseline/comp-feb-contract.tsv` |
| boundary | `tests/baseline/comp-feb-contract-boundary.tsv` |

**COMP-009 状态：定版 ✅**
