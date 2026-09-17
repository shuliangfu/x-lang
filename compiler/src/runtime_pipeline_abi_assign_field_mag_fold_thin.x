// Thin pure: FIELD frame-mag fold over chain (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_field_layout_offset_for_base_field(a: *u8, m: *u8, base_ref: i32, field_name: *u8, flen: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, field_off: i32, ta: i32): i32;

/**
 * Fold glue_struct_field_frame_mag_c from VAR slot through FIELD chain.
 * Writes final off into out_off[0]; returns updated hit (0 cleared on fail).
 * @return i32 — hit (0 or hit_in)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_mag_fold_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, off_in: i32, hit_in: i32, ta: i32, out_off: *i32): i32 {
  unsafe {
    let walk_i: i32 = 0;
    let fa_ref: i32 = 0;
    let base_ref: i32 = 0;
    let vlen: i32 = 0;
    let vname: u8[256] = [];
    let rty: i32 = 0;
    let off: i32 = 0;
    let hit: i32 = 0;
    off = off_in;
    hit = hit_in;
    walk_i = chain_n - 1;
    while (walk_i >= 0 && hit != 0) {
      fa_ref = chain_fa[walk_i];
      base_ref = pipeline_expr_field_access_base_ref(arena, fa_ref);
      vlen = pipeline_expr_field_access_name_len(arena, fa_ref);
      rty = 0 - 1;
      if (vlen > 0) {
        if (vlen <= 255) {
          pipeline_expr_field_access_name_into(arena, fa_ref, &vname[0]);
          rty = glue_field_layout_offset_for_base_field(arena, mod, base_ref, &vname[0], vlen);
        }
      }
      if (rty < 0) {
        rty = glue_field_access_effective_offset_c(arena, mod, fa_ref);
      }
      if (rty < 0) {
        hit = 0;
      } else {
        off = glue_struct_field_frame_mag_c(off, rty, ta);
        if (off < 0) {
          hit = 0;
        }
      }
      walk_i = walk_i - 1;
    }
    out_off[0] = off;
    return hit;
  }
}
