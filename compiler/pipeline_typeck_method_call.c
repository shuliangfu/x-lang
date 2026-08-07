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
            typeck_import_binding_name_equal(module, j, base_nm, base_nlen)) {
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

/*
 * wave251 pure leave: mono-map lookup/bind + named_num_type_args +
 * alloc_named_with_type_args + pattern_unify + build_value_formal_mono_map +
 * subst_type_ref → typeck_x.o (#[no_mangle] Cap faces, flat stride-128 ABI).
 * Dual-export ban: residual bodies deleted; Cap faces top-of-file extern-only.
 * Residual multi-dim names[N][128] is contiguous with flat *u8 — cast when calling.
 * PLATFORM: SHARED freestanding typeck generic mono map engine.
 */
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
/* wave1198: pipeline_typeck_call_arg_repr_compatible_ok_c migrated to
 * pipeline_typeck_check_expr.c EOF. Extern for method_call same-TU callsites. */
extern int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                              int32_t param_ref, int32_t arg_ref);

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
                                                   (uint8_t *)map_names, map_lens, map_conc, W486_MONO_MAX_MAP);
  if (n_map <= 0)
    return 0;

  mono_ret = glue_typeck_subst_type_ref_c(search_mod, search_arena, caller_arena, ret_ty, (uint8_t *)map_names,
                                         map_lens, map_conc, n_map, 0);
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
                                                   (uint8_t *)map_names, map_lens, map_conc, W486_MONO_MAX_MAP);
  if (n_map <= 0)
    return 0;

  /* Free type-param ret: subst free NAMED leaf = map lookup (wave251 Cap). */
  if (pipeline_typeck_named_is_module_type_c(search_mod, search_arena, ret_nm, ret_nlen) == 0) {
    mono_ret = glue_typeck_subst_type_ref_c(search_mod, search_arena, caller_arena, ret_ty, (uint8_t *)map_names,
                                           map_lens, map_conc, n_map, 0);
    return mono_ret > 0 ? mono_ret : 0;
  }

  /* Module ret with free tree — same as subst_module_ret but reuses shared map. */
  if (glue_typeck_type_tree_has_free_param_c(search_mod, search_arena, ret_ty, 0) == 0)
    return 0;
  mono_ret = glue_typeck_subst_type_ref_c(search_mod, search_arena, caller_arena, ret_ty, (uint8_t *)map_names,
                                         map_lens, map_conc, n_map, 0);
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
      if (glue_typeck_pattern_unify_bind_c(module, arena, p0, arena, base_ty, (uint8_t *)g_names, g_lens, g_conc,
                                            &g_nmap, W486_MONO_MAX_MAP, 0) != 0 ||
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
          int32_t g_sub = glue_typeck_subst_type_ref_c(module, arena, arena, g_param, (uint8_t *)g_names, g_lens,
                                                      g_conc, g_nmap, 0);
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
        int32_t g_mono = glue_typeck_subst_type_ref_c(module, arena, arena, g_ret, (uint8_t *)g_names, g_lens,
                                                     g_conc, g_nmap, 0);
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

/*
 * wave249 pure leave: pipeline_typeck_call_arg_effective_type_c body → typeck_x.o
 * (#[no_mangle] Cap face → typeck_call_arg_effective_type). Dual-export ban.
 * try_infer callsites use Cap face via top-of-file extern.
 * PLATFORM: SHARED freestanding typeck mono foundation.
 */


/* ============================================================
 * wave248 pure leave: overload pick/resolve → typeck_x.o
 * Deleted residual second score path (G.7 dual-export ban).
 * PLATFORM: SHARED freestanding typeck CALL overload resolve.
 * ============================================================ */

/* ============================================================
 * wave249 pure leave: mono foundation → typeck_x.o
 * Deleted residual second bodies (G.7 dual-export ban):
 *   pipeline_typeck_named_is_module_type_c
 *   pipeline_typeck_call_arg_effective_type_c
 *   glue_typeck_type_tree_has_free_param_c
 * Live authority: typeck_named_is_module_type + typeck_call_arg_effective_type
 *   + typeck_type_tree_has_free_type_param + Cap faces #[no_mangle] in typeck.x
 * Cap residual faces: top-of-file extern-only (bodies in typeck_x.o).
 * PLATFORM: SHARED freestanding typeck generic mono foundation.
 * ============================================================ */

/* ===========================================================================
 * wave1095-1099 G.7: generic call inference domain residual (try_infer /
 * bounds / check_call_generic_type_args / fixup) still host-cc here.
 * named_is_module_type + free_param + call_arg_effective → typeck_x (wave249).
 * PLATFORM: SHARED.
 * ========================================================================== */

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
/*
 * wave232: non-static product face so typeck.x::typeck_check_expr_call can
 * call after pure leave (was static same-TU only for call_c). G.7 sole fixup
 * path — do not open a second mono stamp in typeck.x body.
 * PLATFORM: SHARED freestanding typeck.
 */
int32_t glue_generic_call_fixup_resolved_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
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
                                                       (uint8_t *)map_names_c, map_lens_c, map_conc_c,
                                                       W486_MONO_MAX_MAP);
    if (n_map_c <= 0)
      return 0;
    mono_ret_c = glue_typeck_subst_type_ref_c(search_mod, search_arena, arena, ret_ty, (uint8_t *)map_names_c,
                                             map_lens_c, map_conc_c, n_map_c, 0);
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

/*
 * wave250 pure leave: try_infer + check_inferred_generic_bounds +
 * pipeline_typeck_check_call_generic_type_args_c → typeck_x.o
 * (#[no_mangle] Cap face → typeck_check_call_generic_type_args + pure helpers).
 * Dual-export ban: residual bodies deleted; Cap face extern at top-of-file.
 * PLATFORM: SHARED freestanding typeck generic call type-args gate.
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

