// Thin pure: wave298/354 M2 — import_heap Cap residual C→.x
// (was import_heap C strong overlay of pipeline_load_import_from_disk_c).
// Heap import orch: resolve path → runtime_read_file_view → PP002
// xlang_preprocess_raw_to_malloc → parse_into_buf. No BSS. No FROM_X gate.
// G.7: body matches runtime_pipeline_abi.x pipeline_load_import_from_disk_c
// + historic runtime_pipeline_abi_import_heap_thin.c / seed cold twin.
// wave354: wrap leftover extern slot get/set in unsafe (T001, same as w349);
// PRODUCT inject PREFER_ASM both ends after typeck green (class B path/view
// locals). Stamp w354.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function parser_copy_module_import_path64(module: *u8, i: i32, out: *u8): i32;
export extern function pipeline_resolve_path_x(ctx: *u8, import_path: *u8, path_len: i32): i32;
export extern function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8;
export extern function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern function runtime_release_file_view(view: *u8): void;
export extern function xlang_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, path: *u8, len: i32): void;
export extern function pipeline_bind_import_dep_buffers(ctx: *u8, import_idx: i32): void;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function ast_pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_parse_into_buf(arena: *u8, module: *u8, buf: *u8, buf_len: i32): i32;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function free(p: *u8): void;

/**
 * Product import orch: disk → view → PP002 malloc prep → parse dep slot.
 * Rejects prep_len > INT32_MAX; pin embed stays 4MiB (resolve_read separate).
 * All extern calls sit in unsafe (T001). PLATFORM: SHARED freestanding Cap
 * leave (wave354 .x thin · PREFER_ASM).
 */
#[no_mangle]
export function pipeline_load_import_from_disk_c(module: *u8, arena: *u8, ctx: *u8, import_idx: i32): i32 {
  let path_buf: u8[128];
  let path_len: i32 = 0;
  let path: *u8 = 0 as *u8;
  let view: u8[32];
  let z: i32 = 0;
  let view_rc: i32 = 0;
  let raw_data: *u8 = 0 as *u8;
  let raw_len: i64 = 0;
  let out_prep: u8[8];
  let out_len: u8[8];
  let prep_rc: i32 = 0;
  let prep: *u8 = 0 as *u8;
  let prep_len64: i64 = 0;
  let i32_max: i64 = 2147483647;
  let prep_len: i32 = 0;
  let dep_arena: *u8 = 0 as *u8;
  let dep_module: *u8 = 0 as *u8;
  let rr: i32 = 0;

  if (module == (0 as *u8) || arena == (0 as *u8) || ctx == (0 as *u8) || import_idx < 0) {
    return -1;
  }
  unsafe {
    memset(&path_buf[0], 0, 128 as usize);
    path_len = parser_copy_module_import_path64(module, import_idx, &path_buf[0]);
    rr = pipeline_resolve_path_x(ctx, &path_buf[0], path_len);
  }
  if (rr != 0) {
    return -7;
  }
  unsafe {
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
  }
  if (path == (0 as *u8)) {
    return -8;
  }
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  unsafe {
    view_rc = runtime_read_file_view(path, &view[0]);
  }
  if (view_rc != 0) {
    return -8;
  }
  /* PLATFORM: SHARED — slot get/set are extern; must be unsafe (T001). */
  unsafe {
    raw_data = xlang_ptr_slot_get(&view[0], 0);
    raw_len = xlang_size_slot_get(&view[0], 1);
    pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
    xlang_size_slot_set(&out_len[0], 0, 0);
  }
  unsafe {
    prep_rc = xlang_preprocess_raw_to_malloc(raw_data, raw_len, &out_prep[0], &out_len[0], path, 0 as *u8, 0);
    runtime_release_file_view(&view[0]);
  }
  if (prep_rc != 0) {
    return -9;
  }
  unsafe {
    prep = pipe_load_ptr_slot(&out_prep[0], 0);
    prep_len64 = xlang_size_slot_get(&out_len[0], 0);
  }
  if (prep == (0 as *u8) || prep_len64 < 0 || prep_len64 > i32_max) {
    if (prep != (0 as *u8)) {
      unsafe {
        free(prep);
      }
    }
    return -9;
  }
  prep_len = prep_len64 as i32;
  if (path_len > 0) {
    unsafe {
      ast_pipeline_dep_ctx_set_import_path(ctx, import_idx, &path_buf[0], path_len);
    }
  }
  unsafe {
    pipeline_bind_import_dep_buffers(ctx, import_idx);
    dep_arena = pipeline_dep_ctx_arena_at(ctx, import_idx);
    dep_module = ast_pipeline_dep_ctx_module_at(ctx, import_idx);
    rr = pipeline_parse_into_buf(dep_arena, dep_module, prep, prep_len);
    free(prep);
  }
  if (rr != 0) {
    return -10;
  }
  return 0;
}
