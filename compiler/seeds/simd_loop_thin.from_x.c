/* seeds/simd_loop_thin.from_x.c
 * G-02f simd_loop L2 thin surface — isomorphic with src/asm/simd_loop_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(thin.x) + full seed rest (-DSHUX_L2_SIMD_LOOP_THIN_FROM_X) ld -r
 * Cold full seed: seeds/simd_loop.from_x.c (unchanged)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl are U)
 * Regen: ./shux -E ... src/asm/simd_loop_thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t glue_f32_slot_rbp_disp32(int32_t off);
extern int32_t glue_soa_f32_col_rbp_disp32(int32_t off_col0, int32_t start_idx);
extern int32_t glue_simd_loop_pick_lanes_c(uint32_t feats, int32_t binop_ko, int32_t * lanes_out);
extern int32_t glue_var_array_i32_size_c(uint8_t * arena, int32_t var_ref);
extern int32_t glue_var_is_array_i32_n_c(uint8_t * arena, int32_t var_ref, int32_t n);
extern int32_t glue_expr_same_var_c(uint8_t * arena, int32_t a_ref, int32_t b_ref);
extern int32_t glue_index_uses_var_c(uint8_t * arena, int32_t index_expr_ref, int32_t i_var_ref);
extern int32_t glue_simd_x86_cmp_rax_rbx_c(uint8_t * elf_ctx);
extern int32_t glue_var_array_size_c(uint8_t * arena, int32_t var_ref);
extern int32_t glue_simd_loop_emit_chunk_binop_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t glue_simd_local_var_stack_off_c(uint8_t * arena, uint8_t * ctx, int32_t var_expr_ref);
extern int32_t glue_emit_full_const_peel_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t off_a, int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t glue_emit_runtime_strip_loop_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a, int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes, uint32_t feats);
extern int32_t glue_block_let_init_lit_c(uint8_t * arena, int32_t block_ref, int32_t var_ref, int32_t * out_lit);
extern int32_t glue_parse_i_plus_one_step_c(uint8_t * arena, int32_t step_ref, int32_t i_var_ref);
extern int32_t glue_parse_index_binop_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * binop_ko, int32_t * dst_base_ref, int32_t * a_base_ref, int32_t * b_base_ref);
extern int32_t glue_parse_i_lt_bound_c(uint8_t * arena, int32_t block_ref, int32_t cond_ref, int32_t * i_var_ref, int32_t * n_lit, int32_t * n_is_const, int32_t * n_var_ref);
extern uint32_t glue_simd_loop_cpu_features_c(void);
extern int32_t glue_parse_f32_soa_sum_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * sum_ref, int32_t * arr_ref, int32_t * fa_ref);
extern int32_t glue_emit_f32_soa_sum_strip_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n, int32_t n_lit, int32_t lanes, uint32_t feats);
extern int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
extern int32_t glue_try_simd_peel_index_add_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t * arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(uint8_t * arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(uint8_t * arena, int32_t type_ref);
int32_t glue_f32_slot_rbp_disp32(int32_t off) {
  return (0 - off);
}
int32_t glue_soa_f32_col_rbp_disp32(int32_t off_col0, int32_t start_idx) {
  return (0 - (off_col0 - (start_idx * 4)));
}
int32_t glue_simd_loop_pick_lanes_c(uint32_t feats, int32_t binop_ko, int32_t * lanes_out) {
  if ((lanes_out ==((int32_t *)(0)))) {
    return (0 - 1);
  }
  {
    if ((binop_ko ==6)) {
      if (((feats & 8) !=0)) {
        (void)(((lanes_out)[0] = 8));
        return 0;
      }
      if (((feats & 2) !=0)) {
        (void)(((lanes_out)[0] = 4));
        return 0;
      }
      return (0 - 1);
    }
    if (((feats & 8) !=0)) {
      (void)(((lanes_out)[0] = 8));
      return 0;
    }
    if (((feats & 1) !=0)) {
      (void)(((lanes_out)[0] = 4));
      return 0;
    }
    return (0 - 1);
  }
  return (0 - 1);
}
int32_t glue_var_array_i32_size_c(uint8_t * arena, int32_t var_ref) {
  {
    int32_t tr = pipeline_expr_resolved_type_ref(arena, var_ref);
    int32_t asz = pipeline_type_array_size_at(arena, tr);
    int32_t elem = pipeline_type_elem_ref_at(arena, tr);
    if ((pipeline_expr_kind_ord_at(arena, var_ref) !=3)) {
      return 0;
    }
    if ((tr <=0)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, tr) !=10)) {
      return 0;
    }
    if ((asz <=0)) {
      return 0;
    }
    if ((asz > 256)) {
      return 0;
    }
    if ((elem <=0)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, elem) !=0)) {
      return 0;
    }
    return asz;
  }
  return 0;
}
int32_t glue_var_is_array_i32_n_c(uint8_t * arena, int32_t var_ref, int32_t n) {
  if ((n <=0)) {
    return 0;
  }
  {
    int32_t asz = glue_var_array_i32_size_c(arena, var_ref);
    if ((asz ==n)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
extern int32_t glue_expr_same_var_c_impl(uint8_t * arena, int32_t a_ref, int32_t b_ref);
extern int32_t glue_index_uses_var_c_impl(uint8_t * arena, int32_t index_expr_ref, int32_t i_var_ref);
int32_t glue_expr_same_var_c(uint8_t * arena, int32_t a_ref, int32_t b_ref) {
  {
    return glue_expr_same_var_c_impl(arena, a_ref, b_ref);
  }
  return 0;
}
int32_t glue_index_uses_var_c(uint8_t * arena, int32_t index_expr_ref, int32_t i_var_ref) {
  {
    return glue_index_uses_var_c_impl(arena, index_expr_ref, i_var_ref);
  }
  return 0;
}
extern int32_t glue_simd_x86_cmp_rax_rbx_c_impl(uint8_t * elf_ctx);
extern int32_t glue_var_array_size_c_impl(uint8_t * arena, int32_t var_ref);
extern int32_t glue_simd_loop_emit_chunk_binop_c_impl(uint8_t * elf_ctx, int32_t binop_ko, int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
int32_t glue_simd_x86_cmp_rax_rbx_c(uint8_t * elf_ctx) {
  {
    return glue_simd_x86_cmp_rax_rbx_c_impl(elf_ctx);
  }
  return (0 - 1);
}
int32_t glue_var_array_size_c(uint8_t * arena, int32_t var_ref) {
  {
    return glue_var_array_size_c_impl(arena, var_ref);
  }
  return 0;
}
int32_t glue_simd_loop_emit_chunk_binop_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats) {
  {
    return glue_simd_loop_emit_chunk_binop_c_impl(elf_ctx, binop_ko, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
  }
  return (0 - 1);
}
extern int32_t glue_simd_local_var_stack_off_c_impl(uint8_t * arena, uint8_t * ctx, int32_t var_expr_ref);
extern int32_t glue_emit_full_const_peel_c_impl(uint8_t * elf_ctx, int32_t binop_ko, int32_t off_a, int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t glue_emit_runtime_strip_loop_c_impl(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a, int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes, uint32_t feats);
int32_t glue_simd_local_var_stack_off_c(uint8_t * arena, uint8_t * ctx, int32_t var_expr_ref) {
  {
    return glue_simd_local_var_stack_off_c_impl(arena, ctx, var_expr_ref);
  }
  return (0 - 1);
}
int32_t glue_emit_full_const_peel_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t off_a, int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats) {
  {
    return glue_emit_full_const_peel_c_impl(elf_ctx, binop_ko, off_a, off_b, off_d, n_lit, lanes, esz, ta, feats);
  }
  return 0;
}
int32_t glue_emit_runtime_strip_loop_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a, int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes, uint32_t feats) {
  {
    return glue_emit_runtime_strip_loop_c_impl(arena, elf_ctx, ctx, ta, assign_body_ref, binop_ko, off_i, off_n, off_a, off_b, off_d, array_n, lanes, feats);
  }
  return 0;
}
extern int32_t glue_block_let_init_lit_c_impl(uint8_t * arena, int32_t block_ref, int32_t var_ref, int32_t * out_lit);
extern int32_t glue_parse_i_plus_one_step_c_impl(uint8_t * arena, int32_t step_ref, int32_t i_var_ref);
extern int32_t glue_parse_index_binop_assign_c_impl(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * binop_ko, int32_t * dst_base_ref, int32_t * a_base_ref, int32_t * b_base_ref);
extern int32_t glue_parse_i_lt_bound_c_impl(uint8_t * arena, int32_t block_ref, int32_t cond_ref, int32_t * i_var_ref, int32_t * n_lit, int32_t * n_is_const, int32_t * n_var_ref);
int32_t glue_block_let_init_lit_c(uint8_t * arena, int32_t block_ref, int32_t var_ref, int32_t * out_lit) {
  {
    return glue_block_let_init_lit_c_impl(arena, block_ref, var_ref, out_lit);
  }
  return 0;
}
int32_t glue_parse_i_plus_one_step_c(uint8_t * arena, int32_t step_ref, int32_t i_var_ref) {
  {
    return glue_parse_i_plus_one_step_c_impl(arena, step_ref, i_var_ref);
  }
  return 0;
}
int32_t glue_parse_index_binop_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * binop_ko, int32_t * dst_base_ref, int32_t * a_base_ref, int32_t * b_base_ref) {
  {
    return glue_parse_index_binop_assign_c_impl(arena, assign_ref, i_var_ref, binop_ko, dst_base_ref, a_base_ref, b_base_ref);
  }
  return 0;
}
int32_t glue_parse_i_lt_bound_c(uint8_t * arena, int32_t block_ref, int32_t cond_ref, int32_t * i_var_ref, int32_t * n_lit, int32_t * n_is_const, int32_t * n_var_ref) {
  {
    return glue_parse_i_lt_bound_c_impl(arena, block_ref, cond_ref, i_var_ref, n_lit, n_is_const, n_var_ref);
  }
  return 0;
}
extern uint32_t glue_simd_loop_cpu_features_c_impl(void);
extern int32_t glue_parse_f32_soa_sum_assign_c_impl(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * sum_ref, int32_t * arr_ref, int32_t * fa_ref);
extern int32_t glue_emit_f32_soa_sum_strip_c_impl(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n, int32_t n_lit, int32_t lanes, uint32_t feats);
extern int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
extern int32_t glue_try_simd_peel_index_add_while_elf_c_impl(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
uint32_t glue_simd_loop_cpu_features_c(void) {
  {
    return glue_simd_loop_cpu_features_c_impl();
  }
  return 0;
}
int32_t glue_parse_f32_soa_sum_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * sum_ref, int32_t * arr_ref, int32_t * fa_ref) {
  {
    return glue_parse_f32_soa_sum_assign_c_impl(arena, assign_ref, i_var_ref, sum_ref, arr_ref, fa_ref);
  }
  return 0;
}
int32_t glue_emit_f32_soa_sum_strip_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n, int32_t n_lit, int32_t lanes, uint32_t feats) {
  {
    return glue_emit_f32_soa_sum_strip_c_impl(arena, elf_ctx, ctx, ta, assign_body_ref, off_col0, off_s, off_i, off_n, n_lit, lanes, feats);
  }
  return 0;
}
int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta) {
  {
    return glue_try_simd_peel_f32_soa_sum_while_elf_c_impl(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
  }
  return 0;
}
int32_t glue_try_simd_peel_index_add_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta) {
  {
    return glue_try_simd_peel_index_add_while_elf_c_impl(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
  }
  return 0;
}
