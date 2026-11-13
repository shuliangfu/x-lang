/**
 * Thin twin of call_dispatch_load_i32_le / call_dispatch_store_i32_le.
 * Root (s41): typool scale-8 on AsmFuncCtx.next_offset @4 → huge pend_off
 *   → lea rcx,[rbp-huge] for Win64 9–16B sret (Option_ptr_u8). See .c.
 * Prefer Windows host-cc of the .c for fold (idx8 of thins with calls AVs
 *   in typool va_cap; this thin has no calls but host-cc matches s40 holds).
 * PLATFORM: SHARED — byte LE i32 load/store; dual-host prove.
 */
#[no_mangle]
export function call_dispatch_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

#[no_mangle]
export function call_dispatch_store_i32_le(p: *u8, off: i32, v: i32): void {
  if (p == 0) { return; }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}
