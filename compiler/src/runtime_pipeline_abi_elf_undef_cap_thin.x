// Strong bodies for the ELF undef workspace.
//
// runtime_pipeline_abi.x and runtime_pipeline_abi_elf_ctx_thin.x already
// return 2048 from pipe_elf_undef_cap and size the rows at 2048 x 128
// plus 2048 x i32. The linked egg was built earlier: pipe_elf_undef_cap
// is weak and returns 256, and g_pipe_elf_ws_undef_names / _lens are
// local BSS of 32768 and 1024 bytes. Those two locals are reached only
// from pipe_elf_ws_undef_name_row, pipe_elf_ws_undef_len_at, and
// pipe_elf_ws_undef_len_set (three R_X86_64_PC32 relocs, all inside
// those functions). pipeline_elf_write_o_standard_to_buf_c calls the
// cap once and the accessors for every undef row.
//
// Raising only the cap would write past the 256-row BSS. This file is
// the strong definition of the same four symbols, with the 2048-row
// storage the .x authorities already describe. It is not a second cap
// policy and it does not rebuild the egg. g05_relink_env.sh compiles
// it with the current product and links it ahead of pabi.
//
// A name that still does not fit (more than 2048 unique undefs, or an
// empty name) is unchanged egg behavior: the writer leaves sym_idx 0,
// which is the .text section symbol. PLATFORM: SHARED.

export extern function pipe_elf_bss_load_i32(blob: *u8, idx: i32): i32;
export extern function pipe_elf_bss_store_i32(blob: *u8, idx: i32, v: i32): void;

// 2048 rows x 128 bytes. Local to this TU. The egg arrays stay 256 rows
// and are not referenced once these strong accessors win the link.
let g_w1572_undef_names: u8[262144] = [];
// 2048 rows x i32, stored little-endian in a flat u8 buffer.
let g_w1572_undef_lens: u8[8192] = [];

/**
 * ELF undef-symbol cap used by pipeline_elf_write_o_standard_to_buf_c.
 * @return i32 — 2048 unique undefined names
 * Matches runtime_pipeline_abi.x::pipe_elf_undef_cap. The egg weak body
 * returns 256 and is not the linked body.
 * PLATFORM: SHARED — Linux first-wins, Darwin weak egg, Windows weaken.
 */
#[no_mangle]
export function pipe_elf_undef_cap(): i32 {
  return 2048;
}

/**
 * Address of undef-name row i (128 bytes, not necessarily NUL-terminated).
 * @param i i32 — row index; the writer only calls this for i in 0 .. cap
 * @return *u8 — pointer into this TU's 2048-row table
 * No bounds check, same as the egg accessor. i * 128 matches the egg shl 7.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_elf_ws_undef_name_row(i: i32): *u8 {
  return &g_w1572_undef_names[0] + ((i * 128) as usize);
}

/**
 * Load the stored byte length of undef-name row i.
 * @param i i32 — row index; negative returns 0 via pipe_elf_bss_load_i32
 * @return i32 — length in bytes
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_elf_ws_undef_len_at(i: i32): i32 {
  // The i32 load/store pair stays the egg authority. This TU only owns
  // the 2048-row buffer the load reads.
  unsafe {
    return pipe_elf_bss_load_i32(&g_w1572_undef_lens[0], i);
  }
}

/**
 * Store the byte length of undef-name row i.
 * @param i i32 — row index; negative is a no-op via pipe_elf_bss_store_i32
 * @param v i32 — length in bytes (the writer clamps a name to 128)
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_elf_ws_undef_len_set(i: i32, v: i32): void {
  unsafe {
    pipe_elf_bss_store_i32(&g_w1572_undef_lens[0], i, v);
  }
}
