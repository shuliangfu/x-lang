// Thin: CodegenOutBuf length@0 / data@+4 (10.94). Cap tip pabi_weak.bak_cap
// still carries length@CAP writers; this thin first-wins after weaken.
// PLATFORM: SHARED freestanding.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Read CodegenOutBuf.length (i32 LE at offset 0).
 * @param out *u8 — opaque CodegenOutBuf*; null → 0
 * @return i32 — length field
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_out_buf_len(out: *u8): i32 {
  if (out == 0 as *u8) {
    return 0;
  }
  unsafe {
    return pipe_load_i32_le(out, 0);
  }
  return 0;
}

/**
 * Write CodegenOutBuf.length (clamp n < 0 → 0).
 * @param out *u8 — opaque CodegenOutBuf*; null → no-op
 * @param n i32 — new length
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_out_buf_set_len(out: *u8, n: i32): void {
  if (out == 0 as *u8) {
    return;
  }
  let v: i32 = n;
  if (v < 0) {
    v = 0;
  }
  unsafe {
    pipe_store_i32_le(out, 0, v);
  }
}
