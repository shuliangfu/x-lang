/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE named_layout unique */

/*
 * wave191 cold twins: MEMORY pass-by-addr (G.7 pure leave).
 * named_layout unique extracted above with the real .x body; leftover rest
 * does not compile this seed stub. pass_addr stays closed on leftover rest
 * (not unique). Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL named layout size.
 */
int32_t glue_call_param_named_struct_pass_addr_elf_c(void *arena, int32_t pty) {
  (void)arena;
  (void)pty;
  return 0;
}

/*
 * wave192 cold twins: dual-GP width + param home width + func return size
 * (G.7 pure leave). Freestanding-safe stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL dual-GP / home / return sizing.
 */
int32_t glue_sysv_dual_gp_byte_size_c(void *arena, int32_t ty_ref) {
  (void)arena;
  (void)ty_ref;
  return 0;
}

int32_t glue_func_param_home_width_c(void *arena, void *mod, int32_t func_index, int32_t param_index) {
  (void)arena;
  (void)mod;
  (void)func_index;
  (void)param_index;
  return 8;
}

#endif /* close wave178 FROM_X for leftover-PE glue_func_return unique */
