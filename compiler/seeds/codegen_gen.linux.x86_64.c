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
/** bootstrap 最小单测：未链 std.io 时提供 weak 桩，避免 ld 缺 io_register_buffers_buf_c。 */
__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }
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
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; int32_t packed; int32_t repr_compatible; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t pending_soa_struct; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };
extern int ast_ref_is_null(int32_t ref);

/* ast gen2 late link aliases */
#define ast_block_num_lets ast_ast_block_num_lets
#define ast_block_num_stmt_order ast_ast_block_num_stmt_order
#define ast_block_stmt_order_kind ast_ast_block_stmt_order_kind
#define ast_block_stmt_order_idx ast_ast_block_stmt_order_idx
#define ast_block_num_consts ast_ast_block_num_consts
#define ast_block_num_expr_stmts ast_ast_block_num_expr_stmts
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_block_while_cond_ref ast_ast_block_while_cond_ref
#define ast_block_while_body_ref ast_ast_block_while_body_ref
#define ast_block_for_init_ref ast_ast_block_for_init_ref
#define ast_block_for_cond_ref ast_ast_block_for_cond_ref
#define ast_block_for_step_ref ast_ast_block_for_step_ref
#define ast_block_for_body_ref ast_ast_block_for_body_ref
#define ast_block_num_if_stmts ast_ast_block_num_if_stmts
#define ast_block_if_cond_ref ast_ast_block_if_cond_ref
#define ast_block_if_then_body_ref ast_ast_block_if_then_body_ref
#define ast_block_if_else_body_ref ast_ast_block_if_else_body_ref
#define ast_block_num_regions ast_ast_block_num_regions
#define ast_block_region_body_ref ast_ast_block_region_body_ref
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_block_get ast_ast_arena_block_get
#define ast_arena_func_get ast_ast_arena_func_get

/* ast gen2 single-prefix externs */
extern struct ast_Expr ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern struct ast_Type ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern struct ast_Block ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern struct ast_Func ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_else_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_num_regions(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_region_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ri);

/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */
#define pipeline_dep_ctx_import_path_len ast_pipeline_dep_ctx_import_path_len
#define pipeline_dep_ctx_import_path_copy64 ast_pipeline_dep_ctx_import_path_copy64
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_module_at ast_pipeline_dep_ctx_module_at
#define pipeline_expr_array_lit_num_elems_at ast_pipeline_expr_array_lit_num_elems_at
#define pipeline_expr_array_lit_elem_ref ast_pipeline_expr_array_lit_elem_ref
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_name_into ast_pipeline_module_struct_layout_name_into
#define pipeline_module_enum_name_len ast_pipeline_module_enum_name_len
#define pipeline_module_enum_name_byte_at ast_pipeline_module_enum_name_byte_at
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_field_name_into ast_pipeline_module_struct_layout_field_name_into
#define pipeline_block_let_name_len ast_pipeline_block_let_name_len
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_binding_name_len ast_pipeline_module_import_binding_name_len
#define pipeline_module_import_binding_name_byte_at ast_pipeline_module_import_binding_name_byte_at
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_module_import_select_name_len ast_pipeline_module_import_select_name_len
#define pipeline_module_import_select_name_byte_at ast_pipeline_module_import_select_name_byte_at
#define pipeline_dep_ctx_arena_at ast_pipeline_dep_ctx_arena_at
#define pipeline_module_func_ref_at ast_pipeline_module_func_ref_at
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_block_const_name_len ast_pipeline_block_const_name_len
#define pipeline_block_const_type_ref ast_pipeline_block_const_type_ref
#define pipeline_block_const_init_ref ast_pipeline_block_const_init_ref
#define pipeline_block_const_name_copy64 ast_pipeline_block_const_name_copy64
#define pipeline_block_let_type_ref ast_pipeline_block_let_type_ref
#define pipeline_block_let_init_ref ast_pipeline_block_let_init_ref
#define pipeline_block_let_name_copy64 ast_pipeline_block_let_name_copy64
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_func_body_expr_ref_at ast_pipeline_module_func_body_expr_ref_at
#define pipeline_module_top_level_let_is_const ast_pipeline_module_top_level_let_is_const
#define pipeline_module_top_level_let_name_len ast_pipeline_module_top_level_let_name_len
#define pipeline_module_top_level_let_name_byte_at ast_pipeline_module_top_level_let_name_byte_at
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
#define pipeline_module_top_level_let_init_ref ast_pipeline_module_top_level_let_init_ref

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_type_named_name_into pipeline_type_named_name_into
#define ast_pipeline_type_kind_ord_at pipeline_type_kind_ord_at
#define ast_pipeline_type_elem_ref_at pipeline_type_elem_ref_at
#define ast_pipeline_type_array_size_at pipeline_type_array_size_at
#define ast_pipeline_expr_kind_ord_at pipeline_expr_kind_ord_at
#define ast_pipeline_expr_struct_lit_field_name_len pipeline_expr_struct_lit_field_name_len
#define ast_pipeline_expr_struct_lit_field_name_into pipeline_expr_struct_lit_field_name_into
#define ast_pipeline_expr_struct_lit_init_ref pipeline_expr_struct_lit_init_ref
#define ast_pipeline_expr_struct_lit_num_fields pipeline_expr_struct_lit_num_fields
#define ast_pipeline_module_func_name_copy64 pipeline_module_func_name_copy64
#define ast_pipeline_module_func_param_name_copy32 pipeline_module_func_param_name_copy32
#define ast_pipeline_module_func_num_params_at pipeline_module_func_num_params_at
#define ast_pipeline_module_func_param_name_len_at pipeline_module_func_param_name_len_at
#define ast_pipeline_module_func_name_len_at pipeline_module_func_name_len_at
#define ast_pipeline_module_func_body_ref_at pipeline_module_func_body_ref_at
#define ast_pipeline_dep_ctx_empty_param_reset pipeline_dep_ctx_empty_param_reset
#define ast_pipeline_dep_ctx_empty_param_append pipeline_dep_ctx_empty_param_append
#define ast_pipeline_dep_ctx_empty_param_at pipeline_dep_ctx_empty_param_at
#define ast_pipeline_dep_ctx_empty_param_backup pipeline_dep_ctx_empty_param_backup
#define ast_pipeline_dep_ctx_empty_param_restore pipeline_dep_ctx_empty_param_restore
#define ast_pipeline_module_func_is_extern_at pipeline_module_func_is_extern_at
#define ast_pipeline_module_func_param_type_ref_at pipeline_module_func_param_type_ref_at
struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t target_cpu_features; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; int32_t typeck_scope_region_len; uint8_t typeck_scope_region_label[64]; };

/* pipeline glue usage aliases */
extern int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
#define pipeline_block_const_init_ref ast_pipeline_block_const_init_ref
#define pipeline_block_const_name_copy64 ast_pipeline_block_const_name_copy64
#define pipeline_block_const_name_len ast_pipeline_block_const_name_len
#define pipeline_block_const_type_ref ast_pipeline_block_const_type_ref
#define pipeline_block_if_cond_ref ast_pipeline_block_if_cond_ref
#define pipeline_block_if_else_body_ref ast_pipeline_block_if_else_body_ref
#define pipeline_block_if_then_body_ref ast_pipeline_block_if_then_body_ref
#define pipeline_block_let_init_ref ast_pipeline_block_let_init_ref
#define pipeline_block_let_name_copy64 ast_pipeline_block_let_name_copy64
#define pipeline_block_let_name_len ast_pipeline_block_let_name_len
#define pipeline_block_let_type_ref ast_pipeline_block_let_type_ref
#define pipeline_dep_ctx_import_path_copy64 ast_pipeline_dep_ctx_import_path_copy64
#define pipeline_dep_ctx_import_path_len ast_pipeline_dep_ctx_import_path_len
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_expr_array_lit_elem_ref ast_pipeline_expr_array_lit_elem_ref
#define pipeline_expr_array_lit_num_elems_at ast_pipeline_expr_array_lit_num_elems_at
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_module_enum_name_byte_at ast_pipeline_module_enum_name_byte_at
#define pipeline_module_enum_name_len ast_pipeline_module_enum_name_len
#define pipeline_module_func_body_expr_ref_at ast_pipeline_module_func_body_expr_ref_at
#define pipeline_module_func_ref_at ast_pipeline_module_func_ref_at
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_import_binding_name_byte_at ast_pipeline_module_import_binding_name_byte_at
#define pipeline_module_import_binding_name_len ast_pipeline_module_import_binding_name_len
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_module_import_select_name_byte_at ast_pipeline_module_import_select_name_byte_at
#define pipeline_module_import_select_name_len ast_pipeline_module_import_select_name_len
#define pipeline_module_struct_layout_field_name_into ast_pipeline_module_struct_layout_field_name_into
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_name_into ast_pipeline_module_struct_layout_name_into
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_top_level_let_init_ref ast_pipeline_module_top_level_let_init_ref
#define pipeline_module_top_level_let_is_const ast_pipeline_module_top_level_let_is_const
#define pipeline_module_top_level_let_name_byte_at ast_pipeline_module_top_level_let_name_byte_at
#define pipeline_module_top_level_let_name_len ast_pipeline_module_top_level_let_name_len
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
extern int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern struct ast_Module * ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void ast_pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern int32_t ast_pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t li, int32_t j, uint8_t * out64);
extern int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern struct ast_ASTArena * ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t ast_pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
extern int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void ast_pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern void ast_pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t ast_pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
struct codegen_CodegenOutBuf { uint8_t data[9437184]; int32_t len; };
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out64);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t layout_idx, int32_t field_idx, uint8_t * out64);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern uint8_t * driver_get_current_dep_path_for_codegen();
extern void driver_diagnostic_codegen_emit_func_fail(void *module, int32_t func_index);
extern int32_t pipeline_codegen_emit_seed_mega_enabled(void);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j, uint8_t * out);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
extern void pipeline_module_func_name_copy64(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern void pipeline_module_func_param_name_copy32(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module * module, int32_t fi);
extern void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx * ctx, int32_t pi);
extern int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_if_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path);
int32_t codegen_path_is_std_io_core_bytes(uint8_t * path);
void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap);
int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst);
int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap);
int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx);
int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len);
int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args);
int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len);
int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len);
int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len);
int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len);
int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len);
int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args);
int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args);
int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len);
int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref);
int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref);
int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b);
int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b);
int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t buf[32], int32_t len);
int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t buf[22], int32_t len);
int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t buf[9], int32_t len);
int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t buf[8], int32_t len);
int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t buf[7], int32_t len);
int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t buf[6], int32_t len);
int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t buf[5], int32_t len);
int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t buf[4], int32_t len);
int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t buf[3], int32_t len);
int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t buf[2], int32_t len);
int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val);
int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int32_t val);
int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent);
int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, enum ast_TypeKind kind);
int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, enum ast_TypeKind kind);
int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, enum ast_TypeKind elem_kind, int32_t lanes);
int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref);
int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx);
int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref);
int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx);
int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len);
int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_codegen_emit_expr_try_propagate_c(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
/** let s: T[] = arr：C glue（pipeline_glue.c），seed 未 regen 时补齐 slice 初值。 */
extern int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t let_idx, int32_t let_type_ref, int32_t linit_ref);
int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t codegen_callee_var_is_string_new(struct ast_Expr e);
int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx);
void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst);
void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals);
int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
int32_t codegen_sx_ast_emit_header(struct codegen_CodegenOutBuf * out);
int32_t codegen_sx_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index);
int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len);
int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len);
int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len);
int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path) {
  uint8_t expect[14] = { 115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0 };
  int32_t i = 0;
  (void)(({ int32_t __tmp = 0; if (path == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  while (i < 14) {
    (void)(({ int32_t __tmp = 0; if ((path)[i] != (expect)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t codegen_path_is_std_io_core_bytes(uint8_t * path) {
  uint8_t expect[12] = { 115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0 };
  int32_t i = 0;
  int32_t pi = 0;
  int32_t ei = 0;
  (void)(({ int32_t __tmp = 0; if (path == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  while (i < 12) {
    (pi = (((int32_t)((path)[i]))));
    (ei = (((int32_t)((expect)[i]))));
    (void)(({ int32_t __tmp = 0; if (pi != ei) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap) {
  (void)(({ int32_t __tmp = 0; if (buf == ((uint8_t *)(0)) || buf_cap <= 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t off = 0;
  int32_t pi = 0;
  while (path != ((uint8_t *)(0))) {
    uint8_t ch = (path)[pi];
    (void)(({ int32_t __tmp = 0; if (ch == ((uint8_t)(0))) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (off + 2 >= buf_cap) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ uint8_t __tmp = 0; if (ch == ((uint8_t)(46))) {   ((buf)[off] = (((uint8_t)(95))));
 } else {   ((buf)[off] = (ch));
 } ; __tmp; }));
    ++off;
    ++pi;
  }
  (void)(({ int32_t __tmp = 0; if (off + 1 < buf_cap) {   ((buf)[off] = (((uint8_t)(95))));
  ++off;
 } else (__tmp = 0) ; __tmp; }));
  ((buf)[off] = (((uint8_t)(0))));
}
int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst) {
  int32_t plen = pipeline_dep_ctx_import_path_len(ctx, idx);
  (void)(({ int32_t __tmp = 0; if (plen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_dep_ctx_import_path_copy64(ctx, idx, dst));
  return plen;
}
int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst) {
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nd = pipeline_dep_ctx_ndep(ctx);
  int32_t j = 0;
  while (j < nd) {
    (void)(({ int32_t __tmp = 0; if (pipeline_dep_ctx_module_at(ctx, j) == (ctx)->current_codegen_module) {   return codegen_dep_import_path_len_at(ctx, j, dst);
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  return 0;
}
int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap) {
  (void)(({ int32_t __tmp = 0; if (buf == ((uint8_t *)(0)) || buf_cap <= 0 || ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  ((buf)[0] = (((uint8_t)(0))));
  (void)(({ int32_t __tmp = 0; if ((ctx)->current_codegen_prefix_len > 0) {   int32_t pi = 0;
  while (pi < (ctx)->current_codegen_prefix_len && pi < buf_cap - 1) {
    ((buf)[pi] = ((pi < 0 || (pi) >= 64 ? (shux_panic_(1, 0), ((ctx)->current_codegen_prefix_mirror)[0]) : ((ctx)->current_codegen_prefix_mirror)[pi])));
    ++pi;
  }
  ((buf)[pi] = (((uint8_t)(0))));
  return pi;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t path_buf[64] = { 0 };
  int32_t path_len = 0;
  (void)(({ int32_t __tmp = 0; if ((ctx)->current_codegen_dep_index >= 0) {   (path_len = (codegen_dep_import_path_len_at(ctx, (ctx)->current_codegen_dep_index, (&((path_buf)[0])))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (path_len == 0) {   (path_len = (codegen_ctx_dep_path_for_current_codegen_module_into(ctx, (&((path_buf)[0])))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (path_len == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_path_is_std_io_core_bytes((&((path_buf)[0]))) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(codegen_import_path_to_c_prefix_into((&((path_buf)[0])), buf, buf_cap));
  int32_t i = 0;
  while (i < buf_cap && (buf)[i] != ((uint8_t)(0))) {
    ++i;
  }
  return i;
}
int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(var_ref) || var_ref <= 0 || var_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (func_index < 0 || func_index >= (mod)->num_funcs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t np = pipeline_module_func_num_params_at(mod, func_index);
  (void)(({ int32_t __tmp = 0; if (param_idx < 0 || param_idx >= np) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base = ast_arena_expr_get(arena, var_ref);
  (void)(({ int32_t __tmp = 0; if ((base).kind != ast_ExprKind_EXPR_VAR) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
  (void)(({ int32_t __tmp = 0; if (p_name_len > 0) {   uint8_t pname_buf[32] = { 0 };
  (void)(pipeline_module_func_param_name_copy32(mod, func_index, param_idx, (&((pname_buf)[0]))));
  __tmp = ({ int32_t __tmp = 0; if ((pname_buf)[0] > 32) {   (void)(({ int32_t __tmp = 0; if ((base).var_name_len != p_name_len) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((base).var_name_len <= 0 || ((base).var_name)[0] <= 32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < p_name_len) {
    (void)(({ int32_t __tmp = 0; if ((j < 0 || (j) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[j]) != (j < 0 || (j) >= 32 ? (shux_panic_(1, 0), (pname_buf)[0]) : (pname_buf)[j])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ctx)->current_func_single_empty_param_index != param_idx) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((base).var_name_len <= 0 || ((base).var_name)[0] <= 32) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len) {
  (void)(({ int32_t __tmp = 0; if (buf == ((uint8_t *)(0)) || lit == ((uint8_t *)(0)) || buf_len != lit_len) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < lit_len) {
    (void)(({ int32_t __tmp = 0; if ((buf)[i] != (lit)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args) {
  (void)(({ int32_t __tmp = 0; if (num_args <= 0) {   return num_args;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t buf[96] = { 0 };
  int32_t full = 0;
  int32_t i = 0;
  (void)(({ int32_t __tmp = 0; if (prefix != ((uint8_t *)(0)) && prefix_len > 0) {   (i = (0));
  while (i < prefix_len && full < 96) {
    ((full < 0 || (full) >= 96 ? (shux_panic_(1, 0), 0) : ((buf)[full] = (prefix)[i], 0)));
    ++full;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name != ((uint8_t *)(0)) && name_len > 0) {   (i = (0));
  while (i < name_len && full < 96) {
    ((full < 0 || (full) >= 96 ? (shux_panic_(1, 0), 0) : ((buf)[full] = (name)[i], 0)));
    ++full;
    ++i;
  }
 } else (__tmp = 0) ; __tmp; }));
  uint8_t z0[13] = { 118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121 };
  uint8_t z1[21] = { 115, 116, 100, 95, 118, 101, 99, 95, 118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121 };
  uint8_t z2[15] = { 97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111 };
  uint8_t z3[24] = { 115, 116, 100, 95, 104, 101, 97, 112, 95, 97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111 };
  uint8_t z4[13] = { 114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121 };
  uint8_t z5[25] = { 115, 116, 100, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121 };
  uint8_t z6[10] = { 115, 116, 114, 105, 110, 103, 95, 110, 101, 119 };
  uint8_t z7[21] = { 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 95, 110, 101, 119 };
  uint8_t z8[11] = { 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114 };
  uint8_t z9[22] = { 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114 };
  uint8_t z10[11] = { 116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102 };
  uint8_t z11[22] = { 115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102 };
  uint8_t z12[22] = { 116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114 };
  uint8_t z13[33] = { 115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114 };
  uint8_t z14[16] = { 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115 };
  uint8_t z15[25] = { 115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115 };
  uint8_t z16[16] = { 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115 };
  uint8_t z17[25] = { 115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115 };
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z0)[0])), 13) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z1)[0])), 21) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z2)[0])), 15) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z3)[0])), 24) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z4)[0])), 13) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z5)[0])), 25) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z6)[0])), 10) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z7)[0])), 21) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z8)[0])), 11) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z9)[0])), 22) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z10)[0])), 11) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z11)[0])), 22) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z12)[0])), 22) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z13)[0])), 33) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z14)[0])), 16) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z15)[0])), 25) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z16)[0])), 16) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((z17)[0])), 25) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args >= 1) {   uint8_t o0[7] = { 102, 109, 116, 95, 105, 51, 50 };
  uint8_t o1[16] = { 99, 111, 114, 101, 95, 102, 109, 116, 95, 102, 109, 116, 95, 105, 51, 50 };
  uint8_t o2[9] = { 112, 114, 105, 110, 116, 95, 105, 51, 50 };
  uint8_t o3[16] = { 115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 51, 50 };
  uint8_t o4[9] = { 112, 114, 105, 110, 116, 95, 117, 51, 50 };
  uint8_t o5[16] = { 115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 117, 51, 50 };
  uint8_t o6[9] = { 112, 114, 105, 110, 116, 95, 105, 54, 52 };
  uint8_t o7[16] = { 115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 54, 52 };
  uint8_t o8[6] = { 111, 107, 95, 105, 51, 50 };
  uint8_t o9[18] = { 99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 111, 107, 95, 105, 51, 50 };
  uint8_t o10[7] = { 101, 114, 114, 95, 105, 51, 50 };
  uint8_t o11[19] = { 99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 101, 114, 114, 95, 105, 51, 50 };
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o0)[0])), 7) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o1)[0])), 16) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o2)[0])), 9) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o3)[0])), 16) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o4)[0])), 9) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o5)[0])), 16) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o6)[0])), 9) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o7)[0])), 16) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o8)[0])), 6) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o9)[0])), 18) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o10)[0])), 7) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_symbuf_bytes_eq((&((buf)[0])), full, (&((o11)[0])), 19) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return num_args;
}
int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len) {
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0)) || expect == ((uint8_t *)(0)) || name_len < exp_len) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < exp_len) {
    (void)(({ int32_t __tmp = 0; if ((name)[i] != (expect)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm8[8] = { 114, 101, 103, 105, 115, 116, 101, 114 };
  (void)(({ int32_t __tmp = 0; if (name_len == 8 || name_len == 9 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm8)[0])), 8) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm11[11] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  (void)(({ int32_t __tmp = 0; if (name_len == 11 || name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm11)[0])), 11) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm12[12] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  (void)(({ int32_t __tmp = 0; if (name_len == 12 || name_len == 13 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm12)[0])), 12) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm13[13] = { 119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101 };
  (void)(({ int32_t __tmp = 0; if (name_len == 13 || name_len == 14 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm13)[0])), 13) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm22[22] = { 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115 };
  (void)(({ int32_t __tmp = 0; if (name_len == 22 || name_len == 23 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm22)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm17[17] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104 };
  (void)(({ int32_t __tmp = 0; if (name_len == 17 || name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm17)[0])), 17) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm18w[18] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104 };
  (void)(({ int32_t __tmp = 0; if (name_len == 18 || name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm18w)[0])), 18) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_core[11] = { 115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101 };
  uint8_t n_rf[17] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100 };
  uint8_t n_wf[18] = { 115, 104, 117, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100 };
  uint8_t n_srb[24] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104 };
  uint8_t n_swb[25] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104 };
  uint8_t n_sr[18] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t n_sw[19] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  int32_t di = 0;
  (void)(({ int32_t __tmp = 0; if (dep_path == ((uint8_t *)(0)) || name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  while (di < 11) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di] != (path_core)[di]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  (void)(({ int32_t __tmp = 0; if (name_len == 17 || name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_rf)[0])), 17) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 18 || name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_wf)[0])), 18) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 24 || name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_srb)[0])), 24) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 25 || name_len == 26 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_swb)[0])), 25) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 18 || name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_sr)[0])), 18) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 19 || name_len == 20 && codegen_name_bytes_prefix_eq(name, name_len, (&((n_sw)[0])), 19) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_io[7] = { 115, 116, 100, 46, 105, 111, 0 };
  uint8_t h_stdin[12] = { 104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110 };
  uint8_t h_stdout[13] = { 104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116 };
  uint8_t h_stderr[13] = { 104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114 };
  uint8_t h_from_fd[15] = { 104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0 };
  int32_t di = 0;
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_path != ((uint8_t *)(0))) {   while (di < 7) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di] != (path_io)[di]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 12 || name_len == 13 && codegen_name_bytes_prefix_eq(name, name_len, (&((h_stdin)[0])), 12) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 13 || name_len == 14 && codegen_name_bytes_prefix_eq(name, name_len, (&((h_stdout)[0])), 13) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 13 || name_len == 14 && codegen_name_bytes_prefix_eq(name, name_len, (&((h_stderr)[0])), 13) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 15 || name_len == 16 && codegen_name_bytes_prefix_eq(name, name_len, (&((h_from_fd)[0])), 15) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t full33[33] = { 115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110 };
  uint8_t full29[29] = { 115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114 };
  uint8_t path_driver[14] = { 115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0 };
  uint8_t path_io[7] = { 115, 116, 100, 46, 105, 111, 0 };
  uint8_t nm_len19[19] = { 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110 };
  uint8_t nm_len15[15] = { 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114 };
  int32_t pi = 0;
  int32_t ni = 0;
  int32_t ok_path = 0;
  int32_t di = 0;
  (void)(({ int32_t __tmp = 0; if (prefix != ((uint8_t *)(0)) && prefix_len > 0 && name != ((uint8_t *)(0)) && name_len > 0) {   int32_t total_len = prefix_len + name_len;
  (void)(({ int32_t __tmp = 0; if (total_len == 33) {   (pi = (0));
  while (pi < prefix_len) {
    (void)(({ int32_t __tmp = 0; if ((prefix)[pi] != (pi < 0 || (pi) >= 33 ? (shux_panic_(1, 0), (full33)[0]) : (full33)[pi])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++pi;
  }
  (ni = (0));
  while (ni < name_len) {
    (void)(({ int32_t __tmp = 0; if ((name)[ni] != (prefix_len + ni < 0 || (prefix_len + ni) >= 33 ? (shux_panic_(1, 0), (full33)[0]) : (full33)[prefix_len + ni])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++ni;
  }
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (total_len == 29) {   (pi = (0));
  while (pi < prefix_len) {
    (void)(({ int32_t __tmp = 0; if ((prefix)[pi] != (pi < 0 || (pi) >= 29 ? (shux_panic_(1, 0), (full29)[0]) : (full29)[pi])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++pi;
  }
  (ni = (0));
  while (ni < name_len) {
    (void)(({ int32_t __tmp = 0; if ((name)[ni] != (prefix_len + ni < 0 || (prefix_len + ni) >= 29 ? (shux_panic_(1, 0), (full29)[0]) : (full29)[prefix_len + ni])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++ni;
  }
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_path != ((uint8_t *)(0))) {   (ok_path = (0));
  (di = (0));
  while (di < 14) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di] != (path_driver)[di]) {   (ok_path = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  (void)(({ int32_t __tmp = 0; if (di == 14) {   (ok_path = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ok_path == 0) {   (di = (0));
  while (di < 7) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di] != (path_io)[di]) {   (ok_path = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  __tmp = ({ int32_t __tmp = 0; if (di == 7) {   (ok_path = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ok_path != 0 && name != ((uint8_t *)(0))) {   (void)(({ int32_t __tmp = 0; if (name_len == 19 || name_len == 20 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm_len19)[0])), 19) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (name_len == 15 || name_len == 16 && codegen_name_bytes_prefix_eq(name, name_len, (&((nm_len15)[0])), 15) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t pref_abi14[14] = { 115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95 };
  (void)(({ int32_t __tmp = 0; if (prefix != ((uint8_t *)(0)) && prefix_len == 14 && name != ((uint8_t *)(0)) && codegen_name_bytes_prefix_eq(prefix, prefix_len, (&((pref_abi14)[0])), 14) != 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_path != ((uint8_t *)(0)) && name != ((uint8_t *)(0))) {   int32_t ok_drv_only = 0;
  (di = (0));
  while (di < 14) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di] != (path_driver)[di]) {   (ok_drv_only = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++di;
  }
  (void)(({ int32_t __tmp = 0; if (di == 14) {   (ok_drv_only = (1));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ok_drv_only != 0 && codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (prefix != ((uint8_t *)(0)) && prefix_len == 14 && name != ((uint8_t *)(0))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_should_skip_emit_std_io_trivial_handle(((uint8_t *)(0)), name, name_len) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_path != ((uint8_t *)(0)) && name != ((uint8_t *)(0))) {   (void)(({ int32_t __tmp = 0; if (codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t path_driver[14] = { 115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0 };
  int32_t di2 = 0;
  while (di2 < 14) {
    (void)(({ int32_t __tmp = 0; if ((dep_path)[di2] != (path_driver)[di2]) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ++di2;
  }
  __tmp = ({ int32_t __tmp = 0; if (di2 == 14 && codegen_should_skip_emit_std_io_trivial_handle(((uint8_t *)(0)), name, name_len) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len) {
  uint8_t exp13[13] = { 115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114 };
  (void)(({ int32_t __tmp = 0; if (prefix == ((uint8_t *)(0)) || prefix_len < 13) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < 13) {
    (void)(({ int32_t __tmp = 0; if ((prefix)[i] != (exp13)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  (void)(({ int32_t __tmp = 0; if (prefix_len > 13) {   uint8_t b14 = (prefix)[13];
  __tmp = ({ int32_t __tmp = 0; if (b14 != ((uint8_t)(0)) && b14 != ((uint8_t)(95))) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd_batch[21] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  uint8_t wr_batch[22] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  (void)(({ int32_t __tmp = 0; if (param_index != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd_batch)[0])), 21) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr_batch)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  (void)(({ int32_t __tmp = 0; if (param_index != 1) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0)) || name_len != 9) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((name)[0] != 112 || (name)[1] != 114 || (name)[2] != 105 || (name)[3] != 110 || (name)[4] != 116 || (name)[5] != 95 || (name)[6] != 115 || (name)[7] != 116 || (name)[8] != 114) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t exp7[7] = { 115, 116, 100, 95, 105, 111, 95 };
  (void)(({ int32_t __tmp = 0; if (prefix == ((uint8_t *)(0)) || prefix_len < 7) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < 7) {
    (void)(({ int32_t __tmp = 0; if ((prefix)[i] != (exp7)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t reg8[8] = { 114, 101, 103, 105, 115, 116, 101, 114 };
  uint8_t rd11[11] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t wr12[12] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  (void)(({ int32_t __tmp = 0; if (param_index != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, (&((reg8)[0])), 8) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd11)[0])), 11) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr12)[0])), 12) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd11[11] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t wr12[12] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  uint8_t reg_fixed_buf[33] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102 };
  uint8_t rd_batch[21] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  uint8_t wr_batch[22] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  (void)(({ int32_t __tmp = 0; if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (param_index == 1) {   (void)(({ int32_t __tmp = 0; if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd11)[0])), 11) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr12)[0])), 12) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 33 && codegen_name_bytes_prefix_eq(name, name_len, (&((reg_fixed_buf)[0])), 33) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (param_index == 3) {   (void)(({ int32_t __tmp = 0; if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd_batch)[0])), 21) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr_batch)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args) {
  uint8_t reg15[15] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114 };
  uint8_t rd18[18] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t wr19[19] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0)) || name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 1 && name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, (&((reg15)[0])), 15) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 2 && name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd18)[0])), 18) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 2 && name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr19)[0])), 19) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args) {
  uint8_t reg8[8] = { 114, 101, 103, 105, 115, 116, 101, 114 };
  uint8_t rd11[11] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t wr12[12] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  uint8_t sym_reg[19] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102 };
  uint8_t sym_rd[22] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102 };
  uint8_t sym_wr[23] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102 };
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0)) || name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 1 && name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, (&((reg8)[0])), 8) != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_reg)[0])), 19) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 2 && name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd11)[0])), 11) != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_rd)[0])), 22) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (num_args == 2 && name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr12)[0])), 12) != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_wr)[0])), 23) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len) {
  uint8_t fn_local[64] = { 0 };
  int32_t fn_len = 0;
  int32_t nparams = 0;
  uint8_t p0[32] = { 98, 117, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  uint8_t p1[32] = { 116, 105, 109, 101, 111, 117, 116, 95, 109, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  uint8_t reg8[8] = { 114, 101, 103, 105, 115, 116, 101, 114 };
  uint8_t rd11[11] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100 };
  uint8_t wr12[12] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101 };
  uint8_t sym_reg[19] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102 };
  uint8_t sym_rd[22] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102 };
  uint8_t sym_wr[23] = { 115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102 };
  uint8_t ret_kw[8] = { 32, 32, 114, 101, 116, 117, 114, 110 };
  uint8_t close_b[3] = { 10, 125, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t p0_len = 3;
  int32_t p1_len = 10;
  (void)(pipeline_module_func_name_copy64(module, fi, (&((fn_local)[0]))));
  (fn_len = (pipeline_module_func_name_len_at(module, fi)));
  (nparams = (pipeline_module_func_num_params_at(module, fi)));
  (void)(({ int32_t __tmp = 0; if (pipeline_module_func_param_name_len_at(module, fi, 0) > 0) {   (void)(pipeline_module_func_param_name_copy32(module, fi, 0, (&((p0)[0]))));
  (p0_len = (pipeline_module_func_param_name_len_at(module, fi, 0)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nparams > 1 && pipeline_module_func_param_name_len_at(module, fi, 1) > 0) {   (void)(pipeline_module_func_param_name_copy32(module, fi, 1, (&((p1)[0]))));
  (p1_len = (pipeline_module_func_param_name_len_at(module, fi, 1)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (fn_len == 8 && codegen_name_bytes_prefix_eq((&((fn_local)[0])), fn_len, (&((reg8)[0])), 8) != 0 && nparams == 1) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((ret_kw)[0])), 8) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_reg)[0])), 19) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((p0)[0])), p0_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 59) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((close_b)[0])), 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (fn_len == 11 && codegen_name_bytes_prefix_eq((&((fn_local)[0])), fn_len, (&((rd11)[0])), 11) != 0 && nparams == 2) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((ret_kw)[0])), 8) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_rd)[0])), 22) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((p0)[0])), p0_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t comma[3] = { 44, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((p1)[0])), p1_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 59) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((close_b)[0])), 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (fn_len == 12 && codegen_name_bytes_prefix_eq((&((fn_local)[0])), fn_len, (&((wr12)[0])), 12) != 0 && nparams == 2) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((ret_kw)[0])), 8) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((sym_wr)[0])), 23) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((p0)[0])), p0_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t comma2[3] = { 44, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma2, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((p1)[0])), p1_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 59) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((close_b)[0])), 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base = ast_arena_expr_get(arena, base_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((base).resolved_type_ref) || (base).resolved_type_ref <= 0 || (base).resolved_type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ty = ast_arena_type_get(arena, (base).resolved_type_ref);
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_PTR) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base = ast_arena_expr_get(arena, base_ref);
  (void)(({ int32_t __tmp = 0; if ((base).kind != ast_ExprKind_EXPR_VAR || (base).var_name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((base).var_name_len == 6) {   __tmp = ({ int32_t __tmp = 0; if (((base).var_name)[0] == 115 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[1]) == 111 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[2]) == 117 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[3]) == 114 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[4]) == 99 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[5]) == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((base).var_name_len == 7) {   __tmp = ({ int32_t __tmp = 0; if (((base).var_name)[0] == 111 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[1]) == 117 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[2]) == 116 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[3]) == 95 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[4]) == 98 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[5]) == 117 && (6 < 0 || (6) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[6]) == 102) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (prefix == ((uint8_t *)(0)) || name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (prefix_len != 6) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((prefix)[0] != 98 || (prefix)[1] != 117 || (prefix)[2] != 105 || (prefix)[3] != 108 || (prefix)[4] != 100 || (prefix)[5] != 95) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len < prefix_len) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < prefix_len) {
    (void)(({ int32_t __tmp = 0; if ((name)[i] != (prefix)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b) {
  (void)(({ int32_t __tmp = 0; if ((out)->len >= 9437184) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (((out)->len < 0 || ((out)->len) >= 9437184 ? (shux_panic_(1, 0), 0) : (((out)->data)[(out)->len] = ((uint8_t)(b & 255)), 0)));
  ((out)->len = ((out)->len + 1));
  return 0;
}
int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b) {
  return codegen_append_byte(out, ((int32_t)(b)));
}
int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (ptr)[i]) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  return codegen_emit_bytes_from_ptr(out, ptr, len);
}
int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t buf[32], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 32 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t buf[22], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 22 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t buf[9], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t buf[8], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t buf[7], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 7 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t buf[6], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 6 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t buf[5], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 5 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t buf[4], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 4 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t buf[3], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 3 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t buf[2], int32_t len) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 2 ? (shux_panic_(1, 0), (buf)[0]) : (buf)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val) {
  (void)(({ int32_t __tmp = 0; if (val >= 10) {   int32_t q = (10 == 0 ? (shux_panic_(1, 0), val) : (val / 10));
  int32_t r = (10 == 0 ? (shux_panic_(1, 0), val) : (val % 10));
  (void)(({ int32_t __tmp = 0; if (codegen_format_uint(out, q) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 48 + r) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 48 + val) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int32_t val) {
  (void)(({ int32_t __tmp = 0; if (val >= 0) {   return codegen_format_uint(out, val);
 } else (__tmp = 0) ; __tmp; }));
  int32_t u = 0 - val;
  (void)(({ int32_t __tmp = 0; if (u < 0) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 45) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t d[11] = { 50, 49, 52, 55, 52, 56, 51, 54, 52, 56, 0 };
  int32_t i = 0;
  while (i < 10) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (i < 0 || (i) >= 11 ? (shux_panic_(1, 0), (d)[0]) : (d)[i])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 45) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_format_uint(out, u);
}
int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent) {
  int32_t i = 0;
  while (i < indent) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t br[8] = { 98, 114, 101, 97, 107, 59, 10, 0 };
  return codegen_emit_bytes_8(out, br, 7);
}
int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t co[11] = { 99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((co)[0])), 10);
}
int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, enum ast_TypeKind kind) {
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_I32) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_I64) {   uint8_t s[8] = { 105, 110, 116, 54, 52, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_BOOL) {   uint8_t s[4] = { 105, 110, 116, 0 };
  return codegen_emit_bytes_4(out, s, 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U8) {   uint8_t s[9] = { 117, 105, 110, 116, 56, 95, 116, 0, 0 };
  return codegen_emit_bytes_9(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U32) {   uint8_t s[9] = { 117, 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_9(out, s, 8);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U64) {   uint8_t s[9] = { 117, 105, 110, 116, 54, 52, 95, 116, 0 };
  return codegen_emit_bytes_9(out, s, 8);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_F32) {   uint8_t s[6] = { 102, 108, 111, 97, 116, 0 };
  return codegen_emit_bytes_6(out, s, 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_F64) {   uint8_t s[7] = { 100, 111, 117, 98, 108, 101, 0 };
  return codegen_emit_bytes_7(out, s, 6);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_VOID) {   uint8_t s[5] = { 118, 111, 105, 100, 0 };
  return codegen_emit_bytes_5(out, s, 4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_USIZE) {   uint8_t s[7] = { 115, 105, 122, 101, 95, 116, 0 };
  return codegen_emit_bytes_7(out, s, 6);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_ISIZE) {   uint8_t s[8] = { 115, 115, 105, 122, 101, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, enum ast_TypeKind kind) {
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_I32) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_I64) {   uint8_t s[8] = { 105, 110, 116, 54, 52, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_BOOL) {   uint8_t s[4] = { 105, 110, 116, 0 };
  int32_t i = 0;
  while (i < 3) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 4 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U8) {   uint8_t s[9] = { 117, 105, 110, 116, 56, 95, 116, 0, 0 };
  int32_t i = 0;
  while (i < 7) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U32) {   uint8_t s[9] = { 117, 105, 110, 116, 51, 50, 95, 116, 0 };
  int32_t i = 0;
  while (i < 8) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_U64) {   uint8_t s[9] = { 117, 105, 110, 116, 54, 52, 95, 116, 0 };
  int32_t i = 0;
  while (i < 8) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_F32) {   uint8_t s[6] = { 102, 108, 111, 97, 116, 0 };
  int32_t i = 0;
  while (i < 5) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 6 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_F64) {   uint8_t s[7] = { 100, 111, 117, 98, 108, 101, 0 };
  int32_t i = 0;
  while (i < 6) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 7 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_VOID) {   uint8_t s[5] = { 118, 111, 105, 100, 0 };
  int32_t i = 0;
  while (i < 4) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 5 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_USIZE) {   uint8_t s[7] = { 115, 105, 122, 101, 95, 116, 0 };
  int32_t i = 0;
  while (i < 6) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 7 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == ast_TypeKind_TYPE_ISIZE) {   uint8_t s[8] = { 115, 115, 105, 122, 101, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++w;
    ++i;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, enum ast_TypeKind elem_kind, int32_t lanes) {
  (void)(({ int32_t __tmp = 0; if (elem_kind == ast_TypeKind_TYPE_I32) {   (void)(({ int32_t __tmp = 0; if (lanes == 4) {   uint8_t s[8] = { 105, 51, 50, 120, 52, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lanes == 8) {   uint8_t s[8] = { 105, 51, 50, 120, 56, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (lanes == 16) {   uint8_t sa[9] = { 105, 51, 50, 120, 49, 54, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((sa)[0])), 8);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (elem_kind == ast_TypeKind_TYPE_U32) {   (void)(({ int32_t __tmp = 0; if (lanes == 4) {   uint8_t s[8] = { 117, 51, 50, 120, 52, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lanes == 8) {   uint8_t s[8] = { 117, 51, 50, 120, 56, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (lanes == 16) {   uint8_t sa[9] = { 117, 51, 50, 120, 49, 54, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((sa)[0])), 8);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t df[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((df)[0])), 7);
}
int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  (void)(({ int32_t __tmp = 0; if (cap < 16) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(type_ref) || type_ref <= 0 || type_ref > (arena)->num_types) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t = ast_arena_type_get(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((t).elem_type_ref))) {   uint8_t inner[256] = { 0 };
  int32_t n = codegen_type_to_c_repr(arena, (&((inner)[0])), 256, (t).elem_type_ref, struct_prefix, struct_prefix_len);
  (void)(({ int32_t __tmp = 0; if (n < 0 || n + 2 >= cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < n) {
    ((scratch)[j] = ((j < 0 || (j) >= 256 ? (shux_panic_(1, 0), (inner)[0]) : (inner)[j])));
    ++j;
  }
  ((scratch)[n] = (((uint8_t)(32))));
  ((scratch)[n + 1] = (((uint8_t)(42))));
  return n + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_ARRAY && (!ast_ref_is_null((t).elem_type_ref))) {   return codegen_type_to_c_repr(arena, scratch, cap, (t).elem_type_ref, struct_prefix, struct_prefix_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_VECTOR && (!ast_ref_is_null((t).elem_type_ref))) {   struct ast_Type elem_t = ast_arena_type_get(arena, (t).elem_type_ref);
  (void)(({ int32_t __tmp = 0; if ((elem_t).kind == ast_TypeKind_TYPE_I32) {   (void)(({ int32_t __tmp = 0; if ((t).array_size == 4) {   uint8_t s[8] = { 105, 51, 50, 120, 52, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).array_size == 8) {   uint8_t s[8] = { 105, 51, 50, 120, 56, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((t).array_size == 16) {   uint8_t sa[9] = { 105, 51, 50, 120, 49, 54, 95, 116, 0 };
  int32_t i = 0;
  while (i < 8) {
    ((scratch)[i] = ((i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (sa)[0]) : (sa)[i])));
    ++i;
  }
  return 8;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((elem_t).kind == ast_TypeKind_TYPE_U32) {   (void)(({ int32_t __tmp = 0; if ((t).array_size == 4) {   uint8_t s[8] = { 117, 51, 50, 120, 52, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).array_size == 8) {   uint8_t s[8] = { 117, 51, 50, 120, 56, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((t).array_size == 16) {   uint8_t sa[9] = { 117, 51, 50, 120, 49, 54, 95, 116, 0 };
  int32_t i = 0;
  while (i < 8) {
    ((scratch)[i] = ((i < 0 || (i) >= 9 ? (shux_panic_(1, 0), (sa)[0]) : (sa)[i])));
    ++i;
  }
  return 8;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  enum ast_TypeKind i32_fallback = ast_TypeKind_TYPE_I32;
  return codegen_type_kind_append_to_scratch(scratch, cap, 0, i32_fallback);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_LINEAR && (!ast_ref_is_null((t).elem_type_ref))) {   return codegen_type_to_c_repr(arena, scratch, cap, (t).elem_type_ref, struct_prefix, struct_prefix_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_SLICE && (!ast_ref_is_null((t).elem_type_ref))) {   uint8_t eb[256] = { 0 };
  int32_t ne = codegen_type_to_c_repr(arena, (&((eb)[0])), 256, (t).elem_type_ref, struct_prefix, struct_prefix_len);
  (void)(({ int32_t __tmp = 0; if (ne < 0 || ne >= 256) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t sp = 0;
  (void)(({ int32_t __tmp = 0; if (ne >= 7) {   __tmp = ({ int32_t __tmp = 0; if ((eb)[0] == ((uint8_t)(115)) && (1 < 0 || (1) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[1]) == ((uint8_t)(116)) && (2 < 0 || (2) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[2]) == ((uint8_t)(114)) && (3 < 0 || (3) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[3]) == ((uint8_t)(117)) && (4 < 0 || (4) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[4]) == ((uint8_t)(99)) && (5 < 0 || (5) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[5]) == ((uint8_t)(116)) && (6 < 0 || (6) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[6]) == ((uint8_t)(32))) {   (sp = (7));
  while (sp < ne && (sp < 0 || (sp) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[sp]) == ((uint8_t)(32))) {
    ++sp;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t plen = ne - sp;
  (void)(({ int32_t __tmp = 0; if (plen <= 0 || 21 + plen >= cap) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t hdr[22] = { 115, 116, 114, 117, 99, 116, 32, 115, 104, 117, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0 };
  int32_t hi = 0;
  while (hi < 21) {
    ((scratch)[hi] = ((hi < 0 || (hi) >= 22 ? (shux_panic_(1, 0), (hdr)[0]) : (hdr)[hi])));
    ++hi;
  }
  int32_t pi = 0;
  while (pi < plen) {
    ((scratch)[21 + pi] = ((sp + pi < 0 || (sp + pi) >= 256 ? (shux_panic_(1, 0), (eb)[0]) : (eb)[sp + pi])));
    ++pi;
  }
  return 21 + plen;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_NAMED && (t).name_len > 0) {   (void)(({ int32_t __tmp = 0; if ((t).name_len == 1 && (t).name[0] == ((uint8_t)84)) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  int32_t i = 0;
  while (i < 7) {
    ((scratch)[i] = ((i < 0 || (i) >= 8 ? (shux_panic_(1, 0), (s)[0]) : (s)[i])));
    ++i;
  }
  return 7;
 } else (__tmp = 0) ; __tmp; }));
  int32_t w = 0;
  uint8_t hdr2[8] = { 115, 116, 114, 117, 99, 116, 32, 0 };
  int32_t h = 0;
  while (h < 7) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((h < 0 || (h) >= 8 ? (shux_panic_(1, 0), (hdr2)[0]) : (hdr2)[h])));
    ++w;
    ++h;
  }
  (void)(({ int32_t __tmp = 0; if (struct_prefix != ((uint8_t *)(0)) && struct_prefix_len > 0) {   int32_t pi = 0;
  while (pi < struct_prefix_len) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((struct_prefix)[pi]));
    ++w;
    ++pi;
  }
 } else {   uint8_t ast_p[4] = { 97, 115, 116, 95 };
  int32_t ai = 0;
  while (ai < 4) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((ast_p)[ai]));
    ++w;
    ++ai;
  }
 } ; __tmp; }));
  int32_t ni = 0;
  while (ni < (t).name_len && ni < 64) {
    (void)(({ int32_t __tmp = 0; if (w >= cap - 1) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ((scratch)[w] = ((ni < 0 || (ni) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[ni])));
    ++w;
    ++ni;
  }
  return w;
 } else (__tmp = 0) ; __tmp; }));
  return codegen_type_kind_append_to_scratch(scratch, cap, 0, (t).kind);
}
int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(type_ref)) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t = ast_arena_type_get(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((t).elem_type_ref))) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, (t).elem_type_ref, struct_prefix, struct_prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 42);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_NAMED && (t).name_len > 0) {   (void)(({ int32_t __tmp = 0; if ((t).name_len == 1 && (t).name[0] == ((uint8_t)84)) {   uint8_t i32_t[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, i32_t, 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).name_len == 6 && ((t).name)[0] == 66 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[1]) == 117 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[2]) == 102 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[3]) == 102 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[4]) == 101 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[5]) == 114) {   uint8_t io_buf[22] = { 115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((io_buf)[0])), 20);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_module != ((struct ast_Module *)(0)) && codegen_type_is_module_user_enum((ctx)->current_codegen_module, arena, type_ref) != 0) {   uint8_t i32_enum[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, i32_enum, 7);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s[8] = { 115, 116, 114, 117, 99, 116, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, s, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (struct_prefix != ((uint8_t *)(0)) && struct_prefix_len > 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_module != ((struct ast_Module *)(0)) && codegen_type_is_module_user_struct((ctx)->current_codegen_module, arena, type_ref) != 0) {  } else {   uint8_t ast_p[4] = { 97, 115, 116, 95 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, ast_p, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; }));
  return codegen_emit_bytes_64(out, (&(((t).name)[0])), (t).name_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_ARRAY && (!ast_ref_is_null((t).elem_type_ref))) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, (t).elem_type_ref, struct_prefix, struct_prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 42);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_SLICE && (!ast_ref_is_null((t).elem_type_ref))) {   uint8_t slb[256] = { 0 };
  int32_t nl = codegen_type_to_c_repr(arena, (&((slb)[0])), 256, type_ref, struct_prefix, struct_prefix_len);
  (void)(({ int32_t __tmp = 0; if (nl <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t si = 0;
  while (si < nl) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (si < 0 || (si) >= 256 ? (shux_panic_(1, 0), (slb)[0]) : (slb)[si])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++si;
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_VECTOR && (!ast_ref_is_null((t).elem_type_ref))) {   struct ast_Type et_vec = ast_arena_type_get(arena, (t).elem_type_ref);
  return codegen_emit_vector_c_type_out(out, (et_vec).kind, (t).array_size);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_emit_type_kind(out, (t).kind);
}
int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(type_ref) || type_ref <= 0 || type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ty = ast_arena_type_get(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if ((ty).kind != ast_TypeKind_TYPE_ARRAY && pipeline_type_kind_ord_at(arena, type_ref) != 10) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t inner = (ty).elem_type_ref;
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(inner)) {   (inner = (pipeline_type_elem_ref_at(arena, type_ref)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(inner) || inner <= 0 || inner > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type inner_ty = ast_arena_type_get(arena, inner);
  (void)(({ int32_t __tmp = 0; if ((inner_ty).kind == ast_TypeKind_TYPE_U8) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_type_kind_ord_at(arena, inner) == 2) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t inner = pipeline_type_elem_ref_at(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(inner) || codegen_emit_type(arena, out, inner, ((uint8_t *)(0)), 0, ctx) != 0) {   uint8_t fb[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, fb, 7);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref) {
  int32_t asz = pipeline_type_array_size_at(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 91) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_format_int(out, asz) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 93);
}
int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(init_ref) || init_ref <= 0 || init_ref > (arena)->num_exprs) {   uint8_t z[4] = { 123, 32, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, z, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, init_ref) != ((int32_t)(46))) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, init_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 123) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  int32_t ai = 0;
  while (ai < n) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) == 0) {   (ai = (ai));
 } else {   return (-1);
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, init_ref, ai), ctx) == 0) {   ++ai;
 } else {   return (-1);
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 125) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  int32_t ord = pipeline_type_kind_ord_at(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(type_ref) || ord < 0) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 9) {   int32_t inner = pipeline_type_elem_ref_at(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_struct_field_type_via_pipeline(arena, out, inner, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 42);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 10) {   int32_t inner_a = pipeline_type_elem_ref_at(arena, type_ref);
  int32_t asz = pipeline_type_array_size_at(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_struct_field_type_via_pipeline(arena, out, inner_a, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 91) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_format_int(out, asz) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 93);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 8) {   uint8_t nm_buf[64] = { 0 };
  int32_t nl = pipeline_type_named_name_into(arena, type_ref, (&((nm_buf)[0])));
  (void)(({ int32_t __tmp = 0; if (nl <= 0) {   uint8_t s[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, s, 7);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t hdr_named[8] = { 115, 116, 114, 117, 99, 116, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, hdr_named, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (struct_prefix != ((uint8_t *)(0)) && struct_prefix_len > 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t ast_pfx[4] = { 97, 115, 116, 95 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, ast_pfx, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return codegen_emit_bytes_64(out, (&((nm_buf)[0])), nl);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 11) {   uint8_t slb[256] = { 0 };
  int32_t nl_s = codegen_type_to_c_repr(arena, (&((slb)[0])), 256, type_ref, struct_prefix, struct_prefix_len);
  (void)(({ int32_t __tmp = 0; if (nl_s <= 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t si = 0;
  while (si < nl_s) {
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte_u8(out, (si < 0 || (si) >= 256 ? (shux_panic_(1, 0), (slb)[0]) : (slb)[si])) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++si;
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 12) {   int32_t lanes_v = pipeline_type_array_size_at(arena, type_ref);
  int32_t inner_v = pipeline_type_elem_ref_at(arena, type_ref);
  int32_t ik = pipeline_type_kind_ord_at(arena, inner_v);
  (void)(({ int32_t __tmp = 0; if (ik == 0) {   (void)(({ int32_t __tmp = 0; if (lanes_v == 4) {   uint8_t s4[8] = { 105, 51, 50, 120, 52, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s4)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lanes_v == 8) {   uint8_t s8[8] = { 105, 51, 50, 120, 56, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s8)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (lanes_v == 16) {   uint8_t s16[9] = { 105, 51, 50, 120, 49, 54, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((s16)[0])), 8);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ik == 3) {   (void)(({ int32_t __tmp = 0; if (lanes_v == 4) {   uint8_t u4[8] = { 117, 51, 50, 120, 52, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((u4)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lanes_v == 8) {   uint8_t u8b[8] = { 117, 51, 50, 120, 56, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((u8b)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (lanes_v == 16) {   uint8_t u16b[9] = { 117, 51, 50, 120, 49, 54, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((u16b)[0])), 8);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t dfv[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_from_ptr(out, (&((dfv)[0])), 7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 0) {   enum ast_TypeKind pk = ast_TypeKind_TYPE_I32;
  return codegen_emit_type_kind(out, pk);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 1) {   enum ast_TypeKind pk1 = ast_TypeKind_TYPE_BOOL;
  return codegen_emit_type_kind(out, pk1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 2) {   enum ast_TypeKind pk2 = ast_TypeKind_TYPE_U8;
  return codegen_emit_type_kind(out, pk2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 3) {   enum ast_TypeKind pk3 = ast_TypeKind_TYPE_U32;
  return codegen_emit_type_kind(out, pk3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 4) {   enum ast_TypeKind pk4 = ast_TypeKind_TYPE_U64;
  return codegen_emit_type_kind(out, pk4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 5) {   enum ast_TypeKind pk5 = ast_TypeKind_TYPE_I64;
  return codegen_emit_type_kind(out, pk5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 6) {   enum ast_TypeKind pk6 = ast_TypeKind_TYPE_USIZE;
  return codegen_emit_type_kind(out, pk6);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 7) {   enum ast_TypeKind pk7 = ast_TypeKind_TYPE_ISIZE;
  return codegen_emit_type_kind(out, pk7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 13) {   enum ast_TypeKind pk13 = ast_TypeKind_TYPE_F32;
  return codegen_emit_type_kind(out, pk13);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 14) {   enum ast_TypeKind pk14 = ast_TypeKind_TYPE_F64;
  return codegen_emit_type_kind(out, pk14);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ord == 15) {   enum ast_TypeKind pk15 = ast_TypeKind_TYPE_VOID;
  return codegen_emit_type_kind(out, pk15);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sfb[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  return codegen_emit_bytes_8(out, sfb, 7);
}
int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0)) || name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_buffer[7] = { 66, 117, 102, 102, 101, 114, 0 };
  uint8_t nm_completion[11] = { 67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0 };
  uint8_t nm_async_ctx[13] = { 65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0 };
  (void)(({ int32_t __tmp = 0; if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, (&((nm_buffer)[0])), 6) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, (&((nm_completion)[0])), 10) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, (&((nm_async_ctx)[0])), 12) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t = ast_arena_type_get(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind != ast_TypeKind_TYPE_NAMED || (t).name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    int32_t nl = pipeline_module_struct_layout_name_len(module, k);
    (void)(({ int32_t __tmp = 0; if (nl == (t).name_len) {   uint8_t ty_nm[64] = { 0 };
  (void)(pipeline_module_struct_layout_name_into(module, k, (&((ty_nm)[0]))));
  int eq = 1;
  int32_t j = 0;
  while (j < nl && j < 64) {
    (void)(({ int32_t __tmp = 0; if ((j < 0 || (j) >= 64 ? (shux_panic_(1, 0), (ty_nm)[0]) : (ty_nm)[j]) != (j < 0 || (j) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[j])) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t = ast_arena_type_get(arena, type_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind != ast_TypeKind_TYPE_NAMED || (t).name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ei = 0;
  while (ei < (module)->num_module_enums) {
    int32_t enl = pipeline_module_enum_name_len(module, ei);
    (void)(({ int32_t __tmp = 0; if (enl == (t).name_len) {   int eq = 1;
  int32_t j = 0;
  while (j < (t).name_len && j < 64) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_enum_name_byte_at(module, ei, j) != (j < 0 || (j) >= 64 ? (shux_panic_(1, 0), ((t).name)[0]) : ((t).name)[j])) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++ei;
  }
  return 0;
}
int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
    int32_t nl = pipeline_module_struct_layout_name_len(module, k);
    (void)(({ int32_t __tmp = 0; if (nf <= 0 || nl <= 0) {   ++k;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t ty_nm[64] = { 0 };
    (void)(pipeline_module_struct_layout_name_into(module, k, (&((ty_nm)[0]))));
    (void)(({ int32_t __tmp = 0; if (codegen_should_skip_emit_struct_layout_for_abi_dup((&((ty_nm)[0])), nl) != 0) {   ++k;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t hdr_top[8] = { 115, 116, 114, 117, 99, 116, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, hdr_top, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (struct_prefix != ((uint8_t *)(0)) && struct_prefix_len > 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_dep_index < 0) {  } else {   uint8_t ast_top[4] = { 97, 115, 116, 95 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, ast_top, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((ty_nm)[0])), nl) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t br1[4] = { 32, 123, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, br1, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t j = 0;
    while (j < nf) {
      int32_t flen = pipeline_module_struct_layout_field_name_len(module, k, j);
      int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, k, j);
      (void)(({ int32_t __tmp = 0; if (flen <= 0) {   ++j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (codegen_emit_struct_field_type_via_pipeline(arena, out, ftr, struct_prefix, struct_prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
      uint8_t fnm[64] = { 0 };
      (void)(pipeline_module_struct_layout_field_name_into(module, k, j, (&((fnm)[0]))));
      (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((fnm)[0])), flen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
      uint8_t semi_nl[3] = { 59, 10, 0 };
      (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, semi_nl, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
      ++j;
    }
    uint8_t close_ty[4] = { 125, 59, 10, 10 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, close_ty, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e = ast_arena_expr_get(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LIT) {   return codegen_format_int(out, (e).int_val);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BOOL_LIT) {   (void)(({ int32_t __tmp = 0; if ((e).int_val != 0) {   return codegen_append_byte(out, 49);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 48);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR) {   (void)(({ int32_t __tmp = 0; if ((e).var_name_len > 0 && ((e).var_name)[0] > 32) {   (void)(({ int32_t __tmp = 0; if ((e).var_name_len == 3 && ((e).var_name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((e).var_name)[0]) : ((e).var_name)[1]) == 115 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((e).var_name)[0]) : ((e).var_name)[2]) == 103 && ctx != ((struct ast_PipelineDepCtx *)(0))) {   int use_l0 = 0;
  (void)(({ int __tmp = 0; if ((ctx)->current_block_ref != 0 && (ctx)->current_block_ref <= (arena)->num_blocks) {   (void)(ast_arena_block_get(arena, (ctx)->current_block_ref));
  __tmp = ({ int __tmp = 0; if (ast_block_num_lets(arena, (ctx)->current_block_ref) >= 1 && pipeline_block_let_name_len(arena, (ctx)->current_block_ref, 0) == 0) {   (use_l0 = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (use_l0) {   uint8_t l0[4] = { 95, 108, 48, 0 };
  return codegen_emit_bytes_4(out, l0, 3);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return codegen_emit_bytes_64(out, (&(((e).var_name)[0])), (e).var_name_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->emit_expr_as_callee != 0) {   uint8_t fallback[3] = { 95, 48, 0 };
  return codegen_emit_bytes_3(out, fallback, 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   (void)(({ int32_t __tmp = 0; if ((ctx)->current_func_single_empty_param_index >= 0) {   uint8_t place[4] = { 95, 112, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_format_int(out, (ctx)->current_func_single_empty_param_index);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((ctx)->current_func_empty_param_count >= 2 && (ctx)->current_emit_empty_var_next_index < (ctx)->current_func_empty_param_count) {   int32_t param_idx = pipeline_dep_ctx_empty_param_at(ctx, (ctx)->current_emit_empty_var_next_index);
  uint8_t place[4] = { 95, 112, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_format_int(out, param_idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ((ctx)->current_emit_empty_var_next_index = ((ctx)->current_emit_empty_var_next_index + 1));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t fallback[3] = { 95, 48, 0 };
  return codegen_emit_bytes_3(out, fallback, 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_AS) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, (e).as_target_type_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).as_operand_ref)) && codegen_emit_expr(arena, out, (e).as_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_RETURN) {   uint8_t op[9] = { 114, 101, 116, 117, 114, 110, 32, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, op, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).unary_operand_ref)) && codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BLOCK) {   uint8_t open[4] = { 40, 123, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, open, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).block_ref)) && codegen_emit_block(arena, out, (e).block_ref, 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t tail[8] = { 32, 125, 41, 0, 0, 0, 0, 0 };
  return codegen_emit_bytes_8(out, tail, 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADD) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 43, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SUB) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 45, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 61, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADD_ASSIGN || (e).kind == ast_ExprKind_EXPR_SUB_ASSIGN || (e).kind == ast_ExprKind_EXPR_MUL_ASSIGN || (e).kind == ast_ExprKind_EXPR_DIV_ASSIGN || (e).kind == ast_ExprKind_EXPR_MOD_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITAND_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITOR_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITXOR_ASSIGN || (e).kind == ast_ExprKind_EXPR_SHL_ASSIGN || (e).kind == ast_ExprKind_EXPR_SHR_ASSIGN) {   uint8_t op_buf[8] = { 32, 43, 61, 32, 0, 0, 0, 0 };
  int32_t op_len = 4;
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADD_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 43, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SUB_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 45, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MUL_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 42, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_DIV_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 47, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MOD_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 37, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITAND_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 38, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITOR_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 124, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITXOR_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 94, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 61, 0)));
  (op_len = (4));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SHL_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 60, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 60, 0)));
  ((3 < 0 || (3) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[3] = 61, 0)));
  ((4 < 0 || (4) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[4] = 32, 0)));
  (op_len = (5));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SHR_ASSIGN) {   ((1 < 0 || (1) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[1] = 62, 0)));
  ((2 < 0 || (2) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[2] = 62, 0)));
  ((3 < 0 || (3) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[3] = 61, 0)));
  ((4 < 0 || (4) >= 8 ? (shux_panic_(1, 0), 0) : ((op_buf)[4] = 32, 0)));
  (op_len = (5));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, op_buf, op_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_NEG) {   uint8_t pre[3] = { 45, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, pre, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADDR_OF) {   uint8_t pre_a[3] = { 38, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, pre_a, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_DEREF) {   uint8_t pre_d[3] = { 42, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, pre_d, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_IF) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_cond_ref)) && codegen_emit_expr(arena, out, (e).if_cond_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t q[4] = { 32, 63, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, q, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_then_ref)) && codegen_emit_expr(arena, out, (e).if_then_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t colon[4] = { 32, 58, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, colon, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_else_ref)) && codegen_emit_expr(arena, out, (e).if_else_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_CALL) {   int32_t callee_ref = (e).call_callee_ref;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(callee_ref)) && callee_ref > 0 && callee_ref <= (arena)->num_exprs && ctx != ((struct ast_PipelineDepCtx *)(0)) && pipeline_dep_ctx_ndep(ctx) > 0 && (ctx)->current_codegen_module != ((struct ast_Module *)(0))) {   struct ast_Expr callee = ast_arena_expr_get(arena, callee_ref);
  struct ast_Module * cur_mod = (ctx)->current_codegen_module;
  (void)(({ int32_t __tmp = 0; if ((callee).kind == ast_ExprKind_EXPR_FIELD_ACCESS && (callee).field_access_base_ref > 0 && (callee).field_access_base_ref <= (arena)->num_exprs) {   struct ast_Expr base = ast_arena_expr_get(arena, (callee).field_access_base_ref);
  __tmp = ({ int32_t __tmp = 0; if ((base).kind == ast_ExprKind_EXPR_VAR && (base).var_name_len > 0 && (base).var_name_len <= 63) {   int32_t j = 0;
  int32_t nd_bind = pipeline_dep_ctx_ndep(ctx);
  while (j < (cur_mod)->num_imports && j < nd_bind) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_import_kind_at(cur_mod, j) == 1 && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {   int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
  (void)(({ int32_t __tmp = 0; if (bind_len != (base).var_name_len) {   ++j;
  continue;
 } else (__tmp = 0) ; __tmp; }));
  int eq = 1;
  int32_t kk = 0;
  while (kk < (base).var_name_len && kk < 64) {
    (void)(({ int32_t __tmp = 0; if ((kk < 0 || (kk) >= 64 ? (shux_panic_(1, 0), ((base).var_name)[0]) : ((base).var_name)[kk]) != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++kk;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   uint8_t dep_path_bind[64] = { 0 };
  (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, (&((dep_path_bind)[0]))));
  uint8_t pre_buf[128] = { 0 };
  (void)(codegen_import_path_to_c_prefix_into((&((dep_path_bind)[0])), (&((pre_buf)[0])), 128));
  int32_t pre_len = 0;
  while (pre_len < 128 && (pre_len < 0 || (pre_len) >= 128 ? (shux_panic_(1, 0), (pre_buf)[0]) : (pre_buf)[pre_len]) != 0) {
    ++pre_len;
  }
  (void)(({ int32_t __tmp = 0; if (pre_len > 0 && codegen_c_prefix_redundant_with_name((&((pre_buf)[0])), pre_len, (&(((callee).field_access_field_name)[0])), (callee).field_access_field_len) == 0 && codegen_emit_bytes_from_ptr(out, (&((pre_buf)[0])), pre_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((callee).field_access_field_len > 0 && codegen_emit_bytes_from_ptr(out, (&(((callee).field_access_field_name)[0])), (callee).field_access_field_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t n_dep = codegen_call_num_args_override((&((pre_buf)[0])), pre_len, (&(((callee).field_access_field_name)[0])), (callee).field_access_field_len, (e).call_num_args);
  int32_t ai = 0;
  while (ai < n_dep) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((callee).kind == ast_ExprKind_EXPR_VAR && (callee).var_name_len > 0) {   int32_t j = 0;
  int32_t nd_sel = pipeline_dep_ctx_ndep(ctx);
  while (j < (cur_mod)->num_imports && j < nd_sel) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_import_kind_at(cur_mod, j) == 2 && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {   int32_t k = 0;
  int32_t sel_cnt = pipeline_module_import_select_count_at(cur_mod, j);
  while (k < sel_cnt) {
    int32_t sel_len = pipeline_module_import_select_name_len(cur_mod, j, k);
    (void)(({ int32_t __tmp = 0; if (sel_len == (callee).var_name_len) {   int eq = 1;
  int32_t kk = 0;
  while (kk < (callee).var_name_len && kk < 64) {
    (void)(({ int32_t __tmp = 0; if ((kk < 0 || (kk) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[kk]) != pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk)) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++kk;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   uint8_t dep_path_sel[64] = { 0 };
  (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, (&((dep_path_sel)[0]))));
  uint8_t pre_buf[128] = { 0 };
  (void)(codegen_import_path_to_c_prefix_into((&((dep_path_sel)[0])), (&((pre_buf)[0])), 128));
  int32_t pre_len = 0;
  while (pre_len < 128 && (pre_len < 0 || (pre_len) >= 128 ? (shux_panic_(1, 0), (pre_buf)[0]) : (pre_buf)[pre_len]) != 0) {
    ++pre_len;
  }
  (void)(({ int32_t __tmp = 0; if (pre_len > 0 && codegen_c_prefix_redundant_with_name((&((pre_buf)[0])), pre_len, (callee).var_name, (callee).var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, (&((pre_buf)[0])), pre_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((callee).var_name)[0])), (callee).var_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t n_dep = codegen_call_num_args_override((&((pre_buf)[0])), pre_len, (&(((callee).var_name)[0])), (callee).var_name_len, (e).call_num_args);
  int32_t ai = 0;
  while (ai < n_dep) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  (j = (0));
  int32_t nd_call = pipeline_dep_ctx_ndep(ctx);
  while (j < nd_call) {
    struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, j);
    struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, j);
    (void)(({ int32_t __tmp = 0; if (dep_mod != ((struct ast_Module *)(0)) && dep_arena != ((struct ast_ASTArena *)(0)) && (dep_mod)->num_funcs > 0) {   int32_t fi = 0;
  while (fi < (dep_mod)->num_funcs) {
    int32_t func_ref = pipeline_module_func_ref_at(dep_mod, fi);
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(func_ref) || func_ref <= 0 || func_ref > (dep_arena)->num_funcs) {   ++fi;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Func df = ast_arena_func_get(dep_arena, func_ref);
    (void)(({ int32_t __tmp = 0; if ((df).name_len == (callee).var_name_len) {   int eq = 1;
  int32_t k = 0;
  while (k < (callee).var_name_len && k < 64) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[k]) != (k < 0 || (k) >= 64 ? (shux_panic_(1, 0), ((df).name)[0]) : ((df).name)[k])) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {   uint8_t dep_path_call[64] = { 0 };
  (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, (&((dep_path_call)[0]))));
  uint8_t pre_buf[128] = { 0 };
  (void)(codegen_import_path_to_c_prefix_into((&((dep_path_call)[0])), (&((pre_buf)[0])), 128));
  int32_t pre_len = 0;
  while (pre_len < 128 && (pre_len < 0 || (pre_len) >= 128 ? (shux_panic_(1, 0), (pre_buf)[0]) : (pre_buf)[pre_len]) != 0) {
    ++pre_len;
  }
  int32_t drv_buf_call = 0;
  (void)(({ int32_t __tmp = 0; if (codegen_path_is_std_io_driver_bytes((&((dep_path_call)[0]))) != 0) {   (drv_buf_call = (codegen_emit_io_driver_buf_call_name(out, (&(((callee).var_name)[0])), (callee).var_name_len, (e).call_num_args)));
  __tmp = ({ int32_t __tmp = 0; if (drv_buf_call < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (drv_buf_call == 0) {   (void)(({ int32_t __tmp = 0; if (pre_len > 0 && codegen_c_prefix_redundant_with_name((&((pre_buf)[0])), pre_len, (callee).var_name, (callee).var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, (&((pre_buf)[0])), pre_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((callee).var_name)[0])), (callee).var_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_path_is_std_io_core_bytes((&((dep_path_call)[0]))) != 0 && codegen_use_buf_wrapper((&(((callee).var_name)[0])), (callee).var_name_len, (e).call_num_args) != 0) {   uint8_t suf_buf[8] = { 95, 98, 117, 102, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((suf_buf)[0])), 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t n_dep = codegen_call_num_args_override((&((pre_buf)[0])), pre_len, (callee).var_name, (callee).var_name_len, (e).call_num_args);
  int32_t fmt_i32_second_dep = 0;
  (void)(({ int32_t __tmp = 0; if ((e).call_num_args == 2 && n_dep == 1 && (callee).var_name_len == 7 && ((callee).var_name)[0] == 102 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[1]) == 109 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[2]) == 116 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[3]) == 95 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[4]) == 105 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[5]) == 51 && (6 < 0 || (6) >= 64 ? (shux_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[6]) == 50) {   __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {   (fmt_i32_second_dep = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t cast_buf0 = drv_buf_call;
  int32_t ai = 0;
  while (ai < n_dep) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t arg_idx_dep = ai;
    (void)(({ int32_t __tmp = 0; if (fmt_i32_second_dep != 0 && ai == 0) {   (arg_idx_dep = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (cast_buf0 != 0 && ai == 0) {   uint8_t cast_buf[19] = { 40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((cast_buf)[0])), 18) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_is_submit_batch_buf_call((callee).var_name, (callee).var_name_len) != 0 && (e).call_num_args == 3) {   uint8_t comma0[4] = { 44, 32, 48, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, comma0, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++fi;
  }
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->ndep > 0 && (!ast_ref_is_null(callee_ref)) && callee_ref > 0 && callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee_fb = ast_arena_expr_get(arena, callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_fb).kind == ast_ExprKind_EXPR_VAR && (callee_fb).var_name_len == 9 && ((callee_fb).var_name)[0] == 112 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[1]) == 114 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[3]) == 110 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[4]) == 116 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[5]) == 95 && (6 < 0 || (6) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[6]) == 115 && (7 < 0 || (7) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[7]) == 116 && (8 < 0 || (8) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[8]) == 114) {   uint8_t std_io[8] = { 115, 116, 100, 95, 105, 111, 95, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((std_io)[0])), 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((callee_fb).var_name)[0])), (callee_fb).var_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t ai = 0;
  while (ai < (e).call_num_args) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_module != ((struct ast_Module *)(0)) && (ctx)->current_codegen_arena != ((struct ast_ASTArena *)(0)) && (!ast_ref_is_null(callee_ref)) && callee_ref > 0 && callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee2 = ast_arena_expr_get(arena, callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee2).kind == ast_ExprKind_EXPR_VAR && (callee2).var_name_len > 0) {   struct ast_Module * cur_mod = (ctx)->current_codegen_module;
  struct ast_ASTArena * cur_arena = (ctx)->current_codegen_arena;
  int32_t fi = 0;
  while (fi < (cur_mod)->num_funcs) {
    int32_t func_ref = pipeline_module_func_ref_at(cur_mod, fi);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(func_ref)) && func_ref > 0 && func_ref <= (cur_arena)->num_funcs) {   struct ast_Func df = ast_arena_func_get(cur_arena, func_ref);
  __tmp = ({ int32_t __tmp = 0; if ((df).name_len == (callee2).var_name_len) {   int eq = 1;
  int32_t k = 0;
  while (k < (callee2).var_name_len && k < 64) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[k]) != (k < 0 || (k) >= 64 ? (shux_panic_(1, 0), ((df).name)[0]) : ((df).name)[k])) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   uint8_t cur_pre[128] = { 0 };
  uint8_t cur_dep_path_buf[128] = { 0 };
  int32_t cur_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, (&((cur_dep_path_buf)[0])));
  (void)(({ uint8_t __tmp = 0; if (cur_dep_plen > 0) {   (void)(codegen_import_path_to_c_prefix_into((&((cur_dep_path_buf)[0])), (&((cur_pre)[0])), 128));
 } else {   ((cur_pre)[0] = (((uint8_t)(0))));
 } ; __tmp; }));
  int32_t pl = 0;
  while (pl < 128 && (pl < 0 || (pl) >= 128 ? (shux_panic_(1, 0), (cur_pre)[0]) : (cur_pre)[pl]) != 0) {
    ++pl;
  }
  (void)(({ int32_t __tmp = 0; if (pl > 0 && codegen_c_prefix_redundant_with_name((&((cur_pre)[0])), pl, (callee2).var_name, (callee2).var_name_len) == 0 && codegen_emit_bytes_from_ptr(out, (&((cur_pre)[0])), pl) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((callee2).var_name)[0])), (callee2).var_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t n_cur = codegen_call_num_args_override((&((cur_pre)[0])), pl, (callee2).var_name, (callee2).var_name_len, (e).call_num_args);
  int32_t fmt_i32_second_cur = 0;
  (void)(({ int32_t __tmp = 0; if ((e).call_num_args == 2 && n_cur == 1 && (callee2).var_name_len == 7 && ((callee2).var_name)[0] == 102 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[1]) == 109 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[2]) == 116 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[3]) == 95 && (4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[4]) == 105 && (5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[5]) == 51 && (6 < 0 || (6) >= 64 ? (shux_panic_(1, 0), ((callee2).var_name)[0]) : ((callee2).var_name)[6]) == 50) {   __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {   (fmt_i32_second_cur = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t ai = 0;
  while (ai < n_cur) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t arg_idx_cur = ai;
    (void)(({ int32_t __tmp = 0; if (fmt_i32_second_cur != 0 && ai == 0) {   (arg_idx_cur = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_is_submit_batch_buf_call((callee2).var_name, (callee2).var_name_len) != 0 && (e).call_num_args == 3) {   uint8_t comma0[4] = { 44, 32, 48, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, comma0, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++fi;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref)) && (e).call_num_args == 2 && (e).call_callee_ref > 0 && (e).call_callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee_fb = ast_arena_expr_get(arena, (e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_fb).kind == ast_ExprKind_EXPR_VAR && (callee_fb).var_name_len >= 10) {   int prefix_ok = ((callee_fb).var_name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[2]) == 112 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[3]) == 95;
  int32_t off = (callee_fb).var_name_len - 6;
  int suffix_ok = off >= 0 && (off < 0 || (off) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off]) == 102 && (off + 1 < 0 || (off + 1) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off + 1]) == 105 && (off + 2 < 0 || (off + 2) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off + 2]) == 110 && (off + 3 < 0 || (off + 3) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off + 3]) == 100 && (off + 4 < 0 || (off + 4) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off + 4]) == 95 && (off + 5 < 0 || (off + 5) >= 64 ? (shux_panic_(1, 0), ((callee_fb).var_name)[0]) : ((callee_fb).var_name)[off + 5]) == 99;
  __tmp = ({ int32_t __tmp = 0; if (prefix_ok && suffix_ok) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((callee_fb).var_name)[0])), (callee_fb).var_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t open[3] = { 40, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, open, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t mid1[10] = { 41, 46, 107, 101, 121, 115, 44, 32, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((mid1)[0])), 9) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t mid2[14] = { 41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((mid2)[0])), 13) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t mid3[8] = { 41, 46, 99, 97, 112, 44, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, mid3, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t need_4th = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref)) && (e).call_callee_ref > 0 && (e).call_callee_ref <= (arena)->num_exprs && (e).call_num_args == 3) {   struct ast_Expr callee_f4 = ast_arena_expr_get(arena, (e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_f4).kind == ast_ExprKind_EXPR_VAR && codegen_is_submit_batch_buf_call((callee_f4).var_name, (callee_f4).var_name_len) != 0) {   (need_4th = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t saved_callee_flag = 0;
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   (saved_callee_flag = ((ctx)->emit_expr_as_callee));
  ((ctx)->emit_expr_as_callee = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref)) && codegen_emit_expr(arena, out, (e).call_callee_ref, ctx) != 0) {   (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->emit_expr_as_callee = (saved_callee_flag));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->emit_expr_as_callee = (saved_callee_flag));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t fallback_pre[64] = { 0 };
  int32_t fallback_pl = 0;
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   uint8_t fb_dep_path_buf[128] = { 0 };
  int32_t fb_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, (&((fb_dep_path_buf)[0])));
  (void)(({ uint8_t __tmp = 0; if (fb_dep_plen > 0) {   (void)(codegen_import_path_to_c_prefix_into((&((fb_dep_path_buf)[0])), (&((fallback_pre)[0])), 64));
 } else {   ((fallback_pre)[0] = (((uint8_t)(0))));
 } ; __tmp; }));
  while (fallback_pl < 64 && (fallback_pl < 0 || (fallback_pl) >= 64 ? (shux_panic_(1, 0), (fallback_pre)[0]) : (fallback_pre)[fallback_pl]) != 0) {
    ++fallback_pl;
  }
 } else (__tmp = 0) ; __tmp; }));
  int32_t n_fb = (e).call_num_args;
  int32_t use_second_arg = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref)) && (e).call_callee_ref > 0 && (e).call_callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee_expr = ast_arena_expr_get(arena, (e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_expr).kind == ast_ExprKind_EXPR_VAR) {   (n_fb = (codegen_call_num_args_override((&((fallback_pre)[0])), fallback_pl, (callee_expr).var_name, (callee_expr).var_name_len, (e).call_num_args)));
  __tmp = ({ int32_t __tmp = 0; if ((e).call_num_args == 2 && n_fb == 1 && ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0)) != 0) {   (use_second_arg = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t ai = 0;
  while (ai < n_fb) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t arg_idx = ai;
    (void)(({ int32_t __tmp = 0; if (use_second_arg != 0 && ai == 0) {   (arg_idx = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (need_4th != 0) {   uint8_t comma0[4] = { 44, 32, 48, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, comma0, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FLOAT_LIT) {   (void)(({ int32_t __tmp = 0; if ((e).float_val == 0.0) {   uint8_t z[4] = { 48, 46, 48, 0 };
  return codegen_emit_bytes_4(out, z, 3);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t z[4] = { 48, 46, 48, 0 };
  return codegen_emit_bytes_4(out, z, 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MUL) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 42, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_DIV) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 47, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MOD) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 37, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_EQ) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 61, 61, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_NE) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 33, 61, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LT) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 60, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LE) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 60, 61, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_GT) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 62, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_GE) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 62, 61, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LOGAND) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[5] = { 32, 38, 38, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, op, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LOGOR) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[5] = { 32, 124, 124, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, op, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SHL) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 60, 60, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_SHR) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 62, 62, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITAND) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 38, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITOR) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 124, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITXOR) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_left_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t op[4] = { 32, 94, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, op, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).binop_right_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BITNOT) {   uint8_t pre[3] = { 126, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, pre, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LOGNOT) {   uint8_t pre[3] = { 33, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, pre, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_TERNARY) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_cond_ref)) && codegen_emit_expr(arena, out, (e).if_cond_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t q[4] = { 32, 63, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, q, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_then_ref)) && codegen_emit_expr(arena, out, (e).if_then_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t colon[4] = { 32, 58, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, colon, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_else_ref)) && codegen_emit_expr(arena, out, (e).if_else_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_INDEX) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).index_base_ref)) && codegen_emit_expr(arena, out, (e).index_base_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).index_base_is_slice != 0) {   uint8_t dot[6] = { 46, 100, 97, 116, 97, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, dot, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 91) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).index_index_ref)) && codegen_emit_expr(arena, out, (e).index_index_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 93);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   (void)(({ int32_t __tmp = 0; if ((e).field_access_is_enum_variant != 0) {   return codegen_format_int(out, (e).enum_variant_tag);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_module != ((struct ast_Module *)(0)) && (ctx)->current_codegen_arena == arena && (ctx)->current_func_index >= 0) {   struct ast_Module * mod = (ctx)->current_codegen_module;
  __tmp = ({ int32_t __tmp = 0; if ((ctx)->current_func_index < (mod)->num_funcs) {   int32_t cfi = (ctx)->current_func_index;
  uint8_t pref[128] = { 0 };
  int32_t plen = codegen_emit_prefix_len_from_ctx(ctx, (&((pref)[0])), 128);
  uint8_t cfn[64] = { 0 };
  (void)(pipeline_module_func_name_copy64(mod, cfi, (&((cfn)[0]))));
  int32_t cfn_len = pipeline_module_func_name_len_at(mod, cfi);
  __tmp = ({ int32_t __tmp = 0; if (codegen_force_param_ptrdiff_t((&((pref)[0])), plen, (&((cfn)[0])), cfn_len, 0) != 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_expr_var_matches_func_param_index(arena, (e).field_access_base_ref, mod, cfi, 0, ctx) != 0) {   return codegen_emit_expr(arena, out, (e).field_access_base_ref, ctx);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).field_access_base_ref)) && codegen_emit_expr(arena, out, (e).field_access_base_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_field_access_base_is_pointer_ref(arena, (e).field_access_base_ref) != 0 || codegen_field_access_base_is_slice_param_name(arena, (e).field_access_base_ref) != 0) {   uint8_t arrow[3] = { 45, 62, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, arrow, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t dot[2] = { 46, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_2(out, dot, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((e).field_access_field_name)[0])), (e).field_access_field_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_PANIC) {   uint8_t p[22] = { 115, 104, 117, 108, 97, 110, 103, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_22(out, p, 15) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).unary_operand_ref)) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 44) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 49) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 44) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BREAK) {   return codegen_append_byte(out, 48);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_CONTINUE) {   return codegen_append_byte(out, 48);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_METHOD_CALL) {   (void)(({ int32_t __tmp = 0; if ((e).method_call_name_len == 6 && (e).method_call_num_args == 0 && (e).method_call_name[0] == ((uint8_t)100) && (e).method_call_name[1] == ((uint8_t)111) && (e).method_call_name[2] == ((uint8_t)117) && (e).method_call_name[3] == ((uint8_t)98) && (e).method_call_name[4] == ((uint8_t)108) && (e).method_call_name[5] == ((uint8_t)101)) {   struct ast_Expr base_e = ast_arena_expr_get(arena, (e).method_call_base_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((base_e).resolved_type_ref)) && pipeline_type_kind_ord_at(arena, (base_e).resolved_type_ref) == 0) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).method_call_base_ref)) && codegen_emit_expr(arena, out, (e).method_call_base_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t mul2[6] = { 32, 42, 32, 50, 41, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((mul2)[0])), 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).method_call_base_ref)) && codegen_emit_expr(arena, out, (e).method_call_base_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t dot[2] = { 46, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_2(out, dot, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((e).method_call_name)[0])), (e).method_call_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t mi = 0;
  while (mi < (e).method_call_num_args) {
    (void)(({ int32_t __tmp = 0; if (mi > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t m_arg = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
    (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(m_arg)) {   __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 48) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, m_arg, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++mi;
  }
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 41) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MATCH) {   (void)(({ int32_t __tmp = 0; if ((e).match_num_arms <= 0) {   return codegen_append_byte(out, 48);
 } else (__tmp = 0) ; __tmp; }));
  int32_t m0 = pipeline_expr_match_arm_result_ref(arena, expr_ref, 0);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(m0)) && codegen_emit_expr(arena, out, m0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_STRUCT_LIT) {   uint8_t sl_pfx[128] = { 0 };
  int32_t sl_plen = codegen_emit_prefix_len_from_ctx(ctx, (&((sl_pfx)[0])), 128);
  int32_t bare_user_lit = 0;
  (void)(({ int32_t __tmp = 0; if (sl_plen == 0 && ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_dep_index < 0 && (ctx)->current_codegen_module != ((struct ast_Module *)(0))) {   struct ast_Module * modu = (ctx)->current_codegen_module;
  int32_t sk = 0;
  while (sk < (modu)->num_struct_layouts) {
    int32_t snl = pipeline_module_struct_layout_name_len(modu, sk);
    (void)(({ int32_t __tmp = 0; if (snl == (e).struct_lit_struct_name_len && snl > 0) {   uint8_t snm[64] = { 0 };
  (void)(pipeline_module_struct_layout_name_into(modu, sk, (&((snm)[0]))));
  int eq2 = 1;
  int32_t sj = 0;
  while (sj < snl && sj < 64) {
    (void)(({ int32_t __tmp = 0; if ((sj < 0 || (sj) >= 64 ? (shux_panic_(1, 0), (snm)[0]) : (snm)[sj]) != (sj < 0 || (sj) >= 64 ? (shux_panic_(1, 0), ((e).struct_lit_struct_name)[0]) : ((e).struct_lit_struct_name)[sj])) {   (eq2 = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++sj;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq2) {   (bare_user_lit = (1));
  break;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++sk;
  }
 } else (__tmp = 0) ; __tmp; }));
  uint8_t open[9] = { 40, 115, 116, 114, 117, 99, 116, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, open, 8) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (bare_user_lit == 0 && sl_plen > 0 && codegen_emit_bytes_from_ptr(out, (&((sl_pfx)[0])), sl_plen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&(((e).struct_lit_struct_name)[0])), (e).struct_lit_struct_name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t open2[5] = { 41, 123, 32, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, open2, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t fi = 0;
  int32_t nf_codegen = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
  while (fi < nf_codegen) {
    (void)(({ int32_t __tmp = 0; if (fi > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 46) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sl_fnbuf[64] = { 0 };
    (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, (&((sl_fnbuf)[0]))));
    int32_t flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
    (void)(({ int32_t __tmp = 0; if (flen > 64) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((sl_fnbuf)[0])), 64) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((sl_fnbuf)[0])), flen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    uint8_t eq[4] = { 32, 61, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ref))) {   struct ast_Expr init_e = ast_arena_expr_get(arena, init_ref);
  __tmp = ({ int32_t __tmp = 0; if ((init_e).kind == ast_ExprKind_EXPR_ARRAY_LIT && (init_e).array_lit_num_elems == 0) {   uint8_t zero_init[6] = { 123, 32, 48, 32, 125, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, zero_init, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, init_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++fi;
  }
  uint8_t close[4] = { 32, 125, 0, 0 };
  return codegen_emit_bytes_4(out, close, 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ARRAY_LIT) {   int32_t n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  int32_t elem_type_ref = 0;
  int32_t is_slice = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).resolved_type_ref)) && (e).resolved_type_ref > 0 && (e).resolved_type_ref <= (arena)->num_types) {   struct ast_Type ty = ast_arena_type_get(arena, (e).resolved_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_SLICE) {   (is_slice = (1));
  (elem_type_ref = ((ty).elem_type_ref));
 } else (__tmp = ({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_ARRAY) {   (elem_type_ref = ((ty).elem_type_ref));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (elem_type_ref == 0 && n > 0) {   int32_t first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(first_ref))) {   struct ast_Expr first_e = ast_arena_expr_get(arena, first_ref);
  (elem_type_ref = ((first_e).resolved_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_slice != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, (e).resolved_type_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   uint8_t fallback[9] = { 117, 105, 110, 116, 56, 95, 116, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, fallback, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t slice_mid[22] = { 41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_22(out, slice_mid, 11) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(elem_type_ref)) && codegen_emit_type(arena, out, elem_type_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   uint8_t fallback[9] = { 117, 105, 110, 116, 56, 95, 116, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, fallback, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t arr[5] = { 91, 93, 41, 123, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, arr, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 40) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(elem_type_ref) || codegen_emit_type(arena, out, elem_type_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   uint8_t fallback[9] = { 117, 105, 110, 116, 56, 95, 116, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, fallback, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t arr[5] = { 91, 93, 41, 123, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, arr, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  int32_t ai = 0;
  while (ai < n) {
    (void)(({ int32_t __tmp = 0; if (ai > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai))) && codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++ai;
  }
  (void)(({ int32_t __tmp = 0; if (is_slice != 0) {   uint8_t slice_end[22] = { 32, 125, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0, 0, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_22(out, slice_end, 14) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_format_int(out, ai) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 125) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return codegen_append_byte(out, 41);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t close[4] = { 32, 125, 0, 0 };
  return codegen_emit_bytes_4(out, close, 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ENUM_VARIANT) {   return codegen_append_byte(out, 48);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, expr_ref) == 58 || pipeline_expr_kind_ord_at(arena, expr_ref) == 57) {   return pipeline_codegen_emit_expr_try_propagate_c(arena, out, expr_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t codegen_callee_var_is_string_new(struct ast_Expr e) {
  (void)(({ int32_t __tmp = 0; if ((e).kind != ast_ExprKind_EXPR_VAR) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).var_name_len == 10) {   uint8_t expect_sn[10] = { 115, 116, 114, 105, 110, 95, 110, 101, 119, 0 };
  int32_t i_sn = 0;
  while (i_sn < 9) {
    (void)(({ int32_t __tmp = 0; if ((i_sn < 0 || (i_sn) >= 64 ? (shux_panic_(1, 0), ((e).var_name)[0]) : ((e).var_name)[i_sn]) != (i_sn < 0 || (i_sn) >= 10 ? (shux_panic_(1, 0), (expect_sn)[0]) : (expect_sn)[i_sn])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i_sn;
  }
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).var_name_len == 22) {   uint8_t expect_ssn[22] = { 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0 };
  int32_t i_ssn = 0;
  while (i_ssn < 20) {
    (void)(({ int32_t __tmp = 0; if ((i_ssn < 0 || (i_ssn) >= 64 ? (shux_panic_(1, 0), ((e).var_name)[0]) : ((e).var_name)[i_ssn]) != (i_ssn < 0 || (i_ssn) >= 22 ? (shux_panic_(1, 0), (expect_ssn)[0]) : (expect_ssn)[i_ssn])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i_ssn;
  }
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx) {
  uint8_t blk_prefix[128] = { 0 };
  int32_t blk_prefix_len = codegen_emit_prefix_len_from_ctx(ctx, (&((blk_prefix)[0])), 128);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(block_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (block_ref <= 0 || block_ref > (arena)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block b = ast_arena_block_get(arena, block_ref);
  (void)(({ int32_t __tmp = 0; if (ast_block_num_stmt_order(arena, block_ref) > 0) {   int32_t si = 0;
  while (si < ast_block_num_stmt_order(arena, block_ref)) {
    uint8_t k = ast_block_stmt_order_kind(arena, block_ref, si);
    int32_t idx = ast_block_stmt_order_idx(arena, block_ref, si);
    (void)(({ int32_t __tmp = 0; if (k == 0) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < ast_block_num_consts(arena, block_ref)) {   uint8_t cname_buf[64] = { 0 };
  (void)(pipeline_block_const_name_copy64(arena, block_ref, idx, (&((cname_buf)[0]))));
  int32_t cname_len = pipeline_block_const_name_len(arena, block_ref, idx);
  int32_t ctype_ref = pipeline_block_const_type_ref(arena, block_ref, idx);
  int32_t cinit_ref = pipeline_block_const_init_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, ctype_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sp[3] = { 32, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sp, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (cname_len > 0 && (cname_buf)[0] > 32) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((cname_buf)[0])), cname_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 99, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  uint8_t eq[4] = { 32, 61, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, cinit_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc[3] = { 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 1) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < ast_block_num_lets(arena, block_ref)) {   uint8_t lname_buf[64] = { 0 };
  (void)(pipeline_block_let_name_copy64(arena, block_ref, idx, (&((lname_buf)[0]))));
  int32_t lname_len = pipeline_block_let_name_len(arena, block_ref, idx);
  int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
  int32_t linit_ref = pipeline_block_let_init_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t type_emitted = 0;
  int32_t use_local_array = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(let_type_ref)) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {   (use_local_array = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (use_local_array != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(linit_ref)) && linit_ref > 0 && linit_ref <= (arena)->num_exprs) {   struct ast_Expr init_e = ast_arena_expr_get(arena, linit_ref);
  (void)(({ int32_t __tmp = 0; if (type_emitted == 0 && (init_e).kind == ast_ExprKind_EXPR_ARRAY_LIT && codegen_type_array_elem_is_u8(arena, let_type_ref) != 0) {   uint8_t u8ptr[9] = { 117, 105, 110, 116, 56, 95, 116, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, u8ptr, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 42) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_emitted == 0 && (!ast_ref_is_null((init_e).resolved_type_ref)) && (init_e).resolved_type_ref > 0 && (init_e).resolved_type_ref <= (arena)->num_types) {   struct ast_Type rt = ast_arena_type_get(arena, (init_e).resolved_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt).kind == ast_TypeKind_TYPE_NAMED && (rt).name_len >= 6) {   int32_t n0 = (rt).name_len - 6;
  __tmp = ({ int32_t __tmp = 0; if ((n0 < 0 || (n0) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0]) == 83 && (n0 + 1 < 0 || (n0 + 1) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0 + 1]) == 116 && (n0 + 2 < 0 || (n0 + 2) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0 + 2]) == 114 && (n0 + 3 < 0 || (n0 + 3) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0 + 3]) == 105 && (n0 + 4 < 0 || (n0 + 4) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0 + 4]) == 110 && (n0 + 5 < 0 || (n0 + 5) >= 64 ? (shux_panic_(1, 0), ((rt).name)[0]) : ((rt).name)[n0 + 5]) == 103) {   uint8_t str_ty[8] = { 83, 116, 114, 105, 110, 103, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((str_ty)[0])), 6) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (type_emitted == 0 && (init_e).kind == ast_ExprKind_EXPR_CALL && (!ast_ref_is_null((init_e).call_callee_ref)) && (init_e).call_callee_ref > 0 && (init_e).call_callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee_let = ast_arena_expr_get(arena, (init_e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_let).kind == ast_ExprKind_EXPR_VAR) {   __tmp = ({ int32_t __tmp = 0; if (codegen_callee_var_is_string_new(callee_let) != 0) {   uint8_t str_ty[8] = { 83, 116, 114, 105, 110, 103, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((str_ty)[0])), 6) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_emitted == 0) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(let_type_ref) && (!ast_ref_is_null(linit_ref)) && linit_ref > 0 && linit_ref <= (arena)->num_exprs) {   struct ast_Expr init_e = ast_arena_expr_get(arena, linit_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((init_e).resolved_type_ref))) {   (let_type_ref = ((init_e).resolved_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lname_len > 0 && (lname_buf)[0] > 32) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((lname_buf)[0])), lname_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 108, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, idx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (use_local_array != 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t eq[4] = { 32, 61, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t slice_init_done = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(linit_ref))) {   slice_init_done = codegen_try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(linit_ref)) {   uint8_t zinit_omit2[6] = { 123, 32, 48, 32, 125, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, zinit_omit2, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (slice_init_done == 1) {   __tmp = 0;
 } else (__tmp = ({ int32_t __tmp = 0; if (slice_init_done < 0) {   return (-1);
 } else (__tmp = ({ int32_t __tmp = 0; if (use_local_array != 0 && (!ast_ref_is_null(linit_ref)) && linit_ref > 0 && linit_ref <= (arena)->num_exprs) {   struct ast_Expr init_e2 = ast_arena_expr_get(arena, linit_ref);
  __tmp = ({ int32_t __tmp = 0; if ((init_e2).kind == ast_ExprKind_EXPR_ARRAY_LIT) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((init_e2).kind == ast_ExprKind_EXPR_LIT && (init_e2).int_val == 0) {   uint8_t zinit[6] = { 123, 32, 48, 32, 125, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, zinit, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  uint8_t sc[3] = { 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 2) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < ast_block_num_expr_stmts(arena, block_ref)) {   int32_t ex_ref = ast_block_expr_stmt_ref(arena, block_ref, idx);
  struct ast_Expr st = ast_arena_expr_get(arena, ex_ref);
  __tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_RETURN) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ret[8] = { 114, 101, 116, 117, 114, 110, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, ret, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((st).unary_operand_ref)) && codegen_emit_expr(arena, out, (st).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc[4] = { 59, 10, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_BREAK) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_break_stmt(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_CONTINUE) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_continue_stmt(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t v[9] = { 40, 118, 111, 105, 100, 41, 40, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, v, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, ex_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc[4] = { 41, 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 3) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < (b).num_loops) {   int32_t w_cr = ast_block_while_cond_ref(arena, block_ref, idx);
  int32_t w_br = ast_block_while_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t wh[8] = { 119, 104, 105, 108, 101, 32, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, wh, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, w_cr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t paren[5] = { 41, 32, 123, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, paren, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, w_br, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t close[3] = { 125, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 4) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < (b).num_for_loops) {   int32_t fl_ir = ast_block_for_init_ref(arena, block_ref, idx);
  int32_t fl_cr = ast_block_for_cond_ref(arena, block_ref, idx);
  int32_t fl_sr = ast_block_for_step_ref(arena, block_ref, idx);
  int32_t fl_br = ast_block_for_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t fk[6] = { 102, 111, 114, 32, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, fk, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_ir))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_ir, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc1[3] = { 59, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc1, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_cr))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_cr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc2[3] = { 59, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc2, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_sr))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_sr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t paren[5] = { 41, 32, 123, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, paren, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_br)) && codegen_emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t close[3] = { 125, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 5) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < ast_block_num_if_stmts(arena, block_ref)) {   int32_t if_cond_r = ast_block_if_cond_ref(arena, block_ref, idx);
  int32_t if_then_r = ast_block_if_then_body_ref(arena, block_ref, idx);
  int32_t if_else_r = ast_block_if_else_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ikw[5] = { 105, 102, 32, 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, ikw, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, if_cond_r, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t paren_if[5] = { 41, 32, 123, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, paren_if, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, if_then_r, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (if_else_r != 0) {   uint8_t else_brace[9] = { 125, 32, 101, 108, 115, 101, 32, 123, 10 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, else_brace, 9) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, if_else_r, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t cif[3] = { 125, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, cif, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (k == 6) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < ast_block_num_regions(arena, block_ref)) {   int32_t reg_body = ast_block_region_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ob[2] = { 123, 10 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_2(out, ob, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, reg_body, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t cb[3] = { 125, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, cb, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    ++si;
  }
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((b).final_expr_ref))) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ret[8] = { 114, 101, 116, 117, 114, 110, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, ret, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr fe_ordered = ast_arena_expr_get(arena, (b).final_expr_ref);
  (void)(({ int32_t __tmp = 0; if ((fe_ordered).kind == ast_ExprKind_EXPR_RETURN) {   __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((fe_ordered).unary_operand_ref)) && codegen_emit_expr(arena, out, (fe_ordered).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (b).final_expr_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  uint8_t sc[4] = { 59, 10, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < ast_block_num_consts(arena, block_ref)) {
    uint8_t cname_fb[64] = { 0 };
    (void)(pipeline_block_const_name_copy64(arena, block_ref, i, (&((cname_fb)[0]))));
    int32_t cname_len_fb = pipeline_block_const_name_len(arena, block_ref, i);
    int32_t ctype_fb = pipeline_block_const_type_ref(arena, block_ref, i);
    int32_t cinit_fb = pipeline_block_const_init_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, ctype_fb, (&((blk_prefix)[0])), blk_prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sp[3] = { 32, 0, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sp, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (cname_len_fb > 0 && (cname_fb)[0] > 32) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((cname_fb)[0])), cname_len_fb) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 99, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    uint8_t eq[4] = { 32, 61, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, cinit_fb, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sc[3] = { 59, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  (i = (0));
  while (i < ast_block_num_lets(arena, block_ref)) {
    uint8_t lname_fb[64] = { 0 };
    (void)(pipeline_block_let_name_copy64(arena, block_ref, i, (&((lname_fb)[0]))));
    int32_t lname_len_fb = pipeline_block_let_name_len(arena, block_ref, i);
    int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    int32_t linit_fb = pipeline_block_let_init_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t type_emitted = 0;
    int32_t use_local_array = 0;
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(let_type_ref)) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {   (use_local_array = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (use_local_array != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(linit_fb)) && linit_fb > 0 && linit_fb <= (arena)->num_exprs) {   struct ast_Expr init_e = ast_arena_expr_get(arena, linit_fb);
  (void)(({ int32_t __tmp = 0; if (type_emitted == 0 && (init_e).kind == ast_ExprKind_EXPR_ARRAY_LIT && codegen_type_array_elem_is_u8(arena, let_type_ref) != 0) {   uint8_t u8ptr[9] = { 117, 105, 110, 116, 56, 95, 116, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, u8ptr, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 42) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (type_emitted == 0 && (!ast_ref_is_null((init_e).resolved_type_ref)) && (init_e).resolved_type_ref > 0 && (init_e).resolved_type_ref <= (arena)->num_types) {   struct ast_Type rt2 = ast_arena_type_get(arena, (init_e).resolved_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt2).kind == ast_TypeKind_TYPE_NAMED && (rt2).name_len >= 6) {   int32_t n02 = (rt2).name_len - 6;
  __tmp = ({ int32_t __tmp = 0; if ((n02 < 0 || (n02) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02]) == 83 && (n02 + 1 < 0 || (n02 + 1) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02 + 1]) == 116 && (n02 + 2 < 0 || (n02 + 2) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02 + 2]) == 114 && (n02 + 3 < 0 || (n02 + 3) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02 + 3]) == 105 && (n02 + 4 < 0 || (n02 + 4) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02 + 4]) == 110 && (n02 + 5 < 0 || (n02 + 5) >= 64 ? (shux_panic_(1, 0), ((rt2).name)[0]) : ((rt2).name)[n02 + 5]) == 103) {   uint8_t str_ty2a[8] = { 83, 116, 114, 105, 110, 103, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((str_ty2a)[0])), 6) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (type_emitted == 0 && (init_e).kind == ast_ExprKind_EXPR_CALL && (!ast_ref_is_null((init_e).call_callee_ref)) && (init_e).call_callee_ref > 0 && (init_e).call_callee_ref <= (arena)->num_exprs) {   struct ast_Expr callee_let2 = ast_arena_expr_get(arena, (init_e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_let2).kind == ast_ExprKind_EXPR_VAR) {   __tmp = ({ int32_t __tmp = 0; if (codegen_callee_var_is_string_new(callee_let2) != 0) {   uint8_t str_ty2[8] = { 83, 116, 114, 105, 110, 103, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((str_ty2)[0])), 6) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (type_emitted = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (type_emitted == 0) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(let_type_ref) && (!ast_ref_is_null(linit_fb)) && linit_fb > 0 && linit_fb <= (arena)->num_exprs) {   struct ast_Expr init_e = ast_arena_expr_get(arena, linit_fb);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((init_e).resolved_type_ref))) {   (let_type_ref = ((init_e).resolved_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, let_type_ref, (&((blk_prefix)[0])), blk_prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (lname_len_fb > 0 && (lname_fb)[0] > 32) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((lname_fb)[0])), lname_len_fb) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 108, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, i) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (use_local_array != 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t eq[4] = { 32, 61, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (use_local_array != 0 && (!ast_ref_is_null(linit_fb)) && linit_fb > 0 && linit_fb <= (arena)->num_exprs) {   struct ast_Expr init_e3 = ast_arena_expr_get(arena, linit_fb);
  __tmp = ({ int32_t __tmp = 0; if ((init_e3).kind == ast_ExprKind_EXPR_ARRAY_LIT) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_braced_array_lit_init(arena, out, linit_fb, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((init_e3).kind == ast_ExprKind_EXPR_LIT && (init_e3).int_val == 0) {   uint8_t zinit2[6] = { 123, 32, 48, 32, 125, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, zinit2, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, linit_fb, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, linit_fb, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    uint8_t sc[3] = { 59, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  (i = (0));
  while (i < ast_block_num_expr_stmts(arena, block_ref)) {
    int32_t ex_fb = ast_block_expr_stmt_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr st = ast_arena_expr_get(arena, ex_fb);
    (void)(({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_RETURN) {   uint8_t ret[8] = { 114, 101, 116, 117, 114, 110, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, ret, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((st).unary_operand_ref)) && codegen_emit_expr(arena, out, (st).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc[4] = { 59, 10, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_BREAK) {   uint8_t br[8] = { 98, 114, 101, 97, 107, 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, br, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_CONTINUE) {   uint8_t co[11] = { 99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((co)[0])), 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t v[9] = { 40, 118, 111, 105, 100, 41, 40, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, v, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, ex_fb, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t sc[4] = { 41, 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
    ++i;
  }
  (i = (0));
  while (i < (b).num_loops) {
    int32_t w_cr = ast_block_while_cond_ref(arena, block_ref, i);
    int32_t w_br = ast_block_while_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t wh[8] = { 119, 104, 105, 108, 101, 32, 40, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, wh, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, w_cr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t paren[5] = { 41, 32, 123, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, paren, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, w_br, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t close[3] = { 125, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  (i = (0));
  while (i < (b).num_for_loops) {
    int32_t fl_ir = ast_block_for_init_ref(arena, block_ref, i);
    int32_t fl_cr = ast_block_for_cond_ref(arena, block_ref, i);
    int32_t fl_sr = ast_block_for_step_ref(arena, block_ref, i);
    int32_t fl_br = ast_block_for_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t fk[6] = { 102, 111, 114, 32, 40, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_6(out, fk, 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_ir))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_ir, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sc1[3] = { 59, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc1, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_cr))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_cr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sc2[3] = { 59, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc2, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_sr))) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, fl_sr, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t paren[5] = { 41, 32, 123, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_5(out, paren, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_br)) && codegen_emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t close[3] = { 125, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((b).final_expr_ref))) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, indent) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ret[8] = { 114, 101, 116, 117, 114, 110, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, ret, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr fe_plain = ast_arena_expr_get(arena, (b).final_expr_ref);
  (void)(({ int32_t __tmp = 0; if ((fe_plain).kind == ast_ExprKind_EXPR_RETURN) {   __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((fe_plain).unary_operand_ref)) && codegen_emit_expr(arena, out, (fe_plain).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, (b).final_expr_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  uint8_t sc[4] = { 59, 10, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst) {
  (void)(pipeline_module_func_name_copy64(module, fi, dst));
}
void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst) {
  (void)(pipeline_module_func_param_name_copy32(module, fi, pi, dst));
}
int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals) {
  (void)(({ int32_t __tmp = 0; if (fi < 0 || fi >= (module)->num_funcs) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t fn_local[64] = { 0 };
  (void)(codegen_copy_func_name64_from_module(module, fi, (&((fn_local)[0]))));
  int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
  (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t main_name[4] = { 109, 97, 105, 110 };
  int name_is_main = fn_len == 4 && (fn_local)[0] == 109 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), (fn_local)[0]) : (fn_local)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), (fn_local)[0]) : (fn_local)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), (fn_local)[0]) : (fn_local)[3]) == 110;
  int force_entry_main = 0;
  (void)(({ int __tmp = 0; if (is_entry && (module)->num_funcs == 1) {   (void)(({ int __tmp = 0; if (fn_len <= 0) {   (force_entry_main = (1));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int __tmp = 0; if ((fn_local)[0] == 0) {   (force_entry_main = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int emit_c_main_symbol = 0;
  (void)(({ int __tmp = 0; if (is_entry) {   __tmp = ({ int __tmp = 0; if (name_is_main) {   (emit_c_main_symbol = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (force_entry_main) {   (emit_c_main_symbol = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (emit_c_main_symbol) {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, main_name, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, (&((fn_local)[0])), fn_len) == 0 && codegen_emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((fn_local)[0])), fn_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, (&((fn_local)[0])), fn_len) != 0) {   uint8_t impl_suffix[6] = { 95, 105, 109, 112, 108, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((impl_suffix)[0])), 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  uint8_t lpar[2] = { 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_2(out, lpar, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_module_func_num_params_at(module, fi) == 0) {   uint8_t v[7] = { 118, 111, 105, 100, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_7(out, v, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t p = 0;
  while (p < pipeline_module_func_num_params_at(module, fi)) {
    (void)(({ int32_t __tmp = 0; if (p > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t size_t_ps[32] = { 115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, size_t_ps, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_size_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t size_t_buf[32] = { 115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, size_t_buf, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_ptrdiff_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t ptrdiff_t_buf[32] = { 112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_uint32_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t u32_buf[32] = { 117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, u32_buf, 9) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_i32(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t i32_str[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, i32_str, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {   uint8_t plocal[32] = { 0 };
  (void)(codegen_copy_param_name32_from_module(module, fi, p, (&((plocal)[0]))));
  __tmp = ({ int32_t __tmp = 0; if ((plocal)[0] > 32 && codegen_emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 112, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, p) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    ++p;
  }
 } ; __tmp; }));
  uint8_t rpar[3] = { 41, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, rpar, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t brace[3] = { 123, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, brace, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int fn_ret_void = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) == 15;
  (void)(({ int32_t __tmp = 0; if (call_init_globals != 0) {   __tmp = ({ int32_t __tmp = 0; if (is_entry) {   __tmp = ({ int32_t __tmp = 0; if (emit_c_main_symbol) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t init_globals_call[22] = { 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((init_globals_call)[0])), 16) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t saved_empty = -1;
  int32_t saved_count = 0;
  int32_t saved_next = 0;
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   (void)(pipeline_dep_ctx_empty_param_backup(ctx));
  (saved_empty = ((ctx)->current_func_single_empty_param_index));
  (saved_count = ((ctx)->current_func_empty_param_count));
  (saved_next = ((ctx)->current_emit_empty_var_next_index));
  int32_t empty_count = 0;
  int32_t empty_idx = -1;
  int32_t pi = 0;
  while (pi < pipeline_module_func_num_params_at(module, fi)) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {   ++empty_count;
  (empty_idx = (pi));
 } else (__tmp = 0) ; __tmp; }));
    ++pi;
  }
  __tmp = ({ int32_t __tmp = 0; if (empty_count == 1) {   ((ctx)->current_func_single_empty_param_index = (empty_idx));
  ((ctx)->current_func_empty_param_count = (0));
  ((ctx)->current_emit_empty_var_next_index = (0));
 } else (__tmp = ({ int32_t __tmp = 0; if (empty_count >= 2) {   ((ctx)->current_func_single_empty_param_index = ((-1)));
  (void)(pipeline_dep_ctx_empty_param_reset(ctx));
  ((ctx)->current_func_empty_param_count = (empty_count));
  int32_t ei = 0;
  (pi = (0));
  while (pi < pipeline_module_func_num_params_at(module, fi)) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {   (void)(pipeline_dep_ctx_empty_param_append(ctx, pi));
  ++ei;
 } else (__tmp = 0) ; __tmp; }));
    ++pi;
  }
  ((ctx)->current_emit_empty_var_next_index = (0));
 } else {   ((ctx)->current_func_single_empty_param_index = ((-1)));
  ((ctx)->current_func_empty_param_count = (0));
  ((ctx)->current_emit_empty_var_next_index = (0));
 } ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {   int32_t saved_block = 0;
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   (saved_block = ((ctx)->current_block_ref));
  ((ctx)->current_block_ref = (pipeline_module_func_body_ref_at(module, fi)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) != 0) {   (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_block_ref = (saved_block));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_block_ref = (saved_block));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {   __tmp = ({ int32_t __tmp = 0; if (fn_ret_void) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 59) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t ret_keyword[9] = { 114, 101, 116, 117, 114, 110, 32, 0, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, ret_keyword, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr body_e = ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
  (void)(({ int32_t __tmp = 0; if ((body_e).kind == ast_ExprKind_EXPR_RETURN) {   __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((body_e).unary_operand_ref)) && codegen_emit_expr(arena, out, (body_e).unary_operand_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 59) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_func_single_empty_param_index = (saved_empty));
  ((ctx)->current_func_empty_param_count = (saved_count));
  ((ctx)->current_emit_empty_var_next_index = (saved_next));
  (void)(pipeline_dep_ctx_empty_param_restore(ctx));
 } else (__tmp = 0) ; __tmp; }));
  int need_fallback_return = 1;
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {   (need_fallback_return = (0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {   int32_t body_br = pipeline_module_func_body_ref_at(module, fi);
  struct ast_Block b = ast_arena_block_get(arena, body_br);
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null((b).final_expr_ref))) {   (need_fallback_return = (0));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ji = 0;
  int32_t nes = ast_block_num_expr_stmts(arena, body_br);
  while (ji < nes) {
    struct ast_Expr se = ast_arena_expr_get(arena, ast_block_expr_stmt_ref(arena, body_br, ji));
    (void)(({ int32_t __tmp = 0; if ((se).kind == ast_ExprKind_EXPR_RETURN) {   (need_fallback_return = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++ji;
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (need_fallback_return) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (fn_ret_void) {   uint8_t ret_void_ln[9] = { 114, 101, 116, 117, 114, 110, 59, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((ret_void_ln)[0])), 8) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t ret0[9] = { 114, 101, 116, 117, 114, 110, 32, 48, 59 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_9(out, ret0, 9) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_append_byte(out, 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t close[3] = { 125, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (fi < 0 || fi >= (module)->num_funcs) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t fn_local[64] = { 0 };
  (void)(codegen_copy_func_name64_from_module(module, fi, (&((fn_local)[0]))));
  int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
  uint8_t kw[8] = { 101, 120, 116, 101, 114, 110, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((kw)[0])), 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, (&((fn_local)[0])), fn_len) == 0 && codegen_emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_64(out, (&((fn_local)[0])), fn_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, (&((fn_local)[0])), fn_len) != 0) {   uint8_t impl_suffix[6] = { 95, 105, 109, 112, 108, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((impl_suffix)[0])), 5) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t lpar[2] = { 40, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_2(out, lpar, 1) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_module_func_num_params_at(module, fi) == 0) {   uint8_t v[7] = { 118, 111, 105, 100, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_7(out, v, 4) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t p = 0;
  while (p < pipeline_module_func_num_params_at(module, fi)) {
    (void)(({ int32_t __tmp = 0; if (p > 0) {   uint8_t comma[3] = { 44, 32, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, comma, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t size_t_buf2[32] = { 115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, size_t_buf2, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_size_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t size_t_buf[32] = { 115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, size_t_buf, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_ptrdiff_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t ptrdiff_t_buf[32] = { 112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_uint32_t(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t u32_buf[32] = { 117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_32(out, u32_buf, 9) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_force_param_i32(prefix, prefix_len, (&((fn_local)[0])), fn_len, p) != 0) {   uint8_t i32_str[8] = { 105, 110, 116, 51, 50, 95, 116, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_8(out, i32_str, 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {   uint8_t plocal[32] = { 0 };
  (void)(codegen_copy_param_name32_from_module(module, fi, p, (&((plocal)[0]))));
  __tmp = ({ int32_t __tmp = 0; if ((plocal)[0] > 32 && codegen_emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t place[4] = { 95, 112, 48, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, place, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_format_int(out, p) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    ++p;
  }
 } ; __tmp; }));
  uint8_t end_proto[3] = { 41, 59, 10 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((end_proto)[0])), 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_sx_ast_emit_header(struct codegen_CodegenOutBuf * out) {
  uint8_t h[22] = { 35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10, 0, 0 };
  return codegen_emit_bytes_22(out, h, 20);
}
int32_t codegen_sx_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index) {
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_codegen_module = (module));
  ((ctx)->current_codegen_arena = (arena));
  ((ctx)->current_codegen_dep_index = (dep_index));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t prefix_buf[128] = { 0 };
  int32_t prefix_len = 0;
  uint8_t dep_path_prefix[64] = { 0 };
  int32_t dep_path_prefix_len = 0;
  (void)(({ int32_t __tmp = 0; if (dep_index >= 0 && ctx != ((struct ast_PipelineDepCtx *)(0))) {   (dep_path_prefix_len = (codegen_dep_import_path_len_at(ctx, dep_index, (&((dep_path_prefix)[0])))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dep_index >= 0 && ctx != ((struct ast_PipelineDepCtx *)(0)) && dep_path_prefix_len > 0) {   __tmp = ({ int32_t __tmp = 0; if (codegen_path_is_std_io_core_bytes((&((dep_path_prefix)[0]))) == 0) {   (void)(codegen_import_path_to_c_prefix_into((&((dep_path_prefix)[0])), (&((prefix_buf)[0])), 128));
  while (prefix_len < 128 && (prefix_len < 0 || (prefix_len) >= 128 ? (shux_panic_(1, 0), (prefix_buf)[0]) : (prefix_buf)[prefix_len]) != 0) {
    ++prefix_len;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (prefix_len == 0 && dep_index < 0 || dep_path_prefix_len == 0 || codegen_path_is_std_io_core_bytes((&((dep_path_prefix)[0]))) == 0) {   (prefix_len = (0));
  ((prefix_buf)[0] = (((uint8_t)(0))));
  __tmp = ({ int32_t __tmp = 0; if (dep_path_prefix_len > 0) {   (void)(codegen_import_path_to_c_prefix_into((&((dep_path_prefix)[0])), (&((prefix_buf)[0])), 128));
  while (prefix_len < 128 && (prefix_len < 0 || (prefix_len) >= 128 ? (shux_panic_(1, 0), (prefix_buf)[0]) : (prefix_buf)[prefix_len]) != 0) {
    ++prefix_len;
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_codegen_prefix_len = (0));
  int32_t px = 0;
  while (px < prefix_len && px < 63) {
    ((px < 0 || (px) >= 64 ? (shux_panic_(1, 0), 0) : (((ctx)->current_codegen_prefix_mirror)[px] = (px < 0 || (px) >= 128 ? (shux_panic_(1, 0), (prefix_buf)[0]) : (prefix_buf)[px]), 0)));
    ++px;
  }
  ((px < 0 || (px) >= 64 ? (shux_panic_(1, 0), 0) : (((ctx)->current_codegen_prefix_mirror)[px] = ((uint8_t)(0)), 0)));
  ((ctx)->current_codegen_prefix_len = (px));
 } else (__tmp = 0) ; __tmp; }));
  int32_t call_init_globals = 0;
  (void)(({ int32_t __tmp = 0; if (dep_index < 0 && (module)->num_top_level_lets > 0) {   int32_t ti = 0;
  while (ti < (module)->num_top_level_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_top_level_let_is_const(module, ti) == 0) {   (call_init_globals = (1));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++ti;
  }
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (i == 0) {   (void)(({ int32_t __tmp = 0; if (codegen_sx_ast_emit_header(out) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_emit_module_struct_definitions(module, arena, out, (&((prefix_buf)[0])), prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (dep_index < 0 && (module)->num_top_level_lets > 0) {   int32_t ti = 0;
  while (ti < (module)->num_top_level_lets) {
    int32_t is_const = pipeline_module_top_level_let_is_const(module, ti);
    int32_t name_len = pipeline_module_top_level_let_name_len(module, ti);
    (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   ++ti;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t tl_name_buf[64] = { 0 };
    int32_t tni = 0;
    while (tni < name_len && tni < 64) {
      ((tni < 0 || (tni) >= 64 ? (shux_panic_(1, 0), 0) : ((tl_name_buf)[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni), 0)));
      ++tni;
    }
    (void)(({ int32_t __tmp = 0; if (is_const != 0) {   uint8_t static_const[15] = { 115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((static_const)[0])), 13) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else {   uint8_t static_[9] = { 115, 116, 97, 116, 105, 99, 32, 0, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((static_)[0])), 7) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_type(arena, out, pipeline_module_top_level_let_type_ref(module, ti), (&((prefix_buf)[0])), 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_append_byte(out, 32) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((tl_name_buf)[0])), name_len) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (is_const != 0 && (!ast_ref_is_null(pipeline_module_top_level_let_init_ref(module, ti)))) {   uint8_t eq[4] = { 32, 61, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sc[3] = { 59, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++ti;
  }
  int32_t any_let = 0;
  (ti = (0));
  while (ti < (module)->num_top_level_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_top_level_let_is_const(module, ti) == 0) {   (any_let = (1));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++ti;
  }
  __tmp = ({ int32_t __tmp = 0; if (any_let != 0) {   uint8_t init_globals_def[32] = { 115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((init_globals_def)[0])), 31) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  uint8_t brace3[3] = { 123, 10, 0 };
  (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, brace3, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (ti = (0));
  while (ti < (module)->num_top_level_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_top_level_let_is_const(module, ti) != 0) {   ++ti;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_indent(out, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t nlen = pipeline_module_top_level_let_name_len(module, ti);
    (void)(({ int32_t __tmp = 0; if (nlen > 0 && nlen <= 63) {   uint8_t tl_init_name[64] = { 0 };
  int32_t tni2 = 0;
  while (tni2 < nlen && tni2 < 64) {
    ((tni2 < 0 || (tni2) >= 64 ? (shux_panic_(1, 0), 0) : ((tl_init_name)[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2), 0)));
    ++tni2;
  }
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_from_ptr(out, (&((tl_init_name)[0])), nlen) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t eq2[4] = { 32, 61, 32, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_4(out, eq2, 3) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_top_level_let_init_ref(module, ti))) && codegen_emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sc2[3] = { 59, 10, 0 };
    (void)(({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, sc2, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    ++ti;
  }
  uint8_t close_brace[3] = { 125, 10, 0 };
  __tmp = ({ int32_t __tmp = 0; if (codegen_emit_bytes_3(out, close_brace, 2) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    uint8_t skip_name[64] = { 0 };
    (void)(codegen_copy_func_name64_from_module(module, i, (&((skip_name)[0]))));
    int32_t skip_nl = pipeline_module_func_name_len_at(module, i);
    (void)(({ int32_t __tmp = 0; if (pipeline_module_func_is_extern_at(module, i) != 0) {   (void)(({ int32_t __tmp = 0; if (codegen_emit_func_extern_declaration(arena, out, module, i, (&((prefix_buf)[0])), prefix_len, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  ++i;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t skip = 0;
    int32_t asm_backend = 0;
    (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->use_asm_backend != 0) {   (asm_backend = (1));
 } else (__tmp = 0) ; __tmp; }));
    (skip = (codegen_should_skip_emit_func_by_name((&((skip_name)[0])), skip_nl)));
    (void)(({ int32_t __tmp = 0; if (skip == 0 && prefix_len == 0 && asm_backend == 0) {   (skip = (codegen_should_skip_emit_func_core_read_ptr((&((skip_name)[0])), skip_nl)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (skip == 0 && prefix_len > 0 && asm_backend == 0) {   (skip = (codegen_should_skip_emit_func(((uint8_t *)(0)), (&((prefix_buf)[0])), prefix_len, (&((skip_name)[0])), skip_nl)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (skip == 0 && dep_index >= 0 && ctx != ((struct ast_PipelineDepCtx *)(0)) && dep_path_prefix_len > 0 && asm_backend == 0) {   (skip = (codegen_should_skip_emit_func((&((dep_path_prefix)[0])), ((uint8_t *)(0)), 0, (&((skip_name)[0])), skip_nl)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (skip == 0 && asm_backend == 0) {   uint8_t * skip_dep = ((uint8_t *)(0));
  (void)(({ uint8_t * __tmp = 0; if (dep_index >= 0 && ctx != ((struct ast_PipelineDepCtx *)(0)) && dep_path_prefix_len > 0) {   (skip_dep = ((&((dep_path_prefix)[0]))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ uint8_t * __tmp = 0; if (skip_dep == ((uint8_t *)(0))) {   (skip_dep = (driver_get_current_dep_path_for_codegen()));
 } else (__tmp = 0) ; __tmp; }));
  (skip = (codegen_should_skip_emit_func(skip_dep, ((uint8_t *)(0)), 0, (&((skip_name)[0])), skip_nl)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (skip != 0) {   ++i;
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int is_entry = i == (module)->main_func_index || (module)->num_funcs == 1;
    int32_t saved_func_idx = -1;
    (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   (saved_func_idx = ((ctx)->current_func_index));
  ((ctx)->current_func_index = (i));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (codegen_emit_func(arena, out, module, i, is_entry, (&((prefix_buf)[0])), prefix_len, ctx, call_init_globals) != 0) {   (void)(driver_diagnostic_codegen_emit_func_fail(module, i));
   (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_func_index = (saved_func_idx));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   ((ctx)->current_func_index = (saved_func_idx));
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 0;
}
int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len) {
  uint8_t ph11[11] = { 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114 };
  uint8_t ssp22[22] = { 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114 };
  uint8_t sn10[10] = { 115, 116, 114, 105, 110, 103, 95, 110, 101, 119 };
  uint8_t sssn22[22] = { 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 95, 110, 101, 119, 0 };
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, (&((ph11)[0])), 11) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, (&((ssp22)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 10 && codegen_name_bytes_prefix_eq(name, name_len, (&((sn10)[0])), 10) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, (&((sssn22)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, (&((sssn22)[0])), 21) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_codegen_emit_seed_mega_enabled() == 0) {
    if (name_len == 25 && memcmp(name, "asm_codegen_ast_seed_mega", 25) == 0) return 1;
    if (name_len == 32 && memcmp(name, "asm_codegen_ast_to_elf_seed_mega", 32) == 0) return 1;
  } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len) {
  uint8_t rd_batch[21] = { 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  uint8_t wr_batch[22] = { 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102 };
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd_batch)[0])), 21) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr_batch)[0])), 22) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  return 0;
}
int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len) {
  uint8_t shu_len19[19] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110 };
  uint8_t shu15[15] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114 };
  uint8_t shu_reg15[15] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114 };
  uint8_t shu_reg_bufs23[23] = { 115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102, 102, 101, 114, 115 };
  uint8_t shu_unreg_bufs25[25] = { 115, 104, 117, 95, 105, 111, 95, 117, 110, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102, 102, 101, 114, 115 };
  uint8_t shu_wait_rd20[20] = { 115, 104, 117, 95, 105, 111, 95, 119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101 };
  (void)(({ int32_t __tmp = 0; if (name == ((uint8_t *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len >= 19 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu_len19)[0])), 19) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu15)[0])), 15) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu_reg15)[0])), 15) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 23 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu_reg_bufs23)[0])), 23) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu_unreg_bufs25)[0])), 25) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len == 20 && codegen_name_bytes_prefix_eq(name, name_len, (&((shu_wait_rd20)[0])), 20) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t pre7[7] = { 115, 116, 100, 95, 105, 111, 95 };
  uint8_t rd13[13] = { 114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100 };
  uint8_t wr14[14] = { 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100 };
  (void)(({ int32_t __tmp = 0; if (prefix == ((uint8_t *)(0)) || name == ((uint8_t *)(0)) || prefix_len < 7 || name_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (codegen_name_bytes_prefix_eq(prefix, prefix_len, (&((pre7)[0])), 7) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len >= 13 && codegen_name_bytes_prefix_eq(name, name_len, (&((rd13)[0])), 13) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (name_len >= 14 && codegen_name_bytes_prefix_eq(name, name_len, (&((wr14)[0])), 14) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
