/* seeds/simd_loop_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/simd_loop.x
 * Product PREFER_X_O: g05_try_x_to_o(simd_loop.x) + hybrid rest
 *   seeds/simd_loop.from_x.c (-DSHUX_SIMD_LOOP_FROM_X) ld -r
 * R2: full.x 吃满 peel/parse/emit 公共业务；FROM_X rest 仅 slice_marker（业务 H=0）
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./shux -E ... src/asm/simd_loop.x | filter DBG + polish prologue
 * Track-L (2026-07-16): glue_simd_hw_env_disabled keeps short name; .x has #[no_mangle]
 * (was module-prefix mangle simd_loop_glue_simd_hw_env_disabled).
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
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
extern int32_t simd_loop_x_doc_anchor(void);
extern int32_t glue_expr_same_var_c(uint8_t * arena, int32_t a_ref, int32_t b_ref);
extern int32_t glue_index_uses_var_c(uint8_t * arena, int32_t index_expr_ref, int32_t i_var_ref);
extern int32_t glue_var_array_i32_size_c(uint8_t * arena, int32_t var_ref);
extern uint32_t glue_simd_loop_cpu_features_c(void);
extern int32_t glue_block_let_init_lit_c(uint8_t * arena, int32_t block_ref, int32_t var_ref, int32_t * out_lit);
extern int32_t glue_parse_i_plus_one_step_c(uint8_t * arena, int32_t step_ref, int32_t i_var_ref);
extern int32_t glue_parse_index_binop_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * binop_ko, int32_t * dst_base_ref, int32_t * a_base_ref, int32_t * b_base_ref);
extern int32_t glue_parse_i_lt_bound_c(uint8_t * arena, int32_t block_ref, int32_t cond_ref, int32_t * i_var_ref, int32_t * n_lit, int32_t * n_is_const, int32_t * n_var_ref);
extern int32_t glue_simd_local_var_stack_off_c(uint8_t * arena, uint8_t * ctx, int32_t var_expr_ref);
extern int32_t glue_parse_f32_soa_sum_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * sum_ref, int32_t * arr_ref, int32_t * fa_ref);
extern int32_t glue_simd_loop_emit_chunk_binop_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t glue_emit_full_const_peel_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t off_a, int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t glue_simd_hw_env_disabled(void);
extern int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
extern int32_t glue_try_simd_peel_index_add_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta);
extern int32_t glue_var_array_size_c(uint8_t * arena, int32_t var_ref);
extern int32_t glue_soa_f32_col_rbp_disp32(int32_t off_col0, int32_t start_idx);
extern int32_t glue_f32_slot_rbp_disp32(int32_t off);
extern int32_t glue_simd_loop_pick_lanes_c(uint32_t feats, int32_t binop_ko, int32_t * lanes_out);
extern int32_t glue_var_is_array_i32_n_c(uint8_t * arena, int32_t var_ref, int32_t n);
extern int32_t glue_simd_x86_cmp_rax_rbx_c(uint8_t * elf_ctx);
extern int32_t glue_emit_runtime_strip_loop_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a, int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes, uint32_t feats);
extern int32_t glue_emit_f32_soa_sum_strip_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n, int32_t n_lit, int32_t lanes, uint32_t feats);
extern uint32_t driver_get_pending_target_cpu_features(void);
extern uint32_t shu_target_cpu_detect_host(void);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(uint8_t * arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(uint8_t * arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(uint8_t * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t * arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t * arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(uint8_t * arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(uint8_t * arena, int32_t type_ref);
int32_t simd_loop_x_doc_anchor(void) {
  return 0;
}
int32_t glue_expr_same_var_c(uint8_t * arena, int32_t a_ref, int32_t b_ref) {
  {
    int32_t alen = pipeline_expr_var_name_len(arena, a_ref);
    int32_t blen = pipeline_expr_var_name_len(arena, b_ref);
    uint8_t an[64] = {};
    uint8_t bn[64] = {};
    int32_t k = 0;
    if ((pipeline_expr_kind_ord_at(arena, a_ref) !=3)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, b_ref) !=3)) {
      return 0;
    }
    if ((alen <=0)) {
      return 0;
    }
    if ((alen !=blen)) {
      return 0;
    }
    if ((alen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, a_ref, &((an)[0])));
    (void)(pipeline_expr_var_name_into(arena, b_ref, &((bn)[0])));
    while ((k < alen)) {
      if (((an)[k] !=(bn)[k])) {
        return 0;
      }
      (void)((k = (k + 1)));
    }
  }
  return 1;
}
int32_t glue_index_uses_var_c(uint8_t * arena, int32_t index_expr_ref, int32_t i_var_ref) {
  {
    int32_t idx_ref = pipeline_expr_index_index_ref(arena, index_expr_ref);
    if ((pipeline_expr_kind_ord_at(arena, index_expr_ref) !=47)) {
      return 0;
    }
    return glue_expr_same_var_c(arena, idx_ref, i_var_ref);
  }
  return 0;
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
uint32_t glue_simd_loop_cpu_features_c(void) {
  {
    uint32_t feats = driver_get_pending_target_cpu_features();
    if ((feats !=0)) {
      return feats;
    }
    return shu_target_cpu_detect_host();
  }
  return 0;
}
extern int32_t pipeline_expr_int_val_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_index_base_ref(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_soa_stride(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_is_enum_variant(uint8_t * arena, int32_t er);
extern int32_t pipeline_expr_field_access_offset(uint8_t * arena, int32_t er);
extern int32_t ast_ast_block_num_lets(uint8_t * arena, int32_t br);
extern int32_t pipeline_block_let_name_len(uint8_t * arena, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(uint8_t * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_let_init_ref(uint8_t * arena, int32_t br, int32_t li);
extern int32_t asm_ctx_local_find_offset(uint8_t * ctx, uint8_t * name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t * ctx, uint8_t * arena, uint8_t * name, int32_t name_len);
extern int32_t simd_enc_try_hw_vector_iadd_rbp(uint8_t * elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_isub_rbp(uint8_t * elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_imul_rbp(uint8_t * elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t ast_ast_block_while_cond_ref(uint8_t * arena, int32_t block_ref, int32_t loop_idx);
extern int32_t ast_ast_block_while_body_ref(uint8_t * arena, int32_t block_ref, int32_t loop_idx);
extern int32_t ast_ast_block_num_expr_stmts(uint8_t * arena, int32_t body);
extern int32_t ast_ast_block_expr_stmt_ref(uint8_t * arena, int32_t body, int32_t ei);
int32_t glue_block_let_init_lit_c(uint8_t * arena, int32_t block_ref, int32_t var_ref, int32_t * out_lit) {
  if ((out_lit ==0)) {
    return 0;
  }
  if ((var_ref <=0)) {
    return 0;
  }
  {
    int32_t vlen = pipeline_expr_var_name_len(arena, var_ref);
    uint8_t vbuf[64] = {};
    int32_t nlet = ast_ast_block_num_lets(arena, block_ref);
    int32_t li = 0;
    if ((pipeline_expr_kind_ord_at(arena, var_ref) !=3)) {
      return 0;
    }
    if ((vlen <=0)) {
      return 0;
    }
    if ((vlen > 63)) {
      return 0;
    }
    (void)(pipeline_expr_var_name_into(arena, var_ref, &((vbuf)[0])));
    while ((li < nlet)) {
      int32_t llen = pipeline_block_let_name_len(arena, block_ref, li);
      if ((llen ==vlen)) {
        uint8_t lb[64] = {};
        (void)(pipeline_block_let_name_copy64(arena, block_ref, li, &((lb)[0])));
        int32_t matched = 1;
        int32_t k = 0;
        while ((k < vlen)) {
          if (((lb)[k] !=(vbuf)[k])) {
            (void)((matched = 0));
          }
          (void)((k = (k + 1)));
        }
        if ((matched !=0)) {
          int32_t init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
          if ((init_ref <=0)) {
            return 0;
          }
          if ((pipeline_expr_kind_ord_at(arena, init_ref) !=0)) {
            return 0;
          }
          (void)(((out_lit)[0] = pipeline_expr_int_val_at(arena, init_ref)));
          return 1;
        }
      }
      (void)((li = (li + 1)));
    }
  }
  return 0;
}
int32_t glue_parse_i_plus_one_step_c(uint8_t * arena, int32_t step_ref, int32_t i_var_ref) {
  {
    int32_t ko = pipeline_expr_kind_ord_at(arena, step_ref);
    if ((ko ==29)) {
      int32_t left_ref = pipeline_expr_binop_left_ref_at(arena, step_ref);
      int32_t right_ref = pipeline_expr_binop_right_ref_at(arena, step_ref);
      if ((glue_expr_same_var_c(arena, left_ref, i_var_ref) ==0)) {
        return 0;
      }
      if ((pipeline_expr_kind_ord_at(arena, right_ref) !=0)) {
        return 0;
      }
      if ((pipeline_expr_int_val_at(arena, right_ref) ==1)) {
        return 1;
      }
      return 0;
    }
    if ((ko !=28)) {
      return 0;
    }
    int32_t left_ref2 = pipeline_expr_binop_left_ref_at(arena, step_ref);
    int32_t right_ref2 = pipeline_expr_binop_right_ref_at(arena, step_ref);
    if ((glue_expr_same_var_c(arena, left_ref2, i_var_ref) ==0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, right_ref2) !=4)) {
      return 0;
    }
    int32_t add_l = pipeline_expr_binop_left_ref_at(arena, right_ref2);
    int32_t add_r = pipeline_expr_binop_right_ref_at(arena, right_ref2);
    if ((glue_expr_same_var_c(arena, add_l, i_var_ref) ==0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, add_r) !=0)) {
      return 0;
    }
    if ((pipeline_expr_int_val_at(arena, add_r) !=1)) {
      return 0;
    }
  }
  return 1;
}
int32_t glue_parse_index_binop_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * binop_ko, int32_t * dst_base_ref, int32_t * a_base_ref, int32_t * b_base_ref) {
  if ((binop_ko ==0)) {
    return 0;
  }
  if ((dst_base_ref ==0)) {
    return 0;
  }
  if ((a_base_ref ==0)) {
    return 0;
  }
  if ((b_base_ref ==0)) {
    return 0;
  }
  {
    int32_t left_ref = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    int32_t right_ref = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    int32_t rko = pipeline_expr_kind_ord_at(arena, right_ref);
    int32_t al = pipeline_expr_binop_left_ref_at(arena, right_ref);
    int32_t ar = pipeline_expr_binop_right_ref_at(arena, right_ref);
    int32_t dst_base = pipeline_expr_index_base_ref(arena, left_ref);
    int32_t a_base = pipeline_expr_index_base_ref(arena, al);
    int32_t b_base = pipeline_expr_index_base_ref(arena, ar);
    if ((pipeline_expr_kind_ord_at(arena, assign_ref) !=28)) {
      return 0;
    }
    if ((glue_index_uses_var_c(arena, left_ref, i_var_ref) ==0)) {
      return 0;
    }
    if ((rko !=4)) {
      if ((rko !=5)) {
        if ((rko !=6)) {
          return 0;
        }
      }
    }
    if ((glue_index_uses_var_c(arena, al, i_var_ref) ==0)) {
      return 0;
    }
    if ((glue_index_uses_var_c(arena, ar, i_var_ref) ==0)) {
      return 0;
    }
    if ((dst_base <=0)) {
      return 0;
    }
    if ((a_base <=0)) {
      return 0;
    }
    if ((b_base <=0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, dst_base) !=3)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, a_base) !=3)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, b_base) !=3)) {
      return 0;
    }
    (void)(((binop_ko)[0] = rko));
    (void)(((dst_base_ref)[0] = dst_base));
    (void)(((a_base_ref)[0] = a_base));
    (void)(((b_base_ref)[0] = b_base));
  }
  return 1;
}
int32_t glue_parse_i_lt_bound_c(uint8_t * arena, int32_t block_ref, int32_t cond_ref, int32_t * i_var_ref, int32_t * n_lit, int32_t * n_is_const, int32_t * n_var_ref) {
  if ((i_var_ref ==0)) {
    return 0;
  }
  if ((n_lit ==0)) {
    return 0;
  }
  if ((n_is_const ==0)) {
    return 0;
  }
  if ((n_var_ref ==0)) {
    return 0;
  }
  {
    int32_t left_ref = pipeline_expr_binop_left_ref_at(arena, cond_ref);
    int32_t right_ref = pipeline_expr_binop_right_ref_at(arena, cond_ref);
    int32_t rko = pipeline_expr_kind_ord_at(arena, right_ref);
    int32_t prop = glue_block_let_init_lit_c(arena, block_ref, right_ref, n_lit);
    if ((pipeline_expr_kind_ord_at(arena, cond_ref) !=16)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, left_ref) !=3)) {
      return 0;
    }
    (void)(((i_var_ref)[0] = left_ref));
    if ((rko ==0)) {
      (void)(((n_lit)[0] = pipeline_expr_int_val_at(arena, right_ref)));
      if (((n_lit)[0] <=0)) {
        return 0;
      }
      (void)(((n_is_const)[0] = 1));
      (void)(((n_var_ref)[0] = 0));
      return 1;
    }
    if ((rko !=3)) {
      return 0;
    }
    (void)(((n_var_ref)[0] = right_ref));
    if ((prop !=0)) {
      if (((n_lit)[0] <=0)) {
        return 0;
      }
      (void)(((n_is_const)[0] = 1));
      return 1;
    }
    (void)(((n_is_const)[0] = 0));
  }
  return 1;
}
int32_t glue_simd_local_var_stack_off_c(uint8_t * arena, uint8_t * ctx, int32_t var_expr_ref) {
  if ((arena ==0)) {
    return (0 - 1);
  }
  if ((ctx ==0)) {
    return (0 - 1);
  }
  if ((var_expr_ref <=0)) {
    return (0 - 1);
  }
  {
    int32_t vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    if ((vlen <=0)) {
      return (0 - 1);
    }
    if ((vlen > 63)) {
      return (0 - 1);
    }
    uint8_t vname[64] = {};
    (void)(pipeline_expr_var_name_into(arena, var_expr_ref, &((vname)[0])));
    int32_t off = asm_ctx_local_find_offset_scoped(ctx, arena, &((vname)[0]), vlen);
    if ((off < 0)) {
      return asm_ctx_local_find_offset(ctx, &((vname)[0]), vlen);
    }
    return off;
  }
  return (0 - 1);
}
int32_t glue_parse_f32_soa_sum_assign_c(uint8_t * arena, int32_t assign_ref, int32_t i_var_ref, int32_t * sum_ref, int32_t * arr_ref, int32_t * fa_ref) {
  if ((sum_ref ==0)) {
    return 0;
  }
  if ((arr_ref ==0)) {
    return 0;
  }
  if ((fa_ref ==0)) {
    return 0;
  }
  {
    int32_t left_ref = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    int32_t right_ref = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    int32_t add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
    int32_t add_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
    int32_t fa_tr = pipeline_expr_resolved_type_ref(arena, add_r);
    int32_t sum_tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    int32_t idx_base = pipeline_expr_field_access_base_ref(arena, add_r);
    if ((pipeline_expr_kind_ord_at(arena, assign_ref) !=28)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, right_ref) !=4)) {
      return 0;
    }
    if ((glue_expr_same_var_c(arena, left_ref, add_l) ==0)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, add_r) !=44)) {
      return 0;
    }
    if ((pipeline_expr_field_access_is_enum_variant(arena, add_r) !=0)) {
      return 0;
    }
    if ((pipeline_expr_field_access_soa_stride(arena, add_r) <=0)) {
      return 0;
    }
    if ((fa_tr <=0)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, fa_tr) !=14)) {
      return 0;
    }
    if ((sum_tr <=0)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, sum_tr) !=14)) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, idx_base) !=47)) {
      return 0;
    }
    if ((glue_index_uses_var_c(arena, idx_base, i_var_ref) ==0)) {
      return 0;
    }
    (void)((idx_base = pipeline_expr_index_base_ref(arena, idx_base)));
    if ((pipeline_expr_kind_ord_at(arena, idx_base) !=3)) {
      return 0;
    }
    (void)(((sum_ref)[0] = left_ref));
    (void)(((arr_ref)[0] = idx_base));
    (void)(((fa_ref)[0] = add_r));
  }
  return 1;
}
int32_t glue_simd_loop_emit_chunk_binop_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats) {
  {
    if ((binop_ko ==5)) {
      return simd_enc_try_hw_vector_isub_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    }
    if ((binop_ko ==6)) {
      return simd_enc_try_hw_vector_imul_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    }
    return simd_enc_try_hw_vector_iadd_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
  }
  return (0 - 1);
}
int32_t glue_emit_full_const_peel_c(uint8_t * elf_ctx, int32_t binop_ko, int32_t off_a, int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats) {
  int32_t chunks = (n_lit / lanes);
  if ((chunks <=0)) {
    return 0;
  }
  if (((chunks * lanes) !=n_lit)) {
    return 0;
  }
  int32_t chunk = 0;
  while ((chunk < chunks)) {
    int32_t start = (chunk * lanes);
    int32_t chunk_off_a = (off_a - (start * esz));
    int32_t chunk_off_b = (off_b - (start * esz));
    int32_t chunk_off_d = (off_d - (start * esz));
    if ((glue_simd_loop_emit_chunk_binop_c(elf_ctx, binop_ko, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats) !=0)) {
      uint8_t name[24] = {};
      (void)(((name)[4] = 95));
      (void)(((name)[5] = 83));
      (void)(((name)[6] = 73));
      (void)(((name)[7] = 77));
      (void)(((name)[8] = 68));
      (void)(((name)[9] = 95));
      (void)(((name)[10] = 72));
      (void)(((name)[11] = 87));
      (void)(((name)[12] = 95));
      (void)(((name)[13] = 83));
      (void)(((name)[14] = 84));
      (void)(((name)[15] = 82));
      (void)(((name)[16] = 73));
      (void)(((name)[17] = 67));
      (void)(((name)[18] = 84));
      (void)(((name)[19] = 0));
      {
        uint8_t * p = getenv(&((name)[0]));
        if ((p !=0)) {
          if (((p)[0] !=48)) {
            return (0 - 1);
          }
        }
      }
      return 0;
    }
    (void)((chunk = (chunk + 1)));
  }
  return 1;
}
int32_t glue_simd_hw_env_disabled(void) {
  {
    uint8_t name[16] = {};
    (void)(((name)[0] = 83));
    (void)(((name)[1] = 72));
    (void)(((name)[2] = 85));
    (void)(((name)[3] = 88));
    (void)(((name)[4] = 95));
    (void)(((name)[5] = 83));
    (void)(((name)[6] = 73));
    (void)(((name)[7] = 77));
    (void)(((name)[8] = 68));
    (void)(((name)[9] = 95));
    (void)(((name)[10] = 72));
    (void)(((name)[11] = 87));
    (void)(((name)[12] = 0));
    uint8_t * p = getenv(&((name)[0]));
    if ((p ==0)) {
      return 0;
    }
    if (((p)[0] ==48)) {
      return 1;
    }
  }
  return 0;
}
int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((block_ref <=0)) {
    return 0;
  }
  if ((glue_simd_hw_env_disabled() !=0)) {
    return 0;
  }
  {
    int32_t cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    int32_t body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if ((cond_ref <=0)) {
      return 0;
    }
    if ((body_ref <=0)) {
      return 0;
    }
    int32_t i_var_ref = 0;
    int32_t n_lit = 0;
    int32_t n_is_const = 0;
    int32_t n_var_ref = 0;
    if ((glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &(i_var_ref), &(n_lit), &(n_is_const), &(n_var_ref)) ==0)) {
      return 0;
    }
    if ((ast_ast_block_num_expr_stmts(arena, body_ref) !=2)) {
      return 0;
    }
    int32_t assign_body_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    int32_t assign_step_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if ((assign_body_ref <=0)) {
      return 0;
    }
    if ((assign_step_ref <=0)) {
      return 0;
    }
    int32_t sum_ref = 0;
    int32_t arr_ref = 0;
    int32_t fa_ref = 0;
    if ((glue_parse_f32_soa_sum_assign_c(arena, assign_body_ref, i_var_ref, &(sum_ref), &(arr_ref), &(fa_ref)) ==0)) {
      return 0;
    }
    if ((glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref) ==0)) {
      return 0;
    }
    int32_t array_n = glue_var_array_size_c(arena, arr_ref);
    if ((n_is_const !=0)) {
      if ((n_lit <=0)) {
        return 0;
      }
      if ((array_n > 0)) {
        if ((n_lit > array_n)) {
          return 0;
        }
      }
    } else {
      if ((n_var_ref <=0)) {
        return 0;
      }
    }
    int32_t off_col0 = glue_simd_local_var_stack_off_c(arena, ctx, arr_ref);
    int32_t col_base = pipeline_expr_field_access_offset(arena, fa_ref);
    if ((col_base > 0)) {
      (void)((off_col0 = (off_col0 - col_base)));
    }
    int32_t off_s = glue_simd_local_var_stack_off_c(arena, ctx, sum_ref);
    int32_t off_i = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if ((off_col0 < 0)) {
      return 0;
    }
    if ((off_s < 0)) {
      return 0;
    }
    if ((off_i < 0)) {
      return 0;
    }
    uint32_t feats = glue_simd_loop_cpu_features_c();
    int32_t lanes = 4;
    if (((feats & 1) ==0)) {
      return 0;
    }
    int32_t off_n = (0 - 1);
    if ((n_var_ref > 0)) {
      (void)((off_n = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref)));
    }
    if ((n_is_const ==0)) {
      if ((off_n < 0)) {
        return 0;
      }
    }
    return glue_emit_f32_soa_sum_strip_c(arena, elf_ctx, ctx, ta, assign_body_ref, off_col0, off_s, off_i, off_n, n_lit, lanes, feats);
  }
  return 0;
}
int32_t glue_try_simd_peel_index_add_while_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, int32_t loop_idx, uint8_t * ctx, int32_t ta) {
  if ((arena ==0)) {
    return 0;
  }
  if ((elf_ctx ==0)) {
    return 0;
  }
  if ((ctx ==0)) {
    return 0;
  }
  if ((block_ref <=0)) {
    return 0;
  }
  if ((glue_simd_hw_env_disabled() !=0)) {
    return 0;
  }
  {
    int32_t cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    int32_t body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if ((cond_ref <=0)) {
      return 0;
    }
    if ((body_ref <=0)) {
      return 0;
    }
    int32_t i_var_ref = 0;
    int32_t n_lit = 0;
    int32_t n_is_const = 0;
    int32_t n_var_ref = 0;
    if ((glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &(i_var_ref), &(n_lit), &(n_is_const), &(n_var_ref)) ==0)) {
      return 0;
    }
    int32_t nes = ast_ast_block_num_expr_stmts(arena, body_ref);
    if ((nes !=2)) {
      return 0;
    }
    int32_t assign_body_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    int32_t assign_step_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if ((assign_body_ref <=0)) {
      return 0;
    }
    if ((assign_step_ref <=0)) {
      return 0;
    }
    int32_t binop_ko = 0;
    int32_t dst_base = 0;
    int32_t a_base = 0;
    int32_t b_base = 0;
    if ((glue_parse_index_binop_assign_c(arena, assign_body_ref, i_var_ref, &(binop_ko), &(dst_base), &(a_base), &(b_base)) ==0)) {
      return 0;
    }
    if ((glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref) ==0)) {
      return 0;
    }
    int32_t array_n = glue_var_array_i32_size_c(arena, dst_base);
    if ((array_n <=0)) {
      return 0;
    }
    if ((glue_var_array_i32_size_c(arena, a_base) !=array_n)) {
      return 0;
    }
    if ((glue_var_array_i32_size_c(arena, b_base) !=array_n)) {
      return 0;
    }
    int32_t off_a = glue_simd_local_var_stack_off_c(arena, ctx, a_base);
    int32_t off_b = glue_simd_local_var_stack_off_c(arena, ctx, b_base);
    int32_t off_d = glue_simd_local_var_stack_off_c(arena, ctx, dst_base);
    int32_t off_i = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if ((off_a < 0)) {
      return 0;
    }
    if ((off_b < 0)) {
      return 0;
    }
    if ((off_d < 0)) {
      return 0;
    }
    if ((off_i < 0)) {
      return 0;
    }
    uint32_t feats = glue_simd_loop_cpu_features_c();
    int32_t esz = 4;
    int32_t lanes = 0;
    if ((glue_simd_loop_pick_lanes_c(feats, binop_ko, &(lanes)) !=0)) {
      return 0;
    }
    if ((n_is_const !=0)) {
      if ((n_lit > 0)) {
        if (((n_lit % lanes) ==0)) {
          if ((n_lit <=array_n)) {
            if ((glue_var_is_array_i32_n_c(arena, dst_base, n_lit) !=0)) {
              return glue_emit_full_const_peel_c(elf_ctx, binop_ko, off_a, off_b, off_d, n_lit, lanes, esz, ta, feats);
            }
          }
        }
      }
    }
    if ((n_var_ref > 0)) {
      int32_t off_n = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref);
      if ((off_n < 0)) {
        return 0;
      }
      return glue_emit_runtime_strip_loop_c(arena, elf_ctx, ctx, ta, assign_body_ref, binop_ko, off_i, off_n, off_a, off_b, off_d, array_n, lanes, feats);
    }
  }
  return 0;
}
int32_t glue_var_array_size_c(uint8_t * arena, int32_t var_ref) {
  {
    int32_t tr = pipeline_expr_resolved_type_ref(arena, var_ref);
    int32_t asz = pipeline_type_array_size_at(arena, tr);
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
    if ((asz > 65536)) {
      return 0;
    }
    return asz;
  }
  return 0;
}
int32_t glue_soa_f32_col_rbp_disp32(int32_t off_col0, int32_t start_idx) {
  return (0 - (off_col0 - (start_idx * 4)));
}
int32_t glue_f32_slot_rbp_disp32(int32_t off) {
  return (0 - off);
}
int32_t glue_simd_loop_pick_lanes_c(uint32_t feats, int32_t binop_ko, int32_t * lanes_out) {
  if ((lanes_out ==0)) {
    return -(1);
  }
  if ((binop_ko ==6)) {
    if (((feats & 8) !=0)) {
      (void)(((lanes_out)[0] = 8));
      return 0;
    }
    if (((feats & 2) !=0)) {
      (void)(((lanes_out)[0] = 4));
      return 0;
    }
    return -(1);
  }
  if (((feats & 8) !=0)) {
    (void)(((lanes_out)[0] = 8));
    return 0;
  }
  if (((feats & 1) !=0)) {
    (void)(((lanes_out)[0] = 4));
    return 0;
  }
  return -(1);
}
int32_t glue_var_is_array_i32_n_c(uint8_t * arena, int32_t var_ref, int32_t n) {
  {
    int32_t sz = glue_var_array_i32_size_c(arena, var_ref);
    if ((sz ==n)) {
      return 1;
    }
  }
  return 0;
}
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t * ctx, uint8_t * ptr, int32_t n);
int32_t glue_simd_x86_cmp_rax_rbx_c(uint8_t * elf_ctx) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  uint8_t b0 = 57;
  uint8_t b1 = 216;
  int32_t r = 0;
  {
    (void)((r = pipeline_elf_ctx_append_bytes(elf_ctx, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = pipeline_elf_ctx_append_bytes(elf_ctx, &(b1), 1)));
  }
  return r;
}
extern int32_t pipeline_asm_emit_next_label_c(uint8_t * ctx, uint8_t * buf, int32_t cap);
extern int32_t pipeline_asm_emit_assign_elf_c(uint8_t * arena, uint8_t * elf_ctx, int32_t assign_ref, uint8_t * ctx, int32_t ta);
extern int32_t backend_enc_label_arch(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_jge_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(uint8_t * elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t simd_enc_try_hw_vector_binop_rbp_at_idx(uint8_t * elf_ctx, int32_t off_a, int32_t off_b, int32_t off_d, int32_t off_i, int32_t array_n, int32_t binop_ko, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_x86_xorps_xmm0_zero(uint8_t * elf_ctx);
extern int32_t simd_enc_f32_soa_col_movups_xmm1_at_idx(uint8_t * elf_ctx, int32_t off_col0, int32_t off_i, int32_t ta);
extern int32_t simd_enc_x86_addps_xmm0_xmm1(uint8_t * elf_ctx);
extern int32_t simd_enc_x86_horizontal_addps_xmm0(uint8_t * elf_ctx);
extern int32_t simd_enc_x86_movss_xmm0_rbp_disp(uint8_t * elf_ctx, int32_t disp);
int32_t glue_emit_runtime_strip_loop_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a, int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes, uint32_t feats) {
  if ((ta !=0)) {
    return 0;
  }
  uint8_t vec_loop[64] = {};
  uint8_t epi_loop[64] = {};
  uint8_t epi_done[64] = {};
  int32_t vec_len = 0;
  int32_t epi_len = 0;
  int32_t done_len = 0;
  {
    (void)((vec_len = pipeline_asm_emit_next_label_c(ctx, &((vec_loop)[0]), 64)));
  }
  {
    (void)((epi_len = pipeline_asm_emit_next_label_c(ctx, &((epi_loop)[0]), 64)));
  }
  {
    (void)((done_len = pipeline_asm_emit_next_label_c(ctx, &((epi_done)[0]), 64)));
  }
  if ((vec_len <=0)) {
    return (0 - 1);
  }
  if ((epi_len <=0)) {
    return (0 - 1);
  }
  if ((done_len <=0)) {
    return (0 - 1);
  }
  int32_t r = 0;
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((vec_loop)[0]), vec_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_push_rax_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_pop_rax_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jge_arch(elf_ctx, &((epi_loop)[0]), epi_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx, off_a, off_b, off_d, off_i, array_n, binop_ko, lanes, 4, ta, feats)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jmp_arch(elf_ctx, &((vec_loop)[0]), vec_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((epi_loop)[0]), epi_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jge_arch(elf_ctx, &((epi_done)[0]), done_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jmp_arch(elf_ctx, &((epi_loop)[0]), epi_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((epi_done)[0]), done_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  return 1;
}
int32_t glue_emit_f32_soa_sum_strip_c(uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx, int32_t ta, int32_t assign_body_ref, int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n, int32_t n_lit, int32_t lanes, uint32_t feats) {
  if ((ta !=0)) {
    return 0;
  }
  if ((lanes !=4)) {
    return 0;
  }
  if (((feats & 1) ==0)) {
    return 0;
  }
  uint8_t vec_loop[64] = {};
  uint8_t epi_merge[64] = {};
  uint8_t epi_loop[64] = {};
  uint8_t epi_done[64] = {};
  int32_t vec_len = 0;
  int32_t merge_len = 0;
  int32_t epi_len = 0;
  int32_t done_len = 0;
  {
    (void)((vec_len = pipeline_asm_emit_next_label_c(ctx, &((vec_loop)[0]), 64)));
  }
  {
    (void)((merge_len = pipeline_asm_emit_next_label_c(ctx, &((epi_merge)[0]), 64)));
  }
  {
    (void)((epi_len = pipeline_asm_emit_next_label_c(ctx, &((epi_loop)[0]), 64)));
  }
  {
    (void)((done_len = pipeline_asm_emit_next_label_c(ctx, &((epi_done)[0]), 64)));
  }
  if ((vec_len <=0)) {
    return (0 - 1);
  }
  if ((merge_len <=0)) {
    return (0 - 1);
  }
  if ((epi_len <=0)) {
    return (0 - 1);
  }
  if ((done_len <=0)) {
    return (0 - 1);
  }
  int32_t r = 0;
  {
    (void)((r = simd_enc_x86_xorps_xmm0_zero(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((vec_loop)[0]), vec_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_push_rax_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  if ((off_n >=0)) {
    {
      (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
  } else {
    {
      (void)((r = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_pop_rax_arch(elf_ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jge_arch(elf_ctx, &((epi_merge)[0]), merge_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx, off_col0, off_i, ta)));
  }
  if ((r !=0)) {
    uint8_t name[24] = {};
    (void)(((name)[0] = 83));
    (void)(((name)[1] = 72));
    (void)(((name)[2] = 85));
    (void)(((name)[3] = 88));
    (void)(((name)[4] = 95));
    (void)(((name)[5] = 83));
    (void)(((name)[6] = 73));
    (void)(((name)[7] = 77));
    (void)(((name)[8] = 68));
    (void)(((name)[9] = 95));
    (void)(((name)[10] = 72));
    (void)(((name)[11] = 87));
    (void)(((name)[12] = 95));
    (void)(((name)[13] = 83));
    (void)(((name)[14] = 84));
    (void)(((name)[15] = 82));
    (void)(((name)[16] = 73));
    (void)(((name)[17] = 67));
    (void)(((name)[18] = 84));
    (void)(((name)[19] = 0));
    {
      uint8_t * p = getenv(&((name)[0]));
      if ((p !=0)) {
        if (((p)[0] !=48)) {
          return (0 - 1);
        }
      }
    }
    return 0;
  }
  {
    (void)((r = simd_enc_x86_addps_xmm0_xmm1(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jmp_arch(elf_ctx, &((vec_loop)[0]), vec_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((epi_merge)[0]), merge_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_enc_x86_horizontal_addps_xmm0(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx, glue_f32_slot_rbp_disp32(off_s))));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((epi_loop)[0]), epi_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  if ((off_n >=0)) {
    {
      (void)((r = backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
  } else {
    {
      (void)((r = backend_enc_push_rax_arch(elf_ctx, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
    {
      (void)((r = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
    {
      (void)((r = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
    {
      (void)((r = backend_enc_pop_rax_arch(elf_ctx, ta)));
    }
    if ((r !=0)) {
      return (0 - 1);
    }
  }
  {
    (void)((r = glue_simd_x86_cmp_rax_rbx_c(elf_ctx)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jge_arch(elf_ctx, &((epi_done)[0]), done_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_jmp_arch(elf_ctx, &((epi_loop)[0]), epi_len, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = backend_enc_label_arch(elf_ctx, &((epi_done)[0]), done_len, 0, ta)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  return 1;
}
