/* Standalone translation unit for seeds/codegen_cap_residual.from_x.c.
 *
 * assemble_codegen_gen_from_x.py pastes that seed onto the end of
 * codegen_gen.c, so the host-cc codegen_x.o is the only object that
 * defines the cap-residual product faces. A pure-asm compile of
 * codegen.x keeps those calls as undefined externs and does not emit
 * the scratch-buffer or bounded-loop helpers. This file is not a second
 * implementation: the bodies stay in the seed. The declarations below
 * are the ones the paste inherited from the surrounding gen file.
 *
 * ast_ASTArena.num_types is the first field, matching codegen_gen.c.
 * The seed reads only that field. The other structs are incomplete
 * because the seed only passes pointers through.
 *
 * PLATFORM: SHARED — same seed the Linux, Darwin, and Windows host-cc
 * codegen objects already contain. The g05 hook that links this object
 * is Linux-only until those other hosts leave host-cc codegen_gen.c.
 */
#include <stddef.h>
#include <stdint.h>

struct ast_ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};
struct codegen_CodegenOutBuf;
struct ast_PipelineDepCtx;
struct ast_Module;

extern int ast_ref_is_null(int32_t ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref);
extern int32_t codegen_append_byte(struct codegen_CodegenOutBuf *out, int32_t b);
extern int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf *out, uint8_t *buf, int32_t len);
extern int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf *out, uint8_t *ptr, int32_t len);
extern int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf *out, uint8_t *ptr, int32_t len);
extern int32_t codegen_emit_expr(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                 int32_t expr_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_emit_indent(struct codegen_CodegenOutBuf *out, int32_t indent);
extern int32_t codegen_emit_type(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                 int32_t type_ref, uint8_t *struct_prefix, int32_t struct_prefix_len,
                                 struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_format_int(struct codegen_CodegenOutBuf *out, int64_t val);

#include "codegen_cap_residual.from_x.c"
