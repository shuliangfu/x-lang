// Thin pure: import_heap read view + PP002 prep (wave487).
// G.7: part of pipeline_load_import_from_disk_c (peer-flat).
// wave487: tip U-complete. PRODUCT inject: BOTH PREFER (stamp w487).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8;
export extern function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern function runtime_release_file_view(view: *u8): void;
export extern function xlang_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern "C" function free(p: *u8): void;

/**
 * Read file view at ctx path; preprocess into out_prep/out_len slots.
 * wave487: no-local — re-call slot get; ban mid `x=call()`.
 * @return i32 — 0 ok; -8/-9 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function import_heap_read_prep_elf_c(ctx: *u8, out_prep: *u8, out_len: *u8): i32 {
  unsafe {
    let view: u8[32] = [];
    let z: i32 = 0;
    if (pipeline_dep_ctx_path_buf_ptr(ctx) == (0 as *u8)) {
      return -8;
    }
    while (z < 32) {
      view[z] = 0;
      z = z + 1;
    }
    if (runtime_read_file_view(pipeline_dep_ctx_path_buf_ptr(ctx), &view[0]) != 0) {
      return -8;
    }
    pipe_store_ptr_slot(out_prep, 0, 0 as *u8);
    xlang_size_slot_set(out_len, 0, 0);
    if (xlang_preprocess_raw_to_malloc(xlang_ptr_slot_get(&view[0], 0), xlang_size_slot_get(&view[0], 1), out_prep, out_len, pipeline_dep_ctx_path_buf_ptr(ctx), 0 as *u8, 0) != 0) {
      runtime_release_file_view(&view[0]);
      return -9;
    }
    runtime_release_file_view(&view[0]);
    if (pipe_load_ptr_slot(out_prep, 0) == (0 as *u8)) {
      return -9;
    }
    /* Reject negative or > INT32_MAX prep_len (ban tip i64↔i32 roundtrip). */
    if (xlang_size_slot_get(out_len, 0) < 0) {
      free(pipe_load_ptr_slot(out_prep, 0));
      return -9;
    }
    if (xlang_size_slot_get(out_len, 0) > 2147483647) {
      free(pipe_load_ptr_slot(out_prep, 0));
      return -9;
    }
    return 0;
  }
}
