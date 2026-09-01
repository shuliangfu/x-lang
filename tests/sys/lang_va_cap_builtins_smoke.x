/**
 * Cap 10.7.1 language slice7–13 smoke: va Cap builtins + arity + host-cc/runtime.
 *
 * Typeck sees export-extern faces; codegen rewrites call sites to xlang_va_*.
 * VaList lowers as xlang_va_list (emit_header includes xlang_va_cap.h).
 * slice8: call sites may pass trailing args beyond named formals.
 * slice9: -E host-cc run must exit 42 (first variadic i32).
 * slice13: also exercise va_arg_i64 + va_arg_ptr (asm Cap qword load).
 * slice14: typed turbofish va_arg<T>(ap) (G.7 size_of<T> type-arg sidecar).
 * slice16: va_arg<f32>/va_arg<f64> (XMM/NEON spill + C float→double promote).
 * PLATFORM: SHARED — L2 gate; Ubuntu gold.
 */

/**
 * Cap face: initialize ap after named last parameter.
 * Codegen emits xlang_va_start — not a real libc call.
 * @param ap Cap VaList local (host-C xlang_va_list).
 * @param last Named last parameter of the enclosing variadic function.
 */
export extern function va_start(ap: VaList, last: i32): void;

/**
 * Cap face: tear down ap.
 * @param ap Cap VaList local.
 */
export extern function va_end(ap: VaList): void;

/**
 * Cap face: fetch next i32 from ap (typed helper; full va_arg(ap,T) deferred).
 * @param ap Cap VaList local.
 * @return Next variadic i32.
 */
export extern function va_arg_i32(ap: VaList): i32;

/**
 * Cap face: fetch next i64 from ap (typed helper; SysV 8-byte slot).
 * @param ap Cap VaList local.
 * @return Next variadic i64.
 */
export extern function va_arg_i64(ap: VaList): i64;

/**
 * Cap face: fetch next pointer from ap (typed helper; SysV GP slot).
 * @param ap Cap VaList local.
 * @return Next variadic *u8.
 */
export extern function va_arg_ptr(ap: VaList): *u8;

/**
 * Cap 10.7.1 slice14: typed va_arg<T>(ap) — turbofish type arg, not C va_arg(ap,T).
 * Generic body is a typeck/host-C face only (never executed); call sites rewrite
 * to Cap xlang_va_arg. Null-deref return compiles for any T without panic FFI.
 * @param ap Cap VaList local (unused in the face body).
 * @return Next variadic value of T (i32 / i64 / *u8 / f32 / f64 this slice).
 */
export function va_arg<T>(ap: VaList): T {
  unsafe {
    let p: *T = 0 as *T;
    return *p;
  }
}

/**
 * Variadic probe: i32, i64, *i32, f32, f64 via typed va_arg<T>; expect exit 42.
 * @param n Named last parameter (required by Cap va_start).
 * @return 42 on success; 1..5 on mismatch of each slot.
 */
export function lang_va_cap_probe(n: i32, ...): i32 {
  let ap: VaList;
  va_start(ap, n);
  let a: i32 = va_arg<i32>(ap);
  let b: i64 = va_arg<i64>(ap);
  let p: *u8 = va_arg<*u8>(ap);
  let xf: f32 = va_arg<f32>(ap);
  let xd: f64 = va_arg<f64>(ap);
  va_end(ap);
  if (a != 42) {
    return 1;
  }
  if (b != 42) {
    return 2;
  }
  unsafe {
    let pi: *i32 = p as *i32;
    if (*pi != 7) {
      return 3;
    }
  }
  if ((xf as i32) != 1) {
    return 4;
  }
  if ((xd as i32) != 2) {
    return 5;
  }
  return 42;
}

/**
 * Entry: trailing i32, i64-slot literal, pointer, f32 1.0, f64 2.0.
 */
export function main(): i32 {
  let m: i32 = 7;
  let xf: f32 = 1.0;
  let xd: f64 = 2.0;
  return lang_va_cap_probe(1, 42, 42, &m, xf, xd);
}
