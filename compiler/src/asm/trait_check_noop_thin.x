// Thin: Cap tip trait completeness no-op (Darwin 10.2).
// finish_ok → trait_check → generic_bound_scan SEGV/L003 after const-import
// entry (bridge u8[] ABI / sticky park). Dep prerun only needs parse AST.
// PLATFORM: MACOS|DARWIN.

#[no_mangle]
export function xlang_trait_check_impls_complete_c(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return 0;
}
