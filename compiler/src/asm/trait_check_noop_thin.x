// Cap tip completeness entry: prefer hand-asm src/asm/trait_check_noop_a64.s
// (LINK_WINNER). Tip-compile of this .x collapses to mov w0,#0;ret and must
// not overwrite the hoist entry. glue_dead runs skip_hoist only.
// PLATFORM: MACOS|DARWIN — kept for docs / non-Cap paths; Cap tip uses .s.

export extern "C" function xlang_trait_check_impls_complete_c_glue_dead(module: *u8): i32;

/**
 * Hoist trait default methods for empty impls.
 * @param module *u8 — parsed module; null returns 0
 * @return i32 — 0 after hoist
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
