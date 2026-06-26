/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; uint8_t region_label[64]; int32_t region_label_len; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t field_access_soa_stride; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t region_base; int32_t num_regions; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; int32_t is_async; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; int32_t packed; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t pending_soa_struct; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };
extern int ast_ref_is_null(int32_t ref);

/* ast gen2 late link aliases */
#define ast_expr_apply_call_resolve ast_ast_expr_apply_call_resolve
#define ast_block_num_expr_stmts ast_ast_block_num_expr_stmts
#define ast_block_final_expr_ref ast_ast_block_final_expr_ref
#define ast_block_num_stmt_order ast_ast_block_num_stmt_order
#define ast_block_stmt_order_kind ast_ast_block_stmt_order_kind
#define ast_block_stmt_order_idx ast_ast_block_stmt_order_idx
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_expr_disallows_implicit_tail ast_ast_expr_disallows_implicit_tail
#define ast_block_const_init_ref ast_ast_block_const_init_ref
#define ast_block_const_type_ref ast_ast_block_const_type_ref
#define ast_block_let_init_ref ast_ast_block_let_init_ref
#define ast_block_let_type_ref ast_ast_block_let_type_ref
#define ast_block_while_cond_ref ast_ast_block_while_cond_ref
#define ast_block_while_body_ref ast_ast_block_while_body_ref
#define ast_block_for_init_ref ast_ast_block_for_init_ref
#define ast_block_for_cond_ref ast_ast_block_for_cond_ref
#define ast_block_for_step_ref ast_ast_block_for_step_ref
#define ast_block_for_body_ref ast_ast_block_for_body_ref
#define ast_block_if_cond_ref ast_ast_block_if_cond_ref
#define ast_block_if_then_body_ref ast_ast_block_if_then_body_ref
#define ast_block_if_else_body_ref ast_ast_block_if_else_body_ref
#define ast_block_num_consts ast_ast_block_num_consts
#define ast_block_num_lets ast_ast_block_num_lets
#define ast_block_num_loops ast_ast_block_num_loops
#define ast_block_num_for_loops ast_ast_block_num_for_loops
#define ast_block_num_if_stmts ast_ast_block_num_if_stmts
#define ast_block_num_regions ast_ast_block_num_regions

/* ast gen2 single-prefix externs */
extern void ast_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern int32_t ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern __attribute__((weak)) void ast_expr_init_call_resolve(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int32_t ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_else_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_regions(struct ast_ASTArena * a, int32_t br);

/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_name_into ast_pipeline_module_struct_layout_name_into
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_name_into ast_pipeline_module_struct_layout_field_name_into
#define pipeline_module_import_path_byte_at ast_pipeline_module_import_path_byte_at
#define pipeline_module_import_binding_name_len ast_pipeline_module_import_binding_name_len
#define pipeline_module_import_binding_name_byte_at ast_pipeline_module_import_binding_name_byte_at
#define pipeline_module_import_select_name_len ast_pipeline_module_import_select_name_len
#define pipeline_module_import_select_name_byte_at ast_pipeline_module_import_select_name_byte_at
#define pipeline_module_top_level_let_name_len ast_pipeline_module_top_level_let_name_len
#define pipeline_module_top_level_let_name_byte_at ast_pipeline_module_top_level_let_name_byte_at
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_allow_padding_at ast_pipeline_module_struct_layout_allow_padding_at
#define pipeline_module_struct_layout_field_offset_at ast_pipeline_module_struct_layout_field_offset_at
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_module_at ast_pipeline_dep_ctx_module_at
#define pipeline_module_struct_layout_set_field ast_pipeline_module_struct_layout_set_field
#define pipeline_module_struct_layout_set_num_fields ast_pipeline_module_struct_layout_set_num_fields
#define pipeline_module_struct_layout_alloc ast_pipeline_module_struct_layout_alloc
#define pipeline_module_struct_layout_reset_slot ast_pipeline_module_struct_layout_reset_slot
#define pipeline_module_struct_layout_set_name ast_pipeline_module_struct_layout_set_name
#define pipeline_module_func_name_byte_at ast_pipeline_module_func_name_byte_at
#define pipeline_arena_type_alloc ast_pipeline_arena_type_alloc
#define pipeline_dep_ctx_arena_at ast_pipeline_dep_ctx_arena_at
#define pipeline_module_struct_layout_name_byte_at ast_pipeline_module_struct_layout_name_byte_at
#define pipeline_module_struct_layout_soa_at ast_pipeline_module_struct_layout_soa_at
#define pipeline_module_struct_layout_set_allow_padding ast_pipeline_module_struct_layout_set_allow_padding
#define pipeline_module_struct_layout_set_soa ast_pipeline_module_struct_layout_set_soa
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_func_name_equal_at ast_pipeline_module_func_name_equal_at
#define pipeline_module_import_path_len ast_pipeline_module_import_path_len
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_expr_array_lit_num_elems_at ast_pipeline_expr_array_lit_num_elems_at
#define pipeline_block_expr_stmt_ref ast_pipeline_block_expr_stmt_ref
#define pipeline_expr_match_arm_is_enum_variant ast_pipeline_expr_match_arm_is_enum_variant
#define pipeline_expr_match_arm_variant_index ast_pipeline_expr_match_arm_variant_index
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_match_num_arms_at ast_pipeline_expr_match_num_arms_at
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_call_num_args_at ast_pipeline_expr_call_num_args_at
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
#define pipeline_block_resolve_var_type_ref ast_pipeline_block_resolve_var_type_ref
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_module_func_body_expr_ref_at ast_pipeline_module_func_body_expr_ref_at

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_typeck_loop_depth_set_c pipeline_typeck_loop_depth_set_c
#define ast_pipeline_typeck_check_expr_impl_c pipeline_typeck_check_expr_impl_c
#define ast_pipeline_typeck_check_expr_impl_mega_c pipeline_typeck_check_expr_impl_mega_c
#define ast_pipeline_typeck_check_expr_field_access_c pipeline_typeck_check_expr_field_access_c
#define ast_pipeline_typeck_field_prebind_c pipeline_typeck_field_prebind_c
#define ast_pipeline_typeck_field_known_ptr_types_c pipeline_typeck_field_known_ptr_types_c
#define ast_pipeline_typeck_field_layout_named_c pipeline_typeck_field_layout_named_c
#define ast_pipeline_typeck_field_slice_c pipeline_typeck_field_slice_c
#define ast_pipeline_typeck_field_name_fallback_c pipeline_typeck_field_name_fallback_c
#define ast_pipeline_typeck_field_lexer_fallback_c pipeline_typeck_field_lexer_fallback_c
#define ast_pipeline_type_named_name_into pipeline_type_named_name_into
#define ast_pipeline_type_kind_ord_at pipeline_type_kind_ord_at
#define ast_pipeline_type_array_size_at pipeline_type_array_size_at
#define ast_pipeline_type_elem_ref_at pipeline_type_elem_ref_at
#define ast_pipeline_typeck_type_refs_equal_c pipeline_typeck_type_refs_equal_c
#define ast_pipeline_expr_binop_left_ref_at pipeline_expr_binop_left_ref_at
#define ast_pipeline_expr_binop_right_ref_at pipeline_expr_binop_right_ref_at
#define ast_pipeline_patch_block_parent_links pipeline_patch_block_parent_links
#define ast_pipeline_get_dep_arena_slot pipeline_get_dep_arena_slot
#define ast_pipeline_module_func_param_type_ref_for_name pipeline_module_func_param_type_ref_for_name
#define ast_pipeline_module_num_funcs pipeline_module_num_funcs
#define ast_pipeline_module_main_func_index pipeline_module_main_func_index
#define ast_pipeline_module_func_is_extern_at pipeline_module_func_is_extern_at
#define ast_pipeline_module_func_body_ref_at pipeline_module_func_body_ref_at
#define ast_pipeline_module_func_name_len_at pipeline_module_func_name_len_at
#define ast_pipeline_module_func_name_copy64 pipeline_module_func_name_copy64
#define ast_pipeline_struct_layout_next_field_offset pipeline_struct_layout_next_field_offset
#define ast_pipeline_expr_struct_lit_num_fields pipeline_expr_struct_lit_num_fields
#define ast_pipeline_expr_struct_lit_type_name_len pipeline_expr_struct_lit_type_name_len
#define ast_pipeline_expr_struct_lit_type_name_into pipeline_expr_struct_lit_type_name_into
#define ast_pipeline_expr_struct_lit_field_name_len pipeline_expr_struct_lit_field_name_len
#define ast_pipeline_expr_struct_lit_field_name_into pipeline_expr_struct_lit_field_name_into
#define ast_pipeline_expr_struct_lit_init_ref pipeline_expr_struct_lit_init_ref
#define ast_pipeline_expr_resolved_type_ref pipeline_expr_resolved_type_ref
#define ast_pipeline_expr_set_resolved_type_ref pipeline_expr_set_resolved_type_ref
#define ast_pipeline_expr_typeck_set_float_bits_from_val pipeline_expr_typeck_set_float_bits_from_val
#define ast_pipeline_expr_line_at pipeline_expr_line_at
#define ast_pipeline_expr_col_at pipeline_expr_col_at
#define ast_pipeline_dep_ctx_typeck_loop_depth_at pipeline_dep_ctx_typeck_loop_depth_at
#define ast_pipeline_dep_ctx_current_block_ref_at pipeline_dep_ctx_current_block_ref_at
#define ast_pipeline_typeck_block_impl_bind_ctx_c pipeline_typeck_block_impl_bind_ctx_c
#define ast_pipeline_typeck_block_impl_restore_ctx_c pipeline_typeck_block_impl_restore_ctx_c
#define ast_pipeline_typeck_block_impl_touch_ctx_block_c pipeline_typeck_block_impl_touch_ctx_block_c
#define ast_pipeline_expr_int_val_at pipeline_expr_int_val_at
#define ast_pipeline_expr_set_field_access_enum_variant pipeline_expr_set_field_access_enum_variant
#define ast_pipeline_type_init_primitive_kind_at pipeline_type_init_primitive_kind_at
#define ast_pipeline_type_init_named_at pipeline_type_init_named_at
#define ast_pipeline_type_init_compound_kind_at pipeline_type_init_compound_kind_at
#define ast_pipeline_type_ensure_by_kind_ord pipeline_type_ensure_by_kind_ord
#define ast_pipeline_type_find_or_alloc_named pipeline_type_find_or_alloc_named
#define ast_pipeline_type_find_or_alloc_compound pipeline_type_find_or_alloc_compound
#define ast_pipeline_type_region_label_into pipeline_type_region_label_into
#define ast_pipeline_type_region_label_len_at pipeline_type_region_label_len_at
#define ast_pipeline_type_set_region_label_at pipeline_type_set_region_label_at
#define ast_pipeline_type_find_or_alloc_slice pipeline_type_find_or_alloc_slice
#define ast_pipeline_typeck_check_slice_region_assign_c pipeline_typeck_check_slice_region_assign_c
#define ast_pipeline_typeck_check_return_slice_region_c pipeline_typeck_check_return_slice_region_c
#define ast_pipeline_typeck_check_call_slice_region_c pipeline_typeck_check_call_slice_region_c
#define ast_pipeline_type_stamp_block_let_region_c pipeline_type_stamp_block_let_region_c
#define ast_pipeline_typeck_check_block_one_region_c pipeline_typeck_check_block_one_region_c
#define ast_pipeline_typeck_linear_reset_c pipeline_typeck_linear_reset_c
#define ast_pipeline_typeck_linear_use_var_c pipeline_typeck_linear_use_var_c
#define ast_pipeline_typeck_linear_accepts_init_c pipeline_typeck_linear_accepts_init_c
#define ast_pipeline_typeck_reject_addr_of_linear_c pipeline_typeck_reject_addr_of_linear_c
#define ast_pipeline_typeck_ptr_for_addr_of_operand_c pipeline_typeck_ptr_for_addr_of_operand_c
#define ast_pipeline_typeck_check_struct_stack_escape_assign_c pipeline_typeck_check_struct_stack_escape_assign_c
#define ast_pipeline_typeck_is_read_ptr_slice_callee_c pipeline_typeck_is_read_ptr_slice_callee_c
#define ast_pipeline_typeck_read_ptr_slice_return_ref_c pipeline_typeck_read_ptr_slice_return_ref_c
#define ast_pipeline_module_func_param_type_ref_at pipeline_module_func_param_type_ref_at
#define ast_pipeline_module_func_num_params_at pipeline_module_func_num_params_at
#define ast_pipeline_expr_call_resolved_func_index_at pipeline_expr_call_resolved_func_index_at
#define ast_pipeline_expr_kind_ord_at pipeline_expr_kind_ord_at
#define ast_pipeline_asm_block_final_expr_ref_at pipeline_asm_block_final_expr_ref_at
#define ast_pipeline_expr_unary_operand_ref_at pipeline_expr_unary_operand_ref_at
#define ast_pipeline_expr_set_index_base_is_slice pipeline_expr_set_index_base_is_slice
#define ast_pipeline_expr_set_index_proven_in_bounds pipeline_expr_set_index_proven_in_bounds
#define ast_pipeline_expr_as_target_type_ref_at pipeline_expr_as_target_type_ref_at
#define ast_pipeline_expr_field_access_name_into pipeline_expr_field_access_name_into
#define ast_pipeline_expr_field_access_name_len pipeline_expr_field_access_name_len
#define ast_pipeline_expr_field_access_base_ref pipeline_expr_field_access_base_ref
#define ast_pipeline_expr_set_field_access_offset pipeline_expr_set_field_access_offset
#define ast_pipeline_expr_var_name_into pipeline_expr_var_name_into
#define ast_pipeline_expr_var_name_len pipeline_expr_var_name_len
#define ast_pipeline_module_num_struct_layouts_at pipeline_module_num_struct_layouts_at
#define ast_pipeline_module_struct_layout_field_align_at pipeline_module_struct_layout_field_align_at
#define ast_pipeline_module_struct_layout_set_field_align pipeline_module_struct_layout_set_field_align
#define ast_pipeline_struct_layout_next_field_offset_ex pipeline_struct_layout_next_field_offset_ex
#define ast_pipeline_typeck_pad_fields_warn_layout pipeline_typeck_pad_fields_warn_layout
#define ast_pipeline_typeck_hot_reorder_warn_layout pipeline_typeck_hot_reorder_warn_layout
struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t target_cpu_features; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; int32_t typeck_scope_region_len; uint8_t typeck_scope_region_label[64]; };

/* pipeline glue usage aliases */
extern int32_t ast_pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name,
                                                         int32_t enum_len, uint8_t *variant_name,
                                                         int32_t variant_len);
#define pipeline_arena_type_alloc ast_pipeline_arena_type_alloc
#define pipeline_block_expr_stmt_ref ast_pipeline_block_expr_stmt_ref
#define pipeline_block_resolve_var_type_ref ast_pipeline_block_resolve_var_type_ref
#define pipeline_dep_ctx_current_func_index ast_pipeline_dep_ctx_current_func_index
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_set_current_func_index ast_pipeline_dep_ctx_set_current_func_index
#define pipeline_expr_array_lit_num_elems_at ast_pipeline_expr_array_lit_num_elems_at
#define pipeline_expr_as_operand_ref_at ast_pipeline_expr_as_operand_ref_at
#define pipeline_expr_block_ref_at ast_pipeline_expr_block_ref_at
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_call_callee_ref_at ast_pipeline_expr_call_callee_ref_at
#define pipeline_expr_call_num_args_at ast_pipeline_expr_call_num_args_at
#define pipeline_expr_field_access_is_enum_variant ast_pipeline_expr_field_access_is_enum_variant
#define pipeline_expr_if_cond_ref_at ast_pipeline_expr_if_cond_ref_at
#define pipeline_expr_if_else_ref_at ast_pipeline_expr_if_else_ref_at
#define pipeline_expr_if_then_ref_at ast_pipeline_expr_if_then_ref_at
#define pipeline_expr_index_base_ref ast_pipeline_expr_index_base_ref
#define pipeline_expr_index_index_ref ast_pipeline_expr_index_index_ref
#define pipeline_expr_match_arm_is_enum_variant ast_pipeline_expr_match_arm_is_enum_variant
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_match_arm_variant_index ast_pipeline_expr_match_arm_variant_index
#define pipeline_expr_match_matched_ref_at ast_pipeline_expr_match_matched_ref_at
#define pipeline_expr_match_num_arms_at ast_pipeline_expr_match_num_arms_at
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_expr_method_call_base_ref_at ast_pipeline_expr_method_call_base_ref_at
#define pipeline_expr_method_call_num_args_at ast_pipeline_expr_method_call_num_args_at
#define pipeline_module_enum_variant_tag_for_names ast_pipeline_module_enum_variant_tag_for_names
#define pipeline_module_func_body_expr_ref_at ast_pipeline_module_func_body_expr_ref_at
#define pipeline_module_func_name_byte_at ast_pipeline_module_func_name_byte_at
#define pipeline_module_func_name_equal_at ast_pipeline_module_func_name_equal_at
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_import_binding_name_byte_at ast_pipeline_module_import_binding_name_byte_at
#define pipeline_module_import_binding_name_len ast_pipeline_module_import_binding_name_len
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_path_byte_at ast_pipeline_module_import_path_byte_at
#define pipeline_module_import_path_len ast_pipeline_module_import_path_len
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_module_import_select_name_byte_at ast_pipeline_module_import_select_name_byte_at
#define pipeline_module_import_select_name_len ast_pipeline_module_import_select_name_len
#define pipeline_module_struct_layout_alloc ast_pipeline_module_struct_layout_alloc
#define pipeline_module_struct_layout_allow_padding_at ast_pipeline_module_struct_layout_allow_padding_at
#define pipeline_module_struct_layout_field_name_into ast_pipeline_module_struct_layout_field_name_into
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_offset_at ast_pipeline_module_struct_layout_field_offset_at
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_name_byte_at ast_pipeline_module_struct_layout_name_byte_at
#define pipeline_module_struct_layout_name_into ast_pipeline_module_struct_layout_name_into
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_reset_slot ast_pipeline_module_struct_layout_reset_slot
#define pipeline_module_struct_layout_set_allow_padding ast_pipeline_module_struct_layout_set_allow_padding
#define pipeline_module_struct_layout_set_field ast_pipeline_module_struct_layout_set_field
#define pipeline_module_struct_layout_set_name ast_pipeline_module_struct_layout_set_name
#define pipeline_module_struct_layout_set_num_fields ast_pipeline_module_struct_layout_set_num_fields
#define pipeline_module_top_level_let_name_byte_at ast_pipeline_module_top_level_let_name_byte_at
#define pipeline_module_top_level_let_name_len ast_pipeline_module_top_level_let_name_len
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void ast_pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t li, int32_t j, uint8_t * out64);
extern uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern struct ast_Module * ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t li, int32_t j, uint8_t * fname_bytes, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module * module, int32_t idx, int32_t nf);
extern int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module * module, int32_t fi, int32_t i);
extern int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena * arena);
extern struct ast_ASTArena * ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_soa_at(struct ast_Module * module, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
extern void ast_pipeline_module_struct_layout_set_soa(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t ast_pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern int32_t ast_pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena * arena, int32_t br, int32_t ei);
extern int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena * arena, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t typeck_float64_bits_lo(double d);
extern int32_t typeck_float64_bits_hi(double d);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void pipeline_typeck_loop_depth_set_c(struct ast_PipelineDepCtx * ctx, int32_t depth);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx * ctx, int32_t ix);
extern int32_t pipeline_typeck_check_expr_impl_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_check_expr_impl_mega_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
extern void pipeline_typeck_field_prebind_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_field_known_ptr_types_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t base_ref, int32_t num_layouts);
extern int32_t pipeline_typeck_field_layout_named_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx * ctx);
extern void pipeline_typeck_field_slice_c(struct ast_ASTArena * arena, int32_t expr_ref, int32_t base_ref);
extern void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena * arena, int32_t expr_ref, int32_t base_ref);
extern void pipeline_typeck_field_lexer_fallback_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx * ctx);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * out);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena * arena, int32_t a, int32_t b);
extern int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);
extern uint8_t * driver_typeck_diag_scratch_expect();
extern uint8_t * driver_typeck_diag_scratch_found();
extern uint8_t * typeck_scratch64_slot(int32_t slot);
extern int32_t * typeck_layout_metrics_sz_slot();
extern int32_t * typeck_layout_metrics_al_slot();
extern int32_t * typeck_layout_metrics_sz_slot_depth(int32_t depth);
extern int32_t * typeck_layout_metrics_al_slot_depth(int32_t depth);
extern void typeck_i32_ptr_store(int32_t * p, int32_t v);
extern int32_t typeck_i32_ptr_read(int32_t * p);
extern int32_t * typeck_call_resolve_dep_idx_slot();
extern int32_t * typeck_call_resolve_func_idx_slot();
extern int32_t typeck_call_resolve_dep_idx_peek();
extern int32_t typeck_call_resolve_func_idx_peek();
extern void typeck_binop_arith_infer_type_c(struct ast_ASTArena * arena, int32_t expr_ref, int32_t bop_l, int32_t bop_r, int32_t expr_kind);
extern void pipeline_patch_block_parent_links(struct ast_ASTArena * arena, int32_t block_ref, int32_t parent_ref);
extern void typeck_layout_metrics_init_depth(int32_t depth);
extern int32_t typeck_layout_metrics_al_read_depth(int32_t depth);
extern int32_t typeck_layout_metrics_sz_read_depth(int32_t depth);
extern void typeck_layout_metrics_init_slot();
extern int32_t typeck_sx_type_align_from_layout_glue(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth);
extern int32_t typeck_sx_type_size_from_layout_glue(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth);
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module * module, struct ast_ASTArena * arena, int32_t elem_type_ref, int32_t array_len, int32_t depth);
extern struct ast_ASTArena * pipeline_get_dep_arena_slot(int32_t ix);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module * module, int32_t func_index, uint8_t * vname, int32_t vname_len);
extern int32_t pipeline_module_num_funcs(struct ast_Module * module);
extern int32_t pipeline_module_main_func_index(struct ast_Module * module);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module * module, int32_t fi);
extern void pipeline_module_func_name_copy64(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern uint8_t pipeline_module_func_name_byte_at(struct ast_Module * module, int32_t fi, int32_t i);
extern int32_t pipeline_module_func_name_equal_at(struct ast_Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t layout_idx, int32_t j, uint8_t * fname, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern int32_t pipeline_struct_layout_next_field_offset(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_idx, int32_t new_field_type_ref);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t layout_idx, int32_t j, uint8_t * out);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t layout_idx, int32_t j);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t layout_idx);
extern void pipeline_module_struct_layout_set_num_fields(struct ast_Module * module, int32_t layout_idx, int32_t nf);
extern int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_type_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_struct_lit_type_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j, uint8_t * out);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t type_ref);
extern void pipeline_expr_typeck_set_float_bits_from_val(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_line_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_col_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_dep_ctx_typeck_loop_depth_at(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_dep_ctx_current_block_ref_at(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_block_impl_bind_ctx_c(struct ast_PipelineDepCtx * ctx, int32_t block_ref);
extern void pipeline_typeck_block_impl_restore_ctx_c(struct ast_PipelineDepCtx * ctx, int32_t saved_block_ref);
extern void pipeline_typeck_block_impl_touch_ctx_block_c(struct ast_PipelineDepCtx * ctx, int32_t block_ref);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_set_field_access_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t tag);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module * m, uint8_t * enum_name, int32_t enum_len, uint8_t * variant_name, int32_t variant_len);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);
extern int32_t pipeline_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_type_init_primitive_kind_at(struct ast_ASTArena * arena, int32_t ref, int32_t kind_ord);
extern int32_t pipeline_type_init_named_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * name, int32_t name_len);
extern int32_t pipeline_type_init_compound_kind_at(struct ast_ASTArena * arena, int32_t ref, int32_t kind_ord, int32_t elem_ref, int32_t array_size);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena * arena, int32_t kind_ord);
extern int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
extern int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena * arena, int32_t kind_ord, int32_t elem_ref, int32_t array_size);
extern int32_t pipeline_type_region_label_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out64);
extern int32_t pipeline_type_region_label_len_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_set_region_label_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * label, int32_t label_len);
extern int32_t pipeline_type_find_or_alloc_slice(struct ast_ASTArena * arena, int32_t elem_ref, uint8_t * reg_label, int32_t reg_label_len);
extern int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena * arena, int32_t site_expr_ref, int32_t expect_ref, int32_t src_ref);
extern int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena * arena, int32_t ret_site_ref, int32_t op_ref, int32_t func_return_ref);
extern int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t region_idx, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
extern void pipeline_typeck_linear_reset_c();
extern int32_t pipeline_typeck_linear_use_var_c(struct ast_ASTArena * arena, int32_t type_ref, int32_t expr_ref, uint8_t * name, int32_t name_len);
extern int32_t pipeline_typeck_linear_accepts_init_c(struct ast_ASTArena * arena, int32_t decl_ref, int32_t init_ref);
extern int32_t pipeline_typeck_reject_addr_of_linear_c(struct ast_ASTArena * arena, int32_t op_ref, int32_t addr_expr_ref, struct ast_Module * module, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena * arena, int32_t op_ref, int32_t elem_ty, struct ast_Module * module, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module * module, struct ast_ASTArena * arena, int32_t site_expr_ref, int32_t left_ref, int32_t right_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t * name, int32_t name_len);
extern int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena * arena);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_block_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_asm_block_final_expr_ref_at(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena * arena, int32_t block_ref, int32_t ei);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_index_base_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_set_index_base_is_slice(struct ast_ASTArena * arena, int32_t expr_ref, int32_t v);
extern void pipeline_expr_set_index_proven_in_bounds(struct ast_ASTArena * arena, int32_t expr_ref, int32_t v);
extern int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_set_field_access_offset(struct ast_ASTArena * arena, int32_t expr_ref, int32_t offset);
extern void pipeline_expr_var_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena * arena, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void asm_qual_sym_layer_reset();
extern int32_t asm_qual_sym_layer_push(uint8_t * bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count();
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t * dst, int32_t cap);
extern void driver_diagnostic_typeck_struct_padding_before(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t * sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module * module);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t layout_idx, int32_t j);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module * module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_align(struct ast_Module * module, int32_t li, int32_t j, int32_t al);
extern int32_t pipeline_struct_layout_next_field_offset_ex(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_idx, int32_t new_field_type_ref, int32_t field_align_req);
extern void pipeline_typeck_pad_fields_warn_layout(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li);
extern void pipeline_typeck_hot_reorder_warn_layout(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_soa_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_soa(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_path_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
int32_t typeck_type_kind_ordinal(enum ast_TypeKind k);
int typeck_name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len);
int typeck_layout_name_equal(struct ast_Module * module, int32_t k, uint8_t * nm, int32_t nlen);
int typeck_layout_field_name_equal(struct ast_Module * module, int32_t k, int32_t j, uint8_t * nm, int32_t nlen);
int32_t typeck_layout_name_into(struct ast_Module * module, int32_t k, uint8_t * buf);
int32_t typeck_layout_field_name_into(struct ast_Module * module, int32_t k, int32_t j, uint8_t * buf);
int typeck_import_path_slice_equal(struct ast_Module * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len);
int typeck_import_binding_name_equal(struct ast_Module * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len);
int typeck_import_select_name_equal(struct ast_Module * module, int32_t imp_ix, int32_t sel, uint8_t * nm, int32_t nm_len);
int typeck_top_level_let_name_equal(struct ast_Module * module, int32_t tl_ix, uint8_t * nm, int32_t nm_len);
int32_t typeck_find_layout_idx_by_type_name(struct ast_Module * module, uint8_t * nm, int32_t nlen);
int32_t typeck_sx_named_builtin_align(uint8_t * nm, int32_t nlen);
int32_t typeck_sx_named_builtin_size(uint8_t * nm, int32_t nlen);
int32_t typeck_sx_type_align(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth);
int32_t typeck_sx_type_size(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth);
int32_t typeck_struct_layout_metrics(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth, int32_t check_pad, int32_t * out_sz, int32_t * out_al);
int32_t typeck_validate_struct_layouts_zero_padding(struct ast_Module * module, struct ast_ASTArena * arena);
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref);
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index);
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena * arena, int32_t base_type_ref, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_ensure_primitive_by_kind_ord(struct ast_ASTArena * arena, int32_t kind_ord);
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_f32_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a);
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena);
int32_t typeck_find_or_alloc_compound_type_ref(struct ast_ASTArena * a, int32_t kind_ord, int32_t elem_ref, int32_t array_size);
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size);
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size);
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, enum ast_TypeKind kind);
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref);
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref);
int32_t typeck_find_or_alloc_linear_type_ref(struct ast_ASTArena * w, int32_t elem_ref);
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size);
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena);
int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_inline_u8_64_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_expr_inline_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen);
void typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
void typeck_wpo_unify_soa_layouts(struct ast_Module * entry, struct ast_PipelineDepCtx * ctx);
int32_t typeck_resolve_scan_dep_with_apply(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax, int32_t want_apply);
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);
int32_t typeck_import_path_segment_count(uint8_t * path, int32_t path_len);
int typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out);
int32_t typeck_resolve_call_binding_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out);
int32_t typeck_resolve_call_select_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t dep_ix, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);
int32_t typeck_resolve_call_callee_try_whole_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord);
int32_t typeck_resolve_call_callee_try_binding_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord);
int32_t typeck_resolve_call_callee_local_module(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_resolve_call_callee_scan_dep(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax);
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_refs_equal_named(struct ast_ASTArena * arena, int32_t a, int32_t b);
int typeck_type_refs_equal_same_kind(struct ast_ASTArena * arena, int32_t a, int32_t b, int32_t kind_ord);
int typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b);
int typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b);
int typeck_return_operand_matches(struct ast_ASTArena * arena, int32_t op_ref, int32_t expect_ref);
int32_t typeck_coerce_init_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_float_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_enum_field_to_decl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_named_call_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_array_vector_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_vector_binop_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t typeck_coerce_init_slice_from_array(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind);
int32_t typeck_coerce_init_expr_to_decl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref);
extern int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind);
extern int32_t pipeline_typeck_check_expr_int_lit_c(struct ast_ASTArena *arena, int32_t expr_ref);
int32_t typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len);
int32_t typeck_diag_append_u32_dec(uint8_t * out, int32_t pos, int32_t cap, int32_t v);
int32_t typeck_diag_fmt_type_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cur, int32_t cap);
int32_t typeck_diag_fmt_type_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cap);
int32_t typeck_diag_fmt_type_or_question(struct ast_ASTArena * arena, int32_t ref, uint8_t * out);
void typeck_ret_coerce_integral_to_expect_i32(struct ast_ASTArena * arena, int32_t op_ref, int32_t expect_ref);
int32_t typeck_check_expr_float_lit(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_check_expr_int_lit(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_check_expr_bool_lit(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_check_expr_break_continue(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_check_expr_if_ternary(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_assign(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_return(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_panic(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_match_arm(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arm_i, int32_t num_arms, int32_t line, int32_t col);
int32_t typeck_check_expr_match(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_call_arg(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arg_i, int32_t num_args);
int32_t typeck_check_expr_call_resolve(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_binop_cmp(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_binop_arith(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_binop(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_field_access(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_unary(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_addr_of(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_deref(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_var_top_level(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * vbuf, int32_t vnlen, int32_t tl);
int32_t typeck_check_expr_var(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_method_call_arg(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arg_i, int32_t num_args);
int32_t typeck_check_expr_method_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_as(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_struct_lit_field(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t field_i, int32_t num_fields);
int32_t typeck_check_expr_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_index(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int typeck_expr_is_any_assign_kind(int32_t kind_ord);
int32_t typeck_check_expr_impl_mega(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref);
int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref);
int32_t typeck_loop_depth_push(struct ast_PipelineDepCtx * ctx);
void typeck_loop_depth_pop(struct ast_PipelineDepCtx * ctx, int32_t saved);
int32_t typeck_check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_block_one_const(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_one_let(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_one_while(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_one_for(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_one_if(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_final(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t fin0);
int32_t typeck_check_block_one_region(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx);
int32_t typeck_check_block_stmt_order_one(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t si, int32_t nso, int32_t nc, int32_t nl, int32_t nes, int32_t nlp, int32_t nfp, int32_t nif, int32_t nreg);
int32_t typeck_check_block_legacy_consts(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nc);
int32_t typeck_check_block_legacy_lets(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nl);
int32_t typeck_check_block_legacy_whiles(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nlp);
int32_t typeck_check_block_legacy_fors(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nfp);
int32_t typeck_check_block_legacy_ifs(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nif);
int32_t typeck_check_block_legacy_expr_stmts(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nes);
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_sx_ast_check_one_func(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t func_idx);
int32_t typeck_sx_ast_check_all_funcs_loop(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t func_i, int32_t num_funcs);
void typeck_patch_all_body_parent_links(struct ast_Module * module, struct ast_ASTArena * arena);
int32_t typeck_sx_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_sx_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_sx_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_type_kind_ordinal(enum ast_TypeKind k) {
  int32_t o = ((int32_t)(k));
  (void)(({ int32_t __tmp = 0; if (o < 0 || o > 15) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return o;
}
int typeck_name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len) {
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < a_len) {
    (void)(({ int __tmp = 0; if ((a)[i] != (b)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int typeck_layout_name_equal(struct ast_Module * module, int32_t k, uint8_t * nm, int32_t nlen) {
  uint8_t * buf = typeck_scratch64_slot(0);
  int32_t slen = pipeline_module_struct_layout_name_len(module, k);
  (void)(({ int __tmp = 0; if (slen != nlen || nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_name_into(module, k, buf));
  return typeck_name_equal(buf, slen, nm, nlen);
}
int typeck_layout_field_name_equal(struct ast_Module * module, int32_t k, int32_t j, uint8_t * nm, int32_t nlen) {
  uint8_t * buf = typeck_scratch64_slot(1);
  int32_t fl = pipeline_module_struct_layout_field_name_len(module, k, j);
  (void)(({ int __tmp = 0; if (fl != nlen || nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_field_name_into(module, k, j, buf));
  return typeck_name_equal(buf, fl, nm, nlen);
}
int32_t typeck_layout_name_into(struct ast_Module * module, int32_t k, uint8_t * buf) {
  (void)(pipeline_module_struct_layout_name_into(module, k, buf));
  return pipeline_module_struct_layout_name_len(module, k);
}
int32_t typeck_layout_field_name_into(struct ast_Module * module, int32_t k, int32_t j, uint8_t * buf) {
  (void)(pipeline_module_struct_layout_field_name_into(module, k, j, buf));
  return pipeline_module_struct_layout_field_name_len(module, k, j);
}
int typeck_import_path_slice_equal(struct ast_Module * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len) {
  (void)(({ int __tmp = 0; if (seg_len != nm_len || seg_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < seg_len) {
    (void)(({ int __tmp = 0; if (pipeline_module_import_path_byte_at(module, imp_ix, off + i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int typeck_import_binding_name_equal(struct ast_Module * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len) {
  int32_t bl = pipeline_module_import_binding_name_len(module, imp_ix);
  (void)(({ int __tmp = 0; if (bl != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (pipeline_module_import_binding_name_byte_at(module, imp_ix, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int typeck_import_select_name_equal(struct ast_Module * module, int32_t imp_ix, int32_t sel, uint8_t * nm, int32_t nm_len) {
  int32_t sl = pipeline_module_import_select_name_len(module, imp_ix, sel);
  (void)(({ int __tmp = 0; if (sl != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (pipeline_module_import_select_name_byte_at(module, imp_ix, sel, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int typeck_top_level_let_name_equal(struct ast_Module * module, int32_t tl_ix, uint8_t * nm, int32_t nm_len) {
  int32_t tll = pipeline_module_top_level_let_name_len(module, tl_ix);
  (void)(({ int __tmp = 0; if (tll != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (pipeline_module_top_level_let_name_byte_at(module, tl_ix, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t typeck_find_layout_idx_by_type_name(struct ast_Module * module, uint8_t * nm, int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, nm, nlen)) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return (-1);
}
int32_t typeck_sx_named_builtin_align(uint8_t * nm, int32_t nlen) {
  (void)(({ int32_t __tmp = 0; if (nm == ((uint8_t *)(0)) || nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 105 && (nm)[1] == 51 && (nm)[2] == 50) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 117 && (nm)[1] == 51 && (nm)[2] == 50) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 4 && (nm)[0] == 98 && (nm)[1] == 111 && (nm)[2] == 111 && (nm)[3] == 108) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 2 && (nm)[0] == 117 && (nm)[1] == 56) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 105 && (nm)[1] == 54 && (nm)[2] == 52) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 117 && (nm)[1] == 54 && (nm)[2] == 52) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 5 && (nm)[0] == 117 && (nm)[1] == 115 && (nm)[2] == 105 && (nm)[3] == 122 && (nm)[4] == 101) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 5 && (nm)[0] == 105 && (nm)[1] == 115 && (nm)[2] == 105 && (nm)[3] == 122 && (nm)[4] == 101) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 102 && (nm)[1] == 51 && (nm)[2] == 50) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nlen == 3 && (nm)[0] == 102 && (nm)[1] == 54 && (nm)[2] == 52) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_sx_named_builtin_size(uint8_t * nm, int32_t nlen) {
  int32_t a = typeck_sx_named_builtin_align(nm, nlen);
  (void)(({ int32_t __tmp = 0; if (a == 1 && nlen == 2 && (nm)[0] == 117 && (nm)[1] == 56) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (a == 4) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (a == 8) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_sx_type_align(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth) {
  int32_t ko = 0;
  int32_t er = 0;
  int32_t nm_len = 0;
  int32_t li = 0;
  int32_t ba = 0;
  uint8_t * nm_buf = typeck_scratch64_slot(4);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > (arena)->num_types || depth > 64) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (ko = (pipeline_type_kind_ord_at(arena, ty_ref)));
  (void)(({ int32_t __tmp = 0; if (ko == 2) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 0 || ko == 3 || ko == 1 || ko == 14) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 5 || ko == 4 || ko == 6 || ko == 7 || ko == 15 || ko == 9) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 11) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 10 || ko == 12 || ko == 13) {   (er = (pipeline_type_elem_ref_at(arena, ty_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(er)) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_sx_type_align(module, arena, er, depth + 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 8) {   (nm_len = (pipeline_type_named_name_into(arena, ty_ref, nm_buf)));
  (li = (typeck_find_layout_idx_by_type_name(module, nm_buf, nm_len)));
  (void)(({ int32_t __tmp = 0; if (li >= 0) {   return typeck_sx_type_align_from_layout_glue(module, arena, li, depth + 1);
 } else (__tmp = 0) ; __tmp; }));
  (ba = (typeck_sx_named_builtin_align(nm_buf, nm_len)));
  (void)(({ int32_t __tmp = 0; if (ba > 0) {   return ba;
 } else (__tmp = 0) ; __tmp; }));
  return 4;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int32_t typeck_sx_type_size(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth) {
  int32_t ko = 0;
  int32_t er = 0;
  int32_t asz = 0;
  int32_t es = 0;
  int32_t nm_len = 0;
  int32_t li2 = 0;
  int32_t bsz = 0;
  uint8_t * nm_buf_sz = typeck_scratch64_slot(4);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > (arena)->num_types || depth > 64) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (ko = (pipeline_type_kind_ord_at(arena, ty_ref)));
  (void)(({ int32_t __tmp = 0; if (ko == 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 2) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 0 || ko == 3 || ko == 1 || ko == 14) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 5 || ko == 4 || ko == 6 || ko == 7 || ko == 15 || ko == 9) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 11) {   return 16;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 12) {   (er = (pipeline_type_elem_ref_at(arena, ty_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(er)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_sx_type_size(module, arena, er, depth + 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 10 || ko == 13) {   (er = (pipeline_type_elem_ref_at(arena, ty_ref)));
  (asz = (pipeline_type_array_size_at(arena, ty_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(er) || asz <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t soa_sz = typeck_soa_array_storage_size_glue(module, arena, er, asz, depth + 1);
  (void)(({ int32_t __tmp = 0; if (soa_sz > 0) {   return soa_sz;
 } else (__tmp = 0) ; __tmp; }));
  (es = (typeck_sx_type_size(module, arena, er, depth + 1)));
  (void)(({ int32_t __tmp = 0; if (es <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return asz * es;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ko == 8) {   (nm_len = (pipeline_type_named_name_into(arena, ty_ref, nm_buf_sz)));
  (li2 = (typeck_find_layout_idx_by_type_name(module, nm_buf_sz, nm_len)));
  (void)(({ int32_t __tmp = 0; if (li2 >= 0) {   return typeck_sx_type_size_from_layout_glue(module, arena, li2, depth + 1);
 } else (__tmp = 0) ; __tmp; }));
  (bsz = (typeck_sx_named_builtin_size(nm_buf_sz, nm_len)));
  (void)(({ int32_t __tmp = 0; if (bsz > 0) {   return bsz;
 } else (__tmp = 0) ; __tmp; }));
  return 4;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_struct_layout_metrics(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth, int32_t check_pad, int32_t * out_sz, int32_t * out_al) {
  int32_t nf = 0;
  int32_t allow = 0;
  int32_t layout_nlen = 0;
  int32_t current = 0;
  int32_t max_align = 1;
  int32_t j = 0;
  int32_t ftr = 0;
  int32_t flen = 0;
  int32_t A = 0;
  int32_t rem = 0;
  int32_t gap = 0;
  int32_t fsize = 0;
  int32_t end_pad = 0;
  int32_t fa = 0;
  uint8_t * layout_nm = typeck_scratch64_slot(2);
  uint8_t * field_nm = typeck_scratch64_slot(3);
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || out_sz == ((int32_t *)(0)) || out_al == ((int32_t *)(0))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (li < 0 || li >= pipeline_module_num_struct_layouts_at(module) || depth > 64) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (nf = (pipeline_module_struct_layout_num_fields(module, li)));
  (allow = (pipeline_module_struct_layout_allow_padding_at(module, li)));
  (void)(typeck_layout_name_into(module, li, layout_nm));
  (layout_nlen = (pipeline_module_struct_layout_name_len(module, li)));
  (current = (0));
  (max_align = (1));
  (j = (0));
  while (j < nf) {
    (ftr = (pipeline_module_struct_layout_field_type_ref(module, li, j)));
    (void)(typeck_layout_field_name_into(module, li, j, field_nm));
    (flen = (pipeline_module_struct_layout_field_name_len(module, li, j)));
    (fa = (pipeline_module_struct_layout_field_align_at(module, li, j)));
    (A = (typeck_sx_type_align(module, arena, ftr, depth)));
    (void)(({ int32_t __tmp = 0; if (A <= 0) {   (A = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (fa > A) {   (A = (fa));
 } else (__tmp = 0) ; __tmp; }));
    (rem = ((A == 0 ? (shux_panic_(1, 0), current) : (current % A))));
    (gap = (A - rem));
    (gap = ((A == 0 ? (shux_panic_(1, 0), gap) : (gap % A))));
    (void)(({ int32_t __tmp = 0; if (check_pad != 0 && gap > 0 && allow == 0) {   (void)(driver_diagnostic_typeck_struct_padding_before(layout_nm, layout_nlen, gap, field_nm, flen));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (current = (current + gap));
    (fsize = (typeck_sx_type_size(module, arena, ftr, depth)));
    (void)(({ int32_t __tmp = 0; if (fsize <= 0) {   (void)(driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (current = (current + fsize));
    (void)(({ int32_t __tmp = 0; if (A > max_align) {   (max_align = (A));
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  (void)(({ int32_t __tmp = 0; if (max_align > 0 && (max_align == 0 ? (shux_panic_(1, 0), current) : (current % max_align)) != 0) {   (end_pad = (max_align - (max_align == 0 ? (shux_panic_(1, 0), current) : (current % max_align))));
  (void)(({ int32_t __tmp = 0; if (check_pad != 0 && end_pad > 0 && allow == 0) {   (void)(driver_diagnostic_typeck_struct_padding_trailing(layout_nm, layout_nlen, end_pad));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (current = (current + end_pad));
 } else (__tmp = 0) ; __tmp; }));
  (void)(typeck_i32_ptr_store(out_sz, current));
  (void)(typeck_i32_ptr_store(out_al, max_align));
  return 0;
}
int32_t typeck_validate_struct_layouts_zero_padding(struct ast_Module * module, struct ast_ASTArena * arena) {
  int32_t li = 0;
  int32_t nsl = pipeline_module_num_struct_layouts_at(module);
  int32_t * sz_out = typeck_layout_metrics_sz_slot();
  int32_t * al_out = typeck_layout_metrics_al_slot();
  while (li < nsl) {
    (void)(typeck_layout_metrics_init_slot());
    (void)(({ int32_t __tmp = 0; if (typeck_struct_layout_metrics(module, arena, li, 0, 1, sz_out, al_out) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_typeck_pad_fields_warn_layout(module, arena, li));
    (void)(pipeline_typeck_hot_reorder_warn_layout(module, arena, li));
    ++li;
  }
  return 0;
}
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {   int32_t j = 0;
  while (j < pipeline_module_struct_layout_num_fields(module, k)) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {   return pipeline_module_struct_layout_field_offset_at(module, k, j);
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return (-1);
}
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {   int32_t j = 0;
  while (j < pipeline_module_struct_layout_num_fields(module, k)) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {   return pipeline_module_struct_layout_field_type_ref(module, k, j);
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t r = typeck_get_field_offset_from_layout(module, type_name, type_name_len, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (r >= 0) {   return r;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t nd = pipeline_dep_ctx_ndep(ctx);
  int32_t di = 0;
  while (di < nd) {
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, di);
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (r = (typeck_get_field_offset_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r >= 0) {   return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  return (-1);
}
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref) {
  int32_t num_fields = 0;
  int32_t name_len = 0;
  int32_t k = 0;
  int32_t found_idx = -1;
  int32_t idx_m = 0;
  int32_t jm = 0;
  int32_t fnlen_m = 0;
  int32_t exists_m = 0;
  int32_t tm = 0;
  int32_t nf_layout = 0;
  int32_t flen_tm = 0;
  int32_t nf_m = 0;
  int32_t ftr_m = 0;
  int32_t init_rm = 0;
  int32_t fr_m = 0;
  int32_t idx = 0;
  int32_t j = 0;
  int32_t fnlen_j = 0;
  int32_t ftr = 0;
  int32_t init_r = 0;
  int32_t fr = 0;
  int32_t foff_m = 0;
  int32_t foff_j = 0;
  int32_t nsl = 0;
  int32_t sname_len = 0;
  uint8_t * lit_nm = typeck_scratch64_slot(4);
  uint8_t * layout_nm = typeck_scratch64_slot(5);
  uint8_t * field_nm = typeck_scratch64_slot(6);
  uint8_t * exist_nm = typeck_scratch64_slot(7);
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (num_fields = (pipeline_expr_struct_lit_num_fields(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (num_fields <= 0 || num_fields > 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (name_len = (pipeline_expr_struct_lit_type_name_len(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_struct_lit_type_name_into(arena, expr_ref, lit_nm));
  (nsl = (pipeline_module_num_struct_layouts_at(module)));
  (k = (0));
  (found_idx = ((-1)));
  while (k < nsl) {
    (void)(pipeline_module_struct_layout_name_into(module, k, layout_nm));
    (sname_len = (pipeline_module_struct_layout_name_len(module, k)));
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal(layout_nm, sname_len, lit_nm, name_len)) {   (found_idx = (k));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  (void)(({ int32_t __tmp = 0; if (found_idx >= 0) {   (idx_m = (found_idx));
  (jm = (0));
  while (jm < num_fields) {
    (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, jm, field_nm));
    (fnlen_m = (pipeline_expr_struct_lit_field_name_len(arena, expr_ref, jm)));
    (exists_m = (0));
    (tm = (0));
    (nf_layout = (pipeline_module_struct_layout_num_fields(module, idx_m)));
    while (tm < nf_layout) {
      (void)(pipeline_module_struct_layout_field_name_into(module, idx_m, tm, exist_nm));
      (flen_tm = (pipeline_module_struct_layout_field_name_len(module, idx_m, tm)));
      (void)(({ int32_t __tmp = 0; if (typeck_name_equal(exist_nm, flen_tm, field_nm, fnlen_m)) {   (exists_m = (1));
 } else (__tmp = 0) ; __tmp; }));
      ++tm;
    }
    (void)(({ int32_t __tmp = 0; if (exists_m == 0) {   (nf_m = (nf_layout));
  (ftr_m = (0));
  (init_rm = (pipeline_expr_struct_lit_init_ref(arena, expr_ref, jm)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_rm)) && init_rm > 0 && init_rm <= (arena)->num_exprs) {   (fr_m = (typeck_expr_type_ref(arena, init_rm)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr_m))) {   (ftr_m = (fr_m));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (foff_m = (pipeline_struct_layout_next_field_offset(module, arena, idx_m, ftr_m)));
  (void)(pipeline_module_struct_layout_set_field(module, idx_m, nf_m, field_nm, fnlen_m, ftr_m, foff_m));
  (void)(pipeline_module_struct_layout_set_num_fields(module, idx_m, nf_m + 1));
 } else (__tmp = 0) ; __tmp; }));
    ++jm;
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (idx = (pipeline_module_struct_layout_alloc(module)));
  (void)(({ int32_t __tmp = 0; if (idx < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_reset_slot(module, idx));
  (void)(pipeline_module_struct_layout_set_name(module, idx, lit_nm, name_len));
  (void)(pipeline_module_struct_layout_set_num_fields(module, idx, num_fields));
  (j = (0));
  while (j < num_fields) {
    (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, field_nm));
    (fnlen_j = (pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j)));
    (ftr = (0));
    (init_r = (pipeline_expr_struct_lit_init_ref(arena, expr_ref, j)));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_r)) && init_r > 0 && init_r <= (arena)->num_exprs) {   (fr = (typeck_expr_type_ref(arena, init_r)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr))) {   (ftr = (fr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (foff_j = (pipeline_struct_layout_next_field_offset(module, arena, idx, ftr)));
    (void)(pipeline_module_struct_layout_set_field(module, idx, j, field_nm, fnlen_j, ftr, foff_j));
    ++j;
  }
  return 0;
}
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index) {
  uint8_t * vbuf = typeck_scratch64_slot(8);
  int32_t b_len = 0;
  int32_t a_len = 0;
  int32_t i = 0;
  (void)(({ int __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 3) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (b_len = (pipeline_expr_var_name_len(arena, callee_expr_ref)));
  (void)(({ int __tmp = 0; if (func_index < 0 || func_index >= (mod)->num_funcs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (a_len = (pipeline_module_func_name_len_at(mod, func_index)));
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0 || a_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_var_name_into(arena, callee_expr_ref, vbuf));
  while (i < a_len) {
    (void)(({ int __tmp = 0; if (pipeline_module_func_name_byte_at(mod, func_index, i) != (vbuf)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len) {
  int32_t k = 0;
  int32_t ko = 0;
  int32_t exist_len = 0;
  int32_t ord_named = 8;
  uint8_t * nm_scr = typeck_scratch64_slot(12);
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || name == ((uint8_t *)(0)) || name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (k = (1));
  while (k <= (arena)->num_types) {
    (ko = (pipeline_type_kind_ord_at(arena, k)));
    (void)(({ int32_t __tmp = 0; if (ko == ord_named) {   (exist_len = (pipeline_type_named_name_into(arena, k, nm_scr)));
  __tmp = ({ int32_t __tmp = 0; if (exist_len == name_len && typeck_name_equal(nm_scr, exist_len, name, name_len)) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  (k = (pipeline_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (k <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_init_named_at(arena, k, name, name_len) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return k;
}
int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena * arena, int32_t base_type_ref, uint8_t * field_name, int32_t field_name_len) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_type_ref) || base_type_ref <= 0 || base_type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t bn[64] = { 0 };
  int32_t bn_len = pipeline_type_named_name_into(arena, base_type_ref, (&((bn)[0])));
  (void)(({ int32_t __tmp = 0; if (bn_len <= 0 || bn_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_lexer[5] = { 76, 101, 120, 101, 114 };
  uint8_t nm_next_lex[8] = { 110, 101, 120, 95, 108, 101, 120 };
  uint8_t nm_token_start[11] = { 116, 111, 107, 101, 110, 95, 115, 116, 97, 114, 116 };
  uint8_t nm_lex[3] = { 108, 101, 120 };
  uint8_t nm_pos[3] = { 112, 111, 115 };
  uint8_t nm_line[4] = { 108, 105, 110, 101 };
  uint8_t nm_col[3] = { 99, 111, 108 };
  uint8_t nm_lres[11] = { 76, 101, 120, 101, 114, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_cir[21] = { 67, 111, 108, 108, 101, 99, 116, 73, 109, 112, 111, 114, 116, 115, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_tsar[18] = { 84, 114, 121, 83, 107, 105, 112, 65, 108, 108, 111, 119, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_lpr[19] = { 76, 105, 98, 114, 97, 114, 121, 80, 97, 114, 115, 101, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_per[15] = { 80, 97, 114, 115, 101, 69, 120, 112, 114, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_pbr[16] = { 80, 97, 114, 115, 101, 66, 108, 111, 99, 107, 82, 101, 115, 117, 108, 116 };
  uint8_t nm_tlr[17] = { 84, 111, 112, 76, 101, 118, 101, 108, 76, 101, 116, 82, 101, 115, 117, 108, 116 };
  int32_t lex_tr = typeck_find_or_alloc_named_type_ref(arena, (&((nm_lexer)[0])), 5);
  (void)(({ int32_t __tmp = 0; if (lex_tr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 8 && typeck_name_equal(field_name, field_name_len, (&((nm_next_lex)[0])), 8)) {   (void)(({ int32_t __tmp = 0; if (bn_len == 11 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_lres)[0])), 11)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (bn_len == 19 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_lpr)[0])), 19)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (bn_len == 15 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_per)[0])), 15)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (bn_len == 16 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_pbr)[0])), 16)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (bn_len == 17 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_tlr)[0])), 17)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 11 && typeck_name_equal(field_name, field_name_len, (&((nm_token_start)[0])), 11)) {   __tmp = ({ int32_t __tmp = 0; if (bn_len == 11 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_lres)[0])), 11)) {   return typeck_ensure_usize_type_ref(arena);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 3 && typeck_name_equal(field_name, field_name_len, (&((nm_lex)[0])), 3)) {   (void)(({ int32_t __tmp = 0; if (bn_len == 21 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_cir)[0])), 21)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (bn_len == 18 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_tsar)[0])), 18)) {   return lex_tr;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (bn_len == 5 && typeck_name_equal((&((bn)[0])), bn_len, (&((nm_lexer)[0])), 5)) {   (void)(({ int32_t __tmp = 0; if (field_name_len == 3 && typeck_name_equal(field_name, field_name_len, (&((nm_pos)[0])), 3)) {   return typeck_ensure_usize_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 4 && typeck_name_equal(field_name, field_name_len, (&((nm_line)[0])), 4)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (field_name_len == 3 && typeck_name_equal(field_name, field_name_len, (&((nm_col)[0])), 3)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_ensure_primitive_by_kind_ord(struct ast_ASTArena * arena, int32_t kind_ord) {
  int32_t k = 0;
  int32_t ko = 0;
  int32_t nlen = 0;
  int32_t er = 0;
  int32_t asz = 0;
  uint8_t * nm_scr = typeck_scratch64_slot(11);
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || kind_ord < 0 || kind_ord > 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (k = (1));
  while (k <= (arena)->num_types) {
    (ko = (pipeline_type_kind_ord_at(arena, k)));
    (void)(({ int32_t __tmp = 0; if (ko == kind_ord) {   (nlen = (pipeline_type_named_name_into(arena, k, nm_scr)));
  (er = (pipeline_type_elem_ref_at(arena, k)));
  (asz = (pipeline_type_array_size_at(arena, k)));
  __tmp = ({ int32_t __tmp = 0; if (nlen == 0 && er == 0 && asz == 0) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  (k = (pipeline_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (k <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_init_primitive_kind_at(arena, k, kind_ord) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return k;
}
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 0);
}
int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 2);
}
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 1);
}
int32_t typeck_ensure_f32_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 14);
}
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 15);
}
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena) {
  return typeck_ensure_primitive_by_kind_ord(arena, 6);
}
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a) {
  return typeck_ensure_primitive_by_kind_ord(a, 16);
}
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0 || ctx == ((struct ast_PipelineDepCtx *)(0)) || from_dep_index >= pipeline_dep_ctx_ndep(ctx)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
  (void)(({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   (dep_arena = (pipeline_get_dep_arena_slot(from_dep_index)));
  __tmp = ({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_dep_return_type_to_caller_arena(dep_arena, dep_return_type_ref, caller_arena);
}
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena) {
  return typeck_ensure_primitive_by_kind_ord(caller_arena, 5);
}
int32_t typeck_find_or_alloc_compound_type_ref(struct ast_ASTArena * a, int32_t kind_ord, int32_t elem_ref, int32_t array_size) {
  int32_t k = 0;
  int32_t ko = 0;
  int32_t er = 0;
  int32_t asz = 0;
  int32_t nlen = 0;
  int32_t rlen = 0;
  uint8_t * nm_scr = typeck_scratch64_slot(13);
  (void)(({ int32_t __tmp = 0; if (a == ((struct ast_ASTArena *)(0)) || kind_ord < 0 || kind_ord > 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (k = (1));
  while (k <= (a)->num_types) {
    (ko = (pipeline_type_kind_ord_at(a, k)));
    (void)(({ int32_t __tmp = 0; if (ko == kind_ord) {   (er = (pipeline_type_elem_ref_at(a, k)));
  (asz = (pipeline_type_array_size_at(a, k)));
  (nlen = (pipeline_type_named_name_into(a, k, nm_scr)));
  (rlen = (pipeline_type_region_label_len_at(a, k)));
  __tmp = ({ int32_t __tmp = 0; if (er == elem_ref && asz == array_size && nlen == 0 && rlen == 0) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  (k = (pipeline_arena_type_alloc(a)));
  (void)(({ int32_t __tmp = 0; if (k <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_init_compound_kind_at(a, k, kind_ord, elem_ref, array_size) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return k;
}
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size) {
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_compound_type_ref(a, 10, elem_ref, array_size);
}
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size) {
  int32_t elem_ref = typeck_find_or_alloc_named_type_ref(a, elem_nm, elem_nm_len);
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_array_type_ref(a, elem_ref, array_size);
}
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, enum ast_TypeKind kind) {
  return typeck_ensure_primitive_by_kind_ord(w, ((int32_t)(kind)));
}
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return typeck_find_or_alloc_compound_type_ref(w, 9, elem_ref, 0);
}
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return pipeline_type_find_or_alloc_slice(w, elem_ref, ((uint8_t *)(0)), 0);
}
int32_t typeck_find_or_alloc_linear_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return typeck_find_or_alloc_compound_type_ref(w, 12, elem_ref, 0);
}
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size) {
  return typeck_find_or_alloc_compound_type_ref(w, 13, elem_ref, array_size);
}
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena) {
  int32_t kind = 0;
  int32_t inner_mapped = 0;
  int32_t elem_ref = 0;
  int32_t array_size = 0;
  int32_t nlen = 0;
  uint8_t * nm_buf = typeck_scratch64_slot(0);
  int32_t ord_i32 = 0;
  int32_t ord_bool = 1;
  int32_t ord_u8 = 2;
  int32_t ord_u32 = 3;
  int32_t ord_u64 = 4;
  int32_t ord_i64 = 5;
  int32_t ord_isize = 7;
  int32_t ord_named = 8;
  int32_t ord_ptr = 9;
  int32_t ord_array = 10;
  int32_t ord_slice = 11;
  int32_t ord_linear = 12;
  int32_t ord_vector = 13;
  int32_t ord_f32 = 14;
  int32_t ord_f64 = 15;
  int32_t ord_usize = 6;
  int32_t ord_void = 16;
  (void)(({ int32_t __tmp = 0; if (dep_return_type_ref <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (kind = (pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref)));
  (void)(({ int32_t __tmp = 0; if (kind < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_i32 || kind == ord_i64 || kind == ord_bool || kind == ord_f64 || kind == ord_u8 || kind == ord_u32 || kind == ord_u64 || kind == ord_isize || kind == ord_f32 || kind == ord_usize || kind == ord_void) {   return typeck_ensure_primitive_by_kind_ord(caller_arena, kind);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_named) {   (nlen = (pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm_buf)));
  (void)(({ int32_t __tmp = 0; if (nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_named_type_ref(caller_arena, nm_buf, nlen);
 } else (__tmp = 0) ; __tmp; }));
  (elem_ref = (pipeline_type_elem_ref_at(dep_arena, dep_return_type_ref)));
  (inner_mapped = (0));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(elem_ref))) {   (inner_mapped = (typeck_dep_return_type_to_caller_arena(dep_arena, elem_ref, caller_arena)));
  __tmp = ({ int32_t __tmp = 0; if (inner_mapped == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (array_size = (pipeline_type_array_size_at(dep_arena, dep_return_type_ref)));
  (void)(({ int32_t __tmp = 0; if (kind == ord_slice) {   int32_t rlen = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
  uint8_t * rbuf = typeck_scratch64_slot(14);
  (void)(({ int32_t __tmp = 0; if (rlen > 0) {   (void)(pipeline_type_region_label_into(dep_arena, dep_return_type_ref, rbuf));
 } else (__tmp = 0) ; __tmp; }));
  return pipeline_type_find_or_alloc_slice(caller_arena, inner_mapped, rbuf, rlen);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_ptr) {   return typeck_find_or_alloc_ptr_type_ref(caller_arena, inner_mapped);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_linear) {   return typeck_find_or_alloc_linear_type_ref(caller_arena, inner_mapped);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_vector) {   return typeck_find_or_alloc_vector_type_ref(caller_arena, inner_mapped, array_size);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_array) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(elem_ref) || array_size <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_array_type_ref(caller_arena, inner_mapped, array_size);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(elem_ref)) || array_size != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (nlen = (pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm_buf)));
  (void)(({ int32_t __tmp = 0; if (nlen != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_ensure_primitive_by_kind_ord(caller_arena, kind);
}
int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len) {
  (void)(({ int32_t __tmp = 0; if (field_name_len >= 4) {   int32_t br = field_name_len - 4;
  __tmp = ({ int32_t __tmp = 0; if ((field_name)[br] == 95 && (field_name)[br + 1] == 114 && (field_name)[br + 2] == 101 && (field_name)[br + 3] == 102) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_match_num_arms[14] = { 109, 97, 116, 99, 104, 95, 110, 117, 109, 95, 97, 114, 109, 115 };
  uint8_t nm_field_access_is_enum_variant[28] = { 102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 105, 115, 95, 101, 110, 117, 109, 95, 118, 97, 114, 105, 97, 110, 116 };
  uint8_t nm_field_access_field_len[22] = { 102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 102, 105, 101, 108, 100, 95, 108, 101, 110 };
  uint8_t nm_field_access_offset[19] = { 102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 111, 102, 102, 115, 101, 116 };
  uint8_t nm_index_base_is_slice[19] = { 105, 110, 100, 101, 120, 95, 98, 97, 115, 101, 95, 105, 115, 95, 115, 108, 105, 99, 101 };
  uint8_t nm_call_num_args[13] = { 99, 97, 108, 108, 95, 110, 117, 109, 95, 97, 114, 103, 115 };
  uint8_t nm_method_call_name_len[20] = { 109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 97, 109, 101, 95, 108, 101, 110 };
  uint8_t nm_method_call_num_args[20] = { 109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 117, 109, 95, 97, 114, 103, 115 };
  uint8_t nm_const_folded_val[16] = { 99, 111, 110, 115, 116, 95, 102, 111, 108, 100, 101, 100, 95, 118, 97, 108 };
  uint8_t nm_const_folded_valid[18] = { 99, 111, 110, 115, 116, 95, 102, 111, 108, 100, 101, 100, 95, 118, 97, 108, 105, 100 };
  uint8_t nm_index_proven_in_bounds[22] = { 105, 110, 100, 101, 120, 95, 112, 114, 111, 118, 101, 110, 95, 105, 110, 95, 98, 111, 117, 110, 100, 115 };
  uint8_t nm_call_resolved_func_index[24] = { 99, 97, 108, 108, 95, 114, 101, 115, 111, 108, 118, 101, 100, 95, 102, 117, 110, 99, 95, 105, 110, 100, 101, 120 };
  uint8_t nm_call_resolved_dep_index[22] = { 99, 97, 108, 108, 95, 114, 101, 115, 111, 108, 118, 101, 100, 95, 100, 101, 112, 95, 105, 110, 100, 101, 120 };
  uint8_t nm_enum_variant_tag[16] = { 101, 110, 117, 109, 95, 118, 97, 114, 105, 97, 110, 116, 95, 116, 97, 103 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 14 && typeck_name_equal(field_name, field_name_len, (&((nm_match_num_arms)[0])), 14)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 28 && typeck_name_equal(field_name, field_name_len, (&((nm_field_access_is_enum_variant)[0])), 28)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 22 && typeck_name_equal(field_name, field_name_len, (&((nm_field_access_field_len)[0])), 22)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 19 && typeck_name_equal(field_name, field_name_len, (&((nm_field_access_offset)[0])), 19)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 19 && typeck_name_equal(field_name, field_name_len, (&((nm_index_base_is_slice)[0])), 19)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 13 && typeck_name_equal(field_name, field_name_len, (&((nm_call_num_args)[0])), 13)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 20 && typeck_name_equal(field_name, field_name_len, (&((nm_method_call_name_len)[0])), 20)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 20 && typeck_name_equal(field_name, field_name_len, (&((nm_method_call_num_args)[0])), 20)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 16 && typeck_name_equal(field_name, field_name_len, (&((nm_const_folded_val)[0])), 16)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 18 && typeck_name_equal(field_name, field_name_len, (&((nm_const_folded_valid)[0])), 18)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 22 && typeck_name_equal(field_name, field_name_len, (&((nm_index_proven_in_bounds)[0])), 22)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 24 && typeck_name_equal(field_name, field_name_len, (&((nm_call_resolved_func_index)[0])), 24)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 22 && typeck_name_equal(field_name, field_name_len, (&((nm_call_resolved_dep_index)[0])), 22)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 16 && typeck_name_equal(field_name, field_name_len, (&((nm_enum_variant_tag)[0])), 16)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  uint8_t nm_funcs_pool[5] = { 102, 117, 110, 99, 115 };
  uint8_t nm_func_elem[4] = { 70, 117, 110, 99 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 5 && typeck_name_equal(field_name, field_name_len, (&((nm_funcs_pool)[0])), 5)) {   int32_t arr_funcs_pool = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_func_elem)[0])), 4, 256);
  __tmp = ({ int32_t __tmp = 0; if (arr_funcs_pool != 0) {   return arr_funcs_pool;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_struct_layouts_pool[14] = { 115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115 };
  uint8_t nm_sl_elem[12] = { 83, 116, 114, 117, 99, 116, 76, 97, 121, 111, 117, 116 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 14 && typeck_name_equal(field_name, field_name_len, (&((nm_struct_layouts_pool)[0])), 14)) {   int32_t arr_sl_pool = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_sl_elem)[0])), 12, 32);
  __tmp = ({ int32_t __tmp = 0; if (arr_sl_pool != 0) {   return arr_sl_pool;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_num_struct_layouts_pool[18] = { 110, 117, 109, 95, 115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 18 && typeck_name_equal(field_name, field_name_len, (&((nm_num_struct_layouts_pool)[0])), 18)) {   return typeck_ensure_i32_type_ref(arena);
 } else (__tmp = 0) ; __tmp; }));
  int32_t u8_inline = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (u8_inline != 0) {   return u8_inline;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i32_arr_inline = typeck_expr_inline_array_field_type_ref(arena, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (i32_arr_inline != 0) {   return i32_arr_inline;
 } else (__tmp = 0) ; __tmp; }));
  int32_t r = typeck_get_field_type_ref_from_layout(module, type_name, type_name_len, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (r != 0) {   return r;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nd2 = pipeline_dep_ctx_ndep(ctx);
  int32_t di = 0;
  while (di < nd2) {
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, di);
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (r = (typeck_get_field_type_ref_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r != 0) {   struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, di);
  (void)(({ int32_t __tmp = 0; if (da != ((struct ast_ASTArena *)(0))) {   return typeck_dep_return_type_to_caller_arena(da, r, arena);
 } else (__tmp = 0) ; __tmp; }));
  return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  (void)(({ int32_t __tmp = 0; if (type_name_len == 4 && (type_name)[0] == 69 && (type_name)[1] == 120 && (type_name)[2] == 112 && (type_name)[3] == 114) {   int32_t u8_fb = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (u8_fb != 0) {   return u8_fb;
 } else (__tmp = 0) ; __tmp; }));
  int32_t arr_fb = typeck_expr_inline_array_field_type_ref(arena, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (arr_fb != 0) {   return arr_fb;
 } else (__tmp = 0) ; __tmp; }));
  int32_t fb = typeck_expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
  __tmp = ({ int32_t __tmp = 0; if (fb != 0) {   return fb;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_name_len == 4 && (type_name)[0] == 84 && (type_name)[1] == 121 && (type_name)[2] == 112 && (type_name)[3] == 101) {   int32_t u8_ty = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
  __tmp = ({ int32_t __tmp = 0; if (u8_ty != 0) {   return u8_ty;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_name_len == 4 && (type_name)[0] == 70 && (type_name)[1] == 117 && (type_name)[2] == 110 && (type_name)[3] == 99) {   int32_t u8_fn = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (u8_fn != 0) {   return u8_fn;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_params[6] = { 112, 97, 114, 97, 109, 115 };
  uint8_t nm_pa[5] = { 80, 97, 114, 97, 109 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 6 && typeck_name_equal(field_name, field_name_len, (&((nm_params)[0])), 6)) {   return typeck_ensure_array_type_ref_named_elem(arena, (&((nm_pa)[0])), 5, 16);
 } else (__tmp = 0) ; __tmp; }));
  int32_t fb_fn = typeck_expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
  __tmp = ({ int32_t __tmp = 0; if (fb_fn != 0) {   return fb_fn;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_name_len == 5 && (type_name)[0] == 80 && (type_name)[1] == 97 && (type_name)[2] == 114 && (type_name)[3] == 97 && (type_name)[4] == 109) {   uint8_t nm_pname[4] = { 110, 97, 109, 101 };
  __tmp = ({ int32_t __tmp = 0; if (field_name_len == 4 && typeck_name_equal(field_name, field_name_len, (&((nm_pname)[0])), 4)) {   int32_t u8r_p = typeck_ensure_u8_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (u8r_p != 0) {   return typeck_find_or_alloc_array_type_ref(arena, u8r_p, 32);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_name_len == 12 && (type_name)[0] == 83 && (type_name)[1] == 116 && (type_name)[2] == 114 && (type_name)[3] == 117 && (type_name)[4] == 99 && (type_name)[5] == 116 && (type_name)[6] == 76 && (type_name)[7] == 97 && (type_name)[8] == 121 && (type_name)[9] == 111 && (type_name)[10] == 117 && (type_name)[11] == 116) {   int32_t u8r_sl = typeck_ensure_u8_type_ref(arena);
  int32_t i32r_sl = typeck_ensure_i32_type_ref(arena);
  uint8_t nm_sl_name[4] = { 110, 97, 109, 101 };
  uint8_t nm_sl_field_names[11] = { 102, 105, 101, 108, 100, 95, 110, 97, 109, 101, 115 };
  uint8_t nm_sl_field_lens[11] = { 102, 105, 101, 108, 100, 95, 108, 101, 110, 115 };
  uint8_t nm_sl_field_offsets[13] = { 102, 105, 101, 108, 100, 95, 111, 102, 102, 115, 101, 116, 115 };
  uint8_t nm_sl_field_type_refs[15] = { 102, 105, 101, 108, 100, 95, 116, 121, 112, 101, 95, 114, 101, 102, 115 };
  uint8_t nm_sl_num_fields[10] = { 110, 117, 109, 95, 102, 105, 101, 108, 100, 115 };
  uint8_t nm_sl_allow_padding[14] = { 97, 108, 108, 111, 119, 95, 112, 97, 100, 100, 105, 110, 103 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 4 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_name)[0])), 4) && u8r_sl != 0) {   return typeck_find_or_alloc_array_type_ref(arena, u8r_sl, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 11 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_field_names)[0])), 11) && u8r_sl != 0) {   int32_t row_u8 = typeck_find_or_alloc_array_type_ref(arena, u8r_sl, 64);
  __tmp = ({ int32_t __tmp = 0; if (row_u8 != 0) {   return typeck_find_or_alloc_array_type_ref(arena, row_u8, 64);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 11 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_field_lens)[0])), 11) && i32r_sl != 0) {   return typeck_find_or_alloc_array_type_ref(arena, i32r_sl, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 13 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_field_offsets)[0])), 13) && i32r_sl != 0) {   return typeck_find_or_alloc_array_type_ref(arena, i32r_sl, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 15 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_field_type_refs)[0])), 15) && i32r_sl != 0) {   return typeck_find_or_alloc_array_type_ref(arena, i32r_sl, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 10 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_num_fields)[0])), 10)) {   return i32r_sl;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 14 && typeck_name_equal(field_name, field_name_len, (&((nm_sl_allow_padding)[0])), 14)) {   return i32r_sl;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (field_name_len == 8 && (field_name)[0] == 110 && (field_name)[1] == 97 && (field_name)[2] == 109 && (field_name)[3] == 101 && (field_name)[4] == 95 && (field_name)[5] == 108 && (field_name)[6] == 101 && (field_name)[7] == 110) {   return i32r_sl;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_inline_u8_64_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len) {
  int32_t u8r = typeck_ensure_u8_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (u8r == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_name[4] = { 110, 97, 109, 101 };
  uint8_t nm_var_name[8] = { 118, 97, 114, 95, 110, 97, 109, 101 };
  uint8_t nm_field_access_field_name[22] = { 102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 102, 105, 101, 108, 100, 95, 110, 97, 109, 101 };
  uint8_t nm_method_call_name[16] = { 109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 97, 109, 101 };
  uint8_t nm_struct_lit_struct_name[22] = { 115, 116, 114, 117, 99, 116, 95, 108, 105, 116, 95, 115, 116, 114, 117, 99, 116, 95, 110, 97, 109, 101 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 4 && typeck_name_equal(field_name, field_name_len, (&((nm_name)[0])), 4)) {   return typeck_find_or_alloc_array_type_ref(arena, u8r, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 8 && typeck_name_equal(field_name, field_name_len, (&((nm_var_name)[0])), 8)) {   return typeck_find_or_alloc_array_type_ref(arena, u8r, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 22 && typeck_name_equal(field_name, field_name_len, (&((nm_field_access_field_name)[0])), 22)) {   return typeck_find_or_alloc_array_type_ref(arena, u8r, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 16 && typeck_name_equal(field_name, field_name_len, (&((nm_method_call_name)[0])), 16)) {   return typeck_find_or_alloc_array_type_ref(arena, u8r, 64);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 22 && typeck_name_equal(field_name, field_name_len, (&((nm_struct_lit_struct_name)[0])), 22)) {   return typeck_find_or_alloc_array_type_ref(arena, u8r, 64);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_expr_inline_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len) {
  int32_t i32r = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (i32r == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_call_arg_refs[13] = { 99, 97, 108, 108, 95, 97, 114, 103, 95, 114, 101, 102, 115 };
  uint8_t nm_method_call_arg_refs[20] = { 109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 97, 114, 103, 95, 114, 101, 102, 115 };
  uint8_t nm_match_arm_result_refs[21] = { 109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 114, 101, 115, 117, 108, 116, 95, 114, 101, 102, 115 };
  uint8_t nm_array_lit_elem_refs[19] = { 97, 114, 114, 97, 121, 95, 108, 105, 116, 95, 101, 108, 101, 109, 95, 114, 101, 102, 115 };
  uint8_t nm_match_arm_is_wildcard[21] = { 109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 105, 115, 95, 119, 105, 108, 100, 99, 97, 114, 100 };
  uint8_t nm_match_arm_lit_val[17] = { 109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 108, 105, 116, 95, 118, 97, 108 };
  uint8_t nm_match_arm_is_enum_variant[25] = { 109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 105, 115, 95, 101, 110, 117, 109, 95, 118, 97, 114, 105, 97, 110, 116 };
  uint8_t nm_match_arm_variant_index[23] = { 109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 118, 97, 114, 105, 97, 110, 116, 95, 105, 110, 100, 101, 120 };
  (void)(({ int32_t __tmp = 0; if (field_name_len == 13 && typeck_name_equal(field_name, field_name_len, (&((nm_call_arg_refs)[0])), 13)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 20 && typeck_name_equal(field_name, field_name_len, (&((nm_method_call_arg_refs)[0])), 20)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 21 && typeck_name_equal(field_name, field_name_len, (&((nm_match_arm_result_refs)[0])), 21)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 19 && typeck_name_equal(field_name, field_name_len, (&((nm_array_lit_elem_refs)[0])), 19)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 21 && typeck_name_equal(field_name, field_name_len, (&((nm_match_arm_is_wildcard)[0])), 21)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 17 && typeck_name_equal(field_name, field_name_len, (&((nm_match_arm_lit_val)[0])), 17)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 25 && typeck_name_equal(field_name, field_name_len, (&((nm_match_arm_is_enum_variant)[0])), 25)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (field_name_len == 23 && typeck_name_equal(field_name, field_name_len, (&((nm_match_arm_variant_index)[0])), 23)) {   return typeck_find_or_alloc_array_type_ref(arena, i32r, 16);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen) {
  return typeck_find_layout_idx_by_type_name(mod, nm, nlen);
}
void typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t nd_merge = 0;
  int32_t di = 0;
  struct ast_Module * dm = ((struct ast_Module *)(0));
  struct ast_ASTArena * darena = ((struct ast_ASTArena *)(0));
  int32_t k = 0;
  int32_t nl = 0;
  int32_t nf_dep = 0;
  int32_t ex = 0;
  int32_t need = 0;
  int weak_entry = 0;
  int is_expr_nm = 0;
  int32_t ni = 0;
  int32_t j = 0;
  int32_t raw_fr = 0;
  int32_t mapped = 0;
  int32_t fnlen = 0;
  int32_t foff = 0;
  int32_t ndm_sl = 0;
  uint8_t * dep_nm_buf = typeck_scratch64_slot(9);
  uint8_t * fn_buf = typeck_scratch64_slot(10);
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (nd_merge = (pipeline_dep_ctx_ndep(ctx)));
  (di = (0));
  while (di < nd_merge) {
    (dm = (pipeline_dep_ctx_module_at(ctx, di)));
    (darena = (pipeline_dep_ctx_arena_at(ctx, di)));
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0)) || darena == ((struct ast_ASTArena *)(0))) {   ++di;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (ndm_sl = (pipeline_module_num_struct_layouts_at(dm)));
    (k = (0));
    while (k < ndm_sl) {
      (nl = (pipeline_module_struct_layout_name_len(dm, k)));
      (void)(({ int32_t __tmp = 0; if (nl > 0 && nl <= 63) {   (nf_dep = (pipeline_module_struct_layout_num_fields(dm, k)));
  (void)(({ int32_t __tmp = 0; if (nf_dep > 64) {   (nf_dep = (64));
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_name_into(dm, k, dep_nm_buf));
  (ex = (typeck_entry_module_find_struct_layout_index(mod, dep_nm_buf, nl)));
  (need = (0));
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   (need = (1));
 } else {   (weak_entry = (0));
  (void)(({ int __tmp = 0; if (pipeline_module_struct_layout_num_fields(mod, ex) >= 2 && pipeline_module_struct_layout_field_type_ref(mod, ex, 1) == 0) {   (weak_entry = (1));
 } else (__tmp = 0) ; __tmp; }));
  (is_expr_nm = (0));
  (void)(({ int __tmp = 0; if (nl == 4) {   __tmp = ({ int __tmp = 0; if (pipeline_module_struct_layout_name_byte_at(dm, k, 0) == 69 && pipeline_module_struct_layout_name_byte_at(dm, k, 1) == 120 && pipeline_module_struct_layout_name_byte_at(dm, k, 2) == 112 && pipeline_module_struct_layout_name_byte_at(dm, k, 3) == 114) {   (is_expr_nm = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nf_dep > pipeline_module_struct_layout_num_fields(mod, ex) || weak_entry || is_expr_nm) {   (need = (1));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (pipeline_module_struct_layout_soa_at(dm, k) != 0 && pipeline_module_struct_layout_soa_at(mod, ex) == 0) {   (need = (1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (need != 0) {   (ni = (ex));
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   (ni = (pipeline_module_struct_layout_alloc(mod)));
  __tmp = ({ int32_t __tmp = 0; if (ni < 0) {   ++k;
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_reset_slot(mod, ni));
  (void)(pipeline_module_struct_layout_set_name(mod, ni, dep_nm_buf, nl));
  (j = (0));
  while (j < nf_dep) {
    (raw_fr = (pipeline_module_struct_layout_field_type_ref(dm, k, j)));
    (mapped = (0));
    (void)(({ int32_t __tmp = 0; if (raw_fr != 0) {   (mapped = (typeck_dep_return_type_to_caller_arena(darena, raw_fr, arena)));
 } else (__tmp = 0) ; __tmp; }));
    (fnlen = (pipeline_module_struct_layout_field_name_len(dm, k, j)));
    (void)(pipeline_module_struct_layout_field_name_into(dm, k, j, fn_buf));
    (foff = (pipeline_module_struct_layout_field_offset_at(dm, k, j)));
    (void)(pipeline_module_struct_layout_set_field(mod, ni, j, fn_buf, fnlen, mapped, foff));
    (void)(pipeline_module_struct_layout_set_field_align(mod, ni, j, pipeline_module_struct_layout_field_align_at(dm, k, j)));
    ++j;
  }
  (void)(pipeline_module_struct_layout_set_num_fields(mod, ni, nf_dep));
  (void)(pipeline_module_struct_layout_set_allow_padding(mod, ni, pipeline_module_struct_layout_allow_padding_at(dm, k)));
  (void)(pipeline_module_struct_layout_set_soa(mod, ni, pipeline_module_struct_layout_soa_at(dm, k)));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
      ++k;
    }
    ++di;
  }
}
void typeck_wpo_unify_soa_layouts(struct ast_Module * entry, struct ast_PipelineDepCtx * ctx) {
  int32_t nd = 0;
  int32_t mi = 0;
  struct ast_Module * dm = ((struct ast_Module *)(0));
  int32_t nsl = 0;
  int32_t k = 0;
  int32_t nl = 0;
  int32_t any_soa = 0;
  int32_t mj = 0;
  struct ast_Module * dm2 = ((struct ast_Module *)(0));
  int32_t nsl2 = 0;
  int32_t k2 = 0;
  int32_t nl2 = 0;
  int32_t li = 0;
  uint8_t * nm_buf = typeck_scratch64_slot(11);
  uint8_t * nm2 = typeck_scratch64_slot(12);
  (void)(({ int32_t __tmp = 0; if (entry == ((struct ast_Module *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (nd = (pipeline_dep_ctx_ndep(ctx)));
  (mi = ((-1)));
  while (mi < nd) {
    (dm = (entry));
    (void)(({ struct ast_Module * __tmp = (struct ast_Module *){0}; if (mi >= 0) {   (dm = (pipeline_dep_ctx_module_at(ctx, mi)));
 } else (__tmp = (struct ast_Module *){0}) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   ++mi;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (nsl = (pipeline_module_num_struct_layouts_at(dm)));
    (k = (0));
    while (k < nsl) {
      (nl = (pipeline_module_struct_layout_name_len(dm, k)));
      (void)(({ int32_t __tmp = 0; if (nl > 0 && nl <= 63) {   (void)(pipeline_module_struct_layout_name_into(dm, k, nm_buf));
  (any_soa = (pipeline_module_struct_layout_soa_at(dm, k)));
  (mj = ((-1)));
  while (mj < nd && any_soa == 0) {
    (dm2 = (entry));
    (void)(({ struct ast_Module * __tmp = (struct ast_Module *){0}; if (mj >= 0) {   (dm2 = (pipeline_dep_ctx_module_at(ctx, mj)));
 } else (__tmp = (struct ast_Module *){0}) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (dm2 != ((struct ast_Module *)(0))) {   (nsl2 = (pipeline_module_num_struct_layouts_at(dm2)));
  (k2 = (0));
  while (k2 < nsl2 && any_soa == 0) {
    (nl2 = (pipeline_module_struct_layout_name_len(dm2, k2)));
    (void)(({ int32_t __tmp = 0; if (nl2 == nl) {   (void)(pipeline_module_struct_layout_name_into(dm2, k2, nm2));
  __tmp = ({ int32_t __tmp = 0; if (typeck_name_equal(nm_buf, nl, nm2, nl2) && pipeline_module_struct_layout_soa_at(dm2, k2) != 0) {   (any_soa = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k2;
  }
 } else (__tmp = 0) ; __tmp; }));
    ++mj;
  }
  __tmp = ({ int32_t __tmp = 0; if (any_soa != 0) {   (mj = ((-1)));
  while (mj < nd) {
    (dm2 = (entry));
    (void)(({ struct ast_Module * __tmp = (struct ast_Module *){0}; if (mj >= 0) {   (dm2 = (pipeline_dep_ctx_module_at(ctx, mj)));
 } else (__tmp = (struct ast_Module *){0}) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (dm2 != ((struct ast_Module *)(0))) {   (li = (typeck_find_layout_idx_by_type_name(dm2, nm_buf, nl)));
  __tmp = ({ int32_t __tmp = 0; if (li >= 0 && pipeline_module_struct_layout_soa_at(dm2, li) == 0) {   (void)(pipeline_module_struct_layout_set_soa(dm2, li, 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++mj;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
      ++k;
    }
    ++mi;
  }
}
int32_t typeck_resolve_scan_dep_with_apply(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax, int32_t want_apply) {
  struct ast_Module * dm = ((struct ast_Module *)(0));
  int32_t ret = 0;
  int32_t * fn_slot = typeck_call_resolve_func_idx_slot();
  (void)(({ int32_t __tmp = 0; if (dep_i >= imax) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (dm = (pipeline_dep_ctx_module_at(ctx, dep_i)));
  (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)(typeck_i32_ptr_store(fn_slot, 0));
  (ret = (typeck_find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, dep_i, ctx, fn_slot)));
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_apply != 0) {   (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, dep_i, typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (dep_i < (module)->num_imports) {   (ret = (typeck_resolve_call_select_import_return_type(module, arena, callee_expr_ref, callee_ord, dep_i, ctx, fn_slot)));
  __tmp = ({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_apply != 0) {   (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, dep_i, typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_resolve_scan_dep_with_apply(module, arena, callee_expr_ref, callee_ord, call_expr_ref, ctx, dep_i + 1, imax, want_apply);
}
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  int32_t j = 0;
  while (j < (mod)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (typeck_expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j)) {   (void)(({ int32_t __tmp = 0; if (func_index_out != ((int32_t *)(0))) {   ((func_index_out)[0] = (j));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_dep = pipeline_module_func_return_type_at(mod, j);
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return ret_dep;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, ret_dep, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  return 0;
}
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < (mod)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {   (void)(({ int32_t __tmp = 0; if (func_index_out != ((int32_t *)(0))) {   ((func_index_out)[0] = (j));
 } else (__tmp = 0) ; __tmp; }));
  int32_t rtr = pipeline_module_func_return_type_at(mod, j);
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return rtr;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, rtr, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  return 0;
}
int32_t typeck_import_path_segment_count(uint8_t * path, int32_t path_len) {
  (void)(({ int32_t __tmp = 0; if (path_len <= 0 || path == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t n = 1;
  int32_t ii = 0;
  while (ii < path_len) {
    uint8_t ch_u8 = (path)[ii];
    (void)(({ int32_t __tmp = 0; if (ch_u8 == 46) {   ++n;
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
  return n;
}
int typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {
  (void)(({ int __tmp = 0; if (module == ((struct ast_Module *)(0)) || imp_ix < 0 || imp_ix >= (module)->num_imports) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t pl = pipeline_module_import_path_len(module, imp_ix);
  (void)(({ int __tmp = 0; if (pl <= 0 || pl > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ci = 0;
  int32_t ss = 0;
  int32_t k = 0;
  while (k <= pl) {
    int at_end_p = k == pl;
    int dot_p = 0;
    (void)(({ int __tmp = 0; if ((!at_end_p) && k < pl) {   (dot_p = (pipeline_module_import_path_byte_at(module, imp_ix, k) == 46));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (at_end_p || dot_p) {   int32_t seg_len_here = k - ss;
  (void)(({ int __tmp = 0; if (seg_len_here <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ci == want_seg) {   ((ostr)[0] = (ss));
  ((olen)[0] = (seg_len_here));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dot_p) {   (ss = (k + 1));
 } else (__tmp = 0) ; __tmp; }));
  ++ci;
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out) {
  int32_t ord_field = 44;
  int32_t ord_var = 3;
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs || module == ((struct ast_Module *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ord_field) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t layer_buf[64] = { 0 };
  (void)(asm_qual_sym_layer_reset());
  int32_t nstack = 0;
  int32_t cur_ref = callee_expr_ref;
  while (1) {
    (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    int32_t falen = pipeline_expr_field_access_name_len(arena, cur_ref);
    (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_field || falen <= 0 || falen > 63) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_expr_field_access_name_into(arena, cur_ref, (&((layer_buf)[0]))));
    (void)(({ int32_t __tmp = 0; if (asm_qual_sym_layer_push((&((layer_buf)[0])), falen) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++nstack;
    (cur_ref = (pipeline_expr_field_access_base_ref(arena, cur_ref)));
  }
  (nstack = (asm_qual_sym_layer_count()));
  (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t vnlen = pipeline_expr_var_name_len(arena, cur_ref);
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_var || vnlen <= 0 || vnlen > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t vname_buf[64] = { 0 };
  (void)(pipeline_expr_var_name_into(arena, cur_ref, (&((vname_buf)[0]))));
  int32_t dep_j = 0;
  while (dep_j < (module)->num_imports) {
    int32_t plen = pipeline_module_import_path_len(module, dep_j);
    (void)(({ int32_t __tmp = 0; if (plen <= 0 || plen > 63) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t path_cnt_buf[64] = { 0 };
    int32_t pci = 0;
    while (pci < plen && pci < 64) {
      ((pci < 0 || (pci) >= 64 ? (shux_panic_(1, 0), 0) : ((path_cnt_buf)[pci] = pipeline_module_import_path_byte_at(module, dep_j, pci), 0)));
      ++pci;
    }
    int32_t Pseg = typeck_import_path_segment_count((&((path_cnt_buf)[0])), plen);
    (void)(({ int32_t __tmp = 0; if (Pseg <= 0 || nstack != Pseg) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t s0_rel = 0;
    int32_t s0_ln = 0;
    (void)(({ int32_t __tmp = 0; if ((!typeck_import_segment_at(module, dep_j, 0, (&(s0_rel)), (&(s0_ln))))) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!typeck_import_path_slice_equal(module, dep_j, s0_rel, s0_ln, (&((vname_buf)[0])), vnlen))) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int bad_mid = 0;
    int32_t sm = 1;
    while (sm <= Pseg - 1) {
      int32_t srv = 0;
      int32_t slv = 0;
      (void)(({ int __tmp = 0; if ((!typeck_import_segment_at(module, dep_j, sm, (&(srv)), (&(slv))))) {   (bad_mid = (1));
 } else {   int32_t lay_ix = Pseg - sm;
  (void)(asm_qual_sym_layer_copy(lay_ix, (&((layer_buf)[0])), 64));
  __tmp = ({ int __tmp = 0; if ((!typeck_import_path_slice_equal(module, dep_j, srv, slv, (&((layer_buf)[0])), asm_qual_sym_layer_len(lay_ix)))) {   (bad_mid = (1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (bad_mid) {   break;
 } else (__tmp = 0) ; __tmp; }));
      ++sm;
    }
    (void)(({ int32_t __tmp = 0; if (bad_mid) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, dep_j);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   ++dep_j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(asm_qual_sym_layer_copy(0, (&((layer_buf)[0])), 64));
    int32_t ret_fn = typeck_find_func_return_type_in_module_by_name(dm, arena, (&((layer_buf)[0])), asm_qual_sym_layer_len(0), dep_j, ctx, func_index_out);
    (void)(({ int32_t __tmp = 0; if (ret_fn != 0) {   __tmp = ({ int32_t __tmp = 0; if (dep_index_out != ((int32_t *)(0))) {   (void)(typeck_i32_ptr_store(dep_index_out, dep_j));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    return ret_fn;
  }
  return 0;
}
int32_t typeck_resolve_call_binding_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out) {
  int32_t ord_field = 44;
  int32_t ord_var = 3;
  int32_t ord_import_binding = 1;
  int32_t base_bind_ref = 0;
  int32_t base_bind_len = 0;
  int32_t field_len = 0;
  int32_t ii = 0;
  int32_t ret_b = 0;
  struct ast_Module * dm = ((struct ast_Module *)(0));
  int32_t import_kind = 0;
  uint8_t base_bind_nm[64] = { 0 };
  uint8_t field_nm[64] = { 0 };
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs || module == ((struct ast_Module *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ord_field) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (base_bind_ref = (pipeline_expr_field_access_base_ref(arena, callee_expr_ref)));
  (void)(({ int32_t __tmp = 0; if (base_bind_ref <= 0 || base_bind_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, base_bind_ref) != ord_var) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (base_bind_len = (pipeline_expr_var_name_len(arena, base_bind_ref)));
  (void)(({ int32_t __tmp = 0; if (base_bind_len <= 0 || base_bind_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_var_name_into(arena, base_bind_ref, (&((base_bind_nm)[0]))));
  (field_len = (pipeline_expr_field_access_name_len(arena, callee_expr_ref)));
  (void)(pipeline_expr_field_access_name_into(arena, callee_expr_ref, (&((field_nm)[0]))));
  (ii = (0));
  while (ii < (module)->num_imports) {
    (import_kind = (pipeline_module_import_kind_at(module, ii)));
    (void)(({ int32_t __tmp = 0; if (import_kind == ord_import_binding && typeck_import_binding_name_equal(module, ii, (&((base_bind_nm)[0])), base_bind_len)) {   (dm = (pipeline_dep_ctx_module_at(ctx, ii)));
  (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (ret_b = (typeck_find_func_return_type_in_module_by_name(dm, arena, (&((field_nm)[0])), field_len, ii, ctx, func_index_out)));
  __tmp = ({ int32_t __tmp = 0; if (ret_b != 0) {   (void)(({ int32_t __tmp = 0; if (dep_index_out != ((int32_t *)(0))) {   (void)(typeck_i32_ptr_store(dep_index_out, ii));
 } else (__tmp = 0) ; __tmp; }));
  return ret_b;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
  return 0;
}
int32_t typeck_resolve_call_select_import_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, int32_t dep_ix, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  int32_t ord_var = 3;
  int32_t ord_import_select = 2;
  int32_t cv_len = 0;
  int32_t k = 0;
  int32_t sel_cnt = 0;
  int32_t import_kind = 0;
  struct ast_Module * dm = ((struct ast_Module *)(0));
  uint8_t cv_nm[64] = { 0 };
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_ix < 0 || dep_ix >= (module)->num_imports || callee_ord != ord_var) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (import_kind = (pipeline_module_import_kind_at(module, dep_ix)));
  (void)(({ int32_t __tmp = 0; if (import_kind != ord_import_select) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (cv_len = (pipeline_expr_var_name_len(arena, callee_expr_ref)));
  (void)(({ int32_t __tmp = 0; if (cv_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_var_name_into(arena, callee_expr_ref, (&((cv_nm)[0]))));
  (dm = (pipeline_dep_ctx_module_at(ctx, dep_ix)));
  (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (sel_cnt = (pipeline_module_import_select_count_at(module, dep_ix)));
  (k = (0));
  while (k < sel_cnt) {
    (void)(({ int32_t __tmp = 0; if (typeck_import_select_name_equal(module, dep_ix, k, (&((cv_nm)[0])), cv_len)) {   return typeck_find_func_return_type_in_module_by_name(dm, arena, (&((cv_nm)[0])), cv_len, dep_ix, ctx, func_index_out);
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t typeck_resolve_call_callee_try_whole_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord) {
  int32_t ord_field = 44;
  int32_t * null_po = ((int32_t *)(0));
  (void)(({ int32_t __tmp = 0; if (callee_ord != ord_field) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx, null_po, null_po);
}
int32_t typeck_resolve_call_callee_try_binding_import(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t callee_ord) {
  int32_t ord_field = 44;
  int32_t * null_po = ((int32_t *)(0));
  (void)(({ int32_t __tmp = 0; if (callee_ord != ord_field) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_resolve_call_binding_import_return_type(module, arena, callee_expr_ref, ctx, null_po, null_po);
}
int32_t typeck_resolve_call_callee_local_module(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t minus_one = -1;
  return typeck_find_func_return_type_in_module(module, arena, arena, arena, callee_expr_ref, minus_one, ctx, ((int32_t *)(0)));
}
int32_t typeck_resolve_call_callee_scan_dep(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t callee_ord, struct ast_PipelineDepCtx * ctx, int32_t dep_i, int32_t imax) {
  struct ast_Module * dm = ((struct ast_Module *)(0));
  int32_t ret = 0;
  int32_t * null_po = ((int32_t *)(0));
  (void)(({ int32_t __tmp = 0; if (dep_i >= imax) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (dm = (pipeline_dep_ctx_module_at(ctx, dep_i)));
  (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (ret = (typeck_find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, dep_i, ctx, null_po)));
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   return ret;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (dep_i < (module)->num_imports) {   (ret = (typeck_resolve_call_select_import_return_type(module, arena, callee_expr_ref, callee_ord, dep_i, ctx, null_po)));
  __tmp = ({ int32_t __tmp = 0; if (ret != 0) {   return ret;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_resolve_call_callee_scan_dep(module, arena, callee_expr_ref, callee_ord, ctx, dep_i + 1, imax);
}
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t want_apply = 0;
  int32_t callee_ord = 0;
  int32_t ret = 0;
  int32_t imax = 0;
  int32_t nd_scan = 0;
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (call_expr_ref > 0 && call_expr_ref <= (arena)->num_exprs) {   (want_apply = (1));
 } else (__tmp = 0) ; __tmp; }));
  (callee_ord = (pipeline_expr_kind_ord_at(arena, callee_expr_ref)));
  (ret = (typeck_resolve_call_callee_try_whole_import(module, arena, callee_expr_ref, ctx, callee_ord)));
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_apply != 0) {   (void)(typeck_i32_ptr_store(typeck_call_resolve_dep_idx_slot(), 0));
  (void)(typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0));
  (void)(typeck_resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx, typeck_call_resolve_dep_idx_slot(), typeck_call_resolve_func_idx_slot()));
  (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, typeck_call_resolve_dep_idx_peek(), typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
  (ret = (typeck_resolve_call_callee_try_binding_import(module, arena, callee_expr_ref, ctx, callee_ord)));
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_apply != 0) {   (void)(typeck_i32_ptr_store(typeck_call_resolve_dep_idx_slot(), 0));
  (void)(typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0));
  (void)(typeck_resolve_call_binding_import_return_type(module, arena, callee_expr_ref, ctx, typeck_call_resolve_dep_idx_slot(), typeck_call_resolve_func_idx_slot()));
  (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, typeck_call_resolve_dep_idx_peek(), typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
  (ret = (typeck_resolve_call_callee_local_module(module, arena, callee_expr_ref, ctx)));
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_apply != 0) {   int32_t minus_one_lm = -1;
  (void)(typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0));
  (void)(typeck_find_func_return_type_in_module(module, arena, arena, arena, callee_expr_ref, minus_one_lm, ctx, typeck_call_resolve_func_idx_slot()));
  (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, minus_one_lm, typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
  (imax = ((module)->num_imports));
  (nd_scan = (pipeline_dep_ctx_ndep(ctx)));
  (void)(({ int32_t __tmp = 0; if (nd_scan > imax) {   (imax = (nd_scan));
 } else (__tmp = 0) ; __tmp; }));
  return typeck_resolve_scan_dep_with_apply(module, arena, callee_expr_ref, callee_ord, call_expr_ref, ctx, 0, imax, want_apply);
}
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return pipeline_expr_resolved_type_ref(arena, expr_ref);
}
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref) {
  int32_t ord_bool = 1;
  return pipeline_type_kind_ord_at(arena, type_ref) == ord_bool;
}
int typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (type_ref <= 0 || type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_type_ref_is_bool_impl(arena, type_ref);
}
int typeck_type_refs_equal_named(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  uint8_t * buf_a = typeck_scratch64_slot(0);
  uint8_t * buf_b = typeck_scratch64_slot(1);
  int32_t na = pipeline_type_named_name_into(arena, a, buf_a);
  int32_t nb = pipeline_type_named_name_into(arena, b, buf_b);
  int32_t i = 0;
  int32_t ta = 0;
  int32_t tb = 0;
  int32_t ua = 0;
  int32_t ub = 0;
  (void)(({ int __tmp = 0; if (na <= 0 || nb <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  if (na == nb) {
    i = 0;
    while (i < na) {
      (void)(({ int __tmp = 0; if ((buf_a)[i] != (buf_b)[i]) {   break;
 } else (__tmp = 0) ; __tmp; }));
      ++i;
    }
    if (i == na)
      return 1;
  }
  for (i = na - 1; i > 0; --i) {
    if (buf_a[i] == '.') { ta = i + 1; break; }
  }
  for (i = nb - 1; i > 0; --i) {
    if (buf_b[i] == '.') { tb = i + 1; break; }
  }
  ua = na - ta;
  ub = nb - tb;
  (void)(({ int __tmp = 0; if (ua != ub || ua <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  i = 0;
  while (i < ua) {
    (void)(({ int __tmp = 0; if ((buf_a)[ta + i] != (buf_b)[tb + i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int typeck_type_refs_equal_same_kind(struct ast_ASTArena * arena, int32_t a, int32_t b, int32_t kind_ord) {
  int32_t ea = 0;
  int32_t eb = 0;
  int32_t ord_named = 8;
  int32_t ord_ptr = 9;
  int32_t ord_array = 10;
  int32_t ord_slice = 11;
  int32_t ord_linear = 12;
  int32_t ord_vector = 13;
  (void)(({ int __tmp = 0; if (kind_ord == ord_named) {   return typeck_type_refs_equal_named(arena, a, b);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind_ord == ord_ptr || kind_ord == ord_slice || kind_ord == ord_linear) {   (ea = (pipeline_type_elem_ref_at(arena, a)));
  (eb = (pipeline_type_elem_ref_at(arena, b)));
  return typeck_type_refs_equal(arena, ea, eb);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind_ord == ord_array || kind_ord == ord_vector) {   (void)(({ int __tmp = 0; if (pipeline_type_array_size_at(arena, a) != pipeline_type_array_size_at(arena, b)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (ea = (pipeline_type_elem_ref_at(arena, a)));
  (eb = (pipeline_type_elem_ref_at(arena, b)));
  return typeck_type_refs_equal(arena, ea, eb);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  int32_t ka = pipeline_type_kind_ord_at(arena, a);
  int32_t kb = pipeline_type_kind_ord_at(arena, b);
  (void)(({ int __tmp = 0; if (ka != kb) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_type_refs_equal_same_kind(arena, a, b, ka);
}
int typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(a) || ast_ref_is_null(b)) {   return a == b;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (a == b) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_type_refs_equal_impl(arena, a, b);
}
int typeck_return_operand_matches(struct ast_ASTArena * arena, int32_t op_ref, int32_t expect_ref) {
  int32_t got = typeck_expr_type_ref(arena, op_ref);
  int32_t ord_i32 = 0;
  (void)(({ int __tmp = 0; if (ast_ref_is_null(op_ref) || ast_ref_is_null(expect_ref)) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_ref_is_null(got)) {   int32_t ord_lit = 0;
  int32_t ord_ptr = 9;
  int32_t expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
  int32_t kop = pipeline_expr_kind_ord_at(arena, op_ref);
  if (kop == ord_lit && expect_kind == ord_ptr && pipeline_expr_int_val_at(arena, op_ref) == 0) {
    (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref));
    return 1;
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (typeck_type_refs_equal(arena, got, expect_ref)) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (pipeline_type_kind_ord_at(arena, got) == 12) {   int32_t elem = pipeline_type_elem_ref_at(arena, got);
  __tmp = ({ int __tmp = 0; if ((!ast_ref_is_null(elem)) && typeck_type_refs_equal(arena, elem, expect_ref)) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (pipeline_type_kind_ord_at(arena, expect_ref) != ord_i32 || (!typeck_type_ref_is_bool(arena, got))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t kop = pipeline_expr_kind_ord_at(arena, op_ref);
  (void)(({ int __tmp = 0; if (kop == 2 || kop == 24) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t int_val = 0;
  int32_t ord_expr_lit = 0;
  int32_t ord_u8 = 2;
  int32_t ord_u32 = 3;
  int32_t ord_u64 = 4;
  int32_t ord_i64 = 5;
  int32_t ord_usize = 6;
  int32_t ord_named = 8;
  int32_t ord_ptr = 9;
  int32_t ord_array = 10;
  int32_t ord_vector = 13;
  int32_t ord_f32 = 14;
  int32_t ord_f64 = 15;
  (void)(({ int32_t __tmp = 0; if (init_kind != ord_expr_lit) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (int_val = (pipeline_expr_int_val_at(arena, init_ref)));
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_ptr && int_val == 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_array && int_val == 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_u8 && int_val >= 0 && int_val <= 255) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_i64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (int_val >= 0 && decl_kind == ord_usize || decl_kind == ord_u32 || decl_kind == ord_u64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (int_val == 0 && decl_kind == ord_f32 || decl_kind == ord_f64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (int_val == 0 && decl_kind == ord_named || decl_kind == ord_vector) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_float_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t ord_expr_float = 1;
  int32_t ord_f32 = 14;
  int32_t ord_f64 = 14;
  (void)(({ int32_t __tmp = 0; if (init_kind == ord_expr_float && decl_kind == ord_f32 || decl_kind == ord_f64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_enum_field_to_decl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t base_ix = 0;
  int32_t ord_named = 8;
  int32_t ord_expr_var = 3;
  int32_t ord_field_access = 44;
  (void)(({ int32_t __tmp = 0; if (decl_kind != ord_named || init_kind != ord_field_access) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (base_ix = (pipeline_expr_field_access_base_ref(arena, init_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(base_ix)) && base_ix > 0 && base_ix <= (arena)->num_exprs) {   uint8_t * decl_buf = typeck_scratch64_slot(0);
  uint8_t * vbuf = typeck_scratch64_slot(1);
  uint8_t * field_buf = typeck_scratch64_slot(2);
  int32_t decl_nlen = pipeline_type_named_name_into(arena, decl_ty_ref, decl_buf);
  int32_t vnlen = pipeline_expr_var_name_len(arena, base_ix);
  int32_t i_nm = 0;
  int eq_nm = 1;
  __tmp = ({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, base_ix) == ord_expr_var && decl_nlen == vnlen && decl_nlen > 0) {   (void)(pipeline_expr_var_name_into(arena, base_ix, vbuf));
  while (i_nm < decl_nlen) {
    (void)(({ int __tmp = 0; if ((decl_buf)[i_nm] != (vbuf)[i_nm]) {   (eq_nm = (0));
 } else (__tmp = 0) ; __tmp; }));
    ++i_nm;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq_nm) {   int32_t field_nlen = pipeline_expr_field_access_name_len(arena, init_ref);
  (void)(pipeline_expr_field_access_name_into(arena, init_ref, field_buf));
  int32_t ev_tag = pipeline_module_enum_variant_tag_for_names(module, decl_buf, decl_nlen, field_buf, field_nlen);
  __tmp = ({ int32_t __tmp = 0; if (ev_tag >= 0) {   (void)(pipeline_expr_set_field_access_enum_variant(arena, init_ref, ev_tag));
  (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_named_call_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t ord_type_named = 8;
  int32_t ord_expr_call = 48;
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_type_named && init_kind == ord_expr_call && ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, init_ref))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_array_vector_lit_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t ord_type_array = 10;
  int32_t ord_type_vector = 12;
  int32_t ord_expr_array_lit = 46;
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_type_array && init_kind == ord_expr_array_lit) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (decl_kind == ord_type_vector && init_kind == ord_expr_array_lit) {   __tmp = ({ int32_t __tmp = 0; if (pipeline_expr_array_lit_num_elems_at(arena, init_ref) == pipeline_type_array_size_at(arena, decl_ty_ref)) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_vector_binop_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  int32_t lref_c = 0;
  int32_t rref_c = 0;
  int32_t ord_type_vector = 12;
  int32_t ord_add = 4;
  int32_t ord_sub = 5;
  int32_t ord_mul = 6;
  int32_t ord_div = 7;
  (void)(({ int32_t __tmp = 0; if (decl_kind != ord_type_vector) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (init_kind != ord_add && init_kind != ord_sub && init_kind != ord_mul && init_kind != ord_div) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (lref_c = (pipeline_expr_binop_left_ref_at(arena, init_ref)));
  (rref_c = (pipeline_expr_binop_right_ref_at(arena, init_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lref_c)) && (!ast_ref_is_null(rref_c))) {   int32_t lt_c = typeck_expr_type_ref(arena, lref_c);
  int32_t rt_c = typeck_expr_type_ref(arena, rref_c);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_c)) && (!ast_ref_is_null(rt_c)) && pipeline_type_kind_ord_at(arena, lt_c) == ord_type_vector && pipeline_type_kind_ord_at(arena, rt_c) == ord_type_vector && pipeline_type_array_size_at(arena, lt_c) == pipeline_type_array_size_at(arena, rt_c) && pipeline_type_array_size_at(arena, lt_c) == pipeline_type_array_size_at(arena, decl_ty_ref) && typeck_type_refs_equal(arena, pipeline_type_elem_ref_at(arena, lt_c), pipeline_type_elem_ref_at(arena, rt_c))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_coerce_init_slice_from_array(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind) {
  int32_t ord_type_slice = 11;
  int32_t ord_type_array = 10;
  int32_t decl_elem = 0;
  int32_t init_res = 0;
  int32_t init_kind = 0;
  int32_t init_elem = 0;
  (void)(({ int32_t __tmp = 0; if (decl_kind != ord_type_slice) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (decl_elem = (pipeline_type_elem_ref_at(arena, decl_ty_ref)));
  (init_res = (pipeline_expr_resolved_type_ref(arena, init_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(decl_elem) || ast_ref_is_null(init_res)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (init_kind = (pipeline_type_kind_ord_at(arena, init_res)));
  (void)(({ int32_t __tmp = 0; if (init_kind != ord_type_array) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (init_elem = (pipeline_type_elem_ref_at(arena, init_res)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(init_elem)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!typeck_type_refs_equal(arena, init_elem, decl_elem))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref));
  return 1;
}
int32_t typeck_coerce_init_expr_to_decl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref) {
  int32_t decl_kind = 0;
  int32_t init_kind = 0;
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(init_ref) || ast_ref_is_null(decl_ty_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (init_ref <= 0 || init_ref > (arena)->num_exprs || decl_ty_ref <= 0 || decl_ty_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (decl_kind = (pipeline_type_kind_ord_at(arena, decl_ty_ref)));
  (init_kind = (pipeline_expr_kind_ord_at(arena, init_ref)));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_float_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_enum_field_to_decl(module, arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_named_call_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_array_vector_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_vector_binop_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_coerce_init_slice_from_array(arena, init_ref, decl_ty_ref, decl_kind) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len) {
  int32_t p = pos;
  int32_t i = 0;
  while (i < lit_len && p >= 0 && p < cap) {
    ((out)[p] = ((lit)[i]));
    ++p;
    ++i;
  }
  return p;
}
int32_t typeck_diag_append_u32_dec(uint8_t * out, int32_t pos, int32_t cap, int32_t v) {
  int32_t p = pos;
  (void)(({ int32_t __tmp = 0; if (v < 0 || p < 0 || p >= cap) {   return p;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (v == 0) {   uint8_t zd[1] = { 48 };
  return typeck_diag_append_lit(out, p, cap, (&((zd)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t cnt = 0;
  int32_t tc = v;
  while (tc > 0) {
    ++cnt;
    (tc = ((10 == 0 ? (shux_panic_(1, 0), tc) : (tc / 10))));
  }
  int32_t k = cnt - 1;
  int32_t tm = v;
  while (tm > 0) {
    int32_t d = (10 == 0 ? (shux_panic_(1, 0), tm) : (tm % 10));
    (tm = ((10 == 0 ? (shux_panic_(1, 0), tm) : (tm / 10))));
    (void)(({ int32_t __tmp = 0; if (pos + k < 0 || pos + k >= cap) {   return p;
 } else (__tmp = 0) ; __tmp; }));
    ((out)[pos + k] = (((uint8_t)(d + 48))));
    (k = (k - 1));
  }
  return pos + cnt;
}
int32_t typeck_diag_fmt_type_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cur, int32_t cap) {
  uint8_t qmk[1] = { 63 };
  uint8_t lit_i32[3] = { 105, 51, 50 };
  uint8_t lit_bool[4] = { 98, 111, 111, 108 };
  uint8_t lit_u8[2] = { 117, 56 };
  uint8_t lit_u32[3] = { 117, 51, 50 };
  uint8_t lit_u64[3] = { 117, 54, 52 };
  uint8_t lit_i64[3] = { 105, 54, 52 };
  uint8_t lit_usize[5] = { 117, 115, 105, 122, 101 };
  uint8_t lit_isize[5] = { 105, 115, 105, 122, 101 };
  uint8_t lit_f32[3] = { 102, 51, 50 };
  uint8_t lit_f64[3] = { 102, 54, 52 };
  uint8_t star[1] = { 42 };
  uint8_t lbk[1] = { 91 };
  uint8_t rbk[1] = { 93 };
  uint8_t slo[2] = { 91, 93 };
  int32_t kind = 0;
  int32_t nlen = 0;
  int32_t elem_ref = 0;
  int32_t asz = 0;
  int32_t ord_i32 = 0;
  int32_t ord_bool = 1;
  int32_t ord_u8 = 2;
  int32_t ord_u32 = 3;
  int32_t ord_u64 = 4;
  int32_t ord_i64 = 5;
  int32_t ord_usize = 6;
  int32_t ord_isize = 7;
  int32_t ord_named = 8;
  int32_t ord_ptr = 9;
  int32_t ord_array = 10;
  int32_t ord_slice = 11;
  int32_t ord_linear = 12;
  int32_t ord_f32 = 14;
  int32_t ord_f64 = 15;
  int32_t ord_void = 16;
  uint8_t * nm_buf = typeck_scratch64_slot(0);
  (void)(({ int32_t __tmp = 0; if (cur < 0 || cap <= 0 || cur >= cap) {   return cur;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ref) || ref <= 0 || ref > (arena)->num_types) {   return typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  (kind = (pipeline_type_kind_ord_at(arena, ref)));
  (void)(({ int32_t __tmp = 0; if (kind == ord_named) {   (nlen = (pipeline_type_named_name_into(arena, ref, nm_buf)));
  __tmp = ({ int32_t __tmp = 0; if (nlen > 0) {   return typeck_diag_append_lit(out, cur, cap, nm_buf, nlen);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_i32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_i32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_bool) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_bool)[0])), 4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_u8) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u8)[0])), 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_u32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_u64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_i64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_i64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_usize) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_usize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_isize) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_isize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_f32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_f32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_f64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_f64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_void) {   return typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_ptr) {   (elem_ref = (pipeline_type_elem_ref_at(arena, ref)));
  int32_t nex = typeck_diag_append_lit(out, cur, cap, (&((star)[0])), 1);
  return typeck_diag_fmt_type_at(arena, elem_ref, out, nex, cap);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_slice) {   uint8_t lt_ch[1] = { 60 };
  uint8_t gt_ch[1] = { 62 };
  int32_t rlen = 0;
  uint8_t * rbuf = typeck_scratch64_slot(15);
  (elem_ref = (pipeline_type_elem_ref_at(arena, ref)));
  int32_t nex2 = typeck_diag_append_lit(out, cur, cap, (&((slo)[0])), 2);
  (nex2 = (typeck_diag_fmt_type_at(arena, elem_ref, out, nex2, cap)));
  (rlen = (pipeline_type_region_label_len_at(arena, ref)));
  (void)(({ int32_t __tmp = 0; if (rlen > 0 && pipeline_type_region_label_into(arena, ref, rbuf) == rlen) {   int32_t p0 = typeck_diag_append_lit(out, nex2, cap, (&((lt_ch)[0])), 1);
  int32_t p1 = typeck_diag_append_lit(out, p0, cap, rbuf, rlen);
  return typeck_diag_append_lit(out, p1, cap, (&((gt_ch)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  return nex2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_linear) {   uint8_t lpar[7] = { 76, 105, 110, 101, 97, 114, 40 };
  uint8_t rpar[1] = { 41 };
  (elem_ref = (pipeline_type_elem_ref_at(arena, ref)));
  int32_t p0 = typeck_diag_append_lit(out, cur, cap, (&((lpar)[0])), 7);
  int32_t p1 = typeck_diag_fmt_type_at(arena, elem_ref, out, p0, cap);
  return typeck_diag_append_lit(out, p1, cap, (&((rpar)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_array) {   (elem_ref = (pipeline_type_elem_ref_at(arena, ref)));
  (asz = (pipeline_type_array_size_at(arena, ref)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(elem_ref)) && asz > 0) {   int32_t p0 = typeck_diag_append_lit(out, cur, cap, (&((lbk)[0])), 1);
  int32_t p1 = typeck_diag_append_u32_dec(out, p0, cap, asz);
  int32_t p2 = typeck_diag_append_lit(out, p1, cap, (&((rbk)[0])), 1);
  return typeck_diag_fmt_type_at(arena, elem_ref, out, p2, cap);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
}
int32_t typeck_diag_fmt_type_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cap) {
  return typeck_diag_fmt_type_at(arena, ref, out, 0, cap);
}
int32_t typeck_diag_fmt_type_or_question(struct ast_ASTArena * arena, int32_t ref, uint8_t * out) {
  uint8_t qmk[1] = { 63 };
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ref) || ref <= 0 || ref > (arena)->num_types) {   return typeck_diag_append_lit(out, 0, 96, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_diag_fmt_type_into(arena, ref, out, 96);
}
void typeck_ret_coerce_integral_to_expect_i32(struct ast_ASTArena * arena, int32_t op_ref, int32_t expect_ref) {
  int32_t ord_i32 = 0;
  int32_t ord_u8 = 2;
  int32_t ord_usize = 6;
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ref) || op_ref <= 0 || op_ref > (arena)->num_exprs || ast_ref_is_null(expect_ref)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expect_ref <= 0 || expect_ref > (arena)->num_types) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_kind_ord_at(arena, expect_ref) != ord_i32) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t got_ref = typeck_expr_type_ref(arena, op_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(got_ref) || got_ref <= 0 || got_ref > (arena)->num_types) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t got_kind = pipeline_type_kind_ord_at(arena, got_ref);
  (void)(({ int32_t __tmp = 0; if (got_kind != ord_u8 && got_kind != ord_usize) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref));
}

/** return 语境：整型字面量 0 按指针 null 收窄（heap_libc `return 0` → *u8）。 */
static void typeck_ret_coerce_null_lit_to_expect_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref) {
  int32_t ord_lit = 0;
  int32_t ord_ptr = 9;
  int32_t op_kind;
  int32_t expect_kind;
  int32_t int_val;
  if (!arena || ast_ref_is_null(op_ref) || ast_ref_is_null(expect_ref))
    return;
  op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
  if (op_kind != ord_lit)
    return;
  expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
  int_val = pipeline_expr_int_val_at(arena, op_ref);
  if (expect_kind == ord_ptr && int_val == 0)
    (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref));
}

/** return 语境：CALL 仍未 resolve 时再跑 call_resolve（同模块 / import）。 */
static void typeck_ret_fixup_unresolved_call_c(struct ast_Module *module, struct ast_ASTArena *arena,
    int32_t op_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t ord_call = 48;
  int32_t op_kind;
  if (!module || !arena || ast_ref_is_null(op_ref))
    return;
  if (!ast_ref_is_null(typeck_expr_type_ref(arena, op_ref)))
    return;
  op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
  if (op_kind != ord_call)
    return;
  (void)(typeck_check_expr_call_resolve(module, arena, op_ref, ctx));
}

int32_t typeck_check_expr_float_lit(struct ast_ASTArena * arena, int32_t expr_ref) {
  (void)(pipeline_expr_typeck_set_float_bits_from_val(arena, expr_ref));
  int32_t ft = typeck_ensure_f64_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (ft != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ft));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_int_lit(struct ast_ASTArena * arena, int32_t expr_ref) {
  return pipeline_typeck_check_expr_int_lit_c(arena, expr_ref);
}
int32_t typeck_check_expr_bool_lit(struct ast_ASTArena * arena, int32_t expr_ref) {
  int32_t bt = typeck_ensure_bool_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_break_continue(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_continue = 40;
  int32_t line = 0;
  int32_t col = 0;
  int32_t kind = 0;
  int32_t is_break = 1;
  (void)(({ int32_t __tmp = 0; if (pipeline_dep_ctx_typeck_loop_depth_at(ctx) > 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (line = (pipeline_expr_line_at(arena, expr_ref)));
  (col = (pipeline_expr_col_at(arena, expr_ref)));
  (kind = (pipeline_expr_kind_ord_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (kind == ord_continue) {   (is_break = (0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(driver_diagnostic_typeck_break_continue_outside(line, col, is_break));
  return (-1);
}
int32_t typeck_check_expr_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref) {
  int32_t it = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (it != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, it));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_if_ternary(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_ternary = 27;
  int32_t ord_named = 8;
  int32_t expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  int32_t cond_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  int32_t then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
  int32_t else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
  int32_t ty_t = 0;
  int32_t ty_e = 0;
  int t_named = 0;
  int e_named = 0;
  int32_t resolved = 0;
  int32_t cond_ty = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, cond_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(cond_ref))) {   (cond_ty = (typeck_expr_type_ref(arena, cond_ref)));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, cond_ty))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, then_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(else_ref))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, else_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (ty_t = (typeck_expr_type_ref(arena, then_ref)));
  (ty_e = (typeck_expr_type_ref(arena, else_ref)));
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_t)) && ty_t > 0) {   (t_named = (pipeline_type_kind_ord_at(arena, ty_t) == ord_named));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_e)) && ty_e > 0) {   (e_named = (pipeline_type_kind_ord_at(arena, ty_e) == ord_named));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_kind == ord_ternary) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_t)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_e)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!typeck_type_refs_equal(arena, ty_t, ty_e))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_t));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e)) && t_named && e_named) {   __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_refs_equal(arena, ty_t, ty_e))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e))) {   __tmp = ({ int32_t __tmp = 0; if (e_named && (!t_named)) {   (resolved = (ty_e));
 } else {   (resolved = (ty_t));
 } ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t))) {   (resolved = (ty_t));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_e))) {   (resolved = (ty_e));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(resolved))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, resolved));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_assign = 28;
  int32_t block_ref = pipeline_expr_block_ref_at(arena, expr_ref);
  int32_t fin_blk = 0;
  int32_t ty_fin = 0;
  int32_t nes = 0;
  int32_t fst_es = 0;
  int32_t st_kind = 0;
  int32_t rhs_ref = 0;
  int32_t ty_rhs = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, block_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(block_ref) || block_ref <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (fin_blk = (pipeline_asm_block_final_expr_ref_at(arena, block_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin_blk))) {   (ty_fin = (typeck_expr_type_ref(arena, fin_blk)));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_fin));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (nes = (ast_block_num_expr_stmts(arena, block_ref)));
  (void)(({ int32_t __tmp = 0; if (nes != 1) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (fst_es = (pipeline_block_expr_stmt_ref(arena, block_ref, 0)));
  (void)(({ int32_t __tmp = 0; if (fst_es <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (st_kind = (pipeline_expr_kind_ord_at(arena, fst_es)));
  (void)(({ int32_t __tmp = 0; if (st_kind != ord_assign && st_kind < 29 || st_kind > 39) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (rhs_ref = (pipeline_expr_binop_right_ref_at(arena, fst_es)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(rhs_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (ty_rhs = (typeck_expr_type_ref(arena, rhs_ref)));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_rhs));
  return 0;
}
int32_t typeck_check_expr_assign(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_assign = 28;
  int32_t ord_lit = 0;
  int32_t ord_var = 3;
  int32_t ord_add = 4;
  int32_t ord_sub = 5;
  int32_t ord_u8 = 2;
  int32_t ord_u32 = 3;
  int32_t ord_u64 = 4;
  int32_t ord_i64 = 5;
  int32_t ord_usize = 6;
  int32_t ord_ptr = 9;
  int32_t ord_field = 44;
  int32_t ord_index = 47;
  int32_t ord_call = 48;
  int32_t expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  int32_t left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  int32_t right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  int32_t line = pipeline_expr_line_at(arena, expr_ref);
  int32_t col = pipeline_expr_col_at(arena, expr_ref);
  int32_t lt = 0;
  int32_t rt = 0;
  int32_t rt_after = 0;
  int32_t compound_flag = 1;
  int32_t lt_kind = 0;
  int32_t rhs_kind = 0;
  int32_t lhs_kind = 0;
  int32_t int_val = 0;
  uint8_t * eb = ((uint8_t *)(0));
  uint8_t * gb = ((uint8_t *)(0));
  int32_t el = 0;
  int32_t gl = 0;
  (void)(({ int32_t __tmp = 0; if (expr_kind == ord_assign) {   (compound_flag = (0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, left_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, right_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(left_ref) || ast_ref_is_null(right_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (lt = (typeck_expr_type_ref(arena, left_ref)));
  (rt_after = (typeck_expr_type_ref(arena, right_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && lt > 0) {   (rhs_kind = (pipeline_expr_kind_ord_at(arena, right_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rhs_kind == ord_lit) {   __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_refs_equal(arena, lt, rt_after))) {   (lt_kind = (pipeline_type_kind_ord_at(arena, lt)));
  (int_val = (pipeline_expr_int_val_at(arena, right_ref)));
  __tmp = ({ int32_t __tmp = 0; if (lt_kind == ord_u8 && int_val >= 0 && int_val <= 255) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
 } else (__tmp = ({ int32_t __tmp = 0; if (expr_kind == ord_assign && lt_kind == ord_ptr && int_val == 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
 } else (__tmp = ({ int32_t __tmp = 0; if (expr_kind == ord_assign && int_val >= 0 && lt_kind == ord_usize || lt_kind == ord_u32 || lt_kind == ord_u64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
 } else (__tmp = ({ int32_t __tmp = 0; if (expr_kind == ord_assign && lt_kind == ord_i64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (rt = (typeck_expr_type_ref(arena, right_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   (rhs_kind = (pipeline_expr_kind_ord_at(arena, right_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rhs_kind == ord_call) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
  (rt = (lt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(lt) && (!ast_ref_is_null(rt))) {   (lhs_kind = (pipeline_expr_kind_ord_at(arena, left_ref)));
  __tmp = ({ int32_t __tmp = 0; if (lhs_kind == ord_var || lhs_kind == ord_field || lhs_kind == ord_index) {   (void)(pipeline_expr_set_resolved_type_ref(arena, left_ref, rt));
  (lt = (rt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && (!ast_ref_is_null(rt))) {   (void)(({ int32_t __tmp = 0; if ((!typeck_type_refs_equal(arena, lt, rt))) {   (eb = (driver_typeck_diag_scratch_expect()));
  (gb = (driver_typeck_diag_scratch_found()));
  (el = (typeck_diag_fmt_type_into(arena, lt, eb, 96)));
  (gl = (typeck_diag_fmt_type_into(arena, rt, gb, 96)));
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (pipeline_typeck_check_slice_region_assign_c(arena, expr_ref, lt, rt) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   (rhs_kind = (pipeline_expr_kind_ord_at(arena, right_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rhs_kind == ord_sub || rhs_kind == ord_add) {   (lt_kind = (pipeline_type_kind_ord_at(arena, lt)));
  __tmp = ({ int32_t __tmp = 0; if (lt_kind == ord_usize) {   (void)(pipeline_expr_set_resolved_type_ref(arena, right_ref, lt));
  (rt = (lt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (eb = (driver_typeck_diag_scratch_expect()));
  (gb = (driver_typeck_diag_scratch_found()));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(lt) && (!ast_ref_is_null(rt))) {   (el = (typeck_diag_fmt_type_or_question(arena, lt, eb)));
  (gl = (typeck_diag_fmt_type_or_question(arena, rt, gb)));
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   (el = (typeck_diag_fmt_type_or_question(arena, lt, eb)));
  (gl = (typeck_diag_fmt_type_or_question(arena, rt, gb)));
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_return(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_void = 16;
  int32_t ord_lit = 0;
  int32_t ord_as = 54;
  int32_t ord_u32 = 3;
  int32_t ord_u64 = 4;
  int32_t ord_usize = 6;
  int32_t ord_ptr = 9;
  int32_t op_ref = 0;
  int32_t line = 0;
  int32_t col = 0;
  int32_t rt_kind = 0;
  int32_t op_kind = 0;
  int32_t int_val = 0;
  int32_t as_tgt = 0;
  int32_t got = 0;
  uint8_t * eb = ((uint8_t *)(0));
  uint8_t * gb = ((uint8_t *)(0));
  int32_t el = 0;
  int32_t gl = 0;
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (op_ref = (pipeline_expr_unary_operand_ref_at(arena, expr_ref)));
  (line = (pipeline_expr_line_at(arena, expr_ref)));
  (col = (pipeline_expr_col_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ref)) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   (rt_kind = (pipeline_type_kind_ord_at(arena, return_type_ref)));
  (void)(({ int32_t __tmp = 0; if (rt_kind != ord_void) {   (void)(driver_diagnostic_typeck_ret_fail(1, expr_ref, return_type_ref, 0));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   (rt_kind = (pipeline_type_kind_ord_at(arena, return_type_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rt_kind == ord_void) {   (got = (typeck_expr_type_ref(arena, op_ref)));
  (void)(driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   (void)(driver_diagnostic_typeck_ret_fail(1, op_ref, return_type_ref, 0));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  typeck_ret_fixup_unresolved_call_c(module, arena, op_ref, ctx);
  typeck_ret_coerce_null_lit_to_expect_c(arena, op_ref, return_type_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && (!ast_ref_is_null(return_type_ref))) {   (op_kind = (pipeline_expr_kind_ord_at(arena, op_ref)));
  __tmp = ({ int32_t __tmp = 0; if (op_kind == ord_lit) {   (int_val = (pipeline_expr_int_val_at(arena, op_ref)));
  __tmp = ({ int32_t __tmp = 0; if (int_val == 0 && rt_kind == ord_ptr) {   (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref));
 } else __tmp = ({ int32_t __tmp = 0; if (int_val >= 0) {   (rt_kind = (pipeline_type_kind_ord_at(arena, return_type_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rt_kind == ord_usize || rt_kind == ord_u32 || rt_kind == ord_u64) {   (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && (!ast_ref_is_null(return_type_ref))) {   (op_kind = (pipeline_expr_kind_ord_at(arena, op_ref)));
  __tmp = ({ int32_t __tmp = 0; if (op_kind == ord_as) {   (as_tgt = (pipeline_expr_as_target_type_ref_at(arena, op_ref)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(as_tgt)) && typeck_type_refs_equal(arena, as_tgt, return_type_ref)) {   (void)(pipeline_expr_set_resolved_type_ref(arena, op_ref, as_tgt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && (!ast_ref_is_null(op_ref))) {   (void)(typeck_ret_coerce_integral_to_expect_i32(arena, op_ref, return_type_ref));
  (got = (typeck_expr_type_ref(arena, op_ref)));
  (void)(({ int32_t __tmp = 0; if ((!typeck_return_operand_matches(arena, op_ref, return_type_ref))) {   (eb = (driver_typeck_diag_scratch_expect()));
  (gb = (driver_typeck_diag_scratch_found()));
  (el = (typeck_diag_fmt_type_or_question(arena, return_type_ref, eb)));
  (gl = (typeck_diag_fmt_type_or_question(arena, got, gb)));
  (void)(driver_diagnostic_typeck_return_mismatch(line, col, eb, el, gb, gl));
  (void)(driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_panic(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t op_ref = 0;
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (op_ref = (pipeline_expr_unary_operand_ref_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_match_arm(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arm_i, int32_t num_arms, int32_t line, int32_t col) {
  int32_t is_enum = 0;
  int32_t var_ix = 0;
  int32_t arm_res = 0;
  (void)(({ int32_t __tmp = 0; if (arm_i >= num_arms) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (is_enum = (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i)));
  (void)(({ int32_t __tmp = 0; if (is_enum != 0) {   (var_ix = (pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i)));
  __tmp = ({ int32_t __tmp = 0; if (var_ix < 0) {   (void)(driver_diagnostic_typeck_enum_no_variant(line, col));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (arm_res = (pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, arm_res, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_match_arm(module, arena, expr_ref, return_type_ref, ctx, arm_i + 1, num_arms, line, col);
}
int32_t typeck_check_expr_match(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  int32_t num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  int32_t line = pipeline_expr_line_at(arena, expr_ref);
  int32_t col = pipeline_expr_col_at(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, matched_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr_match_arm(module, arena, expr_ref, return_type_ref, ctx, 0, num_arms, line, col) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_call_arg(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arg_i, int32_t num_args) {
  int32_t arg_ref = 0;
  (void)(({ int32_t __tmp = 0; if (arg_i >= num_args) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (arg_ref = (pipeline_expr_call_arg_ref(arena, expr_ref, arg_i)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, arg_i + 1, num_args);
}
int32_t typeck_check_expr_call_resolve(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_addr_of = 51;
  int32_t ord_var = 3;
  int32_t minus_one = -1;
  int32_t callee_ref = 0;
  int32_t callee_eff = 0;
  int32_t inner_c = 0;
  int32_t ret_ty = 0;
  int32_t cnml = 0;
  uint8_t cnm[64] = { 0 };
  (callee_ref = (pipeline_expr_call_callee_ref_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(callee_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (callee_eff = (callee_ref));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_eff) == ord_addr_of) {   (inner_c = (pipeline_expr_unary_operand_ref_at(arena, callee_eff)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(inner_c))) {   (callee_eff = (inner_c));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (cnml = (0));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_eff) == ord_var) {   (cnml = (pipeline_expr_var_name_len(arena, callee_eff)));
  __tmp = ({ int32_t __tmp = 0; if (cnml > 0) {   (void)(pipeline_expr_var_name_into(arena, callee_eff, (&((cnm)[0]))));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (ret_ty = (typeck_resolve_call_callee_return_type(module, arena, callee_eff, expr_ref, ctx)));
  (void)(({ int32_t __tmp = 0; if (ret_ty == 0 && cnml > 0) {   (void)(typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0));
  (ret_ty = (typeck_find_func_return_type_in_module_by_name(module, arena, (&((cnm)[0])), cnml, minus_one, ctx, typeck_call_resolve_func_idx_slot())));
  __tmp = ({ int32_t __tmp = 0; if (ret_ty != 0) {   (void)(ast_expr_apply_call_resolve(arena, expr_ref, minus_one, typeck_call_resolve_func_idx_peek()));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (cnml > 0 && pipeline_typeck_is_read_ptr_slice_callee_c((&((cnm)[0])), cnml) != 0) {   (ret_ty = (pipeline_typeck_read_ptr_slice_return_ref_c(arena)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ret_ty != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t num_args = pipeline_expr_call_num_args_at(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, 0, num_args) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr_call_resolve(module, arena, expr_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_typeck_check_call_slice_region_c(module, arena, expr_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_binop_cmp(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t bop_l = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  int32_t bop_r = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  int32_t bt = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (bt = (typeck_ensure_bool_type_ref(arena)));
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_binop_arith(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t bop_l = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  int32_t bop_r = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  int32_t expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  int32_t lt_ar = 0;
  int32_t rt_ar = 0;
  int32_t lko = 0;
  int32_t rko = 0;
  int32_t out_ar = 0;
  int32_t allow_i32_fallback = 0;
  int32_t ord_type_vector = 12;
  int32_t ord_i64 = 5;
  int32_t ord_f64 = 14;
  int32_t ord_bool = 1;
  int32_t ord_i32 = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (lt_ar = (pipeline_expr_resolved_type_ref(arena, bop_l)));
  (rt_ar = (pipeline_expr_resolved_type_ref(arena, bop_r)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_ar)) && (!ast_ref_is_null(rt_ar))) {   (lko = (pipeline_type_kind_ord_at(arena, lt_ar)));
  (rko = (pipeline_type_kind_ord_at(arena, rt_ar)));
  (void)(({ int32_t __tmp = 0; if (lko == ord_type_vector && rko == ord_type_vector && pipeline_type_array_size_at(arena, lt_ar) == pipeline_type_array_size_at(arena, rt_ar) && typeck_type_refs_equal(arena, pipeline_type_elem_ref_at(arena, lt_ar), pipeline_type_elem_ref_at(arena, rt_ar))) {   (out_ar = (lt_ar));
 } else (__tmp = ({ int32_t __tmp = 0; if (lko == ord_i64 || rko == ord_i64) {   (out_ar = (typeck_ensure_primitive_by_kind_ord(arena, ord_i64)));
 } else (__tmp = ({ int32_t __tmp = 0; if (lko == ord_f64 || rko == ord_f64) {   (out_ar = (typeck_ensure_primitive_by_kind_ord(arena, ord_f64)));
 } else (__tmp = ({ int32_t __tmp = 0; if (typeck_type_refs_equal(arena, lt_ar, rt_ar)) {   (out_ar = (lt_ar));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_ar))) {   (out_ar = (lt_ar));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(rt_ar))) {   (out_ar = (rt_ar));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_kind >= 4 && expr_kind <= 13) {   (allow_i32_fallback = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(out_ar) && lko != ord_type_vector && rko != ord_type_vector && allow_i32_fallback != 0) {   (out_ar = (typeck_ensure_primitive_by_kind_ord(arena, ord_i32)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (allow_i32_fallback != 0 && pipeline_type_kind_ord_at(arena, lt_ar) == ord_bool || pipeline_type_kind_ord_at(arena, rt_ar) == ord_bool) {   (out_ar = (typeck_ensure_primitive_by_kind_ord(arena, ord_i32)));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(out_ar))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_binop(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_eq = 14;
  int32_t ord_ne = 15;
  int32_t ord_lt = 16;
  int32_t ord_le = 17;
  int32_t ord_gt = 18;
  int32_t ord_ge = 19;
  int32_t ord_logand = 20;
  int32_t ord_logor = 21;
  int32_t expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (expr_kind == ord_eq || expr_kind == ord_ne || expr_kind == ord_lt || expr_kind == ord_le || expr_kind == ord_gt || expr_kind == ord_ge || expr_kind == ord_logand || expr_kind == ord_logor) {   return typeck_check_expr_binop_cmp(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_binop_arith(module, arena, expr_ref, return_type_ref, ctx);
}
int32_t typeck_check_expr_field_access(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  return pipeline_typeck_check_expr_field_access_c(module, arena, expr_ref, return_type_ref, ctx);
}
int32_t typeck_check_expr_unary(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_lognot = 24;
  int32_t op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  int32_t expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  int32_t op_tr = 0;
  int32_t bt = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_kind == ord_lognot) {   (bt = (typeck_ensure_bool_type_ref(arena)));
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (op_tr = (typeck_expr_type_ref(arena, op_ref)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_tr)) && op_tr > 0 && op_tr <= (arena)->num_types) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_tr));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_addr_of(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  int32_t op_ty = 0;
  int32_t pt = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref))) {   (void)(({ int32_t __tmp = 0; if (pipeline_typeck_reject_addr_of_linear_c(arena, op_ref, expr_ref, module, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (op_ty = (typeck_expr_type_ref(arena, op_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ty) || op_ty <= 0 || op_ty > (arena)->num_types) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (pt = (pipeline_typeck_ptr_for_addr_of_operand_c(arena, op_ref, op_ty, module, ctx)));
  (void)(({ int32_t __tmp = 0; if (pt == 0) {   (pt = (typeck_find_or_alloc_ptr_type_ref(arena, op_ty)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pt == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, pt));
  return 0;
}
int32_t typeck_check_expr_deref(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_ptr = 9;
  int32_t op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  int32_t op_ptr = 0;
  int32_t elem_ty = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (op_ptr = (typeck_expr_type_ref(arena, op_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ptr) || op_ptr <= 0 || op_ptr > (arena)->num_types) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_kind_ord_at(arena, op_ptr) != ord_ptr) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (elem_ty = (pipeline_type_elem_ref_at(arena, op_ptr)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(elem_ty)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, elem_ty));
  return 0;
}
int32_t typeck_check_expr_var_top_level(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * vbuf, int32_t vnlen, int32_t tl) {
  int32_t tl_tr = 0;
  (void)(({ int32_t __tmp = 0; if (tl >= (module)->num_top_level_lets) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_top_level_let_name_equal(module, tl, vbuf, vnlen)) {   (tl_tr = (pipeline_module_top_level_let_type_ref(module, tl)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(tl_tr))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, tl_tr));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_var_top_level(module, arena, expr_ref, vbuf, vnlen, tl + 1);
}
int32_t typeck_check_expr_var(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t vnlen = 0;
  uint8_t * vbuf = typeck_scratch64_slot(0);
  int32_t vd_tr = 0;
  int32_t block_ref = 0;
  int32_t func_ix = 0;
  int32_t pr = 0;
  int32_t tk_tr = 0;
  int32_t tg_tr = 0;
  uint8_t nm_tok_kind[9] = { 84, 111, 107, 101, 110, 75, 105, 110, 100 };
  uint8_t nm_typ_kind[8] = { 84, 121, 112, 101, 75, 105, 110, 100 };
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || module == ((struct ast_Module *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (vnlen = (pipeline_expr_var_name_len(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (vnlen <= 0 || vnlen > 63) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_var_name_into(arena, expr_ref, vbuf));
  (block_ref = (pipeline_dep_ctx_current_block_ref_at(ctx)));
  (void)(({ int32_t __tmp = 0; if (block_ref != 0 && block_ref <= (arena)->num_blocks) {   (vd_tr = (pipeline_block_resolve_var_type_ref(arena, block_ref, vbuf, vnlen)));
  __tmp = ({ int32_t __tmp = 0; if (vd_tr != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, vd_tr));
  (void)(({ int32_t __tmp = 0; if (pipeline_typeck_linear_use_var_c(arena, vd_tr, expr_ref, vbuf, vnlen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->num_top_level_lets > 0) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr_var_top_level(module, arena, expr_ref, vbuf, vnlen, 0) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (func_ix = (pipeline_dep_ctx_current_func_index(ctx)));
  (void)(({ int32_t __tmp = 0; if (func_ix >= 0 && func_ix < (module)->num_funcs) {   (pr = (pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen)));
  __tmp = ({ int32_t __tmp = 0; if (pr != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, pr));
  (void)(({ int32_t __tmp = 0; if (pipeline_typeck_linear_use_var_c(arena, pr, expr_ref, vbuf, vnlen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (vnlen == 9 && typeck_name_equal(vbuf, vnlen, (&((nm_tok_kind)[0])), 9)) {   (tk_tr = (typeck_find_or_alloc_named_type_ref(arena, (&((nm_tok_kind)[0])), 9)));
  __tmp = ({ int32_t __tmp = 0; if (tk_tr != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, tk_tr));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (vnlen == 8 && typeck_name_equal(vbuf, vnlen, (&((nm_typ_kind)[0])), 8)) {   (tg_tr = (typeck_find_or_alloc_named_type_ref(arena, (&((nm_typ_kind)[0])), 8)));
  __tmp = ({ int32_t __tmp = 0; if (tg_tr != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, tg_tr));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_method_call_arg(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t arg_i, int32_t num_args) {
  int32_t arg_ref = 0;
  (void)(({ int32_t __tmp = 0; if (arg_i >= num_args) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (arg_ref = (pipeline_expr_method_call_arg_ref(arena, expr_ref, arg_i)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_method_call_arg(module, arena, expr_ref, return_type_ref, ctx, arg_i + 1, num_args);
}
int32_t typeck_check_expr_method_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t base_ref = 0;
  int32_t num_args = 0;
  (void)(ast_expr_init_call_resolve(arena, expr_ref));
  (base_ref = (pipeline_expr_method_call_base_ref_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (num_args = (pipeline_expr_method_call_num_args_at(arena, expr_ref)));
  return typeck_check_expr_method_call_arg(module, arena, expr_ref, return_type_ref, ctx, 0, num_args);
}
int32_t typeck_check_expr_as(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  int32_t tgt = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && typeck_check_expr(module, arena, op_ref, 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(tgt))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, tgt));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_struct_lit_field(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t field_i, int32_t num_fields) {
  int32_t init_sl = 0;
  (void)(({ int32_t __tmp = 0; if (field_i >= num_fields) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (init_sl = (pipeline_expr_struct_lit_init_ref(arena, expr_ref, field_i)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_sl)) && typeck_check_expr(module, arena, init_sl, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_struct_lit_field(module, arena, expr_ref, return_type_ref, ctx, field_i + 1, num_fields);
}
int32_t typeck_check_expr_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
  int32_t name_len = 0;
  uint8_t name_buf[64] = { 0 };
  int32_t tr = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr_struct_lit_field(module, arena, expr_ref, return_type_ref, ctx, 0, num_fields) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_ensure_struct_layout_from_struct_lit(module, arena, expr_ref) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (name_len = (pipeline_expr_struct_lit_type_name_len(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_struct_lit_type_name_into(arena, expr_ref, (&((name_buf)[0]))));
  (tr = (typeck_find_or_alloc_named_type_ref(arena, (&((name_buf)[0])), name_len)));
  (void)(({ int32_t __tmp = 0; if (tr != 0) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, tr));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_index(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_lit = 0;
  int32_t ord_ptr = 9;
  int32_t ord_array = 10;
  int32_t ord_slice = 11;
  int32_t ord_vector = 13;
  int32_t base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  int32_t index_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  int32_t line = pipeline_expr_line_at(arena, expr_ref);
  int32_t col = pipeline_expr_col_at(arena, expr_ref);
  int32_t base_ty = 0;
  int32_t bt_kind = 0;
  int32_t elem_ty = 0;
  int32_t array_sz = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, index_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (base_ty = (pipeline_expr_resolved_type_ref(arena, base_ref)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > (arena)->num_types) {   (void)(driver_diagnostic_typeck_subscript_base(line, col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (bt_kind = (pipeline_type_kind_ord_at(arena, base_ty)));
  (void)(({ int32_t __tmp = 0; if (bt_kind != ord_array && bt_kind != ord_slice && bt_kind != ord_ptr && bt_kind != ord_vector) {   (void)(driver_diagnostic_typeck_subscript_base(line, col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (elem_ty = (pipeline_type_elem_ref_at(arena, base_ty)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(elem_ty)) {   (void)(driver_diagnostic_typeck_subscript_base(line, col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, elem_ty));
  (void)(({ int32_t __tmp = 0; if (bt_kind == ord_slice) {   (void)(pipeline_expr_set_index_base_is_slice(arena, expr_ref, 1));
 } else {   (void)(pipeline_expr_set_index_base_is_slice(arena, expr_ref, 0));
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(index_ref)) && index_ref > 0 && index_ref <= (arena)->num_exprs) {   __tmp = ({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, index_ref) == ord_lit && pipeline_expr_int_val_at(arena, index_ref) == 0 && bt_kind == ord_array || bt_kind == ord_vector) {   (array_sz = (pipeline_type_array_size_at(arena, base_ty)));
  __tmp = ({ int32_t __tmp = 0; if (array_sz >= 1) {   (void)(pipeline_expr_set_index_proven_in_bounds(arena, expr_ref, 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int typeck_expr_is_any_assign_kind(int32_t kind_ord) {
  int32_t ord_assign = 28;
  int32_t ord_add_assign = 29;
  int32_t ord_shr_assign = 38;
  (void)(({ int __tmp = 0; if (kind_ord == ord_assign) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind_ord >= ord_add_assign && kind_ord <= ord_shr_assign) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_impl_mega(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_return = 41;
  int32_t ord_panic = 42;
  int32_t ord_match = 43;
  int32_t ord_field = 44;
  int32_t ord_struct_lit = 45;
  int32_t ord_index = 47;
  int32_t ord_call = 48;
  int32_t ord_method_call = 49;
  int32_t ord_add = 4;
  int32_t ord_logor = 21;
  int32_t ord_neg = 22;
  int32_t ord_bitnot = 23;
  int32_t ord_lognot = 24;
  int32_t ord_addr_of = 51;
  int32_t ord_deref = 52;
  int32_t ord_var = 3;
  int32_t ord_as = 54;
  int32_t kind = 0;
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (kind = (pipeline_expr_kind_ord_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (typeck_expr_is_any_assign_kind(kind)) {   return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_return) {   return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_panic) {   return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_match) {   return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_field) {   return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_index) {   return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_call) {   return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_method_call) {   return typeck_check_expr_method_call(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind >= ord_add && kind <= ord_logor) {   return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_neg || kind == ord_bitnot || kind == ord_lognot) {   return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_addr_of) {   return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_deref) {   return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_var) {   return typeck_check_expr_var(module, arena, expr_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_as) {   return typeck_check_expr_as(module, arena, expr_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_struct_lit) {   return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_lit = 0;
  int32_t ord_float = 1;
  int32_t ord_bool = 2;
  int32_t ord_if = 25;
  int32_t ord_block = 26;
  int32_t ord_ternary = 27;
  int32_t ord_break = 39;
  int32_t ord_continue = 40;
  int32_t ord_enum_var = 50;
  int32_t kind = 0;
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (kind = (pipeline_expr_kind_ord_at(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (kind == ord_float) {   return typeck_check_expr_float_lit(arena, expr_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_lit) {   return typeck_check_expr_int_lit(arena, expr_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_bool) {   return typeck_check_expr_bool_lit(arena, expr_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_break || kind == ord_continue) {   return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_enum_var) {   return typeck_check_expr_enum_variant(arena, expr_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_if || kind == ord_ternary) {   return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ord_block) {   return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_expr_impl(module, arena, expr_ref, return_type_ref, ctx);
}
int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref) {
  int32_t fin_ref = ast_block_final_expr_ref(arena, body_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin_ref))) {   return fin_ref;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nso = ast_block_num_stmt_order(arena, body_ref);
  (void)(({ int32_t __tmp = 0; if (nso > 0) {   uint8_t last_k = ast_block_stmt_order_kind(arena, body_ref, nso - 1);
  (void)(({ int32_t __tmp = 0; if (last_k == ((uint8_t)(2))) {   int32_t idx = ast_block_stmt_order_idx(arena, body_ref, nso - 1);
  int32_t nes = ast_block_num_expr_stmts(arena, body_ref);
  __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nes) {   return ast_block_expr_stmt_ref(arena, body_ref, idx);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nes2 = ast_block_num_expr_stmts(arena, body_ref);
  (void)(({ int32_t __tmp = 0; if (nes2 > 0) {   return ast_block_expr_stmt_ref(arena, body_ref, nes2 - 1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(body_ref) || body_ref <= 0 || body_ref > (arena)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t tail_ref = typeck_func_body_tail_expr_ref_for_implicit_rule(arena, body_ref);
  (void)(({ int __tmp = 0; if (ast_ref_is_null(tail_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_expr_disallows_implicit_tail(arena, tail_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int32_t typeck_loop_depth_push(struct ast_PipelineDepCtx * ctx) {
  int32_t saved = pipeline_dep_ctx_typeck_loop_depth_at(ctx);
  (void)(pipeline_typeck_loop_depth_set_c(ctx, saved + 1));
  return saved;
}
void typeck_loop_depth_pop(struct ast_PipelineDepCtx * ctx, int32_t saved) {
  (void)(pipeline_typeck_loop_depth_set_c(ctx, saved));
}
int32_t typeck_check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t saved_ld = 0;
  int32_t rc = 0;
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (saved_ld = (typeck_loop_depth_push(ctx)));
  (rc = (typeck_check_block(module, arena, body_ref, return_type_ref, ctx)));
  (void)(typeck_loop_depth_pop(ctx, saved_ld));
  return rc;
}
int32_t typeck_check_block_one_const(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  int32_t cd_ir = ast_block_const_init_ref(arena, block_ref, idx);
  int32_t cd_tr = ast_block_const_type_ref(arena, block_ref, idx);
  int32_t init_ty = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, cd_ir, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(cd_ir)) && (!ast_ref_is_null(cd_tr))) {   (init_ty = (typeck_expr_type_ref(arena, cd_ir)));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && (!typeck_type_refs_equal(arena, cd_tr, init_ty))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_block_one_let(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  int32_t ld_ir = ast_block_let_init_ref(arena, block_ref, idx);
  int32_t ld_tr = ast_block_let_type_ref(arena, block_ref, idx);
  int32_t init_ty = 0;
  uint8_t * eb = ((uint8_t *)(0));
  uint8_t * gb = ((uint8_t *)(0));
  int32_t el = 0;
  int32_t gl = 0;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ld_ir, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_type_stamp_block_let_region_c(arena, block_ref, idx, ctx));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ld_ir)) && (!ast_ref_is_null(ld_tr))) {   (void)(typeck_coerce_init_expr_to_decl(module, arena, ld_ir, ld_tr));
  (init_ty = (typeck_expr_type_ref(arena, ld_ir)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && (!typeck_type_refs_equal(arena, ld_tr, init_ty)) && pipeline_typeck_linear_accepts_init_c(arena, ld_tr, init_ty) == 0) {   (eb = (driver_typeck_diag_scratch_expect()));
  (gb = (driver_typeck_diag_scratch_found()));
  (el = (typeck_diag_fmt_type_into(arena, ld_tr, eb, 96)));
  (gl = (typeck_diag_fmt_type_into(arena, init_ty, gb, 96)));
  (void)(driver_diagnostic_typeck_assign_mismatch(0, 0, 0, eb, el, gb, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && pipeline_typeck_check_slice_region_assign_c(arena, ld_ir, ld_tr, init_ty) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_block_one_while(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  int32_t wc = ast_block_while_cond_ref(arena, block_ref, idx);
  int32_t wb = ast_block_while_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(wc))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, wc, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, wc)))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_as_loop_body(module, arena, wb, return_type_ref, ctx);
}
int32_t typeck_check_block_one_for(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  int32_t fi_ir = ast_block_for_init_ref(arena, block_ref, idx);
  int32_t fc_cr = ast_block_for_cond_ref(arena, block_ref, idx);
  int32_t fs_sr = ast_block_for_step_ref(arena, block_ref, idx);
  int32_t fb_br = ast_block_for_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fi_ir, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fc_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fc_cr, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, fc_cr)))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fs_sr, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_as_loop_body(module, arena, fb_br, return_type_ref, ctx);
}
int32_t typeck_check_block_one_if(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  int32_t ic_cr = ast_block_if_cond_ref(arena, block_ref, idx);
  int32_t ib_tr = ast_block_if_then_body_ref(arena, block_ref, idx);
  int32_t ib_er = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ic_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ic_cr, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, ic_cr)))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ib_tr, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (ib_er = (ast_block_if_else_body_ref(arena, block_ref, idx)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ib_er))) {   return typeck_check_block(module, arena, ib_er, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_block_final(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t fin0) {
  int skip_tail_ty_cmp = 0;
  int32_t fin_k_tail = 0;
  int32_t got = 0;
  int32_t fin_op = 0;
  int32_t fin_k_ret = 0;
  uint8_t * eb_fin = ((uint8_t *)(0));
  uint8_t * gb_fin = ((uint8_t *)(0));
  int32_t el_fin = 0;
  int32_t gl_fin = 0;
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(fin0)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fin0, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (fin_k_tail = (pipeline_expr_kind_ord_at(arena, fin0)));
  (void)(({ int __tmp = 0; if (fin_k_tail == 41) {   __tmp = ({ int __tmp = 0; if (ast_ref_is_null(pipeline_expr_unary_operand_ref_at(arena, fin0))) {   (skip_tail_ty_cmp = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (fin_k_tail == 39 || fin_k_tail == 40) {   (skip_tail_ty_cmp = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (typeck_expr_is_any_assign_kind(fin_k_tail)) {   (skip_tail_ty_cmp = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(return_type_ref) || skip_tail_ty_cmp) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (got = (typeck_expr_type_ref(arena, fin0)));
  (fin_op = (fin0));
  (fin_k_ret = (pipeline_expr_kind_ord_at(arena, fin0)));
  (void)(({ int32_t __tmp = 0; if (fin_k_ret == 41) {   (fin_op = (pipeline_expr_unary_operand_ref_at(arena, fin0)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_return_operand_matches(arena, fin_op, return_type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (eb_fin = (driver_typeck_diag_scratch_expect()));
  (gb_fin = (driver_typeck_diag_scratch_found()));
  (el_fin = (typeck_diag_fmt_type_or_question(arena, return_type_ref, eb_fin)));
  (gl_fin = (typeck_diag_fmt_type_or_question(arena, got, gb_fin)));
  (void)(driver_diagnostic_typeck_return_mismatch(0, 0, eb_fin, el_fin, gb_fin, gl_fin));
  return (-1);
}
int32_t typeck_check_block_one_region(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  return pipeline_typeck_check_block_one_region_c(module, arena, block_ref, idx, return_type_ref, ctx);
}
int32_t typeck_check_block_stmt_order_one(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t si, int32_t nso, int32_t nc, int32_t nl, int32_t nes, int32_t nlp, int32_t nfp, int32_t nif, int32_t nreg) {
  uint8_t sk = ((uint8_t)(0));
  int32_t idx = 0;
  int32_t es_ref = 0;
  (void)(({ int32_t __tmp = 0; if (si >= nso || si >= 96) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_typeck_block_impl_touch_ctx_block_c(ctx, block_ref));
  (sk = (ast_block_stmt_order_kind(arena, block_ref, si)));
  (idx = (ast_block_stmt_order_idx(arena, block_ref, si)));
  (void)(({ int32_t __tmp = 0; if (sk == ((uint8_t)(0))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nc && idx < 128) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(1))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nl && idx < 128) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(2))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nes) {   (es_ref = (ast_block_expr_stmt_ref(arena, block_ref, idx)));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(3))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nlp) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(4))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nfp) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(5))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nif) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == ((uint8_t)(6))) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nreg) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_one_region(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  return typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, si + 1, nso, nc, nl, nes, nlp, nfp, nif, nreg);
}
int32_t typeck_check_block_legacy_consts(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nc) {
  (void)(({ int32_t __tmp = 0; if (i >= nc) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_consts(module, arena, block_ref, return_type_ref, ctx, i + 1, nc);
}
int32_t typeck_check_block_legacy_lets(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nl) {
  (void)(({ int32_t __tmp = 0; if (i >= nl) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_lets(module, arena, block_ref, return_type_ref, ctx, i + 1, nl);
}
int32_t typeck_check_block_legacy_whiles(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nlp) {
  (void)(({ int32_t __tmp = 0; if (i >= nlp) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_whiles(module, arena, block_ref, return_type_ref, ctx, i + 1, nlp);
}
int32_t typeck_check_block_legacy_fors(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nfp) {
  (void)(({ int32_t __tmp = 0; if (i >= nfp) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_fors(module, arena, block_ref, return_type_ref, ctx, i + 1, nfp);
}
int32_t typeck_check_block_legacy_ifs(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nif) {
  (void)(({ int32_t __tmp = 0; if (i >= nif) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_ifs(module, arena, block_ref, return_type_ref, ctx, i + 1, nif);
}
int32_t typeck_check_block_legacy_expr_stmts(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t i, int32_t nes) {
  int32_t es_ref = 0;
  (void)(({ int32_t __tmp = 0; if (i >= nes || i >= 32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (es_ref = (ast_block_expr_stmt_ref(arena, block_ref, i)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_legacy_expr_stmts(module, arena, block_ref, return_type_ref, ctx, i + 1, nes);
}
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t saved_block_ref = 0;
  int32_t nc = 0;
  int32_t nl = 0;
  int32_t nlp = 0;
  int32_t nfp = 0;
  int32_t nif = 0;
  int32_t nreg = 0;
  int32_t nes = 0;
  int32_t nso = 0;
  int32_t fin0 = 0;
  int32_t func_ix = 0;
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0)) || block_ref <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (saved_block_ref = (pipeline_typeck_block_impl_bind_ctx_c(ctx, block_ref)));
  (nc = (ast_block_num_consts(arena, block_ref)));
  (nl = (ast_block_num_lets(arena, block_ref)));
  (nlp = (ast_block_num_loops(arena, block_ref)));
  (nfp = (ast_block_num_for_loops(arena, block_ref)));
  (nif = (ast_block_num_if_stmts(arena, block_ref)));
  (nreg = (ast_block_num_regions(arena, block_ref)));
  (nes = (ast_block_num_expr_stmts(arena, block_ref)));
  (nso = (ast_block_num_stmt_order(arena, block_ref)));
  (fin0 = (ast_block_final_expr_ref(arena, block_ref)));
  (func_ix = (pipeline_dep_ctx_current_func_index(ctx)));
  (void)(driver_diagnostic_typeck_block_enter(func_ix, block_ref, nc, nl, nlp, nfp, nes, fin0));
  (void)(({ int32_t __tmp = 0; if (nso > 0) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, 0, nso, nc, nl, nes, nlp, nfp, nif, nreg) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (typeck_check_block_legacy_consts(module, arena, block_ref, return_type_ref, ctx, 0, nc) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_legacy_lets(module, arena, block_ref, return_type_ref, ctx, 0, nl) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_legacy_whiles(module, arena, block_ref, return_type_ref, ctx, 0, nlp) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_legacy_fors(module, arena, block_ref, return_type_ref, ctx, 0, nfp) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_legacy_ifs(module, arena, block_ref, return_type_ref, ctx, 0, nif) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_legacy_expr_stmts(module, arena, block_ref, return_type_ref, ctx, 0, nes) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block_final(module, arena, block_ref, return_type_ref, ctx, fin0) != 0) {   (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref));
  return 0;
}
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(block_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || block_ref <= 0 || block_ref > (arena)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_impl(module, arena, block_ref, return_type_ref, ctx);
}
int32_t typeck_sx_ast_check_one_func(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t func_idx) {
  int32_t body_ref = 0;
  int32_t ret_ty_ref = 0;
  int32_t fn_name_len = 0;
  int32_t ord_void = 16;
  int32_t rt_kind = 0;
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_typeck_linear_reset_c());
  (body_ref = (pipeline_module_func_body_ref_at(module, func_idx)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(body_ref) || pipeline_module_func_is_extern_at(module, func_idx) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (ret_ty_ref = (pipeline_module_func_return_type_at(module, func_idx)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, body_ref, ret_ty_ref, ctx) != 0) {   (fn_name_len = (pipeline_module_func_name_len_at(module, func_idx)));
  (void)(pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0)));
  int32_t fail_kind_cb = -5;
  (void)(driver_diagnostic_typeck_func_fail(func_idx, typeck_scratch64_slot(0), fn_name_len, fail_kind_cb));
  return fail_kind_cb;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ret_ty_ref))) {   (rt_kind = (pipeline_type_kind_ord_at(arena, ret_ty_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rt_kind != ord_void && typeck_func_body_has_implicit_return_tail(arena, body_ref)) {   (fn_name_len = (pipeline_module_func_name_len_at(module, func_idx)));
  (void)(pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0)));
  int32_t fail_kind_tail = -6;
  (void)(driver_diagnostic_typeck_func_fail(func_idx, typeck_scratch64_slot(0), fn_name_len, fail_kind_tail));
  return fail_kind_tail;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_sx_ast_check_all_funcs_loop(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t func_i, int32_t num_funcs) {
  int32_t body_ref = 0;
  int32_t ret_ty_ref = 0;
  int32_t fn_name_len = 0;
  int32_t ord_void = 16;
  int32_t rt_kind = 0;
  int32_t rc = 0;
  int32_t no_func_ix = -1;
  (void)(({ int32_t __tmp = 0; if (func_i >= num_funcs) {   (void)(pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_dep_ctx_set_current_func_index(ctx, func_i));
  (body_ref = (pipeline_module_func_body_ref_at(module, func_i)));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(body_ref)) && pipeline_module_func_is_extern_at(module, func_i) == 0) {   (ret_ty_ref = (pipeline_module_func_return_type_at(module, func_i)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, body_ref, ret_ty_ref, ctx) != 0) {   (fn_name_len = (pipeline_module_func_name_len_at(module, func_i)));
  (void)(pipeline_module_func_name_copy64(module, func_i, typeck_scratch64_slot(0)));
  int32_t fail_kind_cb = -5;
  (void)(driver_diagnostic_typeck_func_fail(func_i, typeck_scratch64_slot(0), fn_name_len, fail_kind_cb));
  (void)(pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix));
  return fail_kind_cb;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ret_ty_ref))) {   (rt_kind = (pipeline_type_kind_ord_at(arena, ret_ty_ref)));
  __tmp = ({ int32_t __tmp = 0; if (rt_kind != ord_void && typeck_func_body_has_implicit_return_tail(arena, body_ref)) {   (fn_name_len = (pipeline_module_func_name_len_at(module, func_i)));
  (void)(pipeline_module_func_name_copy64(module, func_i, typeck_scratch64_slot(0)));
  int32_t fail_kind_tail = -6;
  (void)(driver_diagnostic_typeck_func_fail(func_i, typeck_scratch64_slot(0), fn_name_len, fail_kind_tail));
  (void)(pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix));
  return fail_kind_tail;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix));
  (rc = (typeck_sx_ast_check_all_funcs_loop(module, arena, ctx, func_i + 1, num_funcs)));
  return rc;
}
void typeck_patch_all_body_parent_links(struct ast_Module * module, struct ast_ASTArena * arena) {
  int32_t i = 0;
  int32_t num = 0;
  int32_t br = 0;
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (num = (pipeline_module_num_funcs(module)));
  while (i < num) {
    (br = (pipeline_module_func_body_ref_at(module, i)));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(br))) {   (void)(pipeline_patch_block_parent_links(arena, br, 0));
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
}
int32_t typeck_sx_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t mi = 0;
  int32_t ret_kind = 0;
  int32_t ord_i32 = 0;
  int32_t ord_i64 = 5;
  int32_t body_ref = 0;
  int32_t body_expr_ref = 0;
  int32_t ret_ty = 0;
  int32_t num_funcs = 0;
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (mi = (pipeline_module_main_func_index(module)));
  (void)(({ int32_t __tmp = 0; if (pipeline_module_func_is_extern_at(module, mi) != 0 && ast_ref_is_null(pipeline_module_func_body_ref_at(module, mi))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (body_ref = (pipeline_module_func_body_ref_at(module, mi)));
  (body_expr_ref = (pipeline_module_func_body_expr_ref_at(module, mi)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(body_ref) && ast_ref_is_null(body_expr_ref)) {   return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (ret_ty = (pipeline_module_func_return_type_at(module, mi)));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ret_ty)) {   return (-3);
 } else (__tmp = 0) ; __tmp; }));
  (ret_kind = (pipeline_type_kind_ord_at(arena, ret_ty)));
  (void)(({ int32_t __tmp = 0; if (ret_kind != ord_i32 && ret_kind != ord_i64) {   return (-4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(typeck_patch_all_body_parent_links(module, arena));
  (num_funcs = (pipeline_module_num_funcs(module)));
  return typeck_sx_ast_check_all_funcs_loop(module, arena, ctx, 0, num_funcs);
}
int32_t typeck_sx_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t num_funcs = 0;
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return (-5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(typeck_patch_all_body_parent_links(module, arena));
  (num_funcs = (pipeline_module_num_funcs(module)));
  return typeck_sx_ast_check_all_funcs_loop(module, arena, ctx, 0, num_funcs);
}
int32_t typeck_sx_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t mi = 0;
  int32_t num_funcs = 0;
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0))) {   return (-10);
 } else (__tmp = 0) ; __tmp; }));
  (mi = (pipeline_module_main_func_index(module)));
  (num_funcs = (pipeline_module_num_funcs(module)));
  (void)(({ int32_t __tmp = 0; if (mi < 0) {   return (-10);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (mi >= num_funcs) {   return (-11);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_sx_ast_impl(module, arena, ctx);
}
