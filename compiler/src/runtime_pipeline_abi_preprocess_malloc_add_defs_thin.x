// Thin pure: preprocess add-defines loop.
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave609 M2: product path is PREFER_ASM (no host-cc for this TU).
//   w501 leftover BAN'd tip PREFER because assign_var smash hung the
//   `while (di < ndefines)` increment; w600 replaced assign_var with
//   gcc -E in the compiler, so this thin's own -backend asm -c now
//   stores di++ and fills the back-edge. Do not fall back to -E.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function preprocess_define_add(name: *u8): i32;

/**
 * Apply ndefines names from the preprocessor -D slot array.
 * @param defines *u8 — slot array of define-name pointers; null → no-op
 * @param ndefines i32 — slot count; loop di in [0, ndefines)
 * @return i32 — 0
 * PLATFORM: SHARED freestanding. Product inject is PREFER_ASM (wave609).
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
