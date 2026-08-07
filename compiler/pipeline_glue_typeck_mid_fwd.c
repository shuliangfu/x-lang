/**
 * pipeline_glue_typeck_mid_fwd.c — Typeck forward-decl / extern shell after
 * field_access domain (BC 8.3 shell thin).
 *
 * wave1286 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations and externs that must be visible after
 * typeck_assign (field_access host-cc leaf retired 8.3.3).
 * wave257: region_assign Cap residual pure-owned leave — region faces on typeck_x.o.
 * Definitions live in method_call / check_block / check_expr leaves included later
 * in this TU, or typeck_x.o / seeds.
 *
 * Sub-clusters (order preserved):
 *  - top-level let name / find_or_alloc_named faces
 *  - module func / dep_ctx / import path+binding+select faces
 *  - asm_qual_sym_layer faces
 *  - import-binding map + dep return type static fwds
 *  - find_func_return_type + import path/binding/select equal statics
 *  - module main/func body/return/extern name faces
 *  - typeck_check_block_one_* / check_expr kind helpers (typeck.o)
 *  - wave248: overload resolve Cap faces pure (for_emit/pick); call_struct_stack_escape face
 *  - wave249: mono foundation Cap faces pure (named_is_module_type / call_arg_effective /
 *    type_tree_has_free_param) — bodies in typeck_x.o
 *  - wave250: generic type-args / try_infer / bounds Cap face pure
 *    (check_call_generic_type_args) — body in typeck_x.o
 *
 * Include site: pipeline_glue.c after typeck_fwd (assign/region_assign #include
 * retired wave256/wave257). Not a separate .o — host-cc via pipeline_x.o.
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

/* wave254 pure leave: dep map + find_func Cap faces live in typeck_x.o
 * (#[no_mangle]). Residual static map_import / dep_return_impl + public bodies
 * deleted (dual-export ban). Same-TU callers use extern Cap faces below.
 * PLATFORM: SHARED freestanding typeck dep map / find_func. */
extern void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module);
extern int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_dep_return_type_to_caller_arena_c(struct ast_ASTArena *dep_arena,
                                                                int32_t dep_return_type_ref,
                                                                struct ast_ASTArena *caller_arena);
extern int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);

/* wave1150 G.7: GLUE_TYPECK_IMPORT_BINDING/SELECT enum moved before
 * call_args.c #include (see ~L2237). Needed by glue_asm_resolve_call_target_
 * module_c migrated to call_args.c EOF. Single authority: mirrors ast.x
 * ImportKind. */

/* wave247 G.7 pure leave: import path/binding/select equal helpers +
 * resolve_call_callee_return_type_c live in typeck_x.o (pure twins / no_mangle).
 * Cap residual method_call: thin import_segment / resolve_dep / whole_import
 * faces only; dual-export ban on resolve_callee body. PLATFORM: SHARED. */

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

/* wave257 BC 8.3.1 host-cc leave: pipeline_typeck_region_assign.c deleted.
 * Cap faces (slice/return/stack_escape/scope_borrow/allocator/call_slice *_c)
 * live on typeck_x.o only. Extern decls below for residual same-TU callers
 * (check_expr mega assign/return/call arms). PLATFORM: SHARED. */
extern int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena,
                                                            int32_t site_expr_ref, int32_t expect_ref,
                                                            int32_t src_ref);
extern int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module,
                                                                  struct ast_ASTArena *arena,
                                                                  int32_t site_expr_ref, int32_t left_ref,
                                                                  int32_t right_ref,
                                                                  struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_scope_borrow_assign_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena,
                                                            int32_t site_expr_ref, int32_t left_ref,
                                                            int32_t right_ref,
                                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_scope_borrow_return_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena,
                                                            int32_t site_expr_ref, int32_t op_ref,
                                                            int32_t return_type_ref,
                                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_allocator_region_assign_c(struct ast_Module *module,
                                                               struct ast_ASTArena *arena,
                                                               int32_t site_expr_ref, int32_t left_ref,
                                                               struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_allocator_region_return_c(struct ast_ASTArena *arena,
                                                               int32_t site_expr_ref,
                                                               int32_t return_type_ref);
extern int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena,
                                                           int32_t ret_site_ref, int32_t op_ref,
                                                           int32_t func_return_ref);
/* wave246 pure leave: body on typeck_x.o (was residual region_assign extern). */
extern int32_t pipeline_typeck_check_return_slice_region_in_scope_c(struct ast_ASTArena *arena,
                                                                    int32_t site_expr_ref,
                                                                    int32_t return_type_ref,
                                                                    struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module,
                                                         struct ast_ASTArena *arena,
                                                         int32_t call_expr_ref,
                                                         struct ast_PipelineDepCtx *ctx);


/* wave1157 G.7: linear type use-once move tracking cluster (6 fns) migrated
 * to pipeline_typeck_check_block.c EOF.
 * wave1282 G.7: TYPECK_LINEAR_MOVED_MAX + g_typeck_linear_moved_* +
 * g_typeck_active_ctx also moved to check_block.c top (sole consumers of
 * those statics). PLATFORM: SHARED. */

/* wave1125-1129 / wave257: TYPECK_STACK_LOCAL_PTR_LBL + stack-escape helpers
 * retired with region_assign residual (wave245 ptr_for_addr pure leave). */

/* wave248 pure leave: overload resolve Cap faces → typeck_x.o (for_emit / pick).
 * Residual second score path deleted; no static resolve_call_func_index_c.
 * Callers use pipeline_typeck_resolve_call_func_index_for_emit_c (pure). */
/* wave242: public residual face (pure scan tree + check_expr call it).
 * wave244 pure leave: body in typeck_x.o; residual may keep prototype only. */
extern int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t call_expr_ref,
                                                                struct ast_PipelineDepCtx *ctx);

/* wave154: pure export (was static in struct_lit.c). Residual typeck Cap-calls. */
extern int32_t typeck_type_is_named_struct_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref);
extern int32_t typeck_layout_index_for_named_type_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref);
extern int32_t typeck_struct_layouts_same_shape_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t la, int32_t lb);
/* wave1113 G.7: typeck_type_is_named_struct_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (struct layout registry name-match
 * helper, co-located with layout registry authority). Static (non-extern):
 * same-TU — struct_lit.c #include at L2051 < all callsites (L10422+ /
 * L11189+ / L11240+ / L11363+). PLATFORM: SHARED. */

/* wave1125-1129 / wave1282 / wave1133-1135 G.7: WPO-S3 stack-escape helpers
 * + ptr_for_addr once lived in region_assign.c EOF.
 * wave245 pure leave: pipeline_typeck_ptr_for_addr_of_operand_c → typeck_x.o
 * (dual-export ban); residual deleted stack_local helpers + dead store-scan.
 * Type-pool face pipeline_type_find_or_alloc_ptr (ast_pool_type.c) stamps
 * stack_local *T. PLATFORM: SHARED. */

