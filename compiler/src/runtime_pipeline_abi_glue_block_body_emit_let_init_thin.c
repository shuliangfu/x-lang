/*
 * Host-gcc twin of glue_block_body_emit_let_init (w1010).
 * Root: tip PE stack u8[256] vn smashes when host-gcc body_sync calls tip
 *   emit_let_init (f32_f64 L2 regresses to CG002 code_len=17). BSS vn +
 *   plain if/else (no GNU statement-expressions — MinGW mishandled them).
 * Semantics mirror runtime_pipeline_abi.x glue_block_body_emit_let_init.
 * PLATFORM: WINDOWS — first-wins + win_patch jmp leftover W→T.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint8_t g_w1010_emit_let_vn[256];

extern int32_t backend_asm_ctx_slot_offset(uint8_t *ctx, int32_t slot_idx);
extern int32_t backend_enc_store_eax_to_rbp_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(uint8_t *elf_ctx, int32_t offset, int32_t ta);
extern int32_t glue_array_temp_bytes_for_let_init(uint8_t *arena, int32_t let_type_ref, int32_t init_ref);
extern void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off);
extern int32_t glue_block_let_is_fixed_array_type(uint8_t *arena, int32_t block_ref, int32_t let_idx);
extern int32_t glue_block_let_is_simd_vector_type(uint8_t *arena, int32_t block_ref, int32_t let_idx);
extern int32_t glue_emit_array_let_empty_init(uint8_t *arena, uint8_t *elf_ctx, uint8_t *ctx, int32_t ta,
                                             int32_t stack_slot_off);
extern int32_t glue_emit_fixed_array_type_let_init_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t init_ref,
                                                        uint8_t *ctx, int32_t ta, int32_t type_ref,
                                                        int32_t stack_slot_off);
extern int32_t glue_emit_float_lit_to_rax_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, int32_t ta,
                                               int32_t force_ty_ref, int32_t call_abi_widen_f64);
extern uint8_t *glue_emit_module_from_ctx(uint8_t *ctx);
extern int32_t glue_emit_slice_from_array_let_init_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t block_ref,
                                                        int32_t let_idx, int32_t init_ref, int32_t let_type_ref,
                                                        uint8_t *ctx, int32_t ta, int32_t slice_slot_off);
extern int32_t glue_emit_struct_type_let_init_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t init_ref,
                                                    uint8_t *ctx, int32_t ta, int32_t let_ty_ref,
                                                    int32_t stack_slot_off);
extern int32_t glue_emit_vector_type_let_init_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t init_ref,
                                                    uint8_t *ctx, int32_t ta, int32_t stack_slot_off,
                                                    int32_t type_ref);
extern int32_t glue_float_promote_src_ty_ref_c(uint8_t *arena, int32_t expr_ref);
extern void glue_index_assign_addr_cache_clear(void);
extern int32_t glue_init_is_empty_array_lit(uint8_t *arena, int32_t init_ref);
extern void glue_live_fwd_forward_after_def(uint8_t *arena, uint8_t *ctx, int32_t def_off, int32_t gen_expr);
extern int32_t glue_maybe_demote_f64_to_f32_eax_elf_c(uint8_t *arena, uint8_t *elf_ctx, uint8_t *ctx,
                                                     int32_t dest_ty_ref, int32_t src_expr_ref, int32_t ta);
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(uint8_t *arena, uint8_t *elf_ctx, int32_t dest_ty_ref,
                                                      int32_t src_ty_ref, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(uint8_t *m, uint8_t *arena, uint8_t *elf_ctx, int32_t ty_ref,
                                                  int32_t slot_off, int32_t ta, int32_t init_ref, uint8_t *ctx);
extern int32_t glue_try_block_let_index_init_from_assign_cache_elf_c(uint8_t *arena, uint8_t *elf_ctx,
                                                                    uint8_t *ctx, int32_t init_ref, int32_t ta);
extern void pipeline_asm_bump_next_offset_after_let_init(uint8_t *arena, int32_t block_ref, int32_t let_idx,
                                                        int32_t init_ref, uint8_t *ctx);
extern int32_t pipeline_asm_emit_expr_elf_rec(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx,
                                              int32_t ta);
extern int32_t pipeline_asm_try_emit_dyn_coerce_let(uint8_t *arena, uint8_t *elf_ctx, int32_t block_ref,
                                                    int32_t idx, int32_t init_ref, int32_t slot_off, uint8_t *ctx,
                                                    int32_t ta);
extern int32_t pipeline_block_let_type_ref(uint8_t *arena, int32_t block_ref, int32_t let_idx);
extern int32_t pipeline_block_resolve_var_type_ref(uint8_t *arena, int32_t block_ref, uint8_t *vname, int32_t vlen);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t ref);

/**
 * Emit one block-let initializer into ELF (float-lit fast path + f32 store).
 * @return 0 ok; -1 fail
 * PLATFORM: WINDOWS — host-gcc twin; BSS vn avoids tip stack smash.
 */
int32_t glue_block_body_emit_let_init(uint8_t *arena, uint8_t *elf_ctx, int32_t block_ref, int32_t idx,
                                      int32_t init_ref, int32_t slot, uint8_t *ctx, int32_t ta, uint8_t *lnb,
                                      int32_t llen) {
  int32_t tref_empty = 0;
  int32_t slice_st = 0;
  int32_t arr_st = 0;
  int32_t vst = 0;
  int32_t st = 0;
  int32_t ix_init = 0;
  int32_t let_ty = 0;
  int32_t init_ko = 0;
  int32_t let_ty2 = 0;
  int32_t src_ty = 0;
  int32_t vl = 0;
  int32_t bt = 0;
  int32_t vtype_ref = 0;
  int32_t rc = 0;
  int32_t slot_off = 0;
  int32_t init_f32_lit = 0;
  (void)lnb;
  (void)llen;

  slot_off = backend_asm_ctx_slot_offset(ctx, slot);
  /* w1010 debug: remove after PE f32 root found */
  fprintf(stderr, "ELI enter idx=%d init=%d slot=%d off=%d\n", idx, init_ref, slot, slot_off);
  rc = pipeline_asm_try_emit_dyn_coerce_let(arena, elf_ctx, block_ref, idx, init_ref, slot_off, ctx, ta);
  if (rc == 1) {
    return 0;
  }
  if (rc < 0) {
    return -1;
  }

  if (glue_init_is_empty_array_lit(arena, init_ref) != 0) {
    tref_empty = pipeline_block_let_type_ref(arena, block_ref, idx);
    slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref, tref_empty,
                                                         ctx, ta, slot_off);
    if (slice_st == 1) {
      return 0;
    }
    if (slice_st < 0) {
      return -1;
    }
    if (glue_block_let_is_fixed_array_type(arena, block_ref, idx) != 0) {
      return 0;
    }
    if (glue_array_temp_bytes_for_let_init(arena, tref_empty, 0) > 0) {
      rc = glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, slot_off);
      if (rc != 0) {
        return -1;
      }
      pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
    }
    return 0;
  }

  if (glue_block_let_is_fixed_array_type(arena, block_ref, idx) != 0) {
    arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                      pipeline_block_let_type_ref(arena, block_ref, idx),
                                                      slot_off);
    if (arr_st == 0) {
      return 0;
    }
    return -1;
  }

  if (glue_block_let_is_simd_vector_type(arena, block_ref, idx) != 0) {
    vtype_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
    vst = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, slot_off, vtype_ref);
    if (vst == 0) {
      return 0;
    }
    if (vst == -1) {
      return -1;
    }
    glue_index_assign_addr_cache_clear();
    rc = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, vtype_ref, slot_off);
    if (rc == 0) {
      return 0;
    }
    if (rc == -1) {
      return -1;
    }
    rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    rc = glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, vtype_ref,
                                            slot_off, ta, init_ref, ctx);
    if (rc != 0) {
      return -1;
    }
    return 0;
  }

  slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref,
                                                       pipeline_block_let_type_ref(arena, block_ref, idx), ctx,
                                                       ta, slot_off);
  if (slice_st == 1) {
    return 0;
  }
  if (slice_st < 0) {
    return -1;
  }

  st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                           pipeline_block_let_type_ref(arena, block_ref, idx), slot_off);
  fprintf(stderr, "ELI struct_st=%d\n", st);
  if (st == 0) {
    return 0;
  }
  if (st == -1) {
    fprintf(stderr, "ELI fail struct\n");
    return -1;
  }

  init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
  /* ARRAY_LIT = 46 */
  if (init_ko == 46) {
    glue_index_assign_addr_cache_clear();
    rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
    if (rc != 0) {
      return -1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta);
    if (rc != 0) {
      return -1;
    }
    pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, init_ref, ctx);
    return 0;
  }

  ix_init = glue_try_block_let_index_init_from_assign_cache_elf_c(arena, elf_ctx, ctx, init_ref, ta);
  if (ix_init < 0) {
    return -1;
  }
  if (ix_init == 0) {
    glue_index_assign_addr_cache_clear();
    let_ty = pipeline_block_let_type_ref(arena, block_ref, idx);
    init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
    /* GLUE_TYPE_KIND_F32_ORD = 14; EXPR_LIT = 1 */
    if (let_ty > 0 && pipeline_type_kind_ord_at(arena, let_ty) == 14 && init_ko == 1) {
      init_f32_lit = 1;
      rc = glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, init_ref, ta, let_ty, 0);
      fprintf(stderr, "ELI f32lit rc=%d ty=%d\n", rc, let_ty);
    } else {
      rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
      fprintf(stderr, "ELI expr rc=%d ko=%d ty=%d\n", rc, init_ko, let_ty);
    }
    if (rc != 0) {
      fprintf(stderr, "ELI fail emit\n");
      return -1;
    }
  }

  let_ty2 = pipeline_block_let_type_ref(arena, block_ref, idx);
  fprintf(stderr, "ELI let_ty2=%d kind=%d f32lit=%d\n", let_ty2,
          let_ty2 > 0 ? pipeline_type_kind_ord_at(arena, let_ty2) : -1, init_f32_lit);
  if (let_ty2 > 0) {
    if (pipeline_type_kind_ord_at(arena, let_ty2) == 14) {
      if (ix_init == 0 && init_f32_lit == 0) {
        rc = glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, let_ty2, init_ref, ta);
        if (rc != 0) {
          fprintf(stderr, "ELI fail demote\n");
          return -1;
        }
      }
      rc = backend_enc_store_eax_to_rbp_arch(elf_ctx, slot_off, ta);
      fprintf(stderr, "ELI store_eax rc=%d ta=%d off=%d elf=%p\n", rc, ta, slot_off, (void *)elf_ctx);
      if (rc != 0) {
        fprintf(stderr, "ELI fail store_eax\n");
        return -1;
      }
      glue_binop_var_slot_cache_kill_def_at_slot(slot_off);
      glue_live_fwd_forward_after_def(arena, ctx, slot_off, init_ref);
      fprintf(stderr, "ELI f32 ok\n");
      return 0;
    }
  }

  src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
  if (pipeline_expr_kind_ord_at(arena, init_ref) == 3) {
    vl = pipeline_expr_var_name_len(arena, init_ref);
    if (vl > 0 && vl <= 63) {
      pipeline_expr_var_name_into(arena, init_ref, &g_w1010_emit_let_vn[0]);
      bt = pipeline_block_resolve_var_type_ref(arena, block_ref, &g_w1010_emit_let_vn[0], vl);
      if (bt > 0) {
        src_ty = bt;
      }
    }
  }
  rc = glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, let_ty2, src_ty, ta);
  if (rc != 0) {
    return -1;
  }
  rc = glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, let_ty2, slot_off, ta,
                                          init_ref, ctx);
  if (rc != 0) {
    return -1;
  }
  glue_binop_var_slot_cache_kill_def_at_slot(slot_off);
  glue_live_fwd_forward_after_def(arena, ctx, slot_off, init_ref);
  return 0;
}
