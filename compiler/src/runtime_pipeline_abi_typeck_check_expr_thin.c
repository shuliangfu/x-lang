/*
 * Thin pure: wave286 pipeline_typeck_check_expr Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE286_TYPECK_CHECK_EXPR_ALWAYS (dispatch check_expr_*_c + match subject BSS
 * + repr_compatible / extern_unsafe). Cold method_call dual stays seed-only
 * under !FROM_X. XLANG_WEAK check_expr_impl{,_mega} kept so typeck_x.o overrides.
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS:
 *   g_w286_typeck_match_subject_ty / g_w286_typeck_match_subject_mod.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc typeck_check_expr Cap residual leave.
 */

/* XLANG_PABI_TYPECK_CHECK_EXPR_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

#include <stdarg.h>

/* Debug-only trace; seed mega uses Cap xlang_vfdprintf. Thin uses stderr. */
static void pabi_trace(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  (void)vfprintf(stderr, fmt, ap);
  va_end(ap);
}


#ifndef XLANG_WEAK
#if defined(__GNUC__) || defined(__clang__)
#define XLANG_WEAK __attribute__((weak))
#else
#define XLANG_WEAK
#endif
#endif

/* ExprKind / TypeKind product ordinals (LE shared with typeck.x / glue). */
#ifndef W286_EXPR_LIT
#define W286_EXPR_LIT 0
#define W286_EXPR_FLOAT_LIT 1
#define W286_EXPR_BOOL_LIT 2
#define W286_EXPR_VAR 3
#define W286_EXPR_ADD 4
#define W286_EXPR_LOGOR 21
#define W286_EXPR_NEG 22
#define W286_EXPR_BITNOT 23
#define W286_EXPR_LOGNOT 24
#define W286_EXPR_IF 25
#define W286_EXPR_BLOCK 26
#define W286_EXPR_TERNARY 27
#define W286_EXPR_BREAK 39
#define W286_EXPR_CONTINUE 40
#define W286_EXPR_RETURN 41
#define W286_EXPR_PANIC 42
#define W286_EXPR_MATCH 43
#define W286_EXPR_FIELD_ACCESS 44
#define W286_EXPR_STRUCT_LIT 45
#define W286_EXPR_INDEX 47
#define W286_EXPR_CALL 48
#define W286_EXPR_METHOD_CALL 49
#define W286_EXPR_ENUM_VARIANT 50
#define W286_EXPR_ADDR_OF 51
#define W286_EXPR_DEREF 52
#define W286_EXPR_AS 54
#define W286_EXPR_TRY_PROPAGATE 58
#define W286_EXPR_C_TRY_PROPAGATE 57
#define W286_EXPR_STRING_LIT 59
#define W286_TYPE_PTR 9
#define W286_TYPE_ARRAY 10
#define W286_TYPE_SLICE 11
#endif

/* Arena LE: num_exprs @ offset 4 (LP64 ASTArena header). */
static int32_t w286_arena_num_exprs(void *a) {
  if (!a)
    return 0;
  return *(int32_t *)((uint8_t *)a + 4);
}

static int32_t w286_ref_is_null(int32_t ref) { return ref == 0; }

/* Prefer void* faces (match pure / earlier ALWAYS blocks; dual-decl safe). */
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t expr_ref);
extern void pipeline_expr_set_resolved_type_ref(void *a, int32_t expr_ref, int32_t ty);
extern int32_t pipeline_type_kind_ord_at(void *a, int32_t type_ref);
extern int32_t pipeline_arena_num_types(void *a);
extern char *link_abi_getenv(const char *name);
/* check_expr_impl_mega: WEAK cold face below; impl_c calls it for mega fallback. */
XLANG_WEAK int32_t check_expr_impl_mega(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);

extern int32_t pipeline_typeck_expr_is_any_assign_kind_c(int32_t kind);
extern int32_t pipeline_typeck_check_struct_stack_escape_assign_c(void *module, void *arena, int32_t expr_ref,
                                                                  int32_t left_ref, int32_t right_ref, void *ctx);
extern int32_t pipeline_typeck_check_scope_borrow_assign_c(void *module, void *arena, int32_t expr_ref,
                                                           int32_t left_ref, int32_t right_ref, void *ctx);
extern int32_t pipeline_typeck_check_allocator_region_assign_c(void *module, void *arena, int32_t expr_ref,
                                                               int32_t left_ref, void *ctx);
extern int32_t pipeline_typeck_check_expr_assign_c(void *module, void *arena, int32_t expr_ref,
                                                   int32_t return_type_ref, void *ctx);
extern int32_t pipeline_typeck_check_scope_borrow_return_c(void *module, void *arena, int32_t expr_ref,
                                                           int32_t op_ref, int32_t return_type_ref, void *ctx);
extern int32_t pipeline_typeck_check_allocator_region_return_c(void *arena, int32_t expr_ref, int32_t return_type_ref);
extern int32_t pipeline_typeck_check_return_slice_region_in_scope_c(void *arena, int32_t expr_ref,
                                                                    int32_t return_type_ref, void *ctx);
extern int32_t pipeline_typeck_check_return_slice_region_c(void *arena, int32_t expr_ref, int32_t op_ref,
                                                           int32_t return_type_ref);
extern int32_t pipeline_typeck_check_call_struct_stack_escape_c(void *module, void *arena, int32_t expr_ref, void *ctx);
extern int32_t pipeline_typeck_check_expr_method_call_c(void *module, void *arena, int32_t expr_ref,
                                                        int32_t return_type_ref, void *ctx);

extern int32_t typeck_check_expr_panic(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_unary(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_addr_of(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_index(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_deref(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_var(void *module, void *arena, int32_t expr_ref, void *ctx);
extern int32_t typeck_check_expr_return(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_match(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_try_propagate(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                                void *ctx);
extern int32_t typeck_check_expr_call(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_field_access(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                               void *ctx);
extern int32_t typeck_check_expr_binop(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_as(void *module, void *arena, int32_t expr_ref, void *ctx);
extern int32_t typeck_check_expr_struct_lit(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                             void *ctx);
extern int32_t typeck_check_expr_float_lit(void *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_int_lit(void *arena, int32_t expr_ref, int32_t return_type_ref);
extern int32_t typeck_check_expr_bool_lit(void *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_break_continue(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                                 void *ctx);
extern int32_t typeck_check_expr_enum_variant(void *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_if_ternary(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                             void *ctx);
extern int32_t typeck_check_expr_block(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
extern int32_t typeck_check_expr_impl_mega(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                            void *ctx);
extern int32_t typeck_ensure_u8_type_ref(void *arena);
extern int32_t typeck_find_or_alloc_ptr_type_ref(void *arena, int32_t elem_ref);
extern int32_t typeck_match_subject_field_type(void *module, void *arena, uint8_t *name, int32_t name_len);
extern int32_t typeck_call_arg_repr_compatible_ok(void *module, void *arena, int32_t param_ref, int32_t arg_ref);
extern int32_t typeck_check_extern_call_unsafe_boundary(void *module, void *arena, int32_t expr_ref, void *ctx);


/* Forward decls for same-TU Cap faces (call before def). */
int32_t pipeline_typeck_match_set_subject_c(void *module, int32_t ty);
void pipeline_typeck_match_clear_subject_c(void);
int32_t pipeline_typeck_match_subject_ty_get_c(void);
int32_t pipeline_typeck_match_subject_field_type_c(void *module, void *arena, uint8_t *name, int32_t name_len);
int32_t pipeline_typeck_check_expr_panic_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_match_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_return_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_unary_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_addr_of_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_deref_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_index_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_var_c(void *module, void *arena, int32_t expr_ref, void *ctx);
int32_t pipeline_typeck_check_expr_try_propagate_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_call_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(void *module, void *arena, int32_t param_ref, int32_t arg_ref);
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(void *module, void *arena, int32_t expr_ref, void *ctx);
int32_t pipeline_typeck_check_expr_impl_mega_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_impl_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);
int32_t pipeline_typeck_check_expr_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx);

/* --- match subject BSS (wave703 + wave231 nested save/restore) --- */
static int32_t g_w286_typeck_match_subject_ty = 0;
static void *g_w286_typeck_match_subject_mod = 0;

/**
 * wave703: set match subject type for field-bind VAR resolve.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_match_set_subject_c(void *module, int32_t ty) {
  g_w286_typeck_match_subject_mod = module;
  g_w286_typeck_match_subject_ty = ty;
  return 0;
}

/**
 * wave703: clear match subject field-bind context.
 * PLATFORM: SHARED.
 */
void pipeline_typeck_match_clear_subject_c(void) {
  g_w286_typeck_match_subject_mod = 0;
  g_w286_typeck_match_subject_ty = 0;
}

/**
 * wave231: read subject type_ref for nested match save/restore (typeck.x match).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_match_subject_ty_get_c(void) {
  return g_w286_typeck_match_subject_ty;
}

/**
 * wave231: read subject module for nested match save/restore (typeck.x match).
 * PLATFORM: SHARED.
 */
void *pipeline_typeck_match_subject_mod_get_c(void) {
  return g_w286_typeck_match_subject_mod;
}

/**
 * Product-mega C face: match subject field-bind type lookup.
 * Thin → typeck_match_subject_field_type (wave234 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_match_subject_field_type_c(void *module, void *arena, uint8_t *name, int32_t name_len) {
  return typeck_match_subject_field_type(module, arena, name, name_len);
}

/* --- thin product faces → typeck_x.o --- */

/**
 * Product-mega C face for EXPR_PANIC. Thin → typeck_check_expr_panic.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_panic_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                           void *ctx) {
  return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_MATCH. Thin → typeck_check_expr_match.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_match_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                           void *ctx) {
  return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_RETURN. Thin → typeck_check_expr_return.
 * Mega arm still runs escape/region gates before this face.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_return_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                             void *ctx) {
  return typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for NEG/BITNOT/LOGNOT. Thin → typeck_check_expr_unary.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_unary_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                           void *ctx) {
  return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_ADDR_OF. Thin → typeck_check_expr_addr_of.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_addr_of_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                             void *ctx) {
  return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_DEREF. Thin → typeck_check_expr_deref.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_deref_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                           void *ctx) {
  return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_INDEX. Thin → typeck_check_expr_index.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_index_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                           void *ctx) {
  return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_VAR. Thin → typeck_check_expr_var.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_var_c(void *module, void *arena, int32_t expr_ref, void *ctx) {
  return typeck_check_expr_var(module, arena, expr_ref, ctx);
}

/**
 * Product-mega C face for EXPR_TRY_PROPAGATE. Thin → typeck_check_expr_try_propagate.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_try_propagate_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                                   void *ctx) {
  return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_CALL. Thin → typeck_check_expr_call.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_call_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                          void *ctx) {
  return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face: #[repr(compatible)] *StructA → *StructB gate.
 * Thin → typeck_call_arg_repr_compatible_ok.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(void *module, void *arena, int32_t param_ref, int32_t arg_ref) {
  return typeck_call_arg_repr_compatible_ok(module, arena, param_ref, arg_ref);
}

/**
 * Product-mega C face: LANG-007 S0 extern call must be inside unsafe { }.
 * Thin → typeck_check_extern_call_unsafe_boundary.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(void *module, void *arena, int32_t expr_ref, void *ctx) {
  return typeck_check_extern_call_unsafe_boundary(module, arena, expr_ref, ctx);
}

/**
 * typeck.x::check_expr_impl_mega C delegate: ExprKind dispatch + escape gates.
 * PLATFORM: SHARED — product path (seed typeck_check_expr_impl_mega → this face).
 */
int32_t pipeline_typeck_check_expr_impl_mega_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                                void *ctx) {
  int32_t kind;
  int32_t nexpr;

  nexpr = w286_arena_num_exprs(arena);
  if (!arena || expr_ref <= 0 || expr_ref > nexpr)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (pipeline_typeck_expr_is_any_assign_kind_c(kind)) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t rc;
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    /* MEM-C1/WPO: escape diagnostics before assign type match. */
    if (pipeline_typeck_check_struct_stack_escape_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_scope_borrow_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_allocator_region_assign_c(module, arena, expr_ref, left_ref, ctx) != 0)
      return -1;
    rc = pipeline_typeck_check_expr_assign_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return 0;
  }
  if (kind == W286_EXPR_RETURN) {
    int32_t op_ref;
    int32_t rc;
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    /* MEM-C1/M-3: return escape diagnostics before return type match. */
    if (pipeline_typeck_check_scope_borrow_return_c(module, arena, expr_ref, op_ref, return_type_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_allocator_region_return_c(arena, expr_ref, return_type_ref) != 0)
      return -1;
    if (pipeline_typeck_check_return_slice_region_in_scope_c(arena, expr_ref, return_type_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0)
      return -1;
    rc = pipeline_typeck_check_expr_return_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return 0;
  }
  if (kind == W286_EXPR_PANIC)
    return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_MATCH)
    return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_FIELD_ACCESS)
    return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_INDEX)
    return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_CALL) {
    int32_t rc = pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return pipeline_typeck_check_call_struct_stack_escape_c(module, arena, expr_ref, ctx);
  }
  if (kind == W286_EXPR_METHOD_CALL)
    return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind >= W286_EXPR_ADD && kind <= W286_EXPR_LOGOR)
    return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_NEG || kind == W286_EXPR_BITNOT || kind == W286_EXPR_LOGNOT)
    return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_ADDR_OF)
    return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_DEREF)
    return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_VAR)
    return typeck_check_expr_var(module, arena, expr_ref, ctx);
  if (kind == W286_EXPR_AS)
    return typeck_check_expr_as(module, arena, expr_ref, ctx);
  if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE)
    return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_STRUCT_LIT)
    return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
  return 0;
}

/**
 * typeck.x::check_expr_impl C delegate: simple kinds + mega fallback.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_impl_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                          void *ctx) {
  int32_t kind;
  int32_t nexpr;

  nexpr = w286_arena_num_exprs(arena);
  if (!arena || expr_ref <= 0 || expr_ref > nexpr)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == W286_EXPR_FLOAT_LIT)
    return typeck_check_expr_float_lit(arena, expr_ref);
  if (kind == W286_EXPR_LIT)
    return typeck_check_expr_int_lit(arena, expr_ref, return_type_ref);
  if (kind == W286_EXPR_BOOL_LIT)
    return typeck_check_expr_bool_lit(arena, expr_ref);
  /* STRING_LIT: only adopt expected PTR/ARRAY/SLICE; else default *u8. */
  if (kind == W286_EXPR_STRING_LIT) {
    int32_t u8r;
    int32_t slice_u8;
    int32_t exp_kind;
    int32_t ntypes = pipeline_arena_num_types(arena);
    if (!w286_ref_is_null(return_type_ref) && return_type_ref > 0 && return_type_ref <= ntypes) {
      exp_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (exp_kind == W286_TYPE_PTR || exp_kind == W286_TYPE_ARRAY || exp_kind == W286_TYPE_SLICE) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
        return 0;
      }
    }
    u8r = typeck_ensure_u8_type_ref(arena);
    if (w286_ref_is_null(u8r))
      return -1;
    slice_u8 = typeck_find_or_alloc_ptr_type_ref(arena, u8r);
    if (!w286_ref_is_null(slice_u8))
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8);
    return 0;
  }
  if (kind == W286_EXPR_BREAK || kind == W286_EXPR_CONTINUE)
    return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_ENUM_VARIANT)
    return typeck_check_expr_enum_variant(arena, expr_ref);
  if (kind == W286_EXPR_IF || kind == W286_EXPR_TERNARY)
    return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_BLOCK)
    return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == W286_EXPR_MATCH)
    return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
  return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * typeck.x::check_expr C delegate: bounds + try_propagate fast-path + impl_c.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_c(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx) {
  int32_t rc;
  int32_t kind;
  int32_t nexpr;

  if (w286_ref_is_null(expr_ref))
    return 0;
  nexpr = w286_arena_num_exprs(arena);
  if (expr_ref <= 0 || !arena || expr_ref > nexpr)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE)
    return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
  rc = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
  if (rc != 0 && link_abi_getenv("XLANG_DEBUG_PIPE"))
    pabi_trace( "xlang: [XLANG_DEBUG_PIPE] check_expr fail func=%d expr=%d kind=%d block=%d\n",
            -1, (int)expr_ref, (int)kind, -1);
  (void)ctx;
  return rc;
}

/* Cold WEAK faces — typeck_x.o provides strong check_expr_impl{,_mega}. */
XLANG_WEAK int32_t check_expr_impl_mega(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref,
                                        void *ctx) {
  return typeck_check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}

XLANG_WEAK int32_t check_expr_impl(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx) {
  return pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
}

/* XLANG_PABI_TYPECK_CHECK_EXPR_THIN_END */
