/* PLATFORM: WINDOWS leftover-PE — real select/shuffle/fma3 try_inline.
 * Twin of FROM_X. Class Y. Link FIRST (PE first-wins).
 */
/* wave774 Class Y: Win SIMD try_inline select/shuffle/fma3 twins (deps already in live). */
#include <stdint.h>
#include <string.h>
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
extern int32_t glue_peel_comptime_array_lit_mask_c(void *arena, void *ctx, int32_t mask_ref);
extern int32_t glue_asm_local_var_stack_off_scoped(void *arena, void *ctx, int32_t var_expr_ref);
extern char *link_abi_getenv(const char *name);
extern int32_t glue_shuffle_pshufd_imm8_from_mask_c(void *arena, int32_t mask_ref, int32_t lanes, int32_t *out_imm8);
extern uint32_t glue_simd_emit_cpu_features_c(void);
extern uint32_t xlang_target_cpu_detect_host(void);
extern int32_t simd_enc_try_pshufd_rbp(void *elf, int32_t src, int32_t dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_shuffle_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t src_ref, int32_t mask_lit,
                                                          int32_t dst_off, int32_t type_ref, void *ctx, int32_t ta);
extern int32_t glue_simd_expr_splat_int_imm_c(void *arena, int32_t expr_ref, int32_t *out_imm);
extern int32_t pipeline_asm_emit_vector_var_copy_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                                       int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                             int32_t ta, int32_t stack_slot_off, int32_t type_ref);
extern int32_t glue_simd_select_arg_stack_off_c(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t arg_ref,
                                                int32_t type_ref);
extern int32_t glue_vector_elem_is_f32_c(void *arena, int32_t type_ref);
extern int32_t simd_enc_try_hw_vector_select_rbp(void *elf, int32_t m, int32_t a, int32_t b, int32_t d, int32_t lanes,
                                                  int32_t is_f32, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_select_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t mask_ref, int32_t a_ref,
                                                         int32_t b_ref, int32_t dst_off, int32_t type_ref, void *ctx,
                                                         int32_t ta);
extern int32_t glue_callee_is_vec4f_fma3_c(uint8_t *cname, int32_t clen);
extern int32_t simd_enc_try_hw_vector_fma_rbp(void *elf, int32_t a, int32_t b, int32_t c, int32_t d, int32_t lanes,
                                               int32_t esz, int32_t ta, uint32_t feats);

int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena,
                                                       void *elf_ctx, int32_t call_ref,
                                                       void *ctx, int32_t ta,
                                                       int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg0;
  int32_t arg1;
  int32_t mask_lit;
  int32_t lanes;
  int32_t esz;
  int32_t src_off;
  int32_t imm8;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.shuffle is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 2)
    return 0;
  if (is_method) {
    /* Method name lives on METHOD_CALL node (not FIELD callee). */
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
  expect_lanes = 0;
  if (clen == 13 && memcmp(cname, "vec4f_shuffle", 13) == 0)
    expect_lanes = 4;
  else if (clen == 13 && memcmp(cname, "vec8i_shuffle", 13) == 0)
    expect_lanes = 8;
  else if (clen == 12 && memcmp(cname, "simd_shuffle", 12) == 0)
    expect_lanes = 0;
  else if (clen == 7 && memcmp(cname, "shuffle", 7) == 0)
    /* import METHOD bare name: simd.shuffle → "shuffle". */
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
  }
  if (arg0 <= 0 || arg1 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3)
    return 0;
  mask_lit = glue_peel_comptime_array_lit_mask_c(arena, ctx, arg1);
  if (mask_lit <= 0)
    return 0;
  src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  if (src_off < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    if (glue_shuffle_pshufd_imm8_from_mask_c(arena, mask_lit, lanes, &imm8) == 0) {
      feats = glue_simd_emit_cpu_features_c();
      if (feats == 0)
        feats = xlang_target_cpu_detect_host();
      if (simd_enc_try_pshufd_rbp(elf_ctx, src_off, stack_slot_off, imm8, lanes, ta, feats) == 0)
        return 1;
    }
  }
  if (glue_emit_vector_shuffle_lane_scalar_elf_c(arena, elf_ctx, arg0, mask_lit, stack_slot_off, type_ref, ctx, ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena,
                                                      void *elf_ctx, int32_t call_ref,
                                                      void *ctx, int32_t ta,
                                                      int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg_m;
  int32_t arg_a;
  int32_t arg_b;
  int32_t lanes;
  int32_t esz;
  int32_t off_m;
  int32_t off_a;
  int32_t off_b;
  int32_t is_f32;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 3)
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
  expect_lanes = 0;
  if (clen == 12 && memcmp(cname, "vec4f_select", 12) == 0)
    expect_lanes = 4;
  else if (clen == 12 && memcmp(cname, "vec8i_select", 12) == 0)
    expect_lanes = 8;
  else if (clen == 11 && memcmp(cname, "simd_select", 11) == 0)
    expect_lanes = 0;
  else if (clen == 6 && memcmp(cname, "select", 6) == 0)
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg_m = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg_m = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg_m <= 0 || arg_a <= 0 || arg_b <= 0)
    return -1;
  /* Comptime-uniform mask: select(splat(k), a, b) → a if k!=0 else b.
   * Product select_lane is mask!=0 ? a : b. Avoids two splat sret + select.
   * PLATFORM: SHARED — fold before any temp emit. */
  {
    int32_t mask_imm;
    int32_t pick;
    int32_t pko;
    if (glue_simd_expr_splat_int_imm_c(arena, arg_m, &mask_imm)) {
      pick = (mask_imm != 0) ? arg_a : arg_b;
      pko = pipeline_expr_kind_ord_at(arena, pick);
      if (pko == 3) {
        if (pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                    type_ref) != 0)
          return -1;
        return 1;
      }
      if (pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                        type_ref) == 1)
        return 1;
      return 0;
    }
  }
  off_m = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_m, type_ref);
  off_a = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_a, type_ref);
  off_b = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_b, type_ref);
  if (off_m < 0 || off_a < 0 || off_b < 0)
    return 0;
  is_f32 = glue_vector_elem_is_f32_c(arena, type_ref);
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    feats = glue_simd_emit_cpu_features_c();
    if (feats == 0)
      feats = xlang_target_cpu_detect_host();
    if (simd_enc_try_hw_vector_select_rbp(elf_ctx, off_m, off_a, off_b, stack_slot_off, lanes, is_f32, ta, feats) == 0)
      return 1;
  }
  /* Lane-scalar fallback still requires IDENT args (expr refs, not temps). */
  if (pipeline_expr_kind_ord_at(arena, arg_m) != 3 || pipeline_expr_kind_ord_at(arena, arg_a) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg_b) != 3)
    return 0;
  if (glue_emit_vector_select_lane_scalar_elf_c(arena, elf_ctx, arg_m, arg_a, arg_b, stack_slot_off, type_ref, ctx,
                                                ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena,
                                                     void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t arg0;
  int32_t arg1;
  int32_t arg2;
  int32_t lanes;
  int32_t esz;
  int32_t off_a;
  int32_t off_b;
  int32_t off_c;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.fma is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49);
  if (is_method) {
    if (pipeline_expr_method_call_num_args_at(arena, call_ref) != 3)
      return 0;
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 3)
      return 0;
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
  }
  if (clen <= 0 || glue_callee_is_vec4f_fma3_c(cname, clen) == 0)
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (lanes != 4 || esz != 4 || glue_vector_elem_is_f32_c(arena, type_ref) == 0)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg0 <= 0 || arg1 <= 0 || arg2 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3 || pipeline_expr_kind_ord_at(arena, arg1) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg2) != 3)
    return 0;
  off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, arg1);
  off_c = glue_asm_local_var_stack_off_scoped(arena, ctx, arg2);
  if (off_a < 0 || off_b < 0 || off_c < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (hw_env && hw_env[0] == '0')
    return 0;
  feats = glue_simd_emit_cpu_features_c();
  if (feats == 0)
    feats = xlang_target_cpu_detect_host();
  if (simd_enc_try_hw_vector_fma_rbp(elf_ctx, off_a, off_b, off_c, stack_slot_off, lanes, esz, ta, feats) == 0)
    return 1;
  return 0;
}
