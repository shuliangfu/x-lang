/* seeds/backend_asm_bare_link_alias.from_x.c — G-02f-17 product TU
 * Logic still C until full .x port.
 */
/**
 * backend_asm_bare_link_alias.c — backend_wpo.o 裸符号 → glue / bridge 的 backend_ 前缀名
 *
 * strict WPO 链：mega/emit helper 仍由 seed partial 导出 backend_*；本 TU 仅转发 wpo 薄入口。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

extern int32_t asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                               struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx);

/** backend_wpo.o asm_codegen_ast → glue backend_asm_codegen_ast。 */
int32_t backend_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx) {
  return asm_codegen_ast(module, arena, out, ctx);
}

extern int32_t asm_codegen_ast_to_elf(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      struct ast_PipelineDepCtx *ctx);

/** backend_wpo.o asm_codegen_ast_to_elf → glue backend_asm_codegen_ast_to_elf。 */
int32_t backend_asm_codegen_ast_to_elf(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       struct ast_PipelineDepCtx *ctx) {
  return asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
}

extern int32_t emit_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                             int32_t expr_ref, struct ast_PipelineDepCtx *ctx, int32_t ta);

/** backend_wpo.o emit_expr_elf → compat backend_emit_expr_elf。 */
int32_t backend_emit_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                              int32_t expr_ref, struct ast_PipelineDepCtx *ctx, int32_t ta) {
  return emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
}

extern int32_t emit_block_body_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                   int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/** backend_wpo.o emit_block_body_elf → seed/backend_emit_block_body_elf 同名薄入口替代。 */
int32_t backend_emit_block_body_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                    int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return emit_block_body_elf(arena, elf_ctx, block_ref, ctx, ta);
}
