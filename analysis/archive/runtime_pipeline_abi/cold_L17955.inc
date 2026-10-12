/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/*
 * wave140: pipeline_asm_emit_index pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: index_elem_byte_sz_c / index_elem_byte_sz / emit_index / addr_of / deref.
 * Cap residual: field_type_ref, fixed_array_total_bytes, esz_from_type_ref,
 *   var_type_fallback, assign_addr_cache, eff_addr_scaled, lvalue_eff_addr, enc loads.
 * PLATFORM: SHARED freestanding · continues same #ifndef FROM_X as wave139
 * (reopened after leftover-PE modlet cluster; leftover rest still closed here;
 * array_lit unique is extracted later from this remaining wave136).
 */

#ifndef PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED
#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)
#endif

extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr);
extern int32_t glue_var_expr_type_ref_with_decl_fallback_c(void *arena, int32_t var_ref);
extern void glue_index_assign_addr_cache_clear(void);
extern int32_t glue_index_assign_addr_cache_hit(void *arena, void *ctx, int32_t base_ref, int32_t idx_ref, int32_t esz);
extern int32_t glue_index_load_from_cached_assign_addr_elf_c(void *elf_ctx, int32_t esz, int32_t ta);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                      int32_t base_ref, int32_t idx_ref, void *ctx,
                                                      int32_t ta, int32_t esz);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t asm_ctx_local_find_offset_scoped(void *ctx, void *arena, uint8_t *name, int32_t name_len);
extern int32_t backend_enc_load_zext8_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *module, int32_t func_index, uint8_t *var_name, int32_t name_len);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_field_access_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);

int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref) {
  int32_t base_ref;
  int32_t tr;
  int32_t kind_ord;
  int32_t pointee;
  int32_t esz_base;
  void *mod;
  int32_t func_idx;
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref > 0) {
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      int32_t flen = pipeline_expr_field_access_name_len(arena, base_ref);
      if (flen == 3) {
        uint8_t fname[256];
        pipeline_expr_field_access_name_into(arena, base_ref, fname);
        if (fname[0] == (uint8_t)'p' && fname[1] == (uint8_t)'t' && fname[2] == (uint8_t)'r') {
          int32_t vref = pipeline_expr_field_access_base_ref(arena, base_ref);
          mod = pipeline_asm_emit_module_ref_c();
          func_idx = pipeline_asm_emit_func_index_c();
          if (vref > 0 && mod && pipeline_expr_kind_ord_at(arena, vref) == 3) {
            uint8_t vn[256];
            int32_t vl = pipeline_expr_var_name_len(arena, vref);
            int32_t pty = 0;
            if (vl > 0 && vl <= 63 && func_idx >= 0) {
              pipeline_expr_var_name_into(arena, vref, vn);
              pty = pipeline_module_func_param_type_ref_for_name(mod, func_idx, vn, vl);
            }
            if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == 9) {
              int32_t st = pipeline_type_elem_ref_at(arena, pty);
              uint8_t sn[128];
              int32_t sl = st > 0 ? pipeline_type_named_name_into(arena, st, sn) : 0;
              if (sl >= 6 && sn[sl - 1] == (uint8_t)'8' && sn[sl - 2] == (uint8_t)'u' &&
                  sn[sl - 3] == (uint8_t)'_' && sn[sl - 4] == (uint8_t)'c' && sn[sl - 5] == (uint8_t)'e' &&
                  sn[sl - 6] == (uint8_t)'V')
                return 1;
            }
          }
        }
      }
    }
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      mod = pipeline_asm_emit_module_ref_c();
      tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    } else {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
    /* Base *T / **T: glue peels outer PTR once. Do not pre-peel then call glue
     * (double-peel **u8 → sizeof(u8)=1; pure-asm argv[i] scale1+ldrb SEGV).
     * PLATFORM: SHARED freestanding — seed cold twin of pure .x. */
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 9) {
      esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      if (esz_base > 0 && esz_base < 8)
        return esz_base;
    } else if (tr > 0) {
      esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      if (esz_base > 0 && esz_base < 8)
        return esz_base;
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr > 0) {
    int32_t esz_res;
    if (pipeline_type_kind_ord_at(arena, tr) == 10) {
      int32_t asz = glue_fixed_array_total_bytes_c(arena, tr, 0);
      if (asz > 0)
        return asz;
    }
    if (pipeline_type_kind_ord_at(arena, tr) == 9)
      return 8;
    if (pipeline_type_kind_ord_at(arena, tr) == 11)
      return 16;
    esz_res = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    if (esz_res >= 8) {
      int32_t base_ref2 = pipeline_expr_index_base_ref(arena, expr_ref);
      int32_t tr_base;
      int32_t pointee2;
      int32_t esz_pt;
      if (base_ref2 > 0) {
        if (pipeline_expr_kind_ord_at(arena, base_ref2) == 44) {
          mod = pipeline_asm_emit_module_ref_c();
          tr_base = glue_field_access_field_type_ref_c(arena, mod, base_ref2);
        } else {
          tr_base = pipeline_expr_resolved_type_ref(arena, base_ref2);
        }
        /* Base *T: glue peels once — pass tr_base, not pre-peeled pointee2. */
        if (tr_base > 0 && pipeline_type_kind_ord_at(arena, tr_base) == 9) {
          esz_pt = glue_index_elem_byte_sz_from_type_ref_c(arena, tr_base);
          if (esz_pt > 0 && esz_pt < esz_res)
            return esz_pt;
        }
      }
    }
    return esz_res;
  }
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref <= 0)
    return 4;
  if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
    mod = pipeline_asm_emit_module_ref_c();
    tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    if (tr > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    return 4;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr <= 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  /* PTR base fallback: single peel via G.7 glue (*u8→1, *i32→4, **T→8). */
  if (kind_ord == 9)
    return glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  if (kind_ord == 10 || kind_ord == 11) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 9)
        return 8;
      if (kind_ord == 10) {
        int32_t asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      if (kind_ord == 11)
        return 16;
      if (kind_ord == 8) {
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          int32_t esz = glue_type_size_simple(mod, arena, pointee, 0);
          if (esz > 0)
            return esz;
        }
      }
    }
  }
  if (kind_ord == 8) {
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      int32_t esz = glue_type_size_simple(mod, arena, tr, 0);
      if (esz > 0)
        return esz;
    }
  }
  if (kind_ord == 13) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, pointee);
    return 4;
  }
  return 8;
}

int32_t pipeline_asm_index_elem_byte_sz(void *a, int32_t index_expr_ref) {
  return pipeline_asm_index_elem_byte_sz_c(a, index_expr_ref);
}

/* PLATFORM: SHARED — INDEX 9–16B rvalue forward to G.7 deref (defined later).
 * Twin: runtime_pipeline_abi.x pipeline_asm_emit_index_elf_c. */
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);

int32_t pipeline_asm_emit_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t idx_ref;
  int32_t esz;
  int32_t res_ty;
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  if (base_ref <= 0 || idx_ref <= 0)
    return -1;
  esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  /* wave350 G.7: no VAR local/modlet early gate. Twin of
   * runtime_pipeline_abi.x pipeline_asm_emit_index_elf_c — assign INDEX
   * already goes straight to glue_emit_index_eff_addr_scaled; a local-only
   * reject here CG002'd module fixed-array rvalue `g[0]` while write/`&`
   * /ascription stayed green (cold prepare vs product find dual table).
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64. */
  if (glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz))
    return glue_index_load_from_cached_assign_addr_elf_c(elf_ctx, esz, ta);
  glue_index_assign_addr_cache_clear();
  if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta, esz) != 0)
    return -1;
  res_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (res_ty > 0 && pipeline_type_kind_ord_at(arena, res_ty) == 10)
    return 0;
  if (res_ty > 0 && pipeline_type_kind_ord_at(arena, res_ty) == 11) {
    /* TYPE_SLICE fat is 16B dual-GP. Twin of runtime_pipeline_abi.x
     * pipeline_asm_emit_index_elf_c rtk==11. Do not use arg_reg(2):
     * ARM64 x2 is the 3rd AAPCS64 arg, not dual-GP hi (x1).
     * PLATFORM: SHARED · LINUX|x86_64 rdx · MACOS|ARM64 x1. */
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  }
  /* PLATFORM: SHARED — INDEX 9–16B rvalue: *rax → rax+rdx via G.7 deref.
   * Twin: runtime_pipeline_abi.x pipeline_asm_emit_index_elf_c.
   * Old leave-addr made METHOD/let/take treat the pointer as payload.
   * >16B MEMORY still leave-addr. Do not touch struct16 classifier. */
  if (esz > 8 && esz <= 16)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8)
    return 0;
  if (esz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}

/* PLATFORM: SHARED — ADDR_OF of ARRAY_LIT (dest extras dest-PTR stamp
 * nested extra lit `&[[2],[4]]`). G.7 complete: reuse ARRAY_LIT emit
 * (temp + lea → rax). Twin runtime_pipeline_abi.x + thin
 * pipeline_glue_strict_minimal.x. Do not invent -3.
 * leftover-PE WIN leftover first-wins lives in the rec cluster
 * (FROM_X && WIN); this remaining-wave body stays #ifndef FROM_X. */
extern int32_t pipeline_asm_emit_array_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
int32_t pipeline_asm_emit_addr_of_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t ok;
  uint8_t vname[256];
  int32_t vlen;
  int32_t off;
  void *gmod;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  ok = pipeline_expr_kind_ord_at(arena, op);
  if (ok == 3) {
    vlen = pipeline_expr_var_name_len(arena, op);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, op, vname);
    off = asm_ctx_local_find_offset_scoped(ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset(ctx, vname, vlen);
    if (off < 0) {
      /* 9.4.2: non-local binding — module-let COMMON cell (modlet-first)
       * or same-module fn link symbol; shared resolver authority, twin of
       * the .x ADDR_OF fallback. Loud FAST_UNHANDLED only when neither. */
      gmod = pipeline_asm_emit_module_ref_c();
      if (gmod && pipe_modlet_lea_named_binding_addr_to_rax_cold(elf_ctx, gmod, vname, vlen, ta) == 0)
        return 0;
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    }
    return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
  }
  if (ok == 47) {
    int32_t base_ref = pipeline_expr_index_base_ref(arena, op);
    int32_t idx_ref = pipeline_expr_index_index_ref(arena, op);
    int32_t esz;
    if (base_ref <= 0 || idx_ref <= 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, op);
    return glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, op, base_ref, idx_ref, ctx, ta, esz);
  }
  if (ok == 44)
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
  if (ok == 52)
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
  /* EXPR_ARRAY_LIT = 46: dest-stamp into temp then lea (rax = &temp). */
  if (ok == 46)
    return pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, op, ctx, ta);
  return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
}

int32_t pipeline_asm_emit_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t tr;
  int32_t esz;
  int32_t trk;
  int32_t named_sz;
  int32_t lanes = 0;
  int32_t lane_esz = 0;
  void *modp;
  extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);
  extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
  extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
  extern void *glue_emit_module_from_ctx(void *ctx);
  extern int32_t glue_vector_type_lanes_esz_c(void *arena, int32_t type_ref, int32_t *out_lanes,
                                              int32_t *out_esz);
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  trk = (tr > 0) ? pipeline_type_kind_ord_at(arena, tr) : 0;
  if (trk == 10)
    return 0;
  if (trk == 11)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  if (trk == 9)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  modp = glue_emit_module_from_ctx(ctx);
  named_sz = glue_type_size_simple(modp, arena, tr, 0);
  if (named_sz > esz)
    esz = named_sz;
  named_sz = glue_type_named_layout_size_any_module_elf_c(arena, tr);
  if (named_sz > esz)
    esz = named_sz;
  if (esz <= 8 && glue_vector_type_lanes_esz_c(arena, tr, &lanes, &lane_esz) == 0 && lanes > 0 &&
      lane_esz > 0)
    esz = lanes * lane_esz;
  if (esz > 16)
    return 0;
  if (esz > 8)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
  if (esz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}



/*
 * wave141: pipeline_asm_emit_context pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: set/get module/dep/arena/call_arg/func_index/elf + param-ptr lookup +
 *   compute_frame_size + fill_param_slots + param_home_elf + fill_local_slots.
 * Cap residual storage: pipeline_asm_emit_ctx_*_get/set (glue_statics cells;
 *   residual C still direct-accesses the same statics — G.7 single storage).
 * PLATFORM: SHARED freestanding · continues same #ifndef FROM_X as wave140.
 */

extern void *pipeline_asm_emit_ctx_module_get(void);
extern void pipeline_asm_emit_ctx_module_set(void *m);
extern int32_t pipeline_asm_emit_ctx_func_index_get(void);
extern void pipeline_asm_emit_ctx_func_index_set(int32_t fi);
extern void *pipeline_asm_emit_ctx_arena_get(void);
extern void pipeline_asm_emit_ctx_arena_set(void *arena);
extern int32_t pipeline_asm_emit_ctx_call_param_ty_get(void);
extern void pipeline_asm_emit_ctx_call_param_ty_set(int32_t type_ref);
extern int32_t pipeline_asm_emit_ctx_call_arg_depth_get(void);
extern void pipeline_asm_emit_ctx_call_arg_depth_set(int32_t d);
extern void *pipeline_asm_emit_ctx_dep_pipe_get(void);
extern void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx);
extern void *pipeline_asm_emit_ctx_elf_ctx_get(void);
extern void pipeline_asm_emit_ctx_elf_ctx_set(void *elf_ctx);
extern int32_t pipeline_asm_emit_ctx_sret_active_get(void);
extern int32_t pipeline_asm_emit_ctx_sret_home_off_get(void);
extern int32_t pipeline_asm_host_is_arm64_c(void);
extern int32_t glue_func_param_home_width_c(void *arena, void *mod, int32_t func_index, int32_t param_index);
extern int32_t glue_func_param_agg_byte_size_c(void *arena, void *mod, int32_t func_index, int32_t param_index);
extern int32_t glue_func_return_byte_size_c(void *mod, void *arena, int32_t func_index);
extern int32_t glue_asm_sum_block_call_spill_bytes(void *arena, int32_t block_ref);
extern int32_t glue_sum_block_slice_reent_dc_bytes_c(void *arena, int32_t block_ref);
extern int32_t asm_sum_block_array_temp_bytes(void *arena, int32_t block_ref);
extern int32_t asm_sum_block_wa_temp_bytes(void *arena, int32_t block_ref);
extern int32_t pipeline_asm_hoist_target_func_index(void *m);
extern int32_t pipeline_asm_sum_module_top_level_lets_stack(void *a, void *m, int32_t off);
extern void asm_ctx_local_reset(void *ctx);
extern void asm_ctx_fill_locals_block_tree(void *ctx, void *arena, int32_t block_ref, int32_t *next_off, int32_t *num_loc);
extern int32_t pipeline_asm_module_func_num_params_at(void *mod, int32_t func_index);
extern void pipeline_asm_module_func_param_name_copy32(void *mod, int32_t func_index, int32_t param_index, uint8_t *dst);
extern int32_t pipeline_asm_module_func_param_name_len_at(void *mod, int32_t func_index, int32_t param_index);
extern int32_t asm_ctx_local_append(void *ctx, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t asm_ctx_local_count(void *ctx);
extern int32_t asm_ctx_block_slot_get(void *ctx, int32_t block_ref);
extern void asm_ctx_block_slot_set(void *ctx, int32_t block_ref, int32_t slot_base);
extern int32_t asm_local_slot_reg_offset(void *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
extern int32_t pipeline_asm_let_init_stack_reserve_bytes(void *arena, int32_t type_ref, int32_t init_ref);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern void ast_pipeline_block_const_name_copy64(void *arena, int32_t block_ref, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_block_const_name_len(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_const_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_const_init_ref(void *arena, int32_t block_ref, int32_t i);
extern void ast_pipeline_block_let_name_copy64(void *arena, int32_t block_ref, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_block_let_name_len(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c(void *elf_ctx, void *ctx, void *mod, int32_t func_index, int32_t np);
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_x_reg_to_rbp_arch(void *elf_ctx, int32_t reg, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_rbp_pos_to_rax_arch(void *elf_ctx, int32_t off_pos, int32_t ta);
extern int32_t backend_enc_load_x29_pos_to_rax_arch(void *elf_ctx, int32_t off_pos, int32_t ta);
extern int32_t pipeline_elf_pgo_hot_enabled(void);
extern void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
extern int32_t pipeline_asm_wpo_pgo_is_hot_func(void *m, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *mod, int32_t fi, uint8_t *vname, int32_t vlen);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);

void pipeline_asm_emit_set_module(void *m) {
  pipeline_asm_emit_ctx_module_set(m);
}
void *pipeline_asm_emit_module_ref_c(void) {
  return pipeline_asm_emit_ctx_module_get();
}
void *pipeline_asm_glue_emit_module_ref(void) {
  return pipeline_asm_emit_ctx_module_get();
}
void pipeline_asm_emit_set_dep_pipe(void *ctx) {
  pipeline_asm_emit_ctx_dep_pipe_set(ctx);
}
void *pipeline_asm_emit_dep_pipe_c(void) {
  return pipeline_asm_emit_ctx_dep_pipe_get();
}
void pipeline_asm_emit_set_arena(void *arena) {
  pipeline_asm_emit_ctx_arena_set(arena);
}
void pipeline_asm_emit_set_call_param_type_ref(int32_t type_ref) {
  pipeline_asm_emit_ctx_call_param_ty_set(type_ref);
}
void pipeline_asm_emit_call_arg_begin_c(void) {
  pipeline_asm_emit_ctx_call_arg_depth_set(pipeline_asm_emit_ctx_call_arg_depth_get() + 1);
}
void pipeline_asm_emit_call_arg_end_c(void) {
  int32_t d = pipeline_asm_emit_ctx_call_arg_depth_get();
  if (d > 0)
    pipeline_asm_emit_ctx_call_arg_depth_set(d - 1);
}
int32_t pipeline_asm_emit_call_arg_active_c(void) {
  return pipeline_asm_emit_ctx_call_arg_depth_get() > 0 ? 1 : 0;
}
void pipeline_asm_emit_set_func_index(int32_t func_index) {
  void *elf;
  void *mod;
  pipeline_asm_emit_ctx_func_index_set(func_index);
  elf = pipeline_asm_emit_ctx_elf_ctx_get();
  mod = pipeline_asm_emit_ctx_module_get();
  if (elf && mod && pipeline_elf_pgo_hot_enabled())
    pipeline_elf_ctx_set_emit_hot((uint8_t *)elf, pipeline_asm_wpo_pgo_is_hot_func(mod, func_index));
}
void pipeline_asm_emit_set_elf_ctx(void *elf_ctx) {
  pipeline_asm_emit_ctx_elf_ctx_set(elf_ctx);
}
int32_t pipeline_asm_emit_func_index_c(void) {
  return pipeline_asm_emit_ctx_func_index_get();
}
int32_t pipeline_asm_emit_func_param_is_ptr_by_name_c(void *arena, void *mod, uint8_t *vname, int32_t vlen) {
  int32_t fi;
  int32_t param_ty;
  int32_t kind;
  if (!arena || !mod || !vname || vlen <= 0 || vlen > 255)
    return 0;
  fi = pipeline_asm_emit_ctx_func_index_get();
  if (fi < 0)
    return 0;
  param_ty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
  if (param_ty <= 0)
    return 0;
  kind = pipeline_type_kind_ord_at(arena, param_ty);
  return (kind == 9) ? 1 : 0;
}
int32_t pipeline_asm_var_is_emit_func_param_ptr_c(void *arena, void *mod, uint8_t *asm_ctx, int32_t var_expr_ref) {
  uint8_t vname[256];
  int32_t vlen;
  (void)asm_ctx;
  if (!arena || !mod || var_expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  return pipeline_asm_emit_func_param_is_ptr_by_name_c(arena, mod, vname, vlen);
}

int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, void *arena, int32_t block_ref, void *mod, int32_t func_index) {
  uint8_t ctx_buf[128];
  int32_t next_off;
  int32_t num_loc;
  int32_t size;
  int32_t arr_temp;
  int32_t call_spill;
  int32_t scratch;
  void *prev_mod;
  int32_t is_arm;
  if (!arena || block_ref <= 0)
    return 64;
  memset(ctx_buf, 0, sizeof(ctx_buf));
  *(void **)(ctx_buf + 16) = mod;
  prev_mod = pipeline_asm_emit_ctx_module_get();
  pipeline_asm_emit_ctx_module_set(mod);
  asm_ctx_local_reset(ctx_buf);
  next_off = 16;
  is_arm = pipeline_asm_host_is_arm64_c();
  if (num_params > 0 && mod && func_index >= 0) {
    int32_t pi;
    for (pi = 0; pi < num_params; pi++) {
      int32_t w = glue_func_param_home_width_c(arena, mod, func_index, pi);
      if (is_arm)
        next_off += (w > 8) ? w : 8;
      else
        next_off += (w > 8) ? (w + 8) : 8;
    }
  } else if (num_params > 0) {
    next_off = 16 + num_params * 8;
  }
  if (mod && func_index >= 0 && glue_func_return_byte_size_c(mod, arena, func_index) > 16)
    next_off += 8;
  if (mod && func_index >= 0 && func_index != pipeline_asm_hoist_target_func_index(mod))
    next_off = pipeline_asm_sum_module_top_level_lets_stack(arena, mod, next_off);
  num_loc = 0;
  asm_ctx_fill_locals_block_tree(ctx_buf, arena, block_ref, &next_off, &num_loc);
  arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
  call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  pipeline_asm_emit_ctx_module_set(prev_mod);
  {
    int32_t wa_temp = asm_sum_block_wa_temp_bytes(arena, block_ref);
    int32_t reent_dc = glue_sum_block_slice_reent_dc_bytes_c(arena, block_ref);
    size = next_off + arr_temp + wa_temp + reent_dc;
  }
  if (size > 0 && size % 16 != 0)
    size += 16 - (size % 16);
  scratch = call_spill;
  /* PLATFORM: SHARED — min scratch 2048 (was 512). Darwin -backend c -o
   * SEGV: invoke_cc_append_argv_head_flags wrote x29+0x898 past a 0x6d0
   * frame and smashed caller xlang_invoke_cc_impl c_paths. Twin of
   * pipeline_asm_compute_frame_size_c in runtime_pipeline_abi.x. */
  if (scratch < 2048)
    scratch = 2048;
  size += scratch;
  return size + 64;
}

