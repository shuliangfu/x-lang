/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/*
 * wave142: pipeline_asm_emit_assign pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: lhs_f32 + assign_rhs + assign_rhs_to_rax + assign_elf +
 *   field_assign_pair_base + body_expr_stmt_at.
 * Cap residual: binop/try_index/spill/slice dual-gp/float promote/fixed_array/
 *   field offset/enc store-div-shift/array_lit/expr faces.
 * PLATFORM: SHARED freestanding · continues same #ifndef FROM_X as wave141.
 */

/* XLANG_PABI_ASSIGN_THIN_BEGIN */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

#ifndef GLUE_STRUCT_LIT_DEST_IN_RBX
#define GLUE_STRUCT_LIT_DEST_IN_RBX (-3)
#endif
#ifndef GLUE_ARRAY_LIT_MAX_ELEMS
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#endif

extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t glue_emit_float_lit_to_rax_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t ta,
                                                 int32_t force_ty_ref, int32_t call_abi_widen_f64);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_try_binop_left_rax_right_rbx_elf_c(void *arena, void *elf_ctx, int32_t left_ref,
                                                        int32_t right_ref, void *ctx, int32_t ta);
extern int32_t glue_emit_binop_add_rax_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
extern int32_t glue_emit_binop_sub_rax_minus_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref,
                                                         int32_t right_ref, int32_t ta);
extern int32_t glue_emit_binop_mul_rax_rbx_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
extern int32_t glue_binop_operand_is_scalar_f32_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_binop_operand_is_unsigned_elf_c(void *arena, void *ctx, int32_t left_ref, int32_t right_ref);
extern int32_t glue_binop_operand_is_64bit_elf_c(void *arena, void *ctx, int32_t left_ref, int32_t right_ref);
extern int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(void *elf_ctx, void *ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_divsd_rax_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_divss_rax_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_and_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_or_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_xor_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_ecx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_eax_arch(void *elf_ctx, int32_t ta);
extern void glue_binop_var_slot_cache_clear(void);
extern void glue_binop_var_slot_cache_invalidate_slot(int32_t off);
extern void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_field_access_effective_offset_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t pipeline_expr_field_access_load_byte_sz(void *arena, void *mod, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(void *arena, void *elf_ctx, int32_t var_ref,
                                                          int32_t var_off, void *ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf_ctx, int32_t off, int32_t load_sz, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                        int32_t ta);
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                          int32_t ta, int32_t stack_slot_off);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref, int32_t base_ref,
                                                      int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                     int32_t ta, int32_t let_ty_ref, int32_t stack_slot_off);
extern int32_t glue_field_layout_offset_for_base_field(void *a, void *m, int32_t base_ref, uint8_t *field_name,
                                                       int32_t flen);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t glue_emit_bulk_mem_copy_spills_elf_c(void *elf_ctx, int32_t src_spill, int32_t dst_spill,
                                                     int32_t nbytes, int32_t ta);
extern int32_t glue_expr_emit_may_clobber_rbx_elf_c(void *arena, int32_t expr_ref);
extern int32_t glue_index_assign_addr_cache_hit(void *arena, void *ctx, int32_t base_ref, int32_t idx_ref,
                                                 int32_t esz);
extern void glue_index_assign_addr_cache_clear(void);
extern int32_t glue_index_assign_finish_store_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t base_ref,
                                                     int32_t idx_ref, int32_t esz, int32_t ta);
extern int32_t glue_try_index_var_lit_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                         void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                         void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                  int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                  int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                   int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                   int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                 int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                 int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                           int32_t idx_ref, void *ctx, int32_t ta,
                                                                           int32_t esz);
extern int32_t glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                            int32_t idx_ref, void *ctx, int32_t ta,
                                                                            int32_t esz);
extern int32_t glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                             int32_t idx_ref, void *ctx, int32_t ta,
                                                                             int32_t esz);
extern int32_t glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                    int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                          int32_t idx_ref, void *ctx, int32_t ta,
                                                                          int32_t esz);
extern int32_t glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                           int32_t idx_ref, void *ctx, int32_t ta,
                                                                           int32_t esz);
extern int32_t glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                      int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                         int32_t idx_ref, void *ctx, int32_t ta,
                                                                         int32_t esz);
extern int32_t glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                         int32_t idx_ref, void *ctx, int32_t ta,
                                                                         int32_t esz);
extern int32_t glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                                            int32_t idx_ref, void *ctx, int32_t ta,
                                                                            int32_t esz);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t asm_ctx_local_find_offset_scoped(void *ctx, void *arena, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern void glue_index_scratch_spill_invalidate_var(void *arena, void *elf_ctx, void *ctx, int32_t var_ref, int32_t ta);
extern int32_t pipeline_asm_modlet_name_is_shared(uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_modlet_store_from_rax_elf_c(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern void glue_slice_dual_gp_bump_past_home_c(void *ctx, int32_t data_home, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t pipeline_asm_emit_array_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void pipeline_asm_bump_next_offset_for_array_lit(void *arena, int32_t expr_ref, void *ctx);
extern int32_t glue_emit_fixed_array_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                          int32_t ta, int32_t arr_ty, int32_t stack_off);
extern int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                     int32_t ta, int32_t stack_off, int32_t type_ref);
extern int32_t glue_float_promote_src_ty_ref_c(void *arena, int32_t expr_ref);
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(void *arena, void *elf_ctx, int32_t dest_ty_ref,
                                                        int32_t src_ty_ref, int32_t ta);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_maybe_demote_f64_to_f32_eax_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t dest_ty_ref,
                                                      int32_t src_expr_ref, int32_t ta);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *arena, int32_t expr_ref);
extern int32_t ast_ast_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t ei);

static int32_t seed_assign_expr_lit_i32_at(void *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  if (!expr_ref)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    if (out_imm)
      *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

int32_t glue_assign_lhs_f32_type_ref_elf_c(void *arena, void *ctx, int32_t left_ref) {
  int32_t lko;
  int32_t tr;
  void *mod;
  if (!arena || left_ref <= 0)
    return 0;
  lko = pipeline_expr_kind_ord_at(arena, left_ref);
  if (lko == 3) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 14)
      return tr;
  }
  if (lko == 44) {
    mod = pipeline_asm_emit_module_ref_c();
    tr = glue_field_access_field_type_ref_c(arena, mod, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 14)
      return tr;
  }
  if (lko == 47) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 14)
      return tr;
  }
  return 0;
}

int32_t glue_emit_assign_rhs_elf_c(void *arena, void *elf_ctx, int32_t left_ref, int32_t right_ref, void *ctx,
                                    int32_t ta) {
  int32_t lhs_f32;
  if (!arena || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 1) {
    lhs_f32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
    if (lhs_f32 > 0)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0);
  }
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
}

int32_t glue_emit_assign_rhs_to_rax_elf_c(void *arena, void *elf_ctx, int32_t assign_expr_ref, int32_t left_ref,
                                           int32_t right_ref, void *ctx, int32_t ta) {
  int32_t ako;
  int32_t vr;
  int32_t is_64bit;
  int32_t is_unsigned;
  if (!arena || !elf_ctx || !ctx || assign_expr_ref <= 0 || left_ref <= 0 || right_ref <= 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  if (ako == 28)
    return glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == -2) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  switch (ako) {
  case 29:
    return glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 30:
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 31:
    return glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 32:
    if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
      return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
    if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  case 33:
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  case 34:
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  case 35:
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  case 36:
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  case 37:
    glue_binop_var_slot_cache_clear();
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    return is_64bit ? backend_enc_shl_cl_rax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  case 38:
    glue_binop_var_slot_cache_clear();
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, 0);
    if (is_unsigned)
      return is_64bit ? backend_enc_shr_cl_rax_arch(elf_ctx, ta) : backend_enc_shr_cl_eax_arch(elf_ctx, ta);
    return is_64bit ? backend_enc_sar_cl_rax_arch(elf_ctx, ta) : backend_enc_sar_cl_eax_arch(elf_ctx, ta);
  default:
    return -1;
  }
}

int32_t pipeline_asm_emit_assign_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lko;
  int32_t load_sz;
  int32_t esz;
  void *mod;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  lko = pipeline_expr_kind_ord_at(arena, left_ref);
  if (lko != 47)
    glue_index_assign_addr_cache_clear();
  if (lko == 44 && pipeline_expr_field_access_is_enum_variant(arena, left_ref) == 0) {
    int32_t base_ref = pipeline_expr_field_access_base_ref(arena, left_ref);
    int32_t field_off;
    int32_t chain_fa[16];
    int32_t chain_n = 0;
    int32_t walk_cur = left_ref;
    int32_t walk_i;
    int32_t dest_off;
    int32_t hit;
    int32_t typed_off;
    int32_t fa_ref;
    /* Walk FIELD chain to a local VAR root (h.s or w.h.s). Fold
     * glue_struct_field_frame_mag_c then reuse let-init. Pointer VAR /
     * mid-chain *T is not a frame-mag dest (Darwin 139). Those plus
     * INDEX roots use dest-in-rbx let-init below.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    while (chain_n < 16 && walk_cur > 0 &&
           pipeline_expr_kind_ord_at(arena, walk_cur) == 44) {
      chain_fa[chain_n++] = walk_cur;
      walk_cur = pipeline_expr_field_access_base_ref(arena, walk_cur);
    }
    if (base_ref > 0 && walk_cur > 0 && chain_n > 0 &&
        pipeline_expr_kind_ord_at(arena, walk_cur) == 3) {
      uint8_t vname[256];
      int32_t vlen;
      int32_t var_off;
      vlen = pipeline_expr_var_name_len(arena, walk_cur);
      if (vlen <= 0 || vlen > 255)
        return -1;
      pipeline_expr_var_name_into(arena, walk_cur, vname);
      var_off = asm_ctx_local_find_offset_scoped(ctx, arena, vname, vlen);
      if (var_off < 0)
        var_off = asm_ctx_local_find_offset(ctx, vname, vlen);
      if (var_off < 0)
        return -1;
      mod = pipeline_asm_emit_module_ref_c();
      field_off = glue_field_access_effective_offset_c(arena, mod, left_ref);
      load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, left_ref);
      if (load_sz <= 0)
        load_sz = 4;
      dest_off = var_off;
      hit = 1;
      {
        int32_t root_ty = glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur);
        int32_t mid_i;
        int32_t mid_ty;
        if (root_ty <= 0)
          root_ty = pipeline_expr_resolved_type_ref(arena, walk_cur);
        if (root_ty > 0 && pipeline_type_kind_ord_at(arena, root_ty) == 9)
          hit = 0;
        for (mid_i = 1; mid_i < chain_n && hit; mid_i++) {
          mid_ty = glue_field_access_field_type_ref_c(arena, mod, chain_fa[mid_i]);
          if (mid_ty > 0 && pipeline_type_kind_ord_at(arena, mid_ty) == 9)
            hit = 0;
        }
      }
      for (walk_i = chain_n - 1; walk_i >= 0 && hit; walk_i--) {
        fa_ref = chain_fa[walk_i];
        base_ref = pipeline_expr_field_access_base_ref(arena, fa_ref);
        vlen = pipeline_expr_field_access_name_len(arena, fa_ref);
        typed_off = -1;
        if (vlen > 0 && vlen <= 255) {
          pipeline_expr_field_access_name_into(arena, fa_ref, vname);
          typed_off = glue_field_layout_offset_for_base_field(arena, mod, base_ref, vname, vlen);
        }
        if (typed_off < 0)
          typed_off = glue_field_access_effective_offset_c(arena, mod, fa_ref);
        if (typed_off < 0) {
          hit = 0;
        } else {
          dest_off = glue_struct_field_frame_mag_c(dest_off, typed_off, ta);
          if (dest_off < 0)
            hit = 0;
        }
      }
      if (hit && (ta == 0 || ta == 1)) {
        int32_t field_ty = glue_field_access_field_type_ref_c(arena, mod, left_ref);
        /* SIMD field dest: same vector let-init as VAR assign
         * (`h.v = add4`). Prior 16B dual-GP store of a real CALL
         * left h.v[1]=0 (Darwin 20). G.7 complete; -2 falls through.
         * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
        if (field_ty > 0) {
          int32_t arr_st = glue_emit_vector_type_let_init_elf_c(
              arena, elf_ctx, right_ref, ctx, ta, dest_off, field_ty);
          if (arr_st == 0)
            return 0;
          if (arr_st == -1)
            return -1;
        }
        if (field_ty > 0 && pipeline_type_kind_ord_at(arena, field_ty) == 8) {
          int32_t arr_st;
          int32_t named_sz;
          int32_t simple_sz;
          arr_st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                       field_ty, dest_off);
          if (arr_st == 0)
            return 0;
          if (arr_st == -1)
            return -1;
          mod = glue_emit_module_from_ctx(ctx);
          simple_sz = glue_type_size_simple(mod, arena, field_ty, 0);
          named_sz = glue_type_named_layout_size_any_module_elf_c(arena, field_ty);
          if (named_sz > simple_sz)
            simple_sz = named_sz;
          if (simple_sz > 8 && simple_sz <= 16) {
            if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
              return -1;
            if (glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, field_ty, dest_off, ta,
                                                    right_ref, ctx) != 0)
              return -1;
            return 0;
          }
        }
      }
      if (chain_n == 1 && hit) {
        if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
          return -1;
        if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, walk_cur, var_off, ctx, ta) != 0)
          return -1;
        return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, field_off, load_sz, ta);
      }
    }
    /* TYPE_NAMED dest through pointer / INDEX / *T field: dest-in-rbx let-init. */
    if (ta == 0 || ta == 1) {
      int32_t field_ty = glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref);
      if (field_ty > 0 && pipeline_type_kind_ord_at(arena, field_ty) == 8) {
        int32_t arr_st;
        if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        arr_st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, field_ty, -3);
        if (arr_st == 0)
          return 0;
        if (arr_st == -1)
          return -1;
      }
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    mod = pipeline_asm_emit_module_ref_c();
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, left_ref);
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, load_sz, ta);
  }
  if (lko == 47) {
    int32_t base_ref;
    int32_t idx_ref;
    int32_t rko_idx;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
    base_ref = pipeline_expr_index_base_ref(arena, left_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
    if (base_ref <= 0 || idx_ref <= 0)
      return -1;
    rko_idx = pipeline_expr_kind_ord_at(arena, right_ref);
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 28 && rko_idx == 45 && esz > 0 &&
        pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      int32_t lit_imm;
      int32_t base_off;
      int32_t elem_home;
      int32_t base_tr;
      int32_t base_tk;
      base_tr = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
      base_tk = (base_tr > 0) ? pipeline_type_kind_ord_at(arena, base_tr) : 0;
      if (base_tk == 10) {
        if (seed_assign_expr_lit_i32_at(arena, idx_ref, &lit_imm)) {
          base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
          if (base_off >= 0) {
            elem_home = (ta == 1) ? (base_off + lit_imm * esz) : (base_off - lit_imm * esz);
            if (elem_home >= 0 &&
                pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, elem_home) == 0) {
              glue_index_assign_addr_cache_clear();
              return 0;
            }
          }
        } else {
          if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                         GLUE_STRUCT_LIT_DEST_IN_RBX) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          glue_index_assign_addr_cache_clear();
          return 0;
        }
      } else if (base_tk == 11) {
        if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                       GLUE_STRUCT_LIT_DEST_IN_RBX) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        glue_index_assign_addr_cache_clear();
        return 0;
      }
    }
    /* SIMD INDEX dest (`arr[0] = add4(a,b)` / `arr[0] = a.add4(b)`).
     * After ARRAY_LIT SIMD VAR the ctor is green; dest CALL is Darwin
     * 2 (lane1 leftover). dest-in-rbx + struct let-init −2 then a
     * real CALL; callee only adds lane0. G.7: VAR+lit frame dest +
     * glue_emit_vector_type_let_init (same as FIELD dest VECTOR CALL).
     * Do not pass dest-in-rbx −3 (would lea rbp-3). Slice dest /
     * nested arr[0][0] leftover.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if ((ta == 0 || ta == 1) && pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      int32_t simd_tr;
      int32_t simd_base_tr;
      int32_t simd_base_tk;
      int32_t simd_lanes;
      int32_t simd_esz;
      int32_t simd_nb;
      int32_t simd_lit;
      int32_t simd_off;
      int32_t simd_home;
      int32_t simd_st;
      simd_tr = pipeline_expr_resolved_type_ref(arena, left_ref);
      if (simd_tr <= 0) {
        simd_base_tr = pipeline_expr_resolved_type_ref(arena, base_ref);
        if (simd_base_tr > 0) {
          simd_base_tk = pipeline_type_kind_ord_at(arena, simd_base_tr);
          if (simd_base_tk == 10 || simd_base_tk == 11 || simd_base_tk == 9)
            simd_tr = pipeline_type_elem_ref_at(arena, simd_base_tr);
        }
      }
      if (simd_tr > 0 &&
          glue_vector_type_lanes_esz_c(arena, simd_tr, &simd_lanes, &simd_esz) == 0 &&
          simd_lanes > 0 && simd_esz > 0) {
        simd_nb = simd_lanes * simd_esz;
        if (seed_assign_expr_lit_i32_at(arena, idx_ref, &simd_lit)) {
          simd_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
          if (simd_off >= 0 && simd_nb > 0) {
            if (ta == 1)
              simd_home = simd_off + simd_lit * simd_nb;
            else
              simd_home = simd_off - simd_lit * simd_nb;
            if (simd_home >= 0) {
              simd_st = glue_emit_vector_type_let_init_elf_c(
                  arena, elf_ctx, right_ref, ctx, ta, simd_home, simd_tr);
              if (simd_st == 0) {
                glue_index_assign_addr_cache_clear();
                return 0;
              }
              if (simd_st == -1) {
                glue_index_assign_addr_cache_clear();
                return -1;
              }
            }
          }
        }
      }
    }
    /* TYPE_NAMED INDEX dest (`arr[0] = id16(x)`). Bulk CALL used
     * let_ty_ref=0 so store_retval_pair wrote rax only (Darwin .b leftover).
     * Dest-in-rbx let-init — same authority as pointer / INDEX FIELD dest.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if ((ta == 0 || ta == 1) && esz > 8) {
      int32_t idx_dest_tr;
      int32_t idx_dest_tk;
      int32_t idx_base_tr;
      int32_t idx_base_tk;
      int32_t idx_let;
      idx_dest_tr = pipeline_expr_resolved_type_ref(arena, left_ref);
      if (idx_dest_tr <= 0) {
        idx_base_tr = pipeline_expr_resolved_type_ref(arena, base_ref);
        if (idx_base_tr > 0) {
          idx_base_tk = pipeline_type_kind_ord_at(arena, idx_base_tr);
          if (idx_base_tk == 10 || idx_base_tk == 11 || idx_base_tk == 9)
            idx_dest_tr = pipeline_type_elem_ref_at(arena, idx_base_tr);
        }
      }
      if (idx_dest_tr > 0) {
        idx_dest_tk = pipeline_type_kind_ord_at(arena, idx_dest_tr);
        if (idx_dest_tk == 8) {
          if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          idx_let = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, idx_dest_tr,
                                                         GLUE_STRUCT_LIT_DEST_IN_RBX);
          if (idx_let == 0) {
            glue_index_assign_addr_cache_clear();
            return 0;
          }
          if (idx_let == -1) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
        }
      }
    }
    if (esz > 8) {
      int32_t rko_bulk;
      int32_t src_spill;
      int32_t dst_spill;
      int32_t temp_home;
      int32_t nbytes;
      int32_t next_off;
      rko_bulk = pipeline_expr_kind_ord_at(arena, right_ref);
      if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47 || rko_bulk == 48 || rko_bulk == 49) {
        next_off = *(int32_t *)((uint8_t *)ctx + 4);
        if (next_off + 32 < next_off) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        next_off += 16;
        src_spill = next_off;
        next_off += 16;
        dst_spill = next_off;
        *(int32_t *)((uint8_t *)ctx + 4) = next_off;
        temp_home = -1;
        if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47) {
          if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
        } else {
          nbytes = (esz + 7) & ~7;
          next_off = *(int32_t *)((uint8_t *)ctx + 4);
          if (next_off + nbytes < next_off) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          next_off += nbytes;
          temp_home = next_off;
          *(int32_t *)((uint8_t *)ctx + 4) = next_off;
          if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0, temp_home) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
        }
        if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        glue_index_assign_addr_cache_clear();
        return 0;
      }
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return -1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return -1;
    }
    if (glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref))
      glue_index_assign_addr_cache_clear();
    if (glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz))
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    if (esz == 1 || esz == 4 || esz == 8) {
      if (glue_try_index_var_lit_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    glue_index_assign_addr_cache_clear();
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
  }
  if (lko == 3) {
    uint8_t vname[256];
    int32_t vlen;
    int32_t off;
    int32_t is_modlet;
    int32_t ltr_pre;
    int32_t ltk_pre;
    int32_t rko_pre;
    vlen = pipeline_expr_var_name_len(arena, left_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, left_ref, vname);
    glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
    is_modlet = pipeline_asm_modlet_name_is_shared(vname, vlen);
    off = asm_ctx_local_find_offset_scoped(ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset(ctx, vname, vlen);
    if (off < 0 && is_modlet == 0)
      return -1;
    if (off >= 0)
      glue_binop_var_slot_cache_invalidate_slot(off);
    ltr_pre = (off >= 0) ? glue_var_decl_type_ref_elf_c(arena, ctx, left_ref) : 0;
    ltk_pre = (ltr_pre > 0) ? pipeline_type_kind_ord_at(arena, ltr_pre) : 0;
    rko_pre = pipeline_expr_kind_ord_at(arena, right_ref);
    if (is_modlet == 0 && off >= 0 && ltk_pre == 11 && rko_pre == 46 &&
        pipeline_expr_kind_ord_at(arena, expr_ref) == 28) {
      int32_t n_arr = pipeline_expr_array_lit_num_elems_at(arena, right_ref);
      if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
        return -1;
      glue_slice_dual_gp_bump_past_home_c(ctx, off, ta);
      if (pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
        return -1;
      if (n_arr > 0)
        pipeline_asm_bump_next_offset_for_array_lit(arena, right_ref, ctx);
      glue_binop_var_slot_cache_kill_def_at_slot(off);
      return 0;
    }
    if (is_modlet == 0 && off >= 0 && ltk_pre == 10 && pipeline_expr_kind_ord_at(arena, expr_ref) == 28) {
      int32_t arr_st =
          glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr_pre, off);
      if (arr_st == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(off);
        return 0;
      }
      if (arr_st == -1)
        return -1;
    }
    /* TYPE_VECTOR VAR assign: same let-init authority as .x (G.7).
     * METHOD `d = a.add4(b)` must lane-inline; -2 falls through to CALL.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    if (is_modlet == 0 && off >= 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 28 && ltr_pre > 0) {
      int32_t vst =
          glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, off, ltr_pre);
      if (vst == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(off);
        return 0;
      }
      if (vst == -1)
        return -1;
    }
    /* TYPE_NAMED VAR assign: same struct let-init as .x (G.7).
     * >16B CALL must lea dest into x8/rdi sret; memcpy-from-rax SIGBUS.
     * TYPE_NAMED=8; -2 falls through. PLATFORM: SHARED. */
    if (is_modlet == 0 && off >= 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 28 && ltk_pre == 8) {
      int32_t sst =
          glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr_pre, off);
      if (sst == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(off);
        return 0;
      }
      if (sst == -1)
        return -1;
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    if (is_modlet != 0) {
      if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, vname, vlen, ta) != 0)
        return -1;
      if (off >= 0)
        glue_binop_var_slot_cache_kill_def_at_slot(off);
      return 0;
    }
    {
      int32_t ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      int32_t rty = glue_float_promote_src_ty_ref_c(arena, right_ref);
      int32_t ltk;
      if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, ltr, rty, ta) != 0)
        return -1;
      /* f32 dest + f64 rhs: demote to f32 bits before the 4-byte store, else
       * the store keeps only the low 32 bits of the f64 (shared truncation). */
      if (glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, ltr, right_ref, ta) != 0)
        return -1;
      ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
      if (ltk == 11) {
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
          return -1;
      } else if (ltr > 0 && ltk == 14) {
        if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
          return -1;
      } else if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx,
                                                    ltr, off, ta, right_ref, ctx) != 0) {
        /* G.7: same dual-GP as let-init (9–16B struct/vector). Scalar ≤8B stores rax only. */
        return -1;
      }
    }
    glue_binop_var_slot_cache_kill_def_at_slot(off);
    return 0;
  }
  if (lko == 52) {
    int32_t store_sz;
    int32_t tr;
    extern int32_t glue_vector_type_lanes_esz_c(void *arena, int32_t type_ref, int32_t *out_lanes,
                                                int32_t *out_esz);
    extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
    extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
    extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf_ctx, int32_t off, int32_t sz,
                                                            int32_t ta);
    extern int32_t glue_x86_store_rdx_to_rbx8_elf_c(void *elf_ctx);
    /* Aggregate dest (`*p = …` TYPE_NAMED / SLICE / VECTOR / ARRAY).
     * Dest-in-rbx let-init for register-class; TYPE_ARRAY CALL is E* then
     * glue_copy *rax → dest. PLATFORM: SHARED — Darwin ARM64 live fail. */
    if (ta == 0 || ta == 1) {
      int32_t deref_tr;
      int32_t deref_tk;
      int32_t deref_op;
      int32_t deref_op_tr;
      int32_t deref_op_tk;
      int32_t deref_let;
      int32_t deref_rko;
      int32_t deref_nbytes;
      void *deref_mod;
      deref_tr = pipeline_expr_resolved_type_ref(arena, left_ref);
      deref_tk = (deref_tr > 0) ? pipeline_type_kind_ord_at(arena, deref_tr) : 0;
      if (deref_tk != 8 && deref_tk != 11 && deref_tk != 13 && deref_tk != 10) {
        deref_op = pipeline_expr_unary_operand_ref_at(arena, left_ref);
        if (deref_op > 0) {
          deref_op_tr = pipeline_expr_resolved_type_ref(arena, deref_op);
          if (deref_op_tr <= 0)
            deref_op_tr = glue_var_decl_type_ref_elf_c(arena, ctx, deref_op);
          if (deref_op_tr > 0) {
            deref_op_tk = pipeline_type_kind_ord_at(arena, deref_op_tr);
            if (deref_op_tk == 9) {
              deref_tr = pipeline_type_elem_ref_at(arena, deref_op_tr);
              deref_tk = (deref_tr > 0) ? pipeline_type_kind_ord_at(arena, deref_tr) : 0;
            }
          }
        }
      }
      if (deref_tr > 0 && (deref_tk == 8 || deref_tk == 11 || deref_tk == 13 || deref_tk == 10)) {
        if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        deref_rko = pipeline_expr_kind_ord_at(arena, right_ref);
        {
          int32_t v_lanes = 0;
          int32_t v_esz = 0;
          int32_t v_src;
          if (glue_vector_type_lanes_esz_c(arena, deref_tr, &v_lanes, &v_esz) == 0 &&
              v_lanes > 0 && v_esz > 0) {
            deref_nbytes = v_lanes * v_esz;
            if (deref_nbytes >= 8 && deref_rko == 3) {
              v_src = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
              if (v_src >= 0) {
                if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, v_src, ta) != 0)
                  return -1;
                if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, GLUE_STRUCT_LIT_DEST_IN_RBX,
                                                              deref_nbytes, ta) != 0)
                  return -1;
                return 0;
              }
            }
            if (deref_nbytes >= 8 && (deref_rko == 48 || deref_rko == 49)) {
              int32_t v_spill;
              int32_t v_temp;
              int32_t v_st;
              extern void glue_align_next_offset(void *ctx);
              extern int32_t pipe_asm_ctx_off_next_offset(void);
              extern int32_t pipe_load_i32_le(void *p, int32_t off);
              extern void pipe_store_i32_le(void *p, int32_t off, int32_t v);
              extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
              extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t off, int32_t ta);
              extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
              extern int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx,
                                                                  int32_t init_ref, void *ctx, int32_t ta,
                                                                  int32_t stack_slot_off, int32_t type_ref);
              /* PLATFORM: SHARED — ARM64 low-end home=cur; x86 high-end
               * home=cur+sz. Increment-after on x86 overlaps last local
               * (Ubuntu memcpy(33) SIGSEGV). Same polarity as
               * glue_simd_alloc_vector_temp_slot / ARRAY_LIT SIMD formal. */
              glue_align_next_offset(ctx);
              v_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
              if (ta == 1)
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), v_spill + 8);
              else {
                v_spill = v_spill + 8;
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), v_spill);
              }
              if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
                return -1;
              if (backend_enc_store_rax_to_rbp_arch(elf_ctx, v_spill, ta) != 0)
                return -1;
              glue_align_next_offset(ctx);
              v_temp = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
              if (ta == 1)
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), v_temp + deref_nbytes);
              else {
                v_temp = v_temp + deref_nbytes;
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), v_temp);
              }
              v_st = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, v_temp,
                                                          deref_tr);
              if (v_st == -1)
                return -1;
              if (backend_enc_load_rbp_to_rax_arch(elf_ctx, v_spill, ta) != 0)
                return -1;
              if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
                return -1;
              if (v_st == 0) {
                if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, v_temp, ta) != 0)
                  return -1;
                if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, GLUE_STRUCT_LIT_DEST_IN_RBX,
                                                              deref_nbytes, ta) != 0)
                  return -1;
                return 0;
              }
              if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
                return -1;
              if (ta == 1) {
                if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta) != 0)
                  return -1;
              } else {
                if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta) != 0)
                  return -1;
                if (glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx) != 0)
                  return -1;
              }
              return 0;
            }
          }
        }
        /* dest-in-rbx TYPE_ARRAY / TYPE_SLICE CALL: park dest before emit.
         * Callee clobbers rbx / AAPCS64 x19 (unsaved in prologue).
         * For TYPE_SLICE (16B): CALL returns dual-GP {data, len} in rax+rdx
         * (x0+x1 on ARM64). Spill to a frame temp, restore dest, then copy 16B.
         * For TYPE_ARRAY: CALL returns payload pointer in rax (x0 on ARM64).
         * Spill payload pointer, restore dest, reload pointer into rax,
         * then copy nbytes via glue_copy_large_struct_from_rax_ptr_elf_c.
         * PLATFORM: SHARED dest-in-rbx CALL · LINUX x86_64 SysV · MACOS|ARM64. */
        if ((deref_tk == 10 || deref_tk == 11) && (deref_rko == 48 || deref_rko == 49)) {
          deref_mod = glue_emit_module_from_ctx(ctx);
          deref_nbytes = glue_type_size_simple(deref_mod, arena, deref_tr, 0);
          if (deref_tk == 11)
            deref_nbytes = 16;
          if (deref_nbytes < 8)
            deref_nbytes = glue_fixed_array_total_bytes_c(arena, deref_tr, 0);
          if (deref_nbytes >= 8) {
            int32_t dst_spill;
            int32_t src_spill;
            extern void glue_align_next_offset(void *ctx);
            extern int32_t pipe_asm_ctx_off_next_offset(void);
            extern int32_t pipe_load_i32_le(void *p, int32_t off);
            extern void pipe_store_i32_le(void *p, int32_t off, int32_t v);
            extern int32_t glue_arm64_mov_x19_to_x0_elf_c(void *elf_ctx);
            extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
            extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t off, int32_t ta);
            extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
            extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
            extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
            extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
            extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
            glue_align_next_offset(ctx);
            dst_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if (ta == 1) {
              pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dst_spill + 8);
            } else {
              dst_spill = dst_spill + 8;
              pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dst_spill);
            }
            if (ta == 1) {
              if (glue_arm64_mov_x19_to_x0_elf_c(elf_ctx) != 0)
                return -1;
            } else {
              if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
                return -1;
            }
            if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
              return -1;
            if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
              return -1;
            if (deref_tk == 11) {
              glue_align_next_offset(ctx);
              src_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
              if (ta == 1) {
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill + 16);
              } else {
                src_spill = src_spill + 16;
                pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill);
              }
              if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
                return -1;
              if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(src_spill, ta), ta) != 0)
                return -1;
              if (backend_enc_load_rbp_to_rax_arch(elf_ctx, dst_spill, ta) != 0)
                return -1;
              if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
                return -1;
              if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_spill, ta) != 0)
                return -1;
              if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, GLUE_STRUCT_LIT_DEST_IN_RBX, 16, ta) != 0)
                return -1;
              return 0;
            }
            glue_align_next_offset(ctx);
            src_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if (ta == 1) {
              pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill + 8);
            } else {
              src_spill = src_spill + 8;
              pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill);
            }
            if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
              return -1;
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, dst_spill, ta) != 0)
              return -1;
            if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
              return -1;
            if (backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta) != 0)
              return -1;
            if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, GLUE_STRUCT_LIT_DEST_IN_RBX, deref_nbytes, ta) != 0)
              return -1;
            return 0;
          }
        }
        deref_let = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, deref_tr,
                                                         GLUE_STRUCT_LIT_DEST_IN_RBX);
        if (deref_let == 0)
          return 0;
        if (deref_let == -1)
          return -1;
      }
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    store_sz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    if (store_sz <= 0)
      store_sz = 4;
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, store_sz, ta);
  }
  return -1;
}

int32_t glue_field_assign_pair_base_ref_c(void *arena, int32_t er) {
  int32_t left_ref;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  return pipeline_expr_field_access_base_ref(arena, left_ref);
}

int32_t glue_body_expr_stmt_at_c(void *arena, int32_t body_ref, int32_t si, int32_t nso, int32_t *out_er) {
  int32_t er;
  if (!arena || body_ref <= 0 || !out_er)
    return 0;
  if (nso > 0) {
    if (ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
  } else {
    er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, si);
  }
  if (er <= 0)
    return 0;
  *out_er = er;
  return 1;
}


/* XLANG_PABI_ASSIGN_THIN_END — assign cluster only; w157/bvsc are separate thins */

/* ============================================================================
 * wave157 call-spill calculation: w157_sum_expr_call_spill_bytes +
 *   glue_asm_sum_block_call_spill_bytes.
 * Walks AST block-tree to calculate call-argument spill bytes required.
 * Accurately covers labeled return expressions (fixing pure-asm stack under-allocation).
 * ============================================================================ */

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_method_call_base_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_struct_lit_num_fields(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_init_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_if_cond_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(void *arena, int32_t expr_ref);

extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_const_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_final_expr_ref(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_if_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_while_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_while_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_for_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_for_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_for_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_for_step_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_for_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_num_labeled_stmts(void *arena, int32_t block_ref);
extern int32_t pipeline_block_labeled_is_goto(void *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_block_labeled_return_expr_ref(void *arena, int32_t block_ref, int32_t li);

static int32_t g_w157_spill_total = 0;
static int32_t g_w157_spill_visits = 0;
static int32_t g_w157_walk_stack[8192];



static void w157_sum_expr_call_spill_bytes(void *arena, int32_t expr_ref) {
  int32_t ko, n, i, arg_ref, op, as_op;
  if (!arena || expr_ref <= 0) return;
  g_w157_spill_visits++;
  if (g_w157_spill_visits > 32768) return;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 48) { /* EXPR_CALL */
    n = pipeline_expr_call_num_args_at(arena, expr_ref);
    if (n < 0) n = 0;
    if (n > 64) n = 64;
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    /* w1040: single-GP stride 8 / dual 16; budget (n+1)*16 (was *32). */
    g_w157_spill_total += (n + 1) * 16;
    return;
  }
  if (ko == 49) { /* EXPR_METHOD_CALL */
    arg_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    n = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    if (n < 0) n = 0;
    if (n > 64) n = 64;
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    g_w157_spill_total += (n + 1) * 16;
    return;
  }
  /*
   * P12g root fix (2026-09-15): EXPR_IF(25)/EXPR_BLOCK(26) share kind ordinals
   * with the binop set — an else-if chain parses into a nested EXPR_IF chain
   * whose arms are EXPR_BLOCK-wrapped blocks (parser if_stmt_parts_to_if_expr).
   * Routing them through the binop branch loses the else arm (binop has no
   * third child), so every chain beyond the first arm vanished from the
   * call-spill estimate. Try the if/block accessors first; fall through to
   * the binop walk when they read empty (shared ordinals stay honored).
   * PLATFORM: SHARED — twin in runtime_pipeline_abi.x.
   */
  if (ko == 25) {
    arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
    if (arg_ref > 0) {
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      op = pipeline_expr_if_then_ref_at(arena, expr_ref);
      w157_sum_expr_call_spill_bytes(arena, op);
      op = pipeline_expr_if_else_ref_at(arena, expr_ref);
      w157_sum_expr_call_spill_bytes(arena, op);
      return;
    }
  }
  if (ko == 26) {
    extern int32_t pipeline_expr_block_ref_at(void *a2, int32_t er2);
    extern void w157_walk_block_rec(void *arena2, int32_t block_ref2, int32_t depth2);
    int32_t wb26 = pipeline_expr_block_ref_at(arena, expr_ref);
    if (wb26 > 0) {
      w157_walk_block_rec(arena, wb26, 40);
      return;
    }
  }
  if ((ko >= 4 && ko <= 21) || ko == 25 || ko == 26 || (ko >= 28 && ko <= 38)) {
    arg_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    op = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 51) {
    /* 51 = EXPR_ADDR_OF; walk `&buf[i]` CALL args / INDEX temps. */
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  as_op = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (ko == 54 || as_op > 0) {
    op = as_op;
    if (op <= 0) {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 47) { /* INDEX */
    arg_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    op = pipeline_expr_index_index_ref(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 44) { /* FIELD_ACCESS */
    op = pipeline_expr_field_access_base_ref(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 46) { /* ARRAY_LIT */
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    if (n > 1024) n = 1024;
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    return;
  }
  if (ko == 45) { /* STRUCT_LIT */
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    if (n > 64) n = 64;
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    return;
  }
  arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  if (arg_ref > 0) {
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    op = pipeline_expr_if_then_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    op = pipeline_expr_if_else_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
  }
}

/*
 * P12g root fix (2026-09-15): recursive block walker shared by the outer
 * driver and the EXPR_BLOCK unwrap above. else-if chains become EXPR_IF
 * exprs whose arms are EXPR_BLOCK-wrapped blocks (parser
 * if_stmt_parts_to_if_expr); without unwrapping them here the walk loses
 * every arm body's calls and compute_frame_size under-reserves call-spill
 * scratch (big functions' spill peaks cross the frame top into the caller).
 * Depth-capped recursion (stmt_order authority when present; raw arrays
 * otherwise). PLATFORM: SHARED — twin in runtime_pipeline_abi.x.
 */
void w157_walk_block_rec(void *arena, int32_t cur, int32_t depth) {
  int32_t i, n, ch, er, fin, nso;
  if (!arena || cur <= 0 || depth <= 0)
    return;
  if (g_w157_spill_visits > 32768)
    return;
  nso = ast_ast_block_num_stmt_order(arena, cur);
  if (nso > 0) {
    for (i = 0; i < nso; i++) {
      int32_t sok = (int32_t)ast_ast_block_stmt_order_kind(arena, cur, i);
      int32_t soi = ast_ast_block_stmt_order_idx(arena, cur, i);
      if (soi < 0)
        continue;
      if (sok == 2) {
        er = ast_pipeline_block_expr_stmt_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 1) {
        er = ast_pipeline_block_let_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 0) {
        er = ast_pipeline_block_const_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 5) {
        er = ast_pipeline_block_if_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = ast_pipeline_block_if_then_body_ref(arena, cur, soi);
        if (ch > 0)
          w157_walk_block_rec(arena, ch, depth - 1);
        ch = ast_pipeline_block_if_else_body_ref(arena, cur, soi);
        if (ch > 0)
          w157_walk_block_rec(arena, ch, depth - 1);
      } else if (sok == 3) {
        er = ast_ast_block_while_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = pipeline_block_while_body_ref(arena, cur, soi);
        if (ch > 0)
          w157_walk_block_rec(arena, ch, depth - 1);
      } else if (sok == 4) {
        er = ast_ast_block_for_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        er = ast_ast_block_for_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        er = ast_ast_block_for_step_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = pipeline_block_for_body_ref(arena, cur, soi);
        if (ch > 0)
          w157_walk_block_rec(arena, ch, depth - 1);
      } else if (sok == 6) {
        ch = pipeline_block_region_body_ref(arena, cur, soi);
        if (ch > 0)
          w157_walk_block_rec(arena, ch, depth - 1);
      } else if (sok == 7) {
        if (pipeline_block_labeled_is_goto(arena, cur, soi) == 0) {
          er = pipeline_block_labeled_return_expr_ref(arena, cur, soi);
          if (er > 0)
            w157_sum_expr_call_spill_bytes(arena, er);
        }
      }
    }
    fin = ast_ast_block_final_expr_ref(arena, cur);
    if (fin > 0)
      w157_sum_expr_call_spill_bytes(arena, fin);
    return;
  }
  n = ast_ast_block_num_consts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_const_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  n = ast_ast_block_num_lets(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_let_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  n = ast_ast_block_num_expr_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  fin = ast_ast_block_final_expr_ref(arena, cur);
  if (fin > 0)
    w157_sum_expr_call_spill_bytes(arena, fin);
  n = ast_ast_block_num_if_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_if_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
    if (ch > 0)
      w157_walk_block_rec(arena, ch, depth - 1);
    ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
    if (ch > 0)
      w157_walk_block_rec(arena, ch, depth - 1);
  }
  n = ast_ast_block_num_loops(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_ast_block_while_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = pipeline_block_while_body_ref(arena, cur, i);
    if (ch > 0)
      w157_walk_block_rec(arena, ch, depth - 1);
  }
  n = ast_ast_block_num_for_loops(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_ast_block_for_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    er = ast_ast_block_for_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    er = ast_ast_block_for_step_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = pipeline_block_for_body_ref(arena, cur, i);
    if (ch > 0)
      w157_walk_block_rec(arena, ch, depth - 1);
  }
  n = ast_ast_block_num_regions(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    if (ch > 0)
      w157_walk_block_rec(arena, ch, depth - 1);
  }
  n = pipeline_block_num_labeled_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    if (pipeline_block_labeled_is_goto(arena, cur, i) == 0) {
      er = pipeline_block_labeled_return_expr_ref(arena, cur, i);
      if (er > 0)
        w157_sum_expr_call_spill_bytes(arena, er);
    }
  }
}

int32_t glue_asm_sum_block_call_spill_bytes(void *arena, int32_t block_ref) {
  if (!arena || block_ref <= 0)
    return 0;
  g_w157_spill_total = 0;
  g_w157_spill_visits = 0;
  w157_walk_block_rec(arena, block_ref, 256);
  return g_w157_spill_total;
}



/*
 * wave143: pipeline_asm_emit_array_lit pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: elem_byte_sz + empty + emit/force_esz + force_esz_from_elem +
 *   durable_ptr + fixed_array_temp_bytes + array_temp_bytes_for_let_init +
 *   array_lit_elem_type_ref.
 * Cap residual: leaf/flat (vector_let) + may_clobber + slice dual-gp +
 *   type_size_simple + fixed_array_total + struct_type_let_init +
 *   scalar_elem + bulk_mem + lea_common + emit_expr_elf_c + al_nc_seq_take +
 *   pool/enc faces.
 * LP64 next_offset@4 via (uint8_t*)ctx+4.
 * GLUE_ARRAY_LIT_MAX_ELEMS=1024  GLUE_ARRAY_LIT_MAX_PAYLOAD=4096
 * PLATFORM: SHARED freestanding · continues same #ifndef FROM_X as wave142.
 */

#ifndef GLUE_ARRAY_LIT_MAX_ELEMS
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#endif
#ifndef GLUE_ARRAY_LIT_MAX_PAYLOAD
#define GLUE_ARRAY_LIT_MAX_PAYLOAD 4096
#endif
#ifndef GLUE_TYPE_KIND_SLICE
#define GLUE_TYPE_KIND_SLICE 11
#endif

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ref);
extern int32_t pipeline_arena_num_types(void *arena);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_asm_array_lit_leaf_elem_byte_sz_c(void *arena, int32_t init_ref);
extern int32_t pipeline_asm_emit_array_lit_flat_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                       int32_t ta, int32_t stack_slot_off, int32_t leaf_esz,
                                                       int32_t *flat_i);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_expr_emit_may_clobber_rbx_elf_c(void *arena, int32_t expr_ref);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                     int32_t ta, int32_t let_ty_ref, int32_t stack_slot_off);
extern int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(void *arena, void *elf_ctx, int32_t array_lit_ref,
                                                             int32_t elem_ref, void *ctx, int32_t ta,
                                                             int32_t force_esz);
extern int32_t glue_emit_bulk_mem_copy_spills_elf_c(void *elf_ctx, int32_t src_spill, int32_t dst_spill,
                                                     int32_t esz, int32_t ta);
extern int32_t glue_asm_lea_rax_common_rip_x86(void *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t glue_asm_lea_rbx_common_rip_x86(void *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t glue_asm_lea_rax_common_adrp_arm64(void *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t glue_asm_lea_rbx_common_adrp_arm64(void *elf_ctx, uint8_t *name, int32_t name_len);
extern void glue_align_next_offset(void *ctx);
extern int32_t glue_pipeline_asm_al_nc_seq_take_c(void);
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_add_common_sym(void *ctx, uint8_t *name, int32_t name_len, int32_t sym_size,
                                               int32_t sym_align);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf_ctx, int32_t off, int32_t load_sz, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf_ctx, int32_t imm, int32_t ta);

