/**
 * pipeline_glue_emit_lea_fwd.c — Early emit inter-include forward-decl / define
 * shell after the lea_common domain (BC 8.3 shell thin).
 *
 * wave1288 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure #defines, forward declarations, and static prototypes that must be
 * visible after pipeline_asm_emit_lea_common.c and before
 * pipeline_asm_emit_return.c (covering the return / unary / as / async_cps /
 * logand / STRUCT_LIT emit chain).
 *
 * Consolidates the two former inline inter-include gaps:
 *  - gap A (lea → return): freestanding ARRAY_LIT element/payload caps +
 *    array_lit scalar/durable prototypes + async CPS phase-reset prototype +
 *    module func return-type accessor extern
 *  - gap B (return → unary, hoisted here): binop scalar f32/f64 classifiers,
 *    type-ref scalar classifiers, var-decl type-ref, and binop mul helper
 *    prototypes. Their sole consumers (unary.c EXPR_NEG, assign.c, binop.c)
 *    are all #included after return.c, so hoisting these decls before
 *    return.c keeps them ahead of every use; return.c carries its own
 *    internal fwd decl for glue_var_decl_type_ref_elf_c (no dependency here).
 *
 * Include site: pipeline_glue.c immediately after pipeline_asm_emit_lea_common.c
 * and before the return domain #include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations + #defines only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/**
 * wave413 Cap residual pure: freestanding ARRAY_LIT element cap 256→512.
 * wave415 Cap residual pure: raise durable byte payload + elem face again.
 * Root (wave415): n_arr<=512 and nbytes<=2048 still CG002 for i32[n] n>512
 * (host-C green; durable text-embed / COMMON / escape shared the 2048B hard cap).
 * G.7: single pair of #defines for freestanding ARRAY_LIT / fixed-array face.
 *   MAX_ELEMS=1024 · MAX_PAYLOAD=4096 -> u8[1024] / i32[1024] / i64[512].
 * Host deep-copy __xlang_sdN[512] (wave412) stays reentrancy soft, not this face.
 * PLATFORM: SHARED freestanding.
 */
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#define GLUE_ARRAY_LIT_MAX_PAYLOAD 4096

/* wave138 pure-owned leave: ARRAY_LIT scalar elem lives in runtime_pipeline_abi pure
 * (was static same-TU in pipeline_asm_emit_as.c). PLATFORM: SHARED freestanding emit. */
extern int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t array_lit_ref, int32_t elem_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t force_esz);

/* wave335 durable ARRAY_LIT -> rax; wave1021 body -> array_lit; wave143 pure leave. */
extern int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t expr_ref, int32_t force_esz, int32_t ta,
                                                            struct backend_AsmFuncCtx *ctx);

/* wave131 pure-owned leave: phase_reset lives in runtime_pipeline_abi pure
 * (was static same-TU in pipeline_asm_emit_async_cps.c). Visible before
 * return.c / as.c #includes. PLATFORM: SHARED freestanding emit. */
extern int32_t glue_async_cps_emit_phase_reset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave1130-1131 G.7: glue_maybe_promote_f32_to_f64_rax_elf_c /
 * glue_float_promote_src_ty_ref_c fwd decls removed — definitions now at
 * pipeline_asm_emit_return.c EOF (#include below provides same-TU
 * visibility to all subsequent callsites incl. assign/block_inits/block_body). */
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);

/* Forward decls (gap B, hoisted before return.c): used by EXPR_NEG / assign
 * before f32/f64 classifiers and mul helper. All consumers are #included
 * after the return domain.
 * wave133 Cap residual: pure unary leave links f32/f64 classifiers — non-static. */
int32_t glue_binop_operand_is_scalar_f32_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t expr_ref);
int32_t glue_binop_operand_is_scalar_f64_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t expr_ref);
static int32_t glue_type_ref_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t type_ref);
static int32_t glue_type_ref_is_scalar_f64_c(struct ast_ASTArena *arena, int32_t type_ref);
/* wave124 pure-owned leave: live in runtime_pipeline_abi pure (was same-TU static). */
extern int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t var_expr_ref);
int32_t glue_emit_binop_mul_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
