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
 */

/** 两 slice 等长字节比较；len<=0 返回 0。 */
static int32_t glue_slice_equal_c(const uint8_t *a, int32_t alen, const uint8_t *b, int32_t blen) {
  int32_t i;
  if (!a || !b || alen != blen || alen <= 0)
    return 0;
  i = 0;
  while (i < alen) {
    if (a[i] != b[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/*
 * wave494: forward declaration — defined below after the pattern-unify helpers.
 * Called by both the weak and strong pipeline_typeck_check_expr_method_call_c.
 * PLATFORM: SHARED typeck.
 */
int32_t pipeline_typeck_method_call_generic_ufcs_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t expr_ref, int32_t base_ty, uint8_t *method_nm,
                                                      int32_t method_nlen, int32_t num_args);

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
 * EXPR_METHOD_CALL: typecheck base/args, resolve import.method via path-matched dep
 * slot + W-heap-overload (call_strict_minimal). Never use entry import index as dep index.
 * PLATFORM: SHARED — weak so pipeline_glue_strict_minimal strong definition wins when linked;
 * this body remains correct if it is the sole definition (Ubuntu first-T link order).
 */
XLANG_WEAK int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module,
                                                                       struct ast_ASTArena *arena,
                                                                       int32_t expr_ref,
                                                                       int32_t return_type_ref,
                                                                       struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t base_rc;
  int32_t base_ty;
  int32_t base_ord;
  int32_t method_nlen;
  uint8_t method_nm[128];
  int32_t ret_ty;
  int32_t num_args;
  int32_t arg_i;
  int32_t ord_i32 = (int32_t)ast_TypeKind_TYPE_I32;
  int32_t ord_var = (int32_t)ast_ExprKind_EXPR_VAR;
  extern int32_t typeck_check_expr(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                   int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  /* Authority for overload pick (seed): same as strict_minimal product path. */
  extern int32_t pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
      struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
      int32_t from_dep_index, int32_t want_arity, int32_t call_expr_ref, int32_t is_method,
      struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);

  if (!module || !arena || expr_ref <= 0)
    return 0;
  pipeline_expr_init_call_resolve_at_ref(arena, expr_ref);
  base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
  base_rc = typeck_check_expr(module, arena, base_ref, 0, ctx);
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  base_ord = pipeline_expr_kind_ord_at(arena, base_ref);
  method_nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
  if (method_nlen <= 0 || method_nlen > 127)
    return -1;
  pipeline_expr_method_call_name_into(arena, expr_ref, method_nm);
  /* Args must be typed before overload scoring (PTR elem match needs resolved *T). */
  num_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
  arg_i = 0;
  while (arg_i < num_args) {
    int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, arg_i);
    if (typeck_check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0)
      return -1;
    arg_i = arg_i + 1;
  }
  if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_PIPE] method_call expr=%d base=%d base_kind=%d base_rc=%d base_ty=%d method=%.*s\n",
            (int)expr_ref, (int)base_ref, (int)base_ord, (int)base_rc, (int)base_ty, (int)method_nlen, method_nm);
    if (base_ord == ord_var) {
      int32_t dbg_base_nlen = pipeline_expr_var_name_len(arena, base_ref);
      if (dbg_base_nlen > 0 && dbg_base_nlen <= 127) {
        uint8_t dbg_base_nm[128];
        pipeline_expr_var_name_into(arena, base_ref, dbg_base_nm);
        fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] method_call base_var=%.*s imports=%d\n", (int)dbg_base_nlen,
                dbg_base_nm, (int)pipeline_typeck_module_num_imports_c(module));
      }
    }
  }
  ret_ty = 0;
  if (base_ty <= 0 && ctx && base_ord == ord_var) {
    int32_t base_nlen = pipeline_expr_var_name_len(arena, base_ref);
    if (base_nlen > 0 && base_nlen <= 127) {
      uint8_t base_nm[128];
      int32_t j = 0;
      int32_t n_imp = pipeline_typeck_module_num_imports_c(module);
      pipeline_expr_var_name_into(arena, base_ref, base_nm);
      while (j < n_imp) {
        if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
          int32_t bind_len = pipeline_module_import_binding_name_len(module, j);
          int32_t path_len = pipeline_module_import_path_len(module, j);
          uint8_t bind_nm[128];
          uint8_t path_nm[128];
          int32_t dbg_i = 0;
          while (dbg_i < 64) {
            bind_nm[dbg_i] = 0;
            path_nm[dbg_i] = 0;
            dbg_i = dbg_i + 1;
          }
          dbg_i = 0;
          if (bind_len > 0 && bind_len <= 63)
            while (dbg_i < bind_len) {
              bind_nm[dbg_i] = pipeline_module_import_binding_name_byte_at(module, j, dbg_i);
              dbg_i = dbg_i + 1;
            }
          dbg_i = 0;
          if (path_len > 0 && path_len <= 63)
            while (dbg_i < path_len) {
              path_nm[dbg_i] = pipeline_module_import_path_byte_at(module, j, dbg_i);
              dbg_i = dbg_i + 1;
            }
          fprintf(stderr,
                  "xlang: [XLANG_DEBUG_PIPE] method_call scan_import idx=%d kind=%d bind=%.*s path=%.*s\n", (int)j,
                  (int)pipeline_module_import_kind_at(module, j), (int)(bind_len > 0 ? bind_len : 0),
                  (bind_len > 0 ? bind_nm : (uint8_t *)""), (int)(path_len > 0 ? path_len : 0),
                  (path_len > 0 ? path_nm : (uint8_t *)""));
        }
        if (pipeline_module_import_kind_at(module, j) == GLUE_TYPECK_IMPORT_BINDING &&
            pipeline_typeck_import_binding_name_equal_impl(module, j, base_nm, base_nlen)) {
          int32_t dep_slot = pipeline_typeck_resolve_dep_index_for_import_c(module, ctx, j);
          struct ast_Module *dm = dep_slot >= 0 ? pipeline_dep_ctx_module_at(ctx, dep_slot) : 0;
          if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
            fprintf(stderr,
                    "xlang: [XLANG_DEBUG_PIPE] method_call binding_match idx=%d dep_slot=%d dep=%p dep_funcs=%d\n",
                    (int)j, (int)dep_slot, (void *)dm, dm ? (int)dm->num_funcs : -1);
            if (dm) {
              int32_t dbg_fi = 0;
              while (dbg_fi < dm->num_funcs && dbg_fi < 32) {
                int32_t dbg_fn_len = pipeline_module_func_name_len_at(dm, dbg_fi);
                uint8_t dbg_fn[128];
                if (dbg_fn_len > 0 && dbg_fn_len <= 63) {
                  pipeline_module_func_name_copy64(dm, dbg_fi, dbg_fn);
                  fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] method_call dep_func idx=%d name=%.*s\n", (int)dbg_fi,
                          (int)dbg_fn_len, dbg_fn);
                }
                dbg_fi = dbg_fi + 1;
              }
            }
          }
          if (dm) {
            int32_t bind_fn = 0;
            /* Overload by arg types (not first same-name). Authority: call_strict_minimal. */
            ret_ty = pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
                dm, arena, method_nm, method_nlen, dep_slot, num_args, expr_ref, 1, ctx, &bind_fn);
            if (link_abi_getenv("XLANG_DEBUG_PIPE"))
              fprintf(stderr,
                      "xlang: [XLANG_DEBUG_PIPE] method_call binding_ret idx=%d dep_slot=%d ret_ty=%d bind_fn=%d\n",
                      (int)j, (int)dep_slot, (int)ret_ty, (int)bind_fn);
            if (ret_ty != 0) {
              pipeline_typeck_expr_apply_call_resolve_c(arena, expr_ref, dep_slot, bind_fn);
              break;
            }
            /* Fallback: path/module misalignment; search other dep slots with same overload pick. */
            {
              int32_t try_di;
              int32_t nd = pipeline_dep_ctx_ndep(ctx);
              for (try_di = 0; try_di < nd && ret_ty == 0; try_di++) {
                if (try_di == dep_slot)
                  continue;
                struct ast_Module *try_dm = pipeline_dep_ctx_module_at(ctx, try_di);
                if (!try_dm)
                  continue;
                bind_fn = 0;
                ret_ty = pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
                    try_dm, arena, method_nm, method_nlen, try_di, num_args, expr_ref, 1, ctx, &bind_fn);
                if (ret_ty != 0) {
                  dep_slot = try_di;
                  pipeline_typeck_expr_apply_call_resolve_c(arena, expr_ref, dep_slot, bind_fn);
                }
              }
            }
          }
          break;
        }
        j = j + 1;
      }
    }
  }
  /*
   * wave494: generic method_call UFCS — method on generic struct.
   * Must run BEFORE non-generic UFCS below: the non-generic UFCS uses
   * pipeline_typeck_type_refs_equal_c (pointer equality) which fails for
   * generic instantiations (Wrap<i32> != Wrap<T>). But the weak integer
   * match (score 100) would still match them by TYPE_NAMED kind and stamp
   * the raw return type T, returning 0 before the generic fixup can run.
   * Delegating to pipeline_typeck_method_call_generic_ufcs_c (exported from
   * this TU, G.7 single authority) first ensures pattern-unify of the formal
   * self param with the concrete receiver type and substitutes the return
   * type. Non-generic methods (self has no free type-param) are skipped by
   * the generic path and fall through to non-generic UFCS.
   * PLATFORM: SHARED typeck — mac + Ubuntu.
   */
  if (ret_ty == 0 && base_ty > 0 && method_nlen > 0) {
    if (pipeline_typeck_method_call_generic_ufcs_c(module, arena, expr_ref, base_ty, method_nm, method_nlen,
                                                     num_args) != 0)
      return 0;
  }
  /*
   * wave358 Cap residual pure — UFCS same-module free method (weak twin of
   * pipeline_glue_strict_minimal strong definition).
   * receiver.method(args) → free fn method(receiver, args...) when
   * nparams == num_args+1 and param0 matches receiver type.
   * wave360: auto-ref value → *T self (score 900).
   * PLATFORM: SHARED — G.7 seed strong wins when linked.
   */
  if (ret_ty == 0 && base_ty > 0 && module && method_nlen > 0) {
    int32_t uj;
    int32_t uf_best = -1;
    int32_t uf_best_score = -1;
    int32_t nf = pipeline_module_num_funcs(module);
    for (uj = 0; uj < nf; uj++) {
      int32_t nparams;
      int32_t score;
      int32_t matched;
      int32_t p0;
      int32_t sc0;
      int32_t ai;
      if (!pipeline_module_func_name_equal_at(module, uj, method_nm, method_nlen))
        continue;
      nparams = pipeline_module_func_num_params_at(module, uj);
      if (nparams != num_args + 1)
        continue;
      p0 = pipeline_module_func_param_type_ref_at(module, uj, 0);
      sc0 = -1;
      if (p0 > 0 && pipeline_typeck_type_refs_equal_c(arena, base_ty, p0) != 0)
        sc0 = 1000;
      /* wave360: T.method when free fn is method(self: *T, ...) — auto-ref. */
      if (sc0 < 0 && p0 > 0 &&
          pipeline_type_kind_ord_at(arena, p0) == (int32_t)ast_TypeKind_TYPE_PTR) {
        int32_t pe = pipeline_type_elem_ref_at(arena, p0);
        if (pe > 0 && pipeline_typeck_type_refs_equal_c(arena, base_ty, pe) != 0)
          sc0 = 900;
      }
      if (sc0 < 0)
        continue;
      score = sc0;
      matched = 1;
      for (ai = 0; ai < num_args; ai++) {
        int32_t param_raw = pipeline_module_func_param_type_ref_at(module, uj, ai + 1);
        int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
        int32_t arg_ty = arg_ref > 0 ? pipeline_expr_resolved_type_ref(arena, arg_ref) : 0;
        if (param_raw <= 0 || arg_ty <= 0 ||
            pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_raw) == 0) {
          matched = 0;
          break;
        }
        score += 1000;
      }
      if (matched && score > uf_best_score) {
        uf_best_score = score;
        uf_best = uj;
      }
    }
    if (uf_best >= 0) {
      int32_t uf_ret = pipeline_module_func_return_type_at(module, uf_best);
      if (uf_ret > 0) {
        pipeline_typeck_expr_apply_call_resolve_c(arena, expr_ref, -1, uf_best);
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, uf_ret);
        return 0;
      }
    }
  }
  if (base_ty > 0) {
    /** bootstrap：impl 块被 skip 时 trait 测试 i32.double() 仍须 typeck 通过。 */
    if (pipeline_type_kind_ord_at(arena, base_ty) == ord_i32 && method_nlen == 6 &&
        method_nm[0] == (uint8_t)'d' && method_nm[1] == (uint8_t)'o' && method_nm[2] == (uint8_t)'u' &&
        method_nm[3] == (uint8_t)'b' && method_nm[4] == (uint8_t)'l' && method_nm[5] == (uint8_t)'e')
      ret_ty = pipeline_type_ensure_by_kind_ord(arena, ord_i32);
  }
  if (ret_ty != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
  if (base_rc != 0 && ret_ty == 0)
    return -1;
  if (ret_ty != 0)
    return 0;
  /*
   * wave421 Cap residual pure — no-impl diagnostic (LANG-004 T5).
   * Weak twin of strict_minimal strong body; product may link either.
   * PLATFORM: SHARED typeck.
   */
  {
    extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
    extern int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref);
    extern int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref);
    int32_t line = pipeline_expr_line_at(arena, expr_ref);
    int32_t col = pipeline_expr_col_at(arena, expr_ref);
    lsp_diag_report_typeck((int)line, (int)col, "no impl for type with method %.*s", (int)method_nlen,
                           (const char *)method_nm);
  }
  return -1;
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
static int32_t pipeline_typeck_named_is_module_type_c(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                     const uint8_t *nm, int32_t nlen);

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
enum { W486_MONO_MAX_MAP = 8, W486_MONO_MAX_TARGS = 8, W486_MONO_MAX_DEPTH = 12 };

/* Forward: used by wave487 pattern-unify before their definitions below. */
static int32_t glue_typeck_named_num_type_args_c(struct ast_ASTArena *arena, int32_t ty);
/*
 * wave494: exported (non-static) so pipeline_glue_strict_minimal seed can call
 * these helpers for generic method_call UFCS. G.7 single authority — no
 * duplicate implementation in the strict_minimal TU.
 * PLATFORM: SHARED typeck.
 */
int32_t glue_typeck_type_tree_has_free_param_c(struct ast_Module *mod, struct ast_ASTArena *arena, int32_t ty,
                                                     int32_t depth);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
/* wave1198: pipeline_typeck_call_arg_repr_compatible_ok_c migrated to
 * pipeline_typeck_check_expr.c EOF (#include at L5444 > this file's #include
 * at L5307). Extern fwd decl needed for L2734 callsite in
 * typeck_check_call_ptr_struct_compat_c. PLATFORM: SHARED. */
extern int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                              int32_t param_ref, int32_t arg_ref);

static int32_t glue_typeck_mono_map_lookup_c(uint8_t names[][128], const int32_t *lens, const int32_t *conc,
                                            int32_t n_map, const uint8_t *nm, int32_t nlen) {
  int32_t i;
  int32_t k;
  if (!names || !lens || !conc || !nm || nlen <= 0 || n_map <= 0)
    return 0;
  for (i = 0; i < n_map; i++) {
    if (lens[i] != nlen)
      continue;
    for (k = 0; k < nlen; k++) {
      if (names[i][k] != nm[k])
        break;
    }
    if (k == nlen)
      return conc[i];
  }
  return 0;
}

/**
 * Bind free type-param name → concrete (caller arena type_ref). Fail-closed on
 * conflicting rebind (same name, unequal types). @return 0 ok, -1 conflict/full
 */
static int32_t glue_typeck_mono_map_bind_c(uint8_t names[][128], int32_t *lens, int32_t *conc, int32_t *n_map,
                                          int32_t max_map, const uint8_t *nm, int32_t nlen, int32_t concrete_ty,
                                          struct ast_ASTArena *caller_arena) {
  int32_t prev;
  if (!names || !lens || !conc || !n_map || !nm || nlen <= 0 || nlen > 127 || concrete_ty <= 0 || max_map <= 0)
    return -1;
  prev = glue_typeck_mono_map_lookup_c(names, lens, conc, *n_map, nm, nlen);
  if (prev > 0) {
    if (caller_arena && pipeline_typeck_type_refs_equal_c(caller_arena, prev, concrete_ty) == 0)
      return -1;
    return 0;
  }
  if (*n_map >= max_map)
    return -1;
  memset(names[*n_map], 0, 64);
  memcpy(names[*n_map], nm, (size_t)nlen);
  lens[*n_map] = nlen;
  conc[*n_map] = concrete_ty;
  *n_map = *n_map + 1;
  return 0;
}

/**
 * wave487: recursively pattern-unify formal type (search_arena) with concrete
 * arg type (caller_arena). Free TYPE_NAMED formals bind; module TYPE_NAMED with
 * type-args unify pairwise against arg type-args (or elem_type_ref slot0).
 * @return 0 ok (partial OK if formal has no free params), -1 hard conflict
 * PLATFORM: SHARED — G.7 single authority with subst/map helpers above.
 */
int32_t glue_typeck_pattern_unify_bind_c(struct ast_Module *mod, struct ast_ASTArena *formal_arena,
                                               int32_t formal_ty, struct ast_ASTArena *arg_arena, int32_t arg_ty,
                                               uint8_t names[][128], int32_t *lens, int32_t *conc, int32_t *n_map,
                                               int32_t max_map, int32_t depth) {
  int32_t fk;
  int32_t ak;
  int32_t fnlen;
  uint8_t fnm[128];
  int32_t anlen;
  uint8_t anm[128];
  int32_t n_fta;
  int32_t n_ata;
  int32_t i;
  int32_t fta;
  int32_t ata;
  int32_t felem;
  int32_t aelem;
  extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);

  if (!mod || !formal_arena || !arg_arena || !names || !lens || !conc || !n_map || formal_ty <= 0 || arg_ty <= 0)
    return -1;
  if (depth > W486_MONO_MAX_DEPTH)
    return -1;

  fk = pipeline_type_kind_ord_at(formal_arena, formal_ty);
  ak = pipeline_type_kind_ord_at(arg_arena, arg_ty);
  if (fk < 0 || ak < 0)
    return -1;

  /* Free type-param formal (TYPE_NAMED not a module struct/alias). */
  if (fk == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(fnm, 0, sizeof(fnm));
    fnlen = pipeline_type_named_name_into(formal_arena, formal_ty, fnm);
    if (fnlen <= 0)
      return -1;
    if (pipeline_typeck_named_is_module_type_c(mod, formal_arena, fnm, fnlen) == 0) {
      /* Identity bind: T → concrete arg type (any kind). */
      return glue_typeck_mono_map_bind_c(names, lens, conc, n_map, max_map, fnm, fnlen, arg_ty, arg_arena);
    }
    /* Module named formal: require arg same name + unify type-pos args. */
    if (ak != (int32_t)ast_TypeKind_TYPE_NAMED)
      return -1;
    memset(anm, 0, sizeof(anm));
    anlen = pipeline_type_named_name_into(arg_arena, arg_ty, anm);
    if (anlen <= 0 || !glue_slice_equal_c(fnm, fnlen, anm, anlen))
      return -1;
    n_fta = glue_typeck_named_num_type_args_c(formal_arena, formal_ty);
    if (n_fta <= 0) {
      /* Concrete module formal with no free tree — nothing to bind. */
      return 0;
    }
    n_ata = glue_typeck_named_num_type_args_c(arg_arena, arg_ty);
    /* Arg may only expose slot0 via elem_type_ref (array_size path). */
    if (n_ata <= 0) {
      aelem = pipeline_type_elem_ref_at(arg_arena, arg_ty);
      if (aelem > 0)
        n_ata = 1;
    }
    if (n_ata < n_fta)
      return -1;
    for (i = 0; i < n_fta; i++) {
      fta = pipeline_type_type_arg_ref_at(formal_arena, formal_ty, i);
      if (fta <= 0 && i == 0)
        fta = pipeline_type_elem_ref_at(formal_arena, formal_ty);
      ata = pipeline_type_type_arg_ref_at(arg_arena, arg_ty, i);
      if (ata <= 0 && i == 0)
        ata = pipeline_type_elem_ref_at(arg_arena, arg_ty);
      if (fta <= 0 || ata <= 0)
        return -1;
      if (glue_typeck_pattern_unify_bind_c(mod, formal_arena, fta, arg_arena, ata, names, lens, conc, n_map, max_map,
                                          depth + 1) != 0)
        return -1;
    }
    return 0;
  }

  /* Compound: ptr/slice/array/vector — strip and unify elems when both match. */
  if (fk == (int32_t)ast_TypeKind_TYPE_PTR || fk == (int32_t)ast_TypeKind_TYPE_SLICE ||
      fk == (int32_t)ast_TypeKind_TYPE_ARRAY || fk == (int32_t)ast_TypeKind_TYPE_VECTOR) {
    if (ak != fk)
      return -1;
    felem = pipeline_type_elem_ref_at(formal_arena, formal_ty);
    aelem = pipeline_type_elem_ref_at(arg_arena, arg_ty);
    if (felem <= 0 || aelem <= 0)
      return -1;
    if (fk == (int32_t)ast_TypeKind_TYPE_ARRAY || fk == (int32_t)ast_TypeKind_TYPE_VECTOR) {
      if (pipeline_type_array_size_at(formal_arena, formal_ty) != pipeline_type_array_size_at(arg_arena, arg_ty))
        return -1;
    }
    return glue_typeck_pattern_unify_bind_c(mod, formal_arena, felem, arg_arena, aelem, names, lens, conc, n_map,
                                           max_map, depth + 1);
  }

  /* Builtin formal (i32/…): no free param; kinds must agree (soft accept equal). */
  if (fk == ak)
    return 0;
  return -1;
}

/**
 * Build free-type-param mono map from value formals + args.
 * Identity: bare free formal `x: T`. Pattern: module formal with free tree
 * `w: Wrap<T>` vs arg `Wrap<i32>`. @return n_map (>=0); 0 if nothing bound.
 */
static int32_t glue_typeck_build_value_formal_mono_map_c(struct ast_Module *search_mod,
                                                        struct ast_ASTArena *search_arena,
                                                        struct ast_ASTArena *caller_arena, int32_t call_expr_ref,
                                                        int32_t func_idx, uint8_t names[][128], int32_t *lens,
                                                        int32_t *conc, int32_t max_map) {
  int32_t n_map;
  int32_t num_params;
  int32_t pi;
  int32_t param_ty;
  int32_t arg_i;
  int32_t arg_ty;
  int32_t ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;
  uint8_t param_nm[128];
  int32_t param_nlen;
  int32_t gi;
  int32_t dup;

  n_map = 0;
  if (!search_mod || !search_arena || !caller_arena || call_expr_ref <= 0 || func_idx < 0 || !names || !lens ||
      !conc || max_map <= 0)
    return 0;
  num_params = pipeline_module_func_num_params_at(search_mod, func_idx);
  for (pi = 0; pi < num_params && n_map < max_map; pi++) {
    param_ty = pipeline_module_func_param_type_ref_at(search_mod, func_idx, pi);
    if (param_ty <= 0)
      continue;
    arg_i = pipeline_expr_call_arg_ref(caller_arena, call_expr_ref, pi);
    if (arg_i <= 0)
      continue;
    arg_ty = pipeline_expr_resolved_type_ref(caller_arena, arg_i);
    if (arg_ty <= 0)
      continue;

    /* Fast path: bare free TYPE_NAMED formal (wave451/486 identity). */
    if (pipeline_type_kind_ord_at(search_arena, param_ty) == ord_named) {
      memset(param_nm, 0, sizeof(param_nm));
      param_nlen = pipeline_type_named_name_into(search_arena, param_ty, param_nm);
      if (param_nlen > 0 &&
          pipeline_typeck_named_is_module_type_c(search_mod, search_arena, param_nm, param_nlen) == 0) {
        dup = 0;
        for (gi = 0; gi < n_map; gi++) {
          if (lens[gi] == param_nlen && memcmp(names[gi], param_nm, (size_t)param_nlen) == 0) {
            dup = 1;
            break;
          }
        }
        if (!dup) {
          if (glue_typeck_mono_map_bind_c(names, lens, conc, &n_map, max_map, param_nm, param_nlen, arg_ty,
                                         caller_arena) != 0)
            return 0; /* conflict → fail closed (empty map) */
        }
        continue;
      }
    }

    /* wave487: pattern-unify module formals with free type-arg trees. */
    if (glue_typeck_type_tree_has_free_param_c(search_mod, search_arena, param_ty, 0) != 0) {
      if (glue_typeck_pattern_unify_bind_c(search_mod, search_arena, param_ty, caller_arena, arg_ty, names, lens,
                                          conc, &n_map, max_map, 0) != 0) {
        /* Soft: skip this formal; other formals may still bind. */
        continue;
      }
    }
  }
  return n_map;
}

/** Count type-position args on TYPE_NAMED (array_size preferred; sidecar walk fallback). */
static int32_t glue_typeck_named_num_type_args_c(struct ast_ASTArena *arena, int32_t ty) {
  int32_t n;
  int32_t asz;
  int32_t i;
  extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
  if (!arena || ty <= 0)
    return 0;
  asz = pipeline_type_array_size_at(arena, ty);
  if (asz > 0 && asz <= W486_MONO_MAX_TARGS)
    return asz;
  n = 0;
  for (i = 0; i < W486_MONO_MAX_TARGS; i++) {
    if (pipeline_type_type_arg_ref_at(arena, ty, i) <= 0)
      break;
    n = i + 1;
  }
  return n;
}

/** 1 if TYPE_NAMED tree contains a free type-param name (not a module concrete). */
int32_t glue_typeck_type_tree_has_free_param_c(struct ast_Module *mod, struct ast_ASTArena *arena, int32_t ty,
                                                     int32_t depth) {
  int32_t kind;
  int32_t nlen;
  uint8_t nm[128];
  int32_t n_ta;
  int32_t i;
  int32_t ta;
  int32_t elem;
  extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
  if (!mod || !arena || ty <= 0 || depth > W486_MONO_MAX_DEPTH)
    return 0;
  kind = pipeline_type_kind_ord_at(arena, ty);
  if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(nm, 0, sizeof(nm));
    nlen = pipeline_type_named_name_into(arena, ty, nm);
    if (nlen <= 0)
      return 0;
    if (pipeline_typeck_named_is_module_type_c(mod, arena, nm, nlen) == 0)
      return 1; /* free type param */
    n_ta = glue_typeck_named_num_type_args_c(arena, ty);
    for (i = 0; i < n_ta; i++) {
      ta = pipeline_type_type_arg_ref_at(arena, ty, i);
      if (ta > 0 && glue_typeck_type_tree_has_free_param_c(mod, arena, ta, depth + 1))
        return 1;
    }
    return 0;
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_PTR || kind == (int32_t)ast_TypeKind_TYPE_SLICE ||
      kind == (int32_t)ast_TypeKind_TYPE_ARRAY || kind == (int32_t)ast_TypeKind_TYPE_VECTOR) {
    elem = pipeline_type_elem_ref_at(arena, ty);
    if (elem > 0)
      return glue_typeck_type_tree_has_free_param_c(mod, arena, elem, depth + 1);
  }
  return 0;
}

/**
 * Allocate TYPE_NAMED with type-pos args (never reuse find_or_alloc_named — that
 * collapses mono combos that share the same bare name).
 */
static int32_t glue_typeck_alloc_named_with_type_args_c(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len,
                                                       const int32_t *arg_refs, int32_t n_args) {
  int32_t tr;
  int32_t i;
  struct ast_Type *t;
  extern int32_t pipeline_type_append_type_arg(struct ast_ASTArena *a, int32_t type_ref, int32_t arg_ref);
  if (!arena || !name || name_len <= 0 || name_len > 127)
    return 0;
  if (n_args < 0 || n_args > W486_MONO_MAX_TARGS)
    return 0;
  tr = pipeline_arena_type_alloc(arena);
  if (tr <= 0)
    return 0;
  if (pipeline_type_init_named_at(arena, tr, name, name_len) == 0)
    return 0;
  for (i = 0; i < n_args; i++) {
    if (arg_refs[i] <= 0)
      return 0;
    if (pipeline_type_append_type_arg(arena, tr, arg_refs[i]) != 0)
      return 0;
  }
  t = pipeline_arena_type_ptr(arena, tr);
  if (t && n_args > 0) {
    t->elem_type_ref = arg_refs[0];
    t->array_size = n_args;
  }
  return tr;
}

/**
 * Recursively substitute free type-params in ty (src_arena) into dst_arena using
 * the mono map. Concrete module names without free params map by name; named
 * types with type-args always allocate a fresh mono node.
 * @return concrete type_ref in dst_arena, or 0 on failure
 */
int32_t glue_typeck_subst_type_ref_c(struct ast_Module *mod, struct ast_ASTArena *src_arena,
                                           struct ast_ASTArena *dst_arena, int32_t ty, uint8_t names[][128],
                                           const int32_t *lens, const int32_t *conc, int32_t n_map, int32_t depth) {
  int32_t kind;
  int32_t nlen;
  uint8_t nm[128];
  int32_t n_ta;
  int32_t i;
  int32_t ta;
  int32_t sa;
  int32_t args[W486_MONO_MAX_TARGS];
  int32_t elem;
  int32_t mapped_elem;
  int32_t asz;
  int32_t looked;
  extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
  extern int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena *a, int32_t kind_ord, int32_t elem_ref,
                                                     int32_t array_size);
  extern int32_t pipeline_type_find_or_alloc_slice(struct ast_ASTArena *a, int32_t elem_ref, uint8_t *rbuf,
                                                  int32_t rlen);

  if (!mod || !src_arena || !dst_arena || ty <= 0 || depth > W486_MONO_MAX_DEPTH)
    return 0;
  kind = pipeline_type_kind_ord_at(src_arena, ty);
  if (kind < 0)
    return 0;
  if (kind == (int32_t)ast_TypeKind_TYPE_I32 || kind == (int32_t)ast_TypeKind_TYPE_I64 ||
      kind == (int32_t)ast_TypeKind_TYPE_BOOL || kind == (int32_t)ast_TypeKind_TYPE_F64 ||
      kind == (int32_t)ast_TypeKind_TYPE_U8 || kind == (int32_t)ast_TypeKind_TYPE_U32 ||
      kind == (int32_t)ast_TypeKind_TYPE_U64 || kind == (int32_t)ast_TypeKind_TYPE_ISIZE ||
      kind == (int32_t)ast_TypeKind_TYPE_F32 || kind == (int32_t)ast_TypeKind_TYPE_USIZE ||
      kind == (int32_t)ast_TypeKind_TYPE_VOID)
    return pipeline_type_ensure_by_kind_ord(dst_arena, kind);

  if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(nm, 0, sizeof(nm));
    nlen = pipeline_type_named_name_into(src_arena, ty, nm);
    if (nlen <= 0)
      return 0;
    if (pipeline_typeck_named_is_module_type_c(mod, src_arena, nm, nlen) == 0) {
      looked = glue_typeck_mono_map_lookup_c(names, lens, conc, n_map, nm, nlen);
      return looked > 0 ? looked : 0;
    }
    n_ta = glue_typeck_named_num_type_args_c(src_arena, ty);
    if (n_ta <= 0)
      return pipeline_type_find_or_alloc_named(dst_arena, nm, nlen);
    for (i = 0; i < n_ta; i++) {
      ta = pipeline_type_type_arg_ref_at(src_arena, ty, i);
      if (ta <= 0)
        return 0;
      sa = glue_typeck_subst_type_ref_c(mod, src_arena, dst_arena, ta, names, lens, conc, n_map, depth + 1);
      if (sa <= 0)
        return 0;
      args[i] = sa;
    }
    return glue_typeck_alloc_named_with_type_args_c(dst_arena, nm, nlen, args, n_ta);
  }

  elem = pipeline_type_elem_ref_at(src_arena, ty);
  mapped_elem = 0;
  if (elem > 0) {
    mapped_elem =
        glue_typeck_subst_type_ref_c(mod, src_arena, dst_arena, elem, names, lens, conc, n_map, depth + 1);
    if (mapped_elem <= 0)
      return 0;
  }
  asz = pipeline_type_array_size_at(src_arena, ty);
  if (kind == (int32_t)ast_TypeKind_TYPE_PTR)
    return pipeline_type_find_or_alloc_compound(dst_arena, (int32_t)ast_TypeKind_TYPE_PTR, mapped_elem, 0);
  if (kind == (int32_t)ast_TypeKind_TYPE_VECTOR)
    return pipeline_type_find_or_alloc_compound(dst_arena, (int32_t)ast_TypeKind_TYPE_VECTOR, mapped_elem, asz);
  if (kind == (int32_t)ast_TypeKind_TYPE_ARRAY) {
    if (mapped_elem <= 0 || asz <= 0)
      return 0;
    return pipeline_type_find_or_alloc_compound(dst_arena, (int32_t)ast_TypeKind_TYPE_ARRAY, mapped_elem, asz);
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_SLICE)
    return pipeline_type_find_or_alloc_slice(dst_arena, mapped_elem, NULL, 0);
  return 0;
}

/**
 * Build formal free-type-param map from value args; if ret is a module named
 * type whose type-arg tree still holds free params, stamp mono return.
 * @return mono type_ref in caller arena, or 0 if not applicable / incomplete
 */
static int32_t glue_generic_call_subst_module_ret_c(struct ast_Module *search_mod, struct ast_ASTArena *search_arena,
                                                   struct ast_ASTArena *caller_arena, int32_t call_expr_ref,
                                                   int32_t func_idx, int32_t ret_ty) {
  int32_t ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;
  int32_t n_map;
  uint8_t map_names[W486_MONO_MAX_MAP][128];
  int32_t map_lens[W486_MONO_MAX_MAP];
  int32_t map_conc[W486_MONO_MAX_MAP];
  uint8_t ret_nm[128];
  int32_t ret_nlen;
  int32_t mono_ret;

  if (!search_mod || !search_arena || !caller_arena || call_expr_ref <= 0 || func_idx < 0 || ret_ty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(search_arena, ret_ty) != ord_named)
    return 0;
  memset(ret_nm, 0, sizeof(ret_nm));
  ret_nlen = pipeline_type_named_name_into(search_arena, ret_ty, ret_nm);
  if (ret_nlen <= 0)
    return 0;
  /* Only module returns (Wrap / Pair / …). Free type-param ret uses path below. */
  if (pipeline_typeck_named_is_module_type_c(search_mod, search_arena, ret_nm, ret_nlen) == 0)
    return 0;
  if (glue_typeck_type_tree_has_free_param_c(search_mod, search_arena, ret_ty, 0) == 0)
    return 0;

  n_map = glue_typeck_build_value_formal_mono_map_c(search_mod, search_arena, caller_arena, call_expr_ref, func_idx,
                                                   map_names, map_lens, map_conc, W486_MONO_MAX_MAP);
  if (n_map <= 0)
    return 0;

  mono_ret = glue_typeck_subst_type_ref_c(search_mod, search_arena, caller_arena, ret_ty, map_names, map_lens,
                                         map_conc, n_map, 0);
  if (mono_ret <= 0)
    return 0;
  /* Fail-closed: mono tree must not still contain free type params. */
  if (glue_typeck_type_tree_has_free_param_c(search_mod, caller_arena, mono_ret, 0) != 0)
    return 0;
  return mono_ret;
}

/**
 * wave487: when ret is a free type-param, stamp CALL from formal pattern map
 * (`unwrap<T>(w: Wrap<T>): T` → T from arg's type-arg). Also subst module ret
 * trees that only need pattern-derived free bindings.
 * @return stamped mono type_ref, or 0 if not applicable
 */
static int32_t glue_generic_call_subst_ret_from_formal_map_c(struct ast_Module *search_mod,
                                                            struct ast_ASTArena *search_arena,
                                                            struct ast_ASTArena *caller_arena,
                                                            int32_t call_expr_ref, int32_t func_idx,
                                                            int32_t ret_ty) {
  int32_t ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;
  int32_t n_map;
  uint8_t map_names[W486_MONO_MAX_MAP][128];
  int32_t map_lens[W486_MONO_MAX_MAP];
  int32_t map_conc[W486_MONO_MAX_MAP];
  uint8_t ret_nm[128];
  int32_t ret_nlen;
  int32_t looked;
  int32_t mono_ret;

  if (!search_mod || !search_arena || !caller_arena || call_expr_ref <= 0 || func_idx < 0 || ret_ty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(search_arena, ret_ty) != ord_named)
    return 0;
  memset(ret_nm, 0, sizeof(ret_nm));
  ret_nlen = pipeline_type_named_name_into(search_arena, ret_ty, ret_nm);
  if (ret_nlen <= 0)
    return 0;

  n_map = glue_typeck_build_value_formal_mono_map_c(search_mod, search_arena, caller_arena, call_expr_ref, func_idx,
                                                   map_names, map_lens, map_conc, W486_MONO_MAX_MAP);
  if (n_map <= 0)
    return 0;

  /* Free type-param ret: direct map lookup (unwrap / nested unwrap_inner). */
  if (pipeline_typeck_named_is_module_type_c(search_mod, search_arena, ret_nm, ret_nlen) == 0) {
    looked = glue_typeck_mono_map_lookup_c(map_names, map_lens, map_conc, n_map, ret_nm, ret_nlen);
    return looked > 0 ? looked : 0;
  }

  /* Module ret with free tree — same as subst_module_ret but reuses shared map. */
  if (glue_typeck_type_tree_has_free_param_c(search_mod, search_arena, ret_ty, 0) == 0)
    return 0;
  mono_ret = glue_typeck_subst_type_ref_c(search_mod, search_arena, caller_arena, ret_ty, map_names, map_lens,
                                         map_conc, n_map, 0);
  if (mono_ret <= 0)
    return 0;
  if (glue_typeck_type_tree_has_free_param_c(search_mod, caller_arena, mono_ret, 0) != 0)
    return 0;
  return mono_ret;
}

/*
 * wave494: generic method_call UFCS resolution.
 *
 * Why: `w.get()` where w: Wrap<i32> and `impl Wrap<T> { function get(self:
 * Wrap<T>): T }` is parsed as EXPR_METHOD_CALL (kind 49). The non-generic UFCS
 * path in pipeline_typeck_check_expr_method_call_c uses
 * pipeline_typeck_type_refs_equal_c (pointer-level equality), which fails for
 * generic instantiations: Wrap<i32> != Wrap<T>. Without this fix, the method
 * call is left unresolved (ret stays T / ?) and the return-statement typeck
 * reports "expected i32, found T".
 *
 * Root: pattern-unify the formal self param (Wrap<T>, in the module arena)
 * with the concrete receiver type (Wrap<i32>, in the caller arena) to build
 * a free-name → concrete-type map (T → i32), then substitute the function
 * return type (T → i32) and stamp the method_call resolved_type.
 *
 * Authority (G.7 single path): this exported function is the SOLE
 * implementation of generic method_call UFCS. Both the weak
 * pipeline_typeck_check_expr_method_call_c (pipeline_glue.c) and the strong
 * one (pipeline_glue_strict_minimal.from_x.c) call it after the non-generic
 * UFCS block fails. The pattern-unify/subst helpers are exported from this TU
 * (no duplicate implementation in the strict_minimal seed).
 *
 * Contract:
 * - module/arena/expr_ref must be valid; base_ty > 0; method_nlen > 0.
 * - On success: sets expr_ref resolved_type_ref + call_resolve(-1, func_idx),
 *   returns 1.
 * - On failure (no generic match / unification conflict): returns 0, leaves
 *   expr_ref untouched.
 * - Only scans same-module free functions (nparams == num_args + 1, param[0]
 *   is the implicit self). Cross-module import.method is handled by the
 *   earlier binding-scan path, not here.
 * PLATFORM: SHARED typeck — mac + Ubuntu.
 */
int32_t pipeline_typeck_method_call_generic_ufcs_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t expr_ref, int32_t base_ty, uint8_t *method_nm,
                                                      int32_t method_nlen, int32_t num_args) {
  int32_t nf;
  int32_t fi;
  int32_t nparams;
  int32_t p0;
  int32_t g_ret;
  int32_t g_ai;
  int32_t g_matched;

  if (!module || !arena || expr_ref <= 0 || base_ty <= 0 || !method_nm || method_nlen <= 0)
    return 0;
  nf = pipeline_module_num_funcs(module);
  for (fi = 0; fi < nf; fi = fi + 1) {
    if (pipeline_module_func_name_equal_at(module, fi, method_nm, method_nlen) == 0)
      continue;
    nparams = pipeline_module_func_num_params_at(module, fi);
    if (nparams != num_args + 1)
      continue;
    p0 = pipeline_module_func_param_type_ref_at(module, fi, 0);
    if (p0 <= 0)
      continue;
    /* Only enter generic path when self param has a free type-param. */
    if (glue_typeck_type_tree_has_free_param_c(module, arena, p0, 0) == 0)
      continue;
    {
      uint8_t g_names[W486_MONO_MAX_MAP][128];
      int32_t g_lens[W486_MONO_MAX_MAP];
      int32_t g_conc[W486_MONO_MAX_MAP];
      int32_t g_nmap = 0;
      /* Pattern-unify formal self (p0, module arena) with concrete receiver
       * (base_ty, caller arena) to build free-name → concrete-type map. */
      if (glue_typeck_pattern_unify_bind_c(module, arena, p0, arena, base_ty, g_names, g_lens, g_conc, &g_nmap,
                                            W486_MONO_MAX_MAP, 0) != 0 ||
          g_nmap <= 0)
        continue;
      /* Verify non-self args match (after substitution if the param is generic). */
      g_matched = 1;
      for (g_ai = 0; g_ai < num_args; g_ai = g_ai + 1) {
        int32_t g_param = pipeline_module_func_param_type_ref_at(module, fi, g_ai + 1);
        int32_t g_arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, g_ai);
        int32_t g_arg_ty = g_arg_ref > 0 ? pipeline_expr_resolved_type_ref(arena, g_arg_ref) : 0;
        if (g_param <= 0 || g_arg_ty <= 0) {
          g_matched = 0;
          break;
        }
        if (pipeline_typeck_type_refs_equal_c(arena, g_arg_ty, g_param) != 0)
          continue;
        /* Try substituted match for generic non-self params (rare but possible). */
        {
          int32_t g_sub = glue_typeck_subst_type_ref_c(module, arena, arena, g_param, g_names, g_lens, g_conc, g_nmap, 0);
          if (g_sub <= 0 || pipeline_typeck_type_refs_equal_c(arena, g_arg_ty, g_sub) == 0) {
            g_matched = 0;
            break;
          }
        }
      }
      if (g_matched == 0)
        continue;
      /* Substitute the return type using the unification map. */
      g_ret = pipeline_module_func_return_type_at(module, fi);
      if (g_ret <= 0)
        continue;
      {
        int32_t g_mono = glue_typeck_subst_type_ref_c(module, arena, arena, g_ret, g_names, g_lens, g_conc, g_nmap, 0);
        if (g_mono > 0 && glue_typeck_type_tree_has_free_param_c(module, arena, g_mono, 0) == 0) {
          pipeline_expr_apply_call_resolve(arena, expr_ref, -1, fi);
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, g_mono);
          return 1;
        }
      }
    }
  }
  return 0;
}

/**
 * Effective mono type_ref for a call arg, falling back to lit-kind defaults.
 *
 * Why: try_infer_generic_call_from_args needs each arg to pin a mono type for
 * free-T unification. Bare INT/BOOL/FLOAT/STRING lits often lack
 * resolved_type_ref until stamp; prior try_infer required arg_ty>0 → id(42)
 * fell through to requires_type_args even after free-T formals were accepted
 * by call_arg_types. This helper centralizes the effective-type fallback so
 * value_ok and same-name unify share one path.
 *
 * Invariant: returns type_ref >0 if arg can pin a mono type; 0 if NULL arena,
 * invalid arg_ref, or arg is bare `null` keyword (cannot pin free T).
 *   - EXPR_LIT(0) non-null → TYPE_I32
 *   - EXPR_FLOAT_LIT(1) → TYPE_F64
 *   - EXPR_BOOL_LIT(2) → TYPE_BOOL
 *   - EXPR_STRING_LIT(59) → *u8 (C interop default)
 *
 * Asm/Perf: O(1) — one resolved_type_ref read + kind dispatch. Cold path —
 * called per call arg in try_infer_generic_call_from_args (glue.c:14810/14834/
 * 14860).
 *
 * PLATFORM: SHARED — typeck mono pin is platform-independent.
 *
 * wave1075 G.7: migrated from glue.c:14747 (body 31 LOC). Static (non-extern):
 * same-TU — method_call.c #include at L14220 < def EOF < all callsites
 * (L14810/14834/14860). Dependencies: pipeline_expr_resolved_type_ref /
 * pipeline_expr_kind_ord_at / pipeline_type_ensure_by_kind_ord /
 * pipeline_type_find_or_alloc_compound (all extern);
 * typeck_expr_is_null_keyword (extern, declared in-function-body).
 */
static int32_t pipeline_typeck_call_arg_effective_type_c(struct ast_ASTArena *arena, int32_t arg_ref) {
  int32_t arg_ty;
  int32_t ek;
  extern int32_t typeck_expr_is_null_keyword(struct ast_ASTArena *a, int32_t expr_ref);
  if (!arena || arg_ref <= 0)
    return 0;
  arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
  if (arg_ty > 0)
    return arg_ty;
  ek = pipeline_expr_kind_ord_at(arena, arg_ref);
  /* EXPR_LIT=0: bare int lit (not keyword null) → i32 for mono pin. */
  if (ek == 0) {
    if (typeck_expr_is_null_keyword(arena, arg_ref) != 0)
      return 0; /* null alone cannot pin free T */
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  }
  /* EXPR_FLOAT_LIT=1 → f64 (product default float lit width). */
  if (ek == 1)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_F64);
  /* EXPR_BOOL_LIT=2 → bool. */
  if (ek == 2)
    return pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_BOOL);
  /* EXPR_STRING_LIT=59 → *u8 (C interop default for string lit). */
  if (ek == 59) {
    int32_t u8t = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U8);
    if (u8t <= 0)
      return 0;
    return pipeline_type_find_or_alloc_compound(arena, (int32_t)ast_TypeKind_TYPE_PTR, u8t, 0);
  }
  return 0;
}

/**
 * Count `.`-separated segments in an import path string.
 *
 * Why: typeck.x::typeck_import_path_segment_count needs to know how many dotted
 * segments an import path carries (e.g. `a.b.c` → 3) so the binding resolver
 * can iterate matching dep imports segment-by-segment. Bare copy of the loop
 * lived inline in glue.c; centralizing here keeps the import path domain with
 * the call/import binding authority.
 *
 * Invariant: returns 0 for NULL path or path_len <= 0; otherwise returns the
 * segment count (a path with no dots yields 1).
 *
 * Asm/Perf: O(n) — single byte scan. Cold path — called per import path
 * resolution in pipeline_typeck_map_import_binding_named_to_caller_c
 * (glue.c:11893).
 *
 * PLATFORM: SHARED — import path lexing is platform-independent.
 *
 * wave1085 G.7: migrated from glue.c:11763 (body 15 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:11762 (before all callsites L11893+) <
 * method_call.c #include at L14053 < def EOF. Dependencies: none (pure byte
 * scan over caller-provided buffer).
 */
static int32_t pipeline_typeck_import_path_segment_count_impl(const uint8_t *path, int32_t path_len) {
  int32_t n;
  int32_t ii;

  if (!path || path_len <= 0)
    return 0;
  n = 1;
  ii = 0;
  while (ii < path_len) {
    if (path[ii] == 46)
      n = n + 1;
    ii = ii + 1;
  }
  return n;
}

/**
 * Compare one import path slice (offset + seg_len) against a name buffer.
 *
 * Why: typeck.x::typeck_import_path_slice_equal verifies that a contiguous
 * sub-slice of an import path (e.g. one segment between dots) equals a candidate
 * name. Used by the binding resolver to walk dep imports segment-by-segment
 * and by the layer-buffer path matching for nested re-exports.
 *
 * Invariant: returns 0 for unequal lengths or seg_len <= 0; returns 1 iff all
 * seg_len bytes match. Module/imp_ix must be valid (caller-checked).
 *
 * Asm/Perf: O(n) — single byte loop. Cold path — called in
 * pipeline_typeck_map_import_binding_named_to_caller_c (glue.c:11899/11918).
 *
 * PLATFORM: SHARED — import path slice compare is platform-independent.
 *
 * wave1086 G.7: migrated from glue.c:11780 (body 14 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:11762 (before all callsites L11899+) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_module_import_path_byte_at (extern).
 */
static int32_t pipeline_typeck_import_path_slice_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t off,
                                                            int32_t seg_len, uint8_t *nm, int32_t nm_len) {
  int32_t i;

  if (seg_len != nm_len || seg_len <= 0)
    return 0;
  i = 0;
  while (i < seg_len) {
    if (pipeline_module_import_path_byte_at(module, imp_ix, off + i) != nm[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * Compare one import binding name (the `as` alias or declared name) against nm.
 *
 * Why: typeck.x::typeck_import_binding_name_equal is used by the binding
 * resolver to find the dep import whose binding name matches a candidate
 * (e.g. when resolving `math.floor`, the resolver walks dep imports looking
 * for the one bound to `math`). Centralizing here keeps the import binding
 * name comparison with the import path authority.
 *
 * Invariant: returns 0 for unequal lengths or nm_len <= 0; returns 1 iff all
 * nm_len bytes match. Module/imp_ix must be valid (caller-checked).
 *
 * Asm/Perf: O(n) — single byte loop. Cold path — called in
 * pipeline_typeck_map_import_binding_named_to_caller_c (glue.c:12025).
 *
 * PLATFORM: SHARED — import binding name compare is platform-independent.
 *
 * wave1087 G.7: migrated from glue.c:11796 (body 16 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:11762 (before all callsites L12025+) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_module_import_binding_name_len /
 * pipeline_module_import_binding_name_byte_at (both extern).
 */
static int32_t pipeline_typeck_import_binding_name_equal_impl(struct ast_Module *module, int32_t imp_ix, uint8_t *nm,
                                                              int32_t nm_len) {
  int32_t bl;
  int32_t i;

  bl = pipeline_module_import_binding_name_len(module, imp_ix);
  if (bl != nm_len || nm_len <= 0)
    return 0;
  i = 0;
  while (i < nm_len) {
    if (pipeline_module_import_binding_name_byte_at(module, imp_ix, i) != nm[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * Compare one import select name (a sub-binding inside a multi-name import)
 * against nm at the given select index.
 *
 * Why: typeck.x::typeck_import_select_name_equal is used when an import
 * exposes multiple names (e.g. `from foo import {a, b}`); the resolver walks
 * each select slot comparing against the candidate name. Centralizing here
 * keeps the select-name compare with the import binding authority.
 *
 * Invariant: returns 0 for unequal lengths or nm_len <= 0; returns 1 iff all
 * nm_len bytes match. Module/imp_ix/sel must be valid (caller-checked).
 *
 * Asm/Perf: O(n) — single byte loop. Cold path — called in
 * pipeline_typeck_map_import_binding_named_to_caller_c (glue.c:12106).
 *
 * PLATFORM: SHARED — import select name compare is platform-independent.
 *
 * wave1088 G.7: migrated from glue.c:11814 (body 16 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:11762 (before all callsites L12106+) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_module_import_select_name_len /
 * pipeline_module_import_select_name_byte_at (both extern).
 */
static int32_t pipeline_typeck_import_select_name_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t sel,
                                                             uint8_t *nm, int32_t nm_len) {
  int32_t sl;
  int32_t i;

  sl = pipeline_module_import_select_name_len(module, imp_ix, sel);
  if (sl != nm_len || nm_len <= 0)
    return 0;
  i = 0;
  while (i < nm_len) {
    if (pipeline_module_import_select_name_byte_at(module, imp_ix, sel, i) != nm[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * Count non-extern funcs in module m whose name equals (name, name_len).
 *
 * Why: typeck.x::find_func_return_type_in_module_by_name_overload and the
 * CALL overload dispatcher both need to know whether a callee name resolves
 * to more than one candidate (i.e. is overload-worthy). Without this gate the
 * dispatcher would always run the full scoring loop even for unique names.
 * Centralizing here keeps overload gating with the call resolution authority.
 *
 * Invariant: returns 0 for NULL m/name or name_len <= 0; otherwise returns
 * the count of non-extern funcs whose name matches. Extern funcs are skipped
 * (they are resolved via import binding, not overload).
 *
 * Asm/Perf: O(num_funcs) — linear scan with name compare. Cold path — called
 * in pipeline_typeck_pick_overload_func_index_c (glue.c:13228) and
 * pipeline_typeck_resolve_call_func_index_c (glue.c:13271).
 *
 * PLATFORM: SHARED — overload count is platform-independent.
 *
 * wave1089 G.7: migrated from glue.c:13063 (body 14 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:12367 (before all callsites L13228+) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_asm_module_func_is_extern_at /
 * pipeline_module_func_name_equal_at (both extern).
 */
static int32_t pipeline_module_func_overload_count_c(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t c;
  if (!m || name_len <= 0 || !name)
    return 0;
  c = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0)
      continue;
    if (pipeline_module_func_name_equal_at(m, i, name, name_len))
      c++;
  }
  return c;
}

/**
 * Predicate: can a call arg (arg_ref) be assigned to a param (param_ref)?
 *
 * Why: typeck.x::type_assignable_to subset for overload scoring — exact match
 * wins, then implicit integer widen (NAMED i8/i16/u16 + first-class), then
 * f32→f64 float widen, then slice-element equivalence, then array→ptr decay.
 * Without this predicate, pipeline_typeck_overload_match_score_c could not
 * reject mismatched candidates and would over-score. Centralizing here keeps
 * the assignability gate with the overload scoring authority.
 *
 * Invariant: returns 0 for NULL arena, invalid arg_ref/param_ref, or no
 * assignable path; returns 1 iff arg can be assigned to param via the
 * supported implicit conversions. EXPR_AS uses its target type_ref as arg_ty
 * when present. Bare EXPR_LIT falls back to literal-form matching against
 * param_kind (i32/i64/u32/usize/u8 with iv range gate). Bare ARRAY_LIT
 * matches TYPE_SLICE/TYPE_ARRAY formals (post-stamp elem coerce in
 * check_call_slice_region).
 *
 * Asm/Perf: O(1) — kind/type reads + equality checks + widen matrix calls.
 * Cold path — called per (arg, param) pair in
 * pipeline_typeck_overload_match_score_c (glue.c:13113 via wrapper).
 *
 * PLATFORM: SHARED — overload assignability is platform-independent.
 *
 * wave1090 G.7: migrated from glue.c:13019 (body 65 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:13015 (before all callsites) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_expr_kind_ord_at / pipeline_typeck_expr_type_ref_c /
 * pipeline_expr_as_target_type_ref_at / pipeline_type_kind_ord_at /
 * pipeline_typeck_type_refs_equal_c / pipeline_typeck_integer_widen_ok_refs_c
 * (static, fwd decl at glue.c:10381) / pipeline_typeck_float_widen_ok_c
 * (static, fwd decl at glue.c:10354) / pipeline_type_elem_ref_at /
 * pipeline_expr_int_val_at (all extern).
 */
static int32_t pipeline_typeck_call_arg_assignable_c(struct ast_ASTArena *arena, int32_t arg_ref, int32_t param_ref) {
  int32_t arg_ty;
  int32_t arg_kind;
  int32_t param_kind;
  int32_t arg_kind_ord;
  int32_t as_tgt;
  if (!arena || arg_ref <= 0 || param_ref <= 0)
    return 0;
  arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
  arg_ty = pipeline_typeck_expr_type_ref_c(arena, arg_ref);
  if (arg_kind == (int32_t)ast_ExprKind_EXPR_AS) {
    as_tgt = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
    if (!ast_ref_is_null(as_tgt))
      arg_ty = as_tgt;
  }
  param_kind = pipeline_type_kind_ord_at(arena, param_ref);
  if (arg_ty > 0) {
    if (pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_ref))
      return 1;
    arg_kind_ord = pipeline_type_kind_ord_at(arena, arg_ty);
    /* wave313: refs path so NAMED i8/i16/u16 call-arg widen scores green. */
    if (pipeline_typeck_integer_widen_ok_refs_c(arena, param_ref, arg_ty))
      return 1;
    /* wave314: f32→f64 call-arg widen. */
    if (pipeline_typeck_float_widen_ok_c(param_kind, arg_kind_ord))
      return 1;
    /** M-3: slice element same → overload match (region checked after CALL). */
    if (param_kind == (int32_t)ast_TypeKind_TYPE_SLICE && arg_kind_ord == (int32_t)ast_TypeKind_TYPE_SLICE) {
      int32_t pe = pipeline_type_elem_ref_at(arena, param_ref);
      int32_t ae = pipeline_type_elem_ref_at(arena, arg_ty);
      if (pe > 0 && ae > 0 && pipeline_typeck_type_refs_equal_c(arena, pe, ae))
        return 1;
    }
    /** array/T → *T decay: `buf: u8[N]` calls `to_buf(buf: *u8, ...)`. */
    if (param_kind == (int32_t)ast_TypeKind_TYPE_PTR && arg_kind_ord == (int32_t)ast_TypeKind_TYPE_ARRAY) {
      int32_t pe = pipeline_type_elem_ref_at(arena, param_ref);
      int32_t ae = pipeline_type_elem_ref_at(arena, arg_ty);
      if (pe > 0 && ae > 0 && pipeline_typeck_type_refs_equal_c(arena, pe, ae))
        return 1;
    }
    return 0;
  }
  /** resolved_type unset → literal-form match (common before CALL dispatch). */
  if (arg_kind == (int32_t)ast_ExprKind_EXPR_LIT) {
    int32_t iv = pipeline_expr_int_val_at(arena, arg_ref);
    if (param_kind == (int32_t)ast_TypeKind_TYPE_I32 || param_kind == (int32_t)ast_TypeKind_TYPE_I64)
      return 1;
    if (param_kind == (int32_t)ast_TypeKind_TYPE_U32 && iv >= 0)
      return 1;
    if (param_kind == (int32_t)ast_TypeKind_TYPE_USIZE && iv >= 0)
      return 1;
    if (param_kind == (int32_t)ast_TypeKind_TYPE_U8 && iv >= 0 && iv <= 255)
      return 1;
  }
  /*
   * wave332: bare ARRAY_LIT vs TYPE_SLICE / TYPE_ARRAY formal — resolve runs before
   * post-resolve stamp in check_call_slice_region; accept for overload score (elem
   * coerce later via array_vector_lit). PLATFORM: SHARED.
   */
  if (arg_kind == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT &&
      (param_kind == (int32_t)ast_TypeKind_TYPE_SLICE ||
       param_kind == (int32_t)ast_TypeKind_TYPE_ARRAY))
    return 1;
  return 0;
}

/**
 * Score one overload candidate against a CALL's args.
 *
 * Why: typeck.x::find_func_return_type_in_module_by_name_overload scores each
 * same-named candidate by per-arg assignability — exact type match gives
 * +1000, implicit-widen assignable gives +1, unassignable rejects (-1). This
 * is the inner loop of pipeline_typeck_pick_overload_func_index_c. Expected
 * return bonus is NOT folded here (kept as secondary key in pick) to avoid
 * vec_u16 BLD001 false-win where outer expected i32 made get_Vec_i32 beat
 * exact Vec_u16.
 *
 * Invariant: returns -1 for NULL m/a, invalid func_ix/call_expr_ref, arg count
 * mismatch, or any unassignable arg; otherwise returns the per-arg score sum.
 *
 * Asm/Perf: O(num_args) — per-arg assignability check. Cold path — called per
 * candidate in pipeline_typeck_pick_overload_func_index_c (glue.c:13177).
 *
 * PLATFORM: SHARED — overload scoring is platform-independent.
 *
 * wave1091 G.7: migrated from glue.c:13095 (body 31 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:13015 (before all callsites) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_expr_call_num_args_at / pipeline_module_func_num_params_at /
 * pipeline_expr_call_arg_ref / pipeline_module_func_param_type_ref_at /
 * pipeline_typeck_type_refs_equal_c / pipeline_typeck_expr_type_ref_c /
 * pipeline_expr_kind_ord_at / pipeline_expr_as_target_type_ref_at /
 * pipeline_typeck_call_arg_assignable_c (same file, def above) (all extern
 * except call_arg_assignable_c).
 */
static int32_t pipeline_typeck_overload_match_score_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                      int32_t call_expr_ref) {
  int32_t num_args;
  int32_t np;
  int32_t i;
  int32_t score;
  int32_t arg_ref;
  int32_t param_ref;
  if (!m || !a || func_ix < 0 || call_expr_ref <= 0)
    return -1;
  num_args = pipeline_expr_call_num_args_at(a, call_expr_ref);
  np = pipeline_module_func_num_params_at(m, func_ix);
  if (num_args != np)
    return -1;
  score = 0;
  for (i = 0; i < num_args; i++) {
    arg_ref = pipeline_expr_call_arg_ref(a, call_expr_ref, i);
    param_ref = pipeline_module_func_param_type_ref_at(m, func_ix, i);
    if (!pipeline_typeck_call_arg_assignable_c(a, arg_ref, param_ref))
      return -1;
    if (pipeline_typeck_type_refs_equal_c(
            a, pipeline_typeck_expr_type_ref_c(a, arg_ref),
            param_ref) ||
        (pipeline_expr_kind_ord_at(a, arg_ref) == (int32_t)ast_ExprKind_EXPR_AS &&
         pipeline_typeck_type_refs_equal_c(a, pipeline_expr_as_target_type_ref_at(a, arg_ref), param_ref)))
      score += 1000;
    else
      score += 1;
  }
  return score;
}

/**
 * Predicate: does func_ix's return type match the expected-return peek?
 *
 * Why: typeck_overload_expected_ret_peek captures the let/assign context's
 * expected return type (e.g. `let v: Vec_u8 = new()` expects Vec_u8). This
 * predicate is the secondary key in pick_overload — when arg scores tie, the
 * candidate whose return matches the expected wins. Kept separate from
 * match_score to preserve vec_u16 BLD001 fix (see match_score docblock).
 *
 * Invariant: returns 0 for NULL m/a, invalid func_ix, no expected-ret peek,
 * or no return type match; returns 1 iff func return type matches peek.
 *
 * Asm/Perf: O(1) — one peek + one type_refs_equal. Cold path — called per
 * candidate in pipeline_typeck_pick_overload_func_index_c (glue.c:13180).
 *
 * PLATFORM: SHARED — expected-return match is platform-independent.
 *
 * wave1092 G.7: migrated from glue.c:13128 (body 15 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:13015 (before all callsites) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * typeck_overload_expected_ret_peek (extern, declared in-function-body) /
 * pipeline_module_func_return_type_at / pipeline_typeck_type_refs_equal_c
 * (both extern).
 */
static int32_t pipeline_typeck_overload_expect_match_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                       int32_t func_ix) {
  int32_t expect_ty;
  int32_t rtr;
  extern int32_t typeck_overload_expected_ret_peek(void);
  if (!m || !a || func_ix < 0)
    return 0;
  expect_ty = typeck_overload_expected_ret_peek();
  if (expect_ty <= 0)
    return 0;
  rtr = pipeline_module_func_return_type_at(m, func_ix);
  if (rtr > 0 && pipeline_typeck_type_refs_equal_c(a, rtr, expect_ty) != 0)
    return 1;
  return 0;
}

/**
 * Pick the unique best overload for a CALL by arg score + expected-return tiebreak.
 *
 * Why: typeck.x::find_func_return_type_in_module_by_name_overload dispatches
 * a CALL with multiple same-named candidates by scoring each via
 * overload_match_score and breaking ties via overload_expect_match. Without
 * this dispatcher, every CALL site would inline the scoring loop. Ambiguity
 * (multiple candidates tie on both score and expect_match) returns -1 so the
 * caller falls back to the resolved-func-index cache or name-only lookup.
 *
 * Invariant: returns -1 for NULL m/a, invalid call_expr_ref, callee not VAR,
 * callee name not overloaded (count <= 1), no candidate matches, or
 * ambiguity; otherwise returns the winning funcs[] index.
 *
 * Asm/Perf: O(num_funcs × num_args) — iterates funcs, scores matching ones.
 * Cold path — called in pipeline_typeck_resolve_call_func_index_c
 * (glue.c:13210) and pipeline_typeck_pick_overload_func_index_for_call_c
 * wrapper (glue.c:13233+).
 *
 * PLATFORM: SHARED — overload dispatch is platform-independent.
 *
 * wave1093 G.7: migrated from glue.c:13147 (body 48 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:13015 (before all callsites) <
 * method_call.c #include at L14053 < def EOF. Dependencies:
 * pipeline_expr_call_callee_ref_at / pipeline_arena_expr_ptr /
 * pipeline_module_func_overload_count_c (same file, def above) /
 * pipeline_asm_module_func_is_extern_at / pipeline_module_func_name_equal_at
 * / pipeline_typeck_overload_match_score_c (same file, def above) /
 * pipeline_typeck_overload_expect_match_c (same file, def above) (mix).
 */
static int32_t pipeline_typeck_pick_overload_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          int32_t call_expr_ref) {
  int32_t callee_ref;
  struct ast_Expr *callee_ex;
  int32_t i;
  int32_t best_ix;
  int32_t best_score;
  int32_t best_expect;
  int32_t n_at_best;
  int32_t sc;
  int32_t em;
  if (!m || !a || call_expr_ref <= 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  if (callee_ref <= 0)
    return -1;
  callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
  if (!callee_ex || callee_ex->kind != ast_ExprKind_EXPR_VAR || callee_ex->var_name_len <= 0)
    return -1;
  if (pipeline_module_func_overload_count_c(m, callee_ex->var_name, callee_ex->var_name_len) <= 1)
    return -1;
  best_ix = -1;
  best_score = -1;
  best_expect = -1;
  n_at_best = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0)
      continue;
    if (!pipeline_module_func_name_equal_at(m, i, callee_ex->var_name, callee_ex->var_name_len))
      continue;
    sc = pipeline_typeck_overload_match_score_c(m, a, i, call_expr_ref);
    if (sc < 0)
      continue;
    em = pipeline_typeck_overload_expect_match_c(m, a, i);
    if (sc > best_score || (sc == best_score && em > best_expect)) {
      best_ix = i;
      best_score = sc;
      best_expect = em;
      n_at_best = 1;
    } else if (sc == best_score && em == best_expect) {
      n_at_best++;
    }
  }
  /* Ambiguous only when arg score *and* expect_match tie across multiple overloads. */
  if (best_ix < 0 || n_at_best > 1)
    return -1;
  return best_ix;
}

/**
 * Resolve a CALL's target func index (overload-aware) for typeck + asm emit.
 *
 * Why: typeck.x::resolve_call_func_index is the single CALL→func_ix resolver
 * used by both typeck check (struct stack-escape scan) and asm emit (CALL
 * target mangle + param SSE class). When callee is overloaded (count > 1),
 * delegates to pick_overload_func_index_c and stamps the resolved index back
 * via pipeline_expr_apply_call_resolve. Otherwise falls back to the cached
 * resolved_func_index, then to a name-only scan. Centralizing here keeps the
 * CALL resolution authority with the overload dispatcher.
 *
 * Invariant: returns -1 for NULL m/a, invalid call_expr_ref, callee not VAR,
 * or no matching func; otherwise returns the funcs[] index. Stamps
 * apply_call_resolve(-1, picked) when overload dispatch succeeds.
 *
 * Asm/Perf: O(num_funcs × num_args) worst case (overload dispatch); O(1) when
 * cached resolved_func_index hits. Cold path — called in
 * pipeline_typeck_check_call_struct_stack_escape_c (glue.c:12695),
 * glue_asm_resolve_call_target_module_c (glue.c:13360), and CALL emit
 * (glue.c:13743), plus the for_emit wrapper.
 *
 * PLATFORM: SHARED — CALL func index resolution is platform-independent.
 *
 * wave1094 G.7: migrated from glue.c:13196 (body 35 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:12315 (existing, before callsite
 * L12695) and glue.c:13015 (before wrapper L13233+) < method_call.c #include
 * at L14053 < def EOF. Dependencies: pipeline_expr_call_callee_ref_at /
 * pipeline_arena_expr_ptr / pipeline_module_func_overload_count_c (same file,
 * def above) / pipeline_typeck_pick_overload_func_index_c (same file, def
 * above) / pipeline_expr_apply_call_resolve /
 * pipeline_expr_call_resolved_func_index_at /
 * pipeline_module_func_name_equal_at (all extern).
 */
static int32_t pipeline_typeck_resolve_call_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                         int32_t call_expr_ref) {
  int32_t fx;
  int32_t picked;
  int32_t callee_ref;
  struct ast_Expr *callee_ex;
  int32_t i;
  if (!m || !a || call_expr_ref <= 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  if (callee_ref > 0) {
    callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
    if (callee_ex && callee_ex->kind == ast_ExprKind_EXPR_VAR && callee_ex->var_name_len > 0 &&
        pipeline_module_func_overload_count_c(m, callee_ex->var_name, callee_ex->var_name_len) > 1) {
      picked = pipeline_typeck_pick_overload_func_index_c(m, a, call_expr_ref);
      if (picked >= 0) {
        pipeline_expr_apply_call_resolve(a, call_expr_ref, -1, picked);
        return picked;
      }
    }
  }
  fx = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
  if (fx >= 0)
    return fx;
  if (callee_ref <= 0)
    return -1;
  callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
  if (!callee_ex || callee_ex->kind != ast_ExprKind_EXPR_VAR || callee_ex->var_name_len <= 0)
    return -1;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, callee_ex->var_name, callee_ex->var_name_len))
      return i;
  }
  return -1;
}

/* ===========================================================================
 * wave1095-1099 G.7: generic call inference domain (5 leaves) migrated from
 * pipeline_glue.c. These functions form the generic call type inference and
 * validation sub-domain of method call: type-param inference from value args,
 * trait bound checking, type-arg count validation, and return-type mono fixup.
 * Static (non-extern): same-TU — method_call.c #include at glue.c:L13803 <
 * def EOF < all remaining callsites in glue.c (L14181 bootstrap_fixup,
 * L14743 check_call_generic_type_args, L14757 glue_generic_call_fixup).
 * pipeline_typeck_named_is_module_type_c has static fwd decl at L348 above
 * (needed by calls at L476-L872 in this file before the EOF definition).
 * PLATFORM: SHARED.
 * ========================================================================== */

/**
 * Check whether a TYPE_NAMED name refers to a module-defined struct or type
 * alias (concrete type), as opposed to a free type parameter.
 *
 * Why: Used by expected-return inference + generic call fixup to fail-closed
 * when a return type is unconstrained (a concrete module type needs no mono
 * fixup; a bare type param T does). Scans module struct_layouts and type
 * aliases for a name match via glue_slice_equal_c byte comparison.
 *
 * Invariant: Returns 1 if the name matches a module struct or alias; 0
 * otherwise (including null/empty inputs).
 *
 * Asm/Perf: O(N_structs + N_aliases) linear scan. Cold path — called during
 * typeck of generic calls, not in hot codegen.
 *
 * PLATFORM: SHARED — typeck helper, platform-independent.
 *
 * wave1095 G.7: migrated from glue.c:14246 (body 40 LOC). Static fwd decl at
 * method_call.c:348 (before callsites L476-L872). Deps: pipeline_module_num_
 * struct_layouts_at / pipeline_module_struct_layout_name_len / pipeline_module_
 * struct_layout_name_into / glue_slice_equal_c (same file, def above) /
 * pipeline_module_num_type_aliases_at / pipeline_module_type_alias_name_len /
 * pipeline_module_type_alias_name_byte_at (all extern).
 */
static int32_t pipeline_typeck_named_is_module_type_c(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                     const uint8_t *nm, int32_t nlen) {
  int32_t si;
  int32_t nsl;
  int32_t snlen;
  uint8_t snm[128];
  int32_t n_alias;
  int32_t ai;
  (void)arena;
  if (!mod || !nm || nlen <= 0)
    return 0;
  nsl = pipeline_module_num_struct_layouts_at(mod);
  for (si = 0; si < nsl; si = si + 1) {
    snlen = pipeline_module_struct_layout_name_len(mod, si);
    if (snlen != nlen || snlen <= 0)
      continue;
    pipeline_module_struct_layout_name_into(mod, si, snm);
    if (glue_slice_equal_c(nm, nlen, snm, snlen))
      return 1;
  }
  n_alias = pipeline_module_num_type_aliases_at(mod);
  for (ai = 0; ai < n_alias; ai = ai + 1) {
    snlen = pipeline_module_type_alias_name_len(mod, ai);
    if (snlen != nlen || snlen <= 0)
      continue;
    {
      int32_t bi;
      int32_t same = 1;
      for (bi = 0; bi < snlen; bi = bi + 1) {
        if (pipeline_module_type_alias_name_byte_at(mod, ai, bi) != nm[bi]) {
          same = 0;
          break;
        }
      }
      if (same)
        return 1;
    }
  }
  return 0;
}

/**
 * Stamp monomorphized resolved_type_ref on a generic CALL when the signature
 * return is a compound tree with free type-params (*T, []T, T[N], nested) or
 * a bare type param matched to a value formal / turbofish type-arg.
 *
 * Why: typeck_check_expr_call_resolve stamps the raw signature ret (*T);
 * let/return assign then reports "expected *i32, found *T". This fixup opens
 * the early gate for free-param trees and, for non-NAMED free rets, reuses
 * glue_typeck_build_value_formal_mono_map_c + glue_typeck_subst_type_ref_c
 * (already used for module NAMED free trees / method UFCS). No second path.
 *
 * Invariant: Returns 0 always (stamps resolved_type_ref in-place or leaves
 * it unchanged when fixup cannot complete). Idempotent — skips when the
 * stamped tree has no free params left.
 *
 * Asm/Perf: O(N_formals * N_args) worst case for formal scan + subst. Cold
 * path — called during typeck post-processing of EXPR_CALL.
 *
 * PLATFORM: SHARED — G.7 single authority with parser type_arg storage.
 *
 * wave1096 G.7: migrated from glue.c:13822 (body 319 LOC). Static (non-extern):
 * same-TU — method_call.c #include at glue.c:L13803 < def EOF < callsites
 * glue.c:L14181 (bootstrap_expr_fixup) + L14757 (check_expr_call). Deps:
 * pipeline_expr_resolved_type_ref / glue_typeck_type_tree_has_free_param_c
 * (same file L385/L633) / pipeline_expr_call_callee_ref_at / pipeline_expr_
 * kind_ord_at / pipeline_expr_var_name_len / pipeline_expr_var_name_into /
 * pipeline_expr_field_access_name_len / pipeline_expr_field_access_name_into /
 * pipeline_expr_call_resolved_dep_index_at / pipeline_expr_call_resolved_
 * func_index_at / pipeline_dep_ctx_module_at / pipeline_dep_ctx_arena_at /
 * pipeline_dep_ctx_ndep / pipeline_module_func_name_equal_at /
 * pipeline_module_func_return_type_at / pipeline_type_kind_ord_at /
 * glue_typeck_build_value_formal_mono_map_c (same file L545) /
 * glue_typeck_subst_type_ref_c (same file L709) / pipeline_type_named_name_
 * into / pipeline_module_func_num_params_at / pipeline_module_func_param_
 * type_ref_at / glue_slice_equal_c (same file L25) / pipeline_expr_call_arg_
 * ref / pipeline_expr_set_resolved_type_ref / glue_generic_call_subst_ret_
 * from_formal_map_c (same file L842) / pipeline_expr_call_type_arg_ref_at
 * (extern, decl in-body) / pipeline_module_func_num_generic_params_at (extern,
 * decl in-body) / xlang_generic_func_type_param_index_c (extern, decl in-body)
 * / pipeline_expr_call_num_type_args_at (extern, decl in-body) /
 * pipeline_typeck_named_is_module_type_c (same file, def above via fwd decl
 * L348) (all extern unless noted).
 */
static int32_t glue_generic_call_fixup_resolved_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx,
                                                       int32_t expected_ret) {
  int32_t ord_var = 3;
  int32_t ord_field = 44;
  int32_t ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;
  int32_t callee_ref;
  int32_t callee_eff;
  int32_t callee_kind;
  int32_t func_idx;
  int32_t ret_ty;
  int32_t param_ty;
  uint8_t ret_nm[128];
  uint8_t param_nm[128];
  int32_t ret_nlen;
  int32_t param_nlen;
  int32_t arg_i;
  int32_t arg_ty;
  int32_t num_params;
  int32_t pi;
  uint8_t cnm[128];
  int32_t cnml;
  int32_t j;
  int32_t dep_ix;
  struct ast_Module *search_mod;
  struct ast_ASTArena *search_arena;

  if (!module || !arena || call_expr_ref <= 0)
    return 0;
  /*
   * Already fully concrete (no free type-param in tree) — nothing to fix.
   * wave688: free *T is TYPE_PTR (non-NAMED) but still needs mono stamp;
   * only skip when the stamped tree has no free params left.
   */
  {
    int32_t cur = pipeline_expr_resolved_type_ref(arena, call_expr_ref);
    if (cur > 0 && glue_typeck_type_tree_has_free_param_c(module, arena, cur, 0) == 0)
      return 0;
  }
  callee_ref = pipeline_expr_call_callee_ref_at(arena, call_expr_ref);
  callee_eff = callee_ref;
  callee_kind = pipeline_expr_kind_ord_at(arena, callee_eff);
  cnml = 0;
  search_mod = module;
  search_arena = arena;
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  func_idx = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
  if (callee_kind == ord_var) {
    cnml = pipeline_expr_var_name_len(arena, callee_eff);
    if (cnml <= 0 || cnml > 127)
      return 0;
    pipeline_expr_var_name_into(arena, callee_eff, cnm);
  } else if (callee_kind == ord_field) {
    /* foo.id: field name is the function; prefer call_resolved dep when set. */
    cnml = pipeline_expr_field_access_name_len(arena, callee_eff);
    if (cnml <= 0 || cnml > 127)
      return 0;
    pipeline_expr_field_access_name_into(arena, callee_eff, cnm);
  } else {
    return 0;
  }
  if (dep_ix >= 0 && ctx && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, dep_ix);
    struct ast_ASTArena *da = pipeline_dep_ctx_arena_at(ctx, dep_ix);
    if (dm) {
      search_mod = dm;
      if (da)
        search_arena = da;
    }
  }
  if (func_idx < 0) {
    j = 0;
    while (j < (int32_t)search_mod->num_funcs) {
      if (pipeline_module_func_name_equal_at(search_mod, j, cnm, cnml) != 0) {
        func_idx = j;
        break;
      }
      j = j + 1;
    }
  }
  /* Local miss: scan deps (bare id via whole/select or binding mis-resolve). */
  if (func_idx < 0 && ctx) {
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t di;
    for (di = 0; di < nd && func_idx < 0; di++) {
      struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
      if (!dm)
        continue;
      j = 0;
      while (j < (int32_t)dm->num_funcs) {
        if (pipeline_module_func_name_equal_at(dm, j, cnm, cnml) != 0) {
          func_idx = j;
          search_mod = dm;
          {
            struct ast_ASTArena *da = pipeline_dep_ctx_arena_at(ctx, di);
            if (da)
              search_arena = da;
          }
          break;
        }
        j = j + 1;
      }
    }
  }
  if (func_idx < 0)
    return 0;
  ret_ty = pipeline_module_func_return_type_at(search_mod, func_idx);
  /* Return type lives in search_arena; match formals by kind/name. */
  if (ret_ty <= 0)
    return 0;
  /*
   * wave688: non-NAMED return with free type-params (`*T`, `[]T`, `T[N]`).
   * Build formal->arg mono map (identity + pattern unify for compound formals)
   * then subst the whole ret tree. Fail-closed if map incomplete or mono still free.
   */
  if (pipeline_type_kind_ord_at(search_arena, ret_ty) != ord_named) {
    int32_t n_map_c;
    uint8_t map_names_c[W486_MONO_MAX_MAP][128];
    int32_t map_lens_c[W486_MONO_MAX_MAP];
    int32_t map_conc_c[W486_MONO_MAX_MAP];
    int32_t mono_ret_c;
    if (glue_typeck_type_tree_has_free_param_c(search_mod, search_arena, ret_ty, 0) == 0)
      return 0;
    n_map_c = glue_typeck_build_value_formal_mono_map_c(search_mod, search_arena, arena, call_expr_ref, func_idx,
                                                       map_names_c, map_lens_c, map_conc_c, W486_MONO_MAX_MAP);
    if (n_map_c <= 0)
      return 0;
    mono_ret_c = glue_typeck_subst_type_ref_c(search_mod, search_arena, arena, ret_ty, map_names_c, map_lens_c,
                                             map_conc_c, n_map_c, 0);
    if (mono_ret_c <= 0)
      return 0;
    if (glue_typeck_type_tree_has_free_param_c(search_mod, arena, mono_ret_c, 0) != 0)
      return 0;
    pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, mono_ret_c);
    return 0;
  }
  ret_nlen = pipeline_type_named_name_into(search_arena, ret_ty, ret_nm);
  if (ret_nlen <= 0)
    return 0;
  num_params = pipeline_module_func_num_params_at(search_mod, func_idx);
  /*
   * wave451: any formal TYPE_NAMED whose name equals the return type name
   * supplies the mono type via the corresponding value argument. First match
   * wins (wave448 unifies same-name formals, so any index is equivalent).
   */
  for (pi = 0; pi < num_params; pi = pi + 1) {
    param_ty = pipeline_module_func_param_type_ref_at(search_mod, func_idx, pi);
    if (param_ty <= 0 || pipeline_type_kind_ord_at(search_arena, param_ty) != ord_named)
      continue;
    param_nlen = pipeline_type_named_name_into(search_arena, param_ty, param_nm);
    if (param_nlen <= 0 || !glue_slice_equal_c(ret_nm, ret_nlen, param_nm, param_nlen))
      continue;
    arg_i = pipeline_expr_call_arg_ref(arena, call_expr_ref, pi);
    if (arg_i <= 0)
      continue;
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_i);
    if (arg_ty <= 0)
      continue;
    pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, arg_ty);
    return 0;
  }
  /*
   * wave494: generic method_call UFCS is handled in
   * pipeline_typeck_check_expr_method_call_c (weak + strict_minimal strong)
   * via pipeline_typeck_method_call_generic_ufcs_c — see that authority.
   * This CALL-fixup path only sees EXPR_CALL with ord_field/ord_var callee;
   * EXPR_METHOD_CALL (kind 49) never reaches here.
   */
  /*
   * wave486/wave487: stamp mono ret from value-formal map.
   * - module ret with free type-arg tree (`nest: Wrap<Wrap<T>>`) — subst tree
   * - free type-param ret with pattern formals (`unwrap(w: Wrap<T>): T`) —
   *   bind T from arg type-args (identity formals already handled above)
   */
  {
    int32_t mono_ret =
        glue_generic_call_subst_ret_from_formal_map_c(search_mod, search_arena, arena, call_expr_ref, func_idx,
                                                     ret_ty);
    if (mono_ret > 0) {
      pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, mono_ret);
      return 0;
    }
  }
  /*
   * wave452: ret TYPE_NAMED is a type parameter not present on any value
   * formal (e.g. as_t<T>(i32):T / mk_default<T>():T). Map via turbofish
   * type_arg type_refs stored by parser (sidecar). Formal path above already
   * handled identity-style ret==param name.
   *
   * Type-param vs concrete named ret: if ret name is a module struct/alias,
   * leave it (already mono). Else treat as type param.
   *
   * wave455: prefer declaration-order type-param names from source scan
   * (xlang_generic_func_type_param_index_c) so multi-param generics with
   * phantom type params (`mk2<T,U>():T`) map ret->type_arg[i] correctly.
   * Fallback: first-appearance formals + ret (wave452), with n_gp==1 -> slot 0.
   * PLATFORM: SHARED — G.7 single authority with parser type_arg storage.
   */
  {
    extern int32_t pipeline_expr_call_type_arg_ref_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
    extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index);
    extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref);
    extern int32_t xlang_generic_func_type_param_index_c(const uint8_t *fn_name, int32_t fn_name_len,
                                                          const uint8_t *tp_name, int32_t tp_name_len);
    int32_t n_gp;
    int32_t n_ta;
    int32_t ta_ty;
    int32_t ret_is_module_type;
    int32_t gnames_n;
    uint8_t gnames[8][128];
    int32_t glens[8];
    int32_t gidx;
    int32_t found_gi;
    int32_t is_mod;

    n_gp = pipeline_module_func_num_generic_params_at(search_mod, func_idx);
    n_ta = pipeline_expr_call_num_type_args_at(arena, call_expr_ref);
    /* Is ret name a known module type (struct)? */
    ret_is_module_type =
        pipeline_typeck_named_is_module_type_c(search_mod, search_arena, ret_nm, ret_nlen);
    if (ret_is_module_type)
      return 0;
    /*
     * wave453: bare call (n_ta==0) with ambient expected return — stamp call
     * resolved type so assignment/return match and codegen mono can fall back
     * to resolved_type_ref (codegen_call_ret_type_param_concrete_at).
     * Requires ret TYPE_NAMED is a type param (already checked above).
     * wave454: only stamp when expected is a module TYPE_NAMED (same gate as
     * try_infer); refuse primitive ambient that would lie about T.
     */
    if (n_gp > 0 && n_ta == 0 && expected_ret > 0 &&
        pipeline_type_kind_ord_at(arena, expected_ret) == ord_named) {
      uint8_t exp_nm[128];
      int32_t exp_nlen;
      memset(exp_nm, 0, sizeof(exp_nm));
      exp_nlen = pipeline_type_named_name_into(arena, expected_ret, exp_nm);
      if (exp_nlen > 0 &&
          pipeline_typeck_named_is_module_type_c(search_mod, search_arena, exp_nm, exp_nlen) != 0) {
        pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, expected_ret);
        return 0;
      }
    }
    if (n_gp <= 0 || n_ta <= 0 || n_ta != n_gp)
      return 0;

    /*
     * wave455 primary: declaration-order index from bound-scan registry.
     * Callee name is cnm/cnml (resolved above). Ret name is the type param.
     */
    found_gi = xlang_generic_func_type_param_index_c(cnm, cnml, ret_nm, ret_nlen);
    if (found_gi >= 0 && found_gi < n_ta) {
      ta_ty = pipeline_expr_call_type_arg_ref_at(arena, call_expr_ref, found_gi);
      if (ta_ty > 0) {
        pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, ta_ty);
        return 0;
      }
    }

    /* Fallback wave452: collect type-param names from formals + ret. */
    gnames_n = 0;
    for (pi = 0; pi < num_params && gnames_n < 8; pi = pi + 1) {
      param_ty = pipeline_module_func_param_type_ref_at(search_mod, func_idx, pi);
      if (param_ty <= 0 || pipeline_type_kind_ord_at(search_arena, param_ty) != ord_named)
        continue;
      param_nlen = pipeline_type_named_name_into(search_arena, param_ty, param_nm);
      if (param_nlen <= 0)
        continue;
      is_mod = pipeline_typeck_named_is_module_type_c(search_mod, search_arena, param_nm, param_nlen);
      if (is_mod)
        continue;
      found_gi = -1;
      for (gidx = 0; gidx < gnames_n; gidx = gidx + 1) {
        if (glue_slice_equal_c(param_nm, param_nlen, gnames[gidx], glens[gidx])) {
          found_gi = gidx;
          break;
        }
      }
      if (found_gi >= 0)
        continue;
      memset(gnames[gnames_n], 0, 64);
      {
        int32_t ci;
        for (ci = 0; ci < param_nlen && ci < 63; ci = ci + 1)
          gnames[gnames_n][ci] = param_nm[ci];
      }
      glens[gnames_n] = param_nlen;
      gnames_n = gnames_n + 1;
    }
    found_gi = -1;
    for (gidx = 0; gidx < gnames_n; gidx = gidx + 1) {
      if (glue_slice_equal_c(ret_nm, ret_nlen, gnames[gidx], glens[gidx])) {
        found_gi = gidx;
        break;
      }
    }
    if (found_gi < 0 && gnames_n < 8) {
      memset(gnames[gnames_n], 0, 64);
      {
        int32_t ci;
        for (ci = 0; ci < ret_nlen && ci < 63; ci = ci + 1)
          gnames[gnames_n][ci] = ret_nm[ci];
      }
      glens[gnames_n] = ret_nlen;
      found_gi = gnames_n;
      gnames_n = gnames_n + 1;
    }
    if (found_gi < 0)
      return 0;
    /* n_gp==1 always uses slot 0 when ret is type param. */
    if (n_gp == 1)
      found_gi = 0;
    else if (n_gp > 1 && gnames_n != n_gp)
      return 0; /* incomplete formal recovery; scan path above should have hit */
    ta_ty = pipeline_expr_call_type_arg_ref_at(arena, call_expr_ref, found_gi);
    if (ta_ty <= 0)
      return 0;
    pipeline_expr_set_resolved_type_ref(arena, call_expr_ref, ta_ty);
    return 0;
  }
}

/**
 * Try to infer omitted turbofish type args from value-argument resolved types.
 *
 * Why: product typeck historically hard-failed generic calls with
 * num_type_args == 0 via requires_type_args, even when every mono type is
 * already available from typed value args (e.g. id(a) with a: A for
 * function id<T>(x: T): T). Algorithm: (1) require nargs >= num_params and
 * every arg has resolved_type_ref > 0 or bare lit effective type; (2) unify
 * same-named TYPE_NAMED formals across value params; (3) success -> allow
 * omitted type args (return 0). Failure -> -1 so caller emits
 * requires_type_args.
 *
 * wave453/457: expected-return inference when ret is a type param covers
 * zero-arg mk_default():T and multi ret-only mk2<T,U>():T; fail-closed when
 * ret is concrete (phantom T on unit_t<T>():i32 still requires turbofish).
 *
 * Invariant: Returns 0 if inference succeeds (type args can be omitted);
 * returns -1 if inference cannot complete (caller should emit diagnostic).
 *
 * Asm/Perf: O(N_params^2) for same-name unify scan. Cold path — called
 * during typeck of EXPR_CALL with generic callee and no turbofish.
 *
 * PLATFORM: SHARED — G.7 single authority for this inference gate.
 *
 * wave1097 G.7: migrated from glue.c:14338 (body 130 LOC). Static (non-extern):
 * same-TU — method_call.c #include at glue.c:L13803 < def EOF < callsite
 * glue.c:L14664 (inside check_call_generic_type_args_c, same migration batch).
 * Deps: pipeline_module_func_num_params_at / pipeline_expr_call_num_args_at /
 * pipeline_typeck_call_arg_effective_type_c (same file L1030) /
 * pipeline_module_func_param_type_ref_at / pipeline_type_kind_ord_at /
 * pipeline_type_named_name_into / pipeline_typeck_named_is_module_type_c
 * (same file, def above via fwd decl L348) / pipeline_typeck_type_refs_equal_c
 * / pipeline_module_func_num_generic_params_at / pipeline_module_func_return_
 * type_at (all extern).
 */
static int32_t pipeline_typeck_try_infer_generic_call_from_args_c(struct ast_Module *callee_mod,
                                                                 struct ast_ASTArena *arena,
                                                                 int32_t expr_ref, int32_t func_ix,
                                                                 int32_t expected_ret) {
  int32_t np;
  int32_t nargs;
  int32_t i;
  int32_t j;
  int32_t ord_named;
  int32_t n_gp;
  int32_t ret_ty;
  uint8_t ret_nm[128];
  int32_t ret_nlen;

  if (!callee_mod || !arena || expr_ref <= 0 || func_ix < 0)
    return -1;
  np = pipeline_module_func_num_params_at(callee_mod, func_ix);
  nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
  ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;

  /* Value-arg path (wave448 + wave685 lit effective types): formals present +
   * each arg has resolved type OR bare lit effective type + same-name unify. */
  if (np > 0 && nargs >= np) {
    int32_t value_ok = 1;
    for (i = 0; i < np; i++) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      int32_t arg_ty;
      if (arg_ref <= 0) {
        value_ok = 0;
        break;
      }
      arg_ty = pipeline_typeck_call_arg_effective_type_c(arena, arg_ref);
      if (arg_ty <= 0) {
        value_ok = 0;
        break;
      }
    }
    if (value_ok) {
      /* Unify same-named TYPE_NAMED formals across value params. */
      for (i = 0; i < np; i++) {
        int32_t pi_ty = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
        uint8_t pi_nm[128];
        int32_t pi_nlen;
        int32_t ai_ty;
        if (pi_ty <= 0 || pipeline_type_kind_ord_at(arena, pi_ty) != ord_named)
          continue;
        /* Only free type-params participate in same-name unify (not struct Wrap). */
        {
          memset(pi_nm, 0, sizeof(pi_nm));
          pi_nlen = pipeline_type_named_name_into(arena, pi_ty, pi_nm);
          if (pi_nlen <= 0)
            continue;
          if (pipeline_typeck_named_is_module_type_c(callee_mod, arena, pi_nm, pi_nlen) != 0)
            continue;
        }
        ai_ty = pipeline_typeck_call_arg_effective_type_c(
            arena, pipeline_expr_call_arg_ref(arena, expr_ref, i));
        if (ai_ty <= 0)
          return -1;
        for (j = i + 1; j < np; j++) {
          int32_t pj_ty = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, j);
          uint8_t pj_nm[128];
          int32_t pj_nlen;
          int32_t aj_ty;
          int32_t k;
          int32_t same_name;
          if (pj_ty <= 0 || pipeline_type_kind_ord_at(arena, pj_ty) != ord_named)
            continue;
          memset(pj_nm, 0, sizeof(pj_nm));
          pj_nlen = pipeline_type_named_name_into(arena, pj_ty, pj_nm);
          if (pj_nlen != pi_nlen)
            continue;
          same_name = 1;
          for (k = 0; k < pi_nlen; k++) {
            if (pi_nm[k] != pj_nm[k]) {
              same_name = 0;
              break;
            }
          }
          if (!same_name)
            continue;
          aj_ty = pipeline_typeck_call_arg_effective_type_c(
              arena, pipeline_expr_call_arg_ref(arena, expr_ref, j));
          if (aj_ty <= 0 || pipeline_typeck_type_refs_equal_c(arena, ai_ty, aj_ty) == 0)
            return -1;
        }
      }
      return 0;
    }
  }

  /*
   * wave453/wave457: expected-return inference when ret is a type param.
   * Covers zero-arg `mk_default():T` and multi ret-only bare
   * (`mk2<T,U>():T` / `mk2u<T,U>():U`); fail-closed when ret is concrete
   * (phantom T on unit_t<T>():i32 still requires turbofish).
   * wave454: ambient expected must itself be a module TYPE_NAMED (struct/alias).
   * Primitive expected (i32 from `return mk_default()` / wrong field ambient)
   * must not pin T — that typeck-greened then BLD001 on host C body.
   * wave457: n_gp may be >1; only the ret type param is pinned here. Fixup
   * stamps call resolved_type_ref from expected (already multi-safe); codegen
   * mono maps ret->concrete via concrete_at prefer resolved (wave455/456).
   */
  n_gp = pipeline_module_func_num_generic_params_at(callee_mod, func_ix);
  if (n_gp < 1 || expected_ret <= 0)
    return -1;
  /* expected_ret must be a concrete module named type (not i32/bool/...). */
  if (pipeline_type_kind_ord_at(arena, expected_ret) != ord_named)
    return -1;
  {
    uint8_t exp_nm[128];
    int32_t exp_nlen;
    memset(exp_nm, 0, sizeof(exp_nm));
    exp_nlen = pipeline_type_named_name_into(arena, expected_ret, exp_nm);
    if (exp_nlen <= 0)
      return -1;
    if (pipeline_typeck_named_is_module_type_c(callee_mod, arena, exp_nm, exp_nlen) == 0)
      return -1; /* not a known module type name */
  }
  ret_ty = pipeline_module_func_return_type_at(callee_mod, func_ix);
  if (ret_ty <= 0 || pipeline_type_kind_ord_at(arena, ret_ty) != ord_named)
    return -1;
  memset(ret_nm, 0, sizeof(ret_nm));
  ret_nlen = pipeline_type_named_name_into(arena, ret_ty, ret_nm);
  if (ret_nlen <= 0)
    return -1;
  if (pipeline_typeck_named_is_module_type_c(callee_mod, arena, ret_nm, ret_nlen) != 0)
    return -1; /* ret is concrete named type, not a type param */
  return 0;
}

/**
 * After value-arg inference succeeds (num_type_args==0), check trait bounds
 * using the same authority as turbofish parse-time scan
 * (xlang_generic_bound_check_type_args_c in skip_tl).
 *
 * Why: Type-arg slots are first-appearance order of distinct TYPE_NAMED
 * formals among value params (matches declaration order for conventional
 * foo<T,U>(x:T,y:U) and collapses foo<T>(x:T,y:T) to one slot). Concrete name
 * is the TYPE_NAMED name of the corresponding value-arg type. wave453/457:
 * when a type param lives only on the return position, append a slot from
 * expected_ret so T: Trait bounds still fire on bare calls.
 *
 * Invariant: Returns 0 if bounds pass or no type params to check; returns
 * non-zero if bound check fails.
 *
 * Asm/Perf: O(N_params * N_type_params) for slot collection. Cold path —
 * called after successful inference in typeck of EXPR_CALL.
 *
 * PLATFORM: SHARED — G.7 single authority for post-infer bound check.
 *
 * wave1098 G.7: migrated from glue.c:14488 (body 124 LOC). Static (non-extern):
 * same-TU — method_call.c #include at glue.c:L13803 < def EOF < callsite
 * glue.c:L14666 (inside check_call_generic_type_args_c, same migration batch).
 * Deps: pipeline_module_func_num_params_at / pipeline_module_func_param_type_
 * ref_at / pipeline_type_kind_ord_at / pipeline_type_named_name_into /
 * pipeline_typeck_named_is_module_type_c (same file, def above via fwd decl
 * L348) / pipeline_expr_call_arg_ref / pipeline_expr_resolved_type_ref /
 * pipeline_module_func_return_type_at / xlang_generic_bound_check_type_args_c
 * (extern, decl in-body) (all extern unless noted).
 */
static int32_t pipeline_typeck_check_inferred_generic_bounds_c(struct ast_Module *callee_mod,
                                                                struct ast_ASTArena *arena,
                                                                int32_t expr_ref, int32_t func_ix,
                                                                const uint8_t *fn_name, int32_t fn_name_len,
                                                                int32_t line, int32_t col,
                                                                int32_t expected_ret) {
  /* Max type-arg slots must match XLANG_GENERIC_CALL_MAX_ARGS in skip_tl. */
  enum { W449_MAX_TARGS = 4 };
  uint8_t type_args[W449_MAX_TARGS][128];
  int32_t type_arg_lens[W449_MAX_TARGS];
  uint8_t formal_names[W449_MAX_TARGS][128];
  int32_t formal_name_lens[W449_MAX_TARGS];
  int32_t n_tp;
  int32_t np;
  int32_t i;
  int32_t ord_named;
  int32_t ret_ty;
  uint8_t ret_nm[128];
  int32_t ret_nlen;
  extern int32_t xlang_generic_bound_check_type_args_c(const uint8_t *fn_name, int32_t fn_name_len,
                                                        const uint8_t type_args[][128],
                                                        const int32_t *type_arg_lens, int32_t nargs,
                                                        int32_t line, int32_t col);

  if (!callee_mod || !arena || expr_ref <= 0 || func_ix < 0 || !fn_name || fn_name_len <= 0)
    return 0;
  np = pipeline_module_func_num_params_at(callee_mod, func_ix);
  ord_named = (int32_t)ast_TypeKind_TYPE_NAMED;
  n_tp = 0;
  memset(type_args, 0, sizeof(type_args));
  memset(type_arg_lens, 0, sizeof(type_arg_lens));
  memset(formal_names, 0, sizeof(formal_names));
  memset(formal_name_lens, 0, sizeof(formal_name_lens));

  for (i = 0; i < np && n_tp < W449_MAX_TARGS; i++) {
    int32_t pi_ty = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
    uint8_t pi_nm[128];
    int32_t pi_nlen;
    int32_t arg_ref;
    int32_t arg_ty;
    int32_t k;
    int32_t found;
    int32_t slot;
    int32_t conc_len;

    if (pi_ty <= 0 || pipeline_type_kind_ord_at(arena, pi_ty) != ord_named)
      continue;
    memset(pi_nm, 0, sizeof(pi_nm));
    pi_nlen = pipeline_type_named_name_into(arena, pi_ty, pi_nm);
    if (pi_nlen <= 0)
      continue;
    /* Skip formals that are module types (concrete), not type params. */
    if (pipeline_typeck_named_is_module_type_c(callee_mod, arena, pi_nm, pi_nlen) != 0)
      continue;
    found = -1;
    for (k = 0; k < n_tp; k++) {
      if (formal_name_lens[k] == pi_nlen &&
          memcmp(formal_names[k], pi_nm, (size_t)pi_nlen) == 0) {
        found = k;
        break;
      }
    }
    if (found >= 0)
      continue; /* same formal name already mapped (unify already checked) */
    slot = n_tp;
    memcpy(formal_names[slot], pi_nm, (size_t)pi_nlen);
    formal_name_lens[slot] = pi_nlen;
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
    arg_ty = (arg_ref > 0) ? pipeline_expr_resolved_type_ref(arena, arg_ref) : 0;
    conc_len = 0;
    if (arg_ty > 0 && pipeline_type_kind_ord_at(arena, arg_ty) == ord_named) {
      memset(type_args[slot], 0, 64);
      conc_len = pipeline_type_named_name_into(arena, arg_ty, type_args[slot]);
      if (conc_len < 0)
        conc_len = 0;
      if (conc_len > 127)
        conc_len = 63;
    }
    type_arg_lens[slot] = conc_len;
    n_tp++;
  }

  /*
   * wave453/wave457: ret type param not already in formal slots (zero-arg
   * mk_default / multi ret-only mk2). Take concrete name from expected_ret.
   */
  ret_ty = pipeline_module_func_return_type_at(callee_mod, func_ix);
  if (ret_ty > 0 && pipeline_type_kind_ord_at(arena, ret_ty) == ord_named && n_tp < W449_MAX_TARGS) {
    memset(ret_nm, 0, sizeof(ret_nm));
    ret_nlen = pipeline_type_named_name_into(arena, ret_ty, ret_nm);
    if (ret_nlen > 0 &&
        pipeline_typeck_named_is_module_type_c(callee_mod, arena, ret_nm, ret_nlen) == 0) {
      int32_t found_r = -1;
      int32_t k;
      for (k = 0; k < n_tp; k++) {
        if (formal_name_lens[k] == ret_nlen &&
            memcmp(formal_names[k], ret_nm, (size_t)ret_nlen) == 0) {
          found_r = k;
          break;
        }
      }
      if (found_r < 0 && expected_ret > 0 &&
          pipeline_type_kind_ord_at(arena, expected_ret) == ord_named) {
        int32_t slot = n_tp;
        int32_t conc_len = 0;
        memcpy(formal_names[slot], ret_nm, (size_t)ret_nlen);
        formal_name_lens[slot] = ret_nlen;
        memset(type_args[slot], 0, 64);
        conc_len = pipeline_type_named_name_into(arena, expected_ret, type_args[slot]);
        if (conc_len < 0)
          conc_len = 0;
        if (conc_len > 127)
          conc_len = 63;
        type_arg_lens[slot] = conc_len;
        n_tp++;
      }
    }
  }

  if (n_tp <= 0)
    return 0;
  return xlang_generic_bound_check_type_args_c(fn_name, fn_name_len, type_args, type_arg_lens, n_tp,
                                              line, col);
}

/**
 * Validate generic call type arguments against callee's generic parameters.
 *
 * Why: Ensures type argument count matches generic parameter count, rejects
 * type arguments for non-generic functions, and triggers type inference for
 * bare calls (no turbofish) when possible. Integrates with try_infer_generic_
 * call_from_args_c for value-based inference and check_inferred_generic_
 * bounds_c for trait validation.
 *
 * Invariant: Returns 0 for valid type args or successful inference; -1 for
 * mismatched counts, non-generic callee with type args, or failed inference/
 * bounds check.
 *
 * Asm/Perf: O(1) — count checks + conditional inference. Cold path — called
 * during typeck of EXPR_CALL with generic callee.
 *
 * PLATFORM: SHARED — generic type arg validation is platform-independent.
 *
 * wave1099 G.7: migrated from glue.c:14613 (body 67 LOC). Static (non-extern):
 * same-TU — method_call.c #include at glue.c:L13803 < def EOF < callsite
 * glue.c:L14743 (inside pipeline_typeck_check_expr_call_c). Deps:
 * pipeline_expr_call_resolved_func_index_at / pipeline_expr_call_resolved_dep_
 * index_at / pipeline_dep_ctx_module_at / pipeline_module_func_num_generic_
 * params_at (extern, decl in-body) / pipeline_expr_call_num_type_args_at
 * (extern, decl in-body) / pipeline_expr_line_at / pipeline_expr_col_at /
 * pipeline_module_func_name_len_at / pipeline_module_func_name_copy64 /
 * driver_diagnostic_typeck_call_not_generic (extern, decl in-body) /
 * driver_diagnostic_typeck_call_requires_type_args (extern, decl in-body) /
 * driver_diagnostic_typeck_call_wrong_num_type_args (extern, decl in-body) /
 * pipeline_typeck_try_infer_generic_call_from_args_c (same file, def above) /
 * pipeline_typeck_check_inferred_generic_bounds_c (same file, def above)
 * (all extern unless noted).
 */
static int32_t pipeline_typeck_check_call_generic_type_args_c(struct ast_Module *module,
                                                              struct ast_ASTArena *arena, int32_t expr_ref,
                                                              struct ast_PipelineDepCtx *ctx,
                                                              int32_t expected_ret) {
  extern void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, const uint8_t *name,
                                                         int32_t name_len);
  extern void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col,
                                                                 const uint8_t *name, int32_t name_len,
                                                                 int32_t expect_n, int32_t got_n);
  extern void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col,
                                                                const uint8_t *name, int32_t name_len);
  extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index);
  extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref);
  struct ast_Module *callee_mod;
  int32_t func_ix;
  int32_t dep_ix;
  int32_t num_generic_params;
  int32_t num_type_args;
  int32_t line;
  int32_t col;
  uint8_t name[128];
  int32_t name_len;

  if (!module || !arena || expr_ref <= 0)
    return 0;
  func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
  if (func_ix < 0)
    return 0;
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
  callee_mod = module;
  if (dep_ix >= 0) {
    callee_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (!callee_mod)
      return 0;
  }
  num_generic_params = pipeline_module_func_num_generic_params_at(callee_mod, func_ix);
  num_type_args = pipeline_expr_call_num_type_args_at(arena, expr_ref);
  if (num_generic_params == 0 && num_type_args == 0)
    return 0;
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  name_len = pipeline_module_func_name_len_at(callee_mod, func_ix);
  if (name_len > 127)
    name_len = 63;
  if (name_len > 0)
    pipeline_module_func_name_copy64(callee_mod, func_ix, name);
  if (num_type_args > 0 && num_generic_params == 0) {
    driver_diagnostic_typeck_call_not_generic(line, col, name, name_len);
    return -1;
  }
  if (num_generic_params > 0 && num_type_args == 0) {
    /*
     * wave448: allow omitted turbofish when mono types are inferable from value
     * args. wave453: also from expected return when sole type param is ret-only
     * (zero-arg mk_default / as_t with ambient let/return type).
     * Fail closed to requires_type_args when inference cannot complete
     * (phantom-only T, untyped arg, mismatched same-name formals).
     * wave449: after successful infer, check trait bounds (parse-time scan only
     * sees turbofish `foo<Type>(...)`; bare `foo(arg)` was false-green).
     */
    if (pipeline_typeck_try_infer_generic_call_from_args_c(callee_mod, arena, expr_ref, func_ix,
                                                            expected_ret) == 0) {
      if (pipeline_typeck_check_inferred_generic_bounds_c(callee_mod, arena, expr_ref, func_ix, name,
                                                           name_len, line, col, expected_ret) != 0)
        return -1;
      return 0;
    }
    driver_diagnostic_typeck_call_requires_type_args(line, col, name, name_len);
    return -1;
  }
  if (num_generic_params != num_type_args) {
    driver_diagnostic_typeck_call_wrong_num_type_args(line, col, name, name_len, num_generic_params, num_type_args);
    return -1;
  }
  return 0;
}

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
 * wave1145 G.7: call arg *Struct compatibility check
 * (migrated from pipeline_glue.c L10200-10241).
 *
 * Why here: typeck_check_call_ptr_struct_compat_c is the MOD-02 sub-check
 * of call_arg compat — verifies that a *Struct formal param accepts the
 * caller's arg (NAMED struct / *NAMED / &local of NAMED). Colocated with
 * the overload resolution / call dispatch domain (wave1089-1094 cluster)
 * and the import binding name resolution domain (wave1085-1088 cluster)
 * already in this file.
 *
 * Caller (in glue.c, BEFORE this file's #include at L10585):
 *   - pipeline_typeck_check_call_slice_region_c (glue.c L10313) calls
 *     typeck_check_call_ptr_struct_compat_c.
 * Static fwd decl added at glue.c L10201 (BEFORE caller L10313).
 *
 * Dependencies (visible via earlier decls in the TU):
 *   - pipeline_type_kind_ord_at (extern fwd at glue.c L774)
 *   - ast_TypeKind_TYPE_PTR / TYPE_NAMED (global enum)
 *   - pipeline_type_elem_ref_at (extern)
 *   - typeck_type_is_named_struct_c (static, in pipeline_asm_emit_struct_lit.c
 *     #include at L2051, before this file's #include at L10585)
 *   - pipeline_expr_resolved_type_ref / pipeline_expr_kind_ord_at (extern)
 *   - ast_ExprKind_EXPR_ADDR_OF (global enum)
 *   - pipeline_expr_unary_operand_ref_at (extern)
 *   - pipeline_typeck_call_arg_repr_compatible_ok_c (extern, defined at
 *     glue.c L10151, before this file's #include at L10585)
 *   - pipeline_expr_line_at / pipeline_expr_col_at (extern)
 *   - lsp_diag_report_typeck (extern)
 *
 * PLATFORM: SHARED — pure typeck check + diagnostic emit; no platform ABI dep.
 * ============================================================ */

/**
 * MOD-02: *Struct formal param vs call arg (incl. &local) type compatibility.
 *
 * Verifies that when a function expects `*T` (TYPE_PTR to TYPE_NAMED struct),
 * the caller's argument is one of:
 *   - arg type is TYPE_NAMED struct T (auto-takes address)
 *   - arg type is *T (already a pointer)
 *   - arg is EXPR_ADDR_OF of a TYPE_NAMED struct T local
 *
 * Returns 0 if the check does not apply (param is not *Struct) or if the
 * argument is compatible (via call_arg_repr_compatible_ok_c positive path).
 * Returns -1 (with diagnostic) when struct pointer argument is incompatible.
 *
 * Contract: module / arena non-NULL; param_ref > 0; arg_ref > 0; call_expr_ref > 0.
 *
 * PLATFORM: SHARED — pure typeck dispatch + lsp_diag_report_typeck emit.
 */
static int32_t typeck_check_call_ptr_struct_compat_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t call_expr_ref, int32_t param_ref, int32_t arg_ref) {
  int32_t line;
  int32_t col;
  if (!module || !arena || param_ref <= 0 || arg_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, param_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
    return 0;
  {
    int32_t param_elem = pipeline_type_elem_ref_at(arena, param_ref);
    int32_t arg_ty;
    int32_t arg_kind;
    int32_t arg_elem;
    if (param_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, param_elem))
      return 0;
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
    if (arg_ty <= 0 && arg_kind == (int32_t)ast_ExprKind_EXPR_ADDR_OF) {
      int32_t op = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
      if (op > 0)
        arg_ty = pipeline_expr_resolved_type_ref(arena, op);
    }
    if (arg_ty <= 0)
      return 0;
    if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_NAMED)
      arg_elem = arg_ty;
    else if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_PTR)
      arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
    else
      return 0;
    if (arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, arg_elem))
      return 0;
  }
  /* wave703: G.7 positive path shared with call_arg_types / score. */
  if (pipeline_typeck_call_arg_repr_compatible_ok_c(module, arena, param_ref, arg_ref))
    return 0;
  line = pipeline_expr_line_at(arena, call_expr_ref);
  col = pipeline_expr_col_at(arena, call_expr_ref);
  lsp_diag_report_typeck((int)line, (int)col, "no matching overload (incompatible struct pointer argument)");
  return -1;
}

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
 *   - glue_generic_call_fixup_resolved_type_c (static, wave1096,
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
 * wave1155 G.7: CALL callee return-type resolver
 * (migrated from pipeline_glue.c L8994-9160).
 *
 * Why here: pipeline_typeck_resolve_call_callee_return_type_c resolves
 * the return type for a CALL/METHOD_CALL callee expr. It is the
 * return-type twin of pipeline_typeck_resolve_call_func_index_c
 * (already in this file, wave1085-1094) — both resolve call targets
 * from callee expressions. Colocating them keeps the call-resolution
 * domain in a single file.
 *
 * Contract: returns >0 type_ref on success (caller applies via
 * pipeline_typeck_expr_apply_call_resolve_c if want_resolve), 0 if
 * unresolved. Resolution order:
 *   (1) FIELD_ACCESS whole-import call (math.floor form)
 *   (2) FIELD_ACCESS binding-based call (import_binding + field name)
 *   (3) Local module function (find_func_return_type_in_module_c)
 *   (4) Dep scan: each dep module + import_select name match
 *
 * Dependencies (all visible via same-TU globals or extern headers):
 *   - pipeline_expr_kind_ord_at / pipeline_expr_field_access_base_ref /
 *     _name_len / _name_into / pipeline_expr_var_name_len / _into
 *     (extern, header-declared)
 *   - pipeline_typeck_resolve_whole_import_call_ret_c (extern)
 *   - pipeline_typeck_expr_apply_call_resolve_c (extern)
 *   - pipeline_typeck_module_num_imports_c (static in assign.c wave1066;
 *     visible same-TU via #include at L8265 < this file #include at L10186)
 *   - pipeline_typeck_import_binding_name_equal_impl (extern)
 *   - pipeline_typeck_resolve_dep_index_for_import_c (extern)
 *   - pipeline_dep_ctx_module_at / pipeline_dep_ctx_ndep (extern)
 *   - pipeline_typeck_find_func_return_type_in_module_c (extern, defined
 *     at glue.c L8926; visible via extern fwd decl at glue.c L8926 which
 *     is BEFORE this file's #include at L10186)
 *   - pipeline_typeck_find_func_return_type_in_module_by_name_c (extern)
 *   - pipeline_module_import_kind_at / pipeline_module_import_select_count_at
 *     / pipeline_typeck_import_select_name_equal_impl (extern)
 *   - GLUE_TYPECK_IMPORT_BINDING / GLUE_TYPECK_IMPORT_SELECT (anonymous
 *     enum at glue.c L2241, BEFORE this file's #include at L10186 — visible)
 *
 * Caller (in glue.c, AFTER this file's #include at L10186):
 *   - pipeline_typeck_check_expr_call_c (glue.c L10353; sole callsite)
 *   No fwd decl needed: caller is after the #include point.
 *
 * PLATFORM: SHARED — pure typeck call-target resolution; no platform ABI dep.
 * ============================================================ */

/**
 * typeck.x::resolve_call_callee_return_type C delegate: resolve CALL callee
 * return type (local module / dep / whole-package / binding / deconstruct import).
 */
int32_t pipeline_typeck_resolve_call_callee_return_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                          int32_t callee_expr_ref, int32_t call_expr_ref,
                                                          struct ast_PipelineDepCtx *ctx) {
  int32_t want_resolve;
  int32_t whole_dep;
  int32_t whole_fn;
  int32_t *p_whole_dep;
  int32_t *p_whole_fn;
  int32_t callee_ord;
  int32_t minus_one;
  int32_t loc_fn;
  int32_t *p_loc_fn;
  int32_t ret;
  int32_t i;
  int32_t imax;
  int32_t nd_scan;

  if (callee_expr_ref <= 0 || !arena || callee_expr_ref > arena->num_exprs)
    return 0;
  want_resolve = (call_expr_ref > 0 && call_expr_ref <= arena->num_exprs);
  whole_dep = 0;
  whole_fn = 0;
  p_whole_dep = 0;
  p_whole_fn = 0;
  if (want_resolve) {
    p_whole_dep = &whole_dep;
    p_whole_fn = &whole_fn;
  }
  callee_ord = pipeline_expr_kind_ord_at(arena, callee_expr_ref);
  if (callee_ord == 44) {
    int32_t r_whole;

    r_whole = pipeline_typeck_resolve_whole_import_call_ret_c(
        module, arena, callee_expr_ref, ctx, p_whole_dep, p_whole_fn);
    if (r_whole != 0) {
      if (want_resolve)
        pipeline_typeck_expr_apply_call_resolve_c(arena, call_expr_ref, whole_dep, whole_fn);
      return r_whole;
    }
  }
  if (callee_ord == 44) {
    int32_t base_bind_ref;

    base_bind_ref = pipeline_expr_field_access_base_ref(arena, callee_expr_ref);
    if (base_bind_ref > 0 && base_bind_ref <= arena->num_exprs &&
        pipeline_expr_kind_ord_at(arena, base_bind_ref) == 3) {
      int32_t base_bind_len;

      base_bind_len = pipeline_expr_var_name_len(arena, base_bind_ref);
      if (base_bind_len > 0 && base_bind_len <= 63) {
        uint8_t base_bind_nm[128];
        int32_t field_len;
        uint8_t field_nm[128];
        int32_t ii;
        int32_t n_imp;

        pipeline_expr_var_name_into(arena, base_bind_ref, base_bind_nm);
        field_len = pipeline_expr_field_access_name_len(arena, callee_expr_ref);
        pipeline_expr_field_access_name_into(arena, callee_expr_ref, field_nm);
        n_imp = pipeline_typeck_module_num_imports_c(module);
        ii = 0;
        while (ii < n_imp) {
          if (pipeline_module_import_kind_at(module, ii) == GLUE_TYPECK_IMPORT_BINDING &&
              pipeline_typeck_import_binding_name_equal_impl(module, ii, base_bind_nm, base_bind_len)) {
            struct ast_Module *dm;
            int32_t dep_slot;

            dep_slot = pipeline_typeck_resolve_dep_index_for_import_c(module, ctx, ii);
            if (dep_slot < 0)
              break;
            dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
            if (dm) {
              int32_t bind_fn = 0;
              int32_t *p_bind_fn = 0;
              int32_t ret_b;

              if (want_resolve)
                p_bind_fn = &bind_fn;
              ret_b = pipeline_typeck_find_func_return_type_in_module_by_name_c(dm, arena, field_nm, field_len,
                                                                                dep_slot, ctx, p_bind_fn);
              if (ret_b != 0) {
                if (want_resolve)
                  pipeline_typeck_expr_apply_call_resolve_c(arena, call_expr_ref, dep_slot, bind_fn);
                return ret_b;
              }
            }
            break;
          }
          ii = ii + 1;
        }
      }
    }
  }
  minus_one = -1;
  loc_fn = 0;
  p_loc_fn = 0;
  if (want_resolve)
    p_loc_fn = &loc_fn;
  ret = pipeline_typeck_find_func_return_type_in_module_c(module, arena, arena, arena, callee_expr_ref, minus_one, ctx,
                                                          p_loc_fn);
  if (ret != 0) {
    if (want_resolve)
      pipeline_typeck_expr_apply_call_resolve_c(arena, call_expr_ref, minus_one, loc_fn);
    return ret;
  }
  i = 0;
  imax = pipeline_typeck_module_num_imports_c(module);
  nd_scan = pipeline_dep_ctx_ndep(ctx);
  if (nd_scan > imax)
    imax = nd_scan;
  while (i < imax) {
    struct ast_Module *dm;
    int32_t dep_fn;
    int32_t *p_dep_fn;

    dm = pipeline_dep_ctx_module_at(ctx, i);
    if (!dm) {
      i = i + 1;
      continue;
    }
    dep_fn = 0;
    p_dep_fn = 0;
    if (want_resolve)
      p_dep_fn = &dep_fn;
    ret = pipeline_typeck_find_func_return_type_in_module_c(dm, arena, arena, arena, callee_expr_ref, i, ctx, p_dep_fn);
    if (ret != 0) {
      if (want_resolve)
        pipeline_typeck_expr_apply_call_resolve_c(arena, call_expr_ref, i, dep_fn);
      return ret;
    }
    if (i < module->num_imports && pipeline_module_import_kind_at(module, i) == GLUE_TYPECK_IMPORT_SELECT &&
        callee_ord == 3) {
      int32_t cv_len;

      cv_len = pipeline_expr_var_name_len(arena, callee_expr_ref);
      if (cv_len > 0) {
        uint8_t cv_nm[128];
        int32_t k;
        int32_t sel_cnt;

        pipeline_expr_var_name_into(arena, callee_expr_ref, cv_nm);
        k = 0;
        sel_cnt = pipeline_module_import_select_count_at(module, i);
        while (k < sel_cnt) {
          if (pipeline_typeck_import_select_name_equal_impl(module, i, k, cv_nm, cv_len)) {
            int32_t sel_fn = 0;
            int32_t *p_sel_fn = 0;

            if (want_resolve)
              p_sel_fn = &sel_fn;
            ret = pipeline_typeck_find_func_return_type_in_module_by_name_c(dm, arena, cv_nm, cv_len, i, ctx, p_sel_fn);
            if (ret != 0) {
              if (want_resolve)
                pipeline_typeck_expr_apply_call_resolve_c(arena, call_expr_ref, i, sel_fn);
              return ret;
            }
            break;
          }
          k = k + 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

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
 * wave1170 G.7: overload wrapper cluster (2 extern fns) migrated from
 * pipeline_glue.c (was L8428-8438). Colocated with method_call domain —
 * these wrappers delegate to static overload resolution functions already
 * in this file (pipeline_typeck_resolve_call_func_index_c and
 * pipeline_typeck_pick_overload_func_index_c, wave1090-1094).
 *
 * Extern fwd decls at glue.c L5081/5083 (before ast_pool.c #include L5281
 * < method_call.c #include L9153) cover ast_pool.c:11607 callsite.
 * Seed callsites (backend_call_dispatch.from_x.c:3033, _surface:763) link
 * against the extern symbol directly.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/**
 * Resolve CALL target func index (with overload dispatch) for asm emit.
 * Why: backend_call_dispatch needs the resolved function index before emitting
 *      call args and the call instruction. Delegates to the static overload
 *      resolver pipeline_typeck_resolve_call_func_index_c (same file).
 * Contract: delegates; null m/a → resolver returns 0.
 * PLATFORM: SHARED — asm CALL/func emit entry point.
 */
int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          int32_t call_expr_ref) {
  return pipeline_typeck_resolve_call_func_index_c(m, a, call_expr_ref);
}

/**
 * Pick overload func index by argument types for WPO call-edge / typeck.
 * Why: WPO call-edge analysis and typeck need to determine which overload
 *      variant a call targets, based on argument types. Delegates to the
 *      static overload scorer pipeline_typeck_pick_overload_func_index_c.
 * Contract: delegates; null m/a → resolver returns 0.
 * PLATFORM: SHARED — WPO call-edge / typeck overload selection.
 */
int32_t pipeline_typeck_pick_overload_func_index_for_call_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                            int32_t call_expr_ref) {
  return pipeline_typeck_pick_overload_func_index_c(m, a, call_expr_ref);
}

/* ============================================================
 * wave1192 G.7: import resolution cluster (3 extern fns)
 * migrated from pipeline_glue.c L4831/L4900/L5014. Colocated with
 * method_call domain — qualified import call resolution is a
 * sub-domain of method-call target resolution:
 * - import_segment_at_c: split import path into '.'-separated segments
 * - resolve_dep_index_for_import_c: map entry import slot → dep ctx slot
 * - resolve_whole_import_call_ret_c: resolve `platform.elf.fn(args)` callee
 *   return type by walking field_access chain + import path match.
 *
 * Forward decls at L82-88 (before callsites L178/2946/2981).
 *
 * Dependencies visible at #include point (method_call.c #include in glue.c):
 * - pipeline_typeck_module_num_imports_c (static in assign.c, same TU)
 * - pipeline_module_import_path_len/byte_at (extern)
 * - pipeline_dep_ctx_ndep/import_path_len/import_path_copy64/module_at (extern)
 * - asm_qual_sym_layer_reset/push/count/len/copy (extern)
 * - pipeline_expr_kind_ord_at/var_name_len/var_name_into (extern)
 * - pipeline_expr_field_access_name_len/name_into/base_ref (extern)
 * - pipeline_typeck_import_path_segment_count_impl (static in this file,
 *   wave1085-1088 migration; visible via static fwd decl in glue.c L5002)
 * - pipeline_typeck_import_path_slice_equal_impl (static in this file,
 *   wave1085-1088 migration; visible via static fwd decl in glue.c L5003)
 * - pipeline_typeck_find_func_return_type_in_module_by_name_c (extern fwd
 *   decl in glue.c L4985, defined in this file wave1169)
 * - link_abi_getenv (extern)
 * PLATFORM: SHARED — product path (seed typeck → this glue).
 * ============================================================ */

/**
 * typeck.x::import_segment_at C twin.
 *
 * Why: split an import path into '.'-separated segments; return the byte
 *      range [ostr, olen) of the want_seg-th segment. Used by
 *      resolve_whole_import_call_ret_c to match qualified call chains
 *      against import path segments.
 * Invariant: module non-null; imp_ix in [0, num_imports); want_seg >= 0.
 * Contract: returns 1 on hit (ostr/olen set); 0 on miss / bad input.
 * PLATFORM: SHARED — typeck pass; no codegen.
 */
int32_t pipeline_typeck_import_segment_at_c(struct ast_Module *module, int32_t imp_ix, int32_t want_seg,
                                              int32_t *ostr, int32_t *olen) {
  int32_t pl;
  int32_t ci;
  int32_t ss;
  int32_t k;
  int32_t n_imp;

  n_imp = pipeline_typeck_module_num_imports_c(module);
  if (!module || imp_ix < 0 || imp_ix >= n_imp || !ostr || !olen)
    return 0;
  pl = pipeline_module_import_path_len(module, imp_ix);
  if (pl <= 0 || pl > 127)
    return 0;
  ci = 0;
  ss = 0;
  k = 0;
  while (k <= pl) {
    int32_t at_end_p = (k == pl);
    int32_t dot_p = 0;
    if (!at_end_p && k < pl)
      dot_p = (pipeline_module_import_path_byte_at(module, imp_ix, k) == 46);
    if (at_end_p || dot_p) {
      int32_t seg_len_here = k - ss;
      if (seg_len_here <= 0)
        return 0;
      if (ci == want_seg) {
        ostr[0] = ss;
        olen[0] = seg_len_here;
        return 1;
      }
      if (dot_p)
        ss = k + 1;
      ci = ci + 1;
    }
    k = k + 1;
  }
  return 0;
}

/**
 * typeck.x::resolve_dep_index_for_import C twin.
 *
 * Why: map entry-module import slot → dep ctx slot by import path.
 *      Closure seed may order deps differently from entry import index
 *      (ndep > n_imports). Callers must use this; never use imp_ix as
 *      dep index directly.
 * Invariant: module/ctx non-null; imp_ix in [0, num_imports).
 * Contract: returns dep slot index >= 0 on hit; -1 on miss / bad input.
 * PLATFORM: SHARED — typeck pass; no codegen.
 */
int32_t pipeline_typeck_resolve_dep_index_for_import_c(struct ast_Module *module,
                                                       struct ast_PipelineDepCtx *ctx, int32_t imp_ix) {
  uint8_t imp_path[128];
  int32_t plen;
  int32_t n_imp;
  int32_t di;
  int32_t nd;

  n_imp = pipeline_typeck_module_num_imports_c(module);
  if (!module || !ctx || imp_ix < 0 || imp_ix >= n_imp)
    return -1;
  plen = pipeline_module_import_path_len(module, imp_ix);
  if (plen <= 0 || plen > 127)
    return -1;
  di = 0;
  while (di < plen) {
    imp_path[di] = pipeline_module_import_path_byte_at(module, imp_ix, di);
    di = di + 1;
  }
  nd = pipeline_dep_ctx_ndep(ctx);
  di = 0;
  while (di < nd) {
    int32_t dep_plen = pipeline_dep_ctx_import_path_len(ctx, di);
    if (dep_plen == plen) {
      uint8_t dep_path[128];
      int32_t k = 0;
      int32_t eq = 1;
      pipeline_dep_ctx_import_path_copy64(ctx, di, dep_path);
      while (k < plen) {
        if (dep_path[k] != imp_path[k]) {
          eq = 0;
          break;
        }
        k = k + 1;
      }
      if (eq)
        return di;
    }
    di = di + 1;
  }
  return -1;
}

/**
 * typeck.x::resolve_whole_import_qualified_call_return_type C twin.
 *
 * Why: resolve `platform.elf.fn(args)` whole-import callee return type.
 *      Walks the field_access chain (pushing each segment onto the asm qual
 *      sym layer stack), matches against entry-module import paths segment
 *      by segment, then resolves the dep slot + func return type via
 *      find_func_return_type_in_module_by_name_c.
 * Invariant: module/arena/ctx non-null; callee_expr_ref > 0;
 *            callee kind must be EXPR_FIELD_ACCESS (ord 44).
 * Contract: returns nonzero type_ref on hit (dep_index_out/func_index_out
 *           set if non-null); 0 on miss / bad input.
 * PLATFORM: SHARED — typeck pass; no codegen.
 */
int32_t pipeline_typeck_resolve_whole_import_call_ret_c(
    struct ast_Module *module, struct ast_ASTArena *arena, int32_t callee_expr_ref, struct ast_PipelineDepCtx *ctx,
    int32_t *dep_index_out, int32_t *func_index_out) {
  uint8_t layer_buf[128];
  int32_t nstack;
  int32_t cur_ref;
  int32_t dep_j;

  if (!ctx || !module || !arena || callee_expr_ref <= 0 || callee_expr_ref > arena->num_exprs)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 44)
    return 0;
  asm_qual_sym_layer_reset();
  cur_ref = callee_expr_ref;
  while (1) {
    int32_t falen;
    if (cur_ref <= 0 || cur_ref > arena->num_exprs)
      return 0;
    falen = pipeline_expr_field_access_name_len(arena, cur_ref);
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != 44 || falen <= 0 || falen > 127)
      break;
    pipeline_expr_field_access_name_into(arena, cur_ref, layer_buf);
    if (asm_qual_sym_layer_push(layer_buf, falen) < 0)
      return 0;
    cur_ref = pipeline_expr_field_access_base_ref(arena, cur_ref);
  }
  nstack = asm_qual_sym_layer_count();
  if (cur_ref <= 0 || cur_ref > arena->num_exprs)
    return 0;
  {
    int32_t vnlen;
    uint8_t vname_buf[128];
    int32_t n_imp;

    vnlen = pipeline_expr_var_name_len(arena, cur_ref);
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != 3 || vnlen <= 0 || vnlen > 127)
      return 0;
    pipeline_expr_var_name_into(arena, cur_ref, vname_buf);
    n_imp = pipeline_typeck_module_num_imports_c(module);
    dep_j = 0;
    while (dep_j < n_imp) {
      int32_t plen;
      uint8_t path_cnt_buf[128];
      int32_t pci;
      int32_t pseg;
      int32_t s0_rel;
      int32_t s0_ln;

      plen = pipeline_module_import_path_len(module, dep_j);
      if (plen <= 0 || plen > 127) {
        dep_j = dep_j + 1;
        continue;
      }
      pci = 0;
      while (pci < plen && pci < 64) {
        path_cnt_buf[pci] = pipeline_module_import_path_byte_at(module, dep_j, pci);
        pci = pci + 1;
      }
      pseg = pipeline_typeck_import_path_segment_count_impl(path_cnt_buf, plen);
      if (pseg <= 0 || nstack != pseg) {
        dep_j = dep_j + 1;
        continue;
      }
      if (!pipeline_typeck_import_segment_at_c(module, dep_j, 0, &s0_rel, &s0_ln) ||
          !pipeline_typeck_import_path_slice_equal_impl(module, dep_j, s0_rel, s0_ln, vname_buf, vnlen)) {
        dep_j = dep_j + 1;
        continue;
      }
      {
        int32_t bad_mid = 0;
        int32_t sm;

        sm = 1;
        while (sm <= pseg - 1) {
          int32_t srv;
          int32_t slv;
          int32_t lay_ix;

          if (!pipeline_typeck_import_segment_at_c(module, dep_j, sm, &srv, &slv)) {
            bad_mid = 1;
          } else {
            lay_ix = pseg - sm;
            asm_qual_sym_layer_copy(lay_ix, layer_buf, 64);
            if (!pipeline_typeck_import_path_slice_equal_impl(module, dep_j, srv, slv, layer_buf,
                                                             asm_qual_sym_layer_len(lay_ix)))
              bad_mid = 1;
          }
          if (bad_mid)
            break;
          sm = sm + 1;
        }
        if (bad_mid) {
          dep_j = dep_j + 1;
          continue;
        }
      }
      {
        struct ast_Module *dm;
        int32_t dep_slot;
        int32_t ret_fn;

        dep_slot = pipeline_typeck_resolve_dep_index_for_import_c(module, ctx, dep_j);
        if (dep_slot < 0) {
          dep_j = dep_j + 1;
          continue;
        }
        dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
        if (!dm) {
          dep_j = dep_j + 1;
          continue;
        }
        asm_qual_sym_layer_copy(0, layer_buf, 64);
        ret_fn = pipeline_typeck_find_func_return_type_in_module_by_name_c(
            dm, arena, layer_buf, asm_qual_sym_layer_len(0), dep_slot, ctx, func_index_out);
        if (ret_fn != 0 && dep_index_out)
          dep_index_out[0] = dep_slot;
        return ret_fn;
      }
    }
  }
  return 0;
}
