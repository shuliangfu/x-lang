/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t glue_emit_vector_operand_lane_elf_c(void *arena,
                                                   void *elf_ctx, int32_t expr_ref,
                                                   int32_t lane, int32_t esz, void *ctx,
                                                   int32_t ta);

/** 向量 VAR 第 lane 分量的 fp 负偏移；失败 -1。 */
int32_t glue_vector_var_lane_stack_off_elf_c(void *arena, void *ctx,
                                                     int32_t var_expr_ref, int32_t lane, int32_t esz,
                                                     int32_t ta) {
  int32_t off;
  if (!arena || !ctx || var_expr_ref <= 0 || lane < 0 || esz <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return -1;
  off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
  if (off < 0)
    return -1;
  /* AAPCS64 positive [x29,#off] ≡ INDEX ta==1; x86 rbp grows down. */
  if (ta == 1)
    return off + lane * esz;
  return off - lane * esz;
}

/**
 * 7.3：向量逐 lane binop 尝试 VAR 快速路径装操作数；0=就绪，-1=错，-2=需 push slow。
 * 交换律（add/mul/and/or/xor）：左 rax、右 rbx；sub：左 rbx、右 rax；div/shift：左 rax、右 rbx。
 */
int32_t glue_try_vector_lane_binop_operands_elf_c(void *arena,
                                                            void *elf_ctx,
                                                            int32_t binop_ko, int32_t left_ref, int32_t right_ref,
                                                            int32_t lane, int32_t esz, void *ctx,
                                                            int32_t ta) {
  int32_t loff;
  int32_t roff;
  int32_t comm;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  loff = glue_vector_var_lane_stack_off_elf_c(arena, ctx, left_ref, lane, esz, ta);
  roff = glue_vector_var_lane_stack_off_elf_c(arena, ctx, right_ref, lane, esz, ta);
  comm = (binop_ko == 4 || binop_ko == 6 || binop_ko == 11 || binop_ko == 12 || binop_ko == 13) ? 1 : 0;
  if (comm) {
    if (loff >= 0 && roff >= 0) {
      if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, loff, esz, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, roff, esz, ta) != 0)
        return -1;
      return 0;
    }
    if (loff >= 0) {
      if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, right_ref, lane, esz, ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, loff, esz, ta) != 0)
        return -1;
      return 0;
    }
    if (roff >= 0) {
      if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, left_ref, lane, esz, ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, roff, esz, ta) != 0)
        return -1;
      return 0;
    }
    return -2;
  }
  if (binop_ko == 5) {
    if (loff >= 0 && roff >= 0) {
      if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, loff, esz, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, roff, esz, ta) != 0)
        return -1;
      return 0;
    }
    if (loff >= 0) {
      if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, loff, esz, ta) != 0)
        return -1;
      if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, right_ref, lane, esz, ctx, ta) != 0)
        return -1;
      return 0;
    }
    if (roff >= 0) {
      if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, left_ref, lane, esz, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, roff, esz, ta) != 0)
        return -1;
      return 0;
    }
    return -2;
  }
  /** div/mod/shl/shr：被除数/左 value 在 rax，除数/count 在 rbx。 */
  if (loff >= 0 && roff >= 0) {
    if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, loff, esz, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, roff, esz, ta) != 0)
      return -1;
    return 0;
  }
  if (loff >= 0) {
    if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, loff, esz, ta) != 0)
      return -1;
    if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, right_ref, lane, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, loff, esz, ta) != 0)
      return -1;
    return 0;
  }
  if (roff >= 0) {
    if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, left_ref, lane, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_lane_to_rbx_arch(elf_ctx, roff, esz, ta) != 0)
      return -1;
    return 0;
  }
  return -2;
}

/** 向量 lane 标量 binop 在 rax/rbx 就绪后发射 ALU（与 glue_emit_vector_lane_scalar_binop 栈序一致）。 */
int32_t glue_apply_vector_lane_scalar_binop_elf_c(void *elf_ctx, int32_t binop_ko,
                                                          void *ctx, int32_t ta) {
  switch (binop_ko) {
  case 4:
    return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
  case 5:
    return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
  case 6:
    return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
  case 7:
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  case 8:
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  case 9:
  case 10: {
    int32_t is_shr = (binop_ko == 10) ? 1 : 0;
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    return is_shr ? backend_enc_shr_cl_eax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  }
  case 11:
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  case 12:
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  case 13:
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  default:
    return -1;
  }
}

/** 向量某一 lane 的标量 binop（left/right 各取 lane 分量，结果在 rax）。 */
int32_t glue_emit_vector_lane_scalar_binop_elf_c(void *arena,
                                                         void *elf_ctx, int32_t binop_ko,
                                                         int32_t left_ref, int32_t right_ref, int32_t lane,
                                                         int32_t esz, void *ctx, int32_t ta) {
  int32_t vr;
  int32_t is_f32 = 0;
  int32_t tr;
  if (!glue_is_vector_lane_scalar_binop_ko(binop_ko))
    return -1;
  /* Vec4f/f32x4 lanes: IEEE f32 addss, not integer ADD of the bits. */
  if (arena && left_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr <= 0 && ctx && pipeline_expr_kind_ord_at(arena, left_ref) == 3)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
    is_f32 = glue_vector_elem_is_f32_c(arena, tr);
  }
  vr = glue_try_vector_lane_binop_operands_elf_c(arena, elf_ctx, binop_ko, left_ref, right_ref, lane, esz, ctx, ta);
  if (vr == 0) {
    if (is_f32 && binop_ko == 4)
      return backend_enc_addss_rax_rbx_arch(elf_ctx, ta);
    if (is_f32 && binop_ko == 5)
      return backend_enc_subss_rbx_rax_arch(elf_ctx, ta);
    if (is_f32 && binop_ko == 6)
      return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
    if (is_f32 && binop_ko == 7)
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    return glue_apply_vector_lane_scalar_binop_elf_c(elf_ctx, binop_ko, ctx, ta);
  }
  if (vr == -1)
    return -1;
  if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, left_ref, lane, esz, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, right_ref, lane, esz, ctx, ta) != 0)
    return -1;
  switch (binop_ko) {
  case 4:
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (is_f32)
      return backend_enc_addss_rax_rbx_arch(elf_ctx, ta);
    return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
  case 5:
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (is_f32)
      return backend_enc_subss_rbx_rax_arch(elf_ctx, ta);
    return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
  case 6:
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (is_f32)
      return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
    return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
  case 7:
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* PLATFORM: SHARED — f32 /0 is IEEE Inf/NaN; skip integer #DE guard. */
    if (!is_f32) {
      if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (is_f32)
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  case 8:
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  case 9:
  case 10: {
    int32_t is_shr = (binop_ko == 10) ? 1 : 0;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    return is_shr ? backend_enc_shr_cl_eax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  }
  case 11:
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  case 12:
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  case 13:
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  default:
    return -1;
  }
}

/** 取向量操作数 expr 的第 lane 个标量分量到 rax（VAR / ARRAY_LIT / 嵌套 binop / 其它标量 expr）。 */
int32_t glue_emit_vector_operand_lane_elf_c(void *arena,
                                                   void *elf_ctx, int32_t expr_ref,
                                                   int32_t lane, int32_t esz, void *ctx,
                                                   int32_t ta) {
  int32_t ko;
  int32_t off;
  int32_t elem_ref;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0 || lane < 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3) {
    off = glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref);
    if (off < 0)
      return -1;
    /* ta==1 AAPCS64: positive [x29,#off] ≡ INDEX; ta==0 SysV rbp grows down. */
    if (ta == 1)
      return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off + lane * esz, esz, ta);
    return backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, off - lane * esz, esz, ta);
  }
  if (ko == 46) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, lane);
    if (elem_ref == 0)
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta);
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
  }
  if (glue_is_vector_lane_scalar_binop_ko(ko))
    return glue_emit_vector_lane_scalar_binop_elf_c(arena, elf_ctx, ko,
                                                    pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                                    pipeline_expr_binop_right_ref_at(arena, expr_ref), lane, esz, ctx,
                                                    ta);
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
}

/** let dst: i32xN = src_var：逐 lane 拷贝向量局部（按值栈槽）。 */
int32_t pipeline_asm_emit_vector_var_copy_elf_c(void *arena,
                                                       void *elf_ctx, int32_t src_expr_ref,
                                                       void *ctx, int32_t ta, int32_t dst_off,
                                                       int32_t type_ref) {
  int32_t lanes;
  int32_t esz;
  int32_t src_off;
  int32_t li;
  if (!arena || !elf_ctx || !ctx || src_expr_ref <= 0)
    return -1;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, src_expr_ref);
  if (src_off < 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, dst_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  for (li = 0; li < lanes; li++) {
    if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, ta == 1 ? src_off + li * esz : src_off - li * esz, esz, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta) != 0)
      return -1;
  }
  return 0;
}

/** SIMD-S3：读取 emit 时 CPU feature（dep_pipe 优先，回落 driver pending）。 */
uint32_t glue_simd_emit_cpu_features_c(void) {
  void *p;
  int32_t feats;
  p = pipeline_asm_emit_dep_pipe_c();
  if (p) {
    /* LP64 offsetof PipelineDepCtx.target_cpu_features */
    feats = *(int32_t *)((uint8_t *)p + 8389668);
    if (feats != 0)
      return (uint32_t)feats;
  }
  return driver_get_pending_target_cpu_features();
}

/** SIMD-S3：local VAR+VAR 向量 add/sub/mul 尝试硬件指令（失败则回退 lane-scalar）。 */
int32_t glue_try_hw_vector_add_binop_elf_c(void *arena,
                                                  void *elf_ctx, int32_t binop_ko,
                                                  int32_t left_ref, int32_t right_ref, int32_t dst_off,
                                                  int32_t type_ref, void *ctx, int32_t ta) {
  int32_t lanes;
  int32_t esz;
  int32_t off_a;
  int32_t off_b;
  uint32_t feats;
  const char *hw_env;

  if ((binop_ko != 4 && binop_ko != 5 && binop_ko != 6) || pipeline_expr_kind_ord_at(arena, left_ref) != 3 ||
      pipeline_expr_kind_ord_at(arena, right_ref) != 3)
    return -1;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (hw_env && hw_env[0] == '0')
    return -1;
  off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, left_ref);
  off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, right_ref);
  if (off_a < 0 || off_b < 0)
    return -1;
  feats = glue_simd_emit_cpu_features_c();
  if (feats == 0)
    feats = xlang_target_cpu_detect_host();
  if (glue_vector_elem_is_f32_c(arena, type_ref)) {
    if (binop_ko == 6)
      return simd_enc_try_hw_vector_fmul_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
    if (binop_ko != 4)
      return -1;
    return simd_enc_try_hw_vector_fadd_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
  }
  if (binop_ko == 5)
    return simd_enc_try_hw_vector_isub_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
  if (binop_ko == 6)
    return simd_enc_try_hw_vector_imul_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
  return simd_enc_try_hw_vector_iadd_rbp(elf_ctx, off_a, off_b, dst_off, lanes, esz, ta, feats);
}

/**
 * CALL callee 函数名：裸 VAR 或 import 限定的 FIELD_ACCESS（如 simd.vec4f_shuffle）。
 * 返回名字节长度；0 表示 callee 形态不支持。
 */
int32_t glue_call_callee_func_name_into_c(void *arena, int32_t callee_ref, uint8_t *out,
                                                 int32_t out_cap) {
  int32_t ko;
  int32_t clen;
  if (!arena || callee_ref <= 0 || !out || out_cap < 2)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, callee_ref);
  if (ko == 3) {
    clen = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0 || clen >= out_cap)
      return 0;
    pipeline_expr_var_name_into(arena, callee_ref, out);
    return clen;
  }
  if (ko == 44) {
    clen = pipeline_expr_field_access_name_len(arena, callee_ref);
    if (clen <= 0 || clen >= out_cap)
      return 0;
    pipeline_expr_field_access_name_into(arena, callee_ref, out);
    return clen;
  }
  return 0;
}

/** comptime shuffle 掩码元素是否为整数字面量（EXPR_LIT ord==0）。 */
int32_t glue_shuffle_mask_elem_is_int_lit_c(void *arena, int32_t elem_ref) {
  int32_t ko;
  if (elem_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, elem_ref);
  return ko == 0 ? 1 : 0;
}

/**
 * comptime shuffle 掩码 → x86 pshufd imm8（每 128-bit 半幅 lane 索引 0..3）。
 * Vec8i 要求 mask[i+4]==mask[i]+4（两半对称 shuffle，单条 vpshufd）。
 * 成功写 *out_imm；失败返回 -1。
 */
int32_t glue_shuffle_pshufd_imm8_from_mask_c(void *arena, int32_t mask_ref, int32_t lanes,
                                                    int32_t *out_imm) {
  int32_t ne;
  int32_t i;
  int32_t m0;
  int32_t m1;
  int32_t m2;
  int32_t m3;
  int32_t elem_ref;
  int32_t lo;
  int32_t hi;

  if (!arena || !out_imm || mask_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, mask_ref) != 46)
    return -1;
  ne = pipeline_expr_array_lit_num_elems_at(arena, mask_ref);
  if (ne != lanes || (lanes != 4 && lanes != 8))
    return -1;
  for (i = 0; i < 4; i++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, mask_ref, i);
    if (!glue_shuffle_mask_elem_is_int_lit_c(arena, elem_ref))
      return -1;
    lo = pipeline_expr_int_val_at(arena, elem_ref);
    if (lo < 0 || lo > 3)
      return -1;
    if (i == 0)
      m0 = lo;
    else if (i == 1)
      m1 = lo;
    else if (i == 2)
      m2 = lo;
    else
      m3 = lo;
  }
  if (lanes == 8) {
    for (i = 0; i < 4; i++) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, mask_ref, i + 4);
      if (!glue_shuffle_mask_elem_is_int_lit_c(arena, elem_ref))
        return -1;
      hi = pipeline_expr_int_val_at(arena, elem_ref);
      lo = pipeline_expr_int_val_at(arena, pipeline_expr_array_lit_elem_ref(arena, mask_ref, i));
      if (hi != lo + 4)
        return -1;
    }
  }
  *out_imm = (m3 << 6) | (m2 << 4) | (m1 << 2) | m0;
  return 0;
}

/** lane-scalar shuffle 回退：按 comptime mask 逐 lane 拷贝（无 pshufd 时）。 */
int32_t glue_emit_vector_shuffle_lane_scalar_elf_c(void *arena,
                                                          void *elf_ctx,
                                                          int32_t src_ref, int32_t mask_ref, int32_t dst_off,
                                                          int32_t type_ref, void *ctx, int32_t ta) {
  int32_t lanes;
  int32_t esz;
  int32_t src_off;
  int32_t li;
  int32_t elem_ref;
  int32_t src_lane;

  if (!arena || !elf_ctx || !ctx || src_ref <= 0 || mask_ref <= 0)
    return -1;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, src_ref) != 3)
    return -1;
  src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, src_ref);
  if (src_off < 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, dst_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  for (li = 0; li < lanes; li++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, mask_ref, li);
    if (!glue_shuffle_mask_elem_is_int_lit_c(arena, elem_ref))
      return -1;
    src_lane = pipeline_expr_int_val_at(arena, elem_ref);
    if (src_lane < 0 || src_lane >= lanes)
      return -1;
    if (backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, src_off - src_lane * esz, esz, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta) != 0)
      return -1;
  }
  return 0;
}

/* Same-TU parent-block face (def later). Peel walks ancestors. */
extern int32_t pipeline_block_parent_block_ref_at(void *a, int32_t block_ref);

/**
 * Peel shuffle mask to ARRAY_LIT (46).
 * Accepts a direct array lit, or a named `let m = […]; simd.shuffle(v, m)` VAR
 * in the current scope or an ancestor block (while/for/if body → function lets).
 * G.7 complete: same-block peel was half; STD-061 heat-loop keeps masks
 * outside the while, so parent walk is required for pshufd inline.
 * Shadow: a same-name let that is not ARRAY_LIT stops the walk.
 * PLATFORM: SHARED freestanding emit.
 * @return array-lit expr ref; 0 if not peelable
 */
int32_t glue_peel_comptime_array_lit_mask_c(void *arena, void *ctx, int32_t mask_ref) {
  int32_t ko;
  int32_t br;
  int32_t nlet;
  int32_t li;
  int32_t vlen;
  int32_t llen;
  int32_t kk;
  int32_t is_match;
  int32_t init_ref;
  int32_t depth;
  uint8_t vbuf[256];
  uint8_t lb[256];

  if (!arena || mask_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, mask_ref);
  if (ko == 46)
    return mask_ref;
  if (ko != 3 || !ctx)
    return 0;
  br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
  if (br <= 0)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, mask_ref);
  if (vlen <= 0 || vlen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, mask_ref, vbuf);
  depth = 0;
  while (br > 0 && depth < 128) {
    nlet = ast_ast_block_num_lets(arena, br);
    li = 0;
    while (li < nlet) {
      llen = pipeline_block_let_name_len(arena, br, li);
      if (llen == vlen) {
        is_match = 1;
        pipeline_block_let_name_copy64(arena, br, li, lb);
        kk = 0;
        while (kk < vlen) {
          if (lb[kk] != vbuf[kk])
            is_match = 0;
          kk++;
        }
        if (is_match) {
          init_ref = pipeline_block_let_init_ref(arena, br, li);
          if (init_ref > 0 && pipeline_expr_kind_ord_at(arena, init_ref) == 46)
            return init_ref;
          return 0;
        }
      }
      li++;
    }
    br = pipeline_block_parent_block_ref_at(arena, br);
    depth++;
  }
  return 0;
}

/**
 * let r = vec4f_shuffle / vec8i_shuffle / simd_shuffle / @shuffle / simd.shuffle：
 * comptime pshufd 内联。
 * G.7 complete: CALL(48) and METHOD_CALL(49) import `simd.shuffle`;
 * bare name "shuffle"; peel named array-lit mask lets.
 * 返回 1=已内联，0=未匹配，-1=错误。
 * PLATFORM: SHARED · LINUX|x86 pshufd · MACOS|ARM64 lane-scalar fallback.
 */
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

/** lane-scalar select 回退：mask lane != 0 取 a，否则取 b（支持 i32 / f32 0/1 掩码）。 */
int32_t glue_emit_vector_select_lane_scalar_elf_c(void *arena,
                                                         void *elf_ctx,
                                                         int32_t mask_ref, int32_t a_ref, int32_t b_ref,
                                                         int32_t dst_off, int32_t type_ref,
                                                         void *ctx, int32_t ta) {
  int32_t lanes;
  int32_t esz;
  int32_t li;
  uint8_t pick_b_lbl[128];
  uint8_t lane_done_lbl[128];
  int32_t pick_b_len;
  int32_t done_len;

  if (!arena || !elf_ctx || !ctx || mask_ref <= 0 || a_ref <= 0 || b_ref <= 0)
    return -1;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, mask_ref) != 3 || pipeline_expr_kind_ord_at(arena, a_ref) != 3 ||
      pipeline_expr_kind_ord_at(arena, b_ref) != 3)
    return -1;
  for (li = 0; li < lanes; li++) {
    pick_b_len = pipeline_asm_emit_next_label_c(ctx, pick_b_lbl, 64);
    done_len = pipeline_asm_emit_next_label_c(ctx, lane_done_lbl, 64);
    if (pick_b_len <= 0 || done_len <= 0)
      return -1;
    if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, mask_ref, li, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jz_arch(elf_ctx, pick_b_lbl, pick_b_len, ta) != 0)
      return -1;
    if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, a_ref, li, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_jmp_arch(elf_ctx, lane_done_lbl, done_len, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, pick_b_lbl, pick_b_len, 0, ta) != 0)
      return -1;
    if (glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, b_ref, li, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, lane_done_lbl, done_len, 0, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, dst_off, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * splat / simd_splat / vec8i_splat / vec4f_splat callee name.
 * PLATFORM: SHARED — G.7 single name table for splat inline + select compose.
 */
static int32_t glue_simd_callee_is_splat_c(const uint8_t *cname, int32_t clen) {
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

/**
 * If expr is CALL/METHOD splat(INT_LIT|BOOL_LIT), write the scalar to *out_imm.
 * @return 1 peelable comptime int splat; 0 otherwise (no emit).
 * PLATFORM: SHARED — select fold of select(splat(k), a, b).
 */
static int32_t glue_simd_expr_splat_int_imm_c(void *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  int32_t nargs;
  int32_t arg0;
  int32_t clen;
  int32_t callee_ref;
  uint8_t cname[256];

  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 49) {
    nargs = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    clen = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (clen <= 0 || clen >= 64 || nargs != 1)
      return 0;
    pipeline_expr_method_call_name_into(arena, expr_ref, cname);
    if (!glue_simd_callee_is_splat_c(cname, clen))
      return 0;
    arg0 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
  } else if (ko == 48) {
    nargs = pipeline_expr_call_num_args_at(arena, expr_ref);
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0 || nargs != 1)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0 || !glue_simd_callee_is_splat_c(cname, clen))
      return 0;
    arg0 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
  } else {
    return 0;
  }
  if (arg0 <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, arg0);
  if (ko != 0 && ko != 2)
    return 0;
  if (out_imm)
    *out_imm = pipeline_expr_int_val_at(arena, arg0);
  return 1;
}

/**
 * Fill a vector stack slot with a 32-bit pattern already decided (i32 splat
 * or f32 IEEE bits). Reuses lea+store-lane (ARRAY_LIT polarity).
 * PLATFORM: SHARED · LINUX|x86 / MACOS|ARM64 via backend_enc_*.
 */
static int32_t glue_simd_emit_imm_fill_slot_c(void *elf_ctx, int32_t stack_slot_off, int32_t lanes,
                                            int32_t esz, int32_t ta, int32_t imm_bits) {
  int32_t li;
  int32_t store_sz;

  if (!elf_ctx || stack_slot_off < 0 || lanes <= 0)
    return -1;
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
    store_sz = 4;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, imm_bits, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  for (li = 0; li < lanes; li++) {
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * store_sz, store_sz, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * Bump AsmFuncCtx.next_offset@4 and return a new vector-sized rbp slot.
 * Frame already reserves >=512B call-spill scratch (compute_frame_size).
 * PLATFORM: SHARED — uses asm_local_slot_reg_offset (host polarity).
 */
static int32_t glue_simd_alloc_vector_temp_slot_c(void *arena, void *ctx, int32_t type_ref) {
  int32_t cur;
  int32_t inout;
  int32_t slot;

  if (!arena || !ctx || type_ref <= 0)
    return -1;
  glue_align_next_offset(ctx);
  cur = *(int32_t *)((uint8_t *)ctx + 4);
  inout = cur;
  slot = asm_local_slot_reg_offset(arena, type_ref, cur, &inout);
  *(int32_t *)((uint8_t *)ctx + 4) = inout;
  if (slot < 0)
    return -1;
  return slot;
}

/**
 * Inline simd.splat / splat(const) into a stack slot.
 * FLOAT_LIT + dest esz==4 packs IEEE f64 bits to f32 (ARRAY_LIT force_esz==4).
 * G.7 无才新增: sibling of try_inline_select/shuffle (no second fill path).
 * @return 1 inlined; 0 no match; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold / MACOS L2 same emit.
 */
int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t arg0;
  int32_t lanes;
  int32_t esz;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;
  int32_t imm;
  int32_t store_sz;
  int32_t li;

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
  if (!glue_simd_callee_is_splat_c(cname, clen))
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (is_method)
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
  else
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
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
    /*
     * FLOAT_LIT splat: dest esz==4 is f32 lanes (Vec4f / f32x4).
     * Unstamped 1.0 is IEEE f64 (0x3FF00000_00000000); store-4 of that
     * low half is 0.0f — same ARRAY_LIT residual typeck already stamped.
     * G.7 complete: reuse force_esz==4 pack + imm_fill (no second store path).
     * PLATFORM: SHARED freestanding emit · LINUX gold.
     */
    if (esz == 4) {
      imm = glue_ieee_f64_bits_to_f32_bits(pipeline_expr_float_bits_lo_at(arena, arg0),
                                          pipeline_expr_float_bits_hi_at(arena, arg0));
      if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
        return -1;
      return 1;
    }
    /* FLOAT_LIT: emit bits to rax, then same lane stores. */
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

/**
 * Resolve a select operand to a rbp slot: IDENT local, or nested splat(const)
 * materialized into a frame temp (512B scratch already reserved).
 * @return slot off >= 0; -1 not resolvable (no emit on IDENT miss; splat may emit)
 * PLATFORM: SHARED.
 */
static int32_t glue_simd_select_arg_stack_off_c(void *arena, void *elf_ctx, void *ctx, int32_t ta,
                                               int32_t arg_ref, int32_t type_ref) {
  int32_t ko;
  int32_t off;
  int32_t tmp;
  int32_t rc;

  if (!arena || !ctx || arg_ref <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arg_ref);
  if (ko == 3)
    return glue_asm_local_var_stack_off_scoped(arena, ctx, arg_ref);
  if (ko != 48 && ko != 49)
    return -1;
  tmp = glue_simd_alloc_vector_temp_slot_c(arena, ctx, type_ref);
  if (tmp < 0)
    return -1;
  rc = pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, arg_ref, ctx, ta, tmp, type_ref);
  if (rc == 1)
    return tmp;
  return -1;
}

/**
 * let r = vec8i_select / vec4f_select / simd_select / @select / simd.select：
 * mask?a:b 内联。
 * G.7 complete: CALL(48) and METHOD_CALL(49); bare name "select".
 * G.7 complete: nested splat(const) args (heat-loop select(splat(1), r8, splat(0))).
 * 返回 1=已内联，0=未匹配，-1=错误。
 * PLATFORM: SHARED · LINUX|x86 pcmpgtd/cmpgtps · MACOS|ARM64 cmgt/bsl fallback.
 */
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

int32_t pipeline_asm_emit_vector_binop_let_init_elf_c(void *arena,
                                                             void *elf_ctx,
                                                             int32_t init_ref, void *ctx,
                                                             int32_t ta, int32_t dst_off, int32_t type_ref) {
  int32_t ko;
  int32_t lanes;
  int32_t esz;
  int32_t li;
  int32_t left_ref;
  int32_t right_ref;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (!glue_is_vector_lane_scalar_binop_ko(ko))
    return -1;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  left_ref = pipeline_expr_binop_left_ref_at(arena, init_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, init_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  if (glue_try_hw_vector_add_binop_elf_c(arena, elf_ctx, ko, left_ref, right_ref, dst_off, type_ref, ctx, ta) == 0)
    return 0;
  for (li = 0; li < lanes; li++) {
    /** 7.3：lane binop 后 lea dst→rbx 再 st，免 push/pop 保存基址。 */
    if (glue_emit_vector_lane_scalar_binop_elf_c(arena, elf_ctx, ko, left_ref, right_ref, li, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, dst_off, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta) != 0)
      return -1;
  }
  return 0;
}

/* glue_module_func_index_by_name_c moved to leftover-PE emit_as callee
 * unique OR after truncated-cmp close (file-scope !FROM_X || WIN).
 * Leaving the body here would dual-def on !FROM_X. */

/**
 * 读取函数体单一 return 的操作数 ref（显式 return 或 final_expr）；失败 0。
 */
/* wave136 Cap residual for fold_primitives pure leave: non-face. */
int32_t glue_fold_func_return_operand_ref_c(void *arena, void *mod,
                                                   int32_t func_idx) {
  int32_t body_ref;
  int32_t fin;
  int32_t nes;
  int32_t found;
  int32_t op_ref;
  int32_t ei;
  int32_t er;
  int32_t op_e;
  if (!arena || !mod || func_idx < 0)
    return 0;
  body_ref = pipeline_module_func_body_ref_at(mod, func_idx);
  if (body_ref <= 0)
    return 0;
  fin = pipeline_asm_block_final_expr_ref_at(arena, body_ref);
  if (fin != 0) {
    if (pipeline_expr_kind_ord_at(arena, fin) == 41) {
      op_e = pipeline_expr_unary_operand_ref_at(arena, fin);
      if (op_e != 0)
        return op_e;
    }
    return fin;
  }
  nes = ast_ast_block_num_expr_stmts(arena, body_ref);
  found = 0;
  op_ref = 0;
  for (ei = 0; ei < nes; ei++) {
    er = ast_ast_block_expr_stmt_ref(arena, body_ref, ei);
    if (er > 0 && pipeline_expr_kind_ord_at(arena, er) == 41) {
      op_e = pipeline_expr_unary_operand_ref_at(arena, er);
      if (op_e != 0) {
        found = found + 1;
        op_ref = op_e;
      }
    }
  }
  return found == 1 ? op_ref : 0;
}

/**
 * expr 是否为 func 第 param_ix 形参同名 VAR（向量 binop 内联 fold）。
 */
/* wave136 Cap residual for fold_primitives pure leave: non-face. */
int32_t glue_expr_is_func_param_at_c(void *arena, void *mod, int32_t func_idx,
                                            int32_t expr_ref, int32_t param_ix) {
  /* Cap 4.2.8: param_name_copy32 memset/memcpy 256 into dst. */
  uint8_t pbuf[256];
  uint8_t vbuf[256];
  int32_t plen;
  int32_t vlen;
  int32_t k;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  plen = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (plen <= 0 || plen != vlen)
    return 0;
  pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, pbuf);
  pipeline_expr_var_name_into(arena, expr_ref, vbuf);
  k = 0;
  while (k < plen) {
    if (pbuf[k] != vbuf[k])
      return 0;
    k = k + 1;
  }
  return 1;
}

/**
 * PLATFORM: SHARED — evaluate pure 1-param scalar callee at a known arg const.
 * Matches:
 *   return p0
 *   return p0 binop lit | lit binop p0  (ko 4..8)
 *   return NEG/BITNOT/LOGNOT p0
 * Authority for nested call-site CTFE (pre-emit): g(3) stamps so f(g(3),4) can fold.
 * Does not expand emit try_inline; consumers only read const_folded_*.
 */
int32_t glue_try_eval_pure_param0_scalar_func_c(void *arena, void *mod,
                                                      int32_t func_idx, int32_t arg_val, int32_t *out) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t uop;
  int32_t lit_val;
  int32_t ret_ty;
  int32_t left_p0;
  int32_t right_p0;
  int32_t lit_ko;
  if (!out || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 1)
    return 0;
  ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  if (ret_ty > 0 &&
      (asm_type_is_simd_vector_spelling(arena, ret_ty) != 0 || asm_type_is_simd_vector(arena, ret_ty) != 0))
    return 0;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  /* Identity: return p0 */
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, ret_ref, 0) != 0) {
    *out = arg_val;
    return 1;
  }
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  /* Unary: -p0 / ~p0 / !p0 (EXPR_NEG=22, BITNOT=23, LOGNOT=24 in product ExprKind). */
  if (ko == (int32_t)ast_ExprKind_EXPR_NEG || ko == (int32_t)ast_ExprKind_EXPR_BITNOT ||
      ko == (int32_t)ast_ExprKind_EXPR_LOGNOT) {
    uop = pipeline_expr_unary_operand_ref_at(arena, ret_ref);
    if (uop <= 0 || glue_expr_is_func_param_at_c(arena, mod, func_idx, uop, 0) == 0)
      return 0;
    if (ko == (int32_t)ast_ExprKind_EXPR_NEG)
      *out = (int32_t)(-(int64_t)arg_val);
    else if (ko == (int32_t)ast_ExprKind_EXPR_BITNOT)
      *out = (int32_t)(~(int64_t)arg_val);
    else
      *out = arg_val ? 0 : 1;
    return 1;
  }
  /* p0 binop lit | lit binop p0 (scalar add..mod only; same domain as 2-arg path). */
  if (ko < 4 || ko > 8)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (al <= 0 || ar <= 0)
    return 0;
  left_p0 = glue_expr_is_func_param_at_c(arena, mod, func_idx, al, 0);
  right_p0 = glue_expr_is_func_param_at_c(arena, mod, func_idx, ar, 0);
  if (left_p0 != 0 && right_p0 == 0) {
    if (pipeline_expr_const_folded_valid_at(arena, ar) != 0)
      lit_val = pipeline_expr_const_folded_val_at(arena, ar);
    else {
      lit_ko = pipeline_expr_kind_ord_at(arena, ar);
      if (lit_ko != 0 && lit_ko != 2)
        return 0;
      lit_val = (int32_t)pipeline_expr_int_val_at(arena, ar);
    }
    switch (ko) {
    case 4:
      *out = (int32_t)((int64_t)arg_val + (int64_t)lit_val);
      break;
    case 5:
      *out = (int32_t)((int64_t)arg_val - (int64_t)lit_val);
      break;
    case 6:
      *out = (int32_t)((int64_t)arg_val * (int64_t)lit_val);
      break;
    case 7:
      if (lit_val == 0)
        return 0;
      *out = (int32_t)((int64_t)arg_val / (int64_t)lit_val);
      break;
    case 8:
      if (lit_val == 0)
        return 0;
      *out = (int32_t)((int64_t)arg_val % (int64_t)lit_val);
      break;
    default:
      return 0;
    }
    return 1;
  }
  if (right_p0 != 0 && left_p0 == 0) {
    if (pipeline_expr_const_folded_valid_at(arena, al) != 0)
      lit_val = pipeline_expr_const_folded_val_at(arena, al);
    else {
      lit_ko = pipeline_expr_kind_ord_at(arena, al);
      if (lit_ko != 0 && lit_ko != 2)
        return 0;
      lit_val = (int32_t)pipeline_expr_int_val_at(arena, al);
    }
    switch (ko) {
    case 4:
      *out = (int32_t)((int64_t)lit_val + (int64_t)arg_val);
      break;
    case 5:
      *out = (int32_t)((int64_t)lit_val - (int64_t)arg_val);
      break;
    case 6:
      *out = (int32_t)((int64_t)lit_val * (int64_t)arg_val);
      break;
    case 7:
      if (arg_val == 0)
        return 0;
      *out = (int32_t)((int64_t)lit_val / (int64_t)arg_val);
      break;
    case 8:
      if (arg_val == 0)
        return 0;
      *out = (int32_t)((int64_t)lit_val % (int64_t)arg_val);
      break;
    default:
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * PLATFORM: SHARED — callee body is pure `return param0 binop param1` (2 scalar params).
 * Authority for WPO-S2 call-site CTFE (pre-emit). Writes *out_binop_ko (4=add..8=mod).
 * Mirrors glue_fold_func_returns_param01_scalar_binop (backend try_inline); kept here so
 * typeck fold does not depend on emit-layer symbols.
 */
int32_t glue_fold_func_returns_param01_scalar_binop_c(void *arena, void *mod,
                                                            int32_t func_idx, int32_t *out_binop_ko) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t ret_ty;
  if (!out_binop_ko || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 2)
    return 0;
  ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  if (ret_ty > 0 &&
      (asm_type_is_simd_vector_spelling(arena, ret_ty) != 0 || asm_type_is_simd_vector(arena, ret_ty) != 0))
    return 0;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  if (ko < 4 || ko > 8)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, al, 0) == 0)
    return 0;
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, ar, 1) == 0)
    return 0;
  *out_binop_ko = ko;
  return 1;
}

/**
 * PLATFORM: SHARED — callee body is pure `return param0[const_lane]` (1 param).
 * Authority for WPO-S2 vector lane call-site CTFE (pre-emit). Writes *out_lane.
 * Mirrors glue_fold_func_returns_param0_index_const (backend try_inline).
 */
int32_t glue_fold_func_returns_param0_index_const_c(void *arena, void *mod,
                                                          int32_t func_idx, int32_t *out_lane) {
  int32_t ret_ref;
  int32_t base_ref;
  int32_t idx_ref;
  int32_t lane;
  int32_t idx_ko;
  if (!out_lane || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 1)
    return 0;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  /* GLUE_EXPR_INDEX / EXPR_INDEX = 47 */
  if (pipeline_expr_kind_ord_at(arena, ret_ref) != 47)
    return 0;
  base_ref = pipeline_expr_index_base_ref(arena, ret_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, ret_ref);
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, base_ref, 0) == 0)
    return 0;
  /* Avoid glue_arena_expr_at_ref here (defined later); use public pipeline getters. */
  if (pipeline_expr_const_folded_valid_at(arena, idx_ref) != 0)
    lane = pipeline_expr_const_folded_val_at(arena, idx_ref);
  else {
    idx_ko = pipeline_expr_kind_ord_at(arena, idx_ref);
    if (idx_ko != 0 && idx_ko != 2) /* LIT / BOOL_LIT */
      return 0;
    lane = (int32_t)pipeline_expr_int_val_at(arena, idx_ref);
  }
  *out_lane = lane;
  return 1;
}

/**
 * PLATFORM: SHARED — callee body is pure `return param0 binop param1` for vector/SIMD shape.
 * Typeck CTFE authority (no dst type required). Allows EXPR_BINOP placeholder ko=51 as add.
 * Mirrors backend glue_fold_func_returns_param01_vector_binop without emit type_ref.
 */
int32_t glue_fold_func_returns_param01_vector_binop_ctfe_c(void *arena, void *mod,
                                                                 int32_t func_idx, int32_t *out_binop_ko) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t ret_ty;
  if (!out_binop_ko || !arena || !mod || func_idx < 0)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 2)
    return 0;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  /* Vector add often lands as placeholder 51; scalar add is 4. */
  if (ko == 51)
    ko = 4;
  else if (!glue_is_vector_lane_scalar_binop_ko(ko))
    return 0;
  /* Prefer SIMD return type when present; still match pure p0 binop p1 when typeck left i32. */
  ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  if (ret_ty > 0) {
    if (asm_type_is_simd_vector_spelling(arena, ret_ty) == 0 && asm_type_is_simd_vector(arena, ret_ty) == 0) {
      /* Body is already vector-shaped binop; allow default i32 return slot (typeck residual). */
      if (ko < 4 || ko > 8)
        return 0;
    }
  }
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, al, 0) == 0)
    return 0;
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, ar, 1) == 0)
    return 0;
  *out_binop_ko = ko;
  return 1;
}

/**
 * PLATFORM: SHARED — ARRAY_LIT[lane] is an i32-like constant (lit or already folded).
 * Typeck CTFE helper; mirrors glue_try_array_lit_lane_const_i32 without emit-layer link.
 */
int32_t glue_try_array_lit_lane_const_i32_c(void *arena, int32_t arr_ref, int32_t lane,
                                                  int32_t *out) {
  int32_t ne;
  int32_t elem_ref;
  int32_t eko;
  if (!arena || arr_ref <= 0 || !out || lane < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, arr_ref) != (int32_t)ast_ExprKind_EXPR_ARRAY_LIT)
    return 0;
  ne = pipeline_expr_array_lit_num_elems_at(arena, arr_ref);
  if (lane >= ne)
    return 0;
  elem_ref = pipeline_expr_array_lit_elem_ref(arena, arr_ref, lane);
  if (elem_ref <= 0)
    return 0;
  if (pipeline_expr_const_folded_valid_at(arena, elem_ref) != 0) {
    *out = pipeline_expr_const_folded_val_at(arena, elem_ref);
    return 1;
  }
  eko = pipeline_expr_kind_ord_at(arena, elem_ref);
  if (eko == 0 || eko == 2) { /* LIT / BOOL_LIT */
    *out = (int32_t)pipeline_expr_int_val_at(arena, elem_ref);
    return 1;
  }
  return 0;
}

/**
 * 函数体是否为 `return param0 binop param1`（两形参、向量返回、binop 为逐 lane 标量运算）。
 * 成功写 *out_binop_ko；失败返回 0。
 */
int32_t glue_fold_func_returns_param01_vector_binop_dst_c(void *arena, void *mod,
                                                           int32_t func_idx, int32_t *out_binop_ko,
                                                           int32_t dst_vec_type_ref) {
  int32_t ret_ref;
  int32_t ko;
  int32_t al;
  int32_t ar;
  int32_t ret_ty;
  if (!out_binop_ko)
    return 0;
  if (pipeline_module_func_num_params_at(mod, func_idx) != 2)
    return 0;
  /** 模块 func 返回 type 常为默认 i32；以 let 目标向量类型为准。 */
  ret_ty = dst_vec_type_ref;
  if (ret_ty <= 0)
    ret_ty = pipeline_module_func_return_type_at(mod, func_idx);
  if (ret_ty <= 0 ||
      (asm_type_is_simd_vector_spelling(arena, ret_ty) == 0 && asm_type_is_simd_vector(arena, ret_ty) == 0))
    return 0;
  ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
  if (ret_ref <= 0)
    ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, ret_ref);
  /** 向量加法常为 EXPR_BINOP 占位序数 51，标量 add 为 4。 */
  if (ko != 4 && ko != 51 && !glue_is_vector_lane_scalar_binop_ko(ko))
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, al, 0) == 0)
    return 0;
  if (glue_expr_is_func_param_at_c(arena, mod, func_idx, ar, 1) == 0)
    return 0;
  *out_binop_ko = ko;
  return 1;
}

/** callee 是否为 Vec4f FMA 三参 intrinsic（vec4f_fma / vec4f_madd / simd_fma）。 */
int32_t glue_callee_is_vec4f_fma3_c(uint8_t *cname, int32_t clen) {
  if (!cname || clen <= 0)
    return 0;
  if (clen == 9 && memcmp(cname, "vec4f_fma", 9) == 0)
    return 1;
  if (clen == 10 && memcmp(cname, "vec4f_madd", 10) == 0)
    return 1;
  if (clen == 8 && memcmp(cname, "simd_fma", 8) == 0)
    return 1;
  /* METHOD import std.simd.fma — bare name after receiver. */
  if (clen == 3 && memcmp(cname, "fma", 3) == 0)
    return 1;
  return 0;
}

/**
 * let r = vec4f_fma(a, b, c) 内联：local VAR×3 时发射 vfmadd231ps（或 mulps+addps）。
 * 返回 1=已内联，0=未匹配，-1=错误。
 */
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

/**
 * let c = vec_fn(a, b) or c = a.add4(b): inline when callee is `return p0 binop p1`.
 * CALL=48 two extras; METHOD=49 UFCS one extra (receiver=p0, extra0=p1).
 * No add/sub/mul name table — body fold only. Returns 1 inlined, 0 no match, -1 error.
 * PLATFORM: SHARED — seed twin of runtime_pipeline_abi.x (Darwin try-heat / L4 sat).
 */
int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(void *arena,
                                                         void *elf_ctx, int32_t call_ref,
                                                         void *ctx, int32_t ta,
                                                         int32_t stack_slot_off, int32_t type_ref) {
  void *mod_ref;
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t fi;
  int32_t binop_ko;
  int32_t arg0;
  int32_t arg1;
  int32_t lanes;
  int32_t esz;
  int32_t li;
  int32_t is_method;
  int32_t ko;
  int32_t nargs;
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49);
  mod_ref = pipeline_asm_emit_module_ref_c();
  if (!mod_ref)
    mod_ref = *(void **)((uint8_t *)ctx + 16);
  if (!mod_ref)
    return 0;
  if (is_method) {
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
    if (nargs != 1)
      return 0;
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 2)
      return 0;
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
      return 0;
    clen = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0 || clen > 255)
      return 0;
    pipeline_expr_var_name_into(arena, callee_ref, cname);
  }
  fi = glue_module_func_index_by_name_c(mod_ref, cname, clen);
  if (fi < 0)
    return 0;
  if (glue_fold_func_returns_param01_vector_binop_dst_c(arena, mod_ref, fi, &binop_ko, type_ref) == 0)
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_base_ref_at(arena, call_ref);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
  }
  if (arg0 <= 0 || arg1 <= 0)
    return -1;
  if (binop_ko == 51)
    binop_ko = 4;
  for (li = 0; li < lanes; li++) {
    if (glue_emit_vector_lane_scalar_binop_elf_c(arena, elf_ctx, binop_ko, arg0, arg1, li, esz, ctx, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta) != 0)
      return -1;
  }
  return 1;
}

/**
 * let v: TYPE_VECTOR 初始化：ARRAY_LIT / VAR 拷贝 / 逐 lane binop / 两参向量 CALL 内联。
 * 0=已处理，-1=错误，-2=非向量 let init。
 */
/* wave145 pure Cap residual: static→extern. */
int32_t glue_emit_vector_type_let_init_elf_c(void *arena,
                                                    void *elf_ctx, int32_t init_ref,
                                                    void *ctx, int32_t ta, int32_t stack_slot_off,
                                                    int32_t type_ref) {
  int32_t ko;
  int32_t inl;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || !asm_type_is_simd_vector_spelling(arena, type_ref))
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 46)
    return pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 3)
    return pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
  if (glue_is_vector_lane_scalar_binop_ko(ko))
    return pipeline_asm_emit_vector_binop_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
  /* CALL=48 / METHOD_CALL=49 (import simd.shuffle/splat/select is METHOD). */
  if (ko == 48 || ko == 49) {
    inl = pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_select_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_shuffle_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_fma3_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_binop2_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
  }
  return -2;
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1115-1117 G.7: vector type/let helpers domain (3 fns) migrated from
 * pipeline_glue.c L2072-2134. These are SIMD vector type introspection and
 * let-init classification helpers — natural co-located with the SIMD emit
 * domain already in vector_simd.c. Static (non-extern): same-TU visibility
 * via #include order — vector_simd.c #include at L2218; all vector_simd.c
 * callsites follow. Glue.c L2205 callsite (pipeline_asm_let_init_stack_reserve_bytes)
 * precedes #include, so a fwd decl is kept at glue.c L2068.
 * PLATFORM: SHARED — pure type introspection, no arch dependency. */

/**
 * Extract lane count and element byte-width for a TYPE_VECTOR (SIMD) type.
 * Handles both builtin kinds (array_size field) and NAMED spellings
 * (i32x4/Vec8i/f32x4 via xlang_simd_vector_lanes_esz_from_spelling).
 *
 * Why: SIMD emit paths (load/store/binop/shuffle) need lanes×esz to compute
 * register widths and memory access sizes. Centralizing this here keeps the
 * spelling table lookup in one place.
 *
 * Contract: arena, out_lanes, out_esz must be non-NULL. Returns 0 on
 * success, -1 if type_ref is not a SIMD vector.
 *
 * PLATFORM: SHARED — pure type introspection. Arch-specific register
 * allocation happens in callers.
 */
/* glue_vector_type_lanes_esz_c: see wave148 accessor twin below */

/* glue_is_vector_lane_scalar_binop_ko: backend_try_inline authority (extern). */
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);

/**
 * Return 1 if a vector let-init can write directly to the type stack slot
 * (ARRAY_LIT=46 / VAR=3 / CALL=48 / METHOD_CALL=49 / per-lane scalar binop).
 * METHOD matches CALL: import simd.splat/shuffle/select and UFCS write the
 * vector home via try_inline or sret/dual-GP (same as emit_vector_type_let_init).
 *
 * Why: direct-slot writes skip extra ARRAY/STRUCT temp reserve in
 * pipeline_asm_let_init_stack_reserve_bytes. Sole consumer today.
 *
 * Contract: arena must be non-NULL, type_ref must be a SIMD vector,
 * init_ref > 0. Returns 0/1.
 *
 * PLATFORM: SHARED — pure classification, no arch dependency.
 */
/* wave145 pure Cap residual: static→extern. */
int32_t glue_vector_let_init_uses_direct_slot(void *arena, int32_t type_ref, int32_t init_ref) {
  int32_t ko;
  if (!asm_type_is_simd_vector_spelling(arena, type_ref) || init_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  /* CALL=48 METHOD_CALL=49 share the vector let-init direct-slot path. */
  if (ko == 46 || ko == 3 || ko == 48 || ko == 49)
    return 1;
  return glue_is_vector_lane_scalar_binop_ko(ko);
}


int32_t glue_vector_elem_is_f32_c(void *arena, int32_t type_ref) {
  int32_t tk;
  int32_t nlen;
  int32_t er;
  int32_t nt;
  int32_t etk;
  uint8_t nm[64];
  if (!arena || type_ref <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  if (tk == 8) {
    nlen = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nlen == 5 && memcmp(nm, "f32x4", 5) == 0)
      return 1;
    if (nlen == 5 && memcmp(nm, "Vec4f", 5) == 0)
      return 1;
    return 0;
  }
  if (tk != 13)
    return 0;
  er = pipeline_type_elem_ref_at(arena, type_ref);
  nt = pipeline_arena_num_types(arena);
  if (er <= 0 || er > nt)
    return 0;
  etk = pipeline_type_kind_ord_at(arena, er);
  return (etk == 14) ? 1 : 0;
}


int32_t glue_vector_type_lanes_esz_c(void *arena, int32_t type_ref, int32_t *out_lanes, int32_t *out_esz) {
  int32_t lanes;
  int32_t esz;
  int32_t elem_ref;
  int32_t tk;
  int32_t nlen;
  int32_t nt;
  int32_t arr_sz;
  int32_t spell_lanes = 0;
  int32_t spell_esz = 0;
  int32_t etk;
  uint8_t nm[64];
  if (!arena || !out_lanes || !out_esz)
    return -1;
  if (!asm_type_is_simd_vector_spelling(arena, type_ref))
    return -1;
  nt = pipeline_arena_num_types(arena);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  lanes = (arr_sz > 0) ? arr_sz : 4;
  if (tk == 8) {
    nlen = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nlen > 0 &&
        xlang_simd_vector_lanes_esz_from_spelling((const char *)nm, (size_t)nlen, &spell_lanes, &spell_esz) == 0) {
      *out_lanes = spell_lanes;
      *out_esz = spell_esz;
      return 0;
    }
    lanes = 4;
    if (nlen == 5 && nm[4] == 56)
      lanes = 8;
    if (nlen == 6 && nm[4] == 49 && nm[5] == 54)
      lanes = 16;
  }
  esz = 4;
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  if (elem_ref > 0 && elem_ref <= nt) {
    etk = pipeline_type_kind_ord_at(arena, elem_ref);
    if (etk == 2)
      esz = 1;
    else if (etk == 14)
      esz = 4;
    else if (etk == 8 || etk == 4 || etk == 5 || etk == 6)
      esz = 8;
  }
  *out_lanes = lanes;
  *out_esz = esz;
  return 0;
}

