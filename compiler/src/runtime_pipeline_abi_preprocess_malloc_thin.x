// Thin pure: wave299/333/w484 M2 — preprocess_malloc Cap residual C→.x
// PP002 heap scratch gate: malloc floor 4MiB; peers for setup/scratch/defines/after.
// No FROM_X gate. G.7: bodies match mega xlang_preprocess_raw_to_malloc_impl.
// wave486: peer-flat no-local. Tip U-complete.
// wave500: PRODUCT tip PREFER dispatcher (stamp w500; add/dup peers stay -E).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function preprocess_define_reset(): void;
export extern function prep_gate_setup_elf_c(raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32;
export extern function prep_malloc_scratch_elf_c(buf_cap: i32, slot: *u8, path_diag: *u8, emit_diag: i32): i32;
export extern function prep_add_defines_elf_c(defines: *u8, ndefines: i32): i32;
export extern function prep_after_scratch_elf_c(raw: *u8, raw_len: i64, slot: *u8, buf_cap: i32, n_cell: *u8, out_src: *u8, out_src_len: *u8, path_diag: *u8, emit_diag: i32): i32;

/**
 * PP002 heap preprocess gate — peers for setup / scratch / defines / after.
 * wave486: no-local — thin cascade; ban nested get-as-arg on long call.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function xlang_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32 {
  unsafe {
    let need: i32 = 0;
    let buf_cap: i32 = 4194304;
    let slot: u8[16] = [];
    let n_cell: u8[4] = [];

    if (prep_gate_setup_elf_c(raw_len, out_src, out_src_len, path_diag, emit_diag) != 0) {
      return -1;
    }
    need = raw_len as i32;
    if (need > buf_cap) {
      buf_cap = need;
    }
    if (prep_malloc_scratch_elf_c(buf_cap, &slot[0], path_diag, emit_diag) != 0) {
      return -1;
    }
    preprocess_define_reset();
    if (prep_add_defines_elf_c(defines, ndefines) != 0) {
      return -1;
    }
    if (prep_after_scratch_elf_c(raw, raw_len, &slot[0], buf_cap, &n_cell[0], out_src, out_src_len, path_diag, emit_diag) != 0) {
      return -1;
    }
    return 0;
  }
}
