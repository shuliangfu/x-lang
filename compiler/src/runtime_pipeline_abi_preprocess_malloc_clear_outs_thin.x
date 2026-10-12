// Thin pure: preprocess gate clear out slots (wave486).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave486: tip PREFER heal — split from setup (i64 compare tip PP002).
//   PRODUCT inject: tip PREFER (stamp w486); setup-family heal.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;

/**
 * Clear out_src / out_src_len slots to null/0.
 * wave486: no-local — tip-safe clears only.
 * @return i32 — 0
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_gate_clear_outs_elf_c(out_src: *u8, out_src_len: *u8): i32 {
  unsafe {
    if (out_src != (0 as *u8)) {
      xlang_ptr_slot_set(out_src, 0, 0 as *u8);
    }
    if (out_src_len != (0 as *u8)) {
      xlang_size_slot_set(out_src_len, 0, 0);
    }
    return 0;
  }
}
