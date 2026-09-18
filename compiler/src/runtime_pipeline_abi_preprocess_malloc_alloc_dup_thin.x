// Thin pure: preprocess dup+slot finish from scratch (wave484/501).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave484: tip U=6/6; PRODUCT -E (byte-while tip PREFER → L2 SEGV).
// wave501: tip PREFER via memcpy (no byte-while); stamp w501.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern function pipeline_diag_preprocess_alloc_fail(path: *u8, what: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/**
 * Copy n bytes from scratch to owned NUL dup; set out slots; free scratch.
 * wave501: memcpy bulk copy — tip byte-while PREFER caused L2 SEGV @w488.
 *   malloc via call-as-arg to ptr_slot_set; ban mid `dup=malloc()`.
 * @param scratch *u8 — preprocess scratch buffer (freed on all paths)
 * @param n i32 — byte length from successful x_buf (arg, not call-assign)
 * @param out_src *u8 — optional ptr slot for owned output
 * @param out_src_len *u8 — optional size slot for length
 * @param path_diag *u8 — path for alloc_fail diag
 * @param emit_diag i32 — nonzero to emit alloc_fail
 * @return i32 — 0 ok; -1 alloc fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_alloc_dup_elf_c(scratch: *u8, n: i32, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    let slot: u8[16] = [];
    let what2: *u8 = "output buffer";
    let neg1: i32 = 0 - 1;
    xlang_ptr_slot_set(&slot[0], 0, malloc((n + 1) as usize));
    if (xlang_ptr_slot_get(&slot[0], 0) == (0 as *u8)) {
      free(scratch);
      if (emit_diag != 0) {
        pipeline_diag_preprocess_alloc_fail(path_diag, what2);
      }
      return neg1;
    }
    /* Bulk copy — tip byte-while PREFER product SEGV (w488); memcpy tipU-stable. */
    memcpy(xlang_ptr_slot_get(&slot[0], 0), scratch, n as usize);
    xlang_ptr_slot_get(&slot[0], 0)[n] = 0;
    free(scratch);
    if (out_src != (0 as *u8)) {
      xlang_ptr_slot_set(out_src, 0, xlang_ptr_slot_get(&slot[0], 0));
    }
    if (out_src_len != (0 as *u8)) {
      xlang_size_slot_set(out_src_len, 0, n as i64);
    }
    return 0;
  }
}
