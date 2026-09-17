// Thin pure: wave299/333 M2 — preprocess_malloc Cap residual C→.x
// (was preprocess_malloc C strong overlay of
// xlang_preprocess_raw_to_malloc_impl). PP002 heap scratch: malloc floor
// 4MiB (or raw_len), preprocess_x_buf, owned NUL dup out. No BSS.
// No FROM_X gate. G.7: body matches runtime_pipeline_abi.x
// xlang_preprocess_raw_to_malloc_impl + historic
// runtime_pipeline_abi_preprocess_malloc_thin.c / seed cold twin.
// PRODUCT inject: wave333 PREFER_ASM via pipeline_abi_inject_preprocess_malloc_thin
// (ALLOW_E_REPLACE + stamp). All extern calls in unsafe (T001 under pure-asm);
// no local fixed arrays — heap-only (was -E+$CC interim).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function preprocess_x_buf(src: *u8, src_len: i64, out: *u8, out_cap: i32): i32;
export extern function preprocess_define_reset(): void;
export extern function preprocess_define_add(name: *u8): i32;
export extern function preprocess_if_stack_len(): i32;
export extern function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function pipeline_diag_preprocess_fail(path: *u8): void;
export extern function pipeline_diag_preprocess_alloc_fail(path: *u8, what: *u8): void;
export extern function pipeline_diag_preprocess_directive_code(path: *u8, n: i32): void;
export extern function pipeline_diag_preprocess_unclosed_if(path: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;

/**
 * PP002 heap preprocess: scratch → preprocess_x_buf → owned NUL-terminated dup.
 * out_src / out_src_len are char** / size_t* bases as *u8 (slot 0).
 * Contract: all FFI/slot/diag callees run under unsafe (T001).
 * PLATFORM: SHARED freestanding Cap leave (wave333 PREFER_ASM · was wave299 -E).
 */
#[no_mangle]
export function xlang_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32 {
  let i32_max: i32 = 2147483647;
  let need: i32 = 0;
  let buf_cap: i32 = 4194304;
  let scratch: *u8 = 0 as *u8;
  let di: i32 = 0;
  let dname: *u8 = 0 as *u8;
  let n: i32 = 0;
  let stack_n: i32 = 0;
  let stack_after: i32 = 0;
  let dup: *u8 = 0 as *u8;
  let i: i32 = 0;
  let what: *u8 = "scratch buffer";
  let what2: *u8 = "output buffer";

  if (out_src != (0 as *u8)) {
    unsafe {
      xlang_ptr_slot_set(out_src, 0, 0 as *u8);
    }
  }
  if (out_src_len != (0 as *u8)) {
    unsafe {
      xlang_size_slot_set(out_src_len, 0, 0);
    }
  }
  if (raw_len < 0) {
    return -1;
  }
  if (raw_len > (i32_max as i64)) {
    if (emit_diag != 0) {
      unsafe {
        pipeline_diag_preprocess_fail(path_diag);
      }
    }
    return -1;
  }
  need = raw_len as i32;
  if (need > buf_cap) {
    buf_cap = need;
  }
  unsafe {
    scratch = malloc(buf_cap as usize);
  }
  if (scratch == (0 as *u8)) {
    if (emit_diag != 0) {
      unsafe {
        pipeline_diag_preprocess_alloc_fail(path_diag, what);
      }
    }
    return -1;
  }
  unsafe {
    preprocess_define_reset();
  }
  while (di < ndefines) {
    if (defines != (0 as *u8)) {
      unsafe {
        dname = xlang_ptr_slot_get(defines, di);
      }
      if (dname != (0 as *u8)) {
        unsafe {
          preprocess_define_add(dname);
        }
      }
    }
    di = di + 1;
  }
  unsafe {
    n = preprocess_x_buf(raw, raw_len, scratch, buf_cap);
  }
  if (n < 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      if (n <= -2) {
        unsafe {
          pipeline_diag_preprocess_directive_code(path_diag, n);
        }
      } else {
        unsafe {
          stack_n = preprocess_if_stack_len();
        }
        if (stack_n != 0) {
          unsafe {
            pipeline_diag_preprocess_unclosed_if(path_diag);
          }
        } else {
          unsafe {
            pipeline_diag_preprocess_fail(path_diag);
          }
        }
      }
    }
    return -1;
  }
  unsafe {
    stack_after = preprocess_if_stack_len();
  }
  if (stack_after != 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      unsafe {
        pipeline_diag_preprocess_unclosed_if(path_diag);
      }
    }
    return -1;
  }
  unsafe {
    dup = malloc((n + 1) as usize);
  }
  if (dup == (0 as *u8)) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      unsafe {
        pipeline_diag_preprocess_alloc_fail(path_diag, what2);
      }
    }
    return -1;
  }
  unsafe {
    while (i < n) {
      dup[i] = scratch[i];
      i = i + 1;
    }
    dup[n] = 0;
    free(scratch);
  }
  if (out_src != (0 as *u8)) {
    unsafe {
      xlang_ptr_slot_set(out_src, 0, dup);
    }
  }
  if (out_src_len != (0 as *u8)) {
    unsafe {
      xlang_size_slot_set(out_src_len, 0, n as i64);
    }
  }
  return 0;
}
