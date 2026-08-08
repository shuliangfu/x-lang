/* seeds/pipeline_glue_strict_minimal.from_x.c — G-02f-222 type_eq/parse_diag; G-02f-221 linear; G-02f-11 product TU
 * G-02f-135 true .x pure helpers.
 * G-02f-123 true .x pure helpers.
 * G-02f-119 true .x pure helpers.
 * G-02f-113 true .x pure helpers.
 * G-02f-110 helper gates.
 * G-02f-108 helper gates.
 * G-02f-107 helper gates.
 * Product object from this seed; logic still C until full .x port.
 */
/**
 * pipeline_glue_strict_minimal.c — B-strict 链最小 glue（不含 ast_pool / pipeline_glue_types.inc）
 *
 * strict_core partial 已含 pipeline_x 几乎全部符号；本 TU 仅补 runtime 入口与裸名 parse_into_init。
 */
/* wave300 G.7 8.3.6 slice: deleted 28 dual-export XLANG_WEAK typeck Cap twins
 * already STRONG on typeck_x.o (product link order: typeck_x before strict_minimal).
 * dual-export ban — no second body for these faces in seed. PLATFORM: SHARED.
 * wave301 G.7 8.3.6 slice: deleted dual-export WEAK already STRONG on
 * runtime_pipeline_abi.o / driver_x.o / pipeline_x.o (product link: abi+driver before
 * strict_minimal suffix) plus dead helpers only used by those twins.
 * wave302 G.7 8.3.6 slice: parse_commit_pre/post moved to runtime_driver_diagnostic
 * thin (product PREFER_X_O; linked before strict_minimal suffix) — dual-export ban;
 * residual seed faces: find_func_return_type_*_call overload chain only.
 * PLATFORM: SHARED freestanding 8.3.6.
 */
#include <xlang_weak.h>
#include <stdint.h>
#include <stddef.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diag.h"

/* wave240 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — strict_minimal residual raw getenv → same face as pipeline_glue.c.
 */
extern char *link_abi_getenv(const char *name);
/* wave248 G.7: shell via public pure thin link_abi_system (wave224 → _impl host system);
 * not raw libc system. Cap residual host system stays only link_abi_system_impl.
 * PLATFORM: SHARED — debug curl residual (try_propagate report) → same face as pipeline_glue.c.
 */
extern int link_abi_system(const char *cmd);

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
  uint8_t current_codegen_prefix_mirror[128];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[128];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[128];
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
struct xlang_slice_uint8_t {
  uint8_t *data;
  int32_t length;
};
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

/* wave302: parser_diagnostic_parse_commit_pre/post deleted — STRONG on
 * runtime_driver_diagnostic.o (thin.x pure / cold rest under #ifndef FROM_X).
 * Product link: diagnostic before strict_minimal suffix. dual-export ban.
 * PLATFORM: SHARED freestanding 8.3.6 leave. */
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
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module *module, int32_t li, int32_t j,
                                                         uint8_t *out64);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module *module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module *module, int32_t idx, uint8_t *out64);
/* wave465: enum name probe so type-param ambient fill does not swallow real enum fields */
extern int32_t pipeline_module_enum_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
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
/* C5-enum-variant: read-only accessors used by the strict-minimal whitelist
 * (pipeline_typeck_const_expr_ref_strict_minimal). The active-module getter
 * returns the typeck module currently in scope (defined in pipeline_glue.c);
 * the marker and the is_enum_variant probe live in ast_pool.c / pipeline_glue.c
 * and are linked at g05 time. Declared here because the seed TU does not see
 * the headers that originally export them. PLATFORM: SHARED. */
extern struct ast_Module *pipeline_typeck_active_module_c(void);
extern void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
/* C5-ternary-if: read-only accessors for EXPR_IF / EXPR_TERNARY field layout
 * (if_cond_ref / if_then_ref / if_else_ref). Both kinds share the same layout
 * (see ast_pool.c::asm_wpo_collect_edges_from_expr L14836-14844); defined in
 * pipeline_glue.c, linked at g05 time. Required so the strict-minimal whitelist
 * can recurse into cond/then/else for `const Y = cond ? a : b;` and
 * `const Y = if (cond) { a } else { b };`. PLATFORM: SHARED. */
extern int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
/* C5-block: read-only accessor for EXPR_BLOCK's block_ref field. The if-expr
 * parser (parser_asm_if_expr_slice.inc::parser_asm_wrap_block_ref_as_expr_c)
 * wraps each branch's parse_block result as an EXPR_BLOCK node holding the
 * block_ref, so EXPR_IF recursion always reaches EXPR_BLOCK children.
 * Without this whitelist entry, `const Y = if (c) { 100 } else { 200 };`
 * is rejected at T001 even when c/100/200 are all const. PLATFORM: SHARED. */
extern int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
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
/*
 * wave494: generic method_call UFCS — exported from pipeline_glue.c (G.7
 * single authority). Pattern-unifies formal self param with concrete receiver
 * type and substitutes the return type. Called after non-generic UFCS fails.
 * PLATFORM: SHARED typeck.
 */
extern int32_t pipeline_typeck_method_call_generic_ufcs_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                            int32_t expr_ref, int32_t base_ty,
                                                            uint8_t *method_nm, int32_t method_nlen,
                                                            int32_t num_args);
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
/* C5-block: wrapper for pipeline_block_expr_stmt_ref (defined in pipeline_glue.c
 * at L23328). Used by EXPR_BLOCK CTFE whitelist to fetch the single expr-stmt
 * when the parser has normalized `{ expr }` (final_expr_ref=0, num_expr_stmts=1,
 * expr_stmts[0]=expr). Declared separately from ast_ast_block_expr_stmt_ref
 * above because the two are distinct symbols in pipeline_x.o — the
 * ast_pipeline_* variant is the glue wrapper, ast_ast_* is the direct accessor. */
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_stmt_order_kind(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern int32_t pipeline_block_region_label_len(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx);
extern void pipeline_block_region_label_copy64(struct ast_ASTArena *arena, int32_t block_ref, int32_t idx,
                                              uint8_t *out64);
extern int32_t pipeline_dep_ctx_scope_region_push_c(struct ast_PipelineDepCtx *ctx, uint8_t *label,
                                                   int32_t label_len);
extern void pipeline_dep_ctx_scope_region_pop_c(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_scope_region_len_at(struct ast_PipelineDepCtx *ctx);
/*
 * PLATFORM: SHARED — 权威实现在 ast_pool.c（经 pipeline_x / Darwin filtered 导出）。
 * 禁止 weak 恒 -1 空桩：Darwin g05 用 bootstrap_seed_pipeline_filtered.o 时，
 * omit_syms 含本 .o 与 pipeline_x 的交集符号，会把 pipeline 侧真 set_let 私有化，
 * 仅剩 weak 空桩为 external → stamp 永远失败 → AL-06 dual_escape 误报 type mismatch
 * （Linux 因 pipeline_x.o 全量导出 strong 盖过 weak，故不暴露）。
 * 只保留 extern：filtered keep_syms 保留真实现，stamp 可写回 let.type_ref。
 */
extern int32_t pipeline_block_set_let_type_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                              int32_t type_ref);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                     struct xlang_slice_uint8_t *source);
extern int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                   struct xlang_slice_uint8_t *source);
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

/* wave300: TYPECK_LINEAR_MOVED_* BSS + name_already_moved helper deleted with
 * dual-export WEAK linear_reset/use_var/accepts_init (STRONG on typeck_x.o).
 * PLATFORM: SHARED dual-export ban. */

/** runtime 期望的程序入口名。 */
extern int32_t driver_run_compiler_full(int32_t argc, char **argv);

/* codegen_x_ast：唯一权威在 codegen_x.o（codegen.x）。
 * 禁止在此提供 weak return(-1) 桩——产品链同时有 codegen_x.o 与本 glue 时，
 * 多 weak 解析可能选中桩，导致全部 -E 失败（codegen failed at entry / out_len=0）。 */

/** runtime 调用的裸名 parse_into_init → partial 导出的 parser_parse_into_init。 */
extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);

/** strict minimal 不链 glue_standalone 时，runtime / pipeline_x 仍需要这两个默认桥接入口。 */
extern int32_t pipeline_lsp_diag_parse_typeck_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         uint8_t *source_data, int32_t source_len,
                                                         struct ast_PipelineDepCtx *ctx);


/* wave254 pure leave: set_entry / get_dep Cap faces → typeck_x.o only.
 * Dual-export ban — no residual BSS / second body in strict_minimal seed. */
extern void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module);
extern int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    struct ast_PipelineDepCtx *ctx);

extern int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
/* wave300: dual WEAK twins deleted — remaining strict dispatch calls STRONG typeck_x faces. */
extern int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t expr_ref, int32_t return_type_ref,
                                                        struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_expr_int_lit_c(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t fi, int32_t pi);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_visibility_allow_func(struct ast_Module *m, int32_t fi, int32_t cross_module);

#ifndef XLANG_PIPELINE_GLUE_STRICT_MINIMAL_FROM_X
/* wave301: residual overload chain (find_func_return_type_*_call) — product U from typeck_x;
 * dual check_expr WEAK twins deleted (STRONG on runtime_pipeline_abi). PLATFORM: SHARED. */
int32_t pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len, int32_t from_dep_index,
    int32_t want_arity, int32_t call_expr_ref, int32_t is_method, struct ast_PipelineDepCtx *ctx,
    int32_t *func_index_out);

/**
 * W-heap-overload：在同名候选中按 CALL/METHOD_CALL 实参类型打分选最优。
 * call_expr_ref 为 METHOD_CALL 或 CALL；args 经 method_call_* / call_* accessor。
 * 跨模块形参经 get_dep_return_type 映到 caller 后再比。
 */
static int32_t pipeline_typeck_overload_arg_score_strict_minimal(struct ast_ASTArena *caller_arena,
                                                                  int32_t call_expr_ref, int32_t is_method,
                                                                  int32_t arg_i, int32_t param_ty_raw,
                                                                  int32_t from_dep_index,
                                                                  struct ast_PipelineDepCtx *ctx) {
  int32_t arg_ref;
  int32_t arg_ty;
  int32_t param_ty;
  int32_t as_tgt;
  int32_t ak;
  int32_t pk;
  if (!caller_arena || call_expr_ref <= 0 || arg_i < 0)
    return -1;
  if (is_method)
    arg_ref = pipeline_expr_method_call_arg_ref(caller_arena, call_expr_ref, arg_i);
  else
    arg_ref = pipeline_expr_call_arg_ref(caller_arena, call_expr_ref, arg_i);
  if (arg_ref <= 0)
    return -1;
  param_ty = param_ty_raw;
  if (from_dep_index >= 0) {
    param_ty = pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, param_ty_raw, caller_arena, ctx);
    if (param_ty == 0)
      return -1;
  }
  if (param_ty <= 0)
    return -1;
  arg_ty = pipeline_expr_resolved_type_ref(caller_arena, arg_ref);
  if (arg_ty > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, arg_ty, param_ty) != 0)
    return 1000;
  /* EXPR_AS = 54 */
  if (pipeline_expr_kind_ord_at(caller_arena, arg_ref) == 54) {
    as_tgt = pipeline_expr_as_target_type_ref_at(caller_arena, arg_ref);
    if (as_tgt > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, as_tgt, param_ty) != 0)
      return 1000;
  }
  /*
   * 【Why 根源】整型字面量默认解析为 i32；若此处对 i64/u32/… 形参给 -1，则
   *   store(*i64, 1000) / fetch_add(*u32, 8) 全部候选被淘汰 → 回退首同名 i32
   *   （atomic 生成 std_atomic_store_i32_ptr_i32(&(y),1000) → 指针类型错误）。
   * 【Invariant】EXPR_LIT(0) 可弱匹配任意整数 TypeKind（I32/U8/U32/U64/I64/USIZE/ISIZE）；
   *   分 100 < 精确 1000，故 *i64 精确 + lit 弱 = 1100 胜过误匹配。
   * 不把非 lit 的 i32 变量自动抬到 i64（避免静默变宽）。
   */
  if (pipeline_expr_kind_ord_at(caller_arena, arg_ref) == 0) {
    pk = pipeline_type_kind_ord_at(caller_arena, param_ty);
    /* wave670: keyword null only → *T (G.7 ≡ typeck.x / pipeline_expr_is_null_keyword_c). */
    {
      extern int32_t pipeline_expr_is_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref);
      if (pipeline_expr_is_null_keyword_c(caller_arena, arg_ref) != 0) {
        if (pk == 9)
          return 100;
        return -1;
      }
    }
    if (pk == 0 || pk == 2 || pk == 3 || pk == 4 || pk == 5 || pk == 6 || pk == 7)
      return 100;
    /* wave668: bare EXPR_LIT 0 → *T (TYPE_PTR=9). */
    if (pk == 9 && pipeline_expr_int64_val_at(caller_arena, arg_ref) == 0)
      return 100;
  }
  if (arg_ty > 0) {
    ak = pipeline_type_kind_ord_at(caller_arena, arg_ty);
    pk = pipeline_type_kind_ord_at(caller_arena, param_ty);
    /*
     * PLATFORM: SHARED — integer widen (align typeck_integer_widen_ok): i32→usize so
     * heap.alloc(al, capacity:i32) matches alloc(Allocator, usize)→*u8 instead of
     * eliminating the 2-arg candidate and falling back to first alloc(i32)→*u64.
     * Score 100 < exact 1000.
     */
    if ((pk == 0 || pk == 2 || pk == 3 || pk == 4 || pk == 5 || pk == 6 || pk == 7) &&
        (ak == 0 || ak == 2 || ak == 3 || ak == 4 || ak == 5 || ak == 6 || ak == 7)) {
      /* Mirror typeck_integer_widen_ok (wave311–312). Kinds: i32=0 u8=2 u32=3 u64=4 i64=5 usize=6 isize=7. */
      if (pk == ak)
        return 100;
      /* u8 → u32/u64/usize/i32/i64/isize */
      if (ak == 2 && (pk == 3 || pk == 4 || pk == 6 || pk == 0 || pk == 5 || pk == 7))
        return 100;
      /* i32 → i64/u32/u64/usize/isize/u8 */
      if (ak == 0 && (pk == 5 || pk == 3 || pk == 4 || pk == 6 || pk == 7 || pk == 2))
        return 100;
      /* u32 → u64/i64/usize/isize */
      if (ak == 3 && (pk == 4 || pk == 5 || pk == 6 || pk == 7))
        return 100;
      /* usize↔u64, isize↔i64 (LP64 same-width) */
      if ((ak == 6 && pk == 4) || (ak == 4 && pk == 6) || (ak == 7 && pk == 5) || (ak == 5 && pk == 7))
        return 100;
    }
    /*
     * wave313 Cap residual: TYPE_NAMED=8 i8/i16/u16 integer widen score.
     * Mirror typeck_integer_widen_ok_refs (name-based family tags 10/11/12).
     * PLATFORM: SHARED — G.7 align typeck.x + typeck_gen seed.
     *
     * wave363 L4: pipeline_type_named_name_into always memcpy's the full Type.name[128]
     * (see pipeline_glue.c). Prior pnm[8]/anm[8] stack-smashed on any TYPE_NAMED score
     * path (String/StrView len overloads → __stack_chk_fail → silent exit 127).
     * Buffers must be 128 bytes (G.7 out128 contract, wave577 Cap).
     */
    if (pk == 8 || ak == 8) {
      uint8_t pnm[128];
      uint8_t anm[128];
      int32_t pnl = 0;
      int32_t anl = 0;
      int32_t pf = -1;
      int32_t af = -1;
      if (pk == 0 || pk == 2 || pk == 3 || pk == 4 || pk == 5 || pk == 6 || pk == 7)
        pf = pk;
      else if (pk == 8) {
        pnl = pipeline_type_named_name_into(caller_arena, param_ty, pnm);
        if (pnl == 2 && pnm[0] == 105 && pnm[1] == 56)
          pf = 10; /* i8 */
        else if (pnl == 3 && pnm[0] == 105 && pnm[1] == 49 && pnm[2] == 54)
          pf = 11; /* i16 */
        else if (pnl == 3 && pnm[0] == 117 && pnm[1] == 49 && pnm[2] == 54)
          pf = 12; /* u16 */
      }
      if (ak == 0 || ak == 2 || ak == 3 || ak == 4 || ak == 5 || ak == 6 || ak == 7)
        af = ak;
      else if (ak == 8) {
        anl = pipeline_type_named_name_into(caller_arena, arg_ty, anm);
        if (anl == 2 && anm[0] == 105 && anm[1] == 56)
          af = 10;
        else if (anl == 3 && anm[0] == 105 && anm[1] == 49 && anm[2] == 54)
          af = 11;
        else if (anl == 3 && anm[0] == 117 && anm[1] == 49 && anm[2] == 54)
          af = 12;
      }
      if (pf >= 0 && af >= 0) {
        if (pf == af)
          return 100;
        /* i8 → i16/u16/u8 + first-class wider */
        if (af == 10 && (pf == 11 || pf == 12 || pf == 2 || pf == 0 || pf == 3 || pf == 4 || pf == 5 ||
                         pf == 6 || pf == 7))
          return 100;
        /* i16 → u16/u8 + first-class wider */
        if (af == 11 && (pf == 12 || pf == 2 || pf == 0 || pf == 3 || pf == 4 || pf == 5 || pf == 6 ||
                         pf == 7))
          return 100;
        /* u16 → u8 + first-class wider */
        if (af == 12 && (pf == 2 || pf == 0 || pf == 3 || pf == 4 || pf == 5 || pf == 6 || pf == 7))
          return 100;
        /* first-class / peer → NAMED dest (narrow store) */
        if (pf == 10 && (af == 2 || af == 0 || af == 11 || af == 12))
          return 100;
        if (pf == 11 && (af == 2 || af == 0 || af == 12 || af == 3))
          return 100;
        if (pf == 12 && (af == 2 || af == 0 || af == 11 || af == 3))
          return 100;
      }
    }
    /* TYPE_ARRAY=10 → TYPE_PTR=9：buf:u8[N] 传 *u8 时须计为可赋，否则全部 overload 评分失败回退首同名(i32)。 */
    if (ak == 10 && pk == 9) {
      int32_t ae = pipeline_type_elem_ref_at(caller_arena, arg_ty);
      int32_t pe = pipeline_type_elem_ref_at(caller_arena, param_ty);
      if (ae > 0 && pe > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae, pe) != 0)
        return 1000;
    }
    /* TYPE_PTR=9：*u8 与 *i32 同 kind 但元素不同，不得给分，否则 best 平局回退首同名(i32)
     *（sort_impl.sort(*u8) 误调 sort_i32 → abort）。须比 elem。 */
    if (ak == 9 && pk == 9) {
      int32_t ae = pipeline_type_elem_ref_at(caller_arena, arg_ty);
      int32_t pe = pipeline_type_elem_ref_at(caller_arena, param_ty);
      if (ae > 0 && pe > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae, pe) != 0)
        return 1000;
      return -1;
    }
    /* wave672: TYPE_ARRAY/SLICE same-kind requires matching elem (bool[N]≠i32[N]). */
    if (ak == 10 && pk == 10) {
      int32_t ae = pipeline_type_elem_ref_at(caller_arena, arg_ty);
      int32_t pe = pipeline_type_elem_ref_at(caller_arena, param_ty);
      int32_t asz = pipeline_type_array_size_at(caller_arena, arg_ty);
      int32_t psz = pipeline_type_array_size_at(caller_arena, param_ty);
      if (ae > 0 && pe > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae, pe) != 0
          && (asz <= 0 || psz <= 0 || asz == psz))
        return 1000;
      return -1;
    }
    if (ak == 11 && pk == 11) {
      int32_t ae = pipeline_type_elem_ref_at(caller_arena, arg_ty);
      int32_t pe = pipeline_type_elem_ref_at(caller_arena, param_ty);
      if (ae > 0 && pe > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae, pe) != 0)
        return 1000;
      return -1;
    }
    if (ak == pk && ak != 0)
      return 1;
    return -1;
  }
  return -1;
}

static int32_t pipeline_typeck_pick_func_index_by_name_args_strict_minimal(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, int32_t want_arity, int32_t call_expr_ref, int32_t is_method,
    struct ast_PipelineDepCtx *ctx) {
  int32_t j;
  int32_t first_match = -1;
  int32_t best_ix = -1;
  int32_t best_score = -1;
  /* PLATFORM: SHARED — expected_ret is a *tie-break only* (never fold +5000 into arg score).
   * Outer function return (e.g. main i32) is threaded as return_type_ref through if/binop into
   * CALL expected_ret; adding 5000 let get_Vec_i32 beat exact Vec_u16 (vec_u16 BLD001).
   * Keep: zero-arg let v: Vec_u8 = vec.new() still wins via expect_match when arg scores tie. */
  int32_t best_expect_match = -1;
  int32_t num_args;
  if (!mod || !name || name_len <= 0)
    return -1;
  num_args = want_arity;
  if (call_expr_ref > 0 && caller_arena) {
    if (is_method)
      num_args = pipeline_expr_method_call_num_args_at(caller_arena, call_expr_ref);
    else
      num_args = pipeline_expr_call_num_args_at(caller_arena, call_expr_ref);
  }
  for (j = 0; j < mod->num_funcs; j++) {
    int32_t nparams;
    int32_t ai;
    int32_t score;
    int32_t matched;
    int32_t expect_match;
    if (!pipeline_module_func_name_equal_at(mod, j, name, name_len))
      continue;
    if (first_match < 0)
      first_match = j;
    nparams = pipeline_module_func_num_params_at(mod, j);
    if (num_args >= 0 && nparams != num_args)
      continue;
    if (call_expr_ref <= 0 || !caller_arena) {
      /* 仅 arity：取首个同 arity（旧行为）。 */
      return j;
    }
    score = 0;
    matched = 1;
    expect_match = 0;
    for (ai = 0; ai < nparams; ai++) {
      int32_t param_raw = pipeline_module_func_param_type_ref_at(mod, j, ai);
      int32_t sc = pipeline_typeck_overload_arg_score_strict_minimal(
          caller_arena, call_expr_ref, is_method, ai, param_raw, from_dep_index, ctx);
      if (sc < 0) {
        matched = 0;
        break;
      }
      score += sc;
    }
    /* PLATFORM: SHARED — expected return: secondary key only (zero-arg / arg-score ties). */
    if (matched) {
      extern int32_t typeck_overload_expected_ret_peek(void);
      int32_t expect_ty = typeck_overload_expected_ret_peek();
      int32_t rtr = pipeline_module_func_return_type_at(mod, j);
      if (expect_ty > 0 && rtr > 0) {
        int32_t mapped = rtr;
        if (from_dep_index >= 0)
          mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, rtr, caller_arena, ctx);
        if (mapped > 0) {
          int eq = pipeline_typeck_type_refs_equal_c(caller_arena, mapped, expect_ty);
          /* Last-segment NAMED: bare Vec_u8 vs vec.Vec_u8 (strict_minimal equal may be exact-only). */
          if (!eq) {
            extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *a, int32_t tr, uint8_t *buf);
            uint8_t na[128], nb[128];
            int32_t la = pipeline_type_named_name_into(caller_arena, mapped, na);
            int32_t lb = pipeline_type_named_name_into(caller_arena, expect_ty, nb);
            if (la > 0 && lb > 0) {
              int32_t sa = 0, sb = 0, i;
              for (i = 0; i < la; i++) if (na[i] == (uint8_t)'.') sa = i + 1;
              for (i = 0; i < lb; i++) if (nb[i] == (uint8_t)'.') sb = i + 1;
              if ((la - sa) == (lb - sb) && (la - sa) > 0) {
                eq = 1;
                for (i = 0; i < la - sa; i++) if (na[sa + i] != nb[sb + i]) { eq = 0; break; }
              }
            }
          }
          if (eq)
            expect_match = 1;
        }
      }
    }
    if (matched &&
        (score > best_score || (score == best_score && expect_match > best_expect_match))) {
      best_score = score;
      best_expect_match = expect_match;
      best_ix = j;
    }
  }
  if (best_ix >= 0)
    return best_ix;
  return first_match;
}
#endif /* XLANG_PIPELINE_GLUE_STRICT_MINIMAL_FROM_X */


#ifndef XLANG_PIPELINE_GLUE_STRICT_MINIMAL_FROM_X
/* G-02f-222 thin+rest：DIRECT 模式，thin 直接实现 */
/* G-02f-140：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* W-heap-overload：call_expr_ref>0 时按实参类型分派（METHOD_CALL/CALL）。 */
int32_t pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len, int32_t from_dep_index,
    int32_t want_arity, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out) {
  return pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
      mod, caller_arena, name, name_len, from_dep_index, want_arity, 0, 0, ctx, func_index_out);
}

int32_t pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len, int32_t from_dep_index,
    int32_t want_arity, int32_t call_expr_ref, int32_t is_method, struct ast_PipelineDepCtx *ctx,
    int32_t *func_index_out) {
  int32_t func_ix;
  int32_t ret_ty;
  func_ix = pipeline_typeck_pick_func_index_by_name_args_strict_minimal(
      mod, caller_arena, name, name_len, from_dep_index, want_arity, call_expr_ref, is_method, ctx);
  if (func_ix < 0)
    return 0;
  /* 模块导出：strict 下跨模块仅 is_export（compat/warn 放行）。 */
  if (from_dep_index >= 0 && pipeline_visibility_allow_func(mod, func_ix, 1) == 0)
    return 0;
  if (func_index_out)
    *func_index_out = func_ix;
  ret_ty = pipeline_module_func_return_type_at(mod, func_ix);
  if (from_dep_index < 0)
    return ret_ty;
  return pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, ret_ty, caller_arena, ctx);
}
#endif /* XLANG_PIPELINE_GLUE_STRICT_MINIMAL_FROM_X */


/* wave301: pipeline_expr_is_func_param_at_strict_minimal deleted (no product U;
 * only served dual check_expr paths already STRONG on runtime_pipeline_abi). */

/* wave289 G.7: pipeline_codegen_emit_float_lit_c Cap residual host-cc leave.
 * Live = runtime_pipeline_abi seed ALWAYS (WAVE289_CODEGEN_OUTBUF_ALWAYS).
 * Dual-export ban: do not re-define here (Darwin/strict paths resolve via pipeline_abi).
 * PLATFORM: SHARED freestanding Cap leave.
 */
