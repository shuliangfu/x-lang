/**
 * pipeline_glue_typeck_mid_fwd.c — Typeck forward-decl / extern shell after
 * field_access domain (BC 8.3 shell thin).
 *
 * wave1286 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations and externs that must be visible after
 * typeck_assign (field_access host-cc leaf retired 8.3.3) and before region_assign.
 * Definitions live in method_call / check_block / region_assign / check_expr
 * leaves included later in this TU, or typeck.o / seeds.
 *
 * Sub-clusters (order preserved):
 *  - top-level let name / find_or_alloc_named faces
 *  - module func / dep_ctx / import path+binding+select faces
 *  - asm_qual_sym_layer faces
 *  - import-binding map + dep return type static fwds
 *  - find_func_return_type + import path/binding/select equal statics
 *  - module main/func body/return/extern name faces
 *  - typeck_check_block_one_* / check_expr kind helpers (typeck.o)
 *  - resolve_call_func_index + call_struct_stack_escape static fwds
 *
 * Include site: pipeline_glue.c after typeck_assign (field_access #include removed)
 * and before pipeline_typeck_region_assign.c.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/* wave1189 G.7: pipeline_typeck_check_expr_index_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/** typeck_x_no_layout_partial：顶层 let 名比较。 */
extern int32_t typeck_top_level_let_name_equal(struct ast_Module *module, int32_t tl_idx, uint8_t *name,
                                               int32_t name_len);
extern int32_t typeck_name_equal(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len);
extern int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *module, int32_t idx);

/* wave1189 G.7: pipeline_typeck_check_expr_var_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). extern above (typeck_top_level_let_name_equal / typeck_name_equal
 * / typeck_find_or_alloc_named_type_ref / pipeline_module_top_level_let_type_ref)
 * remain for other glue.c callsites. PLATFORM: SHARED. */

/* wave1066 G.7: pipeline_typeck_module_num_imports_c migrated to
 * pipeline_typeck_assign.c EOF (unified import count reader). Static
 * same-TU: assign.c #include L11324 < def L11682 < all callsites
 * (L11627/11706/12111). Old fwd decl at L11618 deleted — def visible
 * from #include point. Deps: parser_get_module_num_imports (extern). */
/* wave1192 G.7: pipeline_typeck_import_segment_at_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster).
 * extern above (pipeline_module_import_path_len/byte_at) remain for
 * other glue.c callsites. PLATFORM: SHARED. */

extern int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern uint8_t pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_get_dep_arena_slot(int32_t i);
extern int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel,
                                                          int32_t off);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern void asm_qual_sym_layer_reset(void);
extern int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count(void);
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap);

/* wave1066: def migrated to pipeline_typeck_assign.c EOF. */

/* wave1192 G.7: pipeline_typeck_resolve_dep_index_for_import_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster).
 * PLATFORM: SHARED. */

/* wave1168 G.7: dep return type + entry module cluster (3 extern fns + 1 static)
 * migrated to pipeline_typeck_method_call.c EOF. Colocated with statics
 * pipeline_typeck_map_import_binding_named_to_caller_c (L2522) and
 * pipeline_typeck_dep_return_type_to_caller_arena_impl (L2563) already in
 * method_call.c.
 *
 * Static g_typeck_entry_module_for_dep_map moves to method_call.c (sole access
 * was from the 3 migrated functions).
 *
 * Forward decls:
 * - pipeline_typeck_get_dep_return_type_in_caller_arena_c: fwd decl at L770
 *   (before callsites L8033/8075 < method_call.c #include L9153)
 * - pipeline_typeck_set_entry_module_for_dep_map_c: callsites at L9469/9536
 *   > method_call.c #include L9153; no fwd decl needed.
 * - pipeline_typeck_dep_return_type_to_caller_arena_c: no glue.c callsites;
 *   extern, called from seed only.
 *
 * Static fwd decls below retained for callsites before method_call.c #include:
 * - pipeline_typeck_map_import_binding_named_to_caller_c (fwd decl below;
 *   callsite was in get_dep_return_type_in_caller_arena_c, now migrated)
 * - pipeline_typeck_dep_return_type_to_caller_arena_impl (fwd decl below;
 *   callsite was in dep_return_type_to_caller_arena_c + get_dep_return_type,
 *   both migrated)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */
static int32_t pipeline_typeck_map_import_binding_named_to_caller_c(struct ast_Module *entry_mod,
                                                                    int32_t dep_ix,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    uint8_t *nm, int32_t nlen);
static int32_t pipeline_typeck_dep_return_type_to_caller_arena_impl(struct ast_ASTArena *dep_arena,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena);

/* wave1169 G.7: func resolution cluster (4 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF. Colocated with method_call domain —
 * callee-name matching, func return-type lookup, and call-resolve write-back
 * are all sub-domains of method-call resolution.
 *
 * Forward decl for pipeline_typeck_find_func_return_type_in_module_by_name_c
 * below (before callsite at L8196 < method_call.c #include L9153).
 * Other 3 fns have no glue.c callsites; extern fwd decls in call_args.c
 * (L2479/L2483) cover asm-emit callsites before method_call.c #include.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */
int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);

/* wave1150 G.7: GLUE_TYPECK_IMPORT_BINDING/SELECT enum moved before
 * call_args.c #include (see ~L2237). Needed by glue_asm_resolve_call_target_
 * module_c migrated to call_args.c EOF. Single authority: mirrors ast.x
 * ImportKind. */

/* wave1085-1088 G.7: import path/binding/select name comparison helpers migrated
 * to pipeline_typeck_method_call.c EOF (import binding resolution sub-domain of
 * method_call + generic UFCS). Static (non-extern): same-TU — fwd decls below
 * (before all callsites L11893+) < method_call.c #include at L14053 < def EOF.
 * Deps: pipeline_module_import_path_byte_at /
 * pipeline_module_import_binding_name_len / pipeline_module_import_binding_name_byte_at /
 * pipeline_module_import_select_name_len / pipeline_module_import_select_name_byte_at
 * (all extern). PLATFORM: SHARED. */
static int32_t pipeline_typeck_import_path_segment_count_impl(const uint8_t *path, int32_t path_len);
static int32_t pipeline_typeck_import_path_slice_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t off,
                                                            int32_t seg_len, uint8_t *nm, int32_t nm_len);
static int32_t pipeline_typeck_import_binding_name_equal_impl(struct ast_Module *module, int32_t imp_ix, uint8_t *nm,
                                                              int32_t nm_len);
static int32_t pipeline_typeck_import_select_name_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t sel,
                                                             uint8_t *nm, int32_t nm_len);

/* wave1192 G.7: pipeline_typeck_resolve_whole_import_call_ret_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster). Colocated
 * with method_call domain — qualified import call resolution is a sub-domain
 * of method-call target resolution.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1155 G.7: pipeline_typeck_resolve_call_callee_return_type_c migrated to
 * pipeline_typeck_method_call.c EOF (colocated with resolve_call_func_index_c
 * wave1085-1094 — both resolve CALL callee targets; return-type twin of
 * func_index resolver). Extern (non-static): sole callsite at L10353 is AFTER
 * method_call.c #include at L10186 — visible via extern decl. Deps:
 * GLUE_TYPECK_IMPORT_BINDING/SELECT enum (L2241 < #include L10186), all other
 * deps extern/header-declared. PLATFORM: SHARED. */

extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t fi, uint8_t *dst);
extern void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t *name, int32_t name_len, int32_t kind);
extern int32_t typeck_validate_struct_layouts_zero_padding_glue(struct ast_Module *module, struct ast_ASTArena *arena);
/** typeck.o EMIT_HEAVY 子 helper；check_block_impl C 编排调用。 */
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
extern int32_t typeck_check_block_final(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t fin0);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let,
                                                 int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
/** typeck.o 简单 kind helper；pipeline_typeck_check_expr_impl_c 与 check_expr_impl X 共用。 */
extern int32_t typeck_check_expr_float_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_int_lit(struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref);
extern int32_t typeck_check_expr_bool_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_break_continue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t expr_ref, int32_t return_type_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_enum_variant(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_if_ternary(struct ast_Module *module, struct ast_ASTArena *arena,
                                            int32_t expr_ref, int32_t return_type_ref,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
/** typeck.o / typeck_x_no_layout 子 helper；kind 分派经 pipeline_typeck_check_expr_impl_mega_c 调用。 */
extern int32_t typeck_check_expr_return(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_panic(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_assign(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_field_access(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                              int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_index(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_var(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_match(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_call_arg(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t arg_i,
                                          int32_t num_args);
extern int32_t typeck_check_expr_call_resolve(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                             int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_binop(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_unary(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_addr_of(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_deref(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_as(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
/** typeck.o EMIT_HEAVY 桩仍导出 impl 符号；C orchestration 经 boundary wrapper 调用。 */
extern int32_t check_expr(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);

/* wave1282 G.7: XLANG_WEAK pipeline_typeck_validate_struct_layouts_zero_padding_c
 * migrated to pipeline_typeck_orch.c EOF (colocated with orch callers).
 * PLATFORM: SHARED — pure strong-symbol override unchanged. */

extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);

/** M-3 slice region assign / helpers: body in pipeline_typeck_region_assign.c (included below). */


/* wave1157 G.7: linear type use-once move tracking cluster (6 fns) migrated
 * to pipeline_typeck_check_block.c EOF.
 * wave1282 G.7: TYPECK_LINEAR_MOVED_MAX + g_typeck_linear_moved_* +
 * g_typeck_active_ctx also moved to check_block.c top (sole consumers of
 * those statics). PLATFORM: SHARED. */

/* wave1125-1129 G.7: TYPECK_STACK_LOCAL_PTR_LBL const migrated to
 * pipeline_typeck_region_assign.c (with the 5 stack-escape helpers that
 * are its sole consumers). Visible via #include at L10231. */

static int32_t pipeline_typeck_resolve_call_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                         int32_t call_expr_ref);
static int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t call_expr_ref,
                                                                struct ast_PipelineDepCtx *ctx);

/* wave1113 G.7: typeck_type_is_named_struct_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (struct layout registry name-match
 * helper, co-located with layout registry authority). Static (non-extern):
 * same-TU — struct_lit.c #include at L2051 < all callsites (L10422+ /
 * L11189+ / L11240+ / L11363+). PLATFORM: SHARED. */

/* wave1125-1129 G.7: WPO-S3 stack-escape analysis helpers (5 fns + const)
 * migrated to pipeline_typeck_region_assign.c EOF.
 * wave1282 G.7: pipeline_typeck_ptr_for_addr_of_operand_c also folded into
 * region_assign.c EOF — glue body + static fwd decls for
 * typeck_var_is_block_local_c / typeck_find_or_alloc_ptr_stack_local_c
 * removed (no remaining glue.c callsites before #include).
 * wave1133-1135 G.7: lval param ptr field cluster also in region_assign EOF.
 * PLATFORM: SHARED. */

