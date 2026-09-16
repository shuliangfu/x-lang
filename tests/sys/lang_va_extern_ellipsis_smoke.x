/**
 * Cap 10.7.1: extern "C" trailing `...` (skip_tl already sets is_variadic).
 * Host-C emit must include `, ...` on the extern prototype.
 * PLATFORM: SHARED — parse + codegen only.
 */

extern "C" function lang_va_extern_probe(fmt: *u8, ...): i32;

/**
 * Entry returns 0; call site not required for emit gate.
 */
export function main(): i32 {
  return 0;
}
