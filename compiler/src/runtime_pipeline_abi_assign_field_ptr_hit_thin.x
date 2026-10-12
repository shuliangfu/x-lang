// Thin pure: FIELD mid-chain *T hit clear gate (wave441/w475).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// wave475: while+locals tip U=0/2 → gate+step recurse. Tip U=1/1.
//   PRODUCT inject: LINUX PREFER (stamp w475); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_field_ptr_hit_step_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit: i32, walk_i: i32): i32;

/**
 * Clear hit when any mid-chain FIELD has pointer type (ltk==9).
 * wave475: delegates to step peer (walk_i starts at 1).
 * @return i32 — updated hit (0 or hit_in)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_ptr_hit_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit_in: i32): i32 {
  unsafe {
    return glue_emit_assign_field_ptr_hit_step_elf_c(arena, mod, chain_fa, chain_n, hit_in, 1);
  }
}
