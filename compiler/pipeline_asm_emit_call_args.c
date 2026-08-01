/**
 * pipeline_asm_emit_call_args.c — asm ELF CALL-arg emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding CALL/METHOD_CALL
 * argument packing into rax[/rdx] (or lea of stack payload):
 * - glue_type_ref_is_named_struct_layout_elf_c (wave1017 G.7 fold: TYPE_NAMED
 *   has module struct layout — shared gate for lea-vs-load / pass-by-addr)
 * - glue_call_arg_var_use_lea_not_load_elf_c (VAR: lea payload vs load slot)
 * - glue_load_var_as_value_to_rax_rdx_elf_c (≤16B INTEGER dual-GP by-value)
 * - glue_type_named_layout_size_any_module_elf_c (dep-arena layout size >8)
 * - glue_call_param_named_struct_pass_addr_elf_c (MEMORY class >16B → by addr)
 * - pipeline_asm_emit_expr_elf_for_call_args (public entry; f32 lit, VAR
 *   array→slice fat, dual-GP, fixed array, STRUCT_LIT, INDEX, FIELD, rec)
 *
 * G.7: single product-mega CALL-arg ELF packing face — do not open a second
 * SysV ≤16B dual-GP path or second ARRAY→SLICE fat materializer. CALL/
 * METHOD_CALL dispatch remains seed backend_call_dispatch.
 *
 * wave1017 G.7 有则补全: named-struct layout predicate moved here from glue
 * residual (same TU; no new DEPS). index_helpers keeps a same-TU forward
 * (included earlier). GLUE_TYPE_NAMED remains defined in pipeline_glue.c
 * immediately before this #include (also used by later glue residual).
 * wave1019 G.7 有则补全: call_arg resolve + f32 VAR slot load (+ unusable
 * name / append_at_offset / var_is_param) from glue residual into this leaf.
 * Shared with emit_expr_elf_fast VAR arm + binop load_operand (same TU).
 * wave1022 G.7 有则补全: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c
 * (TYPE_SLICE dual-GP reentrancy deep-copy; use_frame=0 call-arg COMMON /
 * use_frame=1 let frame) from glue residual into this leaf.
 *
 * Callers: backend_call_dispatch.x / seed (extern); glue emit_expr leaf
 * VAR dual-GP via glue_load_var_as_value_to_rax_rdx_elf_c; glue
 * store_retval_pair (reent use_frame=1).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * call-arg packing body site (after glue_type_size_simple forward; before
 * panic/binop/field_access).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV ≤16B by-value / >16B by-addr
 *   · MACOS|ARM64 dual-GP low-end polarity (wave603)
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_call_arg_resolve_var_stack_off_elf_c (static; body in this leaf wave1019)
 * - glue_type_size_simple / glue_sysv_dual_gp_byte_size_c (later)
 * - glue_slice_let_reent_deep_copy_after_dual_gp_elf_c (body in this leaf wave1022)
 * - pipeline_asm_emit_expr_elf_rec / glue_emit_float_lit_to_rax_elf_c
 * - glue_var_decl_type_ref_elf_c (static; body in pipeline_asm_emit_var_decl.c wave1023)
 * - glue_type_is_fixed_array / backend_enc_*
 * - glue_type_ref_is_scalar_f32_c (body in binop leaf; forward below)
 * - glue_lazy_append_block_let_local (static; body in pipeline_asm_emit_var_decl.c wave1023)
 * - glue_slice_dual_gp_length_off_c / glue_slice_dual_gp_bump_past_home_c
 *   (static; bodies in pipeline_asm_emit_block_inits.c wave1024; length_off
 *   early fwd at glue ~2017; bump_past_home same-TU later def)
 * - glue_align_next_offset (later; early fwd)
 * - glue_asm_lea_*_common_* / glue_emit_bulk_mem_copy_spills_elf_c (earlier)
 * - g_pipeline_asm_al_nc_seq (early glue; shared durable/return/reent)
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_call_param_ty_ref / ...
 * - GLUE_TYPE_NAMED (macro; defined in pipeline_glue.c before this include)
 */

/* ========================================================================
 * wave1019 G.7 fold: CALL-arg residual resolve + f32 VAR slot load
 * (from pipeline_glue residual before index_eff_addr / call_args include).
 * Same-TU static. Callers: this leaf (for_call_args); glue emit_expr_elf_fast
 * VAR arm; binop try_binop_load_operand (after this include).
 * glue_var_decl_type_ref_elf_c + glue_lazy_append_block_let_local moved to
 * pipeline_asm_emit_var_decl.c (wave1023 fold; included before this leaf).
 * Forward type_ref_is_scalar_f32
 * (body in binop leaf wave1015).
 * PLATFORM: SHARED product residual C / LINUX+MACOS SysV f32 param homing.
 * ======================================================================== */

/** SKIP_TYPECK：LetDecl.name_len>0 但 name[] 全零，不可用于 sidecar 匹配。 */
static int32_t glue_block_let_name_is_unusable_c(uint8_t *name_buf, int32_t name_len) {
  int32_t k;
  if (name_len <= 0)
    return 1;
  for (k = 0; k < name_len && k < 127; k++) {
    if (name_buf[k] != 0)
      return 0;
  }
  return 1;
}

/**
 * 以已知 rbp 负偏移登记块 let（SKIP_TYPECK 无名 let 回落；勿 bump next_offset 重算槽位）。
 */
static int32_t glue_append_block_let_local_at_offset(struct backend_AsmFuncCtx *ctx, uint8_t *name,
                                                     int32_t name_len, int32_t slot_off) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !name || name_len <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  if (asm_ctx_local_find_offset((uint8_t *)ctx, name, name_len) >= 0)
    return 0;
  if (asm_ctx_local_append((uint8_t *)ctx, name, name_len, slot_off) < 0)
    return -1;
  ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
  return 0;
}

/**
 * SKIP_TYPECK 无名/空名 let：按函数体 let 槽位 + VAR 实参名登记 sidecar。
 */
static int32_t glue_call_arg_resolve_anon_body_let_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                           int32_t body_ref, int32_t let_idx, uint8_t *vname,
                                                           int32_t vlen) {
  int32_t slot_base;
  int32_t nconst;
  int32_t slot;
  int32_t slot_off;
  if (!arena || !ctx || !vname || vlen <= 0 || body_ref <= 0 || let_idx < 0)
    return -1;
  slot_base = backend_block_slot_base_for(ctx, arena, body_ref);
  nconst = ast_ast_block_num_consts(arena, body_ref);
  slot = slot_base + nconst + let_idx;
  slot_off = backend_asm_ctx_slot_offset(ctx, slot);
  if (glue_append_block_let_local_at_offset(ctx, vname, vlen, slot_off) != 0)
    return -1;
  return slot_off;
}

/**
 * CALL 实参：解析局部 VAR 栈偏移；while/if 子块 scoped lookup 失败时懒登记函数体 let。
 */
static int32_t glue_call_arg_resolve_var_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                            int32_t var_expr_ref) {
  int32_t off;
  int32_t body_ref;
  int32_t li;
  int32_t nlet;
  uint8_t vname[128];
  int32_t vlen;
  if (!arena || !ctx || var_expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return -1;
  off = glue_var_expr_stack_off_elf_c(arena, ctx, var_expr_ref);
  if (off >= 0)
    return off;
  if (!g_pipeline_asm_emit_module || g_pipeline_asm_emit_func_index < 0)
    return -1;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return -1;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  body_ref = pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
  if (body_ref <= 0)
    return -1;
  nlet = ast_ast_block_num_lets(arena, body_ref);
  for (li = 0; li < nlet; li++) {
    uint8_t lb[128];
    int32_t llen;
    int32_t k;
    int32_t eq;
    llen = pipeline_block_let_name_len(arena, body_ref, li);
    pipeline_block_let_name_copy64(arena, body_ref, li, lb);
    /** name_len 与 VAR 名等长但字节未写入（SKIP_TYPECK fill）时按 anon let 回落。 */
    if (llen == vlen && vlen > 0 && glue_block_let_name_is_unusable_c(lb, llen)) {
      if (nlet == 1 && li == 0)
        return glue_call_arg_resolve_anon_body_let_elf_c(arena, ctx, body_ref, li, vname, vlen);
      continue;
    }
    if (llen != vlen) {
      /** name_len==0 的单 let 函体（dep_sync_i 等）。 */
      if (llen == 0 && vlen > 0 && nlet == 1 && li == 0)
        return glue_call_arg_resolve_anon_body_let_elf_c(arena, ctx, body_ref, li, vname, vlen);
      continue;
    }
    eq = 1;
    for (k = 0; k < vlen; k++) {
      if (lb[k] != vname[k]) {
        eq = 0;
        break;
      }
    }
    if (eq == 0)
      continue;
    if (glue_lazy_append_block_let_local(arena, ctx, body_ref, li, vname, vlen) != 0)
      return -1;
    return glue_var_expr_stack_off_elf_c(arena, ctx, var_expr_ref);
  }
  return -1;
}

/** VAR 是否为当前 emit 函数的形参（任意 param 槽）。 */
static int32_t glue_var_is_current_func_param_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t var_expr_ref) {
  int32_t np;
  int32_t pi;
  if (!arena || !ctx || !g_pipeline_asm_emit_module || g_pipeline_asm_emit_func_index < 0)
    return 0;
  np = pipeline_module_func_num_params_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
  for (pi = 0; pi < np; pi++) {
    if (glue_expr_is_func_param_at_c(arena, g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index, var_expr_ref,
                                     pi))
      return 1;
  }
  return 0;
}

/** Forward: glue_type_ref_is_scalar_f32_c (body in pipeline_asm_emit_binop.c wave1015). */
static int32_t glue_type_ref_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t type_ref);

/**
 * f32 VAR 装入 rax：XLANG_ABI_F32_XMM=1 形参走 32-bit homing；否则 caller f64 movabs → cvtsd2ss。
 */
static int32_t glue_load_f32_var_slot_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                    int32_t var_expr_ref, int32_t off, int32_t ta) {
  if (glue_var_is_current_func_param_c(arena, ctx, var_expr_ref)) {
    if (ta == 0 && pipeline_asm_abi_f32_xmm_enabled_c() != 0) {
      int32_t tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
      if (glue_type_ref_is_scalar_f32_c(arena, tr))
        return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, 4, ta);
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
      return -1;
    return backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx, ta);
  }
  return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off, 4, ta);
}

/** f32 VAR 装入 rbx（与 rax 路径对称）。 */
static int32_t glue_load_f32_var_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                    int32_t var_expr_ref, int32_t off, int32_t ta) {
  if (glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, var_expr_ref, off, ta) != 0)
    return -1;
  return backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
}

/**
 * Type ref is a module-local named struct that has a struct layout entry
 * (e.g. Pair). Used by CALL-arg lea-vs-load and index_helpers hidden-pointer
 * gates. G.7 single predicate — do not reimplement layout name scan elsewhere.
 *
 * wave1017: folded from pipeline_glue residual into this leaf (callers:
 * glue_call_arg_var_use_lea_not_load_elf_c here; index_helpers via forward).
 * PLATFORM: SHARED layout predicate.
 */
static int32_t glue_type_ref_is_named_struct_layout_elf_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                            int32_t ty_ref) {
  uint8_t nm[128];
  int32_t nlen;
  int32_t k;
  int32_t ln;
  int32_t j;
  if (ty_ref <= 0 || !mod || !arena)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty_ref) != GLUE_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, ty_ref, nm);
  if (nlen <= 0)
    return 0;
  for (k = 0; k < pipeline_module_num_struct_layouts_at(mod); k++) {
    ln = pipeline_module_struct_layout_name_len(mod, k);
    if (ln != nlen || ln <= 0)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != nm[j])
        break;
    }
    if (j == nlen)
      return 1;
  }
  return 0;
}

/**
 * CALL 实参 VAR：块内 let struct / 定长数组 T[N] 须 lea 传地址；标量 / *T / 形参 struct 指针槽须 load。
 */
static int32_t glue_call_arg_var_use_lea_not_load_elf_c(struct ast_ASTArena *arena, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx) {
  int32_t decl_ty;
  int32_t scope_br;
  uint8_t vname[128];
  int32_t vlen;
  if (!arena || !ctx || expr_ref <= 0)
    return 0;
  if (asm_local_var_slot_holds_indirect_ptr(arena, expr_ref, g_pipeline_asm_emit_module, (uint8_t *)ctx) != 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, expr_ref, vname);
  /** emit 中 *T 形参 CALL 须 load 槽内指针，勿 lea 栈地址（v: *Vec3f_soa → reserve_one）。 */
  if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0 &&
      g_pipeline_asm_emit_func_index < (int32_t)g_pipeline_asm_emit_module->num_funcs) {
    int32_t pty = pipeline_module_func_param_type_ref_for_name(g_pipeline_asm_emit_module,
                                                               g_pipeline_asm_emit_func_index, vname, vlen);
    if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == 9)
      return 0;
  }
  scope_br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
  decl_ty = 0;
  if (scope_br > 0)
    decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
  /** main 等无 scope sidecar：用 skip-typeck 回填的 VAR resolved_type_ref（hello msg: u8[12]）。 */
  if (decl_ty <= 0)
    decl_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (decl_ty <= 0)
    return 0;
  if (glue_type_ref_is_named_struct_layout_elf_c(arena, g_pipeline_asm_emit_module, decl_ty)) {
    /**
     * PLATFORM: LINUX+MACOS x86_64 SysV — INTEGER-class aggregates ≤16B pass by value in
     * one/two GPRs (load slot to rax[/rdx]), not as a pointer. Only >16B / MEMORY class
     * uses lea of the stack slot. Formal C (std_string_length_StrView) expects rdi+rsi.
     */
    int32_t sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, decl_ty, 0);
    if (sz > 0 && sz <= 16)
      return 0;
    return 1;
  }
  if (glue_type_is_fixed_array(arena, decl_ty)) {
    /*
     * wave417 Cap residual pure: T[N] formal home is E* (8B pointer; see
     * glue_func_param_agg_byte_size_c). Forwarding `mid(a)` must load the slot
     * (pass E*), not lea(home) which yields E**. Local T[N] still lea(payload).
     * Root: prior always return 1 → mid did `add x0,x29,#0x10` then bl sum;
     * sum INDEX read pointer bits as i32 (fwd 97≠100 / fwd2 106≠20).
     * G.7: reuse glue_emit_func_param_is_indirect_array_slot_c (INDEX twin).
     * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
     */
    if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0 &&
        glue_emit_func_param_is_indirect_array_slot_c(arena, g_pipeline_asm_emit_module, expr_ref) != 0)
      return 0;
    return 1;
  }
  return 0;
}

/** SysV 9–16B dual-GP size for import POD (def later near store_retval). */
static int32_t glue_sysv_dual_gp_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);

/**
 * VAR 按值装入 rax（及 9–16B struct 的 rdx）：局部 let 双 half 栈 load；形参 hidden pointer 则 deref。
 * or_i32/and_i32 三元 `r : other` 与 `return r` 须完整 SysV 双寄存器，单 load 会丢 err 半或误用指针。
 */
/**
 * Load local VAR by-value into return/arg GP pair for call-arg packing.
 * PLATFORM: SHARED freestanding · LINUX|x86 high-end (low@off, high@off-8 → rax+rdx)
 *   · MACOS|ARM64 low-end (low@off, high@off+8 → x0+x1).
 *
 * wave603 Cap residual: arm64 previously returned after the low half only
 * (`if (ta != 0) return 0`), so dual-GP call-arg spill stored dirty x1
 * (e.g. last STRUCT_LIT base pointer) → mac fs take(p) for 12B/16B Pair wrong
 * (var12=78/var16=70; call_dual via mk() dual return was green).
 * G.7: complete dual load for ta==1 with low-end polarity ≡ param_home /
 * store_retval_pair / glue_sysv_spill (wave599/600); no second authority.
 */
static int32_t glue_load_var_as_value_to_rax_rdx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                        int32_t var_expr_ref, int32_t off, int32_t ta) {
  int32_t tr;
  int32_t sz;
  if (!elf_ctx || off < 0)
    return -1;
  if (glue_local_var_slot_needs_ptr_load_elf_c(arena, var_expr_ref, off, ctx) != 0) {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
      return -1;
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
    if (tr <= 0)
      tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
    sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
    if (sz <= 16 && tr > 0) {
      int32_t nsz = glue_sysv_dual_gp_byte_size_c(arena, tr);
      if (nsz > sz)
        sz = nsz;
    }
    if (sz > 8 && sz <= 16 && ta == 0)
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    /* arm64 *T dual soft: still pointer-in-x0 only (rare freestanding path). */
    return 0;
  }
  tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
  sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
  if (sz <= 16 && tr > 0) {
    int32_t nsz = glue_sysv_dual_gp_byte_size_c(arena, tr);
    if (nsz > sz)
      sz = nsz;
  }
  /*
   * 9–16B INTEGER dual-GP by-value into the return/arg GP pair that spill expects:
   *   - x86 SysV: rax + rdx (high@off-8 high-end)
   *   - arm64 AAPCS64: x0 + x1 (high@off+8 low-end)
   * wave603: arm64 must load x1; prior early-return left x1 dirty.
   */
  if (sz > 8 && sz <= 16 && arena && ctx) {
    if (ta == 1) {
      /* MACOS|ARM64: high first into x1 (via x0 temp), then low into x0. */
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off + 8, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
      return 0;
    }
    if (ta == 0) {
      /* LINUX+MACOS x86_64: low→rax, high→rdx (unchanged polarity). */
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rdx_arch(elf_ctx, off - 8, ta) != 0)
        return -1;
      return 0;
    }
  }
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
    return -1;
  return 0;
}

/**
 * CALL 形参 named struct 是否 >8B（含 dep 模块 layout 回落；import Allocator 等）。
 * PLATFORM: SHARED (layout size) / LINUX+MACOS x86_64 SysV (call class consumers).
 *
 * Root (Option_u8 named=24): dep layout field type_refs live in **dep arena**.
 * Sizing them with the caller arena reinterprets indices (e.g. bool → TYPE_SLICE 16)
 * → metrics bool@16 + u8@1 + pad → 24 → false sret. G.7: size dep layouts only
 * with pipeline_dep_ctx_arena_at (same contract as typeck_merge field mapping).
 */
static int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref) {
  uint8_t name[128];
  int32_t nlen;
  int32_t base_off;
  int32_t base_len;
  int32_t sz;
  int32_t di;
  int32_t nd;
  int32_t k;
  int32_t j;
  struct ast_Module *dm;
  struct ast_ASTArena *darena;
  if (!arena || ty_ref <= 0 || pipeline_type_kind_ord_at(arena, ty_ref) != GLUE_TYPE_NAMED)
    return 0;
  /** After size_simple has layout match, trust it when >8 (MEMORY / dual-GP widen). */
  sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, ty_ref, 0);
  if (sz > 8)
    return sz;
  nlen = pipeline_type_named_name_into(arena, ty_ref, name);
  if (nlen <= 0 || nlen > 127)
    return sz;
  base_off = 0;
  for (k = 0; k < nlen; k++) {
    if (name[k] == (uint8_t)'.')
      base_off = k + 1;
  }
  base_len = nlen - base_off;
  if (g_pipeline_asm_emit_dep_pipe) {
    nd = pipeline_dep_ctx_ndep(g_pipeline_asm_emit_dep_pipe);
    for (di = 0; di < nd; di++) {
      dm = pipeline_dep_ctx_module_at(g_pipeline_asm_emit_dep_pipe, di);
      darena = pipeline_dep_ctx_arena_at(g_pipeline_asm_emit_dep_pipe, di);
      if (!dm || !darena)
        continue;
      /**
       * Do not glue_type_size_simple(dm, caller_arena, ty_ref): that still sizes field
       * type_refs against the caller pool. Use dep arena for metrics only.
       */
      for (k = 0; k < (int32_t)dm->num_struct_layouts; k++) {
        int32_t ln = pipeline_module_struct_layout_name_len(dm, k);
        int32_t eq = 1;
        if (ln == nlen) {
          for (j = 0; j < nlen; j++) {
            if (pipeline_module_struct_layout_name_byte_at(dm, k, j) != name[j]) {
              eq = 0;
              break;
            }
          }
        } else if (ln == base_len && base_len > 0) {
          for (j = 0; j < base_len; j++) {
            if (pipeline_module_struct_layout_name_byte_at(dm, k, j) != name[base_off + j]) {
              eq = 0;
              break;
            }
          }
        } else {
          eq = 0;
        }
        if (!eq)
          continue;
        sz = typeck_x_type_size_from_layout_glue(dm, darena, k, 1);
        if (sz > 8)
          return sz;
      }
    }
  }
  return 0;
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — pass named struct by address only when MEMORY class
 * (>16B). 9–16B INTEGER class is by value in two GPRs (matches formal C ABI).
 */
static int32_t glue_call_param_named_struct_pass_addr_elf_c(struct ast_ASTArena *arena, int32_t pty) {
  return glue_type_named_layout_size_any_module_elf_c(arena, pty) > 16 ? 1 : 0;
}

/* ========================================================================
 * wave1022 G.7 fold: TYPE_SLICE reent deep-copy after dual-GP
 * (from pipeline_glue residual). Same-TU static. Callers: for_call_args
 * (use_frame=0 COMMON) + glue store_retval_pair let-init (use_frame=1 frame).
 * Late bodies still via early glue forwards: dual_gp_length_off, align_next_offset;
 * lea COMMON helpers + bulk_mem (spill leaf) already earlier in TU.
 * PLATFORM: SHARED product residual C / LINUX+MACOS SysV fat reentrancy.
 * ======================================================================== */

/**
 * wave409–412/418 Cap residual pure: freestanding TYPE_SLICE deep-copy after dual-GP.
 * After dual-GP is stored at home (data@slot_off + length half), deep-copy payload and
 * retarget fat.data.
 *
 * Root (wave409/410): durable ARRAY_LIT return uses per-function static/COMMON — recursive
 * `let s=mk(n)` and dual same-call formals last-wins without deep-copy.
 * Root (wave411): body-time frame bump without prologue frame_size → SP overrun.
 * Root (wave412): COMMON BSS twin of host static `__xlang_sdN` for dual call-arg (zero frame).
 * Root (wave418): COMMON is *one buffer per emit site* → recursive `let s=mk(n)` last-wins
 * (walk=8≠36). Host let uses *stack* `__xlang_ldN` (per-frame). G.7: let path use_frame=1
 * reserves caller-frame buffer (pre-summed into compute_frame_size); call-arg keeps COMMON
 * (use_frame=0, unique seq per arg). max_n 512→1024 (twin host / ARRAY_LIT face).
 * wave632: large NAMED esz>8 was clamped to 4 → `let s: S24[] = mk()` deep-copy packed
 * half-words (Ubuntu simple_r=193≠110 after durable COMMON return was correct). Accept
 * esz>8 + chunked bulk per elem; payload ceiling 64KiB for large (scalar stays 8192).
 * Soft: length>max_n still caps. PLATFORM: SHARED freestanding · LINUX x86 · MACOS|ARM64.
 *
 * @param home fat data home (slot_off from store_retval_pair / call-arg fat home)
 * @param use_frame 1 = frame buffer (let); 0 = SHN_COMMON (call-arg)
 * @return 0 success; -1 hard fail
 */
static int32_t glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t home, int32_t ty_ref, int32_t use_frame) {
  /* Twin host `__xlang_sdN[1024]` / wave406 call-arg deep-copy cap (wave418 raise). */
  int32_t max_n = 1024;
  int32_t esz = 4;
  int32_t elem_tr = 0;
  int32_t nbytes;
  int32_t max_payload;
  int32_t loop_len;
  int32_t end_len;
  int32_t seq;
  int32_t v;
  int32_t nd;
  int32_t di;
  int32_t llen;
  int32_t dest_off = -1; /* frame payload home when use_frame */
  int32_t src_spill = -1;
  int32_t dst_spill = -1;
  uint8_t loop_lbl[32];
  uint8_t end_lbl[32];
  uint8_t label[24];
  uint8_t digs[8];
  const char *pfx;

  if (!arena || !elf_ctx || !ctx || home < 0 || ty_ref <= 0)
    return -1;
  if (ta != 0 && ta != 1)
    return -1;
  elem_tr = pipeline_type_elem_ref_at(arena, ty_ref);
  if (elem_tr > 0)
    esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
  if (esz <= 0)
    esz = 4;
  /*
   * wave632: esz>8 large NAMED kept (glue_type_size_simple via index face).
   * Prior clamp to 4 rewrote return [S24{…}] durable COMMON into 4B-strided frame
   * (a0=1 b0=0 garbage; Ubuntu 193). Weird mid widths 3/5/6/7 still fall to 4.
   */
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8)
    esz = 4;
  /* Scalar face 8KiB (wave418); large NAMED up to 64KiB (1024×64). */
  max_payload = (esz > 8) ? (1024 * 64) : 8192;
  if (esz > 0 && max_n > max_payload / esz)
    max_n = max_payload / esz;
  if (max_n <= 0)
    max_n = 1;
  nbytes = max_n * esz;
  if (nbytes <= 0 || nbytes > max_payload)
    return -1;

  /*
   * Cap length + park on CPU stack BEFORE allocating frame dest (wave418).
   * Root: allocating dest via next_offset must not race length half; park first so
   * retarget always restores a known good capped length (host twin min(len,max_n)).
   * jge: max_n >= length → keep; else rbx=max_n. SHARED (no x86-only jle).
   */
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, max_n, 0, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = length */
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = max_n */
    return -1;
  if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  {
    uint8_t keep_lbl[32];
    int32_t keep_len = pipeline_asm_emit_next_label_c(ctx, keep_lbl, 32);
    if (keep_len <= 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, keep_lbl, keep_len, ta) != 0) /* max_n >= length → keep */
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, max_n, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = max_n */
      return -1;
    if (backend_enc_label_arch(elf_ctx, keep_lbl, keep_len, 0, ta) != 0)
      return -1;
  }
  if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* stack: [capped_len] */
    return -1;

  if (use_frame != 0) {
    /*
     * Let path: per-frame buffer (true recursion). Bump next_offset; compute_frame_size
     * pre-sums TYPE_SLICE CALL/METHOD lets so prologue covers this growth.
     * Force dest past dual-GP fat window at home (16B).
     * wave632: x86 high-end must place byte0 at the *deep* end of the alloc so
     * dest+ai*esz stays below rbp (prior dest_off=shallow + large esz*max_n walked
     * past rbp → Ubuntu SIGSEGV on S24[] deep-copy; scalar small-n hid it).
     * PLATFORM: SHARED freestanding · LINUX|x86 high-end · MACOS|ARM64 low-end.
     */
    pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
    int32_t fat_hi;
    int32_t dest_base;
    if (!ly)
      return -1;
    dest_base = ly->next_offset;
    if ((dest_base % 8) != 0)
      dest_base = (dest_base + 7) / 8 * 8;
    fat_hi = home + 16;
    if (dest_base < fat_hi)
      dest_base = fat_hi;
    if ((dest_base % 8) != 0)
      dest_base = (dest_base + 7) / 8 * 8;
    if (dest_base < 0)
      return -1;
    if (ta == 1) {
      /* MACOS|ARM64 low-end: byte0 @ dest_base, grows +. */
      dest_off = dest_base;
      ly->next_offset = dest_base + nbytes;
    } else {
      /* LINUX|x86 high-end: byte0 at deep end; +byteoff stays under rbp. */
      dest_off = dest_base + nbytes;
      ly->next_offset = dest_off;
    }
    if (dest_off < 0)
      return -1;
    glue_align_next_offset(ctx);
    llen = 0;
  } else {
    /* Call-arg: unique COMMON per deep-copy site (dual same-call needs two buffers). */
    int32_t common_align = esz;
    if (common_align > 16)
      common_align = 16;
    if (common_align < 1)
      common_align = 1;
    seq = g_pipeline_asm_al_nc_seq;
    if (seq < 0 || seq > 999999)
      seq = 0;
    g_pipeline_asm_al_nc_seq = seq + 1;
    llen = 0;
    pfx = "Lxlang_sd_";
    while (pfx[llen] != 0 && llen < 12) {
      label[llen] = (uint8_t)pfx[llen];
      llen++;
    }
    v = seq;
    nd = 0;
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
      label[llen++] = digs[di];
    if (pipeline_elf_ctx_add_common_sym((uint8_t *)elf_ctx, label, llen, nbytes, common_align) != 0)
      return -1;
  }
  /* wave632: bulk esz>8 needs two pointer spills (src/dst) for chunked copy. */
  if (esz > 8) {
    pipeline_glue_AsmFuncCtxLayout *ly_sp = pipeline_asm_ctx_layout(ctx);
    if (!ly_sp)
      return -1;
    if (ly_sp->next_offset + 32 < ly_sp->next_offset)
      return -1;
    ly_sp->next_offset += 16;
    src_spill = ly_sp->next_offset;
    ly_sp->next_offset += 16;
    dst_spill = ly_sp->next_offset;
  }

  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_lbl, 32);
  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 32);
  if (loop_len <= 0 || end_len <= 0)
    return -1;

  /* ai = 0 parked on stack (zero frame growth; push/pop only). */
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;

  if (backend_enc_label_arch(elf_ctx, loop_lbl, loop_len, 0, ta) != 0)
    return -1;

  /*
   * stack invariant at loop head: [ai]
   * if ai >= length → end (must pop ai so end has clean stack for retarget).
   */
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* keep [ai] */
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* park for cmp */
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = length */
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = ai */
    return -1;
  if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, end_lbl, end_len, ta) != 0) /* ai >= length → done */
    return -1;
  /* fall-through: stack still [ai]; will pop ai at end_lbl */

  /*
   * Body: value = *(data + ai*esz); *(dest + ai*esz) = value; ai++; jmp loop.
   * stack: [ai]
   * wave632: esz>8 → bulk mem copy (scalar store_rax_to_rbx_indirect only ≤8).
   */
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = ai */
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai] keep for store/incr */
    return -1;
  if (esz > 8) {
    /* bulk: src = data+ai*esz; dst = dest_base+ai*esz; chunked copy esz bytes. */
    if (src_spill < 0 || dst_spill < 0)
      return -1;
    /* byteoff = ai * esz */
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_imul_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai, byteoff] */
      return -1;
    /* src = fat.data + byteoff */
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
      return -1;
    /* recompute byteoff from [ai]; dst = dest_base + byteoff */
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* ai */
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai] */
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_imul_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai, byteoff] */
      return -1;
    if (use_frame != 0) {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, dest_off, ta) != 0)
        return -1;
    } else if (ta == 1) {
      if (glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen) != 0)
        return -1;
    } else if (glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen) != 0) {
      return -1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* byteoff; stack [ai] */
      return -1;
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
      return -1;
    if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta) != 0)
      return -1;
  } else {
    /* byteoff = ai * esz → park */
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_imul_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai, byteoff] */
      return -1;
    /* src load: data + byteoff */
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = byteoff */
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = byteoff */
      return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0) /* rax = data + byteoff */
      return -1;
    if (esz == 1) {
      if (backend_enc_load_zext8_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (esz == 8) {
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else {
      if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai, value] */
      return -1;

    /* dest: COMMON + ai*esz. Recompute byteoff from ai under value. */
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* value */
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = value (park in rbx briefly) */
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = ai */
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai] restore for incr */
      return -1;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0) /* [ai, value] */
      return -1;
    /* rax still = ai (push does not clobber); byteoff = ai*esz */
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_imul_rbx_rax_arch(elf_ctx, ta) != 0) /* rax = byteoff */
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) /* [ai, value, byteoff] */
      return -1;
    /* lea dest (frame or COMMON) → rbx; rbx += byteoff; pop value → store indirect */
    if (use_frame != 0) {
      if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, dest_off, ta) != 0)
        return -1;
    } else if (ta == 1) {
      if (glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, label, llen) != 0)
        return -1;
    } else if (glue_asm_lea_rbx_common_rip_x86(elf_ctx, label, llen) != 0) {
      return -1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = byteoff */
      return -1;
    /* rax = dest_base + byteoff (rax was byteoff, rbx was dest_base). */
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /*
     * backend_enc_add_rax_rbx_arch: rax = rax + rbx → rax = dest+byteoff.
     * Need dest in rbx for store_rax_to_rbx_indirect: mov rax → rbx, then pop value → rax.
     */
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = value; stack [ai] */
      return -1;
    if (backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, esz, ta) != 0)
      return -1;
  }

  /* ai++ ; jmp loop. stack [ai] */
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, loop_lbl, loop_len, ta) != 0)
    return -1;

  /* end: stack still [capped_len, ai] from jge path — discard ai. */
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* discard ai */
    return -1;

  /* retarget fat.data → frame dest or COMMON */
  if (use_frame != 0) {
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, dest_off, ta) != 0)
      return -1;
  } else if (ta == 1) {
    if (glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen) != 0)
      return -1;
  } else if (glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen) != 0) {
    return -1;
  }
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
    return -1;
  /* Restore fat.length from parked capped_len (stack: [capped_len]). */
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
    return -1;
  return 0;
}


/**
 * CALL 实参 emit 入口：>16B let struct / 定长数组 lea 传地址；≤16B POD struct 按值 load rax[+rdx]；
 * 其余委托 rec（标量 load、*T/形参 struct load 指针）。
 * PLATFORM: LINUX+MACOS x86_64 SysV for ≤16B by-value.
 */
int32_t pipeline_asm_emit_expr_elf_for_call_args(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                 int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t pty;
  /** XLANG_ABI_F32_XMM=1：f32 实参发 32-bit 位型；否则 legacy f64 widen 经 gp 寄存器。 */
  int32_t call_abi_widen_f64 = pipeline_asm_abi_f32_xmm_enabled_c() != 0 ? 0 : 1;
  /** f32 实参：typeck resolved 或 callee 形参表；勿 f64 movabs（低 32 位=0 致 heap 列全 0）。 */
  if (arena && pipeline_expr_kind_ord_at(arena, expr_ref) == 1) {
    int32_t tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_F32_ORD)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, tr, call_abi_widen_f64);
    pty = g_pipeline_asm_emit_call_param_ty_ref;
    if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == GLUE_TYPE_KIND_F32_ORD)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, pty, call_abi_widen_f64);
  }
  pty = g_pipeline_asm_emit_call_param_ty_ref;
  if (arena && ctx && pipeline_expr_kind_ord_at(arena, expr_ref) == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
    if (off >= 0) {
      vlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (vlen > 0 && vlen <= 63) {
        int32_t want_slice = 0;
        int32_t arg_ty;
        int32_t decl_ty;
        int32_t arr_sz;
        pipeline_expr_var_name_into(arena, expr_ref, vname);
        /*
         * wave395 Cap residual pure: fixed TYPE_ARRAY local as TYPE_SLICE formal.
         * Root: use_lea / bare lea(array) passes T* as fat* → length half reads
         * array payload (host/asm: len_of(a)=a[2]=30 for i32[4]). G.7: materialize
         * dual-GP fat {data=lea(a), length=N} then lea fat (ARRAY_LIT call-arg twin;
         * host: emit_call_arg_slice_abi compound). wave394 length half polarity.
         * PLATFORM: SHARED freestanding · LINUX gold + MACOS arm64.
         */
        want_slice = 0;
        if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
          want_slice = 1;
        arg_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
        decl_ty = 0;
        {
          int32_t scope_br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
          if (scope_br > 0)
            decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
        }
        if (decl_ty <= 0)
          decl_ty = arg_ty;
        arr_sz = 0;
        if (decl_ty > 0 && glue_type_is_fixed_array(arena, decl_ty))
          arr_sz = pipeline_type_array_size_at(arena, decl_ty);
        if (arr_sz <= 0 && arg_ty > 0 &&
            pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_ARRAY)
          arr_sz = pipeline_type_array_size_at(arena, arg_ty);
        if (want_slice && arr_sz > 0) {
          int32_t home;
          int32_t base_off;
          pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
          if (!ly || !elf_ctx)
            return -1;
          base_off = ly->next_offset;
          if ((base_off % 8) != 0)
            base_off = (base_off + 7) / 8 * 8;
          home = base_off + 16;
          ly->next_offset = (ta == 1) ? (home + 16) : (home + 8);
          glue_align_next_offset(ctx);
          /* data@rax = &array payload */
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
            return -1;
          if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta),
                                               ta) != 0)
            return -1;
          /* pass &fat as slice* */
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
            return -1;
          return 0;
        }
        if (glue_call_arg_var_use_lea_not_load_elf_c(arena, expr_ref, ctx) != 0)
          return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
        if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == GLUE_TYPE_KIND_F32_ORD)
          return glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
        /*
         * wave417 Cap residual pure: T[N] formal home is E* (8B). Forward mid(a)
         * must load the pointer only — glue_load_var_as_value would treat payload
         * size 16 as dual-GP struct deref (Ubuntu mid: mov (%rbx); mov 8(%rbx);
         * pass two GPs into sum which expects one E* → SIGSEGV). G.7: load home.
         * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
         */
        if (g_pipeline_asm_emit_module &&
            glue_emit_func_param_is_indirect_array_slot_c(arena, g_pipeline_asm_emit_module,
                                                           expr_ref) != 0)
          return backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
        /*
         * PLATFORM: SHARED freestanding · LINUX gold + MACOS arm64 —
         * TYPE_SLICE formals lower as `struct xlang_slice_* *` (codegen.x authority).
         * Call sites must pass a fat*:
         *   - local by-value dual-GP fat → lea(home) of sequential {data,length}
         *   - slice* param / indirect slot already holds fat* → load the slot
         * wave401 Cap residual pure: prior path always lea(home). Forwarding a
         * slice param (`take(s)` inside mid) passed fat** → callee INDEX read
         * pointer bits as payload (mid_twice=162, reent_sp=239; host-C green).
         * G.7: reuse glue_enc_local_slot_ptr_or_addr_elf_c (needs_ptr_load twin
         * of INDEX/length wave332e — do not invent a second detector).
         * Dual-load of by-value fat still forbidden (SIGSEGV on formal fat*).
         */
        if ((pty > 0 &&
             pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE) ||
            (arg_ty > 0 &&
             pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_SLICE))
          return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, off, ctx, ta);
        /* ≤16B named struct / scalar: dual-half load when size 9–16 (SysV rax+rdx). */
        return glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
      }
    }
  }
  /**
   * wave396 Cap residual pure: FIELD_ACCESS fixed TYPE_ARRAY as TYPE_SLICE formal.
   * Root: bare lea(field) / load passes T* as fat* → length half garbage (host-C
   * sum3(b.a) was 138 before fat compound). G.7: dual-GP fat {data=lea(b.a),
   * length=N} then lea fat (VAR twin wave395; host emit_call_arg_slice_abi).
   * PLATFORM: SHARED freestanding · LINUX gold + MACOS arm64.
   *
   * wave649 Cap residual pure: STRUCT_LIT/CALL base field as TYPE_SLICE formal.
   * Root: wave396 used pipeline_asm_emit_lvalue_eff_addr_elf_c, which only handles
   * VAR/INDEX/DEREF/FIELD chains as true lvalues — Wrap{…}.xs / mk().xs returned
   * -1 → freestanding CG002 (host-C temp + &field green; VAR w.xs fat already green;
   * wave610 TYPE_ARRAY formal green via glue_try_index_var_or_field_base_to_rax).
   * G.7: reuse the same INDEX/call-arg field-address helper (wave609 leave_addr
   * materialise) for data half; fat pack path unchanged — do not invent a second
   * FIELD→slice path.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (arena && ctx && elf_ctx && pipeline_expr_kind_ord_at(arena, expr_ref) == 44) {
    int32_t want_slice = 0;
    int32_t fty = 0;
    int32_t arr_sz = 0;
    int32_t rty;
    if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
      want_slice = 1;
    if (want_slice) {
      fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, expr_ref);
      if (fty > 0 && glue_type_is_fixed_array(arena, fty))
        arr_sz = pipeline_type_array_size_at(arena, fty);
      rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
      if (arr_sz <= 0 && rty > 0 &&
          pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_ARRAY)
        arr_sz = pipeline_type_array_size_at(arena, rty);
      if (arr_sz > 0) {
        int32_t home;
        int32_t base_off;
        int32_t br;
        pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
        if (!ly)
          return -1;
        base_off = ly->next_offset;
        if ((base_off % 8) != 0)
          base_off = (base_off + 7) / 8 * 8;
        home = base_off + 16;
        ly->next_offset = (ta == 1) ? (home + 16) : (home + 8);
        glue_align_next_offset(ctx);
        /* data@rax = &field payload (VAR / STRUCT_LIT / CALL / DEREF base; ≡ wave610) */
        br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
        if (br != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
          return -1;
        if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta),
                                             ta) != 0)
          return -1;
        /* pass &fat as slice* */
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
          return -1;
        return 0;
      }
    }
  }
  /**
   * wave610 Cap residual pure: FIELD_ACCESS fixed TYPE_ARRAY as TYPE_ARRAY formal (E*).
   * Root: freestanding `take(w.xs)` / `take(Wrap{…}.xs)` / `take(mk().xs)` fell through to
   * emit_expr field rvalue (leave_addr=0) → load first array word as "pointer" → callee
   * INDEX SEGV (host-C temp + &field green; ARRAY_LIT call-arg already lea green).
   * G.7: reuse INDEX base address helper (wave609 call_base leave_addr + VAR-base field
   * lea) — pass E* = &field payload only; do not invent a second FIELD array path.
   * wave651: same helper covers FIELD over INDEX (`take(m[i].xs)`) — INDEX eff_addr + off.
   * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
   */
  if (arena && ctx && elf_ctx && pipeline_expr_kind_ord_at(arena, expr_ref) == 44) {
    int32_t want_arr = 0;
    int32_t fty = 0;
    int32_t rty;
    int32_t is_arr = 0;
    if (pty > 0 &&
        (pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_ARRAY ||
         glue_type_is_fixed_array(arena, pty)))
      want_arr = 1;
    if (want_arr) {
      fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, expr_ref);
      if (fty > 0 && glue_type_is_fixed_array(arena, fty))
        is_arr = 1;
      rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
      if (is_arr == 0 && rty > 0 &&
          pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_ARRAY)
        is_arr = 1;
      if (is_arr) {
        int32_t br =
            glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
        if (br == 0)
          return 0;
        if (br == -1)
          return -1;
        /* -2: fall through to other FIELD / rec paths */
      }
    }
  }
  /**
   * FIELD_ACCESS struct 字段 CALL 实参（v.al → alloc）：>8B struct 须 lea 字段地址。
   * 优先按 callee 形参 type_ref；pty 缺失时按字段类型 layout（import heap.Allocator 等）。
   */
  if (arena && ctx && pipeline_expr_kind_ord_at(arena, expr_ref) == 44) {
    int32_t use_lea = 0;
    if (pty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, pty) != 0)
      use_lea = 1;
    if (use_lea == 0) {
      int32_t fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, expr_ref);
      if (fty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, fty) != 0)
        use_lea = 1;
    }
    /* Do not force lea for all NAMED fields: ≤16B SysV is by-value (rax+rdx). */
    if (use_lea != 0)
      return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
  /*
   * wave332 Cap residual pure: call-arg ARRAY_LIT for TYPE_SLICE formal.
   * Root: rec path emits data ptr only (or bare array); formal is slice* → need dual-GP
   * fat home + lea (mirror VAR call-arg lea path above / let-init wave329 dual store).
   * G.7: same dual-GP layout data@home length@home-8; payload via emit_array_lit.
   * PLATFORM: SHARED freestanding · LINUX gold (host-C uses compound + & via codegen).
   *
   * wave622 Cap residual pure: force_esz from formal TYPE_SLICE elem (≡ let-init wave329).
   * Root: wave332 only used formal esz for **frame** size; payload still went through
   * `pipeline_asm_emit_array_lit_elf_c` → `pipeline_asm_array_lit_elem_byte_sz_c`, which
   * stamps untyped INT_LIT as i32 (esz=4). Then `take([10,32])` for []i64/[]u8 stored
   * 4-byte elems while INDEX used formal width → s[0] ok/low half, s[1]=0, sum=10
   * (let a: []i64 = [10,32]; take(a) already green via force_esz durable). f64[] lit
   * call-arg same class (let green, bare lit call red). Prefer durable + force_esz
   * (G.7: expand let-init authority; do not invent a second packer).
   * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64 co-path.
   */
  if (arena && ctx && elf_ctx &&
      pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
    int32_t slice_ty = 0;
    int32_t rty;
    if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
      slice_ty = pty;
    rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (slice_ty == 0 && rty > 0 &&
        pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_SLICE)
      slice_ty = rty;
    if (slice_ty > 0) {
      int32_t n_arr;
      int32_t home;
      int32_t base_off;
      int32_t force_esz = 0;
      int32_t durable = 0;
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
        return -1;
      if (!ly)
        return -1;
      /* wave625: G.7 force_esz authority (scalar + TYPE_NAMED); twin of let-init. */
      force_esz = glue_array_lit_force_esz_from_elem_type_c(
          arena, pipeline_type_elem_ref_at(arena, slice_ty));
      /*
       * Allocate dual-GP home: data@home, length via glue_slice_dual_gp_length_off_c
       * (wave394: arm64 home+8 / x86 home-8 → C fat memory for lea as slice*).
       * Durable payload lives in text/COMMON — only fat home needs stack room.
       * Stack fallback: also reserve payload past home (wave331 temp discipline).
       */
      base_off = ly->next_offset;
      if ((base_off % 8) != 0)
        base_off = (base_off + 7) / 8 * 8;
      home = base_off + 16;
      {
        int32_t esz = force_esz > 0 ? force_esz : 4;
        int32_t payload_bytes;
        int32_t past;
        past = (ta == 1) ? (home + 16) : (home + 8);
        /* Pre-reserve payload for stack fallback; durable will not use it. */
        payload_bytes = n_arr * esz;
        if (payload_bytes < 0)
          payload_bytes = 0;
        if (payload_bytes > 0 && home + payload_bytes > past)
          past = home + payload_bytes;
        ly->next_offset = past;
      }
      glue_align_next_offset(ctx);
      /* Prefer durable + force_esz (≡ let-init / return ARRAY_LIT→slice). */
      if ((ta == 0 || ta == 1) &&
          glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, expr_ref, force_esz, ta,
                                                         ctx) == 0) {
        durable = 1;
      } else if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta,
                                                              force_esz) != 0) {
        /* wave631: stack fallback keeps formal force_esz (large NAMED / esz>8). */
        return -1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) !=
          0)
        return -1;
      if (durable == 0 && n_arr > 0)
        pipeline_asm_bump_next_offset_for_array_lit(arena, expr_ref, ctx);
      glue_slice_dual_gp_bump_past_home_c(ctx, home, ta);
      /* Pass &fat (slice* ABI); lea(data) — length at +8 in memory after wave394. */
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      return 0;
    }
  }
  /*
   * wave345 Cap residual pure: CALL/METHOD returning TYPE_SLICE as call-arg for
   * slice* formal (`pass(take())`). Root: rec path keeps only data@rax and drops
   * length@rdx; pass then treats rax as fat* → Ubuntu freestanding SIGSEGV.
   * Host-C materializes static __xlang_sp (same leaf). G.7: dual-GP → stack fat
   * home then lea. wave394: arch-aware length half.
   *
   * wave404 Cap residual pure: CALL/METHOD returning fixed TYPE_ARRAY as the same
   * TYPE_SLICE formal (`len_of(take3(1))`). Root: wave345 always stored length
   * from rdx (true dual-GP slice ABI). TYPE_ARRAY returns E* in rax only
   * (wave352 freestanding / host __xlang_ar); length is CTFE N. On arm64
   * backend_enc_store_rdx_to_rbp_arch is x86-only (ta!=0 → -1) → CG002; on
   * x86 length half was garbage. Host: emit_call_arg_slice_abi + __xlang_caN
   * (wave396/397). G.7: same dual-GP fat layout as VAR/FIELD (wave395/396) —
   * data@home = E* (rax), length = imm N, then lea fat as slice*.
   * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
   */
  if (arena && ctx && elf_ctx &&
      (pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_CALL ||
       pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_METHOD_CALL)) {
    int32_t slice_ty = 0;
    int32_t rty;
    int32_t arr_sz = 0;
    int32_t ret_kind = -1;
    if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
      slice_ty = pty;
    rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (slice_ty == 0 && rty > 0 &&
        pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_SLICE)
      slice_ty = rty;
    /*
     * Detect fixed TYPE_ARRAY callee return for slice* formals.
     * Critical: host/codegen lower T[N] return as E* (wave352), and typeck often
     * stamps CALL resolved_type as TYPE_PTR — call_return_type_kind_ord then
     * returns PTR from resolved and never consults the func return TYPE_ARRAY.
     * G.7: always resolve callee return_type_ref from the module (dep-mapped)
     * when formal wants a slice; do not trust PTR resolved alone.
     */
    if (rty > 0 && glue_type_is_fixed_array(arena, rty)) {
      arr_sz = pipeline_type_array_size_at(arena, rty);
      ret_kind = (int32_t)ast_TypeKind_TYPE_ARRAY;
    }
    if (arr_sz <= 0 && slice_ty > 0) {
      struct ast_Module *rmod = 0;
      int32_t rfi = -1;
      int32_t rdep = -1;
      int32_t rrty = 0;
      if (glue_asm_resolve_call_target_module_c(arena, expr_ref, &rmod, &rfi, &rdep) == 0 &&
          rmod && rfi >= 0) {
        rrty = pipeline_module_func_return_type_at(rmod, rfi);
        if (rrty > 0 && rdep >= 0 && g_pipeline_asm_emit_dep_pipe) {
          int32_t mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(
              rdep, rrty, arena, g_pipeline_asm_emit_dep_pipe);
          if (mapped > 0)
            rrty = mapped;
        }
        if (rrty > 0 &&
            (glue_type_is_fixed_array(arena, rrty) ||
             pipeline_type_kind_ord_at(arena, rrty) == (int32_t)ast_TypeKind_TYPE_ARRAY)) {
          arr_sz = pipeline_type_array_size_at(arena, rrty);
          ret_kind = (int32_t)ast_TypeKind_TYPE_ARRAY;
          if (rty <= 0 || !glue_type_is_fixed_array(arena, rty))
            rty = rrty;
        } else if (rrty > 0) {
          ret_kind = pipeline_type_kind_ord_at(arena, rrty);
        }
      }
    }
    if (ret_kind < 0 && rty > 0)
      ret_kind = pipeline_type_kind_ord_at(arena, rty);
    if (ret_kind < 0)
      ret_kind = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
    /*
     * wave404: TYPE_ARRAY return → slice* formal.
     * Materialize dual-GP fat with a *caller-frame* payload copy (host __xlang_caN twin):
     * freestanding take3 currently returns E* into the callee frame (stack), which
     * dangles before the outer callee runs — length-only probes hide it; sum3 needs data.
     * G.7: emit CALL → spill E* → copy N×esz into payload_off → fat{data=lea(payload),N}.
     */
    if (slice_ty > 0 && arr_sz > 0) {
      int32_t home;
      int32_t base_off;
      int32_t spill_off;
      int32_t payload_off;
      int32_t esz = 4;
      int32_t ai;
      int32_t elem_tr;
      int32_t past;
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      if (!ly)
        return -1;
      if (rty > 0) {
        elem_tr = pipeline_type_elem_ref_at(arena, rty);
        if (elem_tr > 0)
          esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
        if (esz <= 0)
          esz = 4;
      }
      base_off = ly->next_offset;
      if ((base_off % 8) != 0)
        base_off = (base_off + 7) / 8 * 8;
      /*
       * Frame layout (G.7 / wave394 polarity):
       *   spill E* @ spill_off
       *   dual-GP fat @ home (data) + length half (arm64 home+8 / x86 home-8)
       *   payload copy:
       *     MACOS|ARM64: home+16 .. home+16+N*esz (positive grow away from length)
       *     LINUX|x86: payload_off = home+N*esz; stores lea+i*esz grow *toward* fat
       *       in address space (offsets decrease). Must keep payload_off >= home+N*esz
       *       so element i=N-1 stays at offset >= home (no clobber of fat.data).
       *       Prior home+8 left only 8B before data half → sum3 saw garbage (Ubuntu 94).
       */
      spill_off = base_off + 8;
      home = spill_off + 16;
      if (ta == 1) {
        payload_off = home + 16;
        past = payload_off + arr_sz * esz;
      } else {
        payload_off = home + arr_sz * esz;
        if (payload_off < home + 8)
          payload_off = home + 8;
        if ((payload_off % 8) != 0)
          payload_off = (payload_off + 7) / 8 * 8;
        /* max offset used: payload base (i=0); fat uses home / home-8 */
        past = payload_off;
        if (past < home + 8)
          past = home + 8;
      }
      if (past < payload_off || past < home)
        return -1;
      ly->next_offset = past;
      glue_align_next_offset(ctx);
      /* Emit call → E* in rax. */
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta) != 0)
        return -1;
      /* Deep-copy payload (wave351 CALL→array field twin; host __xlang_caN). */
      for (ai = 0; ai < arr_sz; ai++) {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta) != 0)
          return -1;
        if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
          return -1;
        if (esz == 1) {
          if (backend_enc_load_zext8_from_rax_arch(elf_ctx, ta) != 0)
            return -1;
        } else if (esz == 8) {
          if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
            return -1;
        } else {
          if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
            return -1;
        }
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta) != 0)
          return -1;
      }
      /* fat.data = &payload */
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta),
                                           ta) != 0)
        return -1;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      return 0;
    }
    if (slice_ty > 0) {
      int32_t home;
      int32_t base_off;
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      if (!ly)
        return -1;
      base_off = ly->next_offset;
      if ((base_off % 8) != 0)
        base_off = (base_off + 7) / 8 * 8;
      home = base_off + 16;
      ly->next_offset = (ta == 1) ? (home + 16) : (home + 8);
      glue_align_next_offset(ctx);
      /* Emit call → SysV dual-GP data@rax length@rdx (true TYPE_SLICE return). */
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) !=
          0)
        return -1;
      /*
       * wave410 Cap residual pure: dual same-call TYPE_SLICE formals last-wins.
       * Root: durable ARRAY_LIT return uses per-function static/COMMON; dual-GP
       * fat alone → both formals .data alias last write (sum2(take(1),take(2))
       * fs 72≠69; host wave406 already deep-copied). G.7: reuse wave409 frame
       * deep-copy after dual-GP, then lea fat as slice*. PLATFORM: SHARED fs.
       */
      /* wave418: call-arg keeps COMMON (use_frame=0) — dual same-call unique BSS seq. */
      if (glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena, elf_ctx, ctx, ta, home,
                                                             slice_ty, 0) != 0)
        return -1;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      return 0;
    }
  }
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta);
}
