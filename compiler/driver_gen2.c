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
struct codegen_CodegenOutBuf { uint8_t data[1048576]; int32_t len; };
struct preprocess_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_io_driver_Buffer { uint8_t * ptr; size_t len; size_t handle; };
struct std_io_driver_Completion { int32_t tag; };
struct std_io_driver_AsyncContext { uint32_t flags; };
struct shulang_slice_uint8_t { uint8_t *data; size_t length; };
struct std_io_ReadOnlySlice { struct shulang_slice_uint8_t data; };
struct std_io_WriteOnlySlice { struct shulang_slice_uint8_t data; };
struct std_fs_FsIovecBuf { uint8_t * ptr; size_t len; size_t handle; };
extern ptrdiff_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count);
extern int32_t preprocess_preprocess_su_buf(uint8_t source_buf[262144], ptrdiff_t source_len, uint8_t out_buf[262144], int32_t out_cap);
extern int32_t std_fs_fs_close(int32_t fd);
extern ptrdiff_t std_fs_fs_write(int32_t fd, uint8_t * buf, size_t count);
struct main_DriverSuEmitState { uint8_t path_buf[512]; int32_t path_len; int32_t n_lib_roots; uint8_t lib_root_bufs[16][256]; int32_t lib_root_lens[16]; int32_t emit_extern_imports; int32_t use_asm_backend; int32_t target_arch; uint8_t out_path_buf[512]; int32_t out_path_len; };
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * argv, int32_t i, uint8_t * buf, int32_t max);
extern int32_t driver_fs_open_read_path(uint8_t * path, int32_t path_len);
extern uint8_t * driver_arena_buf();
extern uint8_t * driver_module_buf();
extern int32_t driver_fs_open_write(uint8_t * path, int32_t path_len);
extern void driver_pipeline_fail_code(int32_t rc, uint8_t * path);
extern void driver_print_su_smoke_summary(uint8_t * module, size_t codegen_len);
extern int32_t driver_run_su_emit_c_set_path(uint8_t * path, int32_t path_len);
extern int32_t driver_run_su_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t driver_run_su_emit_c_set_n_lib_roots(int32_t n);
extern int32_t driver_run_su_emit_c_set_emit_extern(int32_t v);
extern int32_t driver_run_su_emit_c();
extern int32_t pipeline_run_su_pipeline_impl(uint8_t * module, uint8_t * arena, uint8_t * source_data, size_t source_len, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx);
extern int32_t driver_want_asm_emit_to_file(int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_full(int32_t argc, uint8_t * argv);
extern int32_t typeck_lsp_main();
int32_t main_run_compiler_su_path(int32_t argc, uint8_t * argv);
int32_t main_run_compiler_c_impl(int32_t argc, uint8_t * argv);
int32_t main_run_compiler_c(int32_t argc, uint8_t * argv);
int32_t main_main_run_compiler_c(int32_t argc, uint8_t * argv);
int32_t main_eq_minus_L(uint8_t * buf, int32_t len);
int32_t main_eq_minus_su(uint8_t * buf, int32_t len);
int32_t main_eq_minus_E(uint8_t * buf, int32_t len);
int32_t main_eq_minus_E_extern(uint8_t * buf, int32_t len);
int32_t main_eq_minus_backend(uint8_t * buf, int32_t len);
int32_t main_eq_asm(uint8_t * buf, int32_t len);
int32_t main_eq_minus_lsp(uint8_t * buf, int32_t len);
int32_t main_eq_minus_target(uint8_t * buf, int32_t len);
int32_t main_target_contains_arm(uint8_t * buf, int32_t len);
int32_t main_target_contains_riscv(uint8_t * buf, int32_t len);
int32_t main_driver_argv_parse_su_path(int32_t argc, uint8_t * argv, struct main_DriverSuEmitState * state);
int32_t main_driver_argv_parse_su(int32_t argc, uint8_t * argv, struct main_DriverSuEmitState * state);
int32_t main_driver_run_su_emit_su(struct main_DriverSuEmitState * state);
int32_t main_run_compiler_su_path_impl(int32_t argc, uint8_t * argv);
int32_t main_entry(int32_t argc, uint8_t * argv);
int32_t main_run_compiler_su_path(int32_t argc, uint8_t * argv) {
  return main_run_compiler_su_path_impl(argc, argv);
}
int32_t main_run_compiler_c_impl(int32_t argc, uint8_t * argv) {
  return driver_run_compiler_full(argc, argv);
}
int32_t main_run_compiler_c(int32_t argc, uint8_t * argv) {
  return main_run_compiler_c_impl(argc, argv);
}
int32_t main_main_run_compiler_c(int32_t argc, uint8_t * argv) {
  return main_run_compiler_c(argc, argv);
}
int32_t main_eq_minus_L(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 2) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 76) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_su(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 3) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 115 && (buf)[2] == 117) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_E(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 2) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 69) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_E_extern(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 9) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 69 && (buf)[2] == 45 && (buf)[3] == 101 && (buf)[4] == 120 && (buf)[5] == 116 && (buf)[6] == 101 && (buf)[7] == 114 && (buf)[8] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_backend(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 98 && (buf)[2] == 97 && (buf)[3] == 99 && (buf)[4] == 107 && (buf)[5] == 101 && (buf)[6] == 110 && (buf)[7] == 100) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_asm(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 3) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 97 && (buf)[1] == 115 && (buf)[2] == 109) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_lsp(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 5) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 45 && (buf)[2] == 108 && (buf)[3] == 115 && (buf)[4] == 112) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_eq_minus_target(uint8_t * buf, int32_t len) {
  (void)(({ int32_t __tmp = 0; if (len < 7) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((buf)[0] == 45 && (buf)[1] == 116 && (buf)[2] == 97 && (buf)[3] == 114 && (buf)[4] == 103 && (buf)[5] == 101 && (buf)[6] == 116) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_target_contains_arm(uint8_t * buf, int32_t len) {
  int32_t start = 0;
  while (start + 7 <= len) {
    (void)(({ int32_t __tmp = 0; if ((buf)[start] == 97 && (buf)[start + 1] == 97 && (buf)[start + 2] == 114 && (buf)[start + 3] == 99 && (buf)[start + 4] == 104 && (buf)[start + 5] == 54 && (buf)[start + 6] == 52) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((start = start + 1));
  }
  (void)((start = 0));
  while (start + 5 <= len) {
    (void)(({ int32_t __tmp = 0; if ((buf)[start] == 97 && (buf)[start + 1] == 114 && (buf)[start + 2] == 109 && (buf)[start + 3] == 54 && (buf)[start + 4] == 52) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((start = start + 1));
  }
  return 0;
}
int32_t main_target_contains_riscv(uint8_t * buf, int32_t len) {
  int32_t start = 0;
  while (start + 7 <= len) {
    (void)(({ int32_t __tmp = 0; if ((buf)[start] == 114 && (buf)[start + 1] == 105 && (buf)[start + 2] == 115 && (buf)[start + 3] == 99 && (buf)[start + 4] == 118 && (buf)[start + 5] == 54 && (buf)[start + 6] == 52) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((start = start + 1));
  }
  return 0;
}
int32_t main_driver_argv_parse_su_path(int32_t argc, uint8_t * argv, struct main_DriverSuEmitState * state) {
  (void)(((state)->path_len = 0));
  (void)(((state)->n_lib_roots = 0));
  (void)(((state)->emit_extern_imports = 0));
  (void)(((state)->use_asm_backend = 0));
  (void)(((state)->target_arch = 0));
  (void)(((state)->out_path_len = 0));
  (void)(({ int32_t __tmp = 0; if (argc < 2) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t arg_buf[512] = { 0 };
  int32_t i = 1;
  int32_t has_o = 0;
  while (i < argc) {
    int32_t len = driver_get_argv_i(argc, argv, i, arg_buf, 512);
    (void)(({ int32_t __tmp = 0; if (len < 0) {   (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {   int32_t tlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
  (void)(({ int32_t __tmp = 0; if (tlen >= 0 && main_target_contains_arm(arg_buf, tlen) != 0) {   (void)(((state)->target_arch = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (tlen >= 0 && main_target_contains_riscv(arg_buf, tlen) != 0) {   (void)(((state)->target_arch = 2));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_L(arg_buf, len) != 0) {   (void)(({ int32_t __tmp = 0; if (i + 1 >= argc) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->n_lib_roots < 16) {   int32_t llen = driver_get_argv_i(argc, argv, i + 1, ((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_bufs)[0]) : ((state)->lib_root_bufs)[(state)->n_lib_roots]), 256);
  __tmp = ({ int32_t __tmp = 0; if (llen >= 0) {   (void)((((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), 0) : (((state)->lib_root_lens)[(state)->n_lib_roots] = llen, 0))));
  (void)(((state)->n_lib_roots = (state)->n_lib_roots + 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {   int32_t vlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
  (void)(({ int32_t __tmp = 0; if (vlen >= 0 && main_eq_asm(arg_buf, vlen) != 0) {   (void)(((state)->use_asm_backend = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (len == 2 && (arg_buf)[0] == 45 && (1 < 0 || (1) >= 512 ? (shulang_panic_(1, 0), (arg_buf)[0]) : (arg_buf)[1]) == 111) {   (void)(({ int32_t __tmp = 0; if (i + 1 < argc) {   int32_t olen = driver_get_argv_i(argc, argv, i + 1, (state)->out_path_buf, 512);
  (void)(({ int32_t __tmp = 0; if (olen >= 0) {   (void)(((state)->out_path_len = olen));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
 } else {   (void)((has_o = 1));
  (void)((i = i + 1));
 } ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (len == 2 && (arg_buf)[0] == 45 && (1 < 0 || (1) >= 512 ? (shulang_panic_(1, 0), (arg_buf)[0]) : (arg_buf)[1]) == 79) {   (void)((i = i + 1));
  (void)(({ int32_t __tmp = 0; if (i < argc) {   (void)((i = i + 1));
 } else (__tmp = 0) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_su(arg_buf, len) != 0) {   (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((state)->path_len == 0 && len > 0) {   int32_t k = 0;
  while (k < len && k < 512) {
    (void)(((k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), 0) : (((state)->path_buf)[k] = (k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), (arg_buf)[0]) : (arg_buf)[k]), 0))));
    (void)((k = k + 1));
  }
  (void)(((state)->path_len = len));
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)(({ int32_t __tmp = 0; if (has_o != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->path_len == 0) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->n_lib_roots == 0) {   (void)(((((state)->lib_root_bufs)[0])[0] = 46));
  (void)((((state)->lib_root_lens)[0] = 1));
  (void)(((state)->n_lib_roots = 1));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t main_driver_argv_parse_su(int32_t argc, uint8_t * argv, struct main_DriverSuEmitState * state) {
  (void)(((state)->path_len = 0));
  (void)(((state)->n_lib_roots = 0));
  (void)(((state)->emit_extern_imports = 0));
  (void)(((state)->use_asm_backend = 0));
  (void)(((state)->target_arch = 0));
  (void)(((state)->out_path_len = 0));
  (void)(({ int32_t __tmp = 0; if (argc < 4) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t arg_buf[512] = { 0 };
  int32_t i = 1;
  while (i < argc) {
    int32_t len = driver_get_argv_i(argc, argv, i, arg_buf, 512);
    (void)(({ int32_t __tmp = 0; if (len < 0) {   (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_L(arg_buf, len) != 0 && i + 1 < argc && (state)->n_lib_roots < 16) {   int32_t llen = driver_get_argv_i(argc, argv, i + 1, ((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_bufs)[0]) : ((state)->lib_root_bufs)[(state)->n_lib_roots]), 256);
  (void)(({ int32_t __tmp = 0; if (llen >= 0) {   (void)((((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), 0) : (((state)->lib_root_lens)[(state)->n_lib_roots] = llen, 0))));
  (void)(((state)->n_lib_roots = (state)->n_lib_roots + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {   int32_t vlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
  (void)(({ int32_t __tmp = 0; if (vlen >= 0 && main_eq_asm(arg_buf, vlen) != 0) {   (void)(((state)->use_asm_backend = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {   int32_t tlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
  (void)(({ int32_t __tmp = 0; if (tlen >= 0 && main_target_contains_arm(arg_buf, tlen) != 0) {   (void)(((state)->target_arch = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (tlen >= 0 && main_target_contains_riscv(arg_buf, tlen) != 0) {   (void)(((state)->target_arch = 2));
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (main_eq_minus_su(arg_buf, len) != 0 && i + 2 < argc) {   int32_t elen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
  (void)(({ int32_t __tmp = 0; if (main_eq_minus_E(arg_buf, elen) != 0) {   int32_t pi = i + 2;
  while (pi < argc) {
    int32_t plen_temp = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
    (void)(({ int32_t __tmp = 0; if (plen_temp > 0 && main_eq_minus_L(arg_buf, plen_temp) != 0 && pi + 1 < argc) {   (void)(({ int32_t __tmp = 0; if ((state)->n_lib_roots < 16) {   int32_t llen = driver_get_argv_i(argc, argv, pi + 1, ((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_bufs)[0]) : ((state)->lib_root_bufs)[(state)->n_lib_roots]), 256);
  __tmp = ({ int32_t __tmp = 0; if (llen >= 0) {   (void)((((state)->n_lib_roots < 0 || ((state)->n_lib_roots) >= 16 ? (shulang_panic_(1, 0), 0) : (((state)->lib_root_lens)[(state)->n_lib_roots] = llen, 0))));
  (void)(((state)->n_lib_roots = (state)->n_lib_roots + 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)((pi = pi + 2));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    break;
  }
  (void)(({ int32_t __tmp = 0; if (pi < argc) {   int32_t opt_len = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
  __tmp = ({ int32_t __tmp = 0; if (opt_len >= 0 && main_eq_minus_E_extern(arg_buf, opt_len) != 0) {   (void)(((state)->emit_extern_imports = 1));
  (void)((pi = pi + 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (pi < argc) {   int32_t plen = driver_get_argv_i(argc, argv, pi, (state)->path_buf, 512);
  __tmp = ({ int32_t __tmp = 0; if (plen >= 0) {   (void)(((state)->path_len = plen));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)((i = i + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t main_driver_run_su_emit_su(struct main_DriverSuEmitState * state) {
  int32_t fd = driver_fs_open_read_path((state)->path_buf, (state)->path_len);
  (void)(({ int32_t __tmp = 0; if (fd < 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t loaded_buf[262144] = { 0 };
  size_t cap = 262144;
  ptrdiff_t n = std_fs_fs_read(fd, loaded_buf, cap);
  (void)(({ int32_t __tmp = 0; if (fd >= 0) {   (void)(std_fs_fs_close(fd));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (n < 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t preprocess_buf[262144] = { 0 };
  int32_t out_len = preprocess_preprocess_su_buf(loaded_buf, n, preprocess_buf, 262144);
  (void)(({ int32_t __tmp = 0; if (out_len < 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t * arena_buf = driver_arena_buf();
  uint8_t * module_buf = driver_module_buf();
  struct ast_PipelineDepCtx ctx = ({ struct ast_PipelineDepCtx _t = { 0 }; _t.ndep = 0; _t.entry_dir_len = 0; _t.num_lib_roots = 0; _t.loaded_len = 0; _t.preprocess_len = 0; _t.use_asm_backend = (state)->use_asm_backend; _t.target_arch = (state)->target_arch; _t.use_macho_o = 0; _t.use_coff_o = 0; _t.current_block_ref = 0; _t.current_func_index = (-1); _t.skip_codegen_dep_0 = 0; _t.entry_already_parsed = 0; _t.current_func_single_empty_param_index = (-1); _t.current_func_empty_param_count = 0; _t.current_emit_empty_var_next_index = 0; _t.emit_expr_as_callee = 0; _t.current_codegen_module = ((struct ast_Module *)(0)); _t.current_codegen_arena = ((struct ast_ASTArena *)(0)); _t; });
  int32_t last_slash = (-1);
  int32_t k = 0;
  while (k < (state)->path_len && k < 512) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), ((state)->path_buf)[0]) : ((state)->path_buf)[k]) == 47) {   (void)((last_slash = k));
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  (void)(({ int32_t __tmp = 0; if (last_slash >= 0) {   (void)((k = 0));
  while (k < last_slash && k < 511) {
    (void)(((k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[k] = (k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), ((state)->path_buf)[0]) : ((state)->path_buf)[k]), 0))));
    (void)((k = k + 1));
  }
  (void)(((k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[k] = 0, 0))));
  (void)(((ctx).entry_dir_len = k));
 } else {   (void)((((ctx).entry_dir_buf)[0] = 46));
  (void)(((1 < 0 || (1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[1] = 0, 0))));
  (void)(((ctx).entry_dir_len = 1));
 } ; __tmp; }));
  (void)(((ctx).num_lib_roots = (state)->n_lib_roots));
  (void)((k = 0));
  while (k < (state)->n_lib_roots && k < 16) {
    int32_t r = 0;
    while (r < (k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_lens)[0]) : ((state)->lib_root_lens)[k]) && r < 256) {
      (void)(((r < 0 || (r) >= 256 ? (shulang_panic_(1, 0), 0) : (((k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((ctx).lib_root_bufs)[0]) : ((ctx).lib_root_bufs)[k]))[r] = (r < 0 || (r) >= 256 ? (shulang_panic_(1, 0), ((k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_bufs)[0]) : ((state)->lib_root_bufs)[k]))[0]) : ((k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_bufs)[0]) : ((state)->lib_root_bufs)[k]))[r]), 0))));
      (void)((r = r + 1));
    }
    (void)(((k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), 0) : (((ctx).lib_root_lens)[k] = (k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state)->lib_root_lens)[0]) : ((state)->lib_root_lens)[k]), 0))));
    (void)((k = k + 1));
  }
  struct codegen_CodegenOutBuf out = ({ struct codegen_CodegenOutBuf _t = { 0 }; _t.len = 0; _t; });
  size_t source_len = out_len;
  int32_t rc = pipeline_run_su_pipeline_impl(module_buf, arena_buf, preprocess_buf, source_len, (&(out)), (&(ctx)));
  (void)(({ int32_t __tmp = 0; if (rc != 0) {   (void)(driver_pipeline_fail_code(rc, (&(((ctx).path_buf)[0]))));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  size_t len = (out).len;
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len == 0) {   (void)(driver_print_su_smoke_summary(module_buf, len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len > 0) {   int32_t fd = driver_fs_open_write((state)->out_path_buf, (state)->out_path_len);
  (void)(({ int32_t __tmp = 0; if (fd < 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (len > 262144) {   ptrdiff_t written = std_fs_fs_write(fd, (out).data, 262144);
  (void)(std_fs_fs_close(fd));
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((size_t)(written)) != 262144) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else {   ptrdiff_t written = std_fs_fs_write(fd, (out).data, len);
  (void)(std_fs_fs_close(fd));
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((size_t)(written)) != len) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (len > 262144) {   ptrdiff_t written = std_fs_fs_write(1, (out).data, 262144);
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((size_t)(written)) != 262144) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else {   ptrdiff_t written = std_fs_fs_write(1, (out).data, len);
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((size_t)(written)) != len) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } ; __tmp; }));
  return 0;
}
int32_t main_run_compiler_su_path_impl(int32_t argc, uint8_t * argv) {
  struct main_DriverSuEmitState state = ({ struct main_DriverSuEmitState _t = { 0 }; _t.path_len = 0; _t.n_lib_roots = 0; _t.emit_extern_imports = 0; _t.use_asm_backend = 0; _t.target_arch = 0; _t.out_path_len = 0; _t; });
  int32_t r = main_driver_argv_parse_su_path(argc, argv, (&(state)));
  (void)(({ int32_t __tmp = 0; if (r == 1) {   return main_run_compiler_c_impl(argc, argv);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (r == 2) {   return main_run_compiler_c_impl(argc, argv);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_want_asm_emit_to_file(argc, argv) != 0) {   return main_run_compiler_c_impl(argc, argv);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state).out_path_len > 0) {   return main_run_compiler_c_impl(argc, argv);
 } else (__tmp = 0) ; __tmp; }));
  return main_driver_run_su_emit_su((&(state)));
}
int32_t main_entry(int32_t argc, uint8_t * argv) {
  uint8_t arg_buf[64] = { 0 };
  int32_t i = 1;
  while (i < argc) {
    int32_t len = driver_get_argv_i(argc, argv, i, arg_buf, 64);
    (void)(({ int32_t __tmp = 0; if (len >= 0 && main_eq_minus_lsp(arg_buf, len) != 0) {   return typeck_lsp_main();
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  struct main_DriverSuEmitState state = ({ struct main_DriverSuEmitState _t = { 0 }; _t.path_len = 0; _t.n_lib_roots = 0; _t.emit_extern_imports = 0; _t.use_asm_backend = 0; _t.target_arch = 0; _t.out_path_len = 0; _t; });
  (void)(({ int32_t __tmp = 0; if (main_driver_argv_parse_su(argc, argv, (&(state))) != 0) {   (void)(driver_run_su_emit_c_set_emit_extern((state).emit_extern_imports));
  (void)(driver_run_su_emit_c_set_path((state).path_buf, (state).path_len));
  int32_t k = 0;
  while (k < (state).n_lib_roots && k < 16) {
    (void)(driver_run_su_emit_c_set_lib(k, (k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state).lib_root_bufs)[0]) : ((state).lib_root_bufs)[k]), (k < 0 || (k) >= 16 ? (shulang_panic_(1, 0), ((state).lib_root_lens)[0]) : ((state).lib_root_lens)[k])));
    (void)((k = k + 1));
  }
  (void)(driver_run_su_emit_c_set_n_lib_roots((state).n_lib_roots));
  return driver_run_su_emit_c();
 } else (__tmp = 0) ; __tmp; }));
  return main_run_compiler_su_path_impl(argc, argv);
}
