/**
 * pipeline_asm_codegen_mega_body.c — asm codegen mega-body loop domain (BC 8.3.1).
 *
 * wave1238 G.7: pipeline_backend_asm_codegen_ast_to_elf_mega_body_c migrated
 * from pipeline_glue.c L2411-2604 to this file (same translation unit via
 * #include at the original site in glue.c). Single-purpose domain: the
 * per-module asm codegen main loop that iterates functions in WPO/PGO emit
 * order, emits prologue/param-home/block-body/epilogue, and handles sret /
 * modlet lit inits / async cps entry.
 *
 * Sole caller: ast_pool.c L1733 (asm_codegen_ast_to_elf_seed_mega C body).
 *
 * Same-TU #include contract: MUST be #included at the original glue.c site
 * (between the extern decls at L2403-2409 and #include "ast_pool.c"). All deps
 * are visible at that point — identical to pre-migration visibility:
 * - pipeline_glue_AsmFuncCtxLayout typedef (glue.c L84, static same-TU)
 * - pipeline_asm_ctx_layout (static, glue.c L86)
 * - pipeline_asm_compute_frame_size_c (glue.c L811, same-TU)
 * - pipeline_asm_emit_ctx_sret_*_{get,set} (wave223 pure BSS faces; residual
 *   mega_body writes only via pure setters — no residual sret statics)
 * - GLUE_TYPE_KIND_F32_ORD / _F64_ORD (macros, defined before #include)
 * - extern fns: pipeline_asm_wpo_pgo_* / pipeline_asm_modlet_* / backend_enc_* /
 *   backend_emit_block_body_sync_elf / pipeline_asm_emit_* / driver_diagnostic_* /
 *   link_abi_getenv / glue_asm_build_func_export_sym_c (decl L2404) / etc.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 * PLATFORM: SHARED — asm codegen orchestrator, arch branches via ta param.
 */

/**
 * wave153 Cap residual: reset per-func AsmFuncCtx between mega emit iterations.
 * Relocated from pipeline_asm_emit_block_body.c (public, next to sole callsite).
 * label_counter intentionally preserved for unique .L_N across whole mega emit.
 * PLATFORM: SHARED — ctx layout platform-independent.
 */
void pipeline_asm_ctx_reset_for_func_c(pipeline_glue_AsmFuncCtxLayout *ctx, struct ast_Module *mod) {
  if (!ctx)
    return;
  ctx->frame_size = 0;
  ctx->next_offset = 0;
  ctx->num_locals = 0;
  ctx->module_ref = mod;
  ctx->break_len = 0;
  ctx->continue_len = 0;
  ctx->loop_label_depth = 0;
  ctx->dep_pipe = NULL;
  ctx->tail_join_label_len = 0;
  asm_ctx_local_reset((uint8_t *)ctx);
}

int32_t pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t ta;
  pipeline_glue_AsmFuncCtxLayout ctx;
  uint8_t fname_buf[128];
  int32_t start_skip;
  int32_t emit_n;
  int32_t k;

  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  ta = pipeline_ctx->target_arch;
  if (ta == 1) {
    elf_ctx->e_machine = 183;
    elf_ctx->reloc_type_r_pc32 = 283;
  } else if (ta == 2) {
    elf_ctx->e_machine = 243;
    elf_ctx->reloc_type_r_pc32 = 32;
  } else {
    elf_ctx->e_machine = 62;
    elf_ctx->reloc_type_r_pc32 = 2;
  }
  memset(&ctx, 0, sizeof(ctx));
  pipeline_asm_wpo_pgo_emit_order_prepare(m);
  start_skip = asm_diag_start_func_skip();
  emit_n = pipeline_asm_wpo_pgo_emit_order_count(m);
  /**
   * PLATFORM: SHARED x86_64 — emit text-embedded module mutable lit cells once before funcs
   * so set_g/get_g share storage (not per-fn stack). Non-x86: no-op, stack residual.
   */
  if (pipeline_asm_modlet_prepare_and_emit_elf_c(m, a, elf_ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: mega_body_c modlet prepare fail\n");
    return -1;
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: mega_body_c start emit_n=%d start_skip=%d nf=%d\n", (int)emit_n, (int)start_skip,
            (int)pipeline_module_num_funcs(m));
  for (k = 0; k < emit_n; k++) {
    int32_t i = pipeline_asm_wpo_pgo_emit_order_at(m, k);
    int32_t body_ref;
    int32_t frame_sz;
    int32_t fname_len;
    int32_t export_sym_len;
    int32_t result_ref;
    uint8_t export_sym[128];
    struct backend_AsmFuncCtx *bctx = (struct backend_AsmFuncCtx *)&ctx;

    if (i < 0)
      continue;
    if (i < start_skip)
      continue;
    pipeline_elf_ctx_set_emit_hot((uint8_t *)elf_ctx, pipeline_asm_wpo_pgo_is_hot_func(m, i));
    pipeline_asm_module_func_name_copy64(m, i, fname_buf);
    fname_len = pipeline_asm_module_func_name_len_at(m, i);
    driver_diagnostic_asm_set_current_func(fname_buf, fname_len);
    pipeline_asm_emit_set_func_index(i);
    pipeline_debug_trace_named_func_bodies("mega_pre_reset", m, a);
    pipeline_asm_ctx_reset_for_func_c(&ctx, m);
    ctx.dep_pipe = pipeline_ctx;
    /* wave223: sret cells pure BSS — residual writes only via pure setters. */
    pipeline_asm_emit_ctx_sret_active_set(0);
    pipeline_asm_emit_ctx_sret_home_off_set(-1);
    pipeline_asm_emit_ctx_sret_ret_sz_set(0);
    pipeline_asm_fill_param_slots(bctx, m, i);
    pipeline_debug_trace_named_func_bodies("mega_post_param_slots", m, a);
    /**
     * >16B return: reserve 8B to save incoming hidden dest (before top-level lets).
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8 (wave591).
     * fill_param_slots already set next_offset ≥ 16 (saved fp/lr / rbx reserve).
     * wave223: pure setters (G.7 single cell authority — no residual sret static).
     */
    if (ta == 0 || ta == 1) {
      int32_t fn_ret_sz = glue_func_return_byte_size_c(m, a, i);
      if (fn_ret_sz > 16) {
        pipeline_asm_emit_ctx_sret_ret_sz_set(fn_ret_sz);
        pipeline_asm_emit_ctx_sret_active_set(1);
        pipeline_asm_emit_ctx_sret_home_off_set(ctx.next_offset);
        ctx.next_offset += 8;
      }
    }
    pipeline_asm_register_module_top_level_lets_c(bctx, m, a, i);
    pipeline_debug_trace_named_func_bodies("mega_post_register_top_level", m, a);
    /* wave580 Cap: export_sym is u8[128]; out_cap must be 128 (was 64 → silent truncate / clen<cap reject at 64). */
    export_sym_len = glue_asm_build_func_export_sym_c(m, a, i, export_sym, 128);
    if (export_sym_len <= 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, export_sym, export_sym_len, 1, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c enc_label fail func=%.*s\n", (int)export_sym_len, (char *)export_sym);
      return -1;
    }
    if (asm_skip_heavy_module_func_body(m, a, i) != 0) {
      if (backend_enc_prologue_arch(elf_ctx, 0, ta) != 0)
        return -1;
      if (pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx, ta, m, i) != 0)
        return -1;
      continue;
    }
    body_ref = pipeline_asm_module_func_body_ref_at(m, i);
    frame_sz = 0;
    if (body_ref != 0) {
      frame_sz = pipeline_asm_compute_frame_size_c(pipeline_asm_module_func_num_params_at(m, i), a, body_ref, m,
                                                    i);
      pipeline_debug_trace_named_func_bodies("mega_post_frame_size", m, a);
      if (pipeline_asm_block_num_stmt_order_at(a, body_ref) == 0)
        pipeline_asm_fill_local_slots(bctx, a, body_ref);
      pipeline_debug_trace_named_func_bodies("mega_post_fill_local_slots", m, a);
    }
    if (backend_enc_prologue_arch(elf_ctx, frame_sz, ta) != 0)
      return -1;
    /*
     * wave603: arm64 MEMORY param_home needs frame_size so incoming stack args
     * resolve at [x29+frame] (wave414 low-end prologue), not [x29+16] identity.
     */
    if (bctx) {
      pipeline_glue_AsmFuncCtxLayout *ly_fs = pipeline_asm_ctx_layout(bctx);
      if (ly_fs)
        ly_fs->frame_size = frame_sz;
    }
    if (pipeline_asm_emit_param_home_elf_c(elf_ctx, bctx, m, i, ta) != 0)
      return -1;
    /** Mutable module-level lit lets on non-hoist: seed stack slots after param home. */
    if (pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, bctx, m, i, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c top_level lit inits fail func=%.*s fi=%d\n", (int)fname_len,
                (char *)fname_buf, (int)i);
      return -1;
    }
    /** COMMON BSS starts zero; non-zero modlet inits (e.g. -1) once on hoist target. */
    if (i == pipeline_asm_hoist_target_func_index(m) &&
        pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c modlet nonzero seed fail func=%.*s\n", (int)fname_len,
                (char *)fname_buf);
      return -1;
    }
    if (pipeline_asm_emit_async_cps_entry_elf_c(a, elf_ctx, bctx, m, i, ta) != 0)
      return -1;
    if (body_ref != 0) {
      ctx.tail_join_label_len = pipeline_asm_emit_next_label_c(bctx, ctx.tail_join_label, 64);
      if (pipeline_asm_block_num_stmt_order_at(a, body_ref) > 0) {
        pipeline_debug_trace_named_func_bodies("mega_pre_emit_block_body", m, a);
        if (backend_emit_block_body_sync_elf(a, elf_ctx, body_ref, bctx, ta) != 0) {
          if (link_abi_getenv("XLANG_ASM_DEBUG"))
            fprintf(stderr, "xlang: mega_body_c emit_block_body fail func=%.*s fi=%d body_ref=%d\n",
                    (int)fname_len, (char *)fname_buf, (int)i, (int)body_ref);
          return -1;
        }
      } else {
        int32_t slot_base =
            ctx.num_locals - ast_ast_block_num_consts(a, body_ref) - ast_ast_block_num_lets(a, body_ref);
        if (slot_base < 0)
          return -1;
        if (pipeline_asm_emit_block_inits_elf_c(a, elf_ctx, body_ref, bctx, ta, slot_base) != 0)
          return -1;
      }
      if (backend_enc_label_arch(elf_ctx, ctx.tail_join_label, ctx.tail_join_label_len, 0, ta) != 0)
        return -1;
    }
    result_ref = 0;
    if (body_ref == 0 || pipeline_asm_block_num_stmt_order_at(a, body_ref) == 0)
      result_ref = pipeline_asm_get_return_expr_ref_at(a, m, i);
    if (result_ref != 0) {
      if (pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta) != 0)
        return -1;
    }
    /**
     * PLATFORM: LINUX+MACOS x86_64 SysV — place scalar float return in xmm0 before epilogue.
     * Internal path holds IEEE bits in eax/rax; callee ABI requires xmm0 for f32/f64.
     * Covers both explicit result_ref and values that jumped to tail_join via return stmts.
     */
    if (ta == 0) {
      int32_t rty = pipeline_module_func_return_type_at(m, i);
      int32_t rkind = (rty > 0) ? pipeline_type_kind_ord_at(a, rty) : -1;
      if (rkind == GLUE_TYPE_KIND_F32_ORD) {
        if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
          return -1;
      } else if (rkind == GLUE_TYPE_KIND_F64_ORD) {
        if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
          return -1;
      }
    }
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c epilogue fail func=%.*s fi=%d\n", (int)fname_len, (char *)fname_buf,
                (int)i);
      return -1;
    }
    pipeline_asm_emit_async_cps_end_func_elf_c();
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: mega_body_c done emit_n=%d rc=0\n", (int)emit_n);
  return 0;
}
