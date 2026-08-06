/**
 * pipeline_asm_emit_call_args.c — asm ELF CALL-arg emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding CALL/METHOD_CALL
 * argument packing into rax[/rdx] (or lea of stack payload):
 * - glue_type_ref_is_named_struct_layout_elf_c — wave190 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_call_arg_var_use_lea_not_load_elf_c — wave190 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_load_var_as_value_to_rax_rdx_elf_c — wave193 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_type_named_layout_size_any_module_elf_c — wave191 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_call_param_named_struct_pass_addr_elf_c — wave191 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_sysv_dual_gp_byte_size_c — wave192 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_func_param_home_width_c — wave192 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_func_return_byte_size_c — wave192 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_func_param_agg_byte_size_c — wave193 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_call_return_byte_size_c — wave194 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_call_arg_value_byte_size_c — wave195 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_call_return_type_kind_ord_c — wave196 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_deref_struct16_rax_ptr_elf_c — wave197 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_call_struct16_ret_needs_rax_deref_c — wave197 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_call_param_type_ref_at_c — wave198 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_asm_resolve_call_target_module_c — wave199 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_load_f32_var_slot_to_rax_elf_c / _to_rbx_elf_c — wave200 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twins
 * - pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c — wave201 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin;
 *   private is_f32/is_f64 pure helpers co-leave
 * - pipeline_asm_push_sysv_memory_by_value_elf_c — wave202 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_store_memory_by_value_to_sp_elf_c — wave202 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - glue_call_arg_resolve_var_stack_off_elf_c — wave203 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin;
 *   private helpers unusable/append_at_offset/anon body-let pure-owned same wave
 * - glue_store_retval_pair_to_rbp_elf_c — wave204 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin;
 *   private glue_copy_large_struct_from_rax_ptr_elf_c pure-owned same wave
 * - glue_slice_let_reent_deep_copy_after_dual_gp_elf_c — wave205 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_set/call_expected_ret_ty_c — wave206 pure leave
 *   (runtime_pipeline_abi pure BSS); Cap residual prototype only + seed cold twin
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
 * wave1045 G.7 fold: glue_func_param_agg_byte_size_c (formal param aggregate
 * byte size; SysV ≤16B dual-GP / >16B MEMORY / SLICE+ARRAY pointer lowering)
 * migrated here from glue residual — callee-side param sizing twin of the
 * caller-side call-arg packing. Consumed by glue_func_param_home_width_c +
 * fill_param_slots / emit_func_param_home (still in glue.c, same TU).
 * wave1046 G.7 fold: glue_func_return_byte_size_c (func return type byte
 * size; 0 for void, 8 for TYPE_ARRAY pointer lowering, else type_size_simple)
 * migrated here from glue residual — return-value sizing twin of param sizing
 * above. Consumed by frame-size reserve + sret activation (still in glue.c).
 * wave1047 G.7 fold: glue_func_param_home_width_c (home slot width; 8B floor,
 * >8B aligned up to 8) migrated here from glue residual — direct consumer of
 * glue_func_param_agg_byte_size_c above. Consumed by fill_param_slots /
 * emit_func_param_home (still in glue.c, same TU).
 * wave1048 G.7 fold: glue_call_return_byte_size_c (CALL expr return type byte
 * size; resolves callee func_index + maps dep type_ref to caller arena)
 * migrated here from glue residual — call-site return sizing twin of
 * wave1046 glue_func_return_byte_size_c (func_index variant). Consumed by
 * field_access.c:328 + struct_let.c:141 + glue.c:3269/3383 (call-arg sret).
 * Fwd decl at L356 serves all post-#include callsites; struct_let.c:93
 * retains its own fwd decl (struct_let.c #include at L2266 < L2392).
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

/* wave1205: backend_emit_expr_call / backend_emit_expr_method_call extern
 * fwd decls — definitions in seed partial (backend_call_dispatch.from_x.c).
 * Original fwd decls at glue.c L3223 are AFTER this file's #include at L1660;
 * needed for wave1205-migrated EXPR_CALL/METHOD_CALL thin wrappers at EOF. */
extern int32_t backend_emit_expr_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                      struct ast_Expr e, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_emit_expr_method_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                             int32_t expr_ref, struct ast_Expr e, struct backend_AsmFuncCtx *ctx,
                                             int32_t target_arch);

/* wave1209: glue_field_access_layout_field_type_ref_by_name_c static fwd
 * decl — definition in pipeline_asm_emit_field_access.c L111 (#include at
 * glue.c L1684, AFTER this file's #include at L1660). Needed for wave1209-
 * migrated pipeline_asm_call_arg_value_byte_size_c at EOF (FIELD_ACCESS
 * field type resolution fallback). */
/* wave151 Cap residual: pure field_access leave (was static fwd). PLATFORM: SHARED. */
extern int32_t glue_field_access_layout_field_type_ref_by_name_c(struct ast_ASTArena *arena,
                                                                  struct ast_Module *mod, int32_t fa_ref);

/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_call_arg_resolve_var_stack_off_elf_c (wave203 pure leave; Cap residual prototype)
 * - glue_type_size_simple / glue_sysv_dual_gp_byte_size_c (later)
 * - glue_slice_let_reent_deep_copy_after_dual_gp_elf_c (wave205 pure leave;
 *   Cap residual prototype only)
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

/* wave203 pure-owned: glue_call_arg_resolve_var_stack_off_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Private helpers
 * glue_block_let_name_is_unusable_c / glue_append_block_let_local_at_offset /
 * glue_call_arg_resolve_anon_body_let_elf_c pure-owned same wave (sole
 * consumers; Cap residual host bodies removed). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding CALL-arg VAR stack home · SKIP_TYPECK anon let. */
int32_t glue_call_arg_resolve_var_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                            int32_t var_expr_ref);

/* wave149: glue_type_ref_is_scalar_f32_c pure-owned leave — Cap residual extern. PLATFORM: SHARED. */
extern int32_t glue_type_ref_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t type_ref);

/* wave200 pure-owned: glue_load_f32_var_slot_to_rax_elf_c + _to_rbx_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Private is_param helper pure-owned with the pair (was static residual).
 * PLATFORM: SHARED freestanding f32 VAR slot load · LINUX+MACOS SysV xmm home. */
int32_t glue_load_f32_var_slot_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                    int32_t var_expr_ref, int32_t off, int32_t ta);
int32_t glue_load_f32_var_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                    int32_t var_expr_ref, int32_t off, int32_t ta);

/* wave190 pure-owned: glue_type_ref_is_named_struct_layout_elf_c +
 * glue_call_arg_var_use_lea_not_load_elf_c (runtime_pipeline_abi pure).
 * Cap residual for_call_args uses pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding CALL-arg lea-vs-load. */
int32_t glue_type_ref_is_named_struct_layout_elf_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t ty_ref);
int32_t glue_call_arg_var_use_lea_not_load_elf_c(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx);

/* wave192 pure-owned: glue_sysv_dual_gp_byte_size_c (runtime_pipeline_abi).
 * Cap residual dual-GP load / param sizing uses pure; G.7 single authority.
 * PLATFORM: SHARED freestanding SysV dual-GP width. */
int32_t glue_sysv_dual_gp_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);

/* wave194 pure-owned: glue_call_return_byte_size_c (runtime_pipeline_abi).
 * Cap residual field_access / struct_let / MEMORY packing uses pure; G.7 single
 * authority — no host body. PLATFORM: SHARED freestanding CALL return sizing. */
int32_t glue_call_return_byte_size_c(struct ast_ASTArena *arena, int32_t call_expr_ref);

/* wave204 pure-owned: glue_copy_large_struct_from_rax_ptr_elf_c private pure
 * helper of store_retval_pair (body in runtime_pipeline_abi). Cap residual
 * host body removed (sole consumer pure-left same wave). */

/* wave193 pure-owned: glue_load_var_as_value_to_rax_rdx_elf_c (runtime_pipeline_abi).
 * Cap residual for_call_args / expr dual-GP VAR uses pure; G.7 single authority.
 * PLATFORM: SHARED freestanding dual-GP by-value load · LINUX x86 · MACOS|ARM64. */
int32_t glue_load_var_as_value_to_rax_rdx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                        int32_t var_expr_ref, int32_t off, int32_t ta);

/* wave191 pure-owned: glue_type_named_layout_size_any_module_elf_c +
 * glue_call_param_named_struct_pass_addr_elf_c (runtime_pipeline_abi pure).
 * Cap residual dual-gp / for_call_args / param sizing uses pure; G.7 single
 * authority — no host body.
 * PLATFORM: SHARED freestanding CALL named layout size + MEMORY pass-by-addr. */
int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref);
int32_t glue_call_param_named_struct_pass_addr_elf_c(struct ast_ASTArena *arena, int32_t pty);

/* ========================================================================
 * wave1022 G.7 fold → wave205 pure leave: TYPE_SLICE reent deep-copy after
 * dual-GP. Body in runtime_pipeline_abi.x (#[no_mangle] export). Cap residual:
 * prototype only. Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Callers: for_call_args (use_frame=0 COMMON) + pure store_retval_pair
 * (use_frame=1 frame; same-module pure).
 * PLATFORM: SHARED freestanding · LINUX x86 · MACOS|ARM64 fat reentrancy.
 * ======================================================================== */

/* wave205 pure-owned: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding TYPE_SLICE dual-GP reentrancy deep-copy. */
int32_t glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t home, int32_t ty_ref, int32_t use_frame);

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

/* wave193 pure-owned: glue_func_param_agg_byte_size_c (runtime_pipeline_abi).
 * Cap residual fill_param / home_width / param sizing uses pure; G.7 single authority.
 * PLATFORM: SHARED freestanding formal param aggregate sizing. */
int32_t glue_func_param_agg_byte_size_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                       int32_t func_index, int32_t param_index);

/* wave192 pure-owned: glue_func_return_byte_size_c + glue_func_param_home_width_c
 * (runtime_pipeline_abi pure). Cap residual frame/sret/fill_param uses pure;
 * G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding return size + param home width. */
int32_t glue_func_return_byte_size_c(struct ast_Module *mod, struct ast_ASTArena *arena, int32_t func_index);
int32_t glue_func_param_home_width_c(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_index,
                                    int32_t param_index);

/* wave194 pure-owned: glue_call_return_byte_size_c body in runtime_pipeline_abi
 * (G.7 single authority). Cap residual resolve remains public host below;
 * pure call_return calls resolve via Cap residual. Prototype retained above. */

/* wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body in
 * runtime_pipeline_abi (G.7 single authority). Cap residual host body removed;
 * seed backend_call_dispatch links pure via extern. Prototype at EOF for
 * same-TU documentation only. */

/* wave192 pure-owned: glue_sysv_dual_gp_byte_size_c body in runtime_pipeline_abi
 * (G.7 single authority). Cap residual load_var / store_retval / param sizing
 * call pure; prototype retained above for same-TU early callsites. */

/* wave204 pure-owned: glue_store_retval_pair_to_rbp_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Private
 * glue_copy_large_struct_from_rax_ptr_elf_c pure-owned same wave.
 * Cap residual: prototype only. Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding CALL/METHOD/STRUCT let-home retval store
 * · LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64. */
int32_t glue_store_retval_pair_to_rbp_elf_c(struct ast_Module *m, struct ast_ASTArena *arena,
                                            struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ty_ref,
                                            int32_t slot_off, int32_t ta, int32_t init_ref,
                                            struct backend_AsmFuncCtx *ctx);

/* wave201 pure-owned: glue_func_param_is_f32_c / glue_func_param_is_f64_c
 * bodies in runtime_pipeline_abi (private pure helpers of param_home f32 xmm).
 * Cap residual host bodies removed (sole consumer pure-left same wave).
 * PLATFORM: SHARED freestanding SysV xmm param kind predicates. */

/* wave197 pure-owned: pipeline_asm_deref_struct16_rax_ptr_elf_c body in
 * runtime_pipeline_abi (G.7 single authority). Cap residual host body removed.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding struct16 *rax → dual-GP load. */
int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);

/* wave197 pure-owned: pipeline_asm_call_struct16_ret_needs_rax_deref_c body in
 * runtime_pipeline_abi (G.7 single authority). Cap residual host body removed.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding struct16 sret-vs-dual-GP classifier. */
int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);

/* wave1062: extern decl — pipeline_dep_ctx_arena_at defined in glue.c:11662
 * (after this leaf's #include at L2395). Needed for dep-arena fallback in
 * pipeline_asm_call_return_type_kind_ord_c below. */
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/**
 * Resolve a CALL expression's return TypeKind ordinal for asm emit.
 *
 * Why: after a CALL, the SysV retval harvest path must know whether the
 * callee returns f32/f64 (SSE class — harvest xmm0) vs i32/i64/struct (GP
 * class — harvest rax[/rdx]). The caller-arena resolved_type_ref is the
 * fast path; when missing (skip_heavy C callees, dep imports without
 * resolved_type), the callee module + func_ix must be resolved via
 * glue_asm_resolve_call_target_module_c (wave1061 same leaf) and the
 * return type_ref fetched + mapped into the caller arena. Dep callee
 * type_refs live in dep arenas — using them with caller-arena kind_ord is
 * garbage (hides f64 as non-float, breaks SSE classification — root cause
 * of abs/signum returning NaN). G.7 single mapping authority.
 *
 * Invariant: returns a valid TypeKind ordinal (>=0) on success, -1 on
 * resolve failure. Dep callee return type_ref is first mapped via
 * pipeline_typeck_get_dep_return_type_in_caller_arena_c; if mapping fails,
 * kind_ord is read from the dep arena directly (safe — kind_ord is
 * arena-local, type_ref is not cross-arena portable but kind_ord read
 * against the owning arena is correct).
 *
 * Asm/Perf: O(1) — one resolved_type lookup + one resolve_call_target +
 * one dep map. Cold path — called per CALL retval harvest in
 * glue_asm_harvest_sse_call_ret_to_gpr_c (backend_call_dispatch.x:3316),
 * binop load_operand (binop.c:869/914), cmp cc select (cmp.c:231/252),
 * and call_args.c:1352 (call-arg f32/fast-path gate).
 *
 * PLATFORM: SHARED — LINUX+MACOS x86_64 SysV SSE/GP harvest + MACOS|ARM64
 * AAPCS64 (kind_ord only selects harvest register; arch select is at the
 * backend_enc call site, not here).
 *
 * wave1062 G.7: migrated from glue.c:13849 (body ~30 LOC). Extern
 * (non-static): extern prototype at struct_let.c:99 (via #include at
 * L2269 < call_args.c L2395) visible to all callsites (call_args.c:1352
 * same leaf; binop.c:869/914 via #include L2413 > 2395; cmp.c:231/252 via
 * #include L3690 > 2395; backend_call_dispatch.x:3316 + seeds via extern C
 * link). Dependencies: pipeline_expr_resolved_type_ref (extern glue.c:1698
 * < 2395); pipeline_type_kind_ord_at (extern < 2395);
 * glue_asm_resolve_call_target_module_c (static fwd decl struct_let.c:78
 * via #include L2269 < 2395; def still in glue.c:13555);
 * pipeline_module_func_return_type_at (extern glue.c:1954 < 2395);
 * pipeline_typeck_get_dep_return_type_in_caller_arena_c (extern glue.c:788
 * < 2395); pipeline_dep_ctx_arena_at (extern glue.c:11662 > 2395 —
 * forward declared just above); g_pipeline_asm_emit_dep_pipe (global).
 */
/* wave196 pure-owned: pipeline_asm_call_return_type_kind_ord_c body in
 * runtime_pipeline_abi (G.7 single authority). Seed backend_call_dispatch /
 * pure binop/cmp harvest link pure via extern; Cap residual host body removed.
 * PLATFORM: SHARED freestanding CALL return TypeKind ordinal. */
int32_t pipeline_asm_call_return_type_kind_ord_c(struct ast_ASTArena *arena, int32_t call_expr_ref);

/* wave1063: extern decls — defined in glue.c after this leaf's #include (L2395).
 * Needed for dep-arena param type_ref mapping in
 * pipeline_asm_call_param_type_ref_at_c below. */
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_get_dep_arena_slot(int32_t i);
extern int32_t pipeline_typeck_dep_return_type_to_caller_arena_c(struct ast_ASTArena *dep_arena,
                                                                int32_t dep_return_type_ref,
                                                                struct ast_ASTArena *caller_arena);

/* wave198 pure-owned: pipeline_asm_call_param_type_ref_at_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * PLATFORM: SHARED freestanding CALL formal param type_ref (caller arena). */
int32_t pipeline_asm_call_param_type_ref_at_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                              int32_t param_index);

/* ============================================================
 * wave1150 G.7: CALL-target module/func_index resolver
 * (migrated from pipeline_glue.c L9843-10042).
 *
 * Why here: glue_asm_resolve_call_target_module_c resolves the callee
 * (struct ast_Module**, func_index*, dep_ix*) for a CALL/METHOD_CALL expr.
 * It is the dispatch twin of the call-arg packing domain already in this
 * file — every call-arg emitter (lines 1334/1725/2176/2292/2379) calls this
 * resolver to get (mod, func_ix, dep_ix) before packing args.
 *
 * Contract: returns 0 on success with mod_out/func_ix_out/dep_ix_out filled;
 * returns -1 on failure. Resolves in order: (1) pre-resolved func_index from
 * typeck, (2) pipeline_typeck_resolve_call_func_index_c fallback, (3) import
 * binding METHOD_CALL (math.floor), (4) import binding FIELD_ACCESS
 * (CALL+FIELD_ACCESS form), (5) linear dep scan.
 *
 * Dependencies (visible via fwd decls below + same-TU globals):
 *   - g_pipeline_asm_emit_module / g_pipeline_asm_emit_dep_pipe (static globals
 *     in glue.c, visible same-TU)
 *   - pipeline_typeck_resolve_call_func_index_c (static; defined in
 *     pipeline_typeck_method_call.c #include'd at glue.c L10491; static fwd
 *     decl below)
 *   - pipeline_typeck_find_func_return_type_in_module_c (extern; defined at
 *     glue.c L8926; extern fwd decl below)
 *   - pipeline_typeck_find_func_return_type_in_module_by_name_c (extern;
 *     already visible — used by other functions in this leaf)
 *   - parser_get_module_num_imports (extern; extern fwd decl below)
 *   - pipeline_expr_call_resolved_func_index_at / pipeline_expr_call_resolved_
 *     dep_index_at / pipeline_expr_kind_ord_at / pipeline_expr_method_call_* /
 *     pipeline_expr_var_name_* / pipeline_expr_call_callee_ref_at /
 *     pipeline_expr_field_access_* (all extern, header-declared)
 *   - pipeline_dep_ctx_module_at / pipeline_dep_ctx_ndep (extern)
 *   - pipeline_module_import_kind_at / pipeline_module_import_binding_name_len /
 *     pipeline_module_import_binding_name_byte_at (extern)
 *   - GLUE_TYPECK_IMPORT_BINDING / GLUE_TYPECK_IMPORT_SELECT (enum; moved
 *     before this file's #include at glue.c L2241 — wave1150)
 *   - ast_ExprKind_EXPR_METHOD_CALL (global enum)
 *
 * Static fwd decl at pipeline_asm_emit_struct_let.c:78 (struct_let.c #include'd
 * at glue.c L2120 < this file's #include at L2251) provides TU-wide visibility
 * for callers in this leaf that precede the EOF definition.
 *
 * PLATFORM: SHARED — pure CALL-target resolution; no platform ABI dep.
 * ============================================================ */

/* extern fwd decls for dependencies defined after this file's #include point. */
extern int32_t pipeline_typeck_find_func_return_type_in_module_c(
    struct ast_Module *mod, struct ast_ASTArena *mod_arena, struct ast_ASTArena *caller_arena,
    struct ast_ASTArena *callee_arena, int32_t callee_expr_ref, int32_t from_dep_index,
    struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);
extern int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref,
                                                 uint8_t *out64);
extern int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx,
                                                            int32_t off);
/* static fwd decl — definition at pipeline_typeck_method_call.c (glue.c #include
 * at L10491, AFTER this file's #include at L2251). */
static int32_t pipeline_typeck_resolve_call_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                         int32_t call_expr_ref);

/* wave199 pure-owned: glue_asm_resolve_call_target_module_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding CALL-target resolve · import BINDING/SELECT. */
int32_t glue_asm_resolve_call_target_module_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                              struct ast_Module **mod_out, int32_t *func_ix_out,
                                              int32_t *dep_ix_out);

/* ============================================================
 * wave1151 G.7: SysV x86 f32 xmm param homing
 * (migrated from pipeline_glue.c L4612-4726).
 *
 * Why here: pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c is the SysV x86
 * gp/xmm split-track param homing path (XLANG_ABI_F32_XMM=1). It is the
 * callee-side twin of the call-arg packing domain in this file — the caller
 * packs f32/f64 into xmm0-7 (or stack), and this function homes them into
 * fill_param_slots stack slots. It directly consumes glue_func_param_agg_byte_
 * size_c / glue_func_param_home_width_c / glue_func_param_is_f32_c /
 * glue_func_param_is_f64_c (all in this leaf, wave1045-1059).
 *
 * Contract: emits prologue param homing for np params. Returns 0 on success,
 * -1 on failure. gp starts at 1 when sret_active (rdi consumed by hidden
 * sret). f32/f64 → xmm0-7 (or stack if >8); 9-16B INTEGER → 2 consecutive
 * GPs (or 16B stack) into dual-half home; >16B named struct → MEMORY class
 * copy from [rbp+stack_pos] into full-size home; else → one GP.
 *
 * Dependencies (all visible in this leaf or same-TU globals):
 *   - g_pipeline_asm_emit_arena (static global in glue.c, same-TU)
 *   - g_pipeline_asm_func_sret_active (static global in glue.c, same-TU)
 *   - glue_func_param_agg_byte_size_c (static, wave1045, same leaf)
 *   - glue_func_param_home_width_c (static, wave1047, same leaf)
 *   - glue_func_param_is_f64_c (static, wave1059, same leaf)
 *   - glue_func_param_is_f32_c (static, wave1059, same leaf)
 *   - backend_enc_*_arch (extern, header-declared)
 *
 * Caller (in glue.c, AFTER this file's #include at L2251):
 *   - pipeline_asm_emit_param_home_elf_c (glue.c L4733+; call at L4774)
 *   No static fwd decl needed: caller is after the #include point.
 *
 * PLATFORM: LINUX+MACOS x86_64 SysV — f32 xmm split-track is x86-only.
 * ============================================================ */

/* wave201 pure-owned: pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: LINUX+MACOS x86_64 SysV — f32 xmm split-track param home. */
int32_t pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct backend_AsmFuncCtx *ctx,
                                                        struct ast_Module *mod, int32_t func_index,
                                                        int32_t np);

/* wave1195 G.7 → wave206 pure leave: pipeline_asm_set/call_expected_ret_ty_c
 * + pure BSS in runtime_pipeline_abi.x (#[no_mangle] export).
 * Cap residual: prototype only. Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X (working BSS, twin of pure).
 *
 * Why colocate residual prototypes: call expected return type is set/read
 * during asm emit CALL arg processing — domain stays call_args. Early fwd
 * (pipeline_glue_early_fwd.c) + same-TU consumers keep C prototypes.
 *
 * Callers: pure struct_let / field_access (same-module after leave); seed
 * backend_call_dispatch.from_x.c (getter via extern).
 *
 * PLATFORM: SHARED — asm emit call ret ty tracking is platform-agnostic. */

/* wave206 pure-owned: pipeline_asm_set/call_expected_ret_ty_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export + pure BSS g_call_expected_ret_ty).
 * Cap residual: prototype only. Seed cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding CALL expected-ret tracking. */
void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
int32_t pipeline_asm_call_expected_ret_ty_c(void);

/* ========================================================================== *
 * wave1205 G.7: pipeline_asm_emit_expr_call_c + pipeline_asm_emit_expr_method_call_c
 * migrated from pipeline_glue.c L3232-3251. Colocated with call-arg emit domain
 * (call_args.c #include at glue.c L1660). Both are thin M8-tail wrappers that
 * pool-copy ast_Expr then delegate to seed partial backend_emit_expr{,_method}_call.
 *
 * Members (2 fns):
 *  - pipeline_asm_emit_expr_call_c        (EXPR_CALL thin wrapper)
 *  - pipeline_asm_emit_expr_method_call_c (EXPR_METHOD_CALL thin wrapper)
 *
 * Deps (all extern, fwd decls retained in glue.c L3223-3227):
 *  - backend_emit_expr_call / backend_emit_expr_method_call (seed partial)
 *  - pipeline_arena_expr_get_copy (extern, ast_pool_arena.c)
 *
 * Callers: no TU-internal callsites. Sole callers are seeds
 * (backend.x L1610/L1626) via extern + ast_pool.c symbol table L9812/L9813
 * + m8_tail_thin_backend_x.pl .x delegate generator.
 *
 * PLATFORM: SHARED — pure delegation, no arch branch.
 * ========================================================================== */

/**
 * Emit text asm for EXPR_CALL — thin M8-tail wrapper.
 *
 * Why: backend.x extern call requires a C-side pool-copy of ast_Expr
 *      (X->C struct copy can misalign kind field); this wrapper performs
 *      the copy then delegates to seed partial backend_emit_expr_call.
 * Contract: expr_ref<=0 -> -1; otherwise delegates return value.
 * Asm/Perf: O(1) — one pool copy + one tail call.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_expr_call_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                      struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  struct ast_Expr e;
  if (expr_ref <= 0)
    return -1;
  e = pipeline_arena_expr_get_copy(arena, expr_ref);
  return backend_emit_expr_call(arena, out, expr_ref, e, ctx, target_arch);
}

/**
 * Emit text asm for EXPR_METHOD_CALL — thin M8-tail wrapper.
 *
 * Why: same pool-copy requirement as EXPR_CALL (see above); delegates to
 *      seed partial backend_emit_expr_method_call.
 * Contract: expr_ref<=0 -> -1; otherwise delegates return value.
 * Asm/Perf: O(1) — one pool copy + one tail call.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_expr_method_call_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  struct ast_Expr e;
  if (expr_ref <= 0)
    return -1;
  e = pipeline_arena_expr_get_copy(arena, expr_ref);
  return backend_emit_expr_method_call(arena, out, expr_ref, e, ctx, target_arch);
}

/* ========================================================================== *
 * wave1207-1209 G.7: MEMORY-by-value call-arg emit + size query cluster
 * migrated from pipeline_glue.c L1856-2210. Colocated with call-arg emit
 * domain (call_args.c #include at glue.c L1660).
 *
 * Members (3 fns; bodies pure-owned after leave):
 *  - pipeline_asm_push_sysv_memory_by_value_elf_c   — wave202 pure leave
 *  - pipeline_asm_store_memory_by_value_to_sp_elf_c — wave202 pure leave
 *  - pipeline_asm_call_arg_value_byte_size_c        — wave195 pure leave
 *
 * Deps (all visible at #include point L1660 — verified via grep):
 *  - glue_call_arg_resolve_var_stack_off_elf_c (static, this file L150)
 *  - glue_call_return_byte_size_c              (static, this file L1716)
 *  - glue_sysv_dual_gp_byte_size_c             (static, this file L1784)
 *  - glue_type_size_simple                     (static, struct_lit.c L1270; #include L1440 < L1660)
 *  - glue_type_is_fixed_array                  (static, vector_let.c L739; #include L1455 < L1660)
 *  - glue_var_decl_type_ref_elf_c              (static, var_decl.c L51; #include L1610 < L1660)
 *  - glue_field_access_field_type_ref_c        (static, index_helpers.c L241; #include L1530 < L1660)
 *  - glue_type_named_layout_size_any_module_elf_c (static fwd decl, glue.c L1396 < L1660)
 *  - glue_field_access_layout_field_type_ref_by_name_c (static fwd decl, glue.c L1396 < L1660)
 *  - pipeline_asm_emit_expr_elf_rec            (static fwd decl, glue.c L1086 < L1660; def in expr_rec.c)
 *  - pipeline_asm_emit_struct_let_init_elf_c   (static, struct_let.c L43; #include L1520 < L1660)
 *  - pipeline_asm_emit_lvalue_eff_addr_elf_c   (static, index_helpers.c L2950; #include L1530 < L1660)
 *  - pipeline_asm_emit_set_call_sret_reg_shift_c (extern)
 *  - glue_arm64_mov_x0_to_x8_elf_c             (extern)
 *  - backend_enc_*_arch                        (extern)
 *  - g_pipeline_asm_emit_module                (static var, glue.c L133 < L1660; READ-ONLY here)
 *  - pipeline_expr_kind_ord_at / pipeline_expr_resolved_type_ref / pipeline_type_kind_ord_at (extern)
 *
 * Callers: no TU-internal callsites. Sole callers are seeds
 * (backend_call_dispatch.from_x.c L641/972/2540/2644/3783/4008/4123) via extern.
 *
 * PLATFORM:
 *  - push_sysv_memory:  LINUX+MACOS x86_64 SysV (ta==0)
 *  - store_memory_sp:   MACOS|ARM64 AAPCS64 (ta==1)
 *  - call_arg_size:     SHARED (size query; consumers apply arch-specific packing)
 * ========================================================================== */

/* wave202 pure-owned: pipeline_asm_push_sysv_memory_by_value_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: LINUX+MACOS x86_64 SysV — MEMORY by-value push (ta==0). */
int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     struct backend_AsmFuncCtx *ctx, int32_t arg_ref, int32_t sz,
                                                     int32_t ta);

/* wave202 pure-owned: pipeline_asm_store_memory_by_value_to_sp_elf_c body in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: MACOS|ARM64 AAPCS64 — MEMORY by-value store to SP (ta==1). */
int32_t pipeline_asm_store_memory_by_value_to_sp_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       struct backend_AsmFuncCtx *ctx, int32_t arg_ref, int32_t sz,
                                                       int32_t ta, int32_t sp_off);

/* wave195 pure-owned: pipeline_asm_call_arg_value_byte_size_c body in
 * runtime_pipeline_abi (G.7 single authority). Seed backend_call_dispatch
 * links pure via extern; Cap residual host body removed.
 * PLATFORM: SHARED freestanding CALL-arg value sizing. */
int32_t pipeline_asm_call_arg_value_byte_size_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t arg_ref, int32_t pty);
