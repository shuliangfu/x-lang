// Thin pure: preprocess add-defines loop (wave486).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave486: PRODUCT inject **-E only** for this leaf (tip while hang; tip unroll
//   drops early-return → PP002). Other preprocess peers tip PREFER.
//   Stamp w486. PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function preprocess_define_add(name: *u8): i32;

/**
 * Apply ndefines names from defines slot array.
 * wave486: -E body (full while). Tip PREFER BAN this leaf only.
 * @return i32 — 0
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_add_defines_elf_c(defines: *u8, ndefines: i32): i32 {
  unsafe {
    let di: i32 = 0;
    if (defines == (0 as *u8)) {
      return 0;
    }
    while (di < ndefines) {
      if (xlang_ptr_slot_get(defines, di) != (0 as *u8)) {
        preprocess_define_add(xlang_ptr_slot_get(defines, di));
      }
      di = di + 1;
    }
    return 0;
  }
}
