/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shulang_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shulang_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern int32_t shu_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shu_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shu_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shu_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shu_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };

/* ast gen2 late link aliases */
#define ast_block_for_step_ref ast_ast_block_for_step_ref
#define ast_block_for_body_ref ast_ast_block_for_body_ref
#define ast_block_if_cond_ref ast_ast_block_if_cond_ref
#define ast_block_if_then_body_ref ast_ast_block_if_then_body_ref
#define ast_block_if_else_body_ref ast_ast_block_if_else_body_ref
#define ast_arena_patch_block_parent_links ast_ast_arena_patch_block_parent_links

/* ast gen2 single-prefix externs */
extern void ast_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern int32_t ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int32_t ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_arena_type_alloc(struct ast_ASTArena * arena);
extern struct ast_Expr ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern int32_t ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
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
extern void ast_arena_patch_block_parent_links(struct ast_ASTArena * arena, int32_t block_ref, int32_t parent_ref);

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
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_allow_padding_at ast_pipeline_module_struct_layout_allow_padding_at
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_field_offset_at ast_pipeline_module_struct_layout_field_offset_at
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_module_at ast_pipeline_dep_ctx_module_at
#define pipeline_module_struct_layout_alloc ast_pipeline_module_struct_layout_alloc
#define pipeline_module_struct_layout_set_field ast_pipeline_module_struct_layout_set_field
#define pipeline_module_struct_layout_set_num_fields ast_pipeline_module_struct_layout_set_num_fields
#define pipeline_module_struct_layout_reset_slot ast_pipeline_module_struct_layout_reset_slot
#define pipeline_module_struct_layout_set_name ast_pipeline_module_struct_layout_set_name
#define pipeline_module_func_name_byte_at ast_pipeline_module_func_name_byte_at
#define pipeline_dep_ctx_arena_at ast_pipeline_dep_ctx_arena_at
#define pipeline_module_struct_layout_name_byte_at ast_pipeline_module_struct_layout_name_byte_at
#define pipeline_module_struct_layout_set_allow_padding ast_pipeline_module_struct_layout_set_allow_padding
#define pipeline_module_func_return_type_at ast_pipeline_module_func_return_type_at
#define pipeline_module_func_name_equal_at ast_pipeline_module_func_name_equal_at
#define pipeline_module_import_path_len ast_pipeline_module_import_path_len
#define pipeline_module_import_kind_at ast_pipeline_module_import_kind_at
#define pipeline_module_import_select_count_at ast_pipeline_module_import_select_count_at
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
#define pipeline_module_top_level_let_type_ref ast_pipeline_module_top_level_let_type_ref
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_type_alloc ast_ast_arena_type_alloc
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_expr_apply_call_resolve ast_ast_expr_apply_call_resolve
#define ast_block_final_expr_ref ast_ast_block_final_expr_ref
#define ast_block_num_expr_stmts ast_ast_block_num_expr_stmts
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_block_resolve_var_to_type_ref ast_ast_block_resolve_var_to_type_ref
#define ast_block_num_stmt_order ast_ast_block_num_stmt_order
#define ast_block_stmt_order_kind ast_ast_block_stmt_order_kind
#define ast_block_stmt_order_idx ast_ast_block_stmt_order_idx
#define ast_expr_disallows_implicit_tail ast_ast_expr_disallows_implicit_tail
#define ast_block_num_consts ast_ast_block_num_consts
#define ast_block_num_lets ast_ast_block_num_lets
#define ast_block_num_loops ast_ast_block_num_loops
#define ast_block_num_for_loops ast_ast_block_num_for_loops
#define ast_block_num_if_stmts ast_ast_block_num_if_stmts
#define ast_block_const_init_ref ast_ast_block_const_init_ref
#define ast_block_const_type_ref ast_ast_block_const_type_ref
#define ast_block_let_init_ref ast_ast_block_let_init_ref
#define ast_block_let_type_ref ast_ast_block_let_type_ref
#define ast_block_while_cond_ref ast_ast_block_while_cond_ref
#define ast_block_while_body_ref ast_ast_block_while_body_ref
#define ast_block_for_init_ref ast_ast_block_for_init_ref
#define ast_block_for_cond_ref ast_ast_block_for_cond_ref
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_func_set ast_ast_arena_func_set

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_type_named_name_into pipeline_type_named_name_into
#define ast_pipeline_type_kind_ord_at pipeline_type_kind_ord_at
#define ast_pipeline_get_dep_arena_slot pipeline_get_dep_arena_slot
#define ast_pipeline_module_func_param_type_ref_for_name pipeline_module_func_param_type_ref_for_name
#define ast_pipeline_module_func_is_extern_at pipeline_module_func_is_extern_at
#define ast_pipeline_module_func_body_ref_at pipeline_module_func_body_ref_at
#define ast_pipeline_module_func_name_len_at pipeline_module_func_name_len_at
#define ast_pipeline_module_func_name_copy64 pipeline_module_func_name_copy64
#define ast_pipeline_expr_struct_lit_num_fields pipeline_expr_struct_lit_num_fields
#define ast_pipeline_expr_struct_lit_type_name_len pipeline_expr_struct_lit_type_name_len
#define ast_pipeline_expr_struct_lit_type_name_into pipeline_expr_struct_lit_type_name_into
#define ast_pipeline_expr_struct_lit_field_name_len pipeline_expr_struct_lit_field_name_len
#define ast_pipeline_expr_struct_lit_field_name_into pipeline_expr_struct_lit_field_name_into
#define ast_pipeline_expr_struct_lit_init_ref pipeline_expr_struct_lit_init_ref
#define ast_pipeline_expr_resolved_type_ref pipeline_expr_resolved_type_ref
#define ast_pipeline_type_ensure_by_kind_ord pipeline_type_ensure_by_kind_ord
#define ast_pipeline_type_find_or_alloc_named pipeline_type_find_or_alloc_named
#define ast_pipeline_type_find_or_alloc_compound pipeline_type_find_or_alloc_compound
#define ast_pipeline_expr_kind_ord_at pipeline_expr_kind_ord_at
#define ast_pipeline_expr_unary_operand_ref_at pipeline_expr_unary_operand_ref_at
#define ast_pipeline_expr_field_access_name_into pipeline_expr_field_access_name_into
#define ast_pipeline_expr_field_access_name_len pipeline_expr_field_access_name_len
#define ast_pipeline_expr_field_access_base_ref pipeline_expr_field_access_base_ref
#define ast_pipeline_expr_var_name_into pipeline_expr_var_name_into
#define ast_pipeline_expr_var_name_len pipeline_expr_var_name_len

/* slim arena grow pool glue (linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; };

/* pipeline glue usage aliases */
extern struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
#define pipeline_arena_block_get_copy ast_pipeline_arena_block_get_copy
#define pipeline_arena_expr_get_copy ast_pipeline_arena_expr_get_copy
#define pipeline_arena_func_get_copy ast_pipeline_arena_func_get_copy
#define pipeline_arena_type_get_copy ast_pipeline_arena_type_get_copy
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_expr_call_arg_ref ast_pipeline_expr_call_arg_ref
#define pipeline_expr_match_arm_result_ref ast_pipeline_expr_match_arm_result_ref
#define pipeline_expr_method_call_arg_ref ast_pipeline_expr_method_call_arg_ref
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
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern int ast_ref_is_null(int32_t ref);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern struct ast_Module * ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern void ast_pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t li, int32_t j, uint8_t * fname_bytes, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module * module, int32_t idx, int32_t nf);
extern void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module * module, int32_t fi, int32_t i);
extern struct ast_ASTArena * ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
extern void ast_ast_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern int32_t ast_pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern int32_t ast_pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern void ast_expr_init_call_resolve(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t typeck_float64_bits_lo(double d);
extern int32_t typeck_float64_bits_hi(double d);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * out);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t type_ref);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);
extern uint8_t * driver_typeck_diag_scratch_expect();
extern uint8_t * driver_typeck_diag_scratch_found();
extern struct ast_ASTArena * pipeline_get_dep_arena_slot(int32_t ix);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module * module, int32_t func_index, uint8_t * vname, int32_t vname_len);
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
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena * arena, int32_t kind_ord);
extern int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
extern int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena * arena, int32_t kind_ord, int32_t elem_ref, int32_t array_size);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern void asm_qual_sym_layer_reset();
extern int32_t asm_qual_sym_layer_push(uint8_t * bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count();
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t * dst, int32_t cap);
extern void driver_diagnostic_typeck_struct_padding_before(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t * sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t layout_idx, int32_t j);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
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
int32_t typeck_su_named_builtin_align(uint8_t * nm, int32_t nlen);
int32_t typeck_su_named_builtin_size(uint8_t * nm, int32_t nlen);
int32_t typeck_su_type_align(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth);
int32_t typeck_su_type_size(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth);
int32_t typeck_struct_layout_metrics(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth, int32_t check_pad, int32_t * out_sz, int32_t * out_al);
int32_t typeck_validate_struct_layouts_zero_padding(struct ast_Module * module, struct ast_ASTArena * arena);
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref);
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index);
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena * arena, int32_t base_type_ref, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena);
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a);
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena);
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size);
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size);
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, enum ast_TypeKind kind);
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref);
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref);
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size);
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena);
int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_inline_u8_64_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_expr_inline_array_field_type_ref(struct ast_ASTArena * arena, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen);
void typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
void typeck_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out);
int32_t typeck_import_path_segment_count(uint8_t * path, int32_t path_len);
int typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out);
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_expr_type_ref_impl(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b);
int typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b);
int32_t typeck_coerce_init_expr_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref);
int32_t typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len);
int32_t typeck_diag_append_u32_dec(uint8_t * out, int32_t pos, int32_t cap, int32_t v);
int32_t typeck_diag_fmt_type_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cur, int32_t cap);
int32_t typeck_diag_fmt_type_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cap);
int32_t typeck_diag_fmt_type_or_question(struct ast_ASTArena * arena, int32_t ref, uint8_t * out);
void typeck_ret_coerce_integral_to_expect_i32(struct ast_ASTArena * arena, int32_t op_ref, int32_t expect_ref);
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref);
int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref);
int32_t typeck_check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
void typeck_patch_all_body_parent_links(struct ast_Module * module, struct ast_ASTArena * arena);
int32_t typeck_su_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_su_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_type_kind_ordinal(enum ast_TypeKind k) {
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_I32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_BOOL) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_U8) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_U32) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_U64) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_I64) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_USIZE) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_ISIZE) {   return 7;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_NAMED) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_PTR) {   return 9;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_ARRAY) {   return 10;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_SLICE) {   return 11;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_VECTOR) {   return 12;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_F32) {   return 13;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_F64) {   return 14;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (k == ast_TypeKind_TYPE_VOID) {   return 15;
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int typeck_name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len) {
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < a_len) {
    (void)(({ int __tmp = 0; if ((a)[i] != (b)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int typeck_layout_name_equal(struct ast_Module * module, int32_t k, uint8_t * nm, int32_t nlen) {
  uint8_t buf[64] = { 0 };
  int32_t slen = ast_pipeline_module_struct_layout_name_len(module, k);
  (void)(({ int __tmp = 0; if (slen != nlen || nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_name_into(module, k, (&((buf)[0]))));
  return typeck_name_equal((&((buf)[0])), slen, nm, nlen);
}
int typeck_layout_field_name_equal(struct ast_Module * module, int32_t k, int32_t j, uint8_t * nm, int32_t nlen) {
  uint8_t buf[64] = { 0 };
  int32_t fl = ast_pipeline_module_struct_layout_field_name_len(module, k, j);
  (void)(({ int __tmp = 0; if (fl != nlen || nlen <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_field_name_into(module, k, j, (&((buf)[0]))));
  return typeck_name_equal((&((buf)[0])), fl, nm, nlen);
}
int32_t typeck_layout_name_into(struct ast_Module * module, int32_t k, uint8_t * buf) {
  int32_t slen = ast_pipeline_module_struct_layout_name_len(module, k);
  (void)(ast_pipeline_module_struct_layout_name_into(module, k, buf));
  return slen;
}
int32_t typeck_layout_field_name_into(struct ast_Module * module, int32_t k, int32_t j, uint8_t * buf) {
  int32_t fl = ast_pipeline_module_struct_layout_field_name_len(module, k, j);
  (void)(ast_pipeline_module_struct_layout_field_name_into(module, k, j, buf));
  return fl;
}
int typeck_import_path_slice_equal(struct ast_Module * module, int32_t imp_ix, int32_t off, int32_t seg_len, uint8_t * nm, int32_t nm_len) {
  (void)(({ int __tmp = 0; if (seg_len != nm_len || seg_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < seg_len) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_import_path_byte_at(module, imp_ix, off + i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int typeck_import_binding_name_equal(struct ast_Module * module, int32_t imp_ix, uint8_t * nm, int32_t nm_len) {
  int32_t bl = ast_pipeline_module_import_binding_name_len(module, imp_ix);
  (void)(({ int __tmp = 0; if (bl != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_import_binding_name_byte_at(module, imp_ix, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int typeck_import_select_name_equal(struct ast_Module * module, int32_t imp_ix, int32_t sel, uint8_t * nm, int32_t nm_len) {
  int32_t sl = ast_pipeline_module_import_select_name_len(module, imp_ix, sel);
  (void)(({ int __tmp = 0; if (sl != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_import_select_name_byte_at(module, imp_ix, sel, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int typeck_top_level_let_name_equal(struct ast_Module * module, int32_t tl_ix, uint8_t * nm, int32_t nm_len) {
  int32_t tll = ast_pipeline_module_top_level_let_name_len(module, tl_ix);
  (void)(({ int __tmp = 0; if (tll != nm_len || nm_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < nm_len) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_top_level_let_name_byte_at(module, tl_ix, i) != (nm)[i]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int32_t typeck_find_layout_idx_by_type_name(struct ast_Module * module, uint8_t * nm, int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, nm, nlen)) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return (-1);
}
int32_t typeck_su_named_builtin_align(uint8_t * nm, int32_t nlen) {
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
int32_t typeck_su_named_builtin_size(uint8_t * nm, int32_t nlen) {
  int32_t a = typeck_su_named_builtin_align(nm, nlen);
  (void)(({ int32_t __tmp = 0; if (a == 1 && nlen == 2 && (nm)[0] == 117 && (nm)[1] == 56) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (a == 4) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (a == 8) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_su_type_align(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > (arena)->num_types || depth > 64) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, ty_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_U8) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_I32 || (t).kind == ast_TypeKind_TYPE_U32 || (t).kind == ast_TypeKind_TYPE_BOOL || (t).kind == ast_TypeKind_TYPE_F32) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_I64 || (t).kind == ast_TypeKind_TYPE_U64 || (t).kind == ast_TypeKind_TYPE_USIZE || (t).kind == ast_TypeKind_TYPE_ISIZE || (t).kind == ast_TypeKind_TYPE_F64 || (t).kind == ast_TypeKind_TYPE_PTR) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_SLICE) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_ARRAY || (t).kind == ast_TypeKind_TYPE_VECTOR) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((t).elem_type_ref)) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_su_type_align(module, arena, (t).elem_type_ref, depth + 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_NAMED) {   int32_t li = typeck_find_layout_idx_by_type_name(module, (&(((t).name)[0])), (t).name_len);
  (void)(({ int32_t __tmp = 0; if (li >= 0) {   int32_t z = 0;
  int32_t al = 1;
  (void)(({ int32_t __tmp = 0; if (typeck_struct_layout_metrics(module, arena, li, depth + 1, 0, (&(z)), (&(al))) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return al;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ba = typeck_su_named_builtin_align((&(((t).name)[0])), (t).name_len);
  (void)(({ int32_t __tmp = 0; if (ba > 0) {   return ba;
 } else (__tmp = 0) ; __tmp; }));
  return 4;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int32_t typeck_su_type_size(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty_ref, int32_t depth) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > (arena)->num_types || depth > 64) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, ty_ref);
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_VOID) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_U8) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_I32 || (t).kind == ast_TypeKind_TYPE_U32 || (t).kind == ast_TypeKind_TYPE_BOOL || (t).kind == ast_TypeKind_TYPE_F32) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_I64 || (t).kind == ast_TypeKind_TYPE_U64 || (t).kind == ast_TypeKind_TYPE_USIZE || (t).kind == ast_TypeKind_TYPE_ISIZE || (t).kind == ast_TypeKind_TYPE_F64 || (t).kind == ast_TypeKind_TYPE_PTR) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_SLICE) {   return 16;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_ARRAY || (t).kind == ast_TypeKind_TYPE_VECTOR) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((t).elem_type_ref) || (t).array_size <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t es = typeck_su_type_size(module, arena, (t).elem_type_ref, depth + 1);
  (void)(({ int32_t __tmp = 0; if (es <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return (t).array_size * es;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_NAMED) {   int32_t li2 = typeck_find_layout_idx_by_type_name(module, (&(((t).name)[0])), (t).name_len);
  (void)(({ int32_t __tmp = 0; if (li2 >= 0) {   int32_t z2 = 0;
  int32_t al2 = 1;
  (void)(({ int32_t __tmp = 0; if (typeck_struct_layout_metrics(module, arena, li2, depth + 1, 0, (&(z2)), (&(al2))) != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return z2;
 } else (__tmp = 0) ; __tmp; }));
  int32_t bsz = typeck_su_named_builtin_size((&(((t).name)[0])), (t).name_len);
  (void)(({ int32_t __tmp = 0; if (bsz > 0) {   return bsz;
 } else (__tmp = 0) ; __tmp; }));
  return 4;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_struct_layout_metrics(struct ast_Module * module, struct ast_ASTArena * arena, int32_t li, int32_t depth, int32_t check_pad, int32_t * out_sz, int32_t * out_al) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || arena == ((struct ast_ASTArena *)(0)) || out_sz == ((int32_t *)(0)) || out_al == ((int32_t *)(0))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (li < 0 || li >= (module)->num_struct_layouts || depth > 64) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t nf = ast_pipeline_module_struct_layout_num_fields(module, li);
  int32_t allow = ast_pipeline_module_struct_layout_allow_padding_at(module, li);
  uint8_t layout_name[64] = { 0 };
  int32_t layout_nlen = typeck_layout_name_into(module, li, (&((layout_name)[0])));
  int32_t current = 0;
  int32_t max_align = 1;
  int32_t j = 0;
  while (j < nf) {
    int32_t ftr = ast_pipeline_module_struct_layout_field_type_ref(module, li, j);
    uint8_t fname[64] = { 0 };
    int32_t flen = typeck_layout_field_name_into(module, li, j, (&((fname)[0])));
    int32_t A = typeck_su_type_align(module, arena, ftr, depth);
    (void)(({ int32_t __tmp = 0; if (A <= 0) {   (void)((A = 1));
 } else (__tmp = 0) ; __tmp; }));
    int32_t rem = (A == 0 ? (shulang_panic_(1, 0), current) : (current % A));
    int32_t gap = A - rem;
    (void)((gap = (A == 0 ? (shulang_panic_(1, 0), gap) : (gap % A))));
    (void)(({ int32_t __tmp = 0; if (check_pad != 0 && gap > 0 && allow == 0) {   (void)(driver_diagnostic_typeck_struct_padding_before((&((layout_name)[0])), layout_nlen, gap, (&((fname)[0])), flen));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((current = current + gap));
    int32_t fsize = typeck_su_type_size(module, arena, ftr, depth);
    (void)(({ int32_t __tmp = 0; if (fsize <= 0) {   (void)(driver_diagnostic_typeck_struct_field_bad_size((&((layout_name)[0])), layout_nlen, (&((fname)[0])), flen));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((current = current + fsize));
    (void)(({ int32_t __tmp = 0; if (A > max_align) {   (void)((max_align = A));
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  (void)(({ int32_t __tmp = 0; if (max_align > 0 && (max_align == 0 ? (shulang_panic_(1, 0), current) : (current % max_align)) != 0) {   int32_t end_pad = max_align - (max_align == 0 ? (shulang_panic_(1, 0), current) : (current % max_align));
  (void)(({ int32_t __tmp = 0; if (check_pad != 0 && end_pad > 0 && allow == 0) {   (void)(driver_diagnostic_typeck_struct_padding_trailing((&((layout_name)[0])), layout_nlen, end_pad));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)((current = current + end_pad));
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_sz)[0] = current));
  (void)(((out_al)[0] = max_align));
  return 0;
}
int32_t typeck_validate_struct_layouts_zero_padding(struct ast_Module * module, struct ast_ASTArena * arena) {
  int32_t li = 0;
  while (li < (module)->num_struct_layouts) {
    int32_t dz = 0;
    int32_t da = 1;
    (void)(({ int32_t __tmp = 0; if (typeck_struct_layout_metrics(module, arena, li, 0, 1, (&(dz)), (&(da))) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((li = li + 1));
  }
  return 0;
}
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {   int32_t j = 0;
  while (j < ast_pipeline_module_struct_layout_num_fields(module, k)) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {   return ast_pipeline_module_struct_layout_field_offset_at(module, k, j);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return (-1);
}
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {   int32_t j = 0;
  while (j < ast_pipeline_module_struct_layout_num_fields(module, k)) {
    (void)(({ int32_t __tmp = 0; if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {   return ast_pipeline_module_struct_layout_field_type_ref(module, k, j);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
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
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)((r = typeck_get_field_offset_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r >= 0) {   return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((di = di + 1));
  }
  return (-1);
}
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref) {
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (num_fields <= 0 || num_fields > 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t type_name_buf[64] = { 0 };
  (void)(pipeline_expr_struct_lit_type_name_into(arena, expr_ref, (&((type_name_buf)[0]))));
  int32_t k = 0;
  int32_t found_idx = (-1);
  while (k < (module)->num_struct_layouts) {
    uint8_t sname_buf[64] = { 0 };
    (void)(ast_pipeline_module_struct_layout_name_into(module, k, (&((sname_buf)[0]))));
    int32_t sname_len = ast_pipeline_module_struct_layout_name_len(module, k);
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&((sname_buf)[0])), sname_len, (&((type_name_buf)[0])), name_len)) {   (void)((found_idx = k));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  (void)(({ int32_t __tmp = 0; if (found_idx >= 0) {   int32_t idx_m = found_idx;
  int32_t jm = 0;
  while (jm < num_fields) {
    uint8_t lit_fnbuf[64] = { 0 };
    (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, jm, (&((lit_fnbuf)[0]))));
    int32_t fnlen_m = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, jm);
    int32_t exists_m = 0;
    int32_t tm = 0;
    int32_t nf_layout = ast_pipeline_module_struct_layout_num_fields(module, idx_m);
    while (tm < nf_layout) {
      uint8_t fnbuf[64] = { 0 };
      (void)(ast_pipeline_module_struct_layout_field_name_into(module, idx_m, tm, (&((fnbuf)[0]))));
      int32_t flen_tm = ast_pipeline_module_struct_layout_field_name_len(module, idx_m, tm);
      (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&((fnbuf)[0])), flen_tm, (&((lit_fnbuf)[0])), fnlen_m)) {   (void)((exists_m = 1));
 } else (__tmp = 0) ; __tmp; }));
      (void)((tm = tm + 1));
    }
    (void)(({ int32_t __tmp = 0; if (exists_m == 0) {   int32_t nf_m = nf_layout;
  int32_t ftr_m = 0;
  int32_t init_rm = pipeline_expr_struct_lit_init_ref(arena, expr_ref, jm);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_rm)) && init_rm > 0 && init_rm <= (arena)->num_exprs) {   int32_t fr_m = typeck_expr_type_ref(arena, init_rm);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr_m))) {   (void)((ftr_m = fr_m));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_set_field(module, idx_m, nf_m, (&((lit_fnbuf)[0])), fnlen_m, ftr_m, nf_m * 8));
  (void)(ast_pipeline_module_struct_layout_set_num_fields(module, idx_m, nf_m + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((jm = jm + 1));
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t idx = ast_pipeline_module_struct_layout_alloc(module);
  (void)(({ int32_t __tmp = 0; if (idx < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_reset_slot(module, idx));
  (void)(ast_pipeline_module_struct_layout_set_name(module, idx, (&((type_name_buf)[0])), name_len));
  (void)(ast_pipeline_module_struct_layout_set_num_fields(module, idx, num_fields));
  int32_t off = 0;
  int32_t j = 0;
  while (j < num_fields) {
    uint8_t lit_fnbuf2[64] = { 0 };
    (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, (&((lit_fnbuf2)[0]))));
    int32_t fnlen_j = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j);
    int32_t ftr = 0;
    int32_t init_r = pipeline_expr_struct_lit_init_ref(arena, expr_ref, j);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_r)) && init_r > 0 && init_r <= (arena)->num_exprs) {   int32_t fr = typeck_expr_type_ref(arena, init_r);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr))) {   (void)((ftr = fr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_pipeline_module_struct_layout_set_field(module, idx, j, (&((lit_fnbuf2)[0])), fnlen_j, ftr, off));
    (void)((off = off + 8));
    (void)((j = j + 1));
  }
  return 0;
}
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index) {
  uint8_t vbuf[64] = { 0 };
  int32_t b_len = 0;
  int32_t a_len = 0;
  int32_t i = 0;
  (void)(({ int __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 3) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b_len = pipeline_expr_var_name_len(arena, callee_expr_ref)));
  (void)(({ int __tmp = 0; if (func_index < 0 || func_index >= (mod)->num_funcs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)((a_len = pipeline_module_func_name_len_at(mod, func_index)));
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0 || a_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_expr_var_name_into(arena, callee_expr_ref, (&((vbuf)[0]))));
  while (i < a_len) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_func_name_byte_at(mod, func_index, i) != (i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), (vbuf)[0]) : (vbuf)[i])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len) {
  return pipeline_type_find_or_alloc_named(arena, name, name_len);
}
int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena * arena, int32_t base_type_ref, uint8_t * field_name, int32_t field_name_len) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(base_type_ref) || base_type_ref <= 0 || base_type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type bt_nm;
  bt_nm = pipeline_arena_type_get_copy(arena, base_type_ref);
  int32_t bn_len = (bt_nm).name_len;
  (void)(({ int32_t __tmp = 0; if (bn_len <= 0 || bn_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t bn[64] = { 0 };
  int32_t bni = 0;
  while (bni < bn_len && bni < 64) {
    (void)(((bni < 0 || (bni) >= 64 ? (shulang_panic_(1, 0), 0) : ((bn)[bni] = (bni < 0 || (bni) >= 64 ? (shulang_panic_(1, 0), ((bt_nm).name)[0]) : ((bt_nm).name)[bni]), 0))));
    (void)((bni = bni + 1));
  }
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
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena) {
  return pipeline_type_ensure_by_kind_ord(arena, 0);
}
int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena * arena) {
  return pipeline_type_ensure_by_kind_ord(arena, 2);
}
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena) {
  return pipeline_type_ensure_by_kind_ord(arena, 1);
}
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena) {
  return pipeline_type_ensure_by_kind_ord(arena, 14);
}
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena) {
  return pipeline_type_ensure_by_kind_ord(arena, 6);
}
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a) {
  return pipeline_type_ensure_by_kind_ord(a, 15);
}
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0 || ctx == ((struct ast_PipelineDepCtx *)(0)) || from_dep_index >= pipeline_dep_ctx_ndep(ctx)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
  (void)(({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   (void)((dep_arena = pipeline_get_dep_arena_slot(from_dep_index)));
  __tmp = ({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_dep_return_type_to_caller_arena(dep_arena, dep_return_type_ref, caller_arena);
}
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena) {
  return pipeline_type_ensure_by_kind_ord(caller_arena, 5);
}
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size) {
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return pipeline_type_find_or_alloc_compound(a, 10, elem_ref, array_size);
}
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size) {
  int32_t elem_ref = typeck_find_or_alloc_named_type_ref(a, elem_nm, elem_nm_len);
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_array_type_ref(a, elem_ref, array_size);
}
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, enum ast_TypeKind kind) {
  return pipeline_type_ensure_by_kind_ord(w, typeck_type_kind_ordinal(kind));
}
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return pipeline_type_find_or_alloc_compound(w, 9, elem_ref, 0);
}
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  return pipeline_type_find_or_alloc_compound(w, 11, elem_ref, 0);
}
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size) {
  return pipeline_type_find_or_alloc_compound(w, 12, elem_ref, array_size);
}
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena) {
  (void)(({ int32_t __tmp = 0; if (dep_return_type_ref <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type tt;
  tt = pipeline_arena_type_get_copy(dep_arena, dep_return_type_ref);
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_I32) {   return typeck_ensure_i32_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_I64) {   return typeck_ensure_i64_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_BOOL) {   return typeck_ensure_bool_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_F64) {   return typeck_ensure_f64_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_U8 || (tt).kind == ast_TypeKind_TYPE_U32 || (tt).kind == ast_TypeKind_TYPE_U64 || (tt).kind == ast_TypeKind_TYPE_ISIZE || (tt).kind == ast_TypeKind_TYPE_F32) {   return typeck_ensure_kind_only_type_ref(caller_arena, (tt).kind);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_USIZE) {   return typeck_ensure_usize_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_VOID) {   return typeck_ensure_void_type_ref(caller_arena);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_NAMED && (tt).name_len > 0) {   return typeck_find_or_alloc_named_type_ref(caller_arena, (tt).name, (tt).name_len);
 } else (__tmp = 0) ; __tmp; }));
  int32_t inner_mapped = 0;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((tt).elem_type_ref))) {   (void)((inner_mapped = typeck_dep_return_type_to_caller_arena(dep_arena, (tt).elem_type_ref, caller_arena)));
  __tmp = ({ int32_t __tmp = 0; if (inner_mapped == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_PTR) {   return typeck_find_or_alloc_ptr_type_ref(caller_arena, inner_mapped);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_SLICE) {   return typeck_find_or_alloc_slice_type_ref(caller_arena, inner_mapped);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_VECTOR) {   return typeck_find_or_alloc_vector_type_ref(caller_arena, inner_mapped, (tt).array_size);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tt).kind == ast_TypeKind_TYPE_ARRAY) {   return typeck_find_or_alloc_array_type_ref(caller_arena, inner_mapped, (tt).array_size);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((tt).elem_type_ref)) || (tt).array_size != 0 || (tt).name_len != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_ensure_kind_only_type_ref(caller_arena, (tt).kind);
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
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)((r = typeck_get_field_type_ref_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r != 0) {   struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, di);
  (void)(({ int32_t __tmp = 0; if (da != ((struct ast_ASTArena *)(0))) {   return typeck_dep_return_type_to_caller_arena(da, r, arena);
 } else (__tmp = 0) ; __tmp; }));
  return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((di = di + 1));
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
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nd_merge = pipeline_dep_ctx_ndep(ctx);
  int32_t di = 0;
  while (di < nd_merge) {
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, di);
    struct ast_ASTArena * darena = pipeline_dep_ctx_arena_at(ctx, di);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0)) || darena == ((struct ast_ASTArena *)(0))) {   (void)((di = di + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t k = 0;
    while (k < (dm)->num_struct_layouts) {
      int32_t nl = ast_pipeline_module_struct_layout_name_len(dm, k);
      (void)(({ int32_t __tmp = 0; if (nl > 0 && nl <= 63) {   int32_t nf_dep = ast_pipeline_module_struct_layout_num_fields(dm, k);
  (void)(({ int32_t __tmp = 0; if (nf_dep > 64) {   (void)((nf_dep = 64));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t dep_nm_buf[64] = { 0 };
  (void)(ast_pipeline_module_struct_layout_name_into(dm, k, (&((dep_nm_buf)[0]))));
  int32_t ex = typeck_entry_module_find_struct_layout_index(mod, (&((dep_nm_buf)[0])), nl);
  int32_t need = 0;
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   (void)((need = 1));
 } else {   int weak_entry = 0;
  (void)(({ int __tmp = 0; if (ast_pipeline_module_struct_layout_num_fields(mod, ex) >= 2 && ast_pipeline_module_struct_layout_field_type_ref(mod, ex, 1) == 0) {   (void)((weak_entry = 1));
 } else (__tmp = 0) ; __tmp; }));
  int is_expr_nm = 0;
  (void)(({ int __tmp = 0; if (nl == 4) {   __tmp = ({ int __tmp = 0; if (ast_pipeline_module_struct_layout_name_byte_at(dm, k, 0) == 69 && ast_pipeline_module_struct_layout_name_byte_at(dm, k, 1) == 120 && ast_pipeline_module_struct_layout_name_byte_at(dm, k, 2) == 112 && ast_pipeline_module_struct_layout_name_byte_at(dm, k, 3) == 114) {   (void)((is_expr_nm = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (nf_dep > ast_pipeline_module_struct_layout_num_fields(mod, ex) || weak_entry || is_expr_nm) {   (void)((need = 1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (need != 0) {   int32_t ni = ex;
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   (void)((ni = ast_pipeline_module_struct_layout_alloc(mod)));
  __tmp = ({ int32_t __tmp = 0; if (ni < 0) {   (void)((k = k + 1));
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_reset_slot(mod, ni));
  (void)(ast_pipeline_module_struct_layout_set_name(mod, ni, (&((dep_nm_buf)[0])), nl));
  int32_t j = 0;
  while (j < nf_dep) {
    int32_t raw_fr = ast_pipeline_module_struct_layout_field_type_ref(dm, k, j);
    int32_t mapped = 0;
    (void)(({ int32_t __tmp = 0; if (raw_fr != 0) {   (void)((mapped = typeck_dep_return_type_to_caller_arena(darena, raw_fr, arena)));
 } else (__tmp = 0) ; __tmp; }));
    uint8_t fn_buf[64] = { 0 };
    int32_t fnlen = ast_pipeline_module_struct_layout_field_name_len(dm, k, j);
    (void)(ast_pipeline_module_struct_layout_field_name_into(dm, k, j, (&((fn_buf)[0]))));
    int32_t foff = ast_pipeline_module_struct_layout_field_offset_at(dm, k, j);
    (void)(ast_pipeline_module_struct_layout_set_field(mod, ni, j, (&((fn_buf)[0])), fnlen, mapped, foff));
    (void)((j = j + 1));
  }
  (void)(ast_pipeline_module_struct_layout_set_num_fields(mod, ni, nf_dep));
  (void)(ast_pipeline_module_struct_layout_set_allow_padding(mod, ni, ast_pipeline_module_struct_layout_allow_padding_at(dm, k)));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
      (void)((k = k + 1));
    }
    (void)((di = di + 1));
  }
}
void typeck_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix) {
  (void)(ast_expr_apply_call_resolve(arena, call_expr_ref, dep_ix, func_ix));
}
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  int32_t j = 0;
  while (j < (mod)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (typeck_expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j)) {   (void)(({ int32_t __tmp = 0; if (func_index_out != ((int32_t *)(0))) {   (void)(((func_index_out)[0] = j));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_dep = ast_pipeline_module_func_return_type_at(mod, j);
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return ret_dep;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, ret_dep, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  return 0;
}
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx, int32_t * func_index_out) {
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < (mod)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {   (void)(({ int32_t __tmp = 0; if (func_index_out != ((int32_t *)(0))) {   (void)(((func_index_out)[0] = j));
 } else (__tmp = 0) ; __tmp; }));
  int32_t rtr = ast_pipeline_module_func_return_type_at(mod, j);
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return rtr;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, rtr, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
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
    (void)(({ int32_t __tmp = 0; if (ch_u8 == 46) {   (void)((n = n + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
  return n;
}
int typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {
  (void)(({ int __tmp = 0; if (module == ((struct ast_Module *)(0)) || imp_ix < 0 || imp_ix >= (module)->num_imports) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t pl = ast_pipeline_module_import_path_len(module, imp_ix);
  (void)(({ int __tmp = 0; if (pl <= 0 || pl > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ci = 0;
  int32_t ss = 0;
  int32_t k = 0;
  while (k <= pl) {
    int at_end_p = k == pl;
    int dot_p = 0;
    (void)(({ int __tmp = 0; if ((!at_end_p) && k < pl) {   (void)((dot_p = ast_pipeline_module_import_path_byte_at(module, imp_ix, k) == 46));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (at_end_p || dot_p) {   int32_t seg_len_here = k - ss;
  (void)(({ int __tmp = 0; if (seg_len_here <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ci == want_seg) {   (void)(((ostr)[0] = ss));
  (void)(((olen)[0] = seg_len_here));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (dot_p) {   (void)((ss = k + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((ci = ci + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return 0;
}
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t * dep_index_out, int32_t * func_index_out) {
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs || module == ((struct ast_Module *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ((int32_t)(44))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t layer_buf[64] = { 0 };
  (void)(asm_qual_sym_layer_reset());
  int32_t nstack = 0;
  int32_t cur_ref = callee_expr_ref;
  while (1) {
    (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    int32_t falen = pipeline_expr_field_access_name_len(arena, cur_ref);
    (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, cur_ref) != ((int32_t)(44)) || falen <= 0 || falen > 63) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_expr_field_access_name_into(arena, cur_ref, (&((layer_buf)[0]))));
    (void)(({ int32_t __tmp = 0; if (asm_qual_sym_layer_push((&((layer_buf)[0])), falen) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((nstack = nstack + 1));
    (void)((cur_ref = pipeline_expr_field_access_base_ref(arena, cur_ref)));
  }
  (void)((nstack = asm_qual_sym_layer_count()));
  (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t vnlen = pipeline_expr_var_name_len(arena, cur_ref);
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, cur_ref) != ((int32_t)(3)) || vnlen <= 0 || vnlen > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t vname_buf[64] = { 0 };
  (void)(pipeline_expr_var_name_into(arena, cur_ref, (&((vname_buf)[0]))));
  int32_t dep_j = 0;
  while (dep_j < (module)->num_imports) {
    int32_t plen = ast_pipeline_module_import_path_len(module, dep_j);
    (void)(({ int32_t __tmp = 0; if (plen <= 0 || plen > 63) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t path_cnt_buf[64] = { 0 };
    int32_t pci = 0;
    while (pci < plen && pci < 64) {
      (void)(((pci < 0 || (pci) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_cnt_buf)[pci] = ast_pipeline_module_import_path_byte_at(module, dep_j, pci), 0))));
      (void)((pci = pci + 1));
    }
    int32_t Pseg = typeck_import_path_segment_count((&((path_cnt_buf)[0])), plen);
    (void)(({ int32_t __tmp = 0; if (Pseg <= 0 || nstack != Pseg) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t s0_rel = 0;
    int32_t s0_ln = 0;
    (void)(({ int32_t __tmp = 0; if ((!typeck_import_segment_at(module, dep_j, 0, (&(s0_rel)), (&(s0_ln))))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!typeck_import_path_slice_equal(module, dep_j, s0_rel, s0_ln, (&((vname_buf)[0])), vnlen))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int bad_mid = 0;
    int32_t sm = 1;
    while (sm <= Pseg - 1) {
      int32_t srv = 0;
      int32_t slv = 0;
      (void)(({ int __tmp = 0; if ((!typeck_import_segment_at(module, dep_j, sm, (&(srv)), (&(slv))))) {   (void)((bad_mid = 1));
 } else {   int32_t lay_ix = Pseg - sm;
  (void)(asm_qual_sym_layer_copy(lay_ix, (&((layer_buf)[0])), 64));
  __tmp = ({ int __tmp = 0; if ((!typeck_import_path_slice_equal(module, dep_j, srv, slv, (&((layer_buf)[0])), asm_qual_sym_layer_len(lay_ix)))) {   (void)((bad_mid = 1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (bad_mid) {   break;
 } else (__tmp = 0) ; __tmp; }));
      (void)((sm = sm + 1));
    }
    (void)(({ int32_t __tmp = 0; if (bad_mid) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, dep_j);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(asm_qual_sym_layer_copy(0, (&((layer_buf)[0])), 64));
    int32_t ret_fn = typeck_find_func_return_type_in_module_by_name(dm, arena, (&((layer_buf)[0])), asm_qual_sym_layer_len(0), dep_j, ctx, func_index_out);
    (void)(({ int32_t __tmp = 0; if (ret_fn != 0) {   __tmp = ({ int32_t __tmp = 0; if (dep_index_out != ((int32_t *)(0))) {   (void)(((dep_index_out)[0] = dep_j));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    return ret_fn;
  }
  return 0;
}
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int want_resolve = call_expr_ref > 0 && call_expr_ref <= (arena)->num_exprs;
  int32_t * null_po = ((int32_t *)(0));
  int32_t whole_dep = 0;
  int32_t whole_fn = 0;
  int32_t * p_whole_dep = null_po;
  int32_t * p_whole_fn = null_po;
  (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)((p_whole_dep = (&(whole_dep))));
  (void)((p_whole_fn = (&(whole_fn))));
 } else (__tmp = 0) ; __tmp; }));
  int32_t callee_ord = pipeline_expr_kind_ord_at(arena, callee_expr_ref);
  (void)(({ int32_t __tmp = 0; if (callee_ord == 44) {   int32_t r_whole = typeck_resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx, p_whole_dep, p_whole_fn);
  __tmp = ({ int32_t __tmp = 0; if (r_whole != 0) {   (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)(typeck_expr_apply_call_resolve(arena, call_expr_ref, whole_dep, whole_fn));
 } else (__tmp = 0) ; __tmp; }));
  return r_whole;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (callee_ord == 44) {   int32_t base_bind_ref = pipeline_expr_field_access_base_ref(arena, callee_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if (base_bind_ref > 0 && base_bind_ref <= (arena)->num_exprs) {   __tmp = ({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, base_bind_ref) == 3) {   int32_t base_bind_len = pipeline_expr_var_name_len(arena, base_bind_ref);
  __tmp = ({ int32_t __tmp = 0; if (base_bind_len > 0 && base_bind_len <= 63) {   uint8_t base_bind_nm[64] = { 0 };
  (void)(pipeline_expr_var_name_into(arena, base_bind_ref, (&((base_bind_nm)[0]))));
  int32_t field_len = pipeline_expr_field_access_name_len(arena, callee_expr_ref);
  uint8_t field_nm[64] = { 0 };
  (void)(pipeline_expr_field_access_name_into(arena, callee_expr_ref, (&((field_nm)[0]))));
  int32_t ii = 0;
  while (ii < (module)->num_imports) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_import_kind_at(module, ii) == ast_ImportKind_IMPORT_BINDING && typeck_import_binding_name_equal(module, ii, (&((base_bind_nm)[0])), base_bind_len)) {   struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, ii);
  (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   int32_t bind_fn = 0;
  int32_t * p_bind_fn = null_po;
  (void)(({ int32_t * __tmp = 0; if (want_resolve) {   (void)((p_bind_fn = (&(bind_fn))));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_b = typeck_find_func_return_type_in_module_by_name(dm, arena, (&((field_nm)[0])), field_len, ii, ctx, p_bind_fn);
  __tmp = ({ int32_t __tmp = 0; if (ret_b != 0) {   (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)(typeck_expr_apply_call_resolve(arena, call_expr_ref, ii, bind_fn));
 } else (__tmp = 0) ; __tmp; }));
  return ret_b;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t minus_one = -1;
  int32_t loc_fn = 0;
  int32_t * p_loc_fn = null_po;
  (void)(({ int32_t * __tmp = 0; if (want_resolve) {   (void)((p_loc_fn = (&(loc_fn))));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret = typeck_find_func_return_type_in_module(module, arena, arena, arena, callee_expr_ref, minus_one, ctx, p_loc_fn);
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)(typeck_expr_apply_call_resolve(arena, call_expr_ref, minus_one, loc_fn));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  int32_t imax = (module)->num_imports;
  int32_t nd_scan = pipeline_dep_ctx_ndep(ctx);
  (void)(({ int32_t __tmp = 0; if (nd_scan > imax) {   (void)((imax = nd_scan));
 } else (__tmp = 0) ; __tmp; }));
  while (i < imax) {
    struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, i);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t dep_fn = 0;
    int32_t * p_dep_fn = null_po;
    (void)(({ int32_t * __tmp = 0; if (want_resolve) {   (void)((p_dep_fn = (&(dep_fn))));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ret = typeck_find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, i, ctx, p_dep_fn)));
    (void)(({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)(typeck_expr_apply_call_resolve(arena, call_expr_ref, i, dep_fn));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (i < (module)->num_imports && ast_pipeline_module_import_kind_at(module, i) == ast_ImportKind_IMPORT_SELECT && callee_ord == 3) {   int32_t cv_len = pipeline_expr_var_name_len(arena, callee_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if (cv_len > 0) {   uint8_t cv_nm[64] = { 0 };
  (void)(pipeline_expr_var_name_into(arena, callee_expr_ref, (&((cv_nm)[0]))));
  int32_t k = 0;
  int32_t sel_cnt = ast_pipeline_module_import_select_count_at(module, i);
  while (k < sel_cnt) {
    (void)(({ int32_t __tmp = 0; if (typeck_import_select_name_equal(module, i, k, (&((cv_nm)[0])), cv_len)) {   (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   int32_t sel_fn = 0;
  int32_t * p_sel_fn = null_po;
  (void)(({ int32_t * __tmp = 0; if (want_resolve) {   (void)((p_sel_fn = (&(sel_fn))));
 } else (__tmp = 0) ; __tmp; }));
  (void)((ret = typeck_find_func_return_type_in_module_by_name(dm, arena, (&((cv_nm)[0])), cv_len, i, ctx, p_sel_fn)));
  __tmp = ({ int32_t __tmp = 0; if (ret != 0) {   (void)(({ int32_t __tmp = 0; if (want_resolve) {   (void)(typeck_expr_apply_call_resolve(arena, call_expr_ref, i, sel_fn));
 } else (__tmp = 0) ; __tmp; }));
  return ret;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_expr_type_ref_impl(struct ast_ASTArena * arena, int32_t expr_ref) {
  return pipeline_expr_resolved_type_ref(arena, expr_ref);
}
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_expr_type_ref_impl(arena, expr_ref);
}
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref) {
  struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref);
  return (t).kind == ast_TypeKind_TYPE_BOOL;
}
int typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (type_ref <= 0 || type_ref > (arena)->num_types) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_type_ref_is_bool_impl(arena, type_ref);
}
int typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  struct ast_Type ta;
  ta = pipeline_arena_type_get_copy(arena, a);
  struct ast_Type tb;
  tb = pipeline_arena_type_get_copy(arena, b);
  (void)(({ int __tmp = 0; if ((ta).kind != (tb).kind) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((ta).kind == ast_TypeKind_TYPE_NAMED && (ta).name_len == (tb).name_len) {   int32_t i = 0;
  while (i < (ta).name_len) {
    (void)(({ int __tmp = 0; if ((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), ((ta).name)[0]) : ((ta).name)[i]) != (i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), ((tb).name)[0]) : ((tb).name)[i])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((ta).kind == ast_TypeKind_TYPE_PTR || (ta).kind == ast_TypeKind_TYPE_SLICE) {   return typeck_type_refs_equal(arena, (ta).elem_type_ref, (tb).elem_type_ref);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((ta).kind == ast_TypeKind_TYPE_ARRAY) {   return (ta).array_size == (tb).array_size && typeck_type_refs_equal(arena, (ta).elem_type_ref, (tb).elem_type_ref);
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(a) || ast_ref_is_null(b)) {   return a == b;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (a == b) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_type_refs_equal_impl(arena, a, b);
}
int32_t typeck_coerce_init_expr_to_decl(struct ast_ASTArena * arena, int32_t init_ref, int32_t decl_ty_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(init_ref) || ast_ref_is_null(decl_ty_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (init_ref <= 0 || init_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr init_e;
  init_e = pipeline_arena_expr_get_copy(arena, init_ref);
  struct ast_Type decl_ty;
  decl_ty = pipeline_arena_type_get_copy(arena, decl_ty_ref);
  (void)(({ int32_t __tmp = 0; if ((init_e).kind == ast_ExprKind_EXPR_LIT) {   (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_PTR && (init_e).int_val == 0) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_ARRAY && (init_e).int_val == 0) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_U8 && (init_e).int_val >= 0 && (init_e).int_val <= 255) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_I64) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((init_e).int_val >= 0 && (decl_ty).kind == ast_TypeKind_TYPE_USIZE || (decl_ty).kind == ast_TypeKind_TYPE_U32 || (decl_ty).kind == ast_TypeKind_TYPE_U64) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((init_e).int_val == 0 && (decl_ty).kind == ast_TypeKind_TYPE_NAMED || (decl_ty).kind == ast_TypeKind_TYPE_VECTOR) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_NAMED && (init_e).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   int32_t base_ix = (init_e).field_access_base_ref;
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(base_ix)) && base_ix > 0 && base_ix <= (arena)->num_exprs) {   struct ast_Expr base_e;
  base_e = pipeline_arena_expr_get_copy(arena, base_ix);
  __tmp = ({ int32_t __tmp = 0; if ((base_e).kind == ast_ExprKind_EXPR_VAR && typeck_name_equal((&(((decl_ty).name)[0])), (decl_ty).name_len, (&(((base_e).var_name)[0])), (base_e).var_name_len)) {   (void)(((init_e).field_access_is_enum_variant = 1));
  (void)(((init_e).enum_variant_tag = 0));
  (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((init_e).field_access_is_enum_variant != 0) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_NAMED && (init_e).kind == ast_ExprKind_EXPR_CALL && ast_ref_is_null((init_e).resolved_type_ref)) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((decl_ty).kind == ast_TypeKind_TYPE_ARRAY && (init_e).kind == ast_ExprKind_EXPR_ARRAY_LIT) {   (void)(((init_e).resolved_type_ref = decl_ty_ref));
  (void)(ast_arena_expr_set(arena, init_ref, init_e));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len) {
  int32_t p = pos;
  int32_t i = 0;
  while (i < lit_len && p >= 0 && p < cap) {
    (void)(((out)[p] = (lit)[i]));
    (void)((p = p + 1));
    (void)((i = i + 1));
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
    (void)((cnt = cnt + 1));
    (void)((tc = (10 == 0 ? (shulang_panic_(1, 0), tc) : (tc / 10))));
  }
  int32_t k = cnt - 1;
  int32_t tm = v;
  while (tm > 0) {
    int32_t d = (10 == 0 ? (shulang_panic_(1, 0), tm) : (tm % 10));
    (void)((tm = (10 == 0 ? (shulang_panic_(1, 0), tm) : (tm / 10))));
    (void)(({ int32_t __tmp = 0; if (pos + k < 0 || pos + k >= cap) {   return p;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out)[pos + k] = ((uint8_t)(d + 48))));
    (void)((k = k - 1));
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
  (void)(({ int32_t __tmp = 0; if (cur < 0 || cap <= 0 || cur >= cap) {   return cur;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ref) || ref <= 0 || ref > (arena)->num_types) {   return typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ty;
  ty = pipeline_arena_type_get_copy(arena, ref);
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_NAMED && (ty).name_len > 0 && (ty).name_len <= 64) {   return typeck_diag_append_lit(out, cur, cap, (&(((ty).name)[0])), (ty).name_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_I32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_i32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_BOOL) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_bool)[0])), 4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U8) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u8)[0])), 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_u64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_I64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_i64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_USIZE) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_usize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_ISIZE) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_isize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_F32) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_f32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_F64) {   return typeck_diag_append_lit(out, cur, cap, (&((lit_f64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_VOID) {   return typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_PTR) {   int32_t nex = typeck_diag_append_lit(out, cur, cap, (&((star)[0])), 1);
  return typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, nex, cap);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_SLICE) {   int32_t nex2 = typeck_diag_append_lit(out, cur, cap, (&((slo)[0])), 2);
  return typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, nex2, cap);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_ARRAY && (!ast_ref_is_null((ty).elem_type_ref)) && (ty).array_size > 0) {   int32_t p0 = typeck_diag_append_lit(out, cur, cap, (&((lbk)[0])), 1);
  int32_t p1 = typeck_diag_append_u32_dec(out, p0, cap, (ty).array_size);
  int32_t p2 = typeck_diag_append_lit(out, p1, cap, (&((rbk)[0])), 1);
  return typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, p2, cap);
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
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ref) || op_ref <= 0 || op_ref > (arena)->num_exprs || ast_ref_is_null(expect_ref)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expect_ref <= 0 || expect_ref > (arena)->num_types) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type exp_ty;
  exp_ty = pipeline_arena_type_get_copy(arena, expect_ref);
  (void)(({ int32_t __tmp = 0; if ((exp_ty).kind != ast_TypeKind_TYPE_I32) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t got_ref = typeck_expr_type_ref(arena, op_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(got_ref) || got_ref <= 0 || got_ref > (arena)->num_types) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type got_ty;
  got_ty = pipeline_arena_type_get_copy(arena, got_ref);
  (void)(({ int32_t __tmp = 0; if ((got_ty).kind != ast_TypeKind_TYPE_U8 && (got_ty).kind != ast_TypeKind_TYPE_USIZE) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr rw;
  rw = pipeline_arena_expr_get_copy(arena, op_ref);
  (void)(((rw).resolved_type_ref = expect_ref));
  (void)(ast_arena_expr_set(arena, op_ref, rw));
}
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FLOAT_LIT) {   (void)(((e).float_bits_lo = typeck_float64_bits_lo((e).float_val)));
  (void)(((e).float_bits_hi = typeck_float64_bits_hi((e).float_val)));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  int32_t ft = typeck_ensure_f64_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (ft != 0) {   (void)(((e).resolved_type_ref = ft));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LIT) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref)) {   int32_t it = typeck_ensure_i32_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (it != 0) {   (void)(((e).resolved_type_ref = it));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BOOL_LIT) {   int32_t bt = typeck_ensure_bool_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(((e).resolved_type_ref = bt));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BREAK || (e).kind == ast_ExprKind_EXPR_CONTINUE) {   (void)(({ int32_t __tmp = 0; if ((ctx)->typeck_loop_depth <= 0) {   int32_t is_br = 0;
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BREAK) {   (void)((is_br = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(driver_diagnostic_typeck_break_continue_outside((e).line, (e).col, is_br));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ENUM_VARIANT) {   int32_t it = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (it != 0) {   (void)(((e).resolved_type_ref = it));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_IF || (e).kind == ast_ExprKind_EXPR_TERNARY) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).if_cond_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_cond_ref))) {   __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, (e).if_cond_ref)))) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).if_then_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).if_else_ref)) && typeck_check_expr(module, arena, (e).if_else_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t ty_t = typeck_expr_type_ref(arena, (e).if_then_ref);
  int32_t ty_e = typeck_expr_type_ref(arena, (e).if_else_ref);
  int t_named = 0;
  int e_named = 0;
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_t)) && ty_t > 0 && ty_t <= (arena)->num_types) {   struct ast_Type tt;
  tt = pipeline_arena_type_get_copy(arena, ty_t);
  (void)((t_named = (tt).kind == ast_TypeKind_TYPE_NAMED));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_e)) && ty_e > 0 && ty_e <= (arena)->num_types) {   struct ast_Type te;
  te = pipeline_arena_type_get_copy(arena, ty_e);
  (void)((e_named = (te).kind == ast_TypeKind_TYPE_NAMED));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_TERNARY) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ty_t) || ast_ref_is_null(ty_e) || (!typeck_type_refs_equal(arena, ty_t, ty_e))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((e).resolved_type_ref = ty_t));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e)) && t_named && e_named && (!typeck_type_refs_equal(arena, ty_t, ty_e))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e))) {   (void)(((e).resolved_type_ref = (e_named && (!t_named) ? ty_e : ty_t)));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t))) {   (void)(((e).resolved_type_ref = ty_t));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_e))) {   (void)(((e).resolved_type_ref = ty_e));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BLOCK) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, (e).block_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).block_ref > 0 && (e).block_ref <= (arena)->num_blocks) {   int32_t fin_blk = ast_block_final_expr_ref(arena, (e).block_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin_blk))) {   (void)(((e).resolved_type_ref = typeck_expr_type_ref(arena, fin_blk)));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if (ast_block_num_expr_stmts(arena, (e).block_ref) == 1) {   int32_t fst_es = ast_block_expr_stmt_ref(arena, (e).block_ref, 0);
  __tmp = ({ int32_t __tmp = 0; if (fst_es > 0 && fst_es <= (arena)->num_exprs) {   struct ast_Expr st;
  st = pipeline_arena_expr_get_copy(arena, fst_es);
  __tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_ASSIGN || (st).kind == ast_ExprKind_EXPR_ADD_ASSIGN || (st).kind == ast_ExprKind_EXPR_SUB_ASSIGN || (st).kind == ast_ExprKind_EXPR_MUL_ASSIGN || (st).kind == ast_ExprKind_EXPR_DIV_ASSIGN || (st).kind == ast_ExprKind_EXPR_MOD_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITAND_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITOR_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITXOR_ASSIGN || (st).kind == ast_ExprKind_EXPR_SHL_ASSIGN || (st).kind == ast_ExprKind_EXPR_SHR_ASSIGN && (!ast_ref_is_null((st).binop_right_ref))) {   (void)(((e).resolved_type_ref = typeck_expr_type_ref(arena, (st).binop_right_ref)));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN || (e).kind == ast_ExprKind_EXPR_ADD_ASSIGN || (e).kind == ast_ExprKind_EXPR_SUB_ASSIGN || (e).kind == ast_ExprKind_EXPR_MUL_ASSIGN || (e).kind == ast_ExprKind_EXPR_DIV_ASSIGN || (e).kind == ast_ExprKind_EXPR_MOD_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITAND_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITOR_ASSIGN || (e).kind == ast_ExprKind_EXPR_BITXOR_ASSIGN || (e).kind == ast_ExprKind_EXPR_SHL_ASSIGN || (e).kind == ast_ExprKind_EXPR_SHR_ASSIGN) {   int32_t left_ref = (e).binop_left_ref;
  int32_t right_ref = (e).binop_right_ref;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, left_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, right_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(left_ref)) && (!ast_ref_is_null(right_ref))) {   int32_t lt = typeck_expr_type_ref(arena, left_ref);
  int32_t rt_after = typeck_expr_type_ref(arena, right_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && lt > 0 && lt <= (arena)->num_types) {   struct ast_Expr rhs_coerce;
  rhs_coerce = pipeline_arena_expr_get_copy(arena, right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rhs_coerce).kind == ast_ExprKind_EXPR_LIT && (!typeck_type_refs_equal(arena, lt, rt_after))) {   struct ast_Type ltp;
  ltp = pipeline_arena_type_get_copy(arena, lt);
  __tmp = ({ int32_t __tmp = 0; if ((ltp).kind == ast_TypeKind_TYPE_U8 && (rhs_coerce).int_val >= 0 && (rhs_coerce).int_val <= 255) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = ({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN && (ltp).kind == ast_TypeKind_TYPE_PTR && (rhs_coerce).int_val == 0) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = ({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN && (rhs_coerce).int_val >= 0 && (ltp).kind == ast_TypeKind_TYPE_USIZE || (ltp).kind == ast_TypeKind_TYPE_U32 || (ltp).kind == ast_TypeKind_TYPE_U64) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = ({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN && (ltp).kind == ast_TypeKind_TYPE_I64) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t rt = typeck_expr_type_ref(arena, right_ref);
  int32_t compound_flag = 1;
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN) {   (void)((compound_flag = 0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   struct ast_Expr rhs_e;
  rhs_e = pipeline_arena_expr_get_copy(arena, right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rhs_e).kind == ast_ExprKind_EXPR_CALL) {   (void)(((rhs_e).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_e));
  (void)((rt = lt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(lt) && (!ast_ref_is_null(rt))) {   struct ast_Expr lhs_e2;
  lhs_e2 = pipeline_arena_expr_get_copy(arena, left_ref);
  __tmp = ({ int32_t __tmp = 0; if ((lhs_e2).kind == ast_ExprKind_EXPR_VAR || (lhs_e2).kind == ast_ExprKind_EXPR_FIELD_ACCESS || (lhs_e2).kind == ast_ExprKind_EXPR_INDEX) {   (void)(((lhs_e2).resolved_type_ref = rt));
  (void)(ast_arena_expr_set(arena, left_ref, lhs_e2));
  (void)((lt = rt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && (!ast_ref_is_null(rt)) && (!typeck_type_refs_equal(arena, lt, rt))) {   uint8_t * eb_ptr = driver_typeck_diag_scratch_expect();
  uint8_t * gb_ptr = driver_typeck_diag_scratch_found();
  int32_t el = typeck_diag_fmt_type_into(arena, lt, eb_ptr, 96);
  int32_t gl = typeck_diag_fmt_type_into(arena, rt, gb_ptr, 96);
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, (e).line, (e).col, eb_ptr, el, gb_ptr, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   struct ast_Expr rhs_sub;
  rhs_sub = pipeline_arena_expr_get_copy(arena, right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rhs_sub).kind == ast_ExprKind_EXPR_SUB || (rhs_sub).kind == ast_ExprKind_EXPR_ADD) {   struct ast_Type lt_ty;
  lt_ty = pipeline_arena_type_get_copy(arena, lt);
  __tmp = ({ int32_t __tmp = 0; if ((lt_ty).kind == ast_TypeKind_TYPE_USIZE) {   (void)(((rhs_sub).resolved_type_ref = lt));
  (void)(ast_arena_expr_set(arena, right_ref, rhs_sub));
  (void)((rt = lt));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(lt) && (!ast_ref_is_null(rt)) || (!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   uint8_t * ebq_ptr = driver_typeck_diag_scratch_expect();
  uint8_t * gbq_ptr = driver_typeck_diag_scratch_found();
  int32_t elq = typeck_diag_fmt_type_or_question(arena, lt, ebq_ptr);
  int32_t glq = typeck_diag_fmt_type_or_question(arena, rt, gbq_ptr);
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, (e).line, (e).col, ebq_ptr, elq, gbq_ptr, glq));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_RETURN) {   int32_t op_ref = (e).unary_operand_ref;
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ref)) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   struct ast_Type rt_bare;
  rt_bare = pipeline_arena_type_get_copy(arena, return_type_ref);
  (void)(({ int32_t __tmp = 0; if ((rt_bare).kind != ast_TypeKind_TYPE_VOID) {   (void)(driver_diagnostic_typeck_ret_fail(1, expr_ref, return_type_ref, 0));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((e).resolved_type_ref = return_type_ref));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   struct ast_Type rt_no_val;
  rt_no_val = pipeline_arena_type_get_copy(arena, return_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt_no_val).kind == ast_TypeKind_TYPE_VOID) {   (void)(driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, typeck_expr_type_ref(arena, op_ref)));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   (void)(driver_diagnostic_typeck_ret_fail(1, op_ref, return_type_ref, 0));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && op_ref > 0 && op_ref <= (arena)->num_exprs && (!ast_ref_is_null(return_type_ref))) {   struct ast_Expr ropw;
  ropw = pipeline_arena_expr_get_copy(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if ((ropw).kind == ast_ExprKind_EXPR_LIT && (ropw).int_val >= 0) {   struct ast_Type rt_w;
  rt_w = pipeline_arena_type_get_copy(arena, return_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt_w).kind == ast_TypeKind_TYPE_USIZE || (rt_w).kind == ast_TypeKind_TYPE_U32 || (rt_w).kind == ast_TypeKind_TYPE_U64) {   (void)(((ropw).resolved_type_ref = return_type_ref));
  (void)(ast_arena_expr_set(arena, op_ref, ropw));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && op_ref > 0 && op_ref <= (arena)->num_exprs) {   struct ast_Expr rop;
  rop = pipeline_arena_expr_get_copy(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rop).kind == ast_ExprKind_EXPR_AS && (!ast_ref_is_null((rop).as_target_type_ref)) && (!ast_ref_is_null(return_type_ref))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_type_refs_equal(arena, (rop).as_target_type_ref, return_type_ref)) {   (void)(((rop).resolved_type_ref = (rop).as_target_type_ref));
  (void)(ast_arena_expr_set(arena, op_ref, rop));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && (!ast_ref_is_null(op_ref))) {   (void)(typeck_ret_coerce_integral_to_expect_i32(arena, op_ref, return_type_ref));
  int32_t got = typeck_expr_type_ref(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(got) || (!typeck_type_refs_equal(arena, got, return_type_ref))) {   uint8_t * eb_ret = driver_typeck_diag_scratch_expect();
  uint8_t * gb_ret = driver_typeck_diag_scratch_found();
  int32_t el_ret = typeck_diag_fmt_type_or_question(arena, return_type_ref, eb_ret);
  int32_t gl_ret = typeck_diag_fmt_type_or_question(arena, got, gb_ret);
  (void)(driver_diagnostic_typeck_return_mismatch((e).line, (e).col, eb_ret, el_ret, gb_ret, gl_ret));
  (void)(driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_PANIC) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   (void)(((e).resolved_type_ref = return_type_ref));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MATCH) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).match_matched_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < (e).match_num_arms) {
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ast_pipeline_expr_match_arm_result_ref(arena, expr_ref, i), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).field_access_base_ref) || (e).field_access_base_ref <= 0 || (e).field_access_base_ref > (arena)->num_exprs) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base_pre;
  base_pre = pipeline_arena_expr_get_copy(arena, (e).field_access_base_ref);
  (void)(({ int32_t __tmp = 0; if ((base_pre).kind == ast_ExprKind_EXPR_VAR && ast_ref_is_null((base_pre).resolved_type_ref) && (base_pre).var_name_len > 0) {   int skip_named_prebind = 0;
  (void)(({ int __tmp = 0; if ((ctx)->current_func_index >= 0 && (ctx)->current_func_index < (module)->num_funcs) {   int32_t param_pre = pipeline_module_func_param_type_ref_for_name(module, (ctx)->current_func_index, (&(((base_pre).var_name)[0])), (base_pre).var_name_len);
  __tmp = ({ int __tmp = 0; if ((!ast_ref_is_null(param_pre))) {   (void)((skip_named_prebind = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!skip_named_prebind)) {   int32_t nt_pre = typeck_find_or_alloc_named_type_ref(arena, (&(((base_pre).var_name)[0])), (base_pre).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if (nt_pre != 0) {   (void)(((base_pre).resolved_type_ref = nt_pre));
  (void)(ast_arena_expr_set(arena, (e).field_access_base_ref, base_pre));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).field_access_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base;
  base = pipeline_arena_expr_get_copy(arena, (e).field_access_base_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((base).resolved_type_ref)) && (base).resolved_type_ref > 0 && (base).resolved_type_ref <= (arena)->num_types) {   struct ast_Type bt;
  bt = pipeline_arena_type_get_copy(arena, (base).resolved_type_ref);
  (void)(({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt).elem_type_ref))) {   uint8_t inner_nm_buf[64] = { 0 };
  int32_t inner_nm_len = pipeline_type_named_name_into(arena, (bt).elem_type_ref, (&((inner_nm_buf)[0])));
  int32_t inner_ord = pipeline_type_kind_ord_at(arena, (bt).elem_type_ref);
  (void)(driver_diagnostic_typeck_ptr_field(typeck_type_kind_ordinal((bt).kind), inner_ord, inner_nm_len, (base).resolved_type_ref, (module)->num_struct_layouts));
  uint8_t nm_astarena[8] = { 65, 83, 84, 65, 114, 101, 110, 97 };
  (void)(({ int32_t __tmp = 0; if (inner_ord == 8 && inner_nm_len == 8 && typeck_name_equal((&((inner_nm_buf)[0])), inner_nm_len, (&((nm_astarena)[0])), 8)) {   int32_t fl = (e).field_access_field_len;
  uint8_t * fn = (&(((e).field_access_field_name)[0]));
  uint8_t nm_types[5] = { 116, 121, 112, 101, 115 };
  uint8_t nm_num_types[9] = { 110, 117, 109, 95, 116, 121, 112, 101, 115 };
  uint8_t nm_exprs[5] = { 101, 120, 112, 114, 115 };
  uint8_t nm_num_exprs[9] = { 110, 117, 109, 95, 101, 120, 112, 114, 115 };
  uint8_t nm_blocks[6] = { 98, 108, 111, 99, 107, 115 };
  uint8_t nm_num_blocks[10] = { 110, 117, 109, 95, 98, 108, 111, 99, 107, 115 };
  uint8_t nm_funcs[5] = { 102, 117, 110, 99, 115 };
  uint8_t nm_num_funcs[9] = { 110, 117, 109, 95, 102, 117, 110, 99, 115 };
  uint8_t nm_ty[4] = { 84, 121, 112, 101 };
  uint8_t nm_ex[4] = { 69, 120, 112, 114 };
  uint8_t nm_bl[5] = { 66, 108, 111, 99, 107 };
  uint8_t nm_fu[4] = { 70, 117, 110, 99 };
  int32_t i32r_at = typeck_ensure_i32_type_ref(arena);
  int matched_at = 0;
  (void)(({ int32_t __tmp = 0; if (fl == 5 && typeck_name_equal(fn, fl, (&((nm_types)[0])), 5)) {   (void)(((e).field_access_offset = 0));
  int32_t arr_types = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_ty)[0])), 4, 512);
  __tmp = ({ int32_t __tmp = 0; if (arr_types != 0) {   (void)(((e).resolved_type_ref = arr_types));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 9 && typeck_name_equal(fn, fl, (&((nm_num_types)[0])), 9)) {   (void)(((e).field_access_offset = 40960));
  __tmp = ({ int32_t __tmp = 0; if (i32r_at != 0) {   (void)(((e).resolved_type_ref = i32r_at));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 5 && typeck_name_equal(fn, fl, (&((nm_exprs)[0])), 5)) {   (void)(((e).field_access_offset = 40968));
  int32_t arr_exprs = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_ex)[0])), 4, 32768);
  __tmp = ({ int32_t __tmp = 0; if (arr_exprs != 0) {   (void)(((e).resolved_type_ref = arr_exprs));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 9 && typeck_name_equal(fn, fl, (&((nm_num_exprs)[0])), 9)) {   (void)(((e).field_access_offset = 6234120));
  __tmp = ({ int32_t __tmp = 0; if (i32r_at != 0) {   (void)(((e).resolved_type_ref = i32r_at));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 6 && typeck_name_equal(fn, fl, (&((nm_blocks)[0])), 6)) {   (void)(((e).field_access_offset = 6234124));
  int32_t arr_blocks = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_bl)[0])), 5, 8192);
  __tmp = ({ int32_t __tmp = 0; if (arr_blocks != 0) {   (void)(((e).resolved_type_ref = arr_blocks));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 10 && typeck_name_equal(fn, fl, (&((nm_num_blocks)[0])), 10)) {   (void)(((e).field_access_offset = 17184780));
  __tmp = ({ int32_t __tmp = 0; if (i32r_at != 0) {   (void)(((e).resolved_type_ref = i32r_at));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 5 && typeck_name_equal(fn, fl, (&((nm_funcs)[0])), 5)) {   (void)(((e).field_access_offset = 17184784));
  int32_t arr_funcs = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_fu)[0])), 4, 256);
  __tmp = ({ int32_t __tmp = 0; if (arr_funcs != 0) {   (void)(((e).resolved_type_ref = arr_funcs));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_at) && fl == 9 && typeck_name_equal(fn, fl, (&((nm_num_funcs)[0])), 9)) {   (void)(((e).field_access_offset = 17371152));
  __tmp = ({ int32_t __tmp = 0; if (i32r_at != 0) {   (void)(((e).resolved_type_ref = i32r_at));
  (void)((matched_at = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (matched_at) {   (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_module[6] = { 77, 111, 100, 117, 108, 101 };
  __tmp = ({ int32_t __tmp = 0; if (inner_ord == 8 && inner_nm_len == 6 && typeck_name_equal((&((inner_nm_buf)[0])), inner_nm_len, (&((nm_module)[0])), 6)) {   int32_t fl_m = (e).field_access_field_len;
  uint8_t * fn_m = (&(((e).field_access_field_name)[0]));
  uint8_t nm_funcs_m[5] = { 102, 117, 110, 99, 115 };
  uint8_t nm_num_funcs_m[9] = { 110, 117, 109, 95, 102, 117, 110, 99, 115 };
  uint8_t nm_struct_layouts_m[14] = { 115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115 };
  uint8_t nm_num_struct_layouts_m[18] = { 110, 117, 109, 95, 115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115 };
  uint8_t nm_fu_m[4] = { 70, 117, 110, 99 };
  uint8_t nm_sl_m[12] = { 83, 116, 114, 117, 99, 116, 76, 97, 121, 111, 117, 116 };
  int32_t i32r_mod = typeck_ensure_i32_type_ref(arena);
  int matched_mod = 0;
  (void)(({ int32_t __tmp = 0; if (fl_m == 5 && typeck_name_equal(fn_m, fl_m, (&((nm_funcs_m)[0])), 5)) {   int32_t arr_funcs_m = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_fu_m)[0])), 4, 256);
  __tmp = ({ int32_t __tmp = 0; if (arr_funcs_m != 0) {   (void)(((e).resolved_type_ref = arr_funcs_m));
  (void)((matched_mod = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_mod) && fl_m == 14 && typeck_name_equal(fn_m, fl_m, (&((nm_struct_layouts_m)[0])), 14)) {   int32_t arr_sl_m = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_sl_m)[0])), 12, 32);
  __tmp = ({ int32_t __tmp = 0; if (arr_sl_m != 0) {   (void)(((e).resolved_type_ref = arr_sl_m));
  (void)((matched_mod = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_mod) && fl_m == 9 && typeck_name_equal(fn_m, fl_m, (&((nm_num_funcs_m)[0])), 9)) {   __tmp = ({ int32_t __tmp = 0; if (i32r_mod != 0) {   (void)(((e).resolved_type_ref = i32r_mod));
  (void)((matched_mod = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!matched_mod) && fl_m == 18 && typeck_name_equal(fn_m, fl_m, (&((nm_num_struct_layouts_m)[0])), 18)) {   __tmp = ({ int32_t __tmp = 0; if (i32r_mod != 0) {   (void)(((e).resolved_type_ref = i32r_mod));
  (void)((matched_mod = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (matched_mod) {   (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t layout_named_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt).elem_type_ref))) {   int32_t un_ord = pipeline_type_kind_ord_at(arena, (bt).elem_type_ref);
  __tmp = ({ int32_t __tmp = 0; if (un_ord == 8) {   (void)((layout_named_ref = (bt).elem_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_NAMED) {   (void)((layout_named_ref = (base).resolved_type_ref));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  uint8_t layout_nm_buf[64] = { 0 };
  int32_t layout_nm_len = 0;
  (void)(({ int32_t __tmp = 0; if (layout_named_ref != 0) {   (void)((layout_nm_len = pipeline_type_named_name_into(arena, layout_named_ref, (&((layout_nm_buf)[0])))));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (layout_nm_len > 0 && pipeline_type_kind_ord_at(arena, layout_named_ref) == 8) {   uint8_t nm_type_kind_ty[8] = { 84, 121, 112, 101, 75, 105, 110, 100 };
  int skip_layout_for_type_kind = 0;
  (void)(({ int32_t __tmp = 0; if (layout_nm_len == 8 && typeck_name_equal((&((layout_nm_buf)[0])), layout_nm_len, (&((nm_type_kind_ty)[0])), 8)) {   int32_t vv = (-1);
  int32_t fl2 = (e).field_access_field_len;
  uint8_t * fn2 = (&(((e).field_access_field_name)[0]));
  uint8_t s_i32[8] = { 84, 121, 112, 101, 95, 73, 51, 50 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_i32)[0])), 8)) {   (void)((vv = 0));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_bool[9] = { 84, 121, 112, 101, 95, 66, 79, 79, 76 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 9 && typeck_name_equal(fn2, fl2, (&((s_bool)[0])), 9)) {   (void)((vv = 1));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_u8[7] = { 84, 121, 112, 101, 95, 85, 56 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 7 && typeck_name_equal(fn2, fl2, (&((s_u8)[0])), 7)) {   (void)((vv = 2));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_u32[8] = { 84, 121, 112, 101, 95, 85, 51, 50 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_u32)[0])), 8)) {   (void)((vv = 3));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_u64[8] = { 84, 121, 112, 101, 95, 85, 54, 52 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_u64)[0])), 8)) {   (void)((vv = 4));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_i64[8] = { 84, 121, 112, 101, 95, 73, 54, 52 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_i64)[0])), 8)) {   (void)((vv = 5));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_usize[10] = { 84, 121, 112, 101, 95, 85, 83, 73, 90, 69 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 10 && typeck_name_equal(fn2, fl2, (&((s_usize)[0])), 10)) {   (void)((vv = 6));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_isize[10] = { 84, 121, 112, 101, 95, 73, 83, 73, 90, 69 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 10 && typeck_name_equal(fn2, fl2, (&((s_isize)[0])), 10)) {   (void)((vv = 7));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_named[10] = { 84, 121, 112, 101, 95, 78, 65, 77, 69, 68 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 10 && typeck_name_equal(fn2, fl2, (&((s_named)[0])), 10)) {   (void)((vv = 8));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_ptr[8] = { 84, 121, 112, 101, 95, 80, 84, 82 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_ptr)[0])), 8)) {   (void)((vv = 9));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_arr[10] = { 84, 121, 112, 101, 95, 65, 82, 82, 65, 89 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 10 && typeck_name_equal(fn2, fl2, (&((s_arr)[0])), 10)) {   (void)((vv = 10));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_sli[10] = { 84, 121, 112, 101, 95, 83, 76, 73, 67, 69 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 10 && typeck_name_equal(fn2, fl2, (&((s_sli)[0])), 10)) {   (void)((vv = 11));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_vec[11] = { 84, 121, 112, 101, 95, 86, 69, 67, 84, 79, 82 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 11 && typeck_name_equal(fn2, fl2, (&((s_vec)[0])), 11)) {   (void)((vv = 12));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_f32[8] = { 84, 121, 112, 101, 95, 70, 51, 50 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_f32)[0])), 8)) {   (void)((vv = 13));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_f64[8] = { 84, 121, 112, 101, 95, 70, 54, 52 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 8 && typeck_name_equal(fn2, fl2, (&((s_f64)[0])), 8)) {   (void)((vv = 14));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t s_void[9] = { 84, 121, 112, 101, 95, 86, 79, 73, 68 };
  (void)(({ int32_t __tmp = 0; if (vv < 0 && fl2 == 9 && typeck_name_equal(fn2, fl2, (&((s_void)[0])), 9)) {   (void)((vv = 15));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (vv >= 0) {   (void)(((e).field_access_is_enum_variant = 1));
  (void)(((e).enum_variant_tag = vv));
  int32_t i32r_tk = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (i32r_tk != 0) {   (void)(((e).resolved_type_ref = i32r_tk));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  (void)((skip_layout_for_type_kind = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t off = (-1);
  int32_t ftr = 0;
  (void)(({ int32_t __tmp = 0; if ((!skip_layout_for_type_kind)) {   (void)((off = typeck_get_field_offset_from_layout_deps(module, ctx, (&((layout_nm_buf)[0])), layout_nm_len, (&(((e).field_access_field_name)[0])), (e).field_access_field_len)));
  (void)(({ int32_t __tmp = 0; if (off >= 0) {   (void)(((e).field_access_offset = off));
 } else (__tmp = 0) ; __tmp; }));
  (void)((ftr = typeck_get_field_type_ref_from_layout_deps(module, arena, ctx, (&((layout_nm_buf)[0])), layout_nm_len, (&(((e).field_access_field_name)[0])), (e).field_access_field_len)));
  (void)(({ int32_t __tmp = 0; if (ftr != 0) {   (void)(((e).resolved_type_ref = ftr));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (off >= 0 || ftr != 0) {   (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_tok_kind_ty[9] = { 84, 111, 107, 101, 110, 75, 105, 110, 100 };
  uint8_t nm_eof_variant[9] = { 84, 79, 75, 69, 78, 95, 69, 79, 70 };
  __tmp = ({ int32_t __tmp = 0; if (off < 0 && ftr == 0 && layout_nm_len == 9 && typeck_name_equal((&((layout_nm_buf)[0])), layout_nm_len, (&((nm_tok_kind_ty)[0])), 9) && (e).field_access_field_len == 9 && typeck_name_equal((&(((e).field_access_field_name)[0])), (e).field_access_field_len, (&((nm_eof_variant)[0])), 9)) {   (void)(((e).field_access_is_enum_variant = 1));
  (void)(((e).enum_variant_tag = 0));
  int32_t i32r = typeck_ensure_i32_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (i32r != 0) {   (void)(((e).resolved_type_ref = i32r));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_SLICE && (!ast_ref_is_null((bt).elem_type_ref))) {   int32_t nm_len = (e).field_access_field_len;
  uint8_t len_nm[6] = { 108, 101, 110, 103, 116, 104 };
  uint8_t dat_nm[4] = { 100, 97, 116, 97 };
  __tmp = ({ int32_t __tmp = 0; if (nm_len == 6 && typeck_name_equal((&(((e).field_access_field_name)[0])), nm_len, (&((len_nm)[0])), 6)) {   int32_t ut = typeck_ensure_usize_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (ut != 0) {   (void)(((e).resolved_type_ref = ut));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (nm_len == 4 && typeck_name_equal((&(((e).field_access_field_name)[0])), nm_len, (&((dat_nm)[0])), 4)) {   struct ast_Type et;
  et = pipeline_arena_type_get_copy(arena, (bt).elem_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((et).kind == ast_TypeKind_TYPE_U8) {   int32_t ptr_ref = ast_arena_type_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (ptr_ref != 0) {   struct ast_Type pt;
  pt = pipeline_arena_type_get_copy(arena, ptr_ref);
  (void)(((pt).kind = ast_TypeKind_TYPE_PTR));
  (void)(((pt).elem_type_ref = (bt).elem_type_ref));
  (void)(((pt).name_len = 0));
  (void)(((pt).array_size = 0));
  (void)(ast_arena_type_set(arena, ptr_ref, pt));
  (void)(((e).resolved_type_ref = ptr_ref));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (e).field_access_field_len == 4 && (!ast_ref_is_null((base).resolved_type_ref))) {   uint8_t nm_dat[4] = { 100, 97, 116, 97 };
  __tmp = ({ int32_t __tmp = 0; if (typeck_name_equal((&(((e).field_access_field_name)[0])), (e).field_access_field_len, (&((nm_dat)[0])), 4)) {   uint8_t cob_nm[64] = { 0 };
  int32_t cob_len = 0;
  int32_t named_ref = 0;
  struct ast_Type bt_cob;
  bt_cob = pipeline_arena_type_get_copy(arena, (base).resolved_type_ref);
  (void)(({ int32_t __tmp = 0; if ((bt_cob).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt_cob).elem_type_ref))) {   __tmp = ({ int32_t __tmp = 0; if (pipeline_type_kind_ord_at(arena, (bt_cob).elem_type_ref) == 8) {   (void)((named_ref = (bt_cob).elem_type_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((bt_cob).kind == ast_TypeKind_TYPE_NAMED) {   (void)((named_ref = (base).resolved_type_ref));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (named_ref != 0) {   (void)((cob_len = pipeline_type_named_name_into(arena, named_ref, (&((cob_nm)[0])))));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_cob[13] = { 67, 111, 100, 101, 103, 101, 110, 79, 117, 116, 66, 117, 102 };
  __tmp = ({ int32_t __tmp = 0; if (cob_len == 13 && typeck_name_equal((&((cob_nm)[0])), cob_len, (&((nm_cob)[0])), 13)) {   int32_t u8r_cob = typeck_ensure_u8_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (u8r_cob != 0) {   int32_t arr_cob = typeck_find_or_alloc_array_type_ref(arena, u8r_cob, 8388608);
  __tmp = ({ int32_t __tmp = 0; if (arr_cob != 0) {   (void)(((e).resolved_type_ref = arr_cob));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (e).field_access_field_len > 0) {   int32_t u8_fb_end = typeck_inline_u8_64_array_field_type_ref(arena, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  __tmp = ({ int32_t __tmp = 0; if (u8_fb_end != 0) {   (void)(((e).resolved_type_ref = u8_fb_end));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (e).field_access_field_len > 0) {   int32_t arr_fb_end = typeck_expr_inline_array_field_type_ref(arena, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  __tmp = ({ int32_t __tmp = 0; if (arr_fb_end != 0) {   (void)(((e).resolved_type_ref = arr_fb_end));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (e).field_access_field_len > 0) {   int32_t fb_end = typeck_expr_field_access_fallback_scalar_type_ref(arena, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  __tmp = ({ int32_t __tmp = 0; if (fb_end != 0) {   (void)(((e).resolved_type_ref = fb_end));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (!ast_ref_is_null((base).resolved_type_ref))) {   int32_t lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, (base).resolved_type_ref, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  (void)(({ int32_t __tmp = 0; if (lx_fb != 0) {   (void)(((e).resolved_type_ref = lx_fb));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref)) {   struct ast_Type bt_fb;
  bt_fb = pipeline_arena_type_get_copy(arena, (base).resolved_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((bt_fb).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt_fb).elem_type_ref))) {   int32_t lx_fb2 = typeck_field_access_lexer_wrapper_fallback(arena, (bt_fb).elem_type_ref, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  __tmp = ({ int32_t __tmp = 0; if (lx_fb2 != 0) {   (void)(((e).resolved_type_ref = lx_fb2));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).resolved_type_ref) && (base).kind == ast_ExprKind_EXPR_VAR && (base).var_name_len > 0 && (ctx)->current_func_index >= 0 && (ctx)->current_func_index < (module)->num_funcs) {   int32_t pr_fb = pipeline_module_func_param_type_ref_for_name(module, (ctx)->current_func_index, (&(((base).var_name)[0])), (base).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(pr_fb))) {   int32_t lx_fb3 = typeck_field_access_lexer_wrapper_fallback(arena, pr_fb, (&(((e).field_access_field_name)[0])), (e).field_access_field_len);
  __tmp = ({ int32_t __tmp = 0; if (lx_fb3 != 0) {   (void)(((e).resolved_type_ref = lx_fb3));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_INDEX) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).index_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).index_index_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).index_base_ref) || (e).index_base_ref <= 0 || (e).index_base_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr eb;
  eb = pipeline_arena_expr_get_copy(arena, (e).index_base_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((eb).resolved_type_ref) || (eb).resolved_type_ref <= 0 || (eb).resolved_type_ref > (arena)->num_types) {   (void)(driver_diagnostic_typeck_subscript_base((e).line, (e).col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type bt;
  bt = pipeline_arena_type_get_copy(arena, (eb).resolved_type_ref);
  (void)(({ int32_t __tmp = 0; if ((bt).kind != ast_TypeKind_TYPE_ARRAY && (bt).kind != ast_TypeKind_TYPE_SLICE && (bt).kind != ast_TypeKind_TYPE_PTR) {   (void)(driver_diagnostic_typeck_subscript_base((e).line, (e).col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((bt).elem_type_ref)) {   (void)(driver_diagnostic_typeck_subscript_base((e).line, (e).col));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((e).resolved_type_ref = (bt).elem_type_ref));
  (void)(({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_SLICE) {   (void)(((e).index_base_is_slice = 1));
 } else {   (void)(((e).index_base_is_slice = 0));
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).index_index_ref)) && (e).index_index_ref > 0 && (e).index_index_ref <= (arena)->num_exprs) {   struct ast_Expr idxe;
  idxe = pipeline_arena_expr_get_copy(arena, (e).index_index_ref);
  __tmp = ({ int32_t __tmp = 0; if ((idxe).kind == ast_ExprKind_EXPR_LIT && (idxe).int_val == 0 && (bt).kind == ast_TypeKind_TYPE_ARRAY && (bt).array_size >= 1) {   (void)(((e).index_proven_in_bounds = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_CALL) {   int32_t j = 0;
  while (j < (e).call_num_args) {
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, pipeline_expr_call_arg_ref(arena, expr_ref, j), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref))) {   int32_t callee_eff = (e).call_callee_ref;
  (void)(({ int32_t __tmp = 0; if (pipeline_expr_kind_ord_at(arena, callee_eff) == ((int32_t)(51))) {   int32_t inner_c = pipeline_expr_unary_operand_ref_at(arena, callee_eff);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(inner_c))) {   (void)((callee_eff = inner_c));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_ty = typeck_resolve_call_callee_return_type(module, arena, callee_eff, expr_ref, ctx);
  (void)(({ int32_t __tmp = 0; if (ret_ty == 0 && pipeline_expr_kind_ord_at(arena, callee_eff) == 3) {   uint8_t cnm[64] = { 0 };
  int32_t cnml = pipeline_expr_var_name_len(arena, callee_eff);
  __tmp = ({ int32_t __tmp = 0; if (cnml > 0) {   (void)(pipeline_expr_var_name_into(arena, callee_eff, (&((cnm)[0]))));
  int32_t cfi = 0;
  (void)((ret_ty = typeck_find_func_return_type_in_module_by_name(module, arena, (&((cnm)[0])), cnml, 0 - 1, ctx, (&(cfi)))));
  __tmp = ({ int32_t __tmp = 0; if (ret_ty != 0) {   (void)(typeck_expr_apply_call_resolve(arena, expr_ref, 0 - 1, cfi));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ret_ty != 0) {   (void)(((e).resolved_type_ref = ret_ty));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_METHOD_CALL) {   (void)(ast_expr_init_call_resolve(arena, expr_ref));
  (void)((e = ast_arena_expr_get(arena, expr_ref)));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).method_call_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < (e).method_call_num_args) {
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ast_pipeline_expr_method_call_arg_ref(arena, expr_ref, j), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADD || (e).kind == ast_ExprKind_EXPR_SUB || (e).kind == ast_ExprKind_EXPR_MUL || (e).kind == ast_ExprKind_EXPR_DIV || (e).kind == ast_ExprKind_EXPR_MOD || (e).kind == ast_ExprKind_EXPR_SHL || (e).kind == ast_ExprKind_EXPR_SHR || (e).kind == ast_ExprKind_EXPR_BITAND || (e).kind == ast_ExprKind_EXPR_BITOR || (e).kind == ast_ExprKind_EXPR_BITXOR || (e).kind == ast_ExprKind_EXPR_EQ || (e).kind == ast_ExprKind_EXPR_NE || (e).kind == ast_ExprKind_EXPR_LT || (e).kind == ast_ExprKind_EXPR_LE || (e).kind == ast_ExprKind_EXPR_GT || (e).kind == ast_ExprKind_EXPR_GE || (e).kind == ast_ExprKind_EXPR_LOGAND || (e).kind == ast_ExprKind_EXPR_LOGOR) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).binop_left_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).binop_right_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_EQ || (e).kind == ast_ExprKind_EXPR_NE || (e).kind == ast_ExprKind_EXPR_LT || (e).kind == ast_ExprKind_EXPR_LE || (e).kind == ast_ExprKind_EXPR_GT || (e).kind == ast_ExprKind_EXPR_GE || (e).kind == ast_ExprKind_EXPR_LOGAND || (e).kind == ast_ExprKind_EXPR_LOGOR) {   int32_t bt = typeck_ensure_bool_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (bt != 0) {   (void)(((e).resolved_type_ref = bt));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t lt_ar = typeck_expr_type_ref(arena, (e).binop_left_ref);
  int32_t rt_ar = typeck_expr_type_ref(arena, (e).binop_right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_ar)) && lt_ar > 0 && lt_ar <= (arena)->num_types && (!ast_ref_is_null(rt_ar)) && rt_ar > 0 && rt_ar <= (arena)->num_types) {   struct ast_Type lar;
  lar = pipeline_arena_type_get_copy(arena, lt_ar);
  struct ast_Type rar;
  rar = pipeline_arena_type_get_copy(arena, rt_ar);
  int32_t out_ar = 0;
  (void)(({ int32_t __tmp = 0; if ((lar).kind == ast_TypeKind_TYPE_I64 || (rar).kind == ast_TypeKind_TYPE_I64) {   (void)((out_ar = typeck_ensure_i64_type_ref(arena)));
 } else (__tmp = ({ int32_t __tmp = 0; if ((lar).kind == ast_TypeKind_TYPE_F64 || (rar).kind == ast_TypeKind_TYPE_F64) {   (void)((out_ar = typeck_ensure_f64_type_ref(arena)));
 } else (__tmp = ({ int32_t __tmp = 0; if (typeck_type_refs_equal(arena, lt_ar, rt_ar)) {   (void)((out_ar = lt_ar));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_ar))) {   (void)((out_ar = lt_ar));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(rt_ar))) {   (void)((out_ar = rt_ar));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (out_ar == 0 && (e).kind == ast_ExprKind_EXPR_BITAND || (e).kind == ast_ExprKind_EXPR_BITOR || (e).kind == ast_ExprKind_EXPR_BITXOR || (e).kind == ast_ExprKind_EXPR_ADD || (e).kind == ast_ExprKind_EXPR_SUB || (e).kind == ast_ExprKind_EXPR_MUL || (e).kind == ast_ExprKind_EXPR_DIV || (e).kind == ast_ExprKind_EXPR_MOD || (e).kind == ast_ExprKind_EXPR_SHL || (e).kind == ast_ExprKind_EXPR_SHR) {   (void)((out_ar = typeck_ensure_i32_type_ref(arena)));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (out_ar != 0) {   (void)(((e).resolved_type_ref = out_ar));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_NEG || (e).kind == ast_ExprKind_EXPR_BITNOT || (e).kind == ast_ExprKind_EXPR_LOGNOT) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LOGNOT) {   int32_t bt = typeck_ensure_bool_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(((e).resolved_type_ref = bt));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_tr = typeck_expr_type_ref(arena, (e).unary_operand_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_tr)) && op_tr > 0 && op_tr <= (arena)->num_types) {   (void)(((e).resolved_type_ref = op_tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ADDR_OF) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).unary_operand_ref)) && typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_addr = typeck_expr_type_ref(arena, (e).unary_operand_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_addr) || op_addr <= 0 || op_addr > (arena)->num_types) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t pt_addr = typeck_find_or_alloc_ptr_type_ref(arena, op_addr);
  (void)(({ int32_t __tmp = 0; if (pt_addr == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((e).resolved_type_ref = pt_addr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_DEREF) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).unary_operand_ref)) && typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_ptr = typeck_expr_type_ref(arena, (e).unary_operand_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(op_ptr) || op_ptr <= 0 || op_ptr > (arena)->num_types) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type top;
  top = pipeline_arena_type_get_copy(arena, op_ptr);
  (void)(({ int32_t __tmp = 0; if ((top).kind != ast_TypeKind_TYPE_PTR || ast_ref_is_null((top).elem_type_ref)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((e).resolved_type_ref = (top).elem_type_ref));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR && (ctx)->current_block_ref != 0 && (ctx)->current_block_ref <= (arena)->num_blocks) {   int32_t vd_tr = ast_block_resolve_var_to_type_ref(arena, (ctx)->current_block_ref, (e).var_name, (e).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(vd_tr))) {   (void)(((e).resolved_type_ref = vd_tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR && (module)->num_top_level_lets > 0) {   int32_t tl = 0;
  while (tl < (module)->num_top_level_lets) {
    (void)(({ int32_t __tmp = 0; if (typeck_top_level_let_name_equal(module, tl, (&(((e).var_name)[0])), (e).var_name_len)) {   int32_t tl_tr = ast_pipeline_module_top_level_let_type_ref(module, tl);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(tl_tr))) {   (void)(((e).resolved_type_ref = tl_tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((tl = tl + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR && (ctx)->current_func_index >= 0 && (ctx)->current_func_index < (module)->num_funcs) {   int32_t fi = (ctx)->current_func_index;
  int32_t pr = pipeline_module_func_param_type_ref_for_name(module, fi, (&(((e).var_name)[0])), (e).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(pr))) {   (void)(((e).resolved_type_ref = pr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR) {   uint8_t nm_tok_kind_sym[9] = { 84, 111, 107, 101, 110, 75, 105, 110, 100 };
  (void)(({ int32_t __tmp = 0; if ((e).var_name_len == 9 && typeck_name_equal((e).var_name, (e).var_name_len, nm_tok_kind_sym, 9)) {   int32_t tk_tr = typeck_find_or_alloc_named_type_ref(arena, nm_tok_kind_sym, 9);
  __tmp = ({ int32_t __tmp = 0; if (tk_tr != 0) {   (void)(((e).resolved_type_ref = tk_tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_typ_kind_sym[8] = { 84, 121, 112, 101, 75, 105, 110, 100 };
  __tmp = ({ int32_t __tmp = 0; if ((e).var_name_len == 8 && typeck_name_equal((e).var_name, (e).var_name_len, (&((nm_typ_kind_sym)[0])), 8)) {   int32_t tg_tr = typeck_find_or_alloc_named_type_ref(arena, (&((nm_typ_kind_sym)[0])), 8);
  __tmp = ({ int32_t __tmp = 0; if (tg_tr != 0) {   (void)(((e).resolved_type_ref = tg_tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR) {   struct ast_Expr ev;
  ev = pipeline_arena_expr_get_copy(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((ev).resolved_type_ref)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_AS) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).as_operand_ref)) && typeck_check_expr(module, arena, (e).as_operand_ref, 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).as_target_type_ref))) {   (void)(((e).resolved_type_ref = (e).as_target_type_ref));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_STRUCT_LIT) {   int32_t fi = 0;
  while (fi < pipeline_expr_struct_lit_num_fields(arena, expr_ref)) {
    int32_t init_sl = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_sl)) && typeck_check_expr(module, arena, init_sl, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((fi = fi + 1));
  }
  (void)(({ int32_t __tmp = 0; if (typeck_ensure_struct_layout_from_struct_lit(module, arena, expr_ref) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t tr = typeck_find_or_alloc_named_type_ref(arena, (e).struct_lit_struct_name, (e).struct_lit_struct_name_len);
  (void)(({ int32_t __tmp = 0; if (tr != 0) {   (void)(((e).resolved_type_ref = tr));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
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
int32_t typeck_check_block_as_loop_body(struct ast_Module * module, struct ast_ASTArena * arena, int32_t body_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t saved_ld = (ctx)->typeck_loop_depth;
  (void)(((ctx)->typeck_loop_depth = (ctx)->typeck_loop_depth + 1));
  int32_t rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
  (void)(((ctx)->typeck_loop_depth = saved_ld));
  return rc;
}
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t saved_block_ref = (ctx)->current_block_ref;
  (void)(((ctx)->current_block_ref = block_ref));
  int32_t nc = ast_block_num_consts(arena, block_ref);
  int32_t nl = ast_block_num_lets(arena, block_ref);
  int32_t nlp = ast_block_num_loops(arena, block_ref);
  int32_t nfp = ast_block_num_for_loops(arena, block_ref);
  int32_t nif = ast_block_num_if_stmts(arena, block_ref);
  int32_t nes = ast_block_num_expr_stmts(arena, block_ref);
  int32_t nso = ast_block_num_stmt_order(arena, block_ref);
  int32_t fin0 = ast_block_final_expr_ref(arena, block_ref);
  (void)(driver_diagnostic_typeck_block_enter((ctx)->current_func_index, block_ref, nc, nl, nlp, nfp, nes, fin0));
  (void)(({ int32_t __tmp = 0; if (nso > 0) {   int32_t si = 0;
  while (si < nso) {
    (void)(({ int32_t __tmp = 0; if (si >= 96) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_block_ref = block_ref));
    uint8_t sk = ast_block_stmt_order_kind(arena, block_ref, si);
    int32_t idx = ast_block_stmt_order_idx(arena, block_ref, si);
    (void)(({ int32_t __tmp = 0; if (sk == 0) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nc && idx < 128) {   int32_t cd0_ir = ast_block_const_init_ref(arena, block_ref, idx);
  int32_t cd0_tr = ast_block_const_type_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, cd0_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(cd0_ir)) && (!ast_ref_is_null(cd0_tr))) {   int32_t init_ty0 = typeck_expr_type_ref(arena, cd0_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty0)) && (!typeck_type_refs_equal(arena, cd0_tr, init_ty0))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 1) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nl && idx < 128) {   int32_t ld0_ir = ast_block_let_init_ref(arena, block_ref, idx);
  int32_t ld0_tr = ast_block_let_type_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ld0_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ld0_ir)) && (!ast_ref_is_null(ld0_tr))) {   (void)(typeck_coerce_init_expr_to_decl(arena, ld0_ir, ld0_tr));
  int32_t init_ty_l = typeck_expr_type_ref(arena, ld0_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty_l)) && (!typeck_type_refs_equal(arena, ld0_tr, init_ty_l))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 2) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nes) {   int32_t expr_s = ast_block_expr_stmt_ref(arena, block_ref, idx);
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, expr_s, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 3) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nlp) {   int32_t wc = ast_block_while_cond_ref(arena, block_ref, idx);
  int32_t wb = ast_block_while_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(wc))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, wc, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, wc)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_as_loop_body(module, arena, wb, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 4) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nfp) {   int32_t fi_ir = ast_block_for_init_ref(arena, block_ref, idx);
  int32_t fc_cr = ast_block_for_cond_ref(arena, block_ref, idx);
  int32_t fs_sr = ast_block_for_step_ref(arena, block_ref, idx);
  int32_t fb_br = ast_block_for_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fi_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fc_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fc_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, fc_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fs_sr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block_as_loop_body(module, arena, fb_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 5) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nif) {   int32_t ic_cr = ast_block_if_cond_ref(arena, block_ref, idx);
  int32_t ib_tr = ast_block_if_then_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ic_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ic_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, ic_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ib_tr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t ib_er = ast_block_if_else_body_ref(arena, block_ref, idx);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ib_er))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ib_er, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)((si = si + 1));
  }
 } else {   int32_t i = 0;
  while (i < nc) {
    int32_t cd_ir = ast_block_const_init_ref(arena, block_ref, i);
    int32_t cd_tr = ast_block_const_type_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, cd_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(cd_ir)) && (!ast_ref_is_null(cd_tr))) {   int32_t init_ty = typeck_expr_type_ref(arena, cd_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && (!typeck_type_refs_equal(arena, cd_tr, init_ty))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nl) {
    int32_t ld_ir = ast_block_let_init_ref(arena, block_ref, i);
    int32_t ld_tr = ast_block_let_type_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ld_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ld_ir)) && (!ast_ref_is_null(ld_tr))) {   (void)(typeck_coerce_init_expr_to_decl(arena, ld_ir, ld_tr));
  int32_t init_ty = typeck_expr_type_ref(arena, ld_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && (!typeck_type_refs_equal(arena, ld_tr, init_ty))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nlp) {
    int32_t w_cr = ast_block_while_cond_ref(arena, block_ref, i);
    int32_t w_br = ast_block_while_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(w_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, w_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, w_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_block_as_loop_body(module, arena, w_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nfp) {
    int32_t fl_ir = ast_block_for_init_ref(arena, block_ref, i);
    int32_t fl_cr = ast_block_for_cond_ref(arena, block_ref, i);
    int32_t fl_sr = ast_block_for_step_ref(arena, block_ref, i);
    int32_t fl_br = ast_block_for_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fl_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fl_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fl_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, fl_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fl_sr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_block_as_loop_body(module, arena, fl_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nif) {
    int32_t ik_cr = ast_block_if_cond_ref(arena, block_ref, i);
    int32_t ik_tr = ast_block_if_then_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ik_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ik_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, ik_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ik_tr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t ik_er = ast_block_if_else_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ik_er))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ik_er, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nes) {
    (void)(({ int32_t __tmp = 0; if (i >= 32) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t es_ref = ast_block_expr_stmt_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin0))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fin0, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int skip_tail_ty_cmp = 0;
  (void)(({ int __tmp = 0; if (pipeline_expr_kind_ord_at(arena, fin0) == ((int32_t)(41))) {   __tmp = ({ int __tmp = 0; if (ast_ref_is_null(pipeline_expr_unary_operand_ref_at(arena, fin0))) {   (void)((skip_tail_ty_cmp = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && (!skip_tail_ty_cmp)) {   int32_t got = typeck_expr_type_ref(arena, fin0);
  __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(got) || (!typeck_type_refs_equal(arena, got, return_type_ref))) {   uint8_t * eb_fin = driver_typeck_diag_scratch_expect();
  uint8_t * gb_fin = driver_typeck_diag_scratch_found();
  int32_t el_fin = typeck_diag_fmt_type_or_question(arena, return_type_ref, eb_fin);
  int32_t gl_fin = typeck_diag_fmt_type_or_question(arena, got, gb_fin);
  (void)(driver_diagnostic_typeck_return_mismatch(0, 0, eb_fin, el_fin, gb_fin, gl_fin));
  (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(((ctx)->current_block_ref = saved_block_ref));
  return 0;
}
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(block_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (block_ref <= 0 || block_ref > (arena)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_check_block_impl(module, arena, block_ref, return_type_ref, ctx);
}
void typeck_patch_all_body_parent_links(struct ast_Module * module, struct ast_ASTArena * arena) {
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_ref_at(module, i)))) {   (void)(ast_arena_patch_block_parent_links(arena, pipeline_module_func_body_ref_at(module, i), 0));
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
}
int32_t typeck_su_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t mi = (module)->main_func_index;
  (void)(({ int32_t __tmp = 0; if (pipeline_module_func_is_extern_at(module, mi) == 1 && ast_ref_is_null(pipeline_module_func_body_ref_at(module, mi))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(pipeline_module_func_body_ref_at(module, mi)) && ast_ref_is_null(ast_pipeline_module_func_body_expr_ref_at(module, mi))) {   return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ast_pipeline_module_func_return_type_at(module, mi))) {   return (-3);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ret_ty;
  ret_ty = pipeline_arena_type_get_copy(arena, ast_pipeline_module_func_return_type_at(module, mi));
  (void)(({ int32_t __tmp = 0; if ((ret_ty).kind != ast_TypeKind_TYPE_I32 && (ret_ty).kind != ast_TypeKind_TYPE_I64) {   return (-4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(typeck_patch_all_body_parent_links(module, arena));
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(((ctx)->current_func_index = i));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_ref_at(module, i))) && pipeline_module_func_is_extern_at(module, i) == 0) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, pipeline_module_func_body_ref_at(module, i), ast_pipeline_module_func_return_type_at(module, i), ctx) != 0) {   uint8_t fn_name_buf[64] = { 0 };
  (void)(pipeline_module_func_name_copy64(module, i, (&((fn_name_buf)[0]))));
  (void)(driver_diagnostic_typeck_func_fail(i, (&((fn_name_buf)[0])), pipeline_module_func_name_len_at(module, i), 0 - 5));
  (void)(((ctx)->current_func_index = (-1)));
  return (-5);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ast_pipeline_module_func_return_type_at(module, i)))) {   struct ast_Type rt;
  rt = pipeline_arena_type_get_copy(arena, ast_pipeline_module_func_return_type_at(module, i));
  __tmp = ({ int32_t __tmp = 0; if ((rt).kind != ast_TypeKind_TYPE_VOID && typeck_func_body_has_implicit_return_tail(arena, pipeline_module_func_body_ref_at(module, i))) {   uint8_t fn_name_buf2[64] = { 0 };
  (void)(pipeline_module_func_name_copy64(module, i, (&((fn_name_buf2)[0]))));
  (void)(driver_diagnostic_typeck_func_fail(i, (&((fn_name_buf2)[0])), pipeline_module_func_name_len_at(module, i), 0 - 6));
  (void)(((ctx)->current_func_index = (-1)));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_func_index = (-1)));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_su_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(typeck_patch_all_body_parent_links(module, arena));
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(((ctx)->current_func_index = i));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(pipeline_module_func_body_ref_at(module, i))) && pipeline_module_func_is_extern_at(module, i) == 0) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, pipeline_module_func_body_ref_at(module, i), ast_pipeline_module_func_return_type_at(module, i), ctx) != 0) {   uint8_t fn_name_lib[64] = { 0 };
  (void)(pipeline_module_func_name_copy64(module, i, (&((fn_name_lib)[0]))));
  (void)(driver_diagnostic_typeck_func_fail(i, (&((fn_name_lib)[0])), pipeline_module_func_name_len_at(module, i), 0 - 5));
  (void)(((ctx)->current_func_index = (-1)));
  return (-5);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ast_pipeline_module_func_return_type_at(module, i)))) {   struct ast_Type rt2;
  rt2 = pipeline_arena_type_get_copy(arena, ast_pipeline_module_func_return_type_at(module, i));
  __tmp = ({ int32_t __tmp = 0; if ((rt2).kind != ast_TypeKind_TYPE_VOID && typeck_func_body_has_implicit_return_tail(arena, pipeline_module_func_body_ref_at(module, i))) {   uint8_t fn_name_lib2[64] = { 0 };
  (void)(pipeline_module_func_name_copy64(module, i, (&((fn_name_lib2)[0]))));
  (void)(driver_diagnostic_typeck_func_fail(i, (&((fn_name_lib2)[0])), pipeline_module_func_name_len_at(module, i), 0 - 6));
  (void)(((ctx)->current_func_index = (-1)));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_func_index = (-1)));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   return (-10);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index >= (module)->num_funcs) {   return (-11);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_su_ast_impl(module, arena, ctx);
}
