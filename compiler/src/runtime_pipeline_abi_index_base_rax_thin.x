// SoA arr[i].field asks this function for the array address in x0.
// Darwin's phase1 hollow is `mov w0, #0; ret`. That reports success
// and leaves x0 alone, so the column add uses 0 or a leftover value
// and the field load is `ldrsw x0, [x0]` (SIGSEGV).
// The address itself is the existing lvalue emitter. This thin only
// replaces the hollow success. Locals, fields, and nested indexes
// stay that one path. PLATFORM: SHARED body. The hollow stub is
// MACOS|DARWIN and is already a weak definition.

export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;

/**
 * Put an INDEX base address in x0.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — encoder context; null returns -1
 * @param base_ref i32 — INDEX base expression; <= 0 returns -1
 * @param ctx *u8 — asm function context; null returns -1
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when x0 holds the address; the lvalue status otherwise
 * A null argument or a non-positive base does not call the lvalue
 * emitter. PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_try_index_var_or_field_base_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32
): i32 {
  if (arena == (0 as *u8)) {
    return 0 - 1;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
  }
}
