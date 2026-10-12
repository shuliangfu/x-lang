/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
static int32_t g_wave132_call_sret_reg_shift = 0;

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                        int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                            int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref,
                                                                  void *ctx, int32_t ta, int32_t stack_slot_off);
/* wave206 pure leave: cold twin body at seed EOF under same #ifndef FROM_X. */
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern int32_t glue_call_return_byte_size_c(void *arena, int32_t call_expr_ref);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref, int32_t slot_off,
                                                   int32_t ta, int32_t init_ref, void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t glue_arm64_mov_x0_to_x8_elf_c(void *elf_ctx);
extern int32_t glue_arm64_mov_x19_to_x0_elf_c(void *elf_ctx);
extern int32_t glue_x86_store_rdx_to_rbx8_elf_c(void *elf_ctx);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf_ctx, int32_t off, int32_t sz, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off, int32_t sz, int32_t ta);

void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift) {
  g_wave132_call_sret_reg_shift = shift > 0 ? 1 : 0;
}

int32_t pipeline_asm_emit_call_sret_reg_shift_c(void) {
  return g_wave132_call_sret_reg_shift;
}

int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                                 int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                             int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  int32_t inl;
  int32_t emit_rc;
  int32_t call_ret_sz;
  int32_t let_sz;
  int32_t named_sz;
  int32_t best;
  int32_t dest_in_rbx;
  void *modp;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  dest_in_rbx = (stack_slot_off == -3) ? 1 : 0;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 45)
    return pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 48 || ko == 49) {
    /* dest-in-rbx: try_inline would lea rbp-3. Skip. */
    if (!dest_in_rbx) {
      /* G.7: METHOD(49) shares try_inline with CALL(48). Body already accepts 49. */
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
    }
    pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref > 0 ? let_ty_ref : 0);
    call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
    if (call_ret_sz <= 16 && let_ty_ref > 0) {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, let_ty_ref, 0);
      named_sz = 0;
      if (let_sz <= 16)
        named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
      best = let_sz;
      if (named_sz > best) {
        if (call_ret_sz > 0 && call_ret_sz <= 16 && named_sz > 16) {
          /* keep best */
        } else if (let_sz <= 4 || call_ret_sz <= 0 || named_sz <= 16) {
          best = named_sz;
        }
      }
      if (best > call_ret_sz)
        call_ret_sz = best;
    }
    if (call_ret_sz > 16 && (ta == 0 || ta == 1)) {
      if (dest_in_rbx) {
        if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
      } else if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      if (ta == 0) {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
        pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      } else {
        if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
      }
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return emit_rc != 0 ? -1 : 0;
    }
    emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    if (dest_in_rbx) {
      if (call_ret_sz > 8) {
        if (ta == 1) {
          if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta) != 0)
            return -1;
        } else {
          if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta) != 0)
            return -1;
          if (glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx) != 0)
            return -1;
        }
      } else if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta) != 0) {
        return -1;
      }
      return 0;
    }
    modp = glue_emit_module_from_ctx(ctx);
    if (glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx) != 0)
      return -1;
    return 0;
  }
  /* EXPR_VAR (3): same slot-to-slot >16B copy as .x (G.7).
   * lea src then glue_copy_large_struct; ≤16B returns -2.
   * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
  if (ko == 3 && (ta == 0 || ta == 1)) {
    int32_t src_off;
    int32_t ty_ref;
    src_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
    if (src_off < 0)
      return -2;
    ty_ref = let_ty_ref;
    if (ty_ref <= 0) {
      ty_ref = glue_var_decl_type_ref_elf_c(arena, ctx, init_ref);
      if (ty_ref <= 0)
        ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
    }
    if (ty_ref <= 0)
      return -2;
    modp = glue_emit_module_from_ctx(ctx);
    let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
    named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    if (named_sz > let_sz)
      let_sz = named_sz;
    /* Frame dest ≤16B: dual-GP fall-through. dest-in-rbx ≥8B: memcpy
     * (deref_struct16 would clobber dest rbx/x19). 8B covers `[2]i32`.
     * PLATFORM: SHARED — DEREF dest 16B VAR leftover was Darwin 2. */
    if (let_sz < 8)
      return -2;
    if (let_sz <= 16 && !dest_in_rbx)
      return -2;
    if (!dest_in_rbx && src_off == stack_slot_off)
      return 0;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta) != 0)
      return -1;
    if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, stack_slot_off, let_sz, ta) != 0)
      return -1;
    return 0;
  }
  /* EXPR_DEREF (52): >16B named `y = *p` — emit leaves pointer, memcpy dest. */
  if (ko == 52 && (ta == 0 || ta == 1)) {
    ty_ref = let_ty_ref;
    if (ty_ref <= 0)
      ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (ty_ref <= 0)
      return -2;
    modp = glue_emit_module_from_ctx(ctx);
    let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
    named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    if (named_sz > let_sz)
      let_sz = named_sz;
    if (let_sz <= 16)
      return -2;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0)
      return -1;
    if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, stack_slot_off, let_sz, ta) != 0)
      return -1;
    return 0;
  }
  return -2;
}

/* Seed twin of .x glue_copy_large_struct_from_rax_ptr (wave204).
 * Prefer FROM_X owns the .x export; this cold body is #ifndef FROM_X only.
 * PLATFORM: LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64. */
int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off, int32_t sz, int32_t ta) {
  uint8_t memcpy_sym[8];
  memcpy_sym[0] = 109;
  memcpy_sym[1] = 101;
  memcpy_sym[2] = 109;
  memcpy_sym[3] = 99;
  memcpy_sym[4] = 112;
  memcpy_sym[5] = 121;
  memcpy_sym[6] = 0;
  /* Frame dest stays >16B. dest-in-rbx ≥8B memcpy is VAR dest-in-rbx.
   * PLATFORM: SHARED — do not lower the frame dest gate. */
  if (!elf_ctx || (ta != 0 && ta != 1) || sz < 8)
    return -1;
  if (sz <= 16 && slot_off != -3)
    return -1;
  if (slot_off == -3) {
    if (ta == 1) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
        return -1;
      if (glue_arm64_mov_x19_to_x0_elf_c(elf_ctx) != 0)
        return -1;
      return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (ta == 1) {
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
}

/*
 * wave133: pipeline_asm_emit_unary pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: sxt i32, jz-after-bool, neg/lognot/bitnot ELF.
 */
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);
extern int32_t backend_enc_test_eax_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_binop_operand_is_scalar_f32_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t arch_arm64_enc_enc_u32_le(void *elf_ctx, int32_t val);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int64_t pipeline_expr_int64_val_at(void *arena, int32_t expr_ref);
extern int32_t backend_enc_neg_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_not_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_setz_movzbl_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);

