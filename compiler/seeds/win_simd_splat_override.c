/* PLATFORM: WINDOWS leftover-PE — real pipeline_asm_simd_try_inline_splat_call_elf_c.
 * Twin of FROM_X try_inline splat (1/0/-1). Class W.
 * Link FIRST with -Wl,--allow-multiple-definition over leftover stub in pabi.
 */
#include <stdint.h>
#include <string.h>

static int32_t win_glue_simd_callee_is_splat_c(const uint8_t *cname, int32_t clen) {
  if (!cname || clen <= 0)
    return 0;
  if (clen == 5 && memcmp(cname, "splat", 5) == 0)
    return 1;
  if (clen == 10 && memcmp(cname, "simd_splat", 10) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec8i_splat", 11) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec4f_splat", 11) == 0)
    return 1;
  return 0;
}

extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref);
extern int32_t glue_call_callee_func_name_into_c(void *a, int32_t callee_ref, uint8_t *out, int32_t cap);
extern int32_t glue_vector_type_lanes_esz_c(void *a, int32_t type_ref, int32_t *out_lanes, int32_t *out_esz);
extern int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t glue_simd_emit_imm_fill_slot_c(void *elf, int32_t slot, int32_t lanes, int32_t esz, int32_t ta,
                                             int32_t imm);
extern int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi);
extern int32_t pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref);
extern int32_t glue_emit_float_lit_to_rax_elf_c(void *a, void *elf, int32_t expr_ref, int32_t ta, int32_t a4,
                                               int32_t a5);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);

int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                     int32_t ta, int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref, clen, arg0, lanes, esz, ko, nargs, is_method, imm, store_sz, li;
  uint8_t cname[256];
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  nargs = is_method ? pipeline_expr_method_call_num_args_at(arena, call_ref)
                    : pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 1)
    return 0;
  if (is_method) {
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  if (!win_glue_simd_callee_is_splat_c(cname, clen))
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  arg0 = is_method ? pipeline_expr_method_call_arg_ref(arena, call_ref, 0)
                   : pipeline_expr_call_arg_ref(arena, call_ref, 0);
  if (arg0 <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arg0);
  if (ko == 0 || ko == 2) {
    imm = pipeline_expr_int_val_at(arena, arg0);
    if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
      return -1;
    return 1;
  }
  if (ko == 1) {
    if (esz == 4) {
      imm = glue_ieee_f64_bits_to_f32_bits(pipeline_expr_float_bits_lo_at(arena, arg0),
                                          pipeline_expr_float_bits_hi_at(arena, arg0));
      if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
        return -1;
      return 1;
    }
    if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, arg0, ta, 0, 0) != 0)
      return -1;
    store_sz = esz;
    if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
      store_sz = 4;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    for (li = 0; li < lanes; li++) {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * store_sz, store_sz, ta) != 0)
        return -1;
    }
    return 1;
  }
  return 0;
}
