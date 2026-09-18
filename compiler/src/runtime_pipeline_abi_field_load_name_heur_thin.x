// Thin pure: field_load is_some/is_none heuristic + default 8 (wave485).
// G.7: part of pipeline_expr_field_access_load_byte_sz (peer-flat).
// wave485: tip U-complete. PRODUCT inject: LINUX PREFER (stamp w485).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function field_load_sz_bytes_eq(a: *u8, b: *u8, n: i32): i32;

/**
 * is_some / is_none name heuristic; else default load width 8.
 * wave485: no-local — flat early exits.
 * @return i32 — 1 or 8
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function field_load_sz_name_heur_elf_c(field_name: *u8, flen: i32): i32 {
  unsafe {
    let nm_is_some: u8[7] = [105, 115, 95, 115, 111, 109, 101];
    let nm_is_none: u8[7] = [105, 115, 95, 110, 111, 110, 101];
    if (flen != 7) {
      return 8;
    }
    if (field_load_sz_bytes_eq(field_name, &nm_is_some[0], 7) != 0) {
      return 1;
    }
    if (field_load_sz_bytes_eq(field_name, &nm_is_none[0], 7) != 0) {
      return 1;
    }
    return 8;
  }
}
