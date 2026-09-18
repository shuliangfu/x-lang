// Thin pure: wave297/352/519 M2 — pipeline_read_file_x Cap residual C→.x
// (was read_file_x_view C thin overlay). Strong overlay of
// pipeline_read_file_x: runtime_read_file_view + reject >4MiB + memcpy
// into PipelineDepCtx loaded_buf. No FROM_X gate.
// G.7: body matches seeds/runtime_pipeline_abi.from_x.c cold twin +
// historic runtime_pipeline_abi_read_file_x_view_thin.c.
// PRODUCT inject wave352: PREFER_ASM both ends (class B FileView).
// wave519: tip CG002 heal — BSS FileView (ban stack u8[32]) + pipe-cell
//   mid `path=/buf=/rc=/data=call()`; tipU Soft Cap; stamp → w519;
//   tip PRODUCT reinject HARD BAN if PREFER poisons (keep prior overlay).
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
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/* Pin embed wall (PipelineDepCtx loaded_buf cap). */
const W297_LOADED_CAP: i64 = 4194304;
/* FileView blob bytes (covers LP64 fields + pad). */
const W297_VIEW_BYTES: i32 = 32;
const W297_VIEW_OFF_LEN: i32 = 8;

/* wave519: BSS FileView — tip CG002 on stack u8[32] + label patches. */
let g_w519_file_view: u8[32] = [];

/**
 * Load LP64 usize/i64 length from FileView blob at +8 (LE).
 * PLATFORM: SHARED — freestanding twin of raw_view.length read.
 */
function w297_view_length(view: *u8): i64 {
  let locell: u8[4] = [];
  let hicell: u8[4] = [];
  let u: i64 = 0;
  unsafe {
    pipe_store_i32_le(&locell[0], 0, pipe_load_i32_le(view, W297_VIEW_OFF_LEN));
    pipe_store_i32_le(&hicell[0], 0, pipe_load_i32_le(view, W297_VIEW_OFF_LEN + 4));
    u = (pipe_load_i32_le(&locell[0], 0) as i64) & 4294967295;
    u = u | ((pipe_load_i32_le(&hicell[0], 0) as i64) << 32);
  }
  return u;
}

/**
 * Resolve-read embed fill: view whole file, reject >4MiB, copy into loaded_buf.
 * wave519: ban mid `path=/buf=/rc=/data=call()`; pipe-cell + BSS view.
 * Product import orch heap-reads separately (does not use this face).
 * PLATFORM: SHARED freestanding Cap leave (wave352/519 .x thin).
 */
#[no_mangle]
export function pipeline_read_file_x(ctx: *u8): i32 {
  let pcell: u8[8] = [];
  let bcell: u8[8] = [];
  let rccell: u8[4] = [];
  let dcell: u8[8] = [];
  let len: i64 = 0;
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_dep_ctx_path_buf_ptr(ctx));
    pipe_store_ptr_slot(&bcell[0], 0, pipeline_dep_ctx_loaded_buf_ptr(ctx));
    if (pipe_load_ptr_slot(&pcell[0], 0) == (0 as *u8)
      || pipe_load_ptr_slot(&bcell[0], 0) == (0 as *u8)) {
      return 0 - 1;
    }
    memset(&g_w519_file_view[0], 0, W297_VIEW_BYTES as usize);
    pipe_store_i32_le(&rccell[0], 0, runtime_read_file_view(
      pipe_load_ptr_slot(&pcell[0], 0), &g_w519_file_view[0]
    ));
    if (pipe_load_i32_le(&rccell[0], 0) != 0) {
      return 0 - 1;
    }
    len = w297_view_length(&g_w519_file_view[0]);
    if (len > W297_LOADED_CAP) {
      runtime_release_file_view(&g_w519_file_view[0]);
      return 0 - 1;
    }
    if (len > 0) {
      pipe_store_ptr_slot(&dcell[0], 0, pipe_load_ptr_slot(&g_w519_file_view[0], 0));
      if (pipe_load_ptr_slot(&dcell[0], 0) == (0 as *u8)) {
        runtime_release_file_view(&g_w519_file_view[0]);
        return 0 - 1;
      }
      memcpy(
        pipe_load_ptr_slot(&bcell[0], 0),
        pipe_load_ptr_slot(&dcell[0], 0),
        len as usize
      );
    }
    pipeline_dep_ctx_set_loaded_len(ctx, len);
    runtime_release_file_view(&g_w519_file_view[0]);
  }
  return 0;
}
