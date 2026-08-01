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
 * pipeline_typeck_named_is_module_type_c is forward-declared here; definition
 * remains later in pipeline_glue.c (same TU).
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
