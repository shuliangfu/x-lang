// Thin pure: preprocess x_buf try + fail diag (wave484/w488).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave488: tip PREFER unlock (L2 green alone + with check_stack). Stamp w488.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function preprocess_x_buf(src: *u8, src_len: i64, out: *u8, out_cap: i32): i32;
export extern function preprocess_if_stack_len(): i32;
export extern function pipeline_diag_preprocess_fail(path: *u8): void;
export extern function pipeline_diag_preprocess_directive_code(path: *u8, n: i32): void;
export extern function pipeline_diag_preprocess_unclosed_if(path: *u8): void;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function free(p: *u8): void;

/**
 * Run preprocess_x_buf into scratch; store length at cell[0].
 * On fail: free scratch, optional diag, return -1. On ok return 0.
 * wave484: no-local — pipe cell for len; ban `n=call()`.
 * @param cell *u8 — i32 cell base (off 0)
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_try_x_buf_elf_c(raw: *u8, raw_len: i64, scratch: *u8, buf_cap: i32, cell: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, preprocess_x_buf(raw, raw_len, scratch, buf_cap));
    if (pipe_load_i32_le(cell, 0) < 0) {
      free(scratch);
      if (emit_diag != 0) {
        if (pipe_load_i32_le(cell, 0) <= -2) {
          pipeline_diag_preprocess_directive_code(path_diag, pipe_load_i32_le(cell, 0));
        } else {
          if (preprocess_if_stack_len() != 0) {
            pipeline_diag_preprocess_unclosed_if(path_diag);
          } else {
            pipeline_diag_preprocess_fail(path_diag);
          }
        }
      }
      return -1;
    }
    return 0;
  }
}
