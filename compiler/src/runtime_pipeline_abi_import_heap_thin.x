// Thin pure: wave298/354/w487 M2 — import_heap Cap residual C→.x
// Heap import orch: resolve → read/prep → parse. No BSS. No FROM_X gate.
// G.7: bodies match mega pipeline_load_import_from_disk_c.
// wave487: peer-flat no-local (resolve/read_prep/parse+gate). Tip U-complete.
//   PRODUCT inject: BOTH PREFER (stamp w487).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function import_heap_resolve_elf_c(module: *u8, ctx: *u8, import_idx: i32, path_buf: *u8, cell: *u8): i32;
export extern function import_heap_read_prep_elf_c(ctx: *u8, out_prep: *u8, out_len: *u8): i32;
export extern function import_heap_parse_elf_c(ctx: *u8, import_idx: i32, path_buf: *u8, path_len: i32, out_prep: *u8, out_len: *u8): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Product import orch: disk → view → PP002 malloc prep → parse dep slot.
 * wave487: no-local — peer cascade + pipe cell for rc; ban mid `x=call()`.
 * @return i32 — 0 ok; negative fail codes (-7/-8/-9/-10)
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function pipeline_load_import_from_disk_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  unsafe {
    let path_buf: u8[128] = [];
    let out_prep: u8[8] = [];
    let out_len: u8[8] = [];
    let cell: u8[8] = [];

    if (module == (0 as *u8) || arena == (0 as *u8) || ctx == (0 as *u8) || import_idx < 0) {
      return -1;
    }
    pipe_store_i32_le(&cell[0], 4, import_heap_resolve_elf_c(module, ctx, import_idx, &path_buf[0], &cell[0]));
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return pipe_load_i32_le(&cell[0], 4);
    }
    pipe_store_i32_le(&cell[0], 4, import_heap_read_prep_elf_c(ctx, &out_prep[0], &out_len[0]));
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return pipe_load_i32_le(&cell[0], 4);
    }
    pipe_store_i32_le(&cell[0], 4, import_heap_parse_elf_c(ctx, import_idx, &path_buf[0], pipe_load_i32_le(&cell[0], 0), &out_prep[0], &out_len[0]));
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return pipe_load_i32_le(&cell[0], 4);
    }
    return 0;
  }
}
