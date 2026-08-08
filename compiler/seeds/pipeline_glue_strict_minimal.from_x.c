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
 * thin (product PREFER_X_O; linked before strict_minimal suffix) — dual-export ban.
 * wave303 G.7 8.3.6 leave: find_func_return_type_*_call overload chain → typeck_x.o
 * STRONG (score + by_name_overload + Cap face); dual-export ban — no residual body.
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

/* wave303 G.7 8.3.6 leave: find_func_return_type_*_call overload chain deleted.
 * Live STRONG = typeck_x.o (typeck_overload_arg_param_score + by_name_overload +
 * pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal).
 * dual-export ban — do not re-define here (product link: typeck_x before this seed).
 * PLATFORM: SHARED freestanding 8.3.6 leave.
 */

/* wave301: pipeline_expr_is_func_param_at_strict_minimal deleted (no product U;
 * only served dual check_expr paths already STRONG on runtime_pipeline_abi). */

/* wave289 G.7: pipeline_codegen_emit_float_lit_c Cap residual host-cc leave.
 * Live = runtime_pipeline_abi seed ALWAYS (WAVE289_CODEGEN_OUTBUF_ALWAYS).
 * Dual-export ban: do not re-define here (Darwin/strict paths resolve via pipeline_abi).
 * PLATFORM: SHARED freestanding Cap leave.
 */
