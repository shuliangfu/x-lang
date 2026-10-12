// Thin pure: field_load try layout_match when base is TYPE_NAMED (wave485).
// G.7: part of pipeline_expr_field_access_load_byte_sz (peer-flat).
// wave485: tip U-complete. PRODUCT inject: LINUX PREFER (stamp w485).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function field_load_sz_layout_match(a: *u8, m: *u8, base_tr: i32, field_name: *u8, flen: i32): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * If base_tr is TYPE_NAMED, run layout_match; else return 0.
 * wave485: no-local — early exit when kind!=8; layout via pipe_store.
 * @return i32 — load width or 0
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function field_load_sz_try_layout_elf_c(a: *u8, m: *u8, base_tr: i32, field_name: *u8, flen: i32): i32 {
  unsafe {
    let hit: u8[4] = [];
    if (base_tr <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(a, base_tr) != 8) {
      return 0;
    }
    pipe_store_i32_le(&hit[0], 0, field_load_sz_layout_match(a, m, base_tr, field_name, flen));
    return pipe_load_i32_le(&hit[0], 0);
  }
}
