/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE glue_call_return unique */

/*
 * wave194 cold twin: CALL expr return byte size (G.7 pure leave).
 * glue_call_return unique extracted above with the real .x body; leftover rest
 * does not compile the seed stub. Remaining wave195+ stay closed on leftover
 * rest (not unique). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL return sizing.
 */

/*
 * wave195 cold twin: CALL-arg value byte size (G.7 pure leave).
 * Freestanding-safe stub. Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL-arg value sizing.
 */
int32_t pipeline_asm_call_arg_value_byte_size_c(void *arena, void *ctx, int32_t arg_ref, int32_t pty) {
  (void)arena;
  (void)ctx;
  (void)arg_ref;
  (void)pty;
  return 8;
}

/*
 * wave196 cold twin: CALL return TypeKind ordinal (G.7 pure leave).
 * Freestanding-safe stub (-1 = resolve fail / unknown). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL return kind (SSE vs GP harvest).
 */
int32_t pipeline_asm_call_return_type_kind_ord_c(void *arena, int32_t call_expr_ref) {
  (void)arena;
  (void)call_expr_ref;
  return -1;
}

/*
 * wave197 cold twin: struct16 *rax → dual-GP load (G.7 pure leave).
 * Freestanding-safe stub (-1 = enc fail). Hybrid product links pure.
 * PLATFORM: SHARED freestanding struct16 sret materialize.
 */
int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx;
  (void)ta;
  return -1;
}

/*
 * wave197 cold twin: struct16 CALL retval sret-vs-dual-GP classifier (G.7 pure leave).
 * Freestanding-safe stub (0 = dual-GP default). Hybrid product links pure.
 * PLATFORM: SHARED freestanding struct16 classifier.
 */
int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(void *arena, int32_t call_expr_ref) {
  (void)arena;
  (void)call_expr_ref;
  return 0;
}

/*
 * wave198 cold twin: CALL formal param type_ref in caller arena (G.7 pure leave).
 * Freestanding-safe stub (0 = unresolved). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL formal type_ref.
 */
int32_t pipeline_asm_call_param_type_ref_at_c(void *arena, int32_t call_expr_ref,
                                               int32_t param_index) {
  (void)arena;
  (void)call_expr_ref;
  (void)param_index;
  return 0;
}

/*
 * wave199 cold twin: CALL-target module/func_index resolve (G.7 pure leave).
 * Freestanding-safe stub (-1 = resolve fail). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL resolve · import BINDING/SELECT.
 */
int32_t glue_asm_resolve_call_target_module_c(void *arena, int32_t call_expr_ref,
                                               void **mod_out, int32_t *func_ix_out,
                                               int32_t *dep_ix_out) {
  (void)arena;
  (void)call_expr_ref;
  if (mod_out)
    *mod_out = 0;
  if (func_ix_out)
    *func_ix_out = -1;
  if (dep_ix_out)
    *dep_ix_out = -1;
  return -1;
}

/*
 * wave200 cold twins: f32 VAR slot load to rax/rbx (G.7 pure leave).
 * Freestanding-safe stubs (-1 = enc fail). Hybrid product links pure.
 * PLATFORM: SHARED freestanding f32 slot · LINUX+MACOS SysV xmm home.
 */
int32_t glue_load_f32_var_slot_to_rax_elf_c(void *elf_ctx, void *arena, void *ctx,
                                             int32_t var_expr_ref, int32_t off, int32_t ta) {
  (void)elf_ctx;
  (void)arena;
  (void)ctx;
  (void)var_expr_ref;
  (void)off;
  (void)ta;
  return -1;
}

int32_t glue_load_f32_var_slot_to_rbx_elf_c(void *elf_ctx, void *arena, void *ctx,
                                             int32_t var_expr_ref, int32_t off, int32_t ta) {
  (void)elf_ctx;
  (void)arena;
  (void)ctx;
  (void)var_expr_ref;
  (void)off;
  (void)ta;
  return -1;
}

/*
 * wave201 cold twin: SysV f32 xmm param home (G.7 pure leave).
 * Freestanding-safe stub (-1 = enc/home fail). Hybrid product links pure.
 * PLATFORM: LINUX+MACOS x86_64 SysV — f32 xmm split-track param home.
 */
int32_t pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c(void *elf_ctx, void *ctx, void *mod,
                                                        int32_t func_index, int32_t np) {
  (void)elf_ctx;
  (void)ctx;
  (void)mod;
  (void)func_index;
  (void)np;
  return -1;
}

/*
 * wave202 cold twins: MEMORY-by-value CALL-arg push/store (G.7 pure leave).
 * Freestanding-safe stubs (-1 = gate/enc fail). Hybrid product links pure.
 * PLATFORM: LINUX+MACOS x86_64 SysV (push) · MACOS|ARM64 AAPCS64 (store).
 */
int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(void *arena, void *elf_ctx, void *ctx,
                                                      int32_t arg_ref, int32_t sz, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)arg_ref;
  (void)sz;
  (void)ta;
  return -1;
}

int32_t pipeline_asm_store_memory_by_value_to_sp_elf_c(void *arena, void *elf_ctx, void *ctx,
                                                        int32_t arg_ref, int32_t sz, int32_t ta,
                                                        int32_t sp_off) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)arg_ref;
  (void)sz;
  (void)ta;
  (void)sp_off;
  return -1;
}

/*
 * wave203 cold twin: CALL-arg VAR stack_off resolve (G.7 pure leave).
 * Freestanding-safe stub (-1 = unresolved). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL-arg VAR home · SKIP_TYPECK anon let.
 */
int32_t glue_call_arg_resolve_var_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref) {
  (void)arena;
  (void)ctx;
  (void)var_expr_ref;
  return -1;
}

/*
 * wave204 cold twin: store_retval_pair (G.7 pure leave).
 * Freestanding-safe stub (-1 = gate/enc fail). Hybrid product links pure.
 * Private copy_large pure helper has no cold surface (sole pure consumer).
 * PLATFORM: SHARED freestanding CALL/METHOD/STRUCT let-home retval store.
 * Product .x memcpy gate is CALL(48)||METHOD(49); this cold twin is a stub.
 */
int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                            int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx) {
  (void)m;
  (void)arena;
  (void)elf_ctx;
  (void)ty_ref;
  (void)slot_off;
  (void)ta;
  (void)init_ref;
  (void)ctx;
  return -1;
}

/*
 * wave205 cold twin: TYPE_SLICE reent deep-copy after dual-GP (G.7 pure leave).
 * Freestanding-safe stub (-1 = gate/enc fail). Hybrid product links pure.
 * PLATFORM: SHARED freestanding TYPE_SLICE fat reentrancy (use_frame 0/1).
 */
int32_t glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(void *arena, void *elf_ctx, void *ctx,
                                                            int32_t ta, int32_t home, int32_t ty_ref,
                                                            int32_t use_frame) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)ta;
  (void)home;
  (void)ty_ref;
  (void)use_frame;
  return -1;
}

/*
 * wave206 cold twin: CALL expected return type BSS set/get (G.7 pure leave).
 * Working freestanding BSS twin of pure g_call_expected_ret_ty (same clamp).
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding CALL expected-ret tracking.
 */
static int32_t g_wave206_call_expected_ret_ty = 0;

void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref) {
  g_wave206_call_expected_ret_ty = type_ref > 0 ? type_ref : 0;
}

int32_t pipeline_asm_call_expected_ret_ty_c(void) {
  return g_wave206_call_expected_ret_ty;
}

/*
 * wave207 cold twins: CAP BSS thin accessors (G.7 pure leave).
 * Working freestanding BSS twins of pure rax_frame nest + index_scratch depth.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
#define WAVE207_RAX_FRAME_SPILL_CAP 16
static int32_t g_wave207_rax_frame_spill_off[WAVE207_RAX_FRAME_SPILL_CAP];
static int32_t g_wave207_rax_frame_spill_n = 0;
static int32_t g_wave207_index_scratch_stack_depth = 0;

int32_t glue_binop_rax_frame_spill_push(int32_t home) {
  if (g_wave207_rax_frame_spill_n >= WAVE207_RAX_FRAME_SPILL_CAP)
    return -1;
  g_wave207_rax_frame_spill_off[g_wave207_rax_frame_spill_n++] = home;
  return 0;
}

int32_t glue_binop_rax_frame_spill_pop(void) {
  if (g_wave207_rax_frame_spill_n <= 0)
    return -1;
  return g_wave207_rax_frame_spill_off[--g_wave207_rax_frame_spill_n];
}

int32_t glue_binop_rax_frame_spill_depth(void) {
  return g_wave207_rax_frame_spill_n;
}

void glue_binop_rax_frame_spill_n_set(int32_t v) {
  g_wave207_rax_frame_spill_n = v < 0 ? 0 : v;
}

void glue_index_scratch_stack_depth_set(int32_t v) {
  g_wave207_index_scratch_stack_depth = v < 0 ? 0 : v;
}

int32_t glue_index_scratch_stack_depth_get(void) {
  return g_wave207_index_scratch_stack_depth;
}

/*
 * wave208 cold twins: binop stack-spill table BSS + thin accessors (G.7 pure leave).
 * Working freestanding BSS twins of pure stack_spill_off/at_depth/n table.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
#define WAVE208_STACK_SPILL_CAP 12
static int32_t g_wave208_stack_spill_off[WAVE208_STACK_SPILL_CAP];
static int32_t g_wave208_stack_spill_at_depth[WAVE208_STACK_SPILL_CAP];
static int32_t g_wave208_stack_spill_n = 0;

int32_t glue_binop_stack_spill_append_at_depth(int32_t off, int32_t depth) {
  if (g_wave208_stack_spill_n >= WAVE208_STACK_SPILL_CAP)
    return -1;
  g_wave208_stack_spill_off[g_wave208_stack_spill_n] = off;
  g_wave208_stack_spill_at_depth[g_wave208_stack_spill_n] = depth;
  g_wave208_stack_spill_n++;
  return 0;
}

int32_t glue_binop_stack_spill_cap_get(void) {
  return WAVE208_STACK_SPILL_CAP;
}

void glue_binop_stack_spill_clear(void) {
  g_wave208_stack_spill_n = 0;
}

void glue_binop_stack_spill_drop_off(int32_t off) {
  int32_t i;
  int32_t j;
  if (off < 0)
    return;
  for (i = 0; i < g_wave208_stack_spill_n; i++) {
    if (g_wave208_stack_spill_off[i] != off)
      continue;
    for (j = i + 1; j < g_wave208_stack_spill_n; j++) {
      g_wave208_stack_spill_off[j - 1] = g_wave208_stack_spill_off[j];
      g_wave208_stack_spill_at_depth[j - 1] = g_wave208_stack_spill_at_depth[j];
    }
    g_wave208_stack_spill_n--;
    return;
  }
}

int32_t glue_binop_stack_spill_find_depth(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < g_wave208_stack_spill_n; i++) {
    if (g_wave208_stack_spill_off[i] == off)
      return g_wave208_stack_spill_at_depth[i];
  }
  return -1;
}

int32_t glue_binop_stack_spill_n_get(void) {
  return g_wave208_stack_spill_n;
}

int32_t glue_binop_stack_spill_off_at(int32_t i) {
  if (i < 0 || i >= g_wave208_stack_spill_n)
    return -1;
  return g_wave208_stack_spill_off[i];
}

/*
 * wave209 cold twins: CAP cache structs BSS + thin accessors + caches_hit_var
 * (G.7 pure leave). Working freestanding BSS twins of pure minus_pair/subadd3
 * flattened fields. Hybrid product links pure; cold seed keeps local static
 * under #ifndef FROM_X. Key hash cold twin wave177; CAP depth twin wave207.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
static int32_t g_wave209_minus_pair_valid = 0;
static void *g_wave209_minus_pair_ctx = 0;
static uint64_t g_wave209_minus_pair_i_key = 0;
static uint64_t g_wave209_minus_pair_j_key = 0;
static int32_t g_wave209_minus_pair_slot_depth = 0;

static int32_t g_wave209_subadd3_valid = 0;
static void *g_wave209_subadd3_ctx = 0;
static uint64_t g_wave209_subadd3_i_key = 0;
static uint64_t g_wave209_subadd3_j_key = 0;
static uint64_t g_wave209_subadd3_k_key = 0;
static int32_t g_wave209_subadd3_slot_depth = 0;

void glue_index_minus_pair_cache_clear(void) {
  g_wave209_minus_pair_valid = 0;
  g_wave209_minus_pair_slot_depth = 0;
}

void glue_index_subadd3_sum_cache_clear(void) {
  g_wave209_subadd3_valid = 0;
  g_wave209_subadd3_slot_depth = 0;
}

int32_t glue_index_minus_pair_cache_valid_get(void) {
  return g_wave209_minus_pair_valid;
}

int32_t glue_index_minus_pair_cache_slot_depth_get(void) {
  return g_wave209_minus_pair_slot_depth;
}

int32_t glue_index_minus_pair_cache_ctx_matches(void *ctx) {
  if (!ctx)
    return 0;
  return g_wave209_minus_pair_ctx == ctx ? 1 : 0;
}

int32_t glue_index_minus_pair_cache_keys_eq(void *arena, int32_t i_ref, int32_t j_ref) {
  if (!arena)
    return 0;
  if (g_wave209_minus_pair_i_key != glue_index_expr_struct_key_elf_c(arena, i_ref))
    return 0;
  if (g_wave209_minus_pair_j_key != glue_index_expr_struct_key_elf_c(arena, j_ref))
    return 0;
  return 1;
}

void glue_index_minus_pair_cache_record(void *arena, void *ctx, int32_t i_ref, int32_t j_ref) {
  g_wave209_minus_pair_valid = 1;
  g_wave209_minus_pair_ctx = ctx;
  g_wave209_minus_pair_i_key = glue_index_expr_struct_key_elf_c(arena, i_ref);
  g_wave209_minus_pair_j_key = glue_index_expr_struct_key_elf_c(arena, j_ref);
  g_wave209_minus_pair_slot_depth = glue_index_scratch_stack_depth_get();
}

int32_t glue_index_subadd3_sum_cache_valid_get(void) {
  return g_wave209_subadd3_valid;
}

int32_t glue_index_subadd3_sum_cache_slot_depth_get(void) {
  return g_wave209_subadd3_slot_depth;
}

int32_t glue_index_subadd3_sum_cache_ctx_matches(void *ctx) {
  if (!ctx)
    return 0;
  return g_wave209_subadd3_ctx == ctx ? 1 : 0;
}

int32_t glue_index_subadd3_sum_cache_keys_eq(void *arena, int32_t i_ref, int32_t j_ref, int32_t k_ref) {
  if (!arena)
    return 0;
  if (g_wave209_subadd3_i_key != glue_index_expr_struct_key_elf_c(arena, i_ref))
    return 0;
  if (g_wave209_subadd3_j_key != glue_index_expr_struct_key_elf_c(arena, j_ref))
    return 0;
  if (g_wave209_subadd3_k_key != glue_index_expr_struct_key_elf_c(arena, k_ref))
    return 0;
  return 1;
}

void glue_index_subadd3_sum_cache_record(void *arena, void *ctx, int32_t i_ref, int32_t j_ref,
                                        int32_t k_ref) {
  g_wave209_subadd3_valid = 1;
  g_wave209_subadd3_ctx = ctx;
  g_wave209_subadd3_i_key = glue_index_expr_struct_key_elf_c(arena, i_ref);
  g_wave209_subadd3_j_key = glue_index_expr_struct_key_elf_c(arena, j_ref);
  g_wave209_subadd3_k_key = glue_index_expr_struct_key_elf_c(arena, k_ref);
  g_wave209_subadd3_slot_depth = glue_index_scratch_stack_depth_get();
}

int32_t glue_index_scratch_caches_hit_var(void *arena, int32_t var_ref) {
  uint64_t vkey;
  if (!arena || var_ref <= 0)
    return 0;
  vkey = glue_index_expr_struct_key_elf_c(arena, var_ref);
  if (g_wave209_subadd3_valid &&
      (vkey == g_wave209_subadd3_i_key || vkey == g_wave209_subadd3_j_key ||
       vkey == g_wave209_subadd3_k_key))
    return 1;
  if (g_wave209_minus_pair_valid &&
      (vkey == g_wave209_minus_pair_i_key || vkey == g_wave209_minus_pair_j_key))
    return 1;
  return 0;
}

/* XLANG_PABI_BINOP_VAR_SLOT_CACHE_THIN_BEGIN */
/*
 * wave210 cold twins: binop VAR slot cache BSS + thin accessors
 * (G.7 pure leave). Working freestanding BSS twins of pure flattened
 * valid/ctx/off fields (rax/rbx + x10–x15). Hybrid product links pure;
 * cold seed keeps local static under #ifndef FROM_X.
 * stack_spill_drop_off cold twin wave208.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
static int32_t g_wave210_var_valid_rax = 0;
static int32_t g_wave210_var_valid_rbx = 0;
static void *g_wave210_var_ctx = 0;
static int32_t g_wave210_var_rax_off = 0;
static int32_t g_wave210_var_rbx_off = 0;
static int32_t g_wave210_var_valid_x10 = 0;
static int32_t g_wave210_var_valid_x11 = 0;
static int32_t g_wave210_var_valid_x12 = 0;
static int32_t g_wave210_var_valid_x13 = 0;
static int32_t g_wave210_var_valid_x14 = 0;
static int32_t g_wave210_var_valid_x15 = 0;
static int32_t g_wave210_var_x10_off = 0;
static int32_t g_wave210_var_x11_off = 0;
static int32_t g_wave210_var_x12_off = 0;
static int32_t g_wave210_var_x13_off = 0;
static int32_t g_wave210_var_x14_off = 0;
static int32_t g_wave210_var_x15_off = 0;

void glue_binop_var_slot_cache_clear(void) {
  g_wave210_var_valid_rax = 0;
  g_wave210_var_valid_rbx = 0;
  g_wave210_var_valid_x10 = 0;
  g_wave210_var_valid_x11 = 0;
  g_wave210_var_valid_x12 = 0;
  g_wave210_var_valid_x13 = 0;
  g_wave210_var_valid_x14 = 0;
  g_wave210_var_valid_x15 = 0;
}

void glue_binop_var_slot_cache_invalidate_rax(void) { g_wave210_var_valid_rax = 0; }

void glue_binop_var_slot_cache_invalidate_rbx(void) { g_wave210_var_valid_rbx = 0; }

int32_t glue_binop_var_slot_cache_ctx_matches(void *ctx) {
  if (!ctx)
    return 0;
  return g_wave210_var_ctx == ctx ? 1 : 0;
}

int32_t glue_binop_var_slot_cache_hit_rax(void *ctx, int32_t off) {
  return (g_wave210_var_valid_rax && g_wave210_var_ctx == ctx && g_wave210_var_rax_off == off) ? 1
                                                                                              : 0;
}

int32_t glue_binop_var_slot_cache_hit_rbx(void *ctx, int32_t off) {
  return (g_wave210_var_valid_rbx && g_wave210_var_ctx == ctx && g_wave210_var_rbx_off == off) ? 1
                                                                                              : 0;
}

int32_t glue_binop_var_slot_cache_valid_rax_get(void) { return g_wave210_var_valid_rax; }
int32_t glue_binop_var_slot_cache_valid_rbx_get(void) { return g_wave210_var_valid_rbx; }
int32_t glue_binop_var_slot_cache_rax_off_get(void) { return g_wave210_var_rax_off; }
int32_t glue_binop_var_slot_cache_rbx_off_get(void) { return g_wave210_var_rbx_off; }

void glue_binop_var_slot_cache_set_ctx_key(void *ctx) { g_wave210_var_ctx = ctx; }

void glue_binop_var_slot_cache_set_rax(void *ctx, int32_t off) {
  g_wave210_var_ctx = ctx;
  g_wave210_var_valid_rax = 1;
  g_wave210_var_rax_off = off;
}

void glue_binop_var_slot_cache_set_rbx(void *ctx, int32_t off) {
  g_wave210_var_ctx = ctx;
  g_wave210_var_valid_rbx = 1;
  g_wave210_var_rbx_off = off;
}

void glue_binop_var_slot_cache_set_valid_rax(int32_t v) { g_wave210_var_valid_rax = v; }
void glue_binop_var_slot_cache_set_valid_rbx(int32_t v) { g_wave210_var_valid_rbx = v; }
void glue_binop_var_slot_cache_set_rax_off(int32_t off) { g_wave210_var_rax_off = off; }
void glue_binop_var_slot_cache_set_rbx_off(int32_t off) { g_wave210_var_rbx_off = off; }

void glue_binop_var_slot_cache_invalidate_slot(int32_t off) {
  if (g_wave210_var_valid_rax && g_wave210_var_rax_off == off)
    g_wave210_var_valid_rax = 0;
  if (g_wave210_var_valid_rbx && g_wave210_var_rbx_off == off)
    g_wave210_var_valid_rbx = 0;
  if (g_wave210_var_valid_x10 && g_wave210_var_x10_off == off)
    g_wave210_var_valid_x10 = 0;
  if (g_wave210_var_valid_x11 && g_wave210_var_x11_off == off)
    g_wave210_var_valid_x11 = 0;
  if (g_wave210_var_valid_x12 && g_wave210_var_x12_off == off)
    g_wave210_var_valid_x12 = 0;
  if (g_wave210_var_valid_x13 && g_wave210_var_x13_off == off)
    g_wave210_var_valid_x13 = 0;
  if (g_wave210_var_valid_x14 && g_wave210_var_x14_off == off)
    g_wave210_var_valid_x14 = 0;
  if (g_wave210_var_valid_x15 && g_wave210_var_x15_off == off)
    g_wave210_var_valid_x15 = 0;
  glue_binop_stack_spill_drop_off(off);
}

void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off) {
  if (off >= 0)
    glue_binop_var_slot_cache_invalidate_slot(off);
  glue_binop_var_slot_cache_invalidate_rax();
}

void glue_binop_var_slot_cache_set_spill_slot(int32_t which, int32_t off) {
  if (which == 0) {
    g_wave210_var_valid_x10 = 1;
    g_wave210_var_x10_off = off;
    return;
  }
  if (which == 1) {
    g_wave210_var_valid_x11 = 1;
    g_wave210_var_x11_off = off;
    return;
  }
  if (which == 2) {
    g_wave210_var_valid_x12 = 1;
    g_wave210_var_x12_off = off;
    return;
  }
  if (which == 3) {
    g_wave210_var_valid_x13 = 1;
    g_wave210_var_x13_off = off;
    return;
  }
  if (which == 4) {
    g_wave210_var_valid_x14 = 1;
    g_wave210_var_x14_off = off;
    return;
  }
  if (which == 5) {
    g_wave210_var_valid_x15 = 1;
    g_wave210_var_x15_off = off;
  }
}

int32_t glue_binop_var_slot_cache_valid_x10_get(void) { return g_wave210_var_valid_x10; }
int32_t glue_binop_var_slot_cache_valid_x11_get(void) { return g_wave210_var_valid_x11; }
int32_t glue_binop_var_slot_cache_valid_x12_get(void) { return g_wave210_var_valid_x12; }
int32_t glue_binop_var_slot_cache_valid_x13_get(void) { return g_wave210_var_valid_x13; }
int32_t glue_binop_var_slot_cache_valid_x14_get(void) { return g_wave210_var_valid_x14; }
int32_t glue_binop_var_slot_cache_valid_x15_get(void) { return g_wave210_var_valid_x15; }
int32_t glue_binop_var_slot_cache_x10_off_get(void) { return g_wave210_var_x10_off; }
int32_t glue_binop_var_slot_cache_x11_off_get(void) { return g_wave210_var_x11_off; }
int32_t glue_binop_var_slot_cache_x12_off_get(void) { return g_wave210_var_x12_off; }
int32_t glue_binop_var_slot_cache_x13_off_get(void) { return g_wave210_var_x13_off; }
int32_t glue_binop_var_slot_cache_x14_off_get(void) { return g_wave210_var_x14_off; }
int32_t glue_binop_var_slot_cache_x15_off_get(void) { return g_wave210_var_x15_off; }
void glue_binop_var_slot_cache_set_valid_x10(int32_t v) { g_wave210_var_valid_x10 = v; }
void glue_binop_var_slot_cache_set_valid_x11(int32_t v) { g_wave210_var_valid_x11 = v; }
void glue_binop_var_slot_cache_set_valid_x12(int32_t v) { g_wave210_var_valid_x12 = v; }
void glue_binop_var_slot_cache_set_valid_x13(int32_t v) { g_wave210_var_valid_x13 = v; }
void glue_binop_var_slot_cache_set_valid_x14(int32_t v) { g_wave210_var_valid_x14 = v; }
void glue_binop_var_slot_cache_set_valid_x15(int32_t v) { g_wave210_var_valid_x15 = v; }

/* XLANG_PABI_BINOP_VAR_SLOT_CACHE_THIN_END */

/* XLANG_PABI_BINOP_STACK_SPILL_TRY_RELOAD_THIN_BEGIN */
/*
 * wave211 cold twin: binop stack-spill try_reload enc public face.
 * Freestanding-safe no-op stub (miss). Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 AAPCS64.
 */
int32_t glue_binop_stack_spill_try_reload_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t to_rbx) {
  (void)elf_ctx;
  (void)ta;
  (void)off;
  (void)to_rbx;
  return 0;
}

/* XLANG_PABI_BINOP_STACK_SPILL_TRY_RELOAD_THIN_END */

/* XLANG_PABI_ASM73_CHAITIN_THIN_BEGIN */
/*
 * wave212 cold twins: Chaitin color/pin BSS + thin accessors
 * (G.7 pure leave). Working freestanding BSS twins of pure pin[6] +
 * color map (cap 16) + cfg_coloring_active + cfg_final_expr_use_n.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * stack_spill_enabled cold twin: final_expr_use_n / always-off linear max
 * (no residual linear_max in cold seed — freestanding-safe conservative 0).
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path.
 */
static int32_t g_wave212_pin_spill_off[6] = {-1, -1, -1, -1, -1, -1};
static int32_t g_wave212_spill_color_off[16];
static int32_t g_wave212_spill_color_which[16];
static int32_t g_wave212_spill_color_n = 0;
static int32_t g_wave212_cfg_coloring_active = 0;
static int32_t g_wave212_cfg_final_expr_use_n = 0;

void glue_asm73_pin_spill_off_clear_all(void) {
  g_wave212_pin_spill_off[0] = -1;
  g_wave212_pin_spill_off[1] = -1;
  g_wave212_pin_spill_off[2] = -1;
  g_wave212_pin_spill_off[3] = -1;
  g_wave212_pin_spill_off[4] = -1;
  g_wave212_pin_spill_off[5] = -1;
}

void glue_asm73_pin_spill_off_set(int32_t which, int32_t off) {
  if (which < 0 || which > 5)
    return;
  g_wave212_pin_spill_off[which] = off;
}

int32_t glue_asm73_off_is_spill_pin(int32_t off) {
  if (off < 0)
    return 0;
  return off == g_wave212_pin_spill_off[0] || off == g_wave212_pin_spill_off[1] ||
         off == g_wave212_pin_spill_off[2] || off == g_wave212_pin_spill_off[3] ||
         off == g_wave212_pin_spill_off[4] || off == g_wave212_pin_spill_off[5];
}

void glue_asm73_clear_spill_color_map(void) { g_wave212_spill_color_n = 0; }

void glue_asm73_set_spill_color(int32_t off, int32_t which) {
  int32_t i;
  if (off < 0 || which < 0 || which > 6)
    return;
  for (i = 0; i < g_wave212_spill_color_n; i++) {
    if (g_wave212_spill_color_off[i] == off) {
      g_wave212_spill_color_which[i] = which;
      return;
    }
  }
  if (g_wave212_spill_color_n >= 16)
    return;
  g_wave212_spill_color_off[g_wave212_spill_color_n] = off;
  g_wave212_spill_color_which[g_wave212_spill_color_n] = which;
  g_wave212_spill_color_n++;
}

int32_t glue_asm73_off_spill_color_which(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < g_wave212_spill_color_n; i++) {
    if (g_wave212_spill_color_off[i] == off)
      return g_wave212_spill_color_which[i];
  }
  return -1;
}

int32_t glue_asm73_cfg_coloring_active_get(void) { return g_wave212_cfg_coloring_active; }

void glue_asm73_cfg_coloring_active_set(int32_t v) {
  g_wave212_cfg_coloring_active = v ? 1 : 0;
}

void glue_asm73_cfg_final_expr_use_n_set(int32_t n) { g_wave212_cfg_final_expr_use_n = n; }

/* XLANG_PABI_ASM73_CHAITIN_THIN_END — pin/color only; stack_spill_enabled uses wave213 BSS below */

/* XLANG_PABI_ASM73_LIVE_INTERF_THIN_BEGIN */
/*
 * wave213 cold twins: live control scalars + Chaitin interf BSS + linear_ctx
 * (G.7 pure leave). Working freestanding BSS twins of pure control/interf.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * glue_asm73_cfg_peak_clear stays Cap residual (peak_live host BSS) — no cold twin.
 * slice9 glue_asm_block_diverged_set/get + BSS live in the leftover unique
 * OR (independent; after lsp_free). Not here — cold full seed compiles
 * that OR; a second def here would dual-def in the same TU.
 * PLATFORM: SHARED freestanding 7.3.
 */
static int32_t g_wave213_cfg_parent = 0;
static int32_t g_wave213_live_fwd_active = 0;
static int32_t g_wave213_emit_stmt_i = 0;
static int32_t g_wave213_linear_max_live_n = 0;
static int32_t g_wave213_interf_n = 0;
static int32_t g_wave213_interf_off[32];
static int32_t g_wave213_interf_adj[32];
static int32_t g_wave213_interf_stack_depth = 0;
static int32_t g_wave213_interf_stack_n[8];
static int32_t g_wave213_interf_stack_off[256];
static int32_t g_wave213_interf_stack_adj[256];
static void *g_wave213_linear_arena = 0;
static void *g_wave213_linear_ctx = 0;
static int32_t g_wave213_linear_block_ref = 0;
static int32_t g_wave213_linear_slot_base = 0;
static int32_t g_wave213_linear_nconst = 0;
static int32_t g_wave213_linear_nlet = 0;
static int32_t g_wave213_linear_nso = 0;

/* Cold twin: stack_spill uses pure-style cfg_parent + linear_max (wave213 BSS). */
int32_t glue_asm73_stack_spill_enabled(void) {
  if (g_wave213_cfg_parent != 0)
    return g_wave212_cfg_final_expr_use_n >= 12 ? 1 : 0;
  return g_wave213_linear_max_live_n >= 15 ? 1 : 0;
}

int32_t glue_asm73_var_prefers_stack_spill(int32_t off) {
  if (off < 0 || !glue_asm73_stack_spill_enabled())
    return 0;
  return glue_asm73_off_spill_color_which(off) == 6 ? 1 : 0;
}

int32_t glue_block_live_cfg_parent_get(void) { return g_wave213_cfg_parent; }
void glue_block_live_cfg_parent_set(int32_t v) { g_wave213_cfg_parent = v ? 1 : 0; }
int32_t glue_block_live_fwd_active_get(void) { return g_wave213_live_fwd_active; }
void glue_block_live_fwd_active_set(int32_t v) { g_wave213_live_fwd_active = v ? 1 : 0; }
void glue_block_emit_stmt_i_set(int32_t v) { g_wave213_emit_stmt_i = v; }
int32_t glue_block_emit_stmt_i_get(void) { return g_wave213_emit_stmt_i; }
int32_t glue_asm73_linear_max_live_n_get(void) { return g_wave213_linear_max_live_n; }
void glue_asm73_linear_max_live_n_set(int32_t n) { g_wave213_linear_max_live_n = n; }
void glue_asm73_linear_max_live_n_maybe_raise(int32_t n) {
  if (n > g_wave213_linear_max_live_n)
    g_wave213_linear_max_live_n = n;
}
int32_t glue_asm73_pressure_live_thresh_get(void) {
  if (g_wave213_linear_max_live_n >= 12)
    return 8;
  if (g_wave213_linear_max_live_n >= 9)
    return 7;
  if (g_wave213_linear_max_live_n >= 8)
    return 6;
  if (g_wave213_linear_max_live_n >= 7)
    return 5;
  if (g_wave213_linear_max_live_n >= 6)
    return 4;
  return 3;
}
void glue_asm73_interf_clear(void) { g_wave213_interf_n = 0; }
int32_t glue_asm73_interf_n_get(void) { return g_wave213_interf_n; }
int32_t glue_asm73_interf_off_at(int32_t i) {
  if (i < 0 || i >= g_wave213_interf_n)
    return -1;
  return g_wave213_interf_off[i];
}
int32_t glue_asm73_interf_has_edge(int32_t i, int32_t j) {
  if (i < 0 || j < 0 || i >= g_wave213_interf_n || j >= g_wave213_interf_n)
    return 0;
  return (g_wave213_interf_adj[i] & (1 << j)) ? 1 : 0;
}
static int32_t w213_cold_interf_index(int32_t off) {
  int32_t i;
  if (off < 0)
    return -1;
  for (i = 0; i < g_wave213_interf_n; i++) {
    if (g_wave213_interf_off[i] == off)
      return i;
  }
  if (g_wave213_interf_n >= 32)
    return -1;
  i = g_wave213_interf_n;
  g_wave213_interf_off[i] = off;
  g_wave213_interf_adj[i] = 0;
  g_wave213_interf_n++;
  return i;
}
void glue_asm73_interf_add_live_set_u8(const void *live) {
  int32_t n;
  int32_t i;
  int32_t j;
  int32_t ii;
  int32_t jj;
  int32_t off_i;
  int32_t off_j;
  if (!live)
    return;
  n = glue_live_fwd_n_get(live);
  for (i = 0; i < n; i++) {
    off_i = glue_live_fwd_off_at(live, i);
    ii = w213_cold_interf_index(off_i);
    if (ii < 0)
      return;
    for (j = i + 1; j < n; j++) {
      off_j = glue_live_fwd_off_at(live, j);
      jj = w213_cold_interf_index(off_j);
      if (jj < 0)
        return;
      g_wave213_interf_adj[ii] |= (1 << jj);
      g_wave213_interf_adj[jj] |= (1 << ii);
    }
  }
}
extern void *glue_asm73_live_at_stmt_as_u8(int32_t stmt_i);
void glue_asm73_interf_add_live_at_stmt(int32_t stmt_i) {
  void *live;
  if (stmt_i < 0 || stmt_i >= 32)
    return;
  live = glue_asm73_live_at_stmt_as_u8(stmt_i);
  glue_asm73_interf_add_live_set_u8(live);
}
void glue_asm73_interf_push(void) {
  int32_t d;
  int32_t i;
  int32_t base;
  if (g_wave213_interf_stack_depth >= 8)
    return;
  d = g_wave213_interf_stack_depth;
  g_wave213_interf_stack_n[d] = g_wave213_interf_n;
  base = d * 32;
  for (i = 0; i < 32; i++) {
    g_wave213_interf_stack_off[base + i] = g_wave213_interf_off[i];
    g_wave213_interf_stack_adj[base + i] = g_wave213_interf_adj[i];
  }
  g_wave213_interf_stack_depth++;
  glue_asm73_interf_clear();
}
void glue_asm73_interf_pop_merge(void) {
  int32_t d;
  int32_t base;
  int32_t child_n;
  int32_t dn;
  int32_t i;
  int32_t j;
  int32_t di;
  int32_t dj;
  int32_t map[32];
  int32_t dst_off[32];
  int32_t dst_adj[32];
  int32_t found;
  int32_t map_ok;
  if (g_wave213_interf_stack_depth <= 0)
    return;
  g_wave213_interf_stack_depth--;
  d = g_wave213_interf_stack_depth;
  base = d * 32;
  child_n = g_wave213_interf_n;
  dn = g_wave213_interf_stack_n[d];
  for (i = 0; i < 32; i++) {
    dst_off[i] = g_wave213_interf_stack_off[base + i];
    dst_adj[i] = g_wave213_interf_stack_adj[base + i];
  }
  map_ok = 1;
  for (i = 0; i < child_n && map_ok; i++) {
    found = 0;
    for (j = 0; j < dn; j++) {
      if (dst_off[j] == g_wave213_interf_off[i]) {
        map[i] = j;
        found = 1;
        break;
      }
    }
    if (!found) {
      if (dn >= 32) {
        map_ok = 0;
        break;
      }
      dst_off[dn] = g_wave213_interf_off[i];
      dst_adj[dn] = 0;
      map[i] = dn;
      dn++;
    }
  }
  if (map_ok) {
    for (i = 0; i < child_n; i++) {
      di = map[i];
      for (j = 0; j < child_n; j++) {
        if (!(g_wave213_interf_adj[i] & (1 << j)))
          continue;
        dj = map[j];
        dst_adj[di] |= (1 << dj);
        dst_adj[dj] |= (1 << di);
      }
    }
  }
  g_wave213_interf_n = dn;
  for (i = 0; i < 32; i++) {
    g_wave213_interf_off[i] = dst_off[i];
    g_wave213_interf_adj[i] = dst_adj[i];
  }
}
void glue_asm73_linear_ctx_bind(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                               int32_t nlet, int32_t nso) {
  g_wave213_linear_arena = arena;
  g_wave213_linear_ctx = ctx;
  g_wave213_linear_block_ref = block_ref;
  g_wave213_linear_slot_base = slot_base;
  g_wave213_linear_nconst = nconst;
  g_wave213_linear_nlet = nlet;
  g_wave213_linear_nso = nso;
}
void *glue_asm73_linear_arena_get(void) { return g_wave213_linear_arena; }
void *glue_asm73_linear_ctx_get(void) { return g_wave213_linear_ctx; }
int32_t glue_asm73_linear_block_ref_get(void) { return g_wave213_linear_block_ref; }
int32_t glue_asm73_linear_slot_base_get(void) { return g_wave213_linear_slot_base; }
int32_t glue_asm73_linear_nconst_get(void) { return g_wave213_linear_nconst; }
int32_t glue_asm73_linear_nlet_get(void) { return g_wave213_linear_nlet; }
int32_t glue_asm73_linear_nso_get(void) { return g_wave213_linear_nso; }

/* XLANG_PABI_ASM73_LIVE_INTERF_THIN_END */

/* XLANG_PABI_ASM73_LIVE_SET_THIN_BEGIN */
/*
 * wave214 cold twins: live set arrays + opaque u8 overlay thins (G.7 pure leave).
 * Layout: offs[32] i32 + n at index 32; blob stride 33 i32 (=132 bytes). Pure uses
 * 136-byte stride with pad; cold uses compact 33-i32 GlueBlockLiveFwd-compatible
 * layout (n at byte 128). Hybrid product links pure; cold seed keeps local static
 * under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding 7.3.
 */
typedef struct {
  int32_t offs[32];
  int32_t n;
} W214Live;

static W214Live g_w214_block_live_fwd;
static W214Live g_w214_live_at_stmt[32];
static W214Live g_w214_snap_before_if;
static W214Live g_w214_sub_exit_snap;
static W214Live g_w214_cfg_peak_live;
static int32_t g_w214_cfg_peak_stmt_i = 0;
static W214Live g_w214_loop_break_exit[8];
static W214Live g_w214_loop_continue_head[8];
static int32_t g_w214_loop_break_exit_depth = 0;

static void w214_live_clear(W214Live *live) {
  if (live)
    live->n = 0;
}
static int32_t w214_live_contains(const W214Live *live, int32_t off) {
  int32_t i;
  if (!live || off < 0)
    return 0;
  for (i = 0; i < live->n; i++)
    if (live->offs[i] == off)
      return 1;
  return 0;
}
static void w214_live_add(W214Live *live, int32_t off) {
  int32_t i;
  if (!live || off < 0)
    return;
  for (i = 0; i < live->n; i++)
    if (live->offs[i] == off)
      return;
  if (live->n >= 32)
    return;
  live->offs[live->n++] = off;
}
static void w214_live_copy(W214Live *dst, const W214Live *src) {
  int32_t i;
  if (!dst || !src)
    return;
  dst->n = src->n;
  for (i = 0; i < src->n; i++)
    dst->offs[i] = src->offs[i];
}
static void w214_live_remove(W214Live *live, int32_t off) {
  int32_t i, j;
  if (!live || off < 0)
    return;
  for (i = 0; i < live->n; i++) {
    if (live->offs[i] == off) {
      for (j = i + 1; j < live->n; j++)
        live->offs[j - 1] = live->offs[j];
      live->n--;
      return;
    }
  }
}
static void w214_live_union_into(W214Live *dst, const W214Live *src) {
  int32_t i;
  if (!dst || !src)
    return;
  for (i = 0; i < src->n; i++)
    w214_live_add(dst, src->offs[i]);
}

int32_t glue_live_fwd_n_get(const void *live) {
  if (!live)
    return 0;
  return ((const W214Live *)live)->n;
}
int32_t glue_live_fwd_off_at(const void *live, int32_t i) {
  const W214Live *lv = (const W214Live *)live;
  if (!lv || i < 0 || i >= lv->n)
    return -1;
  return lv->offs[i];
}
void glue_live_fwd_clear_u8(void *live) { w214_live_clear((W214Live *)live); }
void glue_live_fwd_add_u8(void *live, int32_t off) { w214_live_add((W214Live *)live, off); }
void glue_live_fwd_copy_u8(void *dst, const void *src) {
  if (!dst || !src)
    return;
  w214_live_copy((W214Live *)dst, (const W214Live *)src);
}
void glue_live_fwd_remove_u8(void *live, int32_t off) { w214_live_remove((W214Live *)live, off); }
int32_t glue_live_fwd_contains_u8(const void *live, int32_t off) {
  return w214_live_contains((const W214Live *)live, off) ? 1 : 0;
}
void *glue_block_live_fwd_as_u8(void) { return (void *)&g_w214_block_live_fwd; }
void glue_block_live_fwd_clear_global(void) { w214_live_clear(&g_w214_block_live_fwd); }
int32_t glue_block_live_fwd_contains_off(int32_t off) {
  return w214_live_contains(&g_w214_block_live_fwd, off) ? 1 : 0;
}
void glue_block_live_fwd_add_off(int32_t off) { w214_live_add(&g_w214_block_live_fwd, off); }
void glue_block_live_fwd_remove_off(int32_t off) { w214_live_remove(&g_w214_block_live_fwd, off); }
void glue_block_live_fwd_copy_from_u8(void *src) {
  if (!src) {
    w214_live_clear(&g_w214_block_live_fwd);
    return;
  }
  w214_live_copy(&g_w214_block_live_fwd, (const W214Live *)src);
}
void glue_block_live_fwd_union_from_u8(void *src) {
  if (!src)
    return;
  w214_live_union_into(&g_w214_block_live_fwd, (const W214Live *)src);
}
void glue_live_snap_before_if_copy_from_block_live_fwd(void) {
  w214_live_copy(&g_w214_snap_before_if, &g_w214_block_live_fwd);
}
void glue_live_fwd_copy_from_snap_before_if(void *dst) {
  if (!dst)
    return;
  w214_live_copy((W214Live *)dst, &g_w214_snap_before_if);
}
void glue_block_live_sub_exit_snap_clear(void) { w214_live_clear(&g_w214_sub_exit_snap); }
void glue_block_live_sub_exit_snap_copy_from_block_live_fwd(void) {
  w214_live_copy(&g_w214_sub_exit_snap, &g_w214_block_live_fwd);
}
void glue_block_live_sub_exit_snap_copy_from_u8(const void *src) {
  if (!src) {
    w214_live_clear(&g_w214_sub_exit_snap);
    return;
  }
  w214_live_copy(&g_w214_sub_exit_snap, (const W214Live *)src);
}
int32_t glue_asm73_live_at_stmt_n_get(int32_t stmt_i) {
  if (stmt_i < 0 || stmt_i >= 32)
    return 0;
  return g_w214_live_at_stmt[stmt_i].n;
}
void *glue_asm73_live_at_stmt_as_u8(int32_t stmt_i) {
  if (stmt_i < 0 || stmt_i >= 32)
    return (void *)0;
  return (void *)&g_w214_live_at_stmt[stmt_i];
}
void glue_block_live_at_stmt_copy_from_u8(int32_t stmt_i, const void *live) {
  if (stmt_i < 0 || stmt_i >= 32)
    return;
  if (!live) {
    w214_live_clear(&g_w214_live_at_stmt[stmt_i]);
    return;
  }
  w214_live_copy(&g_w214_live_at_stmt[stmt_i], (const W214Live *)live);
}
int32_t glue_asm73_cfg_peak_live_n_get(void) { return g_w214_cfg_peak_live.n; }
void *glue_asm73_cfg_peak_live_as_u8(void) { return (void *)&g_w214_cfg_peak_live; }
int32_t glue_asm73_cfg_peak_stmt_i_get(void) { return g_w214_cfg_peak_stmt_i; }
void glue_asm73_cfg_peak_snapshot_from_u8(const void *live, int32_t stmt_i) {
  if (!live)
    return;
  w214_live_copy(&g_w214_cfg_peak_live, (const W214Live *)live);
  g_w214_cfg_peak_stmt_i = stmt_i;
}
void glue_asm73_cfg_peak_clear(void) {
  g_w214_cfg_peak_stmt_i = 0;
  w214_live_clear(&g_w214_cfg_peak_live);
}
/* set_from_expr_uses / fill_live_end: cold stubs call pure-style helpers when available. */
extern void glue_live_fwd_collect_expr_uses(void *arena, void *ctx, int32_t expr_ref, void *gen);
extern int32_t glue_block_stmt_order_has_cfg(void *arena, int32_t block_ref);
extern void glue_block_compute_live_end_linear(void *arena, void *ctx, int32_t block_ref, void *out);
void glue_block_live_fwd_set_from_expr_uses(void *arena, void *ctx, int32_t expr_ref) {
  w214_live_clear(&g_w214_block_live_fwd);
  if (expr_ref > 0 && arena && ctx)
    glue_live_fwd_collect_expr_uses(arena, ctx, expr_ref, &g_w214_block_live_fwd);
}
void glue_block_fill_live_end_for_merge(void *arena, void *ctx, int32_t block_ref, void *out_live) {
  w214_live_clear((W214Live *)out_live);
  if (!out_live || !arena || !ctx || block_ref <= 0)
    return;
  if (glue_block_stmt_order_has_cfg(arena, block_ref))
    w214_live_copy((W214Live *)out_live, &g_w214_sub_exit_snap);
  else
    glue_block_compute_live_end_linear(arena, ctx, block_ref, out_live);
}
int32_t glue_loop_break_exit_depth_get(void) { return g_w214_loop_break_exit_depth; }
void glue_loop_break_exit_push(void) {
  if (g_w214_loop_break_exit_depth < 8) {
    w214_live_clear(&g_w214_loop_break_exit[g_w214_loop_break_exit_depth]);
    w214_live_clear(&g_w214_loop_continue_head[g_w214_loop_break_exit_depth]);
    g_w214_loop_break_exit_depth++;
  }
}
void glue_loop_break_exit_pop(void) {
  if (g_w214_loop_break_exit_depth > 0)
    g_w214_loop_break_exit_depth--;
}
void glue_loop_break_exit_note_current(void) {
  int32_t d;
  if (g_w214_loop_break_exit_depth <= 0)
    return;
  d = g_w214_loop_break_exit_depth - 1;
  if (glue_block_live_fwd_active_get())
    w214_live_union_into(&g_w214_loop_break_exit[d], &g_w214_block_live_fwd);
  else
    w214_live_union_into(&g_w214_loop_break_exit[d], &g_w214_sub_exit_snap);
}
void glue_loop_continue_head_note_current(void) {
  int32_t d;
  if (g_w214_loop_break_exit_depth <= 0)
    return;
  d = g_w214_loop_break_exit_depth - 1;
  if (glue_block_live_fwd_active_get())
    w214_live_union_into(&g_w214_loop_continue_head[d], &g_w214_block_live_fwd);
  else
    w214_live_union_into(&g_w214_loop_continue_head[d], &g_w214_sub_exit_snap);
}
void glue_loop_break_exit_live_union_into_u8(void *dst, int32_t d) {
  if (!dst || d < 0 || d >= 8)
    return;
  w214_live_union_into((W214Live *)dst, &g_w214_loop_break_exit[d]);
}
void glue_loop_continue_head_live_union_into_u8(void *dst, int32_t d) {
  if (!dst || d < 0 || d >= 8)
    return;
  w214_live_union_into((W214Live *)dst, &g_w214_loop_continue_head[d]);
}

/* XLANG_PABI_ASM73_LIVE_SET_THIN_END */

/* wave213 cfg_interf_prepare called residual peak_clear; cold twin now local. */
void glue_asm73_cfg_interf_prepare(void) {
  glue_asm73_interf_clear();
  g_wave213_interf_stack_depth = 0;
  g_wave213_linear_max_live_n = 0;
  glue_asm73_cfg_final_expr_use_n_set(0);
  glue_asm73_cfg_peak_clear();
}

#endif /* close remaining wave178 FROM_X for leftover-PE for_call_args unique */
