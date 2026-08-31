// 10.3.1 slice14: direct INDEX Cap/TYPE_FN call `fs[0](x)` (no let bind).
// typeck must stamp CALL ret from INDEX TYPE_FN elem; asm Cap blr loads INDEX.
// Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * Call through a TYPE_FN array INDEX without an intermediate local.
 * @return i32 - 42 on success
 * PLATFORM: SHARED — Ubuntu gold asm path.
 */
function main(): i32 {
  let fs: [2]function(i32): i32 = [helper_add_one, helper_add_one];
  return fs[0](41);
}
