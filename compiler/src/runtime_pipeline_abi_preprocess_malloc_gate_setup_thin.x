// Thin pure: preprocess gate setup — clear outs + validate raw_len (wave486).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave486: tip PREFER heal — peers for clear/validate (ban tip i32_max PP002).
//   PRODUCT inject: tip PREFER (stamp w486); setup-family heal.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function prep_gate_clear_outs_elf_c(out_src: *u8, out_src_len: *u8): i32;
export extern function prep_gate_validate_len_elf_c(raw_len: i64, path_diag: *u8, emit_diag: i32): i32;

/**
 * Clear out slots; reject negative / non-i32-range raw_len.
 * wave486: no-local — thin cascade to tip-safe peers.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_gate_setup_elf_c(raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    prep_gate_clear_outs_elf_c(out_src, out_src_len);
    return prep_gate_validate_len_elf_c(raw_len, path_diag, emit_diag);
  }
}
