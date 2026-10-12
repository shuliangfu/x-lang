// Thin pure: import_heap bind + parse finish (wave487/w509).
// G.7: part of pipeline_load_import_from_disk_c (peer-flat).
// wave487: tip U-complete. PRODUCT inject: BOTH PREFER (stamp w487).
// wave509: tipU 6/7 → 7/7 — `xlang_size_slot_get(...) as i32` nested arg
//   drops U; i64 wrapper (no cast) + pipe cell for buf_len.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, path: *u8, len: i32): void;
export extern function pipeline_bind_import_dep_buffers(ctx: *u8, import_idx: i32): void;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function ast_pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function free(p: *u8): void;

/**
 * Load size-slot i64 without cast (tip keeps U; cast-on-call drops).
 * @param arr *u8 — size-slot array base
 * @return i64 — slot 0 value
 * PLATFORM: SHARED — wave509 tipU heal helper.
 */
function w509_size_slot(arr: *u8): i64 {
  unsafe {
    return xlang_size_slot_get(arr, 0);
  }
}

/**
 * Set import path; bind dep buffers; parse prep into dep module; free prep.
 * wave487: no-local — re-call arena/module; ban mid `x=call()`.
 * wave509: size via w509_size_slot + pipe cell (ban `get() as i32` nested).
 * @return i32 — 0 ok; -10 parse fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function import_heap_parse_elf_c(ctx: *u8, import_idx: i32, path_buf: *u8, path_len: i32, out_prep: *u8, out_len: *u8): i32 {
  unsafe {
    let cell: u8[4] = [];
    if (path_len > 0) {
      ast_pipeline_dep_ctx_set_import_path(ctx, import_idx, path_buf, path_len);
    }
    pipeline_bind_import_dep_buffers(ctx, import_idx);
    /* tip drops U when size_slot_get is cast-nested in parse_into_buf args. */
    pipe_store_i32_le(&cell[0], 0, w509_size_slot(out_len) as i32);
    if (pipeline_parse_into_buf(pipeline_dep_ctx_arena_at(ctx, import_idx), ast_pipeline_dep_ctx_module_at(ctx, import_idx), pipe_load_ptr_slot(out_prep, 0), pipe_load_i32_le(&cell[0], 0)) != 0) {
      free(pipe_load_ptr_slot(out_prep, 0));
      return -10;
    }
    free(pipe_load_ptr_slot(out_prep, 0));
    return 0;
  }
}
