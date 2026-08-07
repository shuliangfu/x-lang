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
 * (typeck_x.o); Cap face thin only. Residual still hosts call-resolve accessors /
 * dep map / find_func faces (next leave).
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

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1111-1112 G.7: dep return type mapping domain (2 fns) migrated from
 * pipeline_glue.c L9400-9494. These map a dep-side (imported module) return
 * type_ref into the caller arena, qualified with import binding prefix when
 * the import is a binding import (e.g. vec.Vec_u8). Co-located with method
 * call domain because cross-module call return-type resolution is the sole
 * consumer. Static (non-extern): same-TU visibility via #include order +
 * fwd decl at glue.c. PLATFORM: SHARED. */

/**
 * Map a dep-side TYPE_NAMED to the caller-side binding-qualified struct
 * (e.g. vec.Vec_u8). Falls back to bare-name find_or_alloc when the import
 * is not a binding import or dep_ix is out of range.
 *
 * Why: top-level dep return types arrive as bare TYPE_NAMED; the caller
 * arena must store them with the import binding prefix so that let
 * declarations like `let v: vec.Vec_u8` resolve to the same type_ref.
 *
 * Contract: entry_mod may be NULL (bare-name fallback); nm/nlen must be
 * valid (nlen > 0). Returns 0 on failure, a caller-arena type_ref on
 * success.
 *
 * PLATFORM: SHARED — pure name resolution, no arch dependency.
 */
static int32_t pipeline_typeck_map_import_binding_named_to_caller_c(struct ast_Module *entry_mod,
                                                                    int32_t dep_ix,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    uint8_t *nm, int32_t nlen) {
  int32_t bl;
  int32_t qlen;
  uint8_t qnm[128];
  int32_t i;

  if (!caller_arena || !nm || nlen <= 0)
    return 0;
  if (!entry_mod || dep_ix < 0 || dep_ix >= entry_mod->num_imports)
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  if (pipeline_module_import_kind_at(entry_mod, dep_ix) != 1) /* IMPORT_BINDING */
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  bl = pipeline_module_import_binding_name_len(entry_mod, dep_ix);
  if (bl <= 0 || bl + 1 + nlen > 127)
    return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
  for (i = 0; i < bl; i++)
    qnm[i] = pipeline_module_import_binding_name_byte_at(entry_mod, dep_ix, i);
  qnm[bl] = '.';
  memcpy(qnm + bl + 1, nm, (size_t)nlen);
  qlen = bl + 1 + nlen;
  return pipeline_type_find_or_alloc_named(caller_arena, qnm, qlen);
}

/**
 * Recursively map a dep-side return_type_ref into the caller arena.
 * Mirrors typeck.x::dep_return_type_to_caller_arena.
 *
 * Why: cross-module calls return a type_ref that is only valid in the dep
 * arena; the caller needs an equivalent type_ref in its own arena to stamp
 * resolved_type_ref on the call expr. Primitives map directly; compound
 * types (slice/ptr/vector/array) recurse on elem_ref; TYPE_NAMED maps via
 * find_or_alloc_named (or binding-qualified map when entry module is set).
 *
 * Invariant: the returned type_ref is in caller_arena, not dep_arena.
 * Returns 0 on failure (kind unknown, name empty, elem recursion fails).
 *
 * PLATFORM: SHARED — pure type_ref translation, no arch dependency.
 */
static int32_t pipeline_typeck_dep_return_type_to_caller_arena_impl(struct ast_ASTArena *dep_arena,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena) {
  int32_t kind;
  int32_t inner_mapped;
  int32_t elem_ref;
  int32_t array_size;
  uint8_t nm[128];
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
  if (!ast_ref_is_null(elem_ref)) {
    inner_mapped =
        pipeline_typeck_dep_return_type_to_caller_arena_impl(dep_arena, elem_ref, caller_arena);
    if (inner_mapped == 0)
      return 0;
  }
  array_size = pipeline_type_array_size_at(dep_arena, dep_return_type_ref);
  if (kind == (int32_t)ast_TypeKind_TYPE_SLICE) {
    int32_t rlen = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
    uint8_t rbuf[128];
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
    if (ast_ref_is_null(elem_ref) || array_size <= 0)
      return 0;
    return pipeline_type_find_or_alloc_compound(caller_arena, (int32_t)ast_TypeKind_TYPE_ARRAY, inner_mapped,
                                                array_size);
  }
  if (!ast_ref_is_null(elem_ref) || array_size != 0)
    return 0;
  nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm);
  if (nlen != 0)
    return 0;
  return pipeline_type_ensure_by_kind_ord(caller_arena, kind);
}

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
 * wave1168 G.7: dep return type + entry module cluster (3 extern fns + 1 static)
 * migrated from pipeline_glue.c (was L7918-7977). Colocated with method_call
 * domain — cross-module call return-type resolution is a sub-domain of method
 * call resolution, and these wrappers delegate to statics already in this file
 * (pipeline_typeck_map_import_binding_named_to_caller_c at L2522,
 *  pipeline_typeck_dep_return_type_to_caller_arena_impl at L2563).
 *
 * Static g_typeck_entry_module_for_dep_map moves here: set by
 * pipeline_typeck_set_entry_module_for_dep_map_c, read by
 * pipeline_typeck_get_dep_return_type_in_caller_arena_c (both in this cluster).
 *
 * Forward decls in glue.c:
 * - pipeline_typeck_get_dep_return_type_in_caller_arena_c: fwd decl at glue.c
 *   L770 (before callsites L8033/8075 < method_call.c #include L9153)
 * - pipeline_typeck_set_entry_module_for_dep_map_c: callsites at L9469/9536
 *   > method_call.c #include L9153; no fwd decl needed.
 * - pipeline_typeck_dep_return_type_to_caller_arena_c: no glue.c callsites;
 *   extern, called from seed only.
 *
 * Deps (all extern, visible at method_call.c #include L9153):
 * - pipeline_dep_ctx_arena_at / pipeline_get_dep_arena_slot /
 *   pipeline_dep_ctx_ndep / pipeline_dep_ctx_module_at (extern)
 * - pipeline_type_kind_ord_at / pipeline_type_named_name_into (extern)
 * - pipeline_typeck_map_import_binding_named_to_caller_c (static, same file L2522)
 * - pipeline_typeck_dep_return_type_to_caller_arena_impl (static, same file L2563)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/** typeck: current entry module (IMPORT_BINDING return-type mapping adds binding prefix). */
static struct ast_Module *g_typeck_entry_module_for_dep_map;

/**
 * Set entry module at typeck entry for dep return-type resolution.
 * Why: when resolving `let v: vec.Vec_u8 = dep.foo()`, the dep return TYPE_NAMED
 *      must be prefixed with the import binding name (vec) to match the caller's
 *      type pool entry. The entry module provides the import binding table.
 * Contract: module may be NULL (clears entry-module context).
 * PLATFORM: SHARED — called from pipeline_typeck_after_parse_ok_c and lsp_diag.
 */
void pipeline_typeck_set_entry_module_for_dep_map_c(struct ast_Module *module) {
  g_typeck_entry_module_for_dep_map = module;
}

/**
 * typeck.x::dep_return_type_to_caller_arena C delegate (EMIT_HEAVY thin wrapper).
 * Why: delegates to pipeline_typeck_dep_return_type_to_caller_arena_impl (static,
 *      same file L2563) which recursively maps dep_arena type refs into
 *      caller_arena via name-based lookup. This wrapper is the extern entry
 *      point called from the seed typeck path.
 * Contract: null dep_arena / null caller_arena → impl returns 0.
 * PLATFORM: SHARED — cross-module return-type mapping.
 */
int32_t pipeline_typeck_dep_return_type_to_caller_arena_c(struct ast_ASTArena *dep_arena, int32_t dep_return_type_ref,
                                                          struct ast_ASTArena *caller_arena) {
  return pipeline_typeck_dep_return_type_to_caller_arena_impl(dep_arena, dep_return_type_ref, caller_arena);
}

/**
 * typeck.x::get_dep_return_type_in_caller_arena C delegate.
 * Why: resolves a dep module's return type ref into the caller's arena ref.
 *      For TYPE_NAMED returns, adds the import binding prefix (e.g. vec.Vec_u8)
 *      via pipeline_typeck_map_import_binding_named_to_caller_c so the caller's
 *      type pool matches qualified-name declarations. For other types, delegates
 *      to pipeline_typeck_dep_return_type_to_caller_arena_impl for recursive mapping.
 *      Handles bootstrap edge case where dep_index >= ndep but slot is bound.
 * Contract: from_dep_index < 0 / null ctx → 0.
 *           dep_arena not found → 0.
 * PLATFORM: SHARED — cross-module return-type resolution for qualified names.
 */
int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index, int32_t dep_return_type_ref,
                                                              struct ast_ASTArena *caller_arena,
                                                              struct ast_PipelineDepCtx *ctx) {
  struct ast_ASTArena *dep_arena;
  int32_t kind;
  uint8_t nm[128];
  int32_t nlen;

  if (from_dep_index < 0 || !ctx)
    return 0;
  dep_arena = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
  if (!dep_arena) {
    dep_arena = pipeline_get_dep_arena_slot(from_dep_index);
    if (!dep_arena)
      return 0;
  }
  /* entry import index may be < ndep (closure seed 9 slots vs entry 1 import);
     if slot is bound, continue. */
  if (from_dep_index >= pipeline_dep_ctx_ndep(ctx) && !pipeline_dep_ctx_module_at(ctx, from_dep_index))
    return 0;
  /* top-level dep returning TYPE_NAMED: must add import binding prefix to match
     caller's `let v: vec.Vec_u8` declaration. */
  if (g_typeck_entry_module_for_dep_map && dep_return_type_ref > 0 &&
      dep_return_type_ref <= dep_arena->num_types) {
    kind = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
    if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
      nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm);
      if (nlen > 0)
        return pipeline_typeck_map_import_binding_named_to_caller_c(
            g_typeck_entry_module_for_dep_map, from_dep_index, caller_arena, nm, nlen);
    }
  }
  return pipeline_typeck_dep_return_type_to_caller_arena_impl(dep_arena, dep_return_type_ref, caller_arena);
}

/*
 * wave1169 G.7: func resolution cluster (4 extern fns) migrated from
 * pipeline_glue.c (was L7949-8056). Colocated with method_call domain —
 * callee-name matching, func return-type lookup, and call-resolve write-back
 * are all sub-domains of method-call resolution.
 *
 * Forward decls:
 * - pipeline_typeck_find_func_return_type_in_module_by_name_c: fwd decl in
 *   glue.c (before callsite at L8196 < method_call.c #include L9153);
 *   also extern fwd decl in call_args.c L2483 (before callsites L2594/2650/2687).
 * - pipeline_typeck_find_func_return_type_in_module_c: extern fwd decl in
 *   call_args.c L2479 (before callsite L2673); no glue.c callsites.
 * - pipeline_typeck_expr_var_name_equal_func_c: no external callsites outside
 *   method_call.c (sole caller is find_func_return_type_in_module_c, same cluster).
 * - pipeline_typeck_expr_apply_call_resolve_c: no external callsites outside
 *   method_call.c (all callers already in method_call.c L200/218/307/2942/etc).
 *
 * Deps (all extern, visible at method_call.c #include L9153):
 * - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len /
 *   pipeline_expr_var_name_into (expr accessor domain)
 * - pipeline_module_func_name_len_at / pipeline_module_func_name_byte_at /
 *   pipeline_module_func_name_equal_at / pipeline_module_func_return_type_at
 *   (module_func domain)
 * - pipeline_visibility_allow_func (ast_pool.c L1249)
 * - pipeline_typeck_get_dep_return_type_in_caller_arena_c (same file, wave1168)
 * - pipeline_typeck_dep_return_type_to_caller_arena_impl (static, same file L2563)
 * - pipeline_dep_ctx_arena_at (extern)
 * - pipeline_expr_apply_call_resolve (extern)
 * - link_abi_getenv (global)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/**
 * Check if a VAR callee expr name matches module.funcs[func_index] name byte-by-byte.
 * Why: method-call resolution must match the callee VAR name against each function
 *      in the target module to find the called function index. Byte comparison
 *      avoids string allocation on the hot path.
 * Contract: invalid callee_expr_ref / non-VAR kind / OOB func_index → 0.
 * PLATFORM: SHARED — callee-name match for method-call resolution.
 */
int32_t pipeline_typeck_expr_var_name_equal_func_c(struct ast_ASTArena *arena, int32_t callee_expr_ref,
                                                   struct ast_Module *mod, int32_t func_index) {
  uint8_t vbuf[128];
  int32_t b_len;
  int32_t a_len;
  int32_t i;

  if (callee_expr_ref <= 0 || !arena || callee_expr_ref > arena->num_exprs)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 3)
    return 0;
  b_len = pipeline_expr_var_name_len(arena, callee_expr_ref);
  if (func_index < 0 || !mod || func_index >= mod->num_funcs)
    return 0;
  a_len = pipeline_module_func_name_len_at(mod, func_index);
  if (a_len != b_len || a_len <= 0 || a_len > 127)
    return 0;
  pipeline_expr_var_name_into(arena, callee_expr_ref, vbuf);
  i = 0;
  while (i < a_len) {
    if (pipeline_module_func_name_byte_at(mod, func_index, i) != vbuf[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * Find a function's return type in a module by name, mapping to caller's arena.
 * Why: cross-module call resolution needs to look up a function by its name
 *      (e.g. from import binding or qualified symbol) and map the dep's return
 *      type ref into the caller's arena. Handles export visibility checks and
 *      bootstrap fallback (direct dep arena primitive mapping).
 * Contract: name_len outside [1,127] → 0.
 *           Function not found / visibility denied → 0.
 * PLATFORM: SHARED — cross-module call return-type resolution by name.
 */
int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out) {
  int32_t j;
  int32_t rtr;

  if (name_len <= 0 || name_len > 127)
    return 0;
  j = 0;
  while (j < mod->num_funcs) {
    if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {
      /* Module export: strict mode requires is_export for cross-module calls
         (compat/warn allows). */
      if (from_dep_index >= 0 && pipeline_visibility_allow_func(mod, j, 1) == 0) {
        j = j + 1;
        continue;
      }
      if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep_func_match name=%.*s func_idx=%d dep_ix=%d raw_ret=%d\n",
                (int)name_len, name, (int)j, (int)from_dep_index, (int)pipeline_module_func_return_type_at(mod, j));
      if (func_index_out)
        func_index_out[0] = j;
      rtr = pipeline_module_func_return_type_at(mod, j);
      if (from_dep_index < 0)
        return rtr;
      {
        int32_t mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, rtr, caller_arena, ctx);
        if (link_abi_getenv("XLANG_DEBUG_PIPE"))
          fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep_func_map name=%.*s func_idx=%d dep_ix=%d mapped=%d\n",
                  (int)name_len, name, (int)j, (int)from_dep_index, (int)mapped);
        if (mapped != 0)
          return mapped;
        /* Bootstrap fallback: ctx dep arena direct-map primitive (import_idx
           vs global dep slot mismatch). */
        {
          struct ast_ASTArena *da = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
          if (link_abi_getenv("XLANG_DEBUG_PIPE"))
            fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] dep_func_fallback name=%.*s func_idx=%d dep_ix=%d dep_arena=%p raw_ret=%d\n",
                    (int)name_len, name, (int)j, (int)from_dep_index, (void *)da, (int)rtr);
          if (da && rtr != 0)
            return pipeline_typeck_dep_return_type_to_caller_arena_impl(da, rtr, caller_arena);
        }
      }
      return 0;
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Find a function's return type in a module by matching callee VAR expr name.
 * Why: UFCS method-call resolution matches the callee expr's VAR name against
 *      each function in the target module. On match, maps the return type to
 *      the caller's arena via pipeline_typeck_get_dep_return_type_in_caller_arena_c.
 * Contract: null mod / null callee_arena → 0.
 *           No match → 0.
 * PLATFORM: SHARED — callee-expr-based method-call return-type resolution.
 */
int32_t pipeline_typeck_find_func_return_type_in_module_c(
    struct ast_Module *mod, struct ast_ASTArena *mod_arena, struct ast_ASTArena *caller_arena,
    struct ast_ASTArena *callee_arena, int32_t callee_expr_ref, int32_t from_dep_index,
    struct ast_PipelineDepCtx *ctx, int32_t *func_index_out) {
  int32_t j;
  int32_t ret_dep;

  (void)mod_arena;
  if (!mod || !callee_arena)
    return 0;
  j = 0;
  while (j < mod->num_funcs) {
    if (pipeline_typeck_expr_var_name_equal_func_c(callee_arena, callee_expr_ref, mod, j) != 0) {
      if (func_index_out)
        func_index_out[0] = j;
      ret_dep = pipeline_module_func_return_type_at(mod, j);
      if (from_dep_index < 0)
        return ret_dep;
      return pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, ret_dep, caller_arena, ctx);
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Write resolved dep/func indices into a CALL expr node.
 * Why: after method-call resolution determines which dep module and function
 *      index the call targets, this writes the resolution into the expr node
 *      so codegen can emit the correct call without re-resolving.
 * Contract: delegates to pipeline_expr_apply_call_resolve (extern accessor).
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

