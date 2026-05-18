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
extern int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena * a, int32_t expr_ref);
int ast_ref_is_null(int32_t ref);
int32_t ast_ast_placeholder();
void ast_ast_arena_init(struct ast_ASTArena * arena);
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena);
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena);
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
void ast_expr_init_match_enum(struct ast_Expr * e);
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
int ast_ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena);
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);
void ast_ast_arena_func_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
int ast_ref_is_null(int32_t ref) {
  return ref == 0;
}
int32_t ast_ast_placeholder() {
  return 0;
}
void ast_ast_arena_init(struct ast_ASTArena * arena) {
  (void)(((arena)->num_types = 0));
  (void)(((arena)->num_exprs = 0));
  (void)(((arena)->num_blocks = 0));
  (void)(((arena)->num_funcs = 0));
}
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena) {
  (void)(({ int32_t __tmp = 0; if ((arena)->num_types >= 512) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((arena)->num_types = (arena)->num_types + 1));
  return (arena)->num_types;
}
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena) {
  (void)(({ int32_t __tmp = 0; if ((arena)->num_exprs >= 8192) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((arena)->num_exprs = (arena)->num_exprs + 1));
  return (arena)->num_exprs;
}
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena) {
  (void)(({ int32_t __tmp = 0; if ((arena)->num_blocks >= 512) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((arena)->num_blocks = (arena)->num_blocks + 1));
  return (arena)->num_blocks;
}
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref) {
  (void)(({ struct ast_Type __tmp = (struct ast_Type){0}; if (ref <= 0) {   uint8_t empty_name[64] = { 0 };
  return ({ struct ast_Type _t = { 0 }; _t.kind = ((enum ast_TypeKind)(0)); _t.name_len = 0; _t.elem_type_ref = 0; _t.array_size = 0; memcpy(_t.name, empty_name, sizeof(_t.name)); _t; });
 } else (__tmp = (struct ast_Type){0}) ; __tmp; }));
  int32_t idx = ref - 1;
  return (idx < 0 || (idx) >= 512 ? (shulang_panic_(1, 0), ((arena)->types)[0]) : ((arena)->types)[idx]);
}
void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t) {
  int32_t idx = ref - 1;
  (void)(((idx < 0 || (idx) >= 512 ? (shulang_panic_(1, 0), 0) : (((arena)->types)[idx] = t, 0))));
}
void ast_expr_init_match_enum(struct ast_Expr * e) {
  int32_t i = 0;
  while (i < 16) {
    (void)(((i < 0 || (i) >= 16 ? (shulang_panic_(1, 0), 0) : (((e)->match_arm_is_wildcard)[i] = 0, 0))));
    (void)(((i < 0 || (i) >= 16 ? (shulang_panic_(1, 0), 0) : (((e)->match_arm_lit_val)[i] = 0, 0))));
    (void)(((i < 0 || (i) >= 16 ? (shulang_panic_(1, 0), 0) : (((e)->match_arm_is_enum_variant)[i] = 0, 0))));
    (void)(((i < 0 || (i) >= 16 ? (shulang_panic_(1, 0), 0) : (((e)->match_arm_variant_index)[i] = 0, 0))));
    (void)((i = i + 1));
  }
  (void)(((e)->enum_variant_tag = 0));
}
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref) {
  int32_t idx = ref - 1;
  return (idx < 0 || (idx) >= 8192 ? (shulang_panic_(1, 0), ((arena)->exprs)[0]) : ((arena)->exprs)[idx]);
}
void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e) {
  int32_t idx = ref - 1;
  (void)(((idx < 0 || (idx) >= 8192 ? (shulang_panic_(1, 0), 0) : (((arena)->exprs)[idx] = e, 0))));
}
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref) {
  int32_t idx = ref - 1;
  return (idx < 0 || (idx) >= 512 ? (shulang_panic_(1, 0), ((arena)->blocks)[0]) : ((arena)->blocks)[idx]);
}
int ast_ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len) {
  (void)(({ int __tmp = 0; if (a_len != b_len || a_len <= 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t j = 0;
  while (j < a_len) {
    (void)(({ int __tmp = 0; if ((a_nm)[j] != (b_nm)[j]) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  return 1;
}
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref) {
  (void)(({ int32_t __tmp = 0; if (body_ref <= 0 || body_ref > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, body_ref);
  return (blk).final_expr_ref;
}
int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref) {
  return implicit_tail_expr_disallowed_by_glue(a, expr_ref);
}
int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nc = ast_ast_arena_block_get(a, br);
  return (blk_nc).num_consts;
}
int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nl = ast_ast_arena_block_get(a, br);
  return (blk_nl).num_lets;
}
int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nlp = ast_ast_arena_block_get(a, br);
  return (blk_nlp).num_loops;
}
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nfp = ast_ast_arena_block_get(a, br);
  return (blk_nfp).num_for_loops;
}
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nif = ast_ast_arena_block_get(a, br);
  return (blk_nif).num_if_stmts;
}
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nes = ast_ast_arena_block_get(a, br);
  return (blk_nes).num_expr_stmts;
}
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk_nso = ast_ast_arena_block_get(a, br);
  return (blk_nso).num_stmt_order;
}
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si) {
  (void)(({ uint8_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || si < 0) {   return ((uint8_t)(0));
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ uint8_t __tmp = 0; if (si >= (blk).num_stmt_order || si >= 96) {   return ((uint8_t)(0));
 } else (__tmp = 0) ; __tmp; }));
  return ((si < 0 || (si) >= 96 ? (shulang_panic_(1, 0), ((blk).stmt_order)[0]) : ((blk).stmt_order)[si])).kind;
}
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || si < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (si >= (blk).num_stmt_order || si >= 96) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((si < 0 || (si) >= 96 ? (shulang_panic_(1, 0), ((blk).stmt_order)[0]) : ((blk).stmt_order)[si])).idx;
}
int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || ci < 0 || ci >= 256) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (ci >= (blk).num_consts) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((ci < 0 || (ci) >= 256 ? (shulang_panic_(1, 0), ((blk).const_decls)[0]) : ((blk).const_decls)[ci])).init_ref;
}
int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || ci < 0 || ci >= 256) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (ci >= (blk).num_consts) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((ci < 0 || (ci) >= 256 ? (shulang_panic_(1, 0), ((blk).const_decls)[0]) : ((blk).const_decls)[ci])).type_ref;
}
int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || li < 0 || li >= 256) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (li >= (blk).num_lets) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((li < 0 || (li) >= 256 ? (shulang_panic_(1, 0), ((blk).let_decls)[0]) : ((blk).let_decls)[li])).init_ref;
}
int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || li < 0 || li >= 256) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (li >= (blk).num_lets) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((li < 0 || (li) >= 256 ? (shulang_panic_(1, 0), ((blk).let_decls)[0]) : ((blk).let_decls)[li])).type_ref;
}
int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || ei < 0 || ei >= 32) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (ei >= (blk).num_expr_stmts) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return (ei < 0 || (ei) >= 32 ? (shulang_panic_(1, 0), ((blk).expr_stmt_refs)[0]) : ((blk).expr_stmt_refs)[ei]);
}
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || wi < 0 || wi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (wi >= (blk).num_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((wi < 0 || (wi) >= 8 ? (shulang_panic_(1, 0), ((blk).loops)[0]) : ((blk).loops)[wi])).cond_ref;
}
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || wi < 0 || wi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (wi >= (blk).num_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((wi < 0 || (wi) >= 8 ? (shulang_panic_(1, 0), ((blk).loops)[0]) : ((blk).loops)[wi])).body_ref;
}
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || fi < 0 || fi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (fi >= (blk).num_for_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((blk).for_loops)[0]) : ((blk).for_loops)[fi])).init_ref;
}
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || fi < 0 || fi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (fi >= (blk).num_for_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((blk).for_loops)[0]) : ((blk).for_loops)[fi])).cond_ref;
}
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || fi < 0 || fi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (fi >= (blk).num_for_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((blk).for_loops)[0]) : ((blk).for_loops)[fi])).step_ref;
}
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || fi < 0 || fi >= 8) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (fi >= (blk).num_for_loops) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((fi < 0 || (fi) >= 8 ? (shulang_panic_(1, 0), ((blk).for_loops)[0]) : ((blk).for_loops)[fi])).body_ref;
}
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || ii < 0 || ii >= 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (ii >= (blk).num_if_stmts) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((ii < 0 || (ii) >= 16 ? (shulang_panic_(1, 0), ((blk).if_stmts)[0]) : ((blk).if_stmts)[ii])).cond_ref;
}
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii) {
  (void)(({ int32_t __tmp = 0; if (br <= 0 || br > (a)->num_blocks || ii < 0 || ii >= 16) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, br);
  (void)(({ int32_t __tmp = 0; if (ii >= (blk).num_if_stmts) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return ((ii < 0 || (ii) >= 16 ? (shulang_panic_(1, 0), ((blk).if_stmts)[0]) : ((blk).if_stmts)[ii])).then_body_ref;
}
int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen) {
  (void)(({ int32_t __tmp = 0; if (block_ref <= 0 || block_ref > (a)->num_blocks) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block blk = ast_ast_arena_block_get(a, block_ref);
  int32_t i = 0;
  while (i < (blk).num_consts && i < 256) {
    struct ast_ConstDecl cd = (i < 0 || (i) >= 256 ? (shulang_panic_(1, 0), ((blk).const_decls)[0]) : ((blk).const_decls)[i]);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((cd).type_ref)) && ast_ast_name_bytes_equal((&(((cd).name)[0])), (cd).name_len, vname, vlen)) {   return (cd).type_ref;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)((i = 0));
  while (i < (blk).num_lets && i < 256) {
    struct ast_LetDecl ld = (i < 0 || (i) >= 256 ? (shulang_panic_(1, 0), ((blk).let_decls)[0]) : ((blk).let_decls)[i]);
    (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null((ld).type_ref)) && ast_ast_name_bytes_equal((&(((ld).name)[0])), (ld).name_len, vname, vlen)) {   return (ld).type_ref;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b) {
  int32_t idx = ref - 1;
  (void)(((idx < 0 || (idx) >= 512 ? (shulang_panic_(1, 0), 0) : (((arena)->blocks)[idx] = b, 0))));
}
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena) {
  (void)(({ int32_t __tmp = 0; if ((arena)->num_funcs >= 256) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((arena)->num_funcs = (arena)->num_funcs + 1));
  return (arena)->num_funcs;
}
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref) {
  int32_t idx = ref - 1;
  return (idx < 0 || (idx) >= 256 ? (shulang_panic_(1, 0), ((arena)->funcs)[0]) : ((arena)->funcs)[idx]);
}
void ast_ast_arena_func_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f) {
  int32_t idx = ref - 1;
  (void)(((idx < 0 || (idx) >= 256 ? (shulang_panic_(1, 0), 0) : (((arena)->funcs)[idx] = f, 0))));
}
