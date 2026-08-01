/**
 * pipeline_asm_emit_modlet.c — module-level mutable let ELF COMMON cell emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via #include).
 * Authority for module-level mutable lit let storage emitted as SHN_COMMON / Mach-O
 * N_UNDF common symbols (linker BSS, writable) — true cross-fn share, NOT per-fn stack.
 *
 * Root issue solved: per-fn stack copies of top-level `let g` make set_g/get_g observe
 * different slots. COMMON lives in linker BSS (writable); never embed mutable cells in
 * RX .text (SEGV on store). x86: lea rbx,[rip+disp32] (R_X86_64_PC32); arm64: adrp+add
 * (ARM64_RELOC_PAGE21 + PAGEOFF12, wave405).
 *
 * Domain members (12 functions + 1 typedef + 1 global):
 * - pipeline_asm_modlet_reset / pipeline_asm_modlet_name_is_shared (public table API)
 * - pipeline_asm_modlet_find (static table lookup)
 * - pipeline_asm_modlet_lea_rbx_rip_x86 / _adrp_arm64 / _arch (static addr-of-cell encoders)
 * - pipeline_asm_modlet_load_to_rax_elf_c / store_from_rax_elf_c (static cell load/store)
 * - pipeline_asm_modlet_prepare_and_emit_elf_c (static build table + emit COMMON syms)
 * - pipeline_asm_modlet_seed_nonzero_inits_elf_c (static seed non-zero BSS cells)
 * - pipeline_asm_register_module_top_level_lets_c (static frame registration for non-hoist fns)
 * - pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c (static per-fn mutable lit seed)
 *
 * G.7: single modlet ELF emit path — typeck.x / strict_minimal consume the same
 * pipeline_asm_modlet_name_is_shared public symbol; no second modlet path.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c before assign.c
 * (callsites: assign.c store_from_rax + modlet_name_is_shared; expr_rec.c load_to_rax;
 * glue.c prepare/register/emit/seed at L8252+).
 *
 * PLATFORM: SHARED (x86_64 + arm64 ELF) — LINUX|UBUNTU x86_64 R_X86_64_PC32 +
 * MACOS|ARM64 ARM64_RELOC_PAGE21/PAGEOFF12.
 */

/* ------------------------------------------------------------------------- */
/* Modlet table: max 64 shared mutable cells per mega emit.                   */
/* ------------------------------------------------------------------------- */

#define XLANG_ASM_MODLET_MAX 64

typedef struct {
  int32_t n;
  int32_t name_len[XLANG_ASM_MODLET_MAX];
  uint8_t name[XLANG_ASM_MODLET_MAX][128];
  int32_t label_len[XLANG_ASM_MODLET_MAX];
  uint8_t label[XLANG_ASM_MODLET_MAX][24];
  int32_t init_imm[XLANG_ASM_MODLET_MAX];
} pipeline_asm_modlet_table_t;

static pipeline_asm_modlet_table_t g_pipeline_asm_modlet;

/**
 * Reset the modlet table to empty (n=0).
 *
 * Why: Called once per mega emit at the start of pipeline_asm_modlet_prepare_and_
 * emit_elf_c to clear any prior mega emit's modlet registrations. The table is
 * static-singleton (file-scope), so stale entries from a previous module would
 * cause spurious COMMON symbol collisions or wrong load/store targets.
 *
 * Invariant: After reset, g_pipeline_asm_modlet.n == 0 and all slots are logically
 * free (not zeroed — callers must check n before indexing).
 *
 * Asm/Perf: O(1) — single field store. Called once per mega emit (cold path).
 *
 * PLATFORM: SHARED — table reset is platform-independent.
 */
static void pipeline_asm_modlet_reset(void) {
  g_pipeline_asm_modlet.n = 0;
}

/**
 * Check whether a name is a text-embedded module shared mutable let for this mega emit.
 *
 * Why: Used by assign.c (store path) and ast_pool_top_level.c (frame registration) to
 * route loads/stores of covered names through the modlet COMMON cell path instead of
 * per-fn stack slots. Without this gate, set_g/get_g across functions would observe
 * different stack copies — the root cause of the cross-fn mutable let bug.
 *
 * Invariant: Returns 1 if the name matches a registered modlet entry (exact byte
 * comparison); 0 otherwise (including null/empty inputs or empty table).
 *
 * Asm/Perf: O(N_modlets * name_len) linear scan. Cold-ish — called during typeck
 * frame registration and asm assign emit, not in tight loops.
 *
 * PLATFORM: SHARED — name lookup is platform-independent.
 */
int32_t pipeline_asm_modlet_name_is_shared(uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t k;
  if (!name || name_len <= 0 || g_pipeline_asm_modlet.n <= 0)
    return 0;
  for (i = 0; i < g_pipeline_asm_modlet.n; i++) {
    if (g_pipeline_asm_modlet.name_len[i] != name_len)
      continue;
    for (k = 0; k < name_len; k++) {
      if (g_pipeline_asm_modlet.name[i][k] != name[k])
        break;
    }
    if (k == name_len)
      return 1;
  }
  return 0;
}

/**
 * Find the modlet table index for a given name.
 *
 * Why: Internal lookup used by load_to_rax / store_from_rax to resolve a modlet
 * name to its table index (for label retrieval in lea_rbx_* encoders).
 *
 * Invariant: Returns >=0 index on match; -1 on miss or null/empty input.
 *
 * Asm/Perf: O(N_modlets * name_len) linear scan. Called per load/store of a
 * shared mutable let (asm emit path, not runtime).
 *
 * PLATFORM: SHARED — table lookup is platform-independent.
 */
static int32_t pipeline_asm_modlet_find(uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t k;
  if (!name || name_len <= 0)
    return -1;
  for (i = 0; i < g_pipeline_asm_modlet.n; i++) {
    if (g_pipeline_asm_modlet.name_len[i] != name_len)
      continue;
    for (k = 0; k < name_len; k++) {
      if (g_pipeline_asm_modlet.name[i][k] != name[k])
        break;
    }
    if (k == name_len)
      return i;
  }
  return -1;
}

/**
 * Emit lea rbx, [rip+disp32] for a modlet COMMON cell (x86_64).
 *
 * Why: x86_64 address-of COMMON object via R_X86_64_PC32 PC-relative relocation.
 * COMMON lives in linker BSS (writable); lea gives the address in rbx without
 * clobbering rax (safe after assign rhs evaluation).
 *
 * Invariant: Returns 0 on success; -1 on null ctx, bad index, or byte/reloc
 * append failure. Emits 7 bytes: 48 8d 1d <disp32=0> + reloc to label.
 *
 * Asm/Perf: O(1) — 7-byte emit + 1 reloc. Cold path (asm emit).
 *
 * PLATFORM: LINUX|UBUNTU x86_64 — R_X86_64_PC32 to SHN_COMMON BSS object.
 * Never embed mutable cells in RX .text (SEGV on store).
 */
static int32_t pipeline_asm_modlet_lea_rbx_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t idx) {
  uint8_t *cb;
  uint8_t lea7[7];
  int32_t rel32_at;
  int32_t llen;
  uint8_t *lname;
  if (!elf_ctx || idx < 0 || idx >= g_pipeline_asm_modlet.n)
    return -1;
  cb = (uint8_t *)elf_ctx;
  llen = g_pipeline_asm_modlet.label_len[idx];
  lname = g_pipeline_asm_modlet.label[idx];
  /* 48 8d 1d disp32  →  lea rbx, [rip+disp32] */
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = 0x1d;
  lea7[3] = 0;
  lea7[4] = 0;
  lea7[5] = 0;
  lea7[6] = 0;
  if (pipeline_elf_ctx_append_bytes(cb, lea7, 7) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  /* Reloc (not internal patch): linker resolves to SHN_COMMON BSS. */
  return pipeline_elf_ctx_append_reloc(cb, rel32_at, lname, llen);
}

/** ast_pool.c — typed reloc (wave405 arm64 PAGE21/PAGEOFF12). */
extern int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len,
                                                   int32_t r_type, int32_t r_pcrel);

/**
 * Emit adrp x1, page; add x1, x1, pageoff for a modlet COMMON cell (arm64).
 *
 * Why: arm64 address-of COMMON object via ARM64_RELOC_PAGE21 (pcrel) +
 * ARM64_RELOC_PAGEOFF12 (not pcrel). Address lands in x1 (rbx equivalent).
 * Does not clobber x0/rax (safe after assign rhs evaluation).
 *
 * Invariant: Returns 0 on success; -1 on null ctx, bad index, or byte/reloc
 * append failure. Emits 8 bytes: adrp x1,#0 (4) + add x1,x1,#0 (4).
 *
 * Asm/Perf: O(1) — 8-byte emit + 2 typed relocs. Cold path (asm emit).
 *
 * PLATFORM: MACOS|ARM64 — Mach-O ARM64_RELOC_PAGE21=3 (pcrel) +
 * ARM64_RELOC_PAGEOFF12=4 (not pcrel). wave405 Cap residual pure.
 */
static int32_t pipeline_asm_modlet_lea_rbx_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t idx) {
  uint8_t *cb;
  uint8_t adrp4[4];
  uint8_t add4[4];
  int32_t adrp_at;
  int32_t add_at;
  int32_t llen;
  uint8_t *lname;
  if (!elf_ctx || idx < 0 || idx >= g_pipeline_asm_modlet.n)
    return -1;
  cb = (uint8_t *)elf_ctx;
  llen = g_pipeline_asm_modlet.label_len[idx];
  lname = g_pipeline_asm_modlet.label[idx];
  /* adrp x1, #0  →  0x90000001 (immlo/immhi zero; PAGE21 reloc fills) */
  adrp4[0] = 0x01;
  adrp4[1] = 0x00;
  adrp4[2] = 0x00;
  adrp4[3] = 0x90;
  if (pipeline_elf_ctx_append_bytes(cb, adrp4, 4) != 0)
    return -1;
  adrp_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_append_reloc_typed(cb, adrp_at, lname, llen, 3, 1) != 0)
    return -1;
  /* add x1, x1, #0 → 0x91000021 (PAGEOFF12 reloc fills imm12) */
  add4[0] = 0x21;
  add4[1] = 0x00;
  add4[2] = 0x00;
  add4[3] = 0x91;
  if (pipeline_elf_ctx_append_bytes(cb, add4, 4) != 0)
    return -1;
  add_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  return pipeline_elf_ctx_append_reloc_typed(cb, add_at, lname, llen, 4, 0);
}

/**
 * Dispatch lea rbx/x1 to modlet COMMON cell by target arch.
 *
 * Why: Single arch-dispatch entry for modlet address-of-cell encoding. ta=0 →
 * x86_64 rip-relative lea; ta=1 → arm64 adrp+add. Called by load/store helpers.
 *
 * Invariant: Returns 0 on success; -1 on unsupported arch or encoder failure.
 *
 * Asm/Perf: O(1) — single dispatch. Cold path (asm emit).
 *
 * PLATFORM: SHARED — dispatches to LINUX|UBUNTU x86_64 or MACOS|ARM64 encoder.
 */
static int32_t pipeline_asm_modlet_lea_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t idx, int32_t ta) {
  if (ta == 1)
    return pipeline_asm_modlet_lea_rbx_adrp_arm64(elf_ctx, idx);
  if (ta == 0)
    return pipeline_asm_modlet_lea_rbx_rip_x86(elf_ctx, idx);
  return -1;
}

/** backend enc: load qword from [rbx] to rax (x86_64 only historically). */
extern int32_t backend_enc_load_qword_from_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);

/**
 * Load a shared modlet cell into rax.
 *
 * Why: EXPR_VAR load of a module-level mutable lit let routes through the modlet
 * COMMON cell (not per-fn stack) so all functions observe the same storage.
 * Emits lea rbx/x1 to cell + load qword from [rbx/x1] to rax/x0.
 *
 * Invariant: Returns 0 on success; -1 on miss (name not in modlet table), null
 * ctx, or bad arch. On x86_64 uses backend_enc_load_qword_from_rbx_to_rax_arch;
 * on arm64 emits ldr x0,[x1] inline (0xf9400020) since dispatch load_qword is
 * x86-only historically.
 *
 * Asm/Perf: O(1) — lea (7-8 bytes) + load (2-4 bytes). Cold path (asm emit).
 *
 * PLATFORM: SHARED — x86_64 rip-relative lea + mov rax,[rbx]; arm64 adrp+add + ldr.
 */
static int32_t pipeline_asm_modlet_load_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                     int32_t name_len, int32_t ta) {
  int32_t idx;
  if ((ta != 0 && ta != 1) || !elf_ctx)
    return -1;
  idx = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0)
    return -1;
  if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) != 0)
    return -1;
  if (ta == 1) {
    /* ldr x0, [x1] = 0xf9400020 — dispatch load_qword is x86-only historically. */
    uint8_t ldr4[4];
    ldr4[0] = 0x20;
    ldr4[1] = 0x00;
    ldr4[2] = 0x40;
    ldr4[3] = 0xf9;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, ldr4, 4);
  }
  return backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx, ta);
}

/** backend enc: store rax to [rbx] indirect (arch-dispatched). */
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t sz,
                                                          int32_t ta);

/**
 * Store rax into a shared modlet cell.
 *
 * Why: ASSIGN store of a module-level mutable lit let routes through the modlet
 * COMMON cell so all functions observe the same storage. Emits lea rbx/x1 to
 * cell + store rax to [rbx/x1].
 *
 * Invariant: Returns 0 on success; -1 on miss (name not in modlet table), null
 * ctx, or bad arch.
 *
 * Asm/Perf: O(1) — lea (7-8 bytes) + store (2-4 bytes). Cold path (asm emit).
 *
 * PLATFORM: SHARED — x86_64 rip-relative lea + mov [rbx],rax; arm64 adrp+add + str.
 */
static int32_t pipeline_asm_modlet_store_from_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                        int32_t name_len, int32_t ta) {
  int32_t idx;
  if ((ta != 0 && ta != 1) || !elf_ctx)
    return -1;
  idx = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0)
    return -1;
  if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) != 0)
    return -1;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, 8, ta);
}

/** ast_pool.c — SHN_COMMON object symbols for module mutable lets (writable BSS via linker). */
extern int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size,
                                               int32_t align);

/* ast_pool.c — module top-level let readers. */
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t tl);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t tl, int32_t k);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t tl);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);

/**
 * Build the modlet table and emit SHN_COMMON symbols for module mutable lets.
 *
 * Why: Once per mega emit, scans module top-level lets for mutable lit-init
 * entries (non-const, init_kind 0 or 2) and registers them as modlet COMMON
 * cells. Linker places COMMON in BSS (writable). Non-zero inits seeded later
 * by pipeline_asm_modlet_seed_nonzero_inits_elf_c on hoist-target entry.
 * Do NOT put mutable cells in .text (RX → SEGV on store).
 *
 * Invariant: Returns 0 on success (including no-op when no top-level lets);
 * -1 on COMMON symbol emission failure. Resets table at entry. Caps at
 * XLANG_ASM_MODLET_MAX (64) entries. Label format: Lxlang_ml_<idx>.
 *
 * Asm/Perf: O(N_top_level_lets + N_modlets) — scan lets + emit COMMON syms.
 * Called once per mega emit (cold path).
 *
 * PLATFORM: SHARED (x86_64 + arm64) — COMMON symbol emission is platform-
 * independent; lea/adrp encoders handle arch-specific address-of-cell.
 * wave405: arm64 ADRP path.
 */
static int32_t pipeline_asm_modlet_prepare_and_emit_elf_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  int32_t tl;
  int32_t n;
  int32_t i;
  pipeline_asm_modlet_reset();
  if (!m || !a || !elf_ctx || (ta != 0 && ta != 1) || m->num_top_level_lets <= 0)
    return 0;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    int32_t name_len;
    int32_t init_ref;
    int32_t init_kind;
    int32_t k;
    int32_t is_const;
    int32_t idx;
    if (g_pipeline_asm_modlet.n >= XLANG_ASM_MODLET_MAX)
      break;
    is_const = pipeline_module_top_level_let_is_const(m, tl);
    if (is_const != 0)
      continue;
    name_len = pipeline_module_top_level_let_name_len(m, tl);
    if (name_len <= 0 || name_len > 127)
      continue;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0 || init_ref > a->num_exprs)
      continue;
    init_kind = pipeline_expr_kind_ord_at(a, init_ref);
    if (init_kind != 0 && init_kind != 2)
      continue;
    idx = g_pipeline_asm_modlet.n;
    g_pipeline_asm_modlet.name_len[idx] = name_len;
    for (k = 0; k < name_len; k++)
      g_pipeline_asm_modlet.name[idx][k] = pipeline_module_top_level_let_name_byte_at(m, tl, k);
    g_pipeline_asm_modlet.init_imm[idx] = pipeline_expr_int_val_at(a, init_ref);
    /* Symbol: Lxlang_ml_<idx> (COMMON object; reloc target for lea). */
    {
      int32_t llen = 0;
      const char *pfx = "Lxlang_ml_";
      int32_t di;
      int32_t v = idx;
      uint8_t digs[8];
      int32_t nd = 0;
      while (pfx[llen] != 0 && llen < 16) {
        g_pipeline_asm_modlet.label[idx][llen] = (uint8_t)pfx[llen];
        llen++;
      }
      if (v == 0) {
        digs[0] = (uint8_t)'0';
        nd = 1;
      } else {
        while (v > 0 && nd < 8) {
          digs[nd++] = (uint8_t)('0' + (v % 10));
          v /= 10;
        }
      }
      for (di = nd - 1; di >= 0 && llen < 23; di--)
        g_pipeline_asm_modlet.label[idx][llen++] = digs[di];
      g_pipeline_asm_modlet.label_len[idx] = llen;
    }
    g_pipeline_asm_modlet.n = idx + 1;
  }
  for (i = 0; i < g_pipeline_asm_modlet.n; i++) {
    if (pipeline_elf_ctx_add_common_sym((uint8_t *)elf_ctx, g_pipeline_asm_modlet.label[i],
                                        g_pipeline_asm_modlet.label_len[i], 8, 8) != 0)
      return -1;
  }
  return 0;
}

/** backend enc: mov imm64 to rax (arch-dispatched). */
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                 int32_t hi32, int32_t ta);

/**
 * Seed non-zero COMMON cells once on hoist-target entry.
 *
 * Why: BSS starts zero. Mutable lit lets with non-zero init (e.g. heap_trace_on
 * = -1) need explicit seeding on hoist-target function entry so first load is
 * not garbage. Zero-init cells are implicitly correct (BSS zero).
 *
 * Invariant: Returns 0 on success (including no-op when no non-zero inits);
 * -1 on mov/store failure. Iterates modlet table, skips imm==0 entries.
 *
 * Asm/Perf: O(N_modlets) — mov imm64 + store per non-zero cell. Called once
 * per mega emit on hoist-target entry (cold path).
 *
 * PLATFORM: SHARED (x86_64 + arm64) — seeding uses arch-dispatched mov/store.
 */
static int32_t pipeline_asm_modlet_seed_nonzero_inits_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  int32_t i;
  if (!elf_ctx || (ta != 0 && ta != 1))
    return 0;
  for (i = 0; i < g_pipeline_asm_modlet.n; i++) {
    int32_t imm = g_pipeline_asm_modlet.init_imm[i];
    if (imm == 0)
      continue;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta) != 0)
      return -1;
    if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, g_pipeline_asm_modlet.name[i],
                                                 g_pipeline_asm_modlet.name_len[i], ta) != 0)
      return -1;
  }
  return 0;
}

/* pipeline_glue.c — hoist target (main or first non-extern body). */
extern int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m);

/**
 * Register module top-level lets into a non-hoist function frame.
 *
 * Why: Non-hoist functions need per-fn stack slots for mutable / non-lit
 * top-level lets that are NOT covered by modlet (CG002 residual shapes).
 * True const + lit/bool init stay unregistered (loads use imm path).
 * Mutable lit lets covered by modlet skip stack (true cross-fn share).
 *
 * Invariant: No-op for hoist-target function (already prepended real lets
 * with inits). Skips names already registered or covered by modlet. Updates
 * ctx->next_offset and num_locals. Returns void (errors are silent — caller
 * trusts frame layout).
 *
 * Asm/Perf: O(N_top_level_lets) — scan + register per non-skipped let.
 * Called once per non-hoist function (cold path).
 *
 * PLATFORM: SHARED — frame registration is platform-independent; stack slot
 * sizing via asm_local_slot_reg_offset handles type-specific widths.
 */
static void pipeline_asm_register_module_top_level_lets_c(struct backend_AsmFuncCtx *ctx, struct ast_Module *m,
                                                           struct ast_ASTArena *a, int32_t func_index) {
  int32_t tl;
  int32_t n;
  int32_t off;
  uint8_t name_buf[128];
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !m || !a || m->num_top_level_lets <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  if (func_index == pipeline_asm_hoist_target_func_index(m))
    return;
  off = ly->next_offset;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    int32_t name_len;
    int32_t type_ref;
    int32_t init_ref;
    int32_t slot_off;
    int32_t k;
    int32_t is_const;
    name_len = pipeline_module_top_level_let_name_len(m, tl);
    /* wave581 Cap residual: top-level let name content cap 127 (was 64). */
    if (name_len <= 0 || name_len > 127)
      continue;
    for (k = 0; k < name_len; k++)
      name_buf[k] = pipeline_module_top_level_let_name_byte_at(m, tl, k);
    if (asm_ctx_local_find_offset((uint8_t *)ctx, name_buf, name_len) >= 0)
      continue;
    /* Shared modlet cell: do not allocate per-fn stack. */
    if (pipeline_asm_modlet_name_is_shared(name_buf, name_len) != 0)
      continue;
    type_ref = pipeline_module_top_level_let_type_ref(m, tl);
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    is_const = pipeline_module_top_level_let_is_const(m, tl);
    /**
     * Skip only true const + lit/bool init (imm load path). Mutable lit let (is_const=0)
     * must register for ASSIGN when not on modlet (heap_trace co-emit on non-x86).
     */
    if (is_const != 0 && init_ref > 0 && init_ref <= a->num_exprs) {
      int32_t init_kind = pipeline_expr_kind_ord_at(a, init_ref);
      if (init_kind == 0 || init_kind == 2)
        continue;
    }
    slot_off = asm_local_slot_reg_offset(a, type_ref, off, &off);
    if (asm_ctx_local_append((uint8_t *)ctx, name_buf, name_len, slot_off) < 0)
      return;
    off += pipeline_asm_let_init_stack_reserve_bytes(a, type_ref, init_ref);
  }
  ly->next_offset = off;
  ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
}

/** backend enc: store rax to [rbp+disp] (arch-dispatched). */
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off, int32_t ta);

/**
 * Seed registered mutable top-level lit slots with their init imm on non-hoist funcs.
 *
 * Why: After prologue on non-hoist funcs, registered mutable top-level lit slots
 * need seeding with their init imm so first load is not garbage (e.g. trace_on
 * = -1, counters = 0). Hoist target already prepends real lets with inits —
 * skip here. Modlet-covered names are inited once in the text blob — skip
 * per-fn seed.
 *
 * Invariant: Returns 0 on success (including no-op for hoist target or no
 * top-level lets); -1 on mov/store failure. Skips const, modlet-covered,
 * unregistered, and non-lit-init entries.
 *
 * Asm/Perf: O(N_top_level_lets) — mov imm64 + store rax to rbp per seeded slot.
 * Called once per non-hoist function after prologue (cold path).
 *
 * PLATFORM: SHARED — seeding uses arch-dispatched mov/store.
 */
static int32_t pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(
    struct ast_ASTArena *a, struct platform_elf_ElfCodegenCtx *elf_ctx, struct backend_AsmFuncCtx *ctx,
    struct ast_Module *m, int32_t func_index, int32_t ta) {
  int32_t tl;
  int32_t n;
  uint8_t name_buf[128];
  if (!a || !elf_ctx || !ctx || !m || m->num_top_level_lets <= 0)
    return 0;
  if (func_index == pipeline_asm_hoist_target_func_index(m))
    return 0;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    int32_t name_len;
    int32_t init_ref;
    int32_t off;
    int32_t k;
    int32_t init_kind;
    int32_t imm;
    if (pipeline_module_top_level_let_is_const(m, tl) != 0)
      continue;
    name_len = pipeline_module_top_level_let_name_len(m, tl);
    if (name_len <= 0 || name_len > 127)
      continue;
    for (k = 0; k < name_len; k++)
      name_buf[k] = pipeline_module_top_level_let_name_byte_at(m, tl, k);
    name_buf[name_len] = 0;
    if (pipeline_asm_modlet_name_is_shared(name_buf, name_len) != 0)
      continue;
    off = asm_ctx_local_find_offset((uint8_t *)ctx, name_buf, name_len);
    if (off < 0)
      continue;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0 || init_ref > a->num_exprs)
      continue;
    init_kind = pipeline_expr_kind_ord_at(a, init_ref);
    if (init_kind != 0 && init_kind != 2)
      continue;
    imm = pipeline_expr_int_val_at(a, init_ref);
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
  }
  return 0;
}
