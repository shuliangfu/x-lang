/**
 * pipeline_glue_typeck_fwd.c — Typeck forward-decl / extern shell before assign
 * domain (BC 8.3 shell thin).
 *
 * wave1286 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations and externs that must be visible after
 * pipeline_ast_forwarders.c and before pipeline_typeck_assign.c.
 * Definitions live in typeck domain leaves included later in this TU
 * (coerce_init / check_expr / check_block / method_call / region_assign / …)
 * or other product TUs (typeck.o / seeds).
 *
 * Sub-clusters (order preserved):
 *  - type_refs_equal / type_ref_is_bool / expr_type_ref public wrappers
 *  - named unqual / type_refs_equal static impls + type alias resolve
 *  - float/integer widen gates + int_family + scratch64
 *  - return operand coerce + typeck diagnostic faces
 *  - check_expr sub-class / try_propagate / coerce_init lit family fwds
 *  - unsafe_depth / region unsafe helpers
 *
 * Include site: pipeline_glue.c immediately after pipeline_ast_forwarders.c
 * and before pipeline_typeck_assign.c.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/* wave1194 G.7: ast_ast_arena_type_get/set + ast_ast_arena_expr_get/set
 * (4 fns) migrated to ast_pool_arena.c EOF (same-TU #include via
 * ast_pool.c L886). Colocated with block/func get/set (wave1183) +
 * ast_arena_* twin forwarders. Forward decls in ast_pool_arena.c
 * replaced by actual definitions; ast_arena_* twins now delegate to
 * same-file definitions. PLATFORM: SHARED. */
/* wave1183 G.7: ast_ast_arena_*_get/set + ast_arena_*_get/set forwarder
 * cluster (14 fns) migrated to ast_pool_arena.c EOF (same-TU #include).
 * Members: block/func get/set (ast_ast_ prefix) + type/expr/block/func
 * get/set (ast_ prefix, delegates to ast_ast_ twins).
 * All pure forwarders to pipeline_arena_*_get_copy/_set_copy impls. */

/* wave1195 G.7: ast_ref_is_null migrated to ast_pool_arena.c EOF
 * (same-TU #include via ast_pool.c L886). Colocated with arena
 * accessors. PLATFORM: SHARED. */

/* wave1183 G.7: ast_ast_arena_patch + ast_ast_block_* getters cluster
 * (20 fns) migrated to ast_pool_block.c EOF (same-TU #include already exists).
 * Members: patch_block_parent_links + num_consts/lets/loops/for_loops/if_stmts/
 * regions/expr_stmts/stmt_order + region_body_ref + stmt_order_kind/idx +
 * const_init/type_ref + let_init/type_ref + expr_stmt_ref + final_expr_ref.
 * All pure forwarders to pipeline_block_ / pipeline_patch_block_parent_links. */

/* wave1191 G.7: typeck func_body implicit return tail cluster (3 fns)
 * migrated to pipeline_typeck_check_block.c EOF. Colocated with check_block
 * walker domain — func_body tail analysis is a sub-domain of block typeck.
 *
 * Members: pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c +
 *          pipeline_typeck_func_body_has_implicit_return_tail_c +
 *          pipeline_typeck_patch_all_body_parent_links_c (XLANG_WEAK).
 *
 * Forward decls visible at #include point (check_block.c) via earlier decls:
 * - ast_ast_block_* / pipeline_block_* / pipeline_expr_* (extern)
 * - implicit_tail_expr_disallowed_by_glue (defined earlier in glue.c before
 *   check_block.c #include — visible in same TU)
 * - ast_ast_arena_patch_block_parent_links / pipeline_module_func_body_ref_at
 *   (extern)
 * - link_abi_getenv (extern)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1158 G.7: typeck type_refs_equal / type_ref_is_bool / expr_type_ref
 * public wrappers (9 extern fns) migrated to pipeline_typeck_coerce_init.c
 * EOF (colocated with wave1080-1083 static implementations). Extern fwd
 * decls below for callsites before #include L9626. */
int32_t pipeline_typeck_type_refs_equal_named_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                     int32_t kind_ord);
int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_impl_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_ref_is_bool_impl_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_type_ref_is_bool_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_expr_type_ref_impl_c(struct ast_ASTArena *arena, int32_t expr_ref);
int32_t pipeline_typeck_expr_type_ref_c(struct ast_ASTArena *arena, int32_t expr_ref);

/* wave1080 G.7: typeck_named_unqual_offset_c migrated to
 * pipeline_typeck_coerce_init.c EOF (NAMED type unqualified-name offset:
 * find last '.' +1). Static same-TU: fwd decl below (before callsites in
 * typeck_glue_type_refs_equal_named L10117/10118) < coerce_init.c #include
 * L14126 < def EOF. Deps: none (pure buf scan). */
static int32_t typeck_named_unqual_offset_c(const uint8_t *buf, int32_t len);

/* wave1081 G.7: typeck_glue_type_refs_equal_named migrated to
 * pipeline_typeck_coerce_init.c EOF (NAMED type_refs_equal: full-name then
 * unqualified suffix match). Static same-TU: fwd decl below (before callsites
 * L10134/10145) < coerce_init.c #include L14126 < def EOF. Deps:
 * typeck_named_unqual_offset_c (same file, def above) /
 * typeck_scratch64_slot (extern L10447) / pipeline_type_named_name_into (extern). */
static int32_t typeck_glue_type_refs_equal_named(struct ast_ASTArena *arena, int32_t a, int32_t b);

/* wave1082 G.7: typeck_glue_type_refs_equal_impl migrated to
 * pipeline_typeck_coerce_init.c EOF (type_refs_equal internal impl: read kind
 * then delegate to same_kind). Static same-TU: fwd decl below (before callsites
 * L10199/10204) < coerce_init.c #include L14126 < def EOF. Deps:
 * pipeline_typeck_type_refs_equal_same_kind_c (extern, glue.c L10108) /
 * pipeline_type_kind_ord_at (extern). */
static int32_t typeck_glue_type_refs_equal_impl(struct ast_ASTArena *arena, int32_t a, int32_t b);

/** WPO-S3：typeck 活跃 module（type 别名展开等 glue 回落；定义见文件前部 g_typeck_active_module）。 */
extern int32_t pipeline_module_num_type_aliases_at(struct ast_Module *m);
extern int32_t pipeline_module_type_alias_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_type_alias_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_type_alias_target_ref(struct ast_Module *m, int32_t idx);

/* wave1083 G.7: pipeline_typeck_resolve_type_alias_ref_impl_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (type alias chain resolver: NAMED → target
 * ref, depth-limited recursion). Static fwd decl below (before callsite in
 * resolve_type_alias_ref_c, now in coerce_init.c). Body 36 LOC. Deps:
 * ast_ref_is_null (global) / pipeline_module_num_type_aliases_at (extern) /
 * pipeline_type_kind_ord_at (extern) / pipeline_type_named_name_into (extern) /
 * pipeline_module_type_alias_name_len (extern) /
 * pipeline_module_type_alias_name_byte_at (extern) /
 * pipeline_module_type_alias_target_ref (extern). */
static int32_t pipeline_typeck_resolve_type_alias_ref_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                             int32_t type_ref, int32_t depth);

/* wave1158 G.7: 9 extern public wrappers (type_refs_equal_named_c /
 * type_refs_equal_same_kind_c / resolve_type_alias_ref_c /
 * type_refs_equal_c / type_refs_equal_impl_c / type_ref_is_bool_impl_c /
 * type_ref_is_bool_c / expr_type_ref_impl_c / expr_type_ref_c) migrated to
 * pipeline_typeck_coerce_init.c EOF — colocated with wave1080-1083 static
 * implementations. Bodies removed; extern fwd decls above. */

/* wave1156 G.7: typeck diag fmt cluster (5 fns) migrated to
 * pipeline_typeck_assign.c EOF (colocated with assign mismatch diag domain —
 * 8 callsites in assign.c lines 265-336; sole glue.c callsite at L8147 in
 * check_expr_return return-type mismatch diag). Extern (non-static):
 * assign.c #include at L8265; extern fwd decl at L8013 (before L8147 callsite).
 * Cluster: diag_append_lit_c / diag_append_u32_dec_c / diag_fmt_type_at_c /
 * diag_fmt_type_into_c / diag_fmt_type_or_question_c. PLATFORM: SHARED. */

/* wave1076 G.7: pipeline_typeck_float_widen_ok_c migrated to
 * pipeline_typeck_coerce_init.c EOF (f32→f64 IEEE float widen gate).
 * Static same-TU: fwd decl below (before all callsites L10570/10650/11132/
 * 13272) < coerce_init.c #include L14126 < def EOF. Deps: ast_TypeKind_* (global). */
/* wave144: pure return leave Cap residual — static→extern (def coerce_init). */
int32_t pipeline_typeck_float_widen_ok_c(int32_t dest_kind, int32_t src_kind);

/* wave1077 G.7: pipeline_typeck_integer_widen_ok_c migrated to
 * pipeline_typeck_coerce_init.c EOF (first-class integer widen gate).
 * Static same-TU: fwd decl below (before sole callsite in refs_c L10523) <
 * coerce_init.c #include L14126 < def EOF. Deps: ast_TypeKind_* (global). */
static int32_t pipeline_typeck_integer_widen_ok_c(int32_t dest_kind, int32_t src_kind);

/* wave1077 G.7: pipeline_typeck_integer_widen_ok_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (first-class integer widen gate).
 * Static fwd decl at L10441 (before sole callsite in refs_c). Body 36 LOC. */

extern uint8_t *typeck_scratch64_slot(int32_t slot);

/* wave1078 G.7: pipeline_typeck_int_family_id_c migrated to
 * pipeline_typeck_coerce_init.c EOF (family id for first-class ints + NAMED
 * i8/i16/u16). Static same-TU: fwd decl below (before callsites in refs_c
 * L10485/10486) < coerce_init.c #include L14126 < def EOF. Deps:
 * typeck_scratch64_slot (extern L10447) / pipeline_type_named_name_into (extern). */
static int32_t pipeline_typeck_int_family_id_c(struct ast_ASTArena *arena, int32_t type_ref);

/* wave1079 G.7: pipeline_typeck_integer_widen_ok_refs_c migrated to
 * pipeline_typeck_coerce_init.c EOF (refs-based integer widen: first-class +
 * NAMED i8/i16/u16). Static same-TU: fwd decl below (before all callsites
 * L10590/10646/11074/13212) < coerce_init.c #include L14126 < def EOF.
 * Deps: pipeline_typeck_int_family_id_c + pipeline_typeck_integer_widen_ok_c
 * (both in coerce_init.c EOF, same file — direct call, no fwd needed). */
static int32_t pipeline_typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref,
                                                       int32_t src_ref);

/* wave1076 G.7: pipeline_typeck_float_widen_ok_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (f32→f64 IEEE float widen gate).
 * Static fwd decl at L10435 (before all callsites). Body 10 LOC. */

/* wave1130-1131: float promote pair migrated to return.c;
 * wave144 pure leave: live = runtime_pipeline_abi pure (extern below). */
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       int32_t dest_ty_ref, int32_t src_ty_ref, int32_t ta);
extern int32_t glue_float_promote_src_ty_ref_c(struct ast_ASTArena *arena, int32_t expr_ref);

/**
 * typeck.x::typeck_return_operand_matches C twin (G.7 single semantic).
 * Accept equal types, integer widen (wave313), f32→f64 (wave314), linear unwrap.
 * wave671 Cap residual: do NOT accept BOOL_LIT / LOGNOT as TYPE_I32
 * (`return true` / `return !x` false-green). Align with wave666 no int↔bool.
 * Explicit `as i32` stamps target before match. LANG-006 bool→int is let/const
 * coerce only. PLATFORM: SHARED — product return path often hits this glue twin
 * (Ubuntu) while typeck.x body is the seed twin; both must match.
 */
/* wave1165 G.7: ret coerce cluster (3 fns:
 * pipeline_typeck_return_operand_matches_c /
 * pipeline_typeck_ret_coerce_integral_to_expect_i32_c /
 * pipeline_typeck_ret_coerce_integral_widen_c) migrated to
 * pipeline_typeck_coerce_init.c EOF (colocated with coerce-init domain —
 * return coercion is the return-path twin of let/const/arg init coercion).
 * Forward decls below for callsites at L7367-7370 (before coerce_init.c
 * #include at L9010). Deps all visible at coerce_init.c #include L9010. */
int32_t pipeline_typeck_return_operand_matches_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref);
void pipeline_typeck_ret_coerce_integral_to_expect_i32_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                         int32_t expect_ref);
void pipeline_typeck_ret_coerce_integral_widen_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref);

/** EXPR_RETURN 诊断与 scratch 缓冲（runtime.c）。 */
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref,
                                              int32_t got_ty_ref);
extern void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t *expect_buf,
                                                     int32_t expect_len, uint8_t *found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col,
                                                     uint8_t *expect_buf, int32_t expect_len, uint8_t *found_buf,
                                                     int32_t found_len);
extern void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_subscript_index(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col);
extern uint8_t *driver_typeck_diag_scratch_expect(void);
extern uint8_t *driver_typeck_diag_scratch_found(void);

/** 前向声明：panic/return C 委托内递归 check 子表达式。 */
int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);

/* wave1189 G.7: typeck check_expr sub-class cluster (8 fns + 3 match helpers
 * + 2 match statics) migrated to pipeline_typeck_check_expr.c EOF (colocated
 * with wave1188 entry/dispatch domain). Members removed from here:
 * pipeline_typeck_check_expr_panic_c
 * + match subject helpers: g_typeck_match_subject_{ty,mod} statics +
 *   pipeline_typeck_match_set_subject_c / clear_subject_c /
 *   subject_field_type_c (sole users of those statics)
 * + pipeline_typeck_check_expr_match_c
 * + pipeline_typeck_check_expr_return_c
 * + pipeline_typeck_check_expr_unary_c
 * + pipeline_typeck_check_expr_addr_of_c
 * + pipeline_typeck_check_expr_deref_c
 * + pipeline_typeck_check_expr_index_c
 * + pipeline_typeck_check_expr_var_c
 * All extern (non-static): cross-TU calls (typeck_x.o / typeck.o / seeds).
 * g_typeck_unsafe_depth remains here (shared with check_block.c via #include).
 * Forward decls below remain for other glue.c callsites. PLATFORM: SHARED. */

/* wave1189+1190: fwd decls for migrated check_expr helpers (defined in
 * pipeline_typeck_check_expr.c EOF, #included at L6246). Needed because:
 * - check_expr.c impl_mega_c / impl_c call match/deref/var/call before their def
 * - check_expr.c check_expr_c calls try_propagate before its def
 * - glue.c typeck_check_expr_deref wrapper at L6207 calls deref_c
 * - glue.c typeck_check_expr_call wrapper at L6216 calls call_c */
int32_t pipeline_typeck_check_expr_match_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_return_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_deref_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_var_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_try_propagate_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_coerce_init_struct_lit_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref);
/* wave318: return path reuses lit coerce before body (defined with coerce family). */
int32_t pipeline_typeck_coerce_init_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                  int32_t decl_kind, int32_t init_kind);
/* wave316: return path reuses float_lit coerce before body (defined with coerce family). */
int32_t pipeline_typeck_coerce_init_float_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
/* wave319: return path reuses int_binop coerce for EXPR_NEG/int binop → f32/f64. */
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
/* wave333: return ARRAY_LIT → TYPE_SLICE/ARRAY/VECTOR (def with coerce family). */
int32_t pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind);

/** bootstrap typeck 后处理（METHOD_CALL / 泛型 CALL）；定义见 pipeline_typeck_bootstrap_expr_fixup_c。 */
static void pipeline_typeck_bootstrap_expr_fixup_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref);

/* wave1156 G.7: extern fwd decl for diag fmt cluster migrated to
 * pipeline_typeck_assign.c EOF. Callsite at L8142 precedes assign.c
 * #include at L8265. */
int32_t pipeline_typeck_diag_fmt_type_or_question_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out);

/* wave1189 G.7: pipeline_typeck_check_expr_return_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/** typeck.o / typeck_x：按元素类型分配或复用 *T Type ref。 */
extern int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref);

/* wave1189 G.7: pipeline_typeck_check_expr_unary_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/* wave1282 G.7: pipeline_typeck_ptr_for_addr_of_operand_c migrated to
 * pipeline_typeck_region_assign.c EOF (colocated with stack-escape helpers).
 * No glue.c fwd decl needed — sole same-TU caller is check_expr.c
 * (#include after region_assign). Cross-TU seeds keep their own extern.
 * PLATFORM: SHARED. */

/* wave1189 G.7: pipeline_typeck_check_expr_addr_of_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t pipeline_dep_ctx_typeck_unsafe_depth_at(struct ast_PipelineDepCtx *ctx);
/* Cap-T001 / WPO-S3 post-scan: push/pop must be visible before typeck_scan_block_stack_escape_c. */
int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx);
void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_unsafe_depth);

/* wave1282 G.7: g_typeck_unsafe_depth migrated to pipeline_typeck_check_block.c
 * top (sole consumers: unsafe_depth push/pop/at in that domain). PLATFORM: SHARED. */

extern void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col);

/* wave1189 G.7: pipeline_typeck_check_expr_deref_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). g_typeck_unsafe_depth + driver_diagnostic_typeck_deref_outside_unsafe
 * extern remain here (shared with check_block.c via same-TU #include).
 * PLATFORM: SHARED. */

/* typeck assign domain (lit narrow + EXPR_ASSIGN): pipeline_typeck_assign.c */
