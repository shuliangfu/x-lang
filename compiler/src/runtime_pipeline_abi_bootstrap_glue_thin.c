/*
 * Thin pure: wave282 ast_pool_bootstrap_glue Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE282_BOOTSTRAP_GLUE_ALWAYS (typeck_i32_ptr_* / layout_metrics / asm scope
 * BSS / asm_local_slot_reg_offset + align/bump/simd/scoped / patch_parent_links /
 * dep_skip cluster / redirect_std_c_wrapper).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS:
 *   g_w282_asm_scope_sc[W282_MAX_ASM_LOCALS_SIDECARS].
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc bootstrap_glue Cap residual leave;
 * MACOS|ARM64 vs LINUX|x86_64 slot polarity via __aarch64__/__arm64__.
 */

#include <string.h>
#include <stdint.h>
#include <stddef.h>

/* Prefer void* signatures (match pure faces / earlier ALWAYS blocks). */
extern int32_t *typeck_layout_metrics_sz_slot(void);
extern int32_t *typeck_layout_metrics_al_slot(void);
extern int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth);
extern int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth);
extern int32_t pipeline_type_kind_ord_at(void *a, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(void *a, int32_t type_ref);
extern void *pipeline_arena_type_ptr(void *a, int32_t type_ref);
extern int32_t pipeline_arena_num_types(void *a);
extern int32_t asm_local_slot_bytes(void *arena, int32_t type_ref);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern int32_t asm_ctx_local_count(uint8_t *ctx);
extern int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx);
extern void asm_ctx_local_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *out);
extern int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t func_index);
extern void pipeline_patch_block_parent_links(void *a, int32_t block_ref, int32_t parent_ref);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path);
/* Wave277 Cap faces (block_domain_thin) — scoped local offset walk. */
extern int32_t ast_ast_block_num_consts(void *a, int32_t br);
extern int32_t ast_ast_block_num_lets(void *a, int32_t br);

/* Forward decls (definition order). */
static int32_t asm_type_align_for_local(void *arena, int32_t type_ref, int32_t depth);
int32_t asm_bump_off_align_for_local(void *arena, int32_t type_ref, int32_t off);
int32_t asm_bump_off_before_struct_local(void *arena, int32_t type_ref, int32_t off);
int32_t asm_type_is_simd_vector(void *arena, int32_t type_ref);
int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);

void typeck_i32_ptr_store(int32_t *p, int32_t v) {
  if (p)
    *p = v;
}

int32_t typeck_i32_ptr_read(int32_t *p) {
  return p ? *p : 0;
}

void typeck_layout_metrics_init_depth(int32_t depth) {
  int32_t *sz = typeck_layout_metrics_sz_slot_depth(depth);
  int32_t *al = typeck_layout_metrics_al_slot_depth(depth);
  if (sz)
    *sz = 0;
  if (al)
    *al = 1;
}

int32_t typeck_layout_metrics_al_read_depth(int32_t depth) {
  return *typeck_layout_metrics_al_slot_depth(depth);
}

int32_t typeck_layout_metrics_sz_read_depth(int32_t depth) {
  return *typeck_layout_metrics_sz_slot_depth(depth);
}

void typeck_layout_metrics_init_slot(void) {
  *typeck_layout_metrics_sz_slot() = 0;
  *typeck_layout_metrics_al_slot() = 1;
}

typedef struct {
  void *ctx;
  int used;
  int32_t scope_block_ref;
} W282_AsmScopeSidecar;

#ifndef W282_MAX_ASM_LOCALS_SIDECARS
#define W282_MAX_ASM_LOCALS_SIDECARS 64
#endif

static W282_AsmScopeSidecar g_w282_asm_scope_sc[W282_MAX_ASM_LOCALS_SIDECARS];

static W282_AsmScopeSidecar *w282_asm_scope_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < W282_MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_w282_asm_scope_sc[i].used && g_w282_asm_scope_sc[i].ctx == (void *)ctx)
      return &g_w282_asm_scope_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < W282_MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_w282_asm_scope_sc[i].used) {
      g_w282_asm_scope_sc[i].ctx = (void *)ctx;
      g_w282_asm_scope_sc[i].used = 1;
      g_w282_asm_scope_sc[i].scope_block_ref = 0;
      return &g_w282_asm_scope_sc[i];
    }
  }
  return NULL;
}

void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref) {
  W282_AsmScopeSidecar *sc = w282_asm_scope_sidecar_get(ctx, 1);
  if (sc)
    sc->scope_block_ref = block_ref;
}

int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx) {
  W282_AsmScopeSidecar *sc = w282_asm_scope_sidecar_get(ctx, 0);
  return sc ? sc->scope_block_ref : 0;
}

static int32_t asm_type_align_for_local(void *arena, int32_t type_ref, int32_t depth) {
  int32_t kind;
  if (!arena || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena) || depth > 64)
    return 8;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if (kind == 2)
    return 1;
  if (kind == 0 || kind == 3 || kind == 1 || kind == 14)
    return 4;
  if (kind == 13)
    return 16;
  if (kind == 5 || kind == 4 || kind == 6 || kind == 7 || kind == 15 || kind == 9 || kind == 11)
    return 8;
  if (kind == 10 || kind == 12) {
    int32_t elem = pipeline_type_elem_ref_at(arena, type_ref);
    return elem > 0 ? asm_type_align_for_local(arena, elem, depth + 1) : 1;
  }
  if (kind == 8)
    return 4;
  return 8;
}

int32_t asm_bump_off_align_for_local(void *arena, int32_t type_ref, int32_t off) {
  int32_t al = asm_type_align_for_local(arena, type_ref, 0);
  if (al <= 0)
    al = 8;
  return (off + al - 1) / al * al;
}

int32_t asm_type_is_simd_vector(void *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena))
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == 13 ? 1 : 0;
}

int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref) {
  /* Type LE (Cap 4.2.8): kind@0 name[256]@4 name_len@260. */
  uint8_t *t;
  int32_t kind;
  int32_t nlen;
  uint8_t *name;
  if (!arena || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena))
    return 0;
  if (asm_type_is_simd_vector(arena, type_ref))
    return 1;
  t = (uint8_t *)pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return 0;
  memcpy(&kind, t + 0, 4);
  /* Cap 4.2.8 Type LE: name[256]@4 => name_len@260 (was 132 on name[128]).
   * The stale +132 read garbage after the widen, so every NAMED SIMD
   * spelling (i32x4, i32x8, u32x series, f32x4, Vec4f, Vec8i) compared
   * against a garbage nlen and this predicate returned 0 — vector INDEX
   * and let-init classification silently degraded (Ubuntu vec_add_verify,
   * 2026-09-13). */
  memcpy(&nlen, t + 260, 4);
  if (kind != 8 || nlen <= 0)
    return 0;
  name = t + 4;
  if (nlen == 5 && memcmp(name, "i32x4", 5) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "i32x8", 5) == 0)
    return 1;
  if (nlen == 6 && memcmp(name, "i32x16", 6) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "u32x4", 5) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "u32x8", 5) == 0)
    return 1;
  if (nlen == 6 && memcmp(name, "u32x16", 6) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "f32x4", 5) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "f32x8", 5) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "Vec4f", 5) == 0)
    return 1;
  if (nlen == 5 && memcmp(name, "Vec8i", 5) == 0)
    return 1;
  return 0;
}

int32_t asm_bump_off_before_struct_local(void *arena, int32_t type_ref, int32_t off) {
  int32_t kind;
  if (!arena || type_ref <= 0)
    return off;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if ((kind == 13 || asm_type_is_simd_vector_spelling(arena, type_ref)) && (off % 16) != 0)
    return (off + 15) / 16 * 16;
  if (kind == 8 && (off % 16) != 0)
    return (off + 15) / 16 * 16;
  return off;
}

/*
 * PLATFORM: SHARED layout math; polarity differs by host product ISA:
 * - LINUX|x86_64: slot_off = off + sz (high-end home for [rbp−slot_off])
 * - MACOS|ARM64: slot_off = off (low-end home for [x29+off])
 */
int32_t asm_local_slot_reg_offset(void *arena, int32_t type_ref, int32_t off, int32_t *inout_off) {
  int32_t sz;
  int32_t slot_off;
  off = asm_bump_off_before_struct_local(arena, type_ref, off);
  off = asm_bump_off_align_for_local(arena, type_ref, off);
  sz = asm_local_slot_bytes(arena, type_ref);
  if (sz <= 0)
    sz = 8;
#if defined(__aarch64__) || defined(__arm64__)
  slot_off = off;
  if (inout_off)
    *inout_off = off + sz;
#else
  slot_off = off + sz;
  if (inout_off)
    *inout_off = off + sz;
#endif
  return slot_off;
}

/*
 * Resolve local name within the current emit scope block.
 *
 * PLATFORM: SHARED — pure-asm VAR load / return of block-local lets.
 *
 * Root (Stage 12.0.5 labi_ensure_list hybrid RED): fill_block_locals_tree
 * pre-order-appends sibling if-then blocks into one name table. Scanning
 * from count-1 down to min_slot (this block's base) still sees later
 * siblings' same-name lets. Multi-branch
 *   if (i==0) { let p = "a"; return p; }
 *   if (i==1) { let p = "b"; return p; }
 * then stores into per-branch slots but every `return p` loads the last
 * registered "p" (or the first when fill order is reversed) → catalog_stem
 * returns wrong path strings → ensure/prepare BLD001 on pure freestanding.
 *
 * Fix: only search this block's direct const/let range
 *   [min_slot, min_slot + nconst + nlet). Nested children have their own
 * block_slot bases and are not included. Fallback: unscoped find_offset
 * (back-to-front) for outer-scope names.
 */
int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, void *arena, uint8_t *name, int32_t name_len) {
  int32_t scope_blk;
  int32_t min_slot;
  int32_t end_slot;
  int32_t nconst;
  int32_t nlet;
  int32_t count;
  scope_blk = asm_ctx_scope_block_ref_at(ctx);
  if (scope_blk <= 0)
    return asm_ctx_local_find_offset(ctx, name, name_len);
  min_slot = asm_ctx_block_slot_get(ctx, scope_blk);
  if (min_slot < 0)
    return asm_ctx_local_find_offset(ctx, name, name_len);
  nconst = 0;
  nlet = 0;
  if (arena) {
    nconst = ast_ast_block_num_consts(arena, scope_blk);
    nlet = ast_ast_block_num_lets(arena, scope_blk);
  }
  if (nconst < 0)
    nconst = 0;
  if (nlet < 0)
    nlet = 0;
  end_slot = min_slot + nconst + nlet;
  count = asm_ctx_local_count(ctx);
  if (end_slot > count)
    end_slot = count;
  {
    int32_t i;
    int32_t off;
    for (i = end_slot - 1; i >= min_slot; i--) {
      uint8_t nb[256];
      int32_t nlen;
      int32_t k;
      nlen = asm_ctx_local_name_len(ctx, i);
      if (nlen != name_len)
        continue;
      asm_ctx_local_name_copy64(ctx, i, nb);
      for (k = 0; k < name_len; k++) {
        if (nb[k] != name[k])
          break;
      }
      if (k == name_len) {
        off = asm_ctx_local_offset_at(ctx, i);
        return off;
      }
    }
  }
  return asm_ctx_local_find_offset(ctx, name, name_len);
}

void pipeline_asm_patch_module_parent_links(void *m, void *a) {
  int32_t i;
  int32_t n;
  int32_t body;
  if (!m || !a)
    return;
  n = pipeline_module_num_funcs(m);
  for (i = 0; i < n; i++) {
    body = pipeline_module_func_body_ref_at(m, i);
    if (body > 0)
      pipeline_patch_block_parent_links(a, body, 0);
  }
}

int32_t pipeline_codegen_dep_skip_asm_user_std_fs(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.fs", 6) != 0)
    return 0;
  return (path[6] == 0 || path[6] == '.') ? 1 : 0;
}

int32_t pipeline_codegen_dep_skip_asm_user_std_process(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.process", 11) != 0)
    return 0;
  return (path[11] == 0 || path[11] == '.') ? 1 : 0;
}

int32_t pipeline_codegen_dep_skip_asm_user_std_fmt(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.fmt", 7) != 0)
    return 0;
  return (path[7] == 0 || path[7] == '.') ? 1 : 0;
}

int32_t pipeline_codegen_dep_skip_asm_user_std_misc(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.error", 9) == 0 && (path[9] == 0 || path[9] == '.'))
    return 1;
  if (memcmp(path, "std.context", 11) == 0 && (path[11] == 0 || path[11] == '.'))
    return 1;
  /* std.simd: simd.o formal_surface is link authority (skip co-emit mod.x). PLATFORM: SHARED. */
  if (memcmp(path, "std.simd", 8) == 0 && (path[8] == 0 || path[8] == '.'))
    return 1;
  return 0;
}

int32_t pipeline_codegen_dep_skip_asm_user_core_lib(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "core.fmt", 8) == 0 && (path[8] == 0 || path[8] == '.'))
    return 1;
  if (memcmp(path, "core.types", 10) == 0 && (path[10] == 0 || path[10] == '.'))
    return 1;
  if (memcmp(path, "core.option", 11) == 0 && (path[11] == 0 || path[11] == '.'))
    return 1;
  if (memcmp(path, "core.result", 11) == 0 && (path[11] == 0 || path[11] == '.'))
    return 1;
  return 0;
}

/**
 * In-tree core.* modules under repo core/ (formal .o / on-demand needles).
 * Scratch dotted deps that only *look* like core.* (e.g. /tmp core.m6) are
 * not listed: they must co-emit or ld leaves UN _core_*.
 * Not the typeck skip set — pipeline_codegen_dep_skip_asm_user_core_lib stays
 * the 4-name parse/typeck skip (expanding it would skip dep typeck and
 * regress layout / parent-link).
 * PLATFORM: SHARED — Darwin -dead_strip hides unused UN _core_* on the
 * product path; scratch probes that CALL the dep still fail.
 */
int32_t pipeline_asm_user_dep_is_in_tree_core(uint8_t *path) {
  static const char *const k[] = {
      "core.assert", "core.builtin", "core.cmp", "core.debug", "core.fmt",
      "core.iterator", "core.mem", "core.option", "core.result", "core.slice",
      "core.str", "core.types", NULL};
  int i;
  size_t n;
  size_t plen;
  if (!path || !path[0])
    return 0;
  plen = 0;
  while (plen < 64 && path[plen] != 0)
    plen++;
  for (i = 0; k[i]; i++) {
    n = strlen(k[i]);
    if (n > plen)
      continue;
    if (memcmp(path, k[i], n) == 0 && (n == plen || path[n] == '.' || path[n] == 0))
      return 1;
  }
  return 0;
}

int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path) {
  if (!path)
    return 0;
  if (memcmp(path, "std.net", 7) != 0)
    return 0;
  return (path[7] == 0 || path[7] == '.') ? 1 : 0;
}

int32_t pipeline_asm_user_deps_need_coemit(char **dep_paths, int32_t n) {
  int32_t i;
  if (!dep_paths || n <= 0)
    return 0;
  for (i = 0; i < n; i++) {
    uint8_t *p = (uint8_t *)(dep_paths[i] ? dep_paths[i] : "");
    /* Hosted std.* / std/ still skip co-emit (prebuilt .o / on-demand).
     * File paths (std/compress/mod.x, ../std/...) must not co-emit: Ubuntu
     * then emits s.hdr.inited as movq to offset 0, wiping gzip magic so
     * stream process returns -1. Darwin c_face + gzip.o stores str w #0xc.
     * PLATFORM: SHARED */
    if (memcmp(p, "std.", 4) == 0)
      continue;
    if (memcmp(p, "std/", 4) == 0)
      continue;
    if (strstr((const char *)p, "/std/") != NULL)
      continue;
    /* Only in-tree core/ — scratch core.m6 etc. must co-emit (UN _core_*). */
    if (pipeline_asm_user_dep_is_in_tree_core(p) != 0)
      continue;
    return 1;
  }
  return 0;
}

int32_t pipeline_asm_user_dep_skip_x_typeck(uint8_t *path) {
  if (!path)
    return 0;
  if (pipeline_codegen_dep_skip_asm_user_std_io(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_fs(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_process(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_fmt(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_std_misc(path) != 0)
    return 1;
  if (pipeline_codegen_dep_skip_asm_user_core_lib(path) != 0)
    return 1;
  if (pipeline_asm_user_std_net_dep_path(path) != 0)
    return 1;
  return 0;
}

void pipeline_asm_seed_std_net_struct_layouts(void *m) {
  (void)m;
}

typedef struct {
  const char *from;
  const char *to;
} w282_std_heap_redirect_t;

static const w282_std_heap_redirect_t kW282GlueStdHeapRedirect[] = {
    {"alloc", "heap_alloc_c"},
    {"alloc_i32", "heap_alloc_i32_c"},
    {"alloc_i32_ret_i32_ptr", "heap_alloc_i32_c"},
    {"alloc_i32_ret_u8_ptr", "heap_alloc_u8_c"},
    {"alloc_i32_ret_u64_ptr", "heap_alloc_u64_c"},
    {"alloc_i32_ret_f64_ptr", "heap_alloc_f64_c"},
    {"alloc_i32_ret_f32_ptr", "heap_alloc_f32_c"},
    {"realloc_i32", "heap_realloc_i32_c"},
    {"realloc_i32_ret_i32_ptr", "heap_realloc_i32_c"},
    {"realloc_u64_ret_u64_ptr", "heap_realloc_u64_c"},
    {"realloc_f64_ret_f64_ptr", "heap_realloc_f64_c"},
    {"realloc_f32_ret_f32_ptr", "heap_realloc_f32_c"},
    {"realloc_u8_ret_u8_ptr", "heap_realloc_u8_c"},
    {"free_i32", "heap_free_i32_c"},
    {"free_i32_ptr", "heap_free_i32_c"},
    {"free_u64_ptr", "heap_free_u64_c"},
    {"free_f64_ptr", "heap_free_f64_c"},
    {"free_f32_ptr", "heap_free_f32_c"},
    {"alloc_u8", "heap_alloc_u8_c"},
    {"realloc_u8", "heap_realloc_u8_c"},
    {"free_u8", "heap_free_u8_c"},
    {"alloc_f32", "heap_alloc_f32_c"},
    {"realloc_f32", "heap_realloc_f32_c"},
    {"free_f32", "heap_free_f32_c"},
    {"copy_i32_at", "heap_copy_i32_at_c"},
    {"copy_u8_at", "heap_copy_u8_at_c"},
    {"copy_f32_at", "heap_copy_f32_at_c"},
    {"copy_u64_at", "heap_copy_u64_at_c"},
    {"copy_f64_at", "heap_copy_f64_at_c"},
    {"copy_i32_ptr_i32_i32_ptr_i32", "heap_copy_i32_at_c"},
    {"copy_u8_ptr_i32_u8_ptr_i32", "heap_copy_u8_at_c"},
    {"copy_f32_ptr_i32_f32_ptr_i32", "heap_copy_f32_at_c"},
    {"copy_u64_ptr_i32_u64_ptr_i32", "heap_copy_u64_at_c"},
    {"copy_f64_ptr_i32_f64_ptr_i32", "heap_copy_f64_at_c"},
    {"arena64_init", "heap_arena64_init_c"},
    {"arena64_alloc", "heap_arena64_alloc_c"},
    {"arena64_deinit", "heap_arena64_deinit_c"},
    {"ptr_mod", "heap_ptr_mod_c"},
};

static int32_t w282_try_std_heap_redirect_sym(const uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                               int32_t out_cap) {
  size_t i;
  for (i = 0; i < sizeof(kW282GlueStdHeapRedirect) / sizeof(kW282GlueStdHeapRedirect[0]); i++) {
    const char *from = kW282GlueStdHeapRedirect[i].from;
    const char *to = kW282GlueStdHeapRedirect[i].to;
    size_t flen = strlen(from);
    size_t tlen = strlen(to);
    if ((int32_t)flen != name_len || memcmp(name, from, flen) != 0)
      continue;
    if ((int32_t)tlen + 1 > out_cap)
      return 0;
    memcpy(sym_out, to, tlen);
    return (int32_t)tlen;
  }
  return 0;
}

int32_t pipeline_asm_redirect_std_c_wrapper_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t out_cap) {
  int32_t hlen;
  if (!name || name_len <= 0 || !sym_out || out_cap <= 0)
    return 0;
  if (name_len >= 2 && name[name_len - 2] == '_' && name[name_len - 1] == 'c')
    return 0;
  hlen = w282_try_std_heap_redirect_sym(name, name_len, sym_out, out_cap);
  if (hlen > 0)
    return hlen;
  if (name_len + 2 >= out_cap)
    return 0;
  if (name_len >= 3 && memcmp(name, "fs_", 3) == 0) {
    memcpy(sym_out, name, (size_t)name_len);
    sym_out[name_len] = '_';
    sym_out[name_len + 1] = 'c';
    return name_len + 2;
  }
  if (name_len >= 4 && memcmp(name, "net_", 4) == 0) {
    memcpy(sym_out, name, (size_t)name_len);
    sym_out[name_len] = '_';
    sym_out[name_len + 1] = 'c';
    return name_len + 2;
  }
  if (name_len == 9 && memcmp(name, "print_str", 9) == 0) {
    memcpy(sym_out, "std_io_print_str", 16);
    return 16;
  }
  if (name_len == 13 && memcmp(name, "std_fmt_print", 13) == 0) {
    memcpy(sym_out, "std_fmt_print", 13);
    return 13;
  }
  if (name_len == 24 && memcmp(name, "std_fmt_print_u8_ptr_i32", 24) == 0) {
    memcpy(sym_out, "std_fmt_print", 13);
    return 13;
  }
  /* PLATFORM: SHARED — std_fmt_println is 15 bytes (len 14 truncated to std_fmt_printl
   * → pure-asm print_str BLD001). Redirect overload mid to bare stub symbol. */
  if (name_len == 15 && memcmp(name, "std_fmt_println", 15) == 0) {
    memcpy(sym_out, "std_fmt_println", 15);
    return 15;
  }
  if (name_len == 26 && memcmp(name, "std_fmt_println_u8_ptr_i32", 26) == 0) {
    memcpy(sym_out, "std_fmt_println", 15);
    return 15;
  }
  if (name_len > 13 && memcmp(name, "std_encoding_", 13) == 0) {
    const int32_t suffix_len = name_len - 13;
    const int32_t out_len = 9 + suffix_len + 2;
    if (out_len >= out_cap)
      return 0;
    memcpy(sym_out, "encoding_", 9);
    memcpy(sym_out + 9, name + 13, (size_t)suffix_len);
    sym_out[9 + suffix_len] = '_';
    sym_out[9 + suffix_len + 1] = 'c';
    return out_len;
  }
  if (name_len > 11 && memcmp(name, "std_string_", 11) == 0) {
    const int32_t suffix_len = name_len - 11;
    if (suffix_len + 1 > out_cap)
      return 0;
    if (suffix_len >= 12 && memcmp(name + 11, "xlang_string_", 12) == 0) {
      memcpy(sym_out, name + 11, (size_t)suffix_len);
      return suffix_len;
    }
  }
  return 0;
}

/* XLANG_PABI_BOOTSTRAP_GLUE_THIN_END */
