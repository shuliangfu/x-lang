/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE glue_func_return unique */

/*
 * wave193 cold twins: param agg size + VAR dual-GP load (G.7 pure leave).
 * Freestanding-safe stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL formal agg / dual-GP load.
 */
int32_t glue_func_param_agg_byte_size_c(void *arena, void *mod, int32_t func_index, int32_t param_index) {
  (void)arena;
  (void)mod;
  (void)func_index;
  (void)param_index;
  return 8;
}

int32_t glue_load_var_as_value_to_rax_rdx_elf_c(void *elf_ctx, void *arena, void *ctx, int32_t var_expr_ref,
                                               int32_t off, int32_t ta) {
  (void)elf_ctx;
  (void)arena;
  (void)ctx;
  (void)var_expr_ref;
  (void)off;
  (void)ta;
  return -1;
}

#endif /* close wave178 FROM_X for leftover-PE glue_call_return unique */
