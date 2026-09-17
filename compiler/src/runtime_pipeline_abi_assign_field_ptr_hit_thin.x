// Thin pure: FIELD mid-chain *T hit clear (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

/**
 * Clear hit when any mid-chain FIELD has pointer type (ltk==9).
 * @param chain_fa *i32 — FIELD refs [0..chain_n)
 * @param hit_in i32 — current hit
 * @return i32 — updated hit (0 or hit_in)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_ptr_hit_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit_in: i32): i32 {
  unsafe {
    let walk_i: i32 = 0;
    let ltr: i32 = 0;
    let ltk: i32 = 0;
    let hit: i32 = 0;
    hit = hit_in;
    walk_i = 1;
    while (walk_i < chain_n && hit != 0) {
      ltr = glue_field_access_field_type_ref_c(arena, mod, chain_fa[walk_i]);
      if (ltr > 0) {
        ltk = pipeline_type_kind_ord_at(arena, ltr);
        if (ltk == 9) {
          hit = 0;
        }
      }
      walk_i = walk_i + 1;
    }
    return hit;
  }
}
