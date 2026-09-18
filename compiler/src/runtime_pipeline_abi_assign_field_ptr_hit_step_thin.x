// Thin pure: FIELD mid-chain *T hit clear step (wave475).
// G.7: part of glue_emit_assign_field_ptr_hit_elf_c (peer-flat).
// wave475: recursive step replaces while+locals. Tip U=2/2.
//   PRODUCT inject: LINUX PREFER (stamp w475); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

/**
 * One mid-chain walk step — if FIELD type is PTR (ltk==9) clear hit; recurse.
 * wave475: no-local — type via re-call; self-recurse (no while).
 * @return i32 — updated hit
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_ptr_hit_step_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit: i32, walk_i: i32): i32 {
  unsafe {
    if (walk_i >= chain_n) {
      return hit;
    }
    if (hit == 0) {
      return 0;
    }
    if (glue_field_access_field_type_ref_c(arena, mod, chain_fa[walk_i]) > 0) {
      if (pipeline_type_kind_ord_at(arena, glue_field_access_field_type_ref_c(arena, mod, chain_fa[walk_i])) == 9) {
        return glue_emit_assign_field_ptr_hit_step_elf_c(arena, mod, chain_fa, chain_n, 0, walk_i + 1);
      }
    }
    return glue_emit_assign_field_ptr_hit_step_elf_c(arena, mod, chain_fa, chain_n, hit, walk_i + 1);
  }
}
