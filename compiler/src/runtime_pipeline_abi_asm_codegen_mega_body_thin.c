/*
 * Thin pure: wave290 pipeline_asm_codegen_mega_body Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE290_ASM_CODEGEN_MEGA_BODY_ALWAYS (ctx_reset_for_func_c +
 * backend_asm_codegen_ast_to_elf_mega_body_c). No file-local BSS.
 * WIN leftover ARRAY_LIT return path kept under
 * XLANG_RUNTIME_PIPELINE_ABI_WIN_LEFTOVER_GROW_VEC (POSIX uses #else).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc asm_codegen_mega_body Cap residual leave.
 */

/* XLANG_PABI_ASM_CODEGEN_MEGA_BODY_THIN_BEGIN */

#include <stdint.h>
#include <string.h>
#include <stdio.h>

#include <stdarg.h>

/* Debug-only trace; seed mega uses Cap xlang_vfdprintf. Thin uses stderr. */
static void pabi_trace(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  (void)vfprintf(stderr, fmt, ap);
  va_end(ap);
}


/* LP64 SHARED — match pure pipe_elf_off_e_machine / reloc_type_r_pc32. */
enum {
  W290_ELF_E_MACHINE_OFF = 17432600,
  W290_ELF_RELOC_R_PC32_OFF = 17432604
};

#ifndef W290_GLUE_TYPE_KIND_F32_ORD
#define W290_GLUE_TYPE_KIND_F32_ORD 14
#endif
#ifndef W290_GLUE_TYPE_KIND_F64_ORD
#define W290_GLUE_TYPE_KIND_F64_ORD 15
#endif

/**
 * Full AsmFuncCtx layout overlay for mega emit (LP64).
 * Must match pipeline_glue.c pipeline_glue_AsmFuncCtxLayout field order/offsets.
 * PLATFORM: SHARED — seed ALWAYS residual (wave290).
 */
typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
  void *module_ref;
  uint8_t loop_break_label_stack[512];
  int32_t loop_break_len_stack[8];
  uint8_t loop_continue_label_stack[512];
  int32_t loop_continue_len_stack[8];
  uint8_t break_label[128];
  int32_t break_len;
  uint8_t continue_label[128];
  int32_t continue_len;
  int32_t loop_label_depth;
  void *dep_pipe;
  uint8_t tail_join_label[128];
  int32_t tail_join_label_len;
} W290_AsmFuncCtxLayout;

extern void *pipeline_asm_ctx_layout(void *ctx);
extern void asm_ctx_local_reset(uint8_t *ctx);
extern int32_t pipeline_dep_ctx_target_arch(void *ctx);
extern char *link_abi_getenv(const char *name);

extern void pipeline_asm_wpo_pgo_emit_order_prepare(void *m);
extern int32_t pipeline_asm_wpo_pgo_emit_order_count(void *m);
extern int32_t pipeline_asm_wpo_pgo_emit_order_at(void *m, int32_t order_index);
extern int32_t pipeline_asm_wpo_pgo_is_hot_func(void *m, int32_t fi);
extern int32_t asm_diag_start_func_skip(void);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_modlet_prepare_and_emit_elf_c(void *m, void *a, void *elf_ctx, int32_t ta);
extern void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
extern void pipeline_asm_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_asm_module_func_name_len_at(void *m, int32_t fi);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len);
extern void pipeline_asm_emit_set_func_index(int32_t func_index);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern void pipeline_asm_emit_ctx_sret_active_set(int32_t v);
extern void pipeline_asm_emit_ctx_sret_home_off_set(int32_t off);
extern void pipeline_asm_emit_ctx_sret_ret_sz_set(int32_t sz);
extern void pipeline_asm_fill_param_slots(void *ctx, void *mod, int32_t func_index);
extern int32_t asm_ctx_local_count(uint8_t *ctx);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_param_name_len_at(void *m, int32_t fi, int32_t pi);
extern void pipeline_asm_module_func_param_name_copy32(void *m, int32_t fi, int32_t pi, uint8_t *dst);
extern int32_t glue_func_return_byte_size_c(void *mod, void *arena, int32_t func_index);
extern void pipeline_asm_register_module_top_level_lets_c(void *ctx, void *m, void *a, int32_t func_index);
extern int32_t glue_asm_build_func_export_sym_c(void *m, void *a, int32_t func_ix, uint8_t *out, int32_t out_cap);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t asm_skip_heavy_module_func_body(void *m, void *arena, int32_t func_index);
extern int32_t backend_enc_prologue_arch(void *elf_ctx, int32_t frame_sz, int32_t ta);
extern int32_t pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(void *elf_ctx, int32_t ta, void *mod, int32_t func_index);
extern int32_t pipeline_asm_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t pipeline_asm_module_func_num_params_at(void *m, int32_t fi);
extern int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, void *arena, int32_t block_ref, void *mod, int32_t func_index);
extern int32_t pipeline_asm_block_num_stmt_order_at(void *a, int32_t br);
extern void pipeline_asm_fill_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_param_home_elf_c(void *elf_ctx, void *ctx, void *mod, int32_t func_index, int32_t ta);
extern int32_t pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(void *a, void *elf_ctx, void *ctx, void *m, int32_t func_index, int32_t ta);
extern int32_t pipeline_asm_hoist_target_func_index(void *m);
extern int32_t pipeline_asm_modlet_seed_nonzero_inits_elf_c(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_emit_async_cps_entry_elf_c(void *arena, void *elf_ctx, void *ctx, void *mod, int32_t func_index, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_block_inits_elf_c(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta, int32_t slot_base);
extern int32_t pipeline_asm_get_return_expr_ref_at(void *a, void *m, int32_t func_index);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_module_func_return_type_at(void *m, int32_t fi);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t type_ref);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                            int32_t force_esz, int32_t ta, void *ctx,
                                                            int32_t dest_elem_ty);
extern int32_t glue_emit_fixed_array_return_durable_ptr_rax_elf_c(void *arena, void *elf_ctx, int32_t src_ref,
                                                                void *ctx, int32_t ta, int32_t arr_ty);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t pipeline_module_main_func_index(void *m);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_epilogue_arch(void *elf_ctx, int32_t ta);
extern void pipeline_asm_emit_async_cps_end_func_elf_c(void);
/* TypeKind.TYPE_VOID ordinal (ast.x: after F32=14 F64=15). */
#ifndef W290_TYPE_KIND_VOID_ORD
#define W290_TYPE_KIND_VOID_ORD 16
#endif

/**
 * wave153 Cap residual: reset per-func AsmFuncCtx between mega emit iterations.
 * label_counter intentionally preserved for unique .L_N across whole mega emit.
 * @param ctx layout overlay (may be null)
 * @param mod module pointer stored into module_ref (may be null)
 * PLATFORM: SHARED freestanding Cap leave (wave290 seed ALWAYS).
 */
void pipeline_asm_ctx_reset_for_func_c(void *ctx, void *mod) {
  W290_AsmFuncCtxLayout *ly = (W290_AsmFuncCtxLayout *)ctx;
  if (!ly)
    return;
  ly->frame_size = 0;
  ly->next_offset = 0;
  ly->num_locals = 0;
  ly->module_ref = mod;
  ly->break_len = 0;
  ly->continue_len = 0;
  ly->loop_label_depth = 0;
  ly->dep_pipe = NULL;
  ly->tail_join_label_len = 0;
  asm_ctx_local_reset((uint8_t *)ly);
}

/**
 * Per-module asm codegen mega-body loop (WPO/PGO emit order).
 * Sets ELF e_machine / reloc defaults from DepCtx.target_arch, emits modlet
 * cells, then for each emit-order function: reset ctx, param homes, prologue,
 * block body / inits, float xmm0 placement, epilogue.
 * @return 0 success, -1 on null/emit failure
 * PLATFORM: SHARED freestanding Cap leave (wave290 seed ALWAYS).
 *   LINUX+MACOS x86_64 SysV float return in xmm0; arm64 sret via pure cells.
 */
int32_t pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(void *m, void *a, void *elf_ctx, void *pipeline_ctx) {
  int32_t ta;
  W290_AsmFuncCtxLayout ctx;
  uint8_t fname_buf[256];
  int32_t start_skip;
  int32_t emit_n;
  int32_t k;
  uint8_t *elfb;

  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  elfb = (uint8_t *)elf_ctx;
  ta = pipeline_dep_ctx_target_arch(pipeline_ctx);
  if (ta == 1) {
    *(int32_t *)(elfb + W290_ELF_E_MACHINE_OFF) = 183;
    *(int32_t *)(elfb + W290_ELF_RELOC_R_PC32_OFF) = 283;
  } else if (ta == 2) {
    *(int32_t *)(elfb + W290_ELF_E_MACHINE_OFF) = 243;
    *(int32_t *)(elfb + W290_ELF_RELOC_R_PC32_OFF) = 32;
  } else {
    *(int32_t *)(elfb + W290_ELF_E_MACHINE_OFF) = 62;
    *(int32_t *)(elfb + W290_ELF_RELOC_R_PC32_OFF) = 2;
  }
  memset(&ctx, 0, sizeof(ctx));
  pipeline_asm_wpo_pgo_emit_order_prepare(m);
  start_skip = asm_diag_start_func_skip();
  emit_n = pipeline_asm_wpo_pgo_emit_order_count(m);
  /* PLATFORM: SHARED x86_64 — text-embedded module mutable lit cells once before funcs. */
  if (pipeline_asm_modlet_prepare_and_emit_elf_c(m, a, elf_ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      pabi_trace( "xlang: mega_body_c modlet prepare fail\n");
    return -1;
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    pabi_trace( "xlang: mega_body_c start emit_n=%d start_skip=%d nf=%d\n", (int)emit_n, (int)start_skip,
            (int)pipeline_module_num_funcs(m));
  for (k = 0; k < emit_n; k++) {
    int32_t i = pipeline_asm_wpo_pgo_emit_order_at(m, k);
    int32_t body_ref;
    int32_t frame_sz;
    int32_t fname_len;
    int32_t export_sym_len;
    int32_t result_ref;
    /* Cap 4.2.8: export_sym[256] / out_cap 256 (was [128] → long def truncates). */
    uint8_t export_sym[256];
    void *bctx = (void *)&ctx;

    if (i < 0)
      continue;
    if (i < start_skip)
      continue;
    /* PLATFORM: SHARED — extern must stay U (text-asm path already skips).
     * Defense if emit_order ever leaks an extern index (OOB/stale). */
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0)
      continue;
    pipeline_elf_ctx_set_emit_hot(elfb, pipeline_asm_wpo_pgo_is_hot_func(m, i));
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
    /* PLATFORM: WINDOWS leftover-PE — diagnose callee-param VAR CG002.
     * call0 (0 params) green; add/id fail in callee body with code_len=12
     * (prologue only). Print np / param0 name_len / local-slot count. */
    if (link_abi_getenv("XLANG_ASM_DEBUG")) {
      int32_t np_dbg = pipeline_asm_module_func_num_params_at(m, i);
      int32_t plen0 = (np_dbg > 0) ? pipeline_asm_module_func_param_name_len_at(m, i, 0) : -1;
      int32_t nloc = asm_ctx_local_count((uint8_t *)bctx);
      uint8_t p0[256];
      int32_t off0 = -2;
      memset(p0, 0, sizeof(p0));
      if (np_dbg > 0 && plen0 > 0) {
        pipeline_asm_module_func_param_name_copy32(m, i, 0, p0);
        off0 = asm_ctx_local_find_offset((uint8_t *)bctx, p0, plen0);
      }
      pabi_trace(
              "xlang: mega_body_c post_fill fi=%d np=%d plen0=%d nloc=%d off0=%d p0=%.*s\n",
              (int)i, (int)np_dbg, (int)plen0, (int)nloc, (int)off0,
              (int)(plen0 > 0 ? plen0 : 0), (char *)p0);
    }
    /*
     * >16B return: reserve 8B to save incoming hidden dest (before top-level lets).
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8.
     */
    if (ta == 0 || ta == 1) {
      int32_t fn_ret_sz = glue_func_return_byte_size_c(m, a, i);
      if (fn_ret_sz > 16) {
        pipeline_asm_emit_ctx_sret_ret_sz_set(fn_ret_sz);
        pipeline_asm_emit_ctx_sret_active_set(1);
        /* PLATFORM: WINDOWS leftover-PE — SAT emit_struct_lit intra SAT
         * sret_active=0 allocates implicit dest at high-end home≈vb
         * (24B → lea [rbp-0x18] occupying [rbp-24,rbp), which clobbers
         * sret_home=16). Park the hidden dest pointer 256B above the
         * current next_offset (compute_frame_size scratch ≥512).
         * POSIX .x emit_struct_lit takes sret dest and does not overlap. */
        pipeline_asm_emit_ctx_sret_home_off_set(ctx.next_offset + 256);
        ctx.next_offset += 8;
      }
    }
    pipeline_asm_register_module_top_level_lets_c(bctx, m, a, i);
    pipeline_debug_trace_named_func_bodies("mega_post_register_top_level", m, a);
    /* Cap 4.2.8: export_sym is u8[256]; out_cap must be 256 (AST content ≤255). */
    export_sym_len = glue_asm_build_func_export_sym_c(m, a, i, export_sym, 256);
    if (export_sym_len <= 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, export_sym, export_sym_len, 1, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        pabi_trace( "xlang: mega_body_c enc_label fail func=%.*s\n", (int)export_sym_len, (char *)export_sym);
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
      frame_sz = pipeline_asm_compute_frame_size_c(pipeline_asm_module_func_num_params_at(m, i), a, body_ref, m, i);
      pipeline_debug_trace_named_func_bodies("mega_post_frame_size", m, a);
      /* Always fill: nso>0 used to skip, so SAT emit_block stored every let
       * at rbp+0 (`add(x,y)` RUN=8). leftover rest fill_local_slots is
       * first-wins WAVE277 names → WAVE267 distinct slots.
       * PLATFORM: WINDOWS leftover-PE hybrid. */
      pipeline_asm_fill_local_slots(bctx, a, body_ref);
      pipeline_debug_trace_named_func_bodies("mega_post_fill_local_slots", m, a);
    }
    if (backend_enc_prologue_arch(elf_ctx, frame_sz, ta) != 0)
      return -1;
    /*
     * wave603: arm64 MEMORY param_home needs frame_size so incoming stack args
     * resolve at [x29+frame] (wave414 low-end prologue), not [x29+16] identity.
     */
    {
      W290_AsmFuncCtxLayout *ly_fs = (W290_AsmFuncCtxLayout *)pipeline_asm_ctx_layout(bctx);
      if (ly_fs)
        ly_fs->frame_size = frame_sz;
    }
    if (pipeline_asm_emit_param_home_elf_c(elf_ctx, bctx, m, i, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        pabi_trace( "xlang: mega_body_c param_home fail fi=%d\n", (int)i);
      return -1;
    }
    /* Mutable module-level lit lets on non-hoist: seed stack slots after param home. */
    if (pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, bctx, m, i, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        pabi_trace( "xlang: mega_body_c top_level lit inits fail func=%.*s fi=%d\n", (int)fname_len,
                (char *)fname_buf, (int)i);
      return -1;
    }
    /* COMMON BSS starts zero; non-zero modlet inits once on hoist target. */
    if (i == pipeline_asm_hoist_target_func_index(m) &&
        pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        pabi_trace( "xlang: mega_body_c modlet nonzero seed fail func=%.*s\n", (int)fname_len,
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
            pabi_trace( "xlang: mega_body_c emit_block_body fail func=%.*s fi=%d body_ref=%d\n",
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
#if defined(XLANG_RUNTIME_PIPELINE_ABI_WIN_LEFTOVER_GROW_VEC)
      /* leftover-PE get_return peels RETURN to ARRAY_LIT; SAT
       * emit_array_lit leaves dest pointer (remaining-wave emit_return
       * dual-GP @19267 is #ifndef FROM_X ABSENT). take(mk()) then
       * dangling dest as fat* (`slice_call_arg` SEGV 139). G.7 complete
       * leftover rest mega_body: durable COMMON + dual-GP (rax=data
       * rdx=n_arr). Do not leftover rest remaining-wave emit_return via
       * !FROM_X || WIN. Do not copy .x reent deep-copy.
       * PLATFORM: WINDOWS leftover-PE. */
      {
        int32_t rrty = pipeline_module_func_return_type_at(m, i);
        int32_t rrtk = (rrty > 0) ? pipeline_type_kind_ord_at(a, rrty) : 0;
        int32_t rko = pipeline_expr_kind_ord_at(a, result_ref);
        int32_t n_arr;
        int32_t et;
        int32_t force_esz;
        int32_t wrapped = 0;
        if (rrtk == 11 && rko == 46) {
          n_arr = pipeline_expr_array_lit_num_elems_at(a, result_ref);
          if (n_arr < 0)
            n_arr = 0;
          et = (rrty > 0) ? pipeline_type_elem_ref_at(a, rrty) : 0;
          force_esz = pipeline_asm_array_lit_elem_byte_sz_c(a, result_ref);
          if (force_esz <= 0)
            force_esz = 4;
          if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(a, elf_ctx, result_ref, force_esz, ta, bctx,
                                                            et) == 0) {
            if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
              return -1;
            if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
              return -1;
            if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, (ta == 1) ? 1 : 2, ta) != 0)
              return -1;
            if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
              return -1;
            wrapped = 1;
          }
        }
        /* TYPE_ARRAY=10 ARRAY_LIT return: leftover-PE get_return peels
         * RETURN to ARRAY_LIT; SAT emit_array_lit leaves a stack dest
         * (remaining-wave emit_return durable E* @19252 is #ifndef
         * FROM_X ABSENT). take(mk()) then stores dest bits as the 8B
         * leftover-PE INTEGER home (`arr_call_arg` RUN=226). G.7
         * complete leftover rest mega_body: same leftover rest unique
         * durable COMMON as TYPE_SLICE, E* only (no length half;
         * remaining-wave @19266). Caller for_call_args CALL tk==10
         * <=8B load_64 / >8B leave E*. Do not leftover rest
         * remaining-wave emit_return via !FROM_X || WIN.
         * PLATFORM: WINDOWS leftover-PE. */
        if (wrapped == 0 && rrtk == 10 && rko == 46) {
          n_arr = pipeline_expr_array_lit_num_elems_at(a, result_ref);
          if (n_arr < 0)
            n_arr = 0;
          et = (rrty > 0) ? pipeline_type_elem_ref_at(a, rrty) : 0;
          force_esz = pipeline_asm_array_lit_elem_byte_sz_c(a, result_ref);
          if (force_esz <= 0)
            force_esz = 4;
          if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(a, elf_ctx, result_ref, force_esz, ta, bctx,
                                                            et) == 0)
            wrapped = 1;
        }
        /* TYPE_ARRAY VAR/FIELD/INDEX/DEREF return: leftover-PE get_return
         * peels RETURN when nso==0 (`return a` of a formal). SAT emit_expr
         * of local VAR load_var payload (`arr_ret_whole` SEGV). G.7 same
         * leftover rest unique durable COMMON as rec RETURN. Do not
         * leftover rest remaining-wave emit_return via !FROM_X || WIN.
         * PLATFORM: WINDOWS leftover-PE. */
        if (wrapped == 0 && rrtk == 10 && rrty > 0 &&
            (rko == 3 || rko == 44 || rko == 47 || rko == 52)) {
          if (glue_emit_fixed_array_return_durable_ptr_rax_elf_c(a, elf_ctx, result_ref, bctx, ta, rrty) == 0)
            wrapped = 1;
        }
        if (wrapped == 0) {
          if (pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta) != 0)
            return -1;
        }
      }
#else
      if (pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta) != 0)
        return -1;
#endif
    }
    /*
     * PLATFORM: LINUX+MACOS x86_64 SysV — place scalar float return in xmm0 before epilogue.
     * Internal path holds IEEE bits in eax/rax; callee ABI requires xmm0 for f32/f64.
     *
     * PLATFORM: SHARED — Zig-like void main: process entry must exit 0 on fall-off /
     * bare `return;` (tail_join then epilogue). Pure-asm previously left w0/x0 garbage
     * → empty void main exited 1 (void-main gate). C codegen maps void main → int32_t
     * main + `return 0;`; pure-asm must mov imm 0 into the return reg before epilogue.
     * Only the module main_func with TYPE_VOID (ord 16); do not clobber i32 main results.
     */
    {
      int32_t rty = pipeline_module_func_return_type_at(m, i);
      int32_t rkind = (rty > 0) ? pipeline_type_kind_ord_at(a, rty) : -1;
      if (ta == 0) {
        if (rkind == W290_GLUE_TYPE_KIND_F32_ORD) {
          if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
            return -1;
        } else if (rkind == W290_GLUE_TYPE_KIND_F64_ORD) {
          if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
            return -1;
        }
      }
      if (rkind == W290_TYPE_KIND_VOID_ORD && i == pipeline_module_main_func_index(m)) {
        if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
          return -1;
      }
    }
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        pabi_trace( "xlang: mega_body_c epilogue fail func=%.*s fi=%d\n", (int)fname_len, (char *)fname_buf,
                (int)i);
      return -1;
    }
    pipeline_asm_emit_async_cps_end_func_elf_c();
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    pabi_trace( "xlang: mega_body_c done emit_n=%d rc=0\n", (int)emit_n);
  return 0;
}

/* XLANG_PABI_ASM_CODEGEN_MEGA_BODY_THIN_END */
