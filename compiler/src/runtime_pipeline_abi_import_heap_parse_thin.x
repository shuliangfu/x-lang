// Thin pure: import_heap bind + parse finish (wave487).
// G.7: part of pipeline_load_import_from_disk_c (peer-flat).
// wave487: tip U-complete. PRODUCT inject: BOTH PREFER (stamp w487).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, path: *u8, len: i32): void;
export extern function pipeline_bind_import_dep_buffers(ctx: *u8, import_idx: i32): void;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function ast_pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern "C" function free(p: *u8): void;

/**
 * Set import path; bind dep buffers; parse prep into dep module; free prep.
 * wave487: no-local — re-call arena/module; ban mid `x=call()`.
 * @return i32 — 0 ok; -10 parse fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function import_heap_parse_elf_c(ctx: *u8, import_idx: i32, path_buf: *u8, path_len: i32, out_prep: *u8, out_len: *u8): i32 {
  unsafe {
    if (path_len > 0) {
      ast_pipeline_dep_ctx_set_import_path(ctx, import_idx, path_buf, path_len);
    }
    pipeline_bind_import_dep_buffers(ctx, import_idx);
    if (pipeline_parse_into_buf(pipeline_dep_ctx_arena_at(ctx, import_idx), ast_pipeline_dep_ctx_module_at(ctx, import_idx), pipe_load_ptr_slot(out_prep, 0), xlang_size_slot_get(out_len, 0) as i32) != 0) {
      free(pipe_load_ptr_slot(out_prep, 0));
      return -10;
    }
    free(pipe_load_ptr_slot(out_prep, 0));
    return 0;
  }
}
