/**
 * Thin twin of w1545_win_mid_ret_call (logic matches the .c).
 * Root (s42): typool mid_ret post-call u8[8] scale-8 appends 48 00 00 00
 *   48 00 00 instead of 48 8B 50 08 / 48 8B 00 after a 16-byte sret call.
 * The Windows fold vehicle is the .c: it writes typool pend BSS (Lxml_*)
 *   so typool pend_is / emit_call_args / pend_rcx_emit stay coherent.
 *   Do not park a private BSS for those slots. idx8 of thins with calls
 *   AVs in typool va_cap; use host-cc of the .c.
 * PLATFORM: SHARED — packed u8 stores; dual-host prove.
 */
export extern function pipeline_asm_emit_call_sret_reg_shift_c(): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function w1545_win_mid_named_sz(arena: *u8, ty: i32): i32;
export extern function backend_call_dispatch_w1545_win_extern_slice_ret_sz(arena: *u8, expr_ref: i32, ty: i32): i32;
export extern function call_dispatch_load_i32_le(p: *u8, off: i32): i32;
export extern function call_dispatch_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function backend_call_dispatch_w1521_body(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, is_m: i32): i32;
export extern function pipeline_elf_ctx_append_bytes(elf_ctx: *u8, b: *u8, n: i32): i32;

/* typool pend_{expr,off,used} — Windows .c binds the Lxml_ BSS directly. */
export extern function w1545_pend_expr_get(): i32;
export extern function w1545_pend_expr_set(v: i32): void;
export extern function w1545_pend_off_get(): i32;
export extern function w1545_pend_off_set(v: i32): void;
export extern function w1545_pend_used_get(): i32;
export extern function w1545_pend_used_set(v: i32): void;

#[no_mangle]
export function backend_call_dispatch_w1545_win_mid_ret_call(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, is_m: i32): i32 {
  let ty: i32 = 0;
  let sz: i32 = 0;
  let cur: i32 = 0;
  let off: i32 = 0;
  let p_e: i32 = 0;
  let p_o: i32 = 0;
  let p_u: i32 = 0;
  let rc: i32 = 0;
  let used: i32 = 0;
  let b: u8[8] = [];
  if (ta != 0 || expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_asm_emit_call_sret_reg_shift_c() != 0) { return 0; }
    ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  sz = w1545_win_mid_named_sz(arena, ty);
  if (sz == 0) {
    sz = backend_call_dispatch_w1545_win_extern_slice_ret_sz(arena, expr_ref, ty);
  }
  if (sz == 0) { return 0; }
  cur = call_dispatch_load_i32_le(ctx, 4);
  if (cur < 8) { cur = 8; }
  off = cur + 16;
  call_dispatch_store_i32_le(ctx, 4, off);
  unsafe {
    p_e = w1545_pend_expr_get();
    p_o = w1545_pend_off_get();
    p_u = w1545_pend_used_get();
    w1545_pend_expr_set(expr_ref);
    w1545_pend_off_set(off);
    w1545_pend_used_set(0);
    rc = backend_call_dispatch_w1521_body(arena, elf_ctx, expr_ref, ctx, ta, is_m);
    used = w1545_pend_used_get();
    w1545_pend_expr_set(p_e);
    w1545_pend_off_set(p_o);
    w1545_pend_used_set(p_u);
  }
  if (rc != 0) { return 0 - 1; }
  if (used != 0) {
    b[0] = 72;
    b[1] = 139;
    b[2] = 80;
    b[3] = 8;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4) != 0) { return 0 - 1; }
    }
    b[0] = 72;
    b[1] = 139;
    b[2] = 0;
    unsafe {
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 3) != 0) { return 0 - 1; }
    }
  }
  return 1;
}
