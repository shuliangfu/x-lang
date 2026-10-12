// Thin pure: preprocess scratch malloc + alloc_fail diag (wave484).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave484: tip U-complete. wave500: PRODUCT tip PREFER (stamp w500).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function pipeline_diag_preprocess_alloc_fail(path: *u8, what: *u8): void;
export extern "C" function malloc(n: usize): *u8;

/**
 * Malloc scratch into slot[0]; optional alloc_fail diag on null.
 * wave484: no-local — malloc via call-as-arg to ptr_slot_set.
 * @param slot *u8 — ptr slot base
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_malloc_scratch_elf_c(buf_cap: i32, slot: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    let what: *u8 = "scratch buffer";
    xlang_ptr_slot_set(slot, 0, malloc(buf_cap as usize));
    if (xlang_ptr_slot_get(slot, 0) == (0 as *u8)) {
      if (emit_diag != 0) {
        pipeline_diag_preprocess_alloc_fail(path_diag, what);
      }
      return -1;
    }
    return 0;
  }
}
