// Thin pure: preprocess after-scratch run (x_buf+stack+dup) (wave484).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave484: tip U-complete. wave500: PRODUCT tip PREFER (stamp w500; dup peer stays -E).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// Takes ptr-slot (not scratch *) so gate avoids nested get-as-arg ABI risk.

export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function prep_try_x_buf_elf_c(raw: *u8, raw_len: i64, scratch: *u8, buf_cap: i32, cell: *u8, path_diag: *u8, emit_diag: i32): i32;
export extern function prep_check_if_stack_elf_c(scratch: *u8, path_diag: *u8, emit_diag: i32): i32;
export extern function prep_alloc_dup_elf_c(scratch: *u8, n: i32, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * After scratch in slot[0]: try x_buf, check if-stack, alloc dup.
 * wave484: no-local — re-call ptr_slot_get; ban mid `scratch=get()`.
 * @param slot *u8 — ptr slot holding scratch
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_after_scratch_elf_c(raw: *u8, raw_len: i64, slot: *u8, buf_cap: i32, n_cell: *u8, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    if (prep_try_x_buf_elf_c(raw, raw_len, xlang_ptr_slot_get(slot, 0), buf_cap, n_cell, path_diag, emit_diag) != 0) {
      return -1;
    }
    if (prep_check_if_stack_elf_c(xlang_ptr_slot_get(slot, 0), path_diag, emit_diag) != 0) {
      return -1;
    }
    return prep_alloc_dup_elf_c(xlang_ptr_slot_get(slot, 0), pipe_load_i32_le(n_cell, 0), out_src, out_src_len, path_diag, emit_diag);
  }
}
