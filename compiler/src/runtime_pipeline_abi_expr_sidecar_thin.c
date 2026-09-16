/*
 * Thin pure: wave278 ast_pool_expr_sidecar Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE278_EXPR_SIDECAR_DOMAIN_ALWAYS (call/method/match/struct_lit/array_lit +
 * type_arg pools + Expr field Cap accessors + rename shims).
 *
 * Independent C thin (Darwin additive-leaf rule). No file-local BSS.
 * GrowVec via wave271; sidecar via wave275; block faces via wave277 thin;
 * expr_ptr via pure/cold. Thin-local W277_Block mirror for glue_fill only.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc expr_sidecar Cap residual leave.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

/**
 * Thin-local trace sink (seed pabi_trace uses xlang_vfdprintf; no-op here).
 * PLATFORM: SHARED — debug-only; omit I/O from Cap residual leaf.
 */
static void pabi_trace(const char *fmt, ...) {
  (void)fmt;
}

/* Thin-local GrowVec (match wave271 / seed FROM_X layout). */
#ifndef W278_NEED_GROWVEC
#define W278_NEED_GROWVEC 1
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;
#endif

/* Thin-local W277 Arena/Block mirrors (seed same-TU statics from wave277).
 * LAYOUT: match WAVE277_BLOCK_DOMAIN_ALWAYS / block_domain_thin.c. */
typedef struct {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
} W277_Arena;

typedef struct {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
} W277_Block;

extern void *pipeline_arena_block_ptr(void *a, int32_t ref);

/** Map arena void* → W277_Arena* (num_blocks @+8). */
static W277_Arena *w277_as_arena(void *a) { return (W277_Arena *)a; }

/** Block row via product pipeline_arena_block_ptr. */
static W277_Block *w277_block_at(void *a, int32_t br) {
  return (W277_Block *)pipeline_arena_block_ptr(a, br);
}

/* Forward decl: defined later in this TU; glue_fill walks call before def. */
extern int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t er);

/* Wave277 Cap faces (block_domain_thin / seed ALWAYS) — glue_fill walk. */
extern int32_t ast_ast_block_num_expr_stmts(void *a, int32_t br);
extern int32_t pipeline_block_expr_stmt_ref(void *a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_final_expr_ref(void *a, int32_t br);
extern int32_t pipeline_block_while_body_ref(void *a, int32_t br, int32_t i);
extern int32_t pipeline_block_for_body_ref(void *a, int32_t br, int32_t i);
extern int32_t pipeline_block_if_then_body_ref(void *a, int32_t br, int32_t i);
extern int32_t pipeline_block_if_else_body_ref(void *a, int32_t br, int32_t i);
extern int32_t pipeline_block_region_body_ref(void *a, int32_t br, int32_t i);

/* Product LE sizeof(ast_Expr)=1224 — match pipeline_gen / pure Cap (var_name[256]). */
typedef struct W278_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
} W278_Expr;

typedef struct {
  int32_t result_ref;
  int32_t is_wildcard;
  int32_t lit_val;
  int32_t is_enum_variant;
  int32_t variant_index;
  int32_t guard_ref;
} W278_MatchArm;

typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t init_ref;
} W278_StructLitField;

/* Full ArenaSidecar LE: W277 prefix through stmt_order + expr var-len pools. */
typedef struct {
  void *arena_key;
  int used;
  GrowVec types;
  GrowVec exprs;
  GrowVec blocks;
  GrowVec funcs;
  GrowVec consts;
  GrowVec lets;
  GrowVec ifs;
  GrowVec regions;
  GrowVec loops;
  GrowVec for_loops;
  GrowVec defer_block_refs;
  GrowVec labeled_stmts;
  GrowVec expr_stmt_refs;
  GrowVec stmt_order;
  GrowVec expr_call_arg_refs;
  GrowVec expr_call_type_arg_refs;
  GrowVec expr_call_type_arg_bases;
  GrowVec type_type_arg_refs;
  GrowVec type_type_arg_bases;
  GrowVec type_type_arg_counts;
  GrowVec expr_method_call_arg_refs;
  GrowVec expr_match_arms;
  GrowVec expr_struct_lit_fields;
  GrowVec expr_array_lit_elem_refs;
  GrowVec func_params;
} W278_Sidecar;

typedef struct {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
} W278_Arena;

static int32_t w278_num_exprs(void *a) {
  return a ? ((W278_Arena *)a)->num_exprs : 0;
}


/* ast_ExprKind ordinals — must match pipeline_gen / product Cap (G.7).
 * LIT=0 FLOAT=1 BOOL=2 VAR=3 … MATCH=43 FIELD_ACCESS=44 STRUCT_LIT=45
 * ARRAY_LIT=46 INDEX=47 CALL=48 METHOD_CALL=49 … STRING uses kind 59 in Cap. */
#ifndef ast_ExprKind_EXPR_LIT
#define ast_ExprKind_EXPR_LIT 0
#endif
#ifndef ast_ExprKind_EXPR_VAR
#define ast_ExprKind_EXPR_VAR 3
#endif
#ifndef ast_ExprKind_EXPR_FIELD_ACCESS
#define ast_ExprKind_EXPR_FIELD_ACCESS 44
#endif
#ifndef ast_ExprKind_EXPR_STRUCT_LIT
#define ast_ExprKind_EXPR_STRUCT_LIT 45
#endif
#ifndef ast_ExprKind_EXPR_CALL
#define ast_ExprKind_EXPR_CALL 48
#endif

extern void *arena_sidecar_get(void *key, int create);
extern void *grow_vec_at(GrowVec *v, int32_t idx);
extern int32_t grow_vec_push(GrowVec *v);
extern int grow_vec_ensure(GrowVec *v);
extern void *pipeline_arena_expr_ptr(void *a, int32_t ref);
extern char *link_abi_getenv(const char *name);
/* Pure-owned Cap faces used by thin prefix wrappers (not redefined here). */
extern int32_t pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_layout_offset(void *a, void *m, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_load_byte_sz(void *a, void *m, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_type_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_struct_lit_type_name_into(void *a, int32_t expr_ref, uint8_t *out64);
extern void pipeline_expr_struct_lit_type_name_set(void *a, int32_t expr_ref, uint8_t *name,
                                                   int32_t name_len);
extern int32_t pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref, int32_t field_ix);
extern int32_t pipeline_expr_struct_lit_field_store_sz(void *a, void *m, int32_t expr_ref, int32_t field_ix);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_module_func_param_type_ref_at(void *m, int32_t fi, int32_t pi);
extern int32_t pipeline_module_import_append_select_name(void *m, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t pipeline_type_elem_ref_at(void *a, int32_t type_ref);

static W278_Expr *w278_expr_ptr(void *a, int32_t ref) {
  return (W278_Expr *)pipeline_arena_expr_ptr(a, ref);
}

/* Local protos for the VAR block_ref backfill walker (strict -Wimplicit). */
extern int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_as_operand_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref(void *a, int32_t er);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t er);
extern int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t er, int32_t idx);
extern int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t er);
extern int32_t pipeline_expr_struct_lit_init_ref(void *a, int32_t er, int32_t j);
extern int32_t pipeline_expr_index_base_ref(void *a, int32_t er);
extern int32_t pipeline_expr_index_index_ref(void *a, int32_t er);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t er, int32_t idx);
extern int32_t pipeline_block_let_init_ref(void *a, int32_t br, int32_t li);
extern int32_t ast_ast_block_num_lets(void *a, int32_t br);
extern int32_t ast_ast_block_num_consts(void *a, int32_t br);
extern int32_t pipeline_block_const_init_ref(void *a, int32_t br, int32_t ci);

/**
 * PLATFORM: SHARED — parse-only dep prerun backfill: stamp block_ref on
 * VAR exprs (nested anywhere in statement / let-init / const-init expr
 * trees). The parser only stamps block-level statement exprs; typeck
 * stamps the rest, and parse-only deps skip typeck — so
 * glue_fill_var_types_from_params_for_func (which climbs
 * pipeline_expr_block_ref_at to the owning function) breaks on the first
 * hop and field-access load widths fall to the 8-byte default (i32
 * `s.length` drags padding garbage into address math; std.string
 * append_char SEGV). Stamps only exprs whose block_ref is still 0.
 */
static void glue_var_blk_walk_expr(void *a, int32_t er, int32_t blk) {
  int32_t ko;
  int32_t l;
  int32_t r;
  int32_t i;
  int32_t n;
  W278_Expr *ex;
  if (!a || er <= 0)
    return;
  ko = pipeline_expr_kind_ord_at(a, er);
  if (ko == 3) {
    ex = w278_expr_ptr(a, er);
    if (ex && ex->block_ref == 0)
      ex->block_ref = blk;
    return;
  }
  if ((ko >= 4 && ko <= 21) || (ko >= 28 && ko <= 38)) {
    /* 4..21 binop family; 28 ASSIGN + 29..38 compound assigns share the
     * binop left/right operand slots (LHS field bases live here). */
    glue_var_blk_walk_expr(a, pipeline_expr_binop_left_ref_at(a, er), blk);
    glue_var_blk_walk_expr(a, pipeline_expr_binop_right_ref_at(a, er), blk);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 50 || ko == 51) {
    glue_var_blk_walk_expr(a, pipeline_expr_unary_operand_ref_at(a, er), blk);
    return;
  }
  l = pipeline_expr_as_operand_ref_at(a, er);
  if (l > 0) {
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  if (ko == 44) {
    glue_var_blk_walk_expr(a, pipeline_expr_field_access_base_ref(a, er), blk);
    return;
  }
  if (ko == 46) {
    n = pipeline_expr_array_lit_num_elems_at(a, er);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_expr_array_lit_elem_ref(a, er, i), blk);
    return;
  }
  if (ko == 45) {
    n = pipeline_expr_struct_lit_num_fields(a, er);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_expr_struct_lit_init_ref(a, er, i), blk);
    return;
  }
  if (ko == 47) {
    glue_var_blk_walk_expr(a, pipeline_expr_index_base_ref(a, er), blk);
    glue_var_blk_walk_expr(a, pipeline_expr_index_index_ref(a, er), blk);
    return;
  }
  if (ko == 48 || ko == 49) {
    n = pipeline_expr_call_num_args_at(a, er);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_expr_call_arg_ref(a, er, i), blk);
    return;
  }
}

void glue_fill_var_block_refs_c(void *a, int32_t block_ref) {
  int32_t stack_blk[256];
  int32_t sp;
  int32_t cur;
  int32_t i;
  int32_t n;
  int32_t er;
  W277_Block *b;
  if (!a || block_ref <= 0)
    return;
  sp = 0;
  stack_blk[sp] = block_ref;
  sp++;
  while (sp > 0) {
    sp--;
    cur = stack_blk[sp];
    if (cur <= 0 || cur > w277_as_arena(a)->num_blocks)
      continue;
    b = w277_block_at(a, cur);
    if (!b)
      continue;
    n = ast_ast_block_num_expr_stmts(a, cur);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_block_expr_stmt_ref(a, cur, i), cur);
    er = ast_ast_block_final_expr_ref(a, cur);
    if (er > 0)
      glue_var_blk_walk_expr(a, er, cur);
    n = ast_ast_block_num_lets(a, cur);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_block_let_init_ref(a, cur, i), cur);
    n = ast_ast_block_num_consts(a, cur);
    for (i = 0; i < n; i++)
      glue_var_blk_walk_expr(a, pipeline_block_const_init_ref(a, cur, i), cur);
    for (i = 0; i < b->num_loops; i++) {
      int32_t wb = pipeline_block_while_body_ref(a, cur, i);
      if (wb > 0 && sp < 8192) { stack_blk[sp] = wb; sp++; }
    }
    for (i = 0; i < b->num_for_loops; i++) {
      int32_t fb = pipeline_block_for_body_ref(a, cur, i);
      if (fb > 0 && sp < 8192) { stack_blk[sp] = fb; sp++; }
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      int32_t tb = pipeline_block_if_then_body_ref(a, cur, i);
      if (tb > 0 && sp < 8192) { stack_blk[sp] = tb; sp++; }
      int32_t eb = pipeline_block_if_else_body_ref(a, cur, i);
      if (eb > 0 && sp < 8192) { stack_blk[sp] = eb; sp++; }
    }
    for (i = 0; i < b->num_regions; i++) {
      int32_t rgb = pipeline_block_region_body_ref(a, cur, i);
      if (rgb > 0 && sp < 8192) { stack_blk[sp] = rgb; sp++; }
    }
  }
}


static W278_MatchArm *expr_match_arm_at(void *a, int32_t expr_ref, int32_t arm_idx, int create) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arm_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->match_arm_base + arm_idx;
  if (create) {
    while (sc->expr_match_arms.len <= abs) {
      if (grow_vec_push(&sc->expr_match_arms) < 0)
        return NULL;
    }
  } else if (arm_idx >= ex->match_num_arms || abs >= sc->expr_match_arms.len) {
    return NULL;
  }
  return (W278_MatchArm *)grow_vec_at(&sc->expr_match_arms, abs);
}

static W278_StructLitField *expr_struct_lit_field_at(void *a, int32_t expr_ref, int32_t field_idx,
                                                     int create) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || field_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->struct_lit_field_base + field_idx;
  if (create) {
    while (sc->expr_struct_lit_fields.len <= abs) {
      if (grow_vec_push(&sc->expr_struct_lit_fields) < 0)
        return NULL;
    }
  } else if (field_idx >= ex->struct_lit_num_fields || abs >= sc->expr_struct_lit_fields.len) {
    return NULL;
  }
  return (W278_StructLitField *)grow_vec_at(&sc->expr_struct_lit_fields, abs);
}

static int32_t *expr_call_arg_slot(void *a, int32_t expr_ref, int32_t arg_idx, int create) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->call_num_args || abs >= sc->expr_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_call_arg_refs, abs);
}

static int32_t *expr_method_call_arg_slot(void *a, int32_t expr_ref, int32_t arg_idx, int create) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->method_call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_method_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_method_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->method_call_num_args || abs >= sc->expr_method_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_method_call_arg_refs, abs);
}

static int32_t *expr_array_lit_elem_slot(void *a, int32_t expr_ref, int32_t elem_idx, int create) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || elem_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->array_lit_elem_base + elem_idx;
  if (create) {
    while (sc->expr_array_lit_elem_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_array_lit_elem_refs) < 0)
        return NULL;
    }
  } else if (elem_idx >= ex->array_lit_num_elems || abs >= sc->expr_array_lit_elem_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_array_lit_elem_refs, abs);
}

/**
 * CALL 节点刚分配后调用：立即固定 call_arg_base，避免嵌套实参解析时内层 CALL 与外层未写入槽位重叠。
 */
void pipeline_expr_on_call_created(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  W278_Sidecar *sc;
  if (!a || expr_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return;
  ex->call_arg_base = (int32_t)sc->expr_call_arg_refs.len;
}

/**
 * 解析/append 前：grow 侧车池至 call_arg_base + call_num_args。
 * 权威调用序见 parser_asm_primary_slice：先 parse 完全部实参，再统一 append
 * （避免嵌套 CALL 与外层 call_arg 槽交错覆盖）。
 */
int32_t pipeline_expr_prepare_call_arg_slot(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  W278_Sidecar *sc;
  int32_t abs;
  if (!a || expr_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return -1;
  /* 兼容未调用 on_call_created 的旧路径：首个实参前 lazy 固定 base */
  if (ex->call_num_args == 0)
    pipeline_expr_on_call_created(a, expr_ref);
  abs = ex->call_arg_base + ex->call_num_args;
  while (sc->expr_call_arg_refs.len <= (size_t)abs) {
    if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
      return -1;
  }
  return 0;
}

int32_t pipeline_expr_append_call_arg(void *a, int32_t expr_ref, int32_t arg_ref) {
  W278_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (pipeline_expr_prepare_call_arg_slot(a, expr_ref) < 0)
    return -1;
  slot = expr_call_arg_slot(a, expr_ref, ex->call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->call_num_args++;
  return ex->call_num_args - 1;
}

int32_t pipeline_expr_call_arg_ref(void *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_call_num_args_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->call_num_args : 0;
}

int32_t pipeline_expr_call_num_type_args_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  return ex->call_num_type_args;
}

/**
 * wave452: ensure expr_call_type_arg_bases has a slot for expr_ref; return pointer to base cell.
 * Unset base is -1. PLATFORM: SHARED — G.7 with append/get type_arg APIs.
 */
static int32_t *expr_call_type_arg_base_cell(void *a, int32_t expr_ref, int create) {
  W278_Sidecar *sc;
  int32_t *cell;
  if (!a || expr_ref <= 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create && (size_t)expr_ref >= sc->expr_call_type_arg_bases.len)
    return NULL;
  while ((size_t)expr_ref >= sc->expr_call_type_arg_bases.len) {
    int32_t idx = grow_vec_push(&sc->expr_call_type_arg_bases);
    if (idx < 0)
      return NULL;
    cell = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_bases, idx);
    if (!cell)
      return NULL;
    *cell = -1;
  }
  return (int32_t *)grow_vec_at(&sc->expr_call_type_arg_bases, expr_ref);
}

/**
 * wave452: append one turbofish type-arg type_ref to CALL expr.
 * First append fixes base in sidecar; increments call_num_type_args.
 * Call after CALL node is created; may reset count if base was unset and count
 * was only a skip-count from legacy path — caller should set count via appends
 * or set call_num_type_args then fill slots. Here: append owns the count when
 * base was -1 (resets count to 0 then increments).
 *
 * @return 0 on success, -1 on failure.
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_append_call_type_arg(void *a, int32_t expr_ref, int32_t type_ref) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t *base_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || expr_ref <= 0 || type_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return -1;
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 1);
  if (!base_cell)
    return -1;
  if (*base_cell < 0) {
    *base_cell = (int32_t)sc->expr_call_type_arg_refs.len;
    ex->call_num_type_args = 0;
  }
  base = *base_cell;
  abs = base + ex->call_num_type_args;
  while (sc->expr_call_type_arg_refs.len <= (size_t)abs) {
    if (grow_vec_push(&sc->expr_call_type_arg_refs) < 0)
      return -1;
  }
  slot = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_refs, abs);
  if (!slot)
    return -1;
  *slot = type_ref;
  ex->call_num_type_args = ex->call_num_type_args + 1;
  return 0;
}

/**
 * wave452: type_ref of CALL turbofish type arg at index, or 0 if missing.
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_call_type_arg_ref_at(void *a, int32_t expr_ref, int32_t idx) {
  W278_Sidecar *sc;
  W278_Expr *ex;
  int32_t *base_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || expr_ref <= 0 || idx < 0)
    return 0;
  sc = arena_sidecar_get(a, 0);
  ex = w278_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return 0;
  if (idx >= ex->call_num_type_args)
    return 0;
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 0);
  if (!base_cell || *base_cell < 0)
    return 0;
  base = *base_cell;
  abs = base + idx;
  if (abs < 0 || (size_t)abs >= sc->expr_call_type_arg_refs.len)
    return 0;
  slot = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_refs, abs);
  return slot ? *slot : 0;
}

/**
 * wave467: ensure type_type_arg_bases/counts have a slot for type_ref.
 * PLATFORM: SHARED.
 */
static int32_t type_type_arg_ensure_meta(void *a, int32_t type_ref, int create,
                                        int32_t **out_base, int32_t **out_count) {
  W278_Sidecar *sc;
  int32_t *bcell;
  int32_t *ccell;
  if (!a || type_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return -1;
  if (!create && ((size_t)type_ref >= sc->type_type_arg_bases.len
                  || (size_t)type_ref >= sc->type_type_arg_counts.len))
    return -1;
  while ((size_t)type_ref >= sc->type_type_arg_bases.len) {
    int32_t idx = grow_vec_push(&sc->type_type_arg_bases);
    if (idx < 0)
      return -1;
    bcell = (int32_t *)grow_vec_at(&sc->type_type_arg_bases, idx);
    if (!bcell)
      return -1;
    *bcell = -1;
  }
  while ((size_t)type_ref >= sc->type_type_arg_counts.len) {
    int32_t idx = grow_vec_push(&sc->type_type_arg_counts);
    if (idx < 0)
      return -1;
    ccell = (int32_t *)grow_vec_at(&sc->type_type_arg_counts, idx);
    if (!ccell)
      return -1;
    *ccell = 0;
  }
  if (out_base)
    *out_base = (int32_t *)grow_vec_at(&sc->type_type_arg_bases, type_ref);
  if (out_count)
    *out_count = (int32_t *)grow_vec_at(&sc->type_type_arg_counts, type_ref);
  return 0;
}

/**
 * wave467: append one type-position type arg to TYPE_NAMED (`Name<T,U>`).
 * First append fixes base; caller sets Type.array_size = n and elem_type_ref = first.
 * @return 0 success, -1 failure. PLATFORM: SHARED
 */
int32_t pipeline_type_append_type_arg(void *a, int32_t type_ref, int32_t arg_ref) {
  W278_Sidecar *sc;
  int32_t *base_cell;
  int32_t *count_cell;
  int32_t base;
  int32_t n;
  int32_t abs;
  int32_t *slot;
  if (!a || type_ref <= 0 || arg_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  if (!sc)
    return -1;
  if (type_type_arg_ensure_meta(a, type_ref, 1, &base_cell, &count_cell) != 0)
    return -1;
  if (!base_cell || !count_cell)
    return -1;
  if (*base_cell < 0) {
    *base_cell = (int32_t)sc->type_type_arg_refs.len;
    *count_cell = 0;
  }
  base = *base_cell;
  n = *count_cell;
  abs = base + n;
  while (sc->type_type_arg_refs.len <= (size_t)abs) {
    int32_t pi = grow_vec_push(&sc->type_type_arg_refs);
    if (pi < 0)
      return -1;
    slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, pi);
    if (slot)
      *slot = 0;
  }
  slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, abs);
  if (!slot)
    return -1;
  *slot = arg_ref;
  *count_cell = n + 1;
  return 0;
}

/**
 * wave467: type_ref of TYPE_NAMED type-pos arg at index, or 0 if missing.
 * Slot0 falls back to Type.elem_type_ref when sidecar empty (wave466).
 * PLATFORM: SHARED
 */
int32_t pipeline_type_type_arg_ref_at(void *a, int32_t type_ref, int32_t idx) {
  W278_Sidecar *sc;
  int32_t *base_cell;
  int32_t *count_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || type_ref <= 0 || idx < 0)
    return 0;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return 0;
  if (type_type_arg_ensure_meta(a, type_ref, 0, &base_cell, &count_cell) == 0
      && base_cell && count_cell && *base_cell >= 0 && idx < *count_cell) {
    base = *base_cell;
    abs = base + idx;
    if (abs >= 0 && (size_t)abs < sc->type_type_arg_refs.len) {
      slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, abs);
      if (slot && *slot > 0)
        return *slot;
    }
  }
  /* wave466 single-arg: only slot0 lives in elem_type_ref. */
  if (idx == 0)
    return pipeline_type_elem_ref_at(a, type_ref);
  return 0;
}

int32_t pipeline_expr_append_method_call_arg(void *a, int32_t expr_ref, int32_t arg_ref) {
  W278_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->method_call_num_args == 0) {
    W278_Sidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->method_call_arg_base = sc->expr_method_call_arg_refs.len;
  }
  slot = expr_method_call_arg_slot(a, expr_ref, ex->method_call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->method_call_num_args++;
  return ex->method_call_num_args - 1;
}

int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_method_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

/* ============================================================
 * wave260 G.7 pure-owned leave: call-resolve + METHOD_CALL field
 * accessors moved from pipeline_typeck_method_call.c residual into
 * this sidecar (same-TU via ast_pool.c → pipeline_glue.c). Completes
 * the expr accessor cluster authority already owning method_call_arg_ref
 * / call_num_args (有则补全). Uses pipeline_arena_expr_ptr (not
 * glue_arena_expr_at_ref) for G.7 single arena-ptr path.
 * Cap typeck faces (method_call_c / import thin / apply_call_resolve_c)
 * live on typeck_x.o only. PLATFORM: SHARED freestanding expr accessors.
 * ============================================================ */

/**
 * Initialize call_resolved_func_index and call_resolved_dep_index to -1
 * (sentinel "unresolved") on the arena-pooled Expr at expr_ref.
 * Null arena or out-of-range expr_ref is a no-op.
 */
void pipeline_expr_init_call_resolve_at_ref(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_func_index = -1;
  ex->call_resolved_dep_index = -1;
}

/**
 * Write resolved dep slot index and func index into the arena-pooled Expr
 * after typeck successfully resolves a call. dep_ix = -1 means same-module.
 * Null arena or out-of-range expr_ref is a no-op.
 */
void pipeline_expr_apply_call_resolve(void *a, int32_t expr_ref, int32_t dep_ix,
                                      int32_t func_ix) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_dep_index = dep_ix;
  ex->call_resolved_func_index = func_ix;
}

/**
 * Initialize call_resolved_* to -1 on a raw heap/stack Expr pointer
 * (parser expr_set_common_zeros path). Null pointer is a no-op.
 */
void pipeline_expr_ptr_init_call_resolve(W278_Expr *e) {
  if (!e)
    return;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/** ast_-prefixed alias: pipeline_expr_ptr_init_call_resolve. */
void ast_pipeline_expr_ptr_init_call_resolve(W278_Expr *e) {
  pipeline_expr_ptr_init_call_resolve(e);
}

/** ast_-prefixed alias: pipeline_expr_init_call_resolve_at_ref. */
void ast_pipeline_expr_init_call_resolve_at_ref(void *a, int32_t expr_ref) {
  pipeline_expr_init_call_resolve_at_ref(a, expr_ref);
}

/** ast_-prefixed alias: pipeline_expr_apply_call_resolve. */
void ast_pipeline_expr_apply_call_resolve(void *a, int32_t expr_ref, int32_t dep_ix,
                                          int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, expr_ref, dep_ix, func_ix);
}

/**
 * Read dep slot index written by typeck after resolving a call.
 * Returns -1 for same-module, -2 for invalid expr_ref or null arena.
 */
int32_t pipeline_expr_call_resolved_dep_index_at(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return -2;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -2;
  return ex->call_resolved_dep_index;
}

/**
 * Read func index written by typeck after resolving a call.
 * Returns -1 if unresolved or invalid expr_ref.
 */
int32_t pipeline_expr_call_resolved_func_index_at(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  return ex->call_resolved_func_index;
}

/**
 * Read EXPR_CALL callee expr ref. Returns 0 for invalid ref.
 */
int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->call_callee_ref : 0;
}

/**
 * Read EXPR_METHOD_CALL receiver (base) expr ref. Returns 0 for invalid ref.
 */
int32_t pipeline_expr_method_call_base_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->method_call_base_ref : 0;
}

/**
 * Read EXPR_METHOD_CALL arg count (excluding receiver). Returns 0 for invalid ref.
 */
int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->method_call_num_args : 0;
}

/**
 * Read EXPR_METHOD_CALL method name length. Returns 0 for invalid ref.
 */
int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->method_call_name_len : 0;
}

/**
 * Copy EXPR_METHOD_CALL method name (u8[128]) into out64 via memcpy.
 * If out64 is null or expr is invalid, zeros the buffer and returns.
 * wave577 Cap: method_call_name is u8[128] (not u8[64]).
 */
void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  W278_Expr *ex;
  if (!out64)
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 256);
    return;
  }
  memcpy(out64, ex->method_call_name, 256);
}

int32_t pipeline_expr_append_match_arm(void *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index) {
  W278_Expr *ex;
  W278_MatchArm *arm;
  if (!a || expr_ref <= 0)
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->match_num_arms == 0) {
    W278_Sidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->match_arm_base = sc->expr_match_arms.len;
  }
  arm = expr_match_arm_at(a, expr_ref, ex->match_num_arms, 1);
  if (!arm)
    return -1;
  arm->result_ref = result_ref;
  arm->is_wildcard = is_wildcard;
  arm->lit_val = lit_val;
  arm->is_enum_variant = is_enum_variant;
  arm->variant_index = variant_index;
  arm->guard_ref = 0; /* wave700: set via pipeline_expr_match_arm_set_guard_ref */
  ex->match_num_arms++;
  return ex->match_num_arms - 1;
}

int32_t pipeline_expr_match_num_arms_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->match_num_arms : 0;
}

int32_t pipeline_expr_match_arm_result_ref(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->result_ref : 0;
}

int32_t pipeline_expr_match_arm_is_wildcard(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_wildcard : 0;
}

int32_t pipeline_expr_match_arm_lit_val(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->lit_val : 0;
}

int32_t pipeline_expr_match_arm_is_enum_variant(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_enum_variant : 0;
}

int32_t pipeline_expr_match_arm_variant_index(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->variant_index : 0;
}

void pipeline_expr_match_arm_set_wildcard(void *a, int32_t expr_ref, int32_t i, int32_t v) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->is_wildcard = v;
}

void pipeline_expr_match_arm_set_lit_val(void *a, int32_t expr_ref, int32_t i, int32_t v) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->lit_val = v;
}

void pipeline_expr_match_arm_set_enum_variant(void *a, int32_t expr_ref, int32_t i, int32_t is_var,
                                              int32_t variant_index) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm) {
    arm->is_enum_variant = is_var;
    arm->variant_index = variant_index;
  }
}

/**
 * wave700: set optional match-arm guard expr (`pat if cond =>`).
 * @param guard_ref — EXPR ref for cond, or 0 to clear
 * PLATFORM: SHARED
 */
void pipeline_expr_match_arm_set_guard_ref(void *a, int32_t expr_ref, int32_t i, int32_t guard_ref) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->guard_ref = guard_ref;
}

/**
 * wave700: get optional match-arm guard expr ref (0 = no guard).
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_match_arm_guard_ref(void *a, int32_t expr_ref, int32_t i) {
  W278_MatchArm *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->guard_ref : 0;
}

int32_t pipeline_expr_append_struct_lit_field(void *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref) {
  W278_Expr *ex;
  W278_StructLitField *fe;
  int32_t n;
  if (!a || expr_ref <= 0 || !name_bytes || name_len <= 0)
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->struct_lit_num_fields == 0) {
    W278_Sidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->struct_lit_field_base = sc->expr_struct_lit_fields.len;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, ex->struct_lit_num_fields, 1);
  if (!fe)
    return -1;
  n = name_len > 255 ? 255 : name_len;
  memset(fe->name, 0, sizeof(fe->name));
  memcpy(fe->name, name_bytes, (size_t)n);
  fe->name_len = n;
  fe->init_ref = init_ref;
  ex->struct_lit_num_fields++;
  return ex->struct_lit_num_fields - 1;
}

int32_t pipeline_expr_struct_lit_field_name_len(void *a, int32_t expr_ref, int32_t j) {
  W278_StructLitField *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->name_len : 0;
}

void pipeline_expr_struct_lit_field_name_into(void *a, int32_t expr_ref, int32_t j,
                                              uint8_t *out64) {
  W278_StructLitField *fe;
  if (!out64) {
    return;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (!fe) {
    memset(out64, 0, 256);
    return;
  }
  memcpy(out64, fe->name, 256); /* wave577 Cap */
}

int32_t pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t j) {
  W278_StructLitField *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->init_ref : 0;
}

/*
 * WAVE278 STRUCT_LIT sidecar faces leftover rest remaining wave154 defines
 * under #ifndef FROM_X (SAT Expr W154 offsets). leftover-PE parser writes
 * W278_Expr via pipeline_arena_expr_ptr; SAT emit_struct_lit intra SAT
 * num_fields → n_fields==0 lea-empty (no mov $3/$4).
 * G.7 complete: FROM_X && WIN leftover only so leftover rest !FROM_X keeps
 * remaining SAT-layout twins (no dual-def). POSIX FROM_X leftover rest
 * ABSENT — SAT T for SAT Expr (POSIX -E).
 * PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
 */
#if defined(XLANG_RUNTIME_PIPELINE_ABI_FROM_X) \
    && defined(XLANG_RUNTIME_PIPELINE_ABI_WIN_LEFTOVER_GROW_VEC)
int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->struct_lit_num_fields : 0;
}

int32_t pipeline_expr_struct_lit_type_name_len(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->struct_lit_struct_name_len : 0;
}

void pipeline_expr_struct_lit_type_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  W278_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 256);
    return;
  }
  nlen = ex->struct_lit_struct_name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  memset(out64, 0, 256);
  if (nlen > 0)
    memcpy(out64, ex->struct_lit_struct_name, (size_t)nlen);
}

void pipeline_expr_struct_lit_type_name_set(void *a, int32_t expr_ref, uint8_t *name,
                                            int32_t name_len) {
  W278_Expr *ex;
  int32_t n;
  if (!a || !name || expr_ref <= 0 || name_len < 0)
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  n = name_len > 255 ? 255 : name_len;
  memset(ex->struct_lit_struct_name, 0, sizeof(ex->struct_lit_struct_name));
  if (n > 0)
    memcpy(ex->struct_lit_struct_name, name, (size_t)n);
  ex->struct_lit_struct_name_len = n;
}
#endif /* FROM_X && WIN_LEFTOVER — leftover-PE W278 STRUCT_LIT name/nf */

int32_t pipeline_expr_append_array_lit_elem(void *a, int32_t expr_ref, int32_t elem_ref) {
  W278_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->array_lit_num_elems == 0) {
    W278_Sidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->array_lit_elem_base = sc->expr_array_lit_elem_refs.len;
  }
  slot = expr_array_lit_elem_slot(a, expr_ref, ex->array_lit_num_elems, 1);
  if (!slot)
    return -1;
  *slot = elem_ref;
  ex->array_lit_num_elems++;
  return ex->array_lit_num_elems - 1;
}

int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_array_lit_elem_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->array_lit_num_elems : 0;
}

/* ============================================================
 * wave152: Cap residual expr pool accessors relocated from
 * pipeline_asm_emit_expr_rec.c L514–EOF (emit faces pure-owned leave).
 * Same-TU via ast_pool.c → pipeline_glue. No semantic change.
 * Uses glue_arena_expr_at_ref / pipeline_arena_expr_ptr (arena before sidecar).
 * PLATFORM: SHARED host residual pool faces.
 * ============================================================ */
/* ============================================================
 * wave1160 G.7: expr accessor public wrappers (10 fns) +
 * ast_pipeline_* forwarding wrappers (9 fns) migrated from
 * pipeline_glue.c L3564-3625 / L10412-10449. Colocated with expr
 * ELF recursion dispatcher — these are the field readers consumed
 * by emit_expr_elf_rec / emit_expr_elf_fast above. Fwd decls at
 * glue.c L1532-1578 (before #include L2210).
 */

/**
 * Read EXPR_AS operand expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_AS arm to load the cast source.
 */
int32_t pipeline_expr_as_operand_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->as_operand_ref : 0;
}

/**
 * Read EXPR_AS target type pool ref. Returns 0 for invalid ref.
 * Used by typeck return path and emit EXPR_AS arm to determine
 * the cast target type.
 */
int32_t pipeline_expr_as_target_type_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->as_target_type_ref : 0;
}

/**
 * Read EXPR_ENUM_VARIANT / FIELD_ACCESS enum variant tag.
 * Returns 0 for invalid ref. Used by emit_expr_elf_rec to emit
 * the variant ordinal as immediate.
 */
int32_t pipeline_expr_enum_variant_tag_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->enum_variant_tag : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY condition expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_cond_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->if_cond_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY then-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_then_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->if_then_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY else-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_else_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->if_else_ref : 0;
}

/**
 * Read EXPR_BLOCK inner block ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_BLOCK arm and typeck tail-expr scan.
 */
int32_t pipeline_expr_block_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->block_ref : 0;
}

/**
 * Read EXPR_MATCH matched-value expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_MATCH arm and typeck check_expr_match.
 */
int32_t pipeline_expr_match_matched_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->match_matched_ref : 0;
}

/**
 * Read CTFE const-folded valid flag. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to short-circuit folded constants.
 */
int32_t pipeline_expr_const_folded_valid_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? (int32_t)ex->const_folded_valid : 0;
}

/**
 * Read CTFE const-folded integer value. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to emit folded constant as immediate.
 */
int32_t pipeline_expr_const_folded_val_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->const_folded_val : 0;
}

/**
 * wave238 G.7: complete const_folded producer faces (was residual-only direct
 * field writes). Pure typeck CTFE leave stamps fold results via this setter.
 * @param a arena
 * @param expr_ref expr ref
 * @param valid 0 clear / non-zero stamp valid
 * @param val const_folded_val when valid != 0
 * PLATFORM: SHARED — single CTFE write authority with residual thin leave.
 */
void pipeline_expr_set_const_folded(void *a, int32_t expr_ref, int32_t valid, int32_t val) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  if (valid != 0) {
    ex->const_folded_val = val;
    ex->const_folded_valid = 1;
  } else {
    ex->const_folded_valid = 0;
  }
}

void ast_pipeline_expr_set_const_folded(void *a, int32_t expr_ref, int32_t valid, int32_t val) {
  pipeline_expr_set_const_folded(a, expr_ref, valid, val);
}

/*
 * ast_pipeline_* forwarding wrappers: codegen may prepend ast_ prefix
 * when importing the ast module; each delegates to the pipeline_expr_*
 * bare symbol defined above.
 */

int32_t ast_pipeline_expr_as_operand_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_as_operand_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_enum_variant_tag_at(void *a, int32_t expr_ref) {
  return pipeline_expr_enum_variant_tag_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_cond_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_if_cond_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_then_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_if_then_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_else_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_if_else_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_block_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_block_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_match_matched_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_match_matched_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_valid_at(void *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_valid_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_val_at(void *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_val_at(a, expr_ref);
}

/* ============================================================
 * wave1161 G.7: index/field_access/line/col accessor public wrappers
 * (10 fns) + ast_pipeline_* forwarding wrappers (3 fns) migrated from
 * pipeline_glue.c L3816-3950 / L10382-10392. Colocated with expr ELF
 * recursion dispatcher — these field readers/writers are consumed by
 * emit_expr_elf_rec / emit_expr_elf_fast and typeck index/field checks.
 * Fwd decls at glue.c L1554-1565 (before #include L2210).
 */

/**
 * Read EXPR_INDEX base expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the indexed value.
 */
int32_t pipeline_expr_index_base_ref(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->index_base_ref : 0;
}

/**
 * Read EXPR_INDEX index expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the index operand.
 */
int32_t pipeline_expr_index_index_ref(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->index_index_ref : 0;
}

/**
 * Read resolved_type_ref from arena-pooled Expr. Returns 0 for invalid
 * ref. Used throughout typeck and asm emit to determine the inferred
 * type of an expression.
 */
int32_t pipeline_expr_resolved_type_ref(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->resolved_type_ref : 0;
}

/* =============================================================================
 * primary-parse wave-0 expr writers (2026-09-14): scalar-field writes over
 * W278_Expr for the upcoming pthin .x primary orchestration (same rationale
 * as set_resolved_type_ref: no Expr by-value get/set on the asm backend).
 * Literal+ident minimal family; more writers land with their consumer waves.
 * PLATFORM: SHARED — always-domain, additive.
 * ============================================================================= */
void pipeline_expr_set_kind(void *a, int32_t er, int32_t kind) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (ex)
    ex->kind = (int32_t)kind;
}

void pipeline_expr_set_line_col(void *a, int32_t er, int32_t line, int32_t col) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (ex) {
    ex->line = line;
    ex->col = col;
  }
}

void pipeline_expr_set_int_val(void *a, int32_t er, int64_t v) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (ex)
    ex->int_val = v;
}

void pipeline_expr_set_float_val(void *a, int32_t er, double v) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (ex)
    ex->float_val = v;
}

/* primary wave-0 #6: arena-side twin of the parse-side common-zeros wipe
 * (every ref/base/count field a fresh literal fill must clear; the .x lane
 * cannot memcpy an Expr). Mirrors parser_asm_expr_set_common_zeros_c. */
void pipeline_expr_set_common_zeros_c(void *a, int32_t er) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->resolved_type_ref = 0;
  ex->binop_left_ref = 0;
  ex->binop_right_ref = 0;
  ex->unary_operand_ref = 0;
  ex->if_cond_ref = 0;
  ex->if_then_ref = 0;
  ex->if_else_ref = 0;
  ex->block_ref = 0;
  ex->match_matched_ref = 0;
  ex->match_arm_base = 0;
  ex->match_num_arms = 0;
  ex->enum_variant_tag = 0;
  ex->field_access_base_ref = 0;
  ex->field_access_field_len = 0;
  ex->field_access_is_enum_variant = 0;
  ex->field_access_offset = 0;
  ex->index_base_ref = 0;
  ex->index_index_ref = 0;
  ex->index_base_is_slice = 0;
  ex->call_callee_ref = 0;
  ex->call_arg_base = 0;
  ex->call_num_args = 0;
  ex->call_num_type_args = 0;
  ex->var_name_len = 0;
}

/* Suffix segment-2 (DOT suffix enabler): field_access + method_call
 * combined writers. Name buffers cap 255 (u8[256] AST face; the parse-side
 * [128] mirrors are content-equal). Kind/line/col/zeros stay with the
 * wave-0 writers so each fill composes exactly like the C struct fill. */
void pipeline_expr_set_field_access_c(void *a, int32_t er, int32_t base_ref,
                                      const uint8_t *nm, int32_t nlen) {
  W278_Expr *ex;
  int32_t i;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->field_access_base_ref = base_ref;
  ex->field_access_field_len = nlen;
  memset(ex->field_access_field_name, 0, sizeof(ex->field_access_field_name));
  for (i = 0; i < nlen; i++)
    ex->field_access_field_name[i] = nm ? nm[i] : 0;
}

void pipeline_expr_set_method_call_c(void *a, int32_t er, int32_t base_ref,
                                     const uint8_t *nm, int32_t nlen) {
  W278_Expr *ex;
  int32_t i;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->method_call_base_ref = base_ref;
  ex->method_call_name_len = nlen;
  memset(ex->method_call_name, 0, sizeof(ex->method_call_name));
  for (i = 0; i < nlen; i++)
    ex->method_call_name[i] = nm ? nm[i] : 0;
}

/* Suffix final-census writers: index trio + call preset. Compose with
 * kind/line_col/zeros (wave-0) exactly like the C struct fills. The call
 * num_type_args preset covers the count-only turbofish fallback; the
 * ref-carrying path appends via pipeline_expr_append_call_type_arg. */
void pipeline_expr_set_index_c(void *a, int32_t er, int32_t base_ref, int32_t index_ref,
                               int32_t is_slice) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->index_base_ref = base_ref;
  ex->index_index_ref = index_ref;
  ex->index_base_is_slice = is_slice;
}

void pipeline_expr_set_call_c(void *a, int32_t er, int32_t callee_ref, int32_t num_type_args) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->call_callee_ref = callee_ref;
  ex->call_num_type_args = num_type_args;
}

/* Suffix LBRACE branch: convert the live FIELD_ACCESS expr into a
 * qualified struct-lit head (kind 45 + name + len; field_base/num zeroed).
 * Caller composes common_zeros + line_col(0,0) like the C fill. */
void pipeline_expr_set_struct_lit_finish_c(void *a, int32_t er, const uint8_t *nm, int32_t nlen) {
  W278_Expr *ex;
  int32_t i;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  ex->kind = 45;
  ex->struct_lit_struct_name_len = nlen;
  memset(ex->struct_lit_struct_name, 0, sizeof(ex->struct_lit_struct_name));
  for (i = 0; i < nlen; i++)
    ex->struct_lit_struct_name[i] = nm ? nm[i] : 0;
  ex->struct_lit_field_base = 0;
  ex->struct_lit_num_fields = 0;
}

/* Suffix LBRACE branch: field_access name readers (in-place conversion to
 * a qualified struct-lit head needs the live field name bytes). */
int32_t pipeline_expr_field_name_len_at(void *a, int32_t er) {
  W278_Expr *ex;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return 0;
  ex = w278_expr_ptr(a, er);
  return ex ? (int32_t)ex->field_access_field_len : 0;
}

void pipeline_expr_field_name_into(void *a, int32_t er, uint8_t *dst) {
  W278_Expr *ex;
  int32_t i;
  if (!a || !dst || er <= 0 || er > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  for (i = 0; i < 256; i++)
    dst[i] = (i < ex->field_access_field_len) ? ex->field_access_field_name[i] : 0;
}

void pipeline_expr_set_var_name(void *a, int32_t er, const uint8_t *nm, int32_t nlen) {
  W278_Expr *ex;
  int32_t i;
  if (!a || er <= 0 || er > w278_num_exprs(a))
    return;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  ex = w278_expr_ptr(a, er);
  if (!ex)
    return;
  memset(ex->var_name, 0, sizeof(ex->var_name));
  for (i = 0; i < nlen; i++)
    ex->var_name[i] = nm ? nm[i] : 0;
  ex->var_name_len = nlen;
}

/**
 * Write resolved_type_ref on arena-pooled Expr. Called by typeck.x
 * EMIT_HEAVY emit path to stamp the inferred type without Expr
 * by-value get/set (which tears the struct on the asm backend).
 * Includes optional XLANG_TRACE_EXPR_SET debug tracing.
 */
void pipeline_expr_set_resolved_type_ref(void *a, int32_t expr_ref, int32_t type_ref) {
  W278_Expr *ex;
  const char *trace_expr;
  int32_t trace_ref;
  int32_t old_ref;

  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  old_ref = ex->resolved_type_ref;
  ex->resolved_type_ref = type_ref;
  trace_expr = link_abi_getenv("XLANG_TRACE_EXPR_SET");
  if (!trace_expr || !*trace_expr)
    return;
  trace_ref = atoi(trace_expr);
  if (trace_ref != expr_ref)
    return;
  pabi_trace( "note: expr set debug: expr=%d kind=%d block=%d old_ty=%d new_ty=%d\n", (int)expr_ref,
          (int)ex->kind, (int)ex->block_ref, (int)old_ref, (int)type_ref);
}

/**
 * Write index_base_is_slice flag on EXPR_INDEX. Called by typeck
 * index bounds check to mark slice-typed bases for asm emit.
 * Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_index_base_is_slice(void *a, int32_t expr_ref, int32_t v) {
  W278_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->index_base_is_slice = v;
}

/**
 * Write index_proven_in_bounds flag on EXPR_INDEX. Called by typeck
 * after static bounds proof to skip runtime bounds check in asm emit.
 */
void pipeline_expr_set_index_proven_in_bounds(void *a, int32_t expr_ref, int32_t v) {
  W278_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->index_proven_in_bounds = v;
}

/**
 * Read index_base_is_slice on EXPR_INDEX (wave147 pure Cap residual getter).
 * G.7: pool face twin of pipeline_expr_set_index_base_is_slice.
 * @return 0 if invalid ref / unset; else flag value
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_index_base_is_slice_at(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return 0;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  return ex->index_base_is_slice;
}

/**
 * Read index_proven_in_bounds on EXPR_INDEX (wave147 pure Cap residual getter).
 * G.7: pool face twin of pipeline_expr_set_index_proven_in_bounds.
 * @return 0 if invalid ref / unset; else flag value
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_index_proven_in_bounds_at(void *a, int32_t expr_ref) {
  W278_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > w278_num_exprs(a))
    return 0;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  return ex->index_proven_in_bounds;
}

/**
 * Read source line number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_line_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->line : 0;
}

/**
 * Read source column number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_col_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->col : 0;
}

/**
 * Read FIELD_ACCESS byte offset. Returns 0 for invalid ref.
 * Used by asm emit to compute the field address (base + offset).
 */
int32_t pipeline_expr_field_access_offset(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->field_access_offset : 0;
}

/**
 * Write FIELD_ACCESS byte offset. Called by typeck field layout
 * resolver. Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_field_access_offset(void *a, int32_t expr_ref, int32_t offset) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (ex)
    ex->field_access_offset = offset;
}

/**
 * Read FIELD_ACCESS SoA column stride (DOD-S1). Returns 0 for AoS
 * static offset. Used by asm emit for SoA struct field access.
 */
int32_t pipeline_expr_field_access_soa_stride(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->field_access_soa_stride : 0;
}

/* ast_pipeline_* forwarding wrappers for index/field_access accessors. */

int32_t ast_pipeline_expr_index_base_ref(void *a, int32_t expr_ref) {
  return pipeline_expr_index_base_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_index_index_ref(void *a, int32_t expr_ref) {
  return pipeline_expr_index_index_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_field_access_offset(void *a, int32_t expr_ref) {
  return pipeline_expr_field_access_offset(a, expr_ref);
}

/* ============================================================
 * wave1162 G.7: lit/var/field_access/unary/binop accessor public
 * wrappers (13 fns) migrated from pipeline_glue.c L3244-3422.
 * Colocated with expr ELF recursion dispatcher — these are the
 * field readers consumed by emit_expr_elf_rec / emit_expr_elf_fast
 * and typeck expr check paths. Fwd decls at glue.c L1530-1571.
 */

/**
 * Read EXPR_LIT/EXPR_BOOL_LIT int_val as i32. Returns 0 for invalid
 * ref. Backend asm must not use ast_arena_expr_get (large module
 * stack overflow risk).
 */
int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? (int32_t)ex->int_val : 0;
}

/**
 * Read EXPR_LIT full i64 value (avoids int32 truncation for
 * INT64_MIN and large constants like P0-4).
 */
int64_t pipeline_expr_int64_val_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->int_val : 0;
}

/**
 * Read EXPR_NEG/EXPR_BITNOT/EXPR_LOGNOT unary operand ref.
 * Returns 0 for invalid ref. typeck check_block_impl block-tail
 * `return;` detection uses this glue (not ast_arena_expr_get
 * which fails on bootstrap asm FIELD_ACCESS).
 */
int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->unary_operand_ref : 0;
}

/**
 * Copy FIELD_ACCESS field name into out64 (u8[128], max 127 bytes
 * + zero-fill). wave577 Cap: output buffer is u8[128].
 */
void pipeline_expr_field_access_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  W278_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 256);
    return;
  }
  nlen = ex->field_access_field_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  memset(out64, 0, 256);
  if (nlen > 0)
    memcpy(out64, ex->field_access_field_name, (size_t)nlen);
}

/**
 * Read FIELD_ACCESS field name length. Returns 0 for non-FIELD_ACCESS
 * or invalid ref.
 */
int32_t pipeline_expr_field_access_name_len(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_field_len;
}

/**
 * Read FIELD_ACCESS base_ref. Returns 0 for non-FIELD_ACCESS or
 * invalid ref.
 */
int32_t pipeline_expr_field_access_base_ref(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_base_ref;
}

/**
 * Copy EXPR_VAR variable name into out64 (u8[128], max 127 bytes
 * + zero-fill).
 */
void pipeline_expr_var_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  W278_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = w278_expr_ptr(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 256);
    return;
  }
  nlen = ex->var_name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 255)
    nlen = 255;
  memset(out64, 0, 256);
  if (nlen > 0)
    memcpy(out64, ex->var_name, (size_t)nlen);
}

/**
 * Read STRING_LIT (kind 59) byte length. Returns 0 for non-string-lit
 * or invalid ref.
 */
int32_t pipeline_expr_var_name_len_for_string_lit_c(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 59)
    return 0;
  return ex->var_name_len;
}

/**
 * Read EXPR_VAR name length. Returns 0 for non-VAR or invalid ref.
 */
int32_t pipeline_expr_var_name_len(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_VAR)
    return 0;
  return ex->var_name_len;
}

/**
 * wave670 Cap residual: keyword `null` is EXPR_LIT int_val=0 tagged
 * var_name="null"/len=4. G.7 single null face.
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_is_null_keyword_c(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 0 /* EXPR_LIT */)
    return 0;
  if (ex->int_val != 0 || ex->var_name_len != 4)
    return 0;
  if (ex->var_name[0] == (uint8_t)'n' && ex->var_name[1] == (uint8_t)'u' &&
      ex->var_name[2] == (uint8_t)'l' && ex->var_name[3] == (uint8_t)'l')
    return 1;
  return 0;
}

/**
 * Tag EXPR_LIT 0 as keyword null on the live arena expr.
 * Use after parser_asm primary set — avoids parser_asm_ast_expr ↔
 * ast_Expr memcpy layout drift (mac vs gcc) losing var_name tag.
 * PLATFORM: SHARED.
 */
void pipeline_expr_tag_null_keyword_c(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  int32_t zi;
  if (!ex)
    return;
  ex->kind = ast_ExprKind_EXPR_LIT;
  ex->int_val = 0;
  ex->var_name[0] = (uint8_t)'n';
  ex->var_name[1] = (uint8_t)'u';
  ex->var_name[2] = (uint8_t)'l';
  ex->var_name[3] = (uint8_t)'l';
  ex->var_name_len = 4;
  for (zi = 4; zi < 128; zi++)
    ex->var_name[zi] = 0;
}

/** Read expr.binop_left_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->binop_left_ref : 0;
}

/** Read expr.binop_right_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t expr_ref) {
  W278_Expr *ex = w278_expr_ptr(a, expr_ref);
  return ex ? ex->binop_right_ref : 0;
}

/* wave1183 G.7: Forward declarations for pipeline_expr_* functions defined
 * in ast_pool_expr_sidecar.c (included later via ast_pool.c #include L4607).
 * Needed because the ast_pipeline_expr_* forwarders below call these before
 * their definitions appear in the same TU. */
int32_t pipeline_expr_append_call_arg(void *a, int32_t expr_ref, int32_t arg_ref);
void pipeline_expr_on_call_created(void *a, int32_t expr_ref);
int32_t pipeline_expr_prepare_call_arg_slot(void *a, int32_t expr_ref);
int32_t pipeline_expr_append_method_call_arg(void *a, int32_t expr_ref, int32_t arg_ref);
int32_t pipeline_expr_append_match_arm(void *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index);
void pipeline_expr_match_arm_set_wildcard(void *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_lit_val(void *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_enum_variant(void *a, int32_t expr_ref, int32_t i,
                                              int32_t is_var, int32_t variant_index);
int32_t pipeline_expr_append_struct_lit_field(void *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref);
int32_t pipeline_expr_append_array_lit_elem(void *a, int32_t expr_ref, int32_t elem_ref);
int32_t pipeline_module_import_append_select_name(void *m, int32_t idx, uint8_t *bytes, int32_t len);

/* wave1183 G.7: ast_pipeline_expr_* + codegen_pipeline_expr_* +
 * backend_pipeline_expr_* forwarder cluster (40 fns) migrated from
 * pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x / codegen.x / backend.x resolve extern pipeline_expr_*
 * symbols with module prefixes at codegen time (ast_pipeline_expr_*,
 * codegen_pipeline_expr_*, backend_pipeline_expr_*), but the authoritative
 * implementations live in ast_pool_expr_sidecar.c / pipeline_asm_emit_expr_rec.c
 * with unprefixed C names (pipeline_expr_*). These 40 thin forwarders exist
 * solely to satisfy the linker name-mangling gap; colocating them here
 * keeps pipeline_glue.c focused on real glue logic.
 *
 * Sub-clusters:
 *  - codegen_pipeline_module_func_param_type_ref_at (1 fn: codegen_ prefix)
 *  - ast_pipeline_expr_call_* (6 fns: append_arg/on_created/prepare_slot/
 *    arg_ref/num_args/callee_ref -- call expr sidecar accessors)
 *  - ast_pipeline_expr_method_call_* (5 fns: append_arg/arg_ref/num_args/
 *    name_len/name_into -- method call sidecar accessors)
 *  - ast_pipeline_expr_match_* (10 fns: append_arm/num_arms/result_ref/
 *    is_wildcard/lit_val/is_enum_variant/variant_index/set_wildcard/
 *    set_lit_val/set_enum_variant -- match arm sidecar accessors)
 *  - ast_pipeline_expr_struct_lit/array_lit/float/if/block/match/const_folded
 *    (12 fns: append_field/append_elem/elem_ref/num_elems/bits_lo/hi/
 *    cond_ref/then_ref/else_ref/block_ref/matched_ref/const_folded_valid/val)
 *  - ast_pipeline_expr_index/field_access (6 fns: base_ref/index_ref/
 *    is_enum_variant/offset/layout_offset/load_byte_sz)
 *  - ast_pipeline_module_import_append_select_name (1 fn: import select name)
 *  - codegen_pipeline_expr_* + backend_pipeline_expr_* (5 fns: kind_ord/
 *    struct_lit_num_fields/init_ref -- codegen_ and backend_ prefix twins)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_expr_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
int32_t codegen_pipeline_module_func_param_type_ref_at(void *m, int32_t func_index,
                                                       int32_t param_index) {
  return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
}

/** Expr sidecar pool symbol forwarders called via import prefix by ast.x / typeck / codegen / backend / parser. */
int32_t ast_pipeline_expr_append_call_arg(void *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}
void ast_pipeline_expr_on_call_created(void *a, int32_t expr_ref) {
  pipeline_expr_on_call_created(a, expr_ref);
}
int32_t ast_pipeline_expr_prepare_call_arg_slot(void *a, int32_t expr_ref) {
  return pipeline_expr_prepare_call_arg_slot(a, expr_ref);
}
int32_t ast_pipeline_expr_call_arg_ref(void *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_call_num_args_at(void *a, int32_t expr_ref) {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_append_method_call_arg(void *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_method_call_arg_ref(void *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_append_match_arm(void *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index) {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}
int32_t ast_pipeline_expr_match_num_arms_at(void *a, int32_t expr_ref) {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_arm_result_ref(void *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_wildcard(void *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_lit_val(void *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_enum_variant(void *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_variant_index(void *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}
void ast_pipeline_expr_match_arm_set_wildcard(void *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_lit_val(void *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_enum_variant(void *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index) {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}
int32_t ast_pipeline_expr_append_struct_lit_field(void *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref) {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}
int32_t ast_pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t ast_pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t ast_pipeline_expr_struct_lit_field_name_len(void *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_field_name_len(a, expr_ref, j);
}
void ast_pipeline_expr_struct_lit_field_name_into(void *a, int32_t expr_ref, int32_t j,
                                                  uint8_t *out64) {
  pipeline_expr_struct_lit_field_name_into(a, expr_ref, j, out64);
}
int32_t ast_pipeline_expr_struct_lit_type_name_len(void *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_type_name_len(a, expr_ref);
}
void ast_pipeline_expr_struct_lit_type_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  pipeline_expr_struct_lit_type_name_into(a, expr_ref, out64);
}
void ast_pipeline_expr_struct_lit_type_name_set(void *a, int32_t expr_ref, uint8_t *name,
                                                int32_t name_len) {
  pipeline_expr_struct_lit_type_name_set(a, expr_ref, name, name_len);
}
int32_t ast_pipeline_expr_append_array_lit_elem(void *a, int32_t expr_ref, int32_t elem_ref) {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}
int32_t ast_pipeline_expr_array_lit_elem_ref(void *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_array_lit_num_elems_at(void *a, int32_t expr_ref) {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_lo_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_hi_at(a, expr_ref);
}
int32_t ast_pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_call_callee_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_as_operand_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_enum_variant_tag_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_method_call_base_ref_at(void *a, int32_t expr_ref) {
  return pipeline_expr_method_call_base_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_num_args_at(void *a, int32_t expr_ref) {
  return pipeline_expr_method_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_name_len(void *a, int32_t expr_ref) {
  return pipeline_expr_method_call_name_len(a, expr_ref);
}
void ast_pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  pipeline_expr_method_call_name_into(a, expr_ref, out64);
}
int32_t ast_pipeline_expr_if_cond_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_then_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_else_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_block_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_match_matched_ref_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_valid_at(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_val_at(void *a, int32_t expr_ref);
/* wave1160 G.7: 9 ast_pipeline_expr_* wrappers above (as/if/block/match/
 * const_folded/enum_variant) migrated to pipeline_asm_emit_expr_rec.c EOF
 * as fwd decls. wave260: pipeline_expr_* method_call / call-resolve bodies
 * live in this sidecar (above); 4 method_call ast_ wrappers hop to them. */
/* wave1161 G.7: index/field_access_offset wrappers migrated to
 * pipeline_asm_emit_expr_rec.c EOF as fwd decls below. */
int32_t ast_pipeline_expr_index_base_ref(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_index_index_ref(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_is_enum_variant(void *a, int32_t expr_ref) {
  return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_offset(void *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_layout_offset(void *a, void *m, int32_t expr_ref) {
  return pipeline_expr_field_access_layout_offset(a, m, expr_ref);
}

int32_t ast_pipeline_expr_field_access_load_byte_sz(void *a, void *m, int32_t expr_ref) {
  return pipeline_expr_field_access_load_byte_sz(a, m, expr_ref);
}
int32_t ast_pipeline_module_import_append_select_name(void *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len) {
  return pipeline_module_import_append_select_name(m, idx, bytes, len);
}

/** backend import codegen uses codegen_ prefix for struct_lit glue. */
int32_t codegen_pipeline_expr_kind_ord_at(void *a, int32_t expr_ref) {
  return pipeline_expr_kind_ord_at(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t backend_pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t backend_pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}

/* wave1187 G.7: codegen_/backend_ struct_lit field offset/store_sz forwarders
 * migrated from pipeline_glue.c L7239-L7255. Pure forwarders to
 * pipeline_expr_struct_lit_field_offset_at / _field_store_sz. */
int32_t codegen_pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t codegen_pipeline_expr_struct_lit_field_store_sz(void *a, void *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_store_sz(void *a, void *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}

/* XLANG_PABI_EXPR_SIDECAR_THIN_END */
