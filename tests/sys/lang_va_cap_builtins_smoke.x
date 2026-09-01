/**
 * Cap 10.7.1 language slice7–9 smoke: va Cap builtins + arity + host-cc/runtime.
 *
 * Typeck sees export-extern faces; codegen rewrites call sites to xlang_va_*.
 * VaList lowers as xlang_va_list (emit_header includes xlang_va_cap.h).
 * slice8: call sites may pass trailing args beyond named formals.
 * slice9: -E host-cc run must exit 42 (first variadic i32).
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
 * Variadic probe: return the first extra i32 after n.
 * @param n Named last parameter (required by Cap va_start).
 * @return First variadic i32 (host-cc/runtime expects 42 from main).
 */
export function lang_va_cap_probe(n: i32, ...): i32 {
  let ap: VaList;
  va_start(ap, n);
  let v: i32 = va_arg_i32(ap);
  va_end(ap);
  return v;
}

/**
 * Entry: pass one trailing variadic literal (slice8 arity Cap).
 */
export function main(): i32 {
  return lang_va_cap_probe(1, 42);
}
