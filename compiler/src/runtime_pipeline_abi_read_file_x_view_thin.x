// Thin pure: wave297 M2 — pipeline_read_file_x Cap residual C→.x
// (was read_file_x_view C thin overlay). Strong overlay of
// pipeline_read_file_x: runtime_read_file_view + reject >4MiB + memcpy
// into PipelineDepCtx loaded_buf. No BSS. No FROM_X gate.
// G.7: body matches seeds/runtime_pipeline_abi.from_x.c cold twin +
// historic runtime_pipeline_abi_read_file_x_view_thin.c.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_read_file_x_view_thin
// (ALLOW_E_REPLACE + stamp). Local FileView blob prefers host-cc C twin
// over pure-asm until view layout under xlang_asm -c is proven.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// XlangRuntimeFileView LP64 layout (match runtime_io_abi.x):
//   data*@0  length@8  needs_free@16  needs_munmap@20  (pad to 24+)

export extern function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8;
export extern function pipeline_dep_ctx_loaded_buf_ptr(ctx: *u8): *u8;
export extern function pipeline_dep_ctx_set_loaded_len(ctx: *u8, n: i64): void;
export extern function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern function runtime_release_file_view(view: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/* Pin embed wall (PipelineDepCtx loaded_buf cap). */
const W297_LOADED_CAP: i64 = 4194304;
/* FileView blob bytes (covers LP64 fields + pad). */
const W297_VIEW_BYTES: i32 = 32;
const W297_VIEW_OFF_LEN: i32 = 8;

/**
 * Load LP64 usize/i64 length from FileView blob at +8 (LE).
 * PLATFORM: SHARED — freestanding twin of raw_view.length read.
 */
function w297_view_length(view: *u8): i64 {
  let lo: i32 = 0;
  let hi: i32 = 0;
  let u: i64 = 0;
  unsafe {
    lo = pipe_load_i32_le(view, W297_VIEW_OFF_LEN);
    hi = pipe_load_i32_le(view, W297_VIEW_OFF_LEN + 4);
  }
  u = (lo as i64) & 4294967295;
  u = u | ((hi as i64) << 32);
  return u;
}

/**
 * Resolve-read embed fill: view whole file, reject >4MiB, copy into loaded_buf.
 * Product import orch heap-reads separately (does not use this face).
 * PLATFORM: SHARED freestanding Cap leave (wave297 .x thin · -E+$CC).
 */
#[no_mangle]
export function pipeline_read_file_x(ctx: *u8): i32 {
  let path: *u8 = 0 as *u8;
  let buf: *u8 = 0 as *u8;
  let view: u8[32];
  let data: *u8 = 0 as *u8;
  let len: i64 = 0;
  let rc: i32 = 0;
  if (ctx == (0 as *u8)) {
    return -1;
  }
  unsafe {
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
    buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  }
  if (path == (0 as *u8) || buf == (0 as *u8)) {
    return -1;
  }
  unsafe {
    memset(&view[0], 0, W297_VIEW_BYTES as usize);
    rc = runtime_read_file_view(path, &view[0]);
  }
  if (rc != 0) {
    return -1;
  }
  len = w297_view_length(&view[0]);
  if (len > W297_LOADED_CAP) {
    unsafe {
      runtime_release_file_view(&view[0]);
    }
    return -1;
  }
  if (len > 0) {
    unsafe {
      data = pipe_load_ptr_slot(&view[0], 0);
    }
    if (data == (0 as *u8)) {
      unsafe {
        runtime_release_file_view(&view[0]);
      }
      return -1;
    }
    unsafe {
      memcpy(buf, data, len as usize);
    }
  }
  unsafe {
    pipeline_dep_ctx_set_loaded_len(ctx, len);
    runtime_release_file_view(&view[0]);
  }
  return 0;
}
