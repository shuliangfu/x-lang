/**
 * backend_asm_strict_fallback_alias.c — 非 backend_wpo strict 链的 backend_* 强桥接
 *
 * 当 strict 链拿不到 backend_wpo.o 时，seed partial 里只剩 weak backend_* 入口桩，
 * user_asm_seed_bridge 调用这些符号会直接 return -1，导致 asm -o 在 ELF emit 入口即失败。
 * 此 TU 仅在 fallback 场景下注入强符号，把 backend_* 入口接回 pipeline glue 的 C 实现。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;
struct platform_elf_ElfCodegenCtx;

extern int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  struct codegen_CodegenOutBuf *out,
                                                  struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct ast_PipelineDepCtx *ctx);

int32_t backend_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx) {
  return pipeline_backend_asm_codegen_ast_c(module, arena, out, ctx);
}

int32_t backend_asm_codegen_ast_to_elf(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       struct ast_PipelineDepCtx *ctx) {
  return pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, ctx);
}
