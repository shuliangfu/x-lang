/*
 * Thin pure: wave279 ast_pool_lifecycle Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE279_LIFECYCLE_DOMAIN_ALWAYS (block_on_alloc / module|arena reset|release /
 * drop_bodies / onefunc reset|release).
 *
 * Independent C thin (Darwin additive-leaf rule). No file-local BSS.
 * Sidecar get/free via wave275; GrowVec free via wave271; module storage
 * reset/release via prior Cap thins.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc lifecycle Cap residual leave.
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
#ifndef W279_NEED_GROWVEC
#define W279_NEED_GROWVEC 1
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;
#endif

/* Product LE: ArenaSidecar 816 / ModuleSidecar 432 / OneFuncSidecar 944 /
 * Block 92 / Func 324 / Arena header 16 / Module header num_funcs@0. */
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
} W279_ArenaSc;

typedef struct {
  void *module_key;
  int used;
  GrowVec funcs;
  GrowVec func_refs;
  GrowVec imports;
  GrowVec struct_layouts;
  GrowVec top_level_lets;
  GrowVec type_aliases;
  GrowVec module_enums;
  GrowVec import_select_name_rows;
  GrowVec import_select_name_lens;
  GrowVec func_params;
  GrowVec struct_layout_fields;
  GrowVec struct_layout_type_params;
  GrowVec struct_layout_type_param_meta;
} W279_ModuleSc;

typedef struct {
  void *onefunc_key;
  int used;
  GrowVec if_cond_refs;
  GrowVec if_then_body_refs;
  GrowVec if_else_body_refs;
  GrowVec const_names;
  GrowVec const_name_lens;
  GrowVec const_init_vals;
  GrowVec const_init_refs;
  GrowVec const_type_refs;
  GrowVec let_names;
  GrowVec let_name_lens;
  GrowVec let_init_vals;
  GrowVec let_init_refs;
  GrowVec let_type_refs;
  GrowVec src_stmt_kind;
  GrowVec src_stmt_idx;
  GrowVec src_body_expr_stmt_refs;
  GrowVec while_cond_refs;
  GrowVec while_body_refs;
  GrowVec for_init_refs;
  GrowVec for_cond_refs;
  GrowVec for_step_refs;
  GrowVec for_body_refs;
  GrowVec param_names;
  GrowVec param_name_lens;
  GrowVec param_type_refs;
  GrowVec call_arg_vals;
  GrowVec regions;
  GrowVec defer_body_refs;
  GrowVec labeleds;
} W279_OneFuncSc;

typedef struct {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
} W279_ArenaHdr;

typedef struct {
  int32_t num_funcs;
} W279_ModuleHdr;

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
} W279_Block;

/* Func LE 324: name[256]@0 … body_ref@276 body_expr_ref@280. */
enum {
  W279_FUNC_SZ = 324,
  W279_FUNC_BODY_REF_OFF = 148,
  W279_FUNC_BODY_EXPR_REF_OFF = 152
};

/* Cap faces — match WAVE277/278 decls (GrowVec*; no void* redecl conflict). */
extern void *arena_sidecar_get(void *key, int create);
extern void arena_sidecar_free(void *sc);
extern void *module_sidecar_get(void *key, int create);
extern void module_sidecar_free(void *sc);
extern void *onefunc_sidecar_get(void *out, int create);
extern void onefunc_sidecar_free(void *sc);
extern void *grow_vec_at(GrowVec *v, int32_t idx);
extern void grow_vec_free(GrowVec *v);
extern char *link_abi_getenv(const char *name);

extern void pipeline_module_type_alias_storage_reset(void *m);
extern void pipeline_module_enum_storage_reset(void *m);
extern void pipeline_module_top_level_let_storage_reset(void *m);
extern void pipeline_module_struct_layout_storage_reset(void *m);
extern void pipeline_module_import_storage_release(void *m);
extern void pipeline_module_type_alias_storage_release(void *m);
extern void pipeline_module_enum_storage_release(void *m);
extern void pipeline_module_top_level_let_storage_release(void *m);
extern void pipeline_module_struct_layout_storage_release(void *m);

static void *w279_arena_block_ptr(void *a, int32_t br) {
  W279_ArenaSc *sc;
  W279_ArenaHdr *ah;
  if (!a || br <= 0)
    return NULL;
  ah = (W279_ArenaHdr *)a;
  if (br > ah->num_blocks)
    return NULL;
  sc = (W279_ArenaSc *)arena_sidecar_get(a, 0);
  if (!sc || br > sc->blocks.len)
    return NULL;
  return grow_vec_at(&sc->blocks, br - 1);
}

static void *w279_module_func_at(void *m, int32_t idx) {
  W279_ModuleSc *sc;
  W279_ModuleHdr *mh;
  if (!m || idx < 0)
    return NULL;
  mh = (W279_ModuleHdr *)m;
  if (idx >= mh->num_funcs)
    return NULL;
  sc = (W279_ModuleSc *)module_sidecar_get(m, 0);
  if (!sc || idx >= sc->funcs.len)
    return NULL;
  return grow_vec_at(&sc->funcs, idx);
}

/**
 * New Block alloc hook: zero slot + record GrowVec base indices.
 * PLATFORM: SHARED — called from pure/cold pipeline_arena_block_alloc.
 */
void ast_pool_block_on_alloc(void *a, int32_t block_ref) {
  W279_ArenaSc *sc;
  W279_Block *b;
  W279_ArenaHdr *ah;
  if (!a || block_ref <= 0)
    return;
  sc = (W279_ArenaSc *)arena_sidecar_get(a, 1);
  if (!sc)
    return;
  ah = (W279_ArenaHdr *)a;
  if (block_ref > ah->num_blocks || block_ref > sc->blocks.len)
    return;
  b = (W279_Block *)grow_vec_at(&sc->blocks, block_ref - 1);
  if (!b)
    return;
  memset(b, 0, sizeof(*b));
  b->const_base = sc->consts.len;
  b->let_base = sc->lets.len;
  b->loop_base = sc->loops.len;
  b->for_loop_base = sc->for_loops.len;
  b->if_base = sc->ifs.len;
  b->region_base = sc->regions.len;
  b->defer_base = sc->defer_block_refs.len;
  b->labeled_base = sc->labeled_stmts.len;
  b->expr_stmt_base = sc->expr_stmt_refs.len;
  b->stmt_order_base = sc->stmt_order.len;
}

/**
 * Soft-reset ModuleSidecar pools before re-parse of the same Module*.
 * PLATFORM: SHARED — also soft-resets pure multi-module maps (type_alias/enum/…).
 */
void ast_pool_module_reset(void *m) {
  W279_ModuleSc *sc;
  if (!m)
    return;
  sc = (W279_ModuleSc *)module_sidecar_get(m, 0);
  if (!sc)
    return;
  sc->funcs.len = 0;
  sc->func_refs.len = 0;
  sc->imports.len = 0;
  sc->struct_layouts.len = 0;
  pipeline_module_struct_layout_storage_reset(m);
  sc->top_level_lets.len = 0;
  pipeline_module_top_level_let_storage_reset(m);
  sc->type_aliases.len = 0;
  pipeline_module_type_alias_storage_reset(m);
  sc->module_enums.len = 0;
  pipeline_module_enum_storage_reset(m);
  sc->import_select_name_rows.len = 0;
  sc->import_select_name_lens.len = 0;
  sc->func_params.len = 0;
  sc->struct_layout_fields.len = 0;
  sc->struct_layout_type_params.len = 0;
  sc->struct_layout_type_param_meta.len = 0;
}

/**
 * Soft-reset ArenaSidecar pools before re-parse of the same ASTArena*.
 * PLATFORM: SHARED.
 */
void ast_pool_arena_reset(void *a) {
  W279_ArenaSc *sc;
  if (!a)
    return;
  sc = (W279_ArenaSc *)arena_sidecar_get(a, 0);
  if (!sc)
    return;
  sc->types.len = 0;
  sc->exprs.len = 0;
  sc->blocks.len = 0;
  sc->funcs.len = 0;
  sc->consts.len = 0;
  sc->lets.len = 0;
  sc->ifs.len = 0;
  sc->regions.len = 0;
  sc->loops.len = 0;
  sc->for_loops.len = 0;
  sc->defer_block_refs.len = 0;
  sc->labeled_stmts.len = 0;
  sc->expr_stmt_refs.len = 0;
  sc->stmt_order.len = 0;
  sc->expr_call_arg_refs.len = 0;
  sc->expr_call_type_arg_refs.len = 0;
  sc->expr_call_type_arg_bases.len = 0;
  sc->type_type_arg_refs.len = 0;
  sc->type_type_arg_bases.len = 0;
  sc->type_type_arg_counts.len = 0;
  sc->expr_method_call_arg_refs.len = 0;
  sc->expr_match_arms.len = 0;
  sc->expr_struct_lit_fields.len = 0;
  sc->expr_array_lit_elem_refs.len = 0;
  sc->func_params.len = 0;
}

/**
 * Hard-free ArenaSidecar GrowVec buffers + mark slot free (wave275 pure table).
 * PLATFORM: SHARED — call before free(arena).
 */
void ast_pool_arena_release(void *a) {
  W279_ArenaSc *sc;
  if (!a)
    return;
  sc = (W279_ArenaSc *)arena_sidecar_get(a, 0);
  if (sc)
    arena_sidecar_free(sc);
}

/**
 * Hard-free pure maps + ModuleSidecar (wave275 pure table).
 * PLATFORM: SHARED — call before free(module).
 */
void ast_pool_module_release(void *m) {
  W279_ModuleSc *sc;
  if (!m)
    return;
  pipeline_module_import_storage_release(m);
  pipeline_module_type_alias_storage_release(m);
  pipeline_module_enum_storage_release(m);
  pipeline_module_top_level_let_storage_release(m);
  pipeline_module_struct_layout_storage_release(m);
  sc = (W279_ModuleSc *)module_sidecar_get(m, 0);
  if (sc)
    module_sidecar_free(sc);
}

/**
 * Drop body AST pools after dep parse_only (check RSS). Keep types + func_params
 * + module Func headers; null body_ref/body_expr_ref. PLATFORM: SHARED.
 */
void ast_pool_drop_bodies_for_check(void *a, void *m) {
  W279_ArenaSc *sc;
  W279_ModuleHdr *mh;
  int32_t i, n;
  size_t freed_approx = 0;
  int32_t n_expr = 0, n_block = 0, n_type = 0;
  uint8_t *fb;

  if (m) {
    mh = (W279_ModuleHdr *)m;
    n = mh->num_funcs;
    for (i = 0; i < n; i++) {
      fb = (uint8_t *)w279_module_func_at(m, i);
      if (!fb)
        continue;
      fb[W279_FUNC_BODY_REF_OFF] = 0;
      fb[W279_FUNC_BODY_REF_OFF + 1] = 0;
      fb[W279_FUNC_BODY_REF_OFF + 2] = 0;
      fb[W279_FUNC_BODY_REF_OFF + 3] = 0;
      fb[W279_FUNC_BODY_EXPR_REF_OFF] = 0;
      fb[W279_FUNC_BODY_EXPR_REF_OFF + 1] = 0;
      fb[W279_FUNC_BODY_EXPR_REF_OFF + 2] = 0;
      fb[W279_FUNC_BODY_EXPR_REF_OFF + 3] = 0;
    }
  }
  if (!a)
    return;
  sc = (W279_ArenaSc *)arena_sidecar_get(a, 0);
  if (!sc)
    return;
  n_expr = sc->exprs.len;
  n_block = sc->blocks.len;
  n_type = sc->types.len;
  freed_approx += (size_t)sc->exprs.cap * sc->exprs.elem_sz;
  freed_approx += (size_t)sc->blocks.cap * sc->blocks.elem_sz;
  freed_approx += (size_t)sc->consts.cap * sc->consts.elem_sz;
  freed_approx += (size_t)sc->lets.cap * sc->lets.elem_sz;
  freed_approx += (size_t)sc->ifs.cap * sc->ifs.elem_sz;
  freed_approx += (size_t)sc->regions.cap * sc->regions.elem_sz;
  freed_approx += (size_t)sc->loops.cap * sc->loops.elem_sz;
  freed_approx += (size_t)sc->for_loops.cap * sc->for_loops.elem_sz;
  freed_approx += (size_t)sc->stmt_order.cap * sc->stmt_order.elem_sz;
  freed_approx += (size_t)sc->expr_call_arg_refs.cap * sc->expr_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_method_call_arg_refs.cap * sc->expr_method_call_arg_refs.elem_sz;
  freed_approx += (size_t)sc->expr_match_arms.cap * sc->expr_match_arms.elem_sz;
  freed_approx += (size_t)sc->expr_struct_lit_fields.cap * sc->expr_struct_lit_fields.elem_sz;
  grow_vec_free(&sc->exprs);
  grow_vec_free(&sc->blocks);
  grow_vec_free(&sc->consts);
  grow_vec_free(&sc->lets);
  grow_vec_free(&sc->ifs);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->loops);
  grow_vec_free(&sc->for_loops);
  grow_vec_free(&sc->defer_block_refs);
  grow_vec_free(&sc->labeled_stmts);
  grow_vec_free(&sc->expr_stmt_refs);
  grow_vec_free(&sc->stmt_order);
  grow_vec_free(&sc->expr_call_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_refs);
  grow_vec_free(&sc->expr_call_type_arg_bases);
  grow_vec_free(&sc->expr_method_call_arg_refs);
  grow_vec_free(&sc->expr_match_arms);
  grow_vec_free(&sc->expr_struct_lit_fields);
  grow_vec_free(&sc->expr_array_lit_elem_refs);
  {
    W279_ArenaHdr *ah = (W279_ArenaHdr *)a;
    ah->num_exprs = 0;
    ah->num_blocks = 0;
  }
  /* PLATFORM: SHARED — return freed pages so check peak RSS is max(dep) not sum. */
#if defined(__APPLE__)
  {
    extern void *malloc_default_zone(void);
    extern size_t malloc_zone_pressure_relief(void *zone, size_t goal);
    (void)malloc_zone_pressure_relief(malloc_default_zone(), 0);
  }
#elif defined(__linux__)
  {
    extern int malloc_trim(size_t pad) __attribute__((weak));
    if (malloc_trim)
      (void)malloc_trim(0);
  }
#endif
  if (link_abi_getenv("XLANG_DEBUG_CHECK_MEM")) {
    pabi_trace(
            "xlang: [CHECK_MEM] drop_bodies arena=%p n_expr=%d n_block=%d n_type=%d "
            "n_func=%d freed_body_approx=%zuMB\n",
            a, (int)n_expr, (int)n_block, (int)n_type,
            m ? (int)((W279_ModuleHdr *)m)->num_funcs : -1, freed_approx / (1024 * 1024));
  }
}

/**
 * Soft-reset OneFuncSidecar scratch pools.
 * PLATFORM: SHARED — parser onefunc reuse path.
 */
void ast_pool_onefunc_reset(uint8_t *out) {
  W279_OneFuncSc *sc;
  if (!out)
    return;
  sc = (W279_OneFuncSc *)onefunc_sidecar_get(out, 0);
  if (!sc)
    return;
  sc->if_cond_refs.len = 0;
  sc->if_then_body_refs.len = 0;
  sc->if_else_body_refs.len = 0;
  sc->const_names.len = 0;
  sc->const_name_lens.len = 0;
  sc->const_init_vals.len = 0;
  sc->const_init_refs.len = 0;
  sc->const_type_refs.len = 0;
  sc->let_names.len = 0;
  sc->let_name_lens.len = 0;
  sc->let_init_vals.len = 0;
  sc->let_init_refs.len = 0;
  sc->let_type_refs.len = 0;
  sc->src_stmt_kind.len = 0;
  sc->src_stmt_idx.len = 0;
  sc->src_body_expr_stmt_refs.len = 0;
  sc->while_cond_refs.len = 0;
  sc->while_body_refs.len = 0;
  sc->for_init_refs.len = 0;
  sc->for_cond_refs.len = 0;
  sc->for_step_refs.len = 0;
  sc->for_body_refs.len = 0;
  sc->param_names.len = 0;
  sc->param_name_lens.len = 0;
  sc->param_type_refs.len = 0;
  sc->call_arg_vals.len = 0;
  sc->regions.len = 0;
  sc->defer_body_refs.len = 0;
  sc->labeleds.len = 0;
}

/**
 * Hard-free OneFuncSidecar (wave275 pure table).
 * PLATFORM: SHARED.
 */
void ast_pool_onefunc_release(uint8_t *out) {
  W279_OneFuncSc *sc;
  if (!out)
    return;
  sc = (W279_OneFuncSc *)onefunc_sidecar_get(out, 0);
  if (sc)
    onefunc_sidecar_free(sc);
}

/* XLANG_PABI_LIFECYCLE_THIN_END */
