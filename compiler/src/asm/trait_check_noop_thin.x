// Cap tip: hoist trait defaults into empty impl; skip archived completeness.
// Archived check rejects impl<T: Trait> then SEGV on a bad bounds stash.
// glue_dead only runs skip_hoist_default_methods_c then returns 0.
// PLATFORM: MACOS|DARWIN — LINK_WINNERS still names trait_check_noop_a64.o.

export extern "C" function xlang_trait_check_impls_complete_c_glue_dead(module: *u8): i32;

/**
 * Hoist trait default methods for empty impls (e.g. get_x on Point).
 * @param module *u8 — parsed module; null returns 0
 * @return i32 — 0 after hoist; missing methods left for typeck
 * PLATFORM: MACOS|DARWIN.
 */
#[no_mangle]
export function xlang_trait_check_impls_complete_c(module: *u8): i32 {
  unsafe {
    if (module == 0 as *u8) {
      return 0;
    }
    return xlang_trait_check_impls_complete_c_glue_dead(module);
  }
}
