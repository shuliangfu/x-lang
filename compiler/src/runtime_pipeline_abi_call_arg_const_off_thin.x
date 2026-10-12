// 记211 probe: nuclear always-miss call_arg stack_off.
// If early_c still 32768, Cap emit return-VAR does NOT use this face.
// PLATFORM: SHARED freestanding · tip pure overlay.

#[no_mangle]
export function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32 {
  return 0 - 1;
}
