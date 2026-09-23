/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE top_level_let storage unique */

/*
 * wave265 cold twins: TopLevelLetEntry multi-module map + top_level Cap leave faces.
 * top_level_let unique extracted above with the real seed body; leftover rest
 * does not compile remaining alloc/set/getters (not unique). Hybrid
 * product links pure. Cold full seed compiles BSS in the OR then these
 * helpers in the same TU.
 * Layout ≡ C TopLevelLetEntry LE:
 *   name[256]@0 | name_len@256 | type_ref@260 | init_ref@264 | is_const@268 | is_export@272
 * Soft-sync when header num_top_level_lets@12 == 0.
 * Hoist/sum/hoist_target: freestanding no-ops or minimal (need Cap block/asm faces);
 * product pure owns full hoist/sum path.
 * PLATFORM: SHARED freestanding top_level Cap leave.
 */

static void wave265_tl_soft_sync(void *module) {
  int s;
  if (!module || wave265_tl_header_n(module) != 0)
    return;
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return;
  g_wave265_tl_n[s] = 0;
}

static int wave265_tl_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  wave265_tl_soft_sync(module);
  found = wave265_tl_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE265_TL_SLOTS; i++) {
    if (g_wave265_tl_mod[i] == NULL) {
      g_wave265_tl_mod[i] = module;
      g_wave265_tl_n[i] = 0;
      g_wave265_tl_cap[i] = 0;
      g_wave265_tl_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave265_tl_ensure(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE265_TL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave265_tl_cap[slot] >= need)
    return 1;
  new_cap = g_wave265_tl_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE265_TL_ENTRY_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE265_TL_ENTRY_SZ);
  old = g_wave265_tl_entries[slot];
  if (old && g_wave265_tl_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave265_tl_n[slot] * (size_t)WAVE265_TL_ENTRY_SZ);
  if (old)
    free(old);
  g_wave265_tl_entries[slot] = np;
  g_wave265_tl_cap[slot] = new_cap;
  return 1;
}

static uint8_t *wave265_tl_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE265_TL_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave265_tl_n[slot])
    return NULL;
  if (!g_wave265_tl_entries[slot])
    return NULL;
  return g_wave265_tl_entries[slot] + (size_t)idx * (size_t)WAVE265_TL_ENTRY_SZ;
}

int32_t pipeline_module_top_level_let_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module)
    return -1;
  s = wave265_tl_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_wave265_tl_n[s];
  if (!wave265_tl_ensure(s, n + 1))
    return -1;
  base = g_wave265_tl_entries[s];
  if (!base)
    return -1;
  memset(base + (size_t)n * (size_t)WAVE265_TL_ENTRY_SZ, 0, (size_t)WAVE265_TL_ENTRY_SZ);
  g_wave265_tl_n[s] = n + 1;
  wave265_tl_set_header_n(module, n + 1);
  return n;
}

void pipeline_module_top_level_let_set(void *module, int32_t idx, uint8_t *name, int32_t name_len,
                                       int32_t type_ref, int32_t init_ref, int32_t is_const) {
  int s;
  uint8_t *e;
  int32_t i;
  int32_t n;
  if (!module || !name || name_len <= 0 || name_len > 255)
    return;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return;
  e = wave265_tl_at(s, idx);
  if (!e)
    return;
  n = name_len;
  memset(e, 0, 256);
  for (i = 0; i < n; i++)
    e[i] = name[i];
  memcpy(e + 256, &n, 4);
  memcpy(e + 260, &type_ref, 4);
  memcpy(e + 264, &init_ref, 4);
  memcpy(e + 268, &is_const, 4);
}

void pipeline_module_top_level_let_set_type_ref(void *module, int32_t idx, int32_t type_ref) {
  int s;
  uint8_t *e;
  if (!module)
    return;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return;
  e = wave265_tl_at(s, idx);
  if (!e)
    return;
  memcpy(e + 260, &type_ref, 4);
}

int32_t pipeline_module_top_level_let_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nlen, e + 256, 4);
  return nlen;
}

uint8_t pipeline_module_top_level_let_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module || off < 0 || off >= 255)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nlen, e + 256, 4);
  if (off >= nlen)
    return 0;
  return e[off];
}

int32_t pipeline_module_top_level_let_type_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&v, e + 260, 4);
  return v;
}

int32_t pipeline_module_top_level_let_init_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&v, e + 264, 4);
  return v;
}

int32_t pipeline_module_top_level_let_is_const(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&v, e + 268, 4);
  return v;
}

void pipeline_module_top_level_let_set_is_export(void *module, int32_t idx, int32_t is_export) {
  int s;
  uint8_t *e;
  if (!module)
    return;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return;
  e = wave265_tl_at(s, idx);
  if (!e)
    return;
  memcpy(e + 272, &is_export, 4);
}

int32_t pipeline_module_top_level_let_is_export_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  e = wave265_tl_at(s, idx);
  if (!e)
    return 0;
  memcpy(&v, e + 272, 4);
  return v;
}

int32_t pipeline_module_top_level_name_is_const(void *module, uint8_t *vname, int32_t vlen) {
  int s;
  int32_t i, n, nl, k;
  uint8_t *e;
  if (!module || !vname || vlen <= 0)
    return 0;
  wave265_tl_soft_sync(module);
  s = wave265_tl_find_slot(module);
  if (s < 0)
    return 0;
  n = g_wave265_tl_n[s];
  for (i = 0; i < n; i++) {
    e = wave265_tl_at(s, i);
    if (!e)
      continue;
    memcpy(&nl, e + 256, 4);
    if (nl != vlen)
      continue;
    for (k = 0; k < vlen; k++) {
      if (e[k] != vname[k])
        break;
    }
    if (k == vlen) {
      int32_t is_c;
      memcpy(&is_c, e + 268, 4);
      return is_c != 0 ? 1 : 0;
    }
  }
  return 0;
}
/* XLANG_PABI_TOP_LEVEL_LET_THIN_END */

/*
 * Cold twin of pure pipeline_module_hoist_top_level_lets_into_main.
 * Stage 12.0.5: skip *all* TYPE_ARRAY (10) module lets — they are COMMON
 * via modlet prepare (const + mutable). dest-SLICE ARRAY_LIT const still
 * hoists (prepare requires TYPE_ARRAY). 9.6.0: mutable scalar LIT/BOOL
 * lets also stay un-hoisted — prepare registers them as 8-byte COMMON
 * (init_kind 0/2, is_const==0) and hoisting stacked a stale main frame
 * slot beside the COMMON home (slot-first consumers read the slot, RMW
 * reads COMMON). prepend count = actually appended.
 * Product pure owns full path when strong; cold must match so WEAK hybrid /
 * freestanding stay aligned.
 * PLATFORM: SHARED freestanding top_level hoist.
 */
void pipeline_module_hoist_top_level_lets_into_main(void *module, void *arena) {
  int32_t n, mi, br, let_start_idx, tl, hoisted, nexprs, name_len, type_ref, init_ref;
  int32_t tk, ik, k;
  uint8_t name_buf[256];
  if (!module || !arena)
    return;
  n = cold_mod_num_top_level_lets(module);
  if (n <= 0)
    return;
  mi = pipeline_module_main_func_index(module);
  if (mi < 0) {
    int32_t nf = pipeline_module_num_funcs(module);
    int32_t fi;
    mi = -1;
    for (fi = 0; fi < nf; fi++) {
      int32_t is_ext = pipeline_asm_module_func_is_extern_at(module, fi);
      int32_t br0 = pipeline_module_func_body_ref_at(module, fi);
      if (is_ext == 0 && br0 > 0) {
        mi = fi;
        break;
      }
    }
    if (mi < 0)
      return;
  }
  br = pipeline_module_func_body_ref_at(module, mi);
  if (br <= 0)
    return;
  let_start_idx = ast_ast_block_num_lets(arena, br);
  nexprs = cold_arena_num_exprs(arena);
  hoisted = 0;
  for (tl = 0; tl < n; tl++) {
    name_len = pipeline_module_top_level_let_name_len(module, tl);
    if (name_len <= 0 || name_len > 255)
      continue;
    type_ref = pipeline_module_top_level_let_type_ref(module, tl);
    init_ref = pipeline_module_top_level_let_init_ref(module, tl);
    tk = 0;
    ik = 0;
    if (type_ref > 0) {
      tk = pipeline_type_kind_ord_at(arena, type_ref);
      if (init_ref > 0 && init_ref <= nexprs)
        ik = pipeline_expr_kind_ord_at(arena, init_ref);
      if (tk == 10) {
        /* Mutable TYPE_ARRAY always COMMON. Const TYPE_ARRAY COMMON unless
         * elem is TYPE_SLICE (`[N][]T` fat rows still hoist). */
        if (pipeline_module_top_level_let_is_const(module, tl) == 0)
          continue;
        {
          int32_t et_h = pipeline_type_elem_ref_at(arena, type_ref);
          int32_t etk_h = (et_h > 0) ? pipeline_type_kind_ord_at(arena, et_h) : 0;
          if (etk_h != 11)
            continue;
        }
      }
      if (ik == 46) {
        /* Mutable dest-SLICE ARRAY_LIT stays un-hoisted. Const dest-SLICE
         * ARRAY_LIT still hoists (no TYPE_ARRAY cell). */
        if (pipeline_module_top_level_let_is_const(module, tl) == 0)
          continue;
      }
      /* 9.6.0 / wave338: mutable scalar COMMON-owned inits stay un-hoisted
       * (prepare registers LIT/BOOL/NEG-over-LIT/null-ptr). Twin of
       * runtime_pipeline_abi.x hoist guard. PLATFORM: SHARED. */
      if (init_ref > 0 && init_ref <= nexprs) {
        int32_t imm_skip = 0;
        int32_t is_c_sc = pipeline_module_top_level_let_is_const(module, tl);
        if (pipe_modlet_scalar_init_common_imm_cold(arena, init_ref, tk, is_c_sc, &imm_skip) != 0)
          continue;
      }
      /* Scalar ADDR_OF / fn-ptr: same predicate as prepare register.
       * PLATFORM: SHARED — 9.6.0 dual-home class. */
      if ((tk == 9 || tk == 18) && init_ref > 0 && init_ref <= nexprs &&
          pipe_modlet_scalar_init_is_ptr_addr_cold(arena, module, init_ref) != 0)
        continue;
    }
    for (k = 0; k < name_len; k++)
      name_buf[k] = pipeline_module_top_level_let_name_byte_at(module, tl, k);
    if (pipeline_block_append_let(arena, br, name_buf, name_len, type_ref, init_ref) < 0)
      return;
    hoisted++;
  }
  if (hoisted > 0)
    pipeline_block_stmt_order_prepend_lets(arena, br, let_start_idx, hoisted);
}

int32_t pipeline_asm_hoist_target_func_index(void *module) {
  (void)module;
  return -1;
}

int32_t pipeline_asm_sum_module_top_level_lets_stack(void *arena, void *mod, int32_t off) {
  (void)arena;
  (void)mod;
  return off;
}



/* XLANG_PABI_CALL_METHOD_WRAPPERS_THIN_BEGIN */
/*
 * wave217 cold twins: CALL/METHOD text thin wrappers (G.7 pure leave).
 * Freestanding-safe stub (-1). Hybrid product links pure (stack snapshot +
 * backend_emit_* via *u8 large-struct ABI). void* signatures avoid incomplete
 * struct ast_Expr in this TU (same pattern as wave216 for_call_args twin).
 * PLATFORM: SHARED freestanding text CALL/METHOD M8-tail.
 */
int32_t pipeline_asm_emit_expr_call_c(void *arena, void *out, int32_t expr_ref, void *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)expr_ref;
  (void)ctx;
  (void)target_arch;
  return -1;
}

int32_t pipeline_asm_emit_expr_method_call_c(void *arena, void *out, int32_t expr_ref, void *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)expr_ref;
  (void)ctx;
  (void)target_arch;
  return -1;
}
/* XLANG_PABI_CALL_METHOD_WRAPPERS_THIN_END */

#endif /* close wave178 FROM_X for leftover-PE struct_layout storage unique */
