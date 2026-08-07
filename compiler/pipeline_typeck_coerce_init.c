/**
 * pipeline_typeck_coerce_init.c — typeck coerce-init domain Cap residual thin
 * (BC 8.3.1 wave230 pure leave + wave229 + wave227).
 *
 * wave230 G.7 pure leave: type_refs_equal cluster + integer_widen +
 * type_ref_is_bool + expr_type_ref dual bodies retired → typeck_type_refs_* /
 * typeck_integer_widen_ok{,_refs} / typeck_type_ref_is_bool /
 * typeck_expr_type_ref. typeck.x type_refs_equal no longer wraps residual C
 * (resolve_alias residual peel + type_refs_equal_impl authority).
 * wave229: float_widen + ret_coerce → typeck twins.
 * wave227: lit/float/enum/named_call/array_vector/vector_binop/slice/expr_to_decl
 * thin → typeck_coerce_init_*.
 * Cap residual keeps only:
 *   1. Thin product faces → typeck_x.o (coerce-init + ret_coerce + float_widen
 *      + type_refs + integer_widen + bool + expr_type_ref + struct_lit)
 *   2. int_binop_c body — typeck.x still thin-wraps this C authority
 *      (cannot thin without cycle)
 *   3. resolve_type_alias_ref_c body — active_module peel (typeck uses it)
 *   4. int_lit + float_bits residual (typeck wraps int_lit C; float bits helper)
 *   5. expr_is_any_assign_kind static (mega dispatch helper)
 *
 * Dual-export ban: do NOT re-open second lit/float/enum/array/vector/slice/
 * ret_coerce/float_widen/type_refs/integer_widen/struct_lit bodies here;
 * typeck.x is single authority.
 * wave231: struct_lit_to_decl_c dual body retired → typeck twin.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * check_block_one_region and before check_expr_impl forward decls.
 *
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link.
 */

/* Live coerce-init authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_coerce_init_lit_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                             int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
extern int32_t typeck_coerce_init_float_lit_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                                   int32_t decl_ty_ref, int32_t decl_kind,
                                                   int32_t init_kind);
extern int32_t typeck_coerce_init_enum_field_to_decl(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind,
                                                    int32_t init_kind);
extern int32_t typeck_coerce_init_named_call_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                                    int32_t decl_ty_ref, int32_t decl_kind,
                                                    int32_t init_kind);
extern int32_t typeck_coerce_init_array_vector_lit_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                                          int32_t decl_ty_ref, int32_t decl_kind,
                                                          int32_t init_kind);
extern int32_t typeck_coerce_init_vector_binop_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                                      int32_t decl_ty_ref, int32_t decl_kind,
                                                      int32_t init_kind);
extern int32_t typeck_coerce_init_slice_from_array(struct ast_ASTArena *arena, int32_t init_ref,
                                                   int32_t decl_ty_ref, int32_t decl_kind);
extern int32_t typeck_coerce_init_expr_to_decl(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t init_ref, int32_t decl_ty_ref);

/* wave229: live ret_coerce + float_widen authority in typeck_x.o. */
extern int32_t typeck_float_widen_ok(int32_t dest_kind, int32_t src_kind);
extern int32_t typeck_return_operand_matches(struct ast_ASTArena *arena, int32_t op_ref,
                                            int32_t expect_ref);
extern void typeck_ret_coerce_integral_to_expect_i32(struct ast_ASTArena *arena, int32_t op_ref,
                                                     int32_t expect_ref);
extern void typeck_ret_coerce_integral_widen(struct ast_ASTArena *arena, int32_t op_ref,
                                             int32_t expect_ref);

/* wave230: live type_refs / integer_widen / bool / expr_type_ref in typeck_x.o. */
extern int typeck_type_refs_equal(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int typeck_type_refs_equal_named(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int typeck_type_refs_equal_same_kind(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                            int32_t kind_ord);
extern int typeck_type_refs_equal_impl(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int typeck_integer_widen_ok(int32_t dest_kind, int32_t src_kind);
extern int typeck_integer_widen_ok_refs(struct ast_ASTArena *arena, int32_t dest_ref, int32_t src_ref);
extern int typeck_type_ref_is_bool(struct ast_ASTArena *arena, int32_t type_ref);
extern int typeck_type_ref_is_bool_impl(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t typeck_expr_type_ref(struct ast_ASTArena *arena, int32_t expr_ref);

/* wave231: live struct_lit coerce authority in typeck_x.o. */
extern int32_t typeck_coerce_init_struct_lit_to_decl(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t init_ref, int32_t decl_ty_ref);

/* wave1158/wave230: public C ABI faces defined below (thin → typeck). Same-TU
 * callers (method_call residual, check_expr try_propagate) need decls before
 * EOF definitions when include order places them earlier. */
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                     int32_t kind_ord);
int32_t pipeline_typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref,
                                                int32_t src_ref);

/**
 * Product-mega C face for integer-literal init coerce.
 * Thin → typeck_coerce_init_lit_to_decl (wave307+ null/u16/i16/f32 paths).
 * Callers: residual check_expr return coerce; expr_to_decl thin face.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                  int32_t decl_kind, int32_t init_kind) {
  return typeck_coerce_init_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * Product-mega C face for float-lit / -float init coerce (wave316).
 * Thin → typeck_coerce_init_float_lit_to_decl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_float_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  return typeck_coerce_init_float_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * Product-mega C face for enum variant field-access init coerce.
 * Thin → typeck_coerce_init_enum_field_to_decl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_enum_field_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind,
                                                         int32_t init_kind) {
  return typeck_coerce_init_enum_field_to_decl(module, arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * Product-mega C face for named TYPE + EXPR_CALL init coerce.
 * Thin → typeck_coerce_init_named_call_to_decl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_named_call_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                         int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  return typeck_coerce_init_named_call_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * Product-mega C face for array/slice/vector lit init coerce (wave328).
 * Thin → typeck_coerce_init_array_vector_lit_to_decl (elem-type walk + stamp).
 * Callers: residual check_expr return + region_assign call-arg.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind) {
  return typeck_coerce_init_array_vector_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * Product-mega C face for vector binop init coerce.
 * Thin → typeck_coerce_init_vector_binop_to_decl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_vector_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                           int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  return typeck_coerce_init_vector_binop_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
}

/**
 * typeck.x::typeck_coerce_init_int_binop_to_decl C authority (kept residual).
 *
 * let/assign/return scalar int or f32/f64 decl + arithmetic / EXPR_NEG init
 * stamps resolved_type_ref to decl type (INT64_MIN, `let a:f32 = -6`, u8/u16
 * wrap, NAMED i8/i16). typeck.x thin-wraps this face — do NOT thin to typeck
 * (would cycle). PLATFORM: SHARED freestanding + host.
 */
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  /*
   * i8/i16 live as TYPE_NAMED; u16 same. wave309+ isize; wave310 u8; wave319 f32/f64.
   * Bare int lit still via lit coerce; float lit NEG via float_lit. PLATFORM: SHARED.
   */
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_I32 && decl_kind != (int32_t)ast_TypeKind_TYPE_I64 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_U8 && decl_kind != (int32_t)ast_TypeKind_TYPE_U32 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_U64 && decl_kind != (int32_t)ast_TypeKind_TYPE_USIZE &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_ISIZE &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_F32 && decl_kind != (int32_t)ast_TypeKind_TYPE_F64 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    uint8_t nm[128] = { 0 };
    int32_t nlen = pipeline_type_named_name_into(arena, decl_ty_ref, nm);
    if (!((nlen == 2 && nm[0] == 105 && nm[1] == 56) ||                 /* "i8" */
          (nlen == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) ||   /* "i16" */
          (nlen == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54)))    /* "u16" */
      return 0;
  }
  if (init_kind != (int32_t)ast_ExprKind_EXPR_ADD && init_kind != (int32_t)ast_ExprKind_EXPR_SUB &&
      init_kind != (int32_t)ast_ExprKind_EXPR_MUL && init_kind != (int32_t)ast_ExprKind_EXPR_DIV &&
      init_kind != (int32_t)ast_ExprKind_EXPR_NEG)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  /*
   * wave319: f32/f64 + EXPR_NEG of bare int lit — stamp operand too so
   * freestanding emit_neg loads IEEE bits (not two's-complement int).
   * PLATFORM: SHARED / LINUX+MACOS freestanding.
   */
  if ((decl_kind == (int32_t)ast_TypeKind_TYPE_F32 || decl_kind == (int32_t)ast_TypeKind_TYPE_F64) &&
      init_kind == (int32_t)ast_ExprKind_EXPR_NEG) {
    int32_t op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
    if (!ast_ref_is_null(op_ref) && op_ref > 0 && op_ref <= arena->num_exprs &&
        pipeline_expr_kind_ord_at(arena, op_ref) == (int32_t)ast_ExprKind_EXPR_LIT) {
      struct ast_Expr *op_ex = pipeline_arena_expr_ptr(arena, op_ref);
      if (op_ex)
        op_ex->resolved_type_ref = decl_ty_ref;
    }
  }
  init_ex->resolved_type_ref = decl_ty_ref;
  return 1;
}

/**
 * Product-mega C face for anonymous struct lit → named decl coerce.
 * Thin → typeck_coerce_init_struct_lit_to_decl (wave231 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_struct_lit_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref) {
  return typeck_coerce_init_struct_lit_to_decl(module, arena, init_ref, decl_ty_ref);
}

/**
 * Product-mega C face for array→slice init coerce.
 * Thin → typeck_coerce_init_slice_from_array.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_slice_from_array_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                       int32_t decl_kind) {
  return typeck_coerce_init_slice_from_array(arena, init_ref, decl_ty_ref, decl_kind);
}

/**
 * Product-mega C face for let/const init coerce dispatcher.
 * Thin → typeck_coerce_init_expr_to_decl (includes resolved_alias + bool→int
 * + arr_c -1 hard fail + wave231 struct_lit). G.7: typeck authority.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_expr_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t init_ref, int32_t decl_ty_ref) {
  return typeck_coerce_init_expr_to_decl(module, arena, init_ref, decl_ty_ref);
}

/**
 * Classify an ExprKind ordinal as any assignment kind (plain or compound).
 *
 * Why: check_block block-final-expr inference must distinguish assign-family
 * expressions from value expressions to route left/right coercion and lval
 * store. A single predicate avoids scattering kind_ord range checks across
 * the check_block path. Matches typeck.x check_block assign-kind gate.
 *
 * Invariant: returns 1 for EXPR_ASSIGN and EXPR_ADD_ASSIGN..EXPR_SHR_ASSIGN
 * inclusive, 0 otherwise (including invalid kind_ord).
 *
 * Asm/Perf: O(1) — two comparisons. Cold path — called per block-final
 * expr in pipeline_typeck_check_block_one_region_c (glue.c:15308).
 *
 * PLATFORM: SHARED — kind_ord classification is platform-independent.
 *
 * wave1065 G.7: migrated from glue.c:14135 (body 6 LOC). Static
 * (non-extern): same-TU visibility — coerce_init.c #include at L14126 <
 * def L14135 < sole callsite glue.c:15308. Dependencies: ast_ExprKind_*
 * enum (global); no other deps.
 */
static int32_t pipeline_typeck_expr_is_any_assign_kind_c(int32_t kind_ord) {
  if (kind_ord == (int32_t)ast_ExprKind_EXPR_ASSIGN)
    return 1;
  if (kind_ord >= (int32_t)ast_ExprKind_EXPR_ADD_ASSIGN && kind_ord <= (int32_t)ast_ExprKind_EXPR_SHR_ASSIGN)
    return 1;
  return 0;
}

/**
 * Product-mega C face for f32→f64 IEEE float widen gate.
 * Thin → typeck_float_widen_ok (wave229 pure leave).
 * Callers: method_call arg assignable, pure maybe_promote, residual faces.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_float_widen_ok_c(int32_t dest_kind, int32_t src_kind) {
  return typeck_float_widen_ok(dest_kind, src_kind);
}

/*
 * wave230 G.7 pure leave: integer_widen dual bodies retired → typeck_x.o.
 * Product/residual C faces keep historical names; live authority is typeck.
 * PLATFORM: SHARED.
 */

/**
 * Product-mega C face: first-class integer widen matrix.
 * Thin → typeck_integer_widen_ok.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_integer_widen_ok_c(int32_t dest_kind, int32_t src_kind) {
  return typeck_integer_widen_ok(dest_kind, src_kind) ? 1 : 0;
}

/**
 * Product-mega C face: refs-based integer widen (first-class + NAMED i8/i16/u16).
 * Thin → typeck_integer_widen_ok_refs.
 * Callers: residual method_call arg assignable (same-TU).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref,
                                                int32_t src_ref) {
  return typeck_integer_widen_ok_refs(arena, dest_ref, src_ref) ? 1 : 0;
}

/**
 * Type alias chain resolver: NAMED → target ref, depth-limited recursion.
 *
 * Why: typeck type_refs_equal must resolve type aliases before comparing.
 * A NAMED type `Foo` may alias to another type `Bar` or a compound. This
 * resolver walks the module's alias table, matching by name, and recurses
 * into the target ref (depth-limited to 32 to prevent infinite loops).
 * Matches typeck.x::resolve_type_alias_ref_impl.
 *
 * Invariant: returns type_ref unchanged for NULL arena, null ref, depth > 32,
 * no module, no aliases, or non-NAMED kind. For NAMED types matching an alias,
 * returns the resolved target ref (recursively). Returns type_ref if target
 * is invalid (<=0).
 *
 * Asm/Perf: O(n_aliases × name_len) per level, depth ≤ 32. Cold path — called
 * in pipeline_typeck_resolve_type_alias_ref_c (glue.c:10145, via fwd decl).
 *
 * PLATFORM: SHARED — alias resolution is platform-independent.
 *
 * wave1083 G.7: migrated from glue.c:10148 (body 36 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10141 (before callsite in
 * resolve_type_alias_ref_c) < coerce_init.c #include at L14126 < def EOF.
 * Recursive self-call is within this def (same file). Dependencies:
 * ast_ref_is_null (global) / pipeline_module_num_type_aliases_at (extern,
 * glue.c:10135) / pipeline_type_kind_ord_at (extern) /
 * pipeline_type_named_name_into (extern) /
 * pipeline_module_type_alias_name_len (extern, glue.c:10136) /
 * pipeline_module_type_alias_name_byte_at (extern, glue.c:10137) /
 * pipeline_module_type_alias_target_ref (extern, glue.c:10138).
 */
static int32_t pipeline_typeck_resolve_type_alias_ref_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                             int32_t type_ref, int32_t depth) {
  int32_t kind;
  uint8_t nm[128];
  int32_t nlen;
  int32_t i;
  int32_t alen;
  int32_t j;
  int32_t tgt;

  if (!arena || ast_ref_is_null(type_ref) || depth > 32)
    return type_ref;
  if (!module || pipeline_module_num_type_aliases_at(module) <= 0)
    return type_ref;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if (kind != (int32_t)ast_TypeKind_TYPE_NAMED)
    return type_ref;
  nlen = pipeline_type_named_name_into(arena, type_ref, nm);
  if (nlen <= 0)
    return type_ref;
  for (i = 0; i < pipeline_module_num_type_aliases_at(module); i++) {
    alen = pipeline_module_type_alias_name_len(module, i);
    if (alen != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_type_alias_name_byte_at(module, i, j) != nm[j])
        break;
    }
    if (j < nlen)
      continue;
    tgt = pipeline_module_type_alias_target_ref(module, i);
    if (tgt <= 0)
      return type_ref;
    return pipeline_typeck_resolve_type_alias_ref_impl_c(module, arena, tgt, depth + 1);
  }
  return type_ref;
}

/* ============================================================
 * wave230 G.7 pure leave: type_refs_equal / type_ref_is_bool /
 * expr_type_ref public C faces thin → typeck_x.o. Alias peel
 * (resolve_type_alias_ref_c) stays residual (active_module).
 * PLATFORM: SHARED.
 */

/**
 * NAMED type_refs_equal public face.
 * Thin → typeck_type_refs_equal_named.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_refs_equal_named_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  return typeck_type_refs_equal_named(arena, a, b) ? 1 : 0;
}

/**
 * resolve_type_alias_ref public wrapper: residual active_module peel.
 * typeck type_refs_equal and residual faces still call this C authority.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return pipeline_typeck_resolve_type_alias_ref_impl_c(pipeline_typeck_active_module_c(), arena, type_ref, 0);
}

/**
 * type_refs_equal_impl public face.
 * Thin → typeck_type_refs_equal_impl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_refs_equal_impl_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  return typeck_type_refs_equal_impl(arena, a, b) ? 1 : 0;
}

/**
 * type_refs_equal public C face (historical name for codegen/typeck U).
 * Thin → typeck_type_refs_equal (alias peel + compound walk in typeck_x.o).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  return typeck_type_refs_equal(arena, a, b) ? 1 : 0;
}

/**
 * Compound type comparison when kind is already known equal.
 * Thin → typeck_type_refs_equal_same_kind.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                    int32_t kind_ord) {
  return typeck_type_refs_equal_same_kind(arena, a, b, kind_ord) ? 1 : 0;
}

/**
 * type_ref_is_bool internal face.
 * Thin → typeck_type_ref_is_bool_impl.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_ref_is_bool_impl_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return typeck_type_ref_is_bool_impl(arena, type_ref) ? 1 : 0;
}

/**
 * type_ref_is_bool public face.
 * Thin → typeck_type_ref_is_bool.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_type_ref_is_bool_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return typeck_type_ref_is_bool(arena, type_ref) ? 1 : 0;
}

/**
 * expr_type_ref public face (impl was pure resolved_type_ref read).
 * Thin → typeck_expr_type_ref (bounds + resolved_type_ref).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_expr_type_ref_impl_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return typeck_expr_type_ref(arena, expr_ref);
}

/**
 * expr_type_ref public face.
 * Thin → typeck_expr_type_ref.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_expr_type_ref_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return typeck_expr_type_ref(arena, expr_ref);
}

/*
 * wave229 G.7: ret coerce cluster thin → typeck.x (wave1165 bodies retired).
 * Faces kept for residual/seed C ABI names; live authority is typeck_x.o.
 * PLATFORM: SHARED.
 */

/**
 * Product-mega C face: return operand matches expected return type.
 * Thin → typeck_return_operand_matches (bool as i32 on C ABI).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_return_operand_matches_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref) {
  return typeck_return_operand_matches(arena, op_ref, expect_ref);
}

/**
 * Product-mega C face: u8/usize → i32 return stamp.
 * Thin → typeck_ret_coerce_integral_to_expect_i32.
 * PLATFORM: SHARED.
 */
void pipeline_typeck_ret_coerce_integral_to_expect_i32_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                         int32_t expect_ref) {
  typeck_ret_coerce_integral_to_expect_i32(arena, op_ref, expect_ref);
}

/**
 * Product-mega C face: integer widen stamp on return operand.
 * Thin → typeck_ret_coerce_integral_widen.
 * PLATFORM: SHARED.
 */
void pipeline_typeck_ret_coerce_integral_widen_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref) {
  typeck_ret_coerce_integral_widen(arena, op_ref, expect_ref);
}

/* wave1172 G.7: pipeline_typeck_check_expr_int_lit_c migrated from
 * pipeline_glue.c L3047. Colocated with coerce_init domain — int literal
 * type resolution (i32 vs i64) is the entry point for literal coerce.
 * No glue.c callsites (sole caller is typeck_gen.c seed).
 * Dependencies: glue_arena_expr_at_ref (static, glue.c L2437 < coerce_init.c
 * #include L8661) + pipeline_type_ensure_by_kind_ord (fwd decl glue.c L769).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Resolve default type for EXPR_LIT: i32 when |v| fits, else i64.
 * Why: typeck_gen seed and typeck.x share this to avoid seed drift where
 *      large integer literals would be mis-inferred as i32.
 * Contract: no-op when arena null, expr_ref out of range, or resolved_type_ref
 *           already set. Keyword `null` (EXPR_LIT 0 with var_name="null") is
 *           skipped — only TYPE_PTR coerce (typeck.x) may retype it.
 * Dependencies: glue_arena_expr_at_ref (static, glue.c) +
 *               pipeline_type_ensure_by_kind_ord (extern, glue.c L3238).
 * PLATFORM: SHARED — freestanding+host int literal type resolution.
 */
int32_t pipeline_typeck_check_expr_int_lit_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  struct ast_Expr *ex;
  int64_t v;
  int32_t ty;

  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  ex = glue_arena_expr_at_ref(arena, expr_ref);
  if (!ex || ex->resolved_type_ref != 0)
    return 0;
  /*
   * wave670 Cap residual: keyword `null` is EXPR_LIT 0 tagged var_name="null".
   * Do not default-stamp as i32 — only TYPE_PTR coerce (typeck.x) may retype it.
   * Bare INT 0 still stamps i32/i64. PLATFORM: SHARED freestanding+host.
   */
  if (ex->int_val == 0 && ex->var_name_len == 4 &&
      ex->var_name[0] == (uint8_t)'n' && ex->var_name[1] == (uint8_t)'u' &&
      ex->var_name[2] == (uint8_t)'l' && ex->var_name[3] == (uint8_t)'l')
    return 0;
  v = ex->int_val;
  if (v > (int64_t)INT32_MAX || v < (int64_t)INT32_MIN)
    ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I64);
  else
    ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  if (ty != 0)
    ex->resolved_type_ref = ty;
  return 0;
}

/* wave1178 G.7: pipeline_expr_typeck_set_float_bits_from_val migrated from
 * pipeline_glue.c L3146-3157. Colocated with coerce_init domain — float bits
 * computation is the float-literal counterpart to int_lit check above (both
 * are typeck X-emit literal helpers that avoid X struct field writes during
 * self-host bootstrap).
 *
 * No glue.c callsites (sole caller is typeck_gen.c seed via extern).
 * Dependencies: glue_arena_expr_at_ref (static, glue.c L2340 < coerce_init.c
 * #include L8188) + typeck_float64_bits_lo/hi (extern, defined in typeck
 * module).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Recompute and write float_bits_lo/hi from float_val.
 * Why: typeck.x EXPR_FLOAT_LIT X-emit must write IEEE bits via C helper to
 *      avoid X Expr struct field assignment typeck failures during self-host
 *      bootstrap.
 * Contract: no-op when arena null, expr_ref out of range, or expr ptr null.
 */
void pipeline_expr_typeck_set_float_bits_from_val(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->float_bits_lo = typeck_float64_bits_lo(ex->float_val);
  ex->float_bits_hi = typeck_float64_bits_hi(ex->float_val);
}

