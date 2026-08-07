/**
 * pipeline_typeck_coerce_init.c — typeck coerce-init domain Cap residual thin
 * (BC 8.3.1 wave233 pure leave + wave230–227).
 *
 * wave233 G.7 pure leave: int_binop + resolve_alias + int_lit dual bodies
 * retired → typeck_coerce_init_int_binop_to_decl /
 * typeck_resolve_type_alias_ref / typeck_check_expr_int_lit. Residual faces
 * thin only (no second authority). type_refs_equal peels via typeck alias.
 * wave230: type_refs_equal cluster + integer_widen + bool + expr_type_ref.
 * wave229: float_widen + ret_coerce → typeck twins.
 * wave227: lit/float/enum/named_call/array_vector/vector_binop/slice/expr_to_decl.
 * Cap residual keeps only:
 *   1. Thin product faces → typeck_x.o (all coerce-init + ret_coerce +
 *      float_widen + type_refs + integer_widen + bool + expr_type_ref +
 *      struct_lit + int_binop + resolve_alias + int_lit)
 *   2. float_bits residual (typeck float_lit still uses C helper)
 *   3. expr_is_any_assign_kind static (mega dispatch helper)
 *
 * Dual-export ban: do NOT re-open second lit/float/enum/array/vector/slice/
 * ret_coerce/float_widen/type_refs/integer_widen/struct_lit/int_binop/
 * resolve_alias/int_lit bodies here; typeck.x is single authority.
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

/* wave233: live int_binop / resolve_alias / int_lit authority in typeck_x.o. */
extern int32_t typeck_coerce_init_int_binop_to_decl(struct ast_ASTArena *arena, int32_t init_ref,
                                                    int32_t decl_ty_ref, int32_t decl_kind,
                                                    int32_t init_kind);
extern int32_t typeck_resolve_type_alias_ref(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t typeck_check_expr_int_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                         int32_t return_type_ref);

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
 * Product-mega C face for int/float arithmetic / EXPR_NEG init coerce.
 * Thin → typeck_coerce_init_int_binop_to_decl (wave233 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  return typeck_coerce_init_int_binop_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind);
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

/* ============================================================
 * wave230/wave233 G.7 pure leave: type_refs_equal / type_ref_is_bool /
 * expr_type_ref / resolve_alias public C faces thin → typeck_x.o.
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
 * resolve_type_alias_ref public C face.
 * Thin → typeck_resolve_type_alias_ref (wave233 pure leave: active_module +
 * typeck_resolve_type_alias_ref_local). typeck type_refs_equal peels via the
 * typeck export directly; residual callers keep this historical C name.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return typeck_resolve_type_alias_ref(arena, type_ref);
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

/**
 * Product-mega C face for EXPR_LIT default i32/i64 stamp.
 * Thin → typeck_check_expr_int_lit (wave233 pure leave; return_type_ref=0
 * skips null→ptr coerce; stamp path only). PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_int_lit_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return typeck_check_expr_int_lit(arena, expr_ref, 0);
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

