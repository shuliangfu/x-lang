/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
extern int getpid(void);
static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = getenv("SHUX_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/shux-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; uint8_t region_label[64]; int32_t region_label_len; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t field_access_soa_stride; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t call_num_type_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t region_base; int32_t num_regions; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t num_generic_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; int32_t is_async; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; int32_t packed; int32_t repr_compatible; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t pending_soa_struct; int32_t pending_cfg_skip; int32_t pending_repr_c_struct; int32_t pending_repr_compatible_struct; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };
struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t target_cpu_features; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; int32_t typeck_scope_region_len; uint8_t typeck_scope_region_label[64]; };
/* slim arena grow pool glue (C-04 codegen; linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

struct driver_DriverCompileState { uint8_t path_buf[512]; int32_t path_len; uint8_t out_path_buf[512]; int32_t out_path_len; int32_t use_asm_backend; int32_t target_arch; uint8_t target_buf[512]; int32_t target_len; uint8_t opt_level_buf[8]; int32_t opt_level_len; int32_t use_lto; int32_t backend_asm_explicit; int32_t use_freestanding; int32_t parse_saw_target; uint8_t target_cpu_buf[64]; int32_t target_cpu_len; int32_t target_cpu_features; int32_t print_target_cpu; int32_t parse_saw_target_cpu; };
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * argv, int32_t i, uint8_t * buf, int32_t max);
extern void driver_compile_argv_copy_path_c(struct driver_DriverCompileState * state, uint8_t * arg_buf, int32_t plen);
extern void driver_compile_ensure_default_lib_c(uint8_t * key);
extern void driver_compile_parse_argv_init_c(struct driver_DriverCompileState * state);
extern void driver_compile_append_lib_root_c(struct driver_DriverCompileState * state, uint8_t * path, int32_t len);
extern void driver_compile_argv_apply_minus_o_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i);
extern void driver_compile_argv_apply_minus_L_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i, uint8_t * arg_buf, int32_t arg_cap);
extern void driver_compile_argv_apply_minus_O_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i);
extern void driver_compile_argv_set_use_lto_c(struct driver_DriverCompileState * state);
extern void driver_compile_argv_set_use_freestanding_c(struct driver_DriverCompileState * state);
extern void driver_compile_argv_set_legacy_f32_abi_c();
extern void driver_compile_argv_set_sanitize_address_c();
extern void driver_compile_argv_apply_backend_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i, uint8_t * arg_buf, int32_t arg_cap);
extern void driver_compile_argv_apply_target_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i);
extern void driver_compile_argv_apply_target_cpu_next_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv, int32_t i);
extern void driver_compile_argv_set_print_target_cpu_c(struct driver_DriverCompileState * state);
extern int32_t driver_print_target_cpu_features_c(int32_t features);
extern void driver_compile_resolve_target_cpu_c(struct driver_DriverCompileState * state);
extern int32_t driver_compile_parse_argv_impl_c(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state);
extern void driver_compile_parse_argv_scan_c(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state);
extern void cfg_sync_compile_target_from_state_c(struct driver_DriverCompileState * state);
extern void driver_emit_lib_root_reset(uint8_t * key);
extern int32_t driver_emit_append_lib_root(uint8_t * key, uint8_t * path, int32_t len);
extern int32_t driver_emit_lib_root_count(uint8_t * key);
extern int32_t driver_resolve_target_arch(int32_t parsed, int32_t saw_target);
extern int32_t driver_source_has_generic_syntax(uint8_t * path, int32_t path_len);
extern int32_t driver_source_has_compound_assign_syntax(uint8_t * path, int32_t path_len);
extern int32_t driver_source_has_top_level_import_path(uint8_t * path, int32_t path_len);
extern int32_t driver_asm_output_want_exe(uint8_t * out_path);
extern int32_t driver_check_only_get();
extern void driver_bump_stack_limit();
extern int32_t driver_asm_entry_module_only_from_env();
extern int32_t driver_compile_argv_is_help_c(int32_t argc, uint8_t * argv);
extern void driver_print_usage_c();
extern int32_t driver_run_compiler_full_sx_impl_c(int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_full_sx_post_parse_impl_c(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv);
extern struct driver_DriverCompileState * driver_compile_state_alloc_c();
extern void driver_compile_state_free_c(struct driver_DriverCompileState * state);
extern int32_t driver_run_asm_backend_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv);
extern int32_t driver_run_emit_c_path_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv);
int32_t driver_compile_dispatch_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv);
int32_t driver_compile_dispatch_emit_c_path(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv);
uint8_t * driver_compile_state_key(struct driver_DriverCompileState * state);
void driver_compile_ensure_default_lib(uint8_t * key);
int32_t driver_eq_minus_o(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_L(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_backend(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_target(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_target_cpu(uint8_t * buf, int32_t len);
int32_t driver_eq_print_target_cpu(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_O(uint8_t * buf, int32_t len);
int32_t driver_eq_flto(uint8_t * buf, int32_t len);
int32_t driver_eq_minus_freestanding(uint8_t * buf, int32_t len);
int32_t driver_eq_legacy_f32_abi(uint8_t * buf, int32_t len);
int32_t driver_eq_fsanitize_address(uint8_t * buf, int32_t len);
int32_t driver_eq_asm_word(uint8_t * buf, int32_t len);
int32_t driver_eq_c_word(uint8_t * buf, int32_t len);
int32_t driver_path_ends_sx(uint8_t * buf, int32_t len);
int32_t driver_target_has_arm(uint8_t * buf, int32_t len);
void driver_compile_parse_argv_init(struct driver_DriverCompileState * state);
int32_t driver_compile_parse_argv_step(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state, int32_t i, uint8_t * arg_buf, int32_t arg_cap);
int32_t driver_compile_parse_argv_loop(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state);
int32_t driver_compile_parse_argv_finalize(struct driver_DriverCompileState * state);
int32_t driver_compile_parse_argv(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state);
int32_t driver_run_compiler_full_sx_post_parse(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv);
int32_t driver_run_compiler_full_sx(int32_t argc, uint8_t * argv);
int32_t driver_compile_dispatch_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv) {
  (void)(({ int32_t __tmp = 0; if (input_path == ((uint8_t *)(0))) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
}
int32_t driver_compile_dispatch_emit_c_path(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv) {
  (void)(({ int32_t __tmp = 0; if (input_path == ((uint8_t *)(0))) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
}
uint8_t * driver_compile_state_key(struct driver_DriverCompileState * state) {
  return ((uint8_t *)(state));
}
void driver_compile_ensure_default_lib(uint8_t * key) {
  (void)(driver_compile_ensure_default_lib_c(key));
}
int32_t driver_eq_minus_o(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 2 && (buf)[0] == 45 && (buf)[1] == 111) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_L(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 2 && (buf)[0] == 45 && (buf)[1] == 76) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_backend(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 8 && (buf)[0] == 45 && (buf)[1] == 98 && (buf)[2] == 97 && (buf)[3] == 99 && (buf)[4] == 107 && (buf)[5] == 101 && (buf)[6] == 110 && (buf)[7] == 100) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_target(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 7) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 116 && (buf)[2] == 97 && (buf)[3] == 114 && (buf)[4] == 103 && (buf)[5] == 101 && (buf)[6] == 116) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_target_cpu(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 11 && (buf)[0] == 45 && (buf)[1] == 116 && (buf)[2] == 97 && (buf)[3] == 114 && (buf)[4] == 103 && (buf)[5] == 101 && (buf)[6] == 116 && (buf)[7] == 45 && (buf)[8] == 99 && (buf)[9] == 112 && (buf)[10] == 117) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_print_target_cpu(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 18 && (buf)[0] == 45 && (buf)[1] == 45 && (buf)[2] == 112 && (buf)[3] == 114 && (buf)[4] == 105 && (buf)[5] == 110 && (buf)[6] == 116 && (buf)[7] == 45 && (buf)[8] == 116 && (buf)[9] == 97 && (buf)[10] == 114 && (buf)[11] == 103 && (buf)[12] == 101 && (buf)[13] == 116 && (buf)[14] == 45 && (buf)[15] == 99 && (buf)[16] == 112 && (buf)[17] == 117) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (len == 17 && (buf)[0] == 45 && (buf)[1] == 112 && (buf)[2] == 114 && (buf)[3] == 105 && (buf)[4] == 110 && (buf)[5] == 116 && (buf)[6] == 45 && (buf)[7] == 116 && (buf)[8] == 97 && (buf)[9] == 114 && (buf)[10] == 103 && (buf)[11] == 101 && (buf)[12] == 116 && (buf)[13] == 45 && (buf)[14] == 99 && (buf)[15] == 112 && (buf)[16] == 117) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_O(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 2 && (buf)[0] == 45 && (buf)[1] == 79) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_flto(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 5 && (buf)[0] == 45 && (buf)[1] == 102 && (buf)[2] == 108 && (buf)[3] == 116 && (buf)[4] == 111) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_minus_freestanding(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 13 && (buf)[0] == 45 && (buf)[1] == 102 && (buf)[2] == 114 && (buf)[3] == 101 && (buf)[4] == 101 && (buf)[5] == 115 && (buf)[6] == 116 && (buf)[7] == 97 && (buf)[8] == 110 && (buf)[9] == 100 && (buf)[10] == 105 && (buf)[11] == 110 && (buf)[12] == 103) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_legacy_f32_abi(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 15 && (buf)[0] == 45 && (buf)[1] == 108 && (buf)[2] == 101 && (buf)[3] == 103 && (buf)[4] == 97 && (buf)[5] == 99 && (buf)[6] == 121 && (buf)[7] == 45 && (buf)[8] == 102 && (buf)[9] == 51 && (buf)[10] == 50 && (buf)[11] == 45 && (buf)[12] == 97 && (buf)[13] == 98 && (buf)[14] == 105) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_fsanitize_address(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 18 && (buf)[0] == 45 && (buf)[1] == 102 && (buf)[2] == 115 && (buf)[3] == 97 && (buf)[4] == 110 && (buf)[5] == 105 && (buf)[6] == 116 && (buf)[7] == 105 && (buf)[8] == 122 && (buf)[9] == 101 && (buf)[10] == 61 && (buf)[11] == 97 && (buf)[12] == 100 && (buf)[13] == 100 && (buf)[14] == 114 && (buf)[15] == 101 && (buf)[16] == 115 && (buf)[17] == 115) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_asm_word(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 3 && (buf)[0] == 97 && (buf)[1] == 115 && (buf)[2] == 109) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_eq_c_word(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len == 1 && (buf)[0] == 99) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_path_ends_sx(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len >= 3 && (buf)[len - 3] == 46 && (buf)[len - 2] == 115) {   uint8_t ext = (buf)[len - 1];
  __tmp = ({ int32_t __tmp = 0; if (ext == 117 || ext == 120) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t driver_target_has_arm(uint8_t * buf, int32_t len) {
  int32_t start = 0;
  while (start + 5 <= len) {
    (void)(({ int32_t __tmp = 0; if ((buf)[start] == 97 && (buf)[start + 1] == 114 && (buf)[start + 2] == 109 && (buf)[start + 3] == 54 && (buf)[start + 4] == 52) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    ++start;
  }
  return 0;
}
void driver_compile_parse_argv_init(struct driver_DriverCompileState * state) {
  (void)(driver_compile_parse_argv_init_c(state));
}
int32_t driver_compile_parse_argv_step(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state, int32_t i, uint8_t * arg_buf, int32_t arg_cap) {
  int32_t len = driver_get_argv_i(argc, argv, i, arg_buf, arg_cap);
  (void)(({ int32_t __tmp = 0; if (len < 0) {   return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_o(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_minus_o_next_c(state, argc, argv, i));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_L(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_minus_L_next_c(state, argc, argv, i, arg_buf, arg_cap));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_O(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_minus_O_next_c(state, argc, argv, i));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_flto(arg_buf, len) != 0) {   (void)(driver_compile_argv_set_use_lto_c(state));
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_freestanding(arg_buf, len) != 0) {   (void)(driver_compile_argv_set_use_freestanding_c(state));
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_legacy_f32_abi(arg_buf, len) != 0) {   (void)(driver_compile_argv_set_legacy_f32_abi_c());
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_fsanitize_address(arg_buf, len) != 0) {   (void)(driver_compile_argv_set_sanitize_address_c());
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_backend_next_c(state, argc, argv, i, arg_buf, arg_cap));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_target_next_c(state, argc, argv, i));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_minus_target_cpu(arg_buf, len) != 0 && i + 1 < argc) {   (void)(driver_compile_argv_apply_target_cpu_next_c(state, argc, argv, i));
  return i + 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_eq_print_target_cpu(arg_buf, len) != 0) {   (void)(driver_compile_argv_set_print_target_cpu_c(state));
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((arg_buf)[0] != 45 && driver_path_ends_sx(arg_buf, len) != 0) {   (void)(driver_compile_argv_copy_path_c(state, arg_buf, len));
  return i + 1;
 } else (__tmp = 0) ; __tmp; }));
  return i + 1;
}
int32_t driver_compile_parse_argv_loop(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state) {
  uint8_t arg_buf[512] = { 0 };
  int32_t i = 1;
  while (i < argc) {
    (i = (driver_compile_parse_argv_step(argc, argv, state, i, (&((arg_buf)[0])), 512)));
  }
  return 0;
}
int32_t driver_compile_parse_argv_finalize(struct driver_DriverCompileState * state) {
  (void)(driver_compile_resolve_target_cpu_c(state));
  (void)(({ int32_t __tmp = 0; if ((state)->print_target_cpu != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->path_len <= 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  ((state)->target_arch = (driver_resolve_target_arch((state)->target_arch, (state)->parse_saw_target)));
  (void)(cfg_sync_compile_target_from_state_c(state));
  (void)(driver_compile_ensure_default_lib_c(driver_compile_state_key(state)));
  return 0;
}
int32_t driver_compile_parse_argv(int32_t argc, uint8_t * argv, struct driver_DriverCompileState * state) {
  int32_t one = 1;
  (void)(({ int32_t __tmp = 0; if (argc < 2) {   return one;
 } else (__tmp = 0) ; __tmp; }));
  (void)(driver_compile_parse_argv_init(state));
  (void)(driver_compile_parse_argv_loop(argc, argv, state));
  return driver_compile_parse_argv_finalize(state);
}
int32_t driver_run_compiler_full_sx_post_parse(struct driver_DriverCompileState * state, int32_t argc, uint8_t * argv) {
  int32_t one = 1;
  int32_t zero = 0;
  (void)(({ int32_t __tmp = 0; if (state == ((struct driver_DriverCompileState *)(0))) {   return one;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_check_only_get() != 0) {   ((state)->use_asm_backend = (zero));
 } else (__tmp = 0) ; __tmp; }));
  int32_t want_generic_check = zero;
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len == zero) {   (want_generic_check = (one));
 } else (__tmp = ({ int32_t __tmp = 0; if (driver_asm_output_want_exe((&(((state)->out_path_buf)[0]))) != 0) {   (want_generic_check = (one));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->use_asm_backend != 0 && want_generic_check != 0) {   __tmp = ({ int32_t __tmp = 0; if (driver_source_has_generic_syntax((&(((state)->path_buf)[0])), (state)->path_len) != 0) {   ((state)->use_asm_backend = (zero));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->use_asm_backend != 0 && (state)->out_path_len > 0 && driver_asm_output_want_exe((&(((state)->out_path_buf)[0]))) != 0) {  } else (__tmp = 0) ; __tmp; }));
  uint8_t * out_ptr = ((uint8_t *)(0));
  (void)(({ uint8_t * __tmp = 0; if ((state)->out_path_len > 0) {   (out_ptr = ((&(((state)->out_path_buf)[0]))));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t * target_ptr = ((uint8_t *)(0));
  (void)(({ uint8_t * __tmp = 0; if ((state)->target_len > 0) {   (target_ptr = ((&(((state)->target_buf)[0]))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len > 0 && (state)->backend_asm_explicit == 0 && driver_source_has_top_level_import_path((&(((state)->path_buf)[0])), (state)->path_len) == 0) {   ((state)->backend_asm_explicit = (one));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->use_asm_backend != 0 && (state)->backend_asm_explicit == 0 && driver_asm_entry_module_only_from_env() == 0 && driver_source_has_top_level_import_path((&(((state)->path_buf)[0])), (state)->path_len) != 0) {   ((state)->use_asm_backend = (zero));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->use_freestanding != 0) {   ((state)->use_asm_backend = (one));
  ((state)->backend_asm_explicit = (one));
  (void)(driver_compile_argv_set_use_freestanding_c(state));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t * lib_key = driver_compile_state_key(state);
  (void)(({ int32_t __tmp = 0; if ((state)->use_asm_backend != 0) {   return driver_compile_dispatch_asm_backend((&(((state)->path_buf)[0])), out_ptr, lib_key, target_ptr, argc, argv);
 } else (__tmp = 0) ; __tmp; }));
  return driver_compile_dispatch_emit_c_path((&(((state)->path_buf)[0])), out_ptr, lib_key, target_ptr, (&(((state)->opt_level_buf)[0])), (state)->use_lto, argc, argv);
}
int32_t driver_run_compiler_full_sx(int32_t argc, uint8_t * argv) {
  int32_t one = 1;
  int32_t zero = 0;
  (void)(({ int32_t __tmp = 0; if (driver_compile_argv_is_help_c(argc, argv) != 0) {   (void)(driver_print_usage_c());
  return zero;
 } else (__tmp = 0) ; __tmp; }));
  (void)(driver_bump_stack_limit());
  struct driver_DriverCompileState * state = driver_compile_state_alloc_c();
  (void)(({ int32_t __tmp = 0; if (state == ((struct driver_DriverCompileState *)(0))) {   return one;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_compile_parse_argv(argc, argv, state) != 0) {   (void)(driver_compile_state_free_c(state));
  return one;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->print_target_cpu != 0) {   int32_t rcpu = driver_print_target_cpu_features_c((state)->target_cpu_features);
  (void)(driver_compile_state_free_c(state));
  return rcpu;
 } else (__tmp = 0) ; __tmp; }));
  int32_t r = driver_run_compiler_full_sx_post_parse(state, argc, argv);
  (void)(driver_compile_state_free_c(state));
  return r;
}
