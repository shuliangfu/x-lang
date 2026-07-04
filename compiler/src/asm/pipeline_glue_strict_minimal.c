/**
 * pipeline_glue_strict_minimal.c — B-strict 链最小 glue（不含 ast_pool / pipeline_glue_types.inc）
 *
 * strict_core partial 已含 pipeline_x 几乎全部符号；本 TU 仅补 runtime 入口与裸名 parse_into_init。
 */
#include <stdint.h>
#include <stddef.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diag.h"

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx {
  int32_t ndep;
  uint8_t entry_dir_buf[512];
  int32_t entry_dir_len;
  int32_t num_lib_roots;
  uint8_t path_buf[512];
  uint8_t loaded_buf[4194304];
  ptrdiff_t loaded_len;
  uint8_t preprocess_buf[4194304];
  int32_t preprocess_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  int32_t target_cpu_features;
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  struct ast_Module *current_codegen_module;
  struct ast_ASTArena *current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[64];
};
struct ast_ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};
struct ast_Module {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t pending_repr_compatible_struct;
  int32_t num_module_enums;
};
struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};
struct shux_slice_uint8_t {
  uint8_t *data;
  int32_t len;
};
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

__attribute__((weak)) void parser_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t *name,
                                                                int32_t name_len, int32_t num_generic_params,
                                                                int32_t is_main) {
  extern void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name,
                                                   int32_t name_len, int32_t num_generic_params, int32_t is_main);
  driver_diagnostic_parse_func_generic(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
}

__attribute__((weak)) void parser_diagnostic_parse_commit_pre(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len,
                                                              int32_t block_ref, uint8_t *pool, int32_t final_expr_ref) {
  extern int32_t pipeline_onefunc_num_consts(uint8_t *out);
  extern int32_t pipeline_onefunc_num_lets(uint8_t *out);
  extern int32_t pipeline_onefunc_num_if_stmts(uint8_t *out);
  extern int32_t pipeline_onefunc_num_regions(uint8_t *out);
  extern int32_t pipeline_onefunc_num_src_stmt_order(uint8_t *out);
  extern void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name,
                                                   int32_t name_len, int32_t phase, int32_t block_ref,
                                                   int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs,
                                                   int32_t pool_num_regions, int32_t pool_num_stmt_order,
                                                   int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs,
                                                   int32_t block_num_regions, int32_t block_num_stmt_order,
                                                   int32_t final_expr_ref);
  (void)arena;
  driver_diagnostic_parse_commit_shape(0, 0, name, name_len, 0, block_ref, pool ? pipeline_onefunc_num_consts(pool) : 0,
                                       pool ? pipeline_onefunc_num_lets(pool) : 0,
                                       pool ? pipeline_onefunc_num_if_stmts(pool) : 0,
                                       pool ? pipeline_onefunc_num_regions(pool) : 0,
                                       pool ? pipeline_onefunc_num_src_stmt_order(pool) : 0,
                                       0, 0, 0, 0, 0, final_expr_ref);
}

__attribute__((weak)) void parser_diagnostic_parse_commit_post(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len,
                                                               int32_t block_ref, uint8_t *pool) {
  extern int32_t pipeline_onefunc_num_consts(uint8_t *out);
  extern int32_t pipeline_onefunc_num_lets(uint8_t *out);
  extern int32_t pipeline_onefunc_num_if_stmts(uint8_t *out);
  extern int32_t pipeline_onefunc_num_regions(uint8_t *out);
  extern int32_t pipeline_onefunc_num_src_stmt_order(uint8_t *out);
  extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *arena, int32_t block_ref);
  extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *arena, int32_t block_ref);
  extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *arena, int32_t block_ref);
  extern int32_t ast_ast_block_num_regions(struct ast_ASTArena *arena, int32_t block_ref);
  extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *arena, int32_t block_ref);
  extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *arena, int32_t block_ref);
  extern void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name,
                                                   int32_t name_len, int32_t phase, int32_t block_ref,
                                                   int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs,
                                                   int32_t pool_num_regions, int32_t pool_num_stmt_order,
                                                   int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs,
                                                   int32_t block_num_regions, int32_t block_num_stmt_order,
                                                   int32_t final_expr_ref);
  driver_diagnostic_parse_commit_shape(0, 0, name, name_len, 1, block_ref, pool ? pipeline_onefunc_num_consts(pool) : 0,
                                       pool ? pipeline_onefunc_num_lets(pool) : 0,
                                       pool ? pipeline_onefunc_num_if_stmts(pool) : 0,
                                       pool ? pipeline_onefunc_num_regions(pool) : 0,
                                       pool ? pipeline_onefunc_num_src_stmt_order(pool) : 0,
                                       arena ? ast_ast_block_num_consts(arena, block_ref) : 0,
                                       arena ? ast_ast_block_num_lets(arena, block_ref) : 0,
                                       arena ? ast_ast_block_num_if_stmts(arena, block_ref) : 0,
                                       arena ? ast_ast_block_num_regions(arena, block_ref) : 0,
                                       arena ? ast_ast_block_num_stmt_order(arena, block_ref) : 0,
                                       arena ? ast_ast_block_final_expr_ref(arena, block_ref) : 0);
}

// #region debug-point A:try-propagate-state
static void debug_try_propagate_report_strict_minimal(struct ast_ASTArena *arena, int32_t expr_ref, int32_t func_ix,
                                                      int32_t return_type_ref, int32_t func_ret,
                                                      int32_t enclosing_return_type_ref, int32_t op_ty) {
  FILE *fp;
  char line[512];
  char url[256];
  char session[64];
  char cmd[2048];
  const char *enabled = getenv("SHUX_DEBUG_RESULT_TRY");
  (void)arena;
  if (!enabled || enabled[0] == '\0' || enabled[0] == '0')
    return;
  snprintf(url, sizeof(url), "%s", "http://127.0.0.1:7777/event");
  snprintf(session, sizeof(session), "%s", "result-try-typeck");
  fp = fopen(".dbg/result-try-typeck.env", "r");
  if (fp) {
    while (fgets(line, sizeof(line), fp)) {
      if (strncmp(line, "DEBUG_SERVER_URL=", 17) == 0) {
        snprintf(url, sizeof(url), "%s", line + 17);
      } else if (strncmp(line, "DEBUG_SESSION_ID=", 17) == 0) {
        snprintf(session, sizeof(session), "%s", line + 17);
      }
    }
    fclose(fp);
  }
  url[strcspn(url, "\r\n")] = '\0';
  session[strcspn(session, "\r\n")] = '\0';
  snprintf(cmd, sizeof(cmd),
           "/usr/bin/curl -s -X POST '%s' -H 'Content-Type: application/json' "
           "-d '{\"sessionId\":\"%s\",\"runId\":\"pre-fix\",\"hypothesisId\":\"A\","
           "\"location\":\"pipeline_glue_strict_minimal.c:try_propagate\","
           "\"msg\":\"[DEBUG] try_propagate_state\","
           "\"data\":{\"expr_ref\":%d,\"func_ix\":%d,\"return_type_ref\":%d,\"func_ret\":%d,"
           "\"enclosing_return_type_ref\":%d,\"op_ty\":%d}}' >/dev/null 2>&1",
           url, session, expr_ref, func_ix, return_type_ref, func_ret, enclosing_return_type_ref, op_ty);
  (void)system(cmd);
}
// #endregion

enum ast_TypeKind {
  ast_TypeKind_TYPE_I32,
  ast_TypeKind_TYPE_BOOL,
  ast_TypeKind_TYPE_U8,
  ast_TypeKind_TYPE_U32,
  ast_TypeKind_TYPE_U64,
  ast_TypeKind_TYPE_I64,
  ast_TypeKind_TYPE_USIZE,
  ast_TypeKind_TYPE_ISIZE,
  ast_TypeKind_TYPE_NAMED,
  ast_TypeKind_TYPE_PTR,
  ast_TypeKind_TYPE_ARRAY,
  ast_TypeKind_TYPE_SLICE,
  ast_TypeKind_TYPE_LINEAR,
  ast_TypeKind_TYPE_VECTOR,
  ast_TypeKind_TYPE_F32,
  ast_TypeKind_TYPE_F64,
  ast_TypeKind_TYPE_VOID,
};

enum ast_ExprKind {
  ast_ExprKind_EXPR_LIT,
  ast_ExprKind_EXPR_FLOAT_LIT,
  ast_ExprKind_EXPR_BOOL_LIT,
  ast_ExprKind_EXPR_VAR,
  ast_ExprKind_EXPR_ADD,
  ast_ExprKind_EXPR_SUB,
  ast_ExprKind_EXPR_MUL,
  ast_ExprKind_EXPR_DIV,
  ast_ExprKind_EXPR_MOD,
  ast_ExprKind_EXPR_SHL,
  ast_ExprKind_EXPR_SHR,
  ast_ExprKind_EXPR_BITAND,
  ast_ExprKind_EXPR_BITOR,
  ast_ExprKind_EXPR_BITXOR,
  ast_ExprKind_EXPR_EQ,
  ast_ExprKind_EXPR_NE,
  ast_ExprKind_EXPR_LT,
  ast_ExprKind_EXPR_LE,
  ast_ExprKind_EXPR_GT,
  ast_ExprKind_EXPR_GE,
  ast_ExprKind_EXPR_LOGAND,
  ast_ExprKind_EXPR_LOGOR,
  ast_ExprKind_EXPR_NEG,
  ast_ExprKind_EXPR_BITNOT,
  ast_ExprKind_EXPR_LOGNOT,
  ast_ExprKind_EXPR_IF,
  ast_ExprKind_EXPR_BLOCK,
  ast_ExprKind_EXPR_TERNARY,
  ast_ExprKind_EXPR_ASSIGN,
  ast_ExprKind_EXPR_ADD_ASSIGN,
  ast_ExprKind_EXPR_SUB_ASSIGN,
  ast_ExprKind_EXPR_MUL_ASSIGN,
  ast_ExprKind_EXPR_DIV_ASSIGN,
  ast_ExprKind_EXPR_MOD_ASSIGN,
  ast_ExprKind_EXPR_BITAND_ASSIGN,
  ast_ExprKind_EXPR_BITOR_ASSIGN,
  ast_ExprKind_EXPR_BITXOR_ASSIGN,
  ast_ExprKind_EXPR_SHL_ASSIGN,
  ast_ExprKind_EXPR_SHR_ASSIGN,
  ast_ExprKind_EXPR_BREAK,
  ast_ExprKind_EXPR_CONTINUE,
  ast_ExprKind_EXPR_RETURN,
  ast_ExprKind_EXPR_PANIC,
  ast_ExprKind_EXPR_MATCH,
  ast_ExprKind_EXPR_FIELD_ACCESS,
  ast_ExprKind_EXPR_STRUCT_LIT,
  ast_ExprKind_EXPR_ARRAY_LIT,
  ast_ExprKind_EXPR_INDEX,
  ast_ExprKind_EXPR_CALL,
  ast_ExprKind_EXPR_METHOD_CALL,
  ast_ExprKind_EXPR_ENUM_VARIANT,
  ast_ExprKind_EXPR_ADDR_OF,
};

#define ast_ref_is_null(ref) ((ref) == 0)
#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)

struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

extern int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t li, int32_t depth, int32_t check_pad,
                                                   int32_t *out_sz, int32_t *out_al);
extern int32_t typeck_x_type_size(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                   int32_t depth);
extern int32_t typeck_x_type_align(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                    int32_t depth);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t type_ref, uint8_t *out64);
extern int32_t pipeline_module_struct_layout_soa_at(struct ast_Module *module, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *module, int32_t li, int32_t j);
extern int32_t typeck_entry_module_find_struct_layout_index(struct ast_Module *mod, uint8_t *nm, int32_t nlen);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lval_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_set_field_access_enum_variant(struct ast_ASTArena *arena, int32_t expr_ref, int32_t tag);
extern void pipeline_expr_set_field_access_offset(struct ast_ASTArena *arena, int32_t expr_ref, int32_t offset);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *arena, int32_t kind_ord);
extern int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len);
extern int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena *arena, int32_t kind_ord, int32_t elem_ref,
                                                    int32_t array_size);
extern int32_t pipeline_type_find_or_alloc_slice(struct ast_ASTArena *arena, int32_t elem_ref, uint8_t *reg_label,
                                                 int32_t reg_label_len);
extern int32_t pipeline_type_region_label_len_at(struct ast_ASTArena *arena, int32_t ref);
extern int32_t pipeline_type_region_label_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                   int32_t vlen);
extern int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                      int32_t vlen);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx,
                                             uint8_t *dst);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx);
extern struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *module, int32_t func_index,
                                                            uint8_t *vname, int32_t vname_len);
extern int32_t pipeline_expr_line_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_col_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_dep_ctx_current_block_ref_at(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
extern void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module *module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *module, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *module, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
extern void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                                   uint8_t *dst);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
extern int32_t pipeline_module_import_kind_at(struct ast_Module *module, int32_t idx);
extern int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                          uint8_t *variant_name, int32_t variant_len);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
extern void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix, int32_t func_ix);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_get_dep_arena_slot(int32_t ix);
extern void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col);
extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len,
                                                        uint8_t *field_name, int32_t field_name_len);
extern int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                          struct ast_PipelineDepCtx *ctx, uint8_t *type_name,
                                                          int32_t type_name_len, uint8_t *field_name,
                                                          int32_t field_name_len);
extern int32_t typeck_check_expr_float_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_bool_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_break_continue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t expr_ref, int32_t return_type_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_enum_variant(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_if_ternary(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_return(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_panic(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_expr_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_type_set_region_label_at(struct ast_ASTArena *arena, int32_t ref, uint8_t *label,
                                                 int32_t label_len);
extern int32_t typeck_check_expr_index(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_binop(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_unary(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_addr_of(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_deref(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_expr_var_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_as(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                 int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_assign(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_var(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_block_one_const(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_let(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_while(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_for(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_if(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_stmt_order_one(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                                 int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t si,
                                                 int32_t nso, int32_t nc, int32_t nl, int32_t nes, int32_t nlp,
                                                 int32_t nfp, int32_t nif, int32_t nreg);
extern int32_t typeck_check_block_final(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t fin0);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_stmt_order_kind(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                     struct shux_slice_uint8_t *source);
extern int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                   struct shux_slice_uint8_t *source);
extern int32_t pipeline_parse_scalars_ok_get(void);
extern int32_t pipeline_parse_scalars_main_idx_get(void);
extern void pipeline_module_set_main_func_index(struct ast_Module *module, int32_t idx);
extern int32_t pipeline_module_main_func_index(struct ast_Module *module);
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx);
extern void driver_diagnostic_typeck_fail(void);
extern void pipeline_typeck_field_prebind_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_field_import_binding_resolve_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                              int32_t expr_ref, int32_t base_ref,
                                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                 int32_t base_ref);
extern int32_t pipeline_typeck_field_known_ptr_types_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t expr_ref, int32_t base_ref, int32_t num_layouts);
extern int32_t pipeline_typeck_field_layout_named_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t base_ref,
                                                    struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_field_slice_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);
extern void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);
extern void pipeline_typeck_field_lexer_fallback_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, int32_t base_ref,
                                                   struct ast_PipelineDepCtx *ctx);

extern int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c(struct ast_ASTArena *arena,
                                                                            int32_t body_ref);
extern int32_t pipeline_typeck_func_body_has_implicit_return_tail_c(struct ast_ASTArena *arena, int32_t body_ref);

#define TYPECK_LINEAR_MOVED_MAX 128
static int g_typeck_linear_moved_n;
static char g_typeck_linear_moved_names[TYPECK_LINEAR_MOVED_MAX][64];
static int32_t g_typeck_linear_moved_lens[TYPECK_LINEAR_MOVED_MAX];

/** runtime 期望的程序入口名。 */
extern int32_t driver_run_compiler_full(int32_t argc, char **argv);

/** runtime 期望的程序入口名；weak 以便与 asm_experimental_symbol_bridge 共存（B-strict 链 build_asm/pipeline.o 时）。 */
__attribute__((weak)) int32_t main_entry(int32_t argc, char **argv) {
  return driver_run_compiler_full(argc, argv);
}

__attribute__((weak)) int32_t main_run_compiler_c(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, (char **)argv);
}

/** pipeline 非 asm 分支 weak 桩（asm 路径不走此符号）。 */
__attribute__((weak)) int32_t codegen_x_ast(void *module, void *arena, void *out_buf, void *ctx, int32_t dep_index) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  (void)dep_index;
  return -1;
}

/** runtime 调用的裸名 parse_into_init → partial 导出的 parser_parse_into_init。 */
extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);

__attribute__((weak)) int32_t ast_pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t fi) {
  int32_t n = pipeline_module_func_num_generic_params_at(m, fi);
  if (getenv("SHUX_DEBUG_FUNC_GENERIC_GET"))
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "func generic get: fi=%d n=%d", (int)fi, (int)n);
  return n;
}

void parse_into_init(void *module, void *arena) {
  parser_parse_into_init((struct ast_Module *)module, (struct ast_ASTArena *)arena);
}

/** strict minimal 不链 glue_standalone 时，runtime / pipeline_x 仍需要这两个默认桥接入口。 */
extern int32_t pipeline_lsp_diag_parse_typeck_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         uint8_t *source_data, int32_t source_len,
                                                         struct ast_PipelineDepCtx *ctx);

__attribute__((weak)) int32_t pipeline_typeck_after_parse_ok_impl_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                    struct shux_slice_uint8_t *source,
                                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t ok;
  int32_t main_idx;
  int32_t tc;
  if (!arena || !module || !source || !ctx)
    return -1;
  pipeline_strict_parse_into_init(arena, module);
  pipeline_parse_into_with_init_slice_scalars_sidecar(arena, module, source);
  ok = pipeline_parse_scalars_ok_get();
  main_idx = pipeline_parse_scalars_main_idx_get();
  if (ok != 0)
    return main_idx;
  pipeline_module_set_main_func_index(module, main_idx);
  pipeline_typeck_set_active_ctx_c(module, ctx);
  if (pipeline_module_main_func_index(module) < 0) {
    tc = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc != 0) {
      driver_diagnostic_typeck_fail();
      return tc;
    }
    return tc;
  }
  tc = typeck_typeck_x_ast(module, arena, ctx);
  if (tc != 0) {
    driver_diagnostic_typeck_fail();
    return tc;
  }
  return tc;
}

__attribute__((weak)) int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             struct shux_slice_uint8_t *source,
                                                             struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
}

__attribute__((weak)) int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                  uint8_t *source_data, int32_t source_len,
                                                                  struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
}

__attribute__((weak)) int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module,
                                                                   struct ast_ASTArena *arena, int32_t li,
                                                                   int32_t depth) {
  int32_t sz = 0;
  int32_t al = 1;
  if (li < 0)
    return 0;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &sz, &al) != 0)
    return 0;
  return sz;
}

__attribute__((weak)) int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module,
                                                                    struct ast_ASTArena *arena, int32_t li,
                                                                    int32_t depth) {
  int32_t sz = 0;
  int32_t al = 1;
  if (li < 0)
    return 1;
  if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &sz, &al) != 0)
    return 1;
  return al > 0 ? al : 1;
}

__attribute__((weak)) int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module,
                                                                 struct ast_ASTArena *arena, int32_t elem_type_ref,
                                                                 int32_t array_len, int32_t depth) {
  uint8_t name[64];
  int32_t nlen;
  int32_t li;
  int32_t nf;
  int32_t col = 0;
  int32_t max_al = 1;
  int32_t j;
  if (!module || !arena || elem_type_ref <= 0 || array_len <= 0 || depth > 64)
    return 0;
  if (pipeline_type_kind_ord_at(arena, elem_type_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, elem_type_ref, name);
  if (nlen <= 0)
    return 0;
  li = typeck_entry_module_find_struct_layout_index(module, name, nlen);
  if (li < 0 || pipeline_module_struct_layout_soa_at(module, li) == 0)
    return 0;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  for (j = 0; j < nf; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    int32_t al;
    int32_t fsize;
    int32_t rem;
    if (ftr <= 0)
      continue;
    al = typeck_x_type_align(module, arena, ftr, depth + 1);
    fsize = typeck_x_type_size(module, arena, ftr, depth + 1);
    if (al <= 0)
      al = 1;
    if (fsize <= 0)
      fsize = 4;
    rem = col % al;
    if (rem != 0)
      col += al - rem;
    col += array_len * fsize;
    if (al > max_al)
      max_al = al;
  }
  if (max_al > 1) {
    int32_t rem = col % max_al;
    if (rem != 0)
      col += max_al - rem;
  }
  return col > 0 ? col : 0;
}

static struct ast_Module *g_typeck_entry_module_for_dep_map_strict_minimal;

__attribute__((weak)) int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index,
                                                                                     int32_t dep_return_type_ref,
                                                                                     struct ast_ASTArena *caller_arena,
                                                                                     struct ast_PipelineDepCtx *ctx);

__attribute__((weak)) void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module) {
  g_typeck_entry_module_for_dep_map_strict_minimal = module;
}

static int32_t pipeline_typeck_named_unqual_offset_strict_minimal(const uint8_t *buf, int32_t len) {
  int32_t i;
  for (i = len - 1; i > 0; i--) {
    if (buf[i] == '.')
      return i + 1;
  }
  return 0;
}

static int32_t pipeline_typeck_named_equal_strict_minimal(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  uint8_t buf_a[64];
  uint8_t buf_b[64];
  int32_t na;
  int32_t nb;
  int32_t i;
  int32_t oa;
  int32_t ob;
  int32_t ua;
  int32_t ub;
  if (!arena)
    return 0;
  na = pipeline_type_named_name_into(arena, a, buf_a);
  nb = pipeline_type_named_name_into(arena, b, buf_b);
  if (na <= 0 || nb <= 0)
    return 0;
  if (na == nb) {
    for (i = 0; i < na; i++) {
      if (buf_a[i] != buf_b[i])
        break;
    }
    if (i == na)
      return 1;
  }
  oa = pipeline_typeck_named_unqual_offset_strict_minimal(buf_a, na);
  ob = pipeline_typeck_named_unqual_offset_strict_minimal(buf_b, nb);
  ua = na - oa;
  ub = nb - ob;
  if (ua != ub)
    return 0;
  for (i = 0; i < ua; i++) {
    if (buf_a[oa + i] != buf_b[ob + i])
      return 0;
  }
  return 1;
}

static int32_t pipeline_typeck_import_binding_name_equal_strict_minimal(struct ast_Module *module, int32_t dep_ix,
                                                                        const uint8_t *name, int32_t name_len) {
  int32_t bind_len;
  int32_t i;
  if (!module || !name || name_len <= 0 || dep_ix < 0 || dep_ix >= module->num_imports)
    return 0;
  bind_len = pipeline_module_import_binding_name_len(module, dep_ix);
  if (bind_len != name_len || bind_len <= 0 || bind_len > 63)
    return 0;
  for (i = 0; i < bind_len; i++) {
    if (pipeline_module_import_binding_name_byte_at(module, dep_ix, i) != name[i])
      return 0;
  }
  return 1;
}

static int32_t pipeline_typeck_find_func_index_in_module_by_name_strict_minimal(struct ast_Module *mod, uint8_t *name,
                                                                                 int32_t name_len, int32_t want_arity) {
  int32_t j;
  int32_t first_match;
  if (!mod || !name || name_len <= 0)
    return -1;
  first_match = -1;
  for (j = 0; j < mod->num_funcs; j++) {
    if (!pipeline_module_func_name_equal_at(mod, j, name, name_len))
      continue;
    if (first_match < 0)
      first_match = j;
    if (want_arity >= 0 && pipeline_module_func_num_params_at(mod, j) == want_arity)
      return j;
  }
  return first_match;
}

static int32_t pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len, int32_t from_dep_index,
    int32_t want_arity, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out) {
  int32_t func_ix;
  int32_t ret_ty;
  func_ix = pipeline_typeck_find_func_index_in_module_by_name_strict_minimal(mod, name, name_len, want_arity);
  if (func_ix < 0)
    return 0;
  if (func_index_out)
    *func_index_out = func_ix;
  ret_ty = pipeline_module_func_return_type_at(mod, func_ix);
  if (from_dep_index < 0)
    return ret_ty;
  return pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, ret_ty, caller_arena, ctx);
}

static int32_t pipeline_typeck_map_import_binding_named_to_caller_strict_minimal(struct ast_Module *entry_mod,
                                                                                  int32_t dep_ix,
                                                                                  struct ast_ASTArena *caller_arena,
                                                                                  uint8_t *nm, int32_t nlen) {
  int32_t bl;
  int32_t qlen;
  int32_t i;
  uint8_t qnm[64];
  if (!caller_arena || !nm || nlen <= 0)
    return 0;
  if (!entry_mod || dep_ix < 0)
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  if (pipeline_module_import_kind_at(entry_mod, dep_ix) != 1)
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  bl = pipeline_module_import_binding_name_len(entry_mod, dep_ix);
  if (bl <= 0 || bl + 1 + nlen > 63)
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  for (i = 0; i < bl; i++)
    qnm[i] = pipeline_module_import_binding_name_byte_at(entry_mod, dep_ix, i);
  qnm[bl] = '.';
  memcpy(qnm + bl + 1, nm, (size_t)nlen);
  qlen = bl + 1 + nlen;
  return pipeline_type_find_or_alloc_named(caller_arena, qnm, qlen);
}

static int32_t pipeline_typeck_dep_return_type_to_caller_strict_minimal(struct ast_ASTArena *dep_arena,
                                                                         int32_t dep_return_type_ref,
                                                                         struct ast_ASTArena *caller_arena) {
  int32_t kind;
  int32_t inner_mapped;
  int32_t elem_ref;
  int32_t array_size;
  uint8_t nm[64];
  int32_t nlen;
  if (dep_return_type_ref <= 0 || !dep_arena || !caller_arena)
    return 0;
  kind = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
  if (kind < 0)
    return 0;
  if (kind == (int32_t)ast_TypeKind_TYPE_I32 || kind == (int32_t)ast_TypeKind_TYPE_I64 ||
      kind == (int32_t)ast_TypeKind_TYPE_BOOL || kind == (int32_t)ast_TypeKind_TYPE_F64 ||
      kind == (int32_t)ast_TypeKind_TYPE_U8 || kind == (int32_t)ast_TypeKind_TYPE_U32 ||
      kind == (int32_t)ast_TypeKind_TYPE_U64 || kind == (int32_t)ast_TypeKind_TYPE_ISIZE ||
      kind == (int32_t)ast_TypeKind_TYPE_F32 || kind == (int32_t)ast_TypeKind_TYPE_USIZE ||
      kind == (int32_t)ast_TypeKind_TYPE_VOID)
    return pipeline_type_ensure_by_kind_ord(caller_arena, kind);
  if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm);
    if (nlen <= 0)
      return 0;
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  }
  elem_ref = pipeline_type_elem_ref_at(dep_arena, dep_return_type_ref);
  inner_mapped = 0;
  if (elem_ref > 0) {
    inner_mapped = pipeline_typeck_dep_return_type_to_caller_strict_minimal(dep_arena, elem_ref, caller_arena);
    if (inner_mapped == 0)
      return 0;
  }
  array_size = pipeline_type_array_size_at(dep_arena, dep_return_type_ref);
  if (kind == (int32_t)ast_TypeKind_TYPE_SLICE) {
    int32_t rlen = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
    uint8_t rbuf[64];
    if (rlen > 0)
      (void)pipeline_type_region_label_into(dep_arena, dep_return_type_ref, rbuf);
    return pipeline_type_find_or_alloc_slice(caller_arena, inner_mapped, rlen > 0 ? rbuf : NULL, rlen);
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_PTR)
    return pipeline_type_find_or_alloc_compound(caller_arena, (int32_t)ast_TypeKind_TYPE_PTR, inner_mapped, 0);
  if (kind == (int32_t)ast_TypeKind_TYPE_VECTOR)
    return pipeline_type_find_or_alloc_compound(caller_arena, (int32_t)ast_TypeKind_TYPE_VECTOR, inner_mapped,
                                                array_size);
  if (kind == (int32_t)ast_TypeKind_TYPE_ARRAY) {
    if (elem_ref <= 0 || array_size <= 0)
      return 0;
    return pipeline_type_find_or_alloc_compound(caller_arena, (int32_t)ast_TypeKind_TYPE_ARRAY, inner_mapped,
                                                array_size);
  }
  if (elem_ref > 0 || array_size != 0)
    return 0;
  nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm);
  if (nlen != 0)
    return 0;
  return pipeline_type_ensure_by_kind_ord(caller_arena, kind);
}

__attribute__((weak)) int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  int32_t kind;
  (void)g_typeck_entry_module_for_dep_map_strict_minimal;
  if (a == 0 || b == 0)
    return a == b;
  if (a == b)
    return 1;
  kind = pipeline_type_kind_ord_at(arena, a);
  if (kind != pipeline_type_kind_ord_at(arena, b))
    return 0;
  switch (kind) {
  case ast_TypeKind_TYPE_NAMED:
    return pipeline_typeck_named_equal_strict_minimal(arena, a, b);
  case ast_TypeKind_TYPE_PTR:
  case ast_TypeKind_TYPE_LINEAR:
    return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, a),
                                             pipeline_type_elem_ref_at(arena, b));
  case ast_TypeKind_TYPE_SLICE: {
    int32_t alen;
    int32_t blen;
    uint8_t abuf[64];
    uint8_t bbuf[64];
    if (!pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, a),
                                           pipeline_type_elem_ref_at(arena, b)))
      return 0;
    alen = pipeline_type_region_label_len_at(arena, a);
    blen = pipeline_type_region_label_len_at(arena, b);
    if (alen > 0 && blen > 0) {
      if (alen != blen)
        return 0;
      if (pipeline_type_region_label_into(arena, a, abuf) != alen
          || pipeline_type_region_label_into(arena, b, bbuf) != blen)
        return 0;
      return memcmp(abuf, bbuf, (size_t)alen) == 0;
    }
    return 1;
  }
  case ast_TypeKind_TYPE_ARRAY:
  case ast_TypeKind_TYPE_VECTOR:
    if (pipeline_type_array_size_at(arena, a) != pipeline_type_array_size_at(arena, b))
      return 0;
    return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, a),
                                             pipeline_type_elem_ref_at(arena, b));
  default:
    return 1;
  }
}

__attribute__((weak)) int32_t pipeline_typeck_reject_addr_of_linear_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                                      int32_t addr_expr_ref, struct ast_Module *module,
                                                                      struct ast_PipelineDepCtx *ctx) {
  int32_t vnlen;
  int32_t block_ref;
  int32_t vd_tr;
  int32_t func_ix;
  int32_t pr;
  int32_t line;
  int32_t col;
  uint8_t vbuf[64];
  if (!arena || !module || !ctx || op_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, op_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  vnlen = pipeline_expr_var_name_len(arena, op_ref);
  if (vnlen <= 0 || vnlen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, op_ref, vbuf);
  block_ref = pipeline_dep_ctx_current_block_ref_at(ctx);
  if (block_ref > 0) {
    vd_tr = pipeline_block_resolve_var_type_ref(arena, block_ref, vbuf, vnlen);
    if (vd_tr > 0 && pipeline_type_kind_ord_at(arena, vd_tr) == (int32_t)ast_TypeKind_TYPE_LINEAR)
      goto reject;
  }
  func_ix = pipeline_dep_ctx_current_func_index(ctx);
  if (func_ix >= 0 && func_ix < pipeline_module_num_funcs(module)) {
    pr = pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen);
    if (pr > 0 && pipeline_type_kind_ord_at(arena, pr) == (int32_t)ast_TypeKind_TYPE_LINEAR)
      goto reject;
  }
  return 0;
reject:
  line = 0;
  col = 0;
  if (addr_expr_ref > 0) {
    line = pipeline_expr_line_at(arena, addr_expr_ref);
    col = pipeline_expr_col_at(arena, addr_expr_ref);
  }
  driver_diagnostic_typeck_linear_addr_of(line, col);
  return -1;
}

/**
 * strict minimal 链在 Darwin 上默认不链接 pipeline_glue_standalone.o，
 * 因此需要在末尾覆盖 pipeline_x.o 里的旧 addr_of 快照实现。
 * &var / &base.field / &base[idx] 都可直接复用现有左值有效地址发射。
 */
int32_t pipeline_asm_emit_addr_of_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op_ref;
  int32_t op_kind;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0)
    return -1;
  op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
  if (op_kind == (int32_t)ast_ExprKind_EXPR_VAR || op_kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS
      || op_kind == (int32_t)ast_ExprKind_EXPR_INDEX) {
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op_ref, ctx, ta);
  }
  /* #region debug-point A:context-cg002-addr-of-fallback */
  if (getenv("SHUX_ASM_DEBUG")) {
    fprintf(stderr, "shux: addr_of elf fallback expr_ref=%d op_ref=%d op_kind=%d\n",
            (int)expr_ref, (int)op_ref, (int)op_kind);
  }
  /* #endregion debug-point A:context-cg002-addr-of-fallback */
  return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
}

__attribute__((weak)) int32_t pipeline_typeck_resolve_call_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                        int32_t call_expr_ref) {
  int32_t fx;
  int32_t callee_ref;
  int32_t callee_name_len;
  int32_t i;
  uint8_t callee_name[64];
  if (!m || !a || call_expr_ref <= 0)
    return -1;
  fx = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
  if (fx >= 0)
    return fx;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  if (callee_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(a, callee_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return -1;
  callee_name_len = pipeline_expr_var_name_len(a, callee_ref);
  if (callee_name_len <= 0 || callee_name_len > 63)
    return -1;
  pipeline_expr_var_name_into(a, callee_ref, callee_name);
  for (i = 0; i < pipeline_module_num_funcs(m); i++) {
    if (!pipeline_module_func_name_equal_at(m, i, callee_name, callee_name_len))
      continue;
    pipeline_expr_apply_call_resolve(a, call_expr_ref, -1, i);
    return i;
  }
  return -1;
}

__attribute__((weak)) int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m,
                                                                                 struct ast_ASTArena *a,
                                                                                 int32_t call_expr_ref) {
  return pipeline_typeck_resolve_call_func_index_c(m, a, call_expr_ref);
}

__attribute__((weak)) void pipeline_typeck_loop_depth_set_c(struct ast_PipelineDepCtx *ctx, int32_t depth) {
  if (!ctx)
    return;
  ctx->typeck_loop_depth = depth;
}

__attribute__((weak)) void pipeline_typeck_pad_fields_warn_layout(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                  int32_t li) {
  (void)module;
  (void)arena;
  (void)li;
}

__attribute__((weak)) int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena *arena) {
  static const uint8_t lbl[] = "io_read_ptr";
  int32_t u8_ref;
  if (!arena)
    return 0;
  u8_ref = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U8);
  if (u8_ref <= 0)
    return 0;
  return pipeline_type_find_or_alloc_slice(arena, u8_ref, (uint8_t *)lbl, 11);
}

static int pipeline_typeck_linear_name_already_moved_strict_minimal(const uint8_t *name, int32_t name_len) {
  int i;
  for (i = 0; i < g_typeck_linear_moved_n; i++) {
    if (g_typeck_linear_moved_lens[i] == name_len && name_len > 0 &&
        memcmp(g_typeck_linear_moved_names[i], name, (size_t)name_len) == 0)
      return 1;
  }
  return 0;
}

__attribute__((weak)) void pipeline_typeck_linear_reset_c(void) {
  g_typeck_linear_moved_n = 0;
}

__attribute__((weak)) int32_t pipeline_typeck_linear_use_var_c(struct ast_ASTArena *arena, int32_t type_ref,
                                                               int32_t expr_ref, uint8_t *name, int32_t name_len) {
  int32_t line;
  int32_t col;
  if (!arena || !name || name_len <= 0 || name_len > 63)
    return 0;
  if (type_ref <= 0 || pipeline_type_kind_ord_at(arena, type_ref) != (int32_t)ast_TypeKind_TYPE_LINEAR)
    return 0;
  if (pipeline_typeck_linear_name_already_moved_strict_minimal(name, name_len)) {
    line = 0;
    col = 0;
    if (expr_ref > 0) {
      line = pipeline_expr_line_at(arena, expr_ref);
      col = pipeline_expr_col_at(arena, expr_ref);
    }
    lsp_diag_report_typeck((int)line, (int)col, "linear value used after move");
    return -1;
  }
  if (g_typeck_linear_moved_n < TYPECK_LINEAR_MOVED_MAX) {
    memcpy(g_typeck_linear_moved_names[g_typeck_linear_moved_n], name, (size_t)name_len);
    g_typeck_linear_moved_lens[g_typeck_linear_moved_n] = name_len;
    g_typeck_linear_moved_n++;
  }
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_linear_accepts_init_c(struct ast_ASTArena *arena, int32_t decl_ref,
                                                                    int32_t init_ref) {
  if (!arena || decl_ref <= 0 || init_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, decl_ref) != (int32_t)ast_TypeKind_TYPE_LINEAR)
    return 0;
  if (pipeline_typeck_type_refs_equal_c(arena, decl_ref, init_ref))
    return 1;
  return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, decl_ref), init_ref);
}

static int32_t pipeline_typeck_slice_region_conflict_strict_minimal(struct ast_ASTArena *arena, int32_t expect_ref,
                                                                    int32_t src_ref) {
  int32_t ek;
  int32_t sk;
  uint8_t eb[64];
  uint8_t sb[64];
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  ek = pipeline_type_region_label_len_at(arena, expect_ref);
  sk = pipeline_type_region_label_len_at(arena, src_ref);
  if (ek <= 0 || sk <= 0)
    return 0;
  if (pipeline_type_region_label_into(arena, expect_ref, eb) != ek ||
      pipeline_type_region_label_into(arena, src_ref, sb) != sk)
    return 0;
  return (ek != sk || memcmp(eb, sb, (size_t)ek) != 0) ? 1 : 0;
}

static int32_t pipeline_typeck_slice_region_escape_strict_minimal(struct ast_ASTArena *arena, int32_t expect_ref,
                                                                  int32_t src_ref) {
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  return (pipeline_type_region_label_len_at(arena, src_ref) > 0 &&
          pipeline_type_region_label_len_at(arena, expect_ref) <= 0)
             ? 1
             : 0;
}

static int pipeline_expr_is_func_param_at_strict_minimal(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         int32_t func_idx, int32_t expr_ref, int32_t param_ix) {
  uint8_t pbuf[32];
  uint8_t vbuf[64];
  int32_t plen;
  int32_t vlen;
  int32_t k;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  plen = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0 || plen != vlen)
    return 0;
  pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, pbuf);
  pipeline_expr_var_name_into(arena, expr_ref, vbuf);
  for (k = 0; k < plen; k++) {
    if (pbuf[k] != vbuf[k])
      return 0;
  }
  return 1;
}

static void pipeline_typeck_expr_diag_line_col_strict_minimal(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *line,
                                                              int32_t *col) {
  if (line)
    *line = 0;
  if (col)
    *col = 0;
  if (!arena || expr_ref <= 0)
    return;
  if (line)
    *line = pipeline_expr_line_at(arena, expr_ref);
  if (col)
    *col = pipeline_expr_col_at(arena, expr_ref);
}

static int32_t typeck_block_is_strict_ancestor_strict_minimal(struct ast_ASTArena *arena, int32_t ancestor,
                                                              int32_t descendant) {
  struct ast_Block *block;
  int32_t cur;
  int32_t depth;
  if (!arena || ancestor <= 0 || descendant <= 0 || ancestor == descendant)
    return 0;
  cur = descendant;
  depth = 0;
  while (cur > 0 && cur <= arena->num_blocks && depth < 128) {
    block = pipeline_arena_block_ptr(arena, cur);
    if (!block)
      break;
    if (block->parent_block_ref == ancestor)
      return 1;
    cur = block->parent_block_ref;
    depth++;
  }
  return 0;
}

static int32_t typeck_expr_lval_root_var_strict_minimal(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *out,
                                                        int32_t *out_len) {
  int32_t cur;
  int32_t kind;
  if (!arena || expr_ref <= 0 || !out || !out_len)
    return 0;
  cur = expr_ref;
  for (;;) {
    kind = pipeline_expr_kind_ord_at(arena, cur);
    if (kind == (int32_t)ast_ExprKind_EXPR_VAR) {
      *out_len = pipeline_expr_var_name_len(arena, cur);
      if (*out_len <= 0 || *out_len > 63)
        return 0;
      pipeline_expr_var_name_into(arena, cur, out);
      return 1;
    }
    if (kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
      cur = pipeline_expr_field_access_base_ref(arena, cur);
    else if (kind == (int32_t)ast_ExprKind_EXPR_INDEX)
      cur = pipeline_expr_index_base_ref(arena, cur);
    else
      return 0;
    if (cur <= 0)
      return 0;
  }
}

static int32_t typeck_name_is_block_local_strict_minimal(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct ast_PipelineDepCtx *ctx, uint8_t *name, int32_t name_len) {
  int32_t func_ix;
  int32_t site_block;
  if (!module || !arena || !ctx || !name || name_len <= 0)
    return 0;
  func_ix = ctx->current_func_index;
  if (func_ix >= 0 && pipeline_module_func_param_type_ref_for_name(module, func_ix, name, name_len) > 0)
    return 0;
  site_block = ctx->current_block_ref;
  if (site_block <= 0 && func_ix >= 0)
    site_block = pipeline_module_func_body_ref_at(module, func_ix);
  if (site_block <= 0)
    return 0;
  return pipeline_block_find_var_decl_block_ref(arena, site_block, name, name_len) > 0 ? 1 : 0;
}

static int32_t typeck_expr_is_addr_of_block_local_strict_minimal(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx, int32_t expr_ref) {
  uint8_t vbuf[64];
  int32_t vlen;
  int32_t op_ref;
  if (!module || !arena || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0)
    return 0;
  if (!typeck_expr_lval_root_var_strict_minimal(arena, op_ref, vbuf, &vlen))
    return 0;
  return typeck_name_is_block_local_strict_minimal(module, arena, ctx, vbuf, vlen);
}

__attribute__((weak)) int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena,
                                                                          int32_t site_expr_ref, int32_t expect_ref,
                                                                          int32_t src_ref) {
  int32_t line;
  int32_t col;
  uint8_t sb[64];
  int32_t slen;
  uint8_t eb[64];
  int32_t elen;
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  line = 0;
  col = 0;
  if (site_expr_ref > 0) {
    line = pipeline_expr_line_at(arena, site_expr_ref);
    col = pipeline_expr_col_at(arena, site_expr_ref);
  }
  if (pipeline_typeck_slice_region_escape_strict_minimal(arena, expect_ref, src_ref)) {
    slen = pipeline_type_region_label_into(arena, src_ref, sb);
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region escape: cannot assign <%.*s> slice to unbound T[]",
                           (int)(slen > 0 ? slen : 0), (const char *)sb);
    return -1;
  }
  if (pipeline_typeck_slice_region_conflict_strict_minimal(arena, expect_ref, src_ref)) {
    elen = pipeline_type_region_label_into(arena, expect_ref, eb);
    slen = pipeline_type_region_label_into(arena, src_ref, sb);
    eb[elen > 0 && elen < 64 ? elen : 0] = '\0';
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region mismatch: expected <%.*s>, found <%.*s>",
                           (int)(elen > 0 ? elen : 0), (const char *)eb, (int)(slen > 0 ? slen : 0),
                           (const char *)sb);
    return -1;
  }
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module,
                                                                                  struct ast_ASTArena *arena,
                                                                                  int32_t site_expr_ref,
                                                                                  int32_t left_ref, int32_t right_ref,
                                                                                  struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t np;
  int32_t pi;
  int32_t line;
  int32_t col;
  int32_t base_ref;
  int32_t op_ref;
  uint8_t name_buf[64];
  int32_t name_len;
  if (!module || !arena || !ctx || left_ref <= 0 || right_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, right_ref);
  if (pipeline_expr_kind_ord_at(arena, op_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  name_len = pipeline_expr_var_name_len(arena, op_ref);
  if (name_len <= 0 || name_len > 63)
    return 0;
  pipeline_expr_var_name_into(arena, op_ref, name_buf);
  if (pipeline_dep_ctx_current_block_ref_at(ctx) <= 0 ||
      pipeline_block_resolve_var_type_ref(arena, pipeline_dep_ctx_current_block_ref_at(ctx), name_buf, name_len) <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  base_ref = pipeline_expr_field_access_base_ref(arena, left_ref);
  func_ix = pipeline_dep_ctx_current_func_index(ctx);
  if (func_ix < 0)
    return 0;
  np = pipeline_module_func_num_params_at(module, func_ix);
  for (pi = 0; pi < np; pi++) {
    if (!pipeline_expr_is_func_param_at_strict_minimal(arena, module, func_ix, base_ref, pi))
      continue;
    if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, func_ix, pi)) !=
        (int32_t)ast_TypeKind_TYPE_PTR)
      continue;
    line = 0;
    col = 0;
    if (site_expr_ref > 0) {
      line = pipeline_expr_line_at(arena, site_expr_ref);
      col = pipeline_expr_col_at(arena, site_expr_ref);
    }
    lsp_diag_report_typeck((int)line, (int)col,
                           "struct stack escape: cannot store address of local struct in outer lifetime");
    return -1;
  }
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena,
                                                                               int32_t init_ref, int32_t decl_ty_ref,
                                                                               int32_t decl_kind, int32_t init_kind) {
  if (!arena || init_ref <= 0)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_I32 && decl_kind != (int32_t)ast_TypeKind_TYPE_I64 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_U64 && decl_kind != (int32_t)ast_TypeKind_TYPE_USIZE)
    return 0;
  if (init_kind != (int32_t)ast_ExprKind_EXPR_ADD && init_kind != (int32_t)ast_ExprKind_EXPR_SUB &&
      init_kind != (int32_t)ast_ExprKind_EXPR_MUL && init_kind != (int32_t)ast_ExprKind_EXPR_DIV)
    return 0;
  pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
  return 1;
}

__attribute__((weak)) void pipeline_typeck_const_init_not_constant_c(int32_t line, int32_t col) {
  lsp_diag_report_typeck((int)line, (int)col, "const init must be constant expression");
}

static int32_t pipeline_typeck_const_name_matches_strict_minimal(uint8_t *name, int32_t name_len, const char *lit) {
  size_t lit_len;
  if (!name || !lit || name_len <= 0)
    return 0;
  lit_len = strlen(lit);
  return name_len == (int32_t)lit_len && memcmp(name, lit, lit_len) == 0 ? 1 : 0;
}

static int32_t pipeline_typeck_const_expr_ref_strict_minimal(struct ast_ASTArena *arena, int32_t expr_ref,
                                                             const char *const_names[], int32_t n_const_names) {
  int32_t kind;
  int32_t i;
  uint8_t name_buf[64];
  int32_t name_len;
  if (!arena || expr_ref <= 0)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_LIT || kind == (int32_t)ast_ExprKind_EXPR_FLOAT_LIT ||
      kind == (int32_t)ast_ExprKind_EXPR_BOOL_LIT)
    return 1;
  if (kind == (int32_t)ast_ExprKind_EXPR_VAR) {
    name_len = pipeline_expr_var_name_len(arena, expr_ref);
    if (name_len <= 0 || name_len > 63)
      return 0;
    pipeline_expr_var_name_into(arena, expr_ref, name_buf);
    for (i = 0; i < n_const_names; i++) {
      if (const_names[i] && pipeline_typeck_const_name_matches_strict_minimal(name_buf, name_len, const_names[i]))
        return 1;
    }
    return 0;
  }
  if (kind >= (int32_t)ast_ExprKind_EXPR_ADD && kind <= (int32_t)ast_ExprKind_EXPR_LOGOR)
    return pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                                         const_names, n_const_names) &&
           pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref),
                                                         const_names, n_const_names);
  if (kind == (int32_t)ast_ExprKind_EXPR_NEG || kind == (int32_t)ast_ExprKind_EXPR_BITNOT ||
      kind == (int32_t)ast_ExprKind_EXPR_LOGNOT)
    return pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref),
                                                         const_names, n_const_names);
  if (kind == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
    int32_t ne = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    for (i = 0; i < ne; i++) {
      if (!pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_array_lit_elem_ref(arena, expr_ref, i),
                                                         const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  return 0;
}

__attribute__((weak)) int32_t pipeline_asm_init_is_empty_array_lit_c(struct ast_ASTArena *arena, int32_t init_ref) {
  if (!arena || init_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != (int32_t)ast_ExprKind_EXPR_ARRAY_LIT)
    return 0;
  return pipeline_expr_array_lit_num_elems_at(arena, init_ref) == 0 ? 1 : 0;
}

__attribute__((weak)) int32_t pipeline_asm_build_import_binding_call_sym_c(const uint8_t *pre, int32_t pre_len,
                                                                           const uint8_t *field_name, int32_t field_len,
                                                                           uint8_t *out_name) {
  int32_t pos;
  int32_t pi;
  int32_t same_prefix;
  if (!field_name || field_len <= 0 || !out_name)
    return -1;
  pos = 0;
  pi = 0;
  same_prefix = 0;
  if (pre && pre_len > 0 && field_len >= pre_len) {
    same_prefix = 1;
    for (pi = 0; pi < pre_len; pi++) {
      if (field_name[pi] != pre[pi]) {
        same_prefix = 0;
        break;
      }
    }
  }
  pi = 0;
  if (pre && pre_len > 0 && same_prefix == 0) {
    while (pi < pre_len && pos < 63)
      out_name[pos++] = pre[pi++];
  }
  pi = 0;
  while (pi < field_len && pos < 63)
    out_name[pos++] = field_name[pi++];
  if (pos <= 0)
    return -1;
  return pos;
}

__attribute__((weak)) int32_t pipeline_typeck_block_const_init_is_const_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                                          int32_t const_idx) {
  const char *names[64];
  char name_bufs[64][64];
  int32_t n;
  int32_t i;
  int32_t init_ref;
  if (!arena || const_idx < 0)
    return 0;
  n = 0;
  for (i = 0; i < const_idx && n < 64; i++) {
    int32_t name_len = pipeline_block_const_name_len(arena, block_ref, i);
    if (name_len <= 0 || name_len >= 64)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, (uint8_t *)name_bufs[n]);
    name_bufs[n][name_len] = '\0';
    names[n] = name_bufs[n];
    n++;
  }
  init_ref = pipeline_block_const_init_ref(arena, block_ref, const_idx);
  if (init_ref <= 0)
    return 1;
  return pipeline_typeck_const_expr_ref_strict_minimal(arena, init_ref, names, n);
}

__attribute__((weak)) int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                                     int32_t let_idx,
                                                                     struct ast_PipelineDepCtx *ctx) {
  (void)arena;
  (void)block_ref;
  (void)let_idx;
  (void)ctx;
  return 0;
}

__attribute__((weak)) void pipeline_typeck_hot_reorder_warn_layout(struct ast_Module *module,
                                                                   struct ast_ASTArena *arena, int32_t li) {
  (void)module;
  (void)arena;
  (void)li;
}

__attribute__((weak)) int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t *name, int32_t name_len) {
  static const uint8_t n0[] = "read_ptr_slice";
  static const uint8_t n1[] = "shux_io_read_ptr_slice";
  static const uint8_t n2[] = "driver_read_ptr_slice";
  static const uint8_t n3[] = "io_read_ptr_slice";
  if (!name || name_len <= 0)
    return 0;
  if (name_len == 14 && memcmp(name, n0, 14) == 0)
    return 1;
  if (name_len == 19 && memcmp(name, n1, 19) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, n2, 18) == 0)
    return 1;
  if (name_len == 16 && memcmp(name, n3, 16) == 0)
    return 1;
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index,
                                                                                      int32_t dep_return_type_ref,
                                                                                      struct ast_ASTArena *caller_arena,
                                                                                      struct ast_PipelineDepCtx *ctx) {
  struct ast_ASTArena *dep_arena;
  int32_t kind;
  uint8_t nm[64];
  int32_t nlen;
  if (from_dep_index < 0 || !ctx)
    return 0;
  dep_arena = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
  if (!dep_arena) {
    dep_arena = pipeline_get_dep_arena_slot(from_dep_index);
    if (!dep_arena)
      return 0;
  }
  if (from_dep_index >= pipeline_dep_ctx_ndep(ctx) && !pipeline_dep_ctx_module_at(ctx, from_dep_index))
    return 0;
  if (g_typeck_entry_module_for_dep_map_strict_minimal && dep_return_type_ref > 0) {
    kind = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
    if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
      nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm);
      if (nlen > 0) {
        return pipeline_typeck_map_import_binding_named_to_caller_strict_minimal(
            g_typeck_entry_module_for_dep_map_strict_minimal, from_dep_index, caller_arena, nm, nlen);
      }
    }
  }
  return pipeline_typeck_dep_return_type_to_caller_strict_minimal(dep_arena, dep_return_type_ref, caller_arena);
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_int_lit_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int64_t value;
  int32_t ty;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  if (pipeline_expr_resolved_type_ref(arena, expr_ref) != 0)
    return 0;
  value = pipeline_expr_int64_val_at(arena, expr_ref);
  if (value > (int64_t)INT32_MAX || value < (int64_t)INT32_MIN)
    ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I64);
  else
    ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  if (ty > 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_match_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 int32_t expr_ref, int32_t return_type_ref,
                                                                 struct ast_PipelineDepCtx *ctx) {
  int32_t matched_ref;
  int32_t num_arms;
  int32_t arm_i;
  int32_t line;
  int32_t col;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  if (typeck_check_expr(module, arena, matched_ref, return_type_ref, ctx) != 0)
    return -1;
  for (arm_i = 0; arm_i < num_arms; arm_i++) {
    int32_t arm_res;
    if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i) != 0 &&
        pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i) < 0) {
      driver_diagnostic_typeck_enum_no_variant(line, col);
      return -1;
    }
    arm_res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
    if (typeck_check_expr(module, arena, arm_res, return_type_ref, ctx) != 0)
      return -1;
  }
  if (return_type_ref > 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena, int32_t expr_ref,
                                                                       int32_t return_type_ref,
                                                                       struct ast_PipelineDepCtx *ctx) {
  static const uint8_t method_double[] = "double";
  int32_t base_kind;
  int32_t base_ref;
  int32_t base_rc;
  int32_t base_ty;
  int32_t base_nlen;
  int32_t method_nlen;
  int32_t dep_ix;
  int32_t func_ix;
  int32_t import_ret_ty;
  int32_t import_kind;
  int32_t ii;
  uint8_t method_nm[64];
  uint8_t base_nm[64];
  int32_t ret_ty;
  int32_t num_args;
  int32_t arg_i;
  struct ast_Module *dm;
  if (!module || !arena || expr_ref <= 0)
    return 0;
  pipeline_expr_init_call_resolve_at_ref(arena, expr_ref);
  base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
  base_rc = typeck_check_expr(module, arena, base_ref, 0, ctx);
  base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  method_nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
  if (method_nlen <= 0 || method_nlen > 63)
    return -1;
  pipeline_expr_method_call_name_into(arena, expr_ref, method_nm);
  ret_ty = 0;
  if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == (int32_t)ast_TypeKind_TYPE_I32 &&
      method_nlen == (int32_t)(sizeof(method_double) - 1) &&
      memcmp(method_nm, method_double, sizeof(method_double) - 1) == 0)
    ret_ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  num_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
  for (arg_i = 0; arg_i < num_args; arg_i++) {
    int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, arg_i);
    if (typeck_check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0)
      return -1;
  }
  dep_ix = -1;
  func_ix = -1;
  import_ret_ty = 0;
  if (ctx && base_kind == (int32_t)ast_ExprKind_EXPR_VAR) {
    base_nlen = pipeline_expr_var_name_len(arena, base_ref);
    if (base_nlen > 0 && base_nlen <= 63) {
      pipeline_expr_var_name_into(arena, base_ref, base_nm);
      for (ii = 0; ii < module->num_imports; ii++) {
        import_kind = pipeline_module_import_kind_at(module, ii);
        if (import_kind != 1)
          continue;
        if (!pipeline_typeck_import_binding_name_equal_strict_minimal(module, ii, base_nm, base_nlen))
          continue;
        dm = pipeline_dep_ctx_module_at(ctx, ii);
        if (!dm)
          break;
        import_ret_ty = pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(
            dm, arena, method_nm, method_nlen, ii, num_args, ctx, &func_ix);
        if (import_ret_ty > 0) {
          dep_ix = ii;
          break;
        }
        break;
      }
    }
  }
  if (import_ret_ty > 0) {
    pipeline_expr_apply_call_resolve(arena, expr_ref, dep_ix, func_ix);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, import_ret_ty);
    return 0;
  }
  if (ret_ty > 0) {
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
    return 0;
  }
  if (base_rc != 0)
    return -1;
  return -1;
}

__attribute__((weak)) int32_t pipeline_typeck_check_scope_borrow_assign_c(struct ast_Module *module,
                                                                          struct ast_ASTArena *arena,
                                                                          int32_t site_expr_ref, int32_t left_ref,
                                                                          int32_t right_ref,
                                                                          struct ast_PipelineDepCtx *ctx) {
  uint8_t lname[64];
  uint8_t rname[64];
  int32_t llen;
  int32_t rlen;
  int32_t op_ref;
  int32_t site_block;
  int32_t lblock;
  int32_t rblock;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || left_ref <= 0 || right_ref <= 0)
    return 0;
  if (!typeck_expr_is_addr_of_block_local_strict_minimal(module, arena, ctx, right_ref))
    return 0;
  if (!typeck_expr_lval_root_var_strict_minimal(arena, left_ref, lname, &llen))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, right_ref);
  if (op_ref <= 0 || pipeline_expr_kind_ord_at(arena, op_ref) != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  rlen = pipeline_expr_var_name_len(arena, op_ref);
  if (rlen <= 0 || rlen > 63)
    return 0;
  pipeline_expr_var_name_into(arena, op_ref, rname);
  site_block = ctx->current_block_ref;
  if (site_block <= 0 && ctx->current_func_index >= 0)
    site_block = pipeline_module_func_body_ref_at(module, ctx->current_func_index);
  if (site_block <= 0)
    return 0;
  lblock = pipeline_block_find_var_decl_block_ref(arena, site_block, lname, llen);
  rblock = pipeline_block_find_var_decl_block_ref(arena, site_block, rname, rlen);
  if (lblock <= 0 || rblock <= 0 || lblock == rblock)
    return 0;
  if (!typeck_block_is_strict_ancestor_strict_minimal(arena, lblock, rblock))
    return 0;
  pipeline_typeck_expr_diag_line_col_strict_minimal(arena, site_expr_ref, &line, &col);
  lsp_diag_report_typeck((int)line, (int)col, "scope borrow escape");
  return -1;
}

__attribute__((weak)) int32_t pipeline_typeck_check_allocator_region_assign_c(struct ast_Module *module,
                                                                              struct ast_ASTArena *arena,
                                                                              int32_t site_expr_ref,
                                                                              int32_t left_ref,
                                                                              struct ast_PipelineDepCtx *ctx) {
  (void)module;
  (void)arena;
  (void)site_expr_ref;
  (void)left_ref;
  (void)ctx;
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena,
                                                                          int32_t ret_site_ref, int32_t op_ref,
                                                                          int32_t func_return_ref) {
  int32_t got_ref;
  int32_t line;
  int32_t col;
  uint8_t sb[64];
  int32_t slen;
  uint8_t eb[64];
  int32_t elen;
  if (!arena || op_ref <= 0 || func_return_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, func_return_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  got_ref = pipeline_expr_resolved_type_ref(arena, op_ref);
  if (got_ref <= 0 || pipeline_type_kind_ord_at(arena, got_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  pipeline_typeck_expr_diag_line_col_strict_minimal(arena, ret_site_ref, &line, &col);
  if (pipeline_typeck_slice_region_escape_strict_minimal(arena, func_return_ref, got_ref)) {
    slen = pipeline_type_region_label_into(arena, got_ref, sb);
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region escape: cannot return <%.*s> slice as unbound T[]",
                           (int)(slen > 0 ? slen : 0), (const char *)sb);
    return -1;
  }
  if (pipeline_typeck_slice_region_conflict_strict_minimal(arena, func_return_ref, got_ref)) {
    elen = pipeline_type_region_label_into(arena, func_return_ref, eb);
    slen = pipeline_type_region_label_into(arena, got_ref, sb);
    eb[elen > 0 && elen < 64 ? elen : 0] = '\0';
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region mismatch in return: expected <%.*s>, found <%.*s>",
                           (int)(elen > 0 ? elen : 0), (const char *)eb, (int)(slen > 0 ? slen : 0),
                           (const char *)sb);
    return -1;
  }
  return 0;
}

static int32_t pipeline_typeck_result_payload_type_from_name_strict_minimal(struct ast_ASTArena *arena, uint8_t *name,
                                                                            int32_t name_len) {
  static const uint8_t prefix[] = "Result_";
  static const uint8_t n_i32[] = "i32";
  static const uint8_t n_u8[] = "u8";
  static const uint8_t n_i64[] = "i64";
  static const uint8_t n_u64[] = "u64";
  static const uint8_t n_usize[] = "usize";
  static const uint8_t n_isize[] = "isize";
  static const uint8_t n_bool[] = "bool";
  int32_t suffix_off;
  int32_t suffix_len;
  if (!arena || !name || name_len <= 0)
    return 0;
  if (name_len < (int32_t)(sizeof(prefix) - 1))
    return 0;
  if (memcmp(name, prefix, sizeof(prefix) - 1) != 0)
    return 0;
  suffix_off = (int32_t)(sizeof(prefix) - 1);
  suffix_len = name_len - suffix_off;
  if (suffix_len == (int32_t)(sizeof(n_i32) - 1) && memcmp(name + suffix_off, n_i32, sizeof(n_i32) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  if (suffix_len == (int32_t)(sizeof(n_u8) - 1) && memcmp(name + suffix_off, n_u8, sizeof(n_u8) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U8);
  if (suffix_len == (int32_t)(sizeof(n_i64) - 1) && memcmp(name + suffix_off, n_i64, sizeof(n_i64) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I64);
  if (suffix_len == (int32_t)(sizeof(n_u64) - 1) && memcmp(name + suffix_off, n_u64, sizeof(n_u64) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U64);
  if (suffix_len == (int32_t)(sizeof(n_usize) - 1) && memcmp(name + suffix_off, n_usize, sizeof(n_usize) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_USIZE);
  if (suffix_len == (int32_t)(sizeof(n_isize) - 1) && memcmp(name + suffix_off, n_isize, sizeof(n_isize) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_ISIZE);
  if (suffix_len == (int32_t)(sizeof(n_bool) - 1) && memcmp(name + suffix_off, n_bool, sizeof(n_bool) - 1) == 0)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_BOOL);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_try_propagate_c(struct ast_Module *module,
                                                                         struct ast_ASTArena *arena, int32_t expr_ref,
                                                                         int32_t return_type_ref,
                                                                         struct ast_PipelineDepCtx *ctx) {
  int32_t op_ref;
  int32_t op_ty;
  int32_t enclosing_return_type_ref;
  int32_t func_ix;
  int32_t func_ret;
  int32_t line;
  int32_t col;
  int32_t payload_ty;
  uint8_t rname[64];
  int32_t rlen;
  if (!module || !arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0)
    return -1;
  op_ty = pipeline_expr_resolved_type_ref(arena, op_ref);
  enclosing_return_type_ref = return_type_ref;
  func_ret = 0;
  func_ix = ctx ? pipeline_dep_ctx_current_func_index(ctx) : -1;
  if (func_ix >= 0 && func_ix < pipeline_module_num_funcs(module)) {
    func_ret = pipeline_module_func_return_type_at(module, func_ix);
    if (func_ret > 0)
      enclosing_return_type_ref = func_ret;
  }
  debug_try_propagate_report_strict_minimal(arena, expr_ref, func_ix, return_type_ref, func_ret,
                                            enclosing_return_type_ref, op_ty);
  if (op_ty <= 0 || pipeline_type_kind_ord_at(arena, op_ty) != (int32_t)ast_TypeKind_TYPE_NAMED) {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  rlen = pipeline_type_named_name_into(arena, op_ty, rname);
  if (rlen < (int32_t)(sizeof("Result_") - 1) || memcmp(rname, "Result_", sizeof("Result_") - 1) != 0) {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  if (enclosing_return_type_ref <= 0 || !pipeline_typeck_type_refs_equal_c(arena, enclosing_return_type_ref, op_ty)) {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  payload_ty = pipeline_typeck_result_payload_type_from_name_strict_minimal(arena, rname, rlen);
  if (payload_ty > 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, payload_ty);
  else
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_ty);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module,
                                                                        struct ast_ASTArena *arena,
                                                                        int32_t call_expr_ref,
                                                                        struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t dep_ix;
  int32_t num_args;
  int32_t np;
  int32_t i;
  struct ast_Module *callee_mod;
  if (!module || !arena || call_expr_ref <= 0)
    return 0;
  func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  if (func_ix < 0)
    func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
  if (func_ix < 0)
    return 0;
  callee_mod = module;
  if (dep_ix >= 0 && ctx) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dm)
      callee_mod = dm;
  }
  num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  np = pipeline_module_func_num_params_at(callee_mod, func_ix);
  if (num_args != np)
    return 0;
  for (i = 0; i < num_args; i++) {
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, i);
    int32_t param_ref = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
    int32_t arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (pipeline_typeck_check_slice_region_assign_c(arena, arg_ref, param_ref, arg_ty) != 0)
      return -1;
  }
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena, int32_t block_ref,
                                                                       int32_t region_idx, int32_t return_type_ref,
                                                                       struct ast_PipelineDepCtx *ctx) {
  int32_t body_ref;
  if (!module || !arena || !ctx || block_ref <= 0 || region_idx < 0)
    return 0;
  body_ref = pipeline_block_region_body_ref(arena, block_ref, region_idx);
  if (body_ref <= 0)
    return 0;
  return typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
}

static int32_t pipeline_typeck_expr_is_any_assign_kind_strict_minimal(int32_t kind) {
  if (kind == (int32_t)ast_ExprKind_EXPR_ASSIGN)
    return 1;
  return kind >= (int32_t)ast_ExprKind_EXPR_ADD_ASSIGN && kind <= (int32_t)ast_ExprKind_EXPR_SHR_ASSIGN ? 1 : 0;
}

static int32_t field_name_equal_strict_minimal(uint8_t *buf, int32_t len, const char *lit) {
  size_t lit_len;
  if (!buf || !lit || len <= 0)
    return 0;
  lit_len = strlen(lit);
  return len == (int32_t)lit_len && memcmp(buf, lit, lit_len) == 0 ? 1 : 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module,
                                                                        struct ast_ASTArena *arena, int32_t expr_ref,
                                                                        int32_t return_type_ref,
                                                                        struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  int32_t field_len;
  uint8_t field_name[64];
  uint8_t type_name[64];
  int32_t type_name_len;
  int32_t field_ty;
  int32_t field_off;
  int32_t prebind_len;
  uint8_t prebind_name[64];
  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, base_ref) == (int32_t)ast_ExprKind_EXPR_VAR &&
      ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, base_ref))) {
    prebind_len = pipeline_expr_var_name_len(arena, base_ref);
    if (prebind_len > 0 && prebind_len <= 63) {
      pipeline_expr_var_name_into(arena, base_ref, prebind_name);
      if (!ctx || ctx->current_func_index < 0 ||
          pipeline_module_func_param_type_ref_for_name(module, ctx->current_func_index, prebind_name, prebind_len) <= 0)
        pipeline_expr_set_resolved_type_ref(arena, base_ref,
                                            pipeline_type_find_or_alloc_named(arena, prebind_name, prebind_len));
    }
  }
  if (typeck_check_expr(module, arena, base_ref, return_type_ref, ctx) != 0)
    return -1;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return 0;
  field_len = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (field_len <= 0 || field_len > 63)
    return 0;
  pipeline_expr_field_access_name_into(arena, expr_ref, field_name);
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_SLICE) {
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (field_name_equal_strict_minimal(field_name, field_len, "length")) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref,
                                          pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_USIZE));
      return 0;
    }
    if (field_name_equal_strict_minimal(field_name, field_len, "data") && elem_ty > 0) {
      pipeline_expr_set_resolved_type_ref(
          arena, expr_ref, pipeline_type_find_or_alloc_compound(arena, (int32_t)ast_TypeKind_TYPE_PTR, elem_ty, 0));
      return 0;
    }
  }
  elem_ty = 0;
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (elem_ty > 0 && pipeline_type_kind_ord_at(arena, elem_ty) == (int32_t)ast_TypeKind_TYPE_NAMED)
      base_ty = elem_ty;
  }
  if (pipeline_type_kind_ord_at(arena, base_ty) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  type_name_len = pipeline_type_named_name_into(arena, base_ty, type_name);
  if (type_name_len <= 0)
    return 0;
  if (field_name_equal_strict_minimal(type_name, type_name_len, "ASTArena")) {
    if (field_name_equal_strict_minimal(field_name, field_len, "num_types") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_exprs") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_blocks") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_funcs")) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref,
                                          pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32));
      return 0;
    }
  }
  if (field_name_equal_strict_minimal(type_name, type_name_len, "Module")) {
    if (field_name_equal_strict_minimal(field_name, field_len, "num_funcs") ||
        field_name_equal_strict_minimal(field_name, field_len, "main_func_index") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_imports") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_top_level_lets") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_struct_layouts") ||
        field_name_equal_strict_minimal(field_name, field_len, "num_module_enums")) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref,
                                          pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32));
      return 0;
    }
  }
  field_off = typeck_get_field_offset_from_layout_deps(module, ctx, type_name, type_name_len, field_name, field_len);
  if (field_off >= 0)
    pipeline_expr_set_field_access_offset(arena, expr_ref, field_off);
  field_ty = typeck_get_field_type_ref_from_layout_deps(module, arena, ctx, type_name, type_name_len, field_name,
                                                        field_len);
  if (field_ty > 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, field_ty);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_impl_mega_c(struct ast_Module *module,
                                                                     struct ast_ASTArena *arena, int32_t expr_ref,
                                                                     int32_t return_type_ref,
                                                                     struct ast_PipelineDepCtx *ctx) {
  int32_t kind;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (pipeline_typeck_expr_is_any_assign_kind_strict_minimal(kind))
    return typeck_check_expr_assign(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_RETURN)
    return typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_PANIC)
    return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_MATCH)
    return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return pipeline_typeck_check_expr_field_access_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_INDEX)
    return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_CALL)
    return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_METHOD_CALL)
    return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind >= (int32_t)ast_ExprKind_EXPR_ADD && kind <= (int32_t)ast_ExprKind_EXPR_LOGOR)
    return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_NEG || kind == (int32_t)ast_ExprKind_EXPR_BITNOT ||
      kind == (int32_t)ast_ExprKind_EXPR_LOGNOT)
    return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == 52)
    return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_VAR)
    return typeck_check_expr_var(module, arena, expr_ref, ctx);
  if (kind == 54)
    return typeck_check_expr_as(module, arena, expr_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_STRUCT_LIT)
    return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == 58 || kind == 57)
    return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
  return 0;
}

__attribute__((weak)) int32_t pipeline_typeck_check_expr_impl_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena, int32_t expr_ref,
                                                                int32_t return_type_ref,
                                                                struct ast_PipelineDepCtx *ctx) {
  int32_t kind;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_check_expr_float_lit(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_LIT)
    return pipeline_typeck_check_expr_int_lit_c(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_BOOL_LIT)
    return typeck_check_expr_bool_lit(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_BREAK || kind == (int32_t)ast_ExprKind_EXPR_CONTINUE)
    return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_ENUM_VARIANT)
    return typeck_check_expr_enum_variant(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_IF || kind == (int32_t)ast_ExprKind_EXPR_TERNARY)
    return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_BLOCK)
    return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_MATCH)
    return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx);
  return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
}

__attribute__((weak)) int32_t pipeline_typeck_block_impl_bind_ctx_c(struct ast_PipelineDepCtx *ctx, int32_t block_ref) {
  int32_t saved;
  if (!ctx)
    return 0;
  saved = ctx->current_block_ref;
  ctx->current_block_ref = block_ref;
  return saved;
}

__attribute__((weak)) void pipeline_typeck_block_impl_restore_ctx_c(struct ast_PipelineDepCtx *ctx,
                                                                    int32_t saved_block_ref) {
  if (!ctx)
    return;
  ctx->current_block_ref = saved_block_ref;
}

__attribute__((weak)) void pipeline_typeck_block_impl_touch_ctx_block_c(struct ast_PipelineDepCtx *ctx,
                                                                        int32_t block_ref) {
  if (!ctx)
    return;
  ctx->current_block_ref = block_ref;
}

__attribute__((weak)) int32_t pipeline_typeck_check_block_impl_c(struct ast_Module *module,
                                                                 struct ast_ASTArena *arena, int32_t block_ref,
                                                                 int32_t return_type_ref,
                                                                 struct ast_PipelineDepCtx *ctx) {
  int32_t saved_block_ref;
  int32_t nc;
  int32_t nl;
  int32_t nlp;
  int32_t nfp;
  int32_t nif;
  int32_t nreg;
  int32_t nes;
  int32_t nso;
  int32_t fin0;
  int32_t i;
  if (!arena || !ctx || block_ref <= 0)
    return -1;
  saved_block_ref = ctx->current_block_ref;
  ctx->current_block_ref = block_ref;
  nc = ast_ast_block_num_consts(arena, block_ref);
  nl = ast_ast_block_num_lets(arena, block_ref);
  nlp = ast_ast_block_num_loops(arena, block_ref);
  nfp = ast_ast_block_num_for_loops(arena, block_ref);
  nif = ast_ast_block_num_if_stmts(arena, block_ref);
  nreg = ast_ast_block_num_regions(arena, block_ref);
  nes = ast_ast_block_num_expr_stmts(arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  fin0 = ast_ast_block_final_expr_ref(arena, block_ref);
  if (nso > 0) {
    for (i = 0; i < nso && i < 96; i++) {
      if (typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, i, nso, nc, nl, nes, nlp,
                                            nfp, nif, nreg) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
  } else {
    for (i = 0; i < nc; i++) {
      if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nl; i++) {
      if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nlp; i++) {
      if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nfp; i++) {
      if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nif; i++) {
      if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nreg; i++) {
      if (pipeline_typeck_check_block_one_region_c(module, arena, block_ref, i, return_type_ref, ctx) != 0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
    for (i = 0; i < nes && i < 32; i++) {
      if (typeck_check_expr(module, arena, ast_ast_block_expr_stmt_ref(arena, block_ref, i), return_type_ref, ctx) !=
          0) {
        ctx->current_block_ref = saved_block_ref;
        return -1;
      }
    }
  }
  if (typeck_check_block_final(module, arena, block_ref, return_type_ref, ctx, fin0) != 0) {
    ctx->current_block_ref = saved_block_ref;
    return -1;
  }
  ctx->current_block_ref = saved_block_ref;
  return 0;
}
