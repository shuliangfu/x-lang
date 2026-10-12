/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef WAVE276_ARENA_DOMAIN_COLD
#define WAVE276_ARENA_DOMAIN_COLD 1

#include <string.h>
#include <stdint.h>

void *arena_sidecar_get(void *a, int create);
void *grow_vec_at(void *v, int32_t idx);
int32_t grow_vec_push(void *v);
void ast_pool_block_on_alloc(void *a, int32_t br);
int32_t pipeline_module_func_alloc_slot(void *m);
void pipeline_module_func_name_write(void *m, int32_t fi, uint8_t *name, int32_t name_len);
void pipeline_module_func_set_num_params(void *m, int32_t fi, int32_t n);
void pipeline_module_func_set_return_type(void *m, int32_t fi, int32_t tr);
void pipeline_module_func_set_body_ref(void *m, int32_t fi, int32_t br);
void pipeline_module_func_set_body_expr_ref(void *m, int32_t fi, int32_t er);
void pipeline_module_func_set_is_extern(void *m, int32_t fi, int32_t v);
void pipeline_module_func_set_is_async(void *m, int32_t fi, int32_t v);
void pipeline_module_func_ref_set(void *m, int32_t fi, int32_t fr);
int32_t ast_pipeline_block_append_labeled(void *a, int32_t br, int32_t label_len, int32_t is_goto,
                                          int32_t goto_target_len, int32_t return_expr_ref);


/* =============================================================================
 * LANG-005 impl-method owner sidecar (associated-call binding, 2026-09-14).
 * Root fix for receiver-blind `X.g()` associated lookups: impl-body methods
 * are registered as flat name rows, so a scan by name could bind ANY impl's
 * method (cross-impl bleed: B.g() ran A's body; empty-impl structs passed).
 * The parser impl glue latches the current impl owner (for-type for
 * `impl T for X`, head ident for inherent `impl X`); func registration
 * stamps it here; typeck rejects rows whose owner does not bind the base.
 * Empty owner = free function / UFCS / pre-latch row (legacy accept).
 * PLATFORM: SHARED — parse latch in skip_tl glue; clear on impl RBRACE.
 * ============================================================================= */
#define PMFO_MAX 4096
static uint8_t g_pmfo_owner[PMFO_MAX][64];
static int32_t g_pmfo_owner_len[PMFO_MAX];
static uint8_t g_pmfo_cur_owner[64];
static int32_t g_pmfo_cur_len = 0;

void pipeline_module_parse_impl_owner_set(const uint8_t *nm, int32_t nlen) {
  int32_t i;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 63)
    nlen = 63;
  g_pmfo_cur_len = nlen;
  for (i = 0; i < 64; i++)
    g_pmfo_cur_owner[i] = (nm && i < nlen) ? nm[i] : 0;
}

void pipeline_module_parse_impl_owner_clear(void) {
  g_pmfo_cur_len = 0;
}

/* Stamp the latched owner onto func slot fi; no-op when no impl is active. */
void pipeline_module_func_owner_from_impl(void *m, int32_t fi) {
  if (!m || fi < 0 || fi >= PMFO_MAX)
    return;
  if (g_pmfo_cur_len <= 0)
    return;
  memcpy(g_pmfo_owner[fi], g_pmfo_cur_owner, 64);
  g_pmfo_owner_len[fi] = g_pmfo_cur_len;
}

/* 1 when row fi may bind associated call on base struct name: empty owner
 * (free fn / UFCS / legacy) or owner == base. 0 = foreign impl method. */
int32_t pipeline_module_func_owner_binds_base_at(void *m, int32_t fi, const uint8_t *base, int32_t base_len) {
  int32_t i;
  if (!m || fi < 0 || fi >= PMFO_MAX)
    return 1;
  if (g_pmfo_owner_len[fi] <= 0)
    return 1;
  if (!base || base_len <= 0 || base_len > 63)
    return 0;
  if (g_pmfo_owner_len[fi] != base_len)
    return 0;
  for (i = 0; i < base_len; i++)
    if (g_pmfo_owner[fi][i] != base[i])
      return 0;
  return 1;
}

enum {
  W276C_TY = 532, W276C_EX = 1224, W276C_BL = 92, W276C_FN = 324,
  W276C_NO_LIMIT = 2147483647
};

static int32_t w276_load_i32(uint8_t *b, int32_t off) {
  return (int32_t)((uint32_t)b[off] | ((uint32_t)b[off + 1] << 8) | ((uint32_t)b[off + 2] << 16) |
                   ((uint32_t)b[off + 3] << 24));
}
static void w276_store_i32(uint8_t *b, int32_t off, int32_t v) {
  b[off] = (uint8_t)(v & 255);
  b[off + 1] = (uint8_t)((v >> 8) & 255);
  b[off + 2] = (uint8_t)((v >> 16) & 255);
  b[off + 3] = (uint8_t)((v >> 24) & 255);
}
static void w276_zero(uint8_t *p, int32_t n) {
  int32_t i;
  if (!p)
    return;
  for (i = 0; i < n; i++)
    p[i] = 0;
}

void *pipeline_arena_type_ptr(void *a, int32_t ref) {
  uint8_t *sc;
  int32_t nt;
  if (!a || ref <= 0)
    return NULL;
  nt = w276_load_i32((uint8_t *)a, 0);
  if (ref > nt)
    return NULL;
  sc = (uint8_t *)arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return grow_vec_at(sc + 16, ref - 1);
}
void *pipeline_arena_expr_ptr(void *a, int32_t ref) {
  uint8_t *sc;
  int32_t ne;
  if (!a || ref <= 0)
    return NULL;
  ne = w276_load_i32((uint8_t *)a, 4);
  if (ref > ne)
    return NULL;
  sc = (uint8_t *)arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return grow_vec_at(sc + 48, ref - 1);
}
void *pipeline_arena_block_ptr(void *a, int32_t ref) {
  uint8_t *sc;
  int32_t nb;
  if (!a || ref <= 0)
    return NULL;
  nb = w276_load_i32((uint8_t *)a, 8);
  if (ref > nb)
    return NULL;
  sc = (uint8_t *)arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return grow_vec_at(sc + 80, ref - 1);
}
void *pipeline_arena_func_ptr(void *a, int32_t ref) {
  uint8_t *sc;
  int32_t nf;
  if (!a || ref <= 0)
    return NULL;
  nf = w276_load_i32((uint8_t *)a, 12);
  if (ref > nf)
    return NULL;
  sc = (uint8_t *)arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return grow_vec_at(sc + 112, ref - 1);
}
int32_t pipeline_arena_type_alloc(void *a) {
  uint8_t *sc;
  int32_t ln;
  if (!a)
    return 0;
  sc = (uint8_t *)arena_sidecar_get(a, 1);
  if (!sc)
    return 0;
  if (grow_vec_push(sc + 16) < 0)
    return 0;
  ln = w276_load_i32(sc + 16, 12);
  w276_store_i32((uint8_t *)a, 0, ln);
  return ln;
}
int32_t pipeline_arena_expr_alloc(void *a) {
  uint8_t *sc;
  int32_t ln;
  if (!a)
    return 0;
  sc = (uint8_t *)arena_sidecar_get(a, 1);
  if (!sc)
    return 0;
  if (grow_vec_push(sc + 48) < 0)
    return 0;
  ln = w276_load_i32(sc + 48, 12);
  w276_store_i32((uint8_t *)a, 4, ln);
  return ln;
}
int32_t pipeline_arena_block_alloc(void *a) {
  uint8_t *sc;
  int32_t ln;
  if (!a)
    return 0;
  sc = (uint8_t *)arena_sidecar_get(a, 1);
  if (!sc)
    return 0;
  if (grow_vec_push(sc + 80) < 0)
    return 0;
  ln = w276_load_i32(sc + 80, 12);
  w276_store_i32((uint8_t *)a, 8, ln);
  ast_pool_block_on_alloc(a, ln);
  return ln;
}
int32_t pipeline_arena_func_alloc(void *a) {
  uint8_t *sc, *f;
  int32_t ln;
  if (!a)
    return 0;
  sc = (uint8_t *)arena_sidecar_get(a, 1);
  if (!sc)
    return 0;
  if (grow_vec_push(sc + 112) < 0)
    return 0;
  ln = w276_load_i32(sc + 112, 12);
  f = (uint8_t *)grow_vec_at(sc + 112, ln - 1);
  if (f) {
    w276_zero(f, W276C_FN);
    w276_store_i32(f, 132, -1); /* param_base */
  }
  w276_store_i32((uint8_t *)a, 12, ln);
  return ln;
}
int32_t pipeline_arena_num_types(void *a) {
  return a ? w276_load_i32((uint8_t *)a, 0) : 0;
}
int32_t pipeline_arena_type_cap(void) { return W276C_NO_LIMIT; }
int32_t pipeline_arena_expr_cap(void) { return W276C_NO_LIMIT; }
int32_t pipeline_arena_block_cap(void) { return W276C_NO_LIMIT; }
int32_t pipeline_arena_func_cap(void) { return W276C_NO_LIMIT; }

/**
 * Initialize EXPR_VAR slot in Cap 4.2.8 Expr layout (name[256]@32, name_len@288).
 * Oversize name_len (>255) clamps to 255 (content max). call_res_* @1216/1220.
 * PLATFORM: SHARED — wave276 cold twin (#ifndef FROM_X); tip prefer uses .x.
 */
void pipeline_arena_expr_write_var(void *a, int32_t ref, uint8_t *name, int32_t name_len) {
  uint8_t *ep;
  int32_t n, i;
  if (!a || ref <= 0 || !name || name_len <= 0)
    return;
  ep = (uint8_t *)pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  w276_zero(ep, W276C_EX);
  w276_store_i32(ep, 0, 3); /* EXPR_VAR */
  n = name_len;
  if (n > 255)
    n = 255;
  w276_store_i32(ep, 288, n);
  for (i = 0; i < n; i++)
    ep[32 + i] = name[i];
  w276_store_i32(ep, 1216, -1);
  w276_store_i32(ep, 1220, -1);
}
/**
 * Initialize binop expr slot (left@292 right@296; Cap 4.2.8 layout).
 * PLATFORM: SHARED — wave276 cold twin; tip prefer uses .x.
 */
void pipeline_arena_expr_write_binop(void *a, int32_t ref, int32_t kind_ord, int32_t left_ref, int32_t right_ref) {
  uint8_t *ep;
  if (!a || ref <= 0)
    return;
  ep = (uint8_t *)pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  w276_zero(ep, W276C_EX);
  w276_store_i32(ep, 0, kind_ord);
  w276_store_i32(ep, 292, left_ref);
  w276_store_i32(ep, 296, right_ref);
  w276_store_i32(ep, 1216, -1);
  w276_store_i32(ep, 1220, -1);
}
void ast_pipeline_arena_expr_write_var(void *a, int32_t ref, uint8_t *name, int32_t name_len) {
  pipeline_arena_expr_write_var(a, ref, name, name_len);
}
void ast_pipeline_arena_expr_write_binop(void *a, int32_t ref, int32_t kind_ord, int32_t left_ref, int32_t right_ref) {
  pipeline_arena_expr_write_binop(a, ref, kind_ord, left_ref, right_ref);
}

int ast_ref_is_null(int32_t ref) { return ref == 0; }
void ast_expr_layout_prime_call_resolved(void) {}
void ast_ast_arena_init(void *arena) {
  if (!arena)
    return;
  ast_expr_layout_prime_call_resolved();
  w276_store_i32((uint8_t *)arena, 0, 0);
  w276_store_i32((uint8_t *)arena, 4, 0);
  w276_store_i32((uint8_t *)arena, 8, 0);
  w276_store_i32((uint8_t *)arena, 12, 0);
}
int32_t ast_ast_arena_type_alloc(void *a) { return pipeline_arena_type_alloc(a); }
int32_t ast_ast_arena_expr_alloc(void *a) { return pipeline_arena_expr_alloc(a); }
int32_t ast_ast_arena_block_alloc(void *a) { return pipeline_arena_block_alloc(a); }
int32_t ast_ast_arena_func_alloc(void *a) { return pipeline_arena_func_alloc(a); }

#endif /* WAVE276_ARENA_DOMAIN_COLD */
