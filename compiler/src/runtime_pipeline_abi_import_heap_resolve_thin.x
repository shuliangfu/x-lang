// Thin pure: import_heap resolve path (wave487).
// G.7: part of pipeline_load_import_from_disk_c (peer-flat).
// wave487: tip U-complete. PRODUCT inject: BOTH PREFER (stamp w487).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function pipeline_resolve_path_x(ctx: *u8, import_path: *u8, path_len: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

/**
 * Copy import path into path_buf; resolve via ctx. Store path_len at cell[0].
 * wave487: no-local — pipe cell; ban `path_len=call()`.
 * @return i32 — 0 ok; -7 resolve fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function import_heap_resolve_elf_c(module: *u8, ctx: *u8, import_idx: i32, path_buf: *u8, cell: *u8): i32 {
  unsafe {
    memset(path_buf, 0, 128 as usize);
    pipe_store_i32_le(cell, 0, parser_copy_module_import_path64(module, import_idx, path_buf));
    if (pipeline_resolve_path_x(ctx, path_buf, pipe_load_i32_le(cell, 0)) != 0) {
      return -7;
    }
    return 0;
  }
}
