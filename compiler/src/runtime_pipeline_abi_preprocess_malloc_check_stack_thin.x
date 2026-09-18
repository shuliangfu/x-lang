// Thin pure: preprocess if-stack check after x_buf ok (wave486/w488).
// G.7: part of xlang_preprocess_raw_to_malloc_impl (peer-flat).
// wave488: tip PREFER unlock (L2 green alone + with try_buf). Stamp w488.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function preprocess_if_stack_len(): i32;
export extern function pipeline_diag_preprocess_unclosed_if(path: *u8): void;
export extern "C" function free(p: *u8): void;

/**
 * After successful x_buf: reject unclosed #if stack.
 * wave486: no-local — fail when stack!=0; else return 0.
 * @return i32 — 0 ok; -1 fail (scratch freed)
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function prep_check_if_stack_elf_c(scratch: *u8, path_diag: *u8, emit_diag: i32): i32 {
  unsafe {
    if (preprocess_if_stack_len() != 0) {
      free(scratch);
      if (emit_diag != 0) {
        pipeline_diag_preprocess_unclosed_if(path_diag);
      }
      return -1;
    }
    return 0;
  }
}
