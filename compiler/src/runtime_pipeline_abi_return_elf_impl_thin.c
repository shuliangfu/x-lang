/*
 * Host-gcc first-wins twin of pipeline_asm_emit_return_elf_impl (EXIT).
 *
 * DIG s259 Soft Cap (PLATFORM: WINDOWS host-cc):
 * Soft Cap return_sret.o already first-wins on Win, but tip-compiled
 * return_sret_thin carries a 0x7168 probe frame and SEGV (RIP=0) after
 * Soft Cap final_expr hands it a RETURN (kind 41). Match the small
 * EXIT shape from runtime_pipeline_abi_return_elf_impl_thin.x:
 * emit operand → scratch/cps cleanup → jmp layout tail_join.
 * Tip-land this host-cc twin ahead of return_sret + win_patch fold.
 *
 * G.7: complete existing emit_return EXIT authority; do not open a
 * second probe. sret Path A–C stay on leftover helpers via emit_expr.
 */
#include <stdint.h>

extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_index_scratch_spills_cleanup_all_elf_c(void *elf_ctx, int32_t ta);
extern int32_t glue_async_cps_emit_phase_reset(void *elf_ctx, int32_t ta);
extern int32_t pipe_load_i32_le(void *base, int32_t off);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, void *name, int32_t name_len, int32_t ta);

/**
 * EXPR_RETURN ELF emit: evaluate operand into rax then jmp function
 * tail_join. Completes mega EXIT that tipU/return_sret huge frames
 * smash under Soft Cap DIG (Win let final_expr → emit_return).
 *
 * @param arena ASTArena*
 * @param elf_ctx ElfCodegenCtx*
 * @param expr_ref EXPR_RETURN (kind 41)
 * @param ctx AsmFuncCtx*
 * @param ta 0 x86_64 / 1 arm64
 * @return 0 ok; -1 encoder/null/missing tail_join
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED EXIT contract.
 */
int32_t pipeline_asm_emit_return_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  void *ly;
  int32_t ret_op;
  int32_t rc;
  int32_t tj_len;
  uint8_t tj_lbl[256];
  int32_t ti;

  if (!arena || !elf_ctx || !ctx || expr_ref <= 0) {
    return -1;
  }
  ly = pipeline_asm_ctx_layout(ctx);
  ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (ret_op != 0) {
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    if (rc != 0) {
      return -1;
    }
  }
  rc = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  if (rc != 0) {
    return -1;
  }
  rc = glue_async_cps_emit_phase_reset(elf_ctx, ta);
  if (rc != 0) {
    return -1;
  }
  if (!ly) {
    return -1;
  }
  /* AsmFuncCtxLayout: tail_join name at 1392, length i32 at 1520. */
  tj_len = pipe_load_i32_le(ly, 1520);
  if (tj_len <= 0) {
    return -1;
  }
  ti = 0;
  while (ti < tj_len && ti < 128) {
    tj_lbl[ti] = ((const uint8_t *)ly)[1392 + ti];
    ti = ti + 1;
  }
  return backend_enc_jmp_arch(elf_ctx, tj_lbl, tj_len, ta);
}
