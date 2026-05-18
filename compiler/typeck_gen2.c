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
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_result_refs[16]; int32_t match_num_arms; int32_t match_arm_is_wildcard[16]; int32_t match_arm_lit_val[16]; int32_t match_arm_is_enum_variant[16]; int32_t match_arm_variant_index[16]; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_refs[16]; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_refs[16]; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_num_fields; uint8_t struct_lit_field_names[8][64]; int32_t struct_lit_field_lens[8]; int32_t struct_lit_init_refs[8]; int32_t array_lit_num_elems; int32_t array_lit_elem_refs[16]; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { struct ast_ConstDecl const_decls[256]; int32_t num_consts; struct ast_LetDecl let_decls[256]; int32_t num_lets; int32_t num_early_lets; struct ast_WhileLoop loops[8]; int32_t num_loops; struct ast_ForLoop for_loops[8]; int32_t num_for_loops; struct ast_IfStmt if_stmts[16]; int32_t num_if_stmts; int32_t defer_block_refs[8]; int32_t num_defers; struct ast_LabeledStmt labeled_stmts[8]; int32_t num_labeled_stmts; int32_t expr_stmt_refs[32]; int32_t num_expr_stmts; int32_t final_expr_ref; struct ast_StmtOrderItem stmt_order[96]; int32_t num_stmt_order; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; struct ast_Param params[16]; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t num_fields; uint8_t field_names[64][64]; int32_t field_lens[64]; int32_t field_offsets[64]; int32_t field_type_refs[64]; };
struct ast_Module { struct ast_Func funcs[256]; int32_t func_refs[256]; int32_t num_funcs; int32_t main_func_index; uint8_t import_path_data[2048]; int32_t import_path_lens[32]; int32_t num_imports; int32_t import_kinds[32]; uint8_t import_binding_name[32][64]; int32_t import_binding_name_len[32]; int32_t import_select_count[32]; uint8_t import_select_names[32][8][64]; int32_t import_select_name_lens[32][8]; int32_t num_top_level_lets; uint8_t top_level_let_names[32][64]; int32_t top_level_let_name_lens[32]; int32_t top_level_let_type_refs[32]; int32_t top_level_let_init_refs[32]; int32_t top_level_let_is_const[32]; struct ast_StructLayout struct_layouts[32]; int32_t num_struct_layouts; };
struct ast_ASTArena { struct ast_Type types[512]; int32_t num_types; struct ast_Expr exprs[8192]; int32_t num_exprs; struct ast_Block blocks[512]; int32_t num_blocks; struct ast_Func funcs[256]; int32_t num_funcs; };
struct ast_PipelineDepCtx { struct ast_Module * dep_modules[32]; struct ast_ASTArena * dep_arenas[32]; int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t lib_root_bufs[16][256]; int32_t lib_root_lens[16]; uint8_t path_buf[512]; uint8_t loaded_buf[262144]; ptrdiff_t loaded_len; uint8_t preprocess_buf[262144]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t current_func_index; uint8_t dep_logical_path_mirror[32][64]; uint8_t * dep_paths[32]; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_func_empty_param_indices[16]; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; };
extern int ast_ref_is_null(int32_t ref);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t typeck_float64_bits_lo(double d);
extern int32_t typeck_float64_bits_hi(double d);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * out);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t type_ref);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern uint8_t * driver_typeck_diag_scratch_expect();
extern uint8_t * driver_typeck_diag_scratch_found();
extern struct ast_ASTArena * pipeline_get_dep_arena_slot(int32_t ix);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module * module, int32_t func_index, uint8_t * vname, int32_t vname_len);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t layout_idx, int32_t j, uint8_t * fname, int32_t fname_len, int32_t ftype_ref, int32_t foff);
int32_t typeck_type_kind_ordinal(enum ast_TypeKind k);
int typeck_name_equal(uint8_t * a, int32_t a_len, uint8_t * b, int32_t b_len);
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_type_ref_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_Expr e);
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index);
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena);
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
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen);
void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx);
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx);
int32_t typeck_typeck_import_path_segment_count(uint8_t * path, int32_t path_len);
int typeck_typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_expr_type_ref_impl(struct ast_ASTArena * arena, int32_t expr_ref);
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_ref_is_bool(struct ast_ASTArena * arena, int32_t type_ref);
int typeck_type_refs_equal_impl(struct ast_ASTArena * arena, int32_t a, int32_t b);
int typeck_type_refs_equal(struct ast_ASTArena * arena, int32_t a, int32_t b);
int32_t typeck_typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len);
int32_t typeck_typeck_diag_append_u32_dec(uint8_t * out, int32_t pos, int32_t cap, int32_t v);
int32_t typeck_typeck_diag_fmt_type_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cur, int32_t cap);
int32_t typeck_typeck_diag_fmt_type_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cap);
int32_t typeck_typeck_diag_fmt_type_or_question(struct ast_ASTArena * arena, int32_t ref, uint8_t * out);
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_expr(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref);
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_check_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx);
int32_t typeck_typeck_su_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_typeck_su_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t typeck_typeck_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
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
int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts && k < 32) {
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name)[0])), ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name_len, type_name, type_name_len)) {   int32_t j = 0;
  while (j < ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).num_fields && j < 64) {
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_names)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_names)[j]))[0])), (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_lens)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_lens)[j]), field_name, field_name_len)) {   return (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_offsets)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_offsets)[j]);
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
  while (k < (module)->num_struct_layouts && k < 32) {
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name)[0])), ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name_len, type_name, type_name_len)) {   int32_t j = 0;
  while (j < ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).num_fields && j < 64) {
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_names)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_names)[j]))[0])), (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_lens)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_lens)[j]), field_name, field_name_len)) {   return (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_type_refs)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).field_type_refs)[j]);
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
  int32_t di = 0;
  while (di < 32) {
    struct ast_Module * dm = (di < 0 || (di) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[di]);
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)((r = typeck_get_field_offset_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r >= 0) {   return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((di = di + 1));
  }
  return (-1);
}
int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_Expr e) {
  (void)(({ int32_t __tmp = 0; if ((e).struct_lit_num_fields <= 0 || (e).struct_lit_num_fields > 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t name_len = (e).struct_lit_struct_name_len;
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t k = 0;
  int32_t found_idx = (-1);
  while (k < (module)->num_struct_layouts && k < 32) {
    (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name)[0])), ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[k])).name_len, (&(((e).struct_lit_struct_name)[0])), name_len)) {   (void)((found_idx = k));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  (void)(({ int32_t __tmp = 0; if (found_idx >= 0) {   int32_t idx_m = found_idx;
  int32_t jm = 0;
  while (jm < (e).struct_lit_num_fields && jm < 8) {
    int32_t fnlen_m = (jm < 0 || (jm) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_lens)[0]) : ((e).struct_lit_field_lens)[jm]);
    int32_t exists_m = 0;
    int32_t tm = 0;
    while (tm < ((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).num_fields && tm < 64) {
      (void)(({ int32_t __tmp = 0; if (typeck_name_equal((&(((tm < 0 || (tm) >= 64 ? (shulang_panic_(1, 0), (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_names)[0]) : (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_names)[tm]))[0])), (tm < 0 || (tm) >= 64 ? (shulang_panic_(1, 0), (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_lens)[0]) : (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_lens)[tm]), (&(((jm < 0 || (jm) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_names)[0]) : ((e).struct_lit_field_names)[jm]))[0])), fnlen_m)) {   (void)((exists_m = 1));
 } else (__tmp = 0) ; __tmp; }));
      (void)((tm = tm + 1));
    }
    (void)(({ int32_t __tmp = 0; if (exists_m == 0 && ((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).num_fields < 64) {   int32_t nf_m = ((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).num_fields;
  int32_t fi_m = 0;
  while (fi_m < 64) {
    (void)(((fi_m < 0 || (fi_m) >= 64 ? (shulang_panic_(1, 0), 0) : (((nf_m < 0 || (nf_m) >= 64 ? (shulang_panic_(1, 0), (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_names)[0]) : (((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_names)[nf_m]))[fi_m] = (fi_m < 0 || (fi_m) >= 64 ? (shulang_panic_(1, 0), ((jm < 0 || (jm) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_names)[0]) : ((e).struct_lit_field_names)[jm]))[0]) : ((jm < 0 || (jm) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_names)[0]) : ((e).struct_lit_field_names)[jm]))[fi_m]), 0))));
    (void)((fi_m = fi_m + 1));
  }
  (void)(((nf_m < 0 || (nf_m) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_lens)[nf_m] = fnlen_m, 0))));
  (void)(((nf_m < 0 || (nf_m) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_offsets)[nf_m] = nf_m * 8, 0))));
  (void)(((nf_m < 0 || (nf_m) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_type_refs)[nf_m] = 0, 0))));
  int32_t init_rm = (jm < 0 || (jm) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_init_refs)[0]) : ((e).struct_lit_init_refs)[jm]);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_rm)) && init_rm > 0 && init_rm <= (arena)->num_exprs) {   int32_t fr_m = typeck_expr_type_ref(arena, init_rm);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr_m))) {   (void)(((nf_m < 0 || (nf_m) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx_m])).field_type_refs)[nf_m] = fr_m, 0))));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(((idx_m < 0 || (idx_m) >= 32 ? (shulang_panic_(1, 0), 0) : (((module)->struct_layouts)[idx_m].num_fields = nf_m + 1, 0))));
 } else (__tmp = 0) ; __tmp; }));
    (void)((jm = jm + 1));
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->num_struct_layouts >= 32) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t idx = (module)->num_struct_layouts;
  (void)(((module)->num_struct_layouts = (module)->num_struct_layouts + 1));
  int32_t i = 0;
  while (i < 64) {
    (void)(((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).name)[i] = (i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), ((e).struct_lit_struct_name)[0]) : ((e).struct_lit_struct_name)[i]), 0))));
    (void)((i = i + 1));
  }
  (void)(((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), 0) : (((module)->struct_layouts)[idx].name_len = name_len, 0))));
  (void)(((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), 0) : (((module)->struct_layouts)[idx].num_fields = (e).struct_lit_num_fields, 0))));
  int32_t off = 0;
  int32_t j = 0;
  while (j < (e).struct_lit_num_fields && j < 8) {
    int32_t fi = 0;
    while (fi < 64) {
      (void)(((fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), 0) : (((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_names)[0]) : (((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_names)[j]))[fi] = (fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), ((j < 0 || (j) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_names)[0]) : ((e).struct_lit_field_names)[j]))[0]) : ((j < 0 || (j) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_names)[0]) : ((e).struct_lit_field_names)[j]))[fi]), 0))));
      (void)((fi = fi + 1));
    }
    (void)(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_lens)[j] = (j < 0 || (j) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_field_lens)[0]) : ((e).struct_lit_field_lens)[j]), 0))));
    (void)(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_offsets)[j] = off, 0))));
    (void)(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_type_refs)[j] = 0, 0))));
    int32_t init_r = (j < 0 || (j) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_init_refs)[0]) : ((e).struct_lit_init_refs)[j]);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_r)) && init_r > 0 && init_r <= (arena)->num_exprs) {   int32_t fr = typeck_expr_type_ref(arena, init_r);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fr))) {   (void)(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), 0) : ((((idx < 0 || (idx) >= 32 ? (shulang_panic_(1, 0), ((module)->struct_layouts)[0]) : ((module)->struct_layouts)[idx])).field_type_refs)[j] = fr, 0))));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((off = off + 8));
    (void)((j = j + 1));
  }
  return 0;
}
int typeck_expr_var_name_equal_func(struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_Module * mod, int32_t func_index) {
  (void)(({ int __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr callee = ast_ast_arena_expr_get(arena, callee_expr_ref);
  (void)(({ int __tmp = 0; if ((callee).kind != ast_ExprKind_EXPR_VAR) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t b_len = (callee).var_name_len;
  (void)(({ int __tmp = 0; if (func_index < 0 || func_index >= (mod)->num_funcs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t a_len = ((func_index < 0 || (func_index) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[func_index])).name_len;
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0 || a_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < a_len) {
    (void)(({ int __tmp = 0; if ((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), (((func_index < 0 || (func_index) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[func_index])).name)[0]) : (((func_index < 0 || (func_index) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[func_index])).name)[i]) != (i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), ((callee).var_name)[0]) : ((callee).var_name)[i])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 1;
}
int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena * arena, uint8_t * name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t k = 1;
  while (k <= (arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_NAMED && typeck_name_equal((tk).name, (tk).name_len, name, name_len)) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((ti).name_len = name_len));
  int32_t i = 0;
  while (i < 64) {
    (void)(({ uint8_t __tmp = 0; if (i < name_len) {   (void)(((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), 0) : (((ti).name)[i] = (name)[i], 0))));
 } else {   (void)(((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), 0) : (((ti).name)[i] = 0, 0))));
 } ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena * arena) {
  int32_t k = 1;
  while (k <= (arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_I32) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_I32));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_ensure_bool_type_ref(struct ast_ASTArena * arena) {
  int32_t k = 1;
  while (k <= (arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_BOOL) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_BOOL));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_ensure_f64_type_ref(struct ast_ASTArena * arena) {
  int32_t k = 1;
  while (k <= (arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_F64) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_F64));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena * arena) {
  int32_t k = 1;
  while (k <= (arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_USIZE) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_USIZE));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_ensure_void_type_ref(struct ast_ASTArena * a) {
  int32_t k = 1;
  while (k <= (a)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(a, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_VOID && (tk).name_len == 0 && (tk).elem_type_ref == 0 && (tk).array_size == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t nr = ast_ast_arena_type_alloc(a);
  (void)(({ int32_t __tmp = 0; if (nr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(a, nr);
  (void)(((ti).kind = ast_TypeKind_TYPE_VOID));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(a, nr, ti));
  return nr;
}
int32_t typeck_get_dep_return_type_in_caller_arena(int32_t from_dep_index, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0 || from_dep_index >= 32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_ASTArena * dep_arena = (from_dep_index < 0 || (from_dep_index) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[from_dep_index]);
  (void)(({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   (void)((dep_arena = pipeline_get_dep_arena_slot(from_dep_index)));
  __tmp = ({ int32_t __tmp = 0; if (dep_arena == ((struct ast_ASTArena *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return typeck_dep_return_type_to_caller_arena(dep_arena, dep_return_type_ref, caller_arena);
}
int32_t typeck_ensure_i64_type_ref(struct ast_ASTArena * caller_arena) {
  int32_t k = 1;
  while (k <= (caller_arena)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(caller_arena, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_I64) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t new_ref = ast_ast_arena_type_alloc(caller_arena);
  (void)(({ int32_t __tmp = 0; if (new_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ti = ast_ast_arena_type_get(caller_arena, new_ref);
  (void)(((ti).kind = ast_TypeKind_TYPE_I64));
  (void)(((ti).name_len = 0));
  (void)(((ti).elem_type_ref = 0));
  (void)(((ti).array_size = 0));
  (void)(ast_ast_arena_type_set(caller_arena, new_ref, ti));
  return new_ref;
}
int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena * a, int32_t elem_ref, int32_t array_size) {
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t k = 1;
  while (k <= (a)->num_types) {
    struct ast_Type tk = ast_ast_arena_type_get(a, k);
    (void)(({ int32_t __tmp = 0; if ((tk).kind == ast_TypeKind_TYPE_ARRAY && (tk).elem_type_ref == elem_ref && (tk).array_size == array_size) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t arr_ref = ast_ast_arena_type_alloc(a);
  (void)(({ int32_t __tmp = 0; if (arr_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ta = ast_ast_arena_type_get(a, arr_ref);
  (void)(((ta).kind = ast_TypeKind_TYPE_ARRAY));
  (void)(((ta).elem_type_ref = elem_ref));
  (void)(((ta).array_size = array_size));
  (void)(((ta).name_len = 0));
  (void)(ast_ast_arena_type_set(a, arr_ref, ta));
  return arr_ref;
}
int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena * a, uint8_t * elem_nm, int32_t elem_nm_len, int32_t array_size) {
  int32_t elem_ref = typeck_find_or_alloc_named_type_ref(a, elem_nm, elem_nm_len);
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_find_or_alloc_array_type_ref(a, elem_ref, array_size);
}
int32_t typeck_ensure_kind_only_type_ref(struct ast_ASTArena * w, enum ast_TypeKind kind) {
  int32_t i = 1;
  while (i <= (w)->num_types) {
    struct ast_Type t = ast_ast_arena_type_get(w, i);
    (void)(({ int32_t __tmp = 0; if ((t).kind == kind && (t).name_len == 0 && (t).elem_type_ref == 0 && (t).array_size == 0) {   return i;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  int32_t pr = ast_ast_arena_type_alloc(w);
  (void)(({ int32_t __tmp = 0; if (pr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type tn = ast_ast_arena_type_get(w, pr);
  (void)(((tn).kind = kind));
  (void)(((tn).name_len = 0));
  (void)(((tn).elem_type_ref = 0));
  (void)(((tn).array_size = 0));
  (void)(ast_ast_arena_type_set(w, pr, tn));
  return pr;
}
int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  int32_t k = 1;
  while (k <= (w)->num_types) {
    struct ast_Type t = ast_ast_arena_type_get(w, k);
    (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_PTR && (t).elem_type_ref == elem_ref && (t).name_len == 0 && (t).array_size == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t rr = ast_ast_arena_type_alloc(w);
  (void)(({ int32_t __tmp = 0; if (rr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type pt = ast_ast_arena_type_get(w, rr);
  (void)(((pt).kind = ast_TypeKind_TYPE_PTR));
  (void)(((pt).elem_type_ref = elem_ref));
  (void)(((pt).name_len = 0));
  (void)(((pt).array_size = 0));
  (void)(ast_ast_arena_type_set(w, rr, pt));
  return rr;
}
int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena * w, int32_t elem_ref) {
  int32_t k = 1;
  while (k <= (w)->num_types) {
    struct ast_Type t = ast_ast_arena_type_get(w, k);
    (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_SLICE && (t).elem_type_ref == elem_ref && (t).name_len == 0 && (t).array_size == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t sr = ast_ast_arena_type_alloc(w);
  (void)(({ int32_t __tmp = 0; if (sr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type st = ast_ast_arena_type_get(w, sr);
  (void)(((st).kind = ast_TypeKind_TYPE_SLICE));
  (void)(((st).elem_type_ref = elem_ref));
  (void)(((st).name_len = 0));
  (void)(((st).array_size = 0));
  (void)(ast_ast_arena_type_set(w, sr, st));
  return sr;
}
int32_t typeck_find_or_alloc_vector_type_ref(struct ast_ASTArena * w, int32_t elem_ref, int32_t array_size) {
  int32_t k = 1;
  while (k <= (w)->num_types) {
    struct ast_Type t = ast_ast_arena_type_get(w, k);
    (void)(({ int32_t __tmp = 0; if ((t).kind == ast_TypeKind_TYPE_VECTOR && (t).elem_type_ref == elem_ref && (t).array_size == array_size && (t).name_len == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  int32_t vr = ast_ast_arena_type_alloc(w);
  (void)(({ int32_t __tmp = 0; if (vr == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type vt = ast_ast_arena_type_get(w, vr);
  (void)(((vt).kind = ast_TypeKind_TYPE_VECTOR));
  (void)(((vt).elem_type_ref = elem_ref));
  (void)(((vt).array_size = array_size));
  (void)(((vt).name_len = 0));
  (void)(ast_ast_arena_type_set(w, vr, vt));
  return vr;
}
int32_t typeck_dep_return_type_to_caller_arena(struct ast_ASTArena * dep_arena, int32_t dep_return_type_ref, struct ast_ASTArena * caller_arena) {
  (void)(({ int32_t __tmp = 0; if (dep_return_type_ref <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type tt = ast_ast_arena_type_get(dep_arena, dep_return_type_ref);
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
  return 0;
}
int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  int32_t r = typeck_get_field_type_ref_from_layout(module, type_name, type_name_len, field_name, field_name_len);
  (void)(({ int32_t __tmp = 0; if (r != 0) {   return r;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t di = 0;
  while (di < 32) {
    struct ast_Module * dm = (di < 0 || (di) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[di]);
    (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)((r = typeck_get_field_type_ref_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
  __tmp = ({ int32_t __tmp = 0; if (r != 0) {   struct ast_ASTArena * da = (di < 0 || (di) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[di]);
  (void)(({ int32_t __tmp = 0; if (da != ((struct ast_ASTArena *)(0))) {   return typeck_dep_return_type_to_caller_arena(da, r, arena);
 } else (__tmp = 0) ; __tmp; }));
  return r;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((di = di + 1));
  }
  (void)(({ int32_t __tmp = 0; if (type_name_len == 4 && (type_name)[0] == 69 && (type_name)[1] == 120 && (type_name)[2] == 112 && (type_name)[3] == 114) {   int32_t fb = typeck_expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
  __tmp = ({ int32_t __tmp = 0; if (fb != 0) {   return fb;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module * mod, uint8_t * nm, int32_t nlen) {
  int32_t k = 0;
  while (k < (mod)->num_struct_layouts && k < 32) {
    (void)(({ int32_t __tmp = 0; if (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[k])).name_len == nlen && nlen > 0) {   __tmp = ({ int32_t __tmp = 0; if (typeck_name_equal((&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[k])).name)[0])), ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[k])).name_len, nm, nlen)) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return (-1);
}
void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t di = 0;
  while (di < 32) {
    struct ast_Module * dm = (di < 0 || (di) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[di]);
    struct ast_ASTArena * darena = (di < 0 || (di) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[di]);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0)) || darena == ((struct ast_ASTArena *)(0))) {   (void)((di = di + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t k = 0;
    while (k < (dm)->num_struct_layouts && k < 32) {
      int32_t nl = ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name_len;
      (void)(({ int32_t __tmp = 0; if (nl > 0 && nl <= 63) {   int32_t nf_dep = ((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).num_fields;
  (void)(({ int32_t __tmp = 0; if (nf_dep > 64) {   (void)((nf_dep = 64));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ex = typeck_entry_module_find_struct_layout_index(mod, (&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0])), nl);
  int32_t need = 0;
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   __tmp = ({ int32_t __tmp = 0; if ((mod)->num_struct_layouts < 32) {   (void)((need = 1));
 } else (__tmp = 0) ; __tmp; });
 } else {   int weak_entry = 0;
  (void)(({ int __tmp = 0; if (((ex < 0 || (ex) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[ex])).num_fields >= 2 && (1 < 0 || (1) >= 64 ? (shulang_panic_(1, 0), (((ex < 0 || (ex) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[ex])).field_type_refs)[0]) : (((ex < 0 || (ex) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[ex])).field_type_refs)[1]) == 0) {   (void)((weak_entry = 1));
 } else (__tmp = 0) ; __tmp; }));
  int is_expr_nm = 0;
  (void)(({ int __tmp = 0; if (nl == 4) {   __tmp = ({ int __tmp = 0; if ((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0] == 69 && (1 < 0 || (1) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[1]) == 120 && (2 < 0 || (2) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[2]) == 112 && (3 < 0 || (3) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[3]) == 114) {   (void)((is_expr_nm = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (nf_dep > ((ex < 0 || (ex) >= 32 ? (shulang_panic_(1, 0), ((mod)->struct_layouts)[0]) : ((mod)->struct_layouts)[ex])).num_fields || weak_entry || is_expr_nm) {   (void)((need = 1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (need != 0) {   int32_t ni = ex;
  (void)(({ int32_t __tmp = 0; if (ex < 0) {   (void)((ni = (mod)->num_struct_layouts));
  (void)(((mod)->num_struct_layouts = (mod)->num_struct_layouts + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_struct_layout_reset_slot(mod, ni));
  (void)(pipeline_module_struct_layout_set_name(mod, ni, (&((((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).name)[0])), nl));
  int32_t j = 0;
  while (j < nf_dep && j < 64) {
    int32_t raw_fr = (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_type_refs)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_type_refs)[j]);
    int32_t mapped = 0;
    (void)(({ int32_t __tmp = 0; if (raw_fr != 0) {   (void)((mapped = typeck_dep_return_type_to_caller_arena(darena, raw_fr, arena)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_module_struct_layout_set_field(mod, ni, j, (&(((j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_names)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_names)[j]))[0])), (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_lens)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_lens)[j]), mapped, (j < 0 || (j) >= 64 ? (shulang_panic_(1, 0), (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_offsets)[0]) : (((k < 0 || (k) >= 32 ? (shulang_panic_(1, 0), ((dm)->struct_layouts)[0]) : ((dm)->struct_layouts)[k])).field_offsets)[j])));
    (void)((j = j + 1));
  }
  (void)(((ni < 0 || (ni) >= 32 ? (shulang_panic_(1, 0), 0) : (((mod)->struct_layouts)[ni].num_fields = nf_dep, 0))));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
      (void)((k = k + 1));
    }
    (void)((di = di + 1));
  }
}
int32_t typeck_find_func_return_type_in_module(struct ast_Module * mod, struct ast_ASTArena * mod_arena, struct ast_ASTArena * caller_arena, struct ast_ASTArena * callee_arena, int32_t callee_expr_ref, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx) {
  int32_t j = 0;
  while (j < (mod)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (j >= 256) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j)) {   int32_t ret_dep = ((j < 0 || (j) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[j])).return_type_ref;
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return ret_dep;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, ret_dep, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  return 0;
}
int32_t typeck_find_func_return_type_in_module_by_name(struct ast_Module * mod, struct ast_ASTArena * caller_arena, uint8_t * name, int32_t name_len, int32_t from_dep_index, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < (mod)->num_funcs && j < 256) {
    (void)(({ int32_t __tmp = 0; if (((j < 0 || (j) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[j])).name_len == name_len && typeck_name_equal((&((((j < 0 || (j) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[j])).name)[0])), ((j < 0 || (j) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[j])).name_len, name, name_len)) {   int32_t rtr = ((j < 0 || (j) >= 256 ? (shulang_panic_(1, 0), ((mod)->funcs)[0]) : ((mod)->funcs)[j])).return_type_ref;
  (void)(({ int32_t __tmp = 0; if (from_dep_index < 0) {   return rtr;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_get_dep_return_type_in_caller_arena(from_dep_index, rtr, caller_arena, ctx);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  return 0;
}
int32_t typeck_typeck_import_path_segment_count(uint8_t * path, int32_t path_len) {
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
int typeck_typeck_import_segment_at(struct ast_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {
  (void)(({ int __tmp = 0; if (module == ((struct ast_Module *)(0)) || imp_ix < 0 || imp_ix >= 32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t pb = imp_ix * 64;
  int32_t pl = (imp_ix < 0 || (imp_ix) >= 32 ? (shulang_panic_(1, 0), ((module)->import_path_lens)[0]) : ((module)->import_path_lens)[imp_ix]);
  (void)(({ int __tmp = 0; if (pl <= 0 || pl > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ci = 0;
  int32_t ss = 0;
  int32_t k = 0;
  while (k <= pl) {
    int at_end_p = k == pl;
    int dot_p = 0;
    (void)(({ int __tmp = 0; if ((!at_end_p) && k < pl) {   (void)((dot_p = (pb + k < 0 || (pb + k) >= 2048 ? (shulang_panic_(1, 0), ((module)->import_path_data)[0]) : ((module)->import_path_data)[pb + k]) == 46));
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
int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (ctx == ((struct ast_PipelineDepCtx *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs || module == ((struct ast_Module *)(0))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr callee0 = ast_ast_arena_expr_get(arena, callee_expr_ref);
  (void)(({ int32_t __tmp = 0; if ((callee0).kind != ast_ExprKind_EXPR_FIELD_ACCESS) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t layer_bytes[16][64] = { 0 };
  int32_t layer_lens[16] = { 0 };
  int32_t nstack = 0;
  int32_t cur_ref = callee_expr_ref;
  while (1) {
    (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr exx = ast_ast_arena_expr_get(arena, cur_ref);
    (void)(({ int32_t __tmp = 0; if ((exx).kind != ast_ExprKind_EXPR_FIELD_ACCESS || (exx).field_access_field_len <= 0 || (exx).field_access_field_len > 63) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (nstack >= 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    int32_t lix = 0;
    while (lix < (exx).field_access_field_len && lix < 64) {
      (void)(((lix < 0 || (lix) >= 64 ? (shulang_panic_(1, 0), 0) : (((nstack < 0 || (nstack) >= 16 ? (shulang_panic_(1, 0), (layer_bytes)[0]) : (layer_bytes)[nstack]))[lix] = (lix < 0 || (lix) >= 64 ? (shulang_panic_(1, 0), ((exx).field_access_field_name)[0]) : ((exx).field_access_field_name)[lix]), 0))));
      (void)((lix = lix + 1));
    }
    (void)(((nstack < 0 || (nstack) >= 16 ? (shulang_panic_(1, 0), 0) : ((layer_lens)[nstack] = (exx).field_access_field_len, 0))));
    (void)((nstack = nstack + 1));
    (void)((cur_ref = (exx).field_access_base_ref));
  }
  (void)(({ int32_t __tmp = 0; if (cur_ref <= 0 || cur_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base_var_ex = ast_ast_arena_expr_get(arena, cur_ref);
  (void)(({ int32_t __tmp = 0; if ((base_var_ex).kind != ast_ExprKind_EXPR_VAR || (base_var_ex).var_name_len <= 0 || (base_var_ex).var_name_len > 63) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t dep_j = 0;
  while (dep_j < (module)->num_imports && dep_j < 32) {
    int32_t pb = dep_j * 64;
    int32_t plen = (dep_j < 0 || (dep_j) >= 32 ? (shulang_panic_(1, 0), ((module)->import_path_lens)[0]) : ((module)->import_path_lens)[dep_j]);
    (void)(({ int32_t __tmp = 0; if (plen <= 0 || plen > 63) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t Pseg = typeck_typeck_import_path_segment_count((pb < 0 || (pb) >= 2048 ? (shulang_panic_(1, 0), &((module)->import_path_data)[0]) : &((module)->import_path_data)[pb]), plen);
    (void)(({ int32_t __tmp = 0; if (Pseg <= 0 || nstack != Pseg) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t s0_rel = 0;
    int32_t s0_ln = 0;
    (void)(({ int32_t __tmp = 0; if ((!typeck_typeck_import_segment_at(module, dep_j, 0, (&(s0_rel)), (&(s0_ln))))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!typeck_name_equal((pb + s0_rel < 0 || (pb + s0_rel) >= 2048 ? (shulang_panic_(1, 0), &((module)->import_path_data)[0]) : &((module)->import_path_data)[pb + s0_rel]), s0_ln, (base_var_ex).var_name, (base_var_ex).var_name_len))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int bad_mid = 0;
    int32_t sm = 1;
    while (sm <= Pseg - 1) {
      int32_t srv = 0;
      int32_t slv = 0;
      (void)(({ int __tmp = 0; if ((!typeck_typeck_import_segment_at(module, dep_j, sm, (&(srv)), (&(slv))))) {   (void)((bad_mid = 1));
 } else {   int32_t lay_ix = Pseg - sm;
  __tmp = ({ int __tmp = 0; if ((!typeck_name_equal((pb + srv < 0 || (pb + srv) >= 2048 ? (shulang_panic_(1, 0), &((module)->import_path_data)[0]) : &((module)->import_path_data)[pb + srv]), slv, (&(((lay_ix < 0 || (lay_ix) >= 16 ? (shulang_panic_(1, 0), (layer_bytes)[0]) : (layer_bytes)[lay_ix]))[0])), (lay_ix < 0 || (lay_ix) >= 16 ? (shulang_panic_(1, 0), (layer_lens)[0]) : (layer_lens)[lay_ix])))) {   (void)((bad_mid = 1));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (bad_mid) {   break;
 } else (__tmp = 0) ; __tmp; }));
      (void)((sm = sm + 1));
    }
    (void)(({ int32_t __tmp = 0; if (bad_mid) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Module * dm = (dep_j < 0 || (dep_j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[dep_j]);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   (void)((dep_j = dep_j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    return typeck_find_func_return_type_in_module_by_name(dm, arena, (&(((layer_bytes)[0])[0])), (layer_lens)[0], dep_j, ctx);
  }
  return 0;
}
int32_t typeck_resolve_call_callee_return_type(struct ast_Module * module, struct ast_ASTArena * arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if (callee_expr_ref <= 0 || callee_expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr callee = ast_ast_arena_expr_get(arena, callee_expr_ref);
  (void)(({ int32_t __tmp = 0; if ((callee).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   int32_t r_whole = typeck_resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx);
  __tmp = ({ int32_t __tmp = 0; if (r_whole != 0) {   return r_whole;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((callee).kind == ast_ExprKind_EXPR_FIELD_ACCESS && (callee).field_access_base_ref > 0 && (callee).field_access_base_ref <= (arena)->num_exprs) {   struct ast_Expr base_bind = ast_ast_arena_expr_get(arena, (callee).field_access_base_ref);
  __tmp = ({ int32_t __tmp = 0; if ((base_bind).kind == ast_ExprKind_EXPR_VAR && (base_bind).var_name_len > 0 && (base_bind).var_name_len <= 63) {   int32_t ii = 0;
  while (ii < (module)->num_imports && ii < 32) {
    (void)(({ int32_t __tmp = 0; if ((ii < 0 || (ii) >= 32 ? (shulang_panic_(1, 0), ((module)->import_kinds)[0]) : ((module)->import_kinds)[ii]) == ast_ImportKind_IMPORT_BINDING && (ii < 0 || (ii) >= 32 ? (shulang_panic_(1, 0), ((module)->import_binding_name_len)[0]) : ((module)->import_binding_name_len)[ii]) == (base_bind).var_name_len && typeck_name_equal((&(((ii < 0 || (ii) >= 32 ? (shulang_panic_(1, 0), ((module)->import_binding_name)[0]) : ((module)->import_binding_name)[ii]))[0])), (ii < 0 || (ii) >= 32 ? (shulang_panic_(1, 0), ((module)->import_binding_name_len)[0]) : ((module)->import_binding_name_len)[ii]), (base_bind).var_name, (base_bind).var_name_len)) {   struct ast_Module * dm = (ii < 0 || (ii) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[ii]);
  (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   int32_t ret_b = typeck_find_func_return_type_in_module_by_name(dm, arena, (callee).field_access_field_name, (callee).field_access_field_len, ii, ctx);
  __tmp = ({ int32_t __tmp = 0; if (ret_b != 0) {   return ret_b;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t minus_one = -1;
  int32_t ret = typeck_find_func_return_type_in_module(module, arena, arena, arena, callee_expr_ref, minus_one, ctx);
  (void)(({ int32_t __tmp = 0; if (ret != 0) {   return ret;
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  int32_t imax = (module)->num_imports;
  (void)(({ int32_t __tmp = 0; if ((ctx)->ndep > imax) {   (void)((imax = (ctx)->ndep));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (imax > 32) {   (void)((imax = 32));
 } else (__tmp = 0) ; __tmp; }));
  while (i < imax) {
    struct ast_Module * dm = (i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[i]);
    (void)(({ int32_t __tmp = 0; if (dm == ((struct ast_Module *)(0))) {   (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)((ret = typeck_find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, i, ctx)));
    (void)(({ int32_t __tmp = 0; if (ret != 0) {   return ret;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (i < (module)->num_imports && (i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_kinds)[0]) : ((module)->import_kinds)[i]) == ast_ImportKind_IMPORT_SELECT && (callee).kind == ast_ExprKind_EXPR_VAR && (callee).var_name_len > 0) {   int32_t k = 0;
  while (k < (i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_count)[0]) : ((module)->import_select_count)[i]) && k < 8) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 8 ? (shulang_panic_(1, 0), ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_name_lens)[0]) : ((module)->import_select_name_lens)[i]))[0]) : ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_name_lens)[0]) : ((module)->import_select_name_lens)[i]))[k]) == (callee).var_name_len && typeck_name_equal((&(((k < 0 || (k) >= 8 ? (shulang_panic_(1, 0), ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_names)[0]) : ((module)->import_select_names)[i]))[0]) : ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_names)[0]) : ((module)->import_select_names)[i]))[k]))[0])), (k < 0 || (k) >= 8 ? (shulang_panic_(1, 0), ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_name_lens)[0]) : ((module)->import_select_name_lens)[i]))[0]) : ((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((module)->import_select_name_lens)[0]) : ((module)->import_select_name_lens)[i]))[k]), (callee).var_name, (callee).var_name_len)) {   (void)(({ int32_t __tmp = 0; if (dm != ((struct ast_Module *)(0))) {   (void)((ret = typeck_find_func_return_type_in_module_by_name(dm, arena, (callee).var_name, (callee).var_name_len, i, ctx)));
  __tmp = ({ int32_t __tmp = 0; if (ret != 0) {   return ret;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_expr_type_ref_impl(struct ast_ASTArena * arena, int32_t expr_ref) {
  struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
  return (e).resolved_type_ref;
}
int32_t typeck_expr_type_ref(struct ast_ASTArena * arena, int32_t expr_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(expr_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return typeck_expr_type_ref_impl(arena, expr_ref);
}
int typeck_type_ref_is_bool_impl(struct ast_ASTArena * arena, int32_t type_ref) {
  struct ast_Type t = ast_ast_arena_type_get(arena, type_ref);
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
  struct ast_Type ta = ast_ast_arena_type_get(arena, a);
  struct ast_Type tb = ast_ast_arena_type_get(arena, b);
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
int32_t typeck_typeck_diag_append_lit(uint8_t * out, int32_t pos, int32_t cap, uint8_t * lit, int32_t lit_len) {
  int32_t p = pos;
  int32_t i = 0;
  while (i < lit_len && p >= 0 && p < cap) {
    (void)(((out)[p] = (lit)[i]));
    (void)((p = p + 1));
    (void)((i = i + 1));
  }
  return p;
}
int32_t typeck_typeck_diag_append_u32_dec(uint8_t * out, int32_t pos, int32_t cap, int32_t v) {
  int32_t p = pos;
  (void)(({ int32_t __tmp = 0; if (v < 0 || p < 0 || p >= cap) {   return p;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (v == 0) {   uint8_t zd[1] = { 48 };
  return typeck_typeck_diag_append_lit(out, p, cap, (&((zd)[0])), 1);
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
int32_t typeck_typeck_diag_fmt_type_at(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cur, int32_t cap) {
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
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ref) || ref <= 0 || ref > (arena)->num_types) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ty = ast_ast_arena_type_get(arena, ref);
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_NAMED && (ty).name_len > 0 && (ty).name_len <= 64) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&(((ty).name)[0])), (ty).name_len);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_I32) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_i32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_BOOL) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_bool)[0])), 4);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U8) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_u8)[0])), 2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U32) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_u32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_U64) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_u64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_I64) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_i64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_USIZE) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_usize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_ISIZE) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_isize)[0])), 5);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_F32) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_f32)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_F64) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((lit_f64)[0])), 3);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_VOID) {   return typeck_typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_PTR) {   int32_t nex = typeck_typeck_diag_append_lit(out, cur, cap, (&((star)[0])), 1);
  return typeck_typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, nex, cap);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_SLICE) {   int32_t nex2 = typeck_typeck_diag_append_lit(out, cur, cap, (&((slo)[0])), 2);
  return typeck_typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, nex2, cap);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((ty).kind == ast_TypeKind_TYPE_ARRAY && (!ast_ref_is_null((ty).elem_type_ref)) && (ty).array_size > 0) {   int32_t p0 = typeck_typeck_diag_append_lit(out, cur, cap, (&((lbk)[0])), 1);
  int32_t p1 = typeck_typeck_diag_append_u32_dec(out, p0, cap, (ty).array_size);
  int32_t p2 = typeck_typeck_diag_append_lit(out, p1, cap, (&((rbk)[0])), 1);
  return typeck_typeck_diag_fmt_type_at(arena, (ty).elem_type_ref, out, p2, cap);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_typeck_diag_append_lit(out, cur, cap, (&((qmk)[0])), 1);
}
int32_t typeck_typeck_diag_fmt_type_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out, int32_t cap) {
  return typeck_typeck_diag_fmt_type_at(arena, ref, out, 0, cap);
}
int32_t typeck_typeck_diag_fmt_type_or_question(struct ast_ASTArena * arena, int32_t ref, uint8_t * out) {
  uint8_t qmk[1] = { 63 };
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(ref) || ref <= 0 || ref > (arena)->num_types) {   return typeck_typeck_diag_append_lit(out, 0, 96, (&((qmk)[0])), 1);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_typeck_diag_fmt_type_into(arena, ref, out, 96);
}
int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FLOAT_LIT) {   (void)(((e).float_bits_lo = typeck_float64_bits_lo((e).float_val)));
  (void)(((e).float_bits_hi = typeck_float64_bits_hi((e).float_val)));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
  int32_t ft = typeck_ensure_f64_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (ft != 0) {   (void)(((e).resolved_type_ref = ft));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LIT) {   int32_t it = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (it != 0) {   (void)(((e).resolved_type_ref = it));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BOOL_LIT) {   int32_t bt = typeck_ensure_bool_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(((e).resolved_type_ref = bt));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ENUM_VARIANT) {   int32_t it = typeck_ensure_i32_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (it != 0) {   (void)(((e).resolved_type_ref = it));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
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
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_t)) && ty_t > 0 && ty_t <= (arena)->num_types) {   struct ast_Type tt = ast_ast_arena_type_get(arena, ty_t);
  (void)((t_named = (tt).kind == ast_TypeKind_TYPE_NAMED));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if ((!ast_ref_is_null(ty_e)) && ty_e > 0 && ty_e <= (arena)->num_types) {   struct ast_Type te = ast_ast_arena_type_get(arena, ty_e);
  (void)((e_named = (te).kind == ast_TypeKind_TYPE_NAMED));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e)) && t_named && e_named && (!typeck_type_refs_equal(arena, ty_t, ty_e))) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t)) && (!ast_ref_is_null(ty_e))) {   (void)(((e).resolved_type_ref = (e_named && (!t_named) ? ty_e : ty_t)));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_t))) {   (void)(((e).resolved_type_ref = ty_t));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ty_e))) {   (void)(((e).resolved_type_ref = ty_e));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_BLOCK) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, (e).block_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).block_ref > 0 && (e).block_ref <= (arena)->num_blocks) {   int32_t fin_blk = ast_ast_block_final_expr_ref(arena, (e).block_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin_blk))) {   (void)(((e).resolved_type_ref = typeck_expr_type_ref(arena, fin_blk)));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = ({ int32_t __tmp = 0; if (ast_ast_block_num_expr_stmts(arena, (e).block_ref) == 1) {   int32_t fst_es = ast_ast_block_expr_stmt_ref(arena, (e).block_ref, 0);
  __tmp = ({ int32_t __tmp = 0; if (fst_es > 0 && fst_es <= (arena)->num_exprs) {   struct ast_Expr st = ast_ast_arena_expr_get(arena, fst_es);
  __tmp = ({ int32_t __tmp = 0; if ((st).kind == ast_ExprKind_EXPR_ASSIGN || (st).kind == ast_ExprKind_EXPR_ADD_ASSIGN || (st).kind == ast_ExprKind_EXPR_SUB_ASSIGN || (st).kind == ast_ExprKind_EXPR_MUL_ASSIGN || (st).kind == ast_ExprKind_EXPR_DIV_ASSIGN || (st).kind == ast_ExprKind_EXPR_MOD_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITAND_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITOR_ASSIGN || (st).kind == ast_ExprKind_EXPR_BITXOR_ASSIGN || (st).kind == ast_ExprKind_EXPR_SHL_ASSIGN || (st).kind == ast_ExprKind_EXPR_SHR_ASSIGN && (!ast_ref_is_null((st).binop_right_ref))) {   (void)(((e).resolved_type_ref = typeck_expr_type_ref(arena, (st).binop_right_ref)));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
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
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && lt > 0 && lt <= (arena)->num_types) {   struct ast_Expr rhs_coerce = ast_ast_arena_expr_get(arena, right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rhs_coerce).kind == ast_ExprKind_EXPR_LIT && (!typeck_type_refs_equal(arena, lt, rt_after))) {   struct ast_Type ltp = ast_ast_arena_type_get(arena, lt);
  __tmp = ({ int32_t __tmp = 0; if ((ltp).kind == ast_TypeKind_TYPE_U8 && (rhs_coerce).int_val >= 0 && (rhs_coerce).int_val <= 255) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = ({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN && (ltp).kind == ast_TypeKind_TYPE_PTR && (rhs_coerce).int_val == 0) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = ({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN && (rhs_coerce).int_val >= 0 && (ltp).kind == ast_TypeKind_TYPE_USIZE || (ltp).kind == ast_TypeKind_TYPE_U32 || (ltp).kind == ast_TypeKind_TYPE_U64) {   (void)(((rhs_coerce).resolved_type_ref = lt));
  (void)(ast_ast_arena_expr_set(arena, right_ref, rhs_coerce));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t rt = typeck_expr_type_ref(arena, right_ref);
  int32_t compound_flag = 1;
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_ASSIGN) {   (void)((compound_flag = 0));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt)) && (!ast_ref_is_null(rt)) && (!typeck_type_refs_equal(arena, lt, rt))) {   uint8_t * eb_ptr = driver_typeck_diag_scratch_expect();
  uint8_t * gb_ptr = driver_typeck_diag_scratch_found();
  int32_t el = typeck_typeck_diag_fmt_type_into(arena, lt, eb_ptr, 96);
  int32_t gl = typeck_typeck_diag_fmt_type_into(arena, rt, gb_ptr, 96);
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, (e).line, (e).col, eb_ptr, el, gb_ptr, gl));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (ast_ref_is_null(lt) && (!ast_ref_is_null(rt)) || (!ast_ref_is_null(lt)) && ast_ref_is_null(rt)) {   uint8_t * ebq_ptr = driver_typeck_diag_scratch_expect();
  uint8_t * gbq_ptr = driver_typeck_diag_scratch_found();
  int32_t elq = typeck_typeck_diag_fmt_type_or_question(arena, lt, ebq_ptr);
  int32_t glq = typeck_typeck_diag_fmt_type_or_question(arena, rt, gbq_ptr);
  (void)(driver_diagnostic_typeck_assign_mismatch(compound_flag, (e).line, (e).col, ebq_ptr, elq, gbq_ptr, glq));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_RETURN) {   int32_t op_ref = (e).unary_operand_ref;
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {   (void)(driver_diagnostic_typeck_ret_fail(1, op_ref, return_type_ref, 0));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && op_ref > 0 && op_ref <= (arena)->num_exprs && (!ast_ref_is_null(return_type_ref))) {   struct ast_Expr ropw = ast_ast_arena_expr_get(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if ((ropw).kind == ast_ExprKind_EXPR_LIT && (ropw).int_val >= 0) {   struct ast_Type rt_w = ast_ast_arena_type_get(arena, return_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt_w).kind == ast_TypeKind_TYPE_USIZE || (rt_w).kind == ast_TypeKind_TYPE_U32 || (rt_w).kind == ast_TypeKind_TYPE_U64) {   (void)(((ropw).resolved_type_ref = return_type_ref));
  (void)(ast_ast_arena_expr_set(arena, op_ref, ropw));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_ref)) && op_ref > 0 && op_ref <= (arena)->num_exprs) {   struct ast_Expr rop = ast_ast_arena_expr_get(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rop).kind == ast_ExprKind_EXPR_AS && (!ast_ref_is_null((rop).as_target_type_ref)) && (!ast_ref_is_null(return_type_ref))) {   __tmp = ({ int32_t __tmp = 0; if (typeck_type_refs_equal(arena, (rop).as_target_type_ref, return_type_ref)) {   (void)(((rop).resolved_type_ref = (rop).as_target_type_ref));
  (void)(ast_ast_arena_expr_set(arena, op_ref, rop));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && (!ast_ref_is_null(op_ref))) {   int32_t got = typeck_expr_type_ref(arena, op_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(got)) && (!typeck_type_refs_equal(arena, got, return_type_ref))) {   (void)(driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_PANIC) {   return typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_MATCH) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).match_matched_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < (e).match_num_arms) {
    (void)(({ int32_t __tmp = 0; if (i >= 16) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (i < 0 || (i) >= 16 ? (shulang_panic_(1, 0), ((e).match_arm_result_refs)[0]) : ((e).match_arm_result_refs)[i]), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).field_access_base_ref) || (e).field_access_base_ref <= 0 || (e).field_access_base_ref > (arena)->num_exprs) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).field_access_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr base = ast_ast_arena_expr_get(arena, (e).field_access_base_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((base).resolved_type_ref)) && (base).resolved_type_ref > 0 && (base).resolved_type_ref <= (arena)->num_types) {   struct ast_Type bt = ast_ast_arena_type_get(arena, (base).resolved_type_ref);
  (void)(({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt).elem_type_ref))) {   uint8_t inner_nm_buf[64] = { 0 };
  int32_t inner_nm_len = pipeline_type_named_name_into(arena, (bt).elem_type_ref, (&((inner_nm_buf)[0])));
  int32_t inner_ord = pipeline_type_kind_ord_at(arena, (bt).elem_type_ref);
  (void)(driver_diagnostic_typeck_ptr_field(typeck_type_kind_ordinal((bt).kind), inner_ord, inner_nm_len, (base).resolved_type_ref, (module)->num_struct_layouts));
  uint8_t nm_astarena[8] = { 65, 83, 84, 65, 114, 101, 110, 97 };
  __tmp = ({ int32_t __tmp = 0; if (inner_ord == 8 && inner_nm_len == 8 && typeck_name_equal((&((inner_nm_buf)[0])), inner_nm_len, (&((nm_astarena)[0])), 8)) {   int32_t fl = (e).field_access_field_len;
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
  int32_t arr_exprs = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_ex)[0])), 4, 4096);
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
  int32_t arr_blocks = typeck_ensure_array_type_ref_named_elem(arena, (&((nm_bl)[0])), 5, 512);
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
  __tmp = ({ int32_t __tmp = 0; if (matched_at) {   (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
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
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
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
  __tmp = ({ int32_t __tmp = 0; if (off >= 0 || ftr != 0) {   (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_tok_kind_ty[9] = { 84, 111, 107, 101, 110, 75, 105, 110, 100 };
  uint8_t nm_eof_variant[9] = { 84, 79, 75, 69, 78, 95, 69, 79, 70 };
  __tmp = ({ int32_t __tmp = 0; if (off < 0 && ftr == 0 && layout_nm_len == 9 && typeck_name_equal((&((layout_nm_buf)[0])), layout_nm_len, (&((nm_tok_kind_ty)[0])), 9) && (e).field_access_field_len == 9 && typeck_name_equal((&(((e).field_access_field_name)[0])), (e).field_access_field_len, (&((nm_eof_variant)[0])), 9)) {   (void)(((e).field_access_is_enum_variant = 1));
  (void)(((e).enum_variant_tag = 0));
  int32_t i32r = typeck_ensure_i32_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (i32r != 0) {   (void)(((e).resolved_type_ref = i32r));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_SLICE && (!ast_ref_is_null((bt).elem_type_ref))) {   int32_t nm_len = (e).field_access_field_len;
  uint8_t len_nm[6] = { 108, 101, 110, 103, 116, 104 };
  uint8_t dat_nm[4] = { 100, 97, 116, 97 };
  __tmp = ({ int32_t __tmp = 0; if (nm_len == 6 && typeck_name_equal((&(((e).field_access_field_name)[0])), nm_len, (&((len_nm)[0])), 6)) {   int32_t ut = typeck_ensure_usize_type_ref(arena);
  __tmp = ({ int32_t __tmp = 0; if (ut != 0) {   (void)(((e).resolved_type_ref = ut));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (nm_len == 4 && typeck_name_equal((&(((e).field_access_field_name)[0])), nm_len, (&((dat_nm)[0])), 4)) {   struct ast_Type et = ast_ast_arena_type_get(arena, (bt).elem_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((et).kind == ast_TypeKind_TYPE_U8) {   int32_t ptr_ref = ast_ast_arena_type_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (ptr_ref != 0) {   struct ast_Type pt = ast_ast_arena_type_get(arena, ptr_ref);
  (void)(((pt).kind = ast_TypeKind_TYPE_PTR));
  (void)(((pt).elem_type_ref = (bt).elem_type_ref));
  (void)(((pt).name_len = 0));
  (void)(((pt).array_size = 0));
  (void)(ast_ast_arena_type_set(arena, ptr_ref, pt));
  (void)(((e).resolved_type_ref = ptr_ref));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_INDEX) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).index_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).index_index_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((e).index_base_ref) || (e).index_base_ref <= 0 || (e).index_base_ref > (arena)->num_exprs) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr eb = ast_ast_arena_expr_get(arena, (e).index_base_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((eb).resolved_type_ref)) && (eb).resolved_type_ref > 0 && (eb).resolved_type_ref <= (arena)->num_types) {   struct ast_Type bt = ast_ast_arena_type_get(arena, (eb).resolved_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_ARRAY || (bt).kind == ast_TypeKind_TYPE_SLICE || (bt).kind == ast_TypeKind_TYPE_PTR && (!ast_ref_is_null((bt).elem_type_ref))) {   (void)(((e).resolved_type_ref = (bt).elem_type_ref));
  (void)(({ int32_t __tmp = 0; if ((bt).kind == ast_TypeKind_TYPE_SLICE) {   (void)(((e).index_base_is_slice = 1));
 } else {   (void)(((e).index_base_is_slice = 0));
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).index_index_ref)) && (e).index_index_ref > 0 && (e).index_index_ref <= (arena)->num_exprs) {   struct ast_Expr idxe = ast_ast_arena_expr_get(arena, (e).index_index_ref);
  __tmp = ({ int32_t __tmp = 0; if ((idxe).kind == ast_ExprKind_EXPR_LIT && (idxe).int_val == 0 && (bt).kind == ast_TypeKind_TYPE_ARRAY && (bt).array_size >= 1) {   (void)(((e).index_proven_in_bounds = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_CALL) {   int32_t j = 0;
  while (j < (e).call_num_args) {
    (void)(({ int32_t __tmp = 0; if (j >= 16) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (j < 0 || (j) >= 16 ? (shulang_panic_(1, 0), ((e).call_arg_refs)[0]) : ((e).call_arg_refs)[j]), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).call_callee_ref))) {   struct ast_Expr callee_ce = ast_ast_arena_expr_get(arena, (e).call_callee_ref);
  __tmp = ({ int32_t __tmp = 0; if ((callee_ce).kind == ast_ExprKind_EXPR_VAR && (callee_ce).var_name_len > 0 && (callee_ce).var_name_len <= 63 || (callee_ce).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {   int32_t ret_ty = typeck_resolve_call_callee_return_type(module, arena, (e).call_callee_ref, ctx);
  __tmp = ({ int32_t __tmp = 0; if (ret_ty != 0) {   (void)(((e).resolved_type_ref = ret_ty));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_METHOD_CALL) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).method_call_base_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < (e).method_call_num_args) {
    (void)(({ int32_t __tmp = 0; if (j >= 16) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (j < 0 || (j) >= 16 ? (shulang_panic_(1, 0), ((e).method_call_arg_refs)[0]) : ((e).method_call_arg_refs)[j]), return_type_ref, ctx) != 0) {   return (-1);
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
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t lt_ar = typeck_expr_type_ref(arena, (e).binop_left_ref);
  int32_t rt_ar = typeck_expr_type_ref(arena, (e).binop_right_ref);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(lt_ar)) && lt_ar > 0 && lt_ar <= (arena)->num_types && (!ast_ref_is_null(rt_ar)) && rt_ar > 0 && rt_ar <= (arena)->num_types) {   struct ast_Type lar = ast_ast_arena_type_get(arena, lt_ar);
  struct ast_Type rar = ast_ast_arena_type_get(arena, rt_ar);
  int32_t out_ar = 0;
  (void)(({ int32_t __tmp = 0; if ((lar).kind == ast_TypeKind_TYPE_I64 || (rar).kind == ast_TypeKind_TYPE_I64) {   (void)((out_ar = typeck_ensure_i64_type_ref(arena)));
 } else (__tmp = ({ int32_t __tmp = 0; if ((lar).kind == ast_TypeKind_TYPE_F64 || (rar).kind == ast_TypeKind_TYPE_F64) {   (void)((out_ar = typeck_ensure_f64_type_ref(arena)));
 } else (__tmp = ({ int32_t __tmp = 0; if (typeck_type_refs_equal(arena, lt_ar, rt_ar)) {   (void)((out_ar = lt_ar));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (out_ar != 0) {   (void)(((e).resolved_type_ref = out_ar));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_NEG || (e).kind == ast_ExprKind_EXPR_BITNOT || (e).kind == ast_ExprKind_EXPR_LOGNOT) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, (e).unary_operand_ref, return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_LOGNOT) {   int32_t bt = typeck_ensure_bool_type_ref(arena);
  (void)(({ int32_t __tmp = 0; if (bt != 0) {   (void)(((e).resolved_type_ref = bt));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_tr = typeck_expr_type_ref(arena, (e).unary_operand_ref);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(op_tr)) && op_tr > 0 && op_tr <= (arena)->num_types) {   (void)(((e).resolved_type_ref = op_tr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR && (ctx)->current_block_ref != 0 && (ctx)->current_block_ref <= (arena)->num_blocks) {   int32_t vd_tr = ast_ast_block_resolve_var_to_type_ref(arena, (ctx)->current_block_ref, (e).var_name, (e).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(vd_tr))) {   (void)(((e).resolved_type_ref = vd_tr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR && (ctx)->current_func_index >= 0 && (ctx)->current_func_index < (module)->num_funcs) {   int32_t fi = (ctx)->current_func_index;
  int32_t pr = pipeline_module_func_param_type_ref_for_name(module, fi, (&(((e).var_name)[0])), (e).var_name_len);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(pr))) {   (void)(((e).resolved_type_ref = pr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR) {   uint8_t nm_tok_kind_sym[9] = { 84, 111, 107, 101, 110, 75, 105, 110, 100 };
  (void)(({ int32_t __tmp = 0; if ((e).var_name_len == 9 && typeck_name_equal((e).var_name, (e).var_name_len, nm_tok_kind_sym, 9)) {   int32_t tk_tr = typeck_find_or_alloc_named_type_ref(arena, nm_tok_kind_sym, 9);
  __tmp = ({ int32_t __tmp = 0; if (tk_tr != 0) {   (void)(((e).resolved_type_ref = tk_tr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  uint8_t nm_typ_kind_sym[8] = { 84, 121, 112, 101, 75, 105, 110, 100 };
  __tmp = ({ int32_t __tmp = 0; if ((e).var_name_len == 8 && typeck_name_equal((e).var_name, (e).var_name_len, (&((nm_typ_kind_sym)[0])), 8)) {   int32_t tg_tr = typeck_find_or_alloc_named_type_ref(arena, (&((nm_typ_kind_sym)[0])), 8);
  __tmp = ({ int32_t __tmp = 0; if (tg_tr != 0) {   (void)(((e).resolved_type_ref = tg_tr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_VAR) {   struct ast_Expr ev = ast_ast_arena_expr_get(arena, expr_ref);
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((ev).resolved_type_ref)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_AS) {   (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).as_operand_ref)) && typeck_check_expr(module, arena, (e).as_operand_ref, 0, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((e).as_target_type_ref))) {   (void)(((e).resolved_type_ref = (e).as_target_type_ref));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((e).kind == ast_ExprKind_EXPR_STRUCT_LIT) {   int32_t fi = 0;
  while (fi < (e).struct_lit_num_fields && fi < 8) {
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_init_refs)[0]) : ((e).struct_lit_init_refs)[fi]))) && typeck_check_expr(module, arena, (fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((e).struct_lit_init_refs)[0]) : ((e).struct_lit_init_refs)[fi]), return_type_ref, ctx) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((fi = fi + 1));
  }
  (void)(({ int32_t __tmp = 0; if (typeck_ensure_struct_layout_from_struct_lit(module, arena, e) != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t tr = typeck_find_or_alloc_named_type_ref(arena, (e).struct_lit_struct_name, (e).struct_lit_struct_name_len);
  (void)(({ int32_t __tmp = 0; if (tr != 0) {   (void)(((e).resolved_type_ref = tr));
  (void)(ast_ast_arena_expr_set(arena, expr_ref, e));
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
int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref) {
  (void)(({ int __tmp = 0; if (ast_ref_is_null(body_ref) || body_ref <= 0 || body_ref > (arena)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t fin_ref = ast_ast_block_final_expr_ref(arena, body_ref);
  (void)(({ int __tmp = 0; if (ast_ref_is_null(fin_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_ast_expr_disallows_implicit_tail(arena, fin_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
int32_t typeck_check_block_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t saved_block_ref = (ctx)->current_block_ref;
  (void)(((ctx)->current_block_ref = block_ref));
  int32_t nc = ast_ast_block_num_consts(arena, block_ref);
  int32_t nl = ast_ast_block_num_lets(arena, block_ref);
  int32_t nlp = ast_ast_block_num_loops(arena, block_ref);
  int32_t nfp = ast_ast_block_num_for_loops(arena, block_ref);
  int32_t nif = ast_ast_block_num_if_stmts(arena, block_ref);
  int32_t nes = ast_ast_block_num_expr_stmts(arena, block_ref);
  int32_t nso = ast_ast_block_num_stmt_order(arena, block_ref);
  int32_t fin0 = ast_ast_block_final_expr_ref(arena, block_ref);
  (void)(driver_diagnostic_typeck_block_enter((ctx)->current_func_index, block_ref, nc, nl, nlp, nfp, nes, fin0));
  (void)(({ int32_t __tmp = 0; if (nso > 0) {   int32_t si = 0;
  while (si < nso) {
    (void)(({ int32_t __tmp = 0; if (si >= 96) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_block_ref = block_ref));
    uint8_t sk = ast_ast_block_stmt_order_kind(arena, block_ref, si);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
    (void)(({ int32_t __tmp = 0; if (sk == 0) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nc && idx < 128) {   int32_t cd0_ir = ast_ast_block_const_init_ref(arena, block_ref, idx);
  int32_t cd0_tr = ast_ast_block_const_type_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, cd0_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(cd0_ir)) && (!ast_ref_is_null(cd0_tr))) {   int32_t init_ty0 = typeck_expr_type_ref(arena, cd0_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty0)) && (!typeck_type_refs_equal(arena, cd0_tr, init_ty0))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 1) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nl && idx < 128) {   int32_t ld0_ir = ast_ast_block_let_init_ref(arena, block_ref, idx);
  int32_t ld0_tr = ast_ast_block_let_type_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ld0_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(ld0_ir)) && (!ast_ref_is_null(ld0_tr))) {   int32_t init_ty_l = typeck_expr_type_ref(arena, ld0_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty_l)) && (!typeck_type_refs_equal(arena, ld0_tr, init_ty_l))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 2) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nes && idx < 32) {   int32_t expr_s = ast_ast_block_expr_stmt_ref(arena, block_ref, idx);
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, expr_s, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 3) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nlp && idx < 8) {   int32_t wc = ast_ast_block_while_cond_ref(arena, block_ref, idx);
  int32_t wb = ast_ast_block_while_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(wc))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, wc, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, wc)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block(module, arena, wb, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 4) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nfp && idx < 8) {   int32_t fi_ir = ast_ast_block_for_init_ref(arena, block_ref, idx);
  int32_t fc_cr = ast_ast_block_for_cond_ref(arena, block_ref, idx);
  int32_t fs_sr = ast_ast_block_for_step_ref(arena, block_ref, idx);
  int32_t fb_br = ast_ast_block_for_body_ref(arena, block_ref, idx);
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
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block(module, arena, fb_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (sk == 5) {   __tmp = ({ int32_t __tmp = 0; if (idx >= 0 && idx < nif && idx < 16) {   int32_t ic_cr = ast_ast_block_if_cond_ref(arena, block_ref, idx);
  int32_t ib_tr = ast_ast_block_if_then_body_ref(arena, block_ref, idx);
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ic_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ic_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, ic_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_check_block(module, arena, ib_tr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)((si = si + 1));
  }
 } else {   int32_t i = 0;
  while (i < nc) {
    (void)(({ int32_t __tmp = 0; if (i >= 64) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t cd_ir = ast_ast_block_const_init_ref(arena, block_ref, i);
    int32_t cd_tr = ast_ast_block_const_type_ref(arena, block_ref, i);
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
    (void)(({ int32_t __tmp = 0; if (i >= 64) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t ld_ir = ast_ast_block_let_init_ref(arena, block_ref, i);
    int32_t ld_tr = ast_ast_block_let_type_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, ld_ir, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(ld_ir)) && (!ast_ref_is_null(ld_tr))) {   int32_t init_ty = typeck_expr_type_ref(arena, ld_ir);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(init_ty)) && (!typeck_type_refs_equal(arena, ld_tr, init_ty))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nlp) {
    (void)(({ int32_t __tmp = 0; if (i >= 8) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t w_cr = ast_ast_block_while_cond_ref(arena, block_ref, i);
    int32_t w_br = ast_ast_block_while_body_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(w_cr))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, w_cr, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!typeck_type_ref_is_bool(arena, typeck_expr_type_ref(arena, w_cr)))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, w_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nfp) {
    (void)(({ int32_t __tmp = 0; if (i >= 8) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t fl_ir = ast_ast_block_for_init_ref(arena, block_ref, i);
    int32_t fl_cr = ast_ast_block_for_cond_ref(arena, block_ref, i);
    int32_t fl_sr = ast_ast_block_for_step_ref(arena, block_ref, i);
    int32_t fl_br = ast_ast_block_for_body_ref(arena, block_ref, i);
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
    (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, fl_br, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nif) {
    (void)(({ int32_t __tmp = 0; if (i >= 16) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t ik_cr = ast_ast_block_if_cond_ref(arena, block_ref, i);
    int32_t ik_tr = ast_ast_block_if_then_body_ref(arena, block_ref, i);
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
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < nes) {
    (void)(({ int32_t __tmp = 0; if (i >= 32) {   break;
 } else (__tmp = 0) ; __tmp; }));
    int32_t es_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, i);
    (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(fin0))) {   (void)(({ int32_t __tmp = 0; if (typeck_check_expr(module, arena, fin0, return_type_ref, ctx) != 0) {   (void)(((ctx)->current_block_ref = saved_block_ref));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref))) {   int32_t got = typeck_expr_type_ref(arena, fin0);
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(got)) && (!typeck_type_refs_equal(arena, got, return_type_ref))) {   (void)(((ctx)->current_block_ref = saved_block_ref));
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
int32_t typeck_typeck_su_ast_impl(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  struct ast_Func main_f = ((module)->main_func_index < 0 || ((module)->main_func_index) >= 256 ? (shulang_panic_(1, 0), ((module)->funcs)[0]) : ((module)->funcs)[(module)->main_func_index]);
  (void)(({ int32_t __tmp = 0; if ((main_f).is_extern == 1 && ast_ref_is_null((main_f).body_ref)) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((main_f).body_ref) && ast_ref_is_null((main_f).body_expr_ref)) {   return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null((main_f).return_type_ref)) {   return (-3);
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type ret_ty = ast_ast_arena_type_get(arena, (main_f).return_type_ref);
  (void)(({ int32_t __tmp = 0; if ((ret_ty).kind != ast_TypeKind_TYPE_I32 && (ret_ty).kind != ast_TypeKind_TYPE_I64) {   return (-4);
 } else (__tmp = 0) ; __tmp; }));
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (i >= 256) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_func_index = i));
    struct ast_Func f = (i < 0 || (i) >= 256 ? (shulang_panic_(1, 0), ((module)->funcs)[0]) : ((module)->funcs)[i]);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((f).body_ref)) && (f).is_extern == 0) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, (f).body_ref, (f).return_type_ref, ctx) != 0) {   (void)(driver_diagnostic_typeck_func_fail(i, (&(((f).name)[0])), (f).name_len, 0 - 5));
  (void)(((ctx)->current_func_index = (-1)));
  return (-5);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((f).return_type_ref))) {   struct ast_Type rt = ast_ast_arena_type_get(arena, (f).return_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt).kind != ast_TypeKind_TYPE_VOID && typeck_func_body_has_implicit_return_tail(arena, (f).body_ref)) {   (void)(driver_diagnostic_typeck_func_fail(i, (&(((f).name)[0])), (f).name_len, 0 - 6));
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
int32_t typeck_typeck_su_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t i = 0;
  while (i < (module)->num_funcs) {
    (void)(({ int32_t __tmp = 0; if (i >= 256) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((ctx)->current_func_index = i));
    struct ast_Func f = (i < 0 || (i) >= 256 ? (shulang_panic_(1, 0), ((module)->funcs)[0]) : ((module)->funcs)[i]);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((f).body_ref)) && (f).is_extern == 0) {   (void)(({ int32_t __tmp = 0; if (typeck_check_block(module, arena, (f).body_ref, (f).return_type_ref, ctx) != 0) {   (void)(driver_diagnostic_typeck_func_fail(i, (&(((f).name)[0])), (f).name_len, 0 - 5));
  (void)(((ctx)->current_func_index = (-1)));
  return (-5);
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null((f).return_type_ref))) {   struct ast_Type rt2 = ast_ast_arena_type_get(arena, (f).return_type_ref);
  __tmp = ({ int32_t __tmp = 0; if ((rt2).kind != ast_TypeKind_TYPE_VOID && typeck_func_body_has_implicit_return_tail(arena, (f).body_ref)) {   (void)(driver_diagnostic_typeck_func_fail(i, (&(((f).name)[0])), (f).name_len, 0 - 6));
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
int32_t typeck_typeck_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   return (-10);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index >= (module)->num_funcs) {   return (-11);
 } else (__tmp = 0) ; __tmp; }));
  return typeck_typeck_su_ast_impl(module, arena, ctx);
}
