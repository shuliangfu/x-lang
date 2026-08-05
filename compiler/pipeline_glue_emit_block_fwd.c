/**
 * pipeline_glue_emit_block_fwd.c — Block-accessor + block-if emit pure-fwd shell
 * after cmp domain (BC 8.3 shell thin).
 *
 * wave1287 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations that must be visible after
 * pipeline_asm_emit_cmp.c and before pipeline_asm_emit_next_offset.c /
 * block_inits / block_body / block_if_stmt domains.
 *
 * Sub-clusters (order preserved):
 *  - ast_pipeline_block_if_* accessors
 *  - ast_ast_block_num_* / stmt_order / loops / for / if / regions / expr_stmts
 *  - ast_ast_block_while_* / for_* / if_* body accessors
 *  - ast_pipeline_block_{const,let}_* name/init accessors
 *  - pipeline_block_let_* / pipeline_expr_* / array_lit_num_elems faces
 *  - pipeline_asm_emit_block_if_stmt_elf public pure face (wave129 leave)
 *  - pipeline_asm_emit_if_then_block_body_elf_c public pure face (wave129 leave)
 *
 * Definitions: block_if live in runtime_pipeline_abi pure (wave129 leave);
 * other accessors live in ast_pool_block / residual domain leaves. No function bodies here.
 *
 * Include site: pipeline_glue.c immediately after pipeline_asm_emit_cmp.c
 * and before next_offset migration notes + #include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
/** WPO-S3 typeck_block_tree_has_var_c 等于 10313 块；定义见 ast_ast_block_if_else_body_ref。 */
int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);

/* wave129 pure-owned leave: block-level if ELF faces (was same-TU host-cc leaf).
 * Residual block_body_sync if arm + backend.x thin path call these pure symbols.
 * PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_emit_block_if_stmt_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t cur_block, int32_t if_idx, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta, int32_t stmt_i);
extern int32_t pipeline_asm_emit_if_then_block_body_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t then_block_ref, struct backend_AsmFuncCtx *ctx,
                                                         int32_t ta);

/* wave145 pure leave: slice_from_array + block_inits faces (was same-TU static in
 * pipeline_asm_emit_block_inits.c). Residual block_body calls these pure symbols.
 * PLATFORM: SHARED freestanding emit. */
extern int32_t glue_emit_slice_from_array_let_init_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t block_ref, int32_t let_idx, int32_t init_ref,
                                                         int32_t let_type_ref, struct backend_AsmFuncCtx *ctx,
                                                         int32_t ta, int32_t slice_slot_off);
extern int32_t pipeline_asm_emit_block_inits_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                   int32_t slot_base);
extern void pipeline_asm_fill_block_locals_tree(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                               int32_t block_ref);
