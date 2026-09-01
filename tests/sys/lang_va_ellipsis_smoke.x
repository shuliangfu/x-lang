/**
 * Cap 10.7.1 language slice5 smoke: trailing `...` in a named-param list.
 * Host-C emit must include `, ...` in the prototype when is_variadic is set.
 * PLATFORM: SHARED — parse + codegen only (no va_start body yet).
 */

/**
 * Minimal variadic surface: one named formal then ellipsis.
 * @param n Named last parameter (required for future Cap va_start).
 * @return Constant 42 so the body typechecks without using the ellipsis.
 */
export function lang_va_ellipsis_probe(n: i32, ...): i32 {
  return 42;
}

/**
 * Entry: call with only the named arg (extra args optional later).
 */
export function main(): i32 {
  return lang_va_ellipsis_probe(1);
}
