/**
 * pipeline_glue_emit_mid_fwd.c — Mid-emit inter-include forward-decl / ordinal
 * shell (BC 8.3 shell thin).
 *
 * wave1289 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c: consolidates
 * the scattered inter-include forward declarations and TypeKind/ExprKind
 * ordinal #defines that previously sat between the mid-emit domain #includes
 * (struct_lit .. call_args) into one pure-decl shell. No function bodies.
 *
 * Hoisted clusters (all moved to one site right after pipeline_glue_emit_fwd;
 * every consumer — struct_let / index_helpers / spill / modlet / assign /
 * array_lit / index / match / var_decl / index_eff_addr / call_args / binop /
 * field_access — is #included after this site, so hoisting earlier preserves
 * same-TU visibility; duplicated decls like glue_var_decl_type_ref_elf_c and
 * glue_type_size_simple are left at their original sites, untouched):
 *  - TypeKind/ExprKind ordinal #defines (GLUE_TYPE_KIND_ARRAY/SLICE/F32_ORD/
 *    F64_ORD, GLUE_EXPR_KIND_VAR) + pipeline_type_array_size_at extern
 *  - public CALL / METHOD_CALL / PANIC emit entry forward decls
 *  - binop / field_access operand loader prototypes (lit_i32, var_field_access,
 *    field_access_fast, expr_elf_fast)
 *
 * Include site: pipeline_glue.c immediately after pipeline_glue_emit_fwd.c
 * and before the struct_lit domain #include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations + #defines only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/** TYPE_ARRAY / TYPE_SLICE ordinals in the TypeKind table
 * (match ast.x / pipeline_type_kind_ord_at). */
#define GLUE_TYPE_KIND_ARRAY 10
#define GLUE_TYPE_KIND_SLICE 11
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref);
/** TYPE_F32 ordinal in the TypeKind table (match pipeline_asm_index_elem_byte_sz_c). */
#define GLUE_TYPE_KIND_F32_ORD 14
/** TYPE_F64 (ast TypeKind with LINEAR; SysV SSE float class, same as TYPE_F32). */
#define GLUE_TYPE_KIND_F64_ORD 15

/** EXPR_VAR kind ordinal (match ast_ExprKind). */
#define GLUE_EXPR_KIND_VAR 3

/* Public CALL / METHOD_CALL / PANIC emit entry forward decls.
 * CALL/METHOD: call_args residual. PANIC: wave127 pure-owned leave
 * (runtime_pipeline_abi); do not re-define in host-cc mega (G.7). */
int32_t pipeline_asm_emit_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_method_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_panic_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* Forward: binop operand loader paths (bodies in field_access / expr_rec leaves). */
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm);
static int32_t pipeline_asm_emit_var_field_access_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta);
/* Forward: FIELD_ACCESS for binop operand (body in field_access leaf). */
/* wave149 Cap residual non-static (def field_access.c). */
int32_t pipeline_asm_emit_field_access_elf_fast_c(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                           int32_t ta);
int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
