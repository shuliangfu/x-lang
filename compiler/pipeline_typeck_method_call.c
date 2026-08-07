/**
 * pipeline_typeck_method_call.c — typeck method_call + generic UFCS mono domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega EXPR_METHOD_CALL typeck and generic
 * free-function UFCS monomorphization:
 * - glue_slice_equal_c (name/type-arg byte compare helper)
 * - pipeline_typeck_check_expr_method_call_c (XLANG_WEAK product path)
 * - pattern-unify / mono-map / subst helpers (glue_typeck_* / glue_generic_call_*)
 * - pipeline_typeck_method_call_generic_ufcs_c (G.7 sole generic method UFCS)
 *
 * G.7: single product-mega method_call + generic UFCS path — typeck.x twin
 * must stay aligned; strict_minimal strong method_call also calls
 * pipeline_typeck_method_call_generic_ufcs_c (no second unify path).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * try_propagate helpers and before generic_call_fixup_resolved_type.
 * pipeline_typeck_named_is_module_type_c is forward-declared here (L348);
 * definition at EOF (wave1095 G.7 migration from pipeline_glue.c).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *
 * wave247 pure leave: resolve_call_callee_return_type_c → typeck_x.o;
 * import_segment / resolve_dep / whole_import residual faces thin → typeck_*;
 * deleted static import path/binding/select equal helpers (pure twins).
 *
 * wave248 pure leave: overload pick/resolve Cap faces → typeck_x.o;
 * deleted residual second score cluster (count/assignable/match/expect/pick/resolve).
 *
 * wave249 pure leave: mono foundation → typeck_x.o;
 * deleted residual named_is_module_type + type_tree_has_free_param +
 * call_arg_effective_type bodies (Cap faces extern-only; dual-export ban).
 *
 * wave250 pure leave: generic type-args / try_infer / bounds → typeck_x.o;
 * deleted residual try_infer + check_inferred_bounds +
 * check_call_generic_type_args bodies (Cap face extern-only; dual-export ban).
 *
 * wave251 pure leave: mono-map / pattern-unify / subst → typeck_x.o;
 * Cap faces flat ABI (names_flat *u8 stride-128); residual multi-dim [8][128]
 * is byte-identical — pass (uint8_t *)names. Dual-export ban.
 *
 * wave252 pure leave: generic method UFCS + CALL mono fixup → typeck_x.o;
 * Cap faces pipeline_typeck_method_call_generic_ufcs_c +
 * glue_generic_call_fixup_resolved_type_c; residual dual-export ban
 * (UFCS / fixup / subst_ret_from_formal_map / dead subst_module_ret deleted).
 *
 * wave253 pure leave: weak method_call_c body → typeck_check_expr_method_call
 * (typeck_x.o); Cap face thin only.
 *
 * wave254 pure leave: dep map + find_func → typeck_x.o (#[no_mangle] Cap faces);
 * deleted residual map_import / dep_return_impl / get_dep / set_entry / find_func
 * second bodies (dual-export ban). Residual still hosts call-resolve accessors
 * (next leave).
 */


/* wave247: pure import / call-resolve helpers from typeck_x.o. */
extern int typeck_import_binding_name_equal(struct ast_Module *module, int32_t imp_ix, uint8_t *nm, int32_t nm_len);
extern int typeck_import_segment_at(struct ast_Module *module, int32_t imp_ix, int32_t want_seg, int32_t *ostr, int32_t *olen);
extern int32_t typeck_resolve_dep_index_for_import(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t imp_ix);
extern int32_t typeck_resolve_whole_import_qualified_call_return_type(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                       int32_t callee_expr_ref, struct ast_PipelineDepCtx *ctx,
                                                                       int32_t *dep_index_out, int32_t *func_index_out);

/* wave249: mono foundation pure leave — Cap faces live in typeck_x.o only. */
extern int32_t pipeline_typeck_named_is_module_type_c(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                     const uint8_t *nm, int32_t nlen);
extern int32_t pipeline_typeck_call_arg_effective_type_c(struct ast_ASTArena *arena, int32_t arg_ref);
extern int32_t glue_typeck_type_tree_has_free_param_c(struct ast_Module *mod, struct ast_ASTArena *arena, int32_t ty,
                                                     int32_t depth);

/* wave250: generic type-args / try_infer / bounds pure leave — Cap face in typeck_x.o only. */
extern int32_t pipeline_typeck_check_call_generic_type_args_c(struct ast_Module *module,
                                                             struct ast_ASTArena *arena, int32_t expr_ref,
                                                             struct ast_PipelineDepCtx *ctx,
                                                             int32_t expected_ret);

/* wave251: mono-map / pattern-unify / subst pure leave — Cap faces in typeck_x.o only.
 * Flat map ABI: names_flat row-major stride 128 (C multi-dim [N][128] → (uint8_t *)). */
extern int32_t glue_typeck_pattern_unify_bind_c(struct ast_Module *mod, struct ast_ASTArena *formal_arena,
                                               int32_t formal_ty, struct ast_ASTArena *arg_arena, int32_t arg_ty,
                                               uint8_t *names_flat, int32_t *lens, int32_t *conc, int32_t *n_map,
                                               int32_t max_map, int32_t depth);
extern int32_t glue_typeck_subst_type_ref_c(struct ast_Module *mod, struct ast_ASTArena *src_arena,
                                           struct ast_ASTArena *dst_arena, int32_t ty, uint8_t *names_flat,
                                           const int32_t *lens, const int32_t *conc, int32_t n_map, int32_t depth);
extern int32_t glue_typeck_build_value_formal_mono_map_c(struct ast_Module *search_mod,
                                                        struct ast_ASTArena *search_arena,
                                                        struct ast_ASTArena *caller_arena, int32_t call_expr_ref,
                                                        int32_t func_idx, uint8_t *names_flat, int32_t *lens,
                                                        int32_t *conc, int32_t max_map);

/* wave252: generic UFCS + CALL fixup pure leave — Cap faces live in typeck_x.o only. */
extern int32_t pipeline_typeck_method_call_generic_ufcs_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t expr_ref, int32_t base_ty, uint8_t *method_nm,
                                                         int32_t method_nlen, int32_t num_args);
extern int32_t glue_generic_call_fixup_resolved_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx,
                                                        int32_t expected_ret);

/*
 * wave1159 G.7: extern call_resolve + method_call accessor public wrappers
 * migrated from pipeline_glue.c L1018-1084 / L3623-3676 to this file's EOF
 * (colocated with method_call typeck domain). Callsites at L79/L990/L1501/
 * L1579/L1586/L1591/L1766/L1772/L2427/L2818 precede the EOF definitions;
 * these decls make them visible within the same TU.
 */
void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                      int32_t func_ix);
void pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e);
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);

/*
 * wave1169 G.7: forward decl — definition at EOF L3508 (callsites at L200/218/
 * 307/2942/2988/3008/3033/3059 precede the EOF definition). extern (non-static):
 * sole callers are within method_call.c; no glue.c/other-TU callsites.
 */
void pipeline_typeck_expr_apply_call_resolve_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t dep_ix,
                                               int32_t func_ix);

/*
 * wave1192 G.7: import resolution cluster (3 extern fns) migrated from
 * pipeline_glue.c L4831/L4900/L5014 to this file's EOF. Forward decls below
 * for callsites at L178/2946/2981 that precede the EOF definitions.
 * Colocated with method_call domain — qualified import call resolution is a
 * sub-domain of method-call target resolution (callee name + dep slot lookup).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */
int32_t pipeline_typeck_import_segment_at_c(struct ast_Module *module, int32_t imp_ix, int32_t want_seg,
                                             int32_t *ostr, int32_t *olen);
int32_t pipeline_typeck_resolve_dep_index_for_import_c(struct ast_Module *module,
                                                        struct ast_PipelineDepCtx *ctx, int32_t imp_ix);
int32_t pipeline_typeck_resolve_whole_import_call_ret_c(
    struct ast_Module *module, struct ast_ASTArena *arena, int32_t callee_expr_ref,
    struct ast_PipelineDepCtx *ctx, int32_t *dep_index_out, int32_t *func_index_out);

/**
 * Cap residual face for EXPR_METHOD_CALL.
 * wave253 pure leave: thin → typeck_check_expr_method_call (typeck_x.o).
 * G.7 dual-export ban: residual second body deleted; product authority = typeck.x.
 * PLATFORM: SHARED freestanding typeck method_call pure leave.
 */
XLANG_WEAK int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena,
                                                                       int32_t expr_ref,
                                                                       int32_t return_type_ref,
                                                                       struct ast_PipelineDepCtx *ctx) {
  extern int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t expr_ref, int32_t return_type_ref,
                                               struct ast_PipelineDepCtx *ctx);
  return typeck_check_expr_method_call(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Generic-call return-type monomorphization fixup (G.7 single authority).
 *
 * Why: typeck stamps CALL resolved_type from the *generic* signature return
 * (TYPE_NAMED `T`/`U`/…). Parser does not store turbofish type_arg type_refs
 * (only `call_num_type_args` count). Without fixup, assignment sees
 * `expected Marker, found T` / `found U` even when value args already carry
 * the concrete mono types (codegen mono already uses arg types).
 *
 * Historical path (pre-wave451): only identity shape ret_name == param0_name
 * → stamp arg0 type. That greenlit `id<T>(x:T):T` and multi-file generic, but
 * left `second<T,U>(a:T,b:U):U` and any non-param0 type-param return red.
 *
 * wave451 root complete: scan **all** formals; if return TYPE_NAMED name equals
 * formal[i] TYPE_NAMED name, stamp call with arg[i] resolved type (caller arena).
 * Covers identity (i=0) and non-identity (`:U` with param1 `U`) under one path.
 *
 * Soft leave-off (not this leaf): zero-value-param generics whose return is a
 * type param (`default_T<T>(): T`) — no formal to map; needs type_arg type_refs
 * or expected-type inference (wave453 expected_ret). PLATFORM: SHARED — rebuild
 * pipeline_glue_standalone.o after edit.
 *
 * @param expected_ret ambient expected type from let/return (0 if none)
 */
/*
 * wave486 Cap residual pure: monomorphize a generic *module* return type tree.
 * wave487: also pattern-unify value formals that are generic structs
 * (`unwrap<T>(w: Wrap<T>): T` / nested `Wrap<Wrap<T>>`) so free type params
 * bind from arg type-arg trees (not only bare `x: T` identity formals).
 *
 * Why: wave451–457 fixups only handle ret TYPE_NAMED equal to a free type-param
 * (`: T` / `: U`). Functions like `nest<T>(x:T): Wrap<Wrap<T>>` stamp CALL with
 * the generic signature return (TYPE_NAMED Wrap whose type-arg tree still holds
 * free T). Field typeck mono (`pipeline_typeck_field_apply_mono_type_arg_c`) then
 * sees `inner: T` → free T → chain `nest(...).inner.inner.v` typecks as `found ?`.
 * wave486 left-off: formals `x: Wrap<T>` skipped by identity map → CALL ret stayed
 * free T (`expected i32, found T`).
 *
 * Authority (G.7 single path): glue_generic_call_fixup_resolved_type_c calls
 * these helpers after formal-identity fails and before the ret-is-type-param
 * branch. Map free formal names → value-arg concrete types (identity + pattern
 * unify); recursively substitute TYPE_NAMED trees; allocate fresh TYPE_NAMED +
 * type-pos args so mono field resolution can walk Wrap→Wrap→A→i32.
 *
 * Soft leave-off: dyn Trait; P010 untyped-let (language contract); ambient
 * STRUCT_LIT without typed let. PLATFORM: SHARED — rebuild
 * pipeline_glue_standalone.o after edit.
 */
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
/* wave1198: pipeline_typeck_call_arg_repr_compatible_ok_c migrated to
 * pipeline_typeck_check_expr.c EOF. Extern for method_call same-TU callsites. */
extern int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                              int32_t param_ref, int32_t arg_ref);

/*
 * wave250–252 pure leaves (Cap residual dual-export ban):
 * wave250: try_infer / bounds / check_call_generic_type_args → typeck_x.o
 * wave251: mono-map / pattern-unify / subst (flat stride-128 Cap faces)
 * wave252: generic method UFCS + CALL mono fixup Cap faces
 *   pipeline_typeck_method_call_generic_ufcs_c
 *   glue_generic_call_fixup_resolved_type_c
 * Deleted residual second bodies (G.7): subst_module_ret (dead),
 * subst_ret_from_formal_map, generic_ufcs, fixup_resolved_type, glue_slice_equal.
 * Live authority: typeck_* pure + Cap faces in typeck.x (top-of-file extern).
 * PLATFORM: SHARED freestanding typeck generic UFCS + CALL fixup.
 */

/* ============================================================
 * wave254 G.7 pure leave: dep return map statics retired → typeck_x.o
 * (typeck_map_import_binding_named_to_caller + dep_return_type_to_caller_arena
 *  + get_dep_return_type_in_caller_arena). Dual-export ban.
 * PLATFORM: SHARED freestanding typeck dep map.
 * ============================================================ */

/* ============================================================
 * wave239 G.7: typeck_check_call_ptr_struct_compat_c body retired.
 * Live authority = typeck.x private typeck_check_call_ptr_struct_compat
 * (called from typeck_check_call_slice_region pure leave). Dual-export ban.
 * PLATFORM: SHARED freestanding typeck.
 * ============================================================ */

/* ============================================================
 * wave1147 G.7: debug-point D try-propagate-strong-state reporter
 * (migrated from pipeline_glue.c L10377-10413).
 *
 * Why here: debug_try_propagate_report_glue_c is a debug-only HTTP
 * POST reporter (gated by XLANG_DEBUG_RESULT_TRY env var) for the
 * Result `?` try-propagate typeck path. Its sole caller
 * pipeline_typeck_check_expr_try_propagate_c (glue.c L10419) is the
 * typeck entry for EXPR_TRY_PROPAGATE — colocated with the call
 * dispatch / overload resolution domain already in this file.
 *
 * Contract: no-op unless XLANG_DEBUG_RESULT_TRY is set non-zero.
 * Reads .dbg/result-try-typeck.env (optional) for url/session
 * override; POSTs a JSON event to the debug server via curl.
 *
 * Dependencies (all extern / libc; no glue.c-local state):
 *   - link_abi_getenv / link_abi_system (extern, host-cc)
 *   - fopen / fgets / fclose / snprintf / strncmp / strcspn (libc)
 *
 * Caller (in glue.c, BEFORE this file's #include at L10525):
 *   - pipeline_typeck_check_expr_try_propagate_c (glue.c L10452)
 * Static fwd decl added at glue.c L10377 (before caller L10452).
 *
 * PLATFORM: SHARED — debug reporter; no platform ABI dep (curl is
 * invoked via link_abi_system, not raw libc system).
 * ============================================================ */
// #region debug-point D:try-propagate-strong-state
static void debug_try_propagate_report_glue_c(int32_t expr_ref, int32_t func_ix, int32_t return_type_ref, int32_t func_ret,
                                              int32_t enclosing_return_type_ref, int32_t op_ty) {
  FILE *fp;
  char line[512];
  char url[256];
  char session[64];
  char cmd[2048];
  const char *enabled = link_abi_getenv("XLANG_DEBUG_RESULT_TRY");
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
           "-d '{\"sessionId\":\"%s\",\"runId\":\"pre-fix\",\"hypothesisId\":\"D\","
           "\"location\":\"pipeline_glue.c:try_propagate\","
           "\"msg\":\"[DEBUG] try_propagate_state_strong\","
           "\"data\":{\"expr_ref\":%d,\"func_ix\":%d,\"return_type_ref\":%d,\"func_ret\":%d,"
           "\"enclosing_return_type_ref\":%d,\"op_ty\":%d}}' >/dev/null 2>&1",
           url, session, expr_ref, func_ix, return_type_ref, func_ret, enclosing_return_type_ref, op_ty);
  /* wave248 G.7: public pure thin link_abi_system (not raw libc system). */
  (void)link_abi_system(cmd);
}
// #endregion

/* ============================================================
 * wave1148 G.7: bootstrap typeck post-processing expr fixup
 * (migrated from pipeline_glue.c L10506-10546).
 *
 * Why here: pipeline_typeck_bootstrap_expr_fixup_c is the
 * post-typeck fixup for METHOD_CALL (`i32.double` → i32 builtin
 * return-type stamp) and generic CALL monomorphization fallback
 * (when bootstrap parser skipped type_args). Colocated with the
 * call dispatch / overload resolution domain already in this file;
 * depends on glue_generic_call_fixup_resolved_type_c (wave1096,
 * already at this file's EOF).
 *
 * Contract: mutates expr_ref.resolved_type_ref in place for
 * METHOD_CALL `i32.double` (stamps TYPE_I32) and delegates generic
 * CALL to glue_generic_call_fixup_resolved_type_c. No-op for
 * other expr kinds.
 *
 * Dependencies (all extern unless noted):
 *   - pipeline_expr_kind_ord_at / pipeline_expr_resolved_type_ref /
 *     pipeline_expr_method_call_base_ref_at /
 *     pipeline_expr_method_call_name_len /
 *     pipeline_expr_method_call_name_into /
 *     pipeline_expr_set_resolved_type_ref (extern)
 *   - pipeline_type_kind_ord_at / pipeline_type_ensure_by_kind_ord (extern)
 *   - ast_TypeKind_TYPE_I32 / ast_ExprKind_EXPR_METHOD_CALL /
 *     ast_ExprKind_EXPR_CALL (global enum)
 *   - glue_generic_call_fixup_resolved_type_c (exported wave232 / wave1096,
 *     same file — direct call, no fwd decl needed)
 *
 * Caller (in glue.c, BEFORE this file's #include at L10499):
 *   - pipeline_typeck_check_expr_return_c (glue.c L8191)
 * Static fwd decl retained at glue.c L8131 (before caller L8191).
 *
 * PLATFORM: SHARED — pure typeck post-processing; no platform ABI dep.
 * ============================================================ */
static void pipeline_typeck_bootstrap_expr_fixup_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref) {
  int32_t kind;
  int32_t base_ref;
  int32_t base_ty;
  int32_t method_nlen;
  uint8_t method_nm[128];
  int32_t ret_ty;
  int32_t ord_i32;
  int32_t ord_method;
  int32_t ord_call;

  if (!module || !arena || expr_ref <= 0)
    return;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  ord_i32 = (int32_t)ast_TypeKind_TYPE_I32;
  ord_method = (int32_t)ast_ExprKind_EXPR_METHOD_CALL;
  ord_call = (int32_t)ast_ExprKind_EXPR_CALL;
  if (kind == ord_method) {
    base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    method_nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (method_nlen <= 0 || method_nlen > 127)
      return;
    pipeline_expr_method_call_name_into(arena, expr_ref, method_nm);
    ret_ty = 0;
    if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == ord_i32 && method_nlen == 6 &&
        method_nm[0] == (uint8_t)'d' && method_nm[1] == (uint8_t)'o' && method_nm[2] == (uint8_t)'u' &&
        method_nm[3] == (uint8_t)'b' && method_nm[4] == (uint8_t)'l' && method_nm[5] == (uint8_t)'e')
      ret_ty = pipeline_type_ensure_by_kind_ord(arena, ord_i32);
    if (ret_ty != 0)
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
    return;
  }
  if (kind == ord_call)
    (void)glue_generic_call_fixup_resolved_type_c(module, arena, expr_ref, 0, 0);
}

/* ============================================================
 * wave247 G.7 pure leave: pipeline_typeck_resolve_call_callee_return_type_c
 * body retired → typeck_x.o (#[no_mangle] thin → resolve_call_callee_return_type).
 * Dual-export ban: residual keeps extern only (U from typeck_x).
 * PLATFORM: SHARED freestanding typeck CALL target resolve.
 * ============================================================ */
extern int32_t pipeline_typeck_resolve_call_callee_return_type_c(struct ast_Module *module,
                                                                  struct ast_ASTArena *arena,
                                                                  int32_t callee_expr_ref,
                                                                  int32_t call_expr_ref,
                                                                  struct ast_PipelineDepCtx *ctx);


/* ============================================================
 * wave1159 G.7: call_resolve + method_call accessor public wrappers
 * (13 extern fns) migrated from pipeline_glue.c L1018-1084 / L3623-3676.
 * Colocated with method_call typeck domain — these are the call-resolution
 * write/read API and EXPR_METHOD_CALL field accessors consumed by the
 * typeck paths above. Forward decls at L54-64.
 */

/**
 * Initialize call_resolved_func_index and call_resolved_dep_index to -1
 * (sentinel "unresolved") on the arena-pooled Expr at expr_ref.
 * Called by parser.x after Expr allocation to avoid FIELD_ACCESS layout
 * gaps when typeck reads the tail fields of struct ast_Expr.
 * Null arena or out-of-range expr_ref is a no-op.
 */
void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_func_index = -1;
  ex->call_resolved_dep_index = -1;
}

/**
 * Write resolved dep slot index and func index into the arena-pooled Expr
 * after typeck successfully resolves a call. dep_ix = -1 means same-module;
 * func_ix is the index within the dep module or same module.
 * Null arena or out-of-range expr_ref is a no-op.
 */
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                    int32_t func_ix) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_dep_index = dep_ix;
  ex->call_resolved_func_index = func_ix;
}

/**
 * Initialize call_resolved_func_index and call_resolved_dep_index to -1
 * on a raw heap-allocated or stack Expr pointer (parser.x
 * expr_set_common_zeros path). Null pointer is a no-op.
 */
void pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  if (!e)
    return;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/**
 * Forwarding wrapper: codegen may prepend ast_ prefix when importing ast
 * module; delegates to the pipeline_expr_* bare symbol above.
 */
void ast_pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  pipeline_expr_ptr_init_call_resolve(e);
}

/**
 * Forwarding wrapper: ast_-prefixed alias for pipeline_expr_init_call_resolve_at_ref.
 */
void ast_pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_init_call_resolve_at_ref(a, expr_ref);
}

/**
 * Forwarding wrapper: ast_-prefixed alias for pipeline_expr_apply_call_resolve.
 */
void ast_pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, expr_ref, dep_ix, func_ix);
}

/**
 * Read the dep slot index written by typeck after resolving an
 * import/same-module call. Returns -1 for same-module, -2 for invalid
 * expr_ref or null arena.
 */
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -2;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -2;
  return ex->call_resolved_dep_index;
}

/**
 * Read the func index (within dep module or same module) written by typeck
 * after resolving a call. Returns -1 if unresolved or invalid expr_ref.
 */
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  return ex->call_resolved_func_index;
}

/**
 * Read EXPR_CALL callee expr ref. Returns 0 for invalid ref.
 * Uses glue_arena_expr_at_ref (static, defined in pipeline_glue.c before
 * the #include of this file).
 */
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->call_callee_ref : 0;
}

/**
 * Read EXPR_METHOD_CALL receiver (base) expr ref. Returns 0 for invalid ref.
 */
int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_base_ref : 0;
}

/**
 * Read EXPR_METHOD_CALL arg count (excluding receiver). Returns 0 for
 * invalid ref.
 */
int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_num_args : 0;
}

/**
 * Read EXPR_METHOD_CALL method name length. Returns 0 for invalid ref.
 */
int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->method_call_name_len : 0;
}

/**
 * Copy EXPR_METHOD_CALL method name (u8[128]) into out64 via memcpy.
 * If out64 is null or expr is invalid, zeros the buffer and returns.
 * wave577 Cap: method_call_name is u8[128] (not u8[64]).
 */
void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  /* wave577 Cap: method_call_name is u8[128] */
  memcpy(out64, ex->method_call_name, 128);
}

/*
 * wave254 pure leave: dep map + find_func Cap faces live in typeck_x.o only
 * (#[no_mangle]). Dual-export ban — residual extern-only (no second body / BSS).
 * PLATFORM: SHARED freestanding typeck dep map / find_func.
 */
extern void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module);
extern int32_t pipeline_typeck_dep_return_type_to_caller_arena_c(struct ast_ASTArena *dep_arena,
                                                                int32_t dep_return_type_ref,
                                                                struct ast_ASTArena *caller_arena);
extern int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_expr_var_name_equal_func_c(struct ast_ASTArena *arena, int32_t callee_expr_ref,
                                                         struct ast_Module *mod, int32_t func_index);
extern int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);
extern int32_t pipeline_typeck_find_func_return_type_in_module_c(
    struct ast_Module *mod, struct ast_ASTArena *mod_arena, struct ast_ASTArena *caller_arena,
    struct ast_ASTArena *callee_arena, int32_t callee_expr_ref, int32_t from_dep_index,
    struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);

/**
 * Write resolved dep/func indices into a CALL expr node.
 * Thin → pipeline_expr_apply_call_resolve (call-resolve accessor; still residual).
 * PLATFORM: SHARED — call-resolve write-back for method-call resolution.
 */
void pipeline_typeck_expr_apply_call_resolve_c(struct ast_ASTArena *arena, int32_t call_expr_ref, int32_t dep_ix,
                                               int32_t func_ix) {
  pipeline_expr_apply_call_resolve(arena, call_expr_ref, dep_ix, func_ix);
}

/*
 * wave248 pure leave: overload Cap residual faces — bodies in typeck_x.o
 * (#[no_mangle] pipeline_typeck_*_c). Same-TU callers use these extern decls;
 * dual-export ban: no residual second body.
 * PLATFORM: SHARED freestanding typeck CALL overload resolve.
 */
extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m,
                                                                 struct ast_ASTArena *a,
                                                                 int32_t call_expr_ref);
extern int32_t pipeline_typeck_pick_overload_func_index_for_call_c(struct ast_Module *m,
                                                                  struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);

/* ============================================================
 * wave247 G.7: import resolution Cap residual faces (thin → typeck_x.o)
 * - import_segment_at_c → typeck_import_segment_at
 * - resolve_dep_index_for_import_c → typeck_resolve_dep_index_for_import
 * - whole_import_call_ret_c → typeck_resolve_whole_import_qualified_call_return_type
 * Static path/binding/select equal helpers deleted (pure twins only).
 * PLATFORM: SHARED freestanding typeck import resolve.
 * ============================================================ */

/**
 * Cap residual face: import path segment at want_seg.
 * wave247 pure leave: thin → typeck_import_segment_at (typeck_x.o).
 * PLATFORM: SHARED freestanding typeck import resolve.
 */
int32_t pipeline_typeck_import_segment_at_c(struct ast_Module *module, int32_t imp_ix, int32_t want_seg,
                                             int32_t *ostr, int32_t *olen) {
  return typeck_import_segment_at(module, imp_ix, want_seg, ostr, olen);
}


/**
 * Cap residual face: entry import slot → dep ctx slot.
 * wave247 pure leave: thin → typeck_resolve_dep_index_for_import (typeck_x.o).
 * PLATFORM: SHARED freestanding typeck import resolve.
 */
int32_t pipeline_typeck_resolve_dep_index_for_import_c(struct ast_Module *module,
                                                        struct ast_PipelineDepCtx *ctx, int32_t imp_ix) {
  return typeck_resolve_dep_index_for_import(module, ctx, imp_ix);
}


/**
 * Cap residual face: qualified whole-import CALL return type.
 * wave247 pure leave: thin → typeck_resolve_whole_import_qualified_call_return_type.
 * PLATFORM: SHARED freestanding typeck import resolve.
 */
int32_t pipeline_typeck_resolve_whole_import_call_ret_c(
    struct ast_Module *module, struct ast_ASTArena *arena, int32_t callee_expr_ref,
    struct ast_PipelineDepCtx *ctx, int32_t *dep_index_out, int32_t *func_index_out) {
  return typeck_resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx,
                                                                dep_index_out, func_index_out);
}

