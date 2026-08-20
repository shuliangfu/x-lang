/* seeds/typeck_mangle_link_alias.from_x.c — wave317 typeck M4 layer-2
 * X-mangle call sites from tip typeck.x -E → short product C faces.
 * G.7: alias-only (zero business logic); short faces on typeck_x / pipeline_abi.
 * Any #[no_mangle] Cap face that typeck.x also forward-declares as
 * `export extern` (call sites emit the mangled name; body stays short)
 * MUST have a thin alias here. Seed typeck_gen snapshot is not the assemble
 * authority — missing rows here UNDEF on the next typeck.x -E.
 * PLATFORM: SHARED freestanding typeck tip re-pin companion (ld -r or append).
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t glue_generic_call_fixup_resolved_type_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t expected_ret);
int32_t glue_generic_call_fixup_resolved_type_c_Module_ptr_ASTArena_ptr_i32_PipelineDepCtx_ptr_i32_reti32(struct ast_Module * module, struct ast_ASTArena * arena, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t expected_ret) { return glue_generic_call_fixup_resolved_type_c(module, arena, call_expr_ref, ctx, expected_ret); }

extern int32_t pipeline_dep_ctx_typeck_unsafe_depth_at(struct ast_PipelineDepCtx * ctx);
int32_t pipeline_dep_ctx_typeck_unsafe_depth_at_PipelineDepCtx_ptr_reti32(struct ast_PipelineDepCtx * ctx) { return pipeline_dep_ctx_typeck_unsafe_depth_at(ctx); }

extern int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_type_stamp_block_let_region_c_ASTArena_ptr_i32_i32_PipelineDepCtx_ptr_reti32(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx, struct ast_PipelineDepCtx * ctx) { return pipeline_type_stamp_block_let_region_c(arena, block_ref, let_idx, ctx); }

extern int32_t pipeline_typeck_block_impl_bind_ctx_c(struct ast_PipelineDepCtx * ctx, int32_t block_ref);
int32_t pipeline_typeck_block_impl_bind_ctx_c_PipelineDepCtx_ptr_i32_reti32(struct ast_PipelineDepCtx * ctx, int32_t block_ref) { return pipeline_typeck_block_impl_bind_ctx_c(ctx, block_ref); }

extern void pipeline_typeck_block_impl_restore_ctx_c(struct ast_PipelineDepCtx * ctx, int32_t saved_block_ref);
void pipeline_typeck_block_impl_restore_ctx_c_PipelineDepCtx_ptr_i32(struct ast_PipelineDepCtx * ctx, int32_t saved_block_ref) { pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref); }

extern void pipeline_typeck_block_impl_touch_ctx_block_c(struct ast_PipelineDepCtx * ctx, int32_t block_ref);
void pipeline_typeck_block_impl_touch_ctx_block_c_PipelineDepCtx_ptr_i32(struct ast_PipelineDepCtx * ctx, int32_t block_ref) { pipeline_typeck_block_impl_touch_ctx_block_c(ctx, block_ref); }

extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t region_idx, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_check_block_one_region_c_Module_ptr_ASTArena_ptr_i32_i32_i32_PipelineDepCtx_ptr_reti32(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t region_idx, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_check_block_one_region_c(module, arena, block_ref, region_idx, return_type_ref, ctx); }

extern int32_t pipeline_typeck_check_call_generic_type_args_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx, int32_t expected_ret);
int32_t pipeline_typeck_check_call_generic_type_args_c_Module_ptr_ASTArena_ptr_i32_PipelineDepCtx_ptr_i32_reti32(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx, int32_t expected_ret) { return pipeline_typeck_check_call_generic_type_args_c(module, arena, expr_ref, ctx, expected_ret); }

extern int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_check_call_struct_stack_escape_c_Module_ptr_ASTArena_ptr_i32_PipelineDepCtx_ptr_reti32(struct ast_Module * module, struct ast_ASTArena * arena, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_check_call_struct_stack_escape_c(module, arena, call_expr_ref, ctx); }

extern int32_t pipeline_typeck_check_return_slice_region_in_scope_c(struct ast_ASTArena * arena, int32_t site_expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_check_return_slice_region_in_scope_c_ASTArena_ptr_i32_i32_PipelineDepCtx_ptr_reti32(struct ast_ASTArena * arena, int32_t site_expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_check_return_slice_region_in_scope_c(arena, site_expr_ref, return_type_ref, ctx); }

extern int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t * name, int32_t name_len);
int32_t pipeline_typeck_is_read_ptr_slice_callee_c_u8_ptr_i32_reti32(uint8_t * name, int32_t name_len) { return pipeline_typeck_is_read_ptr_slice_callee_c(name, name_len); }

extern int32_t pipeline_typeck_is_simd_comptime_callee_c(uint8_t * name, int32_t name_len);
int32_t pipeline_typeck_is_simd_comptime_callee_c_u8_ptr_i32_reti32(uint8_t * name, int32_t name_len) { return pipeline_typeck_is_simd_comptime_callee_c(name, name_len); }

extern int32_t pipeline_typeck_linear_accepts_init_c(struct ast_ASTArena * arena, int32_t decl_ref, int32_t init_ref);
int32_t pipeline_typeck_linear_accepts_init_c_ASTArena_ptr_i32_i32_reti32(struct ast_ASTArena * arena, int32_t decl_ref, int32_t init_ref) { return pipeline_typeck_linear_accepts_init_c(arena, decl_ref, init_ref); }

extern int32_t pipeline_typeck_linear_use_var_c(struct ast_ASTArena * arena, int32_t type_ref, int32_t expr_ref, uint8_t * name, int32_t name_len);
int32_t pipeline_typeck_linear_use_var_c_ASTArena_ptr_i32_i32_u8_ptr_i32_reti32(struct ast_ASTArena * arena, int32_t type_ref, int32_t expr_ref, uint8_t * name, int32_t name_len) { return pipeline_typeck_linear_use_var_c(arena, type_ref, expr_ref, name, name_len); }

extern void pipeline_typeck_loop_depth_set_c(struct ast_PipelineDepCtx * ctx, int32_t depth);
void pipeline_typeck_loop_depth_set_c_PipelineDepCtx_ptr_i32(struct ast_PipelineDepCtx * ctx, int32_t depth) { pipeline_typeck_loop_depth_set_c(ctx, depth); }

extern int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena * arena, int32_t op_ref, int32_t elem_ty, struct ast_Module * module, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_ptr_for_addr_of_operand_c_ASTArena_ptr_i32_i32_Module_ptr_PipelineDepCtx_ptr_reti32(struct ast_ASTArena * arena, int32_t op_ref, int32_t elem_ty, struct ast_Module * module, struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_ptr_for_addr_of_operand_c(arena, op_ref, elem_ty, module, ctx); }

extern int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena * arena);
int32_t pipeline_typeck_read_ptr_slice_return_ref_c_ASTArena_ptr_reti32(struct ast_ASTArena * arena) { return pipeline_typeck_read_ptr_slice_return_ref_c(arena); }

extern int32_t pipeline_typeck_reject_addr_of_linear_c(struct ast_ASTArena * arena, int32_t op_ref, int32_t addr_expr_ref, struct ast_Module * module, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_reject_addr_of_linear_c_ASTArena_ptr_i32_i32_Module_ptr_PipelineDepCtx_ptr_reti32(struct ast_ASTArena * arena, int32_t op_ref, int32_t addr_expr_ref, struct ast_Module * module, struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_reject_addr_of_linear_c(arena, op_ref, addr_expr_ref, module, ctx); }

extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(uint8_t * m, uint8_t * a, int32_t call_expr_ref);
int32_t pipeline_typeck_resolve_call_func_index_for_emit_c_u8_ptr_u8_ptr_i32_reti32(uint8_t * m, uint8_t * a, int32_t call_expr_ref) { return pipeline_typeck_resolve_call_func_index_for_emit_c(m, a, call_expr_ref); }

extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena * arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_c_ASTArena_ptr_i32_i32_reti32(struct ast_ASTArena * arena, int32_t a, int32_t b) { return pipeline_typeck_type_refs_equal_c(arena, a, b); }

extern void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx * ctx, int32_t saved);
void pipeline_typeck_unsafe_depth_pop_c_PipelineDepCtx_ptr_i32(struct ast_PipelineDepCtx * ctx, int32_t saved) { pipeline_typeck_unsafe_depth_pop_c(ctx, saved); }

extern int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx * ctx);
int32_t pipeline_typeck_unsafe_depth_push_c_PipelineDepCtx_ptr_reti32(struct ast_PipelineDepCtx * ctx) { return pipeline_typeck_unsafe_depth_push_c(ctx); }
