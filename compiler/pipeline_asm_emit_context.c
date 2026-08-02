/**
 * pipeline_asm_emit_context.c — asm emit global context setters/getters domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega asm emit context management:
 * - pipeline_asm_emit_set_module / module_ref_c (current emit module)
 * - pipeline_asm_emit_set_dep_pipe / dep_pipe_c (current dep pipe)
 * - pipeline_asm_emit_set_arena (current emit AST arena)
 * - pipeline_asm_emit_set_call_param_type_ref (callee formal type_ref)
 * - pipeline_asm_emit_call_arg_begin_c / end_c / active_c (CALL arg depth)
 * - pipeline_asm_emit_set_func_index / func_index_c (current emit func index)
 * - pipeline_asm_emit_set_elf_ctx (current emit ElfCodegenCtx)
 * - pipeline_asm_emit_func_param_is_ptr_by_name_c (lookup *T param by name)
 * - pipeline_asm_var_is_emit_func_param_ptr_c (wrapper: VAR expr → name lookup)
 *
 * G.7: single product-mega asm emit context face — do not open a second
 * setter/getter family. All static globals stay in pipeline_glue.c
 * (g_pipeline_asm_emit_module / _func_index / _arena / _call_param_ty_ref /
 *  g_glue_emit_call_arg_depth / g_pipeline_asm_emit_dep_pipe /
 *  g_pipeline_asm_emit_elf_ctx) because they are also read directly by
 * pipeline_asm_emit_field_access.c (same-TU #include) for CALL-arg struct
 * pass-by-address classification.
 *
 * Static globals (defined in pipeline_glue.c L132-188, before this file's
 * #include site) — visible in this file via same TU:
 *  - g_pipeline_asm_emit_module          (struct ast_Module *)
 *  - g_pipeline_asm_emit_func_index      (int32_t, init -1)
 *  - g_pipeline_asm_emit_arena           (struct ast_ASTArena *)
 *  - g_pipeline_asm_emit_call_param_ty_ref (int32_t)
 *  - g_glue_emit_call_arg_depth          (int32_t)
 *  - g_pipeline_asm_emit_dep_pipe        (struct ast_PipelineDepCtx *)
 *  - g_pipeline_asm_emit_elf_ctx         (struct platform_elf_ElfCodegenCtx *)
 *
 * Forward decls in pipeline_glue.c retained:
 *  - L180: pipeline_asm_emit_call_arg_active_c (called by field_access.c
 *          #included at L2111, before this file's #include at L3191)
 *  - L186: pipeline_asm_emit_dep_pipe_c (called by vector_simd.c #included
 *          at L1940, before this file's #include at L3191)
 *
 * External dependencies (all declared elsewhere in pipeline_x.o TU):
 *  - pipeline_elf_pgo_hot_enabled / pipeline_elf_ctx_set_emit_hot
 *    / pipeline_asm_wpo_pgo_is_hot_func (PGO-Lite hot section switch)
 *  - pipeline_module_func_param_type_ref_for_name (module formal table)
 *  - pipeline_type_kind_ord_at (type kind ordinal)
 *  - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len / _into
 *    (expr accessor domain)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at L3191
 * (wave1180 include site; replaces former inline definitions L3192-3297).
 *
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — context only (encoding in callees)
 *   · MACOS|ARM64 AAPCS64 — same context twin
 */

/**
 * Set the module currently being emitted by asm_codegen_ast_to_elf.
 * Why: backend.x main emit loop sets this once per function so FIELD_ACCESS
 *      on enum-typed VAR can resolve variant tags via the module enum sidecar
 *      (pipeline_expr_enum_namespace_field_tag) and CALL-arg struct layout
 *      can be looked up by field name (glue_field_access_field_type_ref_c).
 * Contract: NULL is allowed (clears the binding); no return value.
 */
void pipeline_asm_emit_set_module(struct ast_Module *m) {
  g_pipeline_asm_emit_module = m;
}

/**
 * Read the module currently being emitted.
 * Why: CALL-arg emit compares callee formal type_ref against the current
 *      module's struct layout table (glue_field_access_field_type_ref_c);
 *      backend_try_inline reads it for cross-module inlining decisions.
 * Contract: returns NULL when no module is bound (e.g. before first
 *           asm_codegen_ast_to_elf call).
 */
struct ast_Module *pipeline_asm_emit_module_ref_c(void) {
  return g_pipeline_asm_emit_module;
}

/**
 * Bind the current emit dep pipe (PipelineDepCtx).
 * Why: import-struct FIELD_ACCESS needs to walk dep_arenas/dep_modules for
 *      layout offset resolution when the struct is defined in an imported
 *      module (WPO-S3 cross_ret / SIMD field load). backend_try_inline also
 *      falls back to this when ctx->dep_pipe is NULL.
 * Contract: NULL is allowed (clears the binding).
 */
void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx) {
  g_pipeline_asm_emit_dep_pipe = ctx;
}

/**
 * Read the current emit dep pipe.
 * Why: backend_try_inline_dispatch / SIMD emit read this to resolve import
 *      struct layouts when ctx->dep_pipe is missing.
 * Contract: returns NULL when no dep pipe is bound.
 */
struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void) {
  return g_pipeline_asm_emit_dep_pipe;
}

/**
 * Bind the AST arena currently being emitted.
 * Why: backend.x main emit loop sets this before each function so param
 *      homing can query expr kind (pipeline_asm_var_is_emit_func_param_ptr_c)
 *      without threading arena through every emit call.
 * Contract: NULL is allowed (clears the binding).
 */
void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena) {
  g_pipeline_asm_emit_arena = arena;
}

/**
 * Set the callee formal type_ref corresponding to the current CALL argument
 * being emitted.
 * Why: f32 formal must be materialized as 32-bit IEEE bit-pattern (not the
 *      default 64-bit mov); struct formal >16B must be passed by address.
 *      type_ref is read by glue_field_access_call_arg_struct_by_addr_elf_c
 *      and glue_field_call_arg_try_load_agg_from_rax_elf_c.
 * Contract: 0 means "unknown" (fall back to layout scan by field name).
 */
void pipeline_asm_emit_set_call_param_type_ref(int32_t type_ref) {
  g_pipeline_asm_emit_call_param_ty_ref = type_ref;
}

/**
 * Increment CALL argument emit depth.
 * Why: when depth > 0, FIELD_ACCESS on a struct-typed VAR knows to leave the
 *      field address in rax (MEMORY class >16B) rather than loading the
 *      scalar value. backend_call_dispatch calls this before each arg emit.
 * Contract: unbalanced begin/end would misclassify subsequent emit; callers
 *           must pair begin/end in the same dispatch.
 */
void pipeline_asm_emit_call_arg_begin_c(void) {
  g_glue_emit_call_arg_depth++;
}

/**
 * Decrement CALL argument emit depth.
 * Why: closes the begin/end pair; depth 0 means scalar emit resumes.
 * Contract: clamps at 0 (no underflow); safe to call without matching begin
 *           (returns silently).
 */
void pipeline_asm_emit_call_arg_end_c(void) {
  if (g_glue_emit_call_arg_depth > 0)
    g_glue_emit_call_arg_depth--;
}

/**
 * Whether the current emit context is inside a CALL argument.
 * Why: glue_field_access_call_arg_struct_by_addr_elf_c and
 *      glue_field_call_arg_try_load_agg_from_rax_elf_c gate on this to decide
 *      whether to emit a by-address leave or a scalar load.
 * Contract: returns 1 when depth > 0, else 0.
 */
int32_t pipeline_asm_emit_call_arg_active_c(void) {
  return g_glue_emit_call_arg_depth > 0 ? 1 : 0;
}

/**
 * Set the current emit function index (backend.x main loop, per-function).
 * Why: g_pipeline_asm_emit_func_index is read by
 *      pipeline_asm_emit_func_param_is_ptr_by_name_c to look up the formal
 *      parameter table of the currently emitted function — needed when
 *      resolved_type is missing for a *T param VAR (load vs lea+offset).
 *      PGO-Lite: also flips .text / .text.hot section based on whether the
 *      function is in the PGO hot set (wave PGOLite hot section switch).
 * Contract: func_index must be in [0, mod->num_funcs); -1 clears the binding.
 *           PGO-Lite section switch only fires when elf_ctx + module are bound
 *           and pipeline_elf_pgo_hot_enabled() returns true.
 */
void pipeline_asm_emit_set_func_index(int32_t func_index) {
  g_pipeline_asm_emit_func_index = func_index;
  /* PGO-Lite: switch .text / .text.hot in lockstep with enc_label.
   * PLATFORM: SHARED — partial mega also walks this path. */
  if (g_pipeline_asm_emit_elf_ctx && g_pipeline_asm_emit_module && pipeline_elf_pgo_hot_enabled())
    pipeline_elf_ctx_set_emit_hot((uint8_t *)g_pipeline_asm_emit_elf_ctx,
                                  pipeline_asm_wpo_pgo_is_hot_func(g_pipeline_asm_emit_module, func_index));
}

/**
 * Bind the ElfCodegenCtx currently being written by asm_codegen_ast_to_elf.
 * Why: PGO-Lite emit section switch (pipeline_asm_emit_set_func_index) needs
 *      to call pipeline_elf_ctx_set_emit_hot on the live ctx; must be cleared
 *      (NULL) after emit to avoid dangling pointer use by later functions.
 * Contract: NULL is allowed (clears the binding, disables PGO-Lite switch).
 */
void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  g_pipeline_asm_emit_elf_ctx = elf_ctx;
}

/**
 * Read the current emit function index.
 * Why: backend_try_inline reads this to skip inlining the function being
 *      currently emitted (would cause infinite recursion in mono path).
 * Contract: returns -1 when no function is bound.
 */
int32_t pipeline_asm_emit_func_index_c(void) {
  return g_pipeline_asm_emit_func_index;
}

/**
 * Look up whether a named formal of the currently emitted function is *T
 * (TYPE_PTR) by scanning the module formal table.
 * Why: backend.x X-path sometimes has resolved_type missing or non-PTR for
 *      a *T param VAR (especially in partial-module emit); this C helper
 *      scans module_func_param_type_ref_for_name to recover the *T bit so
 *      field/index emit can choose load (8B pointer) over lea+offset.
 * Contract: returns 1 when the named formal is TYPE_PTR (kind 9), 0 otherwise
 *           (including arena/mod null, vname null, vlen out of [1,127],
 *            func_index out of range, or formal not found).
 * Dependencies: pipeline_module_func_param_type_ref_for_name + pipeline_type_kind_ord_at.
 */
int32_t pipeline_asm_emit_func_param_is_ptr_by_name_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                      uint8_t *vname, int32_t vlen) {
  int32_t fi;
  int32_t param_ty;
  int32_t kind;
  if (!arena || !mod || !vname || vlen <= 0 || vlen > 127)
    return 0;
  fi = g_pipeline_asm_emit_func_index;
  if (fi < 0 || fi >= mod->num_funcs)
    return 0;
  param_ty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
  if (param_ty <= 0)
    return 0;
  kind = pipeline_type_kind_ord_at(arena, param_ty);
  return (kind == 9) ? 1 : 0;
}

/**
 * Wrapper: determine whether a VAR expr_ref refers to a *T formal of the
 * currently emitted function.
 * Why: backend.x X-path calls this with (arena, mod, asm_ctx, var_expr_ref);
 *      resolves the var name via pipeline_expr_var_name_len/into then delegates
 *      to pipeline_asm_emit_func_param_is_ptr_by_name_c. asm_ctx is unused
 *      (kept for ABI compatibility with the .x call signature).
 * Contract: returns 1 when the VAR is a *T formal of the current function,
 *           0 otherwise (including null arena/mod, expr_ref out of range,
 *           expr kind != VAR (3), or name length out of [1,127]).
 * Dependencies: pipeline_expr_kind_ord_at + pipeline_expr_var_name_len/into +
 *               pipeline_asm_emit_func_param_is_ptr_by_name_c (same file).
 */
int32_t pipeline_asm_var_is_emit_func_param_ptr_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  uint8_t *asm_ctx, int32_t var_expr_ref) {
  uint8_t vname[128];
  int32_t vlen;
  (void)asm_ctx;
  if (!arena || !mod || var_expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  return pipeline_asm_emit_func_param_is_ptr_by_name_c(arena, mod, vname, vlen);
}

/* ========================================================================== *
 * wave1200 G.7: frame/param/local slots cluster migrated from pipeline_glue.c
 * (L2631-3070). Colocated with asm emit context domain — frame size computation
 * + param slot filling + param homing + local slot filling are the prologue
 * setup face that consumes the context setters above (set_module / set_arena /
 * set_func_index / set_call_param_type_ref). Same-TU #include at glue.c L2570.
 *
 * Members:
 *  - pipeline_asm_compute_frame_size_c: total frame size (params + locals +
 *    array temp + wa temp + slice reent dc + call spill scratch + 64 pad)
 *  - pipeline_asm_fill_param_slots: fill formal param home slots into asm ctx
 *    sidecar ([rbp-8] reserved for saved rbx; >16B MEMORY full-size home)
 *  - pipeline_asm_emit_param_home_elf_c: prologue param homing (reg → stack
 *    slot; stack args → stack slot; SysV x86 f32 xmm / dual-GP / MEMORY paths;
 *    AAPCS64 arm64 low-end dual-GP / MEMORY paths; sret save rdi/x8)
 *  - pipeline_asm_fill_local_slots: fill block const/let slots into asm ctx
 *    sidecar (+8 slot + lit temp reserve)
 *
 * All deps visible at #include point (glue.c L2570):
 *  - g_pipeline_asm_emit_module / _arena / _func_sret_active / _sret_home_off
 *    (statics at glue.c L132-188)
 *  - pipeline_asm_ctx_layout (static at glue.c L86)
 *  - asm_ctx_local_reset / asm_ctx_fill_locals_block_tree (fwd decls L962-963)
 *  - pipeline_asm_abi_f32_xmm_enabled_c (extern at L890)
 *  - pipeline_asm_hoist_target_func_index (fwd decl L967)
 *  - pipeline_asm_sum_module_top_level_lets_stack (fwd decl L968)
 *  - glue_func_param_home_width_c / glue_func_param_agg_byte_size_c /
 *    pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c (call_args.c, #included
 *    at L1656 — before this file's #include at L2570)
 *  - pipeline_asm_emit_set_func_index (in this file above)
 *  - backend_enc_*_arch / asm_ctx_local_append / asm_ctx_local_count /
 *    asm_ctx_block_slot_get / asm_ctx_block_slot_set / asm_local_slot_reg_offset
 *    / asm_sum_block_array_temp_bytes / asm_sum_block_wa_temp_bytes /
 *    glue_asm_sum_block_call_spill_bytes / glue_sum_block_slice_reent_dc_bytes_c
 *    / glue_func_return_byte_size_c / pipeline_asm_let_init_stack_reserve_bytes
 *    / pipeline_asm_module_func_num_params_at /
 *    pipeline_asm_module_func_param_name_copy32 /
 *    pipeline_asm_module_func_param_name_len_at /
 *    ast_ast_block_num_consts / ast_ast_block_num_lets /
 *    ast_pipeline_block_const_name_copy64 / ast_pipeline_block_const_name_len
 *    / pipeline_block_const_type_ref / ast_pipeline_block_const_init_ref /
 *    ast_pipeline_block_let_name_copy64 / ast_pipeline_block_let_name_len /
 *    pipeline_block_let_type_ref / ast_pipeline_block_let_init_ref (extern)
 *
 * Fwd decls retained in glue.c:
 *  - pipeline_asm_compute_frame_size_c at L965 (before any callsite; harmless)
 *  - pipeline_asm_hoist_target_func_index at L967
 *  - pipeline_asm_sum_module_top_level_lets_stack at L968
 *
 * Sole callers (all in glue.c after #include at L2570):
 *  - pipeline_asm_fill_local_slots: L3145 (emit_if_then) + L3562 (mega_body)
 *  - pipeline_asm_fill_param_slots: L3521 (mega_body)
 *  - pipeline_asm_compute_frame_size_c: L3558 (mega_body)
 *  - pipeline_asm_emit_param_home_elf_c: L3576 (mega_body)
 *
 * PLATFORM: SHARED — x86_64 SysV + AAPCS64 arm64 product residual C.
 * ========================================================================== */

/**
 * Compute total frame size for a function prologue.
 *
 * Why: sum param homes (16 + per-param width) + top-level lets + block locals
 *      + array temp + wa temp + slice reent dc + call spill scratch (min 512)
 *      + 64 pad. The 16 base reserves [rbp-8] for saved rbx (callee-saved).
 *      >16B return functions reserve 8B for hidden rdi after params.
 * Contract: NULL arena or block_ref<=0 → 64 (minimal pad); otherwise the
 *           16-aligned frame size + 64 pad.
 * PLATFORM: SHARED x86_64 SysV + AAPCS64 arm64 — param advancement mirrors
 *           fill_param_slots (high-end x86 / low-end arm64).
 */
int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                          struct ast_Module *mod, int32_t func_index) {
  uint8_t ctx_buf[128];
  int32_t next_off;
  int32_t num_loc;
  int32_t size;
  int32_t arr_temp;
  int32_t call_spill;
  int32_t scratch;
  struct ast_Module *prev_mod;
  if (!arena || block_ref <= 0)
    return 64;
  memset(ctx_buf, 0, sizeof(ctx_buf));
  /** module_ref @ AsmFuncCtx+16，与 asm_ctx_ensure_block_locals 一致。 */
  *(struct ast_Module **)(ctx_buf + 16) = mod;
  prev_mod = g_pipeline_asm_emit_module;
  g_pipeline_asm_emit_module = mod;
  asm_ctx_local_reset(ctx_buf);
  /*
   * 【Why】x86_64 prologue 在 [rbp-8] 保存 rbx（callee-saved）；形参 homing 须从 16 起，
   *   否则 store [rbp-8] 覆写 saved rbx → epilogue pop 错误（run-env env_iter SEGV）。
   * PLATFORM: SHARED x86_64 SysV — 与 fill_param_slots / emit_param_home 对齐。
   */
  next_off = 16;
  if (num_params > 0 && mod && func_index >= 0) {
    int32_t pi;
    /**
     * Match pipeline_asm_fill_param_slots advancement (wave599):
     * - PLATFORM: LINUX|x86_64 — 8B +8; multi-word high-end next = home+8 (= off+w+8).
     * - PLATFORM: MACOS|ARM64 — 8B +8; multi-word low-end next = off+w (no high-end gap).
     */
    for (pi = 0; pi < num_params; pi++) {
      int32_t w = glue_func_param_home_width_c(arena, mod, func_index, pi);
#if defined(__aarch64__) || defined(__arm64__)
      next_off += (w > 8) ? w : 8;
#else
      next_off += (w > 8) ? (w + 8) : 8;
#endif
    }
  } else if (num_params > 0) {
    next_off = 16 + num_params * 8;
  }
  /** 与 mega_body emit 一致：>16B 返回函数在形参后预留 8B 存 hidden rdi。 */
  if (mod && func_index >= 0 && glue_func_return_byte_size_c(mod, arena, func_index) > 16)
    next_off += 8;
  if (mod && func_index >= 0 && func_index != pipeline_asm_hoist_target_func_index(mod))
    next_off = pipeline_asm_sum_module_top_level_lets_stack(arena, mod, next_off);
  num_loc = 0;
  asm_ctx_fill_locals_block_tree(ctx_buf, arena, block_ref, &next_off, &num_loc);
  arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
  call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  g_pipeline_asm_emit_module = prev_mod;
  {
    int32_t wa_temp = asm_sum_block_wa_temp_bytes(arena, block_ref);
    /*
     * wave418: TYPE_SLICE let from CALL/METHOD deep-copies into a per-frame buffer
     * (use_frame=1). Pre-sum max_n*esz per such let so prologue covers body next_offset
     * bumps (wave411 SP overrun root). max_n=1024, worst esz=8 → 8192 per let.
     */
    int32_t reent_dc = glue_sum_block_slice_reent_dc_bytes_c(arena, block_ref);
    size = next_off + arr_temp + wa_temp + reent_dc;
  }
  if (size > 0 && size % 16 != 0)
    size += 16 - (size % 16);
  /*
   * Scratch = max(historical 512, AST call-spill estimate).
   * Root (option pure-asm residual): body with many nested Option CALL args permanently
   * advanced next_offset past frame (max rbp off 0xa80 vs sub $0x360). G.7: complete
   * compute_frame_size authority rather than a larger constant-only pad.
   * Also covers transient struct_lit dual-GP spill at next_offset+16 without advance.
   */
  scratch = call_spill;
  if (scratch < 512)
    scratch = 512;
  size += scratch;
  return size + 64;
}

/**
 * Fill formal param home slots into asm ctx sidecar.
 *
 * Why: [rbp-8] reserved for prologue's saved rbx; params start at 16.
 *      >16B MEMORY by-value params get a full-size home (not 8B pointer slot).
 *      wave599 Cap residual pure: arm64 9–16B named dual-GP formals.
 *      Root: fill_param always used x86 high-end (home=off+width) while
 *      asm_local_slot_reg_offset (wave402) is low-end on MACOS|ARM64, and
 *      emit_param_home arm64 only stored one GP at 16+i*8 — field loads from
 *      empty high-end home (take_m(o).m / o.m.f → 0; take_field fs=65≠41).
 *      G.7: same polarity authority as asm_local_slot_reg_offset + dual-GP
 *      store_retval half2 (low@home high@home±8 by ta).
 * Contract: NULL ctx or mod → no-op; otherwise appends each param name+offset
 *           into the ctx local sidecar and advances next_offset.
 * PLATFORM: LINUX|x86_64 SysV — high-end multi-word (home=off+w, next=home+8).
 * PLATFORM: MACOS|ARM64 — low-end multi-word (home=off, next=off+w); matches
 *           [x29+off] emit + field_off add (host ISA == freestanding product target).
 */
void pipeline_asm_fill_param_slots(struct backend_AsmFuncCtx *ctx, struct ast_Module *mod, int32_t func_index) {
  int32_t off;
  int32_t np;
  int32_t i;
  uint8_t pname_buf[128];
  int32_t plen;
  struct ast_ASTArena *arena;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !mod)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  g_pipeline_asm_emit_module = mod;
  arena = g_pipeline_asm_emit_arena;
  off = 16; /* reserve [rbp-8] for callee-saved rbx */
  np = pipeline_asm_module_func_num_params_at(mod, func_index);
  for (i = 0; i < np; i++) {
    int32_t width;
    int32_t slot_off;
    pipeline_asm_module_func_param_name_copy32(mod, func_index, i, pname_buf);
    plen = pipeline_asm_module_func_param_name_len_at(mod, func_index, i);
    width = arena ? glue_func_param_home_width_c(arena, mod, func_index, i) : 8;
#if defined(__aarch64__) || defined(__arm64__)
    /*
     * PLATFORM: MACOS|ARM64 — low-end home (≡ asm_local_slot_reg_offset).
     * 8B scalar/pointer: home@off, next off+8.
     * width>8 dual/MEMORY: byte0@off, payload [off,off+width), next off+width.
     */
    slot_off = off;
    if (asm_ctx_local_append((uint8_t *)ctx, pname_buf, plen, slot_off) < 0)
      return;
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    off = (width > 8) ? (off + width) : (off + 8);
#else
    /**
     * PLATFORM: LINUX|x86_64 — high-end multi-word home.
     * 8B (scalar/pointer): home at `off`, next off+8 (historical param layout).
     * width>8 (9–16B dual-half or MEMORY): byte0 at off+width (like asm_local_slot_reg_offset);
     * words live at home, home-8, … — next free is home+8 so a following 8B param does not
     * clobber byte0 (Allocator dual-home + size; get(Vec,i) MEMORY + i).
     */
    if (width > 8)
      slot_off = off + width;
    else
      slot_off = off;
    if (asm_ctx_local_append((uint8_t *)ctx, pname_buf, plen, slot_off) < 0)
      return;
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    off = (width > 8) ? (slot_off + 8) : (off + 8);
#endif
  }
  ly->next_offset = off;
}

/**
 * Prologue param homing: write register args into fill_param_slots stack slots;
 * stack-passed args copied from [fp+#].
 *
 * Why: AAPCS64 x0-x7 @ [fp-8..-64]; 9+ @ [x29,#16] up. SysV x86 rdi..r9;
 *      7+ @ [rbp+16] up. XLANG_ABI_F32_XMM=1: SysV gp/xmm split track
 *      (f32 via xmm0–7). >16B sret: save incoming hidden dest before homing
 *      (rdi on SysV x86; x8 on AAPCS64 arm64 — must not clobber x0 which is
 *      first GP formal, no shift).
 * Contract: NULL elf_ctx/ctx/mod or func_index<0 → -1; np<=0 → 0; otherwise
 *           0 on success, -1 on emit failure.
 * PLATFORM: LINUX+MACOS x86_64 SysV — rdi..r9 (gp shift when sret active);
 *           f32 xmm path via pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c.
 * PLATFORM: MACOS|ARM64 AAPCS64 — x0..x7 (no shift; x8 is sret-only);
 *           low-end dual-GP (low@home, high@home+8).
 */
int32_t pipeline_asm_emit_param_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           struct backend_AsmFuncCtx *ctx, struct ast_Module *mod,
                                           int32_t func_index, int32_t ta) {
  int32_t np;
  int32_t reg_max;
  int32_t i;
  int32_t off;
  if (!elf_ctx || !ctx || !mod || func_index < 0)
    return -1;
  /** seed partial mega 可能未调 backend.x 的 emit_set_func_index；形参 *T field 识别依赖此下标。 */
  pipeline_asm_emit_set_func_index(func_index);
  np = pipeline_asm_module_func_num_params_at(mod, func_index);
  /**
   * >16B sret: save incoming hidden dest before param homing (independent of nargs).
   * PLATFORM: LINUX+MACOS x86_64 SysV — rdi → [sret_home].
   * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — x8 → [sret_home].
   */
  if (g_pipeline_asm_func_sret_active && g_pipeline_asm_sret_home_off >= 0) {
    if (ta == 0) {
      /* SysV: hidden dest in rdi (= arg reg 0); GP formals shift to rsi… */
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
    } else if (ta == 1) {
      /*
       * wave596 Cap residual pure: AAPCS64 sret save must not clobber x0.
       * Root: wave591 used mov x8→x0 then store_rax — x0 is first GP formal
       * (no GP shift; x8 is separate Indirect Result Location). mk(ip) with
       * >16B return stored sret dest into ip home → pointer fields / first
       * arg garbage (mac freestanding mk(&i).m.p.f wrong; host-C hid).
       * G.7: store x8 directly via store_x_reg_to_rbp(reg=8).
       * PLATFORM: MACOS|ARM64 AAPCS64 · LINUX arm64 same if ever product.
       */
      if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, 8, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
    }
  }
  if (np <= 0)
    return 0;
  if (ta == 0 && pipeline_asm_abi_f32_xmm_enabled_c() != 0)
    return pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c(elf_ctx, ctx, mod, func_index, np);
  /** Legacy SysV (f32 xmm off): MEMORY + 9–16B dual-GP by-value (same as f32_xmm path). */
  if (ta == 0) {
    struct ast_ASTArena *arena = g_pipeline_asm_emit_arena;
    int32_t gp = g_pipeline_asm_func_sret_active ? 1 : 0;
    int32_t stack_pos = 16;
    int32_t cur = 16;
    int32_t k;
    if (!arena)
      return -1;
    for (i = 0; i < np; i++) {
      int32_t psz = glue_func_param_agg_byte_size_c(arena, mod, func_index, i);
      int32_t home_w = glue_func_param_home_width_c(arena, mod, func_index, i);
      int32_t home = (home_w > 8) ? (cur + home_w) : cur;
      if (psz > 16) {
        int32_t nbytes = (psz + 7) & ~7;
        for (k = 0; k < nbytes; k += 8) {
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos + k, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - k, 0) != 0)
            return -1;
        }
        stack_pos += nbytes;
      } else if (psz > 8) {
        if (gp + 2 <= 6) {
          if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
            return -1;
          if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp + 1, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - 8, 0) != 0)
            return -1;
          gp += 2;
        } else {
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
            return -1;
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos + 8, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - 8, 0) != 0)
            return -1;
          stack_pos += 16;
        }
      } else if (gp < 6) {
        if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, 0) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
          return -1;
        gp++;
      } else {
        if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos, 0) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
          return -1;
        stack_pos += 8;
      }
      cur = (home_w > 8) ? (home + 8) : (cur + 8);
    }
    return 0;
  }
  /*
   * PLATFORM: MACOS|ARM64 AAPCS64 (wave599) — dual-GP / MEMORY param home.
   * Prior: one GP per formal at 16+i*8, ignored 9–16B INTEGER dual-GP and
   * fill_param multi-word homes → field extract on Outer formal returned 0.
   * G.7: mirror SysV x86 dual-GP/MEMORY path with arm64 low-end polarity
   * (low@home, high@home+8 ≡ glue_store_retval_pair / wave402 locals).
   * Hidden sret uses x8 (already saved above); GP formals start at x0 (no shift).
   */
  reg_max = 8;
  {
    struct ast_ASTArena *arena = g_pipeline_asm_emit_arena;
    int32_t gp = 0;
    /*
     * wave414 low-end prologue: sub sp,#fs; stp; mov x29,sp → locals [x29+16..)
     * and incoming stack args live at [x29+frame_size + …], not [x29+16]
     * (that was classic stp #-16! / high locals layout). wave603: use frame_size.
     * Fallback 16 only when frame_size unset (skip-heavy / zero-body stubs).
     */
    int32_t stack_pos = 16;
    int32_t cur = 16;
    int32_t k;
    if (!arena)
      return -1;
    if (ctx) {
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      if (ly && ly->frame_size > 16)
        stack_pos = ly->frame_size;
    }
    for (i = 0; i < np; i++) {
      int32_t psz = glue_func_param_agg_byte_size_c(arena, mod, func_index, i);
      int32_t home_w = glue_func_param_home_width_c(arena, mod, func_index, i);
      int32_t home = cur; /* low-end (match fill_param arm64) */
      if (psz > 16) {
        /* MEMORY by-value: copy nbytes from caller stack into low-end home. */
        int32_t nbytes = (psz + 7) & ~7;
        for (k = 0; k < nbytes; k += 8) {
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos + k, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home + k, ta) != 0)
            return -1;
        }
        stack_pos += nbytes;
      } else if (psz > 8) {
        /* 9–16B INTEGER dual-GP: low half @ home, high @ home+8. */
        if (gp + 2 <= reg_max) {
          if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp, home, ta) != 0)
            return -1;
          if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp + 1, home + 8, ta) != 0)
            return -1;
          gp += 2;
        } else {
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
            return -1;
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos + 8, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home + 8, ta) != 0)
            return -1;
          stack_pos += 16;
        }
      } else if (gp < reg_max) {
        if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp, home, ta) != 0)
          return -1;
        gp++;
      } else {
        if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
          return -1;
        stack_pos += 8;
      }
      cur = (home_w > 8) ? (cur + home_w) : (cur + 8);
    }
  }
  return 0;
}

/**
 * Fill block const/let slots into asm ctx sidecar.
 *
 * Why: mirror backend.x fill_local_slots — assign each const/let a stack slot
 *      via asm_local_slot_reg_offset (+8 alignment + lit temp reserve for
 *      TYPE_SLICE / array init). Mutually exclusive with
 *      asm_ctx_ensure_block_locals (stmt_order path) to avoid double-register.
 * Contract: NULL ctx/arena or block_ref<=0 → no-op; otherwise appends each
 *           const/let name+offset and advances next_offset; records slot_base
 *           via asm_ctx_block_slot_set for dedup guard.
 * PLATFORM: SHARED — slot polarity delegated to asm_local_slot_reg_offset.
 */
void pipeline_asm_fill_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t off;
  int32_t i;
  int32_t nconst;
  int32_t nlet;
  uint8_t name_buf[128];
  int32_t nlen;
  int32_t init_ref;
  int32_t slot_base;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !arena || block_ref <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /** 与 asm_ctx_ensure_block_locals 互斥，避免 stmt_order 路径重复登记偏移。 */
  if (asm_ctx_block_slot_get((uint8_t *)ctx, block_ref) >= 0)
    return;
  slot_base = asm_ctx_local_count((uint8_t *)ctx);
  off = ly->next_offset;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  for (i = 0; i < nconst; i++) {
    int32_t type_ref;
    ast_pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    nlen = ast_pipeline_block_const_name_len(arena, block_ref, i);
    type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append((uint8_t *)ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    int32_t type_ref;
    ast_pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    nlen = ast_pipeline_block_let_name_len(arena, block_ref, i);
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append((uint8_t *)ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  ly->next_offset = off;
  asm_ctx_block_slot_set((uint8_t *)ctx, block_ref, slot_base);
}
