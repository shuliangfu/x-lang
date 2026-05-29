/**
 * pipeline 调用 codegen_codegen_su_ast*；codegen_gen.c 导出 codegen_su_ast*。
 * 链接期别名，避免重编 pipeline_su.o。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

extern int32_t codegen_su_ast_emit_header(struct codegen_CodegenOutBuf *out);
extern int32_t codegen_su_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                              struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx,
                              int32_t dep_index);

int32_t codegen_codegen_su_ast_emit_header(struct codegen_CodegenOutBuf *out) {
  return codegen_su_ast_emit_header(out);
}

int32_t codegen_codegen_su_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                               struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx,
                               int32_t dep_index) {
  return codegen_su_ast(module, arena, out, ctx, dep_index);
}
