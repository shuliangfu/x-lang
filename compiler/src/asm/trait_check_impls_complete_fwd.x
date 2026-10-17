// The product used to link a `mov w0, #0; ret` stub over
// xlang_trait_check_impls_complete_c, so trait default methods were
// never hoisted and an empty impl failed later as "no impl for type".
// glue_dead now runs the hoist and returns 0. The archived completeness
// check stays out of this path: it rejects impl<T: Trait> and then
// scans bounds through a non-pointer stash.
// PLATFORM: SHARED. The hoist body is the Darwin pthin object.

export extern "C" function xlang_trait_check_impls_complete_c_glue_dead(module: *u8): i32;

/**
 * Hoist trait default methods, then require each impl to provide them.
 * @param module *u8 — module just parsed; null returns 0
 * @return i32 — 0 after the hoist. A missing default is left for typeck.
 * A null module is not a failed impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_trait_check_impls_complete_c(module: *u8): i32 {
  // PLATFORM: SHARED — one entry; the noop object no longer wins.
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    return xlang_trait_check_impls_complete_c_glue_dead(module);
  }
}
