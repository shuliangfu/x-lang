/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t pipeline_asm_emit_as_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
}


mp_finish_seed(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
}
